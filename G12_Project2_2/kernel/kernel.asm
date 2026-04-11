
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
    80000004:	17813103          	ld	sp,376(sp) # 8000a178 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb337>
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
    80000190:	03450513          	addi	a0,a0,52 # 800121c0 <cons>
    80000194:	23b000ef          	jal	80000bce <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	00012497          	auipc	s1,0x12
    8000019c:	02848493          	addi	s1,s1,40 # 800121c0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	00012917          	auipc	s2,0x12
    800001a4:	0b890913          	addi	s2,s2,184 # 80012258 <cons+0x98>
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
    800001dc:	fe870713          	addi	a4,a4,-24 # 800121c0 <cons>
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
    80000226:	f9e50513          	addi	a0,a0,-98 # 800121c0 <cons>
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
    80000250:	00f72623          	sw	a5,12(a4) # 80012258 <cons+0x98>
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	a031                	j	80000262 <consoleread+0xf4>
    80000258:	ec5e                	sd	s7,24(sp)
    8000025a:	bfbd                	j	800001d8 <consoleread+0x6a>
    8000025c:	6be2                	ld	s7,24(sp)
    8000025e:	a011                	j	80000262 <consoleread+0xf4>
    80000260:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000262:	00012517          	auipc	a0,0x12
    80000266:	f5e50513          	addi	a0,a0,-162 # 800121c0 <cons>
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
    800002ba:	f0a50513          	addi	a0,a0,-246 # 800121c0 <cons>
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
    800002e0:	ee450513          	addi	a0,a0,-284 # 800121c0 <cons>
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
    800002fe:	ec670713          	addi	a4,a4,-314 # 800121c0 <cons>
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
    80000324:	ea078793          	addi	a5,a5,-352 # 800121c0 <cons>
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
    80000352:	f0a7a783          	lw	a5,-246(a5) # 80012258 <cons+0x98>
    80000356:	9f1d                	subw	a4,a4,a5
    80000358:	08000793          	li	a5,128
    8000035c:	f8f710e3          	bne	a4,a5,800002dc <consoleintr+0x32>
    80000360:	a07d                	j	8000040e <consoleintr+0x164>
    80000362:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000364:	00012717          	auipc	a4,0x12
    80000368:	e5c70713          	addi	a4,a4,-420 # 800121c0 <cons>
    8000036c:	0a072783          	lw	a5,160(a4)
    80000370:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000374:	00012497          	auipc	s1,0x12
    80000378:	e4c48493          	addi	s1,s1,-436 # 800121c0 <cons>
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
    800003ba:	e0a70713          	addi	a4,a4,-502 # 800121c0 <cons>
    800003be:	0a072783          	lw	a5,160(a4)
    800003c2:	09c72703          	lw	a4,156(a4)
    800003c6:	f0f70be3          	beq	a4,a5,800002dc <consoleintr+0x32>
      cons.e--;
    800003ca:	37fd                	addiw	a5,a5,-1
    800003cc:	00012717          	auipc	a4,0x12
    800003d0:	e8f72a23          	sw	a5,-364(a4) # 80012260 <cons+0xa0>
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
    800003ee:	dd678793          	addi	a5,a5,-554 # 800121c0 <cons>
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
    80000412:	e4c7a723          	sw	a2,-434(a5) # 8001225c <cons+0x9c>
        wakeup(&cons.r);
    80000416:	00012517          	auipc	a0,0x12
    8000041a:	e4250513          	addi	a0,a0,-446 # 80012258 <cons+0x98>
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
    80000438:	d8c50513          	addi	a0,a0,-628 # 800121c0 <cons>
    8000043c:	712000ef          	jal	80000b4e <initlock>

  uartinit();
    80000440:	400000ef          	jal	80000840 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000444:	00022797          	auipc	a5,0x22
    80000448:	eec78793          	addi	a5,a5,-276 # 80022330 <devsw>
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
    80000482:	29260613          	addi	a2,a2,658 # 80007710 <digits>
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
    8000051c:	c7c7a783          	lw	a5,-900(a5) # 8000a194 <panicking>
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
    80000564:	d0850513          	addi	a0,a0,-760 # 80012268 <pr>
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
    8000072c:	fe8b8b93          	addi	s7,s7,-24 # 80007710 <digits>
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
    800007c0:	9d87a783          	lw	a5,-1576(a5) # 8000a194 <panicking>
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
    800007d6:	a9650513          	addi	a0,a0,-1386 # 80012268 <pr>
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
    800007f4:	9b27a223          	sw	s2,-1628(a5) # 8000a194 <panicking>
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
    80000816:	9727af23          	sw	s2,-1666(a5) # 8000a190 <panicked>
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
    80000830:	a3c50513          	addi	a0,a0,-1476 # 80012268 <pr>
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
    80000888:	9fc50513          	addi	a0,a0,-1540 # 80012280 <tx_lock>
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
    800008ac:	9d850513          	addi	a0,a0,-1576 # 80012280 <tx_lock>
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
    800008ca:	8d648493          	addi	s1,s1,-1834 # 8000a19c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008ce:	00012997          	auipc	s3,0x12
    800008d2:	9b298993          	addi	s3,s3,-1614 # 80012280 <tx_lock>
    800008d6:	0000a917          	auipc	s2,0xa
    800008da:	8c290913          	addi	s2,s2,-1854 # 8000a198 <tx_chan>
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
    80000918:	96c50513          	addi	a0,a0,-1684 # 80012280 <tx_lock>
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
    8000093c:	85c7a783          	lw	a5,-1956(a5) # 8000a194 <panicking>
    80000940:	cf95                	beqz	a5,8000097c <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000942:	0000a797          	auipc	a5,0xa
    80000946:	84e7a783          	lw	a5,-1970(a5) # 8000a190 <panicked>
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
    8000096c:	82c7a783          	lw	a5,-2004(a5) # 8000a194 <panicking>
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
    800009c8:	8bc50513          	addi	a0,a0,-1860 # 80012280 <tx_lock>
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
    800009e4:	8a050513          	addi	a0,a0,-1888 # 80012280 <tx_lock>
    800009e8:	27e000ef          	jal	80000c66 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ec:	54fd                	li	s1,-1
    800009ee:	a831                	j	80000a0a <uartintr+0x5a>
    tx_busy = 0;
    800009f0:	00009797          	auipc	a5,0x9
    800009f4:	7a07a623          	sw	zero,1964(a5) # 8000a19c <tx_busy>
    wakeup(&tx_chan);
    800009f8:	00009517          	auipc	a0,0x9
    800009fc:	7a050513          	addi	a0,a0,1952 # 8000a198 <tx_chan>
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
    80000a34:	a9878793          	addi	a5,a5,-1384 # 800234c8 <end>
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
    80000a50:	84c90913          	addi	s2,s2,-1972 # 80012298 <kmem>
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
    80000ada:	00011517          	auipc	a0,0x11
    80000ade:	7be50513          	addi	a0,a0,1982 # 80012298 <kmem>
    80000ae2:	06c000ef          	jal	80000b4e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ae6:	45c5                	li	a1,17
    80000ae8:	05ee                	slli	a1,a1,0x1b
    80000aea:	00023517          	auipc	a0,0x23
    80000aee:	9de50513          	addi	a0,a0,-1570 # 800234c8 <end>
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
    80000b08:	00011497          	auipc	s1,0x11
    80000b0c:	79048493          	addi	s1,s1,1936 # 80012298 <kmem>
    80000b10:	8526                	mv	a0,s1
    80000b12:	0bc000ef          	jal	80000bce <acquire>
  r = kmem.freelist;
    80000b16:	6c84                	ld	s1,24(s1)
  if(r)
    80000b18:	c485                	beqz	s1,80000b40 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b1a:	609c                	ld	a5,0(s1)
    80000b1c:	00011517          	auipc	a0,0x11
    80000b20:	77c50513          	addi	a0,a0,1916 # 80012298 <kmem>
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
    80000b40:	00011517          	auipc	a0,0x11
    80000b44:	75850513          	addi	a0,a0,1880 # 80012298 <kmem>
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
    80000d16:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdbb39>
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
    80000e4c:	35870713          	addi	a4,a4,856 # 8000a1a0 <started>
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
    80000e76:	552040ef          	jal	800053c8 <plicinithart>
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
    80000ec2:	4ec040ef          	jal	800053ae <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ec6:	502040ef          	jal	800053c8 <plicinithart>
    binit();         // buffer cache
    80000eca:	3c7010ef          	jal	80002a90 <binit>
    iinit();         // inode table
    80000ece:	14c020ef          	jal	8000301a <iinit>
    fileinit();      // file table
    80000ed2:	03e030ef          	jal	80003f10 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ed6:	5e2040ef          	jal	800054b8 <virtio_disk_init>
    userinit();      // first user process
    80000eda:	4bb000ef          	jal	80001b94 <userinit>
    __sync_synchronize();
    80000ede:	0330000f          	fence	rw,rw
    started = 1;
    80000ee2:	4785                	li	a5,1
    80000ee4:	00009717          	auipc	a4,0x9
    80000ee8:	2af72e23          	sw	a5,700(a4) # 8000a1a0 <started>
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
    80000efc:	2b07b783          	ld	a5,688(a5) # 8000a1a8 <kernel_pagetable>
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
    80000f6a:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdbb2f>
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
    80001188:	02a7b223          	sd	a0,36(a5) # 8000a1a8 <kernel_pagetable>
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
    8000176e:	f7e48493          	addi	s1,s1,-130 # 800126e8 <proc>
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
    8000179a:	952a8a93          	addi	s5,s5,-1710 # 800180e8 <tickslock>
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
    8000180c:	ab050513          	addi	a0,a0,-1360 # 800122b8 <pid_lock>
    80001810:	b3eff0ef          	jal	80000b4e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001814:	00006597          	auipc	a1,0x6
    80001818:	95458593          	addi	a1,a1,-1708 # 80007168 <etext+0x168>
    8000181c:	00011517          	auipc	a0,0x11
    80001820:	ab450513          	addi	a0,a0,-1356 # 800122d0 <wait_lock>
    80001824:	b2aff0ef          	jal	80000b4e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001828:	00011497          	auipc	s1,0x11
    8000182c:	ec048493          	addi	s1,s1,-320 # 800126e8 <proc>
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
    80001860:	88ca0a13          	addi	s4,s4,-1908 # 800180e8 <tickslock>
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
    8000187a:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffdbb39>
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
    800018c2:	a2a50513          	addi	a0,a0,-1494 # 800122e8 <cpus>
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
    800018e6:	9d670713          	addi	a4,a4,-1578 # 800122b8 <pid_lock>
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
    80001916:	84e7a783          	lw	a5,-1970(a5) # 8000a160 <first.1>
    8000191a:	cf8d                	beqz	a5,80001954 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    8000191c:	4505                	li	a0,1
    8000191e:	3b9010ef          	jal	800034d6 <fsinit>

    first = 0;
    80001922:	00009797          	auipc	a5,0x9
    80001926:	8207af23          	sw	zero,-1986(a5) # 8000a160 <first.1>
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
    80001942:	49f020ef          	jal	800045e0 <kexec>
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
    800019a6:	91690913          	addi	s2,s2,-1770 # 800122b8 <pid_lock>
    800019aa:	854a                	mv	a0,s2
    800019ac:	a22ff0ef          	jal	80000bce <acquire>
  pid = nextpid;
    800019b0:	00008797          	auipc	a5,0x8
    800019b4:	7b478793          	addi	a5,a5,1972 # 8000a164 <nextpid>
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
    80001afe:	bee48493          	addi	s1,s1,-1042 # 800126e8 <proc>
    80001b02:	00016917          	auipc	s2,0x16
    80001b06:	5e690913          	addi	s2,s2,1510 # 800180e8 <tickslock>
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
    80001ba8:	60a7b623          	sd	a0,1548(a5) # 8000a1b0 <initproc>
  p->cwd = namei("/");
    80001bac:	00005517          	auipc	a0,0x5
    80001bb0:	5e450513          	addi	a0,a0,1508 # 80007190 <etext+0x190>
    80001bb4:	645010ef          	jal	800039f8 <namei>
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
    80001cd0:	2c2020ef          	jal	80003f92 <filedup>
    80001cd4:	00a93023          	sd	a0,0(s2)
    80001cd8:	b7f5                	j	80001cc4 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001cda:	150ab503          	ld	a0,336(s5)
    80001cde:	4ce010ef          	jal	800031ac <idup>
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
    80001d02:	5d248493          	addi	s1,s1,1490 # 800122d0 <wait_lock>
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
    80001d64:	55870713          	addi	a4,a4,1368 # 800122b8 <pid_lock>
    80001d68:	975a                	add	a4,a4,s6
    80001d6a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d6e:	00010717          	auipc	a4,0x10
    80001d72:	58270713          	addi	a4,a4,1410 # 800122f0 <cpus+0x8>
    80001d76:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d78:	4c11                	li	s8,4
        c->proc = p;
    80001d7a:	079e                	slli	a5,a5,0x7
    80001d7c:	00010a17          	auipc	s4,0x10
    80001d80:	53ca0a13          	addi	s4,s4,1340 # 800122b8 <pid_lock>
    80001d84:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d86:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d88:	00016997          	auipc	s3,0x16
    80001d8c:	36098993          	addi	s3,s3,864 # 800180e8 <tickslock>
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
    80001dea:	90248493          	addi	s1,s1,-1790 # 800126e8 <proc>
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
    80001e16:	4a670713          	addi	a4,a4,1190 # 800122b8 <pid_lock>
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
    80001e3c:	48090913          	addi	s2,s2,1152 # 800122b8 <pid_lock>
    80001e40:	2781                	sext.w	a5,a5
    80001e42:	079e                	slli	a5,a5,0x7
    80001e44:	97ca                	add	a5,a5,s2
    80001e46:	0ac7a983          	lw	s3,172(a5)
    80001e4a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e4c:	2781                	sext.w	a5,a5
    80001e4e:	079e                	slli	a5,a5,0x7
    80001e50:	00010597          	auipc	a1,0x10
    80001e54:	4a058593          	addi	a1,a1,1184 # 800122f0 <cpus+0x8>
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
    80001f38:	00010497          	auipc	s1,0x10
    80001f3c:	7b048493          	addi	s1,s1,1968 # 800126e8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f40:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f42:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f44:	00016917          	auipc	s2,0x16
    80001f48:	1a490913          	addi	s2,s2,420 # 800180e8 <tickslock>
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
    80001fa0:	00010497          	auipc	s1,0x10
    80001fa4:	74848493          	addi	s1,s1,1864 # 800126e8 <proc>
      pp->parent = initproc;
    80001fa8:	00008a17          	auipc	s4,0x8
    80001fac:	208a0a13          	addi	s4,s4,520 # 8000a1b0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fb0:	00016997          	auipc	s3,0x16
    80001fb4:	13898993          	addi	s3,s3,312 # 800180e8 <tickslock>
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
    80002000:	1b47b783          	ld	a5,436(a5) # 8000a1b0 <initproc>
    80002004:	0d050493          	addi	s1,a0,208
    80002008:	15050913          	addi	s2,a0,336
    8000200c:	00a79f63          	bne	a5,a0,8000202a <kexit+0x46>
    panic("init exiting");
    80002010:	00005517          	auipc	a0,0x5
    80002014:	1d050513          	addi	a0,a0,464 # 800071e0 <etext+0x1e0>
    80002018:	fc8fe0ef          	jal	800007e0 <panic>
      fileclose(f);
    8000201c:	7bd010ef          	jal	80003fd8 <fileclose>
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
    80002030:	39d010ef          	jal	80003bcc <begin_op>
  iput(p->cwd);
    80002034:	1509b503          	ld	a0,336(s3)
    80002038:	32c010ef          	jal	80003364 <iput>
  end_op();
    8000203c:	3fb010ef          	jal	80003c36 <end_op>
  p->cwd = 0;
    80002040:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002044:	00010497          	auipc	s1,0x10
    80002048:	28c48493          	addi	s1,s1,652 # 800122d0 <wait_lock>
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
    8000209a:	65248493          	addi	s1,s1,1618 # 800126e8 <proc>
    8000209e:	00016997          	auipc	s3,0x16
    800020a2:	04a98993          	addi	s3,s3,74 # 800180e8 <tickslock>
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
    8000215e:	17650513          	addi	a0,a0,374 # 800122d0 <wait_lock>
    80002162:	a6dfe0ef          	jal	80000bce <acquire>
    havekids = 0;
    80002166:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002168:	4a15                	li	s4,5
        havekids = 1;
    8000216a:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000216c:	00016997          	auipc	s3,0x16
    80002170:	f7c98993          	addi	s3,s3,-132 # 800180e8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002174:	00010c17          	auipc	s8,0x10
    80002178:	15cc0c13          	addi	s8,s8,348 # 800122d0 <wait_lock>
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
    800021aa:	12a50513          	addi	a0,a0,298 # 800122d0 <wait_lock>
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
    800021d6:	0fe50513          	addi	a0,a0,254 # 800122d0 <wait_lock>
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
    8000221e:	4ce48493          	addi	s1,s1,1230 # 800126e8 <proc>
    80002222:	b7e1                	j	800021ea <kwait+0xb0>
      release(&wait_lock);
    80002224:	00010517          	auipc	a0,0x10
    80002228:	0ac50513          	addi	a0,a0,172 # 800122d0 <wait_lock>
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
    800022ee:	55648493          	addi	s1,s1,1366 # 80012840 <proc+0x158>
    800022f2:	00016917          	auipc	s2,0x16
    800022f6:	f4e90913          	addi	s2,s2,-178 # 80018240 <bcache+0x140>
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
    80002318:	414b8b93          	addi	s7,s7,1044 # 80007728 <states.0>
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
    800023ea:	d0250513          	addi	a0,a0,-766 # 800180e8 <tickslock>
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
    80002404:	f5078793          	addi	a5,a5,-176 # 80005350 <kernelvec>
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
    800024ba:	c3248493          	addi	s1,s1,-974 # 800180e8 <tickslock>
    800024be:	8526                	mv	a0,s1
    800024c0:	f0efe0ef          	jal	80000bce <acquire>
    ticks++;
    800024c4:	00008517          	auipc	a0,0x8
    800024c8:	cf450513          	addi	a0,a0,-780 # 8000a1b8 <ticks>
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
    8000250c:	6f1020ef          	jal	800053fc <plic_claim>
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
    8000252c:	396030ef          	jal	800058c2 <virtio_disk_intr>
    if(irq)
    80002530:	a801                	j	80002540 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002532:	85a6                	mv	a1,s1
    80002534:	00005517          	auipc	a0,0x5
    80002538:	d1c50513          	addi	a0,a0,-740 # 80007250 <etext+0x250>
    8000253c:	fbffd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002540:	8526                	mv	a0,s1
    80002542:	6db020ef          	jal	8000541c <plic_complete>
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
    8000256e:	de678793          	addi	a5,a5,-538 # 80005350 <kernelvec>
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
    8000270e:	04e70713          	addi	a4,a4,78 # 80007758 <states.0+0x30>
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
[SYS_close]   sys_close,
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
    80002864:	4751                	li	a4,20
    80002866:	00f76f63          	bltu	a4,a5,80002884 <syscall+0x40>
    8000286a:	00369713          	slli	a4,a3,0x3
    8000286e:	00005797          	auipc	a5,0x5
    80002872:	f0278793          	addi	a5,a5,-254 # 80007770 <syscalls>
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
    800029b0:	00015517          	auipc	a0,0x15
    800029b4:	73850513          	addi	a0,a0,1848 # 800180e8 <tickslock>
    800029b8:	a16fe0ef          	jal	80000bce <acquire>
  ticks0 = ticks;
    800029bc:	00007917          	auipc	s2,0x7
    800029c0:	7fc92903          	lw	s2,2044(s2) # 8000a1b8 <ticks>
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
    800029d2:	71a98993          	addi	s3,s3,1818 # 800180e8 <tickslock>
    800029d6:	00007497          	auipc	s1,0x7
    800029da:	7e248493          	addi	s1,s1,2018 # 8000a1b8 <ticks>
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
    80002a06:	6e650513          	addi	a0,a0,1766 # 800180e8 <tickslock>
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
    80002a24:	6c850513          	addi	a0,a0,1736 # 800180e8 <tickslock>
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
    80002a64:	68850513          	addi	a0,a0,1672 # 800180e8 <tickslock>
    80002a68:	966fe0ef          	jal	80000bce <acquire>
  xticks = ticks;
    80002a6c:	00007497          	auipc	s1,0x7
    80002a70:	74c4a483          	lw	s1,1868(s1) # 8000a1b8 <ticks>
  release(&tickslock);
    80002a74:	00015517          	auipc	a0,0x15
    80002a78:	67450513          	addi	a0,a0,1652 # 800180e8 <tickslock>
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

0000000080002a90 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002a90:	7179                	addi	sp,sp,-48
    80002a92:	f406                	sd	ra,40(sp)
    80002a94:	f022                	sd	s0,32(sp)
    80002a96:	ec26                	sd	s1,24(sp)
    80002a98:	e84a                	sd	s2,16(sp)
    80002a9a:	e44e                	sd	s3,8(sp)
    80002a9c:	e052                	sd	s4,0(sp)
    80002a9e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002aa0:	00005597          	auipc	a1,0x5
    80002aa4:	8f058593          	addi	a1,a1,-1808 # 80007390 <etext+0x390>
    80002aa8:	00015517          	auipc	a0,0x15
    80002aac:	65850513          	addi	a0,a0,1624 # 80018100 <bcache>
    80002ab0:	89efe0ef          	jal	80000b4e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ab4:	0001d797          	auipc	a5,0x1d
    80002ab8:	64c78793          	addi	a5,a5,1612 # 80020100 <bcache+0x8000>
    80002abc:	0001e717          	auipc	a4,0x1e
    80002ac0:	8ac70713          	addi	a4,a4,-1876 # 80020368 <bcache+0x8268>
    80002ac4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002ac8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002acc:	00015497          	auipc	s1,0x15
    80002ad0:	64c48493          	addi	s1,s1,1612 # 80018118 <bcache+0x18>
    b->next = bcache.head.next;
    80002ad4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ad6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ad8:	00005a17          	auipc	s4,0x5
    80002adc:	8c0a0a13          	addi	s4,s4,-1856 # 80007398 <etext+0x398>
    b->next = bcache.head.next;
    80002ae0:	2b893783          	ld	a5,696(s2)
    80002ae4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ae6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002aea:	85d2                	mv	a1,s4
    80002aec:	01048513          	addi	a0,s1,16
    80002af0:	322010ef          	jal	80003e12 <initsleeplock>
    bcache.head.next->prev = b;
    80002af4:	2b893783          	ld	a5,696(s2)
    80002af8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002afa:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002afe:	45848493          	addi	s1,s1,1112
    80002b02:	fd349fe3          	bne	s1,s3,80002ae0 <binit+0x50>
  }
}
    80002b06:	70a2                	ld	ra,40(sp)
    80002b08:	7402                	ld	s0,32(sp)
    80002b0a:	64e2                	ld	s1,24(sp)
    80002b0c:	6942                	ld	s2,16(sp)
    80002b0e:	69a2                	ld	s3,8(sp)
    80002b10:	6a02                	ld	s4,0(sp)
    80002b12:	6145                	addi	sp,sp,48
    80002b14:	8082                	ret

0000000080002b16 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002b16:	7179                	addi	sp,sp,-48
    80002b18:	f406                	sd	ra,40(sp)
    80002b1a:	f022                	sd	s0,32(sp)
    80002b1c:	ec26                	sd	s1,24(sp)
    80002b1e:	e84a                	sd	s2,16(sp)
    80002b20:	e44e                	sd	s3,8(sp)
    80002b22:	1800                	addi	s0,sp,48
    80002b24:	892a                	mv	s2,a0
    80002b26:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002b28:	00015517          	auipc	a0,0x15
    80002b2c:	5d850513          	addi	a0,a0,1496 # 80018100 <bcache>
    80002b30:	89efe0ef          	jal	80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002b34:	0001e497          	auipc	s1,0x1e
    80002b38:	8844b483          	ld	s1,-1916(s1) # 800203b8 <bcache+0x82b8>
    80002b3c:	0001e797          	auipc	a5,0x1e
    80002b40:	82c78793          	addi	a5,a5,-2004 # 80020368 <bcache+0x8268>
    80002b44:	02f48b63          	beq	s1,a5,80002b7a <bread+0x64>
    80002b48:	873e                	mv	a4,a5
    80002b4a:	a021                	j	80002b52 <bread+0x3c>
    80002b4c:	68a4                	ld	s1,80(s1)
    80002b4e:	02e48663          	beq	s1,a4,80002b7a <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002b52:	449c                	lw	a5,8(s1)
    80002b54:	ff279ce3          	bne	a5,s2,80002b4c <bread+0x36>
    80002b58:	44dc                	lw	a5,12(s1)
    80002b5a:	ff3799e3          	bne	a5,s3,80002b4c <bread+0x36>
      b->refcnt++;
    80002b5e:	40bc                	lw	a5,64(s1)
    80002b60:	2785                	addiw	a5,a5,1
    80002b62:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b64:	00015517          	auipc	a0,0x15
    80002b68:	59c50513          	addi	a0,a0,1436 # 80018100 <bcache>
    80002b6c:	8fafe0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002b70:	01048513          	addi	a0,s1,16
    80002b74:	2d4010ef          	jal	80003e48 <acquiresleep>
      return b;
    80002b78:	a889                	j	80002bca <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002b7a:	0001e497          	auipc	s1,0x1e
    80002b7e:	8364b483          	ld	s1,-1994(s1) # 800203b0 <bcache+0x82b0>
    80002b82:	0001d797          	auipc	a5,0x1d
    80002b86:	7e678793          	addi	a5,a5,2022 # 80020368 <bcache+0x8268>
    80002b8a:	00f48863          	beq	s1,a5,80002b9a <bread+0x84>
    80002b8e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002b90:	40bc                	lw	a5,64(s1)
    80002b92:	cb91                	beqz	a5,80002ba6 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002b94:	64a4                	ld	s1,72(s1)
    80002b96:	fee49de3          	bne	s1,a4,80002b90 <bread+0x7a>
  panic("bget: no buffers");
    80002b9a:	00005517          	auipc	a0,0x5
    80002b9e:	80650513          	addi	a0,a0,-2042 # 800073a0 <etext+0x3a0>
    80002ba2:	c3ffd0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80002ba6:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002baa:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002bae:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002bb2:	4785                	li	a5,1
    80002bb4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002bb6:	00015517          	auipc	a0,0x15
    80002bba:	54a50513          	addi	a0,a0,1354 # 80018100 <bcache>
    80002bbe:	8a8fe0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002bc2:	01048513          	addi	a0,s1,16
    80002bc6:	282010ef          	jal	80003e48 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002bca:	409c                	lw	a5,0(s1)
    80002bcc:	cb89                	beqz	a5,80002bde <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002bce:	8526                	mv	a0,s1
    80002bd0:	70a2                	ld	ra,40(sp)
    80002bd2:	7402                	ld	s0,32(sp)
    80002bd4:	64e2                	ld	s1,24(sp)
    80002bd6:	6942                	ld	s2,16(sp)
    80002bd8:	69a2                	ld	s3,8(sp)
    80002bda:	6145                	addi	sp,sp,48
    80002bdc:	8082                	ret
    virtio_disk_rw(b, 0);
    80002bde:	4581                	li	a1,0
    80002be0:	8526                	mv	a0,s1
    80002be2:	2cf020ef          	jal	800056b0 <virtio_disk_rw>
    b->valid = 1;
    80002be6:	4785                	li	a5,1
    80002be8:	c09c                	sw	a5,0(s1)
  return b;
    80002bea:	b7d5                	j	80002bce <bread+0xb8>

0000000080002bec <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002bec:	1101                	addi	sp,sp,-32
    80002bee:	ec06                	sd	ra,24(sp)
    80002bf0:	e822                	sd	s0,16(sp)
    80002bf2:	e426                	sd	s1,8(sp)
    80002bf4:	1000                	addi	s0,sp,32
    80002bf6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002bf8:	0541                	addi	a0,a0,16
    80002bfa:	2cc010ef          	jal	80003ec6 <holdingsleep>
    80002bfe:	c911                	beqz	a0,80002c12 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002c00:	4585                	li	a1,1
    80002c02:	8526                	mv	a0,s1
    80002c04:	2ad020ef          	jal	800056b0 <virtio_disk_rw>
}
    80002c08:	60e2                	ld	ra,24(sp)
    80002c0a:	6442                	ld	s0,16(sp)
    80002c0c:	64a2                	ld	s1,8(sp)
    80002c0e:	6105                	addi	sp,sp,32
    80002c10:	8082                	ret
    panic("bwrite");
    80002c12:	00004517          	auipc	a0,0x4
    80002c16:	7a650513          	addi	a0,a0,1958 # 800073b8 <etext+0x3b8>
    80002c1a:	bc7fd0ef          	jal	800007e0 <panic>

0000000080002c1e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002c1e:	1101                	addi	sp,sp,-32
    80002c20:	ec06                	sd	ra,24(sp)
    80002c22:	e822                	sd	s0,16(sp)
    80002c24:	e426                	sd	s1,8(sp)
    80002c26:	e04a                	sd	s2,0(sp)
    80002c28:	1000                	addi	s0,sp,32
    80002c2a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c2c:	01050913          	addi	s2,a0,16
    80002c30:	854a                	mv	a0,s2
    80002c32:	294010ef          	jal	80003ec6 <holdingsleep>
    80002c36:	c135                	beqz	a0,80002c9a <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002c38:	854a                	mv	a0,s2
    80002c3a:	254010ef          	jal	80003e8e <releasesleep>

  acquire(&bcache.lock);
    80002c3e:	00015517          	auipc	a0,0x15
    80002c42:	4c250513          	addi	a0,a0,1218 # 80018100 <bcache>
    80002c46:	f89fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002c4a:	40bc                	lw	a5,64(s1)
    80002c4c:	37fd                	addiw	a5,a5,-1
    80002c4e:	0007871b          	sext.w	a4,a5
    80002c52:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002c54:	e71d                	bnez	a4,80002c82 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002c56:	68b8                	ld	a4,80(s1)
    80002c58:	64bc                	ld	a5,72(s1)
    80002c5a:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002c5c:	68b8                	ld	a4,80(s1)
    80002c5e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002c60:	0001d797          	auipc	a5,0x1d
    80002c64:	4a078793          	addi	a5,a5,1184 # 80020100 <bcache+0x8000>
    80002c68:	2b87b703          	ld	a4,696(a5)
    80002c6c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002c6e:	0001d717          	auipc	a4,0x1d
    80002c72:	6fa70713          	addi	a4,a4,1786 # 80020368 <bcache+0x8268>
    80002c76:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002c78:	2b87b703          	ld	a4,696(a5)
    80002c7c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002c7e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002c82:	00015517          	auipc	a0,0x15
    80002c86:	47e50513          	addi	a0,a0,1150 # 80018100 <bcache>
    80002c8a:	fddfd0ef          	jal	80000c66 <release>
}
    80002c8e:	60e2                	ld	ra,24(sp)
    80002c90:	6442                	ld	s0,16(sp)
    80002c92:	64a2                	ld	s1,8(sp)
    80002c94:	6902                	ld	s2,0(sp)
    80002c96:	6105                	addi	sp,sp,32
    80002c98:	8082                	ret
    panic("brelse");
    80002c9a:	00004517          	auipc	a0,0x4
    80002c9e:	72650513          	addi	a0,a0,1830 # 800073c0 <etext+0x3c0>
    80002ca2:	b3ffd0ef          	jal	800007e0 <panic>

0000000080002ca6 <bpin>:

void
bpin(struct buf *b) {
    80002ca6:	1101                	addi	sp,sp,-32
    80002ca8:	ec06                	sd	ra,24(sp)
    80002caa:	e822                	sd	s0,16(sp)
    80002cac:	e426                	sd	s1,8(sp)
    80002cae:	1000                	addi	s0,sp,32
    80002cb0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002cb2:	00015517          	auipc	a0,0x15
    80002cb6:	44e50513          	addi	a0,a0,1102 # 80018100 <bcache>
    80002cba:	f15fd0ef          	jal	80000bce <acquire>
  b->refcnt++;
    80002cbe:	40bc                	lw	a5,64(s1)
    80002cc0:	2785                	addiw	a5,a5,1
    80002cc2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002cc4:	00015517          	auipc	a0,0x15
    80002cc8:	43c50513          	addi	a0,a0,1084 # 80018100 <bcache>
    80002ccc:	f9bfd0ef          	jal	80000c66 <release>
}
    80002cd0:	60e2                	ld	ra,24(sp)
    80002cd2:	6442                	ld	s0,16(sp)
    80002cd4:	64a2                	ld	s1,8(sp)
    80002cd6:	6105                	addi	sp,sp,32
    80002cd8:	8082                	ret

0000000080002cda <bunpin>:

void
bunpin(struct buf *b) {
    80002cda:	1101                	addi	sp,sp,-32
    80002cdc:	ec06                	sd	ra,24(sp)
    80002cde:	e822                	sd	s0,16(sp)
    80002ce0:	e426                	sd	s1,8(sp)
    80002ce2:	1000                	addi	s0,sp,32
    80002ce4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ce6:	00015517          	auipc	a0,0x15
    80002cea:	41a50513          	addi	a0,a0,1050 # 80018100 <bcache>
    80002cee:	ee1fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002cf2:	40bc                	lw	a5,64(s1)
    80002cf4:	37fd                	addiw	a5,a5,-1
    80002cf6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002cf8:	00015517          	auipc	a0,0x15
    80002cfc:	40850513          	addi	a0,a0,1032 # 80018100 <bcache>
    80002d00:	f67fd0ef          	jal	80000c66 <release>
}
    80002d04:	60e2                	ld	ra,24(sp)
    80002d06:	6442                	ld	s0,16(sp)
    80002d08:	64a2                	ld	s1,8(sp)
    80002d0a:	6105                	addi	sp,sp,32
    80002d0c:	8082                	ret

0000000080002d0e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002d0e:	1101                	addi	sp,sp,-32
    80002d10:	ec06                	sd	ra,24(sp)
    80002d12:	e822                	sd	s0,16(sp)
    80002d14:	e426                	sd	s1,8(sp)
    80002d16:	e04a                	sd	s2,0(sp)
    80002d18:	1000                	addi	s0,sp,32
    80002d1a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002d1c:	00d5d59b          	srliw	a1,a1,0xd
    80002d20:	0001e797          	auipc	a5,0x1e
    80002d24:	abc7a783          	lw	a5,-1348(a5) # 800207dc <sb+0x1c>
    80002d28:	9dbd                	addw	a1,a1,a5
    80002d2a:	dedff0ef          	jal	80002b16 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002d2e:	0074f713          	andi	a4,s1,7
    80002d32:	4785                	li	a5,1
    80002d34:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002d38:	14ce                	slli	s1,s1,0x33
    80002d3a:	90d9                	srli	s1,s1,0x36
    80002d3c:	00950733          	add	a4,a0,s1
    80002d40:	05874703          	lbu	a4,88(a4)
    80002d44:	00e7f6b3          	and	a3,a5,a4
    80002d48:	c29d                	beqz	a3,80002d6e <bfree+0x60>
    80002d4a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002d4c:	94aa                	add	s1,s1,a0
    80002d4e:	fff7c793          	not	a5,a5
    80002d52:	8f7d                	and	a4,a4,a5
    80002d54:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002d58:	7f9000ef          	jal	80003d50 <log_write>
  brelse(bp);
    80002d5c:	854a                	mv	a0,s2
    80002d5e:	ec1ff0ef          	jal	80002c1e <brelse>
}
    80002d62:	60e2                	ld	ra,24(sp)
    80002d64:	6442                	ld	s0,16(sp)
    80002d66:	64a2                	ld	s1,8(sp)
    80002d68:	6902                	ld	s2,0(sp)
    80002d6a:	6105                	addi	sp,sp,32
    80002d6c:	8082                	ret
    panic("freeing free block");
    80002d6e:	00004517          	auipc	a0,0x4
    80002d72:	65a50513          	addi	a0,a0,1626 # 800073c8 <etext+0x3c8>
    80002d76:	a6bfd0ef          	jal	800007e0 <panic>

0000000080002d7a <balloc>:
{
    80002d7a:	711d                	addi	sp,sp,-96
    80002d7c:	ec86                	sd	ra,88(sp)
    80002d7e:	e8a2                	sd	s0,80(sp)
    80002d80:	e4a6                	sd	s1,72(sp)
    80002d82:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002d84:	0001e797          	auipc	a5,0x1e
    80002d88:	a407a783          	lw	a5,-1472(a5) # 800207c4 <sb+0x4>
    80002d8c:	0e078f63          	beqz	a5,80002e8a <balloc+0x110>
    80002d90:	e0ca                	sd	s2,64(sp)
    80002d92:	fc4e                	sd	s3,56(sp)
    80002d94:	f852                	sd	s4,48(sp)
    80002d96:	f456                	sd	s5,40(sp)
    80002d98:	f05a                	sd	s6,32(sp)
    80002d9a:	ec5e                	sd	s7,24(sp)
    80002d9c:	e862                	sd	s8,16(sp)
    80002d9e:	e466                	sd	s9,8(sp)
    80002da0:	8baa                	mv	s7,a0
    80002da2:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002da4:	0001eb17          	auipc	s6,0x1e
    80002da8:	a1cb0b13          	addi	s6,s6,-1508 # 800207c0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002dac:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002dae:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002db0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002db2:	6c89                	lui	s9,0x2
    80002db4:	a0b5                	j	80002e20 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002db6:	97ca                	add	a5,a5,s2
    80002db8:	8e55                	or	a2,a2,a3
    80002dba:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002dbe:	854a                	mv	a0,s2
    80002dc0:	791000ef          	jal	80003d50 <log_write>
        brelse(bp);
    80002dc4:	854a                	mv	a0,s2
    80002dc6:	e59ff0ef          	jal	80002c1e <brelse>
  bp = bread(dev, bno);
    80002dca:	85a6                	mv	a1,s1
    80002dcc:	855e                	mv	a0,s7
    80002dce:	d49ff0ef          	jal	80002b16 <bread>
    80002dd2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002dd4:	40000613          	li	a2,1024
    80002dd8:	4581                	li	a1,0
    80002dda:	05850513          	addi	a0,a0,88
    80002dde:	ec5fd0ef          	jal	80000ca2 <memset>
  log_write(bp);
    80002de2:	854a                	mv	a0,s2
    80002de4:	76d000ef          	jal	80003d50 <log_write>
  brelse(bp);
    80002de8:	854a                	mv	a0,s2
    80002dea:	e35ff0ef          	jal	80002c1e <brelse>
}
    80002dee:	6906                	ld	s2,64(sp)
    80002df0:	79e2                	ld	s3,56(sp)
    80002df2:	7a42                	ld	s4,48(sp)
    80002df4:	7aa2                	ld	s5,40(sp)
    80002df6:	7b02                	ld	s6,32(sp)
    80002df8:	6be2                	ld	s7,24(sp)
    80002dfa:	6c42                	ld	s8,16(sp)
    80002dfc:	6ca2                	ld	s9,8(sp)
}
    80002dfe:	8526                	mv	a0,s1
    80002e00:	60e6                	ld	ra,88(sp)
    80002e02:	6446                	ld	s0,80(sp)
    80002e04:	64a6                	ld	s1,72(sp)
    80002e06:	6125                	addi	sp,sp,96
    80002e08:	8082                	ret
    brelse(bp);
    80002e0a:	854a                	mv	a0,s2
    80002e0c:	e13ff0ef          	jal	80002c1e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002e10:	015c87bb          	addw	a5,s9,s5
    80002e14:	00078a9b          	sext.w	s5,a5
    80002e18:	004b2703          	lw	a4,4(s6)
    80002e1c:	04eaff63          	bgeu	s5,a4,80002e7a <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002e20:	41fad79b          	sraiw	a5,s5,0x1f
    80002e24:	0137d79b          	srliw	a5,a5,0x13
    80002e28:	015787bb          	addw	a5,a5,s5
    80002e2c:	40d7d79b          	sraiw	a5,a5,0xd
    80002e30:	01cb2583          	lw	a1,28(s6)
    80002e34:	9dbd                	addw	a1,a1,a5
    80002e36:	855e                	mv	a0,s7
    80002e38:	cdfff0ef          	jal	80002b16 <bread>
    80002e3c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e3e:	004b2503          	lw	a0,4(s6)
    80002e42:	000a849b          	sext.w	s1,s5
    80002e46:	8762                	mv	a4,s8
    80002e48:	fca4f1e3          	bgeu	s1,a0,80002e0a <balloc+0x90>
      m = 1 << (bi % 8);
    80002e4c:	00777693          	andi	a3,a4,7
    80002e50:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002e54:	41f7579b          	sraiw	a5,a4,0x1f
    80002e58:	01d7d79b          	srliw	a5,a5,0x1d
    80002e5c:	9fb9                	addw	a5,a5,a4
    80002e5e:	4037d79b          	sraiw	a5,a5,0x3
    80002e62:	00f90633          	add	a2,s2,a5
    80002e66:	05864603          	lbu	a2,88(a2)
    80002e6a:	00c6f5b3          	and	a1,a3,a2
    80002e6e:	d5a1                	beqz	a1,80002db6 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e70:	2705                	addiw	a4,a4,1
    80002e72:	2485                	addiw	s1,s1,1
    80002e74:	fd471ae3          	bne	a4,s4,80002e48 <balloc+0xce>
    80002e78:	bf49                	j	80002e0a <balloc+0x90>
    80002e7a:	6906                	ld	s2,64(sp)
    80002e7c:	79e2                	ld	s3,56(sp)
    80002e7e:	7a42                	ld	s4,48(sp)
    80002e80:	7aa2                	ld	s5,40(sp)
    80002e82:	7b02                	ld	s6,32(sp)
    80002e84:	6be2                	ld	s7,24(sp)
    80002e86:	6c42                	ld	s8,16(sp)
    80002e88:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002e8a:	00004517          	auipc	a0,0x4
    80002e8e:	55650513          	addi	a0,a0,1366 # 800073e0 <etext+0x3e0>
    80002e92:	e68fd0ef          	jal	800004fa <printf>
  return 0;
    80002e96:	4481                	li	s1,0
    80002e98:	b79d                	j	80002dfe <balloc+0x84>

