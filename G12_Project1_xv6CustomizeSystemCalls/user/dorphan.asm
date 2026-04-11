
user/_dorphan:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char buf[BUFSZ];

int
main(int argc, char **argv)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  char *s = argv[0];
   a:	6184                	ld	s1,0(a1)

  if(mkdir("dd") != 0){
   c:	00001517          	auipc	a0,0x1
  10:	90450513          	addi	a0,a0,-1788 # 910 <malloc+0xfe>
  14:	372000ef          	jal	386 <mkdir>
  18:	c919                	beqz	a0,2e <main+0x2e>
    printf("%s: mkdir dd failed\n", s);
  1a:	85a6                	mv	a1,s1
  1c:	00001517          	auipc	a0,0x1
  20:	8fc50513          	addi	a0,a0,-1796 # 918 <malloc+0x106>
  24:	73a000ef          	jal	75e <printf>
    exit(1);
  28:	4505                	li	a0,1
  2a:	2f4000ef          	jal	31e <exit>
  }

  if(chdir("dd") != 0){
  2e:	00001517          	auipc	a0,0x1
  32:	8e250513          	addi	a0,a0,-1822 # 910 <malloc+0xfe>
  36:	358000ef          	jal	38e <chdir>
  3a:	c919                	beqz	a0,50 <main+0x50>
    printf("%s: chdir dd failed\n", s);
  3c:	85a6                	mv	a1,s1
  3e:	00001517          	auipc	a0,0x1
  42:	8f250513          	addi	a0,a0,-1806 # 930 <malloc+0x11e>
  46:	718000ef          	jal	75e <printf>
    exit(1);
  4a:	4505                	li	a0,1
  4c:	2d2000ef          	jal	31e <exit>
  }

  if (unlink("../dd") < 0) {
  50:	00001517          	auipc	a0,0x1
  54:	8f850513          	addi	a0,a0,-1800 # 948 <malloc+0x136>
  58:	316000ef          	jal	36e <unlink>
  5c:	00054d63          	bltz	a0,76 <main+0x76>
    printf("%s: unlink failed\n", s);
    exit(1);
  }
  printf("wait for kill and reclaim\n");
  60:	00001517          	auipc	a0,0x1
  64:	90850513          	addi	a0,a0,-1784 # 968 <malloc+0x156>
  68:	6f6000ef          	jal	75e <printf>
  // sit around until killed
  for(;;) pause(1000);
  6c:	3e800513          	li	a0,1000
  70:	33e000ef          	jal	3ae <pause>
  74:	bfe5                	j	6c <main+0x6c>
    printf("%s: unlink failed\n", s);
  76:	85a6                	mv	a1,s1
  78:	00001517          	auipc	a0,0x1
  7c:	8d850513          	addi	a0,a0,-1832 # 950 <malloc+0x13e>
  80:	6de000ef          	jal	75e <printf>
    exit(1);
  84:	4505                	li	a0,1
  86:	298000ef          	jal	31e <exit>

000000000000008a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  8a:	1141                	addi	sp,sp,-16
  8c:	e406                	sd	ra,8(sp)
  8e:	e022                	sd	s0,0(sp)
  90:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  92:	f6fff0ef          	jal	0 <main>
  exit(r);
  96:	288000ef          	jal	31e <exit>

000000000000009a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  9a:	1141                	addi	sp,sp,-16
  9c:	e422                	sd	s0,8(sp)
  9e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  a0:	87aa                	mv	a5,a0
  a2:	0585                	addi	a1,a1,1
  a4:	0785                	addi	a5,a5,1
  a6:	fff5c703          	lbu	a4,-1(a1)
  aa:	fee78fa3          	sb	a4,-1(a5)
  ae:	fb75                	bnez	a4,a2 <strcpy+0x8>
    ;
  return os;
}
  b0:	6422                	ld	s0,8(sp)
  b2:	0141                	addi	sp,sp,16
  b4:	8082                	ret

00000000000000b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b6:	1141                	addi	sp,sp,-16
  b8:	e422                	sd	s0,8(sp)
  ba:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  bc:	00054783          	lbu	a5,0(a0)
  c0:	cb91                	beqz	a5,d4 <strcmp+0x1e>
  c2:	0005c703          	lbu	a4,0(a1)
  c6:	00f71763          	bne	a4,a5,d4 <strcmp+0x1e>
    p++, q++;
  ca:	0505                	addi	a0,a0,1
  cc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  ce:	00054783          	lbu	a5,0(a0)
  d2:	fbe5                	bnez	a5,c2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  d4:	0005c503          	lbu	a0,0(a1)
}
  d8:	40a7853b          	subw	a0,a5,a0
  dc:	6422                	ld	s0,8(sp)
  de:	0141                	addi	sp,sp,16
  e0:	8082                	ret

00000000000000e2 <strlen>:

