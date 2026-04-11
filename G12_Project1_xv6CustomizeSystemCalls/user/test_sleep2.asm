
user/_test_sleep2:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main(){
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    printf("Start\n");
   8:	00001517          	auipc	a0,0x1
   c:	8a850513          	addi	a0,a0,-1880 # 8b0 <malloc+0xfa>
  10:	6f2000ef          	jal	702 <printf>
    sleep2(50);
  14:	03200513          	li	a0,50
  18:	35a000ef          	jal	372 <sleep2>
    printf("End\n");
  1c:	00001517          	auipc	a0,0x1
  20:	89c50513          	addi	a0,a0,-1892 # 8b8 <malloc+0x102>
  24:	6de000ef          	jal	702 <printf>
    exit(0);
  28:	4501                	li	a0,0
  2a:	298000ef          	jal	2c2 <exit>

000000000000002e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  2e:	1141                	addi	sp,sp,-16
  30:	e406                	sd	ra,8(sp)
  32:	e022                	sd	s0,0(sp)
  34:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  36:	fcbff0ef          	jal	0 <main>
  exit(r);
  3a:	288000ef          	jal	2c2 <exit>

000000000000003e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  3e:	1141                	addi	sp,sp,-16
  40:	e422                	sd	s0,8(sp)
  42:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  44:	87aa                	mv	a5,a0
  46:	0585                	addi	a1,a1,1
  48:	0785                	addi	a5,a5,1
  4a:	fff5c703          	lbu	a4,-1(a1)
  4e:	fee78fa3          	sb	a4,-1(a5)
  52:	fb75                	bnez	a4,46 <strcpy+0x8>
    ;
  return os;
}
  54:	6422                	ld	s0,8(sp)
  56:	0141                	addi	sp,sp,16
  58:	8082                	ret

000000000000005a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  5a:	1141                	addi	sp,sp,-16
  5c:	e422                	sd	s0,8(sp)
  5e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  60:	00054783          	lbu	a5,0(a0)
  64:	cb91                	beqz	a5,78 <strcmp+0x1e>
  66:	0005c703          	lbu	a4,0(a1)
  6a:	00f71763          	bne	a4,a5,78 <strcmp+0x1e>
    p++, q++;
  6e:	0505                	addi	a0,a0,1
  70:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  72:	00054783          	lbu	a5,0(a0)
  76:	fbe5                	bnez	a5,66 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  78:	0005c503          	lbu	a0,0(a1)
}
  7c:	40a7853b          	subw	a0,a5,a0
  80:	6422                	ld	s0,8(sp)
  82:	0141                	addi	sp,sp,16
  84:	8082                	ret

0000000000000086 <strlen>:

uint
strlen(const char *s)
{
  86:	1141                	addi	sp,sp,-16
  88:	e422                	sd	s0,8(sp)
  8a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  8c:	00054783          	lbu	a5,0(a0)
  90:	cf91                	beqz	a5,ac <strlen+0x26>
  92:	0505                	addi	a0,a0,1
  94:	87aa                	mv	a5,a0
  96:	86be                	mv	a3,a5
  98:	0785                	addi	a5,a5,1
  9a:	fff7c703          	lbu	a4,-1(a5)
  9e:	ff65                	bnez	a4,96 <strlen+0x10>
  a0:	40a6853b          	subw	a0,a3,a0
  a4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  a6:	6422                	ld	s0,8(sp)
  a8:	0141                	addi	sp,sp,16
  aa:	8082                	ret
  for(n = 0; s[n]; n++)
  ac:	4501                	li	a0,0
  ae:	bfe5                	j	a6 <strlen+0x20>

00000000000000b0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  b0:	1141                	addi	sp,sp,-16
  b2:	e422                	sd	s0,8(sp)
  b4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  b6:	ca19                	beqz	a2,cc <memset+0x1c>
  b8:	87aa                	mv	a5,a0
  ba:	1602                	slli	a2,a2,0x20
  bc:	9201                	srli	a2,a2,0x20
  be:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  c2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  c6:	0785                	addi	a5,a5,1
  c8:	fee79de3          	bne	a5,a4,c2 <memset+0x12>
  }
  return dst;
}
  cc:	6422                	ld	s0,8(sp)
  ce:	0141                	addi	sp,sp,16
  d0:	8082                	ret

00000000000000d2 <strchr>:

char*
strchr(const char *s, char c)
{
  d2:	1141                	addi	sp,sp,-16
  d4:	e422                	sd	s0,8(sp)
  d6:	0800                	addi	s0,sp,16
  for(; *s; s++)
  d8:	00054783          	lbu	a5,0(a0)
  dc:	cb99                	beqz	a5,f2 <strchr+0x20>
    if(*s == c)
  de:	00f58763          	beq	a1,a5,ec <strchr+0x1a>
  for(; *s; s++)
  e2:	0505                	addi	a0,a0,1
  e4:	00054783          	lbu	a5,0(a0)
  e8:	fbfd                	bnez	a5,de <strchr+0xc>
      return (char*)s;
  return 0;
  ea:	4501                	li	a0,0
}
  ec:	6422                	ld	s0,8(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret
  return 0;
  f2:	4501                	li	a0,0
  f4:	bfe5                	j	ec <strchr+0x1a>

00000000000000f6 <gets>:

char*
gets(char *buf, int max)
{
  f6:	711d                	addi	sp,sp,-96
  f8:	ec86                	sd	ra,88(sp)
  fa:	e8a2                	sd	s0,80(sp)
  fc:	e4a6                	sd	s1,72(sp)
  fe:	e0ca                	sd	s2,64(sp)
 100:	fc4e                	sd	s3,56(sp)
 102:	f852                	sd	s4,48(sp)
 104:	f456                	sd	s5,40(sp)
 106:	f05a                	sd	s6,32(sp)
 108:	ec5e                	sd	s7,24(sp)
 10a:	1080                	addi	s0,sp,96
 10c:	8baa                	mv	s7,a0
 10e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 110:	892a                	mv	s2,a0
 112:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 114:	4aa9                	li	s5,10
 116:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 118:	89a6                	mv	s3,s1
 11a:	2485                	addiw	s1,s1,1
 11c:	0344d663          	bge	s1,s4,148 <gets+0x52>
    cc = read(0, &c, 1);
 120:	4605                	li	a2,1
 122:	faf40593          	addi	a1,s0,-81
 126:	4501                	li	a0,0
 128:	1b2000ef          	jal	2da <read>
    if(cc < 1)
 12c:	00a05e63          	blez	a0,148 <gets+0x52>
    buf[i++] = c;
 130:	faf44783          	lbu	a5,-81(s0)
 134:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 138:	01578763          	beq	a5,s5,146 <gets+0x50>
 13c:	0905                	addi	s2,s2,1
 13e:	fd679de3          	bne	a5,s6,118 <gets+0x22>
    buf[i++] = c;
 142:	89a6                	mv	s3,s1
 144:	a011                	j	148 <gets+0x52>
 146:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 148:	99de                	add	s3,s3,s7
 14a:	00098023          	sb	zero,0(s3)
  return buf;
}
 14e:	855e                	mv	a0,s7
 150:	60e6                	ld	ra,88(sp)
 152:	6446                	ld	s0,80(sp)
 154:	64a6                	ld	s1,72(sp)
 156:	6906                	ld	s2,64(sp)
 158:	79e2                	ld	s3,56(sp)
 15a:	7a42                	ld	s4,48(sp)
 15c:	7aa2                	ld	s5,40(sp)
 15e:	7b02                	ld	s6,32(sp)
 160:	6be2                	ld	s7,24(sp)
 162:	6125                	addi	sp,sp,96
 164:	8082                	ret

0000000000000166 <stat>:

int
stat(const char *n, struct stat *st)
{
 166:	1101                	addi	sp,sp,-32
 168:	ec06                	sd	ra,24(sp)
 16a:	e822                	sd	s0,16(sp)
 16c:	e04a                	sd	s2,0(sp)
 16e:	1000                	addi	s0,sp,32
 170:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 172:	4581                	li	a1,0
 174:	18e000ef          	jal	302 <open>
  if(fd < 0)
 178:	02054263          	bltz	a0,19c <stat+0x36>
 17c:	e426                	sd	s1,8(sp)
 17e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 180:	85ca                	mv	a1,s2
 182:	198000ef          	jal	31a <fstat>
 186:	892a                	mv	s2,a0
  close(fd);
 188:	8526                	mv	a0,s1
 18a:	160000ef          	jal	2ea <close>
  return r;
 18e:	64a2                	ld	s1,8(sp)
}
 190:	854a                	mv	a0,s2
 192:	60e2                	ld	ra,24(sp)
 194:	6442                	ld	s0,16(sp)
 196:	6902                	ld	s2,0(sp)
 198:	6105                	addi	sp,sp,32
 19a:	8082                	ret
    return -1;
 19c:	597d                	li	s2,-1
 19e:	bfcd                	j	190 <stat+0x2a>

00000000000001a0 <atoi>:

int
atoi(const char *s)
{
 1a0:	1141                	addi	sp,sp,-16
 1a2:	e422                	sd	s0,8(sp)
 1a4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1a6:	00054683          	lbu	a3,0(a0)
 1aa:	fd06879b          	addiw	a5,a3,-48
 1ae:	0ff7f793          	zext.b	a5,a5
 1b2:	4625                	li	a2,9
 1b4:	02f66863          	bltu	a2,a5,1e4 <atoi+0x44>
 1b8:	872a                	mv	a4,a0
  n = 0;
 1ba:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1bc:	0705                	addi	a4,a4,1
 1be:	0025179b          	slliw	a5,a0,0x2
 1c2:	9fa9                	addw	a5,a5,a0
 1c4:	0017979b          	slliw	a5,a5,0x1
 1c8:	9fb5                	addw	a5,a5,a3
 1ca:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1ce:	00074683          	lbu	a3,0(a4)
 1d2:	fd06879b          	addiw	a5,a3,-48
 1d6:	0ff7f793          	zext.b	a5,a5
 1da:	fef671e3          	bgeu	a2,a5,1bc <atoi+0x1c>
  return n;
}
 1de:	6422                	ld	s0,8(sp)
 1e0:	0141                	addi	sp,sp,16
 1e2:	8082                	ret
  n = 0;
 1e4:	4501                	li	a0,0
 1e6:	bfe5                	j	1de <atoi+0x3e>

00000000000001e8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1e8:	1141                	addi	sp,sp,-16
 1ea:	e422                	sd	s0,8(sp)
 1ec:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1ee:	02b57463          	bgeu	a0,a1,216 <memmove+0x2e>
    while(n-- > 0)
 1f2:	00c05f63          	blez	a2,210 <memmove+0x28>
 1f6:	1602                	slli	a2,a2,0x20
 1f8:	9201                	srli	a2,a2,0x20
 1fa:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 1fe:	872a                	mv	a4,a0
      *dst++ = *src++;
 200:	0585                	addi	a1,a1,1
 202:	0705                	addi	a4,a4,1
 204:	fff5c683          	lbu	a3,-1(a1)
 208:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 20c:	fef71ae3          	bne	a4,a5,200 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 210:	6422                	ld	s0,8(sp)
 212:	0141                	addi	sp,sp,16
 214:	8082                	ret
    dst += n;
 216:	00c50733          	add	a4,a0,a2
    src += n;
 21a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 21c:	fec05ae3          	blez	a2,210 <memmove+0x28>
 220:	fff6079b          	addiw	a5,a2,-1
 224:	1782                	slli	a5,a5,0x20
 226:	9381                	srli	a5,a5,0x20
 228:	fff7c793          	not	a5,a5
 22c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 22e:	15fd                	addi	a1,a1,-1
 230:	177d                	addi	a4,a4,-1
 232:	0005c683          	lbu	a3,0(a1)
 236:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 23a:	fee79ae3          	bne	a5,a4,22e <memmove+0x46>
 23e:	bfc9                	j	210 <memmove+0x28>

0000000000000240 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 240:	1141                	addi	sp,sp,-16
 242:	e422                	sd	s0,8(sp)
 244:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 246:	ca05                	beqz	a2,276 <memcmp+0x36>
 248:	fff6069b          	addiw	a3,a2,-1
 24c:	1682                	slli	a3,a3,0x20
 24e:	9281                	srli	a3,a3,0x20
 250:	0685                	addi	a3,a3,1
 252:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 254:	00054783          	lbu	a5,0(a0)
 258:	0005c703          	lbu	a4,0(a1)
 25c:	00e79863          	bne	a5,a4,26c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 260:	0505                	addi	a0,a0,1
    p2++;
 262:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 264:	fed518e3          	bne	a0,a3,254 <memcmp+0x14>
  }
  return 0;
 268:	4501                	li	a0,0
 26a:	a019                	j	270 <memcmp+0x30>
      return *p1 - *p2;
 26c:	40e7853b          	subw	a0,a5,a4
}
 270:	6422                	ld	s0,8(sp)
 272:	0141                	addi	sp,sp,16
 274:	8082                	ret
  return 0;
 276:	4501                	li	a0,0
 278:	bfe5                	j	270 <memcmp+0x30>