0000000080002e9a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002e9a:	7179                	addi	sp,sp,-48
    80002e9c:	f406                	sd	ra,40(sp)
    80002e9e:	f022                	sd	s0,32(sp)
    80002ea0:	ec26                	sd	s1,24(sp)
    80002ea2:	e84a                	sd	s2,16(sp)
    80002ea4:	e44e                	sd	s3,8(sp)
    80002ea6:	1800                	addi	s0,sp,48
    80002ea8:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002eaa:	47ad                	li	a5,11
    80002eac:	02b7e663          	bltu	a5,a1,80002ed8 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002eb0:	02059793          	slli	a5,a1,0x20
    80002eb4:	01e7d593          	srli	a1,a5,0x1e
    80002eb8:	00b504b3          	add	s1,a0,a1
    80002ebc:	0504a903          	lw	s2,80(s1)
    80002ec0:	06091a63          	bnez	s2,80002f34 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002ec4:	4108                	lw	a0,0(a0)
    80002ec6:	eb5ff0ef          	jal	80002d7a <balloc>
    80002eca:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002ece:	06090363          	beqz	s2,80002f34 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002ed2:	0524a823          	sw	s2,80(s1)
    80002ed6:	a8b9                	j	80002f34 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002ed8:	ff45849b          	addiw	s1,a1,-12
    80002edc:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002ee0:	0ff00793          	li	a5,255
    80002ee4:	06e7ee63          	bltu	a5,a4,80002f60 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002ee8:	08052903          	lw	s2,128(a0)
    80002eec:	00091d63          	bnez	s2,80002f06 <bmap+0x6c>
      addr = balloc(ip->dev);
    80002ef0:	4108                	lw	a0,0(a0)
    80002ef2:	e89ff0ef          	jal	80002d7a <balloc>
    80002ef6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002efa:	02090d63          	beqz	s2,80002f34 <bmap+0x9a>
    80002efe:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002f00:	0929a023          	sw	s2,128(s3)
    80002f04:	a011                	j	80002f08 <bmap+0x6e>
    80002f06:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002f08:	85ca                	mv	a1,s2
    80002f0a:	0009a503          	lw	a0,0(s3)
    80002f0e:	c09ff0ef          	jal	80002b16 <bread>
    80002f12:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002f14:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002f18:	02049713          	slli	a4,s1,0x20
    80002f1c:	01e75593          	srli	a1,a4,0x1e
    80002f20:	00b784b3          	add	s1,a5,a1
    80002f24:	0004a903          	lw	s2,0(s1)
    80002f28:	00090e63          	beqz	s2,80002f44 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002f2c:	8552                	mv	a0,s4
    80002f2e:	cf1ff0ef          	jal	80002c1e <brelse>
    return addr;
    80002f32:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002f34:	854a                	mv	a0,s2
    80002f36:	70a2                	ld	ra,40(sp)
    80002f38:	7402                	ld	s0,32(sp)
    80002f3a:	64e2                	ld	s1,24(sp)
    80002f3c:	6942                	ld	s2,16(sp)
    80002f3e:	69a2                	ld	s3,8(sp)
    80002f40:	6145                	addi	sp,sp,48
    80002f42:	8082                	ret
      addr = balloc(ip->dev);
    80002f44:	0009a503          	lw	a0,0(s3)
    80002f48:	e33ff0ef          	jal	80002d7a <balloc>
    80002f4c:	0005091b          	sext.w	s2,a0
      if(addr){
    80002f50:	fc090ee3          	beqz	s2,80002f2c <bmap+0x92>
        a[bn] = addr;
    80002f54:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002f58:	8552                	mv	a0,s4
    80002f5a:	5f7000ef          	jal	80003d50 <log_write>
    80002f5e:	b7f9                	j	80002f2c <bmap+0x92>
    80002f60:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002f62:	00004517          	auipc	a0,0x4
    80002f66:	49650513          	addi	a0,a0,1174 # 800073f8 <etext+0x3f8>
    80002f6a:	877fd0ef          	jal	800007e0 <panic>

0000000080002f6e <iget>:
{
    80002f6e:	7179                	addi	sp,sp,-48
    80002f70:	f406                	sd	ra,40(sp)
    80002f72:	f022                	sd	s0,32(sp)
    80002f74:	ec26                	sd	s1,24(sp)
    80002f76:	e84a                	sd	s2,16(sp)
    80002f78:	e44e                	sd	s3,8(sp)
    80002f7a:	e052                	sd	s4,0(sp)
    80002f7c:	1800                	addi	s0,sp,48
    80002f7e:	89aa                	mv	s3,a0
    80002f80:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002f82:	0001e517          	auipc	a0,0x1e
    80002f86:	85e50513          	addi	a0,a0,-1954 # 800207e0 <itable>
    80002f8a:	c45fd0ef          	jal	80000bce <acquire>
  empty = 0;
    80002f8e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002f90:	0001e497          	auipc	s1,0x1e
    80002f94:	86848493          	addi	s1,s1,-1944 # 800207f8 <itable+0x18>
    80002f98:	0001f697          	auipc	a3,0x1f
    80002f9c:	2f068693          	addi	a3,a3,752 # 80022288 <log>
    80002fa0:	a039                	j	80002fae <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002fa2:	02090963          	beqz	s2,80002fd4 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002fa6:	08848493          	addi	s1,s1,136
    80002faa:	02d48863          	beq	s1,a3,80002fda <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002fae:	449c                	lw	a5,8(s1)
    80002fb0:	fef059e3          	blez	a5,80002fa2 <iget+0x34>
    80002fb4:	4098                	lw	a4,0(s1)
    80002fb6:	ff3716e3          	bne	a4,s3,80002fa2 <iget+0x34>
    80002fba:	40d8                	lw	a4,4(s1)
    80002fbc:	ff4713e3          	bne	a4,s4,80002fa2 <iget+0x34>
      ip->ref++;
    80002fc0:	2785                	addiw	a5,a5,1
    80002fc2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002fc4:	0001e517          	auipc	a0,0x1e
    80002fc8:	81c50513          	addi	a0,a0,-2020 # 800207e0 <itable>
    80002fcc:	c9bfd0ef          	jal	80000c66 <release>
      return ip;
    80002fd0:	8926                	mv	s2,s1
    80002fd2:	a02d                	j	80002ffc <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002fd4:	fbe9                	bnez	a5,80002fa6 <iget+0x38>
      empty = ip;
    80002fd6:	8926                	mv	s2,s1
    80002fd8:	b7f9                	j	80002fa6 <iget+0x38>
  if(empty == 0)
    80002fda:	02090a63          	beqz	s2,8000300e <iget+0xa0>
  ip->dev = dev;
    80002fde:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002fe2:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002fe6:	4785                	li	a5,1
    80002fe8:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002fec:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002ff0:	0001d517          	auipc	a0,0x1d
    80002ff4:	7f050513          	addi	a0,a0,2032 # 800207e0 <itable>
    80002ff8:	c6ffd0ef          	jal	80000c66 <release>
}
    80002ffc:	854a                	mv	a0,s2
    80002ffe:	70a2                	ld	ra,40(sp)
    80003000:	7402                	ld	s0,32(sp)
    80003002:	64e2                	ld	s1,24(sp)
    80003004:	6942                	ld	s2,16(sp)
    80003006:	69a2                	ld	s3,8(sp)
    80003008:	6a02                	ld	s4,0(sp)
    8000300a:	6145                	addi	sp,sp,48
    8000300c:	8082                	ret
    panic("iget: no inodes");
    8000300e:	00004517          	auipc	a0,0x4
    80003012:	40250513          	addi	a0,a0,1026 # 80007410 <etext+0x410>
    80003016:	fcafd0ef          	jal	800007e0 <panic>

000000008000301a <iinit>:
{
    8000301a:	7179                	addi	sp,sp,-48
    8000301c:	f406                	sd	ra,40(sp)
    8000301e:	f022                	sd	s0,32(sp)
    80003020:	ec26                	sd	s1,24(sp)
    80003022:	e84a                	sd	s2,16(sp)
    80003024:	e44e                	sd	s3,8(sp)
    80003026:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003028:	00004597          	auipc	a1,0x4
    8000302c:	3f858593          	addi	a1,a1,1016 # 80007420 <etext+0x420>
    80003030:	0001d517          	auipc	a0,0x1d
    80003034:	7b050513          	addi	a0,a0,1968 # 800207e0 <itable>
    80003038:	b17fd0ef          	jal	80000b4e <initlock>
  for(i = 0; i < NINODE; i++) {
    8000303c:	0001d497          	auipc	s1,0x1d
    80003040:	7cc48493          	addi	s1,s1,1996 # 80020808 <itable+0x28>
    80003044:	0001f997          	auipc	s3,0x1f
    80003048:	25498993          	addi	s3,s3,596 # 80022298 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000304c:	00004917          	auipc	s2,0x4
    80003050:	3dc90913          	addi	s2,s2,988 # 80007428 <etext+0x428>
    80003054:	85ca                	mv	a1,s2
    80003056:	8526                	mv	a0,s1
    80003058:	5bb000ef          	jal	80003e12 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000305c:	08848493          	addi	s1,s1,136
    80003060:	ff349ae3          	bne	s1,s3,80003054 <iinit+0x3a>
}
    80003064:	70a2                	ld	ra,40(sp)
    80003066:	7402                	ld	s0,32(sp)
    80003068:	64e2                	ld	s1,24(sp)
    8000306a:	6942                	ld	s2,16(sp)
    8000306c:	69a2                	ld	s3,8(sp)
    8000306e:	6145                	addi	sp,sp,48
    80003070:	8082                	ret

0000000080003072 <ialloc>:
{
    80003072:	7139                	addi	sp,sp,-64
    80003074:	fc06                	sd	ra,56(sp)
    80003076:	f822                	sd	s0,48(sp)
    80003078:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000307a:	0001d717          	auipc	a4,0x1d
    8000307e:	75272703          	lw	a4,1874(a4) # 800207cc <sb+0xc>
    80003082:	4785                	li	a5,1
    80003084:	06e7f063          	bgeu	a5,a4,800030e4 <ialloc+0x72>
    80003088:	f426                	sd	s1,40(sp)
    8000308a:	f04a                	sd	s2,32(sp)
    8000308c:	ec4e                	sd	s3,24(sp)
    8000308e:	e852                	sd	s4,16(sp)
    80003090:	e456                	sd	s5,8(sp)
    80003092:	e05a                	sd	s6,0(sp)
    80003094:	8aaa                	mv	s5,a0
    80003096:	8b2e                	mv	s6,a1
    80003098:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000309a:	0001da17          	auipc	s4,0x1d
    8000309e:	726a0a13          	addi	s4,s4,1830 # 800207c0 <sb>
    800030a2:	00495593          	srli	a1,s2,0x4
    800030a6:	018a2783          	lw	a5,24(s4)
    800030aa:	9dbd                	addw	a1,a1,a5
    800030ac:	8556                	mv	a0,s5
    800030ae:	a69ff0ef          	jal	80002b16 <bread>
    800030b2:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800030b4:	05850993          	addi	s3,a0,88
    800030b8:	00f97793          	andi	a5,s2,15
    800030bc:	079a                	slli	a5,a5,0x6
    800030be:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800030c0:	00099783          	lh	a5,0(s3)
    800030c4:	cb9d                	beqz	a5,800030fa <ialloc+0x88>
    brelse(bp);
    800030c6:	b59ff0ef          	jal	80002c1e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800030ca:	0905                	addi	s2,s2,1
    800030cc:	00ca2703          	lw	a4,12(s4)
    800030d0:	0009079b          	sext.w	a5,s2
    800030d4:	fce7e7e3          	bltu	a5,a4,800030a2 <ialloc+0x30>
    800030d8:	74a2                	ld	s1,40(sp)
    800030da:	7902                	ld	s2,32(sp)
    800030dc:	69e2                	ld	s3,24(sp)
    800030de:	6a42                	ld	s4,16(sp)
    800030e0:	6aa2                	ld	s5,8(sp)
    800030e2:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800030e4:	00004517          	auipc	a0,0x4
    800030e8:	34c50513          	addi	a0,a0,844 # 80007430 <etext+0x430>
    800030ec:	c0efd0ef          	jal	800004fa <printf>
  return 0;
    800030f0:	4501                	li	a0,0
}
    800030f2:	70e2                	ld	ra,56(sp)
    800030f4:	7442                	ld	s0,48(sp)
    800030f6:	6121                	addi	sp,sp,64
    800030f8:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800030fa:	04000613          	li	a2,64
    800030fe:	4581                	li	a1,0
    80003100:	854e                	mv	a0,s3
    80003102:	ba1fd0ef          	jal	80000ca2 <memset>
      dip->type = type;
    80003106:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000310a:	8526                	mv	a0,s1
    8000310c:	445000ef          	jal	80003d50 <log_write>
      brelse(bp);
    80003110:	8526                	mv	a0,s1
    80003112:	b0dff0ef          	jal	80002c1e <brelse>
      return iget(dev, inum);
    80003116:	0009059b          	sext.w	a1,s2
    8000311a:	8556                	mv	a0,s5
    8000311c:	e53ff0ef          	jal	80002f6e <iget>
    80003120:	74a2                	ld	s1,40(sp)
    80003122:	7902                	ld	s2,32(sp)
    80003124:	69e2                	ld	s3,24(sp)
    80003126:	6a42                	ld	s4,16(sp)
    80003128:	6aa2                	ld	s5,8(sp)
    8000312a:	6b02                	ld	s6,0(sp)
    8000312c:	b7d9                	j	800030f2 <ialloc+0x80>

000000008000312e <iupdate>:
{
    8000312e:	1101                	addi	sp,sp,-32
    80003130:	ec06                	sd	ra,24(sp)
    80003132:	e822                	sd	s0,16(sp)
    80003134:	e426                	sd	s1,8(sp)
    80003136:	e04a                	sd	s2,0(sp)
    80003138:	1000                	addi	s0,sp,32
    8000313a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000313c:	415c                	lw	a5,4(a0)
    8000313e:	0047d79b          	srliw	a5,a5,0x4
    80003142:	0001d597          	auipc	a1,0x1d
    80003146:	6965a583          	lw	a1,1686(a1) # 800207d8 <sb+0x18>
    8000314a:	9dbd                	addw	a1,a1,a5
    8000314c:	4108                	lw	a0,0(a0)
    8000314e:	9c9ff0ef          	jal	80002b16 <bread>
    80003152:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003154:	05850793          	addi	a5,a0,88
    80003158:	40d8                	lw	a4,4(s1)
    8000315a:	8b3d                	andi	a4,a4,15
    8000315c:	071a                	slli	a4,a4,0x6
    8000315e:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003160:	04449703          	lh	a4,68(s1)
    80003164:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003168:	04649703          	lh	a4,70(s1)
    8000316c:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003170:	04849703          	lh	a4,72(s1)
    80003174:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003178:	04a49703          	lh	a4,74(s1)
    8000317c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003180:	44f8                	lw	a4,76(s1)
    80003182:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003184:	03400613          	li	a2,52
    80003188:	05048593          	addi	a1,s1,80
    8000318c:	00c78513          	addi	a0,a5,12
    80003190:	b6ffd0ef          	jal	80000cfe <memmove>
  log_write(bp);
    80003194:	854a                	mv	a0,s2
    80003196:	3bb000ef          	jal	80003d50 <log_write>
  brelse(bp);
    8000319a:	854a                	mv	a0,s2
    8000319c:	a83ff0ef          	jal	80002c1e <brelse>
}
    800031a0:	60e2                	ld	ra,24(sp)
    800031a2:	6442                	ld	s0,16(sp)
    800031a4:	64a2                	ld	s1,8(sp)
    800031a6:	6902                	ld	s2,0(sp)
    800031a8:	6105                	addi	sp,sp,32
    800031aa:	8082                	ret

00000000800031ac <idup>:
{
    800031ac:	1101                	addi	sp,sp,-32
    800031ae:	ec06                	sd	ra,24(sp)
    800031b0:	e822                	sd	s0,16(sp)
    800031b2:	e426                	sd	s1,8(sp)
    800031b4:	1000                	addi	s0,sp,32
    800031b6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800031b8:	0001d517          	auipc	a0,0x1d
    800031bc:	62850513          	addi	a0,a0,1576 # 800207e0 <itable>
    800031c0:	a0ffd0ef          	jal	80000bce <acquire>
  ip->ref++;
    800031c4:	449c                	lw	a5,8(s1)
    800031c6:	2785                	addiw	a5,a5,1
    800031c8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800031ca:	0001d517          	auipc	a0,0x1d
    800031ce:	61650513          	addi	a0,a0,1558 # 800207e0 <itable>
    800031d2:	a95fd0ef          	jal	80000c66 <release>
}
    800031d6:	8526                	mv	a0,s1
    800031d8:	60e2                	ld	ra,24(sp)
    800031da:	6442                	ld	s0,16(sp)
    800031dc:	64a2                	ld	s1,8(sp)
    800031de:	6105                	addi	sp,sp,32
    800031e0:	8082                	ret

00000000800031e2 <ilock>:
{
    800031e2:	1101                	addi	sp,sp,-32
    800031e4:	ec06                	sd	ra,24(sp)
    800031e6:	e822                	sd	s0,16(sp)
    800031e8:	e426                	sd	s1,8(sp)
    800031ea:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800031ec:	cd19                	beqz	a0,8000320a <ilock+0x28>
    800031ee:	84aa                	mv	s1,a0
    800031f0:	451c                	lw	a5,8(a0)
    800031f2:	00f05c63          	blez	a5,8000320a <ilock+0x28>
  acquiresleep(&ip->lock);
    800031f6:	0541                	addi	a0,a0,16
    800031f8:	451000ef          	jal	80003e48 <acquiresleep>
  if(ip->valid == 0){
    800031fc:	40bc                	lw	a5,64(s1)
    800031fe:	cf89                	beqz	a5,80003218 <ilock+0x36>
}
    80003200:	60e2                	ld	ra,24(sp)
    80003202:	6442                	ld	s0,16(sp)
    80003204:	64a2                	ld	s1,8(sp)
    80003206:	6105                	addi	sp,sp,32
    80003208:	8082                	ret
    8000320a:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000320c:	00004517          	auipc	a0,0x4
    80003210:	23c50513          	addi	a0,a0,572 # 80007448 <etext+0x448>
    80003214:	dccfd0ef          	jal	800007e0 <panic>
    80003218:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000321a:	40dc                	lw	a5,4(s1)
    8000321c:	0047d79b          	srliw	a5,a5,0x4
    80003220:	0001d597          	auipc	a1,0x1d
    80003224:	5b85a583          	lw	a1,1464(a1) # 800207d8 <sb+0x18>
    80003228:	9dbd                	addw	a1,a1,a5
    8000322a:	4088                	lw	a0,0(s1)
    8000322c:	8ebff0ef          	jal	80002b16 <bread>
    80003230:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003232:	05850593          	addi	a1,a0,88
    80003236:	40dc                	lw	a5,4(s1)
    80003238:	8bbd                	andi	a5,a5,15
    8000323a:	079a                	slli	a5,a5,0x6
    8000323c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000323e:	00059783          	lh	a5,0(a1)
    80003242:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003246:	00259783          	lh	a5,2(a1)
    8000324a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000324e:	00459783          	lh	a5,4(a1)
    80003252:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003256:	00659783          	lh	a5,6(a1)
    8000325a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000325e:	459c                	lw	a5,8(a1)
    80003260:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003262:	03400613          	li	a2,52
    80003266:	05b1                	addi	a1,a1,12
    80003268:	05048513          	addi	a0,s1,80
    8000326c:	a93fd0ef          	jal	80000cfe <memmove>
    brelse(bp);
    80003270:	854a                	mv	a0,s2
    80003272:	9adff0ef          	jal	80002c1e <brelse>
    ip->valid = 1;
    80003276:	4785                	li	a5,1
    80003278:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000327a:	04449783          	lh	a5,68(s1)
    8000327e:	c399                	beqz	a5,80003284 <ilock+0xa2>
    80003280:	6902                	ld	s2,0(sp)
    80003282:	bfbd                	j	80003200 <ilock+0x1e>
      panic("ilock: no type");
    80003284:	00004517          	auipc	a0,0x4
    80003288:	1cc50513          	addi	a0,a0,460 # 80007450 <etext+0x450>
    8000328c:	d54fd0ef          	jal	800007e0 <panic>

0000000080003290 <iunlock>:
{
    80003290:	1101                	addi	sp,sp,-32
    80003292:	ec06                	sd	ra,24(sp)
    80003294:	e822                	sd	s0,16(sp)
    80003296:	e426                	sd	s1,8(sp)
    80003298:	e04a                	sd	s2,0(sp)
    8000329a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000329c:	c505                	beqz	a0,800032c4 <iunlock+0x34>
    8000329e:	84aa                	mv	s1,a0
    800032a0:	01050913          	addi	s2,a0,16
    800032a4:	854a                	mv	a0,s2
    800032a6:	421000ef          	jal	80003ec6 <holdingsleep>
    800032aa:	cd09                	beqz	a0,800032c4 <iunlock+0x34>
    800032ac:	449c                	lw	a5,8(s1)
    800032ae:	00f05b63          	blez	a5,800032c4 <iunlock+0x34>
  releasesleep(&ip->lock);
    800032b2:	854a                	mv	a0,s2
    800032b4:	3db000ef          	jal	80003e8e <releasesleep>
}
    800032b8:	60e2                	ld	ra,24(sp)
    800032ba:	6442                	ld	s0,16(sp)
    800032bc:	64a2                	ld	s1,8(sp)
    800032be:	6902                	ld	s2,0(sp)
    800032c0:	6105                	addi	sp,sp,32
    800032c2:	8082                	ret
    panic("iunlock");
    800032c4:	00004517          	auipc	a0,0x4
    800032c8:	19c50513          	addi	a0,a0,412 # 80007460 <etext+0x460>
    800032cc:	d14fd0ef          	jal	800007e0 <panic>

00000000800032d0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800032d0:	7179                	addi	sp,sp,-48
    800032d2:	f406                	sd	ra,40(sp)
    800032d4:	f022                	sd	s0,32(sp)
    800032d6:	ec26                	sd	s1,24(sp)
    800032d8:	e84a                	sd	s2,16(sp)
    800032da:	e44e                	sd	s3,8(sp)
    800032dc:	1800                	addi	s0,sp,48
    800032de:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800032e0:	05050493          	addi	s1,a0,80
    800032e4:	08050913          	addi	s2,a0,128
    800032e8:	a021                	j	800032f0 <itrunc+0x20>
    800032ea:	0491                	addi	s1,s1,4
    800032ec:	01248b63          	beq	s1,s2,80003302 <itrunc+0x32>
    if(ip->addrs[i]){
    800032f0:	408c                	lw	a1,0(s1)
    800032f2:	dde5                	beqz	a1,800032ea <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800032f4:	0009a503          	lw	a0,0(s3)
    800032f8:	a17ff0ef          	jal	80002d0e <bfree>
      ip->addrs[i] = 0;
    800032fc:	0004a023          	sw	zero,0(s1)
    80003300:	b7ed                	j	800032ea <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003302:	0809a583          	lw	a1,128(s3)
    80003306:	ed89                	bnez	a1,80003320 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003308:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000330c:	854e                	mv	a0,s3
    8000330e:	e21ff0ef          	jal	8000312e <iupdate>
}
    80003312:	70a2                	ld	ra,40(sp)
    80003314:	7402                	ld	s0,32(sp)
    80003316:	64e2                	ld	s1,24(sp)
    80003318:	6942                	ld	s2,16(sp)
    8000331a:	69a2                	ld	s3,8(sp)
    8000331c:	6145                	addi	sp,sp,48
    8000331e:	8082                	ret
    80003320:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003322:	0009a503          	lw	a0,0(s3)
    80003326:	ff0ff0ef          	jal	80002b16 <bread>
    8000332a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000332c:	05850493          	addi	s1,a0,88
    80003330:	45850913          	addi	s2,a0,1112
    80003334:	a021                	j	8000333c <itrunc+0x6c>
    80003336:	0491                	addi	s1,s1,4
    80003338:	01248963          	beq	s1,s2,8000334a <itrunc+0x7a>
      if(a[j])
    8000333c:	408c                	lw	a1,0(s1)
    8000333e:	dde5                	beqz	a1,80003336 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003340:	0009a503          	lw	a0,0(s3)
    80003344:	9cbff0ef          	jal	80002d0e <bfree>
    80003348:	b7fd                	j	80003336 <itrunc+0x66>
    brelse(bp);
    8000334a:	8552                	mv	a0,s4
    8000334c:	8d3ff0ef          	jal	80002c1e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003350:	0809a583          	lw	a1,128(s3)
    80003354:	0009a503          	lw	a0,0(s3)
    80003358:	9b7ff0ef          	jal	80002d0e <bfree>
    ip->addrs[NDIRECT] = 0;
    8000335c:	0809a023          	sw	zero,128(s3)
    80003360:	6a02                	ld	s4,0(sp)
    80003362:	b75d                	j	80003308 <itrunc+0x38>

0000000080003364 <iput>:
{
    80003364:	1101                	addi	sp,sp,-32
    80003366:	ec06                	sd	ra,24(sp)
    80003368:	e822                	sd	s0,16(sp)
    8000336a:	e426                	sd	s1,8(sp)
    8000336c:	1000                	addi	s0,sp,32
    8000336e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003370:	0001d517          	auipc	a0,0x1d
    80003374:	47050513          	addi	a0,a0,1136 # 800207e0 <itable>
    80003378:	857fd0ef          	jal	80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000337c:	4498                	lw	a4,8(s1)
    8000337e:	4785                	li	a5,1
    80003380:	02f70063          	beq	a4,a5,800033a0 <iput+0x3c>
  ip->ref--;
    80003384:	449c                	lw	a5,8(s1)
    80003386:	37fd                	addiw	a5,a5,-1
    80003388:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000338a:	0001d517          	auipc	a0,0x1d
    8000338e:	45650513          	addi	a0,a0,1110 # 800207e0 <itable>
    80003392:	8d5fd0ef          	jal	80000c66 <release>
}
    80003396:	60e2                	ld	ra,24(sp)
    80003398:	6442                	ld	s0,16(sp)
    8000339a:	64a2                	ld	s1,8(sp)
    8000339c:	6105                	addi	sp,sp,32
    8000339e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800033a0:	40bc                	lw	a5,64(s1)
    800033a2:	d3ed                	beqz	a5,80003384 <iput+0x20>
    800033a4:	04a49783          	lh	a5,74(s1)
    800033a8:	fff1                	bnez	a5,80003384 <iput+0x20>
    800033aa:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800033ac:	01048913          	addi	s2,s1,16
    800033b0:	854a                	mv	a0,s2
    800033b2:	297000ef          	jal	80003e48 <acquiresleep>
    release(&itable.lock);
    800033b6:	0001d517          	auipc	a0,0x1d
    800033ba:	42a50513          	addi	a0,a0,1066 # 800207e0 <itable>
    800033be:	8a9fd0ef          	jal	80000c66 <release>
    itrunc(ip);
    800033c2:	8526                	mv	a0,s1
    800033c4:	f0dff0ef          	jal	800032d0 <itrunc>
    ip->type = 0;
    800033c8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800033cc:	8526                	mv	a0,s1
    800033ce:	d61ff0ef          	jal	8000312e <iupdate>
    ip->valid = 0;
    800033d2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800033d6:	854a                	mv	a0,s2
    800033d8:	2b7000ef          	jal	80003e8e <releasesleep>
    acquire(&itable.lock);
    800033dc:	0001d517          	auipc	a0,0x1d
    800033e0:	40450513          	addi	a0,a0,1028 # 800207e0 <itable>
    800033e4:	feafd0ef          	jal	80000bce <acquire>
    800033e8:	6902                	ld	s2,0(sp)
    800033ea:	bf69                	j	80003384 <iput+0x20>

00000000800033ec <iunlockput>:
{
    800033ec:	1101                	addi	sp,sp,-32
    800033ee:	ec06                	sd	ra,24(sp)
    800033f0:	e822                	sd	s0,16(sp)
    800033f2:	e426                	sd	s1,8(sp)
    800033f4:	1000                	addi	s0,sp,32
    800033f6:	84aa                	mv	s1,a0
  iunlock(ip);
    800033f8:	e99ff0ef          	jal	80003290 <iunlock>
  iput(ip);
    800033fc:	8526                	mv	a0,s1
    800033fe:	f67ff0ef          	jal	80003364 <iput>
}
    80003402:	60e2                	ld	ra,24(sp)
    80003404:	6442                	ld	s0,16(sp)
    80003406:	64a2                	ld	s1,8(sp)
    80003408:	6105                	addi	sp,sp,32
    8000340a:	8082                	ret

000000008000340c <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000340c:	0001d717          	auipc	a4,0x1d
    80003410:	3c072703          	lw	a4,960(a4) # 800207cc <sb+0xc>
    80003414:	4785                	li	a5,1
    80003416:	0ae7ff63          	bgeu	a5,a4,800034d4 <ireclaim+0xc8>
{
    8000341a:	7139                	addi	sp,sp,-64
    8000341c:	fc06                	sd	ra,56(sp)
    8000341e:	f822                	sd	s0,48(sp)
    80003420:	f426                	sd	s1,40(sp)
    80003422:	f04a                	sd	s2,32(sp)
    80003424:	ec4e                	sd	s3,24(sp)
    80003426:	e852                	sd	s4,16(sp)
    80003428:	e456                	sd	s5,8(sp)
    8000342a:	e05a                	sd	s6,0(sp)
    8000342c:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000342e:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003430:	00050a1b          	sext.w	s4,a0
    80003434:	0001da97          	auipc	s5,0x1d
    80003438:	38ca8a93          	addi	s5,s5,908 # 800207c0 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    8000343c:	00004b17          	auipc	s6,0x4
    80003440:	02cb0b13          	addi	s6,s6,44 # 80007468 <etext+0x468>
    80003444:	a099                	j	8000348a <ireclaim+0x7e>
    80003446:	85ce                	mv	a1,s3
    80003448:	855a                	mv	a0,s6
    8000344a:	8b0fd0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    8000344e:	85ce                	mv	a1,s3
    80003450:	8552                	mv	a0,s4
    80003452:	b1dff0ef          	jal	80002f6e <iget>
    80003456:	89aa                	mv	s3,a0
    brelse(bp);
    80003458:	854a                	mv	a0,s2
    8000345a:	fc4ff0ef          	jal	80002c1e <brelse>
    if (ip) {
    8000345e:	00098f63          	beqz	s3,8000347c <ireclaim+0x70>
      begin_op();
    80003462:	76a000ef          	jal	80003bcc <begin_op>
      ilock(ip);
    80003466:	854e                	mv	a0,s3
    80003468:	d7bff0ef          	jal	800031e2 <ilock>
      iunlock(ip);
    8000346c:	854e                	mv	a0,s3
    8000346e:	e23ff0ef          	jal	80003290 <iunlock>
      iput(ip);
    80003472:	854e                	mv	a0,s3
    80003474:	ef1ff0ef          	jal	80003364 <iput>
      end_op();
    80003478:	7be000ef          	jal	80003c36 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000347c:	0485                	addi	s1,s1,1
    8000347e:	00caa703          	lw	a4,12(s5)
    80003482:	0004879b          	sext.w	a5,s1
    80003486:	02e7fd63          	bgeu	a5,a4,800034c0 <ireclaim+0xb4>
    8000348a:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000348e:	0044d593          	srli	a1,s1,0x4
    80003492:	018aa783          	lw	a5,24(s5)
    80003496:	9dbd                	addw	a1,a1,a5
    80003498:	8552                	mv	a0,s4
    8000349a:	e7cff0ef          	jal	80002b16 <bread>
    8000349e:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800034a0:	05850793          	addi	a5,a0,88
    800034a4:	00f9f713          	andi	a4,s3,15
    800034a8:	071a                	slli	a4,a4,0x6
    800034aa:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800034ac:	00079703          	lh	a4,0(a5)
    800034b0:	c701                	beqz	a4,800034b8 <ireclaim+0xac>
    800034b2:	00679783          	lh	a5,6(a5)
    800034b6:	dbc1                	beqz	a5,80003446 <ireclaim+0x3a>
    brelse(bp);
    800034b8:	854a                	mv	a0,s2
    800034ba:	f64ff0ef          	jal	80002c1e <brelse>
    if (ip) {
    800034be:	bf7d                	j	8000347c <ireclaim+0x70>
}
    800034c0:	70e2                	ld	ra,56(sp)
    800034c2:	7442                	ld	s0,48(sp)
    800034c4:	74a2                	ld	s1,40(sp)
    800034c6:	7902                	ld	s2,32(sp)
    800034c8:	69e2                	ld	s3,24(sp)
    800034ca:	6a42                	ld	s4,16(sp)
    800034cc:	6aa2                	ld	s5,8(sp)
    800034ce:	6b02                	ld	s6,0(sp)
    800034d0:	6121                	addi	sp,sp,64
    800034d2:	8082                	ret
    800034d4:	8082                	ret

00000000800034d6 <fsinit>:
fsinit(int dev) {
    800034d6:	7179                	addi	sp,sp,-48
    800034d8:	f406                	sd	ra,40(sp)
    800034da:	f022                	sd	s0,32(sp)
    800034dc:	ec26                	sd	s1,24(sp)
    800034de:	e84a                	sd	s2,16(sp)
    800034e0:	e44e                	sd	s3,8(sp)
    800034e2:	1800                	addi	s0,sp,48
    800034e4:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800034e6:	4585                	li	a1,1
    800034e8:	e2eff0ef          	jal	80002b16 <bread>
    800034ec:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800034ee:	0001d997          	auipc	s3,0x1d
    800034f2:	2d298993          	addi	s3,s3,722 # 800207c0 <sb>
    800034f6:	02000613          	li	a2,32
    800034fa:	05850593          	addi	a1,a0,88
    800034fe:	854e                	mv	a0,s3
    80003500:	ffefd0ef          	jal	80000cfe <memmove>
  brelse(bp);
    80003504:	854a                	mv	a0,s2
    80003506:	f18ff0ef          	jal	80002c1e <brelse>
  if(sb.magic != FSMAGIC)
    8000350a:	0009a703          	lw	a4,0(s3)
    8000350e:	102037b7          	lui	a5,0x10203
    80003512:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003516:	02f71363          	bne	a4,a5,8000353c <fsinit+0x66>
  initlog(dev, &sb);
    8000351a:	0001d597          	auipc	a1,0x1d
    8000351e:	2a658593          	addi	a1,a1,678 # 800207c0 <sb>
    80003522:	8526                	mv	a0,s1
    80003524:	62a000ef          	jal	80003b4e <initlog>
  ireclaim(dev);
    80003528:	8526                	mv	a0,s1
    8000352a:	ee3ff0ef          	jal	8000340c <ireclaim>
}
    8000352e:	70a2                	ld	ra,40(sp)
    80003530:	7402                	ld	s0,32(sp)
    80003532:	64e2                	ld	s1,24(sp)
    80003534:	6942                	ld	s2,16(sp)
    80003536:	69a2                	ld	s3,8(sp)
    80003538:	6145                	addi	sp,sp,48
    8000353a:	8082                	ret
    panic("invalid file system");
    8000353c:	00004517          	auipc	a0,0x4
    80003540:	f4c50513          	addi	a0,a0,-180 # 80007488 <etext+0x488>
    80003544:	a9cfd0ef          	jal	800007e0 <panic>

0000000080003548 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003548:	1141                	addi	sp,sp,-16
    8000354a:	e422                	sd	s0,8(sp)
    8000354c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000354e:	411c                	lw	a5,0(a0)
    80003550:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003552:	415c                	lw	a5,4(a0)
    80003554:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003556:	04451783          	lh	a5,68(a0)
    8000355a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000355e:	04a51783          	lh	a5,74(a0)
    80003562:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003566:	04c56783          	lwu	a5,76(a0)
    8000356a:	e99c                	sd	a5,16(a1)
}
    8000356c:	6422                	ld	s0,8(sp)
    8000356e:	0141                	addi	sp,sp,16
    80003570:	8082                	ret

0000000080003572 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003572:	457c                	lw	a5,76(a0)
    80003574:	0ed7eb63          	bltu	a5,a3,8000366a <readi+0xf8>
{
    80003578:	7159                	addi	sp,sp,-112
    8000357a:	f486                	sd	ra,104(sp)
    8000357c:	f0a2                	sd	s0,96(sp)
    8000357e:	eca6                	sd	s1,88(sp)
    80003580:	e0d2                	sd	s4,64(sp)
    80003582:	fc56                	sd	s5,56(sp)
    80003584:	f85a                	sd	s6,48(sp)
    80003586:	f45e                	sd	s7,40(sp)
    80003588:	1880                	addi	s0,sp,112
    8000358a:	8b2a                	mv	s6,a0
    8000358c:	8bae                	mv	s7,a1
    8000358e:	8a32                	mv	s4,a2
    80003590:	84b6                	mv	s1,a3
    80003592:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003594:	9f35                	addw	a4,a4,a3
    return 0;
    80003596:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003598:	0cd76063          	bltu	a4,a3,80003658 <readi+0xe6>
    8000359c:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    8000359e:	00e7f463          	bgeu	a5,a4,800035a6 <readi+0x34>
    n = ip->size - off;
    800035a2:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800035a6:	080a8f63          	beqz	s5,80003644 <readi+0xd2>
    800035aa:	e8ca                	sd	s2,80(sp)
    800035ac:	f062                	sd	s8,32(sp)
    800035ae:	ec66                	sd	s9,24(sp)
    800035b0:	e86a                	sd	s10,16(sp)
    800035b2:	e46e                	sd	s11,8(sp)
    800035b4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800035b6:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800035ba:	5c7d                	li	s8,-1
    800035bc:	a80d                	j	800035ee <readi+0x7c>
    800035be:	020d1d93          	slli	s11,s10,0x20
    800035c2:	020ddd93          	srli	s11,s11,0x20
    800035c6:	05890613          	addi	a2,s2,88
    800035ca:	86ee                	mv	a3,s11
    800035cc:	963a                	add	a2,a2,a4
    800035ce:	85d2                	mv	a1,s4
    800035d0:	855e                	mv	a0,s7
    800035d2:	c63fe0ef          	jal	80002234 <either_copyout>
    800035d6:	05850763          	beq	a0,s8,80003624 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800035da:	854a                	mv	a0,s2
    800035dc:	e42ff0ef          	jal	80002c1e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800035e0:	013d09bb          	addw	s3,s10,s3
    800035e4:	009d04bb          	addw	s1,s10,s1
    800035e8:	9a6e                	add	s4,s4,s11
    800035ea:	0559f763          	bgeu	s3,s5,80003638 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800035ee:	00a4d59b          	srliw	a1,s1,0xa
    800035f2:	855a                	mv	a0,s6
    800035f4:	8a7ff0ef          	jal	80002e9a <bmap>
    800035f8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800035fc:	c5b1                	beqz	a1,80003648 <readi+0xd6>
    bp = bread(ip->dev, addr);
    800035fe:	000b2503          	lw	a0,0(s6)
    80003602:	d14ff0ef          	jal	80002b16 <bread>
    80003606:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003608:	3ff4f713          	andi	a4,s1,1023
    8000360c:	40ec87bb          	subw	a5,s9,a4
    80003610:	413a86bb          	subw	a3,s5,s3
    80003614:	8d3e                	mv	s10,a5
    80003616:	2781                	sext.w	a5,a5
    80003618:	0006861b          	sext.w	a2,a3
    8000361c:	faf671e3          	bgeu	a2,a5,800035be <readi+0x4c>
    80003620:	8d36                	mv	s10,a3
    80003622:	bf71                	j	800035be <readi+0x4c>
      brelse(bp);
    80003624:	854a                	mv	a0,s2
    80003626:	df8ff0ef          	jal	80002c1e <brelse>
      tot = -1;
    8000362a:	59fd                	li	s3,-1
      break;
    8000362c:	6946                	ld	s2,80(sp)
    8000362e:	7c02                	ld	s8,32(sp)
    80003630:	6ce2                	ld	s9,24(sp)
    80003632:	6d42                	ld	s10,16(sp)
    80003634:	6da2                	ld	s11,8(sp)
    80003636:	a831                	j	80003652 <readi+0xe0>
    80003638:	6946                	ld	s2,80(sp)
    8000363a:	7c02                	ld	s8,32(sp)
    8000363c:	6ce2                	ld	s9,24(sp)
    8000363e:	6d42                	ld	s10,16(sp)
    80003640:	6da2                	ld	s11,8(sp)
    80003642:	a801                	j	80003652 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003644:	89d6                	mv	s3,s5
    80003646:	a031                	j	80003652 <readi+0xe0>
    80003648:	6946                	ld	s2,80(sp)
    8000364a:	7c02                	ld	s8,32(sp)
    8000364c:	6ce2                	ld	s9,24(sp)
    8000364e:	6d42                	ld	s10,16(sp)
    80003650:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003652:	0009851b          	sext.w	a0,s3
    80003656:	69a6                	ld	s3,72(sp)
}
    80003658:	70a6                	ld	ra,104(sp)
    8000365a:	7406                	ld	s0,96(sp)
    8000365c:	64e6                	ld	s1,88(sp)
    8000365e:	6a06                	ld	s4,64(sp)
    80003660:	7ae2                	ld	s5,56(sp)
    80003662:	7b42                	ld	s6,48(sp)
    80003664:	7ba2                	ld	s7,40(sp)
    80003666:	6165                	addi	sp,sp,112
    80003668:	8082                	ret
    return 0;
    8000366a:	4501                	li	a0,0
}
    8000366c:	8082                	ret

000000008000366e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000366e:	457c                	lw	a5,76(a0)
    80003670:	10d7e063          	bltu	a5,a3,80003770 <writei+0x102>
{
    80003674:	7159                	addi	sp,sp,-112
    80003676:	f486                	sd	ra,104(sp)
    80003678:	f0a2                	sd	s0,96(sp)
    8000367a:	e8ca                	sd	s2,80(sp)
    8000367c:	e0d2                	sd	s4,64(sp)
    8000367e:	fc56                	sd	s5,56(sp)
    80003680:	f85a                	sd	s6,48(sp)
    80003682:	f45e                	sd	s7,40(sp)
    80003684:	1880                	addi	s0,sp,112
    80003686:	8aaa                	mv	s5,a0
    80003688:	8bae                	mv	s7,a1
    8000368a:	8a32                	mv	s4,a2
    8000368c:	8936                	mv	s2,a3
    8000368e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003690:	00e687bb          	addw	a5,a3,a4
    80003694:	0ed7e063          	bltu	a5,a3,80003774 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003698:	00043737          	lui	a4,0x43
    8000369c:	0cf76e63          	bltu	a4,a5,80003778 <writei+0x10a>
    800036a0:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800036a2:	0a0b0f63          	beqz	s6,80003760 <writei+0xf2>
    800036a6:	eca6                	sd	s1,88(sp)
    800036a8:	f062                	sd	s8,32(sp)
    800036aa:	ec66                	sd	s9,24(sp)
    800036ac:	e86a                	sd	s10,16(sp)
    800036ae:	e46e                	sd	s11,8(sp)
    800036b0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800036b2:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800036b6:	5c7d                	li	s8,-1
    800036b8:	a825                	j	800036f0 <writei+0x82>
    800036ba:	020d1d93          	slli	s11,s10,0x20
    800036be:	020ddd93          	srli	s11,s11,0x20
    800036c2:	05848513          	addi	a0,s1,88
    800036c6:	86ee                	mv	a3,s11
    800036c8:	8652                	mv	a2,s4
    800036ca:	85de                	mv	a1,s7
    800036cc:	953a                	add	a0,a0,a4
    800036ce:	bb1fe0ef          	jal	8000227e <either_copyin>
    800036d2:	05850a63          	beq	a0,s8,80003726 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800036d6:	8526                	mv	a0,s1
    800036d8:	678000ef          	jal	80003d50 <log_write>
    brelse(bp);
    800036dc:	8526                	mv	a0,s1
    800036de:	d40ff0ef          	jal	80002c1e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800036e2:	013d09bb          	addw	s3,s10,s3
    800036e6:	012d093b          	addw	s2,s10,s2
    800036ea:	9a6e                	add	s4,s4,s11
    800036ec:	0569f063          	bgeu	s3,s6,8000372c <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800036f0:	00a9559b          	srliw	a1,s2,0xa
    800036f4:	8556                	mv	a0,s5
    800036f6:	fa4ff0ef          	jal	80002e9a <bmap>
    800036fa:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800036fe:	c59d                	beqz	a1,8000372c <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003700:	000aa503          	lw	a0,0(s5)
    80003704:	c12ff0ef          	jal	80002b16 <bread>
    80003708:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000370a:	3ff97713          	andi	a4,s2,1023
    8000370e:	40ec87bb          	subw	a5,s9,a4
    80003712:	413b06bb          	subw	a3,s6,s3
    80003716:	8d3e                	mv	s10,a5
    80003718:	2781                	sext.w	a5,a5
    8000371a:	0006861b          	sext.w	a2,a3
    8000371e:	f8f67ee3          	bgeu	a2,a5,800036ba <writei+0x4c>
    80003722:	8d36                	mv	s10,a3
    80003724:	bf59                	j	800036ba <writei+0x4c>
      brelse(bp);
    80003726:	8526                	mv	a0,s1
    80003728:	cf6ff0ef          	jal	80002c1e <brelse>
  }

  if(off > ip->size)
    8000372c:	04caa783          	lw	a5,76(s5)
    80003730:	0327fa63          	bgeu	a5,s2,80003764 <writei+0xf6>
    ip->size = off;
    80003734:	052aa623          	sw	s2,76(s5)
    80003738:	64e6                	ld	s1,88(sp)
    8000373a:	7c02                	ld	s8,32(sp)
    8000373c:	6ce2                	ld	s9,24(sp)
    8000373e:	6d42                	ld	s10,16(sp)
    80003740:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003742:	8556                	mv	a0,s5
    80003744:	9ebff0ef          	jal	8000312e <iupdate>

  return tot;
    80003748:	0009851b          	sext.w	a0,s3
    8000374c:	69a6                	ld	s3,72(sp)
}
    8000374e:	70a6                	ld	ra,104(sp)
    80003750:	7406                	ld	s0,96(sp)
    80003752:	6946                	ld	s2,80(sp)
    80003754:	6a06                	ld	s4,64(sp)
    80003756:	7ae2                	ld	s5,56(sp)
    80003758:	7b42                	ld	s6,48(sp)
    8000375a:	7ba2                	ld	s7,40(sp)
    8000375c:	6165                	addi	sp,sp,112
    8000375e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003760:	89da                	mv	s3,s6
    80003762:	b7c5                	j	80003742 <writei+0xd4>
    80003764:	64e6                	ld	s1,88(sp)
    80003766:	7c02                	ld	s8,32(sp)
    80003768:	6ce2                	ld	s9,24(sp)
    8000376a:	6d42                	ld	s10,16(sp)
    8000376c:	6da2                	ld	s11,8(sp)
    8000376e:	bfd1                	j	80003742 <writei+0xd4>
    return -1;
    80003770:	557d                	li	a0,-1
}
    80003772:	8082                	ret
    return -1;
    80003774:	557d                	li	a0,-1
    80003776:	bfe1                	j	8000374e <writei+0xe0>
    return -1;
    80003778:	557d                	li	a0,-1
    8000377a:	bfd1                	j	8000374e <writei+0xe0>

000000008000377c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000377c:	1141                	addi	sp,sp,-16
    8000377e:	e406                	sd	ra,8(sp)
    80003780:	e022                	sd	s0,0(sp)
    80003782:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003784:	4639                	li	a2,14
    80003786:	de8fd0ef          	jal	80000d6e <strncmp>
}
    8000378a:	60a2                	ld	ra,8(sp)
    8000378c:	6402                	ld	s0,0(sp)
    8000378e:	0141                	addi	sp,sp,16
    80003790:	8082                	ret

0000000080003792 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003792:	7139                	addi	sp,sp,-64
    80003794:	fc06                	sd	ra,56(sp)
    80003796:	f822                	sd	s0,48(sp)
    80003798:	f426                	sd	s1,40(sp)
    8000379a:	f04a                	sd	s2,32(sp)
    8000379c:	ec4e                	sd	s3,24(sp)
    8000379e:	e852                	sd	s4,16(sp)
    800037a0:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800037a2:	04451703          	lh	a4,68(a0)
    800037a6:	4785                	li	a5,1
    800037a8:	00f71a63          	bne	a4,a5,800037bc <dirlookup+0x2a>
    800037ac:	892a                	mv	s2,a0
    800037ae:	89ae                	mv	s3,a1
    800037b0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800037b2:	457c                	lw	a5,76(a0)
    800037b4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800037b6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800037b8:	e39d                	bnez	a5,800037de <dirlookup+0x4c>
    800037ba:	a095                	j	8000381e <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800037bc:	00004517          	auipc	a0,0x4
    800037c0:	ce450513          	addi	a0,a0,-796 # 800074a0 <etext+0x4a0>
    800037c4:	81cfd0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    800037c8:	00004517          	auipc	a0,0x4
    800037cc:	cf050513          	addi	a0,a0,-784 # 800074b8 <etext+0x4b8>
    800037d0:	810fd0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800037d4:	24c1                	addiw	s1,s1,16
    800037d6:	04c92783          	lw	a5,76(s2)
    800037da:	04f4f163          	bgeu	s1,a5,8000381c <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800037de:	4741                	li	a4,16
    800037e0:	86a6                	mv	a3,s1
    800037e2:	fc040613          	addi	a2,s0,-64
    800037e6:	4581                	li	a1,0
    800037e8:	854a                	mv	a0,s2
    800037ea:	d89ff0ef          	jal	80003572 <readi>
    800037ee:	47c1                	li	a5,16
    800037f0:	fcf51ce3          	bne	a0,a5,800037c8 <dirlookup+0x36>
    if(de.inum == 0)
    800037f4:	fc045783          	lhu	a5,-64(s0)
    800037f8:	dff1                	beqz	a5,800037d4 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800037fa:	fc240593          	addi	a1,s0,-62
    800037fe:	854e                	mv	a0,s3
    80003800:	f7dff0ef          	jal	8000377c <namecmp>
    80003804:	f961                	bnez	a0,800037d4 <dirlookup+0x42>
      if(poff)
    80003806:	000a0463          	beqz	s4,8000380e <dirlookup+0x7c>
        *poff = off;
    8000380a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000380e:	fc045583          	lhu	a1,-64(s0)
    80003812:	00092503          	lw	a0,0(s2)
    80003816:	f58ff0ef          	jal	80002f6e <iget>
    8000381a:	a011                	j	8000381e <dirlookup+0x8c>
  return 0;
    8000381c:	4501                	li	a0,0
}
    8000381e:	70e2                	ld	ra,56(sp)
    80003820:	7442                	ld	s0,48(sp)
    80003822:	74a2                	ld	s1,40(sp)
    80003824:	7902                	ld	s2,32(sp)
    80003826:	69e2                	ld	s3,24(sp)
    80003828:	6a42                	ld	s4,16(sp)
    8000382a:	6121                	addi	sp,sp,64
    8000382c:	8082                	ret