uint
strlen(const char *s)
{
  e2:	1141                	addi	sp,sp,-16
  e4:	e422                	sd	s0,8(sp)
  e6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  e8:	00054783          	lbu	a5,0(a0)
  ec:	cf91                	beqz	a5,108 <strlen+0x26>
  ee:	0505                	addi	a0,a0,1
  f0:	87aa                	mv	a5,a0
  f2:	86be                	mv	a3,a5
  f4:	0785                	addi	a5,a5,1
  f6:	fff7c703          	lbu	a4,-1(a5)
  fa:	ff65                	bnez	a4,f2 <strlen+0x10>
  fc:	40a6853b          	subw	a0,a3,a0
 100:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 102:	6422                	ld	s0,8(sp)
 104:	0141                	addi	sp,sp,16
 106:	8082                	ret
  for(n = 0; s[n]; n++)
 108:	4501                	li	a0,0
 10a:	bfe5                	j	102 <strlen+0x20>

000000000000010c <memset>:

void*
memset(void *dst, int c, uint n)
{
 10c:	1141                	addi	sp,sp,-16
 10e:	e422                	sd	s0,8(sp)
 110:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 112:	ca19                	beqz	a2,128 <memset+0x1c>
 114:	87aa                	mv	a5,a0
 116:	1602                	slli	a2,a2,0x20
 118:	9201                	srli	a2,a2,0x20
 11a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 11e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 122:	0785                	addi	a5,a5,1
 124:	fee79de3          	bne	a5,a4,11e <memset+0x12>
  }
  return dst;
}
 128:	6422                	ld	s0,8(sp)
 12a:	0141                	addi	sp,sp,16
 12c:	8082                	ret

000000000000012e <strchr>:

char*
strchr(const char *s, char c)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e422                	sd	s0,8(sp)
 132:	0800                	addi	s0,sp,16
  for(; *s; s++)
 134:	00054783          	lbu	a5,0(a0)
 138:	cb99                	beqz	a5,14e <strchr+0x20>
    if(*s == c)
 13a:	00f58763          	beq	a1,a5,148 <strchr+0x1a>
  for(; *s; s++)
 13e:	0505                	addi	a0,a0,1
 140:	00054783          	lbu	a5,0(a0)
 144:	fbfd                	bnez	a5,13a <strchr+0xc>
      return (char*)s;
  return 0;
 146:	4501                	li	a0,0
}
 148:	6422                	ld	s0,8(sp)
 14a:	0141                	addi	sp,sp,16
 14c:	8082                	ret
  return 0;
 14e:	4501                	li	a0,0
 150:	bfe5                	j	148 <strchr+0x1a>

0000000000000152 <gets>:

char*
gets(char *buf, int max)
{
 152:	711d                	addi	sp,sp,-96
 154:	ec86                	sd	ra,88(sp)
 156:	e8a2                	sd	s0,80(sp)
 158:	e4a6                	sd	s1,72(sp)
 15a:	e0ca                	sd	s2,64(sp)
 15c:	fc4e                	sd	s3,56(sp)
 15e:	f852                	sd	s4,48(sp)
 160:	f456                	sd	s5,40(sp)
 162:	f05a                	sd	s6,32(sp)
 164:	ec5e                	sd	s7,24(sp)
 166:	1080                	addi	s0,sp,96
 168:	8baa                	mv	s7,a0
 16a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 16c:	892a                	mv	s2,a0
 16e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 170:	4aa9                	li	s5,10
 172:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 174:	89a6                	mv	s3,s1
 176:	2485                	addiw	s1,s1,1
 178:	0344d663          	bge	s1,s4,1a4 <gets+0x52>
    cc = read(0, &c, 1);
 17c:	4605                	li	a2,1
 17e:	faf40593          	addi	a1,s0,-81
 182:	4501                	li	a0,0
 184:	1b2000ef          	jal	336 <read>
    if(cc < 1)
 188:	00a05e63          	blez	a0,1a4 <gets+0x52>
    buf[i++] = c;
 18c:	faf44783          	lbu	a5,-81(s0)
 190:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 194:	01578763          	beq	a5,s5,1a2 <gets+0x50>
 198:	0905                	addi	s2,s2,1
 19a:	fd679de3          	bne	a5,s6,174 <gets+0x22>
    buf[i++] = c;
 19e:	89a6                	mv	s3,s1
 1a0:	a011                	j	1a4 <gets+0x52>
 1a2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1a4:	99de                	add	s3,s3,s7
 1a6:	00098023          	sb	zero,0(s3)
  return buf;
}
 1aa:	855e                	mv	a0,s7
 1ac:	60e6                	ld	ra,88(sp)
 1ae:	6446                	ld	s0,80(sp)
 1b0:	64a6                	ld	s1,72(sp)
 1b2:	6906                	ld	s2,64(sp)
 1b4:	79e2                	ld	s3,56(sp)
 1b6:	7a42                	ld	s4,48(sp)
 1b8:	7aa2                	ld	s5,40(sp)
 1ba:	7b02                	ld	s6,32(sp)
 1bc:	6be2                	ld	s7,24(sp)
 1be:	6125                	addi	sp,sp,96
 1c0:	8082                	ret

00000000000001c2 <stat>:

int
stat(const char *n, struct stat *st)
{
 1c2:	1101                	addi	sp,sp,-32
 1c4:	ec06                	sd	ra,24(sp)
 1c6:	e822                	sd	s0,16(sp)
 1c8:	e04a                	sd	s2,0(sp)
 1ca:	1000                	addi	s0,sp,32
 1cc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ce:	4581                	li	a1,0
 1d0:	18e000ef          	jal	35e <open>
  if(fd < 0)
 1d4:	02054263          	bltz	a0,1f8 <stat+0x36>
 1d8:	e426                	sd	s1,8(sp)
 1da:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1dc:	85ca                	mv	a1,s2
 1de:	198000ef          	jal	376 <fstat>
 1e2:	892a                	mv	s2,a0
  close(fd);
 1e4:	8526                	mv	a0,s1
 1e6:	160000ef          	jal	346 <close>
  return r;
 1ea:	64a2                	ld	s1,8(sp)
}
 1ec:	854a                	mv	a0,s2
 1ee:	60e2                	ld	ra,24(sp)
 1f0:	6442                	ld	s0,16(sp)
 1f2:	6902                	ld	s2,0(sp)
 1f4:	6105                	addi	sp,sp,32
 1f6:	8082                	ret
    return -1;
 1f8:	597d                	li	s2,-1
 1fa:	bfcd                	j	1ec <stat+0x2a>

