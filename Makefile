# Tool Prefix
ifndef TOOLPREFIX
TOOLPREFIX := $(shell if riscv64-unknown-elf-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-unknown-elf-'; \
	elif riscv64-linux-gnu-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-linux-gnu-'; \
	else echo "***" 1>&2; \
	echo "*** Error: Couldn't find an riscv64 version of GCC/binutils." 1>&2; \
	echo "*** To turn off this error, run 'gmake TOOLPREFIX= ...'." 1>&2; \
	echo "***" 1>&2; exit 1; fi)
endif

QEMU = qemu-system-riscv64

CC = $(TOOLPREFIX)gcc
AS = $(TOOLPREFIX)gas
LD = $(TOOLPREFIX)ld
OBJCOPY = $(TOOLPREFIX)objcopy
OBJDUMP = $(TOOLPREFIX)objdump

CFLAGS = -Wall -Werror -O -fno-omit-frame-pointer -ggdb
CFLAGS += -MD
CFLAGS += -mcmodel=medany
CFLAGS += -ffreestanding -fno-common -nostdlib -mno-relax
CFLAGS += -I.
CFLAGS += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)

# Disable PIE when possible (for Ubuntu 16.10 toolchain)
ifneq ($(shell $(CC) -dumpspecs 2>/dev/null | grep -e '[^f]no-pie'),)
CFLAGS += -fno-pie -no-pie
endif
ifneq ($(shell $(CC) -dumpspecs 2>/dev/null | grep -e '[^f]nopie'),)
CFLAGS += -fno-pie -nopie
endif

LDFLAGS = -z max-page-size=4096


#########################################
# Object Files
#########################################

K=kernel
U=user
BUILD_DIR=build

KSRCS = \
	$K/entry.S \
	$K/start.c \
	$K/console.c \
	$K/printf.c \
	$K/uart.c \
	$K/kalloc.c \
	$K/spinlock.c \
	$K/string.c \
	$K/main.c \
	$K/vm.c \
	$K/proc.c \
	$K/swtch.c \
	$K/trampoline.S \
	$K/trap.c \
	$K/syscall.c \
	$K/sysproc.c \
	$K/bio.c \
	$K/fs.c \
	$K/log.c \
	$K/sleeplock.c \
	$K/file.c \
	$K/pipe.c \
	$K/exec.c \
	$K/sysfile.c \
	$K/kernelvec.S \
	$K/plic.c \
	$K/virtio_disk.c \
	$K/buddy.c \
	$K/pci.c \
	$K/e1000.c \
	$K/net.c \
	$K/sysnet.c \

KOBJS=$(patsubst %.S,%.o, $(addprefix $(BUILD_DIR)/, $(KSRCS:.c=.o)))

ULIBSRCS = $U/ulib.c $U/usys.S $U/printf.c $U/umalloc.c
ULIBOBJS = $(patsubst %.S,%.o, $(addprefix $(BUILD_DIR)/, $(ULIBSRCS:.c=.o)))

UPROGS=\
  	_cat\
  	_echo\
  	_find\
  	_forktest\
  	_grep\
  	_init\
  	_kill\
  	_ln\
  	_ls\
  	_mkdir\
  	_nsh\
  	_pingpong\
  	_primes\
  	_rm\
  	_sh\
  	_sleep\
  	_stressfs\
  	_test\
  	_testsbrk\
  	_uptime\
  	_usertests\
  	_wc\
  	_xargs\
  	_zombie\
  	_socktest\

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

kernel: $(KOBJS) $K/kernel.ld initcode
	$(LD) $(LDFLAGS) -T $K/kernel.ld -o $(BUILD_DIR)/$K/kernel $(KOBJS) 
	$(OBJDUMP) -S $(BUILD_DIR)/$K/kernel > $(BUILD_DIR)/$K/kernel.asm
	$(OBJDUMP) -t $(BUILD_DIR)/$K/kernel | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(BUILD_DIR)/$K/kernel.sym

