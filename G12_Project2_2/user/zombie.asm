
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

0000000000000352 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 352:	1101                	addi	sp,sp,-32
 354:	ec06                	sd	ra,24(sp)
 356:	e822                	sd	s0,16(sp)
 358:	1000                	addi	s0,sp,32
 35a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 35e:	4605                	li	a2,1
 360:	fef40593          	addi	a1,s0,-17
 364:	f6fff0ef          	jal	2d2 <write>
}
 368:	60e2                	ld	ra,24(sp)
 36a:	6442                	ld	s0,16(sp)
 36c:	6105                	addi	sp,sp,32
 36e:	8082                	ret

0000000000000370 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 370:	715d                	addi	sp,sp,-80
 372:	e486                	sd	ra,72(sp)
 374:	e0a2                	sd	s0,64(sp)
 376:	f84a                	sd	s2,48(sp)
 378:	0880                	addi	s0,sp,80
 37a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 37c:	c299                	beqz	a3,382 <printint+0x12>
 37e:	0805c363          	bltz	a1,404 <printint+0x94>
  neg = 0;
 382:	4881                	li	a7,0
 384:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 388:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 38a:	00000517          	auipc	a0,0x0
 38e:	50e50513          	addi	a0,a0,1294 # 898 <digits>
 392:	883e                	mv	a6,a5
 394:	2785                	addiw	a5,a5,1
 396:	02c5f733          	remu	a4,a1,a2
 39a:	972a                	add	a4,a4,a0
 39c:	00074703          	lbu	a4,0(a4)
 3a0:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 3a4:	872e                	mv	a4,a1
 3a6:	02c5d5b3          	divu	a1,a1,a2
 3aa:	0685                	addi	a3,a3,1
 3ac:	fec773e3          	bgeu	a4,a2,392 <printint+0x22>
  if(neg)
 3b0:	00088b63          	beqz	a7,3c6 <printint+0x56>
    buf[i++] = '-';
 3b4:	fd078793          	addi	a5,a5,-48
 3b8:	97a2                	add	a5,a5,s0
 3ba:	02d00713          	li	a4,45
 3be:	fee78423          	sb	a4,-24(a5)
 3c2:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 3c6:	02f05a63          	blez	a5,3fa <printint+0x8a>
 3ca:	fc26                	sd	s1,56(sp)
 3cc:	f44e                	sd	s3,40(sp)
 3ce:	fb840713          	addi	a4,s0,-72
 3d2:	00f704b3          	add	s1,a4,a5
 3d6:	fff70993          	addi	s3,a4,-1
 3da:	99be                	add	s3,s3,a5
 3dc:	37fd                	addiw	a5,a5,-1
 3de:	1782                	slli	a5,a5,0x20
 3e0:	9381                	srli	a5,a5,0x20
 3e2:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 3e6:	fff4c583          	lbu	a1,-1(s1)
 3ea:	854a                	mv	a0,s2
 3ec:	f67ff0ef          	jal	352 <putc>
  while(--i >= 0)
 3f0:	14fd                	addi	s1,s1,-1
 3f2:	ff349ae3          	bne	s1,s3,3e6 <printint+0x76>
 3f6:	74e2                	ld	s1,56(sp)
 3f8:	79a2                	ld	s3,40(sp)
}
 3fa:	60a6                	ld	ra,72(sp)
 3fc:	6406                	ld	s0,64(sp)
 3fe:	7942                	ld	s2,48(sp)
 400:	6161                	addi	sp,sp,80
 402:	8082                	ret
    x = -xx;
 404:	40b005b3          	neg	a1,a1
    neg = 1;
 408:	4885                	li	a7,1
    x = -xx;
 40a:	bfad                	j	384 <printint+0x14>