00000000000001fc <atoi>:

int
atoi(const char *s)
{
 1fc:	1141                	addi	sp,sp,-16
 1fe:	e422                	sd	s0,8(sp)
 200:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 202:	00054683          	lbu	a3,0(a0)
 206:	fd06879b          	addiw	a5,a3,-48
 20a:	0ff7f793          	zext.b	a5,a5
 20e:	4625                	li	a2,9
 210:	02f66863          	bltu	a2,a5,240 <atoi+0x44>
 214:	872a                	mv	a4,a0
  n = 0;
 216:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 218:	0705                	addi	a4,a4,1
 21a:	0025179b          	slliw	a5,a0,0x2
 21e:	9fa9                	addw	a5,a5,a0
 220:	0017979b          	slliw	a5,a5,0x1
 224:	9fb5                	addw	a5,a5,a3
 226:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 22a:	00074683          	lbu	a3,0(a4)
 22e:	fd06879b          	addiw	a5,a3,-48
 232:	0ff7f793          	zext.b	a5,a5
 236:	fef671e3          	bgeu	a2,a5,218 <atoi+0x1c>
  return n;
}
 23a:	6422                	ld	s0,8(sp)
 23c:	0141                	addi	sp,sp,16
 23e:	8082                	ret
  n = 0;
 240:	4501                	li	a0,0
 242:	bfe5                	j	23a <atoi+0x3e>

0000000000000244 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 244:	1141                	addi	sp,sp,-16
 246:	e422                	sd	s0,8(sp)
 248:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 24a:	02b57463          	bgeu	a0,a1,272 <memmove+0x2e>
    while(n-- > 0)
 24e:	00c05f63          	blez	a2,26c <memmove+0x28>
 252:	1602                	slli	a2,a2,0x20
 254:	9201                	srli	a2,a2,0x20
 256:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 25a:	872a                	mv	a4,a0
      *dst++ = *src++;
 25c:	0585                	addi	a1,a1,1
 25e:	0705                	addi	a4,a4,1
 260:	fff5c683          	lbu	a3,-1(a1)
 264:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 268:	fef71ae3          	bne	a4,a5,25c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 26c:	6422                	ld	s0,8(sp)
 26e:	0141                	addi	sp,sp,16
 270:	8082                	ret
    dst += n;
 272:	00c50733          	add	a4,a0,a2
    src += n;
 276:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 278:	fec05ae3          	blez	a2,26c <memmove+0x28>
 27c:	fff6079b          	addiw	a5,a2,-1
 280:	1782                	slli	a5,a5,0x20
 282:	9381                	srli	a5,a5,0x20
 284:	fff7c793          	not	a5,a5
 288:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 28a:	15fd                	addi	a1,a1,-1
 28c:	177d                	addi	a4,a4,-1
 28e:	0005c683          	lbu	a3,0(a1)
 292:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 296:	fee79ae3          	bne	a5,a4,28a <memmove+0x46>
 29a:	bfc9                	j	26c <memmove+0x28>

000000000000029c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 29c:	1141                	addi	sp,sp,-16
 29e:	e422                	sd	s0,8(sp)
 2a0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2a2:	ca05                	beqz	a2,2d2 <memcmp+0x36>
 2a4:	fff6069b          	addiw	a3,a2,-1
 2a8:	1682                	slli	a3,a3,0x20
 2aa:	9281                	srli	a3,a3,0x20
 2ac:	0685                	addi	a3,a3,1
 2ae:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2b0:	00054783          	lbu	a5,0(a0)
 2b4:	0005c703          	lbu	a4,0(a1)
 2b8:	00e79863          	bne	a5,a4,2c8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2bc:	0505                	addi	a0,a0,1
    p2++;
 2be:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2c0:	fed518e3          	bne	a0,a3,2b0 <memcmp+0x14>
  }
  return 0;
 2c4:	4501                	li	a0,0
 2c6:	a019                	j	2cc <memcmp+0x30>
      return *p1 - *p2;
 2c8:	40e7853b          	subw	a0,a5,a4
}
 2cc:	6422                	ld	s0,8(sp)
 2ce:	0141                	addi	sp,sp,16
 2d0:	8082                	ret
  return 0;
 2d2:	4501                	li	a0,0
 2d4:	bfe5                	j	2cc <memcmp+0x30>

00000000000002d6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e406                	sd	ra,8(sp)
 2da:	e022                	sd	s0,0(sp)
 2dc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2de:	f67ff0ef          	jal	244 <memmove>
}
 2e2:	60a2                	ld	ra,8(sp)
 2e4:	6402                	ld	s0,0(sp)
 2e6:	0141                	addi	sp,sp,16
 2e8:	8082                	ret

00000000000002ea <sbrk>:

char *
sbrk(int n) {
 2ea:	1141                	addi	sp,sp,-16
 2ec:	e406                	sd	ra,8(sp)
 2ee:	e022                	sd	s0,0(sp)
 2f0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2f2:	4585                	li	a1,1
 2f4:	0b2000ef          	jal	3a6 <sys_sbrk>
}
 2f8:	60a2                	ld	ra,8(sp)
 2fa:	6402                	ld	s0,0(sp)
 2fc:	0141                	addi	sp,sp,16
 2fe:	8082                	ret

