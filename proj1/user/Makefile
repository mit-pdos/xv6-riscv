U = user
ULIB = $(U)/ulib.o $(U)/usys.o $(U)/printf.o $(U)/umalloc.o
$U/_%: proj1/user/%.o $(ULIB)
	$(LD) $(LDFLAGS) -T $U/user.ld -o $@ $^
	$(OBJDUMP) -S $@ > $U/$*.asm
	$(OBJDUMP) -t $@ | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $U/$*.sym
