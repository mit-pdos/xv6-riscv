
user/_forphan:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char buf[BUFSZ];

int
main(int argc, char **argv)
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	0080                	addi	s0,sp,64
  int fd = 0;
  char *s = argv[0];
   a:	6184                	ld	s1,0(a1)
  struct stat st;
  char *ff = "file0";
  
  if ((fd = open(ff, O_CREATE|O_WRONLY)) < 0) {
   c:	20100593          	li	a1,513
  10:	00001517          	auipc	a0,0x1
  14:	94050513          	addi	a0,a0,-1728 # 950 <malloc+0x104>
  18:	380000ef          	jal	398 <open>
  1c:	04054463          	bltz	a0,64 <main+0x64>
    printf("%s: open failed\n", s);
    exit(1);
  }
  if(fstat(fd, &st) < 0){
  20:	fc840593          	addi	a1,s0,-56
  24:	38c000ef          	jal	3b0 <fstat>
  28:	04054863          	bltz	a0,78 <main+0x78>
    fprintf(2, "%s: cannot stat %s\n", s, "ff");
    exit(1);
  }
  if (unlink(ff) < 0) {
  2c:	00001517          	auipc	a0,0x1
  30:	92450513          	addi	a0,a0,-1756 # 950 <malloc+0x104>
  34:	374000ef          	jal	3a8 <unlink>
  38:	04054f63          	bltz	a0,96 <main+0x96>
    printf("%s: unlink failed\n", s);
    exit(1);
  }
  if (open(ff, O_RDONLY) != -1) {
  3c:	4581                	li	a1,0
  3e:	00001517          	auipc	a0,0x1
  42:	91250513          	addi	a0,a0,-1774 # 950 <malloc+0x104>
  46:	352000ef          	jal	398 <open>
  4a:	57fd                	li	a5,-1
  4c:	04f50f63          	beq	a0,a5,aa <main+0xaa>
    printf("%s: open successed\n", s);
  50:	85a6                	mv	a1,s1
  52:	00001517          	auipc	a0,0x1
  56:	95e50513          	addi	a0,a0,-1698 # 9b0 <malloc+0x164>
  5a:	73e000ef          	jal	798 <printf>
    exit(1);
  5e:	4505                	li	a0,1
  60:	2f8000ef          	jal	358 <exit>
    printf("%s: open failed\n", s);
  64:	85a6                	mv	a1,s1
  66:	00001517          	auipc	a0,0x1
  6a:	8fa50513          	addi	a0,a0,-1798 # 960 <malloc+0x114>
  6e:	72a000ef          	jal	798 <printf>
    exit(1);
  72:	4505                	li	a0,1
  74:	2e4000ef          	jal	358 <exit>
    fprintf(2, "%s: cannot stat %s\n", s, "ff");
  78:	00001697          	auipc	a3,0x1
  7c:	90068693          	addi	a3,a3,-1792 # 978 <malloc+0x12c>
  80:	8626                	mv	a2,s1
  82:	00001597          	auipc	a1,0x1
  86:	8fe58593          	addi	a1,a1,-1794 # 980 <malloc+0x134>
  8a:	4509                	li	a0,2
  8c:	6e2000ef          	jal	76e <fprintf>
    exit(1);
  90:	4505                	li	a0,1
  92:	2c6000ef          	jal	358 <exit>
    printf("%s: unlink failed\n", s);
  96:	85a6                	mv	a1,s1
  98:	00001517          	auipc	a0,0x1
  9c:	90050513          	addi	a0,a0,-1792 # 998 <malloc+0x14c>
  a0:	6f8000ef          	jal	798 <printf>
    exit(1);
  a4:	4505                	li	a0,1
  a6:	2b2000ef          	jal	358 <exit>
  }
  printf("wait for kill and reclaim %d\n", st.ino);
  aa:	fcc42583          	lw	a1,-52(s0)
  ae:	00001517          	auipc	a0,0x1
  b2:	91a50513          	addi	a0,a0,-1766 # 9c8 <malloc+0x17c>
  b6:	6e2000ef          	jal	798 <printf>
  // sit around until killed
  for(;;) pause(1000);
  ba:	3e800513          	li	a0,1000
  be:	32a000ef          	jal	3e8 <pause>
  c2:	bfe5                	j	ba <main+0xba>

00000000000000c4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  c4:	1141                	addi	sp,sp,-16
  c6:	e406                	sd	ra,8(sp)
  c8:	e022                	sd	s0,0(sp)
  ca:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  cc:	f35ff0ef          	jal	0 <main>
  exit(r);
  d0:	288000ef          	jal	358 <exit>