0000000000000300 <sbrklazy>:

char *
sbrklazy(int n) {
 300:	1141                	addi	sp,sp,-16
 302:	e406                	sd	ra,8(sp)
 304:	e022                	sd	s0,0(sp)
 306:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 308:	4589                	li	a1,2
 30a:	09c000ef          	jal	3a6 <sys_sbrk>
}
 30e:	60a2                	ld	ra,8(sp)
 310:	6402                	ld	s0,0(sp)
 312:	0141                	addi	sp,sp,16
 314:	8082                	ret

0000000000000316 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 316:	4885                	li	a7,1
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <exit>:
.global exit
exit:
 li a7, SYS_exit
 31e:	4889                	li	a7,2
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <wait>:
.global wait
wait:
 li a7, SYS_wait
 326:	488d                	li	a7,3
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 32e:	4891                	li	a7,4
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <read>:
.global read
read:
 li a7, SYS_read
 336:	4895                	li	a7,5
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <write>:
.global write
write:
 li a7, SYS_write
 33e:	48c1                	li	a7,16
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <close>:
.global close
close:
 li a7, SYS_close
 346:	48d5                	li	a7,21
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <kill>:
.global kill
kill:
 li a7, SYS_kill
 34e:	4899                	li	a7,6
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <exec>:
.global exec
exec:
 li a7, SYS_exec
 356:	489d                	li	a7,7
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <open>:
.global open
open:
 li a7, SYS_open
 35e:	48bd                	li	a7,15
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 366:	48c5                	li	a7,17
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 36e:	48c9                	li	a7,18
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 376:	48a1                	li	a7,8
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <link>:
.global link
link:
 li a7, SYS_link
 37e:	48cd                	li	a7,19
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 386:	48d1                	li	a7,20
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 38e:	48a5                	li	a7,9
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <dup>:
.global dup
dup:
 li a7, SYS_dup
 396:	48a9                	li	a7,10
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 39e:	48ad                	li	a7,11
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3a6:	48b1                	li	a7,12
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <pause>:
.global pause
pause:
 li a7, SYS_pause
 3ae:	48b5                	li	a7,13
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3b6:	48b9                	li	a7,14
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <getprocsinfo>:
.global getprocsinfo
getprocsinfo:
 li a7, SYS_getprocsinfo
 3be:	48d9                	li	a7,22
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 3c6:	48dd                	li	a7,23
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <sleep2>:
.global sleep2
sleep2:
 li a7, SYS_sleep2
 3ce:	48e1                	li	a7,24
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3d6:	1101                	addi	sp,sp,-32
 3d8:	ec06                	sd	ra,24(sp)
 3da:	e822                	sd	s0,16(sp)
 3dc:	1000                	addi	s0,sp,32
 3de:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3e2:	4605                	li	a2,1
 3e4:	fef40593          	addi	a1,s0,-17
 3e8:	f57ff0ef          	jal	33e <write>
}
 3ec:	60e2                	ld	ra,24(sp)
 3ee:	6442                	ld	s0,16(sp)
 3f0:	6105                	addi	sp,sp,32
 3f2:	8082                	ret

00000000000003f4 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3f4:	715d                	addi	sp,sp,-80
 3f6:	e486                	sd	ra,72(sp)
 3f8:	e0a2                	sd	s0,64(sp)
 3fa:	f84a                	sd	s2,48(sp)
 3fc:	0880                	addi	s0,sp,80
 3fe:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 400:	c299                	beqz	a3,406 <printint+0x12>
 402:	0805c363          	bltz	a1,488 <printint+0x94>
  neg = 0;
 406:	4881                	li	a7,0
 408:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 40c:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 40e:	00000517          	auipc	a0,0x0
 412:	58250513          	addi	a0,a0,1410 # 990 <digits>
 416:	883e                	mv	a6,a5
 418:	2785                	addiw	a5,a5,1
 41a:	02c5f733          	remu	a4,a1,a2
 41e:	972a                	add	a4,a4,a0
 420:	00074703          	lbu	a4,0(a4)
 424:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 428:	872e                	mv	a4,a1
 42a:	02c5d5b3          	divu	a1,a1,a2
 42e:	0685                	addi	a3,a3,1
 430:	fec773e3          	bgeu	a4,a2,416 <printint+0x22>
  if(neg)
 434:	00088b63          	beqz	a7,44a <printint+0x56>
    buf[i++] = '-';
 438:	fd078793          	addi	a5,a5,-48
 43c:	97a2                	add	a5,a5,s0
 43e:	02d00713          	li	a4,45
 442:	fee78423          	sb	a4,-24(a5)
 446:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 44a:	02f05a63          	blez	a5,47e <printint+0x8a>
 44e:	fc26                	sd	s1,56(sp)
 450:	f44e                	sd	s3,40(sp)
 452:	fb840713          	addi	a4,s0,-72
 456:	00f704b3          	add	s1,a4,a5
 45a:	fff70993          	addi	s3,a4,-1
 45e:	99be                	add	s3,s3,a5
 460:	37fd                	addiw	a5,a5,-1
 462:	1782                	slli	a5,a5,0x20
 464:	9381                	srli	a5,a5,0x20
 466:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 46a:	fff4c583          	lbu	a1,-1(s1)
 46e:	854a                	mv	a0,s2
 470:	f67ff0ef          	jal	3d6 <putc>
  while(--i >= 0)
 474:	14fd                	addi	s1,s1,-1
 476:	ff349ae3          	bne	s1,s3,46a <printint+0x76>
 47a:	74e2                	ld	s1,56(sp)
 47c:	79a2                	ld	s3,40(sp)
}
 47e:	60a6                	ld	ra,72(sp)
 480:	6406                	ld	s0,64(sp)
 482:	7942                	ld	s2,48(sp)
 484:	6161                	addi	sp,sp,80
 486:	8082                	ret
    x = -xx;
 488:	40b005b3          	neg	a1,a1
    neg = 1;
 48c:	4885                	li	a7,1
    x = -xx;
 48e:	bfad                	j	408 <printint+0x14>

