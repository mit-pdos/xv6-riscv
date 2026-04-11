
user/_zombie:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if(fork() > 0)
   8:	2a2000ef          	jal	2aa <fork>
   c:	00a04563          	bgtz	a0,16 <main+0x16>
    pause(5);  // Let child exit before parent.
  exit(0);
  10:	4501                	li	a0,0
  12:	2a0000ef          	jal	2b2 <exit>
    pause(5);  // Let child exit before parent.
  16:	4515                	li	a0,5
  18:	32a000ef          	jal	342 <pause>
  1c:	bfd5                	j	10 <main+0x10>

000000000000001e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  1e:	1141                	addi	sp,sp,-16
  20:	e406                	sd	ra,8(sp)
  22:	e022                	sd	s0,0(sp)
  24:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  26:	fdbff0ef          	jal	0 <main>
  exit(r);
  2a:	288000ef          	jal	2b2 <exit>

000000000000002e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  2e:	1141                	addi	sp,sp,-16
  30:	e422                	sd	s0,8(sp)
  32:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  34:	87aa                	mv	a5,a0
  36:	0585                	addi	a1,a1,1
  38:	0785                	addi	a5,a5,1
  3a:	fff5c703          	lbu	a4,-1(a1)
  3e:	fee78fa3          	sb	a4,-1(a5)
  42:	fb75                	bnez	a4,36 <strcpy+0x8>
    ;
  return os;
}
  44:	6422                	ld	s0,8(sp)
  46:	0141                	addi	sp,sp,16
  48:	8082                	ret

000000000000004a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  4a:	1141                	addi	sp,sp,-16
  4c:	e422                	sd	s0,8(sp)
  4e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  50:	00054783          	lbu	a5,0(a0)
  54:	cb91                	beqz	a5,68 <strcmp+0x1e>
  56:	0005c703          	lbu	a4,0(a1)
  5a:	00f71763          	bne	a4,a5,68 <strcmp+0x1e>
    p++, q++;
  5e:	0505                	addi	a0,a0,1
  60:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  62:	00054783          	lbu	a5,0(a0)
  66:	fbe5                	bnez	a5,56 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  68:	0005c503          	lbu	a0,0(a1)
}
  6c:	40a7853b          	subw	a0,a5,a0
  70:	6422                	ld	s0,8(sp)
  72:	0141                	addi	sp,sp,16
  74:	8082                	ret

0000000000000076 <strlen>:

uint
strlen(const char *s)
{
  76:	1141                	addi	sp,sp,-16
  78:	e422                	sd	s0,8(sp)
  7a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  7c:	00054783          	lbu	a5,0(a0)
  80:	cf91                	beqz	a5,9c <strlen+0x26>
  82:	0505                	addi	a0,a0,1
  84:	87aa                	mv	a5,a0
  86:	86be                	mv	a3,a5
  88:	0785                	addi	a5,a5,1
  8a:	fff7c703          	lbu	a4,-1(a5)
  8e:	ff65                	bnez	a4,86 <strlen+0x10>
  90:	40a6853b          	subw	a0,a3,a0
  94:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  96:	6422                	ld	s0,8(sp)
  98:	0141                	addi	sp,sp,16
  9a:	8082                	ret
  for(n = 0; s[n]; n++)
  9c:	4501                	li	a0,0
  9e:	bfe5                	j	96 <strlen+0x20>

00000000000000a0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  a0:	1141                	addi	sp,sp,-16
  a2:	e422                	sd	s0,8(sp)
  a4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  a6:	ca19                	beqz	a2,bc <memset+0x1c>
  a8:	87aa                	mv	a5,a0
  aa:	1602                	slli	a2,a2,0x20
  ac:	9201                	srli	a2,a2,0x20
  ae:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  b2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  b6:	0785                	addi	a5,a5,1
  b8:	fee79de3          	bne	a5,a4,b2 <memset+0x12>
  }
  return dst;
}
  bc:	6422                	ld	s0,8(sp)
  be:	0141                	addi	sp,sp,16
  c0:	8082                	ret

00000000000000c2 <strchr>:

char*
strchr(const char *s, char c)
{
  c2:	1141                	addi	sp,sp,-16
  c4:	e422                	sd	s0,8(sp)
  c6:	0800                	addi	s0,sp,16
  for(; *s; s++)
  c8:	00054783          	lbu	a5,0(a0)
  cc:	cb99                	beqz	a5,e2 <strchr+0x20>
    if(*s == c)
  ce:	00f58763          	beq	a1,a5,dc <strchr+0x1a>
  for(; *s; s++)
  d2:	0505                	addi	a0,a0,1
  d4:	00054783          	lbu	a5,0(a0)
  d8:	fbfd                	bnez	a5,ce <strchr+0xc>
      return (char*)s;
  return 0;
  da:	4501                	li	a0,0
}
  dc:	6422                	ld	s0,8(sp)
  de:	0141                	addi	sp,sp,16
  e0:	8082                	ret
  return 0;
  e2:	4501                	li	a0,0
  e4:	bfe5                	j	dc <strchr+0x1a>

00000000000000e6 <gets>:

