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
KDEPS=$(patsubst %.o,%.d, $(KOBJS))

# Try to infer the correct TOOLPREFIX if not set
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

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

kernel: $(KOBJS) $K/kernel.ld initcode
	$(LD) $(LDFLAGS) -T $K/kernel.ld -o $(BUILD_DIR)/$K/kernel $(KOBJS) 
	$(OBJDUMP) -S $(BUILD_DIR)/$K/kernel > $(BUILD_DIR)/$K/kernel.asm
	$(OBJDUMP) -t $(BUILD_DIR)/$K/kernel | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(BUILD_DIR)/$K/kernel.sym

initcode: $U/initcode.S
	$(CC) $(CFLAGS) -nostdinc -I. -Ikernel -c $U/initcode.S -o $U/initcode.o
	$(LD) $(LDFLAGS) -N -e start -Ttext 0 -o $U/initcode.out $U/initcode.o
	$(OBJCOPY) -S -O binary $U/initcode.out $U/initcode
	$(OBJDUMP) -S $U/initcode.o > $U/initcode.asm

tags: $(KOBJS) _init
	etags *.S *.c

$(BUILD_DIR)/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $^

$(BUILD_DIR)/%.o: %.S
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $^

$(BUILD_DIR)/%.d : %.c
	mkdir -p $(dir $@); \
	$(CC) -MM $(CFLAGS) $< \
	| sed 's/$(notdir $*).o/$(subst /,\/,$(patsubst %.d,%.o,$@) $@)/' > $@ ; \
	[ -s $@ ] || rm -f $@ \

$(BUILD_DIR)/%.d : %.S
	mkdir -p $(dir $@); \
	$(CC) -MM $(CFLAGS) $< \
	| sed 's/$(notdir $*).o/$(subst /,\/,$(patsubst %.d,%.o,$@) $@)/' > $@ ; \
	[ -s $@ ] || rm -f $@ \

ULIB = $U/ulib.o $U/usys.o $U/printf.o $U/umalloc.o

_%: %.o $(ULIB)
	$(LD) $(LDFLAGS) -N -e main -Ttext 0 -o $@ $^
	$(OBJDUMP) -S $@ > $*.asm
	$(OBJDUMP) -t $@ | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $*.sym

$U/usys.S : $U/usys.pl
	perl $U/usys.pl > $U/usys.S

$U/usys.o : $U/usys.S
	$(CC) $(CFLAGS) -c -o $U/usys.o $U/usys.S

$U/_forktest: $U/forktest.o $(ULIB)
	# forktest has less library code linked in - needs to be small
	# in order to be able to max out the proc table.
	$(LD) $(LDFLAGS) -N -e main -Ttext 0 -o $U/_forktest $U/forktest.o $U/ulib.o $U/usys.o
	$(OBJDUMP) -S $U/_forktest > $U/forktest.asm

mkfs/mkfs: mkfs/mkfs.c $K/fs.h
	gcc -Werror -Wall -I. -o mkfs/mkfs mkfs/mkfs.c

# Prevent deletion of intermediate files, e.g. cat.o, after first build, so
# that disk image changes after first build are persistent until clean.  More
# details:
# http://www.gnu.org/software/make/manual/html_node/Chained-Rules.html
.PRECIOUS: %.o

UPROGS=\
	$U/_cat\
	$U/_echo\
	$U/_find\
	$U/_forktest\
	$U/_grep\
	$U/_init\
	$U/_kill\
	$U/_ln\
	$U/_ls\
	$U/_mkdir\
	$U/_nsh\
	$U/_pingpong\
	$U/_primes\
	$U/_rm\
	$U/_sh\
	$U/_sleep\
	$U/_stressfs\
	$U/_test\
	$U/_testsbrk\
	$U/_uptime\
	$U/_usertests\
	$U/_wc\
	$U/_xargs\
	$U/_zombie\

fs.img: mkfs/mkfs README $(UPROGS)
	mkfs/mkfs fs.img README $(UPROGS)

-include kernel/*.d user/*.d

clean: 
	rm -f *.tex *.dvi *.idx *.aux *.log *.ind *.ilg \
	*/*.o */*.d */*.asm */*.sym \
	$U/initcode $U/initcode.out $K/kernel fs.img \
	mkfs/mkfs .gdbinit \
        $U/usys.S \
	$(UPROGS)

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
# QEMUOPTS += -netdev tap,id=net0,ifname=tap0 -object filter-dump,id=net0,netdev=net0,file=packets.pcap
QEMUOPTS += -device e1000,netdev=net0,bus=pcie.0

qemu: $(BUILD_DIR) kernel fs.img
	$(QEMU) $(QEMUOPTS)

.gdbinit: .gdbinit.tmpl-riscv
	sed "s/:1234/:$(GDBPORT)/" < $^ > $@

qemu-gdb: $(BUILD_DIR) kernel .gdbinit fs.img
	@echo "*** Now run 'gdb' in another window." 1>&2
	$(QEMU) $(QEMUOPTS) -S $(QEMUGDB)

# CUT HERE
# prepare dist for students
# after running make dist, probably want to
# rename it to rev0 or rev1 or so on and then
# check in that version.

EXTRA=\
	mkfs.c ulib.c user.h cat.c echo.c forktest.c grep.c kill.c\
	ln.c ls.c mkdir.c rm.c stressfs.c usertests.c wc.c zombie.c\
	printf.c umalloc.c\
	README dot-bochsrc *.pl \
	.gdbinit.tmpl gdbutil\

dist:
	rm -rf dist
	mkdir dist
	for i in $(FILES); \
	do \
		grep -v PAGEBREAK $$i >dist/$$i; \
	done
	sed '/CUT HERE/,$$d' Makefile >dist/Makefile
	echo >dist/runoff.spec
	cp $(EXTRA) dist

dist-test:
	rm -rf dist
	make dist
	rm -rf dist-test
	mkdir dist-test
	cp dist/* dist-test
	cd dist-test; $(MAKE) print
	cd dist-test; $(MAKE) bochs || true
	cd dist-test; $(MAKE) qemu

# update this rule (change rev#) when it is time to
# make a new revision.
tar:
	rm -rf /tmp/xv6
	mkdir -p /tmp/xv6
	cp dist/* dist/.gdbinit.tmpl /tmp/xv6
	(cd /tmp; tar cf - xv6) | gzip >xv6-rev10.tar.gz  # the next one will be 10 (9/17)

.PHONY: dist-test dist