00000000000000d4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  d4:	1141                	addi	sp,sp,-16
  d6:	e422                	sd	s0,8(sp)
  d8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  da:	87aa                	mv	a5,a0
  dc:	0585                	addi	a1,a1,1
  de:	0785                	addi	a5,a5,1
  e0:	fff5c703          	lbu	a4,-1(a1)
  e4:	fee78fa3          	sb	a4,-1(a5)
  e8:	fb75                	bnez	a4,dc <strcpy+0x8>
    ;
  return os;
}
  ea:	6422                	ld	s0,8(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret

00000000000000f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	cb91                	beqz	a5,10e <strcmp+0x1e>
  fc:	0005c703          	lbu	a4,0(a1)
 100:	00f71763          	bne	a4,a5,10e <strcmp+0x1e>
    p++, q++;
 104:	0505                	addi	a0,a0,1
 106:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 108:	00054783          	lbu	a5,0(a0)
 10c:	fbe5                	bnez	a5,fc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 10e:	0005c503          	lbu	a0,0(a1)
}
 112:	40a7853b          	subw	a0,a5,a0
 116:	6422                	ld	s0,8(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret

000000000000011c <strlen>:

uint
strlen(const char *s)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e422                	sd	s0,8(sp)
 120:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 122:	00054783          	lbu	a5,0(a0)
 126:	cf91                	beqz	a5,142 <strlen+0x26>
 128:	0505                	addi	a0,a0,1
 12a:	87aa                	mv	a5,a0
 12c:	86be                	mv	a3,a5
 12e:	0785                	addi	a5,a5,1
 130:	fff7c703          	lbu	a4,-1(a5)
 134:	ff65                	bnez	a4,12c <strlen+0x10>
 136:	40a6853b          	subw	a0,a3,a0
 13a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 13c:	6422                	ld	s0,8(sp)
 13e:	0141                	addi	sp,sp,16
 140:	8082                	ret
  for(n = 0; s[n]; n++)
 142:	4501                	li	a0,0
 144:	bfe5                	j	13c <strlen+0x20>

0000000000000146 <memset>:

void*
memset(void *dst, int c, uint n)
{
 146:	1141                	addi	sp,sp,-16
 148:	e422                	sd	s0,8(sp)
 14a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 14c:	ca19                	beqz	a2,162 <memset+0x1c>
 14e:	87aa                	mv	a5,a0
 150:	1602                	slli	a2,a2,0x20
 152:	9201                	srli	a2,a2,0x20
 154:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 158:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 15c:	0785                	addi	a5,a5,1
 15e:	fee79de3          	bne	a5,a4,158 <memset+0x12>
  }
  return dst;
}
 162:	6422                	ld	s0,8(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret

0000000000000168 <strchr>:

char*
strchr(const char *s, char c)
{
 168:	1141                	addi	sp,sp,-16
 16a:	e422                	sd	s0,8(sp)
 16c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 16e:	00054783          	lbu	a5,0(a0)
 172:	cb99                	beqz	a5,188 <strchr+0x20>
    if(*s == c)
 174:	00f58763          	beq	a1,a5,182 <strchr+0x1a>
  for(; *s; s++)
 178:	0505                	addi	a0,a0,1
 17a:	00054783          	lbu	a5,0(a0)
 17e:	fbfd                	bnez	a5,174 <strchr+0xc>
      return (char*)s;
  return 0;
 180:	4501                	li	a0,0
}
 182:	6422                	ld	s0,8(sp)
 184:	0141                	addi	sp,sp,16
 186:	8082                	ret
  return 0;
 188:	4501                	li	a0,0
 18a:	bfe5                	j	182 <strchr+0x1a>

000000000000018c <gets>:

char*
gets(char *buf, int max)
{
 18c:	711d                	addi	sp,sp,-96
 18e:	ec86                	sd	ra,88(sp)
 190:	e8a2                	sd	s0,80(sp)
 192:	e4a6                	sd	s1,72(sp)
 194:	e0ca                	sd	s2,64(sp)
 196:	fc4e                	sd	s3,56(sp)
 198:	f852                	sd	s4,48(sp)
 19a:	f456                	sd	s5,40(sp)
 19c:	f05a                	sd	s6,32(sp)
 19e:	ec5e                	sd	s7,24(sp)
 1a0:	1080                	addi	s0,sp,96
 1a2:	8baa                	mv	s7,a0
 1a4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a6:	892a                	mv	s2,a0
 1a8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1aa:	4aa9                	li	s5,10
 1ac:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ae:	89a6                	mv	s3,s1
 1b0:	2485                	addiw	s1,s1,1
 1b2:	0344d663          	bge	s1,s4,1de <gets+0x52>
    cc = read(0, &c, 1);
 1b6:	4605                	li	a2,1
 1b8:	faf40593          	addi	a1,s0,-81
 1bc:	4501                	li	a0,0
 1be:	1b2000ef          	jal	370 <read>
    if(cc < 1)
 1c2:	00a05e63          	blez	a0,1de <gets+0x52>
    buf[i++] = c;
 1c6:	faf44783          	lbu	a5,-81(s0)
 1ca:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1ce:	01578763          	beq	a5,s5,1dc <gets+0x50>
 1d2:	0905                	addi	s2,s2,1
 1d4:	fd679de3          	bne	a5,s6,1ae <gets+0x22>
    buf[i++] = c;
 1d8:	89a6                	mv	s3,s1
 1da:	a011                	j	1de <gets+0x52>
 1dc:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1de:	99de                	add	s3,s3,s7
 1e0:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e4:	855e                	mv	a0,s7
 1e6:	60e6                	ld	ra,88(sp)
 1e8:	6446                	ld	s0,80(sp)
 1ea:	64a6                	ld	s1,72(sp)
 1ec:	6906                	ld	s2,64(sp)
 1ee:	79e2                	ld	s3,56(sp)
 1f0:	7a42                	ld	s4,48(sp)
 1f2:	7aa2                	ld	s5,40(sp)
 1f4:	7b02                	ld	s6,32(sp)
 1f6:	6be2                	ld	s7,24(sp)
 1f8:	6125                	addi	sp,sp,96
 1fa:	8082                	ret

00000000000001fc <stat>:

int
stat(const char *n, struct stat *st)
{
 1fc:	1101                	addi	sp,sp,-32
 1fe:	ec06                	sd	ra,24(sp)
 200:	e822                	sd	s0,16(sp)
 202:	e04a                	sd	s2,0(sp)
 204:	1000                	addi	s0,sp,32
 206:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 208:	4581                	li	a1,0
 20a:	18e000ef          	jal	398 <open>
  if(fd < 0)
 20e:	02054263          	bltz	a0,232 <stat+0x36>
 212:	e426                	sd	s1,8(sp)
 214:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 216:	85ca                	mv	a1,s2
 218:	198000ef          	jal	3b0 <fstat>
 21c:	892a                	mv	s2,a0
  close(fd);
 21e:	8526                	mv	a0,s1
 220:	160000ef          	jal	380 <close>
  return r;
 224:	64a2                	ld	s1,8(sp)
}
 226:	854a                	mv	a0,s2
 228:	60e2                	ld	ra,24(sp)
 22a:	6442                	ld	s0,16(sp)
 22c:	6902                	ld	s2,0(sp)
 22e:	6105                	addi	sp,sp,32
 230:	8082                	ret
    return -1;
 232:	597d                	li	s2,-1
 234:	bfcd                	j	226 <stat+0x2a>

0000000000000236 <atoi>:

int
atoi(const char *s)
{
 236:	1141                	addi	sp,sp,-16
 238:	e422                	sd	s0,8(sp)
 23a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 23c:	00054683          	lbu	a3,0(a0)
 240:	fd06879b          	addiw	a5,a3,-48
 244:	0ff7f793          	zext.b	a5,a5
 248:	4625                	li	a2,9
 24a:	02f66863          	bltu	a2,a5,27a <atoi+0x44>
 24e:	872a                	mv	a4,a0
  n = 0;
 250:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 252:	0705                	addi	a4,a4,1
 254:	0025179b          	slliw	a5,a0,0x2
 258:	9fa9                	addw	a5,a5,a0
 25a:	0017979b          	slliw	a5,a5,0x1
 25e:	9fb5                	addw	a5,a5,a3
 260:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 264:	00074683          	lbu	a3,0(a4)
 268:	fd06879b          	addiw	a5,a3,-48
 26c:	0ff7f793          	zext.b	a5,a5
 270:	fef671e3          	bgeu	a2,a5,252 <atoi+0x1c>
  return n;
}
 274:	6422                	ld	s0,8(sp)
 276:	0141                	addi	sp,sp,16
 278:	8082                	ret
  n = 0;
 27a:	4501                	li	a0,0
 27c:	bfe5                	j	274 <atoi+0x3e>

000000000000027e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 27e:	1141                	addi	sp,sp,-16
 280:	e422                	sd	s0,8(sp)
 282:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 284:	02b57463          	bgeu	a0,a1,2ac <memmove+0x2e>
    while(n-- > 0)
 288:	00c05f63          	blez	a2,2a6 <memmove+0x28>
 28c:	1602                	slli	a2,a2,0x20
 28e:	9201                	srli	a2,a2,0x20
 290:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 294:	872a                	mv	a4,a0
      *dst++ = *src++;
 296:	0585                	addi	a1,a1,1
 298:	0705                	addi	a4,a4,1
 29a:	fff5c683          	lbu	a3,-1(a1)
 29e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2a2:	fef71ae3          	bne	a4,a5,296 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a6:	6422                	ld	s0,8(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret
    dst += n;
 2ac:	00c50733          	add	a4,a0,a2
    src += n;
 2b0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b2:	fec05ae3          	blez	a2,2a6 <memmove+0x28>
 2b6:	fff6079b          	addiw	a5,a2,-1
 2ba:	1782                	slli	a5,a5,0x20
 2bc:	9381                	srli	a5,a5,0x20
 2be:	fff7c793          	not	a5,a5
 2c2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c4:	15fd                	addi	a1,a1,-1
 2c6:	177d                	addi	a4,a4,-1
 2c8:	0005c683          	lbu	a3,0(a1)
 2cc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2d0:	fee79ae3          	bne	a5,a4,2c4 <memmove+0x46>
 2d4:	bfc9                	j	2a6 <memmove+0x28>

00000000000002d6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e422                	sd	s0,8(sp)
 2da:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2dc:	ca05                	beqz	a2,30c <memcmp+0x36>
 2de:	fff6069b          	addiw	a3,a2,-1
 2e2:	1682                	slli	a3,a3,0x20
 2e4:	9281                	srli	a3,a3,0x20
 2e6:	0685                	addi	a3,a3,1
 2e8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ea:	00054783          	lbu	a5,0(a0)
 2ee:	0005c703          	lbu	a4,0(a1)
 2f2:	00e79863          	bne	a5,a4,302 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2f6:	0505                	addi	a0,a0,1
    p2++;
 2f8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2fa:	fed518e3          	bne	a0,a3,2ea <memcmp+0x14>
  }
  return 0;
 2fe:	4501                	li	a0,0
 300:	a019                	j	306 <memcmp+0x30>
      return *p1 - *p2;
 302:	40e7853b          	subw	a0,a5,a4
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret
  return 0;
 30c:	4501                	li	a0,0
 30e:	bfe5                	j	306 <memcmp+0x30>

0000000000000310 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e406                	sd	ra,8(sp)
 314:	e022                	sd	s0,0(sp)
 316:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 318:	f67ff0ef          	jal	27e <memmove>
}
 31c:	60a2                	ld	ra,8(sp)
 31e:	6402                	ld	s0,0(sp)
 320:	0141                	addi	sp,sp,16
 322:	8082                	ret

0000000000000324 <sbrk>:

char *
sbrk(int n) {
 324:	1141                	addi	sp,sp,-16
 326:	e406                	sd	ra,8(sp)
 328:	e022                	sd	s0,0(sp)
 32a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 32c:	4585                	li	a1,1
 32e:	0b2000ef          	jal	3e0 <sys_sbrk>
}
 332:	60a2                	ld	ra,8(sp)
 334:	6402                	ld	s0,0(sp)
 336:	0141                	addi	sp,sp,16
 338:	8082                	ret

000000000000033a <sbrklazy>:

char *
sbrklazy(int n) {
 33a:	1141                	addi	sp,sp,-16
 33c:	e406                	sd	ra,8(sp)
 33e:	e022                	sd	s0,0(sp)
 340:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 342:	4589                	li	a1,2
 344:	09c000ef          	jal	3e0 <sys_sbrk>
}
 348:	60a2                	ld	ra,8(sp)
 34a:	6402                	ld	s0,0(sp)
 34c:	0141                	addi	sp,sp,16
 34e:	8082                	ret

0000000000000350 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 350:	4885                	li	a7,1
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <exit>:
.global exit
exit:
 li a7, SYS_exit
 358:	4889                	li	a7,2
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <wait>:
.global wait
wait:
 li a7, SYS_wait
 360:	488d                	li	a7,3
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 368:	4891                	li	a7,4
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <read>:
.global read
read:
 li a7, SYS_read
 370:	4895                	li	a7,5
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <write>:
.global write
write:
 li a7, SYS_write
 378:	48c1                	li	a7,16
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <close>:
.global close
close:
 li a7, SYS_close
 380:	48d5                	li	a7,21
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <kill>:
.global kill
kill:
 li a7, SYS_kill
 388:	4899                	li	a7,6
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <exec>:
.global exec
exec:
 li a7, SYS_exec
 390:	489d                	li	a7,7
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <open>:
.global open
open:
 li a7, SYS_open
 398:	48bd                	li	a7,15
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a0:	48c5                	li	a7,17
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3a8:	48c9                	li	a7,18
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b0:	48a1                	li	a7,8
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <link>:
.global link
link:
 li a7, SYS_link
 3b8:	48cd                	li	a7,19
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c0:	48d1                	li	a7,20
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3c8:	48a5                	li	a7,9
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d0:	48a9                	li	a7,10
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3d8:	48ad                	li	a7,11
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3e0:	48b1                	li	a7,12
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3e8:	48b5                	li	a7,13
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f0:	48b9                	li	a7,14
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <getprocsinfo>:
.global getprocsinfo
getprocsinfo:
 li a7, SYS_getprocsinfo
 3f8:	48d9                	li	a7,22
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 400:	48dd                	li	a7,23
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <sleep2>:
.global sleep2
sleep2:
 li a7, SYS_sleep2
 408:	48e1                	li	a7,24
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 410:	1101                	addi	sp,sp,-32
 412:	ec06                	sd	ra,24(sp)
 414:	e822                	sd	s0,16(sp)
 416:	1000                	addi	s0,sp,32
 418:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 41c:	4605                	li	a2,1
 41e:	fef40593          	addi	a1,s0,-17
 422:	f57ff0ef          	jal	378 <write>
}
 426:	60e2                	ld	ra,24(sp)
 428:	6442                	ld	s0,16(sp)
 42a:	6105                	addi	sp,sp,32
 42c:	8082                	ret