char*
gets(char *buf, int max)
{
  e6:	711d                	addi	sp,sp,-96
  e8:	ec86                	sd	ra,88(sp)
  ea:	e8a2                	sd	s0,80(sp)
  ec:	e4a6                	sd	s1,72(sp)
  ee:	e0ca                	sd	s2,64(sp)
  f0:	fc4e                	sd	s3,56(sp)
  f2:	f852                	sd	s4,48(sp)
  f4:	f456                	sd	s5,40(sp)
  f6:	f05a                	sd	s6,32(sp)
  f8:	ec5e                	sd	s7,24(sp)
  fa:	1080                	addi	s0,sp,96
  fc:	8baa                	mv	s7,a0
  fe:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 100:	892a                	mv	s2,a0
 102:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 104:	4aa9                	li	s5,10
 106:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 108:	89a6                	mv	s3,s1
 10a:	2485                	addiw	s1,s1,1
 10c:	0344d663          	bge	s1,s4,138 <gets+0x52>
    cc = read(0, &c, 1);
 110:	4605                	li	a2,1
 112:	faf40593          	addi	a1,s0,-81
 116:	4501                	li	a0,0
 118:	1b2000ef          	jal	2ca <read>
    if(cc < 1)
 11c:	00a05e63          	blez	a0,138 <gets+0x52>
    buf[i++] = c;
 120:	faf44783          	lbu	a5,-81(s0)
 124:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 128:	01578763          	beq	a5,s5,136 <gets+0x50>
 12c:	0905                	addi	s2,s2,1
 12e:	fd679de3          	bne	a5,s6,108 <gets+0x22>
    buf[i++] = c;
 132:	89a6                	mv	s3,s1
 134:	a011                	j	138 <gets+0x52>
 136:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 138:	99de                	add	s3,s3,s7
 13a:	00098023          	sb	zero,0(s3)
  return buf;
}
 13e:	855e                	mv	a0,s7
 140:	60e6                	ld	ra,88(sp)
 142:	6446                	ld	s0,80(sp)
 144:	64a6                	ld	s1,72(sp)
 146:	6906                	ld	s2,64(sp)
 148:	79e2                	ld	s3,56(sp)
 14a:	7a42                	ld	s4,48(sp)
 14c:	7aa2                	ld	s5,40(sp)
 14e:	7b02                	ld	s6,32(sp)
 150:	6be2                	ld	s7,24(sp)
 152:	6125                	addi	sp,sp,96
 154:	8082                	ret

0000000000000156 <stat>:

int
stat(const char *n, struct stat *st)
{
 156:	1101                	addi	sp,sp,-32
 158:	ec06                	sd	ra,24(sp)
 15a:	e822                	sd	s0,16(sp)
 15c:	e04a                	sd	s2,0(sp)
 15e:	1000                	addi	s0,sp,32
 160:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 162:	4581                	li	a1,0
 164:	18e000ef          	jal	2f2 <open>
  if(fd < 0)
 168:	02054263          	bltz	a0,18c <stat+0x36>
 16c:	e426                	sd	s1,8(sp)
 16e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 170:	85ca                	mv	a1,s2
 172:	198000ef          	jal	30a <fstat>
 176:	892a                	mv	s2,a0
  close(fd);
 178:	8526                	mv	a0,s1
 17a:	160000ef          	jal	2da <close>
  return r;
 17e:	64a2                	ld	s1,8(sp)
}
 180:	854a                	mv	a0,s2
 182:	60e2                	ld	ra,24(sp)
 184:	6442                	ld	s0,16(sp)
 186:	6902                	ld	s2,0(sp)
 188:	6105                	addi	sp,sp,32
 18a:	8082                	ret
    return -1;
 18c:	597d                	li	s2,-1
 18e:	bfcd                	j	180 <stat+0x2a>

0000000000000190 <atoi>:

int
atoi(const char *s)
{
 190:	1141                	addi	sp,sp,-16
 192:	e422                	sd	s0,8(sp)
 194:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 196:	00054683          	lbu	a3,0(a0)
 19a:	fd06879b          	addiw	a5,a3,-48
 19e:	0ff7f793          	zext.b	a5,a5
 1a2:	4625                	li	a2,9
 1a4:	02f66863          	bltu	a2,a5,1d4 <atoi+0x44>
 1a8:	872a                	mv	a4,a0
  n = 0;
 1aa:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1ac:	0705                	addi	a4,a4,1
 1ae:	0025179b          	slliw	a5,a0,0x2
 1b2:	9fa9                	addw	a5,a5,a0
 1b4:	0017979b          	slliw	a5,a5,0x1
 1b8:	9fb5                	addw	a5,a5,a3
 1ba:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1be:	00074683          	lbu	a3,0(a4)
 1c2:	fd06879b          	addiw	a5,a3,-48
 1c6:	0ff7f793          	zext.b	a5,a5
 1ca:	fef671e3          	bgeu	a2,a5,1ac <atoi+0x1c>
  return n;
}
 1ce:	6422                	ld	s0,8(sp)
 1d0:	0141                	addi	sp,sp,16
 1d2:	8082                	ret
  n = 0;
 1d4:	4501                	li	a0,0
 1d6:	bfe5                	j	1ce <atoi+0x3e>