0000000000000490 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 490:	711d                	addi	sp,sp,-96
 492:	ec86                	sd	ra,88(sp)
 494:	e8a2                	sd	s0,80(sp)
 496:	e0ca                	sd	s2,64(sp)
 498:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 49a:	0005c903          	lbu	s2,0(a1)
 49e:	28090663          	beqz	s2,72a <vprintf+0x29a>
 4a2:	e4a6                	sd	s1,72(sp)
 4a4:	fc4e                	sd	s3,56(sp)
 4a6:	f852                	sd	s4,48(sp)
 4a8:	f456                	sd	s5,40(sp)
 4aa:	f05a                	sd	s6,32(sp)
 4ac:	ec5e                	sd	s7,24(sp)
 4ae:	e862                	sd	s8,16(sp)
 4b0:	e466                	sd	s9,8(sp)
 4b2:	8b2a                	mv	s6,a0
 4b4:	8a2e                	mv	s4,a1
 4b6:	8bb2                	mv	s7,a2
  state = 0;
 4b8:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4ba:	4481                	li	s1,0
 4bc:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4be:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4c2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4c6:	06c00c93          	li	s9,108
 4ca:	a005                	j	4ea <vprintf+0x5a>
        putc(fd, c0);
 4cc:	85ca                	mv	a1,s2
 4ce:	855a                	mv	a0,s6
 4d0:	f07ff0ef          	jal	3d6 <putc>
 4d4:	a019                	j	4da <vprintf+0x4a>
    } else if(state == '%'){
 4d6:	03598263          	beq	s3,s5,4fa <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 4da:	2485                	addiw	s1,s1,1
 4dc:	8726                	mv	a4,s1
 4de:	009a07b3          	add	a5,s4,s1
 4e2:	0007c903          	lbu	s2,0(a5)
 4e6:	22090a63          	beqz	s2,71a <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 4ea:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4ee:	fe0994e3          	bnez	s3,4d6 <vprintf+0x46>
      if(c0 == '%'){
 4f2:	fd579de3          	bne	a5,s5,4cc <vprintf+0x3c>
        state = '%';
 4f6:	89be                	mv	s3,a5
 4f8:	b7cd                	j	4da <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4fa:	00ea06b3          	add	a3,s4,a4
 4fe:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 502:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 504:	c681                	beqz	a3,50c <vprintf+0x7c>
 506:	9752                	add	a4,a4,s4
 508:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 50c:	05878363          	beq	a5,s8,552 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 510:	05978d63          	beq	a5,s9,56a <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 514:	07500713          	li	a4,117
 518:	0ee78763          	beq	a5,a4,606 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 51c:	07800713          	li	a4,120
 520:	12e78963          	beq	a5,a4,652 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 524:	07000713          	li	a4,112
 528:	14e78e63          	beq	a5,a4,684 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 52c:	06300713          	li	a4,99
 530:	18e78e63          	beq	a5,a4,6cc <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 534:	07300713          	li	a4,115
 538:	1ae78463          	beq	a5,a4,6e0 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 53c:	02500713          	li	a4,37
 540:	04e79563          	bne	a5,a4,58a <vprintf+0xfa>
        putc(fd, '%');
 544:	02500593          	li	a1,37
 548:	855a                	mv	a0,s6
 54a:	e8dff0ef          	jal	3d6 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 54e:	4981                	li	s3,0
 550:	b769                	j	4da <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 552:	008b8913          	addi	s2,s7,8
 556:	4685                	li	a3,1
 558:	4629                	li	a2,10
 55a:	000ba583          	lw	a1,0(s7)
 55e:	855a                	mv	a0,s6
 560:	e95ff0ef          	jal	3f4 <printint>
 564:	8bca                	mv	s7,s2
      state = 0;
 566:	4981                	li	s3,0
 568:	bf8d                	j	4da <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 56a:	06400793          	li	a5,100
 56e:	02f68963          	beq	a3,a5,5a0 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 572:	06c00793          	li	a5,108
 576:	04f68263          	beq	a3,a5,5ba <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 57a:	07500793          	li	a5,117
 57e:	0af68063          	beq	a3,a5,61e <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 582:	07800793          	li	a5,120
 586:	0ef68263          	beq	a3,a5,66a <vprintf+0x1da>
        putc(fd, '%');
 58a:	02500593          	li	a1,37
 58e:	855a                	mv	a0,s6
 590:	e47ff0ef          	jal	3d6 <putc>
        putc(fd, c0);
 594:	85ca                	mv	a1,s2
 596:	855a                	mv	a0,s6
 598:	e3fff0ef          	jal	3d6 <putc>
      state = 0;
 59c:	4981                	li	s3,0
 59e:	bf35                	j	4da <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a0:	008b8913          	addi	s2,s7,8
 5a4:	4685                	li	a3,1
 5a6:	4629                	li	a2,10
 5a8:	000bb583          	ld	a1,0(s7)
 5ac:	855a                	mv	a0,s6
 5ae:	e47ff0ef          	jal	3f4 <printint>
        i += 1;
 5b2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b4:	8bca                	mv	s7,s2
      state = 0;
 5b6:	4981                	li	s3,0
        i += 1;
 5b8:	b70d                	j	4da <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5ba:	06400793          	li	a5,100
 5be:	02f60763          	beq	a2,a5,5ec <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5c2:	07500793          	li	a5,117
 5c6:	06f60963          	beq	a2,a5,638 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5ca:	07800793          	li	a5,120
 5ce:	faf61ee3          	bne	a2,a5,58a <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5d2:	008b8913          	addi	s2,s7,8
 5d6:	4681                	li	a3,0
 5d8:	4641                	li	a2,16
 5da:	000bb583          	ld	a1,0(s7)
 5de:	855a                	mv	a0,s6
 5e0:	e15ff0ef          	jal	3f4 <printint>
        i += 2;
 5e4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e6:	8bca                	mv	s7,s2
      state = 0;
 5e8:	4981                	li	s3,0
        i += 2;
 5ea:	bdc5                	j	4da <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ec:	008b8913          	addi	s2,s7,8
 5f0:	4685                	li	a3,1
 5f2:	4629                	li	a2,10
 5f4:	000bb583          	ld	a1,0(s7)
 5f8:	855a                	mv	a0,s6
 5fa:	dfbff0ef          	jal	3f4 <printint>
        i += 2;
 5fe:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 600:	8bca                	mv	s7,s2
      state = 0;
 602:	4981                	li	s3,0
        i += 2;
 604:	bdd9                	j	4da <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 606:	008b8913          	addi	s2,s7,8
 60a:	4681                	li	a3,0
 60c:	4629                	li	a2,10
 60e:	000be583          	lwu	a1,0(s7)
 612:	855a                	mv	a0,s6
 614:	de1ff0ef          	jal	3f4 <printint>
 618:	8bca                	mv	s7,s2
      state = 0;
 61a:	4981                	li	s3,0
 61c:	bd7d                	j	4da <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 61e:	008b8913          	addi	s2,s7,8
 622:	4681                	li	a3,0
 624:	4629                	li	a2,10
 626:	000bb583          	ld	a1,0(s7)
 62a:	855a                	mv	a0,s6
 62c:	dc9ff0ef          	jal	3f4 <printint>
        i += 1;
 630:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 632:	8bca                	mv	s7,s2
      state = 0;
 634:	4981                	li	s3,0
        i += 1;
 636:	b555                	j	4da <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 638:	008b8913          	addi	s2,s7,8
 63c:	4681                	li	a3,0
 63e:	4629                	li	a2,10
 640:	000bb583          	ld	a1,0(s7)
 644:	855a                	mv	a0,s6
 646:	dafff0ef          	jal	3f4 <printint>
        i += 2;
 64a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 64c:	8bca                	mv	s7,s2
      state = 0;
 64e:	4981                	li	s3,0
        i += 2;
 650:	b569                	j	4da <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 652:	008b8913          	addi	s2,s7,8
 656:	4681                	li	a3,0
 658:	4641                	li	a2,16
 65a:	000be583          	lwu	a1,0(s7)
 65e:	855a                	mv	a0,s6
 660:	d95ff0ef          	jal	3f4 <printint>
 664:	8bca                	mv	s7,s2
      state = 0;
 666:	4981                	li	s3,0
 668:	bd8d                	j	4da <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 66a:	008b8913          	addi	s2,s7,8
 66e:	4681                	li	a3,0
 670:	4641                	li	a2,16
 672:	000bb583          	ld	a1,0(s7)
 676:	855a                	mv	a0,s6
 678:	d7dff0ef          	jal	3f4 <printint>
        i += 1;
 67c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 67e:	8bca                	mv	s7,s2
      state = 0;
 680:	4981                	li	s3,0
        i += 1;
 682:	bda1                	j	4da <vprintf+0x4a>
 684:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 686:	008b8d13          	addi	s10,s7,8
 68a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 68e:	03000593          	li	a1,48
 692:	855a                	mv	a0,s6
 694:	d43ff0ef          	jal	3d6 <putc>
  putc(fd, 'x');
 698:	07800593          	li	a1,120
 69c:	855a                	mv	a0,s6
 69e:	d39ff0ef          	jal	3d6 <putc>
 6a2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6a4:	00000b97          	auipc	s7,0x0
 6a8:	2ecb8b93          	addi	s7,s7,748 # 990 <digits>
 6ac:	03c9d793          	srli	a5,s3,0x3c
 6b0:	97de                	add	a5,a5,s7
 6b2:	0007c583          	lbu	a1,0(a5)
 6b6:	855a                	mv	a0,s6
 6b8:	d1fff0ef          	jal	3d6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6bc:	0992                	slli	s3,s3,0x4
 6be:	397d                	addiw	s2,s2,-1
 6c0:	fe0916e3          	bnez	s2,6ac <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 6c4:	8bea                	mv	s7,s10
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	6d02                	ld	s10,0(sp)
 6ca:	bd01                	j	4da <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 6cc:	008b8913          	addi	s2,s7,8
 6d0:	000bc583          	lbu	a1,0(s7)
 6d4:	855a                	mv	a0,s6
 6d6:	d01ff0ef          	jal	3d6 <putc>
 6da:	8bca                	mv	s7,s2
      state = 0;
 6dc:	4981                	li	s3,0
 6de:	bbf5                	j	4da <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6e0:	008b8993          	addi	s3,s7,8
 6e4:	000bb903          	ld	s2,0(s7)
 6e8:	00090f63          	beqz	s2,706 <vprintf+0x276>
        for(; *s; s++)
 6ec:	00094583          	lbu	a1,0(s2)
 6f0:	c195                	beqz	a1,714 <vprintf+0x284>
          putc(fd, *s);
 6f2:	855a                	mv	a0,s6
 6f4:	ce3ff0ef          	jal	3d6 <putc>
        for(; *s; s++)
 6f8:	0905                	addi	s2,s2,1
 6fa:	00094583          	lbu	a1,0(s2)
 6fe:	f9f5                	bnez	a1,6f2 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 700:	8bce                	mv	s7,s3
      state = 0;
 702:	4981                	li	s3,0
 704:	bbd9                	j	4da <vprintf+0x4a>
          s = "(null)";
 706:	00000917          	auipc	s2,0x0
 70a:	28290913          	addi	s2,s2,642 # 988 <malloc+0x176>
        for(; *s; s++)
 70e:	02800593          	li	a1,40
 712:	b7c5                	j	6f2 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 714:	8bce                	mv	s7,s3
      state = 0;
 716:	4981                	li	s3,0
 718:	b3c9                	j	4da <vprintf+0x4a>
 71a:	64a6                	ld	s1,72(sp)
 71c:	79e2                	ld	s3,56(sp)
 71e:	7a42                	ld	s4,48(sp)
 720:	7aa2                	ld	s5,40(sp)
 722:	7b02                	ld	s6,32(sp)
 724:	6be2                	ld	s7,24(sp)
 726:	6c42                	ld	s8,16(sp)
 728:	6ca2                	ld	s9,8(sp)
    }
  }
}
 72a:	60e6                	ld	ra,88(sp)
 72c:	6446                	ld	s0,80(sp)
 72e:	6906                	ld	s2,64(sp)
 730:	6125                	addi	sp,sp,96
 732:	8082                	ret