000000000000042e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 42e:	715d                	addi	sp,sp,-80
 430:	e486                	sd	ra,72(sp)
 432:	e0a2                	sd	s0,64(sp)
 434:	f84a                	sd	s2,48(sp)
 436:	0880                	addi	s0,sp,80
 438:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 43a:	c299                	beqz	a3,440 <printint+0x12>
 43c:	0805c363          	bltz	a1,4c2 <printint+0x94>
  neg = 0;
 440:	4881                	li	a7,0
 442:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 446:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 448:	00000517          	auipc	a0,0x0
 44c:	5a850513          	addi	a0,a0,1448 # 9f0 <digits>
 450:	883e                	mv	a6,a5
 452:	2785                	addiw	a5,a5,1
 454:	02c5f733          	remu	a4,a1,a2
 458:	972a                	add	a4,a4,a0
 45a:	00074703          	lbu	a4,0(a4)
 45e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 462:	872e                	mv	a4,a1
 464:	02c5d5b3          	divu	a1,a1,a2
 468:	0685                	addi	a3,a3,1
 46a:	fec773e3          	bgeu	a4,a2,450 <printint+0x22>
  if(neg)
 46e:	00088b63          	beqz	a7,484 <printint+0x56>
    buf[i++] = '-';
 472:	fd078793          	addi	a5,a5,-48
 476:	97a2                	add	a5,a5,s0
 478:	02d00713          	li	a4,45
 47c:	fee78423          	sb	a4,-24(a5)
 480:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 484:	02f05a63          	blez	a5,4b8 <printint+0x8a>
 488:	fc26                	sd	s1,56(sp)
 48a:	f44e                	sd	s3,40(sp)
 48c:	fb840713          	addi	a4,s0,-72
 490:	00f704b3          	add	s1,a4,a5
 494:	fff70993          	addi	s3,a4,-1
 498:	99be                	add	s3,s3,a5
 49a:	37fd                	addiw	a5,a5,-1
 49c:	1782                	slli	a5,a5,0x20
 49e:	9381                	srli	a5,a5,0x20
 4a0:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4a4:	fff4c583          	lbu	a1,-1(s1)
 4a8:	854a                	mv	a0,s2
 4aa:	f67ff0ef          	jal	410 <putc>
  while(--i >= 0)
 4ae:	14fd                	addi	s1,s1,-1
 4b0:	ff349ae3          	bne	s1,s3,4a4 <printint+0x76>
 4b4:	74e2                	ld	s1,56(sp)
 4b6:	79a2                	ld	s3,40(sp)
}
 4b8:	60a6                	ld	ra,72(sp)
 4ba:	6406                	ld	s0,64(sp)
 4bc:	7942                	ld	s2,48(sp)
 4be:	6161                	addi	sp,sp,80
 4c0:	8082                	ret
    x = -xx;
 4c2:	40b005b3          	neg	a1,a1
    neg = 1;
 4c6:	4885                	li	a7,1
    x = -xx;
 4c8:	bfad                	j	442 <printint+0x14>