00000000000001d8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1d8:	1141                	addi	sp,sp,-16
 1da:	e422                	sd	s0,8(sp)
 1dc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1de:	02b57463          	bgeu	a0,a1,206 <memmove+0x2e>
    while(n-- > 0)
 1e2:	00c05f63          	blez	a2,200 <memmove+0x28>
 1e6:	1602                	slli	a2,a2,0x20
 1e8:	9201                	srli	a2,a2,0x20
 1ea:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 1ee:	872a                	mv	a4,a0
      *dst++ = *src++;
 1f0:	0585                	addi	a1,a1,1
 1f2:	0705                	addi	a4,a4,1
 1f4:	fff5c683          	lbu	a3,-1(a1)
 1f8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 1fc:	fef71ae3          	bne	a4,a5,1f0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 200:	6422                	ld	s0,8(sp)
 202:	0141                	addi	sp,sp,16
 204:	8082                	ret
    dst += n;
 206:	00c50733          	add	a4,a0,a2
    src += n;
 20a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 20c:	fec05ae3          	blez	a2,200 <memmove+0x28>
 210:	fff6079b          	addiw	a5,a2,-1
 214:	1782                	slli	a5,a5,0x20
 216:	9381                	srli	a5,a5,0x20
 218:	fff7c793          	not	a5,a5
 21c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 21e:	15fd                	addi	a1,a1,-1
 220:	177d                	addi	a4,a4,-1
 222:	0005c683          	lbu	a3,0(a1)
 226:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 22a:	fee79ae3          	bne	a5,a4,21e <memmove+0x46>
 22e:	bfc9                	j	200 <memmove+0x28>

0000000000000230 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 230:	1141                	addi	sp,sp,-16
 232:	e422                	sd	s0,8(sp)
 234:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 236:	ca05                	beqz	a2,266 <memcmp+0x36>
 238:	fff6069b          	addiw	a3,a2,-1
 23c:	1682                	slli	a3,a3,0x20
 23e:	9281                	srli	a3,a3,0x20
 240:	0685                	addi	a3,a3,1
 242:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 244:	00054783          	lbu	a5,0(a0)
 248:	0005c703          	lbu	a4,0(a1)
 24c:	00e79863          	bne	a5,a4,25c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 250:	0505                	addi	a0,a0,1
    p2++;
 252:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 254:	fed518e3          	bne	a0,a3,244 <memcmp+0x14>
  }
  return 0;
 258:	4501                	li	a0,0
 25a:	a019                	j	260 <memcmp+0x30>
      return *p1 - *p2;
 25c:	40e7853b          	subw	a0,a5,a4
}
 260:	6422                	ld	s0,8(sp)
 262:	0141                	addi	sp,sp,16
 264:	8082                	ret
  return 0;
 266:	4501                	li	a0,0
 268:	bfe5                	j	260 <memcmp+0x30>

000000000000026a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 26a:	1141                	addi	sp,sp,-16
 26c:	e406                	sd	ra,8(sp)
 26e:	e022                	sd	s0,0(sp)
 270:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 272:	f67ff0ef          	jal	1d8 <memmove>
}
 276:	60a2                	ld	ra,8(sp)
 278:	6402                	ld	s0,0(sp)
 27a:	0141                	addi	sp,sp,16
 27c:	8082                	ret

000000000000027e <sbrk>:

char *
sbrk(int n) {
 27e:	1141                	addi	sp,sp,-16
 280:	e406                	sd	ra,8(sp)
 282:	e022                	sd	s0,0(sp)
 284:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 286:	4585                	li	a1,1
 288:	0b2000ef          	jal	33a <sys_sbrk>
}
 28c:	60a2                	ld	ra,8(sp)
 28e:	6402                	ld	s0,0(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret

0000000000000294 <sbrklazy>:

char *
sbrklazy(int n) {
 294:	1141                	addi	sp,sp,-16
 296:	e406                	sd	ra,8(sp)
 298:	e022                	sd	s0,0(sp)
 29a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 29c:	4589                	li	a1,2
 29e:	09c000ef          	jal	33a <sys_sbrk>
}
 2a2:	60a2                	ld	ra,8(sp)
 2a4:	6402                	ld	s0,0(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret

00000000000002aa <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2aa:	4885                	li	a7,1
 ecall
 2ac:	00000073          	ecall
 ret
 2b0:	8082                	ret

00000000000002b2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2b2:	4889                	li	a7,2
 ecall
 2b4:	00000073          	ecall
 ret
 2b8:	8082                	ret

00000000000002ba <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ba:	488d                	li	a7,3
 ecall
 2bc:	00000073          	ecall
 ret
 2c0:	8082                	ret

00000000000002c2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2c2:	4891                	li	a7,4
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <read>:
.global read
read:
 li a7, SYS_read
 2ca:	4895                	li	a7,5
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <write>:
.global write
write:
 li a7, SYS_write
 2d2:	48c1                	li	a7,16
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <close>:
.global close
close:
 li a7, SYS_close
 2da:	48d5                	li	a7,21
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2e2:	4899                	li	a7,6
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <exec>:
.global exec
exec:
 li a7, SYS_exec
 2ea:	489d                	li	a7,7
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <open>:
.global open
open:
 li a7, SYS_open
 2f2:	48bd                	li	a7,15
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2fa:	48c5                	li	a7,17
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 302:	48c9                	li	a7,18
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 30a:	48a1                	li	a7,8
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <link>:
.global link
link:
 li a7, SYS_link
 312:	48cd                	li	a7,19
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 31a:	48d1                	li	a7,20
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 322:	48a5                	li	a7,9
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <dup>:
.global dup
dup:
 li a7, SYS_dup
 32a:	48a9                	li	a7,10
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 332:	48ad                	li	a7,11
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 33a:	48b1                	li	a7,12
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <pause>:
.global pause
pause:
 li a7, SYS_pause
 342:	48b5                	li	a7,13
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 34a:	48b9                	li	a7,14
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <getprocsinfo>:
.global getprocsinfo
getprocsinfo:
 li a7, SYS_getprocsinfo
 352:	48d9                	li	a7,22
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 35a:	48dd                	li	a7,23
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <sleep2>:
.global sleep2
sleep2:
 li a7, SYS_sleep2
 362:	48e1                	li	a7,24
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 36a:	1101                	addi	sp,sp,-32
 36c:	ec06                	sd	ra,24(sp)
 36e:	e822                	sd	s0,16(sp)
 370:	1000                	addi	s0,sp,32
 372:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 376:	4605                	li	a2,1
 378:	fef40593          	addi	a1,s0,-17
 37c:	f57ff0ef          	jal	2d2 <write>
}
 380:	60e2                	ld	ra,24(sp)
 382:	6442                	ld	s0,16(sp)
 384:	6105                	addi	sp,sp,32
 386:	8082                	ret

0000000000000388 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 388:	715d                	addi	sp,sp,-80
 38a:	e486                	sd	ra,72(sp)
 38c:	e0a2                	sd	s0,64(sp)
 38e:	f84a                	sd	s2,48(sp)
 390:	0880                	addi	s0,sp,80
 392:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 394:	c299                	beqz	a3,39a <printint+0x12>
 396:	0805c363          	bltz	a1,41c <printint+0x94>
  neg = 0;
 39a:	4881                	li	a7,0
 39c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3a0:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3a2:	00000517          	auipc	a0,0x0
 3a6:	50650513          	addi	a0,a0,1286 # 8a8 <digits>
 3aa:	883e                	mv	a6,a5
 3ac:	2785                	addiw	a5,a5,1
 3ae:	02c5f733          	remu	a4,a1,a2
 3b2:	972a                	add	a4,a4,a0
 3b4:	00074703          	lbu	a4,0(a4)
 3b8:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 3bc:	872e                	mv	a4,a1
 3be:	02c5d5b3          	divu	a1,a1,a2
 3c2:	0685                	addi	a3,a3,1
 3c4:	fec773e3          	bgeu	a4,a2,3aa <printint+0x22>
  if(neg)
 3c8:	00088b63          	beqz	a7,3de <printint+0x56>
    buf[i++] = '-';
 3cc:	fd078793          	addi	a5,a5,-48
 3d0:	97a2                	add	a5,a5,s0
 3d2:	02d00713          	li	a4,45
 3d6:	fee78423          	sb	a4,-24(a5)
 3da:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 3de:	02f05a63          	blez	a5,412 <printint+0x8a>
 3e2:	fc26                	sd	s1,56(sp)
 3e4:	f44e                	sd	s3,40(sp)
 3e6:	fb840713          	addi	a4,s0,-72
 3ea:	00f704b3          	add	s1,a4,a5
 3ee:	fff70993          	addi	s3,a4,-1
 3f2:	99be                	add	s3,s3,a5
 3f4:	37fd                	addiw	a5,a5,-1
 3f6:	1782                	slli	a5,a5,0x20
 3f8:	9381                	srli	a5,a5,0x20
 3fa:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 3fe:	fff4c583          	lbu	a1,-1(s1)
 402:	854a                	mv	a0,s2
 404:	f67ff0ef          	jal	36a <putc>
  while(--i >= 0)
 408:	14fd                	addi	s1,s1,-1
 40a:	ff349ae3          	bne	s1,s3,3fe <printint+0x76>
 40e:	74e2                	ld	s1,56(sp)
 410:	79a2                	ld	s3,40(sp)
}
 412:	60a6                	ld	ra,72(sp)
 414:	6406                	ld	s0,64(sp)
 416:	7942                	ld	s2,48(sp)
 418:	6161                	addi	sp,sp,80
 41a:	8082                	ret
    x = -xx;
 41c:	40b005b3          	neg	a1,a1
    neg = 1;
 420:	4885                	li	a7,1
    x = -xx;
 422:	bfad                	j	39c <printint+0x14>

