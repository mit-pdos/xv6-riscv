
user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	addi	s0,sp,64
  int i;

  for(i = 1; i < argc; i++){
  12:	4785                	li	a5,1
  14:	06a7d063          	bge	a5,a0,74 <main+0x74>
  18:	00858493          	addi	s1,a1,8
  1c:	3579                	addiw	a0,a0,-2
  1e:	02051793          	slli	a5,a0,0x20
  22:	01d7d513          	srli	a0,a5,0x1d
  26:	00a48a33          	add	s4,s1,a0
  2a:	05c1                	addi	a1,a1,16
  2c:	00a589b3          	add	s3,a1,a0
    write(1, argv[i], strlen(argv[i]));
    if(i + 1 < argc){
      write(1, " ", 1);
  30:	00001a97          	auipc	s5,0x1
  34:	8c0a8a93          	addi	s5,s5,-1856 # 8f0 <malloc+0x106>
  38:	a809                	j	4a <main+0x4a>
  3a:	4605                	li	a2,1
  3c:	85d6                	mv	a1,s5
  3e:	4505                	li	a0,1
  40:	2ee000ef          	jal	32e <write>
  for(i = 1; i < argc; i++){
  44:	04a1                	addi	s1,s1,8
  46:	03348763          	beq	s1,s3,74 <main+0x74>
    write(1, argv[i], strlen(argv[i]));
  4a:	0004b903          	ld	s2,0(s1)
  4e:	854a                	mv	a0,s2
  50:	082000ef          	jal	d2 <strlen>
  54:	0005061b          	sext.w	a2,a0
  58:	85ca                	mv	a1,s2
  5a:	4505                	li	a0,1
  5c:	2d2000ef          	jal	32e <write>
    if(i + 1 < argc){
  60:	fd449de3          	bne	s1,s4,3a <main+0x3a>
    } else {
      write(1, "\n", 1);
  64:	4605                	li	a2,1
  66:	00001597          	auipc	a1,0x1
  6a:	89258593          	addi	a1,a1,-1902 # 8f8 <malloc+0x10e>
  6e:	4505                	li	a0,1
  70:	2be000ef          	jal	32e <write>
    }
  }
  exit(0);
  74:	4501                	li	a0,0
  76:	298000ef          	jal	30e <exit>

000000000000007a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  7a:	1141                	addi	sp,sp,-16
  7c:	e406                	sd	ra,8(sp)
  7e:	e022                	sd	s0,0(sp)
  80:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  82:	f7fff0ef          	jal	0 <main>
  exit(r);
  86:	288000ef          	jal	30e <exit>

000000000000008a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  8a:	1141                	addi	sp,sp,-16
  8c:	e422                	sd	s0,8(sp)
  8e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  90:	87aa                	mv	a5,a0
  92:	0585                	addi	a1,a1,1
  94:	0785                	addi	a5,a5,1
  96:	fff5c703          	lbu	a4,-1(a1)
  9a:	fee78fa3          	sb	a4,-1(a5)
  9e:	fb75                	bnez	a4,92 <strcpy+0x8>
    ;
  return os;
}
  a0:	6422                	ld	s0,8(sp)
  a2:	0141                	addi	sp,sp,16
  a4:	8082                	ret

00000000000000a6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a6:	1141                	addi	sp,sp,-16
  a8:	e422                	sd	s0,8(sp)
  aa:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ac:	00054783          	lbu	a5,0(a0)
  b0:	cb91                	beqz	a5,c4 <strcmp+0x1e>
  b2:	0005c703          	lbu	a4,0(a1)
  b6:	00f71763          	bne	a4,a5,c4 <strcmp+0x1e>
    p++, q++;
  ba:	0505                	addi	a0,a0,1
  bc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  be:	00054783          	lbu	a5,0(a0)
  c2:	fbe5                	bnez	a5,b2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  c4:	0005c503          	lbu	a0,0(a1)
}
  c8:	40a7853b          	subw	a0,a5,a0
  cc:	6422                	ld	s0,8(sp)
  ce:	0141                	addi	sp,sp,16
  d0:	8082                	ret

00000000000000d2 <strlen>:

uint
strlen(const char *s)
{
  d2:	1141                	addi	sp,sp,-16
  d4:	e422                	sd	s0,8(sp)
  d6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  d8:	00054783          	lbu	a5,0(a0)
  dc:	cf91                	beqz	a5,f8 <strlen+0x26>
  de:	0505                	addi	a0,a0,1
  e0:	87aa                	mv	a5,a0
  e2:	86be                	mv	a3,a5
  e4:	0785                	addi	a5,a5,1
  e6:	fff7c703          	lbu	a4,-1(a5)
  ea:	ff65                	bnez	a4,e2 <strlen+0x10>
  ec:	40a6853b          	subw	a0,a3,a0
  f0:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  f2:	6422                	ld	s0,8(sp)
  f4:	0141                	addi	sp,sp,16
  f6:	8082                	ret
  for(n = 0; s[n]; n++)
  f8:	4501                	li	a0,0
  fa:	bfe5                	j	f2 <strlen+0x20>

00000000000000fc <memset>:

void*
memset(void *dst, int c, uint n)
{
  fc:	1141                	addi	sp,sp,-16
  fe:	e422                	sd	s0,8(sp)
 100:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 102:	ca19                	beqz	a2,118 <memset+0x1c>
 104:	87aa                	mv	a5,a0
 106:	1602                	slli	a2,a2,0x20
 108:	9201                	srli	a2,a2,0x20
 10a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 10e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 112:	0785                	addi	a5,a5,1
 114:	fee79de3          	bne	a5,a4,10e <memset+0x12>
  }
  return dst;
}
 118:	6422                	ld	s0,8(sp)
 11a:	0141                	addi	sp,sp,16
 11c:	8082                	ret