initcode: $U/initcode.S
	@mkdir -p $(BUILD_DIR)/$U
	$(CC) $(CFLAGS) -nostdinc -I. -Ikernel -c $U/initcode.S -o $(BUILD_DIR)/$U/initcode.o
	$(LD) $(LDFLAGS) -N -e start -Ttext 0 -o $(BUILD_DIR)/$U/initcode.out $(BUILD_DIR)/$U/initcode.o
	$(OBJCOPY) -S -O binary $(BUILD_DIR)/$U/initcode.out $(BUILD_DIR)/$U/initcode
	$(OBJDUMP) -S $(BUILD_DIR)/$U/initcode.o > $(BUILD_DIR)/$U/initcode.asm

# User Program
_%: $(BUILD_DIR)/$U/%.o $(ULIBOBJS)
	$(LD) $(LDFLAGS) -N -e main -Ttext 0 -o $(BUILD_DIR)/$U/$@ $^
	$(OBJDUMP) -S $(BUILD_DIR)/$U/$@ > $(BUILD_DIR)/$U/$*.asm
	$(OBJDUMP) -t $(BUILD_DIR)/$U/$@ | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(BUILD_DIR)/$U/$*.sym

$U/usys.S : $U/usys.pl
	perl $U/usys.pl > $U/usys.S

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: %.S
	@mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) -o $@ $<

mkfs/mkfs: mkfs/mkfs.c $K/fs.h
	gcc -Werror -Wall -I. -o mkfs/mkfs mkfs/mkfs.c

# Prevent deletion of intermediate files, e.g. cat.o, after first build, so
# that disk image changes after first build are persistent until clean.  More
# details:
# http://www.gnu.org/software/make/manual/html_node/Chained-Rules.html
.PRECIOUS: %.o

fs.img: mkfs/mkfs README $(UPROGS)
	mkfs/mkfs fs.img README $(addprefix $(BUILD_DIR)/$U/, $(UPROGS))

-include $(BUILD_DIR)/kernel/*.d $(BUILD_DIR)/user/*.d

clean: 
	-rm -r 	$U/initcode $U/initcode.out $K/kernel fs.img \
			$U/*.d $U/*.o $U/*.asm $U/*.sym $U/_*\
			.gdbinit \
			$U/usys.S \
			$(UPROGS)
	-rm -rf build

###################################
# QEMU and DEBUG
###################################
# try to generate a unique GDB port
GDBPORT = $(shell expr `id -u` % 5000 + 25000)
# QEMU's gdb stub command line changed in 0.11
QEMUGDB = $(shell if $(QEMU) -help | grep -q '^-gdb'; \
	then echo "-gdb tcp::$(GDBPORT)"; \
	else echo "-s -p $(GDBPORT)"; fi)
ifndef CPUS
CPUS := 3
endif

FWDPORT = $(shell expr `id -u` % 5000 + 25999)

QEMUEXTRA = -drive file=fs1.img,if=none,format=raw,id=x1 -device virtio-blk-device,drive=x1,bus=virtio-mmio-bus.1
QEMUOPTS = -machine virt -bios none -kernel $(BUILD_DIR)/$K/kernel -m 3G -smp $(CPUS) -nographic
QEMUOPTS += -drive file=fs.img,if=none,format=raw,id=x0 -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0
QEMUOPTS += -netdev user,id=net0,hostfwd=udp::$(FWDPORT)-:2000 -object filter-dump,id=net0,netdev=net0,file=packets.pcap
QEMUOPTS += -device e1000,netdev=net0,bus=pcie.0

qemu: $(BUILD_DIR) kernel fs.img
	$(QEMU) $(QEMUOPTS)

.gdbinit: .gdbinit.tmpl-riscv
	sed "s/:1234/:$(GDBPORT)/" < $^ > $@

qemu-gdb: $(BUILD_DIR) kernel .gdbinit fs.img
	@echo "*** Now run 'gdb' in another window." 1>&2
	$(QEMU) $(QEMUOPTS) -S $(QEMUGDB)

tags:
	ctags -R -f .tags --exclude=build