000000008000382e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000382e:	711d                	addi	sp,sp,-96
    80003830:	ec86                	sd	ra,88(sp)
    80003832:	e8a2                	sd	s0,80(sp)
    80003834:	e4a6                	sd	s1,72(sp)
    80003836:	e0ca                	sd	s2,64(sp)
    80003838:	fc4e                	sd	s3,56(sp)
    8000383a:	f852                	sd	s4,48(sp)
    8000383c:	f456                	sd	s5,40(sp)
    8000383e:	f05a                	sd	s6,32(sp)
    80003840:	ec5e                	sd	s7,24(sp)
    80003842:	e862                	sd	s8,16(sp)
    80003844:	e466                	sd	s9,8(sp)
    80003846:	1080                	addi	s0,sp,96
    80003848:	84aa                	mv	s1,a0
    8000384a:	8b2e                	mv	s6,a1
    8000384c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000384e:	00054703          	lbu	a4,0(a0)
    80003852:	02f00793          	li	a5,47
    80003856:	00f70e63          	beq	a4,a5,80003872 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000385a:	874fe0ef          	jal	800018ce <myproc>
    8000385e:	15053503          	ld	a0,336(a0)
    80003862:	94bff0ef          	jal	800031ac <idup>
    80003866:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003868:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000386c:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000386e:	4b85                	li	s7,1
    80003870:	a871                	j	8000390c <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003872:	4585                	li	a1,1
    80003874:	4505                	li	a0,1
    80003876:	ef8ff0ef          	jal	80002f6e <iget>
    8000387a:	8a2a                	mv	s4,a0
    8000387c:	b7f5                	j	80003868 <namex+0x3a>
      iunlockput(ip);
    8000387e:	8552                	mv	a0,s4
    80003880:	b6dff0ef          	jal	800033ec <iunlockput>
      return 0;
    80003884:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003886:	8552                	mv	a0,s4
    80003888:	60e6                	ld	ra,88(sp)
    8000388a:	6446                	ld	s0,80(sp)
    8000388c:	64a6                	ld	s1,72(sp)
    8000388e:	6906                	ld	s2,64(sp)
    80003890:	79e2                	ld	s3,56(sp)
    80003892:	7a42                	ld	s4,48(sp)
    80003894:	7aa2                	ld	s5,40(sp)
    80003896:	7b02                	ld	s6,32(sp)
    80003898:	6be2                	ld	s7,24(sp)
    8000389a:	6c42                	ld	s8,16(sp)
    8000389c:	6ca2                	ld	s9,8(sp)
    8000389e:	6125                	addi	sp,sp,96
    800038a0:	8082                	ret
      iunlock(ip);
    800038a2:	8552                	mv	a0,s4
    800038a4:	9edff0ef          	jal	80003290 <iunlock>
      return ip;
    800038a8:	bff9                	j	80003886 <namex+0x58>
      iunlockput(ip);
    800038aa:	8552                	mv	a0,s4
    800038ac:	b41ff0ef          	jal	800033ec <iunlockput>
      return 0;
    800038b0:	8a4e                	mv	s4,s3
    800038b2:	bfd1                	j	80003886 <namex+0x58>
  len = path - s;
    800038b4:	40998633          	sub	a2,s3,s1
    800038b8:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800038bc:	099c5063          	bge	s8,s9,8000393c <namex+0x10e>
    memmove(name, s, DIRSIZ);
    800038c0:	4639                	li	a2,14
    800038c2:	85a6                	mv	a1,s1
    800038c4:	8556                	mv	a0,s5
    800038c6:	c38fd0ef          	jal	80000cfe <memmove>
    800038ca:	84ce                	mv	s1,s3
  while(*path == '/')
    800038cc:	0004c783          	lbu	a5,0(s1)
    800038d0:	01279763          	bne	a5,s2,800038de <namex+0xb0>
    path++;
    800038d4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800038d6:	0004c783          	lbu	a5,0(s1)
    800038da:	ff278de3          	beq	a5,s2,800038d4 <namex+0xa6>
    ilock(ip);
    800038de:	8552                	mv	a0,s4
    800038e0:	903ff0ef          	jal	800031e2 <ilock>
    if(ip->type != T_DIR){
    800038e4:	044a1783          	lh	a5,68(s4)
    800038e8:	f9779be3          	bne	a5,s7,8000387e <namex+0x50>
    if(nameiparent && *path == '\0'){
    800038ec:	000b0563          	beqz	s6,800038f6 <namex+0xc8>
    800038f0:	0004c783          	lbu	a5,0(s1)
    800038f4:	d7dd                	beqz	a5,800038a2 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    800038f6:	4601                	li	a2,0
    800038f8:	85d6                	mv	a1,s5
    800038fa:	8552                	mv	a0,s4
    800038fc:	e97ff0ef          	jal	80003792 <dirlookup>
    80003900:	89aa                	mv	s3,a0
    80003902:	d545                	beqz	a0,800038aa <namex+0x7c>
    iunlockput(ip);
    80003904:	8552                	mv	a0,s4
    80003906:	ae7ff0ef          	jal	800033ec <iunlockput>
    ip = next;
    8000390a:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000390c:	0004c783          	lbu	a5,0(s1)
    80003910:	01279763          	bne	a5,s2,8000391e <namex+0xf0>
    path++;
    80003914:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003916:	0004c783          	lbu	a5,0(s1)
    8000391a:	ff278de3          	beq	a5,s2,80003914 <namex+0xe6>
  if(*path == 0)
    8000391e:	cb8d                	beqz	a5,80003950 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003920:	0004c783          	lbu	a5,0(s1)
    80003924:	89a6                	mv	s3,s1
  len = path - s;
    80003926:	4c81                	li	s9,0
    80003928:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    8000392a:	01278963          	beq	a5,s2,8000393c <namex+0x10e>
    8000392e:	d3d9                	beqz	a5,800038b4 <namex+0x86>
    path++;
    80003930:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003932:	0009c783          	lbu	a5,0(s3)
    80003936:	ff279ce3          	bne	a5,s2,8000392e <namex+0x100>
    8000393a:	bfad                	j	800038b4 <namex+0x86>
    memmove(name, s, len);
    8000393c:	2601                	sext.w	a2,a2
    8000393e:	85a6                	mv	a1,s1
    80003940:	8556                	mv	a0,s5
    80003942:	bbcfd0ef          	jal	80000cfe <memmove>
    name[len] = 0;
    80003946:	9cd6                	add	s9,s9,s5
    80003948:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000394c:	84ce                	mv	s1,s3
    8000394e:	bfbd                	j	800038cc <namex+0x9e>
  if(nameiparent){
    80003950:	f20b0be3          	beqz	s6,80003886 <namex+0x58>
    iput(ip);
    80003954:	8552                	mv	a0,s4
    80003956:	a0fff0ef          	jal	80003364 <iput>
    return 0;
    8000395a:	4a01                	li	s4,0
    8000395c:	b72d                	j	80003886 <namex+0x58>

000000008000395e <dirlink>:
{
    8000395e:	7139                	addi	sp,sp,-64
    80003960:	fc06                	sd	ra,56(sp)
    80003962:	f822                	sd	s0,48(sp)
    80003964:	f04a                	sd	s2,32(sp)
    80003966:	ec4e                	sd	s3,24(sp)
    80003968:	e852                	sd	s4,16(sp)
    8000396a:	0080                	addi	s0,sp,64
    8000396c:	892a                	mv	s2,a0
    8000396e:	8a2e                	mv	s4,a1
    80003970:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003972:	4601                	li	a2,0
    80003974:	e1fff0ef          	jal	80003792 <dirlookup>
    80003978:	e535                	bnez	a0,800039e4 <dirlink+0x86>
    8000397a:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000397c:	04c92483          	lw	s1,76(s2)
    80003980:	c48d                	beqz	s1,800039aa <dirlink+0x4c>
    80003982:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003984:	4741                	li	a4,16
    80003986:	86a6                	mv	a3,s1
    80003988:	fc040613          	addi	a2,s0,-64
    8000398c:	4581                	li	a1,0
    8000398e:	854a                	mv	a0,s2
    80003990:	be3ff0ef          	jal	80003572 <readi>
    80003994:	47c1                	li	a5,16
    80003996:	04f51b63          	bne	a0,a5,800039ec <dirlink+0x8e>
    if(de.inum == 0)
    8000399a:	fc045783          	lhu	a5,-64(s0)
    8000399e:	c791                	beqz	a5,800039aa <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800039a0:	24c1                	addiw	s1,s1,16
    800039a2:	04c92783          	lw	a5,76(s2)
    800039a6:	fcf4efe3          	bltu	s1,a5,80003984 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    800039aa:	4639                	li	a2,14
    800039ac:	85d2                	mv	a1,s4
    800039ae:	fc240513          	addi	a0,s0,-62
    800039b2:	bf2fd0ef          	jal	80000da4 <strncpy>
  de.inum = inum;
    800039b6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039ba:	4741                	li	a4,16
    800039bc:	86a6                	mv	a3,s1
    800039be:	fc040613          	addi	a2,s0,-64
    800039c2:	4581                	li	a1,0
    800039c4:	854a                	mv	a0,s2
    800039c6:	ca9ff0ef          	jal	8000366e <writei>
    800039ca:	1541                	addi	a0,a0,-16
    800039cc:	00a03533          	snez	a0,a0
    800039d0:	40a00533          	neg	a0,a0
    800039d4:	74a2                	ld	s1,40(sp)
}
    800039d6:	70e2                	ld	ra,56(sp)
    800039d8:	7442                	ld	s0,48(sp)
    800039da:	7902                	ld	s2,32(sp)
    800039dc:	69e2                	ld	s3,24(sp)
    800039de:	6a42                	ld	s4,16(sp)
    800039e0:	6121                	addi	sp,sp,64
    800039e2:	8082                	ret
    iput(ip);
    800039e4:	981ff0ef          	jal	80003364 <iput>
    return -1;
    800039e8:	557d                	li	a0,-1
    800039ea:	b7f5                	j	800039d6 <dirlink+0x78>
      panic("dirlink read");
    800039ec:	00004517          	auipc	a0,0x4
    800039f0:	adc50513          	addi	a0,a0,-1316 # 800074c8 <etext+0x4c8>
    800039f4:	dedfc0ef          	jal	800007e0 <panic>

00000000800039f8 <namei>:

struct inode*
namei(char *path)
{
    800039f8:	1101                	addi	sp,sp,-32
    800039fa:	ec06                	sd	ra,24(sp)
    800039fc:	e822                	sd	s0,16(sp)
    800039fe:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003a00:	fe040613          	addi	a2,s0,-32
    80003a04:	4581                	li	a1,0
    80003a06:	e29ff0ef          	jal	8000382e <namex>
}
    80003a0a:	60e2                	ld	ra,24(sp)
    80003a0c:	6442                	ld	s0,16(sp)
    80003a0e:	6105                	addi	sp,sp,32
    80003a10:	8082                	ret

0000000080003a12 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003a12:	1141                	addi	sp,sp,-16
    80003a14:	e406                	sd	ra,8(sp)
    80003a16:	e022                	sd	s0,0(sp)
    80003a18:	0800                	addi	s0,sp,16
    80003a1a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003a1c:	4585                	li	a1,1
    80003a1e:	e11ff0ef          	jal	8000382e <namex>
}
    80003a22:	60a2                	ld	ra,8(sp)
    80003a24:	6402                	ld	s0,0(sp)
    80003a26:	0141                	addi	sp,sp,16
    80003a28:	8082                	ret

0000000080003a2a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003a2a:	1101                	addi	sp,sp,-32
    80003a2c:	ec06                	sd	ra,24(sp)
    80003a2e:	e822                	sd	s0,16(sp)
    80003a30:	e426                	sd	s1,8(sp)
    80003a32:	e04a                	sd	s2,0(sp)
    80003a34:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003a36:	0001f917          	auipc	s2,0x1f
    80003a3a:	85290913          	addi	s2,s2,-1966 # 80022288 <log>
    80003a3e:	01892583          	lw	a1,24(s2)
    80003a42:	02492503          	lw	a0,36(s2)
    80003a46:	8d0ff0ef          	jal	80002b16 <bread>
    80003a4a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003a4c:	02892603          	lw	a2,40(s2)
    80003a50:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003a52:	00c05f63          	blez	a2,80003a70 <write_head+0x46>
    80003a56:	0001f717          	auipc	a4,0x1f
    80003a5a:	85e70713          	addi	a4,a4,-1954 # 800222b4 <log+0x2c>
    80003a5e:	87aa                	mv	a5,a0
    80003a60:	060a                	slli	a2,a2,0x2
    80003a62:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003a64:	4314                	lw	a3,0(a4)
    80003a66:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003a68:	0711                	addi	a4,a4,4
    80003a6a:	0791                	addi	a5,a5,4
    80003a6c:	fec79ce3          	bne	a5,a2,80003a64 <write_head+0x3a>
  }
  bwrite(buf);
    80003a70:	8526                	mv	a0,s1
    80003a72:	97aff0ef          	jal	80002bec <bwrite>
  brelse(buf);
    80003a76:	8526                	mv	a0,s1
    80003a78:	9a6ff0ef          	jal	80002c1e <brelse>
}
    80003a7c:	60e2                	ld	ra,24(sp)
    80003a7e:	6442                	ld	s0,16(sp)
    80003a80:	64a2                	ld	s1,8(sp)
    80003a82:	6902                	ld	s2,0(sp)
    80003a84:	6105                	addi	sp,sp,32
    80003a86:	8082                	ret

0000000080003a88 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a88:	0001f797          	auipc	a5,0x1f
    80003a8c:	8287a783          	lw	a5,-2008(a5) # 800222b0 <log+0x28>
    80003a90:	0af05e63          	blez	a5,80003b4c <install_trans+0xc4>
{
    80003a94:	715d                	addi	sp,sp,-80
    80003a96:	e486                	sd	ra,72(sp)
    80003a98:	e0a2                	sd	s0,64(sp)
    80003a9a:	fc26                	sd	s1,56(sp)
    80003a9c:	f84a                	sd	s2,48(sp)
    80003a9e:	f44e                	sd	s3,40(sp)
    80003aa0:	f052                	sd	s4,32(sp)
    80003aa2:	ec56                	sd	s5,24(sp)
    80003aa4:	e85a                	sd	s6,16(sp)
    80003aa6:	e45e                	sd	s7,8(sp)
    80003aa8:	0880                	addi	s0,sp,80
    80003aaa:	8b2a                	mv	s6,a0
    80003aac:	0001fa97          	auipc	s5,0x1f
    80003ab0:	808a8a93          	addi	s5,s5,-2040 # 800222b4 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ab4:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003ab6:	00004b97          	auipc	s7,0x4
    80003aba:	a22b8b93          	addi	s7,s7,-1502 # 800074d8 <etext+0x4d8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003abe:	0001ea17          	auipc	s4,0x1e
    80003ac2:	7caa0a13          	addi	s4,s4,1994 # 80022288 <log>
    80003ac6:	a025                	j	80003aee <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003ac8:	000aa603          	lw	a2,0(s5)
    80003acc:	85ce                	mv	a1,s3
    80003ace:	855e                	mv	a0,s7
    80003ad0:	a2bfc0ef          	jal	800004fa <printf>
    80003ad4:	a839                	j	80003af2 <install_trans+0x6a>
    brelse(lbuf);
    80003ad6:	854a                	mv	a0,s2
    80003ad8:	946ff0ef          	jal	80002c1e <brelse>
    brelse(dbuf);
    80003adc:	8526                	mv	a0,s1
    80003ade:	940ff0ef          	jal	80002c1e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ae2:	2985                	addiw	s3,s3,1
    80003ae4:	0a91                	addi	s5,s5,4
    80003ae6:	028a2783          	lw	a5,40(s4)
    80003aea:	04f9d663          	bge	s3,a5,80003b36 <install_trans+0xae>
    if(recovering) {
    80003aee:	fc0b1de3          	bnez	s6,80003ac8 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003af2:	018a2583          	lw	a1,24(s4)
    80003af6:	013585bb          	addw	a1,a1,s3
    80003afa:	2585                	addiw	a1,a1,1
    80003afc:	024a2503          	lw	a0,36(s4)
    80003b00:	816ff0ef          	jal	80002b16 <bread>
    80003b04:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003b06:	000aa583          	lw	a1,0(s5)
    80003b0a:	024a2503          	lw	a0,36(s4)
    80003b0e:	808ff0ef          	jal	80002b16 <bread>
    80003b12:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003b14:	40000613          	li	a2,1024
    80003b18:	05890593          	addi	a1,s2,88
    80003b1c:	05850513          	addi	a0,a0,88
    80003b20:	9defd0ef          	jal	80000cfe <memmove>
    bwrite(dbuf);  // write dst to disk
    80003b24:	8526                	mv	a0,s1
    80003b26:	8c6ff0ef          	jal	80002bec <bwrite>
    if(recovering == 0)
    80003b2a:	fa0b16e3          	bnez	s6,80003ad6 <install_trans+0x4e>
      bunpin(dbuf);
    80003b2e:	8526                	mv	a0,s1
    80003b30:	9aaff0ef          	jal	80002cda <bunpin>
    80003b34:	b74d                	j	80003ad6 <install_trans+0x4e>
}
    80003b36:	60a6                	ld	ra,72(sp)
    80003b38:	6406                	ld	s0,64(sp)
    80003b3a:	74e2                	ld	s1,56(sp)
    80003b3c:	7942                	ld	s2,48(sp)
    80003b3e:	79a2                	ld	s3,40(sp)
    80003b40:	7a02                	ld	s4,32(sp)
    80003b42:	6ae2                	ld	s5,24(sp)
    80003b44:	6b42                	ld	s6,16(sp)
    80003b46:	6ba2                	ld	s7,8(sp)
    80003b48:	6161                	addi	sp,sp,80
    80003b4a:	8082                	ret
    80003b4c:	8082                	ret

0000000080003b4e <initlog>:
{
    80003b4e:	7179                	addi	sp,sp,-48
    80003b50:	f406                	sd	ra,40(sp)
    80003b52:	f022                	sd	s0,32(sp)
    80003b54:	ec26                	sd	s1,24(sp)
    80003b56:	e84a                	sd	s2,16(sp)
    80003b58:	e44e                	sd	s3,8(sp)
    80003b5a:	1800                	addi	s0,sp,48
    80003b5c:	892a                	mv	s2,a0
    80003b5e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003b60:	0001e497          	auipc	s1,0x1e
    80003b64:	72848493          	addi	s1,s1,1832 # 80022288 <log>
    80003b68:	00004597          	auipc	a1,0x4
    80003b6c:	99058593          	addi	a1,a1,-1648 # 800074f8 <etext+0x4f8>
    80003b70:	8526                	mv	a0,s1
    80003b72:	fddfc0ef          	jal	80000b4e <initlock>
  log.start = sb->logstart;
    80003b76:	0149a583          	lw	a1,20(s3)
    80003b7a:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003b7c:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003b80:	854a                	mv	a0,s2
    80003b82:	f95fe0ef          	jal	80002b16 <bread>
  log.lh.n = lh->n;
    80003b86:	4d30                	lw	a2,88(a0)
    80003b88:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003b8a:	00c05f63          	blez	a2,80003ba8 <initlog+0x5a>
    80003b8e:	87aa                	mv	a5,a0
    80003b90:	0001e717          	auipc	a4,0x1e
    80003b94:	72470713          	addi	a4,a4,1828 # 800222b4 <log+0x2c>
    80003b98:	060a                	slli	a2,a2,0x2
    80003b9a:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003b9c:	4ff4                	lw	a3,92(a5)
    80003b9e:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003ba0:	0791                	addi	a5,a5,4
    80003ba2:	0711                	addi	a4,a4,4
    80003ba4:	fec79ce3          	bne	a5,a2,80003b9c <initlog+0x4e>
  brelse(buf);
    80003ba8:	876ff0ef          	jal	80002c1e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003bac:	4505                	li	a0,1
    80003bae:	edbff0ef          	jal	80003a88 <install_trans>
  log.lh.n = 0;
    80003bb2:	0001e797          	auipc	a5,0x1e
    80003bb6:	6e07af23          	sw	zero,1790(a5) # 800222b0 <log+0x28>
  write_head(); // clear the log
    80003bba:	e71ff0ef          	jal	80003a2a <write_head>
}
    80003bbe:	70a2                	ld	ra,40(sp)
    80003bc0:	7402                	ld	s0,32(sp)
    80003bc2:	64e2                	ld	s1,24(sp)
    80003bc4:	6942                	ld	s2,16(sp)
    80003bc6:	69a2                	ld	s3,8(sp)
    80003bc8:	6145                	addi	sp,sp,48
    80003bca:	8082                	ret

0000000080003bcc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003bcc:	1101                	addi	sp,sp,-32
    80003bce:	ec06                	sd	ra,24(sp)
    80003bd0:	e822                	sd	s0,16(sp)
    80003bd2:	e426                	sd	s1,8(sp)
    80003bd4:	e04a                	sd	s2,0(sp)
    80003bd6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003bd8:	0001e517          	auipc	a0,0x1e
    80003bdc:	6b050513          	addi	a0,a0,1712 # 80022288 <log>
    80003be0:	feffc0ef          	jal	80000bce <acquire>
  while(1){
    if(log.committing){
    80003be4:	0001e497          	auipc	s1,0x1e
    80003be8:	6a448493          	addi	s1,s1,1700 # 80022288 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003bec:	4979                	li	s2,30
    80003bee:	a029                	j	80003bf8 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003bf0:	85a6                	mv	a1,s1
    80003bf2:	8526                	mv	a0,s1
    80003bf4:	ae4fe0ef          	jal	80001ed8 <sleep>
    if(log.committing){
    80003bf8:	509c                	lw	a5,32(s1)
    80003bfa:	fbfd                	bnez	a5,80003bf0 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003bfc:	4cd8                	lw	a4,28(s1)
    80003bfe:	2705                	addiw	a4,a4,1
    80003c00:	0027179b          	slliw	a5,a4,0x2
    80003c04:	9fb9                	addw	a5,a5,a4
    80003c06:	0017979b          	slliw	a5,a5,0x1
    80003c0a:	5494                	lw	a3,40(s1)
    80003c0c:	9fb5                	addw	a5,a5,a3
    80003c0e:	00f95763          	bge	s2,a5,80003c1c <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003c12:	85a6                	mv	a1,s1
    80003c14:	8526                	mv	a0,s1
    80003c16:	ac2fe0ef          	jal	80001ed8 <sleep>
    80003c1a:	bff9                	j	80003bf8 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003c1c:	0001e517          	auipc	a0,0x1e
    80003c20:	66c50513          	addi	a0,a0,1644 # 80022288 <log>
    80003c24:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003c26:	840fd0ef          	jal	80000c66 <release>
      break;
    }
  }
}
    80003c2a:	60e2                	ld	ra,24(sp)
    80003c2c:	6442                	ld	s0,16(sp)
    80003c2e:	64a2                	ld	s1,8(sp)
    80003c30:	6902                	ld	s2,0(sp)
    80003c32:	6105                	addi	sp,sp,32
    80003c34:	8082                	ret

0000000080003c36 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003c36:	7139                	addi	sp,sp,-64
    80003c38:	fc06                	sd	ra,56(sp)
    80003c3a:	f822                	sd	s0,48(sp)
    80003c3c:	f426                	sd	s1,40(sp)
    80003c3e:	f04a                	sd	s2,32(sp)
    80003c40:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003c42:	0001e497          	auipc	s1,0x1e
    80003c46:	64648493          	addi	s1,s1,1606 # 80022288 <log>
    80003c4a:	8526                	mv	a0,s1
    80003c4c:	f83fc0ef          	jal	80000bce <acquire>
  log.outstanding -= 1;
    80003c50:	4cdc                	lw	a5,28(s1)
    80003c52:	37fd                	addiw	a5,a5,-1
    80003c54:	0007891b          	sext.w	s2,a5
    80003c58:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003c5a:	509c                	lw	a5,32(s1)
    80003c5c:	ef9d                	bnez	a5,80003c9a <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003c5e:	04091763          	bnez	s2,80003cac <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003c62:	0001e497          	auipc	s1,0x1e
    80003c66:	62648493          	addi	s1,s1,1574 # 80022288 <log>
    80003c6a:	4785                	li	a5,1
    80003c6c:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003c6e:	8526                	mv	a0,s1
    80003c70:	ff7fc0ef          	jal	80000c66 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003c74:	549c                	lw	a5,40(s1)
    80003c76:	04f04b63          	bgtz	a5,80003ccc <end_op+0x96>
    acquire(&log.lock);
    80003c7a:	0001e497          	auipc	s1,0x1e
    80003c7e:	60e48493          	addi	s1,s1,1550 # 80022288 <log>
    80003c82:	8526                	mv	a0,s1
    80003c84:	f4bfc0ef          	jal	80000bce <acquire>
    log.committing = 0;
    80003c88:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003c8c:	8526                	mv	a0,s1
    80003c8e:	a96fe0ef          	jal	80001f24 <wakeup>
    release(&log.lock);
    80003c92:	8526                	mv	a0,s1
    80003c94:	fd3fc0ef          	jal	80000c66 <release>
}
    80003c98:	a025                	j	80003cc0 <end_op+0x8a>
    80003c9a:	ec4e                	sd	s3,24(sp)
    80003c9c:	e852                	sd	s4,16(sp)
    80003c9e:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003ca0:	00004517          	auipc	a0,0x4
    80003ca4:	86050513          	addi	a0,a0,-1952 # 80007500 <etext+0x500>
    80003ca8:	b39fc0ef          	jal	800007e0 <panic>
    wakeup(&log);
    80003cac:	0001e497          	auipc	s1,0x1e
    80003cb0:	5dc48493          	addi	s1,s1,1500 # 80022288 <log>
    80003cb4:	8526                	mv	a0,s1
    80003cb6:	a6efe0ef          	jal	80001f24 <wakeup>
  release(&log.lock);
    80003cba:	8526                	mv	a0,s1
    80003cbc:	fabfc0ef          	jal	80000c66 <release>
}
    80003cc0:	70e2                	ld	ra,56(sp)
    80003cc2:	7442                	ld	s0,48(sp)
    80003cc4:	74a2                	ld	s1,40(sp)
    80003cc6:	7902                	ld	s2,32(sp)
    80003cc8:	6121                	addi	sp,sp,64
    80003cca:	8082                	ret
    80003ccc:	ec4e                	sd	s3,24(sp)
    80003cce:	e852                	sd	s4,16(sp)
    80003cd0:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cd2:	0001ea97          	auipc	s5,0x1e
    80003cd6:	5e2a8a93          	addi	s5,s5,1506 # 800222b4 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003cda:	0001ea17          	auipc	s4,0x1e
    80003cde:	5aea0a13          	addi	s4,s4,1454 # 80022288 <log>
    80003ce2:	018a2583          	lw	a1,24(s4)
    80003ce6:	012585bb          	addw	a1,a1,s2
    80003cea:	2585                	addiw	a1,a1,1
    80003cec:	024a2503          	lw	a0,36(s4)
    80003cf0:	e27fe0ef          	jal	80002b16 <bread>
    80003cf4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003cf6:	000aa583          	lw	a1,0(s5)
    80003cfa:	024a2503          	lw	a0,36(s4)
    80003cfe:	e19fe0ef          	jal	80002b16 <bread>
    80003d02:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003d04:	40000613          	li	a2,1024
    80003d08:	05850593          	addi	a1,a0,88
    80003d0c:	05848513          	addi	a0,s1,88
    80003d10:	feffc0ef          	jal	80000cfe <memmove>
    bwrite(to);  // write the log
    80003d14:	8526                	mv	a0,s1
    80003d16:	ed7fe0ef          	jal	80002bec <bwrite>
    brelse(from);
    80003d1a:	854e                	mv	a0,s3
    80003d1c:	f03fe0ef          	jal	80002c1e <brelse>
    brelse(to);
    80003d20:	8526                	mv	a0,s1
    80003d22:	efdfe0ef          	jal	80002c1e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d26:	2905                	addiw	s2,s2,1
    80003d28:	0a91                	addi	s5,s5,4
    80003d2a:	028a2783          	lw	a5,40(s4)
    80003d2e:	faf94ae3          	blt	s2,a5,80003ce2 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003d32:	cf9ff0ef          	jal	80003a2a <write_head>
    install_trans(0); // Now install writes to home locations
    80003d36:	4501                	li	a0,0
    80003d38:	d51ff0ef          	jal	80003a88 <install_trans>
    log.lh.n = 0;
    80003d3c:	0001e797          	auipc	a5,0x1e
    80003d40:	5607aa23          	sw	zero,1396(a5) # 800222b0 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003d44:	ce7ff0ef          	jal	80003a2a <write_head>
    80003d48:	69e2                	ld	s3,24(sp)
    80003d4a:	6a42                	ld	s4,16(sp)
    80003d4c:	6aa2                	ld	s5,8(sp)
    80003d4e:	b735                	j	80003c7a <end_op+0x44>

0000000080003d50 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003d50:	1101                	addi	sp,sp,-32
    80003d52:	ec06                	sd	ra,24(sp)
    80003d54:	e822                	sd	s0,16(sp)
    80003d56:	e426                	sd	s1,8(sp)
    80003d58:	e04a                	sd	s2,0(sp)
    80003d5a:	1000                	addi	s0,sp,32
    80003d5c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003d5e:	0001e917          	auipc	s2,0x1e
    80003d62:	52a90913          	addi	s2,s2,1322 # 80022288 <log>
    80003d66:	854a                	mv	a0,s2
    80003d68:	e67fc0ef          	jal	80000bce <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003d6c:	02892603          	lw	a2,40(s2)
    80003d70:	47f5                	li	a5,29
    80003d72:	04c7cc63          	blt	a5,a2,80003dca <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003d76:	0001e797          	auipc	a5,0x1e
    80003d7a:	52e7a783          	lw	a5,1326(a5) # 800222a4 <log+0x1c>
    80003d7e:	04f05c63          	blez	a5,80003dd6 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003d82:	4781                	li	a5,0
    80003d84:	04c05f63          	blez	a2,80003de2 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003d88:	44cc                	lw	a1,12(s1)
    80003d8a:	0001e717          	auipc	a4,0x1e
    80003d8e:	52a70713          	addi	a4,a4,1322 # 800222b4 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003d92:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003d94:	4314                	lw	a3,0(a4)
    80003d96:	04b68663          	beq	a3,a1,80003de2 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003d9a:	2785                	addiw	a5,a5,1
    80003d9c:	0711                	addi	a4,a4,4
    80003d9e:	fef61be3          	bne	a2,a5,80003d94 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003da2:	0621                	addi	a2,a2,8
    80003da4:	060a                	slli	a2,a2,0x2
    80003da6:	0001e797          	auipc	a5,0x1e
    80003daa:	4e278793          	addi	a5,a5,1250 # 80022288 <log>
    80003dae:	97b2                	add	a5,a5,a2
    80003db0:	44d8                	lw	a4,12(s1)
    80003db2:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003db4:	8526                	mv	a0,s1
    80003db6:	ef1fe0ef          	jal	80002ca6 <bpin>
    log.lh.n++;
    80003dba:	0001e717          	auipc	a4,0x1e
    80003dbe:	4ce70713          	addi	a4,a4,1230 # 80022288 <log>
    80003dc2:	571c                	lw	a5,40(a4)
    80003dc4:	2785                	addiw	a5,a5,1
    80003dc6:	d71c                	sw	a5,40(a4)
    80003dc8:	a80d                	j	80003dfa <log_write+0xaa>
    panic("too big a transaction");
    80003dca:	00003517          	auipc	a0,0x3
    80003dce:	74650513          	addi	a0,a0,1862 # 80007510 <etext+0x510>
    80003dd2:	a0ffc0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    80003dd6:	00003517          	auipc	a0,0x3
    80003dda:	75250513          	addi	a0,a0,1874 # 80007528 <etext+0x528>
    80003dde:	a03fc0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    80003de2:	00878693          	addi	a3,a5,8
    80003de6:	068a                	slli	a3,a3,0x2
    80003de8:	0001e717          	auipc	a4,0x1e
    80003dec:	4a070713          	addi	a4,a4,1184 # 80022288 <log>
    80003df0:	9736                	add	a4,a4,a3
    80003df2:	44d4                	lw	a3,12(s1)
    80003df4:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003df6:	faf60fe3          	beq	a2,a5,80003db4 <log_write+0x64>
  }
  release(&log.lock);
    80003dfa:	0001e517          	auipc	a0,0x1e
    80003dfe:	48e50513          	addi	a0,a0,1166 # 80022288 <log>
    80003e02:	e65fc0ef          	jal	80000c66 <release>
}
    80003e06:	60e2                	ld	ra,24(sp)
    80003e08:	6442                	ld	s0,16(sp)
    80003e0a:	64a2                	ld	s1,8(sp)
    80003e0c:	6902                	ld	s2,0(sp)
    80003e0e:	6105                	addi	sp,sp,32
    80003e10:	8082                	ret

0000000080003e12 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003e12:	1101                	addi	sp,sp,-32
    80003e14:	ec06                	sd	ra,24(sp)
    80003e16:	e822                	sd	s0,16(sp)
    80003e18:	e426                	sd	s1,8(sp)
    80003e1a:	e04a                	sd	s2,0(sp)
    80003e1c:	1000                	addi	s0,sp,32
    80003e1e:	84aa                	mv	s1,a0
    80003e20:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003e22:	00003597          	auipc	a1,0x3
    80003e26:	72658593          	addi	a1,a1,1830 # 80007548 <etext+0x548>
    80003e2a:	0521                	addi	a0,a0,8
    80003e2c:	d23fc0ef          	jal	80000b4e <initlock>
  lk->name = name;
    80003e30:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003e34:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003e38:	0204a423          	sw	zero,40(s1)
}
    80003e3c:	60e2                	ld	ra,24(sp)
    80003e3e:	6442                	ld	s0,16(sp)
    80003e40:	64a2                	ld	s1,8(sp)
    80003e42:	6902                	ld	s2,0(sp)
    80003e44:	6105                	addi	sp,sp,32
    80003e46:	8082                	ret

0000000080003e48 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003e48:	1101                	addi	sp,sp,-32
    80003e4a:	ec06                	sd	ra,24(sp)
    80003e4c:	e822                	sd	s0,16(sp)
    80003e4e:	e426                	sd	s1,8(sp)
    80003e50:	e04a                	sd	s2,0(sp)
    80003e52:	1000                	addi	s0,sp,32
    80003e54:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003e56:	00850913          	addi	s2,a0,8
    80003e5a:	854a                	mv	a0,s2
    80003e5c:	d73fc0ef          	jal	80000bce <acquire>
  while (lk->locked) {
    80003e60:	409c                	lw	a5,0(s1)
    80003e62:	c799                	beqz	a5,80003e70 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003e64:	85ca                	mv	a1,s2
    80003e66:	8526                	mv	a0,s1
    80003e68:	870fe0ef          	jal	80001ed8 <sleep>
  while (lk->locked) {
    80003e6c:	409c                	lw	a5,0(s1)
    80003e6e:	fbfd                	bnez	a5,80003e64 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003e70:	4785                	li	a5,1
    80003e72:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003e74:	a5bfd0ef          	jal	800018ce <myproc>
    80003e78:	591c                	lw	a5,48(a0)
    80003e7a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003e7c:	854a                	mv	a0,s2
    80003e7e:	de9fc0ef          	jal	80000c66 <release>
}
    80003e82:	60e2                	ld	ra,24(sp)
    80003e84:	6442                	ld	s0,16(sp)
    80003e86:	64a2                	ld	s1,8(sp)
    80003e88:	6902                	ld	s2,0(sp)
    80003e8a:	6105                	addi	sp,sp,32
    80003e8c:	8082                	ret

0000000080003e8e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003e8e:	1101                	addi	sp,sp,-32
    80003e90:	ec06                	sd	ra,24(sp)
    80003e92:	e822                	sd	s0,16(sp)
    80003e94:	e426                	sd	s1,8(sp)
    80003e96:	e04a                	sd	s2,0(sp)
    80003e98:	1000                	addi	s0,sp,32
    80003e9a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003e9c:	00850913          	addi	s2,a0,8
    80003ea0:	854a                	mv	a0,s2
    80003ea2:	d2dfc0ef          	jal	80000bce <acquire>
  lk->locked = 0;
    80003ea6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003eaa:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003eae:	8526                	mv	a0,s1
    80003eb0:	874fe0ef          	jal	80001f24 <wakeup>
  release(&lk->lk);
    80003eb4:	854a                	mv	a0,s2
    80003eb6:	db1fc0ef          	jal	80000c66 <release>
}
    80003eba:	60e2                	ld	ra,24(sp)
    80003ebc:	6442                	ld	s0,16(sp)
    80003ebe:	64a2                	ld	s1,8(sp)
    80003ec0:	6902                	ld	s2,0(sp)
    80003ec2:	6105                	addi	sp,sp,32
    80003ec4:	8082                	ret

0000000080003ec6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003ec6:	7179                	addi	sp,sp,-48
    80003ec8:	f406                	sd	ra,40(sp)
    80003eca:	f022                	sd	s0,32(sp)
    80003ecc:	ec26                	sd	s1,24(sp)
    80003ece:	e84a                	sd	s2,16(sp)
    80003ed0:	1800                	addi	s0,sp,48
    80003ed2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003ed4:	00850913          	addi	s2,a0,8
    80003ed8:	854a                	mv	a0,s2
    80003eda:	cf5fc0ef          	jal	80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003ede:	409c                	lw	a5,0(s1)
    80003ee0:	ef81                	bnez	a5,80003ef8 <holdingsleep+0x32>
    80003ee2:	4481                	li	s1,0
  release(&lk->lk);
    80003ee4:	854a                	mv	a0,s2
    80003ee6:	d81fc0ef          	jal	80000c66 <release>
  return r;
}
    80003eea:	8526                	mv	a0,s1
    80003eec:	70a2                	ld	ra,40(sp)
    80003eee:	7402                	ld	s0,32(sp)
    80003ef0:	64e2                	ld	s1,24(sp)
    80003ef2:	6942                	ld	s2,16(sp)
    80003ef4:	6145                	addi	sp,sp,48
    80003ef6:	8082                	ret
    80003ef8:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003efa:	0284a983          	lw	s3,40(s1)
    80003efe:	9d1fd0ef          	jal	800018ce <myproc>
    80003f02:	5904                	lw	s1,48(a0)
    80003f04:	413484b3          	sub	s1,s1,s3
    80003f08:	0014b493          	seqz	s1,s1
    80003f0c:	69a2                	ld	s3,8(sp)
    80003f0e:	bfd9                	j	80003ee4 <holdingsleep+0x1e>