000000000000011e <strchr>:

char*
strchr(const char *s, char c)
{
 11e:	1141                	addi	sp,sp,-16
 120:	e422                	sd	s0,8(sp)
 122:	0800                	addi	s0,sp,16
  for(; *s; s++)
 124:	00054783          	lbu	a5,0(a0)
 128:	cb99                	beqz	a5,13e <strchr+0x20>
    if(*s == c)
 12a:	00f58763          	beq	a1,a5,138 <strchr+0x1a>
  for(; *s; s++)
 12e:	0505                	addi	a0,a0,1
 130:	00054783          	lbu	a5,0(a0)
 134:	fbfd                	bnez	a5,12a <strchr+0xc>
      return (char*)s;
  return 0;
 136:	4501                	li	a0,0
}
 138:	6422                	ld	s0,8(sp)
 13a:	0141                	addi	sp,sp,16
 13c:	8082                	ret
  return 0;
 13e:	4501                	li	a0,0
 140:	bfe5                	j	138 <strchr+0x1a>

0000000000000142 <gets>:

char*
gets(char *buf, int max)
{
 142:	711d                	addi	sp,sp,-96
 144:	ec86                	sd	ra,88(sp)
 146:	e8a2                	sd	s0,80(sp)
 148:	e4a6                	sd	s1,72(sp)
 14a:	e0ca                	sd	s2,64(sp)
 14c:	fc4e                	sd	s3,56(sp)
 14e:	f852                	sd	s4,48(sp)
 150:	f456                	sd	s5,40(sp)
 152:	f05a                	sd	s6,32(sp)
 154:	ec5e                	sd	s7,24(sp)
 156:	1080                	addi	s0,sp,96
 158:	8baa                	mv	s7,a0
 15a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 15c:	892a                	mv	s2,a0
 15e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 160:	4aa9                	li	s5,10
 162:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 164:	89a6                	mv	s3,s1
 166:	2485                	addiw	s1,s1,1
 168:	0344d663          	bge	s1,s4,194 <gets+0x52>
    cc = read(0, &c, 1);
 16c:	4605                	li	a2,1
 16e:	faf40593          	addi	a1,s0,-81
 172:	4501                	li	a0,0
 174:	1b2000ef          	jal	326 <read>
    if(cc < 1)
 178:	00a05e63          	blez	a0,194 <gets+0x52>
    buf[i++] = c;
 17c:	faf44783          	lbu	a5,-81(s0)
 180:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 184:	01578763          	beq	a5,s5,192 <gets+0x50>
 188:	0905                	addi	s2,s2,1
 18a:	fd679de3          	bne	a5,s6,164 <gets+0x22>
    buf[i++] = c;
 18e:	89a6                	mv	s3,s1
 190:	a011                	j	194 <gets+0x52>
 192:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 194:	99de                	add	s3,s3,s7
 196:	00098023          	sb	zero,0(s3)
  return buf;
}
 19a:	855e                	mv	a0,s7
 19c:	60e6                	ld	ra,88(sp)
 19e:	6446                	ld	s0,80(sp)
 1a0:	64a6                	ld	s1,72(sp)
 1a2:	6906                	ld	s2,64(sp)
 1a4:	79e2                	ld	s3,56(sp)
 1a6:	7a42                	ld	s4,48(sp)
 1a8:	7aa2                	ld	s5,40(sp)
 1aa:	7b02                	ld	s6,32(sp)
 1ac:	6be2                	ld	s7,24(sp)
 1ae:	6125                	addi	sp,sp,96
 1b0:	8082                	ret

00000000000001b2 <stat>:

int
stat(const char *n, struct stat *st)
{
 1b2:	1101                	addi	sp,sp,-32
 1b4:	ec06                	sd	ra,24(sp)
 1b6:	e822                	sd	s0,16(sp)
 1b8:	e04a                	sd	s2,0(sp)
 1ba:	1000                	addi	s0,sp,32
 1bc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1be:	4581                	li	a1,0
 1c0:	18e000ef          	jal	34e <open>
  if(fd < 0)
 1c4:	02054263          	bltz	a0,1e8 <stat+0x36>
 1c8:	e426                	sd	s1,8(sp)
 1ca:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1cc:	85ca                	mv	a1,s2
 1ce:	198000ef          	jal	366 <fstat>
 1d2:	892a                	mv	s2,a0
  close(fd);
 1d4:	8526                	mv	a0,s1
 1d6:	160000ef          	jal	336 <close>
  return r;
 1da:	64a2                	ld	s1,8(sp)
}
 1dc:	854a                	mv	a0,s2
 1de:	60e2                	ld	ra,24(sp)
 1e0:	6442                	ld	s0,16(sp)
 1e2:	6902                	ld	s2,0(sp)
 1e4:	6105                	addi	sp,sp,32
 1e6:	8082                	ret
    return -1;
 1e8:	597d                	li	s2,-1
 1ea:	bfcd                	j	1dc <stat+0x2a>

