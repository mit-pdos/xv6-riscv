const std = @import("std");
const mem = std.mem;
const build = std.build;
const Step = std.build.Step;
const Builder = std.build.Builder;
const CompileStep = std.build.CompileStep;
const MakeFilesystemStep = @import("MakeFilesystemStep.zig");
const RunStep = std.build.RunStep;

const fs = std.fs;
const process = std.process;
const EnvMap = process.EnvMap;

const QemuRunStep = @This();

pub const base_id = .emulatable_run;

const max_stdout_size = 1 * 1024 * 1024; // 1 MiB

step: Step,
builder: *Builder,

/// The kernel (executable) to be run by this step
kernel: *CompileStep,

/// The filesystem image for the os
image: *MakeFilesystemStep,

/// Set this to `null` to ignore the exit code for the purpose of determining a successful execution
expected_exit_code: ?u8 = 0,

/// Override this field to modify the environment
env_map: ?*EnvMap,

/// Set this to modify the current working directory
cwd: ?[]const u8,

stdout_action: RunStep.StdIoAction = .inherit,
stderr_action: RunStep.StdIoAction = .inherit,

pub fn create(builder: *Builder, kernel: *CompileStep, image: *MakeFilesystemStep) *QemuRunStep {
    std.debug.assert(kernel.kind == .exe);
    const self = builder.allocator.create(QemuRunStep) catch unreachable;

    self.* = .{
        .builder = builder,
        .step = Step.init(.emulatable_run, "Run os with qemu", builder.allocator, make),
        .kernel = kernel,
        .image = image,
        .env_map = null,
        .cwd = null,
    };
    self.step.dependOn(&kernel.step);
    self.step.dependOn(&image.step);

    return self;
}

fn make(step: *Step) !void {
    const self = @fieldParentPtr(QemuRunStep, "step", step);

    if (!self.builder.enable_qemu) {
        return;
    }

    var argv_list = std.ArrayList([]const u8).init(self.builder.allocator);
    defer argv_list.deinit();

    try argv_list.appendSlice(&[_][]const u8{
        "qemu-system-riscv64",
        "-machine",
        "virt",
        "-bios",
        "none",
        "-m",
        "128M",
        "-smp",
        "3",
        "-nographic",
        "-global",
        "virtio-mmio.force-legacy=false",
        "-device",
        "virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0",
    });

    const kernel_path = self.kernel.getOutputSource().getPath(self.builder);
    try argv_list.appendSlice(&[_][]const u8{
        "-kernel",
        kernel_path,
    });

    const image_path = self.image.getOutputSource().getPath(self.builder);
    var drive_arg = try mem.concat(self.builder.allocator, u8, &[_][]const u8{
        "file=",
        image_path,
        ",if=none,format=raw,id=x0",
    });
    defer self.builder.allocator.free(drive_arg);

    try argv_list.appendSlice(&[_][]const u8{
        "-drive",
        drive_arg,
    });

    try RunStep.runCommand(
        argv_list.items,
        self.builder,
        self.expected_exit_code,
        self.stdout_action,
        self.stderr_action,
        .Inherit,
        self.env_map,
        self.cwd,
        false,
    );
}

pub fn expectStdErrEqual(self: *QemuRunStep, bytes: []const u8) void {
    self.stderr_action = .{ .expect_exact = self.builder.dupe(bytes) };
}

pub fn expectStdOutEqual(self: *QemuRunStep, bytes: []const u8) void {
    self.stdout_action = .{ .expect_exact = self.builder.dupe(bytes) };
}
