const std = @import("std");
const mem = std.mem;
const CompileStep = std.build.CompileStep;
const InstallFileStep = std.build.InstallFileStep;
const MakeFilesystemStep = @import("mkfs/MakeFilesystemStep.zig");
const QemuRunStep = @import("mkfs/QemuRunStep.zig");

pub fn build(b: *std.build.Builder) !void {
    const target = std.zig.CrossTarget{
        .os_tag = .freestanding,
        .cpu_arch = .riscv64,
        .abi = .none,
    };

    const kernel_linker = "scripts/kernel.ld";
    const user_linker = "scripts/user.ld";

    const kernel_src = [_][]const u8{
        "kernel/entry.S", // Very first boot instructions.
        "kernel/start.c", // Early machine-mode boot code.
        "kernel/console.c", // Connect to the user keyboard and screen.
        "kernel/printf.c", // Formatted output to the console.
        "kernel/uart.c", // Serial-port console device driver.
        "kernel/kalloc.c", // Physical page allocator.
        "kernel/spinlock.c", // Locks that don’t yield the CPU.
        "kernel/string.c", // C string and byte-array library.
        "kernel/main.c", // Control initialization of other modules during boot.
        "kernel/vm.c", // Manage page tables and address spaces.
        "kernel/proc.c", // Processes and scheduling.
        "kernel/swtch.S", // Thread switching.
        "kernel/trampoline.S", // Assembly code to switch between user and kernel.
        "kernel/trap.c", // C code to handle and return from traps and interrupts.
        "kernel/syscall.c", // Dispatch system calls to handling function.
        "kernel/sysproc.c", // Process-related system calls.
        "kernel/bio.c", // Disk block cache for the file system.
        "kernel/fs.c", // File system.
        "kernel/log.c", // File system logging and crash recovery.
        "kernel/sleeplock.c", // Locks that yield the CPU.
        "kernel/file.c", // File descriptor support.
        "kernel/pipe.c", // Pipes.
        "kernel/exec.c", // exec() system call.
        "kernel/sysfile.c", // File-related system calls.
        "kernel/kernelvec.S", // Handle traps from kernel, and timer interrupts.
        "kernel/plic.c", // RISC-V interrupt controller.
        "kernel/virtio_disk.c", // Disk device driver.
    };

    const cflags = [_][]const u8{
        "-Wall",
        "-Werror",
        "-Wno-gnu-designator", // workaround for compiler error
        "-fno-omit-frame-pointer",
        "-gdwarf-2",
        "-MD",
        "-ggdb",
        "-ffreestanding",
        "-fno-common",
        "-nostdlib",
        "-mno-relax",
        "-fno-pie",
        "-fno-stack-protector",
        "-Wno-unused-but-set-variable", // workaround for compiler error
    };

    const kernel = b.addExecutable(.{
        .name = "kernel",
        .target = target,
        .optimize = std.builtin.Mode.ReleaseSmall,
    });
    kernel.addCSourceFiles(&kernel_src, &cflags);
    kernel.addIncludePath(".");
    kernel.setLinkerScriptPath(.{ .path = kernel_linker });
    kernel.code_model = .medium;
    kernel.install();
    kernel.strip = true;

    const user_progs = [_][]const u8{
        // "user/forktest.c", // ToDo: build forktest
        "user/cat.c",
        "user/echo.c",
        "user/grep.c",
        "user/init.c",
        "user/kill.c",
        "user/ln.c",
        "user/ls.c",
        "user/mkdir.c",
        "user/rm.c",
        "user/sh.c",
        "user/stressfs.c",
        "user/usertests.c",
        "user/grind.c",
        "user/wc.c",
        "user/zombie.c",
    };

    const ulib_src = [_][]const u8{
        "user/ulib.c",
        "user/usys.S",
        "user/printf.c",
        "user/umalloc.c",
    };

    const usys_install = try generateUsys(b);

    var artifacts = std.ArrayList(*CompileStep).init(b.allocator);
    inline for (user_progs) |src| {
        const exe_name = "_" ++ src["user/".len .. src.len - 2];
        const user_prog = b.addExecutable(.{
            .name = exe_name,
            .target = target,
            .optimize = std.builtin.Mode.ReleaseSmall,
        });
        user_prog.addCSourceFiles(&[_][]const u8{src} ++ ulib_src, &cflags);
        user_prog.addIncludePath(".");
        user_prog.setLinkerScriptPath(.{ .path = user_linker });
        user_prog.code_model = .medium;
        user_prog.install();
        user_prog.step.dependOn(&usys_install.step);
        try artifacts.append(user_prog);
    }
    const image = installFilesystem(b, artifacts, "fs.img");
    _ = qemuRun(b, kernel, image);
}