000000000000027a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 27a:	1141                	addi	sp,sp,-16
 27c:	e406                	sd	ra,8(sp)
 27e:	e022                	sd	s0,0(sp)
 280:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 282:	f67ff0ef          	jal	1e8 <memmove>
}
 286:	60a2                	ld	ra,8(sp)
 288:	6402                	ld	s0,0(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret

000000000000028e <sbrk>:

char *
sbrk(int n) {
 28e:	1141                	addi	sp,sp,-16
 290:	e406                	sd	ra,8(sp)
 292:	e022                	sd	s0,0(sp)
 294:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 296:	4585                	li	a1,1
 298:	0b2000ef          	jal	34a <sys_sbrk>
}
 29c:	60a2                	ld	ra,8(sp)
 29e:	6402                	ld	s0,0(sp)
 2a0:	0141                	addi	sp,sp,16
 2a2:	8082                	ret

00000000000002a4 <sbrklazy>:

char *
sbrklazy(int n) {
 2a4:	1141                	addi	sp,sp,-16
 2a6:	e406                	sd	ra,8(sp)
 2a8:	e022                	sd	s0,0(sp)
 2aa:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2ac:	4589                	li	a1,2
 2ae:	09c000ef          	jal	34a <sys_sbrk>
}
 2b2:	60a2                	ld	ra,8(sp)
 2b4:	6402                	ld	s0,0(sp)
 2b6:	0141                	addi	sp,sp,16
 2b8:	8082                	ret

00000000000002ba <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2ba:	4885                	li	a7,1
 ecall
 2bc:	00000073          	ecall
 ret
 2c0:	8082                	ret

00000000000002c2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2c2:	4889                	li	a7,2
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ca:	488d                	li	a7,3
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2d2:	4891                	li	a7,4
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <read>:
.global read
read:
 li a7, SYS_read
 2da:	4895                	li	a7,5
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <write>:
.global write
write:
 li a7, SYS_write
 2e2:	48c1                	li	a7,16
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <close>:
.global close
close:
 li a7, SYS_close
 2ea:	48d5                	li	a7,21
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2f2:	4899                	li	a7,6
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <exec>:
.global exec
exec:
 li a7, SYS_exec
 2fa:	489d                	li	a7,7
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <open>:
.global open
open:
 li a7, SYS_open
 302:	48bd                	li	a7,15
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 30a:	48c5                	li	a7,17
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 312:	48c9                	li	a7,18
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 31a:	48a1                	li	a7,8
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <link>:
.global link
link:
 li a7, SYS_link
 322:	48cd                	li	a7,19
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 32a:	48d1                	li	a7,20
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 332:	48a5                	li	a7,9
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <dup>:
.global dup
dup:
 li a7, SYS_dup
 33a:	48a9                	li	a7,10
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 342:	48ad                	li	a7,11
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 34a:	48b1                	li	a7,12
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <pause>:
.global pause
pause:
 li a7, SYS_pause
 352:	48b5                	li	a7,13
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 35a:	48b9                	li	a7,14
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <getprocsinfo>:
.global getprocsinfo
getprocsinfo:
 li a7, SYS_getprocsinfo
 362:	48d9                	li	a7,22
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 36a:	48dd                	li	a7,23
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <sleep2>:
.global sleep2
sleep2:
 li a7, SYS_sleep2
 372:	48e1                	li	a7,24
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 37a:	1101                	addi	sp,sp,-32
 37c:	ec06                	sd	ra,24(sp)
 37e:	e822                	sd	s0,16(sp)
 380:	1000                	addi	s0,sp,32
 382:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 386:	4605                	li	a2,1
 388:	fef40593          	addi	a1,s0,-17
 38c:	f57ff0ef          	jal	2e2 <write>
}
 390:	60e2                	ld	ra,24(sp)
 392:	6442                	ld	s0,16(sp)
 394:	6105                	addi	sp,sp,32
 396:	8082                	ret