0000000080003f10 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003f10:	1141                	addi	sp,sp,-16
    80003f12:	e406                	sd	ra,8(sp)
    80003f14:	e022                	sd	s0,0(sp)
    80003f16:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003f18:	00003597          	auipc	a1,0x3
    80003f1c:	64058593          	addi	a1,a1,1600 # 80007558 <etext+0x558>
    80003f20:	0001e517          	auipc	a0,0x1e
    80003f24:	4b050513          	addi	a0,a0,1200 # 800223d0 <ftable>
    80003f28:	c27fc0ef          	jal	80000b4e <initlock>
}
    80003f2c:	60a2                	ld	ra,8(sp)
    80003f2e:	6402                	ld	s0,0(sp)
    80003f30:	0141                	addi	sp,sp,16
    80003f32:	8082                	ret

0000000080003f34 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003f34:	1101                	addi	sp,sp,-32
    80003f36:	ec06                	sd	ra,24(sp)
    80003f38:	e822                	sd	s0,16(sp)
    80003f3a:	e426                	sd	s1,8(sp)
    80003f3c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003f3e:	0001e517          	auipc	a0,0x1e
    80003f42:	49250513          	addi	a0,a0,1170 # 800223d0 <ftable>
    80003f46:	c89fc0ef          	jal	80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f4a:	0001e497          	auipc	s1,0x1e
    80003f4e:	49e48493          	addi	s1,s1,1182 # 800223e8 <ftable+0x18>
    80003f52:	0001f717          	auipc	a4,0x1f
    80003f56:	43670713          	addi	a4,a4,1078 # 80023388 <disk>
    if(f->ref == 0){
    80003f5a:	40dc                	lw	a5,4(s1)
    80003f5c:	cf89                	beqz	a5,80003f76 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f5e:	02848493          	addi	s1,s1,40
    80003f62:	fee49ce3          	bne	s1,a4,80003f5a <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003f66:	0001e517          	auipc	a0,0x1e
    80003f6a:	46a50513          	addi	a0,a0,1130 # 800223d0 <ftable>
    80003f6e:	cf9fc0ef          	jal	80000c66 <release>
  return 0;
    80003f72:	4481                	li	s1,0
    80003f74:	a809                	j	80003f86 <filealloc+0x52>
      f->ref = 1;
    80003f76:	4785                	li	a5,1
    80003f78:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003f7a:	0001e517          	auipc	a0,0x1e
    80003f7e:	45650513          	addi	a0,a0,1110 # 800223d0 <ftable>
    80003f82:	ce5fc0ef          	jal	80000c66 <release>
}
    80003f86:	8526                	mv	a0,s1
    80003f88:	60e2                	ld	ra,24(sp)
    80003f8a:	6442                	ld	s0,16(sp)
    80003f8c:	64a2                	ld	s1,8(sp)
    80003f8e:	6105                	addi	sp,sp,32
    80003f90:	8082                	ret

0000000080003f92 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003f92:	1101                	addi	sp,sp,-32
    80003f94:	ec06                	sd	ra,24(sp)
    80003f96:	e822                	sd	s0,16(sp)
    80003f98:	e426                	sd	s1,8(sp)
    80003f9a:	1000                	addi	s0,sp,32
    80003f9c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003f9e:	0001e517          	auipc	a0,0x1e
    80003fa2:	43250513          	addi	a0,a0,1074 # 800223d0 <ftable>
    80003fa6:	c29fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80003faa:	40dc                	lw	a5,4(s1)
    80003fac:	02f05063          	blez	a5,80003fcc <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003fb0:	2785                	addiw	a5,a5,1
    80003fb2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003fb4:	0001e517          	auipc	a0,0x1e
    80003fb8:	41c50513          	addi	a0,a0,1052 # 800223d0 <ftable>
    80003fbc:	cabfc0ef          	jal	80000c66 <release>
  return f;
}
    80003fc0:	8526                	mv	a0,s1
    80003fc2:	60e2                	ld	ra,24(sp)
    80003fc4:	6442                	ld	s0,16(sp)
    80003fc6:	64a2                	ld	s1,8(sp)
    80003fc8:	6105                	addi	sp,sp,32
    80003fca:	8082                	ret
    panic("filedup");
    80003fcc:	00003517          	auipc	a0,0x3
    80003fd0:	59450513          	addi	a0,a0,1428 # 80007560 <etext+0x560>
    80003fd4:	80dfc0ef          	jal	800007e0 <panic>

0000000080003fd8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003fd8:	7139                	addi	sp,sp,-64
    80003fda:	fc06                	sd	ra,56(sp)
    80003fdc:	f822                	sd	s0,48(sp)
    80003fde:	f426                	sd	s1,40(sp)
    80003fe0:	0080                	addi	s0,sp,64
    80003fe2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003fe4:	0001e517          	auipc	a0,0x1e
    80003fe8:	3ec50513          	addi	a0,a0,1004 # 800223d0 <ftable>
    80003fec:	be3fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80003ff0:	40dc                	lw	a5,4(s1)
    80003ff2:	04f05a63          	blez	a5,80004046 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80003ff6:	37fd                	addiw	a5,a5,-1
    80003ff8:	0007871b          	sext.w	a4,a5
    80003ffc:	c0dc                	sw	a5,4(s1)
    80003ffe:	04e04e63          	bgtz	a4,8000405a <fileclose+0x82>
    80004002:	f04a                	sd	s2,32(sp)
    80004004:	ec4e                	sd	s3,24(sp)
    80004006:	e852                	sd	s4,16(sp)
    80004008:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000400a:	0004a903          	lw	s2,0(s1)
    8000400e:	0094ca83          	lbu	s5,9(s1)
    80004012:	0104ba03          	ld	s4,16(s1)
    80004016:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000401a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000401e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004022:	0001e517          	auipc	a0,0x1e
    80004026:	3ae50513          	addi	a0,a0,942 # 800223d0 <ftable>
    8000402a:	c3dfc0ef          	jal	80000c66 <release>

  if(ff.type == FD_PIPE){
    8000402e:	4785                	li	a5,1
    80004030:	04f90063          	beq	s2,a5,80004070 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004034:	3979                	addiw	s2,s2,-2
    80004036:	4785                	li	a5,1
    80004038:	0527f563          	bgeu	a5,s2,80004082 <fileclose+0xaa>
    8000403c:	7902                	ld	s2,32(sp)
    8000403e:	69e2                	ld	s3,24(sp)
    80004040:	6a42                	ld	s4,16(sp)
    80004042:	6aa2                	ld	s5,8(sp)
    80004044:	a00d                	j	80004066 <fileclose+0x8e>
    80004046:	f04a                	sd	s2,32(sp)
    80004048:	ec4e                	sd	s3,24(sp)
    8000404a:	e852                	sd	s4,16(sp)
    8000404c:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000404e:	00003517          	auipc	a0,0x3
    80004052:	51a50513          	addi	a0,a0,1306 # 80007568 <etext+0x568>
    80004056:	f8afc0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    8000405a:	0001e517          	auipc	a0,0x1e
    8000405e:	37650513          	addi	a0,a0,886 # 800223d0 <ftable>
    80004062:	c05fc0ef          	jal	80000c66 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004066:	70e2                	ld	ra,56(sp)
    80004068:	7442                	ld	s0,48(sp)
    8000406a:	74a2                	ld	s1,40(sp)
    8000406c:	6121                	addi	sp,sp,64
    8000406e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004070:	85d6                	mv	a1,s5
    80004072:	8552                	mv	a0,s4
    80004074:	336000ef          	jal	800043aa <pipeclose>
    80004078:	7902                	ld	s2,32(sp)
    8000407a:	69e2                	ld	s3,24(sp)
    8000407c:	6a42                	ld	s4,16(sp)
    8000407e:	6aa2                	ld	s5,8(sp)
    80004080:	b7dd                	j	80004066 <fileclose+0x8e>
    begin_op();
    80004082:	b4bff0ef          	jal	80003bcc <begin_op>
    iput(ff.ip);
    80004086:	854e                	mv	a0,s3
    80004088:	adcff0ef          	jal	80003364 <iput>
    end_op();
    8000408c:	babff0ef          	jal	80003c36 <end_op>
    80004090:	7902                	ld	s2,32(sp)
    80004092:	69e2                	ld	s3,24(sp)
    80004094:	6a42                	ld	s4,16(sp)
    80004096:	6aa2                	ld	s5,8(sp)
    80004098:	b7f9                	j	80004066 <fileclose+0x8e>

000000008000409a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000409a:	715d                	addi	sp,sp,-80
    8000409c:	e486                	sd	ra,72(sp)
    8000409e:	e0a2                	sd	s0,64(sp)
    800040a0:	fc26                	sd	s1,56(sp)
    800040a2:	f44e                	sd	s3,40(sp)
    800040a4:	0880                	addi	s0,sp,80
    800040a6:	84aa                	mv	s1,a0
    800040a8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800040aa:	825fd0ef          	jal	800018ce <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800040ae:	409c                	lw	a5,0(s1)
    800040b0:	37f9                	addiw	a5,a5,-2
    800040b2:	4705                	li	a4,1
    800040b4:	04f76063          	bltu	a4,a5,800040f4 <filestat+0x5a>
    800040b8:	f84a                	sd	s2,48(sp)
    800040ba:	892a                	mv	s2,a0
    ilock(f->ip);
    800040bc:	6c88                	ld	a0,24(s1)
    800040be:	924ff0ef          	jal	800031e2 <ilock>
    stati(f->ip, &st);
    800040c2:	fb840593          	addi	a1,s0,-72
    800040c6:	6c88                	ld	a0,24(s1)
    800040c8:	c80ff0ef          	jal	80003548 <stati>
    iunlock(f->ip);
    800040cc:	6c88                	ld	a0,24(s1)
    800040ce:	9c2ff0ef          	jal	80003290 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800040d2:	46e1                	li	a3,24
    800040d4:	fb840613          	addi	a2,s0,-72
    800040d8:	85ce                	mv	a1,s3
    800040da:	05093503          	ld	a0,80(s2)
    800040de:	d04fd0ef          	jal	800015e2 <copyout>
    800040e2:	41f5551b          	sraiw	a0,a0,0x1f
    800040e6:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800040e8:	60a6                	ld	ra,72(sp)
    800040ea:	6406                	ld	s0,64(sp)
    800040ec:	74e2                	ld	s1,56(sp)
    800040ee:	79a2                	ld	s3,40(sp)
    800040f0:	6161                	addi	sp,sp,80
    800040f2:	8082                	ret
  return -1;
    800040f4:	557d                	li	a0,-1
    800040f6:	bfcd                	j	800040e8 <filestat+0x4e>

00000000800040f8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800040f8:	7179                	addi	sp,sp,-48
    800040fa:	f406                	sd	ra,40(sp)
    800040fc:	f022                	sd	s0,32(sp)
    800040fe:	e84a                	sd	s2,16(sp)
    80004100:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004102:	00854783          	lbu	a5,8(a0)
    80004106:	cfd1                	beqz	a5,800041a2 <fileread+0xaa>
    80004108:	ec26                	sd	s1,24(sp)
    8000410a:	e44e                	sd	s3,8(sp)
    8000410c:	84aa                	mv	s1,a0
    8000410e:	89ae                	mv	s3,a1
    80004110:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004112:	411c                	lw	a5,0(a0)
    80004114:	4705                	li	a4,1
    80004116:	04e78363          	beq	a5,a4,8000415c <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000411a:	470d                	li	a4,3
    8000411c:	04e78763          	beq	a5,a4,8000416a <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004120:	4709                	li	a4,2
    80004122:	06e79a63          	bne	a5,a4,80004196 <fileread+0x9e>
    ilock(f->ip);
    80004126:	6d08                	ld	a0,24(a0)
    80004128:	8baff0ef          	jal	800031e2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000412c:	874a                	mv	a4,s2
    8000412e:	5094                	lw	a3,32(s1)
    80004130:	864e                	mv	a2,s3
    80004132:	4585                	li	a1,1
    80004134:	6c88                	ld	a0,24(s1)
    80004136:	c3cff0ef          	jal	80003572 <readi>
    8000413a:	892a                	mv	s2,a0
    8000413c:	00a05563          	blez	a0,80004146 <fileread+0x4e>
      f->off += r;
    80004140:	509c                	lw	a5,32(s1)
    80004142:	9fa9                	addw	a5,a5,a0
    80004144:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004146:	6c88                	ld	a0,24(s1)
    80004148:	948ff0ef          	jal	80003290 <iunlock>
    8000414c:	64e2                	ld	s1,24(sp)
    8000414e:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004150:	854a                	mv	a0,s2
    80004152:	70a2                	ld	ra,40(sp)
    80004154:	7402                	ld	s0,32(sp)
    80004156:	6942                	ld	s2,16(sp)
    80004158:	6145                	addi	sp,sp,48
    8000415a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000415c:	6908                	ld	a0,16(a0)
    8000415e:	388000ef          	jal	800044e6 <piperead>
    80004162:	892a                	mv	s2,a0
    80004164:	64e2                	ld	s1,24(sp)
    80004166:	69a2                	ld	s3,8(sp)
    80004168:	b7e5                	j	80004150 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000416a:	02451783          	lh	a5,36(a0)
    8000416e:	03079693          	slli	a3,a5,0x30
    80004172:	92c1                	srli	a3,a3,0x30
    80004174:	4725                	li	a4,9
    80004176:	02d76863          	bltu	a4,a3,800041a6 <fileread+0xae>
    8000417a:	0792                	slli	a5,a5,0x4
    8000417c:	0001e717          	auipc	a4,0x1e
    80004180:	1b470713          	addi	a4,a4,436 # 80022330 <devsw>
    80004184:	97ba                	add	a5,a5,a4
    80004186:	639c                	ld	a5,0(a5)
    80004188:	c39d                	beqz	a5,800041ae <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    8000418a:	4505                	li	a0,1
    8000418c:	9782                	jalr	a5
    8000418e:	892a                	mv	s2,a0
    80004190:	64e2                	ld	s1,24(sp)
    80004192:	69a2                	ld	s3,8(sp)
    80004194:	bf75                	j	80004150 <fileread+0x58>
    panic("fileread");
    80004196:	00003517          	auipc	a0,0x3
    8000419a:	3e250513          	addi	a0,a0,994 # 80007578 <etext+0x578>
    8000419e:	e42fc0ef          	jal	800007e0 <panic>
    return -1;
    800041a2:	597d                	li	s2,-1
    800041a4:	b775                	j	80004150 <fileread+0x58>
      return -1;
    800041a6:	597d                	li	s2,-1
    800041a8:	64e2                	ld	s1,24(sp)
    800041aa:	69a2                	ld	s3,8(sp)
    800041ac:	b755                	j	80004150 <fileread+0x58>
    800041ae:	597d                	li	s2,-1
    800041b0:	64e2                	ld	s1,24(sp)
    800041b2:	69a2                	ld	s3,8(sp)
    800041b4:	bf71                	j	80004150 <fileread+0x58>

00000000800041b6 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800041b6:	00954783          	lbu	a5,9(a0)
    800041ba:	10078b63          	beqz	a5,800042d0 <filewrite+0x11a>
{
    800041be:	715d                	addi	sp,sp,-80
    800041c0:	e486                	sd	ra,72(sp)
    800041c2:	e0a2                	sd	s0,64(sp)
    800041c4:	f84a                	sd	s2,48(sp)
    800041c6:	f052                	sd	s4,32(sp)
    800041c8:	e85a                	sd	s6,16(sp)
    800041ca:	0880                	addi	s0,sp,80
    800041cc:	892a                	mv	s2,a0
    800041ce:	8b2e                	mv	s6,a1
    800041d0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800041d2:	411c                	lw	a5,0(a0)
    800041d4:	4705                	li	a4,1
    800041d6:	02e78763          	beq	a5,a4,80004204 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800041da:	470d                	li	a4,3
    800041dc:	02e78863          	beq	a5,a4,8000420c <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800041e0:	4709                	li	a4,2
    800041e2:	0ce79c63          	bne	a5,a4,800042ba <filewrite+0x104>
    800041e6:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800041e8:	0ac05863          	blez	a2,80004298 <filewrite+0xe2>
    800041ec:	fc26                	sd	s1,56(sp)
    800041ee:	ec56                	sd	s5,24(sp)
    800041f0:	e45e                	sd	s7,8(sp)
    800041f2:	e062                	sd	s8,0(sp)
    int i = 0;
    800041f4:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800041f6:	6b85                	lui	s7,0x1
    800041f8:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800041fc:	6c05                	lui	s8,0x1
    800041fe:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004202:	a8b5                	j	8000427e <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004204:	6908                	ld	a0,16(a0)
    80004206:	1fc000ef          	jal	80004402 <pipewrite>
    8000420a:	a04d                	j	800042ac <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000420c:	02451783          	lh	a5,36(a0)
    80004210:	03079693          	slli	a3,a5,0x30
    80004214:	92c1                	srli	a3,a3,0x30
    80004216:	4725                	li	a4,9
    80004218:	0ad76e63          	bltu	a4,a3,800042d4 <filewrite+0x11e>
    8000421c:	0792                	slli	a5,a5,0x4
    8000421e:	0001e717          	auipc	a4,0x1e
    80004222:	11270713          	addi	a4,a4,274 # 80022330 <devsw>
    80004226:	97ba                	add	a5,a5,a4
    80004228:	679c                	ld	a5,8(a5)
    8000422a:	c7dd                	beqz	a5,800042d8 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000422c:	4505                	li	a0,1
    8000422e:	9782                	jalr	a5
    80004230:	a8b5                	j	800042ac <filewrite+0xf6>
      if(n1 > max)
    80004232:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004236:	997ff0ef          	jal	80003bcc <begin_op>
      ilock(f->ip);
    8000423a:	01893503          	ld	a0,24(s2)
    8000423e:	fa5fe0ef          	jal	800031e2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004242:	8756                	mv	a4,s5
    80004244:	02092683          	lw	a3,32(s2)
    80004248:	01698633          	add	a2,s3,s6
    8000424c:	4585                	li	a1,1
    8000424e:	01893503          	ld	a0,24(s2)
    80004252:	c1cff0ef          	jal	8000366e <writei>
    80004256:	84aa                	mv	s1,a0
    80004258:	00a05763          	blez	a0,80004266 <filewrite+0xb0>
        f->off += r;
    8000425c:	02092783          	lw	a5,32(s2)
    80004260:	9fa9                	addw	a5,a5,a0
    80004262:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004266:	01893503          	ld	a0,24(s2)
    8000426a:	826ff0ef          	jal	80003290 <iunlock>
      end_op();
    8000426e:	9c9ff0ef          	jal	80003c36 <end_op>

      if(r != n1){
    80004272:	029a9563          	bne	s5,s1,8000429c <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004276:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000427a:	0149da63          	bge	s3,s4,8000428e <filewrite+0xd8>
      int n1 = n - i;
    8000427e:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004282:	0004879b          	sext.w	a5,s1
    80004286:	fafbd6e3          	bge	s7,a5,80004232 <filewrite+0x7c>
    8000428a:	84e2                	mv	s1,s8
    8000428c:	b75d                	j	80004232 <filewrite+0x7c>
    8000428e:	74e2                	ld	s1,56(sp)
    80004290:	6ae2                	ld	s5,24(sp)
    80004292:	6ba2                	ld	s7,8(sp)
    80004294:	6c02                	ld	s8,0(sp)
    80004296:	a039                	j	800042a4 <filewrite+0xee>
    int i = 0;
    80004298:	4981                	li	s3,0
    8000429a:	a029                	j	800042a4 <filewrite+0xee>
    8000429c:	74e2                	ld	s1,56(sp)
    8000429e:	6ae2                	ld	s5,24(sp)
    800042a0:	6ba2                	ld	s7,8(sp)
    800042a2:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    800042a4:	033a1c63          	bne	s4,s3,800042dc <filewrite+0x126>
    800042a8:	8552                	mv	a0,s4
    800042aa:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800042ac:	60a6                	ld	ra,72(sp)
    800042ae:	6406                	ld	s0,64(sp)
    800042b0:	7942                	ld	s2,48(sp)
    800042b2:	7a02                	ld	s4,32(sp)
    800042b4:	6b42                	ld	s6,16(sp)
    800042b6:	6161                	addi	sp,sp,80
    800042b8:	8082                	ret
    800042ba:	fc26                	sd	s1,56(sp)
    800042bc:	f44e                	sd	s3,40(sp)
    800042be:	ec56                	sd	s5,24(sp)
    800042c0:	e45e                	sd	s7,8(sp)
    800042c2:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800042c4:	00003517          	auipc	a0,0x3
    800042c8:	2c450513          	addi	a0,a0,708 # 80007588 <etext+0x588>
    800042cc:	d14fc0ef          	jal	800007e0 <panic>
    return -1;
    800042d0:	557d                	li	a0,-1
}
    800042d2:	8082                	ret
      return -1;
    800042d4:	557d                	li	a0,-1
    800042d6:	bfd9                	j	800042ac <filewrite+0xf6>
    800042d8:	557d                	li	a0,-1
    800042da:	bfc9                	j	800042ac <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800042dc:	557d                	li	a0,-1
    800042de:	79a2                	ld	s3,40(sp)
    800042e0:	b7f1                	j	800042ac <filewrite+0xf6>

00000000800042e2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800042e2:	7179                	addi	sp,sp,-48
    800042e4:	f406                	sd	ra,40(sp)
    800042e6:	f022                	sd	s0,32(sp)
    800042e8:	ec26                	sd	s1,24(sp)
    800042ea:	e052                	sd	s4,0(sp)
    800042ec:	1800                	addi	s0,sp,48
    800042ee:	84aa                	mv	s1,a0
    800042f0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800042f2:	0005b023          	sd	zero,0(a1)
    800042f6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800042fa:	c3bff0ef          	jal	80003f34 <filealloc>
    800042fe:	e088                	sd	a0,0(s1)
    80004300:	c549                	beqz	a0,8000438a <pipealloc+0xa8>
    80004302:	c33ff0ef          	jal	80003f34 <filealloc>
    80004306:	00aa3023          	sd	a0,0(s4)
    8000430a:	cd25                	beqz	a0,80004382 <pipealloc+0xa0>
    8000430c:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000430e:	ff0fc0ef          	jal	80000afe <kalloc>
    80004312:	892a                	mv	s2,a0
    80004314:	c12d                	beqz	a0,80004376 <pipealloc+0x94>
    80004316:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004318:	4985                	li	s3,1
    8000431a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000431e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004322:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004326:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000432a:	00003597          	auipc	a1,0x3
    8000432e:	26e58593          	addi	a1,a1,622 # 80007598 <etext+0x598>
    80004332:	81dfc0ef          	jal	80000b4e <initlock>
  (*f0)->type = FD_PIPE;
    80004336:	609c                	ld	a5,0(s1)
    80004338:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000433c:	609c                	ld	a5,0(s1)
    8000433e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004342:	609c                	ld	a5,0(s1)
    80004344:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004348:	609c                	ld	a5,0(s1)
    8000434a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000434e:	000a3783          	ld	a5,0(s4)
    80004352:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004356:	000a3783          	ld	a5,0(s4)
    8000435a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000435e:	000a3783          	ld	a5,0(s4)
    80004362:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004366:	000a3783          	ld	a5,0(s4)
    8000436a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000436e:	4501                	li	a0,0
    80004370:	6942                	ld	s2,16(sp)
    80004372:	69a2                	ld	s3,8(sp)
    80004374:	a01d                	j	8000439a <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004376:	6088                	ld	a0,0(s1)
    80004378:	c119                	beqz	a0,8000437e <pipealloc+0x9c>
    8000437a:	6942                	ld	s2,16(sp)
    8000437c:	a029                	j	80004386 <pipealloc+0xa4>
    8000437e:	6942                	ld	s2,16(sp)
    80004380:	a029                	j	8000438a <pipealloc+0xa8>
    80004382:	6088                	ld	a0,0(s1)
    80004384:	c10d                	beqz	a0,800043a6 <pipealloc+0xc4>
    fileclose(*f0);
    80004386:	c53ff0ef          	jal	80003fd8 <fileclose>
  if(*f1)
    8000438a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000438e:	557d                	li	a0,-1
  if(*f1)
    80004390:	c789                	beqz	a5,8000439a <pipealloc+0xb8>
    fileclose(*f1);
    80004392:	853e                	mv	a0,a5
    80004394:	c45ff0ef          	jal	80003fd8 <fileclose>
  return -1;
    80004398:	557d                	li	a0,-1
}
    8000439a:	70a2                	ld	ra,40(sp)
    8000439c:	7402                	ld	s0,32(sp)
    8000439e:	64e2                	ld	s1,24(sp)
    800043a0:	6a02                	ld	s4,0(sp)
    800043a2:	6145                	addi	sp,sp,48
    800043a4:	8082                	ret
  return -1;
    800043a6:	557d                	li	a0,-1
    800043a8:	bfcd                	j	8000439a <pipealloc+0xb8>

00000000800043aa <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800043aa:	1101                	addi	sp,sp,-32
    800043ac:	ec06                	sd	ra,24(sp)
    800043ae:	e822                	sd	s0,16(sp)
    800043b0:	e426                	sd	s1,8(sp)
    800043b2:	e04a                	sd	s2,0(sp)
    800043b4:	1000                	addi	s0,sp,32
    800043b6:	84aa                	mv	s1,a0
    800043b8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800043ba:	815fc0ef          	jal	80000bce <acquire>
  if(writable){
    800043be:	02090763          	beqz	s2,800043ec <pipeclose+0x42>
    pi->writeopen = 0;
    800043c2:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800043c6:	21848513          	addi	a0,s1,536
    800043ca:	b5bfd0ef          	jal	80001f24 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800043ce:	2204b783          	ld	a5,544(s1)
    800043d2:	e785                	bnez	a5,800043fa <pipeclose+0x50>
    release(&pi->lock);
    800043d4:	8526                	mv	a0,s1
    800043d6:	891fc0ef          	jal	80000c66 <release>
    kfree((char*)pi);
    800043da:	8526                	mv	a0,s1
    800043dc:	e40fc0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    800043e0:	60e2                	ld	ra,24(sp)
    800043e2:	6442                	ld	s0,16(sp)
    800043e4:	64a2                	ld	s1,8(sp)
    800043e6:	6902                	ld	s2,0(sp)
    800043e8:	6105                	addi	sp,sp,32
    800043ea:	8082                	ret
    pi->readopen = 0;
    800043ec:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800043f0:	21c48513          	addi	a0,s1,540
    800043f4:	b31fd0ef          	jal	80001f24 <wakeup>
    800043f8:	bfd9                	j	800043ce <pipeclose+0x24>
    release(&pi->lock);
    800043fa:	8526                	mv	a0,s1
    800043fc:	86bfc0ef          	jal	80000c66 <release>
}
    80004400:	b7c5                	j	800043e0 <pipeclose+0x36>

0000000080004402 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004402:	711d                	addi	sp,sp,-96
    80004404:	ec86                	sd	ra,88(sp)
    80004406:	e8a2                	sd	s0,80(sp)
    80004408:	e4a6                	sd	s1,72(sp)
    8000440a:	e0ca                	sd	s2,64(sp)
    8000440c:	fc4e                	sd	s3,56(sp)
    8000440e:	f852                	sd	s4,48(sp)
    80004410:	f456                	sd	s5,40(sp)
    80004412:	1080                	addi	s0,sp,96
    80004414:	84aa                	mv	s1,a0
    80004416:	8aae                	mv	s5,a1
    80004418:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000441a:	cb4fd0ef          	jal	800018ce <myproc>
    8000441e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004420:	8526                	mv	a0,s1
    80004422:	facfc0ef          	jal	80000bce <acquire>
  while(i < n){
    80004426:	0b405a63          	blez	s4,800044da <pipewrite+0xd8>
    8000442a:	f05a                	sd	s6,32(sp)
    8000442c:	ec5e                	sd	s7,24(sp)
    8000442e:	e862                	sd	s8,16(sp)
  int i = 0;
    80004430:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004432:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004434:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004438:	21c48b93          	addi	s7,s1,540
    8000443c:	a81d                	j	80004472 <pipewrite+0x70>
      release(&pi->lock);
    8000443e:	8526                	mv	a0,s1
    80004440:	827fc0ef          	jal	80000c66 <release>
      return -1;
    80004444:	597d                	li	s2,-1
    80004446:	7b02                	ld	s6,32(sp)
    80004448:	6be2                	ld	s7,24(sp)
    8000444a:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000444c:	854a                	mv	a0,s2
    8000444e:	60e6                	ld	ra,88(sp)
    80004450:	6446                	ld	s0,80(sp)
    80004452:	64a6                	ld	s1,72(sp)
    80004454:	6906                	ld	s2,64(sp)
    80004456:	79e2                	ld	s3,56(sp)
    80004458:	7a42                	ld	s4,48(sp)
    8000445a:	7aa2                	ld	s5,40(sp)
    8000445c:	6125                	addi	sp,sp,96
    8000445e:	8082                	ret
      wakeup(&pi->nread);
    80004460:	8562                	mv	a0,s8
    80004462:	ac3fd0ef          	jal	80001f24 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004466:	85a6                	mv	a1,s1
    80004468:	855e                	mv	a0,s7
    8000446a:	a6ffd0ef          	jal	80001ed8 <sleep>
  while(i < n){
    8000446e:	05495b63          	bge	s2,s4,800044c4 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80004472:	2204a783          	lw	a5,544(s1)
    80004476:	d7e1                	beqz	a5,8000443e <pipewrite+0x3c>
    80004478:	854e                	mv	a0,s3
    8000447a:	c97fd0ef          	jal	80002110 <killed>
    8000447e:	f161                	bnez	a0,8000443e <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004480:	2184a783          	lw	a5,536(s1)
    80004484:	21c4a703          	lw	a4,540(s1)
    80004488:	2007879b          	addiw	a5,a5,512
    8000448c:	fcf70ae3          	beq	a4,a5,80004460 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004490:	4685                	li	a3,1
    80004492:	01590633          	add	a2,s2,s5
    80004496:	faf40593          	addi	a1,s0,-81
    8000449a:	0509b503          	ld	a0,80(s3)
    8000449e:	a28fd0ef          	jal	800016c6 <copyin>
    800044a2:	03650e63          	beq	a0,s6,800044de <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800044a6:	21c4a783          	lw	a5,540(s1)
    800044aa:	0017871b          	addiw	a4,a5,1
    800044ae:	20e4ae23          	sw	a4,540(s1)
    800044b2:	1ff7f793          	andi	a5,a5,511
    800044b6:	97a6                	add	a5,a5,s1
    800044b8:	faf44703          	lbu	a4,-81(s0)
    800044bc:	00e78c23          	sb	a4,24(a5)
      i++;
    800044c0:	2905                	addiw	s2,s2,1
    800044c2:	b775                	j	8000446e <pipewrite+0x6c>
    800044c4:	7b02                	ld	s6,32(sp)
    800044c6:	6be2                	ld	s7,24(sp)
    800044c8:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800044ca:	21848513          	addi	a0,s1,536
    800044ce:	a57fd0ef          	jal	80001f24 <wakeup>
  release(&pi->lock);
    800044d2:	8526                	mv	a0,s1
    800044d4:	f92fc0ef          	jal	80000c66 <release>
  return i;
    800044d8:	bf95                	j	8000444c <pipewrite+0x4a>
  int i = 0;
    800044da:	4901                	li	s2,0
    800044dc:	b7fd                	j	800044ca <pipewrite+0xc8>
    800044de:	7b02                	ld	s6,32(sp)
    800044e0:	6be2                	ld	s7,24(sp)
    800044e2:	6c42                	ld	s8,16(sp)
    800044e4:	b7dd                	j	800044ca <pipewrite+0xc8>

00000000800044e6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800044e6:	715d                	addi	sp,sp,-80
    800044e8:	e486                	sd	ra,72(sp)
    800044ea:	e0a2                	sd	s0,64(sp)
    800044ec:	fc26                	sd	s1,56(sp)
    800044ee:	f84a                	sd	s2,48(sp)
    800044f0:	f44e                	sd	s3,40(sp)
    800044f2:	f052                	sd	s4,32(sp)
    800044f4:	ec56                	sd	s5,24(sp)
    800044f6:	0880                	addi	s0,sp,80
    800044f8:	84aa                	mv	s1,a0
    800044fa:	892e                	mv	s2,a1
    800044fc:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800044fe:	bd0fd0ef          	jal	800018ce <myproc>
    80004502:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004504:	8526                	mv	a0,s1
    80004506:	ec8fc0ef          	jal	80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000450a:	2184a703          	lw	a4,536(s1)
    8000450e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004512:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004516:	02f71563          	bne	a4,a5,80004540 <piperead+0x5a>
    8000451a:	2244a783          	lw	a5,548(s1)
    8000451e:	cb85                	beqz	a5,8000454e <piperead+0x68>
    if(killed(pr)){
    80004520:	8552                	mv	a0,s4
    80004522:	beffd0ef          	jal	80002110 <killed>
    80004526:	ed19                	bnez	a0,80004544 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004528:	85a6                	mv	a1,s1
    8000452a:	854e                	mv	a0,s3
    8000452c:	9adfd0ef          	jal	80001ed8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004530:	2184a703          	lw	a4,536(s1)
    80004534:	21c4a783          	lw	a5,540(s1)
    80004538:	fef701e3          	beq	a4,a5,8000451a <piperead+0x34>
    8000453c:	e85a                	sd	s6,16(sp)
    8000453e:	a809                	j	80004550 <piperead+0x6a>
    80004540:	e85a                	sd	s6,16(sp)
    80004542:	a039                	j	80004550 <piperead+0x6a>
      release(&pi->lock);
    80004544:	8526                	mv	a0,s1
    80004546:	f20fc0ef          	jal	80000c66 <release>
      return -1;
    8000454a:	59fd                	li	s3,-1
    8000454c:	a8b9                	j	800045aa <piperead+0xc4>
    8000454e:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004550:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004552:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004554:	05505363          	blez	s5,8000459a <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004558:	2184a783          	lw	a5,536(s1)
    8000455c:	21c4a703          	lw	a4,540(s1)
    80004560:	02f70d63          	beq	a4,a5,8000459a <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    80004564:	1ff7f793          	andi	a5,a5,511
    80004568:	97a6                	add	a5,a5,s1
    8000456a:	0187c783          	lbu	a5,24(a5)
    8000456e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004572:	4685                	li	a3,1
    80004574:	fbf40613          	addi	a2,s0,-65
    80004578:	85ca                	mv	a1,s2
    8000457a:	050a3503          	ld	a0,80(s4)
    8000457e:	864fd0ef          	jal	800015e2 <copyout>
    80004582:	03650e63          	beq	a0,s6,800045be <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004586:	2184a783          	lw	a5,536(s1)
    8000458a:	2785                	addiw	a5,a5,1
    8000458c:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004590:	2985                	addiw	s3,s3,1
    80004592:	0905                	addi	s2,s2,1
    80004594:	fd3a92e3          	bne	s5,s3,80004558 <piperead+0x72>
    80004598:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000459a:	21c48513          	addi	a0,s1,540
    8000459e:	987fd0ef          	jal	80001f24 <wakeup>
  release(&pi->lock);
    800045a2:	8526                	mv	a0,s1
    800045a4:	ec2fc0ef          	jal	80000c66 <release>
    800045a8:	6b42                	ld	s6,16(sp)
  return i;
}
    800045aa:	854e                	mv	a0,s3
    800045ac:	60a6                	ld	ra,72(sp)
    800045ae:	6406                	ld	s0,64(sp)
    800045b0:	74e2                	ld	s1,56(sp)
    800045b2:	7942                	ld	s2,48(sp)
    800045b4:	79a2                	ld	s3,40(sp)
    800045b6:	7a02                	ld	s4,32(sp)
    800045b8:	6ae2                	ld	s5,24(sp)
    800045ba:	6161                	addi	sp,sp,80
    800045bc:	8082                	ret
      if(i == 0)
    800045be:	fc099ee3          	bnez	s3,8000459a <piperead+0xb4>
        i = -1;
    800045c2:	89aa                	mv	s3,a0
    800045c4:	bfd9                	j	8000459a <piperead+0xb4>

00000000800045c6 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800045c6:	1141                	addi	sp,sp,-16
    800045c8:	e422                	sd	s0,8(sp)
    800045ca:	0800                	addi	s0,sp,16
    800045cc:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800045ce:	8905                	andi	a0,a0,1
    800045d0:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800045d2:	8b89                	andi	a5,a5,2
    800045d4:	c399                	beqz	a5,800045da <flags2perm+0x14>
      perm |= PTE_W;
    800045d6:	00456513          	ori	a0,a0,4
    return perm;
}
    800045da:	6422                	ld	s0,8(sp)
    800045dc:	0141                	addi	sp,sp,16
    800045de:	8082                	ret

00000000800045e0 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800045e0:	df010113          	addi	sp,sp,-528
    800045e4:	20113423          	sd	ra,520(sp)
    800045e8:	20813023          	sd	s0,512(sp)
    800045ec:	ffa6                	sd	s1,504(sp)
    800045ee:	fbca                	sd	s2,496(sp)
    800045f0:	0c00                	addi	s0,sp,528
    800045f2:	892a                	mv	s2,a0
    800045f4:	dea43c23          	sd	a0,-520(s0)
    800045f8:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800045fc:	ad2fd0ef          	jal	800018ce <myproc>
    80004600:	84aa                	mv	s1,a0

  begin_op();
    80004602:	dcaff0ef          	jal	80003bcc <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004606:	854a                	mv	a0,s2
    80004608:	bf0ff0ef          	jal	800039f8 <namei>
    8000460c:	c931                	beqz	a0,80004660 <kexec+0x80>
    8000460e:	f3d2                	sd	s4,480(sp)
    80004610:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004612:	bd1fe0ef          	jal	800031e2 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004616:	04000713          	li	a4,64
    8000461a:	4681                	li	a3,0
    8000461c:	e5040613          	addi	a2,s0,-432
    80004620:	4581                	li	a1,0
    80004622:	8552                	mv	a0,s4
    80004624:	f4ffe0ef          	jal	80003572 <readi>
    80004628:	04000793          	li	a5,64
    8000462c:	00f51a63          	bne	a0,a5,80004640 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004630:	e5042703          	lw	a4,-432(s0)
    80004634:	464c47b7          	lui	a5,0x464c4
    80004638:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000463c:	02f70663          	beq	a4,a5,80004668 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004640:	8552                	mv	a0,s4
    80004642:	dabfe0ef          	jal	800033ec <iunlockput>
    end_op();
    80004646:	df0ff0ef          	jal	80003c36 <end_op>
  }
  return -1;
    8000464a:	557d                	li	a0,-1
    8000464c:	7a1e                	ld	s4,480(sp)
}
    8000464e:	20813083          	ld	ra,520(sp)
    80004652:	20013403          	ld	s0,512(sp)
    80004656:	74fe                	ld	s1,504(sp)
    80004658:	795e                	ld	s2,496(sp)
    8000465a:	21010113          	addi	sp,sp,528
    8000465e:	8082                	ret
    end_op();
    80004660:	dd6ff0ef          	jal	80003c36 <end_op>
    return -1;
    80004664:	557d                	li	a0,-1
    80004666:	b7e5                	j	8000464e <kexec+0x6e>
    80004668:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000466a:	8526                	mv	a0,s1
    8000466c:	b68fd0ef          	jal	800019d4 <proc_pagetable>
    80004670:	8b2a                	mv	s6,a0
    80004672:	2c050b63          	beqz	a0,80004948 <kexec+0x368>
    80004676:	f7ce                	sd	s3,488(sp)
    80004678:	efd6                	sd	s5,472(sp)
    8000467a:	e7de                	sd	s7,456(sp)
    8000467c:	e3e2                	sd	s8,448(sp)
    8000467e:	ff66                	sd	s9,440(sp)
    80004680:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004682:	e7042d03          	lw	s10,-400(s0)
    80004686:	e8845783          	lhu	a5,-376(s0)
    8000468a:	12078963          	beqz	a5,800047bc <kexec+0x1dc>
    8000468e:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004690:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004692:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004694:	6c85                	lui	s9,0x1
    80004696:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000469a:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000469e:	6a85                	lui	s5,0x1
    800046a0:	a085                	j	80004700 <kexec+0x120>
      panic("loadseg: address should exist");
    800046a2:	00003517          	auipc	a0,0x3
    800046a6:	efe50513          	addi	a0,a0,-258 # 800075a0 <etext+0x5a0>
    800046aa:	936fc0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    800046ae:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800046b0:	8726                	mv	a4,s1
    800046b2:	012c06bb          	addw	a3,s8,s2
    800046b6:	4581                	li	a1,0
    800046b8:	8552                	mv	a0,s4
    800046ba:	eb9fe0ef          	jal	80003572 <readi>
    800046be:	2501                	sext.w	a0,a0
    800046c0:	24a49a63          	bne	s1,a0,80004914 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    800046c4:	012a893b          	addw	s2,s5,s2
    800046c8:	03397363          	bgeu	s2,s3,800046ee <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800046cc:	02091593          	slli	a1,s2,0x20
    800046d0:	9181                	srli	a1,a1,0x20
    800046d2:	95de                	add	a1,a1,s7
    800046d4:	855a                	mv	a0,s6
    800046d6:	8dbfc0ef          	jal	80000fb0 <walkaddr>
    800046da:	862a                	mv	a2,a0
    if(pa == 0)
    800046dc:	d179                	beqz	a0,800046a2 <kexec+0xc2>
    if(sz - i < PGSIZE)
    800046de:	412984bb          	subw	s1,s3,s2
    800046e2:	0004879b          	sext.w	a5,s1
    800046e6:	fcfcf4e3          	bgeu	s9,a5,800046ae <kexec+0xce>
    800046ea:	84d6                	mv	s1,s5
    800046ec:	b7c9                	j	800046ae <kexec+0xce>
    sz = sz1;
    800046ee:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800046f2:	2d85                	addiw	s11,s11,1
    800046f4:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    800046f8:	e8845783          	lhu	a5,-376(s0)
    800046fc:	08fdd063          	bge	s11,a5,8000477c <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004700:	2d01                	sext.w	s10,s10
    80004702:	03800713          	li	a4,56
    80004706:	86ea                	mv	a3,s10
    80004708:	e1840613          	addi	a2,s0,-488
    8000470c:	4581                	li	a1,0
    8000470e:	8552                	mv	a0,s4
    80004710:	e63fe0ef          	jal	80003572 <readi>
    80004714:	03800793          	li	a5,56
    80004718:	1cf51663          	bne	a0,a5,800048e4 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    8000471c:	e1842783          	lw	a5,-488(s0)
    80004720:	4705                	li	a4,1
    80004722:	fce798e3          	bne	a5,a4,800046f2 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80004726:	e4043483          	ld	s1,-448(s0)
    8000472a:	e3843783          	ld	a5,-456(s0)
    8000472e:	1af4ef63          	bltu	s1,a5,800048ec <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004732:	e2843783          	ld	a5,-472(s0)
    80004736:	94be                	add	s1,s1,a5
    80004738:	1af4ee63          	bltu	s1,a5,800048f4 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    8000473c:	df043703          	ld	a4,-528(s0)
    80004740:	8ff9                	and	a5,a5,a4
    80004742:	1a079d63          	bnez	a5,800048fc <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004746:	e1c42503          	lw	a0,-484(s0)
    8000474a:	e7dff0ef          	jal	800045c6 <flags2perm>
    8000474e:	86aa                	mv	a3,a0
    80004750:	8626                	mv	a2,s1
    80004752:	85ca                	mv	a1,s2
    80004754:	855a                	mv	a0,s6
    80004756:	b33fc0ef          	jal	80001288 <uvmalloc>
    8000475a:	e0a43423          	sd	a0,-504(s0)
    8000475e:	1a050363          	beqz	a0,80004904 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004762:	e2843b83          	ld	s7,-472(s0)
    80004766:	e2042c03          	lw	s8,-480(s0)
    8000476a:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000476e:	00098463          	beqz	s3,80004776 <kexec+0x196>
    80004772:	4901                	li	s2,0
    80004774:	bfa1                	j	800046cc <kexec+0xec>
    sz = sz1;
    80004776:	e0843903          	ld	s2,-504(s0)
    8000477a:	bfa5                	j	800046f2 <kexec+0x112>
    8000477c:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    8000477e:	8552                	mv	a0,s4
    80004780:	c6dfe0ef          	jal	800033ec <iunlockput>
  end_op();
    80004784:	cb2ff0ef          	jal	80003c36 <end_op>
  p = myproc();
    80004788:	946fd0ef          	jal	800018ce <myproc>
    8000478c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000478e:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004792:	6985                	lui	s3,0x1
    80004794:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004796:	99ca                	add	s3,s3,s2
    80004798:	77fd                	lui	a5,0xfffff
    8000479a:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000479e:	4691                	li	a3,4
    800047a0:	6609                	lui	a2,0x2
    800047a2:	964e                	add	a2,a2,s3
    800047a4:	85ce                	mv	a1,s3
    800047a6:	855a                	mv	a0,s6
    800047a8:	ae1fc0ef          	jal	80001288 <uvmalloc>
    800047ac:	892a                	mv	s2,a0
    800047ae:	e0a43423          	sd	a0,-504(s0)
    800047b2:	e519                	bnez	a0,800047c0 <kexec+0x1e0>
  if(pagetable)
    800047b4:	e1343423          	sd	s3,-504(s0)
    800047b8:	4a01                	li	s4,0
    800047ba:	aab1                	j	80004916 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800047bc:	4901                	li	s2,0
    800047be:	b7c1                	j	8000477e <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800047c0:	75f9                	lui	a1,0xffffe
    800047c2:	95aa                	add	a1,a1,a0
    800047c4:	855a                	mv	a0,s6
    800047c6:	c99fc0ef          	jal	8000145e <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800047ca:	7bfd                	lui	s7,0xfffff
    800047cc:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800047ce:	e0043783          	ld	a5,-512(s0)
    800047d2:	6388                	ld	a0,0(a5)
    800047d4:	cd39                	beqz	a0,80004832 <kexec+0x252>
    800047d6:	e9040993          	addi	s3,s0,-368
    800047da:	f9040c13          	addi	s8,s0,-112
    800047de:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800047e0:	e32fc0ef          	jal	80000e12 <strlen>
    800047e4:	0015079b          	addiw	a5,a0,1
    800047e8:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800047ec:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800047f0:	11796e63          	bltu	s2,s7,8000490c <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800047f4:	e0043d03          	ld	s10,-512(s0)
    800047f8:	000d3a03          	ld	s4,0(s10)
    800047fc:	8552                	mv	a0,s4
    800047fe:	e14fc0ef          	jal	80000e12 <strlen>
    80004802:	0015069b          	addiw	a3,a0,1
    80004806:	8652                	mv	a2,s4
    80004808:	85ca                	mv	a1,s2
    8000480a:	855a                	mv	a0,s6
    8000480c:	dd7fc0ef          	jal	800015e2 <copyout>
    80004810:	10054063          	bltz	a0,80004910 <kexec+0x330>
    ustack[argc] = sp;
    80004814:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004818:	0485                	addi	s1,s1,1
    8000481a:	008d0793          	addi	a5,s10,8
    8000481e:	e0f43023          	sd	a5,-512(s0)
    80004822:	008d3503          	ld	a0,8(s10)
    80004826:	c909                	beqz	a0,80004838 <kexec+0x258>
    if(argc >= MAXARG)
    80004828:	09a1                	addi	s3,s3,8
    8000482a:	fb899be3          	bne	s3,s8,800047e0 <kexec+0x200>
  ip = 0;
    8000482e:	4a01                	li	s4,0
    80004830:	a0dd                	j	80004916 <kexec+0x336>
  sp = sz;
    80004832:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004836:	4481                	li	s1,0
  ustack[argc] = 0;
    80004838:	00349793          	slli	a5,s1,0x3
    8000483c:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdbac8>
    80004840:	97a2                	add	a5,a5,s0
    80004842:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004846:	00148693          	addi	a3,s1,1
    8000484a:	068e                	slli	a3,a3,0x3
    8000484c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004850:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004854:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004858:	f5796ee3          	bltu	s2,s7,800047b4 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000485c:	e9040613          	addi	a2,s0,-368
    80004860:	85ca                	mv	a1,s2
    80004862:	855a                	mv	a0,s6
    80004864:	d7ffc0ef          	jal	800015e2 <copyout>
    80004868:	0e054263          	bltz	a0,8000494c <kexec+0x36c>
  p->trapframe->a1 = sp;
    8000486c:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004870:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004874:	df843783          	ld	a5,-520(s0)
    80004878:	0007c703          	lbu	a4,0(a5)
    8000487c:	cf11                	beqz	a4,80004898 <kexec+0x2b8>
    8000487e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004880:	02f00693          	li	a3,47
    80004884:	a039                	j	80004892 <kexec+0x2b2>
      last = s+1;
    80004886:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000488a:	0785                	addi	a5,a5,1
    8000488c:	fff7c703          	lbu	a4,-1(a5)
    80004890:	c701                	beqz	a4,80004898 <kexec+0x2b8>
    if(*s == '/')
    80004892:	fed71ce3          	bne	a4,a3,8000488a <kexec+0x2aa>
    80004896:	bfc5                	j	80004886 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004898:	4641                	li	a2,16
    8000489a:	df843583          	ld	a1,-520(s0)
    8000489e:	158a8513          	addi	a0,s5,344
    800048a2:	d3efc0ef          	jal	80000de0 <safestrcpy>
  oldpagetable = p->pagetable;
    800048a6:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800048aa:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800048ae:	e0843783          	ld	a5,-504(s0)
    800048b2:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    800048b6:	058ab783          	ld	a5,88(s5)
    800048ba:	e6843703          	ld	a4,-408(s0)
    800048be:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800048c0:	058ab783          	ld	a5,88(s5)
    800048c4:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800048c8:	85e6                	mv	a1,s9
    800048ca:	98efd0ef          	jal	80001a58 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800048ce:	0004851b          	sext.w	a0,s1
    800048d2:	79be                	ld	s3,488(sp)
    800048d4:	7a1e                	ld	s4,480(sp)
    800048d6:	6afe                	ld	s5,472(sp)
    800048d8:	6b5e                	ld	s6,464(sp)
    800048da:	6bbe                	ld	s7,456(sp)
    800048dc:	6c1e                	ld	s8,448(sp)
    800048de:	7cfa                	ld	s9,440(sp)
    800048e0:	7d5a                	ld	s10,432(sp)
    800048e2:	b3b5                	j	8000464e <kexec+0x6e>
    800048e4:	e1243423          	sd	s2,-504(s0)
    800048e8:	7dba                	ld	s11,424(sp)
    800048ea:	a035                	j	80004916 <kexec+0x336>
    800048ec:	e1243423          	sd	s2,-504(s0)
    800048f0:	7dba                	ld	s11,424(sp)
    800048f2:	a015                	j	80004916 <kexec+0x336>
    800048f4:	e1243423          	sd	s2,-504(s0)
    800048f8:	7dba                	ld	s11,424(sp)
    800048fa:	a831                	j	80004916 <kexec+0x336>
    800048fc:	e1243423          	sd	s2,-504(s0)
    80004900:	7dba                	ld	s11,424(sp)
    80004902:	a811                	j	80004916 <kexec+0x336>
    80004904:	e1243423          	sd	s2,-504(s0)
    80004908:	7dba                	ld	s11,424(sp)
    8000490a:	a031                	j	80004916 <kexec+0x336>
  ip = 0;
    8000490c:	4a01                	li	s4,0
    8000490e:	a021                	j	80004916 <kexec+0x336>
    80004910:	4a01                	li	s4,0
  if(pagetable)
    80004912:	a011                	j	80004916 <kexec+0x336>
    80004914:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004916:	e0843583          	ld	a1,-504(s0)
    8000491a:	855a                	mv	a0,s6
    8000491c:	93cfd0ef          	jal	80001a58 <proc_freepagetable>
  return -1;
    80004920:	557d                	li	a0,-1
  if(ip){
    80004922:	000a1b63          	bnez	s4,80004938 <kexec+0x358>
    80004926:	79be                	ld	s3,488(sp)
    80004928:	7a1e                	ld	s4,480(sp)
    8000492a:	6afe                	ld	s5,472(sp)
    8000492c:	6b5e                	ld	s6,464(sp)
    8000492e:	6bbe                	ld	s7,456(sp)
    80004930:	6c1e                	ld	s8,448(sp)
    80004932:	7cfa                	ld	s9,440(sp)
    80004934:	7d5a                	ld	s10,432(sp)
    80004936:	bb21                	j	8000464e <kexec+0x6e>
    80004938:	79be                	ld	s3,488(sp)
    8000493a:	6afe                	ld	s5,472(sp)
    8000493c:	6b5e                	ld	s6,464(sp)
    8000493e:	6bbe                	ld	s7,456(sp)
    80004940:	6c1e                	ld	s8,448(sp)
    80004942:	7cfa                	ld	s9,440(sp)
    80004944:	7d5a                	ld	s10,432(sp)
    80004946:	b9ed                	j	80004640 <kexec+0x60>
    80004948:	6b5e                	ld	s6,464(sp)
    8000494a:	b9dd                	j	80004640 <kexec+0x60>
  sz = sz1;
    8000494c:	e0843983          	ld	s3,-504(s0)
    80004950:	b595                	j	800047b4 <kexec+0x1d4>

0000000080004952 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004952:	7179                	addi	sp,sp,-48
    80004954:	f406                	sd	ra,40(sp)
    80004956:	f022                	sd	s0,32(sp)
    80004958:	ec26                	sd	s1,24(sp)
    8000495a:	e84a                	sd	s2,16(sp)
    8000495c:	1800                	addi	s0,sp,48
    8000495e:	892e                	mv	s2,a1
    80004960:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004962:	fdc40593          	addi	a1,s0,-36
    80004966:	e77fd0ef          	jal	800027dc <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000496a:	fdc42703          	lw	a4,-36(s0)
    8000496e:	47bd                	li	a5,15
    80004970:	02e7e963          	bltu	a5,a4,800049a2 <argfd+0x50>
    80004974:	f5bfc0ef          	jal	800018ce <myproc>
    80004978:	fdc42703          	lw	a4,-36(s0)
    8000497c:	01a70793          	addi	a5,a4,26
    80004980:	078e                	slli	a5,a5,0x3
    80004982:	953e                	add	a0,a0,a5
    80004984:	611c                	ld	a5,0(a0)
    80004986:	c385                	beqz	a5,800049a6 <argfd+0x54>
    return -1;
  if(pfd)
    80004988:	00090463          	beqz	s2,80004990 <argfd+0x3e>
    *pfd = fd;
    8000498c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004990:	4501                	li	a0,0
  if(pf)
    80004992:	c091                	beqz	s1,80004996 <argfd+0x44>
    *pf = f;
    80004994:	e09c                	sd	a5,0(s1)
}
    80004996:	70a2                	ld	ra,40(sp)
    80004998:	7402                	ld	s0,32(sp)
    8000499a:	64e2                	ld	s1,24(sp)
    8000499c:	6942                	ld	s2,16(sp)
    8000499e:	6145                	addi	sp,sp,48
    800049a0:	8082                	ret
    return -1;
    800049a2:	557d                	li	a0,-1
    800049a4:	bfcd                	j	80004996 <argfd+0x44>
    800049a6:	557d                	li	a0,-1
    800049a8:	b7fd                	j	80004996 <argfd+0x44>