pub fn generateUsys(b: *std.build.Builder) !*InstallFileStep {
    const syscalls = [_][]const u8{
        "fork", // Create a process, return childΓÇÖs PID.
        "exit", // Terminate the current process; status reported to wait(). No return.
        "wait", // Wait for a child to exit; exit status in *status; returns child PID.
        "pipe", // Create a pipe, put read/write file descriptors in p[0] and p[1].
        "read", // Read n bytes into buf; returns number read; or 0 if end of file.
        "write", // Write n bytes from buf to file descriptor fd; returns n.
        "close", // Release open file fd.
        "kill", // Terminate process PID. Returns 0, or -1 for error.
        "exec", // Load a file and execute it with arguments; only returns if error.
        "open", // Open a file; flags indicate read/write; returns an fd (file descriptor).
        "mknod", // Create a device file.
        "unlink", // Remove a file.
        "fstat", // Place info about an open file into *st.
        "link", // Create another name (file2) for the file file1.
        "mkdir", // Create a new directory.
        "chdir", // Change the current directory.
        "dup", // Return a new file descriptor referring to the same file as fd.
        "getpid", // Return the current processΓÇÖs PID.
        "sbrk", // Grow processΓÇÖs memory by n bytes. Returns start of new memory.
        "sleep", // Pause for n clock ticks.
        "uptime",
    };

    var usys_file = try mem.concat(b.allocator, u8, &[_][]const u8{
        "# generated by build.zig - do not edit\n",
        "#include \"kernel/syscall.h\"\n",
    });
    defer b.allocator.free(usys_file);

    inline for (syscalls) |syscall| {
        usys_file = try mem.concat(b.allocator, u8, &[_][]const u8{
            usys_file,
            ".global " ++ syscall ++ "\n",
            syscall ++ ":\n",
            " li a7, SYS_" ++ syscall ++ "\n",
            " ecall\n ret\n",
        });
    }

    const write_usys = b.addWriteFile("usys.S", usys_file);
    const usys_install = b.addInstallFile(
        write_usys.getFileSource("usys.S").?,
        "../user/usys.S",
    );
    usys_install.step.dependOn(&write_usys.step);

    return usys_install;
}

/// Output filesystem image determined by filename
pub fn installFilesystem(b: *std.build.Builder, artifacts: std.ArrayList(*CompileStep), dest_filename: []const u8) *MakeFilesystemStep {
    const img = addMakeFilesystem(b, artifacts, dest_filename);
    b.getInstallStep().dependOn(&img.step);
    return img;
}

pub fn addMakeFilesystem(b: *std.build.Builder, artifacts: std.ArrayList(*CompileStep), dest_filename: []const u8) *MakeFilesystemStep {
    return MakeFilesystemStep.create(b, artifacts, dest_filename);
}

/// Run os with qemu
pub fn qemuRun(b: *std.build.Builder, kernel: *CompileStep, image: *MakeFilesystemStep) *QemuRunStep {
    const run_step = addQemuRun(b, kernel, image);
    b.getInstallStep().dependOn(&run_step.step);
    return run_step;
}

pub fn addQemuRun(b: *std.build.Builder, kernel: *CompileStep, image: *MakeFilesystemStep) *QemuRunStep {
    return QemuRunStep.create(b, kernel, image);
}
