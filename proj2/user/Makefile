U = user
ULIB = $(U)/ulib.o $(U)/usys.o $(U)/printf.o $(U)/umalloc.o
$U/_%: proj2/user/%.o $(ULIB)
	$(LD) $(LDFLAGS) -T $U/user.ld -o $@ $^
	$(OBJDUMP) -S $@ > $U/$*.asm
	$(OBJDUMP) -t $@ | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $U/$*.sym

$U/_pipe_rt_test: proj2/user/pipe_rt_test.o $(ULIB)
	$(LD) $(LDFLAGS) -T $U/user.ld -o $@ $^
	$(OBJDUMP) -S $@ > $U/pipe_rt_test.asm
	$(OBJDUMP) -t $@ | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $U/pipe_rt_test.sym

proj2/user/%.o: proj2/user/%.c
	$(CC) $(CFLAGS) -march=rv64g -nostdinc -I. -Ikernel -Iproj2/user -Iuser -c -o $@ $<

