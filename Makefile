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
CFLAGS += -I. -Ikernel/include -Iuser/include
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
	$K/main.c \
	$K/swtch.c \
	$K/trampoline.S \
	$K/trap.c \
	$K/bio.c \
	$K/log.c \
	$K/kernelvec.S \

# Memory System
KSRCS += \
	$K/mem/vm.c \
	# $K/mem/ramdisk.c \

# Lock System
KSRCS += \
	$K/lock/sleeplock.c \
	$K/lock/spinlock.c \

# Process System
KSRCS += \
	$K/proc/proc.c \
	$K/proc/pipe.c \
	$K/proc/exec.c \

# File System
KSRCS += \
	$K/fs/file.c \
	$K/fs/fs.c \

# Kernel Useful Library
KSRCS += \
	$K/lib/printf.c \
	$K/lib/kalloc.c \
	$K/lib/string.c \
	$K/lib/buddy.c \
	
# Device System
KSRCS += \
	$K/dev/plic.c \
	$K/dev/uart.c \
	$K/dev/virtio_disk.c \
	$K/dev/pci.c \

# Network System
KSRCS += \
	$K/net/netutil.c \
	$K/net/dev/e1000.c \
	$K/net/mbuf.c \
	$K/net/ethernet.c \
	$K/net/arp.c \
	$K/net/arptable.c \
	$K/net/ipv4.c \
	$K/net/udp.c \
	$K/net/tcp.c \

# System call and OS Interface for user
KSRCS += \
	$K/sys/sysproc.c \
	$K/sys/sysfile.c \
	$K/sys/sysnet.c \
	$K/sys/syscall.c \

ULIBSRCS = $U/ulib.c $U/usys.S $U/printf.c $U/umalloc.c


KOBJS=$(patsubst %.S,%.o, $(addprefix $(BUILD_DIR)/, $(KSRCS:.c=.o)))
# KOBJS += net.o

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
  	_udp\
  	_tcp\
  	_tcplisten\

all: qemu

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

kernel: $(KOBJS) $K/kernel.ld initcode
	$(LD) $(LDFLAGS) -T $K/kernel.ld -o $(BUILD_DIR)/$K/kernel $(KOBJS) 
	$(OBJDUMP) -S $(BUILD_DIR)/$K/kernel > $(BUILD_DIR)/$K/kernel.asm
	$(OBJDUMP) -t $(BUILD_DIR)/$K/kernel | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(BUILD_DIR)/$K/kernel.sym

initcode: $U/initcode.S
	@mkdir -p $(BUILD_DIR)/$U
	$(CC) $(CFLAGS) -nostdinc -I. -Ikernel -Ikernel/include -c $U/initcode.S -o $(BUILD_DIR)/$U/initcode.o
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

mkfs/mkfs: mkfs/mkfs.c $K/include/fs.h
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
	# -rm -r 	$U/initcode $U/initcode.out $K/kernel fs.img \
	# 		$U/*.d $U/*.o $U/*.asm $U/*.sym $U/_*\
	# 		.gdbinit \
	# 		$U/usys.S \
	# 		$(UPROGS)
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

TAPNAME = tap0
QEMUEXTRA = -drive file=fs1.img,if=none,format=raw,id=x1 -device virtio-blk-device,drive=x1,bus=virtio-mmio-bus.1
QEMUOPTS = -machine virt -bios none -kernel $(BUILD_DIR)/$K/kernel -m 3G -smp $(CPUS) -nographic
QEMUOPTS += -drive file=fs.img,if=none,format=raw,id=x0 -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0
QEMUOPTS += -netdev tap,id=net0,ifname=$(TAPNAME),script=./qemu-ifup,downscript=./qemu-ifdown
# QEMUOPTS += -netdev user,id=net0,hostfwd=udp::26000-:2000,hostfwd=tcp::26001-:2001
QEMUOPTS += -object filter-dump,id=net0,netdev=net0,file=packets.pcap
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