00000000800049aa <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800049aa:	1101                	addi	sp,sp,-32
    800049ac:	ec06                	sd	ra,24(sp)
    800049ae:	e822                	sd	s0,16(sp)
    800049b0:	e426                	sd	s1,8(sp)
    800049b2:	1000                	addi	s0,sp,32
    800049b4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800049b6:	f19fc0ef          	jal	800018ce <myproc>
    800049ba:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800049bc:	0d050793          	addi	a5,a0,208
    800049c0:	4501                	li	a0,0
    800049c2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800049c4:	6398                	ld	a4,0(a5)
    800049c6:	cb19                	beqz	a4,800049dc <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800049c8:	2505                	addiw	a0,a0,1
    800049ca:	07a1                	addi	a5,a5,8
    800049cc:	fed51ce3          	bne	a0,a3,800049c4 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800049d0:	557d                	li	a0,-1
}
    800049d2:	60e2                	ld	ra,24(sp)
    800049d4:	6442                	ld	s0,16(sp)
    800049d6:	64a2                	ld	s1,8(sp)
    800049d8:	6105                	addi	sp,sp,32
    800049da:	8082                	ret
      p->ofile[fd] = f;
    800049dc:	01a50793          	addi	a5,a0,26
    800049e0:	078e                	slli	a5,a5,0x3
    800049e2:	963e                	add	a2,a2,a5
    800049e4:	e204                	sd	s1,0(a2)
      return fd;
    800049e6:	b7f5                	j	800049d2 <fdalloc+0x28>

00000000800049e8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800049e8:	715d                	addi	sp,sp,-80
    800049ea:	e486                	sd	ra,72(sp)
    800049ec:	e0a2                	sd	s0,64(sp)
    800049ee:	fc26                	sd	s1,56(sp)
    800049f0:	f84a                	sd	s2,48(sp)
    800049f2:	f44e                	sd	s3,40(sp)
    800049f4:	ec56                	sd	s5,24(sp)
    800049f6:	e85a                	sd	s6,16(sp)
    800049f8:	0880                	addi	s0,sp,80
    800049fa:	8b2e                	mv	s6,a1
    800049fc:	89b2                	mv	s3,a2
    800049fe:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004a00:	fb040593          	addi	a1,s0,-80
    80004a04:	80eff0ef          	jal	80003a12 <nameiparent>
    80004a08:	84aa                	mv	s1,a0
    80004a0a:	10050a63          	beqz	a0,80004b1e <create+0x136>
    return 0;

  ilock(dp);
    80004a0e:	fd4fe0ef          	jal	800031e2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004a12:	4601                	li	a2,0
    80004a14:	fb040593          	addi	a1,s0,-80
    80004a18:	8526                	mv	a0,s1
    80004a1a:	d79fe0ef          	jal	80003792 <dirlookup>
    80004a1e:	8aaa                	mv	s5,a0
    80004a20:	c129                	beqz	a0,80004a62 <create+0x7a>
    iunlockput(dp);
    80004a22:	8526                	mv	a0,s1
    80004a24:	9c9fe0ef          	jal	800033ec <iunlockput>
    ilock(ip);
    80004a28:	8556                	mv	a0,s5
    80004a2a:	fb8fe0ef          	jal	800031e2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004a2e:	4789                	li	a5,2
    80004a30:	02fb1463          	bne	s6,a5,80004a58 <create+0x70>
    80004a34:	044ad783          	lhu	a5,68(s5)
    80004a38:	37f9                	addiw	a5,a5,-2
    80004a3a:	17c2                	slli	a5,a5,0x30
    80004a3c:	93c1                	srli	a5,a5,0x30
    80004a3e:	4705                	li	a4,1
    80004a40:	00f76c63          	bltu	a4,a5,80004a58 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004a44:	8556                	mv	a0,s5
    80004a46:	60a6                	ld	ra,72(sp)
    80004a48:	6406                	ld	s0,64(sp)
    80004a4a:	74e2                	ld	s1,56(sp)
    80004a4c:	7942                	ld	s2,48(sp)
    80004a4e:	79a2                	ld	s3,40(sp)
    80004a50:	6ae2                	ld	s5,24(sp)
    80004a52:	6b42                	ld	s6,16(sp)
    80004a54:	6161                	addi	sp,sp,80
    80004a56:	8082                	ret
    iunlockput(ip);
    80004a58:	8556                	mv	a0,s5
    80004a5a:	993fe0ef          	jal	800033ec <iunlockput>
    return 0;
    80004a5e:	4a81                	li	s5,0
    80004a60:	b7d5                	j	80004a44 <create+0x5c>
    80004a62:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004a64:	85da                	mv	a1,s6
    80004a66:	4088                	lw	a0,0(s1)
    80004a68:	e0afe0ef          	jal	80003072 <ialloc>
    80004a6c:	8a2a                	mv	s4,a0
    80004a6e:	cd15                	beqz	a0,80004aaa <create+0xc2>
  ilock(ip);
    80004a70:	f72fe0ef          	jal	800031e2 <ilock>
  ip->major = major;
    80004a74:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004a78:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004a7c:	4905                	li	s2,1
    80004a7e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004a82:	8552                	mv	a0,s4
    80004a84:	eaafe0ef          	jal	8000312e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004a88:	032b0763          	beq	s6,s2,80004ab6 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004a8c:	004a2603          	lw	a2,4(s4)
    80004a90:	fb040593          	addi	a1,s0,-80
    80004a94:	8526                	mv	a0,s1
    80004a96:	ec9fe0ef          	jal	8000395e <dirlink>
    80004a9a:	06054563          	bltz	a0,80004b04 <create+0x11c>
  iunlockput(dp);
    80004a9e:	8526                	mv	a0,s1
    80004aa0:	94dfe0ef          	jal	800033ec <iunlockput>
  return ip;
    80004aa4:	8ad2                	mv	s5,s4
    80004aa6:	7a02                	ld	s4,32(sp)
    80004aa8:	bf71                	j	80004a44 <create+0x5c>
    iunlockput(dp);
    80004aaa:	8526                	mv	a0,s1
    80004aac:	941fe0ef          	jal	800033ec <iunlockput>
    return 0;
    80004ab0:	8ad2                	mv	s5,s4
    80004ab2:	7a02                	ld	s4,32(sp)
    80004ab4:	bf41                	j	80004a44 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004ab6:	004a2603          	lw	a2,4(s4)
    80004aba:	00003597          	auipc	a1,0x3
    80004abe:	b0658593          	addi	a1,a1,-1274 # 800075c0 <etext+0x5c0>
    80004ac2:	8552                	mv	a0,s4
    80004ac4:	e9bfe0ef          	jal	8000395e <dirlink>
    80004ac8:	02054e63          	bltz	a0,80004b04 <create+0x11c>
    80004acc:	40d0                	lw	a2,4(s1)
    80004ace:	00003597          	auipc	a1,0x3
    80004ad2:	afa58593          	addi	a1,a1,-1286 # 800075c8 <etext+0x5c8>
    80004ad6:	8552                	mv	a0,s4
    80004ad8:	e87fe0ef          	jal	8000395e <dirlink>
    80004adc:	02054463          	bltz	a0,80004b04 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004ae0:	004a2603          	lw	a2,4(s4)
    80004ae4:	fb040593          	addi	a1,s0,-80
    80004ae8:	8526                	mv	a0,s1
    80004aea:	e75fe0ef          	jal	8000395e <dirlink>
    80004aee:	00054b63          	bltz	a0,80004b04 <create+0x11c>
    dp->nlink++;  // for ".."
    80004af2:	04a4d783          	lhu	a5,74(s1)
    80004af6:	2785                	addiw	a5,a5,1
    80004af8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004afc:	8526                	mv	a0,s1
    80004afe:	e30fe0ef          	jal	8000312e <iupdate>
    80004b02:	bf71                	j	80004a9e <create+0xb6>
  ip->nlink = 0;
    80004b04:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004b08:	8552                	mv	a0,s4
    80004b0a:	e24fe0ef          	jal	8000312e <iupdate>
  iunlockput(ip);
    80004b0e:	8552                	mv	a0,s4
    80004b10:	8ddfe0ef          	jal	800033ec <iunlockput>
  iunlockput(dp);
    80004b14:	8526                	mv	a0,s1
    80004b16:	8d7fe0ef          	jal	800033ec <iunlockput>
  return 0;
    80004b1a:	7a02                	ld	s4,32(sp)
    80004b1c:	b725                	j	80004a44 <create+0x5c>
    return 0;
    80004b1e:	8aaa                	mv	s5,a0
    80004b20:	b715                	j	80004a44 <create+0x5c>

0000000080004b22 <sys_dup>:
{
    80004b22:	7179                	addi	sp,sp,-48
    80004b24:	f406                	sd	ra,40(sp)
    80004b26:	f022                	sd	s0,32(sp)
    80004b28:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004b2a:	fd840613          	addi	a2,s0,-40
    80004b2e:	4581                	li	a1,0
    80004b30:	4501                	li	a0,0
    80004b32:	e21ff0ef          	jal	80004952 <argfd>
    return -1;
    80004b36:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004b38:	02054363          	bltz	a0,80004b5e <sys_dup+0x3c>
    80004b3c:	ec26                	sd	s1,24(sp)
    80004b3e:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004b40:	fd843903          	ld	s2,-40(s0)
    80004b44:	854a                	mv	a0,s2
    80004b46:	e65ff0ef          	jal	800049aa <fdalloc>
    80004b4a:	84aa                	mv	s1,a0
    return -1;
    80004b4c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004b4e:	00054d63          	bltz	a0,80004b68 <sys_dup+0x46>
  filedup(f);
    80004b52:	854a                	mv	a0,s2
    80004b54:	c3eff0ef          	jal	80003f92 <filedup>
  return fd;
    80004b58:	87a6                	mv	a5,s1
    80004b5a:	64e2                	ld	s1,24(sp)
    80004b5c:	6942                	ld	s2,16(sp)
}
    80004b5e:	853e                	mv	a0,a5
    80004b60:	70a2                	ld	ra,40(sp)
    80004b62:	7402                	ld	s0,32(sp)
    80004b64:	6145                	addi	sp,sp,48
    80004b66:	8082                	ret
    80004b68:	64e2                	ld	s1,24(sp)
    80004b6a:	6942                	ld	s2,16(sp)
    80004b6c:	bfcd                	j	80004b5e <sys_dup+0x3c>

0000000080004b6e <sys_read>:
{
    80004b6e:	7179                	addi	sp,sp,-48
    80004b70:	f406                	sd	ra,40(sp)
    80004b72:	f022                	sd	s0,32(sp)
    80004b74:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004b76:	fd840593          	addi	a1,s0,-40
    80004b7a:	4505                	li	a0,1
    80004b7c:	c7dfd0ef          	jal	800027f8 <argaddr>
  argint(2, &n);
    80004b80:	fe440593          	addi	a1,s0,-28
    80004b84:	4509                	li	a0,2
    80004b86:	c57fd0ef          	jal	800027dc <argint>
  if(argfd(0, 0, &f) < 0)
    80004b8a:	fe840613          	addi	a2,s0,-24
    80004b8e:	4581                	li	a1,0
    80004b90:	4501                	li	a0,0
    80004b92:	dc1ff0ef          	jal	80004952 <argfd>
    80004b96:	87aa                	mv	a5,a0
    return -1;
    80004b98:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b9a:	0007ca63          	bltz	a5,80004bae <sys_read+0x40>
  return fileread(f, p, n);
    80004b9e:	fe442603          	lw	a2,-28(s0)
    80004ba2:	fd843583          	ld	a1,-40(s0)
    80004ba6:	fe843503          	ld	a0,-24(s0)
    80004baa:	d4eff0ef          	jal	800040f8 <fileread>
}
    80004bae:	70a2                	ld	ra,40(sp)
    80004bb0:	7402                	ld	s0,32(sp)
    80004bb2:	6145                	addi	sp,sp,48
    80004bb4:	8082                	ret