00000000000001ec <atoi>:

int
atoi(const char *s)
{
 1ec:	1141                	addi	sp,sp,-16
 1ee:	e422                	sd	s0,8(sp)
 1f0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1f2:	00054683          	lbu	a3,0(a0)
 1f6:	fd06879b          	addiw	a5,a3,-48
 1fa:	0ff7f793          	zext.b	a5,a5
 1fe:	4625                	li	a2,9
 200:	02f66863          	bltu	a2,a5,230 <atoi+0x44>
 204:	872a                	mv	a4,a0
  n = 0;
 206:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 208:	0705                	addi	a4,a4,1
 20a:	0025179b          	slliw	a5,a0,0x2
 20e:	9fa9                	addw	a5,a5,a0
 210:	0017979b          	slliw	a5,a5,0x1
 214:	9fb5                	addw	a5,a5,a3
 216:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 21a:	00074683          	lbu	a3,0(a4)
 21e:	fd06879b          	addiw	a5,a3,-48
 222:	0ff7f793          	zext.b	a5,a5
 226:	fef671e3          	bgeu	a2,a5,208 <atoi+0x1c>
  return n;
}
 22a:	6422                	ld	s0,8(sp)
 22c:	0141                	addi	sp,sp,16
 22e:	8082                	ret
  n = 0;
 230:	4501                	li	a0,0
 232:	bfe5                	j	22a <atoi+0x3e>

0000000000000234 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 234:	1141                	addi	sp,sp,-16
 236:	e422                	sd	s0,8(sp)
 238:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 23a:	02b57463          	bgeu	a0,a1,262 <memmove+0x2e>
    while(n-- > 0)
 23e:	00c05f63          	blez	a2,25c <memmove+0x28>
 242:	1602                	slli	a2,a2,0x20
 244:	9201                	srli	a2,a2,0x20
 246:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 24a:	872a                	mv	a4,a0
      *dst++ = *src++;
 24c:	0585                	addi	a1,a1,1
 24e:	0705                	addi	a4,a4,1
 250:	fff5c683          	lbu	a3,-1(a1)
 254:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 258:	fef71ae3          	bne	a4,a5,24c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 25c:	6422                	ld	s0,8(sp)
 25e:	0141                	addi	sp,sp,16
 260:	8082                	ret
    dst += n;
 262:	00c50733          	add	a4,a0,a2
    src += n;
 266:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 268:	fec05ae3          	blez	a2,25c <memmove+0x28>
 26c:	fff6079b          	addiw	a5,a2,-1
 270:	1782                	slli	a5,a5,0x20
 272:	9381                	srli	a5,a5,0x20
 274:	fff7c793          	not	a5,a5
 278:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 27a:	15fd                	addi	a1,a1,-1
 27c:	177d                	addi	a4,a4,-1
 27e:	0005c683          	lbu	a3,0(a1)
 282:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 286:	fee79ae3          	bne	a5,a4,27a <memmove+0x46>
 28a:	bfc9                	j	25c <memmove+0x28>

000000000000028c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e422                	sd	s0,8(sp)
 290:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 292:	ca05                	beqz	a2,2c2 <memcmp+0x36>
 294:	fff6069b          	addiw	a3,a2,-1
 298:	1682                	slli	a3,a3,0x20
 29a:	9281                	srli	a3,a3,0x20
 29c:	0685                	addi	a3,a3,1
 29e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2a0:	00054783          	lbu	a5,0(a0)
 2a4:	0005c703          	lbu	a4,0(a1)
 2a8:	00e79863          	bne	a5,a4,2b8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2ac:	0505                	addi	a0,a0,1
    p2++;
 2ae:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2b0:	fed518e3          	bne	a0,a3,2a0 <memcmp+0x14>
  }
  return 0;
 2b4:	4501                	li	a0,0
 2b6:	a019                	j	2bc <memcmp+0x30>
      return *p1 - *p2;
 2b8:	40e7853b          	subw	a0,a5,a4
}
 2bc:	6422                	ld	s0,8(sp)
 2be:	0141                	addi	sp,sp,16
 2c0:	8082                	ret
  return 0;
 2c2:	4501                	li	a0,0
 2c4:	bfe5                	j	2bc <memcmp+0x30>

