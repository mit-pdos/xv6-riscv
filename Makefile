UPROGS=\
  $U/_cat\
  $U/_echo\
  $U/_forktest\
  $U/_grep\
  $U/_init\
  $U/_kill\
  $U/_ln\
  $U/_ls\
  $U/_mkdir\
  $U/_rm\
  $U/_sh\
  $U/_stressfs\
  $U/_usertests\
  $U/_grind\
  $U/_wc\
  $U/_zombie\
  $U/_test_trigger\
  $U/_threadtest\

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
GDBPORT = $(shell expr id -u % 5000 + 25000)
# QEMU's gdb stub command line changed in 0.11
QEMUGDB = $(shell if $(QEMU) -help | grep -q '^-gdb'; \
  then echo "-gdb tcp::$(GDBPORT)"; \
  else echo "-s -p $(GDBPORT)"; fi)
ifndef CPUS
CPUS := 1
endif

QEMUOPTS = -machine virt -bios none -kernel $K/kernel -m 128M -smp $(CPUS) -nographic
QEMUOPTS += -global virtio-mmio.force-legacy=false
QEMUOPTS += -drive file=fs.img,if=none,format=raw,id=x0
QEMUOPTS += -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0

qemu: $K/kernel fs.img
  $(QEMU) $(QEMUOPTS)

.gdbinit: .gdbinit.tmpl-riscv
  sed "s/:1234/:$(GDBPORT)/" < $^ > $@

qemu-gdb: $K/kernel .gdbinit fs.img
  @echo "*** Now run 'gdb' in another window." 1>&2
  $(QEMU) $(QEMUOPTS) -S $(QEMUGDB)
