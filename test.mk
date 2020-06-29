TEST_KERNEL = $(BUILD_DIR)/testkernel
TEST_KSRCS = $(filter-out $K/start.c,$(KSRCS))

TEST_KSRCS += $K/testinit.c
TEST_KSRCS += $K/test/test_start.c
TEST_KSRCS += $K/test/lib/test_buddy.c

TEST_KOBJS=$(patsubst %.S,%.o, $(addprefix $(BUILD_DIR)/, $(TEST_KSRCS:.c=.o)))

kernel-test: $(TEST_KOBJS) $K/kernel.ld initcode
	$(LD) $(LDFLAGS) -T $K/kernel.ld -o $(TEST_KERNEL) $(TEST_KOBJS) 
	$(OBJDUMP) -S $(TEST_KERNEL) > $(BUILD_DIR)/testkernel.asm
	$(OBJDUMP) -t $(TEST_KERNEL) | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(BUILD_DIR)/testkernel.sym

QEMU_TESTOPTS = -machine virt -bios none -kernel $(TEST_KERNEL) -m 3G -smp $(CPUS) -nographic
QEMU_TESTOPTS += -drive file=fs.img,if=none,format=raw,id=x0 -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0
QEMU_TESTOPTS += -netdev tap,id=net0,ifname=$(TAPNAME),script=./qemu-ifup,downscript=./qemu-ifdown
QEMU_TESTOPTS += -object filter-dump,id=net0,netdev=net0,file=packets.pcap
QEMU_TESTOPTS += -device e1000,netdev=net0,bus=pcie.0

test: $(BUILD_DIR) kernel-test fs.img
	$(QEMU) $(QEMU_TESTOPTS)