0000000000000424 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 424:	711d                	addi	sp,sp,-96
 426:	ec86                	sd	ra,88(sp)
 428:	e8a2                	sd	s0,80(sp)
 42a:	e0ca                	sd	s2,64(sp)
 42c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 42e:	0005c903          	lbu	s2,0(a1)
 432:	28090663          	beqz	s2,6be <vprintf+0x29a>
 436:	e4a6                	sd	s1,72(sp)
 438:	fc4e                	sd	s3,56(sp)
 43a:	f852                	sd	s4,48(sp)
 43c:	f456                	sd	s5,40(sp)
 43e:	f05a                	sd	s6,32(sp)
 440:	ec5e                	sd	s7,24(sp)
 442:	e862                	sd	s8,16(sp)
 444:	e466                	sd	s9,8(sp)
 446:	8b2a                	mv	s6,a0
 448:	8a2e                	mv	s4,a1
 44a:	8bb2                	mv	s7,a2
  state = 0;
 44c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 44e:	4481                	li	s1,0
 450:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 452:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 456:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 45a:	06c00c93          	li	s9,108
 45e:	a005                	j	47e <vprintf+0x5a>
        putc(fd, c0);
 460:	85ca                	mv	a1,s2
 462:	855a                	mv	a0,s6
 464:	f07ff0ef          	jal	36a <putc>
 468:	a019                	j	46e <vprintf+0x4a>
    } else if(state == '%'){
 46a:	03598263          	beq	s3,s5,48e <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 46e:	2485                	addiw	s1,s1,1
 470:	8726                	mv	a4,s1
 472:	009a07b3          	add	a5,s4,s1
 476:	0007c903          	lbu	s2,0(a5)
 47a:	22090a63          	beqz	s2,6ae <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 47e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 482:	fe0994e3          	bnez	s3,46a <vprintf+0x46>
      if(c0 == '%'){
 486:	fd579de3          	bne	a5,s5,460 <vprintf+0x3c>
        state = '%';
 48a:	89be                	mv	s3,a5
 48c:	b7cd                	j	46e <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 48e:	00ea06b3          	add	a3,s4,a4
 492:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 496:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 498:	c681                	beqz	a3,4a0 <vprintf+0x7c>
 49a:	9752                	add	a4,a4,s4
 49c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4a0:	05878363          	beq	a5,s8,4e6 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 4a4:	05978d63          	beq	a5,s9,4fe <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4a8:	07500713          	li	a4,117
 4ac:	0ee78763          	beq	a5,a4,59a <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4b0:	07800713          	li	a4,120
 4b4:	12e78963          	beq	a5,a4,5e6 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4b8:	07000713          	li	a4,112
 4bc:	14e78e63          	beq	a5,a4,618 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 4c0:	06300713          	li	a4,99
 4c4:	18e78e63          	beq	a5,a4,660 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 4c8:	07300713          	li	a4,115
 4cc:	1ae78463          	beq	a5,a4,674 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4d0:	02500713          	li	a4,37
 4d4:	04e79563          	bne	a5,a4,51e <vprintf+0xfa>
        putc(fd, '%');
 4d8:	02500593          	li	a1,37
 4dc:	855a                	mv	a0,s6
 4de:	e8dff0ef          	jal	36a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 4e2:	4981                	li	s3,0
 4e4:	b769                	j	46e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 4e6:	008b8913          	addi	s2,s7,8
 4ea:	4685                	li	a3,1
 4ec:	4629                	li	a2,10
 4ee:	000ba583          	lw	a1,0(s7)
 4f2:	855a                	mv	a0,s6
 4f4:	e95ff0ef          	jal	388 <printint>
 4f8:	8bca                	mv	s7,s2
      state = 0;
 4fa:	4981                	li	s3,0
 4fc:	bf8d                	j	46e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 4fe:	06400793          	li	a5,100
 502:	02f68963          	beq	a3,a5,534 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 506:	06c00793          	li	a5,108
 50a:	04f68263          	beq	a3,a5,54e <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 50e:	07500793          	li	a5,117
 512:	0af68063          	beq	a3,a5,5b2 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 516:	07800793          	li	a5,120
 51a:	0ef68263          	beq	a3,a5,5fe <vprintf+0x1da>
        putc(fd, '%');
 51e:	02500593          	li	a1,37
 522:	855a                	mv	a0,s6
 524:	e47ff0ef          	jal	36a <putc>
        putc(fd, c0);
 528:	85ca                	mv	a1,s2
 52a:	855a                	mv	a0,s6
 52c:	e3fff0ef          	jal	36a <putc>
      state = 0;
 530:	4981                	li	s3,0
 532:	bf35                	j	46e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 534:	008b8913          	addi	s2,s7,8
 538:	4685                	li	a3,1
 53a:	4629                	li	a2,10
 53c:	000bb583          	ld	a1,0(s7)
 540:	855a                	mv	a0,s6
 542:	e47ff0ef          	jal	388 <printint>
        i += 1;
 546:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 548:	8bca                	mv	s7,s2
      state = 0;
 54a:	4981                	li	s3,0
        i += 1;
 54c:	b70d                	j	46e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 54e:	06400793          	li	a5,100
 552:	02f60763          	beq	a2,a5,580 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 556:	07500793          	li	a5,117
 55a:	06f60963          	beq	a2,a5,5cc <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 55e:	07800793          	li	a5,120
 562:	faf61ee3          	bne	a2,a5,51e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 566:	008b8913          	addi	s2,s7,8
 56a:	4681                	li	a3,0
 56c:	4641                	li	a2,16
 56e:	000bb583          	ld	a1,0(s7)
 572:	855a                	mv	a0,s6
 574:	e15ff0ef          	jal	388 <printint>
        i += 2;
 578:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 57a:	8bca                	mv	s7,s2
      state = 0;
 57c:	4981                	li	s3,0
        i += 2;
 57e:	bdc5                	j	46e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 580:	008b8913          	addi	s2,s7,8
 584:	4685                	li	a3,1
 586:	4629                	li	a2,10
 588:	000bb583          	ld	a1,0(s7)
 58c:	855a                	mv	a0,s6
 58e:	dfbff0ef          	jal	388 <printint>
        i += 2;
 592:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 594:	8bca                	mv	s7,s2
      state = 0;
 596:	4981                	li	s3,0
        i += 2;
 598:	bdd9                	j	46e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 59a:	008b8913          	addi	s2,s7,8
 59e:	4681                	li	a3,0
 5a0:	4629                	li	a2,10
 5a2:	000be583          	lwu	a1,0(s7)
 5a6:	855a                	mv	a0,s6
 5a8:	de1ff0ef          	jal	388 <printint>
 5ac:	8bca                	mv	s7,s2
      state = 0;
 5ae:	4981                	li	s3,0
 5b0:	bd7d                	j	46e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b2:	008b8913          	addi	s2,s7,8
 5b6:	4681                	li	a3,0
 5b8:	4629                	li	a2,10
 5ba:	000bb583          	ld	a1,0(s7)
 5be:	855a                	mv	a0,s6
 5c0:	dc9ff0ef          	jal	388 <printint>
        i += 1;
 5c4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c6:	8bca                	mv	s7,s2
      state = 0;
 5c8:	4981                	li	s3,0
        i += 1;
 5ca:	b555                	j	46e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5cc:	008b8913          	addi	s2,s7,8
 5d0:	4681                	li	a3,0
 5d2:	4629                	li	a2,10
 5d4:	000bb583          	ld	a1,0(s7)
 5d8:	855a                	mv	a0,s6
 5da:	dafff0ef          	jal	388 <printint>
        i += 2;
 5de:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e0:	8bca                	mv	s7,s2
      state = 0;
 5e2:	4981                	li	s3,0
        i += 2;
 5e4:	b569                	j	46e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5e6:	008b8913          	addi	s2,s7,8
 5ea:	4681                	li	a3,0
 5ec:	4641                	li	a2,16
 5ee:	000be583          	lwu	a1,0(s7)
 5f2:	855a                	mv	a0,s6
 5f4:	d95ff0ef          	jal	388 <printint>
 5f8:	8bca                	mv	s7,s2
      state = 0;
 5fa:	4981                	li	s3,0
 5fc:	bd8d                	j	46e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5fe:	008b8913          	addi	s2,s7,8
 602:	4681                	li	a3,0
 604:	4641                	li	a2,16
 606:	000bb583          	ld	a1,0(s7)
 60a:	855a                	mv	a0,s6
 60c:	d7dff0ef          	jal	388 <printint>
        i += 1;
 610:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 612:	8bca                	mv	s7,s2
      state = 0;
 614:	4981                	li	s3,0
        i += 1;
 616:	bda1                	j	46e <vprintf+0x4a>
 618:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 61a:	008b8d13          	addi	s10,s7,8
 61e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 622:	03000593          	li	a1,48
 626:	855a                	mv	a0,s6
 628:	d43ff0ef          	jal	36a <putc>
  putc(fd, 'x');
 62c:	07800593          	li	a1,120
 630:	855a                	mv	a0,s6
 632:	d39ff0ef          	jal	36a <putc>
 636:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 638:	00000b97          	auipc	s7,0x0
 63c:	270b8b93          	addi	s7,s7,624 # 8a8 <digits>
 640:	03c9d793          	srli	a5,s3,0x3c
 644:	97de                	add	a5,a5,s7
 646:	0007c583          	lbu	a1,0(a5)
 64a:	855a                	mv	a0,s6
 64c:	d1fff0ef          	jal	36a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 650:	0992                	slli	s3,s3,0x4
 652:	397d                	addiw	s2,s2,-1
 654:	fe0916e3          	bnez	s2,640 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 658:	8bea                	mv	s7,s10
      state = 0;
 65a:	4981                	li	s3,0
 65c:	6d02                	ld	s10,0(sp)
 65e:	bd01                	j	46e <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 660:	008b8913          	addi	s2,s7,8
 664:	000bc583          	lbu	a1,0(s7)
 668:	855a                	mv	a0,s6
 66a:	d01ff0ef          	jal	36a <putc>
 66e:	8bca                	mv	s7,s2
      state = 0;
 670:	4981                	li	s3,0
 672:	bbf5                	j	46e <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 674:	008b8993          	addi	s3,s7,8
 678:	000bb903          	ld	s2,0(s7)
 67c:	00090f63          	beqz	s2,69a <vprintf+0x276>
        for(; *s; s++)
 680:	00094583          	lbu	a1,0(s2)
 684:	c195                	beqz	a1,6a8 <vprintf+0x284>
          putc(fd, *s);
 686:	855a                	mv	a0,s6
 688:	ce3ff0ef          	jal	36a <putc>
        for(; *s; s++)
 68c:	0905                	addi	s2,s2,1
 68e:	00094583          	lbu	a1,0(s2)
 692:	f9f5                	bnez	a1,686 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 694:	8bce                	mv	s7,s3
      state = 0;
 696:	4981                	li	s3,0
 698:	bbd9                	j	46e <vprintf+0x4a>
          s = "(null)";
 69a:	00000917          	auipc	s2,0x0
 69e:	20690913          	addi	s2,s2,518 # 8a0 <malloc+0xfa>
        for(; *s; s++)
 6a2:	02800593          	li	a1,40
 6a6:	b7c5                	j	686 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6a8:	8bce                	mv	s7,s3
      state = 0;
 6aa:	4981                	li	s3,0
 6ac:	b3c9                	j	46e <vprintf+0x4a>
 6ae:	64a6                	ld	s1,72(sp)
 6b0:	79e2                	ld	s3,56(sp)
 6b2:	7a42                	ld	s4,48(sp)
 6b4:	7aa2                	ld	s5,40(sp)
 6b6:	7b02                	ld	s6,32(sp)
 6b8:	6be2                	ld	s7,24(sp)
 6ba:	6c42                	ld	s8,16(sp)
 6bc:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6be:	60e6                	ld	ra,88(sp)
 6c0:	6446                	ld	s0,80(sp)
 6c2:	6906                	ld	s2,64(sp)
 6c4:	6125                	addi	sp,sp,96
 6c6:	8082                	ret

00000000000006c8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6c8:	715d                	addi	sp,sp,-80
 6ca:	ec06                	sd	ra,24(sp)
 6cc:	e822                	sd	s0,16(sp)
 6ce:	1000                	addi	s0,sp,32
 6d0:	e010                	sd	a2,0(s0)
 6d2:	e414                	sd	a3,8(s0)
 6d4:	e818                	sd	a4,16(s0)
 6d6:	ec1c                	sd	a5,24(s0)
 6d8:	03043023          	sd	a6,32(s0)
 6dc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6e0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6e4:	8622                	mv	a2,s0
 6e6:	d3fff0ef          	jal	424 <vprintf>
}
 6ea:	60e2                	ld	ra,24(sp)
 6ec:	6442                	ld	s0,16(sp)
 6ee:	6161                	addi	sp,sp,80
 6f0:	8082                	ret

00000000000006f2 <printf>:

void
printf(const char *fmt, ...)
{
 6f2:	711d                	addi	sp,sp,-96
 6f4:	ec06                	sd	ra,24(sp)
 6f6:	e822                	sd	s0,16(sp)
 6f8:	1000                	addi	s0,sp,32
 6fa:	e40c                	sd	a1,8(s0)
 6fc:	e810                	sd	a2,16(s0)
 6fe:	ec14                	sd	a3,24(s0)
 700:	f018                	sd	a4,32(s0)
 702:	f41c                	sd	a5,40(s0)
 704:	03043823          	sd	a6,48(s0)
 708:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 70c:	00840613          	addi	a2,s0,8
 710:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 714:	85aa                	mv	a1,a0
 716:	4505                	li	a0,1
 718:	d0dff0ef          	jal	424 <vprintf>
}
 71c:	60e2                	ld	ra,24(sp)
 71e:	6442                	ld	s0,16(sp)
 720:	6125                	addi	sp,sp,96
 722:	8082                	ret

0000000000000724 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 724:	1141                	addi	sp,sp,-16
 726:	e422                	sd	s0,8(sp)
 728:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 72a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 72e:	00001797          	auipc	a5,0x1
 732:	8d27b783          	ld	a5,-1838(a5) # 1000 <freep>
 736:	a02d                	j	760 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 738:	4618                	lw	a4,8(a2)
 73a:	9f2d                	addw	a4,a4,a1
 73c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 740:	6398                	ld	a4,0(a5)
 742:	6310                	ld	a2,0(a4)
 744:	a83d                	j	782 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 746:	ff852703          	lw	a4,-8(a0)
 74a:	9f31                	addw	a4,a4,a2
 74c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 74e:	ff053683          	ld	a3,-16(a0)
 752:	a091                	j	796 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 754:	6398                	ld	a4,0(a5)
 756:	00e7e463          	bltu	a5,a4,75e <free+0x3a>
 75a:	00e6ea63          	bltu	a3,a4,76e <free+0x4a>
{
 75e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 760:	fed7fae3          	bgeu	a5,a3,754 <free+0x30>
 764:	6398                	ld	a4,0(a5)
 766:	00e6e463          	bltu	a3,a4,76e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 76a:	fee7eae3          	bltu	a5,a4,75e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 76e:	ff852583          	lw	a1,-8(a0)
 772:	6390                	ld	a2,0(a5)
 774:	02059813          	slli	a6,a1,0x20
 778:	01c85713          	srli	a4,a6,0x1c
 77c:	9736                	add	a4,a4,a3
 77e:	fae60de3          	beq	a2,a4,738 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 782:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 786:	4790                	lw	a2,8(a5)
 788:	02061593          	slli	a1,a2,0x20
 78c:	01c5d713          	srli	a4,a1,0x1c
 790:	973e                	add	a4,a4,a5
 792:	fae68ae3          	beq	a3,a4,746 <free+0x22>
    p->s.ptr = bp->s.ptr;
 796:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 798:	00001717          	auipc	a4,0x1
 79c:	86f73423          	sd	a5,-1944(a4) # 1000 <freep>
}
 7a0:	6422                	ld	s0,8(sp)
 7a2:	0141                	addi	sp,sp,16
 7a4:	8082                	ret

00000000000007a6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7a6:	7139                	addi	sp,sp,-64
 7a8:	fc06                	sd	ra,56(sp)
 7aa:	f822                	sd	s0,48(sp)
 7ac:	f426                	sd	s1,40(sp)
 7ae:	ec4e                	sd	s3,24(sp)
 7b0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7b2:	02051493          	slli	s1,a0,0x20
 7b6:	9081                	srli	s1,s1,0x20
 7b8:	04bd                	addi	s1,s1,15
 7ba:	8091                	srli	s1,s1,0x4
 7bc:	0014899b          	addiw	s3,s1,1
 7c0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7c2:	00001517          	auipc	a0,0x1
 7c6:	83e53503          	ld	a0,-1986(a0) # 1000 <freep>
 7ca:	c915                	beqz	a0,7fe <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7cc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ce:	4798                	lw	a4,8(a5)
 7d0:	08977a63          	bgeu	a4,s1,864 <malloc+0xbe>
 7d4:	f04a                	sd	s2,32(sp)
 7d6:	e852                	sd	s4,16(sp)
 7d8:	e456                	sd	s5,8(sp)
 7da:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7dc:	8a4e                	mv	s4,s3
 7de:	0009871b          	sext.w	a4,s3
 7e2:	6685                	lui	a3,0x1
 7e4:	00d77363          	bgeu	a4,a3,7ea <malloc+0x44>
 7e8:	6a05                	lui	s4,0x1
 7ea:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7ee:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7f2:	00001917          	auipc	s2,0x1
 7f6:	80e90913          	addi	s2,s2,-2034 # 1000 <freep>
  if(p == SBRK_ERROR)
 7fa:	5afd                	li	s5,-1
 7fc:	a081                	j	83c <malloc+0x96>
 7fe:	f04a                	sd	s2,32(sp)
 800:	e852                	sd	s4,16(sp)
 802:	e456                	sd	s5,8(sp)
 804:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 806:	00001797          	auipc	a5,0x1
 80a:	80a78793          	addi	a5,a5,-2038 # 1010 <base>
 80e:	00000717          	auipc	a4,0x0
 812:	7ef73923          	sd	a5,2034(a4) # 1000 <freep>
 816:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 818:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 81c:	b7c1                	j	7dc <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 81e:	6398                	ld	a4,0(a5)
 820:	e118                	sd	a4,0(a0)
 822:	a8a9                	j	87c <malloc+0xd6>
  hp->s.size = nu;
 824:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 828:	0541                	addi	a0,a0,16
 82a:	efbff0ef          	jal	724 <free>
  return freep;
 82e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 832:	c12d                	beqz	a0,894 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 834:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 836:	4798                	lw	a4,8(a5)
 838:	02977263          	bgeu	a4,s1,85c <malloc+0xb6>
    if(p == freep)
 83c:	00093703          	ld	a4,0(s2)
 840:	853e                	mv	a0,a5
 842:	fef719e3          	bne	a4,a5,834 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 846:	8552                	mv	a0,s4
 848:	a37ff0ef          	jal	27e <sbrk>
  if(p == SBRK_ERROR)
 84c:	fd551ce3          	bne	a0,s5,824 <malloc+0x7e>
        return 0;
 850:	4501                	li	a0,0
 852:	7902                	ld	s2,32(sp)
 854:	6a42                	ld	s4,16(sp)
 856:	6aa2                	ld	s5,8(sp)
 858:	6b02                	ld	s6,0(sp)
 85a:	a03d                	j	888 <malloc+0xe2>
 85c:	7902                	ld	s2,32(sp)
 85e:	6a42                	ld	s4,16(sp)
 860:	6aa2                	ld	s5,8(sp)
 862:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 864:	fae48de3          	beq	s1,a4,81e <malloc+0x78>
        p->s.size -= nunits;
 868:	4137073b          	subw	a4,a4,s3
 86c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 86e:	02071693          	slli	a3,a4,0x20
 872:	01c6d713          	srli	a4,a3,0x1c
 876:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 878:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 87c:	00000717          	auipc	a4,0x0
 880:	78a73223          	sd	a0,1924(a4) # 1000 <freep>
      return (void*)(p + 1);
 884:	01078513          	addi	a0,a5,16
  }
}
 888:	70e2                	ld	ra,56(sp)
 88a:	7442                	ld	s0,48(sp)
 88c:	74a2                	ld	s1,40(sp)
 88e:	69e2                	ld	s3,24(sp)
 890:	6121                	addi	sp,sp,64
 892:	8082                	ret
 894:	7902                	ld	s2,32(sp)
 896:	6a42                	ld	s4,16(sp)
 898:	6aa2                	ld	s5,8(sp)
 89a:	6b02                	ld	s6,0(sp)
 89c:	b7f5                	j	888 <malloc+0xe2>