00000000000002c6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2c6:	1141                	addi	sp,sp,-16
 2c8:	e406                	sd	ra,8(sp)
 2ca:	e022                	sd	s0,0(sp)
 2cc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2ce:	f67ff0ef          	jal	234 <memmove>
}
 2d2:	60a2                	ld	ra,8(sp)
 2d4:	6402                	ld	s0,0(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret

00000000000002da <sbrk>:

char *
sbrk(int n) {
 2da:	1141                	addi	sp,sp,-16
 2dc:	e406                	sd	ra,8(sp)
 2de:	e022                	sd	s0,0(sp)
 2e0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2e2:	4585                	li	a1,1
 2e4:	0b2000ef          	jal	396 <sys_sbrk>
}
 2e8:	60a2                	ld	ra,8(sp)
 2ea:	6402                	ld	s0,0(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret

00000000000002f0 <sbrklazy>:

char *
sbrklazy(int n) {
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e406                	sd	ra,8(sp)
 2f4:	e022                	sd	s0,0(sp)
 2f6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2f8:	4589                	li	a1,2
 2fa:	09c000ef          	jal	396 <sys_sbrk>
}
 2fe:	60a2                	ld	ra,8(sp)
 300:	6402                	ld	s0,0(sp)
 302:	0141                	addi	sp,sp,16
 304:	8082                	ret

0000000000000306 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 306:	4885                	li	a7,1
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <exit>:
.global exit
exit:
 li a7, SYS_exit
 30e:	4889                	li	a7,2
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <wait>:
.global wait
wait:
 li a7, SYS_wait
 316:	488d                	li	a7,3
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 31e:	4891                	li	a7,4
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <read>:
.global read
read:
 li a7, SYS_read
 326:	4895                	li	a7,5
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <write>:
.global write
write:
 li a7, SYS_write
 32e:	48c1                	li	a7,16
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <close>:
.global close
close:
 li a7, SYS_close
 336:	48d5                	li	a7,21
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <kill>:
.global kill
kill:
 li a7, SYS_kill
 33e:	4899                	li	a7,6
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <exec>:
.global exec
exec:
 li a7, SYS_exec
 346:	489d                	li	a7,7
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <open>:
.global open
open:
 li a7, SYS_open
 34e:	48bd                	li	a7,15
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 356:	48c5                	li	a7,17
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 35e:	48c9                	li	a7,18
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 366:	48a1                	li	a7,8
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <link>:
.global link
link:
 li a7, SYS_link
 36e:	48cd                	li	a7,19
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 376:	48d1                	li	a7,20
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 37e:	48a5                	li	a7,9
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <dup>:
.global dup
dup:
 li a7, SYS_dup
 386:	48a9                	li	a7,10
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 38e:	48ad                	li	a7,11
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 396:	48b1                	li	a7,12
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <pause>:
.global pause
pause:
 li a7, SYS_pause
 39e:	48b5                	li	a7,13
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3a6:	48b9                	li	a7,14
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3ae:	1101                	addi	sp,sp,-32
 3b0:	ec06                	sd	ra,24(sp)
 3b2:	e822                	sd	s0,16(sp)
 3b4:	1000                	addi	s0,sp,32
 3b6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3ba:	4605                	li	a2,1
 3bc:	fef40593          	addi	a1,s0,-17
 3c0:	f6fff0ef          	jal	32e <write>
}
 3c4:	60e2                	ld	ra,24(sp)
 3c6:	6442                	ld	s0,16(sp)
 3c8:	6105                	addi	sp,sp,32
 3ca:	8082                	ret

00000000000003cc <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3cc:	715d                	addi	sp,sp,-80
 3ce:	e486                	sd	ra,72(sp)
 3d0:	e0a2                	sd	s0,64(sp)
 3d2:	f84a                	sd	s2,48(sp)
 3d4:	0880                	addi	s0,sp,80
 3d6:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3d8:	c299                	beqz	a3,3de <printint+0x12>
 3da:	0805c363          	bltz	a1,460 <printint+0x94>
  neg = 0;
 3de:	4881                	li	a7,0
 3e0:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3e4:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3e6:	00000517          	auipc	a0,0x0
 3ea:	52250513          	addi	a0,a0,1314 # 908 <digits>
 3ee:	883e                	mv	a6,a5
 3f0:	2785                	addiw	a5,a5,1
 3f2:	02c5f733          	remu	a4,a1,a2
 3f6:	972a                	add	a4,a4,a0
 3f8:	00074703          	lbu	a4,0(a4)
 3fc:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 400:	872e                	mv	a4,a1
 402:	02c5d5b3          	divu	a1,a1,a2
 406:	0685                	addi	a3,a3,1
 408:	fec773e3          	bgeu	a4,a2,3ee <printint+0x22>
  if(neg)
 40c:	00088b63          	beqz	a7,422 <printint+0x56>
    buf[i++] = '-';
 410:	fd078793          	addi	a5,a5,-48
 414:	97a2                	add	a5,a5,s0
 416:	02d00713          	li	a4,45
 41a:	fee78423          	sb	a4,-24(a5)
 41e:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 422:	02f05a63          	blez	a5,456 <printint+0x8a>
 426:	fc26                	sd	s1,56(sp)
 428:	f44e                	sd	s3,40(sp)
 42a:	fb840713          	addi	a4,s0,-72
 42e:	00f704b3          	add	s1,a4,a5
 432:	fff70993          	addi	s3,a4,-1
 436:	99be                	add	s3,s3,a5
 438:	37fd                	addiw	a5,a5,-1
 43a:	1782                	slli	a5,a5,0x20
 43c:	9381                	srli	a5,a5,0x20
 43e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 442:	fff4c583          	lbu	a1,-1(s1)
 446:	854a                	mv	a0,s2
 448:	f67ff0ef          	jal	3ae <putc>
  while(--i >= 0)
 44c:	14fd                	addi	s1,s1,-1
 44e:	ff349ae3          	bne	s1,s3,442 <printint+0x76>
 452:	74e2                	ld	s1,56(sp)
 454:	79a2                	ld	s3,40(sp)
}
 456:	60a6                	ld	ra,72(sp)
 458:	6406                	ld	s0,64(sp)
 45a:	7942                	ld	s2,48(sp)
 45c:	6161                	addi	sp,sp,80
 45e:	8082                	ret
    x = -xx;
 460:	40b005b3          	neg	a1,a1
    neg = 1;
 464:	4885                	li	a7,1
    x = -xx;
 466:	bfad                	j	3e0 <printint+0x14>