0000000000000734 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 734:	715d                	addi	sp,sp,-80
 736:	ec06                	sd	ra,24(sp)
 738:	e822                	sd	s0,16(sp)
 73a:	1000                	addi	s0,sp,32
 73c:	e010                	sd	a2,0(s0)
 73e:	e414                	sd	a3,8(s0)
 740:	e818                	sd	a4,16(s0)
 742:	ec1c                	sd	a5,24(s0)
 744:	03043023          	sd	a6,32(s0)
 748:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 74c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 750:	8622                	mv	a2,s0
 752:	d3fff0ef          	jal	490 <vprintf>
}
 756:	60e2                	ld	ra,24(sp)
 758:	6442                	ld	s0,16(sp)
 75a:	6161                	addi	sp,sp,80
 75c:	8082                	ret

000000000000075e <printf>:

void
printf(const char *fmt, ...)
{
 75e:	711d                	addi	sp,sp,-96
 760:	ec06                	sd	ra,24(sp)
 762:	e822                	sd	s0,16(sp)
 764:	1000                	addi	s0,sp,32
 766:	e40c                	sd	a1,8(s0)
 768:	e810                	sd	a2,16(s0)
 76a:	ec14                	sd	a3,24(s0)
 76c:	f018                	sd	a4,32(s0)
 76e:	f41c                	sd	a5,40(s0)
 770:	03043823          	sd	a6,48(s0)
 774:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 778:	00840613          	addi	a2,s0,8
 77c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 780:	85aa                	mv	a1,a0
 782:	4505                	li	a0,1
 784:	d0dff0ef          	jal	490 <vprintf>
}
 788:	60e2                	ld	ra,24(sp)
 78a:	6442                	ld	s0,16(sp)
 78c:	6125                	addi	sp,sp,96
 78e:	8082                	ret