00000000000004ca <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ca:	711d                	addi	sp,sp,-96
 4cc:	ec86                	sd	ra,88(sp)
 4ce:	e8a2                	sd	s0,80(sp)
 4d0:	e0ca                	sd	s2,64(sp)
 4d2:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4d4:	0005c903          	lbu	s2,0(a1)
 4d8:	28090663          	beqz	s2,764 <vprintf+0x29a>
 4dc:	e4a6                	sd	s1,72(sp)
 4de:	fc4e                	sd	s3,56(sp)
 4e0:	f852                	sd	s4,48(sp)
 4e2:	f456                	sd	s5,40(sp)
 4e4:	f05a                	sd	s6,32(sp)
 4e6:	ec5e                	sd	s7,24(sp)
 4e8:	e862                	sd	s8,16(sp)
 4ea:	e466                	sd	s9,8(sp)
 4ec:	8b2a                	mv	s6,a0
 4ee:	8a2e                	mv	s4,a1
 4f0:	8bb2                	mv	s7,a2
  state = 0;
 4f2:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4f4:	4481                	li	s1,0
 4f6:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4f8:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4fc:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 500:	06c00c93          	li	s9,108
 504:	a005                	j	524 <vprintf+0x5a>
        putc(fd, c0);
 506:	85ca                	mv	a1,s2
 508:	855a                	mv	a0,s6
 50a:	f07ff0ef          	jal	410 <putc>
 50e:	a019                	j	514 <vprintf+0x4a>
    } else if(state == '%'){
 510:	03598263          	beq	s3,s5,534 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 514:	2485                	addiw	s1,s1,1
 516:	8726                	mv	a4,s1
 518:	009a07b3          	add	a5,s4,s1
 51c:	0007c903          	lbu	s2,0(a5)
 520:	22090a63          	beqz	s2,754 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 524:	0009079b          	sext.w	a5,s2
    if(state == 0){
 528:	fe0994e3          	bnez	s3,510 <vprintf+0x46>
      if(c0 == '%'){
 52c:	fd579de3          	bne	a5,s5,506 <vprintf+0x3c>
        state = '%';
 530:	89be                	mv	s3,a5
 532:	b7cd                	j	514 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 534:	00ea06b3          	add	a3,s4,a4
 538:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 53c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 53e:	c681                	beqz	a3,546 <vprintf+0x7c>
 540:	9752                	add	a4,a4,s4
 542:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 546:	05878363          	beq	a5,s8,58c <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 54a:	05978d63          	beq	a5,s9,5a4 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 54e:	07500713          	li	a4,117
 552:	0ee78763          	beq	a5,a4,640 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 556:	07800713          	li	a4,120
 55a:	12e78963          	beq	a5,a4,68c <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 55e:	07000713          	li	a4,112
 562:	14e78e63          	beq	a5,a4,6be <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 566:	06300713          	li	a4,99
 56a:	18e78e63          	beq	a5,a4,706 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 56e:	07300713          	li	a4,115
 572:	1ae78463          	beq	a5,a4,71a <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 576:	02500713          	li	a4,37
 57a:	04e79563          	bne	a5,a4,5c4 <vprintf+0xfa>
        putc(fd, '%');
 57e:	02500593          	li	a1,37
 582:	855a                	mv	a0,s6
 584:	e8dff0ef          	jal	410 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 588:	4981                	li	s3,0
 58a:	b769                	j	514 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 58c:	008b8913          	addi	s2,s7,8
 590:	4685                	li	a3,1
 592:	4629                	li	a2,10
 594:	000ba583          	lw	a1,0(s7)
 598:	855a                	mv	a0,s6
 59a:	e95ff0ef          	jal	42e <printint>
 59e:	8bca                	mv	s7,s2
      state = 0;
 5a0:	4981                	li	s3,0
 5a2:	bf8d                	j	514 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5a4:	06400793          	li	a5,100
 5a8:	02f68963          	beq	a3,a5,5da <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5ac:	06c00793          	li	a5,108
 5b0:	04f68263          	beq	a3,a5,5f4 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 5b4:	07500793          	li	a5,117
 5b8:	0af68063          	beq	a3,a5,658 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 5bc:	07800793          	li	a5,120
 5c0:	0ef68263          	beq	a3,a5,6a4 <vprintf+0x1da>
        putc(fd, '%');
 5c4:	02500593          	li	a1,37
 5c8:	855a                	mv	a0,s6
 5ca:	e47ff0ef          	jal	410 <putc>
        putc(fd, c0);
 5ce:	85ca                	mv	a1,s2
 5d0:	855a                	mv	a0,s6
 5d2:	e3fff0ef          	jal	410 <putc>
      state = 0;
 5d6:	4981                	li	s3,0
 5d8:	bf35                	j	514 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5da:	008b8913          	addi	s2,s7,8
 5de:	4685                	li	a3,1
 5e0:	4629                	li	a2,10
 5e2:	000bb583          	ld	a1,0(s7)
 5e6:	855a                	mv	a0,s6
 5e8:	e47ff0ef          	jal	42e <printint>
        i += 1;
 5ec:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ee:	8bca                	mv	s7,s2
      state = 0;
 5f0:	4981                	li	s3,0
        i += 1;
 5f2:	b70d                	j	514 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5f4:	06400793          	li	a5,100
 5f8:	02f60763          	beq	a2,a5,626 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5fc:	07500793          	li	a5,117
 600:	06f60963          	beq	a2,a5,672 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 604:	07800793          	li	a5,120
 608:	faf61ee3          	bne	a2,a5,5c4 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 60c:	008b8913          	addi	s2,s7,8
 610:	4681                	li	a3,0
 612:	4641                	li	a2,16
 614:	000bb583          	ld	a1,0(s7)
 618:	855a                	mv	a0,s6
 61a:	e15ff0ef          	jal	42e <printint>
        i += 2;
 61e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 620:	8bca                	mv	s7,s2
      state = 0;
 622:	4981                	li	s3,0
        i += 2;
 624:	bdc5                	j	514 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 626:	008b8913          	addi	s2,s7,8
 62a:	4685                	li	a3,1
 62c:	4629                	li	a2,10
 62e:	000bb583          	ld	a1,0(s7)
 632:	855a                	mv	a0,s6
 634:	dfbff0ef          	jal	42e <printint>
        i += 2;
 638:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 63a:	8bca                	mv	s7,s2
      state = 0;
 63c:	4981                	li	s3,0
        i += 2;
 63e:	bdd9                	j	514 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 640:	008b8913          	addi	s2,s7,8
 644:	4681                	li	a3,0
 646:	4629                	li	a2,10
 648:	000be583          	lwu	a1,0(s7)
 64c:	855a                	mv	a0,s6
 64e:	de1ff0ef          	jal	42e <printint>
 652:	8bca                	mv	s7,s2
      state = 0;
 654:	4981                	li	s3,0
 656:	bd7d                	j	514 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 658:	008b8913          	addi	s2,s7,8
 65c:	4681                	li	a3,0
 65e:	4629                	li	a2,10
 660:	000bb583          	ld	a1,0(s7)
 664:	855a                	mv	a0,s6
 666:	dc9ff0ef          	jal	42e <printint>
        i += 1;
 66a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 66c:	8bca                	mv	s7,s2
      state = 0;
 66e:	4981                	li	s3,0
        i += 1;
 670:	b555                	j	514 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 672:	008b8913          	addi	s2,s7,8
 676:	4681                	li	a3,0
 678:	4629                	li	a2,10
 67a:	000bb583          	ld	a1,0(s7)
 67e:	855a                	mv	a0,s6
 680:	dafff0ef          	jal	42e <printint>
        i += 2;
 684:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 686:	8bca                	mv	s7,s2
      state = 0;
 688:	4981                	li	s3,0
        i += 2;
 68a:	b569                	j	514 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 68c:	008b8913          	addi	s2,s7,8
 690:	4681                	li	a3,0
 692:	4641                	li	a2,16
 694:	000be583          	lwu	a1,0(s7)
 698:	855a                	mv	a0,s6
 69a:	d95ff0ef          	jal	42e <printint>
 69e:	8bca                	mv	s7,s2
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	bd8d                	j	514 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a4:	008b8913          	addi	s2,s7,8
 6a8:	4681                	li	a3,0
 6aa:	4641                	li	a2,16
 6ac:	000bb583          	ld	a1,0(s7)
 6b0:	855a                	mv	a0,s6
 6b2:	d7dff0ef          	jal	42e <printint>
        i += 1;
 6b6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b8:	8bca                	mv	s7,s2
      state = 0;
 6ba:	4981                	li	s3,0
        i += 1;
 6bc:	bda1                	j	514 <vprintf+0x4a>
 6be:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6c0:	008b8d13          	addi	s10,s7,8
 6c4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6c8:	03000593          	li	a1,48
 6cc:	855a                	mv	a0,s6
 6ce:	d43ff0ef          	jal	410 <putc>
  putc(fd, 'x');
 6d2:	07800593          	li	a1,120
 6d6:	855a                	mv	a0,s6
 6d8:	d39ff0ef          	jal	410 <putc>
 6dc:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6de:	00000b97          	auipc	s7,0x0
 6e2:	312b8b93          	addi	s7,s7,786 # 9f0 <digits>
 6e6:	03c9d793          	srli	a5,s3,0x3c
 6ea:	97de                	add	a5,a5,s7
 6ec:	0007c583          	lbu	a1,0(a5)
 6f0:	855a                	mv	a0,s6
 6f2:	d1fff0ef          	jal	410 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6f6:	0992                	slli	s3,s3,0x4
 6f8:	397d                	addiw	s2,s2,-1
 6fa:	fe0916e3          	bnez	s2,6e6 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 6fe:	8bea                	mv	s7,s10
      state = 0;
 700:	4981                	li	s3,0
 702:	6d02                	ld	s10,0(sp)
 704:	bd01                	j	514 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 706:	008b8913          	addi	s2,s7,8
 70a:	000bc583          	lbu	a1,0(s7)
 70e:	855a                	mv	a0,s6
 710:	d01ff0ef          	jal	410 <putc>
 714:	8bca                	mv	s7,s2
      state = 0;
 716:	4981                	li	s3,0
 718:	bbf5                	j	514 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 71a:	008b8993          	addi	s3,s7,8
 71e:	000bb903          	ld	s2,0(s7)
 722:	00090f63          	beqz	s2,740 <vprintf+0x276>
        for(; *s; s++)
 726:	00094583          	lbu	a1,0(s2)
 72a:	c195                	beqz	a1,74e <vprintf+0x284>
          putc(fd, *s);
 72c:	855a                	mv	a0,s6
 72e:	ce3ff0ef          	jal	410 <putc>
        for(; *s; s++)
 732:	0905                	addi	s2,s2,1
 734:	00094583          	lbu	a1,0(s2)
 738:	f9f5                	bnez	a1,72c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 73a:	8bce                	mv	s7,s3
      state = 0;
 73c:	4981                	li	s3,0
 73e:	bbd9                	j	514 <vprintf+0x4a>
          s = "(null)";
 740:	00000917          	auipc	s2,0x0
 744:	2a890913          	addi	s2,s2,680 # 9e8 <malloc+0x19c>
        for(; *s; s++)
 748:	02800593          	li	a1,40
 74c:	b7c5                	j	72c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 74e:	8bce                	mv	s7,s3
      state = 0;
 750:	4981                	li	s3,0
 752:	b3c9                	j	514 <vprintf+0x4a>
 754:	64a6                	ld	s1,72(sp)
 756:	79e2                	ld	s3,56(sp)
 758:	7a42                	ld	s4,48(sp)
 75a:	7aa2                	ld	s5,40(sp)
 75c:	7b02                	ld	s6,32(sp)
 75e:	6be2                	ld	s7,24(sp)
 760:	6c42                	ld	s8,16(sp)
 762:	6ca2                	ld	s9,8(sp)
    }
  }
}
 764:	60e6                	ld	ra,88(sp)
 766:	6446                	ld	s0,80(sp)
 768:	6906                	ld	s2,64(sp)
 76a:	6125                	addi	sp,sp,96
 76c:	8082                	ret