0000000000000468 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 468:	711d                	addi	sp,sp,-96
 46a:	ec86                	sd	ra,88(sp)
 46c:	e8a2                	sd	s0,80(sp)
 46e:	e0ca                	sd	s2,64(sp)
 470:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 472:	0005c903          	lbu	s2,0(a1)
 476:	28090663          	beqz	s2,702 <vprintf+0x29a>
 47a:	e4a6                	sd	s1,72(sp)
 47c:	fc4e                	sd	s3,56(sp)
 47e:	f852                	sd	s4,48(sp)
 480:	f456                	sd	s5,40(sp)
 482:	f05a                	sd	s6,32(sp)
 484:	ec5e                	sd	s7,24(sp)
 486:	e862                	sd	s8,16(sp)
 488:	e466                	sd	s9,8(sp)
 48a:	8b2a                	mv	s6,a0
 48c:	8a2e                	mv	s4,a1
 48e:	8bb2                	mv	s7,a2
  state = 0;
 490:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 492:	4481                	li	s1,0
 494:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 496:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 49a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 49e:	06c00c93          	li	s9,108
 4a2:	a005                	j	4c2 <vprintf+0x5a>
        putc(fd, c0);
 4a4:	85ca                	mv	a1,s2
 4a6:	855a                	mv	a0,s6
 4a8:	f07ff0ef          	jal	3ae <putc>
 4ac:	a019                	j	4b2 <vprintf+0x4a>
    } else if(state == '%'){
 4ae:	03598263          	beq	s3,s5,4d2 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 4b2:	2485                	addiw	s1,s1,1
 4b4:	8726                	mv	a4,s1
 4b6:	009a07b3          	add	a5,s4,s1
 4ba:	0007c903          	lbu	s2,0(a5)
 4be:	22090a63          	beqz	s2,6f2 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 4c2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4c6:	fe0994e3          	bnez	s3,4ae <vprintf+0x46>
      if(c0 == '%'){
 4ca:	fd579de3          	bne	a5,s5,4a4 <vprintf+0x3c>
        state = '%';
 4ce:	89be                	mv	s3,a5
 4d0:	b7cd                	j	4b2 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4d2:	00ea06b3          	add	a3,s4,a4
 4d6:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4da:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4dc:	c681                	beqz	a3,4e4 <vprintf+0x7c>
 4de:	9752                	add	a4,a4,s4
 4e0:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4e4:	05878363          	beq	a5,s8,52a <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 4e8:	05978d63          	beq	a5,s9,542 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4ec:	07500713          	li	a4,117
 4f0:	0ee78763          	beq	a5,a4,5de <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4f4:	07800713          	li	a4,120
 4f8:	12e78963          	beq	a5,a4,62a <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4fc:	07000713          	li	a4,112
 500:	14e78e63          	beq	a5,a4,65c <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 504:	06300713          	li	a4,99
 508:	18e78e63          	beq	a5,a4,6a4 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 50c:	07300713          	li	a4,115
 510:	1ae78463          	beq	a5,a4,6b8 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 514:	02500713          	li	a4,37
 518:	04e79563          	bne	a5,a4,562 <vprintf+0xfa>
        putc(fd, '%');
 51c:	02500593          	li	a1,37
 520:	855a                	mv	a0,s6
 522:	e8dff0ef          	jal	3ae <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 526:	4981                	li	s3,0
 528:	b769                	j	4b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 52a:	008b8913          	addi	s2,s7,8
 52e:	4685                	li	a3,1
 530:	4629                	li	a2,10
 532:	000ba583          	lw	a1,0(s7)
 536:	855a                	mv	a0,s6
 538:	e95ff0ef          	jal	3cc <printint>
 53c:	8bca                	mv	s7,s2
      state = 0;
 53e:	4981                	li	s3,0
 540:	bf8d                	j	4b2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 542:	06400793          	li	a5,100
 546:	02f68963          	beq	a3,a5,578 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 54a:	06c00793          	li	a5,108
 54e:	04f68263          	beq	a3,a5,592 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 552:	07500793          	li	a5,117
 556:	0af68063          	beq	a3,a5,5f6 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 55a:	07800793          	li	a5,120
 55e:	0ef68263          	beq	a3,a5,642 <vprintf+0x1da>
        putc(fd, '%');
 562:	02500593          	li	a1,37
 566:	855a                	mv	a0,s6
 568:	e47ff0ef          	jal	3ae <putc>
        putc(fd, c0);
 56c:	85ca                	mv	a1,s2
 56e:	855a                	mv	a0,s6
 570:	e3fff0ef          	jal	3ae <putc>
      state = 0;
 574:	4981                	li	s3,0
 576:	bf35                	j	4b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 578:	008b8913          	addi	s2,s7,8
 57c:	4685                	li	a3,1
 57e:	4629                	li	a2,10
 580:	000bb583          	ld	a1,0(s7)
 584:	855a                	mv	a0,s6
 586:	e47ff0ef          	jal	3cc <printint>
        i += 1;
 58a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 58c:	8bca                	mv	s7,s2
      state = 0;
 58e:	4981                	li	s3,0
        i += 1;
 590:	b70d                	j	4b2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 592:	06400793          	li	a5,100
 596:	02f60763          	beq	a2,a5,5c4 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 59a:	07500793          	li	a5,117
 59e:	06f60963          	beq	a2,a5,610 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5a2:	07800793          	li	a5,120
 5a6:	faf61ee3          	bne	a2,a5,562 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5aa:	008b8913          	addi	s2,s7,8
 5ae:	4681                	li	a3,0
 5b0:	4641                	li	a2,16
 5b2:	000bb583          	ld	a1,0(s7)
 5b6:	855a                	mv	a0,s6
 5b8:	e15ff0ef          	jal	3cc <printint>
        i += 2;
 5bc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5be:	8bca                	mv	s7,s2
      state = 0;
 5c0:	4981                	li	s3,0
        i += 2;
 5c2:	bdc5                	j	4b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5c4:	008b8913          	addi	s2,s7,8
 5c8:	4685                	li	a3,1
 5ca:	4629                	li	a2,10
 5cc:	000bb583          	ld	a1,0(s7)
 5d0:	855a                	mv	a0,s6
 5d2:	dfbff0ef          	jal	3cc <printint>
        i += 2;
 5d6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d8:	8bca                	mv	s7,s2
      state = 0;
 5da:	4981                	li	s3,0
        i += 2;
 5dc:	bdd9                	j	4b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5de:	008b8913          	addi	s2,s7,8
 5e2:	4681                	li	a3,0
 5e4:	4629                	li	a2,10
 5e6:	000be583          	lwu	a1,0(s7)
 5ea:	855a                	mv	a0,s6
 5ec:	de1ff0ef          	jal	3cc <printint>
 5f0:	8bca                	mv	s7,s2
      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	bd7d                	j	4b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f6:	008b8913          	addi	s2,s7,8
 5fa:	4681                	li	a3,0
 5fc:	4629                	li	a2,10
 5fe:	000bb583          	ld	a1,0(s7)
 602:	855a                	mv	a0,s6
 604:	dc9ff0ef          	jal	3cc <printint>
        i += 1;
 608:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 60a:	8bca                	mv	s7,s2
      state = 0;
 60c:	4981                	li	s3,0
        i += 1;
 60e:	b555                	j	4b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 610:	008b8913          	addi	s2,s7,8
 614:	4681                	li	a3,0
 616:	4629                	li	a2,10
 618:	000bb583          	ld	a1,0(s7)
 61c:	855a                	mv	a0,s6
 61e:	dafff0ef          	jal	3cc <printint>
        i += 2;
 622:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 624:	8bca                	mv	s7,s2
      state = 0;
 626:	4981                	li	s3,0
        i += 2;
 628:	b569                	j	4b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 62a:	008b8913          	addi	s2,s7,8
 62e:	4681                	li	a3,0
 630:	4641                	li	a2,16
 632:	000be583          	lwu	a1,0(s7)
 636:	855a                	mv	a0,s6
 638:	d95ff0ef          	jal	3cc <printint>
 63c:	8bca                	mv	s7,s2
      state = 0;
 63e:	4981                	li	s3,0
 640:	bd8d                	j	4b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 642:	008b8913          	addi	s2,s7,8
 646:	4681                	li	a3,0
 648:	4641                	li	a2,16
 64a:	000bb583          	ld	a1,0(s7)
 64e:	855a                	mv	a0,s6
 650:	d7dff0ef          	jal	3cc <printint>
        i += 1;
 654:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 656:	8bca                	mv	s7,s2
      state = 0;
 658:	4981                	li	s3,0
        i += 1;
 65a:	bda1                	j	4b2 <vprintf+0x4a>
 65c:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 65e:	008b8d13          	addi	s10,s7,8
 662:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 666:	03000593          	li	a1,48
 66a:	855a                	mv	a0,s6
 66c:	d43ff0ef          	jal	3ae <putc>
  putc(fd, 'x');
 670:	07800593          	li	a1,120
 674:	855a                	mv	a0,s6
 676:	d39ff0ef          	jal	3ae <putc>
 67a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 67c:	00000b97          	auipc	s7,0x0
 680:	28cb8b93          	addi	s7,s7,652 # 908 <digits>
 684:	03c9d793          	srli	a5,s3,0x3c
 688:	97de                	add	a5,a5,s7
 68a:	0007c583          	lbu	a1,0(a5)
 68e:	855a                	mv	a0,s6
 690:	d1fff0ef          	jal	3ae <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 694:	0992                	slli	s3,s3,0x4
 696:	397d                	addiw	s2,s2,-1
 698:	fe0916e3          	bnez	s2,684 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 69c:	8bea                	mv	s7,s10
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	6d02                	ld	s10,0(sp)
 6a2:	bd01                	j	4b2 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 6a4:	008b8913          	addi	s2,s7,8
 6a8:	000bc583          	lbu	a1,0(s7)
 6ac:	855a                	mv	a0,s6
 6ae:	d01ff0ef          	jal	3ae <putc>
 6b2:	8bca                	mv	s7,s2
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	bbf5                	j	4b2 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6b8:	008b8993          	addi	s3,s7,8
 6bc:	000bb903          	ld	s2,0(s7)
 6c0:	00090f63          	beqz	s2,6de <vprintf+0x276>
        for(; *s; s++)
 6c4:	00094583          	lbu	a1,0(s2)
 6c8:	c195                	beqz	a1,6ec <vprintf+0x284>
          putc(fd, *s);
 6ca:	855a                	mv	a0,s6
 6cc:	ce3ff0ef          	jal	3ae <putc>
        for(; *s; s++)
 6d0:	0905                	addi	s2,s2,1
 6d2:	00094583          	lbu	a1,0(s2)
 6d6:	f9f5                	bnez	a1,6ca <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6d8:	8bce                	mv	s7,s3
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	bbd9                	j	4b2 <vprintf+0x4a>
          s = "(null)";
 6de:	00000917          	auipc	s2,0x0
 6e2:	22290913          	addi	s2,s2,546 # 900 <malloc+0x116>
        for(; *s; s++)
 6e6:	02800593          	li	a1,40
 6ea:	b7c5                	j	6ca <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6ec:	8bce                	mv	s7,s3
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	b3c9                	j	4b2 <vprintf+0x4a>
 6f2:	64a6                	ld	s1,72(sp)
 6f4:	79e2                	ld	s3,56(sp)
 6f6:	7a42                	ld	s4,48(sp)
 6f8:	7aa2                	ld	s5,40(sp)
 6fa:	7b02                	ld	s6,32(sp)
 6fc:	6be2                	ld	s7,24(sp)
 6fe:	6c42                	ld	s8,16(sp)
 700:	6ca2                	ld	s9,8(sp)
    }
  }
}
 702:	60e6                	ld	ra,88(sp)
 704:	6446                	ld	s0,80(sp)
 706:	6906                	ld	s2,64(sp)
 708:	6125                	addi	sp,sp,96
 70a:	8082                	ret