0000000000000790 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 790:	1141                	addi	sp,sp,-16
 792:	e422                	sd	s0,8(sp)
 794:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 796:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 79a:	00001797          	auipc	a5,0x1
 79e:	8667b783          	ld	a5,-1946(a5) # 1000 <freep>
 7a2:	a02d                	j	7cc <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7a4:	4618                	lw	a4,8(a2)
 7a6:	9f2d                	addw	a4,a4,a1
 7a8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ac:	6398                	ld	a4,0(a5)
 7ae:	6310                	ld	a2,0(a4)
 7b0:	a83d                	j	7ee <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7b2:	ff852703          	lw	a4,-8(a0)
 7b6:	9f31                	addw	a4,a4,a2
 7b8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7ba:	ff053683          	ld	a3,-16(a0)
 7be:	a091                	j	802 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c0:	6398                	ld	a4,0(a5)
 7c2:	00e7e463          	bltu	a5,a4,7ca <free+0x3a>
 7c6:	00e6ea63          	bltu	a3,a4,7da <free+0x4a>
{
 7ca:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7cc:	fed7fae3          	bgeu	a5,a3,7c0 <free+0x30>
 7d0:	6398                	ld	a4,0(a5)
 7d2:	00e6e463          	bltu	a3,a4,7da <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d6:	fee7eae3          	bltu	a5,a4,7ca <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7da:	ff852583          	lw	a1,-8(a0)
 7de:	6390                	ld	a2,0(a5)
 7e0:	02059813          	slli	a6,a1,0x20
 7e4:	01c85713          	srli	a4,a6,0x1c
 7e8:	9736                	add	a4,a4,a3
 7ea:	fae60de3          	beq	a2,a4,7a4 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7ee:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7f2:	4790                	lw	a2,8(a5)
 7f4:	02061593          	slli	a1,a2,0x20
 7f8:	01c5d713          	srli	a4,a1,0x1c
 7fc:	973e                	add	a4,a4,a5
 7fe:	fae68ae3          	beq	a3,a4,7b2 <free+0x22>
    p->s.ptr = bp->s.ptr;
 802:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 804:	00000717          	auipc	a4,0x0
 808:	7ef73e23          	sd	a5,2044(a4) # 1000 <freep>
}
 80c:	6422                	ld	s0,8(sp)
 80e:	0141                	addi	sp,sp,16
 810:	8082                	ret

