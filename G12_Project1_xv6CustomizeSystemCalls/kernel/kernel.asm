
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	25813103          	ld	sp,600(sp) # 8000a258 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb257>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	dbc78793          	addi	a5,a5,-580 # 80000e3c <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a2:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	7119                	addi	sp,sp,-128
    800000d2:	fc86                	sd	ra,120(sp)
    800000d4:	f8a2                	sd	s0,112(sp)
    800000d6:	f4a6                	sd	s1,104(sp)
    800000d8:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000da:	06c05a63          	blez	a2,8000014e <consolewrite+0x7e>
    800000de:	f0ca                	sd	s2,96(sp)
    800000e0:	ecce                	sd	s3,88(sp)
    800000e2:	e8d2                	sd	s4,80(sp)
    800000e4:	e4d6                	sd	s5,72(sp)
    800000e6:	e0da                	sd	s6,64(sp)
    800000e8:	fc5e                	sd	s7,56(sp)
    800000ea:	f862                	sd	s8,48(sp)
    800000ec:	f466                	sd	s9,40(sp)
    800000ee:	8aaa                	mv	s5,a0
    800000f0:	8b2e                	mv	s6,a1
    800000f2:	8a32                	mv	s4,a2
  int i = 0;
    800000f4:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000f6:	02000c13          	li	s8,32
    800000fa:	02000c93          	li	s9,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800000fe:	5bfd                	li	s7,-1
    80000100:	a035                	j	8000012c <consolewrite+0x5c>
    if(nn > n - i)
    80000102:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000106:	86ce                	mv	a3,s3
    80000108:	01648633          	add	a2,s1,s6
    8000010c:	85d6                	mv	a1,s5
    8000010e:	f8040513          	addi	a0,s0,-128
    80000112:	16c020ef          	jal	8000227e <either_copyin>
    80000116:	03750e63          	beq	a0,s7,80000152 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    8000011a:	85ce                	mv	a1,s3
    8000011c:	f8040513          	addi	a0,s0,-128
    80000120:	778000ef          	jal	80000898 <uartwrite>
    i += nn;
    80000124:	009904bb          	addw	s1,s2,s1
  while(i < n){
    80000128:	0144da63          	bge	s1,s4,8000013c <consolewrite+0x6c>
    if(nn > n - i)
    8000012c:	409a093b          	subw	s2,s4,s1
    80000130:	0009079b          	sext.w	a5,s2
    80000134:	fcfc57e3          	bge	s8,a5,80000102 <consolewrite+0x32>
    80000138:	8966                	mv	s2,s9
    8000013a:	b7e1                	j	80000102 <consolewrite+0x32>
    8000013c:	7906                	ld	s2,96(sp)
    8000013e:	69e6                	ld	s3,88(sp)
    80000140:	6a46                	ld	s4,80(sp)
    80000142:	6aa6                	ld	s5,72(sp)
    80000144:	6b06                	ld	s6,64(sp)
    80000146:	7be2                	ld	s7,56(sp)
    80000148:	7c42                	ld	s8,48(sp)
    8000014a:	7ca2                	ld	s9,40(sp)
    8000014c:	a819                	j	80000162 <consolewrite+0x92>
  int i = 0;
    8000014e:	4481                	li	s1,0
    80000150:	a809                	j	80000162 <consolewrite+0x92>
    80000152:	7906                	ld	s2,96(sp)
    80000154:	69e6                	ld	s3,88(sp)
    80000156:	6a46                	ld	s4,80(sp)
    80000158:	6aa6                	ld	s5,72(sp)
    8000015a:	6b06                	ld	s6,64(sp)
    8000015c:	7be2                	ld	s7,56(sp)
    8000015e:	7c42                	ld	s8,48(sp)
    80000160:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80000162:	8526                	mv	a0,s1
    80000164:	70e6                	ld	ra,120(sp)
    80000166:	7446                	ld	s0,112(sp)
    80000168:	74a6                	ld	s1,104(sp)
    8000016a:	6109                	addi	sp,sp,128
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	addi	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	addi	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	00012517          	auipc	a0,0x12
    80000190:	11450513          	addi	a0,a0,276 # 800122a0 <cons>
    80000194:	23b000ef          	jal	80000bce <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	00012497          	auipc	s1,0x12
    8000019c:	10848493          	addi	s1,s1,264 # 800122a0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	00012917          	auipc	s2,0x12
    800001a4:	19890913          	addi	s2,s2,408 # 80012338 <cons+0x98>
  while(n > 0){
    800001a8:	0b305d63          	blez	s3,80000262 <consoleread+0xf4>
    while(cons.r == cons.w){
    800001ac:	0984a783          	lw	a5,152(s1)
    800001b0:	09c4a703          	lw	a4,156(s1)
    800001b4:	0af71263          	bne	a4,a5,80000258 <consoleread+0xea>
      if(killed(myproc())){
    800001b8:	716010ef          	jal	800018ce <myproc>
    800001bc:	755010ef          	jal	80002110 <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	513010ef          	jal	80001ed8 <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef703e3          	beq	a4,a5,800001b8 <consoleread+0x4a>
    800001d6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001d8:	00012717          	auipc	a4,0x12
    800001dc:	0c870713          	addi	a4,a4,200 # 800122a0 <cons>
    800001e0:	0017869b          	addiw	a3,a5,1
    800001e4:	08d72c23          	sw	a3,152(a4)
    800001e8:	07f7f693          	andi	a3,a5,127
    800001ec:	9736                	add	a4,a4,a3
    800001ee:	01874703          	lbu	a4,24(a4)
    800001f2:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001f6:	4691                	li	a3,4
    800001f8:	04db8663          	beq	s7,a3,80000244 <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001fc:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000200:	4685                	li	a3,1
    80000202:	faf40613          	addi	a2,s0,-81
    80000206:	85d2                	mv	a1,s4
    80000208:	8556                	mv	a0,s5
    8000020a:	02a020ef          	jal	80002234 <either_copyout>
    8000020e:	57fd                	li	a5,-1
    80000210:	04f50863          	beq	a0,a5,80000260 <consoleread+0xf2>
      break;

    dst++;
    80000214:	0a05                	addi	s4,s4,1
    --n;
    80000216:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000218:	47a9                	li	a5,10
    8000021a:	04fb8d63          	beq	s7,a5,80000274 <consoleread+0x106>
    8000021e:	6be2                	ld	s7,24(sp)
    80000220:	b761                	j	800001a8 <consoleread+0x3a>
        release(&cons.lock);
    80000222:	00012517          	auipc	a0,0x12
    80000226:	07e50513          	addi	a0,a0,126 # 800122a0 <cons>
    8000022a:	23d000ef          	jal	80000c66 <release>
        return -1;
    8000022e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000230:	60e6                	ld	ra,88(sp)
    80000232:	6446                	ld	s0,80(sp)
    80000234:	64a6                	ld	s1,72(sp)
    80000236:	6906                	ld	s2,64(sp)
    80000238:	79e2                	ld	s3,56(sp)
    8000023a:	7a42                	ld	s4,48(sp)
    8000023c:	7aa2                	ld	s5,40(sp)
    8000023e:	7b02                	ld	s6,32(sp)
    80000240:	6125                	addi	sp,sp,96
    80000242:	8082                	ret
      if(n < target){
    80000244:	0009871b          	sext.w	a4,s3
    80000248:	01677a63          	bgeu	a4,s6,8000025c <consoleread+0xee>
        cons.r--;
    8000024c:	00012717          	auipc	a4,0x12
    80000250:	0ef72623          	sw	a5,236(a4) # 80012338 <cons+0x98>
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	a031                	j	80000262 <consoleread+0xf4>
    80000258:	ec5e                	sd	s7,24(sp)
    8000025a:	bfbd                	j	800001d8 <consoleread+0x6a>
    8000025c:	6be2                	ld	s7,24(sp)
    8000025e:	a011                	j	80000262 <consoleread+0xf4>
    80000260:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000262:	00012517          	auipc	a0,0x12
    80000266:	03e50513          	addi	a0,a0,62 # 800122a0 <cons>
    8000026a:	1fd000ef          	jal	80000c66 <release>
  return target - n;
    8000026e:	413b053b          	subw	a0,s6,s3
    80000272:	bf7d                	j	80000230 <consoleread+0xc2>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	b7f5                	j	80000262 <consoleread+0xf4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50863          	beq	a0,a5,80000294 <consputc+0x1c>
    uartputc_sync(c);
    80000288:	6a4000ef          	jal	8000092c <uartputc_sync>
}
    8000028c:	60a2                	ld	ra,8(sp)
    8000028e:	6402                	ld	s0,0(sp)
    80000290:	0141                	addi	sp,sp,16
    80000292:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000294:	4521                	li	a0,8
    80000296:	696000ef          	jal	8000092c <uartputc_sync>
    8000029a:	02000513          	li	a0,32
    8000029e:	68e000ef          	jal	8000092c <uartputc_sync>
    800002a2:	4521                	li	a0,8
    800002a4:	688000ef          	jal	8000092c <uartputc_sync>
    800002a8:	b7d5                	j	8000028c <consputc+0x14>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	1000                	addi	s0,sp,32
    800002b4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b6:	00012517          	auipc	a0,0x12
    800002ba:	fea50513          	addi	a0,a0,-22 # 800122a0 <cons>
    800002be:	111000ef          	jal	80000bce <acquire>

  switch(c){
    800002c2:	47d5                	li	a5,21
    800002c4:	08f48f63          	beq	s1,a5,80000362 <consoleintr+0xb8>
    800002c8:	0297c563          	blt	a5,s1,800002f2 <consoleintr+0x48>
    800002cc:	47a1                	li	a5,8
    800002ce:	0ef48463          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    800002d2:	47c1                	li	a5,16
    800002d4:	10f49563          	bne	s1,a5,800003de <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002d8:	7f1010ef          	jal	800022c8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002dc:	00012517          	auipc	a0,0x12
    800002e0:	fc450513          	addi	a0,a0,-60 # 800122a0 <cons>
    800002e4:	183000ef          	jal	80000c66 <release>
}
    800002e8:	60e2                	ld	ra,24(sp)
    800002ea:	6442                	ld	s0,16(sp)
    800002ec:	64a2                	ld	s1,8(sp)
    800002ee:	6105                	addi	sp,sp,32
    800002f0:	8082                	ret
  switch(c){
    800002f2:	07f00793          	li	a5,127
    800002f6:	0cf48063          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fa:	00012717          	auipc	a4,0x12
    800002fe:	fa670713          	addi	a4,a4,-90 # 800122a0 <cons>
    80000302:	0a072783          	lw	a5,160(a4)
    80000306:	09872703          	lw	a4,152(a4)
    8000030a:	9f99                	subw	a5,a5,a4
    8000030c:	07f00713          	li	a4,127
    80000310:	fcf766e3          	bltu	a4,a5,800002dc <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000314:	47b5                	li	a5,13
    80000316:	0cf48763          	beq	s1,a5,800003e4 <consoleintr+0x13a>
      consputc(c);
    8000031a:	8526                	mv	a0,s1
    8000031c:	f5dff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000320:	00012797          	auipc	a5,0x12
    80000324:	f8078793          	addi	a5,a5,-128 # 800122a0 <cons>
    80000328:	0a07a683          	lw	a3,160(a5)
    8000032c:	0016871b          	addiw	a4,a3,1
    80000330:	0007061b          	sext.w	a2,a4
    80000334:	0ae7a023          	sw	a4,160(a5)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	97b6                	add	a5,a5,a3
    8000033e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	47a9                	li	a5,10
    80000344:	0cf48563          	beq	s1,a5,8000040e <consoleintr+0x164>
    80000348:	4791                	li	a5,4
    8000034a:	0cf48263          	beq	s1,a5,8000040e <consoleintr+0x164>
    8000034e:	00012797          	auipc	a5,0x12
    80000352:	fea7a783          	lw	a5,-22(a5) # 80012338 <cons+0x98>
    80000356:	9f1d                	subw	a4,a4,a5
    80000358:	08000793          	li	a5,128
    8000035c:	f8f710e3          	bne	a4,a5,800002dc <consoleintr+0x32>
    80000360:	a07d                	j	8000040e <consoleintr+0x164>
    80000362:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000364:	00012717          	auipc	a4,0x12
    80000368:	f3c70713          	addi	a4,a4,-196 # 800122a0 <cons>
    8000036c:	0a072783          	lw	a5,160(a4)
    80000370:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000374:	00012497          	auipc	s1,0x12
    80000378:	f2c48493          	addi	s1,s1,-212 # 800122a0 <cons>
    while(cons.e != cons.w &&
    8000037c:	4929                	li	s2,10
    8000037e:	02f70863          	beq	a4,a5,800003ae <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000382:	37fd                	addiw	a5,a5,-1
    80000384:	07f7f713          	andi	a4,a5,127
    80000388:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000038a:	01874703          	lbu	a4,24(a4)
    8000038e:	03270263          	beq	a4,s2,800003b2 <consoleintr+0x108>
      cons.e--;
    80000392:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000396:	10000513          	li	a0,256
    8000039a:	edfff0ef          	jal	80000278 <consputc>
    while(cons.e != cons.w &&
    8000039e:	0a04a783          	lw	a5,160(s1)
    800003a2:	09c4a703          	lw	a4,156(s1)
    800003a6:	fcf71ee3          	bne	a4,a5,80000382 <consoleintr+0xd8>
    800003aa:	6902                	ld	s2,0(sp)
    800003ac:	bf05                	j	800002dc <consoleintr+0x32>
    800003ae:	6902                	ld	s2,0(sp)
    800003b0:	b735                	j	800002dc <consoleintr+0x32>
    800003b2:	6902                	ld	s2,0(sp)
    800003b4:	b725                	j	800002dc <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b6:	00012717          	auipc	a4,0x12
    800003ba:	eea70713          	addi	a4,a4,-278 # 800122a0 <cons>
    800003be:	0a072783          	lw	a5,160(a4)
    800003c2:	09c72703          	lw	a4,156(a4)
    800003c6:	f0f70be3          	beq	a4,a5,800002dc <consoleintr+0x32>
      cons.e--;
    800003ca:	37fd                	addiw	a5,a5,-1
    800003cc:	00012717          	auipc	a4,0x12
    800003d0:	f6f72a23          	sw	a5,-140(a4) # 80012340 <cons+0xa0>
      consputc(BACKSPACE);
    800003d4:	10000513          	li	a0,256
    800003d8:	ea1ff0ef          	jal	80000278 <consputc>
    800003dc:	b701                	j	800002dc <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003de:	ee048fe3          	beqz	s1,800002dc <consoleintr+0x32>
    800003e2:	bf21                	j	800002fa <consoleintr+0x50>
      consputc(c);
    800003e4:	4529                	li	a0,10
    800003e6:	e93ff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003ea:	00012797          	auipc	a5,0x12
    800003ee:	eb678793          	addi	a5,a5,-330 # 800122a0 <cons>
    800003f2:	0a07a703          	lw	a4,160(a5)
    800003f6:	0017069b          	addiw	a3,a4,1
    800003fa:	0006861b          	sext.w	a2,a3
    800003fe:	0ad7a023          	sw	a3,160(a5)
    80000402:	07f77713          	andi	a4,a4,127
    80000406:	97ba                	add	a5,a5,a4
    80000408:	4729                	li	a4,10
    8000040a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040e:	00012797          	auipc	a5,0x12
    80000412:	f2c7a723          	sw	a2,-210(a5) # 8001233c <cons+0x9c>
        wakeup(&cons.r);
    80000416:	00012517          	auipc	a0,0x12
    8000041a:	f2250513          	addi	a0,a0,-222 # 80012338 <cons+0x98>
    8000041e:	307010ef          	jal	80001f24 <wakeup>
    80000422:	bd6d                	j	800002dc <consoleintr+0x32>

0000000080000424 <consoleinit>:

void
consoleinit(void)
{
    80000424:	1141                	addi	sp,sp,-16
    80000426:	e406                	sd	ra,8(sp)
    80000428:	e022                	sd	s0,0(sp)
    8000042a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000042c:	00007597          	auipc	a1,0x7
    80000430:	bd458593          	addi	a1,a1,-1068 # 80007000 <etext>
    80000434:	00012517          	auipc	a0,0x12
    80000438:	e6c50513          	addi	a0,a0,-404 # 800122a0 <cons>
    8000043c:	712000ef          	jal	80000b4e <initlock>

  uartinit();
    80000440:	400000ef          	jal	80000840 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000444:	00022797          	auipc	a5,0x22
    80000448:	fcc78793          	addi	a5,a5,-52 # 80022410 <devsw>
    8000044c:	00000717          	auipc	a4,0x0
    80000450:	d2270713          	addi	a4,a4,-734 # 8000016e <consoleread>
    80000454:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000456:	00000717          	auipc	a4,0x0
    8000045a:	c7a70713          	addi	a4,a4,-902 # 800000d0 <consolewrite>
    8000045e:	ef98                	sd	a4,24(a5)
}
    80000460:	60a2                	ld	ra,8(sp)
    80000462:	6402                	ld	s0,0(sp)
    80000464:	0141                	addi	sp,sp,16
    80000466:	8082                	ret

0000000080000468 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000468:	7139                	addi	sp,sp,-64
    8000046a:	fc06                	sd	ra,56(sp)
    8000046c:	f822                	sd	s0,48(sp)
    8000046e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000470:	c219                	beqz	a2,80000476 <printint+0xe>
    80000472:	08054063          	bltz	a0,800004f2 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000476:	4881                	li	a7,0
    80000478:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000047c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00007617          	auipc	a2,0x7
    80000482:	2b260613          	addi	a2,a2,690 # 80007730 <digits>
    80000486:	883e                	mv	a6,a5
    80000488:	2785                	addiw	a5,a5,1
    8000048a:	02b57733          	remu	a4,a0,a1
    8000048e:	9732                	add	a4,a4,a2
    80000490:	00074703          	lbu	a4,0(a4)
    80000494:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000498:	872a                	mv	a4,a0
    8000049a:	02b55533          	divu	a0,a0,a1
    8000049e:	0685                	addi	a3,a3,1
    800004a0:	feb773e3          	bgeu	a4,a1,80000486 <printint+0x1e>

  if(sign)
    800004a4:	00088a63          	beqz	a7,800004b8 <printint+0x50>
    buf[i++] = '-';
    800004a8:	1781                	addi	a5,a5,-32
    800004aa:	97a2                	add	a5,a5,s0
    800004ac:	02d00713          	li	a4,45
    800004b0:	fee78423          	sb	a4,-24(a5)
    800004b4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800004b8:	02f05963          	blez	a5,800004ea <printint+0x82>
    800004bc:	f426                	sd	s1,40(sp)
    800004be:	f04a                	sd	s2,32(sp)
    800004c0:	fc840713          	addi	a4,s0,-56
    800004c4:	00f704b3          	add	s1,a4,a5
    800004c8:	fff70913          	addi	s2,a4,-1
    800004cc:	993e                	add	s2,s2,a5
    800004ce:	37fd                	addiw	a5,a5,-1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004d8:	fff4c503          	lbu	a0,-1(s1)
    800004dc:	d9dff0ef          	jal	80000278 <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x70>
    800004e6:	74a2                	ld	s1,40(sp)
    800004e8:	7902                	ld	s2,32(sp)
}
    800004ea:	70e2                	ld	ra,56(sp)
    800004ec:	7442                	ld	s0,48(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4885                	li	a7,1
    x = -xx;
    800004f8:	b741                	j	80000478 <printint+0x10>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	e8d2                	sd	s4,80(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	8a2a                	mv	s4,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	0000a797          	auipc	a5,0xa
    8000051c:	d5c7a783          	lw	a5,-676(a5) # 8000a274 <panicking>
    80000520:	c3a1                	beqz	a5,80000560 <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	000a4503          	lbu	a0,0(s4)
    8000052e:	28050763          	beqz	a0,800007bc <printf+0x2c2>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	f0ca                	sd	s2,96(sp)
    80000536:	ecce                	sd	s3,88(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	f862                	sd	s8,48(sp)
    8000053e:	f466                	sd	s9,40(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4981                	li	s3,0
    if(cx != '%'){
    80000546:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    8000054a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000054e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000552:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000556:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    8000055a:	07000d93          	li	s11,112
    8000055e:	a01d                	j	80000584 <printf+0x8a>
    acquire(&pr.lock);
    80000560:	00012517          	auipc	a0,0x12
    80000564:	de850513          	addi	a0,a0,-536 # 80012348 <pr>
    80000568:	666000ef          	jal	80000bce <acquire>
    8000056c:	bf5d                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056e:	d0bff0ef          	jal	80000278 <consputc>
      continue;
    80000572:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000574:	0014899b          	addiw	s3,s1,1
    80000578:	013a07b3          	add	a5,s4,s3
    8000057c:	0007c503          	lbu	a0,0(a5)
    80000580:	20050b63          	beqz	a0,80000796 <printf+0x29c>
    if(cx != '%'){
    80000584:	ff5515e3          	bne	a0,s5,8000056e <printf+0x74>
    i++;
    80000588:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000058c:	009a07b3          	add	a5,s4,s1
    80000590:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000594:	20090b63          	beqz	s2,800007aa <printf+0x2b0>
    80000598:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    8000059c:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059e:	c789                	beqz	a5,800005a8 <printf+0xae>
    800005a0:	009a0733          	add	a4,s4,s1
    800005a4:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800005a8:	03690963          	beq	s2,s6,800005da <printf+0xe0>
    } else if(c0 == 'l' && c1 == 'd'){
    800005ac:	05890363          	beq	s2,s8,800005f2 <printf+0xf8>
    } else if(c0 == 'u'){
    800005b0:	0d990663          	beq	s2,s9,8000067c <printf+0x182>
    } else if(c0 == 'x'){
    800005b4:	11a90d63          	beq	s2,s10,800006ce <printf+0x1d4>
    } else if(c0 == 'p'){
    800005b8:	15b90663          	beq	s2,s11,80000704 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    800005bc:	06300793          	li	a5,99
    800005c0:	18f90563          	beq	s2,a5,8000074a <printf+0x250>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    800005c4:	07300793          	li	a5,115
    800005c8:	18f90b63          	beq	s2,a5,8000075e <printf+0x264>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005cc:	03591b63          	bne	s2,s5,80000602 <printf+0x108>
      consputc('%');
    800005d0:	02500513          	li	a0,37
    800005d4:	ca5ff0ef          	jal	80000278 <consputc>
    800005d8:	bf71                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005da:	f8843783          	ld	a5,-120(s0)
    800005de:	00878713          	addi	a4,a5,8
    800005e2:	f8e43423          	sd	a4,-120(s0)
    800005e6:	4605                	li	a2,1
    800005e8:	45a9                	li	a1,10
    800005ea:	4388                	lw	a0,0(a5)
    800005ec:	e7dff0ef          	jal	80000468 <printint>
    800005f0:	b751                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    800005f2:	01678f63          	beq	a5,s6,80000610 <printf+0x116>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005f6:	03878b63          	beq	a5,s8,8000062c <printf+0x132>
    } else if(c0 == 'l' && c1 == 'u'){
    800005fa:	09978e63          	beq	a5,s9,80000696 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'x'){
    800005fe:	0fa78563          	beq	a5,s10,800006e8 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000602:	8556                	mv	a0,s5
    80000604:	c75ff0ef          	jal	80000278 <consputc>
      consputc(c0);
    80000608:	854a                	mv	a0,s2
    8000060a:	c6fff0ef          	jal	80000278 <consputc>
    8000060e:	b79d                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000610:	f8843783          	ld	a5,-120(s0)
    80000614:	00878713          	addi	a4,a5,8
    80000618:	f8e43423          	sd	a4,-120(s0)
    8000061c:	4605                	li	a2,1
    8000061e:	45a9                	li	a1,10
    80000620:	6388                	ld	a0,0(a5)
    80000622:	e47ff0ef          	jal	80000468 <printint>
      i += 1;
    80000626:	0029849b          	addiw	s1,s3,2
    8000062a:	b7a9                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000062c:	06400793          	li	a5,100
    80000630:	02f68863          	beq	a3,a5,80000660 <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000634:	07500793          	li	a5,117
    80000638:	06f68d63          	beq	a3,a5,800006b2 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000063c:	07800793          	li	a5,120
    80000640:	fcf691e3          	bne	a3,a5,80000602 <printf+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4601                	li	a2,0
    80000652:	45c1                	li	a1,16
    80000654:	6388                	ld	a0,0(a5)
    80000656:	e13ff0ef          	jal	80000468 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bf19                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4605                	li	a2,1
    8000066e:	45a9                	li	a1,10
    80000670:	6388                	ld	a0,0(a5)
    80000672:	df7ff0ef          	jal	80000468 <printint>
      i += 2;
    80000676:	0039849b          	addiw	s1,s3,3
    8000067a:	bded                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4601                	li	a2,0
    8000068a:	45a9                	li	a1,10
    8000068c:	0007e503          	lwu	a0,0(a5)
    80000690:	dd9ff0ef          	jal	80000468 <printint>
    80000694:	b5c5                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	4601                	li	a2,0
    800006a4:	45a9                	li	a1,10
    800006a6:	6388                	ld	a0,0(a5)
    800006a8:	dc1ff0ef          	jal	80000468 <printint>
      i += 1;
    800006ac:	0029849b          	addiw	s1,s3,2
    800006b0:	b5d1                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4601                	li	a2,0
    800006c0:	45a9                	li	a1,10
    800006c2:	6388                	ld	a0,0(a5)
    800006c4:	da5ff0ef          	jal	80000468 <printint>
      i += 2;
    800006c8:	0039849b          	addiw	s1,s3,3
    800006cc:	b565                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	4601                	li	a2,0
    800006dc:	45c1                	li	a1,16
    800006de:	0007e503          	lwu	a0,0(a5)
    800006e2:	d87ff0ef          	jal	80000468 <printint>
    800006e6:	b579                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	4601                	li	a2,0
    800006f6:	45c1                	li	a1,16
    800006f8:	6388                	ld	a0,0(a5)
    800006fa:	d6fff0ef          	jal	80000468 <printint>
      i += 1;
    800006fe:	0029849b          	addiw	s1,s3,2
    80000702:	bd8d                	j	80000574 <printf+0x7a>
    80000704:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000706:	f8843783          	ld	a5,-120(s0)
    8000070a:	00878713          	addi	a4,a5,8
    8000070e:	f8e43423          	sd	a4,-120(s0)
    80000712:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000716:	03000513          	li	a0,48
    8000071a:	b5fff0ef          	jal	80000278 <consputc>
  consputc('x');
    8000071e:	07800513          	li	a0,120
    80000722:	b57ff0ef          	jal	80000278 <consputc>
    80000726:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000728:	00007b97          	auipc	s7,0x7
    8000072c:	008b8b93          	addi	s7,s7,8 # 80007730 <digits>
    80000730:	03c9d793          	srli	a5,s3,0x3c
    80000734:	97de                	add	a5,a5,s7
    80000736:	0007c503          	lbu	a0,0(a5)
    8000073a:	b3fff0ef          	jal	80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000073e:	0992                	slli	s3,s3,0x4
    80000740:	397d                	addiw	s2,s2,-1
    80000742:	fe0917e3          	bnez	s2,80000730 <printf+0x236>
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	b535                	j	80000574 <printf+0x7a>
      consputc(va_arg(ap, uint));
    8000074a:	f8843783          	ld	a5,-120(s0)
    8000074e:	00878713          	addi	a4,a5,8
    80000752:	f8e43423          	sd	a4,-120(s0)
    80000756:	4388                	lw	a0,0(a5)
    80000758:	b21ff0ef          	jal	80000278 <consputc>
    8000075c:	bd21                	j	80000574 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    8000075e:	f8843783          	ld	a5,-120(s0)
    80000762:	00878713          	addi	a4,a5,8
    80000766:	f8e43423          	sd	a4,-120(s0)
    8000076a:	0007b903          	ld	s2,0(a5)
    8000076e:	00090d63          	beqz	s2,80000788 <printf+0x28e>
      for(; *s; s++)
    80000772:	00094503          	lbu	a0,0(s2)
    80000776:	de050fe3          	beqz	a0,80000574 <printf+0x7a>
        consputc(*s);
    8000077a:	affff0ef          	jal	80000278 <consputc>
      for(; *s; s++)
    8000077e:	0905                	addi	s2,s2,1
    80000780:	00094503          	lbu	a0,0(s2)
    80000784:	f97d                	bnez	a0,8000077a <printf+0x280>
    80000786:	b3fd                	j	80000574 <printf+0x7a>
        s = "(null)";
    80000788:	00007917          	auipc	s2,0x7
    8000078c:	88090913          	addi	s2,s2,-1920 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000790:	02800513          	li	a0,40
    80000794:	b7dd                	j	8000077a <printf+0x280>
    80000796:	74a6                	ld	s1,104(sp)
    80000798:	7906                	ld	s2,96(sp)
    8000079a:	69e6                	ld	s3,88(sp)
    8000079c:	6aa6                	ld	s5,72(sp)
    8000079e:	6b06                	ld	s6,64(sp)
    800007a0:	7c42                	ld	s8,48(sp)
    800007a2:	7ca2                	ld	s9,40(sp)
    800007a4:	7d02                	ld	s10,32(sp)
    800007a6:	6de2                	ld	s11,24(sp)
    800007a8:	a811                	j	800007bc <printf+0x2c2>
    800007aa:	74a6                	ld	s1,104(sp)
    800007ac:	7906                	ld	s2,96(sp)
    800007ae:	69e6                	ld	s3,88(sp)
    800007b0:	6aa6                	ld	s5,72(sp)
    800007b2:	6b06                	ld	s6,64(sp)
    800007b4:	7c42                	ld	s8,48(sp)
    800007b6:	7ca2                	ld	s9,40(sp)
    800007b8:	7d02                	ld	s10,32(sp)
    800007ba:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    800007bc:	0000a797          	auipc	a5,0xa
    800007c0:	ab87a783          	lw	a5,-1352(a5) # 8000a274 <panicking>
    800007c4:	c799                	beqz	a5,800007d2 <printf+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007c6:	4501                	li	a0,0
    800007c8:	70e6                	ld	ra,120(sp)
    800007ca:	7446                	ld	s0,112(sp)
    800007cc:	6a46                	ld	s4,80(sp)
    800007ce:	6129                	addi	sp,sp,192
    800007d0:	8082                	ret
    release(&pr.lock);
    800007d2:	00012517          	auipc	a0,0x12
    800007d6:	b7650513          	addi	a0,a0,-1162 # 80012348 <pr>
    800007da:	48c000ef          	jal	80000c66 <release>
  return 0;
    800007de:	b7e5                	j	800007c6 <printf+0x2cc>

00000000800007e0 <panic>:

void
panic(char *s)
{
    800007e0:	1101                	addi	sp,sp,-32
    800007e2:	ec06                	sd	ra,24(sp)
    800007e4:	e822                	sd	s0,16(sp)
    800007e6:	e426                	sd	s1,8(sp)
    800007e8:	e04a                	sd	s2,0(sp)
    800007ea:	1000                	addi	s0,sp,32
    800007ec:	84aa                	mv	s1,a0
  panicking = 1;
    800007ee:	4905                	li	s2,1
    800007f0:	0000a797          	auipc	a5,0xa
    800007f4:	a927a223          	sw	s2,-1404(a5) # 8000a274 <panicking>
  printf("panic: ");
    800007f8:	00007517          	auipc	a0,0x7
    800007fc:	82050513          	addi	a0,a0,-2016 # 80007018 <etext+0x18>
    80000800:	cfbff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000804:	85a6                	mv	a1,s1
    80000806:	00007517          	auipc	a0,0x7
    8000080a:	81a50513          	addi	a0,a0,-2022 # 80007020 <etext+0x20>
    8000080e:	cedff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000812:	0000a797          	auipc	a5,0xa
    80000816:	a527af23          	sw	s2,-1442(a5) # 8000a270 <panicked>
  for(;;)
    8000081a:	a001                	j	8000081a <panic+0x3a>

000000008000081c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000081c:	1141                	addi	sp,sp,-16
    8000081e:	e406                	sd	ra,8(sp)
    80000820:	e022                	sd	s0,0(sp)
    80000822:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000824:	00007597          	auipc	a1,0x7
    80000828:	80458593          	addi	a1,a1,-2044 # 80007028 <etext+0x28>
    8000082c:	00012517          	auipc	a0,0x12
    80000830:	b1c50513          	addi	a0,a0,-1252 # 80012348 <pr>
    80000834:	31a000ef          	jal	80000b4e <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	addi	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000840:	1141                	addi	sp,sp,-16
    80000842:	e406                	sd	ra,8(sp)
    80000844:	e022                	sd	s0,0(sp)
    80000846:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000848:	100007b7          	lui	a5,0x10000
    8000084c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000850:	10000737          	lui	a4,0x10000
    80000854:	f8000693          	li	a3,-128
    80000858:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000085c:	468d                	li	a3,3
    8000085e:	10000637          	lui	a2,0x10000
    80000862:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000866:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000086a:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	461d                	li	a2,7
    80000874:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000878:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    8000087c:	00006597          	auipc	a1,0x6
    80000880:	7b458593          	addi	a1,a1,1972 # 80007030 <etext+0x30>
    80000884:	00012517          	auipc	a0,0x12
    80000888:	adc50513          	addi	a0,a0,-1316 # 80012360 <tx_lock>
    8000088c:	2c2000ef          	jal	80000b4e <initlock>
}
    80000890:	60a2                	ld	ra,8(sp)
    80000892:	6402                	ld	s0,0(sp)
    80000894:	0141                	addi	sp,sp,16
    80000896:	8082                	ret

0000000080000898 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000898:	715d                	addi	sp,sp,-80
    8000089a:	e486                	sd	ra,72(sp)
    8000089c:	e0a2                	sd	s0,64(sp)
    8000089e:	fc26                	sd	s1,56(sp)
    800008a0:	ec56                	sd	s5,24(sp)
    800008a2:	0880                	addi	s0,sp,80
    800008a4:	8aaa                	mv	s5,a0
    800008a6:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008a8:	00012517          	auipc	a0,0x12
    800008ac:	ab850513          	addi	a0,a0,-1352 # 80012360 <tx_lock>
    800008b0:	31e000ef          	jal	80000bce <acquire>

  int i = 0;
  while(i < n){ 
    800008b4:	06905063          	blez	s1,80000914 <uartwrite+0x7c>
    800008b8:	f84a                	sd	s2,48(sp)
    800008ba:	f44e                	sd	s3,40(sp)
    800008bc:	f052                	sd	s4,32(sp)
    800008be:	e85a                	sd	s6,16(sp)
    800008c0:	e45e                	sd	s7,8(sp)
    800008c2:	8a56                	mv	s4,s5
    800008c4:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    800008c6:	0000a497          	auipc	s1,0xa
    800008ca:	9b648493          	addi	s1,s1,-1610 # 8000a27c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008ce:	00012997          	auipc	s3,0x12
    800008d2:	a9298993          	addi	s3,s3,-1390 # 80012360 <tx_lock>
    800008d6:	0000a917          	auipc	s2,0xa
    800008da:	9a290913          	addi	s2,s2,-1630 # 8000a278 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    800008de:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    800008e2:	4b05                	li	s6,1
    800008e4:	a005                	j	80000904 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    800008e6:	85ce                	mv	a1,s3
    800008e8:	854a                	mv	a0,s2
    800008ea:	5ee010ef          	jal	80001ed8 <sleep>
    while(tx_busy != 0){
    800008ee:	409c                	lw	a5,0(s1)
    800008f0:	fbfd                	bnez	a5,800008e6 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    800008f2:	000a4783          	lbu	a5,0(s4)
    800008f6:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008fa:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008fe:	0a05                	addi	s4,s4,1
    80000900:	015a0563          	beq	s4,s5,8000090a <uartwrite+0x72>
    while(tx_busy != 0){
    80000904:	409c                	lw	a5,0(s1)
    80000906:	f3e5                	bnez	a5,800008e6 <uartwrite+0x4e>
    80000908:	b7ed                	j	800008f2 <uartwrite+0x5a>
    8000090a:	7942                	ld	s2,48(sp)
    8000090c:	79a2                	ld	s3,40(sp)
    8000090e:	7a02                	ld	s4,32(sp)
    80000910:	6b42                	ld	s6,16(sp)
    80000912:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000914:	00012517          	auipc	a0,0x12
    80000918:	a4c50513          	addi	a0,a0,-1460 # 80012360 <tx_lock>
    8000091c:	34a000ef          	jal	80000c66 <release>
}
    80000920:	60a6                	ld	ra,72(sp)
    80000922:	6406                	ld	s0,64(sp)
    80000924:	74e2                	ld	s1,56(sp)
    80000926:	6ae2                	ld	s5,24(sp)
    80000928:	6161                	addi	sp,sp,80
    8000092a:	8082                	ret

000000008000092c <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000092c:	1101                	addi	sp,sp,-32
    8000092e:	ec06                	sd	ra,24(sp)
    80000930:	e822                	sd	s0,16(sp)
    80000932:	e426                	sd	s1,8(sp)
    80000934:	1000                	addi	s0,sp,32
    80000936:	84aa                	mv	s1,a0
  if(panicking == 0)
    80000938:	0000a797          	auipc	a5,0xa
    8000093c:	93c7a783          	lw	a5,-1732(a5) # 8000a274 <panicking>
    80000940:	cf95                	beqz	a5,8000097c <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000942:	0000a797          	auipc	a5,0xa
    80000946:	92e7a783          	lw	a5,-1746(a5) # 8000a270 <panicked>
    8000094a:	ef85                	bnez	a5,80000982 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000094c:	10000737          	lui	a4,0x10000
    80000950:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000952:	00074783          	lbu	a5,0(a4)
    80000956:	0207f793          	andi	a5,a5,32
    8000095a:	dfe5                	beqz	a5,80000952 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000095c:	0ff4f513          	zext.b	a0,s1
    80000960:	100007b7          	lui	a5,0x10000
    80000964:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000968:	0000a797          	auipc	a5,0xa
    8000096c:	90c7a783          	lw	a5,-1780(a5) # 8000a274 <panicking>
    80000970:	cb91                	beqz	a5,80000984 <uartputc_sync+0x58>
    pop_off();
}
    80000972:	60e2                	ld	ra,24(sp)
    80000974:	6442                	ld	s0,16(sp)
    80000976:	64a2                	ld	s1,8(sp)
    80000978:	6105                	addi	sp,sp,32
    8000097a:	8082                	ret
    push_off();
    8000097c:	212000ef          	jal	80000b8e <push_off>
    80000980:	b7c9                	j	80000942 <uartputc_sync+0x16>
    for(;;)
    80000982:	a001                	j	80000982 <uartputc_sync+0x56>
    pop_off();
    80000984:	28e000ef          	jal	80000c12 <pop_off>
}
    80000988:	b7ed                	j	80000972 <uartputc_sync+0x46>

000000008000098a <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000098a:	1141                	addi	sp,sp,-16
    8000098c:	e422                	sd	s0,8(sp)
    8000098e:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000990:	100007b7          	lui	a5,0x10000
    80000994:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80000996:	0007c783          	lbu	a5,0(a5)
    8000099a:	8b85                	andi	a5,a5,1
    8000099c:	cb81                	beqz	a5,800009ac <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    8000099e:	100007b7          	lui	a5,0x10000
    800009a2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009a6:	6422                	ld	s0,8(sp)
    800009a8:	0141                	addi	sp,sp,16
    800009aa:	8082                	ret
    return -1;
    800009ac:	557d                	li	a0,-1
    800009ae:	bfe5                	j	800009a6 <uartgetc+0x1c>

00000000800009b0 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009b0:	1101                	addi	sp,sp,-32
    800009b2:	ec06                	sd	ra,24(sp)
    800009b4:	e822                	sd	s0,16(sp)
    800009b6:	e426                	sd	s1,8(sp)
    800009b8:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009ba:	100007b7          	lui	a5,0x10000
    800009be:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    800009c0:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    800009c4:	00012517          	auipc	a0,0x12
    800009c8:	99c50513          	addi	a0,a0,-1636 # 80012360 <tx_lock>
    800009cc:	202000ef          	jal	80000bce <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    800009d0:	100007b7          	lui	a5,0x10000
    800009d4:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009d6:	0007c783          	lbu	a5,0(a5)
    800009da:	0207f793          	andi	a5,a5,32
    800009de:	eb89                	bnez	a5,800009f0 <uartintr+0x40>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    800009e0:	00012517          	auipc	a0,0x12
    800009e4:	98050513          	addi	a0,a0,-1664 # 80012360 <tx_lock>
    800009e8:	27e000ef          	jal	80000c66 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ec:	54fd                	li	s1,-1
    800009ee:	a831                	j	80000a0a <uartintr+0x5a>
    tx_busy = 0;
    800009f0:	0000a797          	auipc	a5,0xa
    800009f4:	8807a623          	sw	zero,-1908(a5) # 8000a27c <tx_busy>
    wakeup(&tx_chan);
    800009f8:	0000a517          	auipc	a0,0xa
    800009fc:	88050513          	addi	a0,a0,-1920 # 8000a278 <tx_chan>
    80000a00:	524010ef          	jal	80001f24 <wakeup>
    80000a04:	bff1                	j	800009e0 <uartintr+0x30>
      break;
    consoleintr(c);
    80000a06:	8a5ff0ef          	jal	800002aa <consoleintr>
    int c = uartgetc();
    80000a0a:	f81ff0ef          	jal	8000098a <uartgetc>
    if(c == -1)
    80000a0e:	fe951ce3          	bne	a0,s1,80000a06 <uartintr+0x56>
  }
}
    80000a12:	60e2                	ld	ra,24(sp)
    80000a14:	6442                	ld	s0,16(sp)
    80000a16:	64a2                	ld	s1,8(sp)
    80000a18:	6105                	addi	sp,sp,32
    80000a1a:	8082                	ret

0000000080000a1c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a1c:	1101                	addi	sp,sp,-32
    80000a1e:	ec06                	sd	ra,24(sp)
    80000a20:	e822                	sd	s0,16(sp)
    80000a22:	e426                	sd	s1,8(sp)
    80000a24:	e04a                	sd	s2,0(sp)
    80000a26:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a28:	03451793          	slli	a5,a0,0x34
    80000a2c:	e7a9                	bnez	a5,80000a76 <kfree+0x5a>
    80000a2e:	84aa                	mv	s1,a0
    80000a30:	00023797          	auipc	a5,0x23
    80000a34:	b7878793          	addi	a5,a5,-1160 # 800235a8 <end>
    80000a38:	02f56f63          	bltu	a0,a5,80000a76 <kfree+0x5a>
    80000a3c:	47c5                	li	a5,17
    80000a3e:	07ee                	slli	a5,a5,0x1b
    80000a40:	02f57b63          	bgeu	a0,a5,80000a76 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a44:	6605                	lui	a2,0x1
    80000a46:	4585                	li	a1,1
    80000a48:	25a000ef          	jal	80000ca2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a4c:	00012917          	auipc	s2,0x12
    80000a50:	92c90913          	addi	s2,s2,-1748 # 80012378 <kmem>
    80000a54:	854a                	mv	a0,s2
    80000a56:	178000ef          	jal	80000bce <acquire>
  r->next = kmem.freelist;
    80000a5a:	01893783          	ld	a5,24(s2)
    80000a5e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a60:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a64:	854a                	mv	a0,s2
    80000a66:	200000ef          	jal	80000c66 <release>
}
    80000a6a:	60e2                	ld	ra,24(sp)
    80000a6c:	6442                	ld	s0,16(sp)
    80000a6e:	64a2                	ld	s1,8(sp)
    80000a70:	6902                	ld	s2,0(sp)
    80000a72:	6105                	addi	sp,sp,32
    80000a74:	8082                	ret
    panic("kfree");
    80000a76:	00006517          	auipc	a0,0x6
    80000a7a:	5c250513          	addi	a0,a0,1474 # 80007038 <etext+0x38>
    80000a7e:	d63ff0ef          	jal	800007e0 <panic>

0000000080000a82 <freerange>:
{
    80000a82:	7179                	addi	sp,sp,-48
    80000a84:	f406                	sd	ra,40(sp)
    80000a86:	f022                	sd	s0,32(sp)
    80000a88:	ec26                	sd	s1,24(sp)
    80000a8a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a8c:	6785                	lui	a5,0x1
    80000a8e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a92:	00e504b3          	add	s1,a0,a4
    80000a96:	777d                	lui	a4,0xfffff
    80000a98:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a9a:	94be                	add	s1,s1,a5
    80000a9c:	0295e263          	bltu	a1,s1,80000ac0 <freerange+0x3e>
    80000aa0:	e84a                	sd	s2,16(sp)
    80000aa2:	e44e                	sd	s3,8(sp)
    80000aa4:	e052                	sd	s4,0(sp)
    80000aa6:	892e                	mv	s2,a1
    kfree(p);
    80000aa8:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aaa:	6985                	lui	s3,0x1
    kfree(p);
    80000aac:	01448533          	add	a0,s1,s4
    80000ab0:	f6dff0ef          	jal	80000a1c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ab4:	94ce                	add	s1,s1,s3
    80000ab6:	fe997be3          	bgeu	s2,s1,80000aac <freerange+0x2a>
    80000aba:	6942                	ld	s2,16(sp)
    80000abc:	69a2                	ld	s3,8(sp)
    80000abe:	6a02                	ld	s4,0(sp)
}
    80000ac0:	70a2                	ld	ra,40(sp)
    80000ac2:	7402                	ld	s0,32(sp)
    80000ac4:	64e2                	ld	s1,24(sp)
    80000ac6:	6145                	addi	sp,sp,48
    80000ac8:	8082                	ret

0000000080000aca <kinit>:
{
    80000aca:	1141                	addi	sp,sp,-16
    80000acc:	e406                	sd	ra,8(sp)
    80000ace:	e022                	sd	s0,0(sp)
    80000ad0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ad2:	00006597          	auipc	a1,0x6
    80000ad6:	56e58593          	addi	a1,a1,1390 # 80007040 <etext+0x40>
    80000ada:	00012517          	auipc	a0,0x12
    80000ade:	89e50513          	addi	a0,a0,-1890 # 80012378 <kmem>
    80000ae2:	06c000ef          	jal	80000b4e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ae6:	45c5                	li	a1,17
    80000ae8:	05ee                	slli	a1,a1,0x1b
    80000aea:	00023517          	auipc	a0,0x23
    80000aee:	abe50513          	addi	a0,a0,-1346 # 800235a8 <end>
    80000af2:	f91ff0ef          	jal	80000a82 <freerange>
}
    80000af6:	60a2                	ld	ra,8(sp)
    80000af8:	6402                	ld	s0,0(sp)
    80000afa:	0141                	addi	sp,sp,16
    80000afc:	8082                	ret

0000000080000afe <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000afe:	1101                	addi	sp,sp,-32
    80000b00:	ec06                	sd	ra,24(sp)
    80000b02:	e822                	sd	s0,16(sp)
    80000b04:	e426                	sd	s1,8(sp)
    80000b06:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b08:	00012497          	auipc	s1,0x12
    80000b0c:	87048493          	addi	s1,s1,-1936 # 80012378 <kmem>
    80000b10:	8526                	mv	a0,s1
    80000b12:	0bc000ef          	jal	80000bce <acquire>
  r = kmem.freelist;
    80000b16:	6c84                	ld	s1,24(s1)
  if(r)
    80000b18:	c485                	beqz	s1,80000b40 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b1a:	609c                	ld	a5,0(s1)
    80000b1c:	00012517          	auipc	a0,0x12
    80000b20:	85c50513          	addi	a0,a0,-1956 # 80012378 <kmem>
    80000b24:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b26:	140000ef          	jal	80000c66 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b2a:	6605                	lui	a2,0x1
    80000b2c:	4595                	li	a1,5
    80000b2e:	8526                	mv	a0,s1
    80000b30:	172000ef          	jal	80000ca2 <memset>
  return (void*)r;
}
    80000b34:	8526                	mv	a0,s1
    80000b36:	60e2                	ld	ra,24(sp)
    80000b38:	6442                	ld	s0,16(sp)
    80000b3a:	64a2                	ld	s1,8(sp)
    80000b3c:	6105                	addi	sp,sp,32
    80000b3e:	8082                	ret
  release(&kmem.lock);
    80000b40:	00012517          	auipc	a0,0x12
    80000b44:	83850513          	addi	a0,a0,-1992 # 80012378 <kmem>
    80000b48:	11e000ef          	jal	80000c66 <release>
  if(r)
    80000b4c:	b7e5                	j	80000b34 <kalloc+0x36>

0000000080000b4e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b4e:	1141                	addi	sp,sp,-16
    80000b50:	e422                	sd	s0,8(sp)
    80000b52:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b54:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b56:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b5a:	00053823          	sd	zero,16(a0)
}
    80000b5e:	6422                	ld	s0,8(sp)
    80000b60:	0141                	addi	sp,sp,16
    80000b62:	8082                	ret

0000000080000b64 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b64:	411c                	lw	a5,0(a0)
    80000b66:	e399                	bnez	a5,80000b6c <holding+0x8>
    80000b68:	4501                	li	a0,0
  return r;
}
    80000b6a:	8082                	ret
{
    80000b6c:	1101                	addi	sp,sp,-32
    80000b6e:	ec06                	sd	ra,24(sp)
    80000b70:	e822                	sd	s0,16(sp)
    80000b72:	e426                	sd	s1,8(sp)
    80000b74:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b76:	6904                	ld	s1,16(a0)
    80000b78:	53b000ef          	jal	800018b2 <mycpu>
    80000b7c:	40a48533          	sub	a0,s1,a0
    80000b80:	00153513          	seqz	a0,a0
}
    80000b84:	60e2                	ld	ra,24(sp)
    80000b86:	6442                	ld	s0,16(sp)
    80000b88:	64a2                	ld	s1,8(sp)
    80000b8a:	6105                	addi	sp,sp,32
    80000b8c:	8082                	ret

0000000080000b8e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8e:	1101                	addi	sp,sp,-32
    80000b90:	ec06                	sd	ra,24(sp)
    80000b92:	e822                	sd	s0,16(sp)
    80000b94:	e426                	sd	s1,8(sp)
    80000b96:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b98:	100024f3          	csrr	s1,sstatus
    80000b9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000ba0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ba2:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000ba6:	50d000ef          	jal	800018b2 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cb99                	beqz	a5,80000bc2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	505000ef          	jal	800018b2 <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addiw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	4f1000ef          	jal	800018b2 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bc6:	8085                	srli	s1,s1,0x1
    80000bc8:	8885                	andi	s1,s1,1
    80000bca:	dd64                	sw	s1,124(a0)
    80000bcc:	b7cd                	j	80000bae <push_off+0x20>

0000000080000bce <acquire>:
{
    80000bce:	1101                	addi	sp,sp,-32
    80000bd0:	ec06                	sd	ra,24(sp)
    80000bd2:	e822                	sd	s0,16(sp)
    80000bd4:	e426                	sd	s1,8(sp)
    80000bd6:	1000                	addi	s0,sp,32
    80000bd8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bda:	fb5ff0ef          	jal	80000b8e <push_off>
  if(holding(lk))
    80000bde:	8526                	mv	a0,s1
    80000be0:	f85ff0ef          	jal	80000b64 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	4705                	li	a4,1
  if(holding(lk))
    80000be6:	e105                	bnez	a0,80000c06 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be8:	87ba                	mv	a5,a4
    80000bea:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bee:	2781                	sext.w	a5,a5
    80000bf0:	ffe5                	bnez	a5,80000be8 <acquire+0x1a>
  __sync_synchronize();
    80000bf2:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000bf6:	4bd000ef          	jal	800018b2 <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00006517          	auipc	a0,0x6
    80000c0a:	44250513          	addi	a0,a0,1090 # 80007048 <etext+0x48>
    80000c0e:	bd3ff0ef          	jal	800007e0 <panic>

0000000080000c12 <pop_off>:

void
pop_off(void)
{
    80000c12:	1141                	addi	sp,sp,-16
    80000c14:	e406                	sd	ra,8(sp)
    80000c16:	e022                	sd	s0,0(sp)
    80000c18:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1a:	499000ef          	jal	800018b2 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c1e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c22:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c24:	e78d                	bnez	a5,80000c4e <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c26:	5d3c                	lw	a5,120(a0)
    80000c28:	02f05963          	blez	a5,80000c5a <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c2c:	37fd                	addiw	a5,a5,-1
    80000c2e:	0007871b          	sext.w	a4,a5
    80000c32:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c34:	eb09                	bnez	a4,80000c46 <pop_off+0x34>
    80000c36:	5d7c                	lw	a5,124(a0)
    80000c38:	c799                	beqz	a5,80000c46 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c3e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c42:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c46:	60a2                	ld	ra,8(sp)
    80000c48:	6402                	ld	s0,0(sp)
    80000c4a:	0141                	addi	sp,sp,16
    80000c4c:	8082                	ret
    panic("pop_off - interruptible");
    80000c4e:	00006517          	auipc	a0,0x6
    80000c52:	40250513          	addi	a0,a0,1026 # 80007050 <etext+0x50>
    80000c56:	b8bff0ef          	jal	800007e0 <panic>
    panic("pop_off");
    80000c5a:	00006517          	auipc	a0,0x6
    80000c5e:	40e50513          	addi	a0,a0,1038 # 80007068 <etext+0x68>
    80000c62:	b7fff0ef          	jal	800007e0 <panic>

0000000080000c66 <release>:
{
    80000c66:	1101                	addi	sp,sp,-32
    80000c68:	ec06                	sd	ra,24(sp)
    80000c6a:	e822                	sd	s0,16(sp)
    80000c6c:	e426                	sd	s1,8(sp)
    80000c6e:	1000                	addi	s0,sp,32
    80000c70:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c72:	ef3ff0ef          	jal	80000b64 <holding>
    80000c76:	c105                	beqz	a0,80000c96 <release+0x30>
  lk->cpu = 0;
    80000c78:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c7c:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000c80:	0310000f          	fence	rw,w
    80000c84:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000c88:	f8bff0ef          	jal	80000c12 <pop_off>
}
    80000c8c:	60e2                	ld	ra,24(sp)
    80000c8e:	6442                	ld	s0,16(sp)
    80000c90:	64a2                	ld	s1,8(sp)
    80000c92:	6105                	addi	sp,sp,32
    80000c94:	8082                	ret
    panic("release");
    80000c96:	00006517          	auipc	a0,0x6
    80000c9a:	3da50513          	addi	a0,a0,986 # 80007070 <etext+0x70>
    80000c9e:	b43ff0ef          	jal	800007e0 <panic>

0000000080000ca2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ca2:	1141                	addi	sp,sp,-16
    80000ca4:	e422                	sd	s0,8(sp)
    80000ca6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ca8:	ca19                	beqz	a2,80000cbe <memset+0x1c>
    80000caa:	87aa                	mv	a5,a0
    80000cac:	1602                	slli	a2,a2,0x20
    80000cae:	9201                	srli	a2,a2,0x20
    80000cb0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cb4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cb8:	0785                	addi	a5,a5,1
    80000cba:	fee79de3          	bne	a5,a4,80000cb4 <memset+0x12>
  }
  return dst;
}
    80000cbe:	6422                	ld	s0,8(sp)
    80000cc0:	0141                	addi	sp,sp,16
    80000cc2:	8082                	ret

0000000080000cc4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cc4:	1141                	addi	sp,sp,-16
    80000cc6:	e422                	sd	s0,8(sp)
    80000cc8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cca:	ca05                	beqz	a2,80000cfa <memcmp+0x36>
    80000ccc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cd0:	1682                	slli	a3,a3,0x20
    80000cd2:	9281                	srli	a3,a3,0x20
    80000cd4:	0685                	addi	a3,a3,1
    80000cd6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cd8:	00054783          	lbu	a5,0(a0)
    80000cdc:	0005c703          	lbu	a4,0(a1)
    80000ce0:	00e79863          	bne	a5,a4,80000cf0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000ce4:	0505                	addi	a0,a0,1
    80000ce6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ce8:	fed518e3          	bne	a0,a3,80000cd8 <memcmp+0x14>
  }

  return 0;
    80000cec:	4501                	li	a0,0
    80000cee:	a019                	j	80000cf4 <memcmp+0x30>
      return *s1 - *s2;
    80000cf0:	40e7853b          	subw	a0,a5,a4
}
    80000cf4:	6422                	ld	s0,8(sp)
    80000cf6:	0141                	addi	sp,sp,16
    80000cf8:	8082                	ret
  return 0;
    80000cfa:	4501                	li	a0,0
    80000cfc:	bfe5                	j	80000cf4 <memcmp+0x30>

0000000080000cfe <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000cfe:	1141                	addi	sp,sp,-16
    80000d00:	e422                	sd	s0,8(sp)
    80000d02:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d04:	c205                	beqz	a2,80000d24 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d06:	02a5e263          	bltu	a1,a0,80000d2a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d0a:	1602                	slli	a2,a2,0x20
    80000d0c:	9201                	srli	a2,a2,0x20
    80000d0e:	00c587b3          	add	a5,a1,a2
{
    80000d12:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d14:	0585                	addi	a1,a1,1
    80000d16:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdba59>
    80000d18:	fff5c683          	lbu	a3,-1(a1)
    80000d1c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d20:	feb79ae3          	bne	a5,a1,80000d14 <memmove+0x16>

  return dst;
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  if(s < d && s + n > d){
    80000d2a:	02061693          	slli	a3,a2,0x20
    80000d2e:	9281                	srli	a3,a3,0x20
    80000d30:	00d58733          	add	a4,a1,a3
    80000d34:	fce57be3          	bgeu	a0,a4,80000d0a <memmove+0xc>
    d += n;
    80000d38:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d3a:	fff6079b          	addiw	a5,a2,-1
    80000d3e:	1782                	slli	a5,a5,0x20
    80000d40:	9381                	srli	a5,a5,0x20
    80000d42:	fff7c793          	not	a5,a5
    80000d46:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d48:	177d                	addi	a4,a4,-1
    80000d4a:	16fd                	addi	a3,a3,-1
    80000d4c:	00074603          	lbu	a2,0(a4)
    80000d50:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d54:	fef71ae3          	bne	a4,a5,80000d48 <memmove+0x4a>
    80000d58:	b7f1                	j	80000d24 <memmove+0x26>

0000000080000d5a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d5a:	1141                	addi	sp,sp,-16
    80000d5c:	e406                	sd	ra,8(sp)
    80000d5e:	e022                	sd	s0,0(sp)
    80000d60:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d62:	f9dff0ef          	jal	80000cfe <memmove>
}
    80000d66:	60a2                	ld	ra,8(sp)
    80000d68:	6402                	ld	s0,0(sp)
    80000d6a:	0141                	addi	sp,sp,16
    80000d6c:	8082                	ret

0000000080000d6e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d6e:	1141                	addi	sp,sp,-16
    80000d70:	e422                	sd	s0,8(sp)
    80000d72:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d74:	ce11                	beqz	a2,80000d90 <strncmp+0x22>
    80000d76:	00054783          	lbu	a5,0(a0)
    80000d7a:	cf89                	beqz	a5,80000d94 <strncmp+0x26>
    80000d7c:	0005c703          	lbu	a4,0(a1)
    80000d80:	00f71a63          	bne	a4,a5,80000d94 <strncmp+0x26>
    n--, p++, q++;
    80000d84:	367d                	addiw	a2,a2,-1
    80000d86:	0505                	addi	a0,a0,1
    80000d88:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d8a:	f675                	bnez	a2,80000d76 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d8c:	4501                	li	a0,0
    80000d8e:	a801                	j	80000d9e <strncmp+0x30>
    80000d90:	4501                	li	a0,0
    80000d92:	a031                	j	80000d9e <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000d94:	00054503          	lbu	a0,0(a0)
    80000d98:	0005c783          	lbu	a5,0(a1)
    80000d9c:	9d1d                	subw	a0,a0,a5
}
    80000d9e:	6422                	ld	s0,8(sp)
    80000da0:	0141                	addi	sp,sp,16
    80000da2:	8082                	ret

0000000080000da4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000da4:	1141                	addi	sp,sp,-16
    80000da6:	e422                	sd	s0,8(sp)
    80000da8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000daa:	87aa                	mv	a5,a0
    80000dac:	86b2                	mv	a3,a2
    80000dae:	367d                	addiw	a2,a2,-1
    80000db0:	02d05563          	blez	a3,80000dda <strncpy+0x36>
    80000db4:	0785                	addi	a5,a5,1
    80000db6:	0005c703          	lbu	a4,0(a1)
    80000dba:	fee78fa3          	sb	a4,-1(a5)
    80000dbe:	0585                	addi	a1,a1,1
    80000dc0:	f775                	bnez	a4,80000dac <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dc2:	873e                	mv	a4,a5
    80000dc4:	9fb5                	addw	a5,a5,a3
    80000dc6:	37fd                	addiw	a5,a5,-1
    80000dc8:	00c05963          	blez	a2,80000dda <strncpy+0x36>
    *s++ = 0;
    80000dcc:	0705                	addi	a4,a4,1
    80000dce:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000dd2:	40e786bb          	subw	a3,a5,a4
    80000dd6:	fed04be3          	bgtz	a3,80000dcc <strncpy+0x28>
  return os;
}
    80000dda:	6422                	ld	s0,8(sp)
    80000ddc:	0141                	addi	sp,sp,16
    80000dde:	8082                	ret

0000000080000de0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000de0:	1141                	addi	sp,sp,-16
    80000de2:	e422                	sd	s0,8(sp)
    80000de4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000de6:	02c05363          	blez	a2,80000e0c <safestrcpy+0x2c>
    80000dea:	fff6069b          	addiw	a3,a2,-1
    80000dee:	1682                	slli	a3,a3,0x20
    80000df0:	9281                	srli	a3,a3,0x20
    80000df2:	96ae                	add	a3,a3,a1
    80000df4:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000df6:	00d58963          	beq	a1,a3,80000e08 <safestrcpy+0x28>
    80000dfa:	0585                	addi	a1,a1,1
    80000dfc:	0785                	addi	a5,a5,1
    80000dfe:	fff5c703          	lbu	a4,-1(a1)
    80000e02:	fee78fa3          	sb	a4,-1(a5)
    80000e06:	fb65                	bnez	a4,80000df6 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e08:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e0c:	6422                	ld	s0,8(sp)
    80000e0e:	0141                	addi	sp,sp,16
    80000e10:	8082                	ret

0000000080000e12 <strlen>:

int
strlen(const char *s)
{
    80000e12:	1141                	addi	sp,sp,-16
    80000e14:	e422                	sd	s0,8(sp)
    80000e16:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e18:	00054783          	lbu	a5,0(a0)
    80000e1c:	cf91                	beqz	a5,80000e38 <strlen+0x26>
    80000e1e:	0505                	addi	a0,a0,1
    80000e20:	87aa                	mv	a5,a0
    80000e22:	86be                	mv	a3,a5
    80000e24:	0785                	addi	a5,a5,1
    80000e26:	fff7c703          	lbu	a4,-1(a5)
    80000e2a:	ff65                	bnez	a4,80000e22 <strlen+0x10>
    80000e2c:	40a6853b          	subw	a0,a3,a0
    80000e30:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e38:	4501                	li	a0,0
    80000e3a:	bfe5                	j	80000e32 <strlen+0x20>

0000000080000e3c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e3c:	1141                	addi	sp,sp,-16
    80000e3e:	e406                	sd	ra,8(sp)
    80000e40:	e022                	sd	s0,0(sp)
    80000e42:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e44:	25f000ef          	jal	800018a2 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e48:	00009717          	auipc	a4,0x9
    80000e4c:	43870713          	addi	a4,a4,1080 # 8000a280 <started>
  if(cpuid() == 0){
    80000e50:	c51d                	beqz	a0,80000e7e <main+0x42>
    while(started == 0)
    80000e52:	431c                	lw	a5,0(a4)
    80000e54:	2781                	sext.w	a5,a5
    80000e56:	dff5                	beqz	a5,80000e52 <main+0x16>
      ;
    __sync_synchronize();
    80000e58:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000e5c:	247000ef          	jal	800018a2 <cpuid>
    80000e60:	85aa                	mv	a1,a0
    80000e62:	00006517          	auipc	a0,0x6
    80000e66:	23650513          	addi	a0,a0,566 # 80007098 <etext+0x98>
    80000e6a:	e90ff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000e6e:	080000ef          	jal	80000eee <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e72:	588010ef          	jal	800023fa <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e76:	662040ef          	jal	800054d8 <plicinithart>
  }

  scheduler();        
    80000e7a:	6c7000ef          	jal	80001d40 <scheduler>
    consoleinit();
    80000e7e:	da6ff0ef          	jal	80000424 <consoleinit>
    printfinit();
    80000e82:	99bff0ef          	jal	8000081c <printfinit>
    printf("\n");
    80000e86:	00006517          	auipc	a0,0x6
    80000e8a:	1f250513          	addi	a0,a0,498 # 80007078 <etext+0x78>
    80000e8e:	e6cff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000e92:	00006517          	auipc	a0,0x6
    80000e96:	1ee50513          	addi	a0,a0,494 # 80007080 <etext+0x80>
    80000e9a:	e60ff0ef          	jal	800004fa <printf>
    printf("\n");
    80000e9e:	00006517          	auipc	a0,0x6
    80000ea2:	1da50513          	addi	a0,a0,474 # 80007078 <etext+0x78>
    80000ea6:	e54ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000eaa:	c21ff0ef          	jal	80000aca <kinit>
    kvminit();       // create kernel page table
    80000eae:	2ca000ef          	jal	80001178 <kvminit>
    kvminithart();   // turn on paging
    80000eb2:	03c000ef          	jal	80000eee <kvminithart>
    procinit();      // process table
    80000eb6:	137000ef          	jal	800017ec <procinit>
    trapinit();      // trap vectors
    80000eba:	51c010ef          	jal	800023d6 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ebe:	53c010ef          	jal	800023fa <trapinithart>
    plicinit();      // set up interrupt controller
    80000ec2:	5fc040ef          	jal	800054be <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ec6:	612040ef          	jal	800054d8 <plicinithart>
    binit();         // buffer cache
    80000eca:	4d7010ef          	jal	80002ba0 <binit>
    iinit();         // inode table
    80000ece:	25c020ef          	jal	8000312a <iinit>
    fileinit();      // file table
    80000ed2:	14e030ef          	jal	80004020 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ed6:	6f2040ef          	jal	800055c8 <virtio_disk_init>
    userinit();      // first user process
    80000eda:	4bb000ef          	jal	80001b94 <userinit>
    __sync_synchronize();
    80000ede:	0330000f          	fence	rw,rw
    started = 1;
    80000ee2:	4785                	li	a5,1
    80000ee4:	00009717          	auipc	a4,0x9
    80000ee8:	38f72e23          	sw	a5,924(a4) # 8000a280 <started>
    80000eec:	b779                	j	80000e7a <main+0x3e>

0000000080000eee <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000eee:	1141                	addi	sp,sp,-16
    80000ef0:	e422                	sd	s0,8(sp)
    80000ef2:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000ef4:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ef8:	00009797          	auipc	a5,0x9
    80000efc:	3907b783          	ld	a5,912(a5) # 8000a288 <kernel_pagetable>
    80000f00:	83b1                	srli	a5,a5,0xc
    80000f02:	577d                	li	a4,-1
    80000f04:	177e                	slli	a4,a4,0x3f
    80000f06:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f08:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f0c:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f10:	6422                	ld	s0,8(sp)
    80000f12:	0141                	addi	sp,sp,16
    80000f14:	8082                	ret

0000000080000f16 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f16:	7139                	addi	sp,sp,-64
    80000f18:	fc06                	sd	ra,56(sp)
    80000f1a:	f822                	sd	s0,48(sp)
    80000f1c:	f426                	sd	s1,40(sp)
    80000f1e:	f04a                	sd	s2,32(sp)
    80000f20:	ec4e                	sd	s3,24(sp)
    80000f22:	e852                	sd	s4,16(sp)
    80000f24:	e456                	sd	s5,8(sp)
    80000f26:	e05a                	sd	s6,0(sp)
    80000f28:	0080                	addi	s0,sp,64
    80000f2a:	84aa                	mv	s1,a0
    80000f2c:	89ae                	mv	s3,a1
    80000f2e:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f30:	57fd                	li	a5,-1
    80000f32:	83e9                	srli	a5,a5,0x1a
    80000f34:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f36:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f38:	02b7fc63          	bgeu	a5,a1,80000f70 <walk+0x5a>
    panic("walk");
    80000f3c:	00006517          	auipc	a0,0x6
    80000f40:	17450513          	addi	a0,a0,372 # 800070b0 <etext+0xb0>
    80000f44:	89dff0ef          	jal	800007e0 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f48:	060a8263          	beqz	s5,80000fac <walk+0x96>
    80000f4c:	bb3ff0ef          	jal	80000afe <kalloc>
    80000f50:	84aa                	mv	s1,a0
    80000f52:	c139                	beqz	a0,80000f98 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f54:	6605                	lui	a2,0x1
    80000f56:	4581                	li	a1,0
    80000f58:	d4bff0ef          	jal	80000ca2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f5c:	00c4d793          	srli	a5,s1,0xc
    80000f60:	07aa                	slli	a5,a5,0xa
    80000f62:	0017e793          	ori	a5,a5,1
    80000f66:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f6a:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdba4f>
    80000f6c:	036a0063          	beq	s4,s6,80000f8c <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f70:	0149d933          	srl	s2,s3,s4
    80000f74:	1ff97913          	andi	s2,s2,511
    80000f78:	090e                	slli	s2,s2,0x3
    80000f7a:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f7c:	00093483          	ld	s1,0(s2)
    80000f80:	0014f793          	andi	a5,s1,1
    80000f84:	d3f1                	beqz	a5,80000f48 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f86:	80a9                	srli	s1,s1,0xa
    80000f88:	04b2                	slli	s1,s1,0xc
    80000f8a:	b7c5                	j	80000f6a <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f8c:	00c9d513          	srli	a0,s3,0xc
    80000f90:	1ff57513          	andi	a0,a0,511
    80000f94:	050e                	slli	a0,a0,0x3
    80000f96:	9526                	add	a0,a0,s1
}
    80000f98:	70e2                	ld	ra,56(sp)
    80000f9a:	7442                	ld	s0,48(sp)
    80000f9c:	74a2                	ld	s1,40(sp)
    80000f9e:	7902                	ld	s2,32(sp)
    80000fa0:	69e2                	ld	s3,24(sp)
    80000fa2:	6a42                	ld	s4,16(sp)
    80000fa4:	6aa2                	ld	s5,8(sp)
    80000fa6:	6b02                	ld	s6,0(sp)
    80000fa8:	6121                	addi	sp,sp,64
    80000faa:	8082                	ret
        return 0;
    80000fac:	4501                	li	a0,0
    80000fae:	b7ed                	j	80000f98 <walk+0x82>

0000000080000fb0 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fb0:	57fd                	li	a5,-1
    80000fb2:	83e9                	srli	a5,a5,0x1a
    80000fb4:	00b7f463          	bgeu	a5,a1,80000fbc <walkaddr+0xc>
    return 0;
    80000fb8:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fba:	8082                	ret
{
    80000fbc:	1141                	addi	sp,sp,-16
    80000fbe:	e406                	sd	ra,8(sp)
    80000fc0:	e022                	sd	s0,0(sp)
    80000fc2:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fc4:	4601                	li	a2,0
    80000fc6:	f51ff0ef          	jal	80000f16 <walk>
  if(pte == 0)
    80000fca:	c105                	beqz	a0,80000fea <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000fcc:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000fce:	0117f693          	andi	a3,a5,17
    80000fd2:	4745                	li	a4,17
    return 0;
    80000fd4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000fd6:	00e68663          	beq	a3,a4,80000fe2 <walkaddr+0x32>
}
    80000fda:	60a2                	ld	ra,8(sp)
    80000fdc:	6402                	ld	s0,0(sp)
    80000fde:	0141                	addi	sp,sp,16
    80000fe0:	8082                	ret
  pa = PTE2PA(*pte);
    80000fe2:	83a9                	srli	a5,a5,0xa
    80000fe4:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000fe8:	bfcd                	j	80000fda <walkaddr+0x2a>
    return 0;
    80000fea:	4501                	li	a0,0
    80000fec:	b7fd                	j	80000fda <walkaddr+0x2a>

0000000080000fee <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000fee:	715d                	addi	sp,sp,-80
    80000ff0:	e486                	sd	ra,72(sp)
    80000ff2:	e0a2                	sd	s0,64(sp)
    80000ff4:	fc26                	sd	s1,56(sp)
    80000ff6:	f84a                	sd	s2,48(sp)
    80000ff8:	f44e                	sd	s3,40(sp)
    80000ffa:	f052                	sd	s4,32(sp)
    80000ffc:	ec56                	sd	s5,24(sp)
    80000ffe:	e85a                	sd	s6,16(sp)
    80001000:	e45e                	sd	s7,8(sp)
    80001002:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001004:	03459793          	slli	a5,a1,0x34
    80001008:	e7a9                	bnez	a5,80001052 <mappages+0x64>
    8000100a:	8aaa                	mv	s5,a0
    8000100c:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    8000100e:	03461793          	slli	a5,a2,0x34
    80001012:	e7b1                	bnez	a5,8000105e <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80001014:	ca39                	beqz	a2,8000106a <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001016:	77fd                	lui	a5,0xfffff
    80001018:	963e                	add	a2,a2,a5
    8000101a:	00b609b3          	add	s3,a2,a1
  a = va;
    8000101e:	892e                	mv	s2,a1
    80001020:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001024:	6b85                	lui	s7,0x1
    80001026:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    8000102a:	4605                	li	a2,1
    8000102c:	85ca                	mv	a1,s2
    8000102e:	8556                	mv	a0,s5
    80001030:	ee7ff0ef          	jal	80000f16 <walk>
    80001034:	c539                	beqz	a0,80001082 <mappages+0x94>
    if(*pte & PTE_V)
    80001036:	611c                	ld	a5,0(a0)
    80001038:	8b85                	andi	a5,a5,1
    8000103a:	ef95                	bnez	a5,80001076 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000103c:	80b1                	srli	s1,s1,0xc
    8000103e:	04aa                	slli	s1,s1,0xa
    80001040:	0164e4b3          	or	s1,s1,s6
    80001044:	0014e493          	ori	s1,s1,1
    80001048:	e104                	sd	s1,0(a0)
    if(a == last)
    8000104a:	05390863          	beq	s2,s3,8000109a <mappages+0xac>
    a += PGSIZE;
    8000104e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	bfd9                	j	80001026 <mappages+0x38>
    panic("mappages: va not aligned");
    80001052:	00006517          	auipc	a0,0x6
    80001056:	06650513          	addi	a0,a0,102 # 800070b8 <etext+0xb8>
    8000105a:	f86ff0ef          	jal	800007e0 <panic>
    panic("mappages: size not aligned");
    8000105e:	00006517          	auipc	a0,0x6
    80001062:	07a50513          	addi	a0,a0,122 # 800070d8 <etext+0xd8>
    80001066:	f7aff0ef          	jal	800007e0 <panic>
    panic("mappages: size");
    8000106a:	00006517          	auipc	a0,0x6
    8000106e:	08e50513          	addi	a0,a0,142 # 800070f8 <etext+0xf8>
    80001072:	f6eff0ef          	jal	800007e0 <panic>
      panic("mappages: remap");
    80001076:	00006517          	auipc	a0,0x6
    8000107a:	09250513          	addi	a0,a0,146 # 80007108 <etext+0x108>
    8000107e:	f62ff0ef          	jal	800007e0 <panic>
      return -1;
    80001082:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001084:	60a6                	ld	ra,72(sp)
    80001086:	6406                	ld	s0,64(sp)
    80001088:	74e2                	ld	s1,56(sp)
    8000108a:	7942                	ld	s2,48(sp)
    8000108c:	79a2                	ld	s3,40(sp)
    8000108e:	7a02                	ld	s4,32(sp)
    80001090:	6ae2                	ld	s5,24(sp)
    80001092:	6b42                	ld	s6,16(sp)
    80001094:	6ba2                	ld	s7,8(sp)
    80001096:	6161                	addi	sp,sp,80
    80001098:	8082                	ret
  return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7e5                	j	80001084 <mappages+0x96>

000000008000109e <kvmmap>:
{
    8000109e:	1141                	addi	sp,sp,-16
    800010a0:	e406                	sd	ra,8(sp)
    800010a2:	e022                	sd	s0,0(sp)
    800010a4:	0800                	addi	s0,sp,16
    800010a6:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010a8:	86b2                	mv	a3,a2
    800010aa:	863e                	mv	a2,a5
    800010ac:	f43ff0ef          	jal	80000fee <mappages>
    800010b0:	e509                	bnez	a0,800010ba <kvmmap+0x1c>
}
    800010b2:	60a2                	ld	ra,8(sp)
    800010b4:	6402                	ld	s0,0(sp)
    800010b6:	0141                	addi	sp,sp,16
    800010b8:	8082                	ret
    panic("kvmmap");
    800010ba:	00006517          	auipc	a0,0x6
    800010be:	05e50513          	addi	a0,a0,94 # 80007118 <etext+0x118>
    800010c2:	f1eff0ef          	jal	800007e0 <panic>

00000000800010c6 <kvmmake>:
{
    800010c6:	1101                	addi	sp,sp,-32
    800010c8:	ec06                	sd	ra,24(sp)
    800010ca:	e822                	sd	s0,16(sp)
    800010cc:	e426                	sd	s1,8(sp)
    800010ce:	e04a                	sd	s2,0(sp)
    800010d0:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010d2:	a2dff0ef          	jal	80000afe <kalloc>
    800010d6:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010d8:	6605                	lui	a2,0x1
    800010da:	4581                	li	a1,0
    800010dc:	bc7ff0ef          	jal	80000ca2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800010e0:	4719                	li	a4,6
    800010e2:	6685                	lui	a3,0x1
    800010e4:	10000637          	lui	a2,0x10000
    800010e8:	100005b7          	lui	a1,0x10000
    800010ec:	8526                	mv	a0,s1
    800010ee:	fb1ff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010f2:	4719                	li	a4,6
    800010f4:	6685                	lui	a3,0x1
    800010f6:	10001637          	lui	a2,0x10001
    800010fa:	100015b7          	lui	a1,0x10001
    800010fe:	8526                	mv	a0,s1
    80001100:	f9fff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001104:	4719                	li	a4,6
    80001106:	040006b7          	lui	a3,0x4000
    8000110a:	0c000637          	lui	a2,0xc000
    8000110e:	0c0005b7          	lui	a1,0xc000
    80001112:	8526                	mv	a0,s1
    80001114:	f8bff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001118:	00006917          	auipc	s2,0x6
    8000111c:	ee890913          	addi	s2,s2,-280 # 80007000 <etext>
    80001120:	4729                	li	a4,10
    80001122:	80006697          	auipc	a3,0x80006
    80001126:	ede68693          	addi	a3,a3,-290 # 7000 <_entry-0x7fff9000>
    8000112a:	4605                	li	a2,1
    8000112c:	067e                	slli	a2,a2,0x1f
    8000112e:	85b2                	mv	a1,a2
    80001130:	8526                	mv	a0,s1
    80001132:	f6dff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001136:	46c5                	li	a3,17
    80001138:	06ee                	slli	a3,a3,0x1b
    8000113a:	4719                	li	a4,6
    8000113c:	412686b3          	sub	a3,a3,s2
    80001140:	864a                	mv	a2,s2
    80001142:	85ca                	mv	a1,s2
    80001144:	8526                	mv	a0,s1
    80001146:	f59ff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000114a:	4729                	li	a4,10
    8000114c:	6685                	lui	a3,0x1
    8000114e:	00005617          	auipc	a2,0x5
    80001152:	eb260613          	addi	a2,a2,-334 # 80006000 <_trampoline>
    80001156:	040005b7          	lui	a1,0x4000
    8000115a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000115c:	05b2                	slli	a1,a1,0xc
    8000115e:	8526                	mv	a0,s1
    80001160:	f3fff0ef          	jal	8000109e <kvmmap>
  proc_mapstacks(kpgtbl);
    80001164:	8526                	mv	a0,s1
    80001166:	5ee000ef          	jal	80001754 <proc_mapstacks>
}
    8000116a:	8526                	mv	a0,s1
    8000116c:	60e2                	ld	ra,24(sp)
    8000116e:	6442                	ld	s0,16(sp)
    80001170:	64a2                	ld	s1,8(sp)
    80001172:	6902                	ld	s2,0(sp)
    80001174:	6105                	addi	sp,sp,32
    80001176:	8082                	ret

0000000080001178 <kvminit>:
{
    80001178:	1141                	addi	sp,sp,-16
    8000117a:	e406                	sd	ra,8(sp)
    8000117c:	e022                	sd	s0,0(sp)
    8000117e:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001180:	f47ff0ef          	jal	800010c6 <kvmmake>
    80001184:	00009797          	auipc	a5,0x9
    80001188:	10a7b223          	sd	a0,260(a5) # 8000a288 <kernel_pagetable>
}
    8000118c:	60a2                	ld	ra,8(sp)
    8000118e:	6402                	ld	s0,0(sp)
    80001190:	0141                	addi	sp,sp,16
    80001192:	8082                	ret

0000000080001194 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001194:	1101                	addi	sp,sp,-32
    80001196:	ec06                	sd	ra,24(sp)
    80001198:	e822                	sd	s0,16(sp)
    8000119a:	e426                	sd	s1,8(sp)
    8000119c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000119e:	961ff0ef          	jal	80000afe <kalloc>
    800011a2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800011a4:	c509                	beqz	a0,800011ae <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800011a6:	6605                	lui	a2,0x1
    800011a8:	4581                	li	a1,0
    800011aa:	af9ff0ef          	jal	80000ca2 <memset>
  return pagetable;
}
    800011ae:	8526                	mv	a0,s1
    800011b0:	60e2                	ld	ra,24(sp)
    800011b2:	6442                	ld	s0,16(sp)
    800011b4:	64a2                	ld	s1,8(sp)
    800011b6:	6105                	addi	sp,sp,32
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	7139                	addi	sp,sp,-64
    800011bc:	fc06                	sd	ra,56(sp)
    800011be:	f822                	sd	s0,48(sp)
    800011c0:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e38d                	bnez	a5,800011e8 <uvmunmap+0x2e>
    800011c8:	f04a                	sd	s2,32(sp)
    800011ca:	ec4e                	sd	s3,24(sp)
    800011cc:	e852                	sd	s4,16(sp)
    800011ce:	e456                	sd	s5,8(sp)
    800011d0:	e05a                	sd	s6,0(sp)
    800011d2:	8a2a                	mv	s4,a0
    800011d4:	892e                	mv	s2,a1
    800011d6:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011d8:	0632                	slli	a2,a2,0xc
    800011da:	00b609b3          	add	s3,a2,a1
    800011de:	6b05                	lui	s6,0x1
    800011e0:	0535f963          	bgeu	a1,s3,80001232 <uvmunmap+0x78>
    800011e4:	f426                	sd	s1,40(sp)
    800011e6:	a015                	j	8000120a <uvmunmap+0x50>
    800011e8:	f426                	sd	s1,40(sp)
    800011ea:	f04a                	sd	s2,32(sp)
    800011ec:	ec4e                	sd	s3,24(sp)
    800011ee:	e852                	sd	s4,16(sp)
    800011f0:	e456                	sd	s5,8(sp)
    800011f2:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    800011f4:	00006517          	auipc	a0,0x6
    800011f8:	f2c50513          	addi	a0,a0,-212 # 80007120 <etext+0x120>
    800011fc:	de4ff0ef          	jal	800007e0 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001200:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001204:	995a                	add	s2,s2,s6
    80001206:	03397563          	bgeu	s2,s3,80001230 <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    8000120a:	4601                	li	a2,0
    8000120c:	85ca                	mv	a1,s2
    8000120e:	8552                	mv	a0,s4
    80001210:	d07ff0ef          	jal	80000f16 <walk>
    80001214:	84aa                	mv	s1,a0
    80001216:	d57d                	beqz	a0,80001204 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    80001218:	611c                	ld	a5,0(a0)
    8000121a:	0017f713          	andi	a4,a5,1
    8000121e:	d37d                	beqz	a4,80001204 <uvmunmap+0x4a>
    if(do_free){
    80001220:	fe0a80e3          	beqz	s5,80001200 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    80001224:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    80001226:	00c79513          	slli	a0,a5,0xc
    8000122a:	ff2ff0ef          	jal	80000a1c <kfree>
    8000122e:	bfc9                	j	80001200 <uvmunmap+0x46>
    80001230:	74a2                	ld	s1,40(sp)
    80001232:	7902                	ld	s2,32(sp)
    80001234:	69e2                	ld	s3,24(sp)
    80001236:	6a42                	ld	s4,16(sp)
    80001238:	6aa2                	ld	s5,8(sp)
    8000123a:	6b02                	ld	s6,0(sp)
  }
}
    8000123c:	70e2                	ld	ra,56(sp)
    8000123e:	7442                	ld	s0,48(sp)
    80001240:	6121                	addi	sp,sp,64
    80001242:	8082                	ret

0000000080001244 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001244:	1101                	addi	sp,sp,-32
    80001246:	ec06                	sd	ra,24(sp)
    80001248:	e822                	sd	s0,16(sp)
    8000124a:	e426                	sd	s1,8(sp)
    8000124c:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000124e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001250:	00b67d63          	bgeu	a2,a1,8000126a <uvmdealloc+0x26>
    80001254:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001256:	6785                	lui	a5,0x1
    80001258:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000125a:	00f60733          	add	a4,a2,a5
    8000125e:	76fd                	lui	a3,0xfffff
    80001260:	8f75                	and	a4,a4,a3
    80001262:	97ae                	add	a5,a5,a1
    80001264:	8ff5                	and	a5,a5,a3
    80001266:	00f76863          	bltu	a4,a5,80001276 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000126a:	8526                	mv	a0,s1
    8000126c:	60e2                	ld	ra,24(sp)
    8000126e:	6442                	ld	s0,16(sp)
    80001270:	64a2                	ld	s1,8(sp)
    80001272:	6105                	addi	sp,sp,32
    80001274:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001276:	8f99                	sub	a5,a5,a4
    80001278:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000127a:	4685                	li	a3,1
    8000127c:	0007861b          	sext.w	a2,a5
    80001280:	85ba                	mv	a1,a4
    80001282:	f39ff0ef          	jal	800011ba <uvmunmap>
    80001286:	b7d5                	j	8000126a <uvmdealloc+0x26>

0000000080001288 <uvmalloc>:
  if(newsz < oldsz)
    80001288:	08b66f63          	bltu	a2,a1,80001326 <uvmalloc+0x9e>
{
    8000128c:	7139                	addi	sp,sp,-64
    8000128e:	fc06                	sd	ra,56(sp)
    80001290:	f822                	sd	s0,48(sp)
    80001292:	ec4e                	sd	s3,24(sp)
    80001294:	e852                	sd	s4,16(sp)
    80001296:	e456                	sd	s5,8(sp)
    80001298:	0080                	addi	s0,sp,64
    8000129a:	8aaa                	mv	s5,a0
    8000129c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000129e:	6785                	lui	a5,0x1
    800012a0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012a2:	95be                	add	a1,a1,a5
    800012a4:	77fd                	lui	a5,0xfffff
    800012a6:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012aa:	08c9f063          	bgeu	s3,a2,8000132a <uvmalloc+0xa2>
    800012ae:	f426                	sd	s1,40(sp)
    800012b0:	f04a                	sd	s2,32(sp)
    800012b2:	e05a                	sd	s6,0(sp)
    800012b4:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012b6:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800012ba:	845ff0ef          	jal	80000afe <kalloc>
    800012be:	84aa                	mv	s1,a0
    if(mem == 0){
    800012c0:	c515                	beqz	a0,800012ec <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800012c2:	6605                	lui	a2,0x1
    800012c4:	4581                	li	a1,0
    800012c6:	9ddff0ef          	jal	80000ca2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012ca:	875a                	mv	a4,s6
    800012cc:	86a6                	mv	a3,s1
    800012ce:	6605                	lui	a2,0x1
    800012d0:	85ca                	mv	a1,s2
    800012d2:	8556                	mv	a0,s5
    800012d4:	d1bff0ef          	jal	80000fee <mappages>
    800012d8:	e915                	bnez	a0,8000130c <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012da:	6785                	lui	a5,0x1
    800012dc:	993e                	add	s2,s2,a5
    800012de:	fd496ee3          	bltu	s2,s4,800012ba <uvmalloc+0x32>
  return newsz;
    800012e2:	8552                	mv	a0,s4
    800012e4:	74a2                	ld	s1,40(sp)
    800012e6:	7902                	ld	s2,32(sp)
    800012e8:	6b02                	ld	s6,0(sp)
    800012ea:	a811                	j	800012fe <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800012ec:	864e                	mv	a2,s3
    800012ee:	85ca                	mv	a1,s2
    800012f0:	8556                	mv	a0,s5
    800012f2:	f53ff0ef          	jal	80001244 <uvmdealloc>
      return 0;
    800012f6:	4501                	li	a0,0
    800012f8:	74a2                	ld	s1,40(sp)
    800012fa:	7902                	ld	s2,32(sp)
    800012fc:	6b02                	ld	s6,0(sp)
}
    800012fe:	70e2                	ld	ra,56(sp)
    80001300:	7442                	ld	s0,48(sp)
    80001302:	69e2                	ld	s3,24(sp)
    80001304:	6a42                	ld	s4,16(sp)
    80001306:	6aa2                	ld	s5,8(sp)
    80001308:	6121                	addi	sp,sp,64
    8000130a:	8082                	ret
      kfree(mem);
    8000130c:	8526                	mv	a0,s1
    8000130e:	f0eff0ef          	jal	80000a1c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001312:	864e                	mv	a2,s3
    80001314:	85ca                	mv	a1,s2
    80001316:	8556                	mv	a0,s5
    80001318:	f2dff0ef          	jal	80001244 <uvmdealloc>
      return 0;
    8000131c:	4501                	li	a0,0
    8000131e:	74a2                	ld	s1,40(sp)
    80001320:	7902                	ld	s2,32(sp)
    80001322:	6b02                	ld	s6,0(sp)
    80001324:	bfe9                	j	800012fe <uvmalloc+0x76>
    return oldsz;
    80001326:	852e                	mv	a0,a1
}
    80001328:	8082                	ret
  return newsz;
    8000132a:	8532                	mv	a0,a2
    8000132c:	bfc9                	j	800012fe <uvmalloc+0x76>

000000008000132e <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000132e:	7179                	addi	sp,sp,-48
    80001330:	f406                	sd	ra,40(sp)
    80001332:	f022                	sd	s0,32(sp)
    80001334:	ec26                	sd	s1,24(sp)
    80001336:	e84a                	sd	s2,16(sp)
    80001338:	e44e                	sd	s3,8(sp)
    8000133a:	e052                	sd	s4,0(sp)
    8000133c:	1800                	addi	s0,sp,48
    8000133e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001340:	84aa                	mv	s1,a0
    80001342:	6905                	lui	s2,0x1
    80001344:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001346:	4985                	li	s3,1
    80001348:	a819                	j	8000135e <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000134a:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000134c:	00c79513          	slli	a0,a5,0xc
    80001350:	fdfff0ef          	jal	8000132e <freewalk>
      pagetable[i] = 0;
    80001354:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001358:	04a1                	addi	s1,s1,8
    8000135a:	01248f63          	beq	s1,s2,80001378 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    8000135e:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001360:	00f7f713          	andi	a4,a5,15
    80001364:	ff3703e3          	beq	a4,s3,8000134a <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001368:	8b85                	andi	a5,a5,1
    8000136a:	d7fd                	beqz	a5,80001358 <freewalk+0x2a>
      panic("freewalk: leaf");
    8000136c:	00006517          	auipc	a0,0x6
    80001370:	dcc50513          	addi	a0,a0,-564 # 80007138 <etext+0x138>
    80001374:	c6cff0ef          	jal	800007e0 <panic>
    }
  }
  kfree((void*)pagetable);
    80001378:	8552                	mv	a0,s4
    8000137a:	ea2ff0ef          	jal	80000a1c <kfree>
}
    8000137e:	70a2                	ld	ra,40(sp)
    80001380:	7402                	ld	s0,32(sp)
    80001382:	64e2                	ld	s1,24(sp)
    80001384:	6942                	ld	s2,16(sp)
    80001386:	69a2                	ld	s3,8(sp)
    80001388:	6a02                	ld	s4,0(sp)
    8000138a:	6145                	addi	sp,sp,48
    8000138c:	8082                	ret

000000008000138e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000138e:	1101                	addi	sp,sp,-32
    80001390:	ec06                	sd	ra,24(sp)
    80001392:	e822                	sd	s0,16(sp)
    80001394:	e426                	sd	s1,8(sp)
    80001396:	1000                	addi	s0,sp,32
    80001398:	84aa                	mv	s1,a0
  if(sz > 0)
    8000139a:	e989                	bnez	a1,800013ac <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000139c:	8526                	mv	a0,s1
    8000139e:	f91ff0ef          	jal	8000132e <freewalk>
}
    800013a2:	60e2                	ld	ra,24(sp)
    800013a4:	6442                	ld	s0,16(sp)
    800013a6:	64a2                	ld	s1,8(sp)
    800013a8:	6105                	addi	sp,sp,32
    800013aa:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800013ac:	6785                	lui	a5,0x1
    800013ae:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013b0:	95be                	add	a1,a1,a5
    800013b2:	4685                	li	a3,1
    800013b4:	00c5d613          	srli	a2,a1,0xc
    800013b8:	4581                	li	a1,0
    800013ba:	e01ff0ef          	jal	800011ba <uvmunmap>
    800013be:	bff9                	j	8000139c <uvmfree+0xe>

00000000800013c0 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800013c0:	ce49                	beqz	a2,8000145a <uvmcopy+0x9a>
{
    800013c2:	715d                	addi	sp,sp,-80
    800013c4:	e486                	sd	ra,72(sp)
    800013c6:	e0a2                	sd	s0,64(sp)
    800013c8:	fc26                	sd	s1,56(sp)
    800013ca:	f84a                	sd	s2,48(sp)
    800013cc:	f44e                	sd	s3,40(sp)
    800013ce:	f052                	sd	s4,32(sp)
    800013d0:	ec56                	sd	s5,24(sp)
    800013d2:	e85a                	sd	s6,16(sp)
    800013d4:	e45e                	sd	s7,8(sp)
    800013d6:	0880                	addi	s0,sp,80
    800013d8:	8aaa                	mv	s5,a0
    800013da:	8b2e                	mv	s6,a1
    800013dc:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800013de:	4481                	li	s1,0
    800013e0:	a029                	j	800013ea <uvmcopy+0x2a>
    800013e2:	6785                	lui	a5,0x1
    800013e4:	94be                	add	s1,s1,a5
    800013e6:	0544fe63          	bgeu	s1,s4,80001442 <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    800013ea:	4601                	li	a2,0
    800013ec:	85a6                	mv	a1,s1
    800013ee:	8556                	mv	a0,s5
    800013f0:	b27ff0ef          	jal	80000f16 <walk>
    800013f4:	d57d                	beqz	a0,800013e2 <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    800013f6:	6118                	ld	a4,0(a0)
    800013f8:	00177793          	andi	a5,a4,1
    800013fc:	d3fd                	beqz	a5,800013e2 <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    800013fe:	00a75593          	srli	a1,a4,0xa
    80001402:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001406:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    8000140a:	ef4ff0ef          	jal	80000afe <kalloc>
    8000140e:	89aa                	mv	s3,a0
    80001410:	c105                	beqz	a0,80001430 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001412:	6605                	lui	a2,0x1
    80001414:	85de                	mv	a1,s7
    80001416:	8e9ff0ef          	jal	80000cfe <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000141a:	874a                	mv	a4,s2
    8000141c:	86ce                	mv	a3,s3
    8000141e:	6605                	lui	a2,0x1
    80001420:	85a6                	mv	a1,s1
    80001422:	855a                	mv	a0,s6
    80001424:	bcbff0ef          	jal	80000fee <mappages>
    80001428:	dd4d                	beqz	a0,800013e2 <uvmcopy+0x22>
      kfree(mem);
    8000142a:	854e                	mv	a0,s3
    8000142c:	df0ff0ef          	jal	80000a1c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001430:	4685                	li	a3,1
    80001432:	00c4d613          	srli	a2,s1,0xc
    80001436:	4581                	li	a1,0
    80001438:	855a                	mv	a0,s6
    8000143a:	d81ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000143e:	557d                	li	a0,-1
    80001440:	a011                	j	80001444 <uvmcopy+0x84>
  return 0;
    80001442:	4501                	li	a0,0
}
    80001444:	60a6                	ld	ra,72(sp)
    80001446:	6406                	ld	s0,64(sp)
    80001448:	74e2                	ld	s1,56(sp)
    8000144a:	7942                	ld	s2,48(sp)
    8000144c:	79a2                	ld	s3,40(sp)
    8000144e:	7a02                	ld	s4,32(sp)
    80001450:	6ae2                	ld	s5,24(sp)
    80001452:	6b42                	ld	s6,16(sp)
    80001454:	6ba2                	ld	s7,8(sp)
    80001456:	6161                	addi	sp,sp,80
    80001458:	8082                	ret
  return 0;
    8000145a:	4501                	li	a0,0
}
    8000145c:	8082                	ret

000000008000145e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000145e:	1141                	addi	sp,sp,-16
    80001460:	e406                	sd	ra,8(sp)
    80001462:	e022                	sd	s0,0(sp)
    80001464:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001466:	4601                	li	a2,0
    80001468:	aafff0ef          	jal	80000f16 <walk>
  if(pte == 0)
    8000146c:	c901                	beqz	a0,8000147c <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000146e:	611c                	ld	a5,0(a0)
    80001470:	9bbd                	andi	a5,a5,-17
    80001472:	e11c                	sd	a5,0(a0)
}
    80001474:	60a2                	ld	ra,8(sp)
    80001476:	6402                	ld	s0,0(sp)
    80001478:	0141                	addi	sp,sp,16
    8000147a:	8082                	ret
    panic("uvmclear");
    8000147c:	00006517          	auipc	a0,0x6
    80001480:	ccc50513          	addi	a0,a0,-820 # 80007148 <etext+0x148>
    80001484:	b5cff0ef          	jal	800007e0 <panic>

0000000080001488 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001488:	c6dd                	beqz	a3,80001536 <copyinstr+0xae>
{
    8000148a:	715d                	addi	sp,sp,-80
    8000148c:	e486                	sd	ra,72(sp)
    8000148e:	e0a2                	sd	s0,64(sp)
    80001490:	fc26                	sd	s1,56(sp)
    80001492:	f84a                	sd	s2,48(sp)
    80001494:	f44e                	sd	s3,40(sp)
    80001496:	f052                	sd	s4,32(sp)
    80001498:	ec56                	sd	s5,24(sp)
    8000149a:	e85a                	sd	s6,16(sp)
    8000149c:	e45e                	sd	s7,8(sp)
    8000149e:	0880                	addi	s0,sp,80
    800014a0:	8a2a                	mv	s4,a0
    800014a2:	8b2e                	mv	s6,a1
    800014a4:	8bb2                	mv	s7,a2
    800014a6:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800014a8:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800014aa:	6985                	lui	s3,0x1
    800014ac:	a825                	j	800014e4 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800014ae:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800014b2:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800014b4:	37fd                	addiw	a5,a5,-1
    800014b6:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800014ba:	60a6                	ld	ra,72(sp)
    800014bc:	6406                	ld	s0,64(sp)
    800014be:	74e2                	ld	s1,56(sp)
    800014c0:	7942                	ld	s2,48(sp)
    800014c2:	79a2                	ld	s3,40(sp)
    800014c4:	7a02                	ld	s4,32(sp)
    800014c6:	6ae2                	ld	s5,24(sp)
    800014c8:	6b42                	ld	s6,16(sp)
    800014ca:	6ba2                	ld	s7,8(sp)
    800014cc:	6161                	addi	sp,sp,80
    800014ce:	8082                	ret
    800014d0:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800014d4:	9742                	add	a4,a4,a6
      --max;
    800014d6:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    800014da:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    800014de:	04e58463          	beq	a1,a4,80001526 <copyinstr+0x9e>
{
    800014e2:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    800014e4:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800014e8:	85a6                	mv	a1,s1
    800014ea:	8552                	mv	a0,s4
    800014ec:	ac5ff0ef          	jal	80000fb0 <walkaddr>
    if(pa0 == 0)
    800014f0:	cd0d                	beqz	a0,8000152a <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800014f2:	417486b3          	sub	a3,s1,s7
    800014f6:	96ce                	add	a3,a3,s3
    if(n > max)
    800014f8:	00d97363          	bgeu	s2,a3,800014fe <copyinstr+0x76>
    800014fc:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    800014fe:	955e                	add	a0,a0,s7
    80001500:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001502:	c695                	beqz	a3,8000152e <copyinstr+0xa6>
    80001504:	87da                	mv	a5,s6
    80001506:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001508:	41650633          	sub	a2,a0,s6
    while(n > 0){
    8000150c:	96da                	add	a3,a3,s6
    8000150e:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001510:	00f60733          	add	a4,a2,a5
    80001514:	00074703          	lbu	a4,0(a4)
    80001518:	db59                	beqz	a4,800014ae <copyinstr+0x26>
        *dst = *p;
    8000151a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000151e:	0785                	addi	a5,a5,1
    while(n > 0){
    80001520:	fed797e3          	bne	a5,a3,8000150e <copyinstr+0x86>
    80001524:	b775                	j	800014d0 <copyinstr+0x48>
    80001526:	4781                	li	a5,0
    80001528:	b771                	j	800014b4 <copyinstr+0x2c>
      return -1;
    8000152a:	557d                	li	a0,-1
    8000152c:	b779                	j	800014ba <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    8000152e:	6b85                	lui	s7,0x1
    80001530:	9ba6                	add	s7,s7,s1
    80001532:	87da                	mv	a5,s6
    80001534:	b77d                	j	800014e2 <copyinstr+0x5a>
  int got_null = 0;
    80001536:	4781                	li	a5,0
  if(got_null){
    80001538:	37fd                	addiw	a5,a5,-1
    8000153a:	0007851b          	sext.w	a0,a5
}
    8000153e:	8082                	ret

0000000080001540 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    80001540:	1141                	addi	sp,sp,-16
    80001542:	e406                	sd	ra,8(sp)
    80001544:	e022                	sd	s0,0(sp)
    80001546:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001548:	4601                	li	a2,0
    8000154a:	9cdff0ef          	jal	80000f16 <walk>
  if (pte == 0) {
    8000154e:	c519                	beqz	a0,8000155c <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    80001550:	6108                	ld	a0,0(a0)
    80001552:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001554:	60a2                	ld	ra,8(sp)
    80001556:	6402                	ld	s0,0(sp)
    80001558:	0141                	addi	sp,sp,16
    8000155a:	8082                	ret
    return 0;
    8000155c:	4501                	li	a0,0
    8000155e:	bfdd                	j	80001554 <ismapped+0x14>

0000000080001560 <vmfault>:
{
    80001560:	7179                	addi	sp,sp,-48
    80001562:	f406                	sd	ra,40(sp)
    80001564:	f022                	sd	s0,32(sp)
    80001566:	ec26                	sd	s1,24(sp)
    80001568:	e44e                	sd	s3,8(sp)
    8000156a:	1800                	addi	s0,sp,48
    8000156c:	89aa                	mv	s3,a0
    8000156e:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    80001570:	35e000ef          	jal	800018ce <myproc>
  if (va >= p->sz)
    80001574:	653c                	ld	a5,72(a0)
    80001576:	00f4ea63          	bltu	s1,a5,8000158a <vmfault+0x2a>
    return 0;
    8000157a:	4981                	li	s3,0
}
    8000157c:	854e                	mv	a0,s3
    8000157e:	70a2                	ld	ra,40(sp)
    80001580:	7402                	ld	s0,32(sp)
    80001582:	64e2                	ld	s1,24(sp)
    80001584:	69a2                	ld	s3,8(sp)
    80001586:	6145                	addi	sp,sp,48
    80001588:	8082                	ret
    8000158a:	e84a                	sd	s2,16(sp)
    8000158c:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    8000158e:	77fd                	lui	a5,0xfffff
    80001590:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80001592:	85a6                	mv	a1,s1
    80001594:	854e                	mv	a0,s3
    80001596:	fabff0ef          	jal	80001540 <ismapped>
    return 0;
    8000159a:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    8000159c:	c119                	beqz	a0,800015a2 <vmfault+0x42>
    8000159e:	6942                	ld	s2,16(sp)
    800015a0:	bff1                	j	8000157c <vmfault+0x1c>
    800015a2:	e052                	sd	s4,0(sp)
  mem = (uint64) kalloc();
    800015a4:	d5aff0ef          	jal	80000afe <kalloc>
    800015a8:	8a2a                	mv	s4,a0
  if(mem == 0)
    800015aa:	c90d                	beqz	a0,800015dc <vmfault+0x7c>
  mem = (uint64) kalloc();
    800015ac:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    800015ae:	6605                	lui	a2,0x1
    800015b0:	4581                	li	a1,0
    800015b2:	ef0ff0ef          	jal	80000ca2 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    800015b6:	4759                	li	a4,22
    800015b8:	86d2                	mv	a3,s4
    800015ba:	6605                	lui	a2,0x1
    800015bc:	85a6                	mv	a1,s1
    800015be:	05093503          	ld	a0,80(s2)
    800015c2:	a2dff0ef          	jal	80000fee <mappages>
    800015c6:	e501                	bnez	a0,800015ce <vmfault+0x6e>
    800015c8:	6942                	ld	s2,16(sp)
    800015ca:	6a02                	ld	s4,0(sp)
    800015cc:	bf45                	j	8000157c <vmfault+0x1c>
    kfree((void *)mem);
    800015ce:	8552                	mv	a0,s4
    800015d0:	c4cff0ef          	jal	80000a1c <kfree>
    return 0;
    800015d4:	4981                	li	s3,0
    800015d6:	6942                	ld	s2,16(sp)
    800015d8:	6a02                	ld	s4,0(sp)
    800015da:	b74d                	j	8000157c <vmfault+0x1c>
    800015dc:	6942                	ld	s2,16(sp)
    800015de:	6a02                	ld	s4,0(sp)
    800015e0:	bf71                	j	8000157c <vmfault+0x1c>

00000000800015e2 <copyout>:
  while(len > 0){
    800015e2:	c2cd                	beqz	a3,80001684 <copyout+0xa2>
{
    800015e4:	711d                	addi	sp,sp,-96
    800015e6:	ec86                	sd	ra,88(sp)
    800015e8:	e8a2                	sd	s0,80(sp)
    800015ea:	e4a6                	sd	s1,72(sp)
    800015ec:	f852                	sd	s4,48(sp)
    800015ee:	f05a                	sd	s6,32(sp)
    800015f0:	ec5e                	sd	s7,24(sp)
    800015f2:	e862                	sd	s8,16(sp)
    800015f4:	1080                	addi	s0,sp,96
    800015f6:	8c2a                	mv	s8,a0
    800015f8:	8b2e                	mv	s6,a1
    800015fa:	8bb2                	mv	s7,a2
    800015fc:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800015fe:	74fd                	lui	s1,0xfffff
    80001600:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001602:	57fd                	li	a5,-1
    80001604:	83e9                	srli	a5,a5,0x1a
    80001606:	0897e163          	bltu	a5,s1,80001688 <copyout+0xa6>
    8000160a:	e0ca                	sd	s2,64(sp)
    8000160c:	fc4e                	sd	s3,56(sp)
    8000160e:	f456                	sd	s5,40(sp)
    80001610:	e466                	sd	s9,8(sp)
    80001612:	e06a                	sd	s10,0(sp)
    80001614:	6d05                	lui	s10,0x1
    80001616:	8cbe                	mv	s9,a5
    80001618:	a015                	j	8000163c <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000161a:	409b0533          	sub	a0,s6,s1
    8000161e:	0009861b          	sext.w	a2,s3
    80001622:	85de                	mv	a1,s7
    80001624:	954a                	add	a0,a0,s2
    80001626:	ed8ff0ef          	jal	80000cfe <memmove>
    len -= n;
    8000162a:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000162e:	9bce                	add	s7,s7,s3
  while(len > 0){
    80001630:	040a0363          	beqz	s4,80001676 <copyout+0x94>
    if(va0 >= MAXVA)
    80001634:	055cec63          	bltu	s9,s5,8000168c <copyout+0xaa>
    80001638:	84d6                	mv	s1,s5
    8000163a:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    8000163c:	85a6                	mv	a1,s1
    8000163e:	8562                	mv	a0,s8
    80001640:	971ff0ef          	jal	80000fb0 <walkaddr>
    80001644:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80001646:	e901                	bnez	a0,80001656 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001648:	4601                	li	a2,0
    8000164a:	85a6                	mv	a1,s1
    8000164c:	8562                	mv	a0,s8
    8000164e:	f13ff0ef          	jal	80001560 <vmfault>
    80001652:	892a                	mv	s2,a0
    80001654:	c139                	beqz	a0,8000169a <copyout+0xb8>
    pte = walk(pagetable, va0, 0);
    80001656:	4601                	li	a2,0
    80001658:	85a6                	mv	a1,s1
    8000165a:	8562                	mv	a0,s8
    8000165c:	8bbff0ef          	jal	80000f16 <walk>
    if((*pte & PTE_W) == 0)
    80001660:	611c                	ld	a5,0(a0)
    80001662:	8b91                	andi	a5,a5,4
    80001664:	c3b1                	beqz	a5,800016a8 <copyout+0xc6>
    n = PGSIZE - (dstva - va0);
    80001666:	01a48ab3          	add	s5,s1,s10
    8000166a:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    8000166e:	fb3a76e3          	bgeu	s4,s3,8000161a <copyout+0x38>
    80001672:	89d2                	mv	s3,s4
    80001674:	b75d                	j	8000161a <copyout+0x38>
  return 0;
    80001676:	4501                	li	a0,0
    80001678:	6906                	ld	s2,64(sp)
    8000167a:	79e2                	ld	s3,56(sp)
    8000167c:	7aa2                	ld	s5,40(sp)
    8000167e:	6ca2                	ld	s9,8(sp)
    80001680:	6d02                	ld	s10,0(sp)
    80001682:	a80d                	j	800016b4 <copyout+0xd2>
    80001684:	4501                	li	a0,0
}
    80001686:	8082                	ret
      return -1;
    80001688:	557d                	li	a0,-1
    8000168a:	a02d                	j	800016b4 <copyout+0xd2>
    8000168c:	557d                	li	a0,-1
    8000168e:	6906                	ld	s2,64(sp)
    80001690:	79e2                	ld	s3,56(sp)
    80001692:	7aa2                	ld	s5,40(sp)
    80001694:	6ca2                	ld	s9,8(sp)
    80001696:	6d02                	ld	s10,0(sp)
    80001698:	a831                	j	800016b4 <copyout+0xd2>
        return -1;
    8000169a:	557d                	li	a0,-1
    8000169c:	6906                	ld	s2,64(sp)
    8000169e:	79e2                	ld	s3,56(sp)
    800016a0:	7aa2                	ld	s5,40(sp)
    800016a2:	6ca2                	ld	s9,8(sp)
    800016a4:	6d02                	ld	s10,0(sp)
    800016a6:	a039                	j	800016b4 <copyout+0xd2>
      return -1;
    800016a8:	557d                	li	a0,-1
    800016aa:	6906                	ld	s2,64(sp)
    800016ac:	79e2                	ld	s3,56(sp)
    800016ae:	7aa2                	ld	s5,40(sp)
    800016b0:	6ca2                	ld	s9,8(sp)
    800016b2:	6d02                	ld	s10,0(sp)
}
    800016b4:	60e6                	ld	ra,88(sp)
    800016b6:	6446                	ld	s0,80(sp)
    800016b8:	64a6                	ld	s1,72(sp)
    800016ba:	7a42                	ld	s4,48(sp)
    800016bc:	7b02                	ld	s6,32(sp)
    800016be:	6be2                	ld	s7,24(sp)
    800016c0:	6c42                	ld	s8,16(sp)
    800016c2:	6125                	addi	sp,sp,96
    800016c4:	8082                	ret

00000000800016c6 <copyin>:
  while(len > 0){
    800016c6:	c6c9                	beqz	a3,80001750 <copyin+0x8a>
{
    800016c8:	715d                	addi	sp,sp,-80
    800016ca:	e486                	sd	ra,72(sp)
    800016cc:	e0a2                	sd	s0,64(sp)
    800016ce:	fc26                	sd	s1,56(sp)
    800016d0:	f84a                	sd	s2,48(sp)
    800016d2:	f44e                	sd	s3,40(sp)
    800016d4:	f052                	sd	s4,32(sp)
    800016d6:	ec56                	sd	s5,24(sp)
    800016d8:	e85a                	sd	s6,16(sp)
    800016da:	e45e                	sd	s7,8(sp)
    800016dc:	e062                	sd	s8,0(sp)
    800016de:	0880                	addi	s0,sp,80
    800016e0:	8baa                	mv	s7,a0
    800016e2:	8aae                	mv	s5,a1
    800016e4:	8932                	mv	s2,a2
    800016e6:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    800016e8:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    800016ea:	6b05                	lui	s6,0x1
    800016ec:	a035                	j	80001718 <copyin+0x52>
    800016ee:	412984b3          	sub	s1,s3,s2
    800016f2:	94da                	add	s1,s1,s6
    if(n > len)
    800016f4:	009a7363          	bgeu	s4,s1,800016fa <copyin+0x34>
    800016f8:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016fa:	413905b3          	sub	a1,s2,s3
    800016fe:	0004861b          	sext.w	a2,s1
    80001702:	95aa                	add	a1,a1,a0
    80001704:	8556                	mv	a0,s5
    80001706:	df8ff0ef          	jal	80000cfe <memmove>
    len -= n;
    8000170a:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000170e:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001710:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001714:	020a0163          	beqz	s4,80001736 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001718:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    8000171c:	85ce                	mv	a1,s3
    8000171e:	855e                	mv	a0,s7
    80001720:	891ff0ef          	jal	80000fb0 <walkaddr>
    if(pa0 == 0) {
    80001724:	f569                	bnez	a0,800016ee <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001726:	4601                	li	a2,0
    80001728:	85ce                	mv	a1,s3
    8000172a:	855e                	mv	a0,s7
    8000172c:	e35ff0ef          	jal	80001560 <vmfault>
    80001730:	fd5d                	bnez	a0,800016ee <copyin+0x28>
        return -1;
    80001732:	557d                	li	a0,-1
    80001734:	a011                	j	80001738 <copyin+0x72>
  return 0;
    80001736:	4501                	li	a0,0
}
    80001738:	60a6                	ld	ra,72(sp)
    8000173a:	6406                	ld	s0,64(sp)
    8000173c:	74e2                	ld	s1,56(sp)
    8000173e:	7942                	ld	s2,48(sp)
    80001740:	79a2                	ld	s3,40(sp)
    80001742:	7a02                	ld	s4,32(sp)
    80001744:	6ae2                	ld	s5,24(sp)
    80001746:	6b42                	ld	s6,16(sp)
    80001748:	6ba2                	ld	s7,8(sp)
    8000174a:	6c02                	ld	s8,0(sp)
    8000174c:	6161                	addi	sp,sp,80
    8000174e:	8082                	ret
  return 0;
    80001750:	4501                	li	a0,0
}
    80001752:	8082                	ret

0000000080001754 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001754:	7139                	addi	sp,sp,-64
    80001756:	fc06                	sd	ra,56(sp)
    80001758:	f822                	sd	s0,48(sp)
    8000175a:	f426                	sd	s1,40(sp)
    8000175c:	f04a                	sd	s2,32(sp)
    8000175e:	ec4e                	sd	s3,24(sp)
    80001760:	e852                	sd	s4,16(sp)
    80001762:	e456                	sd	s5,8(sp)
    80001764:	e05a                	sd	s6,0(sp)
    80001766:	0080                	addi	s0,sp,64
    80001768:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000176a:	00011497          	auipc	s1,0x11
    8000176e:	05e48493          	addi	s1,s1,94 # 800127c8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001772:	8b26                	mv	s6,s1
    80001774:	04fa5937          	lui	s2,0x4fa5
    80001778:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    8000177c:	0932                	slli	s2,s2,0xc
    8000177e:	fa590913          	addi	s2,s2,-91
    80001782:	0932                	slli	s2,s2,0xc
    80001784:	fa590913          	addi	s2,s2,-91
    80001788:	0932                	slli	s2,s2,0xc
    8000178a:	fa590913          	addi	s2,s2,-91
    8000178e:	040009b7          	lui	s3,0x4000
    80001792:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001794:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001796:	00017a97          	auipc	s5,0x17
    8000179a:	a32a8a93          	addi	s5,s5,-1486 # 800181c8 <tickslock>
    char *pa = kalloc();
    8000179e:	b60ff0ef          	jal	80000afe <kalloc>
    800017a2:	862a                	mv	a2,a0
    if(pa == 0)
    800017a4:	cd15                	beqz	a0,800017e0 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017a6:	416485b3          	sub	a1,s1,s6
    800017aa:	858d                	srai	a1,a1,0x3
    800017ac:	032585b3          	mul	a1,a1,s2
    800017b0:	2585                	addiw	a1,a1,1
    800017b2:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017b6:	4719                	li	a4,6
    800017b8:	6685                	lui	a3,0x1
    800017ba:	40b985b3          	sub	a1,s3,a1
    800017be:	8552                	mv	a0,s4
    800017c0:	8dfff0ef          	jal	8000109e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017c4:	16848493          	addi	s1,s1,360
    800017c8:	fd549be3          	bne	s1,s5,8000179e <proc_mapstacks+0x4a>
  }
}
    800017cc:	70e2                	ld	ra,56(sp)
    800017ce:	7442                	ld	s0,48(sp)
    800017d0:	74a2                	ld	s1,40(sp)
    800017d2:	7902                	ld	s2,32(sp)
    800017d4:	69e2                	ld	s3,24(sp)
    800017d6:	6a42                	ld	s4,16(sp)
    800017d8:	6aa2                	ld	s5,8(sp)
    800017da:	6b02                	ld	s6,0(sp)
    800017dc:	6121                	addi	sp,sp,64
    800017de:	8082                	ret
      panic("kalloc");
    800017e0:	00006517          	auipc	a0,0x6
    800017e4:	97850513          	addi	a0,a0,-1672 # 80007158 <etext+0x158>
    800017e8:	ff9fe0ef          	jal	800007e0 <panic>

00000000800017ec <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017ec:	7139                	addi	sp,sp,-64
    800017ee:	fc06                	sd	ra,56(sp)
    800017f0:	f822                	sd	s0,48(sp)
    800017f2:	f426                	sd	s1,40(sp)
    800017f4:	f04a                	sd	s2,32(sp)
    800017f6:	ec4e                	sd	s3,24(sp)
    800017f8:	e852                	sd	s4,16(sp)
    800017fa:	e456                	sd	s5,8(sp)
    800017fc:	e05a                	sd	s6,0(sp)
    800017fe:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001800:	00006597          	auipc	a1,0x6
    80001804:	96058593          	addi	a1,a1,-1696 # 80007160 <etext+0x160>
    80001808:	00011517          	auipc	a0,0x11
    8000180c:	b9050513          	addi	a0,a0,-1136 # 80012398 <pid_lock>
    80001810:	b3eff0ef          	jal	80000b4e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001814:	00006597          	auipc	a1,0x6
    80001818:	95458593          	addi	a1,a1,-1708 # 80007168 <etext+0x168>
    8000181c:	00011517          	auipc	a0,0x11
    80001820:	b9450513          	addi	a0,a0,-1132 # 800123b0 <wait_lock>
    80001824:	b2aff0ef          	jal	80000b4e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001828:	00011497          	auipc	s1,0x11
    8000182c:	fa048493          	addi	s1,s1,-96 # 800127c8 <proc>
      initlock(&p->lock, "proc");
    80001830:	00006b17          	auipc	s6,0x6
    80001834:	948b0b13          	addi	s6,s6,-1720 # 80007178 <etext+0x178>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001838:	8aa6                	mv	s5,s1
    8000183a:	04fa5937          	lui	s2,0x4fa5
    8000183e:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001842:	0932                	slli	s2,s2,0xc
    80001844:	fa590913          	addi	s2,s2,-91
    80001848:	0932                	slli	s2,s2,0xc
    8000184a:	fa590913          	addi	s2,s2,-91
    8000184e:	0932                	slli	s2,s2,0xc
    80001850:	fa590913          	addi	s2,s2,-91
    80001854:	040009b7          	lui	s3,0x4000
    80001858:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000185a:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000185c:	00017a17          	auipc	s4,0x17
    80001860:	96ca0a13          	addi	s4,s4,-1684 # 800181c8 <tickslock>
      initlock(&p->lock, "proc");
    80001864:	85da                	mv	a1,s6
    80001866:	8526                	mv	a0,s1
    80001868:	ae6ff0ef          	jal	80000b4e <initlock>
      p->state = UNUSED;
    8000186c:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001870:	415487b3          	sub	a5,s1,s5
    80001874:	878d                	srai	a5,a5,0x3
    80001876:	032787b3          	mul	a5,a5,s2
    8000187a:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffdba59>
    8000187c:	00d7979b          	slliw	a5,a5,0xd
    80001880:	40f987b3          	sub	a5,s3,a5
    80001884:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001886:	16848493          	addi	s1,s1,360
    8000188a:	fd449de3          	bne	s1,s4,80001864 <procinit+0x78>
  }
}
    8000188e:	70e2                	ld	ra,56(sp)
    80001890:	7442                	ld	s0,48(sp)
    80001892:	74a2                	ld	s1,40(sp)
    80001894:	7902                	ld	s2,32(sp)
    80001896:	69e2                	ld	s3,24(sp)
    80001898:	6a42                	ld	s4,16(sp)
    8000189a:	6aa2                	ld	s5,8(sp)
    8000189c:	6b02                	ld	s6,0(sp)
    8000189e:	6121                	addi	sp,sp,64
    800018a0:	8082                	ret

00000000800018a2 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018a2:	1141                	addi	sp,sp,-16
    800018a4:	e422                	sd	s0,8(sp)
    800018a6:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018a8:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018aa:	2501                	sext.w	a0,a0
    800018ac:	6422                	ld	s0,8(sp)
    800018ae:	0141                	addi	sp,sp,16
    800018b0:	8082                	ret

00000000800018b2 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018b2:	1141                	addi	sp,sp,-16
    800018b4:	e422                	sd	s0,8(sp)
    800018b6:	0800                	addi	s0,sp,16
    800018b8:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018ba:	2781                	sext.w	a5,a5
    800018bc:	079e                	slli	a5,a5,0x7
  return c;
}
    800018be:	00011517          	auipc	a0,0x11
    800018c2:	b0a50513          	addi	a0,a0,-1270 # 800123c8 <cpus>
    800018c6:	953e                	add	a0,a0,a5
    800018c8:	6422                	ld	s0,8(sp)
    800018ca:	0141                	addi	sp,sp,16
    800018cc:	8082                	ret

00000000800018ce <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018ce:	1101                	addi	sp,sp,-32
    800018d0:	ec06                	sd	ra,24(sp)
    800018d2:	e822                	sd	s0,16(sp)
    800018d4:	e426                	sd	s1,8(sp)
    800018d6:	1000                	addi	s0,sp,32
  push_off();
    800018d8:	ab6ff0ef          	jal	80000b8e <push_off>
    800018dc:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018de:	2781                	sext.w	a5,a5
    800018e0:	079e                	slli	a5,a5,0x7
    800018e2:	00011717          	auipc	a4,0x11
    800018e6:	ab670713          	addi	a4,a4,-1354 # 80012398 <pid_lock>
    800018ea:	97ba                	add	a5,a5,a4
    800018ec:	7b84                	ld	s1,48(a5)
  pop_off();
    800018ee:	b24ff0ef          	jal	80000c12 <pop_off>
  return p;
}
    800018f2:	8526                	mv	a0,s1
    800018f4:	60e2                	ld	ra,24(sp)
    800018f6:	6442                	ld	s0,16(sp)
    800018f8:	64a2                	ld	s1,8(sp)
    800018fa:	6105                	addi	sp,sp,32
    800018fc:	8082                	ret

00000000800018fe <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800018fe:	7179                	addi	sp,sp,-48
    80001900:	f406                	sd	ra,40(sp)
    80001902:	f022                	sd	s0,32(sp)
    80001904:	ec26                	sd	s1,24(sp)
    80001906:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001908:	fc7ff0ef          	jal	800018ce <myproc>
    8000190c:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    8000190e:	b58ff0ef          	jal	80000c66 <release>

  if (first) {
    80001912:	00009797          	auipc	a5,0x9
    80001916:	92e7a783          	lw	a5,-1746(a5) # 8000a240 <first.1>
    8000191a:	cf8d                	beqz	a5,80001954 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    8000191c:	4505                	li	a0,1
    8000191e:	4c9010ef          	jal	800035e6 <fsinit>

    first = 0;
    80001922:	00009797          	auipc	a5,0x9
    80001926:	9007af23          	sw	zero,-1762(a5) # 8000a240 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    8000192a:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    8000192e:	00006517          	auipc	a0,0x6
    80001932:	85250513          	addi	a0,a0,-1966 # 80007180 <etext+0x180>
    80001936:	fca43823          	sd	a0,-48(s0)
    8000193a:	fc043c23          	sd	zero,-40(s0)
    8000193e:	fd040593          	addi	a1,s0,-48
    80001942:	5af020ef          	jal	800046f0 <kexec>
    80001946:	6cbc                	ld	a5,88(s1)
    80001948:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    8000194a:	6cbc                	ld	a5,88(s1)
    8000194c:	7bb8                	ld	a4,112(a5)
    8000194e:	57fd                	li	a5,-1
    80001950:	02f70d63          	beq	a4,a5,8000198a <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001954:	2bf000ef          	jal	80002412 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001958:	68a8                	ld	a0,80(s1)
    8000195a:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000195c:	04000737          	lui	a4,0x4000
    80001960:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001962:	0732                	slli	a4,a4,0xc
    80001964:	00004797          	auipc	a5,0x4
    80001968:	73878793          	addi	a5,a5,1848 # 8000609c <userret>
    8000196c:	00004697          	auipc	a3,0x4
    80001970:	69468693          	addi	a3,a3,1684 # 80006000 <_trampoline>
    80001974:	8f95                	sub	a5,a5,a3
    80001976:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001978:	577d                	li	a4,-1
    8000197a:	177e                	slli	a4,a4,0x3f
    8000197c:	8d59                	or	a0,a0,a4
    8000197e:	9782                	jalr	a5
}
    80001980:	70a2                	ld	ra,40(sp)
    80001982:	7402                	ld	s0,32(sp)
    80001984:	64e2                	ld	s1,24(sp)
    80001986:	6145                	addi	sp,sp,48
    80001988:	8082                	ret
      panic("exec");
    8000198a:	00005517          	auipc	a0,0x5
    8000198e:	7fe50513          	addi	a0,a0,2046 # 80007188 <etext+0x188>
    80001992:	e4ffe0ef          	jal	800007e0 <panic>

0000000080001996 <allocpid>:
{
    80001996:	1101                	addi	sp,sp,-32
    80001998:	ec06                	sd	ra,24(sp)
    8000199a:	e822                	sd	s0,16(sp)
    8000199c:	e426                	sd	s1,8(sp)
    8000199e:	e04a                	sd	s2,0(sp)
    800019a0:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800019a2:	00011917          	auipc	s2,0x11
    800019a6:	9f690913          	addi	s2,s2,-1546 # 80012398 <pid_lock>
    800019aa:	854a                	mv	a0,s2
    800019ac:	a22ff0ef          	jal	80000bce <acquire>
  pid = nextpid;
    800019b0:	00009797          	auipc	a5,0x9
    800019b4:	89478793          	addi	a5,a5,-1900 # 8000a244 <nextpid>
    800019b8:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019ba:	0014871b          	addiw	a4,s1,1
    800019be:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019c0:	854a                	mv	a0,s2
    800019c2:	aa4ff0ef          	jal	80000c66 <release>
}
    800019c6:	8526                	mv	a0,s1
    800019c8:	60e2                	ld	ra,24(sp)
    800019ca:	6442                	ld	s0,16(sp)
    800019cc:	64a2                	ld	s1,8(sp)
    800019ce:	6902                	ld	s2,0(sp)
    800019d0:	6105                	addi	sp,sp,32
    800019d2:	8082                	ret

00000000800019d4 <proc_pagetable>:
{
    800019d4:	1101                	addi	sp,sp,-32
    800019d6:	ec06                	sd	ra,24(sp)
    800019d8:	e822                	sd	s0,16(sp)
    800019da:	e426                	sd	s1,8(sp)
    800019dc:	e04a                	sd	s2,0(sp)
    800019de:	1000                	addi	s0,sp,32
    800019e0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800019e2:	fb2ff0ef          	jal	80001194 <uvmcreate>
    800019e6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800019e8:	cd05                	beqz	a0,80001a20 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800019ea:	4729                	li	a4,10
    800019ec:	00004697          	auipc	a3,0x4
    800019f0:	61468693          	addi	a3,a3,1556 # 80006000 <_trampoline>
    800019f4:	6605                	lui	a2,0x1
    800019f6:	040005b7          	lui	a1,0x4000
    800019fa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019fc:	05b2                	slli	a1,a1,0xc
    800019fe:	df0ff0ef          	jal	80000fee <mappages>
    80001a02:	02054663          	bltz	a0,80001a2e <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a06:	4719                	li	a4,6
    80001a08:	05893683          	ld	a3,88(s2)
    80001a0c:	6605                	lui	a2,0x1
    80001a0e:	020005b7          	lui	a1,0x2000
    80001a12:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a14:	05b6                	slli	a1,a1,0xd
    80001a16:	8526                	mv	a0,s1
    80001a18:	dd6ff0ef          	jal	80000fee <mappages>
    80001a1c:	00054f63          	bltz	a0,80001a3a <proc_pagetable+0x66>
}
    80001a20:	8526                	mv	a0,s1
    80001a22:	60e2                	ld	ra,24(sp)
    80001a24:	6442                	ld	s0,16(sp)
    80001a26:	64a2                	ld	s1,8(sp)
    80001a28:	6902                	ld	s2,0(sp)
    80001a2a:	6105                	addi	sp,sp,32
    80001a2c:	8082                	ret
    uvmfree(pagetable, 0);
    80001a2e:	4581                	li	a1,0
    80001a30:	8526                	mv	a0,s1
    80001a32:	95dff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001a36:	4481                	li	s1,0
    80001a38:	b7e5                	j	80001a20 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a3a:	4681                	li	a3,0
    80001a3c:	4605                	li	a2,1
    80001a3e:	040005b7          	lui	a1,0x4000
    80001a42:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a44:	05b2                	slli	a1,a1,0xc
    80001a46:	8526                	mv	a0,s1
    80001a48:	f72ff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001a4c:	4581                	li	a1,0
    80001a4e:	8526                	mv	a0,s1
    80001a50:	93fff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001a54:	4481                	li	s1,0
    80001a56:	b7e9                	j	80001a20 <proc_pagetable+0x4c>

0000000080001a58 <proc_freepagetable>:
{
    80001a58:	1101                	addi	sp,sp,-32
    80001a5a:	ec06                	sd	ra,24(sp)
    80001a5c:	e822                	sd	s0,16(sp)
    80001a5e:	e426                	sd	s1,8(sp)
    80001a60:	e04a                	sd	s2,0(sp)
    80001a62:	1000                	addi	s0,sp,32
    80001a64:	84aa                	mv	s1,a0
    80001a66:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a68:	4681                	li	a3,0
    80001a6a:	4605                	li	a2,1
    80001a6c:	040005b7          	lui	a1,0x4000
    80001a70:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a72:	05b2                	slli	a1,a1,0xc
    80001a74:	f46ff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a78:	4681                	li	a3,0
    80001a7a:	4605                	li	a2,1
    80001a7c:	020005b7          	lui	a1,0x2000
    80001a80:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a82:	05b6                	slli	a1,a1,0xd
    80001a84:	8526                	mv	a0,s1
    80001a86:	f34ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001a8a:	85ca                	mv	a1,s2
    80001a8c:	8526                	mv	a0,s1
    80001a8e:	901ff0ef          	jal	8000138e <uvmfree>
}
    80001a92:	60e2                	ld	ra,24(sp)
    80001a94:	6442                	ld	s0,16(sp)
    80001a96:	64a2                	ld	s1,8(sp)
    80001a98:	6902                	ld	s2,0(sp)
    80001a9a:	6105                	addi	sp,sp,32
    80001a9c:	8082                	ret

0000000080001a9e <freeproc>:
{
    80001a9e:	1101                	addi	sp,sp,-32
    80001aa0:	ec06                	sd	ra,24(sp)
    80001aa2:	e822                	sd	s0,16(sp)
    80001aa4:	e426                	sd	s1,8(sp)
    80001aa6:	1000                	addi	s0,sp,32
    80001aa8:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001aaa:	6d28                	ld	a0,88(a0)
    80001aac:	c119                	beqz	a0,80001ab2 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001aae:	f6ffe0ef          	jal	80000a1c <kfree>
  p->trapframe = 0;
    80001ab2:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001ab6:	68a8                	ld	a0,80(s1)
    80001ab8:	c501                	beqz	a0,80001ac0 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001aba:	64ac                	ld	a1,72(s1)
    80001abc:	f9dff0ef          	jal	80001a58 <proc_freepagetable>
  p->pagetable = 0;
    80001ac0:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ac4:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ac8:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001acc:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ad0:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ad4:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ad8:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001adc:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ae0:	0004ac23          	sw	zero,24(s1)
}
    80001ae4:	60e2                	ld	ra,24(sp)
    80001ae6:	6442                	ld	s0,16(sp)
    80001ae8:	64a2                	ld	s1,8(sp)
    80001aea:	6105                	addi	sp,sp,32
    80001aec:	8082                	ret

0000000080001aee <allocproc>:
{
    80001aee:	1101                	addi	sp,sp,-32
    80001af0:	ec06                	sd	ra,24(sp)
    80001af2:	e822                	sd	s0,16(sp)
    80001af4:	e426                	sd	s1,8(sp)
    80001af6:	e04a                	sd	s2,0(sp)
    80001af8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001afa:	00011497          	auipc	s1,0x11
    80001afe:	cce48493          	addi	s1,s1,-818 # 800127c8 <proc>
    80001b02:	00016917          	auipc	s2,0x16
    80001b06:	6c690913          	addi	s2,s2,1734 # 800181c8 <tickslock>
    acquire(&p->lock);
    80001b0a:	8526                	mv	a0,s1
    80001b0c:	8c2ff0ef          	jal	80000bce <acquire>
    if(p->state == UNUSED) {
    80001b10:	4c9c                	lw	a5,24(s1)
    80001b12:	cb91                	beqz	a5,80001b26 <allocproc+0x38>
      release(&p->lock);
    80001b14:	8526                	mv	a0,s1
    80001b16:	950ff0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b1a:	16848493          	addi	s1,s1,360
    80001b1e:	ff2496e3          	bne	s1,s2,80001b0a <allocproc+0x1c>
  return 0;
    80001b22:	4481                	li	s1,0
    80001b24:	a089                	j	80001b66 <allocproc+0x78>
  p->pid = allocpid();
    80001b26:	e71ff0ef          	jal	80001996 <allocpid>
    80001b2a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b2c:	4785                	li	a5,1
    80001b2e:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b30:	fcffe0ef          	jal	80000afe <kalloc>
    80001b34:	892a                	mv	s2,a0
    80001b36:	eca8                	sd	a0,88(s1)
    80001b38:	cd15                	beqz	a0,80001b74 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b3a:	8526                	mv	a0,s1
    80001b3c:	e99ff0ef          	jal	800019d4 <proc_pagetable>
    80001b40:	892a                	mv	s2,a0
    80001b42:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001b44:	c121                	beqz	a0,80001b84 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b46:	07000613          	li	a2,112
    80001b4a:	4581                	li	a1,0
    80001b4c:	06048513          	addi	a0,s1,96
    80001b50:	952ff0ef          	jal	80000ca2 <memset>
  p->context.ra = (uint64)forkret;
    80001b54:	00000797          	auipc	a5,0x0
    80001b58:	daa78793          	addi	a5,a5,-598 # 800018fe <forkret>
    80001b5c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b5e:	60bc                	ld	a5,64(s1)
    80001b60:	6705                	lui	a4,0x1
    80001b62:	97ba                	add	a5,a5,a4
    80001b64:	f4bc                	sd	a5,104(s1)
}
    80001b66:	8526                	mv	a0,s1
    80001b68:	60e2                	ld	ra,24(sp)
    80001b6a:	6442                	ld	s0,16(sp)
    80001b6c:	64a2                	ld	s1,8(sp)
    80001b6e:	6902                	ld	s2,0(sp)
    80001b70:	6105                	addi	sp,sp,32
    80001b72:	8082                	ret
    freeproc(p);
    80001b74:	8526                	mv	a0,s1
    80001b76:	f29ff0ef          	jal	80001a9e <freeproc>
    release(&p->lock);
    80001b7a:	8526                	mv	a0,s1
    80001b7c:	8eaff0ef          	jal	80000c66 <release>
    return 0;
    80001b80:	84ca                	mv	s1,s2
    80001b82:	b7d5                	j	80001b66 <allocproc+0x78>
    freeproc(p);
    80001b84:	8526                	mv	a0,s1
    80001b86:	f19ff0ef          	jal	80001a9e <freeproc>
    release(&p->lock);
    80001b8a:	8526                	mv	a0,s1
    80001b8c:	8daff0ef          	jal	80000c66 <release>
    return 0;
    80001b90:	84ca                	mv	s1,s2
    80001b92:	bfd1                	j	80001b66 <allocproc+0x78>

0000000080001b94 <userinit>:
{
    80001b94:	1101                	addi	sp,sp,-32
    80001b96:	ec06                	sd	ra,24(sp)
    80001b98:	e822                	sd	s0,16(sp)
    80001b9a:	e426                	sd	s1,8(sp)
    80001b9c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b9e:	f51ff0ef          	jal	80001aee <allocproc>
    80001ba2:	84aa                	mv	s1,a0
  initproc = p;
    80001ba4:	00008797          	auipc	a5,0x8
    80001ba8:	6ea7b623          	sd	a0,1772(a5) # 8000a290 <initproc>
  p->cwd = namei("/");
    80001bac:	00005517          	auipc	a0,0x5
    80001bb0:	5e450513          	addi	a0,a0,1508 # 80007190 <etext+0x190>
    80001bb4:	755010ef          	jal	80003b08 <namei>
    80001bb8:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bbc:	478d                	li	a5,3
    80001bbe:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	8a4ff0ef          	jal	80000c66 <release>
}
    80001bc6:	60e2                	ld	ra,24(sp)
    80001bc8:	6442                	ld	s0,16(sp)
    80001bca:	64a2                	ld	s1,8(sp)
    80001bcc:	6105                	addi	sp,sp,32
    80001bce:	8082                	ret

0000000080001bd0 <growproc>:
{
    80001bd0:	1101                	addi	sp,sp,-32
    80001bd2:	ec06                	sd	ra,24(sp)
    80001bd4:	e822                	sd	s0,16(sp)
    80001bd6:	e426                	sd	s1,8(sp)
    80001bd8:	e04a                	sd	s2,0(sp)
    80001bda:	1000                	addi	s0,sp,32
    80001bdc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001bde:	cf1ff0ef          	jal	800018ce <myproc>
    80001be2:	892a                	mv	s2,a0
  sz = p->sz;
    80001be4:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001be6:	02905963          	blez	s1,80001c18 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001bea:	00b48633          	add	a2,s1,a1
    80001bee:	020007b7          	lui	a5,0x2000
    80001bf2:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001bf4:	07b6                	slli	a5,a5,0xd
    80001bf6:	02c7ea63          	bltu	a5,a2,80001c2a <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001bfa:	4691                	li	a3,4
    80001bfc:	6928                	ld	a0,80(a0)
    80001bfe:	e8aff0ef          	jal	80001288 <uvmalloc>
    80001c02:	85aa                	mv	a1,a0
    80001c04:	c50d                	beqz	a0,80001c2e <growproc+0x5e>
  p->sz = sz;
    80001c06:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c0a:	4501                	li	a0,0
}
    80001c0c:	60e2                	ld	ra,24(sp)
    80001c0e:	6442                	ld	s0,16(sp)
    80001c10:	64a2                	ld	s1,8(sp)
    80001c12:	6902                	ld	s2,0(sp)
    80001c14:	6105                	addi	sp,sp,32
    80001c16:	8082                	ret
  } else if(n < 0){
    80001c18:	fe04d7e3          	bgez	s1,80001c06 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c1c:	00b48633          	add	a2,s1,a1
    80001c20:	6928                	ld	a0,80(a0)
    80001c22:	e22ff0ef          	jal	80001244 <uvmdealloc>
    80001c26:	85aa                	mv	a1,a0
    80001c28:	bff9                	j	80001c06 <growproc+0x36>
      return -1;
    80001c2a:	557d                	li	a0,-1
    80001c2c:	b7c5                	j	80001c0c <growproc+0x3c>
      return -1;
    80001c2e:	557d                	li	a0,-1
    80001c30:	bff1                	j	80001c0c <growproc+0x3c>

0000000080001c32 <kfork>:
{
    80001c32:	7139                	addi	sp,sp,-64
    80001c34:	fc06                	sd	ra,56(sp)
    80001c36:	f822                	sd	s0,48(sp)
    80001c38:	f04a                	sd	s2,32(sp)
    80001c3a:	e456                	sd	s5,8(sp)
    80001c3c:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c3e:	c91ff0ef          	jal	800018ce <myproc>
    80001c42:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c44:	eabff0ef          	jal	80001aee <allocproc>
    80001c48:	0e050a63          	beqz	a0,80001d3c <kfork+0x10a>
    80001c4c:	e852                	sd	s4,16(sp)
    80001c4e:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c50:	048ab603          	ld	a2,72(s5)
    80001c54:	692c                	ld	a1,80(a0)
    80001c56:	050ab503          	ld	a0,80(s5)
    80001c5a:	f66ff0ef          	jal	800013c0 <uvmcopy>
    80001c5e:	04054a63          	bltz	a0,80001cb2 <kfork+0x80>
    80001c62:	f426                	sd	s1,40(sp)
    80001c64:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c66:	048ab783          	ld	a5,72(s5)
    80001c6a:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c6e:	058ab683          	ld	a3,88(s5)
    80001c72:	87b6                	mv	a5,a3
    80001c74:	058a3703          	ld	a4,88(s4)
    80001c78:	12068693          	addi	a3,a3,288
    80001c7c:	0007b803          	ld	a6,0(a5)
    80001c80:	6788                	ld	a0,8(a5)
    80001c82:	6b8c                	ld	a1,16(a5)
    80001c84:	6f90                	ld	a2,24(a5)
    80001c86:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001c8a:	e708                	sd	a0,8(a4)
    80001c8c:	eb0c                	sd	a1,16(a4)
    80001c8e:	ef10                	sd	a2,24(a4)
    80001c90:	02078793          	addi	a5,a5,32
    80001c94:	02070713          	addi	a4,a4,32
    80001c98:	fed792e3          	bne	a5,a3,80001c7c <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001c9c:	058a3783          	ld	a5,88(s4)
    80001ca0:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001ca4:	0d0a8493          	addi	s1,s5,208
    80001ca8:	0d0a0913          	addi	s2,s4,208
    80001cac:	150a8993          	addi	s3,s5,336
    80001cb0:	a831                	j	80001ccc <kfork+0x9a>
    freeproc(np);
    80001cb2:	8552                	mv	a0,s4
    80001cb4:	debff0ef          	jal	80001a9e <freeproc>
    release(&np->lock);
    80001cb8:	8552                	mv	a0,s4
    80001cba:	fadfe0ef          	jal	80000c66 <release>
    return -1;
    80001cbe:	597d                	li	s2,-1
    80001cc0:	6a42                	ld	s4,16(sp)
    80001cc2:	a0b5                	j	80001d2e <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001cc4:	04a1                	addi	s1,s1,8
    80001cc6:	0921                	addi	s2,s2,8
    80001cc8:	01348963          	beq	s1,s3,80001cda <kfork+0xa8>
    if(p->ofile[i])
    80001ccc:	6088                	ld	a0,0(s1)
    80001cce:	d97d                	beqz	a0,80001cc4 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cd0:	3d2020ef          	jal	800040a2 <filedup>
    80001cd4:	00a93023          	sd	a0,0(s2)
    80001cd8:	b7f5                	j	80001cc4 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001cda:	150ab503          	ld	a0,336(s5)
    80001cde:	5de010ef          	jal	800032bc <idup>
    80001ce2:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ce6:	4641                	li	a2,16
    80001ce8:	158a8593          	addi	a1,s5,344
    80001cec:	158a0513          	addi	a0,s4,344
    80001cf0:	8f0ff0ef          	jal	80000de0 <safestrcpy>
  pid = np->pid;
    80001cf4:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001cf8:	8552                	mv	a0,s4
    80001cfa:	f6dfe0ef          	jal	80000c66 <release>
  acquire(&wait_lock);
    80001cfe:	00010497          	auipc	s1,0x10
    80001d02:	6b248493          	addi	s1,s1,1714 # 800123b0 <wait_lock>
    80001d06:	8526                	mv	a0,s1
    80001d08:	ec7fe0ef          	jal	80000bce <acquire>
  np->parent = p;
    80001d0c:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d10:	8526                	mv	a0,s1
    80001d12:	f55fe0ef          	jal	80000c66 <release>
  acquire(&np->lock);
    80001d16:	8552                	mv	a0,s4
    80001d18:	eb7fe0ef          	jal	80000bce <acquire>
  np->state = RUNNABLE;
    80001d1c:	478d                	li	a5,3
    80001d1e:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d22:	8552                	mv	a0,s4
    80001d24:	f43fe0ef          	jal	80000c66 <release>
  return pid;
    80001d28:	74a2                	ld	s1,40(sp)
    80001d2a:	69e2                	ld	s3,24(sp)
    80001d2c:	6a42                	ld	s4,16(sp)
}
    80001d2e:	854a                	mv	a0,s2
    80001d30:	70e2                	ld	ra,56(sp)
    80001d32:	7442                	ld	s0,48(sp)
    80001d34:	7902                	ld	s2,32(sp)
    80001d36:	6aa2                	ld	s5,8(sp)
    80001d38:	6121                	addi	sp,sp,64
    80001d3a:	8082                	ret
    return -1;
    80001d3c:	597d                	li	s2,-1
    80001d3e:	bfc5                	j	80001d2e <kfork+0xfc>

0000000080001d40 <scheduler>:
{
    80001d40:	715d                	addi	sp,sp,-80
    80001d42:	e486                	sd	ra,72(sp)
    80001d44:	e0a2                	sd	s0,64(sp)
    80001d46:	fc26                	sd	s1,56(sp)
    80001d48:	f84a                	sd	s2,48(sp)
    80001d4a:	f44e                	sd	s3,40(sp)
    80001d4c:	f052                	sd	s4,32(sp)
    80001d4e:	ec56                	sd	s5,24(sp)
    80001d50:	e85a                	sd	s6,16(sp)
    80001d52:	e45e                	sd	s7,8(sp)
    80001d54:	e062                	sd	s8,0(sp)
    80001d56:	0880                	addi	s0,sp,80
    80001d58:	8792                	mv	a5,tp
  int id = r_tp();
    80001d5a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d5c:	00779b13          	slli	s6,a5,0x7
    80001d60:	00010717          	auipc	a4,0x10
    80001d64:	63870713          	addi	a4,a4,1592 # 80012398 <pid_lock>
    80001d68:	975a                	add	a4,a4,s6
    80001d6a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d6e:	00010717          	auipc	a4,0x10
    80001d72:	66270713          	addi	a4,a4,1634 # 800123d0 <cpus+0x8>
    80001d76:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d78:	4c11                	li	s8,4
        c->proc = p;
    80001d7a:	079e                	slli	a5,a5,0x7
    80001d7c:	00010a17          	auipc	s4,0x10
    80001d80:	61ca0a13          	addi	s4,s4,1564 # 80012398 <pid_lock>
    80001d84:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d86:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d88:	00016997          	auipc	s3,0x16
    80001d8c:	44098993          	addi	s3,s3,1088 # 800181c8 <tickslock>
    80001d90:	a83d                	j	80001dce <scheduler+0x8e>
      release(&p->lock);
    80001d92:	8526                	mv	a0,s1
    80001d94:	ed3fe0ef          	jal	80000c66 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d98:	16848493          	addi	s1,s1,360
    80001d9c:	03348563          	beq	s1,s3,80001dc6 <scheduler+0x86>
      acquire(&p->lock);
    80001da0:	8526                	mv	a0,s1
    80001da2:	e2dfe0ef          	jal	80000bce <acquire>
      if(p->state == RUNNABLE) {
    80001da6:	4c9c                	lw	a5,24(s1)
    80001da8:	ff2795e3          	bne	a5,s2,80001d92 <scheduler+0x52>
        p->state = RUNNING;
    80001dac:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001db0:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001db4:	06048593          	addi	a1,s1,96
    80001db8:	855a                	mv	a0,s6
    80001dba:	5b2000ef          	jal	8000236c <swtch>
        c->proc = 0;
    80001dbe:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001dc2:	8ade                	mv	s5,s7
    80001dc4:	b7f9                	j	80001d92 <scheduler+0x52>
    if(found == 0) {
    80001dc6:	000a9463          	bnez	s5,80001dce <scheduler+0x8e>
      asm volatile("wfi");
    80001dca:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dce:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dd2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dd6:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dda:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001dde:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001de0:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001de4:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001de6:	00011497          	auipc	s1,0x11
    80001dea:	9e248493          	addi	s1,s1,-1566 # 800127c8 <proc>
      if(p->state == RUNNABLE) {
    80001dee:	490d                	li	s2,3
    80001df0:	bf45                	j	80001da0 <scheduler+0x60>

0000000080001df2 <sched>:
{
    80001df2:	7179                	addi	sp,sp,-48
    80001df4:	f406                	sd	ra,40(sp)
    80001df6:	f022                	sd	s0,32(sp)
    80001df8:	ec26                	sd	s1,24(sp)
    80001dfa:	e84a                	sd	s2,16(sp)
    80001dfc:	e44e                	sd	s3,8(sp)
    80001dfe:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e00:	acfff0ef          	jal	800018ce <myproc>
    80001e04:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e06:	d5ffe0ef          	jal	80000b64 <holding>
    80001e0a:	c92d                	beqz	a0,80001e7c <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e0c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e0e:	2781                	sext.w	a5,a5
    80001e10:	079e                	slli	a5,a5,0x7
    80001e12:	00010717          	auipc	a4,0x10
    80001e16:	58670713          	addi	a4,a4,1414 # 80012398 <pid_lock>
    80001e1a:	97ba                	add	a5,a5,a4
    80001e1c:	0a87a703          	lw	a4,168(a5)
    80001e20:	4785                	li	a5,1
    80001e22:	06f71363          	bne	a4,a5,80001e88 <sched+0x96>
  if(p->state == RUNNING)
    80001e26:	4c98                	lw	a4,24(s1)
    80001e28:	4791                	li	a5,4
    80001e2a:	06f70563          	beq	a4,a5,80001e94 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e2e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e32:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e34:	e7b5                	bnez	a5,80001ea0 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e36:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e38:	00010917          	auipc	s2,0x10
    80001e3c:	56090913          	addi	s2,s2,1376 # 80012398 <pid_lock>
    80001e40:	2781                	sext.w	a5,a5
    80001e42:	079e                	slli	a5,a5,0x7
    80001e44:	97ca                	add	a5,a5,s2
    80001e46:	0ac7a983          	lw	s3,172(a5)
    80001e4a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e4c:	2781                	sext.w	a5,a5
    80001e4e:	079e                	slli	a5,a5,0x7
    80001e50:	00010597          	auipc	a1,0x10
    80001e54:	58058593          	addi	a1,a1,1408 # 800123d0 <cpus+0x8>
    80001e58:	95be                	add	a1,a1,a5
    80001e5a:	06048513          	addi	a0,s1,96
    80001e5e:	50e000ef          	jal	8000236c <swtch>
    80001e62:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e64:	2781                	sext.w	a5,a5
    80001e66:	079e                	slli	a5,a5,0x7
    80001e68:	993e                	add	s2,s2,a5
    80001e6a:	0b392623          	sw	s3,172(s2)
}
    80001e6e:	70a2                	ld	ra,40(sp)
    80001e70:	7402                	ld	s0,32(sp)
    80001e72:	64e2                	ld	s1,24(sp)
    80001e74:	6942                	ld	s2,16(sp)
    80001e76:	69a2                	ld	s3,8(sp)
    80001e78:	6145                	addi	sp,sp,48
    80001e7a:	8082                	ret
    panic("sched p->lock");
    80001e7c:	00005517          	auipc	a0,0x5
    80001e80:	31c50513          	addi	a0,a0,796 # 80007198 <etext+0x198>
    80001e84:	95dfe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    80001e88:	00005517          	auipc	a0,0x5
    80001e8c:	32050513          	addi	a0,a0,800 # 800071a8 <etext+0x1a8>
    80001e90:	951fe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    80001e94:	00005517          	auipc	a0,0x5
    80001e98:	32450513          	addi	a0,a0,804 # 800071b8 <etext+0x1b8>
    80001e9c:	945fe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    80001ea0:	00005517          	auipc	a0,0x5
    80001ea4:	32850513          	addi	a0,a0,808 # 800071c8 <etext+0x1c8>
    80001ea8:	939fe0ef          	jal	800007e0 <panic>

0000000080001eac <yield>:
{
    80001eac:	1101                	addi	sp,sp,-32
    80001eae:	ec06                	sd	ra,24(sp)
    80001eb0:	e822                	sd	s0,16(sp)
    80001eb2:	e426                	sd	s1,8(sp)
    80001eb4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001eb6:	a19ff0ef          	jal	800018ce <myproc>
    80001eba:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001ebc:	d13fe0ef          	jal	80000bce <acquire>
  p->state = RUNNABLE;
    80001ec0:	478d                	li	a5,3
    80001ec2:	cc9c                	sw	a5,24(s1)
  sched();
    80001ec4:	f2fff0ef          	jal	80001df2 <sched>
  release(&p->lock);
    80001ec8:	8526                	mv	a0,s1
    80001eca:	d9dfe0ef          	jal	80000c66 <release>
}
    80001ece:	60e2                	ld	ra,24(sp)
    80001ed0:	6442                	ld	s0,16(sp)
    80001ed2:	64a2                	ld	s1,8(sp)
    80001ed4:	6105                	addi	sp,sp,32
    80001ed6:	8082                	ret

0000000080001ed8 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001ed8:	7179                	addi	sp,sp,-48
    80001eda:	f406                	sd	ra,40(sp)
    80001edc:	f022                	sd	s0,32(sp)
    80001ede:	ec26                	sd	s1,24(sp)
    80001ee0:	e84a                	sd	s2,16(sp)
    80001ee2:	e44e                	sd	s3,8(sp)
    80001ee4:	1800                	addi	s0,sp,48
    80001ee6:	89aa                	mv	s3,a0
    80001ee8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001eea:	9e5ff0ef          	jal	800018ce <myproc>
    80001eee:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001ef0:	cdffe0ef          	jal	80000bce <acquire>
  release(lk);
    80001ef4:	854a                	mv	a0,s2
    80001ef6:	d71fe0ef          	jal	80000c66 <release>

  // Go to sleep.
  p->chan = chan;
    80001efa:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001efe:	4789                	li	a5,2
    80001f00:	cc9c                	sw	a5,24(s1)

  sched();
    80001f02:	ef1ff0ef          	jal	80001df2 <sched>

  // Tidy up.
  p->chan = 0;
    80001f06:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f0a:	8526                	mv	a0,s1
    80001f0c:	d5bfe0ef          	jal	80000c66 <release>
  acquire(lk);
    80001f10:	854a                	mv	a0,s2
    80001f12:	cbdfe0ef          	jal	80000bce <acquire>
}
    80001f16:	70a2                	ld	ra,40(sp)
    80001f18:	7402                	ld	s0,32(sp)
    80001f1a:	64e2                	ld	s1,24(sp)
    80001f1c:	6942                	ld	s2,16(sp)
    80001f1e:	69a2                	ld	s3,8(sp)
    80001f20:	6145                	addi	sp,sp,48
    80001f22:	8082                	ret

0000000080001f24 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001f24:	7139                	addi	sp,sp,-64
    80001f26:	fc06                	sd	ra,56(sp)
    80001f28:	f822                	sd	s0,48(sp)
    80001f2a:	f426                	sd	s1,40(sp)
    80001f2c:	f04a                	sd	s2,32(sp)
    80001f2e:	ec4e                	sd	s3,24(sp)
    80001f30:	e852                	sd	s4,16(sp)
    80001f32:	e456                	sd	s5,8(sp)
    80001f34:	0080                	addi	s0,sp,64
    80001f36:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f38:	00011497          	auipc	s1,0x11
    80001f3c:	89048493          	addi	s1,s1,-1904 # 800127c8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f40:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f42:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f44:	00016917          	auipc	s2,0x16
    80001f48:	28490913          	addi	s2,s2,644 # 800181c8 <tickslock>
    80001f4c:	a801                	j	80001f5c <wakeup+0x38>
      }
      release(&p->lock);
    80001f4e:	8526                	mv	a0,s1
    80001f50:	d17fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f54:	16848493          	addi	s1,s1,360
    80001f58:	03248263          	beq	s1,s2,80001f7c <wakeup+0x58>
    if(p != myproc()){
    80001f5c:	973ff0ef          	jal	800018ce <myproc>
    80001f60:	fea48ae3          	beq	s1,a0,80001f54 <wakeup+0x30>
      acquire(&p->lock);
    80001f64:	8526                	mv	a0,s1
    80001f66:	c69fe0ef          	jal	80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f6a:	4c9c                	lw	a5,24(s1)
    80001f6c:	ff3791e3          	bne	a5,s3,80001f4e <wakeup+0x2a>
    80001f70:	709c                	ld	a5,32(s1)
    80001f72:	fd479ee3          	bne	a5,s4,80001f4e <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f76:	0154ac23          	sw	s5,24(s1)
    80001f7a:	bfd1                	j	80001f4e <wakeup+0x2a>
    }
  }
}
    80001f7c:	70e2                	ld	ra,56(sp)
    80001f7e:	7442                	ld	s0,48(sp)
    80001f80:	74a2                	ld	s1,40(sp)
    80001f82:	7902                	ld	s2,32(sp)
    80001f84:	69e2                	ld	s3,24(sp)
    80001f86:	6a42                	ld	s4,16(sp)
    80001f88:	6aa2                	ld	s5,8(sp)
    80001f8a:	6121                	addi	sp,sp,64
    80001f8c:	8082                	ret

0000000080001f8e <reparent>:
{
    80001f8e:	7179                	addi	sp,sp,-48
    80001f90:	f406                	sd	ra,40(sp)
    80001f92:	f022                	sd	s0,32(sp)
    80001f94:	ec26                	sd	s1,24(sp)
    80001f96:	e84a                	sd	s2,16(sp)
    80001f98:	e44e                	sd	s3,8(sp)
    80001f9a:	e052                	sd	s4,0(sp)
    80001f9c:	1800                	addi	s0,sp,48
    80001f9e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fa0:	00011497          	auipc	s1,0x11
    80001fa4:	82848493          	addi	s1,s1,-2008 # 800127c8 <proc>
      pp->parent = initproc;
    80001fa8:	00008a17          	auipc	s4,0x8
    80001fac:	2e8a0a13          	addi	s4,s4,744 # 8000a290 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fb0:	00016997          	auipc	s3,0x16
    80001fb4:	21898993          	addi	s3,s3,536 # 800181c8 <tickslock>
    80001fb8:	a029                	j	80001fc2 <reparent+0x34>
    80001fba:	16848493          	addi	s1,s1,360
    80001fbe:	01348b63          	beq	s1,s3,80001fd4 <reparent+0x46>
    if(pp->parent == p){
    80001fc2:	7c9c                	ld	a5,56(s1)
    80001fc4:	ff279be3          	bne	a5,s2,80001fba <reparent+0x2c>
      pp->parent = initproc;
    80001fc8:	000a3503          	ld	a0,0(s4)
    80001fcc:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fce:	f57ff0ef          	jal	80001f24 <wakeup>
    80001fd2:	b7e5                	j	80001fba <reparent+0x2c>
}
    80001fd4:	70a2                	ld	ra,40(sp)
    80001fd6:	7402                	ld	s0,32(sp)
    80001fd8:	64e2                	ld	s1,24(sp)
    80001fda:	6942                	ld	s2,16(sp)
    80001fdc:	69a2                	ld	s3,8(sp)
    80001fde:	6a02                	ld	s4,0(sp)
    80001fe0:	6145                	addi	sp,sp,48
    80001fe2:	8082                	ret

0000000080001fe4 <kexit>:
{
    80001fe4:	7179                	addi	sp,sp,-48
    80001fe6:	f406                	sd	ra,40(sp)
    80001fe8:	f022                	sd	s0,32(sp)
    80001fea:	ec26                	sd	s1,24(sp)
    80001fec:	e84a                	sd	s2,16(sp)
    80001fee:	e44e                	sd	s3,8(sp)
    80001ff0:	e052                	sd	s4,0(sp)
    80001ff2:	1800                	addi	s0,sp,48
    80001ff4:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001ff6:	8d9ff0ef          	jal	800018ce <myproc>
    80001ffa:	89aa                	mv	s3,a0
  if(p == initproc)
    80001ffc:	00008797          	auipc	a5,0x8
    80002000:	2947b783          	ld	a5,660(a5) # 8000a290 <initproc>
    80002004:	0d050493          	addi	s1,a0,208
    80002008:	15050913          	addi	s2,a0,336
    8000200c:	00a79f63          	bne	a5,a0,8000202a <kexit+0x46>
    panic("init exiting");
    80002010:	00005517          	auipc	a0,0x5
    80002014:	1d050513          	addi	a0,a0,464 # 800071e0 <etext+0x1e0>
    80002018:	fc8fe0ef          	jal	800007e0 <panic>
      fileclose(f);
    8000201c:	0cc020ef          	jal	800040e8 <fileclose>
      p->ofile[fd] = 0;
    80002020:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002024:	04a1                	addi	s1,s1,8
    80002026:	01248563          	beq	s1,s2,80002030 <kexit+0x4c>
    if(p->ofile[fd]){
    8000202a:	6088                	ld	a0,0(s1)
    8000202c:	f965                	bnez	a0,8000201c <kexit+0x38>
    8000202e:	bfdd                	j	80002024 <kexit+0x40>
  begin_op();
    80002030:	4ad010ef          	jal	80003cdc <begin_op>
  iput(p->cwd);
    80002034:	1509b503          	ld	a0,336(s3)
    80002038:	43c010ef          	jal	80003474 <iput>
  end_op();
    8000203c:	50b010ef          	jal	80003d46 <end_op>
  p->cwd = 0;
    80002040:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002044:	00010497          	auipc	s1,0x10
    80002048:	36c48493          	addi	s1,s1,876 # 800123b0 <wait_lock>
    8000204c:	8526                	mv	a0,s1
    8000204e:	b81fe0ef          	jal	80000bce <acquire>
  reparent(p);
    80002052:	854e                	mv	a0,s3
    80002054:	f3bff0ef          	jal	80001f8e <reparent>
  wakeup(p->parent);
    80002058:	0389b503          	ld	a0,56(s3)
    8000205c:	ec9ff0ef          	jal	80001f24 <wakeup>
  acquire(&p->lock);
    80002060:	854e                	mv	a0,s3
    80002062:	b6dfe0ef          	jal	80000bce <acquire>
  p->xstate = status;
    80002066:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000206a:	4795                	li	a5,5
    8000206c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002070:	8526                	mv	a0,s1
    80002072:	bf5fe0ef          	jal	80000c66 <release>
  sched();
    80002076:	d7dff0ef          	jal	80001df2 <sched>
  panic("zombie exit");
    8000207a:	00005517          	auipc	a0,0x5
    8000207e:	17650513          	addi	a0,a0,374 # 800071f0 <etext+0x1f0>
    80002082:	f5efe0ef          	jal	800007e0 <panic>

0000000080002086 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002086:	7179                	addi	sp,sp,-48
    80002088:	f406                	sd	ra,40(sp)
    8000208a:	f022                	sd	s0,32(sp)
    8000208c:	ec26                	sd	s1,24(sp)
    8000208e:	e84a                	sd	s2,16(sp)
    80002090:	e44e                	sd	s3,8(sp)
    80002092:	1800                	addi	s0,sp,48
    80002094:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002096:	00010497          	auipc	s1,0x10
    8000209a:	73248493          	addi	s1,s1,1842 # 800127c8 <proc>
    8000209e:	00016997          	auipc	s3,0x16
    800020a2:	12a98993          	addi	s3,s3,298 # 800181c8 <tickslock>
    acquire(&p->lock);
    800020a6:	8526                	mv	a0,s1
    800020a8:	b27fe0ef          	jal	80000bce <acquire>
    if(p->pid == pid){
    800020ac:	589c                	lw	a5,48(s1)
    800020ae:	01278b63          	beq	a5,s2,800020c4 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020b2:	8526                	mv	a0,s1
    800020b4:	bb3fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020b8:	16848493          	addi	s1,s1,360
    800020bc:	ff3495e3          	bne	s1,s3,800020a6 <kkill+0x20>
  }
  return -1;
    800020c0:	557d                	li	a0,-1
    800020c2:	a819                	j	800020d8 <kkill+0x52>
      p->killed = 1;
    800020c4:	4785                	li	a5,1
    800020c6:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020c8:	4c98                	lw	a4,24(s1)
    800020ca:	4789                	li	a5,2
    800020cc:	00f70d63          	beq	a4,a5,800020e6 <kkill+0x60>
      release(&p->lock);
    800020d0:	8526                	mv	a0,s1
    800020d2:	b95fe0ef          	jal	80000c66 <release>
      return 0;
    800020d6:	4501                	li	a0,0
}
    800020d8:	70a2                	ld	ra,40(sp)
    800020da:	7402                	ld	s0,32(sp)
    800020dc:	64e2                	ld	s1,24(sp)
    800020de:	6942                	ld	s2,16(sp)
    800020e0:	69a2                	ld	s3,8(sp)
    800020e2:	6145                	addi	sp,sp,48
    800020e4:	8082                	ret
        p->state = RUNNABLE;
    800020e6:	478d                	li	a5,3
    800020e8:	cc9c                	sw	a5,24(s1)
    800020ea:	b7dd                	j	800020d0 <kkill+0x4a>

00000000800020ec <setkilled>:

void
setkilled(struct proc *p)
{
    800020ec:	1101                	addi	sp,sp,-32
    800020ee:	ec06                	sd	ra,24(sp)
    800020f0:	e822                	sd	s0,16(sp)
    800020f2:	e426                	sd	s1,8(sp)
    800020f4:	1000                	addi	s0,sp,32
    800020f6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020f8:	ad7fe0ef          	jal	80000bce <acquire>
  p->killed = 1;
    800020fc:	4785                	li	a5,1
    800020fe:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002100:	8526                	mv	a0,s1
    80002102:	b65fe0ef          	jal	80000c66 <release>
}
    80002106:	60e2                	ld	ra,24(sp)
    80002108:	6442                	ld	s0,16(sp)
    8000210a:	64a2                	ld	s1,8(sp)
    8000210c:	6105                	addi	sp,sp,32
    8000210e:	8082                	ret

0000000080002110 <killed>:

int
killed(struct proc *p)
{
    80002110:	1101                	addi	sp,sp,-32
    80002112:	ec06                	sd	ra,24(sp)
    80002114:	e822                	sd	s0,16(sp)
    80002116:	e426                	sd	s1,8(sp)
    80002118:	e04a                	sd	s2,0(sp)
    8000211a:	1000                	addi	s0,sp,32
    8000211c:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000211e:	ab1fe0ef          	jal	80000bce <acquire>
  k = p->killed;
    80002122:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002126:	8526                	mv	a0,s1
    80002128:	b3ffe0ef          	jal	80000c66 <release>
  return k;
}
    8000212c:	854a                	mv	a0,s2
    8000212e:	60e2                	ld	ra,24(sp)
    80002130:	6442                	ld	s0,16(sp)
    80002132:	64a2                	ld	s1,8(sp)
    80002134:	6902                	ld	s2,0(sp)
    80002136:	6105                	addi	sp,sp,32
    80002138:	8082                	ret

000000008000213a <kwait>:
{
    8000213a:	715d                	addi	sp,sp,-80
    8000213c:	e486                	sd	ra,72(sp)
    8000213e:	e0a2                	sd	s0,64(sp)
    80002140:	fc26                	sd	s1,56(sp)
    80002142:	f84a                	sd	s2,48(sp)
    80002144:	f44e                	sd	s3,40(sp)
    80002146:	f052                	sd	s4,32(sp)
    80002148:	ec56                	sd	s5,24(sp)
    8000214a:	e85a                	sd	s6,16(sp)
    8000214c:	e45e                	sd	s7,8(sp)
    8000214e:	e062                	sd	s8,0(sp)
    80002150:	0880                	addi	s0,sp,80
    80002152:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002154:	f7aff0ef          	jal	800018ce <myproc>
    80002158:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000215a:	00010517          	auipc	a0,0x10
    8000215e:	25650513          	addi	a0,a0,598 # 800123b0 <wait_lock>
    80002162:	a6dfe0ef          	jal	80000bce <acquire>
    havekids = 0;
    80002166:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002168:	4a15                	li	s4,5
        havekids = 1;
    8000216a:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000216c:	00016997          	auipc	s3,0x16
    80002170:	05c98993          	addi	s3,s3,92 # 800181c8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002174:	00010c17          	auipc	s8,0x10
    80002178:	23cc0c13          	addi	s8,s8,572 # 800123b0 <wait_lock>
    8000217c:	a871                	j	80002218 <kwait+0xde>
          pid = pp->pid;
    8000217e:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002182:	000b0c63          	beqz	s6,8000219a <kwait+0x60>
    80002186:	4691                	li	a3,4
    80002188:	02c48613          	addi	a2,s1,44
    8000218c:	85da                	mv	a1,s6
    8000218e:	05093503          	ld	a0,80(s2)
    80002192:	c50ff0ef          	jal	800015e2 <copyout>
    80002196:	02054b63          	bltz	a0,800021cc <kwait+0x92>
          freeproc(pp);
    8000219a:	8526                	mv	a0,s1
    8000219c:	903ff0ef          	jal	80001a9e <freeproc>
          release(&pp->lock);
    800021a0:	8526                	mv	a0,s1
    800021a2:	ac5fe0ef          	jal	80000c66 <release>
          release(&wait_lock);
    800021a6:	00010517          	auipc	a0,0x10
    800021aa:	20a50513          	addi	a0,a0,522 # 800123b0 <wait_lock>
    800021ae:	ab9fe0ef          	jal	80000c66 <release>
}
    800021b2:	854e                	mv	a0,s3
    800021b4:	60a6                	ld	ra,72(sp)
    800021b6:	6406                	ld	s0,64(sp)
    800021b8:	74e2                	ld	s1,56(sp)
    800021ba:	7942                	ld	s2,48(sp)
    800021bc:	79a2                	ld	s3,40(sp)
    800021be:	7a02                	ld	s4,32(sp)
    800021c0:	6ae2                	ld	s5,24(sp)
    800021c2:	6b42                	ld	s6,16(sp)
    800021c4:	6ba2                	ld	s7,8(sp)
    800021c6:	6c02                	ld	s8,0(sp)
    800021c8:	6161                	addi	sp,sp,80
    800021ca:	8082                	ret
            release(&pp->lock);
    800021cc:	8526                	mv	a0,s1
    800021ce:	a99fe0ef          	jal	80000c66 <release>
            release(&wait_lock);
    800021d2:	00010517          	auipc	a0,0x10
    800021d6:	1de50513          	addi	a0,a0,478 # 800123b0 <wait_lock>
    800021da:	a8dfe0ef          	jal	80000c66 <release>
            return -1;
    800021de:	59fd                	li	s3,-1
    800021e0:	bfc9                	j	800021b2 <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021e2:	16848493          	addi	s1,s1,360
    800021e6:	03348063          	beq	s1,s3,80002206 <kwait+0xcc>
      if(pp->parent == p){
    800021ea:	7c9c                	ld	a5,56(s1)
    800021ec:	ff279be3          	bne	a5,s2,800021e2 <kwait+0xa8>
        acquire(&pp->lock);
    800021f0:	8526                	mv	a0,s1
    800021f2:	9ddfe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    800021f6:	4c9c                	lw	a5,24(s1)
    800021f8:	f94783e3          	beq	a5,s4,8000217e <kwait+0x44>
        release(&pp->lock);
    800021fc:	8526                	mv	a0,s1
    800021fe:	a69fe0ef          	jal	80000c66 <release>
        havekids = 1;
    80002202:	8756                	mv	a4,s5
    80002204:	bff9                	j	800021e2 <kwait+0xa8>
    if(!havekids || killed(p)){
    80002206:	cf19                	beqz	a4,80002224 <kwait+0xea>
    80002208:	854a                	mv	a0,s2
    8000220a:	f07ff0ef          	jal	80002110 <killed>
    8000220e:	e919                	bnez	a0,80002224 <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002210:	85e2                	mv	a1,s8
    80002212:	854a                	mv	a0,s2
    80002214:	cc5ff0ef          	jal	80001ed8 <sleep>
    havekids = 0;
    80002218:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000221a:	00010497          	auipc	s1,0x10
    8000221e:	5ae48493          	addi	s1,s1,1454 # 800127c8 <proc>
    80002222:	b7e1                	j	800021ea <kwait+0xb0>
      release(&wait_lock);
    80002224:	00010517          	auipc	a0,0x10
    80002228:	18c50513          	addi	a0,a0,396 # 800123b0 <wait_lock>
    8000222c:	a3bfe0ef          	jal	80000c66 <release>
      return -1;
    80002230:	59fd                	li	s3,-1
    80002232:	b741                	j	800021b2 <kwait+0x78>

0000000080002234 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002234:	7179                	addi	sp,sp,-48
    80002236:	f406                	sd	ra,40(sp)
    80002238:	f022                	sd	s0,32(sp)
    8000223a:	ec26                	sd	s1,24(sp)
    8000223c:	e84a                	sd	s2,16(sp)
    8000223e:	e44e                	sd	s3,8(sp)
    80002240:	e052                	sd	s4,0(sp)
    80002242:	1800                	addi	s0,sp,48
    80002244:	84aa                	mv	s1,a0
    80002246:	892e                	mv	s2,a1
    80002248:	89b2                	mv	s3,a2
    8000224a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000224c:	e82ff0ef          	jal	800018ce <myproc>
  if(user_dst){
    80002250:	cc99                	beqz	s1,8000226e <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002252:	86d2                	mv	a3,s4
    80002254:	864e                	mv	a2,s3
    80002256:	85ca                	mv	a1,s2
    80002258:	6928                	ld	a0,80(a0)
    8000225a:	b88ff0ef          	jal	800015e2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000225e:	70a2                	ld	ra,40(sp)
    80002260:	7402                	ld	s0,32(sp)
    80002262:	64e2                	ld	s1,24(sp)
    80002264:	6942                	ld	s2,16(sp)
    80002266:	69a2                	ld	s3,8(sp)
    80002268:	6a02                	ld	s4,0(sp)
    8000226a:	6145                	addi	sp,sp,48
    8000226c:	8082                	ret
    memmove((char *)dst, src, len);
    8000226e:	000a061b          	sext.w	a2,s4
    80002272:	85ce                	mv	a1,s3
    80002274:	854a                	mv	a0,s2
    80002276:	a89fe0ef          	jal	80000cfe <memmove>
    return 0;
    8000227a:	8526                	mv	a0,s1
    8000227c:	b7cd                	j	8000225e <either_copyout+0x2a>

000000008000227e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000227e:	7179                	addi	sp,sp,-48
    80002280:	f406                	sd	ra,40(sp)
    80002282:	f022                	sd	s0,32(sp)
    80002284:	ec26                	sd	s1,24(sp)
    80002286:	e84a                	sd	s2,16(sp)
    80002288:	e44e                	sd	s3,8(sp)
    8000228a:	e052                	sd	s4,0(sp)
    8000228c:	1800                	addi	s0,sp,48
    8000228e:	892a                	mv	s2,a0
    80002290:	84ae                	mv	s1,a1
    80002292:	89b2                	mv	s3,a2
    80002294:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002296:	e38ff0ef          	jal	800018ce <myproc>
  if(user_src){
    8000229a:	cc99                	beqz	s1,800022b8 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000229c:	86d2                	mv	a3,s4
    8000229e:	864e                	mv	a2,s3
    800022a0:	85ca                	mv	a1,s2
    800022a2:	6928                	ld	a0,80(a0)
    800022a4:	c22ff0ef          	jal	800016c6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022a8:	70a2                	ld	ra,40(sp)
    800022aa:	7402                	ld	s0,32(sp)
    800022ac:	64e2                	ld	s1,24(sp)
    800022ae:	6942                	ld	s2,16(sp)
    800022b0:	69a2                	ld	s3,8(sp)
    800022b2:	6a02                	ld	s4,0(sp)
    800022b4:	6145                	addi	sp,sp,48
    800022b6:	8082                	ret
    memmove(dst, (char*)src, len);
    800022b8:	000a061b          	sext.w	a2,s4
    800022bc:	85ce                	mv	a1,s3
    800022be:	854a                	mv	a0,s2
    800022c0:	a3ffe0ef          	jal	80000cfe <memmove>
    return 0;
    800022c4:	8526                	mv	a0,s1
    800022c6:	b7cd                	j	800022a8 <either_copyin+0x2a>

00000000800022c8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022c8:	715d                	addi	sp,sp,-80
    800022ca:	e486                	sd	ra,72(sp)
    800022cc:	e0a2                	sd	s0,64(sp)
    800022ce:	fc26                	sd	s1,56(sp)
    800022d0:	f84a                	sd	s2,48(sp)
    800022d2:	f44e                	sd	s3,40(sp)
    800022d4:	f052                	sd	s4,32(sp)
    800022d6:	ec56                	sd	s5,24(sp)
    800022d8:	e85a                	sd	s6,16(sp)
    800022da:	e45e                	sd	s7,8(sp)
    800022dc:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022de:	00005517          	auipc	a0,0x5
    800022e2:	d9a50513          	addi	a0,a0,-614 # 80007078 <etext+0x78>
    800022e6:	a14fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022ea:	00010497          	auipc	s1,0x10
    800022ee:	63648493          	addi	s1,s1,1590 # 80012920 <proc+0x158>
    800022f2:	00016917          	auipc	s2,0x16
    800022f6:	02e90913          	addi	s2,s2,46 # 80018320 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022fa:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022fc:	00005997          	auipc	s3,0x5
    80002300:	f0498993          	addi	s3,s3,-252 # 80007200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    80002304:	00005a97          	auipc	s5,0x5
    80002308:	f04a8a93          	addi	s5,s5,-252 # 80007208 <etext+0x208>
    printf("\n");
    8000230c:	00005a17          	auipc	s4,0x5
    80002310:	d6ca0a13          	addi	s4,s4,-660 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002314:	00005b97          	auipc	s7,0x5
    80002318:	434b8b93          	addi	s7,s7,1076 # 80007748 <states.0>
    8000231c:	a829                	j	80002336 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000231e:	ed86a583          	lw	a1,-296(a3)
    80002322:	8556                	mv	a0,s5
    80002324:	9d6fe0ef          	jal	800004fa <printf>
    printf("\n");
    80002328:	8552                	mv	a0,s4
    8000232a:	9d0fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000232e:	16848493          	addi	s1,s1,360
    80002332:	03248263          	beq	s1,s2,80002356 <procdump+0x8e>
    if(p->state == UNUSED)
    80002336:	86a6                	mv	a3,s1
    80002338:	ec04a783          	lw	a5,-320(s1)
    8000233c:	dbed                	beqz	a5,8000232e <procdump+0x66>
      state = "???";
    8000233e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002340:	fcfb6fe3          	bltu	s6,a5,8000231e <procdump+0x56>
    80002344:	02079713          	slli	a4,a5,0x20
    80002348:	01d75793          	srli	a5,a4,0x1d
    8000234c:	97de                	add	a5,a5,s7
    8000234e:	6390                	ld	a2,0(a5)
    80002350:	f679                	bnez	a2,8000231e <procdump+0x56>
      state = "???";
    80002352:	864e                	mv	a2,s3
    80002354:	b7e9                	j	8000231e <procdump+0x56>
  }
}
    80002356:	60a6                	ld	ra,72(sp)
    80002358:	6406                	ld	s0,64(sp)
    8000235a:	74e2                	ld	s1,56(sp)
    8000235c:	7942                	ld	s2,48(sp)
    8000235e:	79a2                	ld	s3,40(sp)
    80002360:	7a02                	ld	s4,32(sp)
    80002362:	6ae2                	ld	s5,24(sp)
    80002364:	6b42                	ld	s6,16(sp)
    80002366:	6ba2                	ld	s7,8(sp)
    80002368:	6161                	addi	sp,sp,80
    8000236a:	8082                	ret

000000008000236c <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000236c:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002370:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002374:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002376:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002378:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000237c:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002380:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002384:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002388:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    8000238c:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002390:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002394:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002398:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000239c:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800023a0:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800023a4:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800023a8:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800023aa:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800023ac:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800023b0:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800023b4:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800023b8:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800023bc:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800023c0:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800023c4:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800023c8:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800023cc:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800023d0:	0685bd83          	ld	s11,104(a1)
        
        ret
    800023d4:	8082                	ret

00000000800023d6 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023d6:	1141                	addi	sp,sp,-16
    800023d8:	e406                	sd	ra,8(sp)
    800023da:	e022                	sd	s0,0(sp)
    800023dc:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023de:	00005597          	auipc	a1,0x5
    800023e2:	e6a58593          	addi	a1,a1,-406 # 80007248 <etext+0x248>
    800023e6:	00016517          	auipc	a0,0x16
    800023ea:	de250513          	addi	a0,a0,-542 # 800181c8 <tickslock>
    800023ee:	f60fe0ef          	jal	80000b4e <initlock>
}
    800023f2:	60a2                	ld	ra,8(sp)
    800023f4:	6402                	ld	s0,0(sp)
    800023f6:	0141                	addi	sp,sp,16
    800023f8:	8082                	ret

00000000800023fa <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800023fa:	1141                	addi	sp,sp,-16
    800023fc:	e422                	sd	s0,8(sp)
    800023fe:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002400:	00003797          	auipc	a5,0x3
    80002404:	06078793          	addi	a5,a5,96 # 80005460 <kernelvec>
    80002408:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000240c:	6422                	ld	s0,8(sp)
    8000240e:	0141                	addi	sp,sp,16
    80002410:	8082                	ret

0000000080002412 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002412:	1141                	addi	sp,sp,-16
    80002414:	e406                	sd	ra,8(sp)
    80002416:	e022                	sd	s0,0(sp)
    80002418:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000241a:	cb4ff0ef          	jal	800018ce <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000241e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002422:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002424:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002428:	04000737          	lui	a4,0x4000
    8000242c:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000242e:	0732                	slli	a4,a4,0xc
    80002430:	00004797          	auipc	a5,0x4
    80002434:	bd078793          	addi	a5,a5,-1072 # 80006000 <_trampoline>
    80002438:	00004697          	auipc	a3,0x4
    8000243c:	bc868693          	addi	a3,a3,-1080 # 80006000 <_trampoline>
    80002440:	8f95                	sub	a5,a5,a3
    80002442:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002444:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002448:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000244a:	18002773          	csrr	a4,satp
    8000244e:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002450:	6d38                	ld	a4,88(a0)
    80002452:	613c                	ld	a5,64(a0)
    80002454:	6685                	lui	a3,0x1
    80002456:	97b6                	add	a5,a5,a3
    80002458:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000245a:	6d3c                	ld	a5,88(a0)
    8000245c:	00000717          	auipc	a4,0x0
    80002460:	0f870713          	addi	a4,a4,248 # 80002554 <usertrap>
    80002464:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002466:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002468:	8712                	mv	a4,tp
    8000246a:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000246c:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002470:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002474:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002478:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000247c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000247e:	6f9c                	ld	a5,24(a5)
    80002480:	14179073          	csrw	sepc,a5
}
    80002484:	60a2                	ld	ra,8(sp)
    80002486:	6402                	ld	s0,0(sp)
    80002488:	0141                	addi	sp,sp,16
    8000248a:	8082                	ret

000000008000248c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000248c:	1101                	addi	sp,sp,-32
    8000248e:	ec06                	sd	ra,24(sp)
    80002490:	e822                	sd	s0,16(sp)
    80002492:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002494:	c0eff0ef          	jal	800018a2 <cpuid>
    80002498:	cd11                	beqz	a0,800024b4 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    8000249a:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000249e:	000f4737          	lui	a4,0xf4
    800024a2:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800024a6:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800024a8:	14d79073          	csrw	stimecmp,a5
}
    800024ac:	60e2                	ld	ra,24(sp)
    800024ae:	6442                	ld	s0,16(sp)
    800024b0:	6105                	addi	sp,sp,32
    800024b2:	8082                	ret
    800024b4:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800024b6:	00016497          	auipc	s1,0x16
    800024ba:	d1248493          	addi	s1,s1,-750 # 800181c8 <tickslock>
    800024be:	8526                	mv	a0,s1
    800024c0:	f0efe0ef          	jal	80000bce <acquire>
    ticks++;
    800024c4:	00008517          	auipc	a0,0x8
    800024c8:	dd450513          	addi	a0,a0,-556 # 8000a298 <ticks>
    800024cc:	411c                	lw	a5,0(a0)
    800024ce:	2785                	addiw	a5,a5,1
    800024d0:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800024d2:	a53ff0ef          	jal	80001f24 <wakeup>
    release(&tickslock);
    800024d6:	8526                	mv	a0,s1
    800024d8:	f8efe0ef          	jal	80000c66 <release>
    800024dc:	64a2                	ld	s1,8(sp)
    800024de:	bf75                	j	8000249a <clockintr+0xe>

00000000800024e0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800024e0:	1101                	addi	sp,sp,-32
    800024e2:	ec06                	sd	ra,24(sp)
    800024e4:	e822                	sd	s0,16(sp)
    800024e6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800024e8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800024ec:	57fd                	li	a5,-1
    800024ee:	17fe                	slli	a5,a5,0x3f
    800024f0:	07a5                	addi	a5,a5,9
    800024f2:	00f70c63          	beq	a4,a5,8000250a <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800024f6:	57fd                	li	a5,-1
    800024f8:	17fe                	slli	a5,a5,0x3f
    800024fa:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800024fc:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800024fe:	04f70763          	beq	a4,a5,8000254c <devintr+0x6c>
  }
}
    80002502:	60e2                	ld	ra,24(sp)
    80002504:	6442                	ld	s0,16(sp)
    80002506:	6105                	addi	sp,sp,32
    80002508:	8082                	ret
    8000250a:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000250c:	000030ef          	jal	8000550c <plic_claim>
    80002510:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002512:	47a9                	li	a5,10
    80002514:	00f50963          	beq	a0,a5,80002526 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002518:	4785                	li	a5,1
    8000251a:	00f50963          	beq	a0,a5,8000252c <devintr+0x4c>
    return 1;
    8000251e:	4505                	li	a0,1
    } else if(irq){
    80002520:	e889                	bnez	s1,80002532 <devintr+0x52>
    80002522:	64a2                	ld	s1,8(sp)
    80002524:	bff9                	j	80002502 <devintr+0x22>
      uartintr();
    80002526:	c8afe0ef          	jal	800009b0 <uartintr>
    if(irq)
    8000252a:	a819                	j	80002540 <devintr+0x60>
      virtio_disk_intr();
    8000252c:	4a6030ef          	jal	800059d2 <virtio_disk_intr>
    if(irq)
    80002530:	a801                	j	80002540 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002532:	85a6                	mv	a1,s1
    80002534:	00005517          	auipc	a0,0x5
    80002538:	d1c50513          	addi	a0,a0,-740 # 80007250 <etext+0x250>
    8000253c:	fbffd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002540:	8526                	mv	a0,s1
    80002542:	7eb020ef          	jal	8000552c <plic_complete>
    return 1;
    80002546:	4505                	li	a0,1
    80002548:	64a2                	ld	s1,8(sp)
    8000254a:	bf65                	j	80002502 <devintr+0x22>
    clockintr();
    8000254c:	f41ff0ef          	jal	8000248c <clockintr>
    return 2;
    80002550:	4509                	li	a0,2
    80002552:	bf45                	j	80002502 <devintr+0x22>

0000000080002554 <usertrap>:
{
    80002554:	1101                	addi	sp,sp,-32
    80002556:	ec06                	sd	ra,24(sp)
    80002558:	e822                	sd	s0,16(sp)
    8000255a:	e426                	sd	s1,8(sp)
    8000255c:	e04a                	sd	s2,0(sp)
    8000255e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002560:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002564:	1007f793          	andi	a5,a5,256
    80002568:	eba5                	bnez	a5,800025d8 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000256a:	00003797          	auipc	a5,0x3
    8000256e:	ef678793          	addi	a5,a5,-266 # 80005460 <kernelvec>
    80002572:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002576:	b58ff0ef          	jal	800018ce <myproc>
    8000257a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000257c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000257e:	14102773          	csrr	a4,sepc
    80002582:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002584:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002588:	47a1                	li	a5,8
    8000258a:	04f70d63          	beq	a4,a5,800025e4 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    8000258e:	f53ff0ef          	jal	800024e0 <devintr>
    80002592:	892a                	mv	s2,a0
    80002594:	e945                	bnez	a0,80002644 <usertrap+0xf0>
    80002596:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000259a:	47bd                	li	a5,15
    8000259c:	08f70863          	beq	a4,a5,8000262c <usertrap+0xd8>
    800025a0:	14202773          	csrr	a4,scause
    800025a4:	47b5                	li	a5,13
    800025a6:	08f70363          	beq	a4,a5,8000262c <usertrap+0xd8>
    800025aa:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800025ae:	5890                	lw	a2,48(s1)
    800025b0:	00005517          	auipc	a0,0x5
    800025b4:	ce050513          	addi	a0,a0,-800 # 80007290 <etext+0x290>
    800025b8:	f43fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025bc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025c0:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800025c4:	00005517          	auipc	a0,0x5
    800025c8:	cfc50513          	addi	a0,a0,-772 # 800072c0 <etext+0x2c0>
    800025cc:	f2ffd0ef          	jal	800004fa <printf>
    setkilled(p);
    800025d0:	8526                	mv	a0,s1
    800025d2:	b1bff0ef          	jal	800020ec <setkilled>
    800025d6:	a035                	j	80002602 <usertrap+0xae>
    panic("usertrap: not from user mode");
    800025d8:	00005517          	auipc	a0,0x5
    800025dc:	c9850513          	addi	a0,a0,-872 # 80007270 <etext+0x270>
    800025e0:	a00fe0ef          	jal	800007e0 <panic>
    if(killed(p))
    800025e4:	b2dff0ef          	jal	80002110 <killed>
    800025e8:	ed15                	bnez	a0,80002624 <usertrap+0xd0>
    p->trapframe->epc += 4;
    800025ea:	6cb8                	ld	a4,88(s1)
    800025ec:	6f1c                	ld	a5,24(a4)
    800025ee:	0791                	addi	a5,a5,4
    800025f0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025f2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025f6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025fa:	10079073          	csrw	sstatus,a5
    syscall();
    800025fe:	246000ef          	jal	80002844 <syscall>
  if(killed(p))
    80002602:	8526                	mv	a0,s1
    80002604:	b0dff0ef          	jal	80002110 <killed>
    80002608:	e139                	bnez	a0,8000264e <usertrap+0xfa>
  prepare_return();
    8000260a:	e09ff0ef          	jal	80002412 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000260e:	68a8                	ld	a0,80(s1)
    80002610:	8131                	srli	a0,a0,0xc
    80002612:	57fd                	li	a5,-1
    80002614:	17fe                	slli	a5,a5,0x3f
    80002616:	8d5d                	or	a0,a0,a5
}
    80002618:	60e2                	ld	ra,24(sp)
    8000261a:	6442                	ld	s0,16(sp)
    8000261c:	64a2                	ld	s1,8(sp)
    8000261e:	6902                	ld	s2,0(sp)
    80002620:	6105                	addi	sp,sp,32
    80002622:	8082                	ret
      kexit(-1);
    80002624:	557d                	li	a0,-1
    80002626:	9bfff0ef          	jal	80001fe4 <kexit>
    8000262a:	b7c1                	j	800025ea <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000262c:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002630:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002634:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002636:	00163613          	seqz	a2,a2
    8000263a:	68a8                	ld	a0,80(s1)
    8000263c:	f25fe0ef          	jal	80001560 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002640:	f169                	bnez	a0,80002602 <usertrap+0xae>
    80002642:	b7a5                	j	800025aa <usertrap+0x56>
  if(killed(p))
    80002644:	8526                	mv	a0,s1
    80002646:	acbff0ef          	jal	80002110 <killed>
    8000264a:	c511                	beqz	a0,80002656 <usertrap+0x102>
    8000264c:	a011                	j	80002650 <usertrap+0xfc>
    8000264e:	4901                	li	s2,0
    kexit(-1);
    80002650:	557d                	li	a0,-1
    80002652:	993ff0ef          	jal	80001fe4 <kexit>
  if(which_dev == 2)
    80002656:	4789                	li	a5,2
    80002658:	faf919e3          	bne	s2,a5,8000260a <usertrap+0xb6>
    yield();
    8000265c:	851ff0ef          	jal	80001eac <yield>
    80002660:	b76d                	j	8000260a <usertrap+0xb6>

0000000080002662 <kerneltrap>:
{
    80002662:	7179                	addi	sp,sp,-48
    80002664:	f406                	sd	ra,40(sp)
    80002666:	f022                	sd	s0,32(sp)
    80002668:	ec26                	sd	s1,24(sp)
    8000266a:	e84a                	sd	s2,16(sp)
    8000266c:	e44e                	sd	s3,8(sp)
    8000266e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002670:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002674:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002678:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000267c:	1004f793          	andi	a5,s1,256
    80002680:	c795                	beqz	a5,800026ac <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002682:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002686:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002688:	eb85                	bnez	a5,800026b8 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    8000268a:	e57ff0ef          	jal	800024e0 <devintr>
    8000268e:	c91d                	beqz	a0,800026c4 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002690:	4789                	li	a5,2
    80002692:	04f50a63          	beq	a0,a5,800026e6 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002696:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000269a:	10049073          	csrw	sstatus,s1
}
    8000269e:	70a2                	ld	ra,40(sp)
    800026a0:	7402                	ld	s0,32(sp)
    800026a2:	64e2                	ld	s1,24(sp)
    800026a4:	6942                	ld	s2,16(sp)
    800026a6:	69a2                	ld	s3,8(sp)
    800026a8:	6145                	addi	sp,sp,48
    800026aa:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800026ac:	00005517          	auipc	a0,0x5
    800026b0:	c3c50513          	addi	a0,a0,-964 # 800072e8 <etext+0x2e8>
    800026b4:	92cfe0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    800026b8:	00005517          	auipc	a0,0x5
    800026bc:	c5850513          	addi	a0,a0,-936 # 80007310 <etext+0x310>
    800026c0:	920fe0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026c4:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026c8:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800026cc:	85ce                	mv	a1,s3
    800026ce:	00005517          	auipc	a0,0x5
    800026d2:	c6250513          	addi	a0,a0,-926 # 80007330 <etext+0x330>
    800026d6:	e25fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    800026da:	00005517          	auipc	a0,0x5
    800026de:	c7e50513          	addi	a0,a0,-898 # 80007358 <etext+0x358>
    800026e2:	8fefe0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    800026e6:	9e8ff0ef          	jal	800018ce <myproc>
    800026ea:	d555                	beqz	a0,80002696 <kerneltrap+0x34>
    yield();
    800026ec:	fc0ff0ef          	jal	80001eac <yield>
    800026f0:	b75d                	j	80002696 <kerneltrap+0x34>

00000000800026f2 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026f2:	1101                	addi	sp,sp,-32
    800026f4:	ec06                	sd	ra,24(sp)
    800026f6:	e822                	sd	s0,16(sp)
    800026f8:	e426                	sd	s1,8(sp)
    800026fa:	1000                	addi	s0,sp,32
    800026fc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800026fe:	9d0ff0ef          	jal	800018ce <myproc>
  switch (n) {
    80002702:	4795                	li	a5,5
    80002704:	0497e163          	bltu	a5,s1,80002746 <argraw+0x54>
    80002708:	048a                	slli	s1,s1,0x2
    8000270a:	00005717          	auipc	a4,0x5
    8000270e:	06e70713          	addi	a4,a4,110 # 80007778 <states.0+0x30>
    80002712:	94ba                	add	s1,s1,a4
    80002714:	409c                	lw	a5,0(s1)
    80002716:	97ba                	add	a5,a5,a4
    80002718:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000271a:	6d3c                	ld	a5,88(a0)
    8000271c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000271e:	60e2                	ld	ra,24(sp)
    80002720:	6442                	ld	s0,16(sp)
    80002722:	64a2                	ld	s1,8(sp)
    80002724:	6105                	addi	sp,sp,32
    80002726:	8082                	ret
    return p->trapframe->a1;
    80002728:	6d3c                	ld	a5,88(a0)
    8000272a:	7fa8                	ld	a0,120(a5)
    8000272c:	bfcd                	j	8000271e <argraw+0x2c>
    return p->trapframe->a2;
    8000272e:	6d3c                	ld	a5,88(a0)
    80002730:	63c8                	ld	a0,128(a5)
    80002732:	b7f5                	j	8000271e <argraw+0x2c>
    return p->trapframe->a3;
    80002734:	6d3c                	ld	a5,88(a0)
    80002736:	67c8                	ld	a0,136(a5)
    80002738:	b7dd                	j	8000271e <argraw+0x2c>
    return p->trapframe->a4;
    8000273a:	6d3c                	ld	a5,88(a0)
    8000273c:	6bc8                	ld	a0,144(a5)
    8000273e:	b7c5                	j	8000271e <argraw+0x2c>
    return p->trapframe->a5;
    80002740:	6d3c                	ld	a5,88(a0)
    80002742:	6fc8                	ld	a0,152(a5)
    80002744:	bfe9                	j	8000271e <argraw+0x2c>
  panic("argraw");
    80002746:	00005517          	auipc	a0,0x5
    8000274a:	c2250513          	addi	a0,a0,-990 # 80007368 <etext+0x368>
    8000274e:	892fe0ef          	jal	800007e0 <panic>

0000000080002752 <fetchaddr>:
{
    80002752:	1101                	addi	sp,sp,-32
    80002754:	ec06                	sd	ra,24(sp)
    80002756:	e822                	sd	s0,16(sp)
    80002758:	e426                	sd	s1,8(sp)
    8000275a:	e04a                	sd	s2,0(sp)
    8000275c:	1000                	addi	s0,sp,32
    8000275e:	84aa                	mv	s1,a0
    80002760:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002762:	96cff0ef          	jal	800018ce <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002766:	653c                	ld	a5,72(a0)
    80002768:	02f4f663          	bgeu	s1,a5,80002794 <fetchaddr+0x42>
    8000276c:	00848713          	addi	a4,s1,8
    80002770:	02e7e463          	bltu	a5,a4,80002798 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002774:	46a1                	li	a3,8
    80002776:	8626                	mv	a2,s1
    80002778:	85ca                	mv	a1,s2
    8000277a:	6928                	ld	a0,80(a0)
    8000277c:	f4bfe0ef          	jal	800016c6 <copyin>
    80002780:	00a03533          	snez	a0,a0
    80002784:	40a00533          	neg	a0,a0
}
    80002788:	60e2                	ld	ra,24(sp)
    8000278a:	6442                	ld	s0,16(sp)
    8000278c:	64a2                	ld	s1,8(sp)
    8000278e:	6902                	ld	s2,0(sp)
    80002790:	6105                	addi	sp,sp,32
    80002792:	8082                	ret
    return -1;
    80002794:	557d                	li	a0,-1
    80002796:	bfcd                	j	80002788 <fetchaddr+0x36>
    80002798:	557d                	li	a0,-1
    8000279a:	b7fd                	j	80002788 <fetchaddr+0x36>

000000008000279c <fetchstr>:
{
    8000279c:	7179                	addi	sp,sp,-48
    8000279e:	f406                	sd	ra,40(sp)
    800027a0:	f022                	sd	s0,32(sp)
    800027a2:	ec26                	sd	s1,24(sp)
    800027a4:	e84a                	sd	s2,16(sp)
    800027a6:	e44e                	sd	s3,8(sp)
    800027a8:	1800                	addi	s0,sp,48
    800027aa:	892a                	mv	s2,a0
    800027ac:	84ae                	mv	s1,a1
    800027ae:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800027b0:	91eff0ef          	jal	800018ce <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800027b4:	86ce                	mv	a3,s3
    800027b6:	864a                	mv	a2,s2
    800027b8:	85a6                	mv	a1,s1
    800027ba:	6928                	ld	a0,80(a0)
    800027bc:	ccdfe0ef          	jal	80001488 <copyinstr>
    800027c0:	00054c63          	bltz	a0,800027d8 <fetchstr+0x3c>
  return strlen(buf);
    800027c4:	8526                	mv	a0,s1
    800027c6:	e4cfe0ef          	jal	80000e12 <strlen>
}
    800027ca:	70a2                	ld	ra,40(sp)
    800027cc:	7402                	ld	s0,32(sp)
    800027ce:	64e2                	ld	s1,24(sp)
    800027d0:	6942                	ld	s2,16(sp)
    800027d2:	69a2                	ld	s3,8(sp)
    800027d4:	6145                	addi	sp,sp,48
    800027d6:	8082                	ret
    return -1;
    800027d8:	557d                	li	a0,-1
    800027da:	bfc5                	j	800027ca <fetchstr+0x2e>

00000000800027dc <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800027dc:	1101                	addi	sp,sp,-32
    800027de:	ec06                	sd	ra,24(sp)
    800027e0:	e822                	sd	s0,16(sp)
    800027e2:	e426                	sd	s1,8(sp)
    800027e4:	1000                	addi	s0,sp,32
    800027e6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027e8:	f0bff0ef          	jal	800026f2 <argraw>
    800027ec:	c088                	sw	a0,0(s1)
}
    800027ee:	60e2                	ld	ra,24(sp)
    800027f0:	6442                	ld	s0,16(sp)
    800027f2:	64a2                	ld	s1,8(sp)
    800027f4:	6105                	addi	sp,sp,32
    800027f6:	8082                	ret

00000000800027f8 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800027f8:	1101                	addi	sp,sp,-32
    800027fa:	ec06                	sd	ra,24(sp)
    800027fc:	e822                	sd	s0,16(sp)
    800027fe:	e426                	sd	s1,8(sp)
    80002800:	1000                	addi	s0,sp,32
    80002802:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002804:	eefff0ef          	jal	800026f2 <argraw>
    80002808:	e088                	sd	a0,0(s1)
}
    8000280a:	60e2                	ld	ra,24(sp)
    8000280c:	6442                	ld	s0,16(sp)
    8000280e:	64a2                	ld	s1,8(sp)
    80002810:	6105                	addi	sp,sp,32
    80002812:	8082                	ret

0000000080002814 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002814:	7179                	addi	sp,sp,-48
    80002816:	f406                	sd	ra,40(sp)
    80002818:	f022                	sd	s0,32(sp)
    8000281a:	ec26                	sd	s1,24(sp)
    8000281c:	e84a                	sd	s2,16(sp)
    8000281e:	1800                	addi	s0,sp,48
    80002820:	84ae                	mv	s1,a1
    80002822:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002824:	fd840593          	addi	a1,s0,-40
    80002828:	fd1ff0ef          	jal	800027f8 <argaddr>
  return fetchstr(addr, buf, max);
    8000282c:	864a                	mv	a2,s2
    8000282e:	85a6                	mv	a1,s1
    80002830:	fd843503          	ld	a0,-40(s0)
    80002834:	f69ff0ef          	jal	8000279c <fetchstr>
}
    80002838:	70a2                	ld	ra,40(sp)
    8000283a:	7402                	ld	s0,32(sp)
    8000283c:	64e2                	ld	s1,24(sp)
    8000283e:	6942                	ld	s2,16(sp)
    80002840:	6145                	addi	sp,sp,48
    80002842:	8082                	ret

0000000080002844 <syscall>:
[SYS_sleep2] sys_sleep2,
};

void
syscall(void)
{
    80002844:	1101                	addi	sp,sp,-32
    80002846:	ec06                	sd	ra,24(sp)
    80002848:	e822                	sd	s0,16(sp)
    8000284a:	e426                	sd	s1,8(sp)
    8000284c:	e04a                	sd	s2,0(sp)
    8000284e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002850:	87eff0ef          	jal	800018ce <myproc>
    80002854:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002856:	05853903          	ld	s2,88(a0)
    8000285a:	0a893783          	ld	a5,168(s2)
    8000285e:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002862:	37fd                	addiw	a5,a5,-1
    80002864:	475d                	li	a4,23
    80002866:	00f76f63          	bltu	a4,a5,80002884 <syscall+0x40>
    8000286a:	00369713          	slli	a4,a3,0x3
    8000286e:	00005797          	auipc	a5,0x5
    80002872:	f2278793          	addi	a5,a5,-222 # 80007790 <syscalls>
    80002876:	97ba                	add	a5,a5,a4
    80002878:	639c                	ld	a5,0(a5)
    8000287a:	c789                	beqz	a5,80002884 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000287c:	9782                	jalr	a5
    8000287e:	06a93823          	sd	a0,112(s2)
    80002882:	a829                	j	8000289c <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002884:	15848613          	addi	a2,s1,344
    80002888:	588c                	lw	a1,48(s1)
    8000288a:	00005517          	auipc	a0,0x5
    8000288e:	ae650513          	addi	a0,a0,-1306 # 80007370 <etext+0x370>
    80002892:	c69fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002896:	6cbc                	ld	a5,88(s1)
    80002898:	577d                	li	a4,-1
    8000289a:	fbb8                	sd	a4,112(a5)
  }
}
    8000289c:	60e2                	ld	ra,24(sp)
    8000289e:	6442                	ld	s0,16(sp)
    800028a0:	64a2                	ld	s1,8(sp)
    800028a2:	6902                	ld	s2,0(sp)
    800028a4:	6105                	addi	sp,sp,32
    800028a6:	8082                	ret

00000000800028a8 <sys_exit>:
#include "spinlock.h"
#include "proc.h"
#include "vm.h"
uint64
sys_exit(void)
{
    800028a8:	1101                	addi	sp,sp,-32
    800028aa:	ec06                	sd	ra,24(sp)
    800028ac:	e822                	sd	s0,16(sp)
    800028ae:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800028b0:	fec40593          	addi	a1,s0,-20
    800028b4:	4501                	li	a0,0
    800028b6:	f27ff0ef          	jal	800027dc <argint>
  kexit(n);
    800028ba:	fec42503          	lw	a0,-20(s0)
    800028be:	f26ff0ef          	jal	80001fe4 <kexit>
  return 0;  // not reached
}
    800028c2:	4501                	li	a0,0
    800028c4:	60e2                	ld	ra,24(sp)
    800028c6:	6442                	ld	s0,16(sp)
    800028c8:	6105                	addi	sp,sp,32
    800028ca:	8082                	ret

00000000800028cc <sys_getpid>:

uint64
sys_getpid(void)
{
    800028cc:	1141                	addi	sp,sp,-16
    800028ce:	e406                	sd	ra,8(sp)
    800028d0:	e022                	sd	s0,0(sp)
    800028d2:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800028d4:	ffbfe0ef          	jal	800018ce <myproc>
}
    800028d8:	5908                	lw	a0,48(a0)
    800028da:	60a2                	ld	ra,8(sp)
    800028dc:	6402                	ld	s0,0(sp)
    800028de:	0141                	addi	sp,sp,16
    800028e0:	8082                	ret

00000000800028e2 <sys_fork>:

uint64
sys_fork(void)
{
    800028e2:	1141                	addi	sp,sp,-16
    800028e4:	e406                	sd	ra,8(sp)
    800028e6:	e022                	sd	s0,0(sp)
    800028e8:	0800                	addi	s0,sp,16
  return kfork();
    800028ea:	b48ff0ef          	jal	80001c32 <kfork>
}
    800028ee:	60a2                	ld	ra,8(sp)
    800028f0:	6402                	ld	s0,0(sp)
    800028f2:	0141                	addi	sp,sp,16
    800028f4:	8082                	ret

00000000800028f6 <sys_wait>:

uint64
sys_wait(void)
{
    800028f6:	1101                	addi	sp,sp,-32
    800028f8:	ec06                	sd	ra,24(sp)
    800028fa:	e822                	sd	s0,16(sp)
    800028fc:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800028fe:	fe840593          	addi	a1,s0,-24
    80002902:	4501                	li	a0,0
    80002904:	ef5ff0ef          	jal	800027f8 <argaddr>
  return kwait(p);
    80002908:	fe843503          	ld	a0,-24(s0)
    8000290c:	82fff0ef          	jal	8000213a <kwait>
}
    80002910:	60e2                	ld	ra,24(sp)
    80002912:	6442                	ld	s0,16(sp)
    80002914:	6105                	addi	sp,sp,32
    80002916:	8082                	ret

0000000080002918 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002918:	7179                	addi	sp,sp,-48
    8000291a:	f406                	sd	ra,40(sp)
    8000291c:	f022                	sd	s0,32(sp)
    8000291e:	ec26                	sd	s1,24(sp)
    80002920:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002922:	fd840593          	addi	a1,s0,-40
    80002926:	4501                	li	a0,0
    80002928:	eb5ff0ef          	jal	800027dc <argint>
  argint(1, &t);
    8000292c:	fdc40593          	addi	a1,s0,-36
    80002930:	4505                	li	a0,1
    80002932:	eabff0ef          	jal	800027dc <argint>
  addr = myproc()->sz;
    80002936:	f99fe0ef          	jal	800018ce <myproc>
    8000293a:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    8000293c:	fdc42703          	lw	a4,-36(s0)
    80002940:	4785                	li	a5,1
    80002942:	02f70763          	beq	a4,a5,80002970 <sys_sbrk+0x58>
    80002946:	fd842783          	lw	a5,-40(s0)
    8000294a:	0207c363          	bltz	a5,80002970 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    8000294e:	97a6                	add	a5,a5,s1
    80002950:	0297ee63          	bltu	a5,s1,8000298c <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002954:	02000737          	lui	a4,0x2000
    80002958:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    8000295a:	0736                	slli	a4,a4,0xd
    8000295c:	02f76a63          	bltu	a4,a5,80002990 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002960:	f6ffe0ef          	jal	800018ce <myproc>
    80002964:	fd842703          	lw	a4,-40(s0)
    80002968:	653c                	ld	a5,72(a0)
    8000296a:	97ba                	add	a5,a5,a4
    8000296c:	e53c                	sd	a5,72(a0)
    8000296e:	a039                	j	8000297c <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002970:	fd842503          	lw	a0,-40(s0)
    80002974:	a5cff0ef          	jal	80001bd0 <growproc>
    80002978:	00054863          	bltz	a0,80002988 <sys_sbrk+0x70>
  }
  return addr;
}
    8000297c:	8526                	mv	a0,s1
    8000297e:	70a2                	ld	ra,40(sp)
    80002980:	7402                	ld	s0,32(sp)
    80002982:	64e2                	ld	s1,24(sp)
    80002984:	6145                	addi	sp,sp,48
    80002986:	8082                	ret
      return -1;
    80002988:	54fd                	li	s1,-1
    8000298a:	bfcd                	j	8000297c <sys_sbrk+0x64>
      return -1;
    8000298c:	54fd                	li	s1,-1
    8000298e:	b7fd                	j	8000297c <sys_sbrk+0x64>
      return -1;
    80002990:	54fd                	li	s1,-1
    80002992:	b7ed                	j	8000297c <sys_sbrk+0x64>

0000000080002994 <sys_pause>:

uint64
sys_pause(void)
{
    80002994:	7139                	addi	sp,sp,-64
    80002996:	fc06                	sd	ra,56(sp)
    80002998:	f822                	sd	s0,48(sp)
    8000299a:	f04a                	sd	s2,32(sp)
    8000299c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000299e:	fcc40593          	addi	a1,s0,-52
    800029a2:	4501                	li	a0,0
    800029a4:	e39ff0ef          	jal	800027dc <argint>
  if(n < 0)
    800029a8:	fcc42783          	lw	a5,-52(s0)
    800029ac:	0607c763          	bltz	a5,80002a1a <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    800029b0:	00016517          	auipc	a0,0x16
    800029b4:	81850513          	addi	a0,a0,-2024 # 800181c8 <tickslock>
    800029b8:	a16fe0ef          	jal	80000bce <acquire>
  ticks0 = ticks;
    800029bc:	00008917          	auipc	s2,0x8
    800029c0:	8dc92903          	lw	s2,-1828(s2) # 8000a298 <ticks>
  while(ticks - ticks0 < n){
    800029c4:	fcc42783          	lw	a5,-52(s0)
    800029c8:	cf8d                	beqz	a5,80002a02 <sys_pause+0x6e>
    800029ca:	f426                	sd	s1,40(sp)
    800029cc:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800029ce:	00015997          	auipc	s3,0x15
    800029d2:	7fa98993          	addi	s3,s3,2042 # 800181c8 <tickslock>
    800029d6:	00008497          	auipc	s1,0x8
    800029da:	8c248493          	addi	s1,s1,-1854 # 8000a298 <ticks>
    if(killed(myproc())){
    800029de:	ef1fe0ef          	jal	800018ce <myproc>
    800029e2:	f2eff0ef          	jal	80002110 <killed>
    800029e6:	ed0d                	bnez	a0,80002a20 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    800029e8:	85ce                	mv	a1,s3
    800029ea:	8526                	mv	a0,s1
    800029ec:	cecff0ef          	jal	80001ed8 <sleep>
  while(ticks - ticks0 < n){
    800029f0:	409c                	lw	a5,0(s1)
    800029f2:	412787bb          	subw	a5,a5,s2
    800029f6:	fcc42703          	lw	a4,-52(s0)
    800029fa:	fee7e2e3          	bltu	a5,a4,800029de <sys_pause+0x4a>
    800029fe:	74a2                	ld	s1,40(sp)
    80002a00:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002a02:	00015517          	auipc	a0,0x15
    80002a06:	7c650513          	addi	a0,a0,1990 # 800181c8 <tickslock>
    80002a0a:	a5cfe0ef          	jal	80000c66 <release>
  return 0;
    80002a0e:	4501                	li	a0,0
}
    80002a10:	70e2                	ld	ra,56(sp)
    80002a12:	7442                	ld	s0,48(sp)
    80002a14:	7902                	ld	s2,32(sp)
    80002a16:	6121                	addi	sp,sp,64
    80002a18:	8082                	ret
    n = 0;
    80002a1a:	fc042623          	sw	zero,-52(s0)
    80002a1e:	bf49                	j	800029b0 <sys_pause+0x1c>
      release(&tickslock);
    80002a20:	00015517          	auipc	a0,0x15
    80002a24:	7a850513          	addi	a0,a0,1960 # 800181c8 <tickslock>
    80002a28:	a3efe0ef          	jal	80000c66 <release>
      return -1;
    80002a2c:	557d                	li	a0,-1
    80002a2e:	74a2                	ld	s1,40(sp)
    80002a30:	69e2                	ld	s3,24(sp)
    80002a32:	bff9                	j	80002a10 <sys_pause+0x7c>

0000000080002a34 <sys_kill>:

uint64
sys_kill(void)
{
    80002a34:	1101                	addi	sp,sp,-32
    80002a36:	ec06                	sd	ra,24(sp)
    80002a38:	e822                	sd	s0,16(sp)
    80002a3a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a3c:	fec40593          	addi	a1,s0,-20
    80002a40:	4501                	li	a0,0
    80002a42:	d9bff0ef          	jal	800027dc <argint>
  return kkill(pid);
    80002a46:	fec42503          	lw	a0,-20(s0)
    80002a4a:	e3cff0ef          	jal	80002086 <kkill>
}
    80002a4e:	60e2                	ld	ra,24(sp)
    80002a50:	6442                	ld	s0,16(sp)
    80002a52:	6105                	addi	sp,sp,32
    80002a54:	8082                	ret

0000000080002a56 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a56:	1101                	addi	sp,sp,-32
    80002a58:	ec06                	sd	ra,24(sp)
    80002a5a:	e822                	sd	s0,16(sp)
    80002a5c:	e426                	sd	s1,8(sp)
    80002a5e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a60:	00015517          	auipc	a0,0x15
    80002a64:	76850513          	addi	a0,a0,1896 # 800181c8 <tickslock>
    80002a68:	966fe0ef          	jal	80000bce <acquire>
  xticks = ticks;
    80002a6c:	00008497          	auipc	s1,0x8
    80002a70:	82c4a483          	lw	s1,-2004(s1) # 8000a298 <ticks>
  release(&tickslock);
    80002a74:	00015517          	auipc	a0,0x15
    80002a78:	75450513          	addi	a0,a0,1876 # 800181c8 <tickslock>
    80002a7c:	9eafe0ef          	jal	80000c66 <release>
  return xticks;
}
    80002a80:	02049513          	slli	a0,s1,0x20
    80002a84:	9101                	srli	a0,a0,0x20
    80002a86:	60e2                	ld	ra,24(sp)
    80002a88:	6442                	ld	s0,16(sp)
    80002a8a:	64a2                	ld	s1,8(sp)
    80002a8c:	6105                	addi	sp,sp,32
    80002a8e:	8082                	ret

0000000080002a90 <sys_getprocsinfo>:

extern struct proc proc[NPROC];

uint64
sys_getprocsinfo(void)
{
    80002a90:	7179                	addi	sp,sp,-48
    80002a92:	f406                	sd	ra,40(sp)
    80002a94:	f022                	sd	s0,32(sp)
    80002a96:	ec26                	sd	s1,24(sp)
    80002a98:	e84a                	sd	s2,16(sp)
    80002a9a:	e44e                	sd	s3,8(sp)
    80002a9c:	1800                	addi	s0,sp,48
    struct proc *p;

    printf("PID\tSTATE\tSIZE\n");
    80002a9e:	00005517          	auipc	a0,0x5
    80002aa2:	8f250513          	addi	a0,a0,-1806 # 80007390 <etext+0x390>
    80002aa6:	a55fd0ef          	jal	800004fa <printf>

    for(p = proc; p < &proc[NPROC]; p++){
    80002aaa:	00010497          	auipc	s1,0x10
    80002aae:	d1e48493          	addi	s1,s1,-738 # 800127c8 <proc>
        if(p->state != UNUSED){
            printf("%d\t%d\t%ld\n", p->pid, p->state, p->sz);
    80002ab2:	00005997          	auipc	s3,0x5
    80002ab6:	8ee98993          	addi	s3,s3,-1810 # 800073a0 <etext+0x3a0>
    for(p = proc; p < &proc[NPROC]; p++){
    80002aba:	00015917          	auipc	s2,0x15
    80002abe:	70e90913          	addi	s2,s2,1806 # 800181c8 <tickslock>
    80002ac2:	a029                	j	80002acc <sys_getprocsinfo+0x3c>
    80002ac4:	16848493          	addi	s1,s1,360
    80002ac8:	01248a63          	beq	s1,s2,80002adc <sys_getprocsinfo+0x4c>
        if(p->state != UNUSED){
    80002acc:	4c90                	lw	a2,24(s1)
    80002ace:	da7d                	beqz	a2,80002ac4 <sys_getprocsinfo+0x34>
            printf("%d\t%d\t%ld\n", p->pid, p->state, p->sz);
    80002ad0:	64b4                	ld	a3,72(s1)
    80002ad2:	588c                	lw	a1,48(s1)
    80002ad4:	854e                	mv	a0,s3
    80002ad6:	a25fd0ef          	jal	800004fa <printf>
    80002ada:	b7ed                	j	80002ac4 <sys_getprocsinfo+0x34>
        }
    }

    return 0;
}
    80002adc:	4501                	li	a0,0
    80002ade:	70a2                	ld	ra,40(sp)
    80002ae0:	7402                	ld	s0,32(sp)
    80002ae2:	64e2                	ld	s1,24(sp)
    80002ae4:	6942                	ld	s2,16(sp)
    80002ae6:	69a2                	ld	s3,8(sp)
    80002ae8:	6145                	addi	sp,sp,48
    80002aea:	8082                	ret

0000000080002aec <sys_getppid>:
uint64
sys_getppid(void)
{
    80002aec:	1141                	addi	sp,sp,-16
    80002aee:	e406                	sd	ra,8(sp)
    80002af0:	e022                	sd	s0,0(sp)
    80002af2:	0800                	addi	s0,sp,16
    struct proc *p = myproc();
    80002af4:	ddbfe0ef          	jal	800018ce <myproc>
    if(p->parent)
    80002af8:	7d1c                	ld	a5,56(a0)
        return p->parent->pid;
    return -1;
    80002afa:	557d                	li	a0,-1
    if(p->parent)
    80002afc:	c391                	beqz	a5,80002b00 <sys_getppid+0x14>
        return p->parent->pid;
    80002afe:	5b88                	lw	a0,48(a5)
}
    80002b00:	60a2                	ld	ra,8(sp)
    80002b02:	6402                	ld	s0,0(sp)
    80002b04:	0141                	addi	sp,sp,16
    80002b06:	8082                	ret

0000000080002b08 <sys_sleep2>:
uint64
sys_sleep2(void)
{
    80002b08:	7139                	addi	sp,sp,-64
    80002b0a:	fc06                	sd	ra,56(sp)
    80002b0c:	f822                	sd	s0,48(sp)
    80002b0e:	f04a                	sd	s2,32(sp)
    80002b10:	ec4e                	sd	s3,24(sp)
    80002b12:	0080                	addi	s0,sp,64
    int n;
    argint(0, &n);
    80002b14:	fcc40593          	addi	a1,s0,-52
    80002b18:	4501                	li	a0,0
    80002b1a:	cc3ff0ef          	jal	800027dc <argint>

    struct proc *p = myproc();
    80002b1e:	db1fe0ef          	jal	800018ce <myproc>
    80002b22:	892a                	mv	s2,a0

    acquire(&tickslock);
    80002b24:	00015517          	auipc	a0,0x15
    80002b28:	6a450513          	addi	a0,a0,1700 # 800181c8 <tickslock>
    80002b2c:	8a2fe0ef          	jal	80000bce <acquire>
    uint ticks0 = ticks;
    80002b30:	00007997          	auipc	s3,0x7
    80002b34:	7689a983          	lw	s3,1896(s3) # 8000a298 <ticks>

    while(ticks - ticks0 < n){
    80002b38:	fcc42783          	lw	a5,-52(s0)
    80002b3c:	cb9d                	beqz	a5,80002b72 <sys_sleep2+0x6a>
    80002b3e:	f426                	sd	s1,40(sp)
    80002b40:	e852                	sd	s4,16(sp)
        if(p->killed){
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    80002b42:	00015a17          	auipc	s4,0x15
    80002b46:	686a0a13          	addi	s4,s4,1670 # 800181c8 <tickslock>
    80002b4a:	00007497          	auipc	s1,0x7
    80002b4e:	74e48493          	addi	s1,s1,1870 # 8000a298 <ticks>
        if(p->killed){
    80002b52:	02892783          	lw	a5,40(s2)
    80002b56:	eb9d                	bnez	a5,80002b8c <sys_sleep2+0x84>
        sleep(&ticks, &tickslock);
    80002b58:	85d2                	mv	a1,s4
    80002b5a:	8526                	mv	a0,s1
    80002b5c:	b7cff0ef          	jal	80001ed8 <sleep>
    while(ticks - ticks0 < n){
    80002b60:	409c                	lw	a5,0(s1)
    80002b62:	413787bb          	subw	a5,a5,s3
    80002b66:	fcc42703          	lw	a4,-52(s0)
    80002b6a:	fee7e4e3          	bltu	a5,a4,80002b52 <sys_sleep2+0x4a>
    80002b6e:	74a2                	ld	s1,40(sp)
    80002b70:	6a42                	ld	s4,16(sp)
    }

    release(&tickslock);
    80002b72:	00015517          	auipc	a0,0x15
    80002b76:	65650513          	addi	a0,a0,1622 # 800181c8 <tickslock>
    80002b7a:	8ecfe0ef          	jal	80000c66 <release>
    return 0;
    80002b7e:	4501                	li	a0,0
}
    80002b80:	70e2                	ld	ra,56(sp)
    80002b82:	7442                	ld	s0,48(sp)
    80002b84:	7902                	ld	s2,32(sp)
    80002b86:	69e2                	ld	s3,24(sp)
    80002b88:	6121                	addi	sp,sp,64
    80002b8a:	8082                	ret
            release(&tickslock);
    80002b8c:	00015517          	auipc	a0,0x15
    80002b90:	63c50513          	addi	a0,a0,1596 # 800181c8 <tickslock>
    80002b94:	8d2fe0ef          	jal	80000c66 <release>
            return -1;
    80002b98:	557d                	li	a0,-1
    80002b9a:	74a2                	ld	s1,40(sp)
    80002b9c:	6a42                	ld	s4,16(sp)
    80002b9e:	b7cd                	j	80002b80 <sys_sleep2+0x78>

0000000080002ba0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ba0:	7179                	addi	sp,sp,-48
    80002ba2:	f406                	sd	ra,40(sp)
    80002ba4:	f022                	sd	s0,32(sp)
    80002ba6:	ec26                	sd	s1,24(sp)
    80002ba8:	e84a                	sd	s2,16(sp)
    80002baa:	e44e                	sd	s3,8(sp)
    80002bac:	e052                	sd	s4,0(sp)
    80002bae:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002bb0:	00005597          	auipc	a1,0x5
    80002bb4:	80058593          	addi	a1,a1,-2048 # 800073b0 <etext+0x3b0>
    80002bb8:	00015517          	auipc	a0,0x15
    80002bbc:	62850513          	addi	a0,a0,1576 # 800181e0 <bcache>
    80002bc0:	f8ffd0ef          	jal	80000b4e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002bc4:	0001d797          	auipc	a5,0x1d
    80002bc8:	61c78793          	addi	a5,a5,1564 # 800201e0 <bcache+0x8000>
    80002bcc:	0001e717          	auipc	a4,0x1e
    80002bd0:	87c70713          	addi	a4,a4,-1924 # 80020448 <bcache+0x8268>
    80002bd4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002bd8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002bdc:	00015497          	auipc	s1,0x15
    80002be0:	61c48493          	addi	s1,s1,1564 # 800181f8 <bcache+0x18>
    b->next = bcache.head.next;
    80002be4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002be6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002be8:	00004a17          	auipc	s4,0x4
    80002bec:	7d0a0a13          	addi	s4,s4,2000 # 800073b8 <etext+0x3b8>
    b->next = bcache.head.next;
    80002bf0:	2b893783          	ld	a5,696(s2)
    80002bf4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002bf6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002bfa:	85d2                	mv	a1,s4
    80002bfc:	01048513          	addi	a0,s1,16
    80002c00:	322010ef          	jal	80003f22 <initsleeplock>
    bcache.head.next->prev = b;
    80002c04:	2b893783          	ld	a5,696(s2)
    80002c08:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002c0a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c0e:	45848493          	addi	s1,s1,1112
    80002c12:	fd349fe3          	bne	s1,s3,80002bf0 <binit+0x50>
  }
}
    80002c16:	70a2                	ld	ra,40(sp)
    80002c18:	7402                	ld	s0,32(sp)
    80002c1a:	64e2                	ld	s1,24(sp)
    80002c1c:	6942                	ld	s2,16(sp)
    80002c1e:	69a2                	ld	s3,8(sp)
    80002c20:	6a02                	ld	s4,0(sp)
    80002c22:	6145                	addi	sp,sp,48
    80002c24:	8082                	ret

0000000080002c26 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002c26:	7179                	addi	sp,sp,-48
    80002c28:	f406                	sd	ra,40(sp)
    80002c2a:	f022                	sd	s0,32(sp)
    80002c2c:	ec26                	sd	s1,24(sp)
    80002c2e:	e84a                	sd	s2,16(sp)
    80002c30:	e44e                	sd	s3,8(sp)
    80002c32:	1800                	addi	s0,sp,48
    80002c34:	892a                	mv	s2,a0
    80002c36:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002c38:	00015517          	auipc	a0,0x15
    80002c3c:	5a850513          	addi	a0,a0,1448 # 800181e0 <bcache>
    80002c40:	f8ffd0ef          	jal	80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002c44:	0001e497          	auipc	s1,0x1e
    80002c48:	8544b483          	ld	s1,-1964(s1) # 80020498 <bcache+0x82b8>
    80002c4c:	0001d797          	auipc	a5,0x1d
    80002c50:	7fc78793          	addi	a5,a5,2044 # 80020448 <bcache+0x8268>
    80002c54:	02f48b63          	beq	s1,a5,80002c8a <bread+0x64>
    80002c58:	873e                	mv	a4,a5
    80002c5a:	a021                	j	80002c62 <bread+0x3c>
    80002c5c:	68a4                	ld	s1,80(s1)
    80002c5e:	02e48663          	beq	s1,a4,80002c8a <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002c62:	449c                	lw	a5,8(s1)
    80002c64:	ff279ce3          	bne	a5,s2,80002c5c <bread+0x36>
    80002c68:	44dc                	lw	a5,12(s1)
    80002c6a:	ff3799e3          	bne	a5,s3,80002c5c <bread+0x36>
      b->refcnt++;
    80002c6e:	40bc                	lw	a5,64(s1)
    80002c70:	2785                	addiw	a5,a5,1
    80002c72:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c74:	00015517          	auipc	a0,0x15
    80002c78:	56c50513          	addi	a0,a0,1388 # 800181e0 <bcache>
    80002c7c:	febfd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002c80:	01048513          	addi	a0,s1,16
    80002c84:	2d4010ef          	jal	80003f58 <acquiresleep>
      return b;
    80002c88:	a889                	j	80002cda <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c8a:	0001e497          	auipc	s1,0x1e
    80002c8e:	8064b483          	ld	s1,-2042(s1) # 80020490 <bcache+0x82b0>
    80002c92:	0001d797          	auipc	a5,0x1d
    80002c96:	7b678793          	addi	a5,a5,1974 # 80020448 <bcache+0x8268>
    80002c9a:	00f48863          	beq	s1,a5,80002caa <bread+0x84>
    80002c9e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002ca0:	40bc                	lw	a5,64(s1)
    80002ca2:	cb91                	beqz	a5,80002cb6 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ca4:	64a4                	ld	s1,72(s1)
    80002ca6:	fee49de3          	bne	s1,a4,80002ca0 <bread+0x7a>
  panic("bget: no buffers");
    80002caa:	00004517          	auipc	a0,0x4
    80002cae:	71650513          	addi	a0,a0,1814 # 800073c0 <etext+0x3c0>
    80002cb2:	b2ffd0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80002cb6:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002cba:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002cbe:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002cc2:	4785                	li	a5,1
    80002cc4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002cc6:	00015517          	auipc	a0,0x15
    80002cca:	51a50513          	addi	a0,a0,1306 # 800181e0 <bcache>
    80002cce:	f99fd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002cd2:	01048513          	addi	a0,s1,16
    80002cd6:	282010ef          	jal	80003f58 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002cda:	409c                	lw	a5,0(s1)
    80002cdc:	cb89                	beqz	a5,80002cee <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002cde:	8526                	mv	a0,s1
    80002ce0:	70a2                	ld	ra,40(sp)
    80002ce2:	7402                	ld	s0,32(sp)
    80002ce4:	64e2                	ld	s1,24(sp)
    80002ce6:	6942                	ld	s2,16(sp)
    80002ce8:	69a2                	ld	s3,8(sp)
    80002cea:	6145                	addi	sp,sp,48
    80002cec:	8082                	ret
    virtio_disk_rw(b, 0);
    80002cee:	4581                	li	a1,0
    80002cf0:	8526                	mv	a0,s1
    80002cf2:	2cf020ef          	jal	800057c0 <virtio_disk_rw>
    b->valid = 1;
    80002cf6:	4785                	li	a5,1
    80002cf8:	c09c                	sw	a5,0(s1)
  return b;
    80002cfa:	b7d5                	j	80002cde <bread+0xb8>

0000000080002cfc <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002cfc:	1101                	addi	sp,sp,-32
    80002cfe:	ec06                	sd	ra,24(sp)
    80002d00:	e822                	sd	s0,16(sp)
    80002d02:	e426                	sd	s1,8(sp)
    80002d04:	1000                	addi	s0,sp,32
    80002d06:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002d08:	0541                	addi	a0,a0,16
    80002d0a:	2cc010ef          	jal	80003fd6 <holdingsleep>
    80002d0e:	c911                	beqz	a0,80002d22 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002d10:	4585                	li	a1,1
    80002d12:	8526                	mv	a0,s1
    80002d14:	2ad020ef          	jal	800057c0 <virtio_disk_rw>
}
    80002d18:	60e2                	ld	ra,24(sp)
    80002d1a:	6442                	ld	s0,16(sp)
    80002d1c:	64a2                	ld	s1,8(sp)
    80002d1e:	6105                	addi	sp,sp,32
    80002d20:	8082                	ret
    panic("bwrite");
    80002d22:	00004517          	auipc	a0,0x4
    80002d26:	6b650513          	addi	a0,a0,1718 # 800073d8 <etext+0x3d8>
    80002d2a:	ab7fd0ef          	jal	800007e0 <panic>

0000000080002d2e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002d2e:	1101                	addi	sp,sp,-32
    80002d30:	ec06                	sd	ra,24(sp)
    80002d32:	e822                	sd	s0,16(sp)
    80002d34:	e426                	sd	s1,8(sp)
    80002d36:	e04a                	sd	s2,0(sp)
    80002d38:	1000                	addi	s0,sp,32
    80002d3a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002d3c:	01050913          	addi	s2,a0,16
    80002d40:	854a                	mv	a0,s2
    80002d42:	294010ef          	jal	80003fd6 <holdingsleep>
    80002d46:	c135                	beqz	a0,80002daa <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002d48:	854a                	mv	a0,s2
    80002d4a:	254010ef          	jal	80003f9e <releasesleep>

  acquire(&bcache.lock);
    80002d4e:	00015517          	auipc	a0,0x15
    80002d52:	49250513          	addi	a0,a0,1170 # 800181e0 <bcache>
    80002d56:	e79fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002d5a:	40bc                	lw	a5,64(s1)
    80002d5c:	37fd                	addiw	a5,a5,-1
    80002d5e:	0007871b          	sext.w	a4,a5
    80002d62:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002d64:	e71d                	bnez	a4,80002d92 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002d66:	68b8                	ld	a4,80(s1)
    80002d68:	64bc                	ld	a5,72(s1)
    80002d6a:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002d6c:	68b8                	ld	a4,80(s1)
    80002d6e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d70:	0001d797          	auipc	a5,0x1d
    80002d74:	47078793          	addi	a5,a5,1136 # 800201e0 <bcache+0x8000>
    80002d78:	2b87b703          	ld	a4,696(a5)
    80002d7c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d7e:	0001d717          	auipc	a4,0x1d
    80002d82:	6ca70713          	addi	a4,a4,1738 # 80020448 <bcache+0x8268>
    80002d86:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d88:	2b87b703          	ld	a4,696(a5)
    80002d8c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d8e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002d92:	00015517          	auipc	a0,0x15
    80002d96:	44e50513          	addi	a0,a0,1102 # 800181e0 <bcache>
    80002d9a:	ecdfd0ef          	jal	80000c66 <release>
}
    80002d9e:	60e2                	ld	ra,24(sp)
    80002da0:	6442                	ld	s0,16(sp)
    80002da2:	64a2                	ld	s1,8(sp)
    80002da4:	6902                	ld	s2,0(sp)
    80002da6:	6105                	addi	sp,sp,32
    80002da8:	8082                	ret
    panic("brelse");
    80002daa:	00004517          	auipc	a0,0x4
    80002dae:	63650513          	addi	a0,a0,1590 # 800073e0 <etext+0x3e0>
    80002db2:	a2ffd0ef          	jal	800007e0 <panic>

0000000080002db6 <bpin>:

void
bpin(struct buf *b) {
    80002db6:	1101                	addi	sp,sp,-32
    80002db8:	ec06                	sd	ra,24(sp)
    80002dba:	e822                	sd	s0,16(sp)
    80002dbc:	e426                	sd	s1,8(sp)
    80002dbe:	1000                	addi	s0,sp,32
    80002dc0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002dc2:	00015517          	auipc	a0,0x15
    80002dc6:	41e50513          	addi	a0,a0,1054 # 800181e0 <bcache>
    80002dca:	e05fd0ef          	jal	80000bce <acquire>
  b->refcnt++;
    80002dce:	40bc                	lw	a5,64(s1)
    80002dd0:	2785                	addiw	a5,a5,1
    80002dd2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002dd4:	00015517          	auipc	a0,0x15
    80002dd8:	40c50513          	addi	a0,a0,1036 # 800181e0 <bcache>
    80002ddc:	e8bfd0ef          	jal	80000c66 <release>
}
    80002de0:	60e2                	ld	ra,24(sp)
    80002de2:	6442                	ld	s0,16(sp)
    80002de4:	64a2                	ld	s1,8(sp)
    80002de6:	6105                	addi	sp,sp,32
    80002de8:	8082                	ret

0000000080002dea <bunpin>:

void
bunpin(struct buf *b) {
    80002dea:	1101                	addi	sp,sp,-32
    80002dec:	ec06                	sd	ra,24(sp)
    80002dee:	e822                	sd	s0,16(sp)
    80002df0:	e426                	sd	s1,8(sp)
    80002df2:	1000                	addi	s0,sp,32
    80002df4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002df6:	00015517          	auipc	a0,0x15
    80002dfa:	3ea50513          	addi	a0,a0,1002 # 800181e0 <bcache>
    80002dfe:	dd1fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002e02:	40bc                	lw	a5,64(s1)
    80002e04:	37fd                	addiw	a5,a5,-1
    80002e06:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e08:	00015517          	auipc	a0,0x15
    80002e0c:	3d850513          	addi	a0,a0,984 # 800181e0 <bcache>
    80002e10:	e57fd0ef          	jal	80000c66 <release>
}
    80002e14:	60e2                	ld	ra,24(sp)
    80002e16:	6442                	ld	s0,16(sp)
    80002e18:	64a2                	ld	s1,8(sp)
    80002e1a:	6105                	addi	sp,sp,32
    80002e1c:	8082                	ret

0000000080002e1e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002e1e:	1101                	addi	sp,sp,-32
    80002e20:	ec06                	sd	ra,24(sp)
    80002e22:	e822                	sd	s0,16(sp)
    80002e24:	e426                	sd	s1,8(sp)
    80002e26:	e04a                	sd	s2,0(sp)
    80002e28:	1000                	addi	s0,sp,32
    80002e2a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002e2c:	00d5d59b          	srliw	a1,a1,0xd
    80002e30:	0001e797          	auipc	a5,0x1e
    80002e34:	a8c7a783          	lw	a5,-1396(a5) # 800208bc <sb+0x1c>
    80002e38:	9dbd                	addw	a1,a1,a5
    80002e3a:	dedff0ef          	jal	80002c26 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002e3e:	0074f713          	andi	a4,s1,7
    80002e42:	4785                	li	a5,1
    80002e44:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002e48:	14ce                	slli	s1,s1,0x33
    80002e4a:	90d9                	srli	s1,s1,0x36
    80002e4c:	00950733          	add	a4,a0,s1
    80002e50:	05874703          	lbu	a4,88(a4)
    80002e54:	00e7f6b3          	and	a3,a5,a4
    80002e58:	c29d                	beqz	a3,80002e7e <bfree+0x60>
    80002e5a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002e5c:	94aa                	add	s1,s1,a0
    80002e5e:	fff7c793          	not	a5,a5
    80002e62:	8f7d                	and	a4,a4,a5
    80002e64:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002e68:	7f9000ef          	jal	80003e60 <log_write>
  brelse(bp);
    80002e6c:	854a                	mv	a0,s2
    80002e6e:	ec1ff0ef          	jal	80002d2e <brelse>
}
    80002e72:	60e2                	ld	ra,24(sp)
    80002e74:	6442                	ld	s0,16(sp)
    80002e76:	64a2                	ld	s1,8(sp)
    80002e78:	6902                	ld	s2,0(sp)
    80002e7a:	6105                	addi	sp,sp,32
    80002e7c:	8082                	ret
    panic("freeing free block");
    80002e7e:	00004517          	auipc	a0,0x4
    80002e82:	56a50513          	addi	a0,a0,1386 # 800073e8 <etext+0x3e8>
    80002e86:	95bfd0ef          	jal	800007e0 <panic>

0000000080002e8a <balloc>:
{
    80002e8a:	711d                	addi	sp,sp,-96
    80002e8c:	ec86                	sd	ra,88(sp)
    80002e8e:	e8a2                	sd	s0,80(sp)
    80002e90:	e4a6                	sd	s1,72(sp)
    80002e92:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002e94:	0001e797          	auipc	a5,0x1e
    80002e98:	a107a783          	lw	a5,-1520(a5) # 800208a4 <sb+0x4>
    80002e9c:	0e078f63          	beqz	a5,80002f9a <balloc+0x110>
    80002ea0:	e0ca                	sd	s2,64(sp)
    80002ea2:	fc4e                	sd	s3,56(sp)
    80002ea4:	f852                	sd	s4,48(sp)
    80002ea6:	f456                	sd	s5,40(sp)
    80002ea8:	f05a                	sd	s6,32(sp)
    80002eaa:	ec5e                	sd	s7,24(sp)
    80002eac:	e862                	sd	s8,16(sp)
    80002eae:	e466                	sd	s9,8(sp)
    80002eb0:	8baa                	mv	s7,a0
    80002eb2:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002eb4:	0001eb17          	auipc	s6,0x1e
    80002eb8:	9ecb0b13          	addi	s6,s6,-1556 # 800208a0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ebc:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002ebe:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ec0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002ec2:	6c89                	lui	s9,0x2
    80002ec4:	a0b5                	j	80002f30 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002ec6:	97ca                	add	a5,a5,s2
    80002ec8:	8e55                	or	a2,a2,a3
    80002eca:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002ece:	854a                	mv	a0,s2
    80002ed0:	791000ef          	jal	80003e60 <log_write>
        brelse(bp);
    80002ed4:	854a                	mv	a0,s2
    80002ed6:	e59ff0ef          	jal	80002d2e <brelse>
  bp = bread(dev, bno);
    80002eda:	85a6                	mv	a1,s1
    80002edc:	855e                	mv	a0,s7
    80002ede:	d49ff0ef          	jal	80002c26 <bread>
    80002ee2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002ee4:	40000613          	li	a2,1024
    80002ee8:	4581                	li	a1,0
    80002eea:	05850513          	addi	a0,a0,88
    80002eee:	db5fd0ef          	jal	80000ca2 <memset>
  log_write(bp);
    80002ef2:	854a                	mv	a0,s2
    80002ef4:	76d000ef          	jal	80003e60 <log_write>
  brelse(bp);
    80002ef8:	854a                	mv	a0,s2
    80002efa:	e35ff0ef          	jal	80002d2e <brelse>
}
    80002efe:	6906                	ld	s2,64(sp)
    80002f00:	79e2                	ld	s3,56(sp)
    80002f02:	7a42                	ld	s4,48(sp)
    80002f04:	7aa2                	ld	s5,40(sp)
    80002f06:	7b02                	ld	s6,32(sp)
    80002f08:	6be2                	ld	s7,24(sp)
    80002f0a:	6c42                	ld	s8,16(sp)
    80002f0c:	6ca2                	ld	s9,8(sp)
}
    80002f0e:	8526                	mv	a0,s1
    80002f10:	60e6                	ld	ra,88(sp)
    80002f12:	6446                	ld	s0,80(sp)
    80002f14:	64a6                	ld	s1,72(sp)
    80002f16:	6125                	addi	sp,sp,96
    80002f18:	8082                	ret
    brelse(bp);
    80002f1a:	854a                	mv	a0,s2
    80002f1c:	e13ff0ef          	jal	80002d2e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002f20:	015c87bb          	addw	a5,s9,s5
    80002f24:	00078a9b          	sext.w	s5,a5
    80002f28:	004b2703          	lw	a4,4(s6)
    80002f2c:	04eaff63          	bgeu	s5,a4,80002f8a <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002f30:	41fad79b          	sraiw	a5,s5,0x1f
    80002f34:	0137d79b          	srliw	a5,a5,0x13
    80002f38:	015787bb          	addw	a5,a5,s5
    80002f3c:	40d7d79b          	sraiw	a5,a5,0xd
    80002f40:	01cb2583          	lw	a1,28(s6)
    80002f44:	9dbd                	addw	a1,a1,a5
    80002f46:	855e                	mv	a0,s7
    80002f48:	cdfff0ef          	jal	80002c26 <bread>
    80002f4c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f4e:	004b2503          	lw	a0,4(s6)
    80002f52:	000a849b          	sext.w	s1,s5
    80002f56:	8762                	mv	a4,s8
    80002f58:	fca4f1e3          	bgeu	s1,a0,80002f1a <balloc+0x90>
      m = 1 << (bi % 8);
    80002f5c:	00777693          	andi	a3,a4,7
    80002f60:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002f64:	41f7579b          	sraiw	a5,a4,0x1f
    80002f68:	01d7d79b          	srliw	a5,a5,0x1d
    80002f6c:	9fb9                	addw	a5,a5,a4
    80002f6e:	4037d79b          	sraiw	a5,a5,0x3
    80002f72:	00f90633          	add	a2,s2,a5
    80002f76:	05864603          	lbu	a2,88(a2)
    80002f7a:	00c6f5b3          	and	a1,a3,a2
    80002f7e:	d5a1                	beqz	a1,80002ec6 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f80:	2705                	addiw	a4,a4,1
    80002f82:	2485                	addiw	s1,s1,1
    80002f84:	fd471ae3          	bne	a4,s4,80002f58 <balloc+0xce>
    80002f88:	bf49                	j	80002f1a <balloc+0x90>
    80002f8a:	6906                	ld	s2,64(sp)
    80002f8c:	79e2                	ld	s3,56(sp)
    80002f8e:	7a42                	ld	s4,48(sp)
    80002f90:	7aa2                	ld	s5,40(sp)
    80002f92:	7b02                	ld	s6,32(sp)
    80002f94:	6be2                	ld	s7,24(sp)
    80002f96:	6c42                	ld	s8,16(sp)
    80002f98:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002f9a:	00004517          	auipc	a0,0x4
    80002f9e:	46650513          	addi	a0,a0,1126 # 80007400 <etext+0x400>
    80002fa2:	d58fd0ef          	jal	800004fa <printf>
  return 0;
    80002fa6:	4481                	li	s1,0
    80002fa8:	b79d                	j	80002f0e <balloc+0x84>

0000000080002faa <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002faa:	7179                	addi	sp,sp,-48
    80002fac:	f406                	sd	ra,40(sp)
    80002fae:	f022                	sd	s0,32(sp)
    80002fb0:	ec26                	sd	s1,24(sp)
    80002fb2:	e84a                	sd	s2,16(sp)
    80002fb4:	e44e                	sd	s3,8(sp)
    80002fb6:	1800                	addi	s0,sp,48
    80002fb8:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002fba:	47ad                	li	a5,11
    80002fbc:	02b7e663          	bltu	a5,a1,80002fe8 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002fc0:	02059793          	slli	a5,a1,0x20
    80002fc4:	01e7d593          	srli	a1,a5,0x1e
    80002fc8:	00b504b3          	add	s1,a0,a1
    80002fcc:	0504a903          	lw	s2,80(s1)
    80002fd0:	06091a63          	bnez	s2,80003044 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002fd4:	4108                	lw	a0,0(a0)
    80002fd6:	eb5ff0ef          	jal	80002e8a <balloc>
    80002fda:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002fde:	06090363          	beqz	s2,80003044 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002fe2:	0524a823          	sw	s2,80(s1)
    80002fe6:	a8b9                	j	80003044 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002fe8:	ff45849b          	addiw	s1,a1,-12
    80002fec:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002ff0:	0ff00793          	li	a5,255
    80002ff4:	06e7ee63          	bltu	a5,a4,80003070 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002ff8:	08052903          	lw	s2,128(a0)
    80002ffc:	00091d63          	bnez	s2,80003016 <bmap+0x6c>
      addr = balloc(ip->dev);
    80003000:	4108                	lw	a0,0(a0)
    80003002:	e89ff0ef          	jal	80002e8a <balloc>
    80003006:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000300a:	02090d63          	beqz	s2,80003044 <bmap+0x9a>
    8000300e:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003010:	0929a023          	sw	s2,128(s3)
    80003014:	a011                	j	80003018 <bmap+0x6e>
    80003016:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003018:	85ca                	mv	a1,s2
    8000301a:	0009a503          	lw	a0,0(s3)
    8000301e:	c09ff0ef          	jal	80002c26 <bread>
    80003022:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003024:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003028:	02049713          	slli	a4,s1,0x20
    8000302c:	01e75593          	srli	a1,a4,0x1e
    80003030:	00b784b3          	add	s1,a5,a1
    80003034:	0004a903          	lw	s2,0(s1)
    80003038:	00090e63          	beqz	s2,80003054 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000303c:	8552                	mv	a0,s4
    8000303e:	cf1ff0ef          	jal	80002d2e <brelse>
    return addr;
    80003042:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003044:	854a                	mv	a0,s2
    80003046:	70a2                	ld	ra,40(sp)
    80003048:	7402                	ld	s0,32(sp)
    8000304a:	64e2                	ld	s1,24(sp)
    8000304c:	6942                	ld	s2,16(sp)
    8000304e:	69a2                	ld	s3,8(sp)
    80003050:	6145                	addi	sp,sp,48
    80003052:	8082                	ret
      addr = balloc(ip->dev);
    80003054:	0009a503          	lw	a0,0(s3)
    80003058:	e33ff0ef          	jal	80002e8a <balloc>
    8000305c:	0005091b          	sext.w	s2,a0
      if(addr){
    80003060:	fc090ee3          	beqz	s2,8000303c <bmap+0x92>
        a[bn] = addr;
    80003064:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003068:	8552                	mv	a0,s4
    8000306a:	5f7000ef          	jal	80003e60 <log_write>
    8000306e:	b7f9                	j	8000303c <bmap+0x92>
    80003070:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003072:	00004517          	auipc	a0,0x4
    80003076:	3a650513          	addi	a0,a0,934 # 80007418 <etext+0x418>
    8000307a:	f66fd0ef          	jal	800007e0 <panic>

000000008000307e <iget>:
{
    8000307e:	7179                	addi	sp,sp,-48
    80003080:	f406                	sd	ra,40(sp)
    80003082:	f022                	sd	s0,32(sp)
    80003084:	ec26                	sd	s1,24(sp)
    80003086:	e84a                	sd	s2,16(sp)
    80003088:	e44e                	sd	s3,8(sp)
    8000308a:	e052                	sd	s4,0(sp)
    8000308c:	1800                	addi	s0,sp,48
    8000308e:	89aa                	mv	s3,a0
    80003090:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003092:	0001e517          	auipc	a0,0x1e
    80003096:	82e50513          	addi	a0,a0,-2002 # 800208c0 <itable>
    8000309a:	b35fd0ef          	jal	80000bce <acquire>
  empty = 0;
    8000309e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800030a0:	0001e497          	auipc	s1,0x1e
    800030a4:	83848493          	addi	s1,s1,-1992 # 800208d8 <itable+0x18>
    800030a8:	0001f697          	auipc	a3,0x1f
    800030ac:	2c068693          	addi	a3,a3,704 # 80022368 <log>
    800030b0:	a039                	j	800030be <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800030b2:	02090963          	beqz	s2,800030e4 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800030b6:	08848493          	addi	s1,s1,136
    800030ba:	02d48863          	beq	s1,a3,800030ea <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800030be:	449c                	lw	a5,8(s1)
    800030c0:	fef059e3          	blez	a5,800030b2 <iget+0x34>
    800030c4:	4098                	lw	a4,0(s1)
    800030c6:	ff3716e3          	bne	a4,s3,800030b2 <iget+0x34>
    800030ca:	40d8                	lw	a4,4(s1)
    800030cc:	ff4713e3          	bne	a4,s4,800030b2 <iget+0x34>
      ip->ref++;
    800030d0:	2785                	addiw	a5,a5,1
    800030d2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800030d4:	0001d517          	auipc	a0,0x1d
    800030d8:	7ec50513          	addi	a0,a0,2028 # 800208c0 <itable>
    800030dc:	b8bfd0ef          	jal	80000c66 <release>
      return ip;
    800030e0:	8926                	mv	s2,s1
    800030e2:	a02d                	j	8000310c <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800030e4:	fbe9                	bnez	a5,800030b6 <iget+0x38>
      empty = ip;
    800030e6:	8926                	mv	s2,s1
    800030e8:	b7f9                	j	800030b6 <iget+0x38>
  if(empty == 0)
    800030ea:	02090a63          	beqz	s2,8000311e <iget+0xa0>
  ip->dev = dev;
    800030ee:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800030f2:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800030f6:	4785                	li	a5,1
    800030f8:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800030fc:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003100:	0001d517          	auipc	a0,0x1d
    80003104:	7c050513          	addi	a0,a0,1984 # 800208c0 <itable>
    80003108:	b5ffd0ef          	jal	80000c66 <release>
}
    8000310c:	854a                	mv	a0,s2
    8000310e:	70a2                	ld	ra,40(sp)
    80003110:	7402                	ld	s0,32(sp)
    80003112:	64e2                	ld	s1,24(sp)
    80003114:	6942                	ld	s2,16(sp)
    80003116:	69a2                	ld	s3,8(sp)
    80003118:	6a02                	ld	s4,0(sp)
    8000311a:	6145                	addi	sp,sp,48
    8000311c:	8082                	ret
    panic("iget: no inodes");
    8000311e:	00004517          	auipc	a0,0x4
    80003122:	31250513          	addi	a0,a0,786 # 80007430 <etext+0x430>
    80003126:	ebafd0ef          	jal	800007e0 <panic>

000000008000312a <iinit>:
{
    8000312a:	7179                	addi	sp,sp,-48
    8000312c:	f406                	sd	ra,40(sp)
    8000312e:	f022                	sd	s0,32(sp)
    80003130:	ec26                	sd	s1,24(sp)
    80003132:	e84a                	sd	s2,16(sp)
    80003134:	e44e                	sd	s3,8(sp)
    80003136:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003138:	00004597          	auipc	a1,0x4
    8000313c:	30858593          	addi	a1,a1,776 # 80007440 <etext+0x440>
    80003140:	0001d517          	auipc	a0,0x1d
    80003144:	78050513          	addi	a0,a0,1920 # 800208c0 <itable>
    80003148:	a07fd0ef          	jal	80000b4e <initlock>
  for(i = 0; i < NINODE; i++) {
    8000314c:	0001d497          	auipc	s1,0x1d
    80003150:	79c48493          	addi	s1,s1,1948 # 800208e8 <itable+0x28>
    80003154:	0001f997          	auipc	s3,0x1f
    80003158:	22498993          	addi	s3,s3,548 # 80022378 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000315c:	00004917          	auipc	s2,0x4
    80003160:	2ec90913          	addi	s2,s2,748 # 80007448 <etext+0x448>
    80003164:	85ca                	mv	a1,s2
    80003166:	8526                	mv	a0,s1
    80003168:	5bb000ef          	jal	80003f22 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000316c:	08848493          	addi	s1,s1,136
    80003170:	ff349ae3          	bne	s1,s3,80003164 <iinit+0x3a>
}
    80003174:	70a2                	ld	ra,40(sp)
    80003176:	7402                	ld	s0,32(sp)
    80003178:	64e2                	ld	s1,24(sp)
    8000317a:	6942                	ld	s2,16(sp)
    8000317c:	69a2                	ld	s3,8(sp)
    8000317e:	6145                	addi	sp,sp,48
    80003180:	8082                	ret

0000000080003182 <ialloc>:
{
    80003182:	7139                	addi	sp,sp,-64
    80003184:	fc06                	sd	ra,56(sp)
    80003186:	f822                	sd	s0,48(sp)
    80003188:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000318a:	0001d717          	auipc	a4,0x1d
    8000318e:	72272703          	lw	a4,1826(a4) # 800208ac <sb+0xc>
    80003192:	4785                	li	a5,1
    80003194:	06e7f063          	bgeu	a5,a4,800031f4 <ialloc+0x72>
    80003198:	f426                	sd	s1,40(sp)
    8000319a:	f04a                	sd	s2,32(sp)
    8000319c:	ec4e                	sd	s3,24(sp)
    8000319e:	e852                	sd	s4,16(sp)
    800031a0:	e456                	sd	s5,8(sp)
    800031a2:	e05a                	sd	s6,0(sp)
    800031a4:	8aaa                	mv	s5,a0
    800031a6:	8b2e                	mv	s6,a1
    800031a8:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800031aa:	0001da17          	auipc	s4,0x1d
    800031ae:	6f6a0a13          	addi	s4,s4,1782 # 800208a0 <sb>
    800031b2:	00495593          	srli	a1,s2,0x4
    800031b6:	018a2783          	lw	a5,24(s4)
    800031ba:	9dbd                	addw	a1,a1,a5
    800031bc:	8556                	mv	a0,s5
    800031be:	a69ff0ef          	jal	80002c26 <bread>
    800031c2:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800031c4:	05850993          	addi	s3,a0,88
    800031c8:	00f97793          	andi	a5,s2,15
    800031cc:	079a                	slli	a5,a5,0x6
    800031ce:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800031d0:	00099783          	lh	a5,0(s3)
    800031d4:	cb9d                	beqz	a5,8000320a <ialloc+0x88>
    brelse(bp);
    800031d6:	b59ff0ef          	jal	80002d2e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800031da:	0905                	addi	s2,s2,1
    800031dc:	00ca2703          	lw	a4,12(s4)
    800031e0:	0009079b          	sext.w	a5,s2
    800031e4:	fce7e7e3          	bltu	a5,a4,800031b2 <ialloc+0x30>
    800031e8:	74a2                	ld	s1,40(sp)
    800031ea:	7902                	ld	s2,32(sp)
    800031ec:	69e2                	ld	s3,24(sp)
    800031ee:	6a42                	ld	s4,16(sp)
    800031f0:	6aa2                	ld	s5,8(sp)
    800031f2:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800031f4:	00004517          	auipc	a0,0x4
    800031f8:	25c50513          	addi	a0,a0,604 # 80007450 <etext+0x450>
    800031fc:	afefd0ef          	jal	800004fa <printf>
  return 0;
    80003200:	4501                	li	a0,0
}
    80003202:	70e2                	ld	ra,56(sp)
    80003204:	7442                	ld	s0,48(sp)
    80003206:	6121                	addi	sp,sp,64
    80003208:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000320a:	04000613          	li	a2,64
    8000320e:	4581                	li	a1,0
    80003210:	854e                	mv	a0,s3
    80003212:	a91fd0ef          	jal	80000ca2 <memset>
      dip->type = type;
    80003216:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000321a:	8526                	mv	a0,s1
    8000321c:	445000ef          	jal	80003e60 <log_write>
      brelse(bp);
    80003220:	8526                	mv	a0,s1
    80003222:	b0dff0ef          	jal	80002d2e <brelse>
      return iget(dev, inum);
    80003226:	0009059b          	sext.w	a1,s2
    8000322a:	8556                	mv	a0,s5
    8000322c:	e53ff0ef          	jal	8000307e <iget>
    80003230:	74a2                	ld	s1,40(sp)
    80003232:	7902                	ld	s2,32(sp)
    80003234:	69e2                	ld	s3,24(sp)
    80003236:	6a42                	ld	s4,16(sp)
    80003238:	6aa2                	ld	s5,8(sp)
    8000323a:	6b02                	ld	s6,0(sp)
    8000323c:	b7d9                	j	80003202 <ialloc+0x80>

000000008000323e <iupdate>:
{
    8000323e:	1101                	addi	sp,sp,-32
    80003240:	ec06                	sd	ra,24(sp)
    80003242:	e822                	sd	s0,16(sp)
    80003244:	e426                	sd	s1,8(sp)
    80003246:	e04a                	sd	s2,0(sp)
    80003248:	1000                	addi	s0,sp,32
    8000324a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000324c:	415c                	lw	a5,4(a0)
    8000324e:	0047d79b          	srliw	a5,a5,0x4
    80003252:	0001d597          	auipc	a1,0x1d
    80003256:	6665a583          	lw	a1,1638(a1) # 800208b8 <sb+0x18>
    8000325a:	9dbd                	addw	a1,a1,a5
    8000325c:	4108                	lw	a0,0(a0)
    8000325e:	9c9ff0ef          	jal	80002c26 <bread>
    80003262:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003264:	05850793          	addi	a5,a0,88
    80003268:	40d8                	lw	a4,4(s1)
    8000326a:	8b3d                	andi	a4,a4,15
    8000326c:	071a                	slli	a4,a4,0x6
    8000326e:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003270:	04449703          	lh	a4,68(s1)
    80003274:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003278:	04649703          	lh	a4,70(s1)
    8000327c:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003280:	04849703          	lh	a4,72(s1)
    80003284:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003288:	04a49703          	lh	a4,74(s1)
    8000328c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003290:	44f8                	lw	a4,76(s1)
    80003292:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003294:	03400613          	li	a2,52
    80003298:	05048593          	addi	a1,s1,80
    8000329c:	00c78513          	addi	a0,a5,12
    800032a0:	a5ffd0ef          	jal	80000cfe <memmove>
  log_write(bp);
    800032a4:	854a                	mv	a0,s2
    800032a6:	3bb000ef          	jal	80003e60 <log_write>
  brelse(bp);
    800032aa:	854a                	mv	a0,s2
    800032ac:	a83ff0ef          	jal	80002d2e <brelse>
}
    800032b0:	60e2                	ld	ra,24(sp)
    800032b2:	6442                	ld	s0,16(sp)
    800032b4:	64a2                	ld	s1,8(sp)
    800032b6:	6902                	ld	s2,0(sp)
    800032b8:	6105                	addi	sp,sp,32
    800032ba:	8082                	ret

00000000800032bc <idup>:
{
    800032bc:	1101                	addi	sp,sp,-32
    800032be:	ec06                	sd	ra,24(sp)
    800032c0:	e822                	sd	s0,16(sp)
    800032c2:	e426                	sd	s1,8(sp)
    800032c4:	1000                	addi	s0,sp,32
    800032c6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800032c8:	0001d517          	auipc	a0,0x1d
    800032cc:	5f850513          	addi	a0,a0,1528 # 800208c0 <itable>
    800032d0:	8fffd0ef          	jal	80000bce <acquire>
  ip->ref++;
    800032d4:	449c                	lw	a5,8(s1)
    800032d6:	2785                	addiw	a5,a5,1
    800032d8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800032da:	0001d517          	auipc	a0,0x1d
    800032de:	5e650513          	addi	a0,a0,1510 # 800208c0 <itable>
    800032e2:	985fd0ef          	jal	80000c66 <release>
}
    800032e6:	8526                	mv	a0,s1
    800032e8:	60e2                	ld	ra,24(sp)
    800032ea:	6442                	ld	s0,16(sp)
    800032ec:	64a2                	ld	s1,8(sp)
    800032ee:	6105                	addi	sp,sp,32
    800032f0:	8082                	ret

00000000800032f2 <ilock>:
{
    800032f2:	1101                	addi	sp,sp,-32
    800032f4:	ec06                	sd	ra,24(sp)
    800032f6:	e822                	sd	s0,16(sp)
    800032f8:	e426                	sd	s1,8(sp)
    800032fa:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800032fc:	cd19                	beqz	a0,8000331a <ilock+0x28>
    800032fe:	84aa                	mv	s1,a0
    80003300:	451c                	lw	a5,8(a0)
    80003302:	00f05c63          	blez	a5,8000331a <ilock+0x28>
  acquiresleep(&ip->lock);
    80003306:	0541                	addi	a0,a0,16
    80003308:	451000ef          	jal	80003f58 <acquiresleep>
  if(ip->valid == 0){
    8000330c:	40bc                	lw	a5,64(s1)
    8000330e:	cf89                	beqz	a5,80003328 <ilock+0x36>
}
    80003310:	60e2                	ld	ra,24(sp)
    80003312:	6442                	ld	s0,16(sp)
    80003314:	64a2                	ld	s1,8(sp)
    80003316:	6105                	addi	sp,sp,32
    80003318:	8082                	ret
    8000331a:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000331c:	00004517          	auipc	a0,0x4
    80003320:	14c50513          	addi	a0,a0,332 # 80007468 <etext+0x468>
    80003324:	cbcfd0ef          	jal	800007e0 <panic>
    80003328:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000332a:	40dc                	lw	a5,4(s1)
    8000332c:	0047d79b          	srliw	a5,a5,0x4
    80003330:	0001d597          	auipc	a1,0x1d
    80003334:	5885a583          	lw	a1,1416(a1) # 800208b8 <sb+0x18>
    80003338:	9dbd                	addw	a1,a1,a5
    8000333a:	4088                	lw	a0,0(s1)
    8000333c:	8ebff0ef          	jal	80002c26 <bread>
    80003340:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003342:	05850593          	addi	a1,a0,88
    80003346:	40dc                	lw	a5,4(s1)
    80003348:	8bbd                	andi	a5,a5,15
    8000334a:	079a                	slli	a5,a5,0x6
    8000334c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000334e:	00059783          	lh	a5,0(a1)
    80003352:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003356:	00259783          	lh	a5,2(a1)
    8000335a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000335e:	00459783          	lh	a5,4(a1)
    80003362:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003366:	00659783          	lh	a5,6(a1)
    8000336a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000336e:	459c                	lw	a5,8(a1)
    80003370:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003372:	03400613          	li	a2,52
    80003376:	05b1                	addi	a1,a1,12
    80003378:	05048513          	addi	a0,s1,80
    8000337c:	983fd0ef          	jal	80000cfe <memmove>
    brelse(bp);
    80003380:	854a                	mv	a0,s2
    80003382:	9adff0ef          	jal	80002d2e <brelse>
    ip->valid = 1;
    80003386:	4785                	li	a5,1
    80003388:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000338a:	04449783          	lh	a5,68(s1)
    8000338e:	c399                	beqz	a5,80003394 <ilock+0xa2>
    80003390:	6902                	ld	s2,0(sp)
    80003392:	bfbd                	j	80003310 <ilock+0x1e>
      panic("ilock: no type");
    80003394:	00004517          	auipc	a0,0x4
    80003398:	0dc50513          	addi	a0,a0,220 # 80007470 <etext+0x470>
    8000339c:	c44fd0ef          	jal	800007e0 <panic>

00000000800033a0 <iunlock>:
{
    800033a0:	1101                	addi	sp,sp,-32
    800033a2:	ec06                	sd	ra,24(sp)
    800033a4:	e822                	sd	s0,16(sp)
    800033a6:	e426                	sd	s1,8(sp)
    800033a8:	e04a                	sd	s2,0(sp)
    800033aa:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800033ac:	c505                	beqz	a0,800033d4 <iunlock+0x34>
    800033ae:	84aa                	mv	s1,a0
    800033b0:	01050913          	addi	s2,a0,16
    800033b4:	854a                	mv	a0,s2
    800033b6:	421000ef          	jal	80003fd6 <holdingsleep>
    800033ba:	cd09                	beqz	a0,800033d4 <iunlock+0x34>
    800033bc:	449c                	lw	a5,8(s1)
    800033be:	00f05b63          	blez	a5,800033d4 <iunlock+0x34>
  releasesleep(&ip->lock);
    800033c2:	854a                	mv	a0,s2
    800033c4:	3db000ef          	jal	80003f9e <releasesleep>
}
    800033c8:	60e2                	ld	ra,24(sp)
    800033ca:	6442                	ld	s0,16(sp)
    800033cc:	64a2                	ld	s1,8(sp)
    800033ce:	6902                	ld	s2,0(sp)
    800033d0:	6105                	addi	sp,sp,32
    800033d2:	8082                	ret
    panic("iunlock");
    800033d4:	00004517          	auipc	a0,0x4
    800033d8:	0ac50513          	addi	a0,a0,172 # 80007480 <etext+0x480>
    800033dc:	c04fd0ef          	jal	800007e0 <panic>

00000000800033e0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800033e0:	7179                	addi	sp,sp,-48
    800033e2:	f406                	sd	ra,40(sp)
    800033e4:	f022                	sd	s0,32(sp)
    800033e6:	ec26                	sd	s1,24(sp)
    800033e8:	e84a                	sd	s2,16(sp)
    800033ea:	e44e                	sd	s3,8(sp)
    800033ec:	1800                	addi	s0,sp,48
    800033ee:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800033f0:	05050493          	addi	s1,a0,80
    800033f4:	08050913          	addi	s2,a0,128
    800033f8:	a021                	j	80003400 <itrunc+0x20>
    800033fa:	0491                	addi	s1,s1,4
    800033fc:	01248b63          	beq	s1,s2,80003412 <itrunc+0x32>
    if(ip->addrs[i]){
    80003400:	408c                	lw	a1,0(s1)
    80003402:	dde5                	beqz	a1,800033fa <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003404:	0009a503          	lw	a0,0(s3)
    80003408:	a17ff0ef          	jal	80002e1e <bfree>
      ip->addrs[i] = 0;
    8000340c:	0004a023          	sw	zero,0(s1)
    80003410:	b7ed                	j	800033fa <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003412:	0809a583          	lw	a1,128(s3)
    80003416:	ed89                	bnez	a1,80003430 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003418:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000341c:	854e                	mv	a0,s3
    8000341e:	e21ff0ef          	jal	8000323e <iupdate>
}
    80003422:	70a2                	ld	ra,40(sp)
    80003424:	7402                	ld	s0,32(sp)
    80003426:	64e2                	ld	s1,24(sp)
    80003428:	6942                	ld	s2,16(sp)
    8000342a:	69a2                	ld	s3,8(sp)
    8000342c:	6145                	addi	sp,sp,48
    8000342e:	8082                	ret
    80003430:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003432:	0009a503          	lw	a0,0(s3)
    80003436:	ff0ff0ef          	jal	80002c26 <bread>
    8000343a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000343c:	05850493          	addi	s1,a0,88
    80003440:	45850913          	addi	s2,a0,1112
    80003444:	a021                	j	8000344c <itrunc+0x6c>
    80003446:	0491                	addi	s1,s1,4
    80003448:	01248963          	beq	s1,s2,8000345a <itrunc+0x7a>
      if(a[j])
    8000344c:	408c                	lw	a1,0(s1)
    8000344e:	dde5                	beqz	a1,80003446 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003450:	0009a503          	lw	a0,0(s3)
    80003454:	9cbff0ef          	jal	80002e1e <bfree>
    80003458:	b7fd                	j	80003446 <itrunc+0x66>
    brelse(bp);
    8000345a:	8552                	mv	a0,s4
    8000345c:	8d3ff0ef          	jal	80002d2e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003460:	0809a583          	lw	a1,128(s3)
    80003464:	0009a503          	lw	a0,0(s3)
    80003468:	9b7ff0ef          	jal	80002e1e <bfree>
    ip->addrs[NDIRECT] = 0;
    8000346c:	0809a023          	sw	zero,128(s3)
    80003470:	6a02                	ld	s4,0(sp)
    80003472:	b75d                	j	80003418 <itrunc+0x38>

0000000080003474 <iput>:
{
    80003474:	1101                	addi	sp,sp,-32
    80003476:	ec06                	sd	ra,24(sp)
    80003478:	e822                	sd	s0,16(sp)
    8000347a:	e426                	sd	s1,8(sp)
    8000347c:	1000                	addi	s0,sp,32
    8000347e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003480:	0001d517          	auipc	a0,0x1d
    80003484:	44050513          	addi	a0,a0,1088 # 800208c0 <itable>
    80003488:	f46fd0ef          	jal	80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000348c:	4498                	lw	a4,8(s1)
    8000348e:	4785                	li	a5,1
    80003490:	02f70063          	beq	a4,a5,800034b0 <iput+0x3c>
  ip->ref--;
    80003494:	449c                	lw	a5,8(s1)
    80003496:	37fd                	addiw	a5,a5,-1
    80003498:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000349a:	0001d517          	auipc	a0,0x1d
    8000349e:	42650513          	addi	a0,a0,1062 # 800208c0 <itable>
    800034a2:	fc4fd0ef          	jal	80000c66 <release>
}
    800034a6:	60e2                	ld	ra,24(sp)
    800034a8:	6442                	ld	s0,16(sp)
    800034aa:	64a2                	ld	s1,8(sp)
    800034ac:	6105                	addi	sp,sp,32
    800034ae:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800034b0:	40bc                	lw	a5,64(s1)
    800034b2:	d3ed                	beqz	a5,80003494 <iput+0x20>
    800034b4:	04a49783          	lh	a5,74(s1)
    800034b8:	fff1                	bnez	a5,80003494 <iput+0x20>
    800034ba:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800034bc:	01048913          	addi	s2,s1,16
    800034c0:	854a                	mv	a0,s2
    800034c2:	297000ef          	jal	80003f58 <acquiresleep>
    release(&itable.lock);
    800034c6:	0001d517          	auipc	a0,0x1d
    800034ca:	3fa50513          	addi	a0,a0,1018 # 800208c0 <itable>
    800034ce:	f98fd0ef          	jal	80000c66 <release>
    itrunc(ip);
    800034d2:	8526                	mv	a0,s1
    800034d4:	f0dff0ef          	jal	800033e0 <itrunc>
    ip->type = 0;
    800034d8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800034dc:	8526                	mv	a0,s1
    800034de:	d61ff0ef          	jal	8000323e <iupdate>
    ip->valid = 0;
    800034e2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800034e6:	854a                	mv	a0,s2
    800034e8:	2b7000ef          	jal	80003f9e <releasesleep>
    acquire(&itable.lock);
    800034ec:	0001d517          	auipc	a0,0x1d
    800034f0:	3d450513          	addi	a0,a0,980 # 800208c0 <itable>
    800034f4:	edafd0ef          	jal	80000bce <acquire>
    800034f8:	6902                	ld	s2,0(sp)
    800034fa:	bf69                	j	80003494 <iput+0x20>

00000000800034fc <iunlockput>:
{
    800034fc:	1101                	addi	sp,sp,-32
    800034fe:	ec06                	sd	ra,24(sp)
    80003500:	e822                	sd	s0,16(sp)
    80003502:	e426                	sd	s1,8(sp)
    80003504:	1000                	addi	s0,sp,32
    80003506:	84aa                	mv	s1,a0
  iunlock(ip);
    80003508:	e99ff0ef          	jal	800033a0 <iunlock>
  iput(ip);
    8000350c:	8526                	mv	a0,s1
    8000350e:	f67ff0ef          	jal	80003474 <iput>
}
    80003512:	60e2                	ld	ra,24(sp)
    80003514:	6442                	ld	s0,16(sp)
    80003516:	64a2                	ld	s1,8(sp)
    80003518:	6105                	addi	sp,sp,32
    8000351a:	8082                	ret

000000008000351c <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000351c:	0001d717          	auipc	a4,0x1d
    80003520:	39072703          	lw	a4,912(a4) # 800208ac <sb+0xc>
    80003524:	4785                	li	a5,1
    80003526:	0ae7ff63          	bgeu	a5,a4,800035e4 <ireclaim+0xc8>
{
    8000352a:	7139                	addi	sp,sp,-64
    8000352c:	fc06                	sd	ra,56(sp)
    8000352e:	f822                	sd	s0,48(sp)
    80003530:	f426                	sd	s1,40(sp)
    80003532:	f04a                	sd	s2,32(sp)
    80003534:	ec4e                	sd	s3,24(sp)
    80003536:	e852                	sd	s4,16(sp)
    80003538:	e456                	sd	s5,8(sp)
    8000353a:	e05a                	sd	s6,0(sp)
    8000353c:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000353e:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003540:	00050a1b          	sext.w	s4,a0
    80003544:	0001da97          	auipc	s5,0x1d
    80003548:	35ca8a93          	addi	s5,s5,860 # 800208a0 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    8000354c:	00004b17          	auipc	s6,0x4
    80003550:	f3cb0b13          	addi	s6,s6,-196 # 80007488 <etext+0x488>
    80003554:	a099                	j	8000359a <ireclaim+0x7e>
    80003556:	85ce                	mv	a1,s3
    80003558:	855a                	mv	a0,s6
    8000355a:	fa1fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    8000355e:	85ce                	mv	a1,s3
    80003560:	8552                	mv	a0,s4
    80003562:	b1dff0ef          	jal	8000307e <iget>
    80003566:	89aa                	mv	s3,a0
    brelse(bp);
    80003568:	854a                	mv	a0,s2
    8000356a:	fc4ff0ef          	jal	80002d2e <brelse>
    if (ip) {
    8000356e:	00098f63          	beqz	s3,8000358c <ireclaim+0x70>
      begin_op();
    80003572:	76a000ef          	jal	80003cdc <begin_op>
      ilock(ip);
    80003576:	854e                	mv	a0,s3
    80003578:	d7bff0ef          	jal	800032f2 <ilock>
      iunlock(ip);
    8000357c:	854e                	mv	a0,s3
    8000357e:	e23ff0ef          	jal	800033a0 <iunlock>
      iput(ip);
    80003582:	854e                	mv	a0,s3
    80003584:	ef1ff0ef          	jal	80003474 <iput>
      end_op();
    80003588:	7be000ef          	jal	80003d46 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000358c:	0485                	addi	s1,s1,1
    8000358e:	00caa703          	lw	a4,12(s5)
    80003592:	0004879b          	sext.w	a5,s1
    80003596:	02e7fd63          	bgeu	a5,a4,800035d0 <ireclaim+0xb4>
    8000359a:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000359e:	0044d593          	srli	a1,s1,0x4
    800035a2:	018aa783          	lw	a5,24(s5)
    800035a6:	9dbd                	addw	a1,a1,a5
    800035a8:	8552                	mv	a0,s4
    800035aa:	e7cff0ef          	jal	80002c26 <bread>
    800035ae:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800035b0:	05850793          	addi	a5,a0,88
    800035b4:	00f9f713          	andi	a4,s3,15
    800035b8:	071a                	slli	a4,a4,0x6
    800035ba:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800035bc:	00079703          	lh	a4,0(a5)
    800035c0:	c701                	beqz	a4,800035c8 <ireclaim+0xac>
    800035c2:	00679783          	lh	a5,6(a5)
    800035c6:	dbc1                	beqz	a5,80003556 <ireclaim+0x3a>
    brelse(bp);
    800035c8:	854a                	mv	a0,s2
    800035ca:	f64ff0ef          	jal	80002d2e <brelse>
    if (ip) {
    800035ce:	bf7d                	j	8000358c <ireclaim+0x70>
}
    800035d0:	70e2                	ld	ra,56(sp)
    800035d2:	7442                	ld	s0,48(sp)
    800035d4:	74a2                	ld	s1,40(sp)
    800035d6:	7902                	ld	s2,32(sp)
    800035d8:	69e2                	ld	s3,24(sp)
    800035da:	6a42                	ld	s4,16(sp)
    800035dc:	6aa2                	ld	s5,8(sp)
    800035de:	6b02                	ld	s6,0(sp)
    800035e0:	6121                	addi	sp,sp,64
    800035e2:	8082                	ret
    800035e4:	8082                	ret

00000000800035e6 <fsinit>:
fsinit(int dev) {
    800035e6:	7179                	addi	sp,sp,-48
    800035e8:	f406                	sd	ra,40(sp)
    800035ea:	f022                	sd	s0,32(sp)
    800035ec:	ec26                	sd	s1,24(sp)
    800035ee:	e84a                	sd	s2,16(sp)
    800035f0:	e44e                	sd	s3,8(sp)
    800035f2:	1800                	addi	s0,sp,48
    800035f4:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800035f6:	4585                	li	a1,1
    800035f8:	e2eff0ef          	jal	80002c26 <bread>
    800035fc:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800035fe:	0001d997          	auipc	s3,0x1d
    80003602:	2a298993          	addi	s3,s3,674 # 800208a0 <sb>
    80003606:	02000613          	li	a2,32
    8000360a:	05850593          	addi	a1,a0,88
    8000360e:	854e                	mv	a0,s3
    80003610:	eeefd0ef          	jal	80000cfe <memmove>
  brelse(bp);
    80003614:	854a                	mv	a0,s2
    80003616:	f18ff0ef          	jal	80002d2e <brelse>
  if(sb.magic != FSMAGIC)
    8000361a:	0009a703          	lw	a4,0(s3)
    8000361e:	102037b7          	lui	a5,0x10203
    80003622:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003626:	02f71363          	bne	a4,a5,8000364c <fsinit+0x66>
  initlog(dev, &sb);
    8000362a:	0001d597          	auipc	a1,0x1d
    8000362e:	27658593          	addi	a1,a1,630 # 800208a0 <sb>
    80003632:	8526                	mv	a0,s1
    80003634:	62a000ef          	jal	80003c5e <initlog>
  ireclaim(dev);
    80003638:	8526                	mv	a0,s1
    8000363a:	ee3ff0ef          	jal	8000351c <ireclaim>
}
    8000363e:	70a2                	ld	ra,40(sp)
    80003640:	7402                	ld	s0,32(sp)
    80003642:	64e2                	ld	s1,24(sp)
    80003644:	6942                	ld	s2,16(sp)
    80003646:	69a2                	ld	s3,8(sp)
    80003648:	6145                	addi	sp,sp,48
    8000364a:	8082                	ret
    panic("invalid file system");
    8000364c:	00004517          	auipc	a0,0x4
    80003650:	e5c50513          	addi	a0,a0,-420 # 800074a8 <etext+0x4a8>
    80003654:	98cfd0ef          	jal	800007e0 <panic>

0000000080003658 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003658:	1141                	addi	sp,sp,-16
    8000365a:	e422                	sd	s0,8(sp)
    8000365c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000365e:	411c                	lw	a5,0(a0)
    80003660:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003662:	415c                	lw	a5,4(a0)
    80003664:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003666:	04451783          	lh	a5,68(a0)
    8000366a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000366e:	04a51783          	lh	a5,74(a0)
    80003672:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003676:	04c56783          	lwu	a5,76(a0)
    8000367a:	e99c                	sd	a5,16(a1)
}
    8000367c:	6422                	ld	s0,8(sp)
    8000367e:	0141                	addi	sp,sp,16
    80003680:	8082                	ret

0000000080003682 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003682:	457c                	lw	a5,76(a0)
    80003684:	0ed7eb63          	bltu	a5,a3,8000377a <readi+0xf8>
{
    80003688:	7159                	addi	sp,sp,-112
    8000368a:	f486                	sd	ra,104(sp)
    8000368c:	f0a2                	sd	s0,96(sp)
    8000368e:	eca6                	sd	s1,88(sp)
    80003690:	e0d2                	sd	s4,64(sp)
    80003692:	fc56                	sd	s5,56(sp)
    80003694:	f85a                	sd	s6,48(sp)
    80003696:	f45e                	sd	s7,40(sp)
    80003698:	1880                	addi	s0,sp,112
    8000369a:	8b2a                	mv	s6,a0
    8000369c:	8bae                	mv	s7,a1
    8000369e:	8a32                	mv	s4,a2
    800036a0:	84b6                	mv	s1,a3
    800036a2:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800036a4:	9f35                	addw	a4,a4,a3
    return 0;
    800036a6:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800036a8:	0cd76063          	bltu	a4,a3,80003768 <readi+0xe6>
    800036ac:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800036ae:	00e7f463          	bgeu	a5,a4,800036b6 <readi+0x34>
    n = ip->size - off;
    800036b2:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800036b6:	080a8f63          	beqz	s5,80003754 <readi+0xd2>
    800036ba:	e8ca                	sd	s2,80(sp)
    800036bc:	f062                	sd	s8,32(sp)
    800036be:	ec66                	sd	s9,24(sp)
    800036c0:	e86a                	sd	s10,16(sp)
    800036c2:	e46e                	sd	s11,8(sp)
    800036c4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800036c6:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800036ca:	5c7d                	li	s8,-1
    800036cc:	a80d                	j	800036fe <readi+0x7c>
    800036ce:	020d1d93          	slli	s11,s10,0x20
    800036d2:	020ddd93          	srli	s11,s11,0x20
    800036d6:	05890613          	addi	a2,s2,88
    800036da:	86ee                	mv	a3,s11
    800036dc:	963a                	add	a2,a2,a4
    800036de:	85d2                	mv	a1,s4
    800036e0:	855e                	mv	a0,s7
    800036e2:	b53fe0ef          	jal	80002234 <either_copyout>
    800036e6:	05850763          	beq	a0,s8,80003734 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800036ea:	854a                	mv	a0,s2
    800036ec:	e42ff0ef          	jal	80002d2e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800036f0:	013d09bb          	addw	s3,s10,s3
    800036f4:	009d04bb          	addw	s1,s10,s1
    800036f8:	9a6e                	add	s4,s4,s11
    800036fa:	0559f763          	bgeu	s3,s5,80003748 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800036fe:	00a4d59b          	srliw	a1,s1,0xa
    80003702:	855a                	mv	a0,s6
    80003704:	8a7ff0ef          	jal	80002faa <bmap>
    80003708:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000370c:	c5b1                	beqz	a1,80003758 <readi+0xd6>
    bp = bread(ip->dev, addr);
    8000370e:	000b2503          	lw	a0,0(s6)
    80003712:	d14ff0ef          	jal	80002c26 <bread>
    80003716:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003718:	3ff4f713          	andi	a4,s1,1023
    8000371c:	40ec87bb          	subw	a5,s9,a4
    80003720:	413a86bb          	subw	a3,s5,s3
    80003724:	8d3e                	mv	s10,a5
    80003726:	2781                	sext.w	a5,a5
    80003728:	0006861b          	sext.w	a2,a3
    8000372c:	faf671e3          	bgeu	a2,a5,800036ce <readi+0x4c>
    80003730:	8d36                	mv	s10,a3
    80003732:	bf71                	j	800036ce <readi+0x4c>
      brelse(bp);
    80003734:	854a                	mv	a0,s2
    80003736:	df8ff0ef          	jal	80002d2e <brelse>
      tot = -1;
    8000373a:	59fd                	li	s3,-1
      break;
    8000373c:	6946                	ld	s2,80(sp)
    8000373e:	7c02                	ld	s8,32(sp)
    80003740:	6ce2                	ld	s9,24(sp)
    80003742:	6d42                	ld	s10,16(sp)
    80003744:	6da2                	ld	s11,8(sp)
    80003746:	a831                	j	80003762 <readi+0xe0>
    80003748:	6946                	ld	s2,80(sp)
    8000374a:	7c02                	ld	s8,32(sp)
    8000374c:	6ce2                	ld	s9,24(sp)
    8000374e:	6d42                	ld	s10,16(sp)
    80003750:	6da2                	ld	s11,8(sp)
    80003752:	a801                	j	80003762 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003754:	89d6                	mv	s3,s5
    80003756:	a031                	j	80003762 <readi+0xe0>
    80003758:	6946                	ld	s2,80(sp)
    8000375a:	7c02                	ld	s8,32(sp)
    8000375c:	6ce2                	ld	s9,24(sp)
    8000375e:	6d42                	ld	s10,16(sp)
    80003760:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003762:	0009851b          	sext.w	a0,s3
    80003766:	69a6                	ld	s3,72(sp)
}
    80003768:	70a6                	ld	ra,104(sp)
    8000376a:	7406                	ld	s0,96(sp)
    8000376c:	64e6                	ld	s1,88(sp)
    8000376e:	6a06                	ld	s4,64(sp)
    80003770:	7ae2                	ld	s5,56(sp)
    80003772:	7b42                	ld	s6,48(sp)
    80003774:	7ba2                	ld	s7,40(sp)
    80003776:	6165                	addi	sp,sp,112
    80003778:	8082                	ret
    return 0;
    8000377a:	4501                	li	a0,0
}
    8000377c:	8082                	ret

000000008000377e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000377e:	457c                	lw	a5,76(a0)
    80003780:	10d7e063          	bltu	a5,a3,80003880 <writei+0x102>
{
    80003784:	7159                	addi	sp,sp,-112
    80003786:	f486                	sd	ra,104(sp)
    80003788:	f0a2                	sd	s0,96(sp)
    8000378a:	e8ca                	sd	s2,80(sp)
    8000378c:	e0d2                	sd	s4,64(sp)
    8000378e:	fc56                	sd	s5,56(sp)
    80003790:	f85a                	sd	s6,48(sp)
    80003792:	f45e                	sd	s7,40(sp)
    80003794:	1880                	addi	s0,sp,112
    80003796:	8aaa                	mv	s5,a0
    80003798:	8bae                	mv	s7,a1
    8000379a:	8a32                	mv	s4,a2
    8000379c:	8936                	mv	s2,a3
    8000379e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800037a0:	00e687bb          	addw	a5,a3,a4
    800037a4:	0ed7e063          	bltu	a5,a3,80003884 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800037a8:	00043737          	lui	a4,0x43
    800037ac:	0cf76e63          	bltu	a4,a5,80003888 <writei+0x10a>
    800037b0:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800037b2:	0a0b0f63          	beqz	s6,80003870 <writei+0xf2>
    800037b6:	eca6                	sd	s1,88(sp)
    800037b8:	f062                	sd	s8,32(sp)
    800037ba:	ec66                	sd	s9,24(sp)
    800037bc:	e86a                	sd	s10,16(sp)
    800037be:	e46e                	sd	s11,8(sp)
    800037c0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800037c2:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800037c6:	5c7d                	li	s8,-1
    800037c8:	a825                	j	80003800 <writei+0x82>
    800037ca:	020d1d93          	slli	s11,s10,0x20
    800037ce:	020ddd93          	srli	s11,s11,0x20
    800037d2:	05848513          	addi	a0,s1,88
    800037d6:	86ee                	mv	a3,s11
    800037d8:	8652                	mv	a2,s4
    800037da:	85de                	mv	a1,s7
    800037dc:	953a                	add	a0,a0,a4
    800037de:	aa1fe0ef          	jal	8000227e <either_copyin>
    800037e2:	05850a63          	beq	a0,s8,80003836 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800037e6:	8526                	mv	a0,s1
    800037e8:	678000ef          	jal	80003e60 <log_write>
    brelse(bp);
    800037ec:	8526                	mv	a0,s1
    800037ee:	d40ff0ef          	jal	80002d2e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800037f2:	013d09bb          	addw	s3,s10,s3
    800037f6:	012d093b          	addw	s2,s10,s2
    800037fa:	9a6e                	add	s4,s4,s11
    800037fc:	0569f063          	bgeu	s3,s6,8000383c <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003800:	00a9559b          	srliw	a1,s2,0xa
    80003804:	8556                	mv	a0,s5
    80003806:	fa4ff0ef          	jal	80002faa <bmap>
    8000380a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000380e:	c59d                	beqz	a1,8000383c <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003810:	000aa503          	lw	a0,0(s5)
    80003814:	c12ff0ef          	jal	80002c26 <bread>
    80003818:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000381a:	3ff97713          	andi	a4,s2,1023
    8000381e:	40ec87bb          	subw	a5,s9,a4
    80003822:	413b06bb          	subw	a3,s6,s3
    80003826:	8d3e                	mv	s10,a5
    80003828:	2781                	sext.w	a5,a5
    8000382a:	0006861b          	sext.w	a2,a3
    8000382e:	f8f67ee3          	bgeu	a2,a5,800037ca <writei+0x4c>
    80003832:	8d36                	mv	s10,a3
    80003834:	bf59                	j	800037ca <writei+0x4c>
      brelse(bp);
    80003836:	8526                	mv	a0,s1
    80003838:	cf6ff0ef          	jal	80002d2e <brelse>
  }

  if(off > ip->size)
    8000383c:	04caa783          	lw	a5,76(s5)
    80003840:	0327fa63          	bgeu	a5,s2,80003874 <writei+0xf6>
    ip->size = off;
    80003844:	052aa623          	sw	s2,76(s5)
    80003848:	64e6                	ld	s1,88(sp)
    8000384a:	7c02                	ld	s8,32(sp)
    8000384c:	6ce2                	ld	s9,24(sp)
    8000384e:	6d42                	ld	s10,16(sp)
    80003850:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003852:	8556                	mv	a0,s5
    80003854:	9ebff0ef          	jal	8000323e <iupdate>

  return tot;
    80003858:	0009851b          	sext.w	a0,s3
    8000385c:	69a6                	ld	s3,72(sp)
}
    8000385e:	70a6                	ld	ra,104(sp)
    80003860:	7406                	ld	s0,96(sp)
    80003862:	6946                	ld	s2,80(sp)
    80003864:	6a06                	ld	s4,64(sp)
    80003866:	7ae2                	ld	s5,56(sp)
    80003868:	7b42                	ld	s6,48(sp)
    8000386a:	7ba2                	ld	s7,40(sp)
    8000386c:	6165                	addi	sp,sp,112
    8000386e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003870:	89da                	mv	s3,s6
    80003872:	b7c5                	j	80003852 <writei+0xd4>
    80003874:	64e6                	ld	s1,88(sp)
    80003876:	7c02                	ld	s8,32(sp)
    80003878:	6ce2                	ld	s9,24(sp)
    8000387a:	6d42                	ld	s10,16(sp)
    8000387c:	6da2                	ld	s11,8(sp)
    8000387e:	bfd1                	j	80003852 <writei+0xd4>
    return -1;
    80003880:	557d                	li	a0,-1
}
    80003882:	8082                	ret
    return -1;
    80003884:	557d                	li	a0,-1
    80003886:	bfe1                	j	8000385e <writei+0xe0>
    return -1;
    80003888:	557d                	li	a0,-1
    8000388a:	bfd1                	j	8000385e <writei+0xe0>

000000008000388c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000388c:	1141                	addi	sp,sp,-16
    8000388e:	e406                	sd	ra,8(sp)
    80003890:	e022                	sd	s0,0(sp)
    80003892:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003894:	4639                	li	a2,14
    80003896:	cd8fd0ef          	jal	80000d6e <strncmp>
}
    8000389a:	60a2                	ld	ra,8(sp)
    8000389c:	6402                	ld	s0,0(sp)
    8000389e:	0141                	addi	sp,sp,16
    800038a0:	8082                	ret

00000000800038a2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800038a2:	7139                	addi	sp,sp,-64
    800038a4:	fc06                	sd	ra,56(sp)
    800038a6:	f822                	sd	s0,48(sp)
    800038a8:	f426                	sd	s1,40(sp)
    800038aa:	f04a                	sd	s2,32(sp)
    800038ac:	ec4e                	sd	s3,24(sp)
    800038ae:	e852                	sd	s4,16(sp)
    800038b0:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800038b2:	04451703          	lh	a4,68(a0)
    800038b6:	4785                	li	a5,1
    800038b8:	00f71a63          	bne	a4,a5,800038cc <dirlookup+0x2a>
    800038bc:	892a                	mv	s2,a0
    800038be:	89ae                	mv	s3,a1
    800038c0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800038c2:	457c                	lw	a5,76(a0)
    800038c4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800038c6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038c8:	e39d                	bnez	a5,800038ee <dirlookup+0x4c>
    800038ca:	a095                	j	8000392e <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800038cc:	00004517          	auipc	a0,0x4
    800038d0:	bf450513          	addi	a0,a0,-1036 # 800074c0 <etext+0x4c0>
    800038d4:	f0dfc0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    800038d8:	00004517          	auipc	a0,0x4
    800038dc:	c0050513          	addi	a0,a0,-1024 # 800074d8 <etext+0x4d8>
    800038e0:	f01fc0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038e4:	24c1                	addiw	s1,s1,16
    800038e6:	04c92783          	lw	a5,76(s2)
    800038ea:	04f4f163          	bgeu	s1,a5,8000392c <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038ee:	4741                	li	a4,16
    800038f0:	86a6                	mv	a3,s1
    800038f2:	fc040613          	addi	a2,s0,-64
    800038f6:	4581                	li	a1,0
    800038f8:	854a                	mv	a0,s2
    800038fa:	d89ff0ef          	jal	80003682 <readi>
    800038fe:	47c1                	li	a5,16
    80003900:	fcf51ce3          	bne	a0,a5,800038d8 <dirlookup+0x36>
    if(de.inum == 0)
    80003904:	fc045783          	lhu	a5,-64(s0)
    80003908:	dff1                	beqz	a5,800038e4 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    8000390a:	fc240593          	addi	a1,s0,-62
    8000390e:	854e                	mv	a0,s3
    80003910:	f7dff0ef          	jal	8000388c <namecmp>
    80003914:	f961                	bnez	a0,800038e4 <dirlookup+0x42>
      if(poff)
    80003916:	000a0463          	beqz	s4,8000391e <dirlookup+0x7c>
        *poff = off;
    8000391a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000391e:	fc045583          	lhu	a1,-64(s0)
    80003922:	00092503          	lw	a0,0(s2)
    80003926:	f58ff0ef          	jal	8000307e <iget>
    8000392a:	a011                	j	8000392e <dirlookup+0x8c>
  return 0;
    8000392c:	4501                	li	a0,0
}
    8000392e:	70e2                	ld	ra,56(sp)
    80003930:	7442                	ld	s0,48(sp)
    80003932:	74a2                	ld	s1,40(sp)
    80003934:	7902                	ld	s2,32(sp)
    80003936:	69e2                	ld	s3,24(sp)
    80003938:	6a42                	ld	s4,16(sp)
    8000393a:	6121                	addi	sp,sp,64
    8000393c:	8082                	ret

000000008000393e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000393e:	711d                	addi	sp,sp,-96
    80003940:	ec86                	sd	ra,88(sp)
    80003942:	e8a2                	sd	s0,80(sp)
    80003944:	e4a6                	sd	s1,72(sp)
    80003946:	e0ca                	sd	s2,64(sp)
    80003948:	fc4e                	sd	s3,56(sp)
    8000394a:	f852                	sd	s4,48(sp)
    8000394c:	f456                	sd	s5,40(sp)
    8000394e:	f05a                	sd	s6,32(sp)
    80003950:	ec5e                	sd	s7,24(sp)
    80003952:	e862                	sd	s8,16(sp)
    80003954:	e466                	sd	s9,8(sp)
    80003956:	1080                	addi	s0,sp,96
    80003958:	84aa                	mv	s1,a0
    8000395a:	8b2e                	mv	s6,a1
    8000395c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000395e:	00054703          	lbu	a4,0(a0)
    80003962:	02f00793          	li	a5,47
    80003966:	00f70e63          	beq	a4,a5,80003982 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000396a:	f65fd0ef          	jal	800018ce <myproc>
    8000396e:	15053503          	ld	a0,336(a0)
    80003972:	94bff0ef          	jal	800032bc <idup>
    80003976:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003978:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000397c:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000397e:	4b85                	li	s7,1
    80003980:	a871                	j	80003a1c <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003982:	4585                	li	a1,1
    80003984:	4505                	li	a0,1
    80003986:	ef8ff0ef          	jal	8000307e <iget>
    8000398a:	8a2a                	mv	s4,a0
    8000398c:	b7f5                	j	80003978 <namex+0x3a>
      iunlockput(ip);
    8000398e:	8552                	mv	a0,s4
    80003990:	b6dff0ef          	jal	800034fc <iunlockput>
      return 0;
    80003994:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003996:	8552                	mv	a0,s4
    80003998:	60e6                	ld	ra,88(sp)
    8000399a:	6446                	ld	s0,80(sp)
    8000399c:	64a6                	ld	s1,72(sp)
    8000399e:	6906                	ld	s2,64(sp)
    800039a0:	79e2                	ld	s3,56(sp)
    800039a2:	7a42                	ld	s4,48(sp)
    800039a4:	7aa2                	ld	s5,40(sp)
    800039a6:	7b02                	ld	s6,32(sp)
    800039a8:	6be2                	ld	s7,24(sp)
    800039aa:	6c42                	ld	s8,16(sp)
    800039ac:	6ca2                	ld	s9,8(sp)
    800039ae:	6125                	addi	sp,sp,96
    800039b0:	8082                	ret
      iunlock(ip);
    800039b2:	8552                	mv	a0,s4
    800039b4:	9edff0ef          	jal	800033a0 <iunlock>
      return ip;
    800039b8:	bff9                	j	80003996 <namex+0x58>
      iunlockput(ip);
    800039ba:	8552                	mv	a0,s4
    800039bc:	b41ff0ef          	jal	800034fc <iunlockput>
      return 0;
    800039c0:	8a4e                	mv	s4,s3
    800039c2:	bfd1                	j	80003996 <namex+0x58>
  len = path - s;
    800039c4:	40998633          	sub	a2,s3,s1
    800039c8:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800039cc:	099c5063          	bge	s8,s9,80003a4c <namex+0x10e>
    memmove(name, s, DIRSIZ);
    800039d0:	4639                	li	a2,14
    800039d2:	85a6                	mv	a1,s1
    800039d4:	8556                	mv	a0,s5
    800039d6:	b28fd0ef          	jal	80000cfe <memmove>
    800039da:	84ce                	mv	s1,s3
  while(*path == '/')
    800039dc:	0004c783          	lbu	a5,0(s1)
    800039e0:	01279763          	bne	a5,s2,800039ee <namex+0xb0>
    path++;
    800039e4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800039e6:	0004c783          	lbu	a5,0(s1)
    800039ea:	ff278de3          	beq	a5,s2,800039e4 <namex+0xa6>
    ilock(ip);
    800039ee:	8552                	mv	a0,s4
    800039f0:	903ff0ef          	jal	800032f2 <ilock>
    if(ip->type != T_DIR){
    800039f4:	044a1783          	lh	a5,68(s4)
    800039f8:	f9779be3          	bne	a5,s7,8000398e <namex+0x50>
    if(nameiparent && *path == '\0'){
    800039fc:	000b0563          	beqz	s6,80003a06 <namex+0xc8>
    80003a00:	0004c783          	lbu	a5,0(s1)
    80003a04:	d7dd                	beqz	a5,800039b2 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003a06:	4601                	li	a2,0
    80003a08:	85d6                	mv	a1,s5
    80003a0a:	8552                	mv	a0,s4
    80003a0c:	e97ff0ef          	jal	800038a2 <dirlookup>
    80003a10:	89aa                	mv	s3,a0
    80003a12:	d545                	beqz	a0,800039ba <namex+0x7c>
    iunlockput(ip);
    80003a14:	8552                	mv	a0,s4
    80003a16:	ae7ff0ef          	jal	800034fc <iunlockput>
    ip = next;
    80003a1a:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003a1c:	0004c783          	lbu	a5,0(s1)
    80003a20:	01279763          	bne	a5,s2,80003a2e <namex+0xf0>
    path++;
    80003a24:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a26:	0004c783          	lbu	a5,0(s1)
    80003a2a:	ff278de3          	beq	a5,s2,80003a24 <namex+0xe6>
  if(*path == 0)
    80003a2e:	cb8d                	beqz	a5,80003a60 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003a30:	0004c783          	lbu	a5,0(s1)
    80003a34:	89a6                	mv	s3,s1
  len = path - s;
    80003a36:	4c81                	li	s9,0
    80003a38:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003a3a:	01278963          	beq	a5,s2,80003a4c <namex+0x10e>
    80003a3e:	d3d9                	beqz	a5,800039c4 <namex+0x86>
    path++;
    80003a40:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003a42:	0009c783          	lbu	a5,0(s3)
    80003a46:	ff279ce3          	bne	a5,s2,80003a3e <namex+0x100>
    80003a4a:	bfad                	j	800039c4 <namex+0x86>
    memmove(name, s, len);
    80003a4c:	2601                	sext.w	a2,a2
    80003a4e:	85a6                	mv	a1,s1
    80003a50:	8556                	mv	a0,s5
    80003a52:	aacfd0ef          	jal	80000cfe <memmove>
    name[len] = 0;
    80003a56:	9cd6                	add	s9,s9,s5
    80003a58:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003a5c:	84ce                	mv	s1,s3
    80003a5e:	bfbd                	j	800039dc <namex+0x9e>
  if(nameiparent){
    80003a60:	f20b0be3          	beqz	s6,80003996 <namex+0x58>
    iput(ip);
    80003a64:	8552                	mv	a0,s4
    80003a66:	a0fff0ef          	jal	80003474 <iput>
    return 0;
    80003a6a:	4a01                	li	s4,0
    80003a6c:	b72d                	j	80003996 <namex+0x58>

0000000080003a6e <dirlink>:
{
    80003a6e:	7139                	addi	sp,sp,-64
    80003a70:	fc06                	sd	ra,56(sp)
    80003a72:	f822                	sd	s0,48(sp)
    80003a74:	f04a                	sd	s2,32(sp)
    80003a76:	ec4e                	sd	s3,24(sp)
    80003a78:	e852                	sd	s4,16(sp)
    80003a7a:	0080                	addi	s0,sp,64
    80003a7c:	892a                	mv	s2,a0
    80003a7e:	8a2e                	mv	s4,a1
    80003a80:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003a82:	4601                	li	a2,0
    80003a84:	e1fff0ef          	jal	800038a2 <dirlookup>
    80003a88:	e535                	bnez	a0,80003af4 <dirlink+0x86>
    80003a8a:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a8c:	04c92483          	lw	s1,76(s2)
    80003a90:	c48d                	beqz	s1,80003aba <dirlink+0x4c>
    80003a92:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a94:	4741                	li	a4,16
    80003a96:	86a6                	mv	a3,s1
    80003a98:	fc040613          	addi	a2,s0,-64
    80003a9c:	4581                	li	a1,0
    80003a9e:	854a                	mv	a0,s2
    80003aa0:	be3ff0ef          	jal	80003682 <readi>
    80003aa4:	47c1                	li	a5,16
    80003aa6:	04f51b63          	bne	a0,a5,80003afc <dirlink+0x8e>
    if(de.inum == 0)
    80003aaa:	fc045783          	lhu	a5,-64(s0)
    80003aae:	c791                	beqz	a5,80003aba <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ab0:	24c1                	addiw	s1,s1,16
    80003ab2:	04c92783          	lw	a5,76(s2)
    80003ab6:	fcf4efe3          	bltu	s1,a5,80003a94 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003aba:	4639                	li	a2,14
    80003abc:	85d2                	mv	a1,s4
    80003abe:	fc240513          	addi	a0,s0,-62
    80003ac2:	ae2fd0ef          	jal	80000da4 <strncpy>
  de.inum = inum;
    80003ac6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003aca:	4741                	li	a4,16
    80003acc:	86a6                	mv	a3,s1
    80003ace:	fc040613          	addi	a2,s0,-64
    80003ad2:	4581                	li	a1,0
    80003ad4:	854a                	mv	a0,s2
    80003ad6:	ca9ff0ef          	jal	8000377e <writei>
    80003ada:	1541                	addi	a0,a0,-16
    80003adc:	00a03533          	snez	a0,a0
    80003ae0:	40a00533          	neg	a0,a0
    80003ae4:	74a2                	ld	s1,40(sp)
}
    80003ae6:	70e2                	ld	ra,56(sp)
    80003ae8:	7442                	ld	s0,48(sp)
    80003aea:	7902                	ld	s2,32(sp)
    80003aec:	69e2                	ld	s3,24(sp)
    80003aee:	6a42                	ld	s4,16(sp)
    80003af0:	6121                	addi	sp,sp,64
    80003af2:	8082                	ret
    iput(ip);
    80003af4:	981ff0ef          	jal	80003474 <iput>
    return -1;
    80003af8:	557d                	li	a0,-1
    80003afa:	b7f5                	j	80003ae6 <dirlink+0x78>
      panic("dirlink read");
    80003afc:	00004517          	auipc	a0,0x4
    80003b00:	9ec50513          	addi	a0,a0,-1556 # 800074e8 <etext+0x4e8>
    80003b04:	cddfc0ef          	jal	800007e0 <panic>

0000000080003b08 <namei>:

struct inode*
namei(char *path)
{
    80003b08:	1101                	addi	sp,sp,-32
    80003b0a:	ec06                	sd	ra,24(sp)
    80003b0c:	e822                	sd	s0,16(sp)
    80003b0e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003b10:	fe040613          	addi	a2,s0,-32
    80003b14:	4581                	li	a1,0
    80003b16:	e29ff0ef          	jal	8000393e <namex>
}
    80003b1a:	60e2                	ld	ra,24(sp)
    80003b1c:	6442                	ld	s0,16(sp)
    80003b1e:	6105                	addi	sp,sp,32
    80003b20:	8082                	ret

0000000080003b22 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003b22:	1141                	addi	sp,sp,-16
    80003b24:	e406                	sd	ra,8(sp)
    80003b26:	e022                	sd	s0,0(sp)
    80003b28:	0800                	addi	s0,sp,16
    80003b2a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003b2c:	4585                	li	a1,1
    80003b2e:	e11ff0ef          	jal	8000393e <namex>
}
    80003b32:	60a2                	ld	ra,8(sp)
    80003b34:	6402                	ld	s0,0(sp)
    80003b36:	0141                	addi	sp,sp,16
    80003b38:	8082                	ret

0000000080003b3a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003b3a:	1101                	addi	sp,sp,-32
    80003b3c:	ec06                	sd	ra,24(sp)
    80003b3e:	e822                	sd	s0,16(sp)
    80003b40:	e426                	sd	s1,8(sp)
    80003b42:	e04a                	sd	s2,0(sp)
    80003b44:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003b46:	0001f917          	auipc	s2,0x1f
    80003b4a:	82290913          	addi	s2,s2,-2014 # 80022368 <log>
    80003b4e:	01892583          	lw	a1,24(s2)
    80003b52:	02492503          	lw	a0,36(s2)
    80003b56:	8d0ff0ef          	jal	80002c26 <bread>
    80003b5a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003b5c:	02892603          	lw	a2,40(s2)
    80003b60:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003b62:	00c05f63          	blez	a2,80003b80 <write_head+0x46>
    80003b66:	0001f717          	auipc	a4,0x1f
    80003b6a:	82e70713          	addi	a4,a4,-2002 # 80022394 <log+0x2c>
    80003b6e:	87aa                	mv	a5,a0
    80003b70:	060a                	slli	a2,a2,0x2
    80003b72:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003b74:	4314                	lw	a3,0(a4)
    80003b76:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003b78:	0711                	addi	a4,a4,4
    80003b7a:	0791                	addi	a5,a5,4
    80003b7c:	fec79ce3          	bne	a5,a2,80003b74 <write_head+0x3a>
  }
  bwrite(buf);
    80003b80:	8526                	mv	a0,s1
    80003b82:	97aff0ef          	jal	80002cfc <bwrite>
  brelse(buf);
    80003b86:	8526                	mv	a0,s1
    80003b88:	9a6ff0ef          	jal	80002d2e <brelse>
}
    80003b8c:	60e2                	ld	ra,24(sp)
    80003b8e:	6442                	ld	s0,16(sp)
    80003b90:	64a2                	ld	s1,8(sp)
    80003b92:	6902                	ld	s2,0(sp)
    80003b94:	6105                	addi	sp,sp,32
    80003b96:	8082                	ret

0000000080003b98 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b98:	0001e797          	auipc	a5,0x1e
    80003b9c:	7f87a783          	lw	a5,2040(a5) # 80022390 <log+0x28>
    80003ba0:	0af05e63          	blez	a5,80003c5c <install_trans+0xc4>
{
    80003ba4:	715d                	addi	sp,sp,-80
    80003ba6:	e486                	sd	ra,72(sp)
    80003ba8:	e0a2                	sd	s0,64(sp)
    80003baa:	fc26                	sd	s1,56(sp)
    80003bac:	f84a                	sd	s2,48(sp)
    80003bae:	f44e                	sd	s3,40(sp)
    80003bb0:	f052                	sd	s4,32(sp)
    80003bb2:	ec56                	sd	s5,24(sp)
    80003bb4:	e85a                	sd	s6,16(sp)
    80003bb6:	e45e                	sd	s7,8(sp)
    80003bb8:	0880                	addi	s0,sp,80
    80003bba:	8b2a                	mv	s6,a0
    80003bbc:	0001ea97          	auipc	s5,0x1e
    80003bc0:	7d8a8a93          	addi	s5,s5,2008 # 80022394 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bc4:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003bc6:	00004b97          	auipc	s7,0x4
    80003bca:	932b8b93          	addi	s7,s7,-1742 # 800074f8 <etext+0x4f8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003bce:	0001ea17          	auipc	s4,0x1e
    80003bd2:	79aa0a13          	addi	s4,s4,1946 # 80022368 <log>
    80003bd6:	a025                	j	80003bfe <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003bd8:	000aa603          	lw	a2,0(s5)
    80003bdc:	85ce                	mv	a1,s3
    80003bde:	855e                	mv	a0,s7
    80003be0:	91bfc0ef          	jal	800004fa <printf>
    80003be4:	a839                	j	80003c02 <install_trans+0x6a>
    brelse(lbuf);
    80003be6:	854a                	mv	a0,s2
    80003be8:	946ff0ef          	jal	80002d2e <brelse>
    brelse(dbuf);
    80003bec:	8526                	mv	a0,s1
    80003bee:	940ff0ef          	jal	80002d2e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bf2:	2985                	addiw	s3,s3,1
    80003bf4:	0a91                	addi	s5,s5,4
    80003bf6:	028a2783          	lw	a5,40(s4)
    80003bfa:	04f9d663          	bge	s3,a5,80003c46 <install_trans+0xae>
    if(recovering) {
    80003bfe:	fc0b1de3          	bnez	s6,80003bd8 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003c02:	018a2583          	lw	a1,24(s4)
    80003c06:	013585bb          	addw	a1,a1,s3
    80003c0a:	2585                	addiw	a1,a1,1
    80003c0c:	024a2503          	lw	a0,36(s4)
    80003c10:	816ff0ef          	jal	80002c26 <bread>
    80003c14:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003c16:	000aa583          	lw	a1,0(s5)
    80003c1a:	024a2503          	lw	a0,36(s4)
    80003c1e:	808ff0ef          	jal	80002c26 <bread>
    80003c22:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003c24:	40000613          	li	a2,1024
    80003c28:	05890593          	addi	a1,s2,88
    80003c2c:	05850513          	addi	a0,a0,88
    80003c30:	8cefd0ef          	jal	80000cfe <memmove>
    bwrite(dbuf);  // write dst to disk
    80003c34:	8526                	mv	a0,s1
    80003c36:	8c6ff0ef          	jal	80002cfc <bwrite>
    if(recovering == 0)
    80003c3a:	fa0b16e3          	bnez	s6,80003be6 <install_trans+0x4e>
      bunpin(dbuf);
    80003c3e:	8526                	mv	a0,s1
    80003c40:	9aaff0ef          	jal	80002dea <bunpin>
    80003c44:	b74d                	j	80003be6 <install_trans+0x4e>
}
    80003c46:	60a6                	ld	ra,72(sp)
    80003c48:	6406                	ld	s0,64(sp)
    80003c4a:	74e2                	ld	s1,56(sp)
    80003c4c:	7942                	ld	s2,48(sp)
    80003c4e:	79a2                	ld	s3,40(sp)
    80003c50:	7a02                	ld	s4,32(sp)
    80003c52:	6ae2                	ld	s5,24(sp)
    80003c54:	6b42                	ld	s6,16(sp)
    80003c56:	6ba2                	ld	s7,8(sp)
    80003c58:	6161                	addi	sp,sp,80
    80003c5a:	8082                	ret
    80003c5c:	8082                	ret

0000000080003c5e <initlog>:
{
    80003c5e:	7179                	addi	sp,sp,-48
    80003c60:	f406                	sd	ra,40(sp)
    80003c62:	f022                	sd	s0,32(sp)
    80003c64:	ec26                	sd	s1,24(sp)
    80003c66:	e84a                	sd	s2,16(sp)
    80003c68:	e44e                	sd	s3,8(sp)
    80003c6a:	1800                	addi	s0,sp,48
    80003c6c:	892a                	mv	s2,a0
    80003c6e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003c70:	0001e497          	auipc	s1,0x1e
    80003c74:	6f848493          	addi	s1,s1,1784 # 80022368 <log>
    80003c78:	00004597          	auipc	a1,0x4
    80003c7c:	8a058593          	addi	a1,a1,-1888 # 80007518 <etext+0x518>
    80003c80:	8526                	mv	a0,s1
    80003c82:	ecdfc0ef          	jal	80000b4e <initlock>
  log.start = sb->logstart;
    80003c86:	0149a583          	lw	a1,20(s3)
    80003c8a:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003c8c:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003c90:	854a                	mv	a0,s2
    80003c92:	f95fe0ef          	jal	80002c26 <bread>
  log.lh.n = lh->n;
    80003c96:	4d30                	lw	a2,88(a0)
    80003c98:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003c9a:	00c05f63          	blez	a2,80003cb8 <initlog+0x5a>
    80003c9e:	87aa                	mv	a5,a0
    80003ca0:	0001e717          	auipc	a4,0x1e
    80003ca4:	6f470713          	addi	a4,a4,1780 # 80022394 <log+0x2c>
    80003ca8:	060a                	slli	a2,a2,0x2
    80003caa:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003cac:	4ff4                	lw	a3,92(a5)
    80003cae:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003cb0:	0791                	addi	a5,a5,4
    80003cb2:	0711                	addi	a4,a4,4
    80003cb4:	fec79ce3          	bne	a5,a2,80003cac <initlog+0x4e>
  brelse(buf);
    80003cb8:	876ff0ef          	jal	80002d2e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003cbc:	4505                	li	a0,1
    80003cbe:	edbff0ef          	jal	80003b98 <install_trans>
  log.lh.n = 0;
    80003cc2:	0001e797          	auipc	a5,0x1e
    80003cc6:	6c07a723          	sw	zero,1742(a5) # 80022390 <log+0x28>
  write_head(); // clear the log
    80003cca:	e71ff0ef          	jal	80003b3a <write_head>
}
    80003cce:	70a2                	ld	ra,40(sp)
    80003cd0:	7402                	ld	s0,32(sp)
    80003cd2:	64e2                	ld	s1,24(sp)
    80003cd4:	6942                	ld	s2,16(sp)
    80003cd6:	69a2                	ld	s3,8(sp)
    80003cd8:	6145                	addi	sp,sp,48
    80003cda:	8082                	ret

0000000080003cdc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003cdc:	1101                	addi	sp,sp,-32
    80003cde:	ec06                	sd	ra,24(sp)
    80003ce0:	e822                	sd	s0,16(sp)
    80003ce2:	e426                	sd	s1,8(sp)
    80003ce4:	e04a                	sd	s2,0(sp)
    80003ce6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003ce8:	0001e517          	auipc	a0,0x1e
    80003cec:	68050513          	addi	a0,a0,1664 # 80022368 <log>
    80003cf0:	edffc0ef          	jal	80000bce <acquire>
  while(1){
    if(log.committing){
    80003cf4:	0001e497          	auipc	s1,0x1e
    80003cf8:	67448493          	addi	s1,s1,1652 # 80022368 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003cfc:	4979                	li	s2,30
    80003cfe:	a029                	j	80003d08 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003d00:	85a6                	mv	a1,s1
    80003d02:	8526                	mv	a0,s1
    80003d04:	9d4fe0ef          	jal	80001ed8 <sleep>
    if(log.committing){
    80003d08:	509c                	lw	a5,32(s1)
    80003d0a:	fbfd                	bnez	a5,80003d00 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003d0c:	4cd8                	lw	a4,28(s1)
    80003d0e:	2705                	addiw	a4,a4,1
    80003d10:	0027179b          	slliw	a5,a4,0x2
    80003d14:	9fb9                	addw	a5,a5,a4
    80003d16:	0017979b          	slliw	a5,a5,0x1
    80003d1a:	5494                	lw	a3,40(s1)
    80003d1c:	9fb5                	addw	a5,a5,a3
    80003d1e:	00f95763          	bge	s2,a5,80003d2c <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003d22:	85a6                	mv	a1,s1
    80003d24:	8526                	mv	a0,s1
    80003d26:	9b2fe0ef          	jal	80001ed8 <sleep>
    80003d2a:	bff9                	j	80003d08 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003d2c:	0001e517          	auipc	a0,0x1e
    80003d30:	63c50513          	addi	a0,a0,1596 # 80022368 <log>
    80003d34:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003d36:	f31fc0ef          	jal	80000c66 <release>
      break;
    }
  }
}
    80003d3a:	60e2                	ld	ra,24(sp)
    80003d3c:	6442                	ld	s0,16(sp)
    80003d3e:	64a2                	ld	s1,8(sp)
    80003d40:	6902                	ld	s2,0(sp)
    80003d42:	6105                	addi	sp,sp,32
    80003d44:	8082                	ret

0000000080003d46 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003d46:	7139                	addi	sp,sp,-64
    80003d48:	fc06                	sd	ra,56(sp)
    80003d4a:	f822                	sd	s0,48(sp)
    80003d4c:	f426                	sd	s1,40(sp)
    80003d4e:	f04a                	sd	s2,32(sp)
    80003d50:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003d52:	0001e497          	auipc	s1,0x1e
    80003d56:	61648493          	addi	s1,s1,1558 # 80022368 <log>
    80003d5a:	8526                	mv	a0,s1
    80003d5c:	e73fc0ef          	jal	80000bce <acquire>
  log.outstanding -= 1;
    80003d60:	4cdc                	lw	a5,28(s1)
    80003d62:	37fd                	addiw	a5,a5,-1
    80003d64:	0007891b          	sext.w	s2,a5
    80003d68:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003d6a:	509c                	lw	a5,32(s1)
    80003d6c:	ef9d                	bnez	a5,80003daa <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003d6e:	04091763          	bnez	s2,80003dbc <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003d72:	0001e497          	auipc	s1,0x1e
    80003d76:	5f648493          	addi	s1,s1,1526 # 80022368 <log>
    80003d7a:	4785                	li	a5,1
    80003d7c:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003d7e:	8526                	mv	a0,s1
    80003d80:	ee7fc0ef          	jal	80000c66 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003d84:	549c                	lw	a5,40(s1)
    80003d86:	04f04b63          	bgtz	a5,80003ddc <end_op+0x96>
    acquire(&log.lock);
    80003d8a:	0001e497          	auipc	s1,0x1e
    80003d8e:	5de48493          	addi	s1,s1,1502 # 80022368 <log>
    80003d92:	8526                	mv	a0,s1
    80003d94:	e3bfc0ef          	jal	80000bce <acquire>
    log.committing = 0;
    80003d98:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003d9c:	8526                	mv	a0,s1
    80003d9e:	986fe0ef          	jal	80001f24 <wakeup>
    release(&log.lock);
    80003da2:	8526                	mv	a0,s1
    80003da4:	ec3fc0ef          	jal	80000c66 <release>
}
    80003da8:	a025                	j	80003dd0 <end_op+0x8a>
    80003daa:	ec4e                	sd	s3,24(sp)
    80003dac:	e852                	sd	s4,16(sp)
    80003dae:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003db0:	00003517          	auipc	a0,0x3
    80003db4:	77050513          	addi	a0,a0,1904 # 80007520 <etext+0x520>
    80003db8:	a29fc0ef          	jal	800007e0 <panic>
    wakeup(&log);
    80003dbc:	0001e497          	auipc	s1,0x1e
    80003dc0:	5ac48493          	addi	s1,s1,1452 # 80022368 <log>
    80003dc4:	8526                	mv	a0,s1
    80003dc6:	95efe0ef          	jal	80001f24 <wakeup>
  release(&log.lock);
    80003dca:	8526                	mv	a0,s1
    80003dcc:	e9bfc0ef          	jal	80000c66 <release>
}
    80003dd0:	70e2                	ld	ra,56(sp)
    80003dd2:	7442                	ld	s0,48(sp)
    80003dd4:	74a2                	ld	s1,40(sp)
    80003dd6:	7902                	ld	s2,32(sp)
    80003dd8:	6121                	addi	sp,sp,64
    80003dda:	8082                	ret
    80003ddc:	ec4e                	sd	s3,24(sp)
    80003dde:	e852                	sd	s4,16(sp)
    80003de0:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003de2:	0001ea97          	auipc	s5,0x1e
    80003de6:	5b2a8a93          	addi	s5,s5,1458 # 80022394 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003dea:	0001ea17          	auipc	s4,0x1e
    80003dee:	57ea0a13          	addi	s4,s4,1406 # 80022368 <log>
    80003df2:	018a2583          	lw	a1,24(s4)
    80003df6:	012585bb          	addw	a1,a1,s2
    80003dfa:	2585                	addiw	a1,a1,1
    80003dfc:	024a2503          	lw	a0,36(s4)
    80003e00:	e27fe0ef          	jal	80002c26 <bread>
    80003e04:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003e06:	000aa583          	lw	a1,0(s5)
    80003e0a:	024a2503          	lw	a0,36(s4)
    80003e0e:	e19fe0ef          	jal	80002c26 <bread>
    80003e12:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003e14:	40000613          	li	a2,1024
    80003e18:	05850593          	addi	a1,a0,88
    80003e1c:	05848513          	addi	a0,s1,88
    80003e20:	edffc0ef          	jal	80000cfe <memmove>
    bwrite(to);  // write the log
    80003e24:	8526                	mv	a0,s1
    80003e26:	ed7fe0ef          	jal	80002cfc <bwrite>
    brelse(from);
    80003e2a:	854e                	mv	a0,s3
    80003e2c:	f03fe0ef          	jal	80002d2e <brelse>
    brelse(to);
    80003e30:	8526                	mv	a0,s1
    80003e32:	efdfe0ef          	jal	80002d2e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e36:	2905                	addiw	s2,s2,1
    80003e38:	0a91                	addi	s5,s5,4
    80003e3a:	028a2783          	lw	a5,40(s4)
    80003e3e:	faf94ae3          	blt	s2,a5,80003df2 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003e42:	cf9ff0ef          	jal	80003b3a <write_head>
    install_trans(0); // Now install writes to home locations
    80003e46:	4501                	li	a0,0
    80003e48:	d51ff0ef          	jal	80003b98 <install_trans>
    log.lh.n = 0;
    80003e4c:	0001e797          	auipc	a5,0x1e
    80003e50:	5407a223          	sw	zero,1348(a5) # 80022390 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003e54:	ce7ff0ef          	jal	80003b3a <write_head>
    80003e58:	69e2                	ld	s3,24(sp)
    80003e5a:	6a42                	ld	s4,16(sp)
    80003e5c:	6aa2                	ld	s5,8(sp)
    80003e5e:	b735                	j	80003d8a <end_op+0x44>

0000000080003e60 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003e60:	1101                	addi	sp,sp,-32
    80003e62:	ec06                	sd	ra,24(sp)
    80003e64:	e822                	sd	s0,16(sp)
    80003e66:	e426                	sd	s1,8(sp)
    80003e68:	e04a                	sd	s2,0(sp)
    80003e6a:	1000                	addi	s0,sp,32
    80003e6c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003e6e:	0001e917          	auipc	s2,0x1e
    80003e72:	4fa90913          	addi	s2,s2,1274 # 80022368 <log>
    80003e76:	854a                	mv	a0,s2
    80003e78:	d57fc0ef          	jal	80000bce <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003e7c:	02892603          	lw	a2,40(s2)
    80003e80:	47f5                	li	a5,29
    80003e82:	04c7cc63          	blt	a5,a2,80003eda <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003e86:	0001e797          	auipc	a5,0x1e
    80003e8a:	4fe7a783          	lw	a5,1278(a5) # 80022384 <log+0x1c>
    80003e8e:	04f05c63          	blez	a5,80003ee6 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003e92:	4781                	li	a5,0
    80003e94:	04c05f63          	blez	a2,80003ef2 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003e98:	44cc                	lw	a1,12(s1)
    80003e9a:	0001e717          	auipc	a4,0x1e
    80003e9e:	4fa70713          	addi	a4,a4,1274 # 80022394 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003ea2:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003ea4:	4314                	lw	a3,0(a4)
    80003ea6:	04b68663          	beq	a3,a1,80003ef2 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003eaa:	2785                	addiw	a5,a5,1
    80003eac:	0711                	addi	a4,a4,4
    80003eae:	fef61be3          	bne	a2,a5,80003ea4 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003eb2:	0621                	addi	a2,a2,8
    80003eb4:	060a                	slli	a2,a2,0x2
    80003eb6:	0001e797          	auipc	a5,0x1e
    80003eba:	4b278793          	addi	a5,a5,1202 # 80022368 <log>
    80003ebe:	97b2                	add	a5,a5,a2
    80003ec0:	44d8                	lw	a4,12(s1)
    80003ec2:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003ec4:	8526                	mv	a0,s1
    80003ec6:	ef1fe0ef          	jal	80002db6 <bpin>
    log.lh.n++;
    80003eca:	0001e717          	auipc	a4,0x1e
    80003ece:	49e70713          	addi	a4,a4,1182 # 80022368 <log>
    80003ed2:	571c                	lw	a5,40(a4)
    80003ed4:	2785                	addiw	a5,a5,1
    80003ed6:	d71c                	sw	a5,40(a4)
    80003ed8:	a80d                	j	80003f0a <log_write+0xaa>
    panic("too big a transaction");
    80003eda:	00003517          	auipc	a0,0x3
    80003ede:	65650513          	addi	a0,a0,1622 # 80007530 <etext+0x530>
    80003ee2:	8fffc0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    80003ee6:	00003517          	auipc	a0,0x3
    80003eea:	66250513          	addi	a0,a0,1634 # 80007548 <etext+0x548>
    80003eee:	8f3fc0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    80003ef2:	00878693          	addi	a3,a5,8
    80003ef6:	068a                	slli	a3,a3,0x2
    80003ef8:	0001e717          	auipc	a4,0x1e
    80003efc:	47070713          	addi	a4,a4,1136 # 80022368 <log>
    80003f00:	9736                	add	a4,a4,a3
    80003f02:	44d4                	lw	a3,12(s1)
    80003f04:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003f06:	faf60fe3          	beq	a2,a5,80003ec4 <log_write+0x64>
  }
  release(&log.lock);
    80003f0a:	0001e517          	auipc	a0,0x1e
    80003f0e:	45e50513          	addi	a0,a0,1118 # 80022368 <log>
    80003f12:	d55fc0ef          	jal	80000c66 <release>
}
    80003f16:	60e2                	ld	ra,24(sp)
    80003f18:	6442                	ld	s0,16(sp)
    80003f1a:	64a2                	ld	s1,8(sp)
    80003f1c:	6902                	ld	s2,0(sp)
    80003f1e:	6105                	addi	sp,sp,32
    80003f20:	8082                	ret

0000000080003f22 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003f22:	1101                	addi	sp,sp,-32
    80003f24:	ec06                	sd	ra,24(sp)
    80003f26:	e822                	sd	s0,16(sp)
    80003f28:	e426                	sd	s1,8(sp)
    80003f2a:	e04a                	sd	s2,0(sp)
    80003f2c:	1000                	addi	s0,sp,32
    80003f2e:	84aa                	mv	s1,a0
    80003f30:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003f32:	00003597          	auipc	a1,0x3
    80003f36:	63658593          	addi	a1,a1,1590 # 80007568 <etext+0x568>
    80003f3a:	0521                	addi	a0,a0,8
    80003f3c:	c13fc0ef          	jal	80000b4e <initlock>
  lk->name = name;
    80003f40:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003f44:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f48:	0204a423          	sw	zero,40(s1)
}
    80003f4c:	60e2                	ld	ra,24(sp)
    80003f4e:	6442                	ld	s0,16(sp)
    80003f50:	64a2                	ld	s1,8(sp)
    80003f52:	6902                	ld	s2,0(sp)
    80003f54:	6105                	addi	sp,sp,32
    80003f56:	8082                	ret

0000000080003f58 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003f58:	1101                	addi	sp,sp,-32
    80003f5a:	ec06                	sd	ra,24(sp)
    80003f5c:	e822                	sd	s0,16(sp)
    80003f5e:	e426                	sd	s1,8(sp)
    80003f60:	e04a                	sd	s2,0(sp)
    80003f62:	1000                	addi	s0,sp,32
    80003f64:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f66:	00850913          	addi	s2,a0,8
    80003f6a:	854a                	mv	a0,s2
    80003f6c:	c63fc0ef          	jal	80000bce <acquire>
  while (lk->locked) {
    80003f70:	409c                	lw	a5,0(s1)
    80003f72:	c799                	beqz	a5,80003f80 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003f74:	85ca                	mv	a1,s2
    80003f76:	8526                	mv	a0,s1
    80003f78:	f61fd0ef          	jal	80001ed8 <sleep>
  while (lk->locked) {
    80003f7c:	409c                	lw	a5,0(s1)
    80003f7e:	fbfd                	bnez	a5,80003f74 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003f80:	4785                	li	a5,1
    80003f82:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003f84:	94bfd0ef          	jal	800018ce <myproc>
    80003f88:	591c                	lw	a5,48(a0)
    80003f8a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003f8c:	854a                	mv	a0,s2
    80003f8e:	cd9fc0ef          	jal	80000c66 <release>
}
    80003f92:	60e2                	ld	ra,24(sp)
    80003f94:	6442                	ld	s0,16(sp)
    80003f96:	64a2                	ld	s1,8(sp)
    80003f98:	6902                	ld	s2,0(sp)
    80003f9a:	6105                	addi	sp,sp,32
    80003f9c:	8082                	ret

0000000080003f9e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003f9e:	1101                	addi	sp,sp,-32
    80003fa0:	ec06                	sd	ra,24(sp)
    80003fa2:	e822                	sd	s0,16(sp)
    80003fa4:	e426                	sd	s1,8(sp)
    80003fa6:	e04a                	sd	s2,0(sp)
    80003fa8:	1000                	addi	s0,sp,32
    80003faa:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003fac:	00850913          	addi	s2,a0,8
    80003fb0:	854a                	mv	a0,s2
    80003fb2:	c1dfc0ef          	jal	80000bce <acquire>
  lk->locked = 0;
    80003fb6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003fba:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003fbe:	8526                	mv	a0,s1
    80003fc0:	f65fd0ef          	jal	80001f24 <wakeup>
  release(&lk->lk);
    80003fc4:	854a                	mv	a0,s2
    80003fc6:	ca1fc0ef          	jal	80000c66 <release>
}
    80003fca:	60e2                	ld	ra,24(sp)
    80003fcc:	6442                	ld	s0,16(sp)
    80003fce:	64a2                	ld	s1,8(sp)
    80003fd0:	6902                	ld	s2,0(sp)
    80003fd2:	6105                	addi	sp,sp,32
    80003fd4:	8082                	ret

0000000080003fd6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003fd6:	7179                	addi	sp,sp,-48
    80003fd8:	f406                	sd	ra,40(sp)
    80003fda:	f022                	sd	s0,32(sp)
    80003fdc:	ec26                	sd	s1,24(sp)
    80003fde:	e84a                	sd	s2,16(sp)
    80003fe0:	1800                	addi	s0,sp,48
    80003fe2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003fe4:	00850913          	addi	s2,a0,8
    80003fe8:	854a                	mv	a0,s2
    80003fea:	be5fc0ef          	jal	80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003fee:	409c                	lw	a5,0(s1)
    80003ff0:	ef81                	bnez	a5,80004008 <holdingsleep+0x32>
    80003ff2:	4481                	li	s1,0
  release(&lk->lk);
    80003ff4:	854a                	mv	a0,s2
    80003ff6:	c71fc0ef          	jal	80000c66 <release>
  return r;
}
    80003ffa:	8526                	mv	a0,s1
    80003ffc:	70a2                	ld	ra,40(sp)
    80003ffe:	7402                	ld	s0,32(sp)
    80004000:	64e2                	ld	s1,24(sp)
    80004002:	6942                	ld	s2,16(sp)
    80004004:	6145                	addi	sp,sp,48
    80004006:	8082                	ret
    80004008:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000400a:	0284a983          	lw	s3,40(s1)
    8000400e:	8c1fd0ef          	jal	800018ce <myproc>
    80004012:	5904                	lw	s1,48(a0)
    80004014:	413484b3          	sub	s1,s1,s3
    80004018:	0014b493          	seqz	s1,s1
    8000401c:	69a2                	ld	s3,8(sp)
    8000401e:	bfd9                	j	80003ff4 <holdingsleep+0x1e>

0000000080004020 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004020:	1141                	addi	sp,sp,-16
    80004022:	e406                	sd	ra,8(sp)
    80004024:	e022                	sd	s0,0(sp)
    80004026:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004028:	00003597          	auipc	a1,0x3
    8000402c:	55058593          	addi	a1,a1,1360 # 80007578 <etext+0x578>
    80004030:	0001e517          	auipc	a0,0x1e
    80004034:	48050513          	addi	a0,a0,1152 # 800224b0 <ftable>
    80004038:	b17fc0ef          	jal	80000b4e <initlock>
}
    8000403c:	60a2                	ld	ra,8(sp)
    8000403e:	6402                	ld	s0,0(sp)
    80004040:	0141                	addi	sp,sp,16
    80004042:	8082                	ret

0000000080004044 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004044:	1101                	addi	sp,sp,-32
    80004046:	ec06                	sd	ra,24(sp)
    80004048:	e822                	sd	s0,16(sp)
    8000404a:	e426                	sd	s1,8(sp)
    8000404c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000404e:	0001e517          	auipc	a0,0x1e
    80004052:	46250513          	addi	a0,a0,1122 # 800224b0 <ftable>
    80004056:	b79fc0ef          	jal	80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000405a:	0001e497          	auipc	s1,0x1e
    8000405e:	46e48493          	addi	s1,s1,1134 # 800224c8 <ftable+0x18>
    80004062:	0001f717          	auipc	a4,0x1f
    80004066:	40670713          	addi	a4,a4,1030 # 80023468 <disk>
    if(f->ref == 0){
    8000406a:	40dc                	lw	a5,4(s1)
    8000406c:	cf89                	beqz	a5,80004086 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000406e:	02848493          	addi	s1,s1,40
    80004072:	fee49ce3          	bne	s1,a4,8000406a <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004076:	0001e517          	auipc	a0,0x1e
    8000407a:	43a50513          	addi	a0,a0,1082 # 800224b0 <ftable>
    8000407e:	be9fc0ef          	jal	80000c66 <release>
  return 0;
    80004082:	4481                	li	s1,0
    80004084:	a809                	j	80004096 <filealloc+0x52>
      f->ref = 1;
    80004086:	4785                	li	a5,1
    80004088:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000408a:	0001e517          	auipc	a0,0x1e
    8000408e:	42650513          	addi	a0,a0,1062 # 800224b0 <ftable>
    80004092:	bd5fc0ef          	jal	80000c66 <release>
}
    80004096:	8526                	mv	a0,s1
    80004098:	60e2                	ld	ra,24(sp)
    8000409a:	6442                	ld	s0,16(sp)
    8000409c:	64a2                	ld	s1,8(sp)
    8000409e:	6105                	addi	sp,sp,32
    800040a0:	8082                	ret

00000000800040a2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800040a2:	1101                	addi	sp,sp,-32
    800040a4:	ec06                	sd	ra,24(sp)
    800040a6:	e822                	sd	s0,16(sp)
    800040a8:	e426                	sd	s1,8(sp)
    800040aa:	1000                	addi	s0,sp,32
    800040ac:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800040ae:	0001e517          	auipc	a0,0x1e
    800040b2:	40250513          	addi	a0,a0,1026 # 800224b0 <ftable>
    800040b6:	b19fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    800040ba:	40dc                	lw	a5,4(s1)
    800040bc:	02f05063          	blez	a5,800040dc <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800040c0:	2785                	addiw	a5,a5,1
    800040c2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800040c4:	0001e517          	auipc	a0,0x1e
    800040c8:	3ec50513          	addi	a0,a0,1004 # 800224b0 <ftable>
    800040cc:	b9bfc0ef          	jal	80000c66 <release>
  return f;
}
    800040d0:	8526                	mv	a0,s1
    800040d2:	60e2                	ld	ra,24(sp)
    800040d4:	6442                	ld	s0,16(sp)
    800040d6:	64a2                	ld	s1,8(sp)
    800040d8:	6105                	addi	sp,sp,32
    800040da:	8082                	ret
    panic("filedup");
    800040dc:	00003517          	auipc	a0,0x3
    800040e0:	4a450513          	addi	a0,a0,1188 # 80007580 <etext+0x580>
    800040e4:	efcfc0ef          	jal	800007e0 <panic>

00000000800040e8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800040e8:	7139                	addi	sp,sp,-64
    800040ea:	fc06                	sd	ra,56(sp)
    800040ec:	f822                	sd	s0,48(sp)
    800040ee:	f426                	sd	s1,40(sp)
    800040f0:	0080                	addi	s0,sp,64
    800040f2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800040f4:	0001e517          	auipc	a0,0x1e
    800040f8:	3bc50513          	addi	a0,a0,956 # 800224b0 <ftable>
    800040fc:	ad3fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80004100:	40dc                	lw	a5,4(s1)
    80004102:	04f05a63          	blez	a5,80004156 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004106:	37fd                	addiw	a5,a5,-1
    80004108:	0007871b          	sext.w	a4,a5
    8000410c:	c0dc                	sw	a5,4(s1)
    8000410e:	04e04e63          	bgtz	a4,8000416a <fileclose+0x82>
    80004112:	f04a                	sd	s2,32(sp)
    80004114:	ec4e                	sd	s3,24(sp)
    80004116:	e852                	sd	s4,16(sp)
    80004118:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000411a:	0004a903          	lw	s2,0(s1)
    8000411e:	0094ca83          	lbu	s5,9(s1)
    80004122:	0104ba03          	ld	s4,16(s1)
    80004126:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000412a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000412e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004132:	0001e517          	auipc	a0,0x1e
    80004136:	37e50513          	addi	a0,a0,894 # 800224b0 <ftable>
    8000413a:	b2dfc0ef          	jal	80000c66 <release>

  if(ff.type == FD_PIPE){
    8000413e:	4785                	li	a5,1
    80004140:	04f90063          	beq	s2,a5,80004180 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004144:	3979                	addiw	s2,s2,-2
    80004146:	4785                	li	a5,1
    80004148:	0527f563          	bgeu	a5,s2,80004192 <fileclose+0xaa>
    8000414c:	7902                	ld	s2,32(sp)
    8000414e:	69e2                	ld	s3,24(sp)
    80004150:	6a42                	ld	s4,16(sp)
    80004152:	6aa2                	ld	s5,8(sp)
    80004154:	a00d                	j	80004176 <fileclose+0x8e>
    80004156:	f04a                	sd	s2,32(sp)
    80004158:	ec4e                	sd	s3,24(sp)
    8000415a:	e852                	sd	s4,16(sp)
    8000415c:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000415e:	00003517          	auipc	a0,0x3
    80004162:	42a50513          	addi	a0,a0,1066 # 80007588 <etext+0x588>
    80004166:	e7afc0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    8000416a:	0001e517          	auipc	a0,0x1e
    8000416e:	34650513          	addi	a0,a0,838 # 800224b0 <ftable>
    80004172:	af5fc0ef          	jal	80000c66 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004176:	70e2                	ld	ra,56(sp)
    80004178:	7442                	ld	s0,48(sp)
    8000417a:	74a2                	ld	s1,40(sp)
    8000417c:	6121                	addi	sp,sp,64
    8000417e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004180:	85d6                	mv	a1,s5
    80004182:	8552                	mv	a0,s4
    80004184:	336000ef          	jal	800044ba <pipeclose>
    80004188:	7902                	ld	s2,32(sp)
    8000418a:	69e2                	ld	s3,24(sp)
    8000418c:	6a42                	ld	s4,16(sp)
    8000418e:	6aa2                	ld	s5,8(sp)
    80004190:	b7dd                	j	80004176 <fileclose+0x8e>
    begin_op();
    80004192:	b4bff0ef          	jal	80003cdc <begin_op>
    iput(ff.ip);
    80004196:	854e                	mv	a0,s3
    80004198:	adcff0ef          	jal	80003474 <iput>
    end_op();
    8000419c:	babff0ef          	jal	80003d46 <end_op>
    800041a0:	7902                	ld	s2,32(sp)
    800041a2:	69e2                	ld	s3,24(sp)
    800041a4:	6a42                	ld	s4,16(sp)
    800041a6:	6aa2                	ld	s5,8(sp)
    800041a8:	b7f9                	j	80004176 <fileclose+0x8e>

00000000800041aa <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800041aa:	715d                	addi	sp,sp,-80
    800041ac:	e486                	sd	ra,72(sp)
    800041ae:	e0a2                	sd	s0,64(sp)
    800041b0:	fc26                	sd	s1,56(sp)
    800041b2:	f44e                	sd	s3,40(sp)
    800041b4:	0880                	addi	s0,sp,80
    800041b6:	84aa                	mv	s1,a0
    800041b8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800041ba:	f14fd0ef          	jal	800018ce <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800041be:	409c                	lw	a5,0(s1)
    800041c0:	37f9                	addiw	a5,a5,-2
    800041c2:	4705                	li	a4,1
    800041c4:	04f76063          	bltu	a4,a5,80004204 <filestat+0x5a>
    800041c8:	f84a                	sd	s2,48(sp)
    800041ca:	892a                	mv	s2,a0
    ilock(f->ip);
    800041cc:	6c88                	ld	a0,24(s1)
    800041ce:	924ff0ef          	jal	800032f2 <ilock>
    stati(f->ip, &st);
    800041d2:	fb840593          	addi	a1,s0,-72
    800041d6:	6c88                	ld	a0,24(s1)
    800041d8:	c80ff0ef          	jal	80003658 <stati>
    iunlock(f->ip);
    800041dc:	6c88                	ld	a0,24(s1)
    800041de:	9c2ff0ef          	jal	800033a0 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800041e2:	46e1                	li	a3,24
    800041e4:	fb840613          	addi	a2,s0,-72
    800041e8:	85ce                	mv	a1,s3
    800041ea:	05093503          	ld	a0,80(s2)
    800041ee:	bf4fd0ef          	jal	800015e2 <copyout>
    800041f2:	41f5551b          	sraiw	a0,a0,0x1f
    800041f6:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800041f8:	60a6                	ld	ra,72(sp)
    800041fa:	6406                	ld	s0,64(sp)
    800041fc:	74e2                	ld	s1,56(sp)
    800041fe:	79a2                	ld	s3,40(sp)
    80004200:	6161                	addi	sp,sp,80
    80004202:	8082                	ret
  return -1;
    80004204:	557d                	li	a0,-1
    80004206:	bfcd                	j	800041f8 <filestat+0x4e>

0000000080004208 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004208:	7179                	addi	sp,sp,-48
    8000420a:	f406                	sd	ra,40(sp)
    8000420c:	f022                	sd	s0,32(sp)
    8000420e:	e84a                	sd	s2,16(sp)
    80004210:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004212:	00854783          	lbu	a5,8(a0)
    80004216:	cfd1                	beqz	a5,800042b2 <fileread+0xaa>
    80004218:	ec26                	sd	s1,24(sp)
    8000421a:	e44e                	sd	s3,8(sp)
    8000421c:	84aa                	mv	s1,a0
    8000421e:	89ae                	mv	s3,a1
    80004220:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004222:	411c                	lw	a5,0(a0)
    80004224:	4705                	li	a4,1
    80004226:	04e78363          	beq	a5,a4,8000426c <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000422a:	470d                	li	a4,3
    8000422c:	04e78763          	beq	a5,a4,8000427a <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004230:	4709                	li	a4,2
    80004232:	06e79a63          	bne	a5,a4,800042a6 <fileread+0x9e>
    ilock(f->ip);
    80004236:	6d08                	ld	a0,24(a0)
    80004238:	8baff0ef          	jal	800032f2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000423c:	874a                	mv	a4,s2
    8000423e:	5094                	lw	a3,32(s1)
    80004240:	864e                	mv	a2,s3
    80004242:	4585                	li	a1,1
    80004244:	6c88                	ld	a0,24(s1)
    80004246:	c3cff0ef          	jal	80003682 <readi>
    8000424a:	892a                	mv	s2,a0
    8000424c:	00a05563          	blez	a0,80004256 <fileread+0x4e>
      f->off += r;
    80004250:	509c                	lw	a5,32(s1)
    80004252:	9fa9                	addw	a5,a5,a0
    80004254:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004256:	6c88                	ld	a0,24(s1)
    80004258:	948ff0ef          	jal	800033a0 <iunlock>
    8000425c:	64e2                	ld	s1,24(sp)
    8000425e:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004260:	854a                	mv	a0,s2
    80004262:	70a2                	ld	ra,40(sp)
    80004264:	7402                	ld	s0,32(sp)
    80004266:	6942                	ld	s2,16(sp)
    80004268:	6145                	addi	sp,sp,48
    8000426a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000426c:	6908                	ld	a0,16(a0)
    8000426e:	388000ef          	jal	800045f6 <piperead>
    80004272:	892a                	mv	s2,a0
    80004274:	64e2                	ld	s1,24(sp)
    80004276:	69a2                	ld	s3,8(sp)
    80004278:	b7e5                	j	80004260 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000427a:	02451783          	lh	a5,36(a0)
    8000427e:	03079693          	slli	a3,a5,0x30
    80004282:	92c1                	srli	a3,a3,0x30
    80004284:	4725                	li	a4,9
    80004286:	02d76863          	bltu	a4,a3,800042b6 <fileread+0xae>
    8000428a:	0792                	slli	a5,a5,0x4
    8000428c:	0001e717          	auipc	a4,0x1e
    80004290:	18470713          	addi	a4,a4,388 # 80022410 <devsw>
    80004294:	97ba                	add	a5,a5,a4
    80004296:	639c                	ld	a5,0(a5)
    80004298:	c39d                	beqz	a5,800042be <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    8000429a:	4505                	li	a0,1
    8000429c:	9782                	jalr	a5
    8000429e:	892a                	mv	s2,a0
    800042a0:	64e2                	ld	s1,24(sp)
    800042a2:	69a2                	ld	s3,8(sp)
    800042a4:	bf75                	j	80004260 <fileread+0x58>
    panic("fileread");
    800042a6:	00003517          	auipc	a0,0x3
    800042aa:	2f250513          	addi	a0,a0,754 # 80007598 <etext+0x598>
    800042ae:	d32fc0ef          	jal	800007e0 <panic>
    return -1;
    800042b2:	597d                	li	s2,-1
    800042b4:	b775                	j	80004260 <fileread+0x58>
      return -1;
    800042b6:	597d                	li	s2,-1
    800042b8:	64e2                	ld	s1,24(sp)
    800042ba:	69a2                	ld	s3,8(sp)
    800042bc:	b755                	j	80004260 <fileread+0x58>
    800042be:	597d                	li	s2,-1
    800042c0:	64e2                	ld	s1,24(sp)
    800042c2:	69a2                	ld	s3,8(sp)
    800042c4:	bf71                	j	80004260 <fileread+0x58>

00000000800042c6 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800042c6:	00954783          	lbu	a5,9(a0)
    800042ca:	10078b63          	beqz	a5,800043e0 <filewrite+0x11a>
{
    800042ce:	715d                	addi	sp,sp,-80
    800042d0:	e486                	sd	ra,72(sp)
    800042d2:	e0a2                	sd	s0,64(sp)
    800042d4:	f84a                	sd	s2,48(sp)
    800042d6:	f052                	sd	s4,32(sp)
    800042d8:	e85a                	sd	s6,16(sp)
    800042da:	0880                	addi	s0,sp,80
    800042dc:	892a                	mv	s2,a0
    800042de:	8b2e                	mv	s6,a1
    800042e0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800042e2:	411c                	lw	a5,0(a0)
    800042e4:	4705                	li	a4,1
    800042e6:	02e78763          	beq	a5,a4,80004314 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800042ea:	470d                	li	a4,3
    800042ec:	02e78863          	beq	a5,a4,8000431c <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800042f0:	4709                	li	a4,2
    800042f2:	0ce79c63          	bne	a5,a4,800043ca <filewrite+0x104>
    800042f6:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800042f8:	0ac05863          	blez	a2,800043a8 <filewrite+0xe2>
    800042fc:	fc26                	sd	s1,56(sp)
    800042fe:	ec56                	sd	s5,24(sp)
    80004300:	e45e                	sd	s7,8(sp)
    80004302:	e062                	sd	s8,0(sp)
    int i = 0;
    80004304:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004306:	6b85                	lui	s7,0x1
    80004308:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000430c:	6c05                	lui	s8,0x1
    8000430e:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004312:	a8b5                	j	8000438e <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004314:	6908                	ld	a0,16(a0)
    80004316:	1fc000ef          	jal	80004512 <pipewrite>
    8000431a:	a04d                	j	800043bc <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000431c:	02451783          	lh	a5,36(a0)
    80004320:	03079693          	slli	a3,a5,0x30
    80004324:	92c1                	srli	a3,a3,0x30
    80004326:	4725                	li	a4,9
    80004328:	0ad76e63          	bltu	a4,a3,800043e4 <filewrite+0x11e>
    8000432c:	0792                	slli	a5,a5,0x4
    8000432e:	0001e717          	auipc	a4,0x1e
    80004332:	0e270713          	addi	a4,a4,226 # 80022410 <devsw>
    80004336:	97ba                	add	a5,a5,a4
    80004338:	679c                	ld	a5,8(a5)
    8000433a:	c7dd                	beqz	a5,800043e8 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000433c:	4505                	li	a0,1
    8000433e:	9782                	jalr	a5
    80004340:	a8b5                	j	800043bc <filewrite+0xf6>
      if(n1 > max)
    80004342:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004346:	997ff0ef          	jal	80003cdc <begin_op>
      ilock(f->ip);
    8000434a:	01893503          	ld	a0,24(s2)
    8000434e:	fa5fe0ef          	jal	800032f2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004352:	8756                	mv	a4,s5
    80004354:	02092683          	lw	a3,32(s2)
    80004358:	01698633          	add	a2,s3,s6
    8000435c:	4585                	li	a1,1
    8000435e:	01893503          	ld	a0,24(s2)
    80004362:	c1cff0ef          	jal	8000377e <writei>
    80004366:	84aa                	mv	s1,a0
    80004368:	00a05763          	blez	a0,80004376 <filewrite+0xb0>
        f->off += r;
    8000436c:	02092783          	lw	a5,32(s2)
    80004370:	9fa9                	addw	a5,a5,a0
    80004372:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004376:	01893503          	ld	a0,24(s2)
    8000437a:	826ff0ef          	jal	800033a0 <iunlock>
      end_op();
    8000437e:	9c9ff0ef          	jal	80003d46 <end_op>

      if(r != n1){
    80004382:	029a9563          	bne	s5,s1,800043ac <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004386:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000438a:	0149da63          	bge	s3,s4,8000439e <filewrite+0xd8>
      int n1 = n - i;
    8000438e:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004392:	0004879b          	sext.w	a5,s1
    80004396:	fafbd6e3          	bge	s7,a5,80004342 <filewrite+0x7c>
    8000439a:	84e2                	mv	s1,s8
    8000439c:	b75d                	j	80004342 <filewrite+0x7c>
    8000439e:	74e2                	ld	s1,56(sp)
    800043a0:	6ae2                	ld	s5,24(sp)
    800043a2:	6ba2                	ld	s7,8(sp)
    800043a4:	6c02                	ld	s8,0(sp)
    800043a6:	a039                	j	800043b4 <filewrite+0xee>
    int i = 0;
    800043a8:	4981                	li	s3,0
    800043aa:	a029                	j	800043b4 <filewrite+0xee>
    800043ac:	74e2                	ld	s1,56(sp)
    800043ae:	6ae2                	ld	s5,24(sp)
    800043b0:	6ba2                	ld	s7,8(sp)
    800043b2:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    800043b4:	033a1c63          	bne	s4,s3,800043ec <filewrite+0x126>
    800043b8:	8552                	mv	a0,s4
    800043ba:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800043bc:	60a6                	ld	ra,72(sp)
    800043be:	6406                	ld	s0,64(sp)
    800043c0:	7942                	ld	s2,48(sp)
    800043c2:	7a02                	ld	s4,32(sp)
    800043c4:	6b42                	ld	s6,16(sp)
    800043c6:	6161                	addi	sp,sp,80
    800043c8:	8082                	ret
    800043ca:	fc26                	sd	s1,56(sp)
    800043cc:	f44e                	sd	s3,40(sp)
    800043ce:	ec56                	sd	s5,24(sp)
    800043d0:	e45e                	sd	s7,8(sp)
    800043d2:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800043d4:	00003517          	auipc	a0,0x3
    800043d8:	1d450513          	addi	a0,a0,468 # 800075a8 <etext+0x5a8>
    800043dc:	c04fc0ef          	jal	800007e0 <panic>
    return -1;
    800043e0:	557d                	li	a0,-1
}
    800043e2:	8082                	ret
      return -1;
    800043e4:	557d                	li	a0,-1
    800043e6:	bfd9                	j	800043bc <filewrite+0xf6>
    800043e8:	557d                	li	a0,-1
    800043ea:	bfc9                	j	800043bc <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800043ec:	557d                	li	a0,-1
    800043ee:	79a2                	ld	s3,40(sp)
    800043f0:	b7f1                	j	800043bc <filewrite+0xf6>

00000000800043f2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800043f2:	7179                	addi	sp,sp,-48
    800043f4:	f406                	sd	ra,40(sp)
    800043f6:	f022                	sd	s0,32(sp)
    800043f8:	ec26                	sd	s1,24(sp)
    800043fa:	e052                	sd	s4,0(sp)
    800043fc:	1800                	addi	s0,sp,48
    800043fe:	84aa                	mv	s1,a0
    80004400:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004402:	0005b023          	sd	zero,0(a1)
    80004406:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000440a:	c3bff0ef          	jal	80004044 <filealloc>
    8000440e:	e088                	sd	a0,0(s1)
    80004410:	c549                	beqz	a0,8000449a <pipealloc+0xa8>
    80004412:	c33ff0ef          	jal	80004044 <filealloc>
    80004416:	00aa3023          	sd	a0,0(s4)
    8000441a:	cd25                	beqz	a0,80004492 <pipealloc+0xa0>
    8000441c:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000441e:	ee0fc0ef          	jal	80000afe <kalloc>
    80004422:	892a                	mv	s2,a0
    80004424:	c12d                	beqz	a0,80004486 <pipealloc+0x94>
    80004426:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004428:	4985                	li	s3,1
    8000442a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000442e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004432:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004436:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000443a:	00003597          	auipc	a1,0x3
    8000443e:	17e58593          	addi	a1,a1,382 # 800075b8 <etext+0x5b8>
    80004442:	f0cfc0ef          	jal	80000b4e <initlock>
  (*f0)->type = FD_PIPE;
    80004446:	609c                	ld	a5,0(s1)
    80004448:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000444c:	609c                	ld	a5,0(s1)
    8000444e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004452:	609c                	ld	a5,0(s1)
    80004454:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004458:	609c                	ld	a5,0(s1)
    8000445a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000445e:	000a3783          	ld	a5,0(s4)
    80004462:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004466:	000a3783          	ld	a5,0(s4)
    8000446a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000446e:	000a3783          	ld	a5,0(s4)
    80004472:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004476:	000a3783          	ld	a5,0(s4)
    8000447a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000447e:	4501                	li	a0,0
    80004480:	6942                	ld	s2,16(sp)
    80004482:	69a2                	ld	s3,8(sp)
    80004484:	a01d                	j	800044aa <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004486:	6088                	ld	a0,0(s1)
    80004488:	c119                	beqz	a0,8000448e <pipealloc+0x9c>
    8000448a:	6942                	ld	s2,16(sp)
    8000448c:	a029                	j	80004496 <pipealloc+0xa4>
    8000448e:	6942                	ld	s2,16(sp)
    80004490:	a029                	j	8000449a <pipealloc+0xa8>
    80004492:	6088                	ld	a0,0(s1)
    80004494:	c10d                	beqz	a0,800044b6 <pipealloc+0xc4>
    fileclose(*f0);
    80004496:	c53ff0ef          	jal	800040e8 <fileclose>
  if(*f1)
    8000449a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000449e:	557d                	li	a0,-1
  if(*f1)
    800044a0:	c789                	beqz	a5,800044aa <pipealloc+0xb8>
    fileclose(*f1);
    800044a2:	853e                	mv	a0,a5
    800044a4:	c45ff0ef          	jal	800040e8 <fileclose>
  return -1;
    800044a8:	557d                	li	a0,-1
}
    800044aa:	70a2                	ld	ra,40(sp)
    800044ac:	7402                	ld	s0,32(sp)
    800044ae:	64e2                	ld	s1,24(sp)
    800044b0:	6a02                	ld	s4,0(sp)
    800044b2:	6145                	addi	sp,sp,48
    800044b4:	8082                	ret
  return -1;
    800044b6:	557d                	li	a0,-1
    800044b8:	bfcd                	j	800044aa <pipealloc+0xb8>

00000000800044ba <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800044ba:	1101                	addi	sp,sp,-32
    800044bc:	ec06                	sd	ra,24(sp)
    800044be:	e822                	sd	s0,16(sp)
    800044c0:	e426                	sd	s1,8(sp)
    800044c2:	e04a                	sd	s2,0(sp)
    800044c4:	1000                	addi	s0,sp,32
    800044c6:	84aa                	mv	s1,a0
    800044c8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800044ca:	f04fc0ef          	jal	80000bce <acquire>
  if(writable){
    800044ce:	02090763          	beqz	s2,800044fc <pipeclose+0x42>
    pi->writeopen = 0;
    800044d2:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800044d6:	21848513          	addi	a0,s1,536
    800044da:	a4bfd0ef          	jal	80001f24 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800044de:	2204b783          	ld	a5,544(s1)
    800044e2:	e785                	bnez	a5,8000450a <pipeclose+0x50>
    release(&pi->lock);
    800044e4:	8526                	mv	a0,s1
    800044e6:	f80fc0ef          	jal	80000c66 <release>
    kfree((char*)pi);
    800044ea:	8526                	mv	a0,s1
    800044ec:	d30fc0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    800044f0:	60e2                	ld	ra,24(sp)
    800044f2:	6442                	ld	s0,16(sp)
    800044f4:	64a2                	ld	s1,8(sp)
    800044f6:	6902                	ld	s2,0(sp)
    800044f8:	6105                	addi	sp,sp,32
    800044fa:	8082                	ret
    pi->readopen = 0;
    800044fc:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004500:	21c48513          	addi	a0,s1,540
    80004504:	a21fd0ef          	jal	80001f24 <wakeup>
    80004508:	bfd9                	j	800044de <pipeclose+0x24>
    release(&pi->lock);
    8000450a:	8526                	mv	a0,s1
    8000450c:	f5afc0ef          	jal	80000c66 <release>
}
    80004510:	b7c5                	j	800044f0 <pipeclose+0x36>

0000000080004512 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004512:	711d                	addi	sp,sp,-96
    80004514:	ec86                	sd	ra,88(sp)
    80004516:	e8a2                	sd	s0,80(sp)
    80004518:	e4a6                	sd	s1,72(sp)
    8000451a:	e0ca                	sd	s2,64(sp)
    8000451c:	fc4e                	sd	s3,56(sp)
    8000451e:	f852                	sd	s4,48(sp)
    80004520:	f456                	sd	s5,40(sp)
    80004522:	1080                	addi	s0,sp,96
    80004524:	84aa                	mv	s1,a0
    80004526:	8aae                	mv	s5,a1
    80004528:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000452a:	ba4fd0ef          	jal	800018ce <myproc>
    8000452e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004530:	8526                	mv	a0,s1
    80004532:	e9cfc0ef          	jal	80000bce <acquire>
  while(i < n){
    80004536:	0b405a63          	blez	s4,800045ea <pipewrite+0xd8>
    8000453a:	f05a                	sd	s6,32(sp)
    8000453c:	ec5e                	sd	s7,24(sp)
    8000453e:	e862                	sd	s8,16(sp)
  int i = 0;
    80004540:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004542:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004544:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004548:	21c48b93          	addi	s7,s1,540
    8000454c:	a81d                	j	80004582 <pipewrite+0x70>
      release(&pi->lock);
    8000454e:	8526                	mv	a0,s1
    80004550:	f16fc0ef          	jal	80000c66 <release>
      return -1;
    80004554:	597d                	li	s2,-1
    80004556:	7b02                	ld	s6,32(sp)
    80004558:	6be2                	ld	s7,24(sp)
    8000455a:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000455c:	854a                	mv	a0,s2
    8000455e:	60e6                	ld	ra,88(sp)
    80004560:	6446                	ld	s0,80(sp)
    80004562:	64a6                	ld	s1,72(sp)
    80004564:	6906                	ld	s2,64(sp)
    80004566:	79e2                	ld	s3,56(sp)
    80004568:	7a42                	ld	s4,48(sp)
    8000456a:	7aa2                	ld	s5,40(sp)
    8000456c:	6125                	addi	sp,sp,96
    8000456e:	8082                	ret
      wakeup(&pi->nread);
    80004570:	8562                	mv	a0,s8
    80004572:	9b3fd0ef          	jal	80001f24 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004576:	85a6                	mv	a1,s1
    80004578:	855e                	mv	a0,s7
    8000457a:	95ffd0ef          	jal	80001ed8 <sleep>
  while(i < n){
    8000457e:	05495b63          	bge	s2,s4,800045d4 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80004582:	2204a783          	lw	a5,544(s1)
    80004586:	d7e1                	beqz	a5,8000454e <pipewrite+0x3c>
    80004588:	854e                	mv	a0,s3
    8000458a:	b87fd0ef          	jal	80002110 <killed>
    8000458e:	f161                	bnez	a0,8000454e <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004590:	2184a783          	lw	a5,536(s1)
    80004594:	21c4a703          	lw	a4,540(s1)
    80004598:	2007879b          	addiw	a5,a5,512
    8000459c:	fcf70ae3          	beq	a4,a5,80004570 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800045a0:	4685                	li	a3,1
    800045a2:	01590633          	add	a2,s2,s5
    800045a6:	faf40593          	addi	a1,s0,-81
    800045aa:	0509b503          	ld	a0,80(s3)
    800045ae:	918fd0ef          	jal	800016c6 <copyin>
    800045b2:	03650e63          	beq	a0,s6,800045ee <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800045b6:	21c4a783          	lw	a5,540(s1)
    800045ba:	0017871b          	addiw	a4,a5,1
    800045be:	20e4ae23          	sw	a4,540(s1)
    800045c2:	1ff7f793          	andi	a5,a5,511
    800045c6:	97a6                	add	a5,a5,s1
    800045c8:	faf44703          	lbu	a4,-81(s0)
    800045cc:	00e78c23          	sb	a4,24(a5)
      i++;
    800045d0:	2905                	addiw	s2,s2,1
    800045d2:	b775                	j	8000457e <pipewrite+0x6c>
    800045d4:	7b02                	ld	s6,32(sp)
    800045d6:	6be2                	ld	s7,24(sp)
    800045d8:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800045da:	21848513          	addi	a0,s1,536
    800045de:	947fd0ef          	jal	80001f24 <wakeup>
  release(&pi->lock);
    800045e2:	8526                	mv	a0,s1
    800045e4:	e82fc0ef          	jal	80000c66 <release>
  return i;
    800045e8:	bf95                	j	8000455c <pipewrite+0x4a>
  int i = 0;
    800045ea:	4901                	li	s2,0
    800045ec:	b7fd                	j	800045da <pipewrite+0xc8>
    800045ee:	7b02                	ld	s6,32(sp)
    800045f0:	6be2                	ld	s7,24(sp)
    800045f2:	6c42                	ld	s8,16(sp)
    800045f4:	b7dd                	j	800045da <pipewrite+0xc8>

00000000800045f6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800045f6:	715d                	addi	sp,sp,-80
    800045f8:	e486                	sd	ra,72(sp)
    800045fa:	e0a2                	sd	s0,64(sp)
    800045fc:	fc26                	sd	s1,56(sp)
    800045fe:	f84a                	sd	s2,48(sp)
    80004600:	f44e                	sd	s3,40(sp)
    80004602:	f052                	sd	s4,32(sp)
    80004604:	ec56                	sd	s5,24(sp)
    80004606:	0880                	addi	s0,sp,80
    80004608:	84aa                	mv	s1,a0
    8000460a:	892e                	mv	s2,a1
    8000460c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000460e:	ac0fd0ef          	jal	800018ce <myproc>
    80004612:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004614:	8526                	mv	a0,s1
    80004616:	db8fc0ef          	jal	80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000461a:	2184a703          	lw	a4,536(s1)
    8000461e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004622:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004626:	02f71563          	bne	a4,a5,80004650 <piperead+0x5a>
    8000462a:	2244a783          	lw	a5,548(s1)
    8000462e:	cb85                	beqz	a5,8000465e <piperead+0x68>
    if(killed(pr)){
    80004630:	8552                	mv	a0,s4
    80004632:	adffd0ef          	jal	80002110 <killed>
    80004636:	ed19                	bnez	a0,80004654 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004638:	85a6                	mv	a1,s1
    8000463a:	854e                	mv	a0,s3
    8000463c:	89dfd0ef          	jal	80001ed8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004640:	2184a703          	lw	a4,536(s1)
    80004644:	21c4a783          	lw	a5,540(s1)
    80004648:	fef701e3          	beq	a4,a5,8000462a <piperead+0x34>
    8000464c:	e85a                	sd	s6,16(sp)
    8000464e:	a809                	j	80004660 <piperead+0x6a>
    80004650:	e85a                	sd	s6,16(sp)
    80004652:	a039                	j	80004660 <piperead+0x6a>
      release(&pi->lock);
    80004654:	8526                	mv	a0,s1
    80004656:	e10fc0ef          	jal	80000c66 <release>
      return -1;
    8000465a:	59fd                	li	s3,-1
    8000465c:	a8b9                	j	800046ba <piperead+0xc4>
    8000465e:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004660:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004662:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004664:	05505363          	blez	s5,800046aa <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004668:	2184a783          	lw	a5,536(s1)
    8000466c:	21c4a703          	lw	a4,540(s1)
    80004670:	02f70d63          	beq	a4,a5,800046aa <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    80004674:	1ff7f793          	andi	a5,a5,511
    80004678:	97a6                	add	a5,a5,s1
    8000467a:	0187c783          	lbu	a5,24(a5)
    8000467e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004682:	4685                	li	a3,1
    80004684:	fbf40613          	addi	a2,s0,-65
    80004688:	85ca                	mv	a1,s2
    8000468a:	050a3503          	ld	a0,80(s4)
    8000468e:	f55fc0ef          	jal	800015e2 <copyout>
    80004692:	03650e63          	beq	a0,s6,800046ce <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004696:	2184a783          	lw	a5,536(s1)
    8000469a:	2785                	addiw	a5,a5,1
    8000469c:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800046a0:	2985                	addiw	s3,s3,1
    800046a2:	0905                	addi	s2,s2,1
    800046a4:	fd3a92e3          	bne	s5,s3,80004668 <piperead+0x72>
    800046a8:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800046aa:	21c48513          	addi	a0,s1,540
    800046ae:	877fd0ef          	jal	80001f24 <wakeup>
  release(&pi->lock);
    800046b2:	8526                	mv	a0,s1
    800046b4:	db2fc0ef          	jal	80000c66 <release>
    800046b8:	6b42                	ld	s6,16(sp)
  return i;
}
    800046ba:	854e                	mv	a0,s3
    800046bc:	60a6                	ld	ra,72(sp)
    800046be:	6406                	ld	s0,64(sp)
    800046c0:	74e2                	ld	s1,56(sp)
    800046c2:	7942                	ld	s2,48(sp)
    800046c4:	79a2                	ld	s3,40(sp)
    800046c6:	7a02                	ld	s4,32(sp)
    800046c8:	6ae2                	ld	s5,24(sp)
    800046ca:	6161                	addi	sp,sp,80
    800046cc:	8082                	ret
      if(i == 0)
    800046ce:	fc099ee3          	bnez	s3,800046aa <piperead+0xb4>
        i = -1;
    800046d2:	89aa                	mv	s3,a0
    800046d4:	bfd9                	j	800046aa <piperead+0xb4>

00000000800046d6 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800046d6:	1141                	addi	sp,sp,-16
    800046d8:	e422                	sd	s0,8(sp)
    800046da:	0800                	addi	s0,sp,16
    800046dc:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800046de:	8905                	andi	a0,a0,1
    800046e0:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800046e2:	8b89                	andi	a5,a5,2
    800046e4:	c399                	beqz	a5,800046ea <flags2perm+0x14>
      perm |= PTE_W;
    800046e6:	00456513          	ori	a0,a0,4
    return perm;
}
    800046ea:	6422                	ld	s0,8(sp)
    800046ec:	0141                	addi	sp,sp,16
    800046ee:	8082                	ret

00000000800046f0 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800046f0:	df010113          	addi	sp,sp,-528
    800046f4:	20113423          	sd	ra,520(sp)
    800046f8:	20813023          	sd	s0,512(sp)
    800046fc:	ffa6                	sd	s1,504(sp)
    800046fe:	fbca                	sd	s2,496(sp)
    80004700:	0c00                	addi	s0,sp,528
    80004702:	892a                	mv	s2,a0
    80004704:	dea43c23          	sd	a0,-520(s0)
    80004708:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000470c:	9c2fd0ef          	jal	800018ce <myproc>
    80004710:	84aa                	mv	s1,a0

  begin_op();
    80004712:	dcaff0ef          	jal	80003cdc <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004716:	854a                	mv	a0,s2
    80004718:	bf0ff0ef          	jal	80003b08 <namei>
    8000471c:	c931                	beqz	a0,80004770 <kexec+0x80>
    8000471e:	f3d2                	sd	s4,480(sp)
    80004720:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004722:	bd1fe0ef          	jal	800032f2 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004726:	04000713          	li	a4,64
    8000472a:	4681                	li	a3,0
    8000472c:	e5040613          	addi	a2,s0,-432
    80004730:	4581                	li	a1,0
    80004732:	8552                	mv	a0,s4
    80004734:	f4ffe0ef          	jal	80003682 <readi>
    80004738:	04000793          	li	a5,64
    8000473c:	00f51a63          	bne	a0,a5,80004750 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004740:	e5042703          	lw	a4,-432(s0)
    80004744:	464c47b7          	lui	a5,0x464c4
    80004748:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000474c:	02f70663          	beq	a4,a5,80004778 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004750:	8552                	mv	a0,s4
    80004752:	dabfe0ef          	jal	800034fc <iunlockput>
    end_op();
    80004756:	df0ff0ef          	jal	80003d46 <end_op>
  }
  return -1;
    8000475a:	557d                	li	a0,-1
    8000475c:	7a1e                	ld	s4,480(sp)
}
    8000475e:	20813083          	ld	ra,520(sp)
    80004762:	20013403          	ld	s0,512(sp)
    80004766:	74fe                	ld	s1,504(sp)
    80004768:	795e                	ld	s2,496(sp)
    8000476a:	21010113          	addi	sp,sp,528
    8000476e:	8082                	ret
    end_op();
    80004770:	dd6ff0ef          	jal	80003d46 <end_op>
    return -1;
    80004774:	557d                	li	a0,-1
    80004776:	b7e5                	j	8000475e <kexec+0x6e>
    80004778:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000477a:	8526                	mv	a0,s1
    8000477c:	a58fd0ef          	jal	800019d4 <proc_pagetable>
    80004780:	8b2a                	mv	s6,a0
    80004782:	2c050b63          	beqz	a0,80004a58 <kexec+0x368>
    80004786:	f7ce                	sd	s3,488(sp)
    80004788:	efd6                	sd	s5,472(sp)
    8000478a:	e7de                	sd	s7,456(sp)
    8000478c:	e3e2                	sd	s8,448(sp)
    8000478e:	ff66                	sd	s9,440(sp)
    80004790:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004792:	e7042d03          	lw	s10,-400(s0)
    80004796:	e8845783          	lhu	a5,-376(s0)
    8000479a:	12078963          	beqz	a5,800048cc <kexec+0x1dc>
    8000479e:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800047a0:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047a2:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800047a4:	6c85                	lui	s9,0x1
    800047a6:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800047aa:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800047ae:	6a85                	lui	s5,0x1
    800047b0:	a085                	j	80004810 <kexec+0x120>
      panic("loadseg: address should exist");
    800047b2:	00003517          	auipc	a0,0x3
    800047b6:	e0e50513          	addi	a0,a0,-498 # 800075c0 <etext+0x5c0>
    800047ba:	826fc0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    800047be:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800047c0:	8726                	mv	a4,s1
    800047c2:	012c06bb          	addw	a3,s8,s2
    800047c6:	4581                	li	a1,0
    800047c8:	8552                	mv	a0,s4
    800047ca:	eb9fe0ef          	jal	80003682 <readi>
    800047ce:	2501                	sext.w	a0,a0
    800047d0:	24a49a63          	bne	s1,a0,80004a24 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    800047d4:	012a893b          	addw	s2,s5,s2
    800047d8:	03397363          	bgeu	s2,s3,800047fe <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800047dc:	02091593          	slli	a1,s2,0x20
    800047e0:	9181                	srli	a1,a1,0x20
    800047e2:	95de                	add	a1,a1,s7
    800047e4:	855a                	mv	a0,s6
    800047e6:	fcafc0ef          	jal	80000fb0 <walkaddr>
    800047ea:	862a                	mv	a2,a0
    if(pa == 0)
    800047ec:	d179                	beqz	a0,800047b2 <kexec+0xc2>
    if(sz - i < PGSIZE)
    800047ee:	412984bb          	subw	s1,s3,s2
    800047f2:	0004879b          	sext.w	a5,s1
    800047f6:	fcfcf4e3          	bgeu	s9,a5,800047be <kexec+0xce>
    800047fa:	84d6                	mv	s1,s5
    800047fc:	b7c9                	j	800047be <kexec+0xce>
    sz = sz1;
    800047fe:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004802:	2d85                	addiw	s11,s11,1
    80004804:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004808:	e8845783          	lhu	a5,-376(s0)
    8000480c:	08fdd063          	bge	s11,a5,8000488c <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004810:	2d01                	sext.w	s10,s10
    80004812:	03800713          	li	a4,56
    80004816:	86ea                	mv	a3,s10
    80004818:	e1840613          	addi	a2,s0,-488
    8000481c:	4581                	li	a1,0
    8000481e:	8552                	mv	a0,s4
    80004820:	e63fe0ef          	jal	80003682 <readi>
    80004824:	03800793          	li	a5,56
    80004828:	1cf51663          	bne	a0,a5,800049f4 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    8000482c:	e1842783          	lw	a5,-488(s0)
    80004830:	4705                	li	a4,1
    80004832:	fce798e3          	bne	a5,a4,80004802 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80004836:	e4043483          	ld	s1,-448(s0)
    8000483a:	e3843783          	ld	a5,-456(s0)
    8000483e:	1af4ef63          	bltu	s1,a5,800049fc <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004842:	e2843783          	ld	a5,-472(s0)
    80004846:	94be                	add	s1,s1,a5
    80004848:	1af4ee63          	bltu	s1,a5,80004a04 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    8000484c:	df043703          	ld	a4,-528(s0)
    80004850:	8ff9                	and	a5,a5,a4
    80004852:	1a079d63          	bnez	a5,80004a0c <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004856:	e1c42503          	lw	a0,-484(s0)
    8000485a:	e7dff0ef          	jal	800046d6 <flags2perm>
    8000485e:	86aa                	mv	a3,a0
    80004860:	8626                	mv	a2,s1
    80004862:	85ca                	mv	a1,s2
    80004864:	855a                	mv	a0,s6
    80004866:	a23fc0ef          	jal	80001288 <uvmalloc>
    8000486a:	e0a43423          	sd	a0,-504(s0)
    8000486e:	1a050363          	beqz	a0,80004a14 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004872:	e2843b83          	ld	s7,-472(s0)
    80004876:	e2042c03          	lw	s8,-480(s0)
    8000487a:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000487e:	00098463          	beqz	s3,80004886 <kexec+0x196>
    80004882:	4901                	li	s2,0
    80004884:	bfa1                	j	800047dc <kexec+0xec>
    sz = sz1;
    80004886:	e0843903          	ld	s2,-504(s0)
    8000488a:	bfa5                	j	80004802 <kexec+0x112>
    8000488c:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    8000488e:	8552                	mv	a0,s4
    80004890:	c6dfe0ef          	jal	800034fc <iunlockput>
  end_op();
    80004894:	cb2ff0ef          	jal	80003d46 <end_op>
  p = myproc();
    80004898:	836fd0ef          	jal	800018ce <myproc>
    8000489c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000489e:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800048a2:	6985                	lui	s3,0x1
    800048a4:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800048a6:	99ca                	add	s3,s3,s2
    800048a8:	77fd                	lui	a5,0xfffff
    800048aa:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800048ae:	4691                	li	a3,4
    800048b0:	6609                	lui	a2,0x2
    800048b2:	964e                	add	a2,a2,s3
    800048b4:	85ce                	mv	a1,s3
    800048b6:	855a                	mv	a0,s6
    800048b8:	9d1fc0ef          	jal	80001288 <uvmalloc>
    800048bc:	892a                	mv	s2,a0
    800048be:	e0a43423          	sd	a0,-504(s0)
    800048c2:	e519                	bnez	a0,800048d0 <kexec+0x1e0>
  if(pagetable)
    800048c4:	e1343423          	sd	s3,-504(s0)
    800048c8:	4a01                	li	s4,0
    800048ca:	aab1                	j	80004a26 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800048cc:	4901                	li	s2,0
    800048ce:	b7c1                	j	8000488e <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800048d0:	75f9                	lui	a1,0xffffe
    800048d2:	95aa                	add	a1,a1,a0
    800048d4:	855a                	mv	a0,s6
    800048d6:	b89fc0ef          	jal	8000145e <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800048da:	7bfd                	lui	s7,0xfffff
    800048dc:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800048de:	e0043783          	ld	a5,-512(s0)
    800048e2:	6388                	ld	a0,0(a5)
    800048e4:	cd39                	beqz	a0,80004942 <kexec+0x252>
    800048e6:	e9040993          	addi	s3,s0,-368
    800048ea:	f9040c13          	addi	s8,s0,-112
    800048ee:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800048f0:	d22fc0ef          	jal	80000e12 <strlen>
    800048f4:	0015079b          	addiw	a5,a0,1
    800048f8:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800048fc:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004900:	11796e63          	bltu	s2,s7,80004a1c <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004904:	e0043d03          	ld	s10,-512(s0)
    80004908:	000d3a03          	ld	s4,0(s10)
    8000490c:	8552                	mv	a0,s4
    8000490e:	d04fc0ef          	jal	80000e12 <strlen>
    80004912:	0015069b          	addiw	a3,a0,1
    80004916:	8652                	mv	a2,s4
    80004918:	85ca                	mv	a1,s2
    8000491a:	855a                	mv	a0,s6
    8000491c:	cc7fc0ef          	jal	800015e2 <copyout>
    80004920:	10054063          	bltz	a0,80004a20 <kexec+0x330>
    ustack[argc] = sp;
    80004924:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004928:	0485                	addi	s1,s1,1
    8000492a:	008d0793          	addi	a5,s10,8
    8000492e:	e0f43023          	sd	a5,-512(s0)
    80004932:	008d3503          	ld	a0,8(s10)
    80004936:	c909                	beqz	a0,80004948 <kexec+0x258>
    if(argc >= MAXARG)
    80004938:	09a1                	addi	s3,s3,8
    8000493a:	fb899be3          	bne	s3,s8,800048f0 <kexec+0x200>
  ip = 0;
    8000493e:	4a01                	li	s4,0
    80004940:	a0dd                	j	80004a26 <kexec+0x336>
  sp = sz;
    80004942:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004946:	4481                	li	s1,0
  ustack[argc] = 0;
    80004948:	00349793          	slli	a5,s1,0x3
    8000494c:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb9e8>
    80004950:	97a2                	add	a5,a5,s0
    80004952:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004956:	00148693          	addi	a3,s1,1
    8000495a:	068e                	slli	a3,a3,0x3
    8000495c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004960:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004964:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004968:	f5796ee3          	bltu	s2,s7,800048c4 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000496c:	e9040613          	addi	a2,s0,-368
    80004970:	85ca                	mv	a1,s2
    80004972:	855a                	mv	a0,s6
    80004974:	c6ffc0ef          	jal	800015e2 <copyout>
    80004978:	0e054263          	bltz	a0,80004a5c <kexec+0x36c>
  p->trapframe->a1 = sp;
    8000497c:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004980:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004984:	df843783          	ld	a5,-520(s0)
    80004988:	0007c703          	lbu	a4,0(a5)
    8000498c:	cf11                	beqz	a4,800049a8 <kexec+0x2b8>
    8000498e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004990:	02f00693          	li	a3,47
    80004994:	a039                	j	800049a2 <kexec+0x2b2>
      last = s+1;
    80004996:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000499a:	0785                	addi	a5,a5,1
    8000499c:	fff7c703          	lbu	a4,-1(a5)
    800049a0:	c701                	beqz	a4,800049a8 <kexec+0x2b8>
    if(*s == '/')
    800049a2:	fed71ce3          	bne	a4,a3,8000499a <kexec+0x2aa>
    800049a6:	bfc5                	j	80004996 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    800049a8:	4641                	li	a2,16
    800049aa:	df843583          	ld	a1,-520(s0)
    800049ae:	158a8513          	addi	a0,s5,344
    800049b2:	c2efc0ef          	jal	80000de0 <safestrcpy>
  oldpagetable = p->pagetable;
    800049b6:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800049ba:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800049be:	e0843783          	ld	a5,-504(s0)
    800049c2:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    800049c6:	058ab783          	ld	a5,88(s5)
    800049ca:	e6843703          	ld	a4,-408(s0)
    800049ce:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800049d0:	058ab783          	ld	a5,88(s5)
    800049d4:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800049d8:	85e6                	mv	a1,s9
    800049da:	87efd0ef          	jal	80001a58 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800049de:	0004851b          	sext.w	a0,s1
    800049e2:	79be                	ld	s3,488(sp)
    800049e4:	7a1e                	ld	s4,480(sp)
    800049e6:	6afe                	ld	s5,472(sp)
    800049e8:	6b5e                	ld	s6,464(sp)
    800049ea:	6bbe                	ld	s7,456(sp)
    800049ec:	6c1e                	ld	s8,448(sp)
    800049ee:	7cfa                	ld	s9,440(sp)
    800049f0:	7d5a                	ld	s10,432(sp)
    800049f2:	b3b5                	j	8000475e <kexec+0x6e>
    800049f4:	e1243423          	sd	s2,-504(s0)
    800049f8:	7dba                	ld	s11,424(sp)
    800049fa:	a035                	j	80004a26 <kexec+0x336>
    800049fc:	e1243423          	sd	s2,-504(s0)
    80004a00:	7dba                	ld	s11,424(sp)
    80004a02:	a015                	j	80004a26 <kexec+0x336>
    80004a04:	e1243423          	sd	s2,-504(s0)
    80004a08:	7dba                	ld	s11,424(sp)
    80004a0a:	a831                	j	80004a26 <kexec+0x336>
    80004a0c:	e1243423          	sd	s2,-504(s0)
    80004a10:	7dba                	ld	s11,424(sp)
    80004a12:	a811                	j	80004a26 <kexec+0x336>
    80004a14:	e1243423          	sd	s2,-504(s0)
    80004a18:	7dba                	ld	s11,424(sp)
    80004a1a:	a031                	j	80004a26 <kexec+0x336>
  ip = 0;
    80004a1c:	4a01                	li	s4,0
    80004a1e:	a021                	j	80004a26 <kexec+0x336>
    80004a20:	4a01                	li	s4,0
  if(pagetable)
    80004a22:	a011                	j	80004a26 <kexec+0x336>
    80004a24:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004a26:	e0843583          	ld	a1,-504(s0)
    80004a2a:	855a                	mv	a0,s6
    80004a2c:	82cfd0ef          	jal	80001a58 <proc_freepagetable>
  return -1;
    80004a30:	557d                	li	a0,-1
  if(ip){
    80004a32:	000a1b63          	bnez	s4,80004a48 <kexec+0x358>
    80004a36:	79be                	ld	s3,488(sp)
    80004a38:	7a1e                	ld	s4,480(sp)
    80004a3a:	6afe                	ld	s5,472(sp)
    80004a3c:	6b5e                	ld	s6,464(sp)
    80004a3e:	6bbe                	ld	s7,456(sp)
    80004a40:	6c1e                	ld	s8,448(sp)
    80004a42:	7cfa                	ld	s9,440(sp)
    80004a44:	7d5a                	ld	s10,432(sp)
    80004a46:	bb21                	j	8000475e <kexec+0x6e>
    80004a48:	79be                	ld	s3,488(sp)
    80004a4a:	6afe                	ld	s5,472(sp)
    80004a4c:	6b5e                	ld	s6,464(sp)
    80004a4e:	6bbe                	ld	s7,456(sp)
    80004a50:	6c1e                	ld	s8,448(sp)
    80004a52:	7cfa                	ld	s9,440(sp)
    80004a54:	7d5a                	ld	s10,432(sp)
    80004a56:	b9ed                	j	80004750 <kexec+0x60>
    80004a58:	6b5e                	ld	s6,464(sp)
    80004a5a:	b9dd                	j	80004750 <kexec+0x60>
  sz = sz1;
    80004a5c:	e0843983          	ld	s3,-504(s0)
    80004a60:	b595                	j	800048c4 <kexec+0x1d4>

0000000080004a62 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004a62:	7179                	addi	sp,sp,-48
    80004a64:	f406                	sd	ra,40(sp)
    80004a66:	f022                	sd	s0,32(sp)
    80004a68:	ec26                	sd	s1,24(sp)
    80004a6a:	e84a                	sd	s2,16(sp)
    80004a6c:	1800                	addi	s0,sp,48
    80004a6e:	892e                	mv	s2,a1
    80004a70:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004a72:	fdc40593          	addi	a1,s0,-36
    80004a76:	d67fd0ef          	jal	800027dc <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004a7a:	fdc42703          	lw	a4,-36(s0)
    80004a7e:	47bd                	li	a5,15
    80004a80:	02e7e963          	bltu	a5,a4,80004ab2 <argfd+0x50>
    80004a84:	e4bfc0ef          	jal	800018ce <myproc>
    80004a88:	fdc42703          	lw	a4,-36(s0)
    80004a8c:	01a70793          	addi	a5,a4,26
    80004a90:	078e                	slli	a5,a5,0x3
    80004a92:	953e                	add	a0,a0,a5
    80004a94:	611c                	ld	a5,0(a0)
    80004a96:	c385                	beqz	a5,80004ab6 <argfd+0x54>
    return -1;
  if(pfd)
    80004a98:	00090463          	beqz	s2,80004aa0 <argfd+0x3e>
    *pfd = fd;
    80004a9c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004aa0:	4501                	li	a0,0
  if(pf)
    80004aa2:	c091                	beqz	s1,80004aa6 <argfd+0x44>
    *pf = f;
    80004aa4:	e09c                	sd	a5,0(s1)
}
    80004aa6:	70a2                	ld	ra,40(sp)
    80004aa8:	7402                	ld	s0,32(sp)
    80004aaa:	64e2                	ld	s1,24(sp)
    80004aac:	6942                	ld	s2,16(sp)
    80004aae:	6145                	addi	sp,sp,48
    80004ab0:	8082                	ret
    return -1;
    80004ab2:	557d                	li	a0,-1
    80004ab4:	bfcd                	j	80004aa6 <argfd+0x44>
    80004ab6:	557d                	li	a0,-1
    80004ab8:	b7fd                	j	80004aa6 <argfd+0x44>

0000000080004aba <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004aba:	1101                	addi	sp,sp,-32
    80004abc:	ec06                	sd	ra,24(sp)
    80004abe:	e822                	sd	s0,16(sp)
    80004ac0:	e426                	sd	s1,8(sp)
    80004ac2:	1000                	addi	s0,sp,32
    80004ac4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004ac6:	e09fc0ef          	jal	800018ce <myproc>
    80004aca:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004acc:	0d050793          	addi	a5,a0,208
    80004ad0:	4501                	li	a0,0
    80004ad2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004ad4:	6398                	ld	a4,0(a5)
    80004ad6:	cb19                	beqz	a4,80004aec <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004ad8:	2505                	addiw	a0,a0,1
    80004ada:	07a1                	addi	a5,a5,8
    80004adc:	fed51ce3          	bne	a0,a3,80004ad4 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004ae0:	557d                	li	a0,-1
}
    80004ae2:	60e2                	ld	ra,24(sp)
    80004ae4:	6442                	ld	s0,16(sp)
    80004ae6:	64a2                	ld	s1,8(sp)
    80004ae8:	6105                	addi	sp,sp,32
    80004aea:	8082                	ret
      p->ofile[fd] = f;
    80004aec:	01a50793          	addi	a5,a0,26
    80004af0:	078e                	slli	a5,a5,0x3
    80004af2:	963e                	add	a2,a2,a5
    80004af4:	e204                	sd	s1,0(a2)
      return fd;
    80004af6:	b7f5                	j	80004ae2 <fdalloc+0x28>

0000000080004af8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004af8:	715d                	addi	sp,sp,-80
    80004afa:	e486                	sd	ra,72(sp)
    80004afc:	e0a2                	sd	s0,64(sp)
    80004afe:	fc26                	sd	s1,56(sp)
    80004b00:	f84a                	sd	s2,48(sp)
    80004b02:	f44e                	sd	s3,40(sp)
    80004b04:	ec56                	sd	s5,24(sp)
    80004b06:	e85a                	sd	s6,16(sp)
    80004b08:	0880                	addi	s0,sp,80
    80004b0a:	8b2e                	mv	s6,a1
    80004b0c:	89b2                	mv	s3,a2
    80004b0e:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004b10:	fb040593          	addi	a1,s0,-80
    80004b14:	80eff0ef          	jal	80003b22 <nameiparent>
    80004b18:	84aa                	mv	s1,a0
    80004b1a:	10050a63          	beqz	a0,80004c2e <create+0x136>
    return 0;

  ilock(dp);
    80004b1e:	fd4fe0ef          	jal	800032f2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004b22:	4601                	li	a2,0
    80004b24:	fb040593          	addi	a1,s0,-80
    80004b28:	8526                	mv	a0,s1
    80004b2a:	d79fe0ef          	jal	800038a2 <dirlookup>
    80004b2e:	8aaa                	mv	s5,a0
    80004b30:	c129                	beqz	a0,80004b72 <create+0x7a>
    iunlockput(dp);
    80004b32:	8526                	mv	a0,s1
    80004b34:	9c9fe0ef          	jal	800034fc <iunlockput>
    ilock(ip);
    80004b38:	8556                	mv	a0,s5
    80004b3a:	fb8fe0ef          	jal	800032f2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004b3e:	4789                	li	a5,2
    80004b40:	02fb1463          	bne	s6,a5,80004b68 <create+0x70>
    80004b44:	044ad783          	lhu	a5,68(s5)
    80004b48:	37f9                	addiw	a5,a5,-2
    80004b4a:	17c2                	slli	a5,a5,0x30
    80004b4c:	93c1                	srli	a5,a5,0x30
    80004b4e:	4705                	li	a4,1
    80004b50:	00f76c63          	bltu	a4,a5,80004b68 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004b54:	8556                	mv	a0,s5
    80004b56:	60a6                	ld	ra,72(sp)
    80004b58:	6406                	ld	s0,64(sp)
    80004b5a:	74e2                	ld	s1,56(sp)
    80004b5c:	7942                	ld	s2,48(sp)
    80004b5e:	79a2                	ld	s3,40(sp)
    80004b60:	6ae2                	ld	s5,24(sp)
    80004b62:	6b42                	ld	s6,16(sp)
    80004b64:	6161                	addi	sp,sp,80
    80004b66:	8082                	ret
    iunlockput(ip);
    80004b68:	8556                	mv	a0,s5
    80004b6a:	993fe0ef          	jal	800034fc <iunlockput>
    return 0;
    80004b6e:	4a81                	li	s5,0
    80004b70:	b7d5                	j	80004b54 <create+0x5c>
    80004b72:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004b74:	85da                	mv	a1,s6
    80004b76:	4088                	lw	a0,0(s1)
    80004b78:	e0afe0ef          	jal	80003182 <ialloc>
    80004b7c:	8a2a                	mv	s4,a0
    80004b7e:	cd15                	beqz	a0,80004bba <create+0xc2>
  ilock(ip);
    80004b80:	f72fe0ef          	jal	800032f2 <ilock>
  ip->major = major;
    80004b84:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004b88:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004b8c:	4905                	li	s2,1
    80004b8e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004b92:	8552                	mv	a0,s4
    80004b94:	eaafe0ef          	jal	8000323e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004b98:	032b0763          	beq	s6,s2,80004bc6 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004b9c:	004a2603          	lw	a2,4(s4)
    80004ba0:	fb040593          	addi	a1,s0,-80
    80004ba4:	8526                	mv	a0,s1
    80004ba6:	ec9fe0ef          	jal	80003a6e <dirlink>
    80004baa:	06054563          	bltz	a0,80004c14 <create+0x11c>
  iunlockput(dp);
    80004bae:	8526                	mv	a0,s1
    80004bb0:	94dfe0ef          	jal	800034fc <iunlockput>
  return ip;
    80004bb4:	8ad2                	mv	s5,s4
    80004bb6:	7a02                	ld	s4,32(sp)
    80004bb8:	bf71                	j	80004b54 <create+0x5c>
    iunlockput(dp);
    80004bba:	8526                	mv	a0,s1
    80004bbc:	941fe0ef          	jal	800034fc <iunlockput>
    return 0;
    80004bc0:	8ad2                	mv	s5,s4
    80004bc2:	7a02                	ld	s4,32(sp)
    80004bc4:	bf41                	j	80004b54 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004bc6:	004a2603          	lw	a2,4(s4)
    80004bca:	00003597          	auipc	a1,0x3
    80004bce:	a1658593          	addi	a1,a1,-1514 # 800075e0 <etext+0x5e0>
    80004bd2:	8552                	mv	a0,s4
    80004bd4:	e9bfe0ef          	jal	80003a6e <dirlink>
    80004bd8:	02054e63          	bltz	a0,80004c14 <create+0x11c>
    80004bdc:	40d0                	lw	a2,4(s1)
    80004bde:	00003597          	auipc	a1,0x3
    80004be2:	a0a58593          	addi	a1,a1,-1526 # 800075e8 <etext+0x5e8>
    80004be6:	8552                	mv	a0,s4
    80004be8:	e87fe0ef          	jal	80003a6e <dirlink>
    80004bec:	02054463          	bltz	a0,80004c14 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004bf0:	004a2603          	lw	a2,4(s4)
    80004bf4:	fb040593          	addi	a1,s0,-80
    80004bf8:	8526                	mv	a0,s1
    80004bfa:	e75fe0ef          	jal	80003a6e <dirlink>
    80004bfe:	00054b63          	bltz	a0,80004c14 <create+0x11c>
    dp->nlink++;  // for ".."
    80004c02:	04a4d783          	lhu	a5,74(s1)
    80004c06:	2785                	addiw	a5,a5,1
    80004c08:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004c0c:	8526                	mv	a0,s1
    80004c0e:	e30fe0ef          	jal	8000323e <iupdate>
    80004c12:	bf71                	j	80004bae <create+0xb6>
  ip->nlink = 0;
    80004c14:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004c18:	8552                	mv	a0,s4
    80004c1a:	e24fe0ef          	jal	8000323e <iupdate>
  iunlockput(ip);
    80004c1e:	8552                	mv	a0,s4
    80004c20:	8ddfe0ef          	jal	800034fc <iunlockput>
  iunlockput(dp);
    80004c24:	8526                	mv	a0,s1
    80004c26:	8d7fe0ef          	jal	800034fc <iunlockput>
  return 0;
    80004c2a:	7a02                	ld	s4,32(sp)
    80004c2c:	b725                	j	80004b54 <create+0x5c>
    return 0;
    80004c2e:	8aaa                	mv	s5,a0
    80004c30:	b715                	j	80004b54 <create+0x5c>

0000000080004c32 <sys_dup>:
{
    80004c32:	7179                	addi	sp,sp,-48
    80004c34:	f406                	sd	ra,40(sp)
    80004c36:	f022                	sd	s0,32(sp)
    80004c38:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004c3a:	fd840613          	addi	a2,s0,-40
    80004c3e:	4581                	li	a1,0
    80004c40:	4501                	li	a0,0
    80004c42:	e21ff0ef          	jal	80004a62 <argfd>
    return -1;
    80004c46:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004c48:	02054363          	bltz	a0,80004c6e <sys_dup+0x3c>
    80004c4c:	ec26                	sd	s1,24(sp)
    80004c4e:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004c50:	fd843903          	ld	s2,-40(s0)
    80004c54:	854a                	mv	a0,s2
    80004c56:	e65ff0ef          	jal	80004aba <fdalloc>
    80004c5a:	84aa                	mv	s1,a0
    return -1;
    80004c5c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004c5e:	00054d63          	bltz	a0,80004c78 <sys_dup+0x46>
  filedup(f);
    80004c62:	854a                	mv	a0,s2
    80004c64:	c3eff0ef          	jal	800040a2 <filedup>
  return fd;
    80004c68:	87a6                	mv	a5,s1
    80004c6a:	64e2                	ld	s1,24(sp)
    80004c6c:	6942                	ld	s2,16(sp)
}
    80004c6e:	853e                	mv	a0,a5
    80004c70:	70a2                	ld	ra,40(sp)
    80004c72:	7402                	ld	s0,32(sp)
    80004c74:	6145                	addi	sp,sp,48
    80004c76:	8082                	ret
    80004c78:	64e2                	ld	s1,24(sp)
    80004c7a:	6942                	ld	s2,16(sp)
    80004c7c:	bfcd                	j	80004c6e <sys_dup+0x3c>

0000000080004c7e <sys_read>:
{
    80004c7e:	7179                	addi	sp,sp,-48
    80004c80:	f406                	sd	ra,40(sp)
    80004c82:	f022                	sd	s0,32(sp)
    80004c84:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004c86:	fd840593          	addi	a1,s0,-40
    80004c8a:	4505                	li	a0,1
    80004c8c:	b6dfd0ef          	jal	800027f8 <argaddr>
  argint(2, &n);
    80004c90:	fe440593          	addi	a1,s0,-28
    80004c94:	4509                	li	a0,2
    80004c96:	b47fd0ef          	jal	800027dc <argint>
  if(argfd(0, 0, &f) < 0)
    80004c9a:	fe840613          	addi	a2,s0,-24
    80004c9e:	4581                	li	a1,0
    80004ca0:	4501                	li	a0,0
    80004ca2:	dc1ff0ef          	jal	80004a62 <argfd>
    80004ca6:	87aa                	mv	a5,a0
    return -1;
    80004ca8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004caa:	0007ca63          	bltz	a5,80004cbe <sys_read+0x40>
  return fileread(f, p, n);
    80004cae:	fe442603          	lw	a2,-28(s0)
    80004cb2:	fd843583          	ld	a1,-40(s0)
    80004cb6:	fe843503          	ld	a0,-24(s0)
    80004cba:	d4eff0ef          	jal	80004208 <fileread>
}
    80004cbe:	70a2                	ld	ra,40(sp)
    80004cc0:	7402                	ld	s0,32(sp)
    80004cc2:	6145                	addi	sp,sp,48
    80004cc4:	8082                	ret

0000000080004cc6 <sys_write>:
{
    80004cc6:	7179                	addi	sp,sp,-48
    80004cc8:	f406                	sd	ra,40(sp)
    80004cca:	f022                	sd	s0,32(sp)
    80004ccc:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004cce:	fd840593          	addi	a1,s0,-40
    80004cd2:	4505                	li	a0,1
    80004cd4:	b25fd0ef          	jal	800027f8 <argaddr>
  argint(2, &n);
    80004cd8:	fe440593          	addi	a1,s0,-28
    80004cdc:	4509                	li	a0,2
    80004cde:	afffd0ef          	jal	800027dc <argint>
  if(argfd(0, 0, &f) < 0)
    80004ce2:	fe840613          	addi	a2,s0,-24
    80004ce6:	4581                	li	a1,0
    80004ce8:	4501                	li	a0,0
    80004cea:	d79ff0ef          	jal	80004a62 <argfd>
    80004cee:	87aa                	mv	a5,a0
    return -1;
    80004cf0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004cf2:	0007ca63          	bltz	a5,80004d06 <sys_write+0x40>
  return filewrite(f, p, n);
    80004cf6:	fe442603          	lw	a2,-28(s0)
    80004cfa:	fd843583          	ld	a1,-40(s0)
    80004cfe:	fe843503          	ld	a0,-24(s0)
    80004d02:	dc4ff0ef          	jal	800042c6 <filewrite>
}
    80004d06:	70a2                	ld	ra,40(sp)
    80004d08:	7402                	ld	s0,32(sp)
    80004d0a:	6145                	addi	sp,sp,48
    80004d0c:	8082                	ret

0000000080004d0e <sys_close>:
{
    80004d0e:	1101                	addi	sp,sp,-32
    80004d10:	ec06                	sd	ra,24(sp)
    80004d12:	e822                	sd	s0,16(sp)
    80004d14:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004d16:	fe040613          	addi	a2,s0,-32
    80004d1a:	fec40593          	addi	a1,s0,-20
    80004d1e:	4501                	li	a0,0
    80004d20:	d43ff0ef          	jal	80004a62 <argfd>
    return -1;
    80004d24:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004d26:	02054063          	bltz	a0,80004d46 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004d2a:	ba5fc0ef          	jal	800018ce <myproc>
    80004d2e:	fec42783          	lw	a5,-20(s0)
    80004d32:	07e9                	addi	a5,a5,26
    80004d34:	078e                	slli	a5,a5,0x3
    80004d36:	953e                	add	a0,a0,a5
    80004d38:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004d3c:	fe043503          	ld	a0,-32(s0)
    80004d40:	ba8ff0ef          	jal	800040e8 <fileclose>
  return 0;
    80004d44:	4781                	li	a5,0
}
    80004d46:	853e                	mv	a0,a5
    80004d48:	60e2                	ld	ra,24(sp)
    80004d4a:	6442                	ld	s0,16(sp)
    80004d4c:	6105                	addi	sp,sp,32
    80004d4e:	8082                	ret

0000000080004d50 <sys_fstat>:
{
    80004d50:	1101                	addi	sp,sp,-32
    80004d52:	ec06                	sd	ra,24(sp)
    80004d54:	e822                	sd	s0,16(sp)
    80004d56:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004d58:	fe040593          	addi	a1,s0,-32
    80004d5c:	4505                	li	a0,1
    80004d5e:	a9bfd0ef          	jal	800027f8 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004d62:	fe840613          	addi	a2,s0,-24
    80004d66:	4581                	li	a1,0
    80004d68:	4501                	li	a0,0
    80004d6a:	cf9ff0ef          	jal	80004a62 <argfd>
    80004d6e:	87aa                	mv	a5,a0
    return -1;
    80004d70:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d72:	0007c863          	bltz	a5,80004d82 <sys_fstat+0x32>
  return filestat(f, st);
    80004d76:	fe043583          	ld	a1,-32(s0)
    80004d7a:	fe843503          	ld	a0,-24(s0)
    80004d7e:	c2cff0ef          	jal	800041aa <filestat>
}
    80004d82:	60e2                	ld	ra,24(sp)
    80004d84:	6442                	ld	s0,16(sp)
    80004d86:	6105                	addi	sp,sp,32
    80004d88:	8082                	ret

0000000080004d8a <sys_link>:
{
    80004d8a:	7169                	addi	sp,sp,-304
    80004d8c:	f606                	sd	ra,296(sp)
    80004d8e:	f222                	sd	s0,288(sp)
    80004d90:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d92:	08000613          	li	a2,128
    80004d96:	ed040593          	addi	a1,s0,-304
    80004d9a:	4501                	li	a0,0
    80004d9c:	a79fd0ef          	jal	80002814 <argstr>
    return -1;
    80004da0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004da2:	0c054e63          	bltz	a0,80004e7e <sys_link+0xf4>
    80004da6:	08000613          	li	a2,128
    80004daa:	f5040593          	addi	a1,s0,-176
    80004dae:	4505                	li	a0,1
    80004db0:	a65fd0ef          	jal	80002814 <argstr>
    return -1;
    80004db4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004db6:	0c054463          	bltz	a0,80004e7e <sys_link+0xf4>
    80004dba:	ee26                	sd	s1,280(sp)
  begin_op();
    80004dbc:	f21fe0ef          	jal	80003cdc <begin_op>
  if((ip = namei(old)) == 0){
    80004dc0:	ed040513          	addi	a0,s0,-304
    80004dc4:	d45fe0ef          	jal	80003b08 <namei>
    80004dc8:	84aa                	mv	s1,a0
    80004dca:	c53d                	beqz	a0,80004e38 <sys_link+0xae>
  ilock(ip);
    80004dcc:	d26fe0ef          	jal	800032f2 <ilock>
  if(ip->type == T_DIR){
    80004dd0:	04449703          	lh	a4,68(s1)
    80004dd4:	4785                	li	a5,1
    80004dd6:	06f70663          	beq	a4,a5,80004e42 <sys_link+0xb8>
    80004dda:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004ddc:	04a4d783          	lhu	a5,74(s1)
    80004de0:	2785                	addiw	a5,a5,1
    80004de2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004de6:	8526                	mv	a0,s1
    80004de8:	c56fe0ef          	jal	8000323e <iupdate>
  iunlock(ip);
    80004dec:	8526                	mv	a0,s1
    80004dee:	db2fe0ef          	jal	800033a0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004df2:	fd040593          	addi	a1,s0,-48
    80004df6:	f5040513          	addi	a0,s0,-176
    80004dfa:	d29fe0ef          	jal	80003b22 <nameiparent>
    80004dfe:	892a                	mv	s2,a0
    80004e00:	cd21                	beqz	a0,80004e58 <sys_link+0xce>
  ilock(dp);
    80004e02:	cf0fe0ef          	jal	800032f2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004e06:	00092703          	lw	a4,0(s2)
    80004e0a:	409c                	lw	a5,0(s1)
    80004e0c:	04f71363          	bne	a4,a5,80004e52 <sys_link+0xc8>
    80004e10:	40d0                	lw	a2,4(s1)
    80004e12:	fd040593          	addi	a1,s0,-48
    80004e16:	854a                	mv	a0,s2
    80004e18:	c57fe0ef          	jal	80003a6e <dirlink>
    80004e1c:	02054b63          	bltz	a0,80004e52 <sys_link+0xc8>
  iunlockput(dp);
    80004e20:	854a                	mv	a0,s2
    80004e22:	edafe0ef          	jal	800034fc <iunlockput>
  iput(ip);
    80004e26:	8526                	mv	a0,s1
    80004e28:	e4cfe0ef          	jal	80003474 <iput>
  end_op();
    80004e2c:	f1bfe0ef          	jal	80003d46 <end_op>
  return 0;
    80004e30:	4781                	li	a5,0
    80004e32:	64f2                	ld	s1,280(sp)
    80004e34:	6952                	ld	s2,272(sp)
    80004e36:	a0a1                	j	80004e7e <sys_link+0xf4>
    end_op();
    80004e38:	f0ffe0ef          	jal	80003d46 <end_op>
    return -1;
    80004e3c:	57fd                	li	a5,-1
    80004e3e:	64f2                	ld	s1,280(sp)
    80004e40:	a83d                	j	80004e7e <sys_link+0xf4>
    iunlockput(ip);
    80004e42:	8526                	mv	a0,s1
    80004e44:	eb8fe0ef          	jal	800034fc <iunlockput>
    end_op();
    80004e48:	efffe0ef          	jal	80003d46 <end_op>
    return -1;
    80004e4c:	57fd                	li	a5,-1
    80004e4e:	64f2                	ld	s1,280(sp)
    80004e50:	a03d                	j	80004e7e <sys_link+0xf4>
    iunlockput(dp);
    80004e52:	854a                	mv	a0,s2
    80004e54:	ea8fe0ef          	jal	800034fc <iunlockput>
  ilock(ip);
    80004e58:	8526                	mv	a0,s1
    80004e5a:	c98fe0ef          	jal	800032f2 <ilock>
  ip->nlink--;
    80004e5e:	04a4d783          	lhu	a5,74(s1)
    80004e62:	37fd                	addiw	a5,a5,-1
    80004e64:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e68:	8526                	mv	a0,s1
    80004e6a:	bd4fe0ef          	jal	8000323e <iupdate>
  iunlockput(ip);
    80004e6e:	8526                	mv	a0,s1
    80004e70:	e8cfe0ef          	jal	800034fc <iunlockput>
  end_op();
    80004e74:	ed3fe0ef          	jal	80003d46 <end_op>
  return -1;
    80004e78:	57fd                	li	a5,-1
    80004e7a:	64f2                	ld	s1,280(sp)
    80004e7c:	6952                	ld	s2,272(sp)
}
    80004e7e:	853e                	mv	a0,a5
    80004e80:	70b2                	ld	ra,296(sp)
    80004e82:	7412                	ld	s0,288(sp)
    80004e84:	6155                	addi	sp,sp,304
    80004e86:	8082                	ret

0000000080004e88 <sys_unlink>:
{
    80004e88:	7151                	addi	sp,sp,-240
    80004e8a:	f586                	sd	ra,232(sp)
    80004e8c:	f1a2                	sd	s0,224(sp)
    80004e8e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004e90:	08000613          	li	a2,128
    80004e94:	f3040593          	addi	a1,s0,-208
    80004e98:	4501                	li	a0,0
    80004e9a:	97bfd0ef          	jal	80002814 <argstr>
    80004e9e:	16054063          	bltz	a0,80004ffe <sys_unlink+0x176>
    80004ea2:	eda6                	sd	s1,216(sp)
  begin_op();
    80004ea4:	e39fe0ef          	jal	80003cdc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004ea8:	fb040593          	addi	a1,s0,-80
    80004eac:	f3040513          	addi	a0,s0,-208
    80004eb0:	c73fe0ef          	jal	80003b22 <nameiparent>
    80004eb4:	84aa                	mv	s1,a0
    80004eb6:	c945                	beqz	a0,80004f66 <sys_unlink+0xde>
  ilock(dp);
    80004eb8:	c3afe0ef          	jal	800032f2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004ebc:	00002597          	auipc	a1,0x2
    80004ec0:	72458593          	addi	a1,a1,1828 # 800075e0 <etext+0x5e0>
    80004ec4:	fb040513          	addi	a0,s0,-80
    80004ec8:	9c5fe0ef          	jal	8000388c <namecmp>
    80004ecc:	10050e63          	beqz	a0,80004fe8 <sys_unlink+0x160>
    80004ed0:	00002597          	auipc	a1,0x2
    80004ed4:	71858593          	addi	a1,a1,1816 # 800075e8 <etext+0x5e8>
    80004ed8:	fb040513          	addi	a0,s0,-80
    80004edc:	9b1fe0ef          	jal	8000388c <namecmp>
    80004ee0:	10050463          	beqz	a0,80004fe8 <sys_unlink+0x160>
    80004ee4:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004ee6:	f2c40613          	addi	a2,s0,-212
    80004eea:	fb040593          	addi	a1,s0,-80
    80004eee:	8526                	mv	a0,s1
    80004ef0:	9b3fe0ef          	jal	800038a2 <dirlookup>
    80004ef4:	892a                	mv	s2,a0
    80004ef6:	0e050863          	beqz	a0,80004fe6 <sys_unlink+0x15e>
  ilock(ip);
    80004efa:	bf8fe0ef          	jal	800032f2 <ilock>
  if(ip->nlink < 1)
    80004efe:	04a91783          	lh	a5,74(s2)
    80004f02:	06f05763          	blez	a5,80004f70 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004f06:	04491703          	lh	a4,68(s2)
    80004f0a:	4785                	li	a5,1
    80004f0c:	06f70963          	beq	a4,a5,80004f7e <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004f10:	4641                	li	a2,16
    80004f12:	4581                	li	a1,0
    80004f14:	fc040513          	addi	a0,s0,-64
    80004f18:	d8bfb0ef          	jal	80000ca2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f1c:	4741                	li	a4,16
    80004f1e:	f2c42683          	lw	a3,-212(s0)
    80004f22:	fc040613          	addi	a2,s0,-64
    80004f26:	4581                	li	a1,0
    80004f28:	8526                	mv	a0,s1
    80004f2a:	855fe0ef          	jal	8000377e <writei>
    80004f2e:	47c1                	li	a5,16
    80004f30:	08f51b63          	bne	a0,a5,80004fc6 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004f34:	04491703          	lh	a4,68(s2)
    80004f38:	4785                	li	a5,1
    80004f3a:	08f70d63          	beq	a4,a5,80004fd4 <sys_unlink+0x14c>
  iunlockput(dp);
    80004f3e:	8526                	mv	a0,s1
    80004f40:	dbcfe0ef          	jal	800034fc <iunlockput>
  ip->nlink--;
    80004f44:	04a95783          	lhu	a5,74(s2)
    80004f48:	37fd                	addiw	a5,a5,-1
    80004f4a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004f4e:	854a                	mv	a0,s2
    80004f50:	aeefe0ef          	jal	8000323e <iupdate>
  iunlockput(ip);
    80004f54:	854a                	mv	a0,s2
    80004f56:	da6fe0ef          	jal	800034fc <iunlockput>
  end_op();
    80004f5a:	dedfe0ef          	jal	80003d46 <end_op>
  return 0;
    80004f5e:	4501                	li	a0,0
    80004f60:	64ee                	ld	s1,216(sp)
    80004f62:	694e                	ld	s2,208(sp)
    80004f64:	a849                	j	80004ff6 <sys_unlink+0x16e>
    end_op();
    80004f66:	de1fe0ef          	jal	80003d46 <end_op>
    return -1;
    80004f6a:	557d                	li	a0,-1
    80004f6c:	64ee                	ld	s1,216(sp)
    80004f6e:	a061                	j	80004ff6 <sys_unlink+0x16e>
    80004f70:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004f72:	00002517          	auipc	a0,0x2
    80004f76:	67e50513          	addi	a0,a0,1662 # 800075f0 <etext+0x5f0>
    80004f7a:	867fb0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004f7e:	04c92703          	lw	a4,76(s2)
    80004f82:	02000793          	li	a5,32
    80004f86:	f8e7f5e3          	bgeu	a5,a4,80004f10 <sys_unlink+0x88>
    80004f8a:	e5ce                	sd	s3,200(sp)
    80004f8c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f90:	4741                	li	a4,16
    80004f92:	86ce                	mv	a3,s3
    80004f94:	f1840613          	addi	a2,s0,-232
    80004f98:	4581                	li	a1,0
    80004f9a:	854a                	mv	a0,s2
    80004f9c:	ee6fe0ef          	jal	80003682 <readi>
    80004fa0:	47c1                	li	a5,16
    80004fa2:	00f51c63          	bne	a0,a5,80004fba <sys_unlink+0x132>
    if(de.inum != 0)
    80004fa6:	f1845783          	lhu	a5,-232(s0)
    80004faa:	efa1                	bnez	a5,80005002 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004fac:	29c1                	addiw	s3,s3,16
    80004fae:	04c92783          	lw	a5,76(s2)
    80004fb2:	fcf9efe3          	bltu	s3,a5,80004f90 <sys_unlink+0x108>
    80004fb6:	69ae                	ld	s3,200(sp)
    80004fb8:	bfa1                	j	80004f10 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004fba:	00002517          	auipc	a0,0x2
    80004fbe:	64e50513          	addi	a0,a0,1614 # 80007608 <etext+0x608>
    80004fc2:	81ffb0ef          	jal	800007e0 <panic>
    80004fc6:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004fc8:	00002517          	auipc	a0,0x2
    80004fcc:	65850513          	addi	a0,a0,1624 # 80007620 <etext+0x620>
    80004fd0:	811fb0ef          	jal	800007e0 <panic>
    dp->nlink--;
    80004fd4:	04a4d783          	lhu	a5,74(s1)
    80004fd8:	37fd                	addiw	a5,a5,-1
    80004fda:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004fde:	8526                	mv	a0,s1
    80004fe0:	a5efe0ef          	jal	8000323e <iupdate>
    80004fe4:	bfa9                	j	80004f3e <sys_unlink+0xb6>
    80004fe6:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004fe8:	8526                	mv	a0,s1
    80004fea:	d12fe0ef          	jal	800034fc <iunlockput>
  end_op();
    80004fee:	d59fe0ef          	jal	80003d46 <end_op>
  return -1;
    80004ff2:	557d                	li	a0,-1
    80004ff4:	64ee                	ld	s1,216(sp)
}
    80004ff6:	70ae                	ld	ra,232(sp)
    80004ff8:	740e                	ld	s0,224(sp)
    80004ffa:	616d                	addi	sp,sp,240
    80004ffc:	8082                	ret
    return -1;
    80004ffe:	557d                	li	a0,-1
    80005000:	bfdd                	j	80004ff6 <sys_unlink+0x16e>
    iunlockput(ip);
    80005002:	854a                	mv	a0,s2
    80005004:	cf8fe0ef          	jal	800034fc <iunlockput>
    goto bad;
    80005008:	694e                	ld	s2,208(sp)
    8000500a:	69ae                	ld	s3,200(sp)
    8000500c:	bff1                	j	80004fe8 <sys_unlink+0x160>

000000008000500e <sys_open>:

uint64
sys_open(void)
{
    8000500e:	7131                	addi	sp,sp,-192
    80005010:	fd06                	sd	ra,184(sp)
    80005012:	f922                	sd	s0,176(sp)
    80005014:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005016:	f4c40593          	addi	a1,s0,-180
    8000501a:	4505                	li	a0,1
    8000501c:	fc0fd0ef          	jal	800027dc <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005020:	08000613          	li	a2,128
    80005024:	f5040593          	addi	a1,s0,-176
    80005028:	4501                	li	a0,0
    8000502a:	feafd0ef          	jal	80002814 <argstr>
    8000502e:	87aa                	mv	a5,a0
    return -1;
    80005030:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005032:	0a07c263          	bltz	a5,800050d6 <sys_open+0xc8>
    80005036:	f526                	sd	s1,168(sp)

  begin_op();
    80005038:	ca5fe0ef          	jal	80003cdc <begin_op>

  if(omode & O_CREATE){
    8000503c:	f4c42783          	lw	a5,-180(s0)
    80005040:	2007f793          	andi	a5,a5,512
    80005044:	c3d5                	beqz	a5,800050e8 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005046:	4681                	li	a3,0
    80005048:	4601                	li	a2,0
    8000504a:	4589                	li	a1,2
    8000504c:	f5040513          	addi	a0,s0,-176
    80005050:	aa9ff0ef          	jal	80004af8 <create>
    80005054:	84aa                	mv	s1,a0
    if(ip == 0){
    80005056:	c541                	beqz	a0,800050de <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005058:	04449703          	lh	a4,68(s1)
    8000505c:	478d                	li	a5,3
    8000505e:	00f71763          	bne	a4,a5,8000506c <sys_open+0x5e>
    80005062:	0464d703          	lhu	a4,70(s1)
    80005066:	47a5                	li	a5,9
    80005068:	0ae7ed63          	bltu	a5,a4,80005122 <sys_open+0x114>
    8000506c:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000506e:	fd7fe0ef          	jal	80004044 <filealloc>
    80005072:	892a                	mv	s2,a0
    80005074:	c179                	beqz	a0,8000513a <sys_open+0x12c>
    80005076:	ed4e                	sd	s3,152(sp)
    80005078:	a43ff0ef          	jal	80004aba <fdalloc>
    8000507c:	89aa                	mv	s3,a0
    8000507e:	0a054a63          	bltz	a0,80005132 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005082:	04449703          	lh	a4,68(s1)
    80005086:	478d                	li	a5,3
    80005088:	0cf70263          	beq	a4,a5,8000514c <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000508c:	4789                	li	a5,2
    8000508e:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005092:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005096:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000509a:	f4c42783          	lw	a5,-180(s0)
    8000509e:	0017c713          	xori	a4,a5,1
    800050a2:	8b05                	andi	a4,a4,1
    800050a4:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800050a8:	0037f713          	andi	a4,a5,3
    800050ac:	00e03733          	snez	a4,a4
    800050b0:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800050b4:	4007f793          	andi	a5,a5,1024
    800050b8:	c791                	beqz	a5,800050c4 <sys_open+0xb6>
    800050ba:	04449703          	lh	a4,68(s1)
    800050be:	4789                	li	a5,2
    800050c0:	08f70d63          	beq	a4,a5,8000515a <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    800050c4:	8526                	mv	a0,s1
    800050c6:	adafe0ef          	jal	800033a0 <iunlock>
  end_op();
    800050ca:	c7dfe0ef          	jal	80003d46 <end_op>

  return fd;
    800050ce:	854e                	mv	a0,s3
    800050d0:	74aa                	ld	s1,168(sp)
    800050d2:	790a                	ld	s2,160(sp)
    800050d4:	69ea                	ld	s3,152(sp)
}
    800050d6:	70ea                	ld	ra,184(sp)
    800050d8:	744a                	ld	s0,176(sp)
    800050da:	6129                	addi	sp,sp,192
    800050dc:	8082                	ret
      end_op();
    800050de:	c69fe0ef          	jal	80003d46 <end_op>
      return -1;
    800050e2:	557d                	li	a0,-1
    800050e4:	74aa                	ld	s1,168(sp)
    800050e6:	bfc5                	j	800050d6 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    800050e8:	f5040513          	addi	a0,s0,-176
    800050ec:	a1dfe0ef          	jal	80003b08 <namei>
    800050f0:	84aa                	mv	s1,a0
    800050f2:	c11d                	beqz	a0,80005118 <sys_open+0x10a>
    ilock(ip);
    800050f4:	9fefe0ef          	jal	800032f2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800050f8:	04449703          	lh	a4,68(s1)
    800050fc:	4785                	li	a5,1
    800050fe:	f4f71de3          	bne	a4,a5,80005058 <sys_open+0x4a>
    80005102:	f4c42783          	lw	a5,-180(s0)
    80005106:	d3bd                	beqz	a5,8000506c <sys_open+0x5e>
      iunlockput(ip);
    80005108:	8526                	mv	a0,s1
    8000510a:	bf2fe0ef          	jal	800034fc <iunlockput>
      end_op();
    8000510e:	c39fe0ef          	jal	80003d46 <end_op>
      return -1;
    80005112:	557d                	li	a0,-1
    80005114:	74aa                	ld	s1,168(sp)
    80005116:	b7c1                	j	800050d6 <sys_open+0xc8>
      end_op();
    80005118:	c2ffe0ef          	jal	80003d46 <end_op>
      return -1;
    8000511c:	557d                	li	a0,-1
    8000511e:	74aa                	ld	s1,168(sp)
    80005120:	bf5d                	j	800050d6 <sys_open+0xc8>
    iunlockput(ip);
    80005122:	8526                	mv	a0,s1
    80005124:	bd8fe0ef          	jal	800034fc <iunlockput>
    end_op();
    80005128:	c1ffe0ef          	jal	80003d46 <end_op>
    return -1;
    8000512c:	557d                	li	a0,-1
    8000512e:	74aa                	ld	s1,168(sp)
    80005130:	b75d                	j	800050d6 <sys_open+0xc8>
      fileclose(f);
    80005132:	854a                	mv	a0,s2
    80005134:	fb5fe0ef          	jal	800040e8 <fileclose>
    80005138:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000513a:	8526                	mv	a0,s1
    8000513c:	bc0fe0ef          	jal	800034fc <iunlockput>
    end_op();
    80005140:	c07fe0ef          	jal	80003d46 <end_op>
    return -1;
    80005144:	557d                	li	a0,-1
    80005146:	74aa                	ld	s1,168(sp)
    80005148:	790a                	ld	s2,160(sp)
    8000514a:	b771                	j	800050d6 <sys_open+0xc8>
    f->type = FD_DEVICE;
    8000514c:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005150:	04649783          	lh	a5,70(s1)
    80005154:	02f91223          	sh	a5,36(s2)
    80005158:	bf3d                	j	80005096 <sys_open+0x88>
    itrunc(ip);
    8000515a:	8526                	mv	a0,s1
    8000515c:	a84fe0ef          	jal	800033e0 <itrunc>
    80005160:	b795                	j	800050c4 <sys_open+0xb6>

0000000080005162 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005162:	7175                	addi	sp,sp,-144
    80005164:	e506                	sd	ra,136(sp)
    80005166:	e122                	sd	s0,128(sp)
    80005168:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000516a:	b73fe0ef          	jal	80003cdc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000516e:	08000613          	li	a2,128
    80005172:	f7040593          	addi	a1,s0,-144
    80005176:	4501                	li	a0,0
    80005178:	e9cfd0ef          	jal	80002814 <argstr>
    8000517c:	02054363          	bltz	a0,800051a2 <sys_mkdir+0x40>
    80005180:	4681                	li	a3,0
    80005182:	4601                	li	a2,0
    80005184:	4585                	li	a1,1
    80005186:	f7040513          	addi	a0,s0,-144
    8000518a:	96fff0ef          	jal	80004af8 <create>
    8000518e:	c911                	beqz	a0,800051a2 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005190:	b6cfe0ef          	jal	800034fc <iunlockput>
  end_op();
    80005194:	bb3fe0ef          	jal	80003d46 <end_op>
  return 0;
    80005198:	4501                	li	a0,0
}
    8000519a:	60aa                	ld	ra,136(sp)
    8000519c:	640a                	ld	s0,128(sp)
    8000519e:	6149                	addi	sp,sp,144
    800051a0:	8082                	ret
    end_op();
    800051a2:	ba5fe0ef          	jal	80003d46 <end_op>
    return -1;
    800051a6:	557d                	li	a0,-1
    800051a8:	bfcd                	j	8000519a <sys_mkdir+0x38>

00000000800051aa <sys_mknod>:

uint64
sys_mknod(void)
{
    800051aa:	7135                	addi	sp,sp,-160
    800051ac:	ed06                	sd	ra,152(sp)
    800051ae:	e922                	sd	s0,144(sp)
    800051b0:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800051b2:	b2bfe0ef          	jal	80003cdc <begin_op>
  argint(1, &major);
    800051b6:	f6c40593          	addi	a1,s0,-148
    800051ba:	4505                	li	a0,1
    800051bc:	e20fd0ef          	jal	800027dc <argint>
  argint(2, &minor);
    800051c0:	f6840593          	addi	a1,s0,-152
    800051c4:	4509                	li	a0,2
    800051c6:	e16fd0ef          	jal	800027dc <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800051ca:	08000613          	li	a2,128
    800051ce:	f7040593          	addi	a1,s0,-144
    800051d2:	4501                	li	a0,0
    800051d4:	e40fd0ef          	jal	80002814 <argstr>
    800051d8:	02054563          	bltz	a0,80005202 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800051dc:	f6841683          	lh	a3,-152(s0)
    800051e0:	f6c41603          	lh	a2,-148(s0)
    800051e4:	458d                	li	a1,3
    800051e6:	f7040513          	addi	a0,s0,-144
    800051ea:	90fff0ef          	jal	80004af8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800051ee:	c911                	beqz	a0,80005202 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800051f0:	b0cfe0ef          	jal	800034fc <iunlockput>
  end_op();
    800051f4:	b53fe0ef          	jal	80003d46 <end_op>
  return 0;
    800051f8:	4501                	li	a0,0
}
    800051fa:	60ea                	ld	ra,152(sp)
    800051fc:	644a                	ld	s0,144(sp)
    800051fe:	610d                	addi	sp,sp,160
    80005200:	8082                	ret
    end_op();
    80005202:	b45fe0ef          	jal	80003d46 <end_op>
    return -1;
    80005206:	557d                	li	a0,-1
    80005208:	bfcd                	j	800051fa <sys_mknod+0x50>

000000008000520a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000520a:	7135                	addi	sp,sp,-160
    8000520c:	ed06                	sd	ra,152(sp)
    8000520e:	e922                	sd	s0,144(sp)
    80005210:	e14a                	sd	s2,128(sp)
    80005212:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005214:	ebafc0ef          	jal	800018ce <myproc>
    80005218:	892a                	mv	s2,a0
  
  begin_op();
    8000521a:	ac3fe0ef          	jal	80003cdc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000521e:	08000613          	li	a2,128
    80005222:	f6040593          	addi	a1,s0,-160
    80005226:	4501                	li	a0,0
    80005228:	decfd0ef          	jal	80002814 <argstr>
    8000522c:	04054363          	bltz	a0,80005272 <sys_chdir+0x68>
    80005230:	e526                	sd	s1,136(sp)
    80005232:	f6040513          	addi	a0,s0,-160
    80005236:	8d3fe0ef          	jal	80003b08 <namei>
    8000523a:	84aa                	mv	s1,a0
    8000523c:	c915                	beqz	a0,80005270 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000523e:	8b4fe0ef          	jal	800032f2 <ilock>
  if(ip->type != T_DIR){
    80005242:	04449703          	lh	a4,68(s1)
    80005246:	4785                	li	a5,1
    80005248:	02f71963          	bne	a4,a5,8000527a <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000524c:	8526                	mv	a0,s1
    8000524e:	952fe0ef          	jal	800033a0 <iunlock>
  iput(p->cwd);
    80005252:	15093503          	ld	a0,336(s2)
    80005256:	a1efe0ef          	jal	80003474 <iput>
  end_op();
    8000525a:	aedfe0ef          	jal	80003d46 <end_op>
  p->cwd = ip;
    8000525e:	14993823          	sd	s1,336(s2)
  return 0;
    80005262:	4501                	li	a0,0
    80005264:	64aa                	ld	s1,136(sp)
}
    80005266:	60ea                	ld	ra,152(sp)
    80005268:	644a                	ld	s0,144(sp)
    8000526a:	690a                	ld	s2,128(sp)
    8000526c:	610d                	addi	sp,sp,160
    8000526e:	8082                	ret
    80005270:	64aa                	ld	s1,136(sp)
    end_op();
    80005272:	ad5fe0ef          	jal	80003d46 <end_op>
    return -1;
    80005276:	557d                	li	a0,-1
    80005278:	b7fd                	j	80005266 <sys_chdir+0x5c>
    iunlockput(ip);
    8000527a:	8526                	mv	a0,s1
    8000527c:	a80fe0ef          	jal	800034fc <iunlockput>
    end_op();
    80005280:	ac7fe0ef          	jal	80003d46 <end_op>
    return -1;
    80005284:	557d                	li	a0,-1
    80005286:	64aa                	ld	s1,136(sp)
    80005288:	bff9                	j	80005266 <sys_chdir+0x5c>

000000008000528a <sys_exec>:

uint64
sys_exec(void)
{
    8000528a:	7121                	addi	sp,sp,-448
    8000528c:	ff06                	sd	ra,440(sp)
    8000528e:	fb22                	sd	s0,432(sp)
    80005290:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005292:	e4840593          	addi	a1,s0,-440
    80005296:	4505                	li	a0,1
    80005298:	d60fd0ef          	jal	800027f8 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000529c:	08000613          	li	a2,128
    800052a0:	f5040593          	addi	a1,s0,-176
    800052a4:	4501                	li	a0,0
    800052a6:	d6efd0ef          	jal	80002814 <argstr>
    800052aa:	87aa                	mv	a5,a0
    return -1;
    800052ac:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800052ae:	0c07c463          	bltz	a5,80005376 <sys_exec+0xec>
    800052b2:	f726                	sd	s1,424(sp)
    800052b4:	f34a                	sd	s2,416(sp)
    800052b6:	ef4e                	sd	s3,408(sp)
    800052b8:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    800052ba:	10000613          	li	a2,256
    800052be:	4581                	li	a1,0
    800052c0:	e5040513          	addi	a0,s0,-432
    800052c4:	9dffb0ef          	jal	80000ca2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800052c8:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800052cc:	89a6                	mv	s3,s1
    800052ce:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800052d0:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800052d4:	00391513          	slli	a0,s2,0x3
    800052d8:	e4040593          	addi	a1,s0,-448
    800052dc:	e4843783          	ld	a5,-440(s0)
    800052e0:	953e                	add	a0,a0,a5
    800052e2:	c70fd0ef          	jal	80002752 <fetchaddr>
    800052e6:	02054663          	bltz	a0,80005312 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800052ea:	e4043783          	ld	a5,-448(s0)
    800052ee:	c3a9                	beqz	a5,80005330 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800052f0:	80ffb0ef          	jal	80000afe <kalloc>
    800052f4:	85aa                	mv	a1,a0
    800052f6:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800052fa:	cd01                	beqz	a0,80005312 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800052fc:	6605                	lui	a2,0x1
    800052fe:	e4043503          	ld	a0,-448(s0)
    80005302:	c9afd0ef          	jal	8000279c <fetchstr>
    80005306:	00054663          	bltz	a0,80005312 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    8000530a:	0905                	addi	s2,s2,1
    8000530c:	09a1                	addi	s3,s3,8
    8000530e:	fd4913e3          	bne	s2,s4,800052d4 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005312:	f5040913          	addi	s2,s0,-176
    80005316:	6088                	ld	a0,0(s1)
    80005318:	c931                	beqz	a0,8000536c <sys_exec+0xe2>
    kfree(argv[i]);
    8000531a:	f02fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000531e:	04a1                	addi	s1,s1,8
    80005320:	ff249be3          	bne	s1,s2,80005316 <sys_exec+0x8c>
  return -1;
    80005324:	557d                	li	a0,-1
    80005326:	74ba                	ld	s1,424(sp)
    80005328:	791a                	ld	s2,416(sp)
    8000532a:	69fa                	ld	s3,408(sp)
    8000532c:	6a5a                	ld	s4,400(sp)
    8000532e:	a0a1                	j	80005376 <sys_exec+0xec>
      argv[i] = 0;
    80005330:	0009079b          	sext.w	a5,s2
    80005334:	078e                	slli	a5,a5,0x3
    80005336:	fd078793          	addi	a5,a5,-48
    8000533a:	97a2                	add	a5,a5,s0
    8000533c:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80005340:	e5040593          	addi	a1,s0,-432
    80005344:	f5040513          	addi	a0,s0,-176
    80005348:	ba8ff0ef          	jal	800046f0 <kexec>
    8000534c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000534e:	f5040993          	addi	s3,s0,-176
    80005352:	6088                	ld	a0,0(s1)
    80005354:	c511                	beqz	a0,80005360 <sys_exec+0xd6>
    kfree(argv[i]);
    80005356:	ec6fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000535a:	04a1                	addi	s1,s1,8
    8000535c:	ff349be3          	bne	s1,s3,80005352 <sys_exec+0xc8>
  return ret;
    80005360:	854a                	mv	a0,s2
    80005362:	74ba                	ld	s1,424(sp)
    80005364:	791a                	ld	s2,416(sp)
    80005366:	69fa                	ld	s3,408(sp)
    80005368:	6a5a                	ld	s4,400(sp)
    8000536a:	a031                	j	80005376 <sys_exec+0xec>
  return -1;
    8000536c:	557d                	li	a0,-1
    8000536e:	74ba                	ld	s1,424(sp)
    80005370:	791a                	ld	s2,416(sp)
    80005372:	69fa                	ld	s3,408(sp)
    80005374:	6a5a                	ld	s4,400(sp)
}
    80005376:	70fa                	ld	ra,440(sp)
    80005378:	745a                	ld	s0,432(sp)
    8000537a:	6139                	addi	sp,sp,448
    8000537c:	8082                	ret

000000008000537e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000537e:	7139                	addi	sp,sp,-64
    80005380:	fc06                	sd	ra,56(sp)
    80005382:	f822                	sd	s0,48(sp)
    80005384:	f426                	sd	s1,40(sp)
    80005386:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005388:	d46fc0ef          	jal	800018ce <myproc>
    8000538c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000538e:	fd840593          	addi	a1,s0,-40
    80005392:	4501                	li	a0,0
    80005394:	c64fd0ef          	jal	800027f8 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005398:	fc840593          	addi	a1,s0,-56
    8000539c:	fd040513          	addi	a0,s0,-48
    800053a0:	852ff0ef          	jal	800043f2 <pipealloc>
    return -1;
    800053a4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800053a6:	0a054463          	bltz	a0,8000544e <sys_pipe+0xd0>
  fd0 = -1;
    800053aa:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800053ae:	fd043503          	ld	a0,-48(s0)
    800053b2:	f08ff0ef          	jal	80004aba <fdalloc>
    800053b6:	fca42223          	sw	a0,-60(s0)
    800053ba:	08054163          	bltz	a0,8000543c <sys_pipe+0xbe>
    800053be:	fc843503          	ld	a0,-56(s0)
    800053c2:	ef8ff0ef          	jal	80004aba <fdalloc>
    800053c6:	fca42023          	sw	a0,-64(s0)
    800053ca:	06054063          	bltz	a0,8000542a <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800053ce:	4691                	li	a3,4
    800053d0:	fc440613          	addi	a2,s0,-60
    800053d4:	fd843583          	ld	a1,-40(s0)
    800053d8:	68a8                	ld	a0,80(s1)
    800053da:	a08fc0ef          	jal	800015e2 <copyout>
    800053de:	00054e63          	bltz	a0,800053fa <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800053e2:	4691                	li	a3,4
    800053e4:	fc040613          	addi	a2,s0,-64
    800053e8:	fd843583          	ld	a1,-40(s0)
    800053ec:	0591                	addi	a1,a1,4
    800053ee:	68a8                	ld	a0,80(s1)
    800053f0:	9f2fc0ef          	jal	800015e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800053f4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800053f6:	04055c63          	bgez	a0,8000544e <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800053fa:	fc442783          	lw	a5,-60(s0)
    800053fe:	07e9                	addi	a5,a5,26
    80005400:	078e                	slli	a5,a5,0x3
    80005402:	97a6                	add	a5,a5,s1
    80005404:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005408:	fc042783          	lw	a5,-64(s0)
    8000540c:	07e9                	addi	a5,a5,26
    8000540e:	078e                	slli	a5,a5,0x3
    80005410:	94be                	add	s1,s1,a5
    80005412:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005416:	fd043503          	ld	a0,-48(s0)
    8000541a:	ccffe0ef          	jal	800040e8 <fileclose>
    fileclose(wf);
    8000541e:	fc843503          	ld	a0,-56(s0)
    80005422:	cc7fe0ef          	jal	800040e8 <fileclose>
    return -1;
    80005426:	57fd                	li	a5,-1
    80005428:	a01d                	j	8000544e <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000542a:	fc442783          	lw	a5,-60(s0)
    8000542e:	0007c763          	bltz	a5,8000543c <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005432:	07e9                	addi	a5,a5,26
    80005434:	078e                	slli	a5,a5,0x3
    80005436:	97a6                	add	a5,a5,s1
    80005438:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000543c:	fd043503          	ld	a0,-48(s0)
    80005440:	ca9fe0ef          	jal	800040e8 <fileclose>
    fileclose(wf);
    80005444:	fc843503          	ld	a0,-56(s0)
    80005448:	ca1fe0ef          	jal	800040e8 <fileclose>
    return -1;
    8000544c:	57fd                	li	a5,-1
}
    8000544e:	853e                	mv	a0,a5
    80005450:	70e2                	ld	ra,56(sp)
    80005452:	7442                	ld	s0,48(sp)
    80005454:	74a2                	ld	s1,40(sp)
    80005456:	6121                	addi	sp,sp,64
    80005458:	8082                	ret
    8000545a:	0000                	unimp
    8000545c:	0000                	unimp
	...

0000000080005460 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005460:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005462:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005464:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005466:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005468:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000546a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000546c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000546e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005470:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005472:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005474:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005476:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005478:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000547a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000547c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000547e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005480:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005482:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005484:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005486:	9dcfd0ef          	jal	80002662 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000548a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000548c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000548e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005490:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005492:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005494:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005496:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005498:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000549a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000549c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000549e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800054a0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800054a2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800054a4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800054a6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800054a8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800054aa:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800054ac:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800054ae:	10200073          	sret
	...

00000000800054be <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800054be:	1141                	addi	sp,sp,-16
    800054c0:	e422                	sd	s0,8(sp)
    800054c2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800054c4:	0c0007b7          	lui	a5,0xc000
    800054c8:	4705                	li	a4,1
    800054ca:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800054cc:	0c0007b7          	lui	a5,0xc000
    800054d0:	c3d8                	sw	a4,4(a5)
}
    800054d2:	6422                	ld	s0,8(sp)
    800054d4:	0141                	addi	sp,sp,16
    800054d6:	8082                	ret

00000000800054d8 <plicinithart>:

void
plicinithart(void)
{
    800054d8:	1141                	addi	sp,sp,-16
    800054da:	e406                	sd	ra,8(sp)
    800054dc:	e022                	sd	s0,0(sp)
    800054de:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800054e0:	bc2fc0ef          	jal	800018a2 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800054e4:	0085171b          	slliw	a4,a0,0x8
    800054e8:	0c0027b7          	lui	a5,0xc002
    800054ec:	97ba                	add	a5,a5,a4
    800054ee:	40200713          	li	a4,1026
    800054f2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800054f6:	00d5151b          	slliw	a0,a0,0xd
    800054fa:	0c2017b7          	lui	a5,0xc201
    800054fe:	97aa                	add	a5,a5,a0
    80005500:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005504:	60a2                	ld	ra,8(sp)
    80005506:	6402                	ld	s0,0(sp)
    80005508:	0141                	addi	sp,sp,16
    8000550a:	8082                	ret

000000008000550c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000550c:	1141                	addi	sp,sp,-16
    8000550e:	e406                	sd	ra,8(sp)
    80005510:	e022                	sd	s0,0(sp)
    80005512:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005514:	b8efc0ef          	jal	800018a2 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005518:	00d5151b          	slliw	a0,a0,0xd
    8000551c:	0c2017b7          	lui	a5,0xc201
    80005520:	97aa                	add	a5,a5,a0
  return irq;
}
    80005522:	43c8                	lw	a0,4(a5)
    80005524:	60a2                	ld	ra,8(sp)
    80005526:	6402                	ld	s0,0(sp)
    80005528:	0141                	addi	sp,sp,16
    8000552a:	8082                	ret

000000008000552c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000552c:	1101                	addi	sp,sp,-32
    8000552e:	ec06                	sd	ra,24(sp)
    80005530:	e822                	sd	s0,16(sp)
    80005532:	e426                	sd	s1,8(sp)
    80005534:	1000                	addi	s0,sp,32
    80005536:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005538:	b6afc0ef          	jal	800018a2 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000553c:	00d5151b          	slliw	a0,a0,0xd
    80005540:	0c2017b7          	lui	a5,0xc201
    80005544:	97aa                	add	a5,a5,a0
    80005546:	c3c4                	sw	s1,4(a5)
}
    80005548:	60e2                	ld	ra,24(sp)
    8000554a:	6442                	ld	s0,16(sp)
    8000554c:	64a2                	ld	s1,8(sp)
    8000554e:	6105                	addi	sp,sp,32
    80005550:	8082                	ret

0000000080005552 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005552:	1141                	addi	sp,sp,-16
    80005554:	e406                	sd	ra,8(sp)
    80005556:	e022                	sd	s0,0(sp)
    80005558:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000555a:	479d                	li	a5,7
    8000555c:	04a7ca63          	blt	a5,a0,800055b0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005560:	0001e797          	auipc	a5,0x1e
    80005564:	f0878793          	addi	a5,a5,-248 # 80023468 <disk>
    80005568:	97aa                	add	a5,a5,a0
    8000556a:	0187c783          	lbu	a5,24(a5)
    8000556e:	e7b9                	bnez	a5,800055bc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005570:	00451693          	slli	a3,a0,0x4
    80005574:	0001e797          	auipc	a5,0x1e
    80005578:	ef478793          	addi	a5,a5,-268 # 80023468 <disk>
    8000557c:	6398                	ld	a4,0(a5)
    8000557e:	9736                	add	a4,a4,a3
    80005580:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005584:	6398                	ld	a4,0(a5)
    80005586:	9736                	add	a4,a4,a3
    80005588:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000558c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005590:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005594:	97aa                	add	a5,a5,a0
    80005596:	4705                	li	a4,1
    80005598:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000559c:	0001e517          	auipc	a0,0x1e
    800055a0:	ee450513          	addi	a0,a0,-284 # 80023480 <disk+0x18>
    800055a4:	981fc0ef          	jal	80001f24 <wakeup>
}
    800055a8:	60a2                	ld	ra,8(sp)
    800055aa:	6402                	ld	s0,0(sp)
    800055ac:	0141                	addi	sp,sp,16
    800055ae:	8082                	ret
    panic("free_desc 1");
    800055b0:	00002517          	auipc	a0,0x2
    800055b4:	08050513          	addi	a0,a0,128 # 80007630 <etext+0x630>
    800055b8:	a28fb0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    800055bc:	00002517          	auipc	a0,0x2
    800055c0:	08450513          	addi	a0,a0,132 # 80007640 <etext+0x640>
    800055c4:	a1cfb0ef          	jal	800007e0 <panic>

00000000800055c8 <virtio_disk_init>:
{
    800055c8:	1101                	addi	sp,sp,-32
    800055ca:	ec06                	sd	ra,24(sp)
    800055cc:	e822                	sd	s0,16(sp)
    800055ce:	e426                	sd	s1,8(sp)
    800055d0:	e04a                	sd	s2,0(sp)
    800055d2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800055d4:	00002597          	auipc	a1,0x2
    800055d8:	07c58593          	addi	a1,a1,124 # 80007650 <etext+0x650>
    800055dc:	0001e517          	auipc	a0,0x1e
    800055e0:	fb450513          	addi	a0,a0,-76 # 80023590 <disk+0x128>
    800055e4:	d6afb0ef          	jal	80000b4e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800055e8:	100017b7          	lui	a5,0x10001
    800055ec:	4398                	lw	a4,0(a5)
    800055ee:	2701                	sext.w	a4,a4
    800055f0:	747277b7          	lui	a5,0x74727
    800055f4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800055f8:	18f71063          	bne	a4,a5,80005778 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800055fc:	100017b7          	lui	a5,0x10001
    80005600:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005602:	439c                	lw	a5,0(a5)
    80005604:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005606:	4709                	li	a4,2
    80005608:	16e79863          	bne	a5,a4,80005778 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000560c:	100017b7          	lui	a5,0x10001
    80005610:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005612:	439c                	lw	a5,0(a5)
    80005614:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005616:	16e79163          	bne	a5,a4,80005778 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000561a:	100017b7          	lui	a5,0x10001
    8000561e:	47d8                	lw	a4,12(a5)
    80005620:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005622:	554d47b7          	lui	a5,0x554d4
    80005626:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000562a:	14f71763          	bne	a4,a5,80005778 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000562e:	100017b7          	lui	a5,0x10001
    80005632:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005636:	4705                	li	a4,1
    80005638:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000563a:	470d                	li	a4,3
    8000563c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000563e:	10001737          	lui	a4,0x10001
    80005642:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005644:	c7ffe737          	lui	a4,0xc7ffe
    80005648:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb1b7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000564c:	8ef9                	and	a3,a3,a4
    8000564e:	10001737          	lui	a4,0x10001
    80005652:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005654:	472d                	li	a4,11
    80005656:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005658:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000565c:	439c                	lw	a5,0(a5)
    8000565e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005662:	8ba1                	andi	a5,a5,8
    80005664:	12078063          	beqz	a5,80005784 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005668:	100017b7          	lui	a5,0x10001
    8000566c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005670:	100017b7          	lui	a5,0x10001
    80005674:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005678:	439c                	lw	a5,0(a5)
    8000567a:	2781                	sext.w	a5,a5
    8000567c:	10079a63          	bnez	a5,80005790 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005680:	100017b7          	lui	a5,0x10001
    80005684:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005688:	439c                	lw	a5,0(a5)
    8000568a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000568c:	10078863          	beqz	a5,8000579c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005690:	471d                	li	a4,7
    80005692:	10f77b63          	bgeu	a4,a5,800057a8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005696:	c68fb0ef          	jal	80000afe <kalloc>
    8000569a:	0001e497          	auipc	s1,0x1e
    8000569e:	dce48493          	addi	s1,s1,-562 # 80023468 <disk>
    800056a2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800056a4:	c5afb0ef          	jal	80000afe <kalloc>
    800056a8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800056aa:	c54fb0ef          	jal	80000afe <kalloc>
    800056ae:	87aa                	mv	a5,a0
    800056b0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800056b2:	6088                	ld	a0,0(s1)
    800056b4:	10050063          	beqz	a0,800057b4 <virtio_disk_init+0x1ec>
    800056b8:	0001e717          	auipc	a4,0x1e
    800056bc:	db873703          	ld	a4,-584(a4) # 80023470 <disk+0x8>
    800056c0:	0e070a63          	beqz	a4,800057b4 <virtio_disk_init+0x1ec>
    800056c4:	0e078863          	beqz	a5,800057b4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    800056c8:	6605                	lui	a2,0x1
    800056ca:	4581                	li	a1,0
    800056cc:	dd6fb0ef          	jal	80000ca2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800056d0:	0001e497          	auipc	s1,0x1e
    800056d4:	d9848493          	addi	s1,s1,-616 # 80023468 <disk>
    800056d8:	6605                	lui	a2,0x1
    800056da:	4581                	li	a1,0
    800056dc:	6488                	ld	a0,8(s1)
    800056de:	dc4fb0ef          	jal	80000ca2 <memset>
  memset(disk.used, 0, PGSIZE);
    800056e2:	6605                	lui	a2,0x1
    800056e4:	4581                	li	a1,0
    800056e6:	6888                	ld	a0,16(s1)
    800056e8:	dbafb0ef          	jal	80000ca2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800056ec:	100017b7          	lui	a5,0x10001
    800056f0:	4721                	li	a4,8
    800056f2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800056f4:	4098                	lw	a4,0(s1)
    800056f6:	100017b7          	lui	a5,0x10001
    800056fa:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800056fe:	40d8                	lw	a4,4(s1)
    80005700:	100017b7          	lui	a5,0x10001
    80005704:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005708:	649c                	ld	a5,8(s1)
    8000570a:	0007869b          	sext.w	a3,a5
    8000570e:	10001737          	lui	a4,0x10001
    80005712:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005716:	9781                	srai	a5,a5,0x20
    80005718:	10001737          	lui	a4,0x10001
    8000571c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005720:	689c                	ld	a5,16(s1)
    80005722:	0007869b          	sext.w	a3,a5
    80005726:	10001737          	lui	a4,0x10001
    8000572a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000572e:	9781                	srai	a5,a5,0x20
    80005730:	10001737          	lui	a4,0x10001
    80005734:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005738:	10001737          	lui	a4,0x10001
    8000573c:	4785                	li	a5,1
    8000573e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005740:	00f48c23          	sb	a5,24(s1)
    80005744:	00f48ca3          	sb	a5,25(s1)
    80005748:	00f48d23          	sb	a5,26(s1)
    8000574c:	00f48da3          	sb	a5,27(s1)
    80005750:	00f48e23          	sb	a5,28(s1)
    80005754:	00f48ea3          	sb	a5,29(s1)
    80005758:	00f48f23          	sb	a5,30(s1)
    8000575c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005760:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005764:	100017b7          	lui	a5,0x10001
    80005768:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000576c:	60e2                	ld	ra,24(sp)
    8000576e:	6442                	ld	s0,16(sp)
    80005770:	64a2                	ld	s1,8(sp)
    80005772:	6902                	ld	s2,0(sp)
    80005774:	6105                	addi	sp,sp,32
    80005776:	8082                	ret
    panic("could not find virtio disk");
    80005778:	00002517          	auipc	a0,0x2
    8000577c:	ee850513          	addi	a0,a0,-280 # 80007660 <etext+0x660>
    80005780:	860fb0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005784:	00002517          	auipc	a0,0x2
    80005788:	efc50513          	addi	a0,a0,-260 # 80007680 <etext+0x680>
    8000578c:	854fb0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    80005790:	00002517          	auipc	a0,0x2
    80005794:	f1050513          	addi	a0,a0,-240 # 800076a0 <etext+0x6a0>
    80005798:	848fb0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    8000579c:	00002517          	auipc	a0,0x2
    800057a0:	f2450513          	addi	a0,a0,-220 # 800076c0 <etext+0x6c0>
    800057a4:	83cfb0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    800057a8:	00002517          	auipc	a0,0x2
    800057ac:	f3850513          	addi	a0,a0,-200 # 800076e0 <etext+0x6e0>
    800057b0:	830fb0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    800057b4:	00002517          	auipc	a0,0x2
    800057b8:	f4c50513          	addi	a0,a0,-180 # 80007700 <etext+0x700>
    800057bc:	824fb0ef          	jal	800007e0 <panic>

00000000800057c0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800057c0:	7159                	addi	sp,sp,-112
    800057c2:	f486                	sd	ra,104(sp)
    800057c4:	f0a2                	sd	s0,96(sp)
    800057c6:	eca6                	sd	s1,88(sp)
    800057c8:	e8ca                	sd	s2,80(sp)
    800057ca:	e4ce                	sd	s3,72(sp)
    800057cc:	e0d2                	sd	s4,64(sp)
    800057ce:	fc56                	sd	s5,56(sp)
    800057d0:	f85a                	sd	s6,48(sp)
    800057d2:	f45e                	sd	s7,40(sp)
    800057d4:	f062                	sd	s8,32(sp)
    800057d6:	ec66                	sd	s9,24(sp)
    800057d8:	1880                	addi	s0,sp,112
    800057da:	8a2a                	mv	s4,a0
    800057dc:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800057de:	00c52c83          	lw	s9,12(a0)
    800057e2:	001c9c9b          	slliw	s9,s9,0x1
    800057e6:	1c82                	slli	s9,s9,0x20
    800057e8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800057ec:	0001e517          	auipc	a0,0x1e
    800057f0:	da450513          	addi	a0,a0,-604 # 80023590 <disk+0x128>
    800057f4:	bdafb0ef          	jal	80000bce <acquire>
  for(int i = 0; i < 3; i++){
    800057f8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800057fa:	44a1                	li	s1,8
      disk.free[i] = 0;
    800057fc:	0001eb17          	auipc	s6,0x1e
    80005800:	c6cb0b13          	addi	s6,s6,-916 # 80023468 <disk>
  for(int i = 0; i < 3; i++){
    80005804:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005806:	0001ec17          	auipc	s8,0x1e
    8000580a:	d8ac0c13          	addi	s8,s8,-630 # 80023590 <disk+0x128>
    8000580e:	a8b9                	j	8000586c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005810:	00fb0733          	add	a4,s6,a5
    80005814:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005818:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000581a:	0207c563          	bltz	a5,80005844 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000581e:	2905                	addiw	s2,s2,1
    80005820:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005822:	05590963          	beq	s2,s5,80005874 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005826:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005828:	0001e717          	auipc	a4,0x1e
    8000582c:	c4070713          	addi	a4,a4,-960 # 80023468 <disk>
    80005830:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005832:	01874683          	lbu	a3,24(a4)
    80005836:	fee9                	bnez	a3,80005810 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005838:	2785                	addiw	a5,a5,1
    8000583a:	0705                	addi	a4,a4,1
    8000583c:	fe979be3          	bne	a5,s1,80005832 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005840:	57fd                	li	a5,-1
    80005842:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005844:	01205d63          	blez	s2,8000585e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005848:	f9042503          	lw	a0,-112(s0)
    8000584c:	d07ff0ef          	jal	80005552 <free_desc>
      for(int j = 0; j < i; j++)
    80005850:	4785                	li	a5,1
    80005852:	0127d663          	bge	a5,s2,8000585e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005856:	f9442503          	lw	a0,-108(s0)
    8000585a:	cf9ff0ef          	jal	80005552 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000585e:	85e2                	mv	a1,s8
    80005860:	0001e517          	auipc	a0,0x1e
    80005864:	c2050513          	addi	a0,a0,-992 # 80023480 <disk+0x18>
    80005868:	e70fc0ef          	jal	80001ed8 <sleep>
  for(int i = 0; i < 3; i++){
    8000586c:	f9040613          	addi	a2,s0,-112
    80005870:	894e                	mv	s2,s3
    80005872:	bf55                	j	80005826 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005874:	f9042503          	lw	a0,-112(s0)
    80005878:	00451693          	slli	a3,a0,0x4

  if(write)
    8000587c:	0001e797          	auipc	a5,0x1e
    80005880:	bec78793          	addi	a5,a5,-1044 # 80023468 <disk>
    80005884:	00a50713          	addi	a4,a0,10
    80005888:	0712                	slli	a4,a4,0x4
    8000588a:	973e                	add	a4,a4,a5
    8000588c:	01703633          	snez	a2,s7
    80005890:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005892:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005896:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000589a:	6398                	ld	a4,0(a5)
    8000589c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000589e:	0a868613          	addi	a2,a3,168
    800058a2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800058a4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800058a6:	6390                	ld	a2,0(a5)
    800058a8:	00d605b3          	add	a1,a2,a3
    800058ac:	4741                	li	a4,16
    800058ae:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800058b0:	4805                	li	a6,1
    800058b2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800058b6:	f9442703          	lw	a4,-108(s0)
    800058ba:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800058be:	0712                	slli	a4,a4,0x4
    800058c0:	963a                	add	a2,a2,a4
    800058c2:	058a0593          	addi	a1,s4,88
    800058c6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800058c8:	0007b883          	ld	a7,0(a5)
    800058cc:	9746                	add	a4,a4,a7
    800058ce:	40000613          	li	a2,1024
    800058d2:	c710                	sw	a2,8(a4)
  if(write)
    800058d4:	001bb613          	seqz	a2,s7
    800058d8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800058dc:	00166613          	ori	a2,a2,1
    800058e0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800058e4:	f9842583          	lw	a1,-104(s0)
    800058e8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800058ec:	00250613          	addi	a2,a0,2
    800058f0:	0612                	slli	a2,a2,0x4
    800058f2:	963e                	add	a2,a2,a5
    800058f4:	577d                	li	a4,-1
    800058f6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800058fa:	0592                	slli	a1,a1,0x4
    800058fc:	98ae                	add	a7,a7,a1
    800058fe:	03068713          	addi	a4,a3,48
    80005902:	973e                	add	a4,a4,a5
    80005904:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005908:	6398                	ld	a4,0(a5)
    8000590a:	972e                	add	a4,a4,a1
    8000590c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005910:	4689                	li	a3,2
    80005912:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005916:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000591a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000591e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005922:	6794                	ld	a3,8(a5)
    80005924:	0026d703          	lhu	a4,2(a3)
    80005928:	8b1d                	andi	a4,a4,7
    8000592a:	0706                	slli	a4,a4,0x1
    8000592c:	96ba                	add	a3,a3,a4
    8000592e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005932:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005936:	6798                	ld	a4,8(a5)
    80005938:	00275783          	lhu	a5,2(a4)
    8000593c:	2785                	addiw	a5,a5,1
    8000593e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005942:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005946:	100017b7          	lui	a5,0x10001
    8000594a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000594e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005952:	0001e917          	auipc	s2,0x1e
    80005956:	c3e90913          	addi	s2,s2,-962 # 80023590 <disk+0x128>
  while(b->disk == 1) {
    8000595a:	4485                	li	s1,1
    8000595c:	01079a63          	bne	a5,a6,80005970 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005960:	85ca                	mv	a1,s2
    80005962:	8552                	mv	a0,s4
    80005964:	d74fc0ef          	jal	80001ed8 <sleep>
  while(b->disk == 1) {
    80005968:	004a2783          	lw	a5,4(s4)
    8000596c:	fe978ae3          	beq	a5,s1,80005960 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005970:	f9042903          	lw	s2,-112(s0)
    80005974:	00290713          	addi	a4,s2,2
    80005978:	0712                	slli	a4,a4,0x4
    8000597a:	0001e797          	auipc	a5,0x1e
    8000597e:	aee78793          	addi	a5,a5,-1298 # 80023468 <disk>
    80005982:	97ba                	add	a5,a5,a4
    80005984:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005988:	0001e997          	auipc	s3,0x1e
    8000598c:	ae098993          	addi	s3,s3,-1312 # 80023468 <disk>
    80005990:	00491713          	slli	a4,s2,0x4
    80005994:	0009b783          	ld	a5,0(s3)
    80005998:	97ba                	add	a5,a5,a4
    8000599a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000599e:	854a                	mv	a0,s2
    800059a0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800059a4:	bafff0ef          	jal	80005552 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800059a8:	8885                	andi	s1,s1,1
    800059aa:	f0fd                	bnez	s1,80005990 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800059ac:	0001e517          	auipc	a0,0x1e
    800059b0:	be450513          	addi	a0,a0,-1052 # 80023590 <disk+0x128>
    800059b4:	ab2fb0ef          	jal	80000c66 <release>
}
    800059b8:	70a6                	ld	ra,104(sp)
    800059ba:	7406                	ld	s0,96(sp)
    800059bc:	64e6                	ld	s1,88(sp)
    800059be:	6946                	ld	s2,80(sp)
    800059c0:	69a6                	ld	s3,72(sp)
    800059c2:	6a06                	ld	s4,64(sp)
    800059c4:	7ae2                	ld	s5,56(sp)
    800059c6:	7b42                	ld	s6,48(sp)
    800059c8:	7ba2                	ld	s7,40(sp)
    800059ca:	7c02                	ld	s8,32(sp)
    800059cc:	6ce2                	ld	s9,24(sp)
    800059ce:	6165                	addi	sp,sp,112
    800059d0:	8082                	ret

00000000800059d2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800059d2:	1101                	addi	sp,sp,-32
    800059d4:	ec06                	sd	ra,24(sp)
    800059d6:	e822                	sd	s0,16(sp)
    800059d8:	e426                	sd	s1,8(sp)
    800059da:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800059dc:	0001e497          	auipc	s1,0x1e
    800059e0:	a8c48493          	addi	s1,s1,-1396 # 80023468 <disk>
    800059e4:	0001e517          	auipc	a0,0x1e
    800059e8:	bac50513          	addi	a0,a0,-1108 # 80023590 <disk+0x128>
    800059ec:	9e2fb0ef          	jal	80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800059f0:	100017b7          	lui	a5,0x10001
    800059f4:	53b8                	lw	a4,96(a5)
    800059f6:	8b0d                	andi	a4,a4,3
    800059f8:	100017b7          	lui	a5,0x10001
    800059fc:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800059fe:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005a02:	689c                	ld	a5,16(s1)
    80005a04:	0204d703          	lhu	a4,32(s1)
    80005a08:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005a0c:	04f70663          	beq	a4,a5,80005a58 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005a10:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005a14:	6898                	ld	a4,16(s1)
    80005a16:	0204d783          	lhu	a5,32(s1)
    80005a1a:	8b9d                	andi	a5,a5,7
    80005a1c:	078e                	slli	a5,a5,0x3
    80005a1e:	97ba                	add	a5,a5,a4
    80005a20:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005a22:	00278713          	addi	a4,a5,2
    80005a26:	0712                	slli	a4,a4,0x4
    80005a28:	9726                	add	a4,a4,s1
    80005a2a:	01074703          	lbu	a4,16(a4)
    80005a2e:	e321                	bnez	a4,80005a6e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005a30:	0789                	addi	a5,a5,2
    80005a32:	0792                	slli	a5,a5,0x4
    80005a34:	97a6                	add	a5,a5,s1
    80005a36:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005a38:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005a3c:	ce8fc0ef          	jal	80001f24 <wakeup>

    disk.used_idx += 1;
    80005a40:	0204d783          	lhu	a5,32(s1)
    80005a44:	2785                	addiw	a5,a5,1
    80005a46:	17c2                	slli	a5,a5,0x30
    80005a48:	93c1                	srli	a5,a5,0x30
    80005a4a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005a4e:	6898                	ld	a4,16(s1)
    80005a50:	00275703          	lhu	a4,2(a4)
    80005a54:	faf71ee3          	bne	a4,a5,80005a10 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005a58:	0001e517          	auipc	a0,0x1e
    80005a5c:	b3850513          	addi	a0,a0,-1224 # 80023590 <disk+0x128>
    80005a60:	a06fb0ef          	jal	80000c66 <release>
}
    80005a64:	60e2                	ld	ra,24(sp)
    80005a66:	6442                	ld	s0,16(sp)
    80005a68:	64a2                	ld	s1,8(sp)
    80005a6a:	6105                	addi	sp,sp,32
    80005a6c:	8082                	ret
      panic("virtio_disk_intr status");
    80005a6e:	00002517          	auipc	a0,0x2
    80005a72:	caa50513          	addi	a0,a0,-854 # 80007718 <etext+0x718>
    80005a76:	d6bfa0ef          	jal	800007e0 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