0000000080004bb6 <sys_write>:
{
    80004bb6:	7179                	addi	sp,sp,-48
    80004bb8:	f406                	sd	ra,40(sp)
    80004bba:	f022                	sd	s0,32(sp)
    80004bbc:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004bbe:	fd840593          	addi	a1,s0,-40
    80004bc2:	4505                	li	a0,1
    80004bc4:	c35fd0ef          	jal	800027f8 <argaddr>
  argint(2, &n);
    80004bc8:	fe440593          	addi	a1,s0,-28
    80004bcc:	4509                	li	a0,2
    80004bce:	c0ffd0ef          	jal	800027dc <argint>
  if(argfd(0, 0, &f) < 0)
    80004bd2:	fe840613          	addi	a2,s0,-24
    80004bd6:	4581                	li	a1,0
    80004bd8:	4501                	li	a0,0
    80004bda:	d79ff0ef          	jal	80004952 <argfd>
    80004bde:	87aa                	mv	a5,a0
    return -1;
    80004be0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004be2:	0007ca63          	bltz	a5,80004bf6 <sys_write+0x40>
  return filewrite(f, p, n);
    80004be6:	fe442603          	lw	a2,-28(s0)
    80004bea:	fd843583          	ld	a1,-40(s0)
    80004bee:	fe843503          	ld	a0,-24(s0)
    80004bf2:	dc4ff0ef          	jal	800041b6 <filewrite>
}
    80004bf6:	70a2                	ld	ra,40(sp)
    80004bf8:	7402                	ld	s0,32(sp)
    80004bfa:	6145                	addi	sp,sp,48
    80004bfc:	8082                	ret

0000000080004bfe <sys_close>:
{
    80004bfe:	1101                	addi	sp,sp,-32
    80004c00:	ec06                	sd	ra,24(sp)
    80004c02:	e822                	sd	s0,16(sp)
    80004c04:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004c06:	fe040613          	addi	a2,s0,-32
    80004c0a:	fec40593          	addi	a1,s0,-20
    80004c0e:	4501                	li	a0,0
    80004c10:	d43ff0ef          	jal	80004952 <argfd>
    return -1;
    80004c14:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004c16:	02054063          	bltz	a0,80004c36 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004c1a:	cb5fc0ef          	jal	800018ce <myproc>
    80004c1e:	fec42783          	lw	a5,-20(s0)
    80004c22:	07e9                	addi	a5,a5,26
    80004c24:	078e                	slli	a5,a5,0x3
    80004c26:	953e                	add	a0,a0,a5
    80004c28:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004c2c:	fe043503          	ld	a0,-32(s0)
    80004c30:	ba8ff0ef          	jal	80003fd8 <fileclose>
  return 0;
    80004c34:	4781                	li	a5,0
}
    80004c36:	853e                	mv	a0,a5
    80004c38:	60e2                	ld	ra,24(sp)
    80004c3a:	6442                	ld	s0,16(sp)
    80004c3c:	6105                	addi	sp,sp,32
    80004c3e:	8082                	ret

0000000080004c40 <sys_fstat>:
{
    80004c40:	1101                	addi	sp,sp,-32
    80004c42:	ec06                	sd	ra,24(sp)
    80004c44:	e822                	sd	s0,16(sp)
    80004c46:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004c48:	fe040593          	addi	a1,s0,-32
    80004c4c:	4505                	li	a0,1
    80004c4e:	babfd0ef          	jal	800027f8 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004c52:	fe840613          	addi	a2,s0,-24
    80004c56:	4581                	li	a1,0
    80004c58:	4501                	li	a0,0
    80004c5a:	cf9ff0ef          	jal	80004952 <argfd>
    80004c5e:	87aa                	mv	a5,a0
    return -1;
    80004c60:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c62:	0007c863          	bltz	a5,80004c72 <sys_fstat+0x32>
  return filestat(f, st);
    80004c66:	fe043583          	ld	a1,-32(s0)
    80004c6a:	fe843503          	ld	a0,-24(s0)
    80004c6e:	c2cff0ef          	jal	8000409a <filestat>
}
    80004c72:	60e2                	ld	ra,24(sp)
    80004c74:	6442                	ld	s0,16(sp)
    80004c76:	6105                	addi	sp,sp,32
    80004c78:	8082                	ret

0000000080004c7a <sys_link>:
{
    80004c7a:	7169                	addi	sp,sp,-304
    80004c7c:	f606                	sd	ra,296(sp)
    80004c7e:	f222                	sd	s0,288(sp)
    80004c80:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c82:	08000613          	li	a2,128
    80004c86:	ed040593          	addi	a1,s0,-304
    80004c8a:	4501                	li	a0,0
    80004c8c:	b89fd0ef          	jal	80002814 <argstr>
    return -1;
    80004c90:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c92:	0c054e63          	bltz	a0,80004d6e <sys_link+0xf4>
    80004c96:	08000613          	li	a2,128
    80004c9a:	f5040593          	addi	a1,s0,-176
    80004c9e:	4505                	li	a0,1
    80004ca0:	b75fd0ef          	jal	80002814 <argstr>
    return -1;
    80004ca4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ca6:	0c054463          	bltz	a0,80004d6e <sys_link+0xf4>
    80004caa:	ee26                	sd	s1,280(sp)
  begin_op();
    80004cac:	f21fe0ef          	jal	80003bcc <begin_op>
  if((ip = namei(old)) == 0){
    80004cb0:	ed040513          	addi	a0,s0,-304
    80004cb4:	d45fe0ef          	jal	800039f8 <namei>
    80004cb8:	84aa                	mv	s1,a0
    80004cba:	c53d                	beqz	a0,80004d28 <sys_link+0xae>
  ilock(ip);
    80004cbc:	d26fe0ef          	jal	800031e2 <ilock>
  if(ip->type == T_DIR){
    80004cc0:	04449703          	lh	a4,68(s1)
    80004cc4:	4785                	li	a5,1
    80004cc6:	06f70663          	beq	a4,a5,80004d32 <sys_link+0xb8>
    80004cca:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004ccc:	04a4d783          	lhu	a5,74(s1)
    80004cd0:	2785                	addiw	a5,a5,1
    80004cd2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004cd6:	8526                	mv	a0,s1
    80004cd8:	c56fe0ef          	jal	8000312e <iupdate>
  iunlock(ip);
    80004cdc:	8526                	mv	a0,s1
    80004cde:	db2fe0ef          	jal	80003290 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004ce2:	fd040593          	addi	a1,s0,-48
    80004ce6:	f5040513          	addi	a0,s0,-176
    80004cea:	d29fe0ef          	jal	80003a12 <nameiparent>
    80004cee:	892a                	mv	s2,a0
    80004cf0:	cd21                	beqz	a0,80004d48 <sys_link+0xce>
  ilock(dp);
    80004cf2:	cf0fe0ef          	jal	800031e2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004cf6:	00092703          	lw	a4,0(s2)
    80004cfa:	409c                	lw	a5,0(s1)
    80004cfc:	04f71363          	bne	a4,a5,80004d42 <sys_link+0xc8>
    80004d00:	40d0                	lw	a2,4(s1)
    80004d02:	fd040593          	addi	a1,s0,-48
    80004d06:	854a                	mv	a0,s2
    80004d08:	c57fe0ef          	jal	8000395e <dirlink>
    80004d0c:	02054b63          	bltz	a0,80004d42 <sys_link+0xc8>
  iunlockput(dp);
    80004d10:	854a                	mv	a0,s2
    80004d12:	edafe0ef          	jal	800033ec <iunlockput>
  iput(ip);
    80004d16:	8526                	mv	a0,s1
    80004d18:	e4cfe0ef          	jal	80003364 <iput>
  end_op();
    80004d1c:	f1bfe0ef          	jal	80003c36 <end_op>
  return 0;
    80004d20:	4781                	li	a5,0
    80004d22:	64f2                	ld	s1,280(sp)
    80004d24:	6952                	ld	s2,272(sp)
    80004d26:	a0a1                	j	80004d6e <sys_link+0xf4>
    end_op();
    80004d28:	f0ffe0ef          	jal	80003c36 <end_op>
    return -1;
    80004d2c:	57fd                	li	a5,-1
    80004d2e:	64f2                	ld	s1,280(sp)
    80004d30:	a83d                	j	80004d6e <sys_link+0xf4>
    iunlockput(ip);
    80004d32:	8526                	mv	a0,s1
    80004d34:	eb8fe0ef          	jal	800033ec <iunlockput>
    end_op();
    80004d38:	efffe0ef          	jal	80003c36 <end_op>
    return -1;
    80004d3c:	57fd                	li	a5,-1
    80004d3e:	64f2                	ld	s1,280(sp)
    80004d40:	a03d                	j	80004d6e <sys_link+0xf4>
    iunlockput(dp);
    80004d42:	854a                	mv	a0,s2
    80004d44:	ea8fe0ef          	jal	800033ec <iunlockput>
  ilock(ip);
    80004d48:	8526                	mv	a0,s1
    80004d4a:	c98fe0ef          	jal	800031e2 <ilock>
  ip->nlink--;
    80004d4e:	04a4d783          	lhu	a5,74(s1)
    80004d52:	37fd                	addiw	a5,a5,-1
    80004d54:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d58:	8526                	mv	a0,s1
    80004d5a:	bd4fe0ef          	jal	8000312e <iupdate>
  iunlockput(ip);
    80004d5e:	8526                	mv	a0,s1
    80004d60:	e8cfe0ef          	jal	800033ec <iunlockput>
  end_op();
    80004d64:	ed3fe0ef          	jal	80003c36 <end_op>
  return -1;
    80004d68:	57fd                	li	a5,-1
    80004d6a:	64f2                	ld	s1,280(sp)
    80004d6c:	6952                	ld	s2,272(sp)
}
    80004d6e:	853e                	mv	a0,a5
    80004d70:	70b2                	ld	ra,296(sp)
    80004d72:	7412                	ld	s0,288(sp)
    80004d74:	6155                	addi	sp,sp,304
    80004d76:	8082                	ret

0000000080004d78 <sys_unlink>:
{
    80004d78:	7151                	addi	sp,sp,-240
    80004d7a:	f586                	sd	ra,232(sp)
    80004d7c:	f1a2                	sd	s0,224(sp)
    80004d7e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004d80:	08000613          	li	a2,128
    80004d84:	f3040593          	addi	a1,s0,-208
    80004d88:	4501                	li	a0,0
    80004d8a:	a8bfd0ef          	jal	80002814 <argstr>
    80004d8e:	16054063          	bltz	a0,80004eee <sys_unlink+0x176>
    80004d92:	eda6                	sd	s1,216(sp)
  begin_op();
    80004d94:	e39fe0ef          	jal	80003bcc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004d98:	fb040593          	addi	a1,s0,-80
    80004d9c:	f3040513          	addi	a0,s0,-208
    80004da0:	c73fe0ef          	jal	80003a12 <nameiparent>
    80004da4:	84aa                	mv	s1,a0
    80004da6:	c945                	beqz	a0,80004e56 <sys_unlink+0xde>
  ilock(dp);
    80004da8:	c3afe0ef          	jal	800031e2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004dac:	00003597          	auipc	a1,0x3
    80004db0:	81458593          	addi	a1,a1,-2028 # 800075c0 <etext+0x5c0>
    80004db4:	fb040513          	addi	a0,s0,-80
    80004db8:	9c5fe0ef          	jal	8000377c <namecmp>
    80004dbc:	10050e63          	beqz	a0,80004ed8 <sys_unlink+0x160>
    80004dc0:	00003597          	auipc	a1,0x3
    80004dc4:	80858593          	addi	a1,a1,-2040 # 800075c8 <etext+0x5c8>
    80004dc8:	fb040513          	addi	a0,s0,-80
    80004dcc:	9b1fe0ef          	jal	8000377c <namecmp>
    80004dd0:	10050463          	beqz	a0,80004ed8 <sys_unlink+0x160>
    80004dd4:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004dd6:	f2c40613          	addi	a2,s0,-212
    80004dda:	fb040593          	addi	a1,s0,-80
    80004dde:	8526                	mv	a0,s1
    80004de0:	9b3fe0ef          	jal	80003792 <dirlookup>
    80004de4:	892a                	mv	s2,a0
    80004de6:	0e050863          	beqz	a0,80004ed6 <sys_unlink+0x15e>
  ilock(ip);
    80004dea:	bf8fe0ef          	jal	800031e2 <ilock>
  if(ip->nlink < 1)
    80004dee:	04a91783          	lh	a5,74(s2)
    80004df2:	06f05763          	blez	a5,80004e60 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004df6:	04491703          	lh	a4,68(s2)
    80004dfa:	4785                	li	a5,1
    80004dfc:	06f70963          	beq	a4,a5,80004e6e <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004e00:	4641                	li	a2,16
    80004e02:	4581                	li	a1,0
    80004e04:	fc040513          	addi	a0,s0,-64
    80004e08:	e9bfb0ef          	jal	80000ca2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e0c:	4741                	li	a4,16
    80004e0e:	f2c42683          	lw	a3,-212(s0)
    80004e12:	fc040613          	addi	a2,s0,-64
    80004e16:	4581                	li	a1,0
    80004e18:	8526                	mv	a0,s1
    80004e1a:	855fe0ef          	jal	8000366e <writei>
    80004e1e:	47c1                	li	a5,16
    80004e20:	08f51b63          	bne	a0,a5,80004eb6 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004e24:	04491703          	lh	a4,68(s2)
    80004e28:	4785                	li	a5,1
    80004e2a:	08f70d63          	beq	a4,a5,80004ec4 <sys_unlink+0x14c>
  iunlockput(dp);
    80004e2e:	8526                	mv	a0,s1
    80004e30:	dbcfe0ef          	jal	800033ec <iunlockput>
  ip->nlink--;
    80004e34:	04a95783          	lhu	a5,74(s2)
    80004e38:	37fd                	addiw	a5,a5,-1
    80004e3a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004e3e:	854a                	mv	a0,s2
    80004e40:	aeefe0ef          	jal	8000312e <iupdate>
  iunlockput(ip);
    80004e44:	854a                	mv	a0,s2
    80004e46:	da6fe0ef          	jal	800033ec <iunlockput>
  end_op();
    80004e4a:	dedfe0ef          	jal	80003c36 <end_op>
  return 0;
    80004e4e:	4501                	li	a0,0
    80004e50:	64ee                	ld	s1,216(sp)
    80004e52:	694e                	ld	s2,208(sp)
    80004e54:	a849                	j	80004ee6 <sys_unlink+0x16e>
    end_op();
    80004e56:	de1fe0ef          	jal	80003c36 <end_op>
    return -1;
    80004e5a:	557d                	li	a0,-1
    80004e5c:	64ee                	ld	s1,216(sp)
    80004e5e:	a061                	j	80004ee6 <sys_unlink+0x16e>
    80004e60:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004e62:	00002517          	auipc	a0,0x2
    80004e66:	76e50513          	addi	a0,a0,1902 # 800075d0 <etext+0x5d0>
    80004e6a:	977fb0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004e6e:	04c92703          	lw	a4,76(s2)
    80004e72:	02000793          	li	a5,32
    80004e76:	f8e7f5e3          	bgeu	a5,a4,80004e00 <sys_unlink+0x88>
    80004e7a:	e5ce                	sd	s3,200(sp)
    80004e7c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e80:	4741                	li	a4,16
    80004e82:	86ce                	mv	a3,s3
    80004e84:	f1840613          	addi	a2,s0,-232
    80004e88:	4581                	li	a1,0
    80004e8a:	854a                	mv	a0,s2
    80004e8c:	ee6fe0ef          	jal	80003572 <readi>
    80004e90:	47c1                	li	a5,16
    80004e92:	00f51c63          	bne	a0,a5,80004eaa <sys_unlink+0x132>
    if(de.inum != 0)
    80004e96:	f1845783          	lhu	a5,-232(s0)
    80004e9a:	efa1                	bnez	a5,80004ef2 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004e9c:	29c1                	addiw	s3,s3,16
    80004e9e:	04c92783          	lw	a5,76(s2)
    80004ea2:	fcf9efe3          	bltu	s3,a5,80004e80 <sys_unlink+0x108>
    80004ea6:	69ae                	ld	s3,200(sp)
    80004ea8:	bfa1                	j	80004e00 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004eaa:	00002517          	auipc	a0,0x2
    80004eae:	73e50513          	addi	a0,a0,1854 # 800075e8 <etext+0x5e8>
    80004eb2:	92ffb0ef          	jal	800007e0 <panic>
    80004eb6:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004eb8:	00002517          	auipc	a0,0x2
    80004ebc:	74850513          	addi	a0,a0,1864 # 80007600 <etext+0x600>
    80004ec0:	921fb0ef          	jal	800007e0 <panic>
    dp->nlink--;
    80004ec4:	04a4d783          	lhu	a5,74(s1)
    80004ec8:	37fd                	addiw	a5,a5,-1
    80004eca:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004ece:	8526                	mv	a0,s1
    80004ed0:	a5efe0ef          	jal	8000312e <iupdate>
    80004ed4:	bfa9                	j	80004e2e <sys_unlink+0xb6>
    80004ed6:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004ed8:	8526                	mv	a0,s1
    80004eda:	d12fe0ef          	jal	800033ec <iunlockput>
  end_op();
    80004ede:	d59fe0ef          	jal	80003c36 <end_op>
  return -1;
    80004ee2:	557d                	li	a0,-1
    80004ee4:	64ee                	ld	s1,216(sp)
}
    80004ee6:	70ae                	ld	ra,232(sp)
    80004ee8:	740e                	ld	s0,224(sp)
    80004eea:	616d                	addi	sp,sp,240
    80004eec:	8082                	ret
    return -1;
    80004eee:	557d                	li	a0,-1
    80004ef0:	bfdd                	j	80004ee6 <sys_unlink+0x16e>
    iunlockput(ip);
    80004ef2:	854a                	mv	a0,s2
    80004ef4:	cf8fe0ef          	jal	800033ec <iunlockput>
    goto bad;
    80004ef8:	694e                	ld	s2,208(sp)
    80004efa:	69ae                	ld	s3,200(sp)
    80004efc:	bff1                	j	80004ed8 <sys_unlink+0x160>

0000000080004efe <sys_open>:

uint64
sys_open(void)
{
    80004efe:	7131                	addi	sp,sp,-192
    80004f00:	fd06                	sd	ra,184(sp)
    80004f02:	f922                	sd	s0,176(sp)
    80004f04:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004f06:	f4c40593          	addi	a1,s0,-180
    80004f0a:	4505                	li	a0,1
    80004f0c:	8d1fd0ef          	jal	800027dc <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004f10:	08000613          	li	a2,128
    80004f14:	f5040593          	addi	a1,s0,-176
    80004f18:	4501                	li	a0,0
    80004f1a:	8fbfd0ef          	jal	80002814 <argstr>
    80004f1e:	87aa                	mv	a5,a0
    return -1;
    80004f20:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004f22:	0a07c263          	bltz	a5,80004fc6 <sys_open+0xc8>
    80004f26:	f526                	sd	s1,168(sp)

  begin_op();
    80004f28:	ca5fe0ef          	jal	80003bcc <begin_op>

  if(omode & O_CREATE){
    80004f2c:	f4c42783          	lw	a5,-180(s0)
    80004f30:	2007f793          	andi	a5,a5,512
    80004f34:	c3d5                	beqz	a5,80004fd8 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004f36:	4681                	li	a3,0
    80004f38:	4601                	li	a2,0
    80004f3a:	4589                	li	a1,2
    80004f3c:	f5040513          	addi	a0,s0,-176
    80004f40:	aa9ff0ef          	jal	800049e8 <create>
    80004f44:	84aa                	mv	s1,a0
    if(ip == 0){
    80004f46:	c541                	beqz	a0,80004fce <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004f48:	04449703          	lh	a4,68(s1)
    80004f4c:	478d                	li	a5,3
    80004f4e:	00f71763          	bne	a4,a5,80004f5c <sys_open+0x5e>
    80004f52:	0464d703          	lhu	a4,70(s1)
    80004f56:	47a5                	li	a5,9
    80004f58:	0ae7ed63          	bltu	a5,a4,80005012 <sys_open+0x114>
    80004f5c:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004f5e:	fd7fe0ef          	jal	80003f34 <filealloc>
    80004f62:	892a                	mv	s2,a0
    80004f64:	c179                	beqz	a0,8000502a <sys_open+0x12c>
    80004f66:	ed4e                	sd	s3,152(sp)
    80004f68:	a43ff0ef          	jal	800049aa <fdalloc>
    80004f6c:	89aa                	mv	s3,a0
    80004f6e:	0a054a63          	bltz	a0,80005022 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004f72:	04449703          	lh	a4,68(s1)
    80004f76:	478d                	li	a5,3
    80004f78:	0cf70263          	beq	a4,a5,8000503c <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004f7c:	4789                	li	a5,2
    80004f7e:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004f82:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004f86:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004f8a:	f4c42783          	lw	a5,-180(s0)
    80004f8e:	0017c713          	xori	a4,a5,1
    80004f92:	8b05                	andi	a4,a4,1
    80004f94:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004f98:	0037f713          	andi	a4,a5,3
    80004f9c:	00e03733          	snez	a4,a4
    80004fa0:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004fa4:	4007f793          	andi	a5,a5,1024
    80004fa8:	c791                	beqz	a5,80004fb4 <sys_open+0xb6>
    80004faa:	04449703          	lh	a4,68(s1)
    80004fae:	4789                	li	a5,2
    80004fb0:	08f70d63          	beq	a4,a5,8000504a <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80004fb4:	8526                	mv	a0,s1
    80004fb6:	adafe0ef          	jal	80003290 <iunlock>
  end_op();
    80004fba:	c7dfe0ef          	jal	80003c36 <end_op>

  return fd;
    80004fbe:	854e                	mv	a0,s3
    80004fc0:	74aa                	ld	s1,168(sp)
    80004fc2:	790a                	ld	s2,160(sp)
    80004fc4:	69ea                	ld	s3,152(sp)
}
    80004fc6:	70ea                	ld	ra,184(sp)
    80004fc8:	744a                	ld	s0,176(sp)
    80004fca:	6129                	addi	sp,sp,192
    80004fcc:	8082                	ret
      end_op();
    80004fce:	c69fe0ef          	jal	80003c36 <end_op>
      return -1;
    80004fd2:	557d                	li	a0,-1
    80004fd4:	74aa                	ld	s1,168(sp)
    80004fd6:	bfc5                	j	80004fc6 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80004fd8:	f5040513          	addi	a0,s0,-176
    80004fdc:	a1dfe0ef          	jal	800039f8 <namei>
    80004fe0:	84aa                	mv	s1,a0
    80004fe2:	c11d                	beqz	a0,80005008 <sys_open+0x10a>
    ilock(ip);
    80004fe4:	9fefe0ef          	jal	800031e2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004fe8:	04449703          	lh	a4,68(s1)
    80004fec:	4785                	li	a5,1
    80004fee:	f4f71de3          	bne	a4,a5,80004f48 <sys_open+0x4a>
    80004ff2:	f4c42783          	lw	a5,-180(s0)
    80004ff6:	d3bd                	beqz	a5,80004f5c <sys_open+0x5e>
      iunlockput(ip);
    80004ff8:	8526                	mv	a0,s1
    80004ffa:	bf2fe0ef          	jal	800033ec <iunlockput>
      end_op();
    80004ffe:	c39fe0ef          	jal	80003c36 <end_op>
      return -1;
    80005002:	557d                	li	a0,-1
    80005004:	74aa                	ld	s1,168(sp)
    80005006:	b7c1                	j	80004fc6 <sys_open+0xc8>
      end_op();
    80005008:	c2ffe0ef          	jal	80003c36 <end_op>
      return -1;
    8000500c:	557d                	li	a0,-1
    8000500e:	74aa                	ld	s1,168(sp)
    80005010:	bf5d                	j	80004fc6 <sys_open+0xc8>
    iunlockput(ip);
    80005012:	8526                	mv	a0,s1
    80005014:	bd8fe0ef          	jal	800033ec <iunlockput>
    end_op();
    80005018:	c1ffe0ef          	jal	80003c36 <end_op>
    return -1;
    8000501c:	557d                	li	a0,-1
    8000501e:	74aa                	ld	s1,168(sp)
    80005020:	b75d                	j	80004fc6 <sys_open+0xc8>
      fileclose(f);
    80005022:	854a                	mv	a0,s2
    80005024:	fb5fe0ef          	jal	80003fd8 <fileclose>
    80005028:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000502a:	8526                	mv	a0,s1
    8000502c:	bc0fe0ef          	jal	800033ec <iunlockput>
    end_op();
    80005030:	c07fe0ef          	jal	80003c36 <end_op>
    return -1;
    80005034:	557d                	li	a0,-1
    80005036:	74aa                	ld	s1,168(sp)
    80005038:	790a                	ld	s2,160(sp)
    8000503a:	b771                	j	80004fc6 <sys_open+0xc8>
    f->type = FD_DEVICE;
    8000503c:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005040:	04649783          	lh	a5,70(s1)
    80005044:	02f91223          	sh	a5,36(s2)
    80005048:	bf3d                	j	80004f86 <sys_open+0x88>
    itrunc(ip);
    8000504a:	8526                	mv	a0,s1
    8000504c:	a84fe0ef          	jal	800032d0 <itrunc>
    80005050:	b795                	j	80004fb4 <sys_open+0xb6>

0000000080005052 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005052:	7175                	addi	sp,sp,-144
    80005054:	e506                	sd	ra,136(sp)
    80005056:	e122                	sd	s0,128(sp)
    80005058:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000505a:	b73fe0ef          	jal	80003bcc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000505e:	08000613          	li	a2,128
    80005062:	f7040593          	addi	a1,s0,-144
    80005066:	4501                	li	a0,0
    80005068:	facfd0ef          	jal	80002814 <argstr>
    8000506c:	02054363          	bltz	a0,80005092 <sys_mkdir+0x40>
    80005070:	4681                	li	a3,0
    80005072:	4601                	li	a2,0
    80005074:	4585                	li	a1,1
    80005076:	f7040513          	addi	a0,s0,-144
    8000507a:	96fff0ef          	jal	800049e8 <create>
    8000507e:	c911                	beqz	a0,80005092 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005080:	b6cfe0ef          	jal	800033ec <iunlockput>
  end_op();
    80005084:	bb3fe0ef          	jal	80003c36 <end_op>
  return 0;
    80005088:	4501                	li	a0,0
}
    8000508a:	60aa                	ld	ra,136(sp)
    8000508c:	640a                	ld	s0,128(sp)
    8000508e:	6149                	addi	sp,sp,144
    80005090:	8082                	ret
    end_op();
    80005092:	ba5fe0ef          	jal	80003c36 <end_op>
    return -1;
    80005096:	557d                	li	a0,-1
    80005098:	bfcd                	j	8000508a <sys_mkdir+0x38>

000000008000509a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000509a:	7135                	addi	sp,sp,-160
    8000509c:	ed06                	sd	ra,152(sp)
    8000509e:	e922                	sd	s0,144(sp)
    800050a0:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800050a2:	b2bfe0ef          	jal	80003bcc <begin_op>
  argint(1, &major);
    800050a6:	f6c40593          	addi	a1,s0,-148
    800050aa:	4505                	li	a0,1
    800050ac:	f30fd0ef          	jal	800027dc <argint>
  argint(2, &minor);
    800050b0:	f6840593          	addi	a1,s0,-152
    800050b4:	4509                	li	a0,2
    800050b6:	f26fd0ef          	jal	800027dc <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800050ba:	08000613          	li	a2,128
    800050be:	f7040593          	addi	a1,s0,-144
    800050c2:	4501                	li	a0,0
    800050c4:	f50fd0ef          	jal	80002814 <argstr>
    800050c8:	02054563          	bltz	a0,800050f2 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800050cc:	f6841683          	lh	a3,-152(s0)
    800050d0:	f6c41603          	lh	a2,-148(s0)
    800050d4:	458d                	li	a1,3
    800050d6:	f7040513          	addi	a0,s0,-144
    800050da:	90fff0ef          	jal	800049e8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800050de:	c911                	beqz	a0,800050f2 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800050e0:	b0cfe0ef          	jal	800033ec <iunlockput>
  end_op();
    800050e4:	b53fe0ef          	jal	80003c36 <end_op>
  return 0;
    800050e8:	4501                	li	a0,0
}
    800050ea:	60ea                	ld	ra,152(sp)
    800050ec:	644a                	ld	s0,144(sp)
    800050ee:	610d                	addi	sp,sp,160
    800050f0:	8082                	ret
    end_op();
    800050f2:	b45fe0ef          	jal	80003c36 <end_op>
    return -1;
    800050f6:	557d                	li	a0,-1
    800050f8:	bfcd                	j	800050ea <sys_mknod+0x50>

00000000800050fa <sys_chdir>:

uint64
sys_chdir(void)
{
    800050fa:	7135                	addi	sp,sp,-160
    800050fc:	ed06                	sd	ra,152(sp)
    800050fe:	e922                	sd	s0,144(sp)
    80005100:	e14a                	sd	s2,128(sp)
    80005102:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005104:	fcafc0ef          	jal	800018ce <myproc>
    80005108:	892a                	mv	s2,a0
  
  begin_op();
    8000510a:	ac3fe0ef          	jal	80003bcc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000510e:	08000613          	li	a2,128
    80005112:	f6040593          	addi	a1,s0,-160
    80005116:	4501                	li	a0,0
    80005118:	efcfd0ef          	jal	80002814 <argstr>
    8000511c:	04054363          	bltz	a0,80005162 <sys_chdir+0x68>
    80005120:	e526                	sd	s1,136(sp)
    80005122:	f6040513          	addi	a0,s0,-160
    80005126:	8d3fe0ef          	jal	800039f8 <namei>
    8000512a:	84aa                	mv	s1,a0
    8000512c:	c915                	beqz	a0,80005160 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000512e:	8b4fe0ef          	jal	800031e2 <ilock>
  if(ip->type != T_DIR){
    80005132:	04449703          	lh	a4,68(s1)
    80005136:	4785                	li	a5,1
    80005138:	02f71963          	bne	a4,a5,8000516a <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000513c:	8526                	mv	a0,s1
    8000513e:	952fe0ef          	jal	80003290 <iunlock>
  iput(p->cwd);
    80005142:	15093503          	ld	a0,336(s2)
    80005146:	a1efe0ef          	jal	80003364 <iput>
  end_op();
    8000514a:	aedfe0ef          	jal	80003c36 <end_op>
  p->cwd = ip;
    8000514e:	14993823          	sd	s1,336(s2)
  return 0;
    80005152:	4501                	li	a0,0
    80005154:	64aa                	ld	s1,136(sp)
}
    80005156:	60ea                	ld	ra,152(sp)
    80005158:	644a                	ld	s0,144(sp)
    8000515a:	690a                	ld	s2,128(sp)
    8000515c:	610d                	addi	sp,sp,160
    8000515e:	8082                	ret
    80005160:	64aa                	ld	s1,136(sp)
    end_op();
    80005162:	ad5fe0ef          	jal	80003c36 <end_op>
    return -1;
    80005166:	557d                	li	a0,-1
    80005168:	b7fd                	j	80005156 <sys_chdir+0x5c>
    iunlockput(ip);
    8000516a:	8526                	mv	a0,s1
    8000516c:	a80fe0ef          	jal	800033ec <iunlockput>
    end_op();
    80005170:	ac7fe0ef          	jal	80003c36 <end_op>
    return -1;
    80005174:	557d                	li	a0,-1
    80005176:	64aa                	ld	s1,136(sp)
    80005178:	bff9                	j	80005156 <sys_chdir+0x5c>

000000008000517a <sys_exec>:

uint64
sys_exec(void)
{
    8000517a:	7121                	addi	sp,sp,-448
    8000517c:	ff06                	sd	ra,440(sp)
    8000517e:	fb22                	sd	s0,432(sp)
    80005180:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005182:	e4840593          	addi	a1,s0,-440
    80005186:	4505                	li	a0,1
    80005188:	e70fd0ef          	jal	800027f8 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000518c:	08000613          	li	a2,128
    80005190:	f5040593          	addi	a1,s0,-176
    80005194:	4501                	li	a0,0
    80005196:	e7efd0ef          	jal	80002814 <argstr>
    8000519a:	87aa                	mv	a5,a0
    return -1;
    8000519c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000519e:	0c07c463          	bltz	a5,80005266 <sys_exec+0xec>
    800051a2:	f726                	sd	s1,424(sp)
    800051a4:	f34a                	sd	s2,416(sp)
    800051a6:	ef4e                	sd	s3,408(sp)
    800051a8:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    800051aa:	10000613          	li	a2,256
    800051ae:	4581                	li	a1,0
    800051b0:	e5040513          	addi	a0,s0,-432
    800051b4:	aeffb0ef          	jal	80000ca2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800051b8:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800051bc:	89a6                	mv	s3,s1
    800051be:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800051c0:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800051c4:	00391513          	slli	a0,s2,0x3
    800051c8:	e4040593          	addi	a1,s0,-448
    800051cc:	e4843783          	ld	a5,-440(s0)
    800051d0:	953e                	add	a0,a0,a5
    800051d2:	d80fd0ef          	jal	80002752 <fetchaddr>
    800051d6:	02054663          	bltz	a0,80005202 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800051da:	e4043783          	ld	a5,-448(s0)
    800051de:	c3a9                	beqz	a5,80005220 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800051e0:	91ffb0ef          	jal	80000afe <kalloc>
    800051e4:	85aa                	mv	a1,a0
    800051e6:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800051ea:	cd01                	beqz	a0,80005202 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800051ec:	6605                	lui	a2,0x1
    800051ee:	e4043503          	ld	a0,-448(s0)
    800051f2:	daafd0ef          	jal	8000279c <fetchstr>
    800051f6:	00054663          	bltz	a0,80005202 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800051fa:	0905                	addi	s2,s2,1
    800051fc:	09a1                	addi	s3,s3,8
    800051fe:	fd4913e3          	bne	s2,s4,800051c4 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005202:	f5040913          	addi	s2,s0,-176
    80005206:	6088                	ld	a0,0(s1)
    80005208:	c931                	beqz	a0,8000525c <sys_exec+0xe2>
    kfree(argv[i]);
    8000520a:	813fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000520e:	04a1                	addi	s1,s1,8
    80005210:	ff249be3          	bne	s1,s2,80005206 <sys_exec+0x8c>
  return -1;
    80005214:	557d                	li	a0,-1
    80005216:	74ba                	ld	s1,424(sp)
    80005218:	791a                	ld	s2,416(sp)
    8000521a:	69fa                	ld	s3,408(sp)
    8000521c:	6a5a                	ld	s4,400(sp)
    8000521e:	a0a1                	j	80005266 <sys_exec+0xec>
      argv[i] = 0;
    80005220:	0009079b          	sext.w	a5,s2
    80005224:	078e                	slli	a5,a5,0x3
    80005226:	fd078793          	addi	a5,a5,-48
    8000522a:	97a2                	add	a5,a5,s0
    8000522c:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80005230:	e5040593          	addi	a1,s0,-432
    80005234:	f5040513          	addi	a0,s0,-176
    80005238:	ba8ff0ef          	jal	800045e0 <kexec>
    8000523c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000523e:	f5040993          	addi	s3,s0,-176
    80005242:	6088                	ld	a0,0(s1)
    80005244:	c511                	beqz	a0,80005250 <sys_exec+0xd6>
    kfree(argv[i]);
    80005246:	fd6fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000524a:	04a1                	addi	s1,s1,8
    8000524c:	ff349be3          	bne	s1,s3,80005242 <sys_exec+0xc8>
  return ret;
    80005250:	854a                	mv	a0,s2
    80005252:	74ba                	ld	s1,424(sp)
    80005254:	791a                	ld	s2,416(sp)
    80005256:	69fa                	ld	s3,408(sp)
    80005258:	6a5a                	ld	s4,400(sp)
    8000525a:	a031                	j	80005266 <sys_exec+0xec>
  return -1;
    8000525c:	557d                	li	a0,-1
    8000525e:	74ba                	ld	s1,424(sp)
    80005260:	791a                	ld	s2,416(sp)
    80005262:	69fa                	ld	s3,408(sp)
    80005264:	6a5a                	ld	s4,400(sp)
}
    80005266:	70fa                	ld	ra,440(sp)
    80005268:	745a                	ld	s0,432(sp)
    8000526a:	6139                	addi	sp,sp,448
    8000526c:	8082                	ret

000000008000526e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000526e:	7139                	addi	sp,sp,-64
    80005270:	fc06                	sd	ra,56(sp)
    80005272:	f822                	sd	s0,48(sp)
    80005274:	f426                	sd	s1,40(sp)
    80005276:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005278:	e56fc0ef          	jal	800018ce <myproc>
    8000527c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000527e:	fd840593          	addi	a1,s0,-40
    80005282:	4501                	li	a0,0
    80005284:	d74fd0ef          	jal	800027f8 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005288:	fc840593          	addi	a1,s0,-56
    8000528c:	fd040513          	addi	a0,s0,-48
    80005290:	852ff0ef          	jal	800042e2 <pipealloc>
    return -1;
    80005294:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005296:	0a054463          	bltz	a0,8000533e <sys_pipe+0xd0>
  fd0 = -1;
    8000529a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000529e:	fd043503          	ld	a0,-48(s0)
    800052a2:	f08ff0ef          	jal	800049aa <fdalloc>
    800052a6:	fca42223          	sw	a0,-60(s0)
    800052aa:	08054163          	bltz	a0,8000532c <sys_pipe+0xbe>
    800052ae:	fc843503          	ld	a0,-56(s0)
    800052b2:	ef8ff0ef          	jal	800049aa <fdalloc>
    800052b6:	fca42023          	sw	a0,-64(s0)
    800052ba:	06054063          	bltz	a0,8000531a <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800052be:	4691                	li	a3,4
    800052c0:	fc440613          	addi	a2,s0,-60
    800052c4:	fd843583          	ld	a1,-40(s0)
    800052c8:	68a8                	ld	a0,80(s1)
    800052ca:	b18fc0ef          	jal	800015e2 <copyout>
    800052ce:	00054e63          	bltz	a0,800052ea <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800052d2:	4691                	li	a3,4
    800052d4:	fc040613          	addi	a2,s0,-64
    800052d8:	fd843583          	ld	a1,-40(s0)
    800052dc:	0591                	addi	a1,a1,4
    800052de:	68a8                	ld	a0,80(s1)
    800052e0:	b02fc0ef          	jal	800015e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800052e4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800052e6:	04055c63          	bgez	a0,8000533e <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800052ea:	fc442783          	lw	a5,-60(s0)
    800052ee:	07e9                	addi	a5,a5,26
    800052f0:	078e                	slli	a5,a5,0x3
    800052f2:	97a6                	add	a5,a5,s1
    800052f4:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800052f8:	fc042783          	lw	a5,-64(s0)
    800052fc:	07e9                	addi	a5,a5,26
    800052fe:	078e                	slli	a5,a5,0x3
    80005300:	94be                	add	s1,s1,a5
    80005302:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005306:	fd043503          	ld	a0,-48(s0)
    8000530a:	ccffe0ef          	jal	80003fd8 <fileclose>
    fileclose(wf);
    8000530e:	fc843503          	ld	a0,-56(s0)
    80005312:	cc7fe0ef          	jal	80003fd8 <fileclose>
    return -1;
    80005316:	57fd                	li	a5,-1
    80005318:	a01d                	j	8000533e <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000531a:	fc442783          	lw	a5,-60(s0)
    8000531e:	0007c763          	bltz	a5,8000532c <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005322:	07e9                	addi	a5,a5,26
    80005324:	078e                	slli	a5,a5,0x3
    80005326:	97a6                	add	a5,a5,s1
    80005328:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000532c:	fd043503          	ld	a0,-48(s0)
    80005330:	ca9fe0ef          	jal	80003fd8 <fileclose>
    fileclose(wf);
    80005334:	fc843503          	ld	a0,-56(s0)
    80005338:	ca1fe0ef          	jal	80003fd8 <fileclose>
    return -1;
    8000533c:	57fd                	li	a5,-1
}
    8000533e:	853e                	mv	a0,a5
    80005340:	70e2                	ld	ra,56(sp)
    80005342:	7442                	ld	s0,48(sp)
    80005344:	74a2                	ld	s1,40(sp)
    80005346:	6121                	addi	sp,sp,64
    80005348:	8082                	ret
    8000534a:	0000                	unimp
    8000534c:	0000                	unimp
	...

0000000080005350 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005350:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005352:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005354:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005356:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005358:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000535a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000535c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000535e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005360:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005362:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005364:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005366:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005368:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000536a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000536c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000536e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005370:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005372:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005374:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005376:	aecfd0ef          	jal	80002662 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000537a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000537c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000537e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005380:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005382:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005384:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005386:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005388:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000538a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000538c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000538e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005390:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005392:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005394:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005396:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005398:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000539a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000539c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000539e:	10200073          	sret
	...

00000000800053ae <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800053ae:	1141                	addi	sp,sp,-16
    800053b0:	e422                	sd	s0,8(sp)
    800053b2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800053b4:	0c0007b7          	lui	a5,0xc000
    800053b8:	4705                	li	a4,1
    800053ba:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800053bc:	0c0007b7          	lui	a5,0xc000
    800053c0:	c3d8                	sw	a4,4(a5)
}
    800053c2:	6422                	ld	s0,8(sp)
    800053c4:	0141                	addi	sp,sp,16
    800053c6:	8082                	ret

00000000800053c8 <plicinithart>:

void
plicinithart(void)
{
    800053c8:	1141                	addi	sp,sp,-16
    800053ca:	e406                	sd	ra,8(sp)
    800053cc:	e022                	sd	s0,0(sp)
    800053ce:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800053d0:	cd2fc0ef          	jal	800018a2 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800053d4:	0085171b          	slliw	a4,a0,0x8
    800053d8:	0c0027b7          	lui	a5,0xc002
    800053dc:	97ba                	add	a5,a5,a4
    800053de:	40200713          	li	a4,1026
    800053e2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800053e6:	00d5151b          	slliw	a0,a0,0xd
    800053ea:	0c2017b7          	lui	a5,0xc201
    800053ee:	97aa                	add	a5,a5,a0
    800053f0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800053f4:	60a2                	ld	ra,8(sp)
    800053f6:	6402                	ld	s0,0(sp)
    800053f8:	0141                	addi	sp,sp,16
    800053fa:	8082                	ret

00000000800053fc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800053fc:	1141                	addi	sp,sp,-16
    800053fe:	e406                	sd	ra,8(sp)
    80005400:	e022                	sd	s0,0(sp)
    80005402:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005404:	c9efc0ef          	jal	800018a2 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005408:	00d5151b          	slliw	a0,a0,0xd
    8000540c:	0c2017b7          	lui	a5,0xc201
    80005410:	97aa                	add	a5,a5,a0
  return irq;
}
    80005412:	43c8                	lw	a0,4(a5)
    80005414:	60a2                	ld	ra,8(sp)
    80005416:	6402                	ld	s0,0(sp)
    80005418:	0141                	addi	sp,sp,16
    8000541a:	8082                	ret

000000008000541c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000541c:	1101                	addi	sp,sp,-32
    8000541e:	ec06                	sd	ra,24(sp)
    80005420:	e822                	sd	s0,16(sp)
    80005422:	e426                	sd	s1,8(sp)
    80005424:	1000                	addi	s0,sp,32
    80005426:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005428:	c7afc0ef          	jal	800018a2 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000542c:	00d5151b          	slliw	a0,a0,0xd
    80005430:	0c2017b7          	lui	a5,0xc201
    80005434:	97aa                	add	a5,a5,a0
    80005436:	c3c4                	sw	s1,4(a5)
}
    80005438:	60e2                	ld	ra,24(sp)
    8000543a:	6442                	ld	s0,16(sp)
    8000543c:	64a2                	ld	s1,8(sp)
    8000543e:	6105                	addi	sp,sp,32
    80005440:	8082                	ret