000000000000076e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 76e:	715d                	addi	sp,sp,-80
 770:	ec06                	sd	ra,24(sp)
 772:	e822                	sd	s0,16(sp)
 774:	1000                	addi	s0,sp,32
 776:	e010                	sd	a2,0(s0)
 778:	e414                	sd	a3,8(s0)
 77a:	e818                	sd	a4,16(s0)
 77c:	ec1c                	sd	a5,24(s0)
 77e:	03043023          	sd	a6,32(s0)
 782:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 786:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 78a:	8622                	mv	a2,s0
 78c:	d3fff0ef          	jal	4ca <vprintf>
}
 790:	60e2                	ld	ra,24(sp)
 792:	6442                	ld	s0,16(sp)
 794:	6161                	addi	sp,sp,80
 796:	8082                	ret

0000000000000798 <printf>:

void
printf(const char *fmt, ...)
{
 798:	711d                	addi	sp,sp,-96
 79a:	ec06                	sd	ra,24(sp)
 79c:	e822                	sd	s0,16(sp)
 79e:	1000                	addi	s0,sp,32
 7a0:	e40c                	sd	a1,8(s0)
 7a2:	e810                	sd	a2,16(s0)
 7a4:	ec14                	sd	a3,24(s0)
 7a6:	f018                	sd	a4,32(s0)
 7a8:	f41c                	sd	a5,40(s0)
 7aa:	03043823          	sd	a6,48(s0)
 7ae:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7b2:	00840613          	addi	a2,s0,8
 7b6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7ba:	85aa                	mv	a1,a0
 7bc:	4505                	li	a0,1
 7be:	d0dff0ef          	jal	4ca <vprintf>
}
 7c2:	60e2                	ld	ra,24(sp)
 7c4:	6442                	ld	s0,16(sp)
 7c6:	6125                	addi	sp,sp,96
 7c8:	8082                	ret