000000000000040c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 40c:	711d                	addi	sp,sp,-96
 40e:	ec86                	sd	ra,88(sp)
 410:	e8a2                	sd	s0,80(sp)
 412:	e0ca                	sd	s2,64(sp)
 414:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 416:	0005c903          	lbu	s2,0(a1)
 41a:	28090663          	beqz	s2,6a6 <vprintf+0x29a>
 41e:	e4a6                	sd	s1,72(sp)
 420:	fc4e                	sd	s3,56(sp)
 422:	f852                	sd	s4,48(sp)
 424:	f456                	sd	s5,40(sp)
 426:	f05a                	sd	s6,32(sp)
 428:	ec5e                	sd	s7,24(sp)
 42a:	e862                	sd	s8,16(sp)
 42c:	e466                	sd	s9,8(sp)
 42e:	8b2a                	mv	s6,a0
 430:	8a2e                	mv	s4,a1
 432:	8bb2                	mv	s7,a2
  state = 0;
 434:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 436:	4481                	li	s1,0
 438:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 43a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 43e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 442:	06c00c93          	li	s9,108
 446:	a005                	j	466 <vprintf+0x5a>
        putc(fd, c0);
 448:	85ca                	mv	a1,s2
 44a:	855a                	mv	a0,s6
 44c:	f07ff0ef          	jal	352 <putc>
 450:	a019                	j	456 <vprintf+0x4a>
    } else if(state == '%'){
 452:	03598263          	beq	s3,s5,476 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 456:	2485                	addiw	s1,s1,1
 458:	8726                	mv	a4,s1
 45a:	009a07b3          	add	a5,s4,s1
 45e:	0007c903          	lbu	s2,0(a5)
 462:	22090a63          	beqz	s2,696 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 466:	0009079b          	sext.w	a5,s2
    if(state == 0){
 46a:	fe0994e3          	bnez	s3,452 <vprintf+0x46>
      if(c0 == '%'){
 46e:	fd579de3          	bne	a5,s5,448 <vprintf+0x3c>
        state = '%';
 472:	89be                	mv	s3,a5
 474:	b7cd                	j	456 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 476:	00ea06b3          	add	a3,s4,a4
 47a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 47e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 480:	c681                	beqz	a3,488 <vprintf+0x7c>
 482:	9752                	add	a4,a4,s4
 484:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 488:	05878363          	beq	a5,s8,4ce <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 48c:	05978d63          	beq	a5,s9,4e6 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 490:	07500713          	li	a4,117
 494:	0ee78763          	beq	a5,a4,582 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 498:	07800713          	li	a4,120
 49c:	12e78963          	beq	a5,a4,5ce <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4a0:	07000713          	li	a4,112
 4a4:	14e78e63          	beq	a5,a4,600 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 4a8:	06300713          	li	a4,99
 4ac:	18e78e63          	beq	a5,a4,648 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 4b0:	07300713          	li	a4,115
 4b4:	1ae78463          	beq	a5,a4,65c <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4b8:	02500713          	li	a4,37
 4bc:	04e79563          	bne	a5,a4,506 <vprintf+0xfa>
        putc(fd, '%');
 4c0:	02500593          	li	a1,37
 4c4:	855a                	mv	a0,s6
 4c6:	e8dff0ef          	jal	352 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 4ca:	4981                	li	s3,0
 4cc:	b769                	j	456 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 4ce:	008b8913          	addi	s2,s7,8
 4d2:	4685                	li	a3,1
 4d4:	4629                	li	a2,10
 4d6:	000ba583          	lw	a1,0(s7)
 4da:	855a                	mv	a0,s6
 4dc:	e95ff0ef          	jal	370 <printint>
 4e0:	8bca                	mv	s7,s2
      state = 0;
 4e2:	4981                	li	s3,0
 4e4:	bf8d                	j	456 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 4e6:	06400793          	li	a5,100
 4ea:	02f68963          	beq	a3,a5,51c <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 4ee:	06c00793          	li	a5,108
 4f2:	04f68263          	beq	a3,a5,536 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 4f6:	07500793          	li	a5,117
 4fa:	0af68063          	beq	a3,a5,59a <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 4fe:	07800793          	li	a5,120
 502:	0ef68263          	beq	a3,a5,5e6 <vprintf+0x1da>
        putc(fd, '%');
 506:	02500593          	li	a1,37
 50a:	855a                	mv	a0,s6
 50c:	e47ff0ef          	jal	352 <putc>
        putc(fd, c0);
 510:	85ca                	mv	a1,s2
 512:	855a                	mv	a0,s6
 514:	e3fff0ef          	jal	352 <putc>
      state = 0;
 518:	4981                	li	s3,0
 51a:	bf35                	j	456 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 51c:	008b8913          	addi	s2,s7,8
 520:	4685                	li	a3,1
 522:	4629                	li	a2,10
 524:	000bb583          	ld	a1,0(s7)
 528:	855a                	mv	a0,s6
 52a:	e47ff0ef          	jal	370 <printint>
        i += 1;
 52e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 530:	8bca                	mv	s7,s2
      state = 0;
 532:	4981                	li	s3,0
        i += 1;
 534:	b70d                	j	456 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 536:	06400793          	li	a5,100
 53a:	02f60763          	beq	a2,a5,568 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 53e:	07500793          	li	a5,117
 542:	06f60963          	beq	a2,a5,5b4 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 546:	07800793          	li	a5,120
 54a:	faf61ee3          	bne	a2,a5,506 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 54e:	008b8913          	addi	s2,s7,8
 552:	4681                	li	a3,0
 554:	4641                	li	a2,16
 556:	000bb583          	ld	a1,0(s7)
 55a:	855a                	mv	a0,s6
 55c:	e15ff0ef          	jal	370 <printint>
        i += 2;
 560:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 562:	8bca                	mv	s7,s2
      state = 0;
 564:	4981                	li	s3,0
        i += 2;
 566:	bdc5                	j	456 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 568:	008b8913          	addi	s2,s7,8
 56c:	4685                	li	a3,1
 56e:	4629                	li	a2,10
 570:	000bb583          	ld	a1,0(s7)
 574:	855a                	mv	a0,s6
 576:	dfbff0ef          	jal	370 <printint>
        i += 2;
 57a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 57c:	8bca                	mv	s7,s2
      state = 0;
 57e:	4981                	li	s3,0
        i += 2;
 580:	bdd9                	j	456 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 582:	008b8913          	addi	s2,s7,8
 586:	4681                	li	a3,0
 588:	4629                	li	a2,10
 58a:	000be583          	lwu	a1,0(s7)
 58e:	855a                	mv	a0,s6
 590:	de1ff0ef          	jal	370 <printint>
 594:	8bca                	mv	s7,s2
      state = 0;
 596:	4981                	li	s3,0
 598:	bd7d                	j	456 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 59a:	008b8913          	addi	s2,s7,8
 59e:	4681                	li	a3,0
 5a0:	4629                	li	a2,10
 5a2:	000bb583          	ld	a1,0(s7)
 5a6:	855a                	mv	a0,s6
 5a8:	dc9ff0ef          	jal	370 <printint>
        i += 1;
 5ac:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ae:	8bca                	mv	s7,s2
      state = 0;
 5b0:	4981                	li	s3,0
        i += 1;
 5b2:	b555                	j	456 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b4:	008b8913          	addi	s2,s7,8
 5b8:	4681                	li	a3,0
 5ba:	4629                	li	a2,10
 5bc:	000bb583          	ld	a1,0(s7)
 5c0:	855a                	mv	a0,s6
 5c2:	dafff0ef          	jal	370 <printint>
        i += 2;
 5c6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c8:	8bca                	mv	s7,s2
      state = 0;
 5ca:	4981                	li	s3,0
        i += 2;
 5cc:	b569                	j	456 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5ce:	008b8913          	addi	s2,s7,8
 5d2:	4681                	li	a3,0
 5d4:	4641                	li	a2,16
 5d6:	000be583          	lwu	a1,0(s7)
 5da:	855a                	mv	a0,s6
 5dc:	d95ff0ef          	jal	370 <printint>
 5e0:	8bca                	mv	s7,s2
      state = 0;
 5e2:	4981                	li	s3,0
 5e4:	bd8d                	j	456 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e6:	008b8913          	addi	s2,s7,8
 5ea:	4681                	li	a3,0
 5ec:	4641                	li	a2,16
 5ee:	000bb583          	ld	a1,0(s7)
 5f2:	855a                	mv	a0,s6
 5f4:	d7dff0ef          	jal	370 <printint>
        i += 1;
 5f8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5fa:	8bca                	mv	s7,s2
      state = 0;
 5fc:	4981                	li	s3,0
        i += 1;
 5fe:	bda1                	j	456 <vprintf+0x4a>
 600:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 602:	008b8d13          	addi	s10,s7,8
 606:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 60a:	03000593          	li	a1,48
 60e:	855a                	mv	a0,s6
 610:	d43ff0ef          	jal	352 <putc>
  putc(fd, 'x');
 614:	07800593          	li	a1,120
 618:	855a                	mv	a0,s6
 61a:	d39ff0ef          	jal	352 <putc>
 61e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 620:	00000b97          	auipc	s7,0x0
 624:	278b8b93          	addi	s7,s7,632 # 898 <digits>
 628:	03c9d793          	srli	a5,s3,0x3c
 62c:	97de                	add	a5,a5,s7
 62e:	0007c583          	lbu	a1,0(a5)
 632:	855a                	mv	a0,s6
 634:	d1fff0ef          	jal	352 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 638:	0992                	slli	s3,s3,0x4
 63a:	397d                	addiw	s2,s2,-1
 63c:	fe0916e3          	bnez	s2,628 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 640:	8bea                	mv	s7,s10
      state = 0;
 642:	4981                	li	s3,0
 644:	6d02                	ld	s10,0(sp)
 646:	bd01                	j	456 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 648:	008b8913          	addi	s2,s7,8
 64c:	000bc583          	lbu	a1,0(s7)
 650:	855a                	mv	a0,s6
 652:	d01ff0ef          	jal	352 <putc>
 656:	8bca                	mv	s7,s2
      state = 0;
 658:	4981                	li	s3,0
 65a:	bbf5                	j	456 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 65c:	008b8993          	addi	s3,s7,8
 660:	000bb903          	ld	s2,0(s7)
 664:	00090f63          	beqz	s2,682 <vprintf+0x276>
        for(; *s; s++)
 668:	00094583          	lbu	a1,0(s2)
 66c:	c195                	beqz	a1,690 <vprintf+0x284>
          putc(fd, *s);
 66e:	855a                	mv	a0,s6
 670:	ce3ff0ef          	jal	352 <putc>
        for(; *s; s++)
 674:	0905                	addi	s2,s2,1
 676:	00094583          	lbu	a1,0(s2)
 67a:	f9f5                	bnez	a1,66e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 67c:	8bce                	mv	s7,s3
      state = 0;
 67e:	4981                	li	s3,0
 680:	bbd9                	j	456 <vprintf+0x4a>
          s = "(null)";
 682:	00000917          	auipc	s2,0x0
 686:	20e90913          	addi	s2,s2,526 # 890 <malloc+0x102>
        for(; *s; s++)
 68a:	02800593          	li	a1,40
 68e:	b7c5                	j	66e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 690:	8bce                	mv	s7,s3
      state = 0;
 692:	4981                	li	s3,0
 694:	b3c9                	j	456 <vprintf+0x4a>
 696:	64a6                	ld	s1,72(sp)
 698:	79e2                	ld	s3,56(sp)
 69a:	7a42                	ld	s4,48(sp)
 69c:	7aa2                	ld	s5,40(sp)
 69e:	7b02                	ld	s6,32(sp)
 6a0:	6be2                	ld	s7,24(sp)
 6a2:	6c42                	ld	s8,16(sp)
 6a4:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6a6:	60e6                	ld	ra,88(sp)
 6a8:	6446                	ld	s0,80(sp)
 6aa:	6906                	ld	s2,64(sp)
 6ac:	6125                	addi	sp,sp,96
 6ae:	8082                	ret

00000000000006b0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6b0:	715d                	addi	sp,sp,-80
 6b2:	ec06                	sd	ra,24(sp)
 6b4:	e822                	sd	s0,16(sp)
 6b6:	1000                	addi	s0,sp,32
 6b8:	e010                	sd	a2,0(s0)
 6ba:	e414                	sd	a3,8(s0)
 6bc:	e818                	sd	a4,16(s0)
 6be:	ec1c                	sd	a5,24(s0)
 6c0:	03043023          	sd	a6,32(s0)
 6c4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6c8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6cc:	8622                	mv	a2,s0
 6ce:	d3fff0ef          	jal	40c <vprintf>
}
 6d2:	60e2                	ld	ra,24(sp)
 6d4:	6442                	ld	s0,16(sp)
 6d6:	6161                	addi	sp,sp,80
 6d8:	8082                	ret

00000000000006da <printf>:

void
printf(const char *fmt, ...)
{
 6da:	711d                	addi	sp,sp,-96
 6dc:	ec06                	sd	ra,24(sp)
 6de:	e822                	sd	s0,16(sp)
 6e0:	1000                	addi	s0,sp,32
 6e2:	e40c                	sd	a1,8(s0)
 6e4:	e810                	sd	a2,16(s0)
 6e6:	ec14                	sd	a3,24(s0)
 6e8:	f018                	sd	a4,32(s0)
 6ea:	f41c                	sd	a5,40(s0)
 6ec:	03043823          	sd	a6,48(s0)
 6f0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6f4:	00840613          	addi	a2,s0,8
 6f8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6fc:	85aa                	mv	a1,a0
 6fe:	4505                	li	a0,1
 700:	d0dff0ef          	jal	40c <vprintf>
}
 704:	60e2                	ld	ra,24(sp)
 706:	6442                	ld	s0,16(sp)
 708:	6125                	addi	sp,sp,96
 70a:	8082                	ret

000000000000070c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 70c:	1141                	addi	sp,sp,-16
 70e:	e422                	sd	s0,8(sp)
 710:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 712:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 716:	00001797          	auipc	a5,0x1
 71a:	8ea7b783          	ld	a5,-1814(a5) # 1000 <freep>
 71e:	a02d                	j	748 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 720:	4618                	lw	a4,8(a2)
 722:	9f2d                	addw	a4,a4,a1
 724:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 728:	6398                	ld	a4,0(a5)
 72a:	6310                	ld	a2,0(a4)
 72c:	a83d                	j	76a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 72e:	ff852703          	lw	a4,-8(a0)
 732:	9f31                	addw	a4,a4,a2
 734:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 736:	ff053683          	ld	a3,-16(a0)
 73a:	a091                	j	77e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 73c:	6398                	ld	a4,0(a5)
 73e:	00e7e463          	bltu	a5,a4,746 <free+0x3a>
 742:	00e6ea63          	bltu	a3,a4,756 <free+0x4a>
{
 746:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 748:	fed7fae3          	bgeu	a5,a3,73c <free+0x30>
 74c:	6398                	ld	a4,0(a5)
 74e:	00e6e463          	bltu	a3,a4,756 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 752:	fee7eae3          	bltu	a5,a4,746 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 756:	ff852583          	lw	a1,-8(a0)
 75a:	6390                	ld	a2,0(a5)
 75c:	02059813          	slli	a6,a1,0x20
 760:	01c85713          	srli	a4,a6,0x1c
 764:	9736                	add	a4,a4,a3
 766:	fae60de3          	beq	a2,a4,720 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 76a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 76e:	4790                	lw	a2,8(a5)
 770:	02061593          	slli	a1,a2,0x20
 774:	01c5d713          	srli	a4,a1,0x1c
 778:	973e                	add	a4,a4,a5
 77a:	fae68ae3          	beq	a3,a4,72e <free+0x22>
    p->s.ptr = bp->s.ptr;
 77e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 780:	00001717          	auipc	a4,0x1
 784:	88f73023          	sd	a5,-1920(a4) # 1000 <freep>
}
 788:	6422                	ld	s0,8(sp)
 78a:	0141                	addi	sp,sp,16
 78c:	8082                	ret

000000000000078e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 78e:	7139                	addi	sp,sp,-64
 790:	fc06                	sd	ra,56(sp)
 792:	f822                	sd	s0,48(sp)
 794:	f426                	sd	s1,40(sp)
 796:	ec4e                	sd	s3,24(sp)
 798:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 79a:	02051493          	slli	s1,a0,0x20
 79e:	9081                	srli	s1,s1,0x20
 7a0:	04bd                	addi	s1,s1,15
 7a2:	8091                	srli	s1,s1,0x4
 7a4:	0014899b          	addiw	s3,s1,1
 7a8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7aa:	00001517          	auipc	a0,0x1
 7ae:	85653503          	ld	a0,-1962(a0) # 1000 <freep>
 7b2:	c915                	beqz	a0,7e6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7b6:	4798                	lw	a4,8(a5)
 7b8:	08977a63          	bgeu	a4,s1,84c <malloc+0xbe>
 7bc:	f04a                	sd	s2,32(sp)
 7be:	e852                	sd	s4,16(sp)
 7c0:	e456                	sd	s5,8(sp)
 7c2:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7c4:	8a4e                	mv	s4,s3
 7c6:	0009871b          	sext.w	a4,s3
 7ca:	6685                	lui	a3,0x1
 7cc:	00d77363          	bgeu	a4,a3,7d2 <malloc+0x44>
 7d0:	6a05                	lui	s4,0x1
 7d2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7d6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7da:	00001917          	auipc	s2,0x1
 7de:	82690913          	addi	s2,s2,-2010 # 1000 <freep>
  if(p == SBRK_ERROR)
 7e2:	5afd                	li	s5,-1
 7e4:	a081                	j	824 <malloc+0x96>
 7e6:	f04a                	sd	s2,32(sp)
 7e8:	e852                	sd	s4,16(sp)
 7ea:	e456                	sd	s5,8(sp)
 7ec:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7ee:	00001797          	auipc	a5,0x1
 7f2:	82278793          	addi	a5,a5,-2014 # 1010 <base>
 7f6:	00001717          	auipc	a4,0x1
 7fa:	80f73523          	sd	a5,-2038(a4) # 1000 <freep>
 7fe:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 800:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 804:	b7c1                	j	7c4 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 806:	6398                	ld	a4,0(a5)
 808:	e118                	sd	a4,0(a0)
 80a:	a8a9                	j	864 <malloc+0xd6>
  hp->s.size = nu;
 80c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 810:	0541                	addi	a0,a0,16
 812:	efbff0ef          	jal	70c <free>
  return freep;
 816:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 81a:	c12d                	beqz	a0,87c <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 81c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 81e:	4798                	lw	a4,8(a5)
 820:	02977263          	bgeu	a4,s1,844 <malloc+0xb6>
    if(p == freep)
 824:	00093703          	ld	a4,0(s2)
 828:	853e                	mv	a0,a5
 82a:	fef719e3          	bne	a4,a5,81c <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 82e:	8552                	mv	a0,s4
 830:	a4fff0ef          	jal	27e <sbrk>
  if(p == SBRK_ERROR)
 834:	fd551ce3          	bne	a0,s5,80c <malloc+0x7e>
        return 0;
 838:	4501                	li	a0,0
 83a:	7902                	ld	s2,32(sp)
 83c:	6a42                	ld	s4,16(sp)
 83e:	6aa2                	ld	s5,8(sp)
 840:	6b02                	ld	s6,0(sp)
 842:	a03d                	j	870 <malloc+0xe2>
 844:	7902                	ld	s2,32(sp)
 846:	6a42                	ld	s4,16(sp)
 848:	6aa2                	ld	s5,8(sp)
 84a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 84c:	fae48de3          	beq	s1,a4,806 <malloc+0x78>
        p->s.size -= nunits;
 850:	4137073b          	subw	a4,a4,s3
 854:	c798                	sw	a4,8(a5)
        p += p->s.size;
 856:	02071693          	slli	a3,a4,0x20
 85a:	01c6d713          	srli	a4,a3,0x1c
 85e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 860:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 864:	00000717          	auipc	a4,0x0
 868:	78a73e23          	sd	a0,1948(a4) # 1000 <freep>
      return (void*)(p + 1);
 86c:	01078513          	addi	a0,a5,16
  }
}
 870:	70e2                	ld	ra,56(sp)
 872:	7442                	ld	s0,48(sp)
 874:	74a2                	ld	s1,40(sp)
 876:	69e2                	ld	s3,24(sp)
 878:	6121                	addi	sp,sp,64
 87a:	8082                	ret
 87c:	7902                	ld	s2,32(sp)
 87e:	6a42                	ld	s4,16(sp)
 880:	6aa2                	ld	s5,8(sp)
 882:	6b02                	ld	s6,0(sp)
 884:	b7f5                	j	870 <malloc+0xe2>