000000000000070c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 70c:	715d                	addi	sp,sp,-80
 70e:	ec06                	sd	ra,24(sp)
 710:	e822                	sd	s0,16(sp)
 712:	1000                	addi	s0,sp,32
 714:	e010                	sd	a2,0(s0)
 716:	e414                	sd	a3,8(s0)
 718:	e818                	sd	a4,16(s0)
 71a:	ec1c                	sd	a5,24(s0)
 71c:	03043023          	sd	a6,32(s0)
 720:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 724:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 728:	8622                	mv	a2,s0
 72a:	d3fff0ef          	jal	468 <vprintf>
}
 72e:	60e2                	ld	ra,24(sp)
 730:	6442                	ld	s0,16(sp)
 732:	6161                	addi	sp,sp,80
 734:	8082                	ret

0000000000000736 <printf>:

void
printf(const char *fmt, ...)
{
 736:	711d                	addi	sp,sp,-96
 738:	ec06                	sd	ra,24(sp)
 73a:	e822                	sd	s0,16(sp)
 73c:	1000                	addi	s0,sp,32
 73e:	e40c                	sd	a1,8(s0)
 740:	e810                	sd	a2,16(s0)
 742:	ec14                	sd	a3,24(s0)
 744:	f018                	sd	a4,32(s0)
 746:	f41c                	sd	a5,40(s0)
 748:	03043823          	sd	a6,48(s0)
 74c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 750:	00840613          	addi	a2,s0,8
 754:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 758:	85aa                	mv	a1,a0
 75a:	4505                	li	a0,1
 75c:	d0dff0ef          	jal	468 <vprintf>
}
 760:	60e2                	ld	ra,24(sp)
 762:	6442                	ld	s0,16(sp)
 764:	6125                	addi	sp,sp,96
 766:	8082                	ret