00000000000007ca <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ca:	1141                	addi	sp,sp,-16
 7cc:	e422                	sd	s0,8(sp)
 7ce:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7d0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d4:	00001797          	auipc	a5,0x1
 7d8:	82c7b783          	ld	a5,-2004(a5) # 1000 <freep>
 7dc:	a02d                	j	806 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7de:	4618                	lw	a4,8(a2)
 7e0:	9f2d                	addw	a4,a4,a1
 7e2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e6:	6398                	ld	a4,0(a5)
 7e8:	6310                	ld	a2,0(a4)
 7ea:	a83d                	j	828 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ec:	ff852703          	lw	a4,-8(a0)
 7f0:	9f31                	addw	a4,a4,a2
 7f2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7f4:	ff053683          	ld	a3,-16(a0)
 7f8:	a091                	j	83c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7fa:	6398                	ld	a4,0(a5)
 7fc:	00e7e463          	bltu	a5,a4,804 <free+0x3a>
 800:	00e6ea63          	bltu	a3,a4,814 <free+0x4a>
{
 804:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 806:	fed7fae3          	bgeu	a5,a3,7fa <free+0x30>
 80a:	6398                	ld	a4,0(a5)
 80c:	00e6e463          	bltu	a3,a4,814 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 810:	fee7eae3          	bltu	a5,a4,804 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 814:	ff852583          	lw	a1,-8(a0)
 818:	6390                	ld	a2,0(a5)
 81a:	02059813          	slli	a6,a1,0x20
 81e:	01c85713          	srli	a4,a6,0x1c
 822:	9736                	add	a4,a4,a3
 824:	fae60de3          	beq	a2,a4,7de <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 828:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 82c:	4790                	lw	a2,8(a5)
 82e:	02061593          	slli	a1,a2,0x20
 832:	01c5d713          	srli	a4,a1,0x1c
 836:	973e                	add	a4,a4,a5
 838:	fae68ae3          	beq	a3,a4,7ec <free+0x22>
    p->s.ptr = bp->s.ptr;
 83c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 83e:	00000717          	auipc	a4,0x0
 842:	7cf73123          	sd	a5,1986(a4) # 1000 <freep>
}
 846:	6422                	ld	s0,8(sp)
 848:	0141                	addi	sp,sp,16
 84a:	8082                	ret