0000000000000398 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 398:	715d                	addi	sp,sp,-80
 39a:	e486                	sd	ra,72(sp)
 39c:	e0a2                	sd	s0,64(sp)
 39e:	f84a                	sd	s2,48(sp)
 3a0:	0880                	addi	s0,sp,80
 3a2:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3a4:	c299                	beqz	a3,3aa <printint+0x12>
 3a6:	0805c363          	bltz	a1,42c <printint+0x94>
  neg = 0;
 3aa:	4881                	li	a7,0
 3ac:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3b0:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3b2:	00000517          	auipc	a0,0x0
 3b6:	51650513          	addi	a0,a0,1302 # 8c8 <digits>
 3ba:	883e                	mv	a6,a5
 3bc:	2785                	addiw	a5,a5,1
 3be:	02c5f733          	remu	a4,a1,a2
 3c2:	972a                	add	a4,a4,a0
 3c4:	00074703          	lbu	a4,0(a4)
 3c8:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 3cc:	872e                	mv	a4,a1
 3ce:	02c5d5b3          	divu	a1,a1,a2
 3d2:	0685                	addi	a3,a3,1
 3d4:	fec773e3          	bgeu	a4,a2,3ba <printint+0x22>
  if(neg)
 3d8:	00088b63          	beqz	a7,3ee <printint+0x56>
    buf[i++] = '-';
 3dc:	fd078793          	addi	a5,a5,-48
 3e0:	97a2                	add	a5,a5,s0
 3e2:	02d00713          	li	a4,45
 3e6:	fee78423          	sb	a4,-24(a5)
 3ea:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 3ee:	02f05a63          	blez	a5,422 <printint+0x8a>
 3f2:	fc26                	sd	s1,56(sp)
 3f4:	f44e                	sd	s3,40(sp)
 3f6:	fb840713          	addi	a4,s0,-72
 3fa:	00f704b3          	add	s1,a4,a5
 3fe:	fff70993          	addi	s3,a4,-1
 402:	99be                	add	s3,s3,a5
 404:	37fd                	addiw	a5,a5,-1
 406:	1782                	slli	a5,a5,0x20
 408:	9381                	srli	a5,a5,0x20
 40a:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 40e:	fff4c583          	lbu	a1,-1(s1)
 412:	854a                	mv	a0,s2
 414:	f67ff0ef          	jal	37a <putc>
  while(--i >= 0)
 418:	14fd                	addi	s1,s1,-1
 41a:	ff349ae3          	bne	s1,s3,40e <printint+0x76>
 41e:	74e2                	ld	s1,56(sp)
 420:	79a2                	ld	s3,40(sp)
}
 422:	60a6                	ld	ra,72(sp)
 424:	6406                	ld	s0,64(sp)
 426:	7942                	ld	s2,48(sp)
 428:	6161                	addi	sp,sp,80
 42a:	8082                	ret
    x = -xx;
 42c:	40b005b3          	neg	a1,a1
    neg = 1;
 430:	4885                	li	a7,1
    x = -xx;
 432:	bfad                	j	3ac <printint+0x14>