0000000000000768 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 768:	1141                	addi	sp,sp,-16
 76a:	e422                	sd	s0,8(sp)
 76c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 76e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 772:	00001797          	auipc	a5,0x1
 776:	88e7b783          	ld	a5,-1906(a5) # 1000 <freep>
 77a:	a02d                	j	7a4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 77c:	4618                	lw	a4,8(a2)
 77e:	9f2d                	addw	a4,a4,a1
 780:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 784:	6398                	ld	a4,0(a5)
 786:	6310                	ld	a2,0(a4)
 788:	a83d                	j	7c6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 78a:	ff852703          	lw	a4,-8(a0)
 78e:	9f31                	addw	a4,a4,a2
 790:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 792:	ff053683          	ld	a3,-16(a0)
 796:	a091                	j	7da <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 798:	6398                	ld	a4,0(a5)
 79a:	00e7e463          	bltu	a5,a4,7a2 <free+0x3a>
 79e:	00e6ea63          	bltu	a3,a4,7b2 <free+0x4a>
{
 7a2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a4:	fed7fae3          	bgeu	a5,a3,798 <free+0x30>
 7a8:	6398                	ld	a4,0(a5)
 7aa:	00e6e463          	bltu	a3,a4,7b2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ae:	fee7eae3          	bltu	a5,a4,7a2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7b2:	ff852583          	lw	a1,-8(a0)
 7b6:	6390                	ld	a2,0(a5)
 7b8:	02059813          	slli	a6,a1,0x20
 7bc:	01c85713          	srli	a4,a6,0x1c
 7c0:	9736                	add	a4,a4,a3
 7c2:	fae60de3          	beq	a2,a4,77c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7c6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7ca:	4790                	lw	a2,8(a5)
 7cc:	02061593          	slli	a1,a2,0x20
 7d0:	01c5d713          	srli	a4,a1,0x1c
 7d4:	973e                	add	a4,a4,a5
 7d6:	fae68ae3          	beq	a3,a4,78a <free+0x22>
    p->s.ptr = bp->s.ptr;
 7da:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7dc:	00001717          	auipc	a4,0x1
 7e0:	82f73223          	sd	a5,-2012(a4) # 1000 <freep>
}
 7e4:	6422                	ld	s0,8(sp)
 7e6:	0141                	addi	sp,sp,16
 7e8:	8082                	ret