000000000000084c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 84c:	7139                	addi	sp,sp,-64
 84e:	fc06                	sd	ra,56(sp)
 850:	f822                	sd	s0,48(sp)
 852:	f426                	sd	s1,40(sp)
 854:	ec4e                	sd	s3,24(sp)
 856:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 858:	02051493          	slli	s1,a0,0x20
 85c:	9081                	srli	s1,s1,0x20
 85e:	04bd                	addi	s1,s1,15
 860:	8091                	srli	s1,s1,0x4
 862:	0014899b          	addiw	s3,s1,1
 866:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 868:	00000517          	auipc	a0,0x0
 86c:	79853503          	ld	a0,1944(a0) # 1000 <freep>
 870:	c915                	beqz	a0,8a4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 872:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 874:	4798                	lw	a4,8(a5)
 876:	08977a63          	bgeu	a4,s1,90a <malloc+0xbe>
 87a:	f04a                	sd	s2,32(sp)
 87c:	e852                	sd	s4,16(sp)
 87e:	e456                	sd	s5,8(sp)
 880:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 882:	8a4e                	mv	s4,s3
 884:	0009871b          	sext.w	a4,s3
 888:	6685                	lui	a3,0x1
 88a:	00d77363          	bgeu	a4,a3,890 <malloc+0x44>
 88e:	6a05                	lui	s4,0x1
 890:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 894:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 898:	00000917          	auipc	s2,0x0
 89c:	76890913          	addi	s2,s2,1896 # 1000 <freep>
  if(p == SBRK_ERROR)
 8a0:	5afd                	li	s5,-1
 8a2:	a081                	j	8e2 <malloc+0x96>
 8a4:	f04a                	sd	s2,32(sp)
 8a6:	e852                	sd	s4,16(sp)
 8a8:	e456                	sd	s5,8(sp)
 8aa:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8ac:	00001797          	auipc	a5,0x1
 8b0:	95c78793          	addi	a5,a5,-1700 # 1208 <base>
 8b4:	00000717          	auipc	a4,0x0
 8b8:	74f73623          	sd	a5,1868(a4) # 1000 <freep>
 8bc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8be:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8c2:	b7c1                	j	882 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8c4:	6398                	ld	a4,0(a5)
 8c6:	e118                	sd	a4,0(a0)
 8c8:	a8a9                	j	922 <malloc+0xd6>
  hp->s.size = nu;
 8ca:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ce:	0541                	addi	a0,a0,16
 8d0:	efbff0ef          	jal	7ca <free>
  return freep;
 8d4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8d8:	c12d                	beqz	a0,93a <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8da:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8dc:	4798                	lw	a4,8(a5)
 8de:	02977263          	bgeu	a4,s1,902 <malloc+0xb6>
    if(p == freep)
 8e2:	00093703          	ld	a4,0(s2)
 8e6:	853e                	mv	a0,a5
 8e8:	fef719e3          	bne	a4,a5,8da <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8ec:	8552                	mv	a0,s4
 8ee:	a37ff0ef          	jal	324 <sbrk>
  if(p == SBRK_ERROR)
 8f2:	fd551ce3          	bne	a0,s5,8ca <malloc+0x7e>
        return 0;
 8f6:	4501                	li	a0,0
 8f8:	7902                	ld	s2,32(sp)
 8fa:	6a42                	ld	s4,16(sp)
 8fc:	6aa2                	ld	s5,8(sp)
 8fe:	6b02                	ld	s6,0(sp)
 900:	a03d                	j	92e <malloc+0xe2>
 902:	7902                	ld	s2,32(sp)
 904:	6a42                	ld	s4,16(sp)
 906:	6aa2                	ld	s5,8(sp)
 908:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 90a:	fae48de3          	beq	s1,a4,8c4 <malloc+0x78>
        p->s.size -= nunits;
 90e:	4137073b          	subw	a4,a4,s3
 912:	c798                	sw	a4,8(a5)
        p += p->s.size;
 914:	02071693          	slli	a3,a4,0x20
 918:	01c6d713          	srli	a4,a3,0x1c
 91c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 91e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 922:	00000717          	auipc	a4,0x0
 926:	6ca73f23          	sd	a0,1758(a4) # 1000 <freep>
      return (void*)(p + 1);
 92a:	01078513          	addi	a0,a5,16
  }
}
 92e:	70e2                	ld	ra,56(sp)
 930:	7442                	ld	s0,48(sp)
 932:	74a2                	ld	s1,40(sp)
 934:	69e2                	ld	s3,24(sp)
 936:	6121                	addi	sp,sp,64
 938:	8082                	ret
 93a:	7902                	ld	s2,32(sp)
 93c:	6a42                	ld	s4,16(sp)
 93e:	6aa2                	ld	s5,8(sp)
 940:	6b02                	ld	s6,0(sp)
 942:	b7f5                	j	92e <malloc+0xe2>