0000000080005442 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005442:	1141                	addi	sp,sp,-16
    80005444:	e406                	sd	ra,8(sp)
    80005446:	e022                	sd	s0,0(sp)
    80005448:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000544a:	479d                	li	a5,7
    8000544c:	04a7ca63          	blt	a5,a0,800054a0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005450:	0001e797          	auipc	a5,0x1e
    80005454:	f3878793          	addi	a5,a5,-200 # 80023388 <disk>
    80005458:	97aa                	add	a5,a5,a0
    8000545a:	0187c783          	lbu	a5,24(a5)
    8000545e:	e7b9                	bnez	a5,800054ac <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005460:	00451693          	slli	a3,a0,0x4
    80005464:	0001e797          	auipc	a5,0x1e
    80005468:	f2478793          	addi	a5,a5,-220 # 80023388 <disk>
    8000546c:	6398                	ld	a4,0(a5)
    8000546e:	9736                	add	a4,a4,a3
    80005470:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005474:	6398                	ld	a4,0(a5)
    80005476:	9736                	add	a4,a4,a3
    80005478:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000547c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005480:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005484:	97aa                	add	a5,a5,a0
    80005486:	4705                	li	a4,1
    80005488:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000548c:	0001e517          	auipc	a0,0x1e
    80005490:	f1450513          	addi	a0,a0,-236 # 800233a0 <disk+0x18>
    80005494:	a91fc0ef          	jal	80001f24 <wakeup>
}
    80005498:	60a2                	ld	ra,8(sp)
    8000549a:	6402                	ld	s0,0(sp)
    8000549c:	0141                	addi	sp,sp,16
    8000549e:	8082                	ret
    panic("free_desc 1");
    800054a0:	00002517          	auipc	a0,0x2
    800054a4:	17050513          	addi	a0,a0,368 # 80007610 <etext+0x610>
    800054a8:	b38fb0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    800054ac:	00002517          	auipc	a0,0x2
    800054b0:	17450513          	addi	a0,a0,372 # 80007620 <etext+0x620>
    800054b4:	b2cfb0ef          	jal	800007e0 <panic>

00000000800054b8 <virtio_disk_init>:
{
    800054b8:	1101                	addi	sp,sp,-32
    800054ba:	ec06                	sd	ra,24(sp)
    800054bc:	e822                	sd	s0,16(sp)
    800054be:	e426                	sd	s1,8(sp)
    800054c0:	e04a                	sd	s2,0(sp)
    800054c2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800054c4:	00002597          	auipc	a1,0x2
    800054c8:	16c58593          	addi	a1,a1,364 # 80007630 <etext+0x630>
    800054cc:	0001e517          	auipc	a0,0x1e
    800054d0:	fe450513          	addi	a0,a0,-28 # 800234b0 <disk+0x128>
    800054d4:	e7afb0ef          	jal	80000b4e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800054d8:	100017b7          	lui	a5,0x10001
    800054dc:	4398                	lw	a4,0(a5)
    800054de:	2701                	sext.w	a4,a4
    800054e0:	747277b7          	lui	a5,0x74727
    800054e4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800054e8:	18f71063          	bne	a4,a5,80005668 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800054ec:	100017b7          	lui	a5,0x10001
    800054f0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800054f2:	439c                	lw	a5,0(a5)
    800054f4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800054f6:	4709                	li	a4,2
    800054f8:	16e79863          	bne	a5,a4,80005668 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800054fc:	100017b7          	lui	a5,0x10001
    80005500:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005502:	439c                	lw	a5,0(a5)
    80005504:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005506:	16e79163          	bne	a5,a4,80005668 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000550a:	100017b7          	lui	a5,0x10001
    8000550e:	47d8                	lw	a4,12(a5)
    80005510:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005512:	554d47b7          	lui	a5,0x554d4
    80005516:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000551a:	14f71763          	bne	a4,a5,80005668 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000551e:	100017b7          	lui	a5,0x10001
    80005522:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005526:	4705                	li	a4,1
    80005528:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000552a:	470d                	li	a4,3
    8000552c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000552e:	10001737          	lui	a4,0x10001
    80005532:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005534:	c7ffe737          	lui	a4,0xc7ffe
    80005538:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb297>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000553c:	8ef9                	and	a3,a3,a4
    8000553e:	10001737          	lui	a4,0x10001
    80005542:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005544:	472d                	li	a4,11
    80005546:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005548:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000554c:	439c                	lw	a5,0(a5)
    8000554e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005552:	8ba1                	andi	a5,a5,8
    80005554:	12078063          	beqz	a5,80005674 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005558:	100017b7          	lui	a5,0x10001
    8000555c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005560:	100017b7          	lui	a5,0x10001
    80005564:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005568:	439c                	lw	a5,0(a5)
    8000556a:	2781                	sext.w	a5,a5
    8000556c:	10079a63          	bnez	a5,80005680 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005570:	100017b7          	lui	a5,0x10001
    80005574:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005578:	439c                	lw	a5,0(a5)
    8000557a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000557c:	10078863          	beqz	a5,8000568c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005580:	471d                	li	a4,7
    80005582:	10f77b63          	bgeu	a4,a5,80005698 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005586:	d78fb0ef          	jal	80000afe <kalloc>
    8000558a:	0001e497          	auipc	s1,0x1e
    8000558e:	dfe48493          	addi	s1,s1,-514 # 80023388 <disk>
    80005592:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005594:	d6afb0ef          	jal	80000afe <kalloc>
    80005598:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000559a:	d64fb0ef          	jal	80000afe <kalloc>
    8000559e:	87aa                	mv	a5,a0
    800055a0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800055a2:	6088                	ld	a0,0(s1)
    800055a4:	10050063          	beqz	a0,800056a4 <virtio_disk_init+0x1ec>
    800055a8:	0001e717          	auipc	a4,0x1e
    800055ac:	de873703          	ld	a4,-536(a4) # 80023390 <disk+0x8>
    800055b0:	0e070a63          	beqz	a4,800056a4 <virtio_disk_init+0x1ec>
    800055b4:	0e078863          	beqz	a5,800056a4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    800055b8:	6605                	lui	a2,0x1
    800055ba:	4581                	li	a1,0
    800055bc:	ee6fb0ef          	jal	80000ca2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800055c0:	0001e497          	auipc	s1,0x1e
    800055c4:	dc848493          	addi	s1,s1,-568 # 80023388 <disk>
    800055c8:	6605                	lui	a2,0x1
    800055ca:	4581                	li	a1,0
    800055cc:	6488                	ld	a0,8(s1)
    800055ce:	ed4fb0ef          	jal	80000ca2 <memset>
  memset(disk.used, 0, PGSIZE);
    800055d2:	6605                	lui	a2,0x1
    800055d4:	4581                	li	a1,0
    800055d6:	6888                	ld	a0,16(s1)
    800055d8:	ecafb0ef          	jal	80000ca2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800055dc:	100017b7          	lui	a5,0x10001
    800055e0:	4721                	li	a4,8
    800055e2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800055e4:	4098                	lw	a4,0(s1)
    800055e6:	100017b7          	lui	a5,0x10001
    800055ea:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800055ee:	40d8                	lw	a4,4(s1)
    800055f0:	100017b7          	lui	a5,0x10001
    800055f4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800055f8:	649c                	ld	a5,8(s1)
    800055fa:	0007869b          	sext.w	a3,a5
    800055fe:	10001737          	lui	a4,0x10001
    80005602:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005606:	9781                	srai	a5,a5,0x20
    80005608:	10001737          	lui	a4,0x10001
    8000560c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005610:	689c                	ld	a5,16(s1)
    80005612:	0007869b          	sext.w	a3,a5
    80005616:	10001737          	lui	a4,0x10001
    8000561a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000561e:	9781                	srai	a5,a5,0x20
    80005620:	10001737          	lui	a4,0x10001
    80005624:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005628:	10001737          	lui	a4,0x10001
    8000562c:	4785                	li	a5,1
    8000562e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005630:	00f48c23          	sb	a5,24(s1)
    80005634:	00f48ca3          	sb	a5,25(s1)
    80005638:	00f48d23          	sb	a5,26(s1)
    8000563c:	00f48da3          	sb	a5,27(s1)
    80005640:	00f48e23          	sb	a5,28(s1)
    80005644:	00f48ea3          	sb	a5,29(s1)
    80005648:	00f48f23          	sb	a5,30(s1)
    8000564c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005650:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005654:	100017b7          	lui	a5,0x10001
    80005658:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000565c:	60e2                	ld	ra,24(sp)
    8000565e:	6442                	ld	s0,16(sp)
    80005660:	64a2                	ld	s1,8(sp)
    80005662:	6902                	ld	s2,0(sp)
    80005664:	6105                	addi	sp,sp,32
    80005666:	8082                	ret
    panic("could not find virtio disk");
    80005668:	00002517          	auipc	a0,0x2
    8000566c:	fd850513          	addi	a0,a0,-40 # 80007640 <etext+0x640>
    80005670:	970fb0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005674:	00002517          	auipc	a0,0x2
    80005678:	fec50513          	addi	a0,a0,-20 # 80007660 <etext+0x660>
    8000567c:	964fb0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    80005680:	00002517          	auipc	a0,0x2
    80005684:	00050513          	mv	a0,a0
    80005688:	958fb0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    8000568c:	00002517          	auipc	a0,0x2
    80005690:	01450513          	addi	a0,a0,20 # 800076a0 <etext+0x6a0>
    80005694:	94cfb0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    80005698:	00002517          	auipc	a0,0x2
    8000569c:	02850513          	addi	a0,a0,40 # 800076c0 <etext+0x6c0>
    800056a0:	940fb0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    800056a4:	00002517          	auipc	a0,0x2
    800056a8:	03c50513          	addi	a0,a0,60 # 800076e0 <etext+0x6e0>
    800056ac:	934fb0ef          	jal	800007e0 <panic>

00000000800056b0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800056b0:	7159                	addi	sp,sp,-112
    800056b2:	f486                	sd	ra,104(sp)
    800056b4:	f0a2                	sd	s0,96(sp)
    800056b6:	eca6                	sd	s1,88(sp)
    800056b8:	e8ca                	sd	s2,80(sp)
    800056ba:	e4ce                	sd	s3,72(sp)
    800056bc:	e0d2                	sd	s4,64(sp)
    800056be:	fc56                	sd	s5,56(sp)
    800056c0:	f85a                	sd	s6,48(sp)
    800056c2:	f45e                	sd	s7,40(sp)
    800056c4:	f062                	sd	s8,32(sp)
    800056c6:	ec66                	sd	s9,24(sp)
    800056c8:	1880                	addi	s0,sp,112
    800056ca:	8a2a                	mv	s4,a0
    800056cc:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800056ce:	00c52c83          	lw	s9,12(a0)
    800056d2:	001c9c9b          	slliw	s9,s9,0x1
    800056d6:	1c82                	slli	s9,s9,0x20
    800056d8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800056dc:	0001e517          	auipc	a0,0x1e
    800056e0:	dd450513          	addi	a0,a0,-556 # 800234b0 <disk+0x128>
    800056e4:	ceafb0ef          	jal	80000bce <acquire>
  for(int i = 0; i < 3; i++){
    800056e8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800056ea:	44a1                	li	s1,8
      disk.free[i] = 0;
    800056ec:	0001eb17          	auipc	s6,0x1e
    800056f0:	c9cb0b13          	addi	s6,s6,-868 # 80023388 <disk>
  for(int i = 0; i < 3; i++){
    800056f4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800056f6:	0001ec17          	auipc	s8,0x1e
    800056fa:	dbac0c13          	addi	s8,s8,-582 # 800234b0 <disk+0x128>
    800056fe:	a8b9                	j	8000575c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005700:	00fb0733          	add	a4,s6,a5
    80005704:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005708:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000570a:	0207c563          	bltz	a5,80005734 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000570e:	2905                	addiw	s2,s2,1
    80005710:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005712:	05590963          	beq	s2,s5,80005764 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005716:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005718:	0001e717          	auipc	a4,0x1e
    8000571c:	c7070713          	addi	a4,a4,-912 # 80023388 <disk>
    80005720:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005722:	01874683          	lbu	a3,24(a4)
    80005726:	fee9                	bnez	a3,80005700 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005728:	2785                	addiw	a5,a5,1
    8000572a:	0705                	addi	a4,a4,1
    8000572c:	fe979be3          	bne	a5,s1,80005722 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005730:	57fd                	li	a5,-1
    80005732:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005734:	01205d63          	blez	s2,8000574e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005738:	f9042503          	lw	a0,-112(s0)
    8000573c:	d07ff0ef          	jal	80005442 <free_desc>
      for(int j = 0; j < i; j++)
    80005740:	4785                	li	a5,1
    80005742:	0127d663          	bge	a5,s2,8000574e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005746:	f9442503          	lw	a0,-108(s0)
    8000574a:	cf9ff0ef          	jal	80005442 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000574e:	85e2                	mv	a1,s8
    80005750:	0001e517          	auipc	a0,0x1e
    80005754:	c5050513          	addi	a0,a0,-944 # 800233a0 <disk+0x18>
    80005758:	f80fc0ef          	jal	80001ed8 <sleep>
  for(int i = 0; i < 3; i++){
    8000575c:	f9040613          	addi	a2,s0,-112
    80005760:	894e                	mv	s2,s3
    80005762:	bf55                	j	80005716 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005764:	f9042503          	lw	a0,-112(s0)
    80005768:	00451693          	slli	a3,a0,0x4

  if(write)
    8000576c:	0001e797          	auipc	a5,0x1e
    80005770:	c1c78793          	addi	a5,a5,-996 # 80023388 <disk>
    80005774:	00a50713          	addi	a4,a0,10
    80005778:	0712                	slli	a4,a4,0x4
    8000577a:	973e                	add	a4,a4,a5
    8000577c:	01703633          	snez	a2,s7
    80005780:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005782:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005786:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000578a:	6398                	ld	a4,0(a5)
    8000578c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000578e:	0a868613          	addi	a2,a3,168
    80005792:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005794:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005796:	6390                	ld	a2,0(a5)
    80005798:	00d605b3          	add	a1,a2,a3
    8000579c:	4741                	li	a4,16
    8000579e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800057a0:	4805                	li	a6,1
    800057a2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800057a6:	f9442703          	lw	a4,-108(s0)
    800057aa:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800057ae:	0712                	slli	a4,a4,0x4
    800057b0:	963a                	add	a2,a2,a4
    800057b2:	058a0593          	addi	a1,s4,88
    800057b6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800057b8:	0007b883          	ld	a7,0(a5)
    800057bc:	9746                	add	a4,a4,a7
    800057be:	40000613          	li	a2,1024
    800057c2:	c710                	sw	a2,8(a4)
  if(write)
    800057c4:	001bb613          	seqz	a2,s7
    800057c8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800057cc:	00166613          	ori	a2,a2,1
    800057d0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800057d4:	f9842583          	lw	a1,-104(s0)
    800057d8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800057dc:	00250613          	addi	a2,a0,2
    800057e0:	0612                	slli	a2,a2,0x4
    800057e2:	963e                	add	a2,a2,a5
    800057e4:	577d                	li	a4,-1
    800057e6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800057ea:	0592                	slli	a1,a1,0x4
    800057ec:	98ae                	add	a7,a7,a1
    800057ee:	03068713          	addi	a4,a3,48
    800057f2:	973e                	add	a4,a4,a5
    800057f4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800057f8:	6398                	ld	a4,0(a5)
    800057fa:	972e                	add	a4,a4,a1
    800057fc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005800:	4689                	li	a3,2
    80005802:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005806:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000580a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000580e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005812:	6794                	ld	a3,8(a5)
    80005814:	0026d703          	lhu	a4,2(a3)
    80005818:	8b1d                	andi	a4,a4,7
    8000581a:	0706                	slli	a4,a4,0x1
    8000581c:	96ba                	add	a3,a3,a4
    8000581e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005822:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005826:	6798                	ld	a4,8(a5)
    80005828:	00275783          	lhu	a5,2(a4)
    8000582c:	2785                	addiw	a5,a5,1
    8000582e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005832:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005836:	100017b7          	lui	a5,0x10001
    8000583a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000583e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005842:	0001e917          	auipc	s2,0x1e
    80005846:	c6e90913          	addi	s2,s2,-914 # 800234b0 <disk+0x128>
  while(b->disk == 1) {
    8000584a:	4485                	li	s1,1
    8000584c:	01079a63          	bne	a5,a6,80005860 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005850:	85ca                	mv	a1,s2
    80005852:	8552                	mv	a0,s4
    80005854:	e84fc0ef          	jal	80001ed8 <sleep>
  while(b->disk == 1) {
    80005858:	004a2783          	lw	a5,4(s4)
    8000585c:	fe978ae3          	beq	a5,s1,80005850 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005860:	f9042903          	lw	s2,-112(s0)
    80005864:	00290713          	addi	a4,s2,2
    80005868:	0712                	slli	a4,a4,0x4
    8000586a:	0001e797          	auipc	a5,0x1e
    8000586e:	b1e78793          	addi	a5,a5,-1250 # 80023388 <disk>
    80005872:	97ba                	add	a5,a5,a4
    80005874:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005878:	0001e997          	auipc	s3,0x1e
    8000587c:	b1098993          	addi	s3,s3,-1264 # 80023388 <disk>
    80005880:	00491713          	slli	a4,s2,0x4
    80005884:	0009b783          	ld	a5,0(s3)
    80005888:	97ba                	add	a5,a5,a4
    8000588a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000588e:	854a                	mv	a0,s2
    80005890:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005894:	bafff0ef          	jal	80005442 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005898:	8885                	andi	s1,s1,1
    8000589a:	f0fd                	bnez	s1,80005880 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000589c:	0001e517          	auipc	a0,0x1e
    800058a0:	c1450513          	addi	a0,a0,-1004 # 800234b0 <disk+0x128>
    800058a4:	bc2fb0ef          	jal	80000c66 <release>
}
    800058a8:	70a6                	ld	ra,104(sp)
    800058aa:	7406                	ld	s0,96(sp)
    800058ac:	64e6                	ld	s1,88(sp)
    800058ae:	6946                	ld	s2,80(sp)
    800058b0:	69a6                	ld	s3,72(sp)
    800058b2:	6a06                	ld	s4,64(sp)
    800058b4:	7ae2                	ld	s5,56(sp)
    800058b6:	7b42                	ld	s6,48(sp)
    800058b8:	7ba2                	ld	s7,40(sp)
    800058ba:	7c02                	ld	s8,32(sp)
    800058bc:	6ce2                	ld	s9,24(sp)
    800058be:	6165                	addi	sp,sp,112
    800058c0:	8082                	ret

00000000800058c2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800058c2:	1101                	addi	sp,sp,-32
    800058c4:	ec06                	sd	ra,24(sp)
    800058c6:	e822                	sd	s0,16(sp)
    800058c8:	e426                	sd	s1,8(sp)
    800058ca:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800058cc:	0001e497          	auipc	s1,0x1e
    800058d0:	abc48493          	addi	s1,s1,-1348 # 80023388 <disk>
    800058d4:	0001e517          	auipc	a0,0x1e
    800058d8:	bdc50513          	addi	a0,a0,-1060 # 800234b0 <disk+0x128>
    800058dc:	af2fb0ef          	jal	80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800058e0:	100017b7          	lui	a5,0x10001
    800058e4:	53b8                	lw	a4,96(a5)
    800058e6:	8b0d                	andi	a4,a4,3
    800058e8:	100017b7          	lui	a5,0x10001
    800058ec:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800058ee:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800058f2:	689c                	ld	a5,16(s1)
    800058f4:	0204d703          	lhu	a4,32(s1)
    800058f8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800058fc:	04f70663          	beq	a4,a5,80005948 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005900:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005904:	6898                	ld	a4,16(s1)
    80005906:	0204d783          	lhu	a5,32(s1)
    8000590a:	8b9d                	andi	a5,a5,7
    8000590c:	078e                	slli	a5,a5,0x3
    8000590e:	97ba                	add	a5,a5,a4
    80005910:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005912:	00278713          	addi	a4,a5,2
    80005916:	0712                	slli	a4,a4,0x4
    80005918:	9726                	add	a4,a4,s1
    8000591a:	01074703          	lbu	a4,16(a4)
    8000591e:	e321                	bnez	a4,8000595e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005920:	0789                	addi	a5,a5,2
    80005922:	0792                	slli	a5,a5,0x4
    80005924:	97a6                	add	a5,a5,s1
    80005926:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005928:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000592c:	df8fc0ef          	jal	80001f24 <wakeup>

    disk.used_idx += 1;
    80005930:	0204d783          	lhu	a5,32(s1)
    80005934:	2785                	addiw	a5,a5,1
    80005936:	17c2                	slli	a5,a5,0x30
    80005938:	93c1                	srli	a5,a5,0x30
    8000593a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000593e:	6898                	ld	a4,16(s1)
    80005940:	00275703          	lhu	a4,2(a4)
    80005944:	faf71ee3          	bne	a4,a5,80005900 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005948:	0001e517          	auipc	a0,0x1e
    8000594c:	b6850513          	addi	a0,a0,-1176 # 800234b0 <disk+0x128>
    80005950:	b16fb0ef          	jal	80000c66 <release>
}
    80005954:	60e2                	ld	ra,24(sp)
    80005956:	6442                	ld	s0,16(sp)
    80005958:	64a2                	ld	s1,8(sp)
    8000595a:	6105                	addi	sp,sp,32
    8000595c:	8082                	ret
      panic("virtio_disk_intr status");
    8000595e:	00002517          	auipc	a0,0x2
    80005962:	d9a50513          	addi	a0,a0,-614 # 800076f8 <etext+0x6f8>
    80005966:	e7bfa0ef          	jal	800007e0 <panic>
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