0000000000000812 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 812:	7139                	addi	sp,sp,-64
 814:	fc06                	sd	ra,56(sp)
 816:	f822                	sd	s0,48(sp)
 818:	f426                	sd	s1,40(sp)
 81a:	ec4e                	sd	s3,24(sp)
 81c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 81e:	02051493          	slli	s1,a0,0x20
 822:	9081                	srli	s1,s1,0x20
 824:	04bd                	addi	s1,s1,15
 826:	8091                	srli	s1,s1,0x4
 828:	0014899b          	addiw	s3,s1,1
 82c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 82e:	00000517          	auipc	a0,0x0
 832:	7d253503          	ld	a0,2002(a0) # 1000 <freep>
 836:	c915                	beqz	a0,86a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 838:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 83a:	4798                	lw	a4,8(a5)
 83c:	08977a63          	bgeu	a4,s1,8d0 <malloc+0xbe>
 840:	f04a                	sd	s2,32(sp)
 842:	e852                	sd	s4,16(sp)
 844:	e456                	sd	s5,8(sp)
 846:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 848:	8a4e                	mv	s4,s3
 84a:	0009871b          	sext.w	a4,s3
 84e:	6685                	lui	a3,0x1
 850:	00d77363          	bgeu	a4,a3,856 <malloc+0x44>
 854:	6a05                	lui	s4,0x1
 856:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 85a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 85e:	00000917          	auipc	s2,0x0
 862:	7a290913          	addi	s2,s2,1954 # 1000 <freep>
  if(p == SBRK_ERROR)
 866:	5afd                	li	s5,-1
 868:	a081                	j	8a8 <malloc+0x96>
 86a:	f04a                	sd	s2,32(sp)
 86c:	e852                	sd	s4,16(sp)
 86e:	e456                	sd	s5,8(sp)
 870:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 872:	00001797          	auipc	a5,0x1
 876:	99678793          	addi	a5,a5,-1642 # 1208 <base>
 87a:	00000717          	auipc	a4,0x0
 87e:	78f73323          	sd	a5,1926(a4) # 1000 <freep>
 882:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 884:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 888:	b7c1                	j	848 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 88a:	6398                	ld	a4,0(a5)
 88c:	e118                	sd	a4,0(a0)
 88e:	a8a9                	j	8e8 <malloc+0xd6>
  hp->s.size = nu;
 890:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 894:	0541                	addi	a0,a0,16
 896:	efbff0ef          	jal	790 <free>
  return freep;
 89a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 89e:	c12d                	beqz	a0,900 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a2:	4798                	lw	a4,8(a5)
 8a4:	02977263          	bgeu	a4,s1,8c8 <malloc+0xb6>
    if(p == freep)
 8a8:	00093703          	ld	a4,0(s2)
 8ac:	853e                	mv	a0,a5
 8ae:	fef719e3          	bne	a4,a5,8a0 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8b2:	8552                	mv	a0,s4
 8b4:	a37ff0ef          	jal	2ea <sbrk>
  if(p == SBRK_ERROR)
 8b8:	fd551ce3          	bne	a0,s5,890 <malloc+0x7e>
        return 0;
 8bc:	4501                	li	a0,0
 8be:	7902                	ld	s2,32(sp)
 8c0:	6a42                	ld	s4,16(sp)
 8c2:	6aa2                	ld	s5,8(sp)
 8c4:	6b02                	ld	s6,0(sp)
 8c6:	a03d                	j	8f4 <malloc+0xe2>
 8c8:	7902                	ld	s2,32(sp)
 8ca:	6a42                	ld	s4,16(sp)
 8cc:	6aa2                	ld	s5,8(sp)
 8ce:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8d0:	fae48de3          	beq	s1,a4,88a <malloc+0x78>
        p->s.size -= nunits;
 8d4:	4137073b          	subw	a4,a4,s3
 8d8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8da:	02071693          	slli	a3,a4,0x20
 8de:	01c6d713          	srli	a4,a3,0x1c
 8e2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8e4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8e8:	00000717          	auipc	a4,0x0
 8ec:	70a73c23          	sd	a0,1816(a4) # 1000 <freep>
      return (void*)(p + 1);
 8f0:	01078513          	addi	a0,a5,16
  }
}
 8f4:	70e2                	ld	ra,56(sp)
 8f6:	7442                	ld	s0,48(sp)
 8f8:	74a2                	ld	s1,40(sp)
 8fa:	69e2                	ld	s3,24(sp)
 8fc:	6121                	addi	sp,sp,64
 8fe:	8082                	ret
 900:	7902                	ld	s2,32(sp)
 902:	6a42                	ld	s4,16(sp)
 904:	6aa2                	ld	s5,8(sp)
 906:	6b02                	ld	s6,0(sp)
 908:	b7f5                	j	8f4 <malloc+0xe2>