0000000000000434 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 434:	711d                	addi	sp,sp,-96
 436:	ec86                	sd	ra,88(sp)
 438:	e8a2                	sd	s0,80(sp)
 43a:	e0ca                	sd	s2,64(sp)
 43c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 43e:	0005c903          	lbu	s2,0(a1)
 442:	28090663          	beqz	s2,6ce <vprintf+0x29a>
 446:	e4a6                	sd	s1,72(sp)
 448:	fc4e                	sd	s3,56(sp)
 44a:	f852                	sd	s4,48(sp)
 44c:	f456                	sd	s5,40(sp)
 44e:	f05a                	sd	s6,32(sp)
 450:	ec5e                	sd	s7,24(sp)
 452:	e862                	sd	s8,16(sp)
 454:	e466                	sd	s9,8(sp)
 456:	8b2a                	mv	s6,a0
 458:	8a2e                	mv	s4,a1
 45a:	8bb2                	mv	s7,a2
  state = 0;
 45c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 45e:	4481                	li	s1,0
 460:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 462:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 466:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 46a:	06c00c93          	li	s9,108
 46e:	a005                	j	48e <vprintf+0x5a>
        putc(fd, c0);
 470:	85ca                	mv	a1,s2
 472:	855a                	mv	a0,s6
 474:	f07ff0ef          	jal	37a <putc>
 478:	a019                	j	47e <vprintf+0x4a>
    } else if(state == '%'){
 47a:	03598263          	beq	s3,s5,49e <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 47e:	2485                	addiw	s1,s1,1
 480:	8726                	mv	a4,s1
 482:	009a07b3          	add	a5,s4,s1
 486:	0007c903          	lbu	s2,0(a5)
 48a:	22090a63          	beqz	s2,6be <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 48e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 492:	fe0994e3          	bnez	s3,47a <vprintf+0x46>
      if(c0 == '%'){
 496:	fd579de3          	bne	a5,s5,470 <vprintf+0x3c>
        state = '%';
 49a:	89be                	mv	s3,a5
 49c:	b7cd                	j	47e <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 49e:	00ea06b3          	add	a3,s4,a4
 4a2:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4a6:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4a8:	c681                	beqz	a3,4b0 <vprintf+0x7c>
 4aa:	9752                	add	a4,a4,s4
 4ac:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4b0:	05878363          	beq	a5,s8,4f6 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 4b4:	05978d63          	beq	a5,s9,50e <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4b8:	07500713          	li	a4,117
 4bc:	0ee78763          	beq	a5,a4,5aa <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4c0:	07800713          	li	a4,120
 4c4:	12e78963          	beq	a5,a4,5f6 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4c8:	07000713          	li	a4,112
 4cc:	14e78e63          	beq	a5,a4,628 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 4d0:	06300713          	li	a4,99
 4d4:	18e78e63          	beq	a5,a4,670 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 4d8:	07300713          	li	a4,115
 4dc:	1ae78463          	beq	a5,a4,684 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4e0:	02500713          	li	a4,37
 4e4:	04e79563          	bne	a5,a4,52e <vprintf+0xfa>
        putc(fd, '%');
 4e8:	02500593          	li	a1,37
 4ec:	855a                	mv	a0,s6
 4ee:	e8dff0ef          	jal	37a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 4f2:	4981                	li	s3,0
 4f4:	b769                	j	47e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 4f6:	008b8913          	addi	s2,s7,8
 4fa:	4685                	li	a3,1
 4fc:	4629                	li	a2,10
 4fe:	000ba583          	lw	a1,0(s7)
 502:	855a                	mv	a0,s6
 504:	e95ff0ef          	jal	398 <printint>
 508:	8bca                	mv	s7,s2
      state = 0;
 50a:	4981                	li	s3,0
 50c:	bf8d                	j	47e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 50e:	06400793          	li	a5,100
 512:	02f68963          	beq	a3,a5,544 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 516:	06c00793          	li	a5,108
 51a:	04f68263          	beq	a3,a5,55e <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 51e:	07500793          	li	a5,117
 522:	0af68063          	beq	a3,a5,5c2 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 526:	07800793          	li	a5,120
 52a:	0ef68263          	beq	a3,a5,60e <vprintf+0x1da>
        putc(fd, '%');
 52e:	02500593          	li	a1,37
 532:	855a                	mv	a0,s6
 534:	e47ff0ef          	jal	37a <putc>
        putc(fd, c0);
 538:	85ca                	mv	a1,s2
 53a:	855a                	mv	a0,s6
 53c:	e3fff0ef          	jal	37a <putc>
      state = 0;
 540:	4981                	li	s3,0
 542:	bf35                	j	47e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 544:	008b8913          	addi	s2,s7,8
 548:	4685                	li	a3,1
 54a:	4629                	li	a2,10
 54c:	000bb583          	ld	a1,0(s7)
 550:	855a                	mv	a0,s6
 552:	e47ff0ef          	jal	398 <printint>
        i += 1;
 556:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 558:	8bca                	mv	s7,s2
      state = 0;
 55a:	4981                	li	s3,0
        i += 1;
 55c:	b70d                	j	47e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 55e:	06400793          	li	a5,100
 562:	02f60763          	beq	a2,a5,590 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 566:	07500793          	li	a5,117
 56a:	06f60963          	beq	a2,a5,5dc <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 56e:	07800793          	li	a5,120
 572:	faf61ee3          	bne	a2,a5,52e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 576:	008b8913          	addi	s2,s7,8
 57a:	4681                	li	a3,0
 57c:	4641                	li	a2,16
 57e:	000bb583          	ld	a1,0(s7)
 582:	855a                	mv	a0,s6
 584:	e15ff0ef          	jal	398 <printint>
        i += 2;
 588:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 58a:	8bca                	mv	s7,s2
      state = 0;
 58c:	4981                	li	s3,0
        i += 2;
 58e:	bdc5                	j	47e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 590:	008b8913          	addi	s2,s7,8
 594:	4685                	li	a3,1
 596:	4629                	li	a2,10
 598:	000bb583          	ld	a1,0(s7)
 59c:	855a                	mv	a0,s6
 59e:	dfbff0ef          	jal	398 <printint>
        i += 2;
 5a2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a4:	8bca                	mv	s7,s2
      state = 0;
 5a6:	4981                	li	s3,0
        i += 2;
 5a8:	bdd9                	j	47e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5aa:	008b8913          	addi	s2,s7,8
 5ae:	4681                	li	a3,0
 5b0:	4629                	li	a2,10
 5b2:	000be583          	lwu	a1,0(s7)
 5b6:	855a                	mv	a0,s6
 5b8:	de1ff0ef          	jal	398 <printint>
 5bc:	8bca                	mv	s7,s2
      state = 0;
 5be:	4981                	li	s3,0
 5c0:	bd7d                	j	47e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c2:	008b8913          	addi	s2,s7,8
 5c6:	4681                	li	a3,0
 5c8:	4629                	li	a2,10
 5ca:	000bb583          	ld	a1,0(s7)
 5ce:	855a                	mv	a0,s6
 5d0:	dc9ff0ef          	jal	398 <printint>
        i += 1;
 5d4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d6:	8bca                	mv	s7,s2
      state = 0;
 5d8:	4981                	li	s3,0
        i += 1;
 5da:	b555                	j	47e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5dc:	008b8913          	addi	s2,s7,8
 5e0:	4681                	li	a3,0
 5e2:	4629                	li	a2,10
 5e4:	000bb583          	ld	a1,0(s7)
 5e8:	855a                	mv	a0,s6
 5ea:	dafff0ef          	jal	398 <printint>
        i += 2;
 5ee:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f0:	8bca                	mv	s7,s2
      state = 0;
 5f2:	4981                	li	s3,0
        i += 2;
 5f4:	b569                	j	47e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5f6:	008b8913          	addi	s2,s7,8
 5fa:	4681                	li	a3,0
 5fc:	4641                	li	a2,16
 5fe:	000be583          	lwu	a1,0(s7)
 602:	855a                	mv	a0,s6
 604:	d95ff0ef          	jal	398 <printint>
 608:	8bca                	mv	s7,s2
      state = 0;
 60a:	4981                	li	s3,0
 60c:	bd8d                	j	47e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 60e:	008b8913          	addi	s2,s7,8
 612:	4681                	li	a3,0
 614:	4641                	li	a2,16
 616:	000bb583          	ld	a1,0(s7)
 61a:	855a                	mv	a0,s6
 61c:	d7dff0ef          	jal	398 <printint>
        i += 1;
 620:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 622:	8bca                	mv	s7,s2
      state = 0;
 624:	4981                	li	s3,0
        i += 1;
 626:	bda1                	j	47e <vprintf+0x4a>
 628:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 62a:	008b8d13          	addi	s10,s7,8
 62e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 632:	03000593          	li	a1,48
 636:	855a                	mv	a0,s6
 638:	d43ff0ef          	jal	37a <putc>
  putc(fd, 'x');
 63c:	07800593          	li	a1,120
 640:	855a                	mv	a0,s6
 642:	d39ff0ef          	jal	37a <putc>
 646:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 648:	00000b97          	auipc	s7,0x0
 64c:	280b8b93          	addi	s7,s7,640 # 8c8 <digits>
 650:	03c9d793          	srli	a5,s3,0x3c
 654:	97de                	add	a5,a5,s7
 656:	0007c583          	lbu	a1,0(a5)
 65a:	855a                	mv	a0,s6
 65c:	d1fff0ef          	jal	37a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 660:	0992                	slli	s3,s3,0x4
 662:	397d                	addiw	s2,s2,-1
 664:	fe0916e3          	bnez	s2,650 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 668:	8bea                	mv	s7,s10
      state = 0;
 66a:	4981                	li	s3,0
 66c:	6d02                	ld	s10,0(sp)
 66e:	bd01                	j	47e <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 670:	008b8913          	addi	s2,s7,8
 674:	000bc583          	lbu	a1,0(s7)
 678:	855a                	mv	a0,s6
 67a:	d01ff0ef          	jal	37a <putc>
 67e:	8bca                	mv	s7,s2
      state = 0;
 680:	4981                	li	s3,0
 682:	bbf5                	j	47e <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 684:	008b8993          	addi	s3,s7,8
 688:	000bb903          	ld	s2,0(s7)
 68c:	00090f63          	beqz	s2,6aa <vprintf+0x276>
        for(; *s; s++)
 690:	00094583          	lbu	a1,0(s2)
 694:	c195                	beqz	a1,6b8 <vprintf+0x284>
          putc(fd, *s);
 696:	855a                	mv	a0,s6
 698:	ce3ff0ef          	jal	37a <putc>
        for(; *s; s++)
 69c:	0905                	addi	s2,s2,1
 69e:	00094583          	lbu	a1,0(s2)
 6a2:	f9f5                	bnez	a1,696 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6a4:	8bce                	mv	s7,s3
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	bbd9                	j	47e <vprintf+0x4a>
          s = "(null)";
 6aa:	00000917          	auipc	s2,0x0
 6ae:	21690913          	addi	s2,s2,534 # 8c0 <malloc+0x10a>
        for(; *s; s++)
 6b2:	02800593          	li	a1,40
 6b6:	b7c5                	j	696 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6b8:	8bce                	mv	s7,s3
      state = 0;
 6ba:	4981                	li	s3,0
 6bc:	b3c9                	j	47e <vprintf+0x4a>
 6be:	64a6                	ld	s1,72(sp)
 6c0:	79e2                	ld	s3,56(sp)
 6c2:	7a42                	ld	s4,48(sp)
 6c4:	7aa2                	ld	s5,40(sp)
 6c6:	7b02                	ld	s6,32(sp)
 6c8:	6be2                	ld	s7,24(sp)
 6ca:	6c42                	ld	s8,16(sp)
 6cc:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6ce:	60e6                	ld	ra,88(sp)
 6d0:	6446                	ld	s0,80(sp)
 6d2:	6906                	ld	s2,64(sp)
 6d4:	6125                	addi	sp,sp,96
 6d6:	8082                	ret

00000000000006d8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6d8:	715d                	addi	sp,sp,-80
 6da:	ec06                	sd	ra,24(sp)
 6dc:	e822                	sd	s0,16(sp)
 6de:	1000                	addi	s0,sp,32
 6e0:	e010                	sd	a2,0(s0)
 6e2:	e414                	sd	a3,8(s0)
 6e4:	e818                	sd	a4,16(s0)
 6e6:	ec1c                	sd	a5,24(s0)
 6e8:	03043023          	sd	a6,32(s0)
 6ec:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6f0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6f4:	8622                	mv	a2,s0
 6f6:	d3fff0ef          	jal	434 <vprintf>
}
 6fa:	60e2                	ld	ra,24(sp)
 6fc:	6442                	ld	s0,16(sp)
 6fe:	6161                	addi	sp,sp,80
 700:	8082                	ret

0000000000000702 <printf>:

void
printf(const char *fmt, ...)
{
 702:	711d                	addi	sp,sp,-96
 704:	ec06                	sd	ra,24(sp)
 706:	e822                	sd	s0,16(sp)
 708:	1000                	addi	s0,sp,32
 70a:	e40c                	sd	a1,8(s0)
 70c:	e810                	sd	a2,16(s0)
 70e:	ec14                	sd	a3,24(s0)
 710:	f018                	sd	a4,32(s0)
 712:	f41c                	sd	a5,40(s0)
 714:	03043823          	sd	a6,48(s0)
 718:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 71c:	00840613          	addi	a2,s0,8
 720:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 724:	85aa                	mv	a1,a0
 726:	4505                	li	a0,1
 728:	d0dff0ef          	jal	434 <vprintf>
}
 72c:	60e2                	ld	ra,24(sp)
 72e:	6442                	ld	s0,16(sp)
 730:	6125                	addi	sp,sp,96
 732:	8082                	ret

0000000000000734 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 734:	1141                	addi	sp,sp,-16
 736:	e422                	sd	s0,8(sp)
 738:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 73a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 73e:	00001797          	auipc	a5,0x1
 742:	8c27b783          	ld	a5,-1854(a5) # 1000 <freep>
 746:	a02d                	j	770 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 748:	4618                	lw	a4,8(a2)
 74a:	9f2d                	addw	a4,a4,a1
 74c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 750:	6398                	ld	a4,0(a5)
 752:	6310                	ld	a2,0(a4)
 754:	a83d                	j	792 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 756:	ff852703          	lw	a4,-8(a0)
 75a:	9f31                	addw	a4,a4,a2
 75c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 75e:	ff053683          	ld	a3,-16(a0)
 762:	a091                	j	7a6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 764:	6398                	ld	a4,0(a5)
 766:	00e7e463          	bltu	a5,a4,76e <free+0x3a>
 76a:	00e6ea63          	bltu	a3,a4,77e <free+0x4a>
{
 76e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 770:	fed7fae3          	bgeu	a5,a3,764 <free+0x30>
 774:	6398                	ld	a4,0(a5)
 776:	00e6e463          	bltu	a3,a4,77e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 77a:	fee7eae3          	bltu	a5,a4,76e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 77e:	ff852583          	lw	a1,-8(a0)
 782:	6390                	ld	a2,0(a5)
 784:	02059813          	slli	a6,a1,0x20
 788:	01c85713          	srli	a4,a6,0x1c
 78c:	9736                	add	a4,a4,a3
 78e:	fae60de3          	beq	a2,a4,748 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 792:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 796:	4790                	lw	a2,8(a5)
 798:	02061593          	slli	a1,a2,0x20
 79c:	01c5d713          	srli	a4,a1,0x1c
 7a0:	973e                	add	a4,a4,a5
 7a2:	fae68ae3          	beq	a3,a4,756 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7a6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7a8:	00001717          	auipc	a4,0x1
 7ac:	84f73c23          	sd	a5,-1960(a4) # 1000 <freep>
}
 7b0:	6422                	ld	s0,8(sp)
 7b2:	0141                	addi	sp,sp,16
 7b4:	8082                	ret

00000000000007b6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7b6:	7139                	addi	sp,sp,-64
 7b8:	fc06                	sd	ra,56(sp)
 7ba:	f822                	sd	s0,48(sp)
 7bc:	f426                	sd	s1,40(sp)
 7be:	ec4e                	sd	s3,24(sp)
 7c0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7c2:	02051493          	slli	s1,a0,0x20
 7c6:	9081                	srli	s1,s1,0x20
 7c8:	04bd                	addi	s1,s1,15
 7ca:	8091                	srli	s1,s1,0x4
 7cc:	0014899b          	addiw	s3,s1,1
 7d0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7d2:	00001517          	auipc	a0,0x1
 7d6:	82e53503          	ld	a0,-2002(a0) # 1000 <freep>
 7da:	c915                	beqz	a0,80e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7dc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7de:	4798                	lw	a4,8(a5)
 7e0:	08977a63          	bgeu	a4,s1,874 <malloc+0xbe>
 7e4:	f04a                	sd	s2,32(sp)
 7e6:	e852                	sd	s4,16(sp)
 7e8:	e456                	sd	s5,8(sp)
 7ea:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7ec:	8a4e                	mv	s4,s3
 7ee:	0009871b          	sext.w	a4,s3
 7f2:	6685                	lui	a3,0x1
 7f4:	00d77363          	bgeu	a4,a3,7fa <malloc+0x44>
 7f8:	6a05                	lui	s4,0x1
 7fa:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7fe:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 802:	00000917          	auipc	s2,0x0
 806:	7fe90913          	addi	s2,s2,2046 # 1000 <freep>
  if(p == SBRK_ERROR)
 80a:	5afd                	li	s5,-1
 80c:	a081                	j	84c <malloc+0x96>
 80e:	f04a                	sd	s2,32(sp)
 810:	e852                	sd	s4,16(sp)
 812:	e456                	sd	s5,8(sp)
 814:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 816:	00000797          	auipc	a5,0x0
 81a:	7fa78793          	addi	a5,a5,2042 # 1010 <base>
 81e:	00000717          	auipc	a4,0x0
 822:	7ef73123          	sd	a5,2018(a4) # 1000 <freep>
 826:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 828:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 82c:	b7c1                	j	7ec <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 82e:	6398                	ld	a4,0(a5)
 830:	e118                	sd	a4,0(a0)
 832:	a8a9                	j	88c <malloc+0xd6>
  hp->s.size = nu;
 834:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 838:	0541                	addi	a0,a0,16
 83a:	efbff0ef          	jal	734 <free>
  return freep;
 83e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 842:	c12d                	beqz	a0,8a4 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 844:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 846:	4798                	lw	a4,8(a5)
 848:	02977263          	bgeu	a4,s1,86c <malloc+0xb6>
    if(p == freep)
 84c:	00093703          	ld	a4,0(s2)
 850:	853e                	mv	a0,a5
 852:	fef719e3          	bne	a4,a5,844 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 856:	8552                	mv	a0,s4
 858:	a37ff0ef          	jal	28e <sbrk>
  if(p == SBRK_ERROR)
 85c:	fd551ce3          	bne	a0,s5,834 <malloc+0x7e>
        return 0;
 860:	4501                	li	a0,0
 862:	7902                	ld	s2,32(sp)
 864:	6a42                	ld	s4,16(sp)
 866:	6aa2                	ld	s5,8(sp)
 868:	6b02                	ld	s6,0(sp)
 86a:	a03d                	j	898 <malloc+0xe2>
 86c:	7902                	ld	s2,32(sp)
 86e:	6a42                	ld	s4,16(sp)
 870:	6aa2                	ld	s5,8(sp)
 872:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 874:	fae48de3          	beq	s1,a4,82e <malloc+0x78>
        p->s.size -= nunits;
 878:	4137073b          	subw	a4,a4,s3
 87c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 87e:	02071693          	slli	a3,a4,0x20
 882:	01c6d713          	srli	a4,a3,0x1c
 886:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 888:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 88c:	00000717          	auipc	a4,0x0
 890:	76a73a23          	sd	a0,1908(a4) # 1000 <freep>
      return (void*)(p + 1);
 894:	01078513          	addi	a0,a5,16
  }
}
 898:	70e2                	ld	ra,56(sp)
 89a:	7442                	ld	s0,48(sp)
 89c:	74a2                	ld	s1,40(sp)
 89e:	69e2                	ld	s3,24(sp)
 8a0:	6121                	addi	sp,sp,64
 8a2:	8082                	ret
 8a4:	7902                	ld	s2,32(sp)
 8a6:	6a42                	ld	s4,16(sp)
 8a8:	6aa2                	ld	s5,8(sp)
 8aa:	6b02                	ld	s6,0(sp)
 8ac:	b7f5                	j	898 <malloc+0xe2>