00000000000007ea <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ea:	7139                	addi	sp,sp,-64
 7ec:	fc06                	sd	ra,56(sp)
 7ee:	f822                	sd	s0,48(sp)
 7f0:	f426                	sd	s1,40(sp)
 7f2:	ec4e                	sd	s3,24(sp)
 7f4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f6:	02051493          	slli	s1,a0,0x20
 7fa:	9081                	srli	s1,s1,0x20
 7fc:	04bd                	addi	s1,s1,15
 7fe:	8091                	srli	s1,s1,0x4
 800:	0014899b          	addiw	s3,s1,1
 804:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 806:	00000517          	auipc	a0,0x0
 80a:	7fa53503          	ld	a0,2042(a0) # 1000 <freep>
 80e:	c915                	beqz	a0,842 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 810:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 812:	4798                	lw	a4,8(a5)
 814:	08977a63          	bgeu	a4,s1,8a8 <malloc+0xbe>
 818:	f04a                	sd	s2,32(sp)
 81a:	e852                	sd	s4,16(sp)
 81c:	e456                	sd	s5,8(sp)
 81e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 820:	8a4e                	mv	s4,s3
 822:	0009871b          	sext.w	a4,s3
 826:	6685                	lui	a3,0x1
 828:	00d77363          	bgeu	a4,a3,82e <malloc+0x44>
 82c:	6a05                	lui	s4,0x1
 82e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 832:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 836:	00000917          	auipc	s2,0x0
 83a:	7ca90913          	addi	s2,s2,1994 # 1000 <freep>
  if(p == SBRK_ERROR)
 83e:	5afd                	li	s5,-1
 840:	a081                	j	880 <malloc+0x96>
 842:	f04a                	sd	s2,32(sp)
 844:	e852                	sd	s4,16(sp)
 846:	e456                	sd	s5,8(sp)
 848:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 84a:	00000797          	auipc	a5,0x0
 84e:	7c678793          	addi	a5,a5,1990 # 1010 <base>
 852:	00000717          	auipc	a4,0x0
 856:	7af73723          	sd	a5,1966(a4) # 1000 <freep>
 85a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 85c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 860:	b7c1                	j	820 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 862:	6398                	ld	a4,0(a5)
 864:	e118                	sd	a4,0(a0)
 866:	a8a9                	j	8c0 <malloc+0xd6>
  hp->s.size = nu;
 868:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 86c:	0541                	addi	a0,a0,16
 86e:	efbff0ef          	jal	768 <free>
  return freep;
 872:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 876:	c12d                	beqz	a0,8d8 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 878:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 87a:	4798                	lw	a4,8(a5)
 87c:	02977263          	bgeu	a4,s1,8a0 <malloc+0xb6>
    if(p == freep)
 880:	00093703          	ld	a4,0(s2)
 884:	853e                	mv	a0,a5
 886:	fef719e3          	bne	a4,a5,878 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 88a:	8552                	mv	a0,s4
 88c:	a4fff0ef          	jal	2da <sbrk>
  if(p == SBRK_ERROR)
 890:	fd551ce3          	bne	a0,s5,868 <malloc+0x7e>
        return 0;
 894:	4501                	li	a0,0
 896:	7902                	ld	s2,32(sp)
 898:	6a42                	ld	s4,16(sp)
 89a:	6aa2                	ld	s5,8(sp)
 89c:	6b02                	ld	s6,0(sp)
 89e:	a03d                	j	8cc <malloc+0xe2>
 8a0:	7902                	ld	s2,32(sp)
 8a2:	6a42                	ld	s4,16(sp)
 8a4:	6aa2                	ld	s5,8(sp)
 8a6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8a8:	fae48de3          	beq	s1,a4,862 <malloc+0x78>
        p->s.size -= nunits;
 8ac:	4137073b          	subw	a4,a4,s3
 8b0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8b2:	02071693          	slli	a3,a4,0x20
 8b6:	01c6d713          	srli	a4,a3,0x1c
 8ba:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8bc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8c0:	00000717          	auipc	a4,0x0
 8c4:	74a73023          	sd	a0,1856(a4) # 1000 <freep>
      return (void*)(p + 1);
 8c8:	01078513          	addi	a0,a5,16
  }
}
 8cc:	70e2                	ld	ra,56(sp)
 8ce:	7442                	ld	s0,48(sp)
 8d0:	74a2                	ld	s1,40(sp)
 8d2:	69e2                	ld	s3,24(sp)
 8d4:	6121                	addi	sp,sp,64
 8d6:	8082                	ret
 8d8:	7902                	ld	s2,32(sp)
 8da:	6a42                	ld	s4,16(sp)
 8dc:	6aa2                	ld	s5,8(sp)
 8de:	6b02                	ld	s6,0(sp)
 8e0:	b7f5                	j	8cc <malloc+0xe2>
