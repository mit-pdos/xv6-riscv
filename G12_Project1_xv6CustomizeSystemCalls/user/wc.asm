
user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	f8a43423          	sd	a0,-120(s0)
  22:	f8b43023          	sd	a1,-128(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  26:	4901                	li	s2,0
  l = w = c = 0;
  28:	4d01                	li	s10,0
  2a:	4c81                	li	s9,0
  2c:	4c01                	li	s8,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  2e:	00001d97          	auipc	s11,0x1
  32:	fe2d8d93          	addi	s11,s11,-30 # 1010 <buf>
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  36:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  38:	00001a17          	auipc	s4,0x1
  3c:	9a8a0a13          	addi	s4,s4,-1624 # 9e0 <malloc+0xfc>
        inword = 0;
  40:	4b81                	li	s7,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  42:	a035                	j	6e <wc+0x6e>
      if(strchr(" \r\t\n\v", buf[i]))
  44:	8552                	mv	a0,s4
  46:	1ba000ef          	jal	200 <strchr>
  4a:	c919                	beqz	a0,60 <wc+0x60>
        inword = 0;
  4c:	895e                	mv	s2,s7
    for(i=0; i<n; i++){
  4e:	0485                	addi	s1,s1,1
  50:	01348d63          	beq	s1,s3,6a <wc+0x6a>
      if(buf[i] == '\n')
  54:	0004c583          	lbu	a1,0(s1)
  58:	ff5596e3          	bne	a1,s5,44 <wc+0x44>
        l++;
  5c:	2c05                	addiw	s8,s8,1
  5e:	b7dd                	j	44 <wc+0x44>
      else if(!inword){
  60:	fe0917e3          	bnez	s2,4e <wc+0x4e>
        w++;
  64:	2c85                	addiw	s9,s9,1
        inword = 1;
  66:	4905                	li	s2,1
  68:	b7dd                	j	4e <wc+0x4e>
  6a:	01ab0d3b          	addw	s10,s6,s10
  while((n = read(fd, buf, sizeof(buf))) > 0){
  6e:	20000613          	li	a2,512
  72:	85ee                	mv	a1,s11
  74:	f8843503          	ld	a0,-120(s0)
  78:	390000ef          	jal	408 <read>
  7c:	8b2a                	mv	s6,a0
  7e:	00a05963          	blez	a0,90 <wc+0x90>
    for(i=0; i<n; i++){
  82:	00001497          	auipc	s1,0x1
  86:	f8e48493          	addi	s1,s1,-114 # 1010 <buf>
  8a:	009509b3          	add	s3,a0,s1
  8e:	b7d9                	j	54 <wc+0x54>
      }
    }
  }
  if(n < 0){
  90:	02054c63          	bltz	a0,c8 <wc+0xc8>
    printf("wc: read error\n");
    exit(1);
  }
  printf("%d %d %d %s\n", l, w, c, name);
  94:	f8043703          	ld	a4,-128(s0)
  98:	86ea                	mv	a3,s10
  9a:	8666                	mv	a2,s9
  9c:	85e2                	mv	a1,s8
  9e:	00001517          	auipc	a0,0x1
  a2:	96250513          	addi	a0,a0,-1694 # a00 <malloc+0x11c>
  a6:	78a000ef          	jal	830 <printf>
}
  aa:	70e6                	ld	ra,120(sp)
  ac:	7446                	ld	s0,112(sp)
  ae:	74a6                	ld	s1,104(sp)
  b0:	7906                	ld	s2,96(sp)
  b2:	69e6                	ld	s3,88(sp)
  b4:	6a46                	ld	s4,80(sp)
  b6:	6aa6                	ld	s5,72(sp)
  b8:	6b06                	ld	s6,64(sp)
  ba:	7be2                	ld	s7,56(sp)
  bc:	7c42                	ld	s8,48(sp)
  be:	7ca2                	ld	s9,40(sp)
  c0:	7d02                	ld	s10,32(sp)
  c2:	6de2                	ld	s11,24(sp)
  c4:	6109                	addi	sp,sp,128
  c6:	8082                	ret
    printf("wc: read error\n");
  c8:	00001517          	auipc	a0,0x1
  cc:	92850513          	addi	a0,a0,-1752 # 9f0 <malloc+0x10c>
  d0:	760000ef          	jal	830 <printf>
    exit(1);
  d4:	4505                	li	a0,1
  d6:	31a000ef          	jal	3f0 <exit>

00000000000000da <main>:

int
main(int argc, char *argv[])
{
  da:	7179                	addi	sp,sp,-48
  dc:	f406                	sd	ra,40(sp)
  de:	f022                	sd	s0,32(sp)
  e0:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  e2:	4785                	li	a5,1
  e4:	04a7d463          	bge	a5,a0,12c <main+0x52>
  e8:	ec26                	sd	s1,24(sp)
  ea:	e84a                	sd	s2,16(sp)
  ec:	e44e                	sd	s3,8(sp)
  ee:	00858913          	addi	s2,a1,8
  f2:	ffe5099b          	addiw	s3,a0,-2
  f6:	02099793          	slli	a5,s3,0x20
  fa:	01d7d993          	srli	s3,a5,0x1d
  fe:	05c1                	addi	a1,a1,16
 100:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], O_RDONLY)) < 0){
 102:	4581                	li	a1,0
 104:	00093503          	ld	a0,0(s2)
 108:	328000ef          	jal	430 <open>
 10c:	84aa                	mv	s1,a0
 10e:	02054c63          	bltz	a0,146 <main+0x6c>
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 112:	00093583          	ld	a1,0(s2)
 116:	eebff0ef          	jal	0 <wc>
    close(fd);
 11a:	8526                	mv	a0,s1
 11c:	2fc000ef          	jal	418 <close>
  for(i = 1; i < argc; i++){
 120:	0921                	addi	s2,s2,8
 122:	ff3910e3          	bne	s2,s3,102 <main+0x28>
  }
  exit(0);
 126:	4501                	li	a0,0
 128:	2c8000ef          	jal	3f0 <exit>
 12c:	ec26                	sd	s1,24(sp)
 12e:	e84a                	sd	s2,16(sp)
 130:	e44e                	sd	s3,8(sp)
    wc(0, "");
 132:	00001597          	auipc	a1,0x1
 136:	8b658593          	addi	a1,a1,-1866 # 9e8 <malloc+0x104>
 13a:	4501                	li	a0,0
 13c:	ec5ff0ef          	jal	0 <wc>
    exit(0);
 140:	4501                	li	a0,0
 142:	2ae000ef          	jal	3f0 <exit>
      printf("wc: cannot open %s\n", argv[i]);
 146:	00093583          	ld	a1,0(s2)
 14a:	00001517          	auipc	a0,0x1
 14e:	8c650513          	addi	a0,a0,-1850 # a10 <malloc+0x12c>
 152:	6de000ef          	jal	830 <printf>
      exit(1);
 156:	4505                	li	a0,1
 158:	298000ef          	jal	3f0 <exit>

000000000000015c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 15c:	1141                	addi	sp,sp,-16
 15e:	e406                	sd	ra,8(sp)
 160:	e022                	sd	s0,0(sp)
 162:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 164:	f77ff0ef          	jal	da <main>
  exit(r);
 168:	288000ef          	jal	3f0 <exit>

000000000000016c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e422                	sd	s0,8(sp)
 170:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 172:	87aa                	mv	a5,a0
 174:	0585                	addi	a1,a1,1
 176:	0785                	addi	a5,a5,1
 178:	fff5c703          	lbu	a4,-1(a1)
 17c:	fee78fa3          	sb	a4,-1(a5)
 180:	fb75                	bnez	a4,174 <strcpy+0x8>
    ;
  return os;
}
 182:	6422                	ld	s0,8(sp)
 184:	0141                	addi	sp,sp,16
 186:	8082                	ret

0000000000000188 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 188:	1141                	addi	sp,sp,-16
 18a:	e422                	sd	s0,8(sp)
 18c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 18e:	00054783          	lbu	a5,0(a0)
 192:	cb91                	beqz	a5,1a6 <strcmp+0x1e>
 194:	0005c703          	lbu	a4,0(a1)
 198:	00f71763          	bne	a4,a5,1a6 <strcmp+0x1e>
    p++, q++;
 19c:	0505                	addi	a0,a0,1
 19e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1a0:	00054783          	lbu	a5,0(a0)
 1a4:	fbe5                	bnez	a5,194 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1a6:	0005c503          	lbu	a0,0(a1)
}
 1aa:	40a7853b          	subw	a0,a5,a0
 1ae:	6422                	ld	s0,8(sp)
 1b0:	0141                	addi	sp,sp,16
 1b2:	8082                	ret

00000000000001b4 <strlen>:

uint
strlen(const char *s)
{
 1b4:	1141                	addi	sp,sp,-16
 1b6:	e422                	sd	s0,8(sp)
 1b8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ba:	00054783          	lbu	a5,0(a0)
 1be:	cf91                	beqz	a5,1da <strlen+0x26>
 1c0:	0505                	addi	a0,a0,1
 1c2:	87aa                	mv	a5,a0
 1c4:	86be                	mv	a3,a5
 1c6:	0785                	addi	a5,a5,1
 1c8:	fff7c703          	lbu	a4,-1(a5)
 1cc:	ff65                	bnez	a4,1c4 <strlen+0x10>
 1ce:	40a6853b          	subw	a0,a3,a0
 1d2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1d4:	6422                	ld	s0,8(sp)
 1d6:	0141                	addi	sp,sp,16
 1d8:	8082                	ret
  for(n = 0; s[n]; n++)
 1da:	4501                	li	a0,0
 1dc:	bfe5                	j	1d4 <strlen+0x20>

00000000000001de <memset>:

void*
memset(void *dst, int c, uint n)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e422                	sd	s0,8(sp)
 1e2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1e4:	ca19                	beqz	a2,1fa <memset+0x1c>
 1e6:	87aa                	mv	a5,a0
 1e8:	1602                	slli	a2,a2,0x20
 1ea:	9201                	srli	a2,a2,0x20
 1ec:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1f0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1f4:	0785                	addi	a5,a5,1
 1f6:	fee79de3          	bne	a5,a4,1f0 <memset+0x12>
  }
  return dst;
}
 1fa:	6422                	ld	s0,8(sp)
 1fc:	0141                	addi	sp,sp,16
 1fe:	8082                	ret

0000000000000200 <strchr>:

char*
strchr(const char *s, char c)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  for(; *s; s++)
 206:	00054783          	lbu	a5,0(a0)
 20a:	cb99                	beqz	a5,220 <strchr+0x20>
    if(*s == c)
 20c:	00f58763          	beq	a1,a5,21a <strchr+0x1a>
  for(; *s; s++)
 210:	0505                	addi	a0,a0,1
 212:	00054783          	lbu	a5,0(a0)
 216:	fbfd                	bnez	a5,20c <strchr+0xc>
      return (char*)s;
  return 0;
 218:	4501                	li	a0,0
}
 21a:	6422                	ld	s0,8(sp)
 21c:	0141                	addi	sp,sp,16
 21e:	8082                	ret
  return 0;
 220:	4501                	li	a0,0
 222:	bfe5                	j	21a <strchr+0x1a>

0000000000000224 <gets>:

char*
gets(char *buf, int max)
{
 224:	711d                	addi	sp,sp,-96
 226:	ec86                	sd	ra,88(sp)
 228:	e8a2                	sd	s0,80(sp)
 22a:	e4a6                	sd	s1,72(sp)
 22c:	e0ca                	sd	s2,64(sp)
 22e:	fc4e                	sd	s3,56(sp)
 230:	f852                	sd	s4,48(sp)
 232:	f456                	sd	s5,40(sp)
 234:	f05a                	sd	s6,32(sp)
 236:	ec5e                	sd	s7,24(sp)
 238:	1080                	addi	s0,sp,96
 23a:	8baa                	mv	s7,a0
 23c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 23e:	892a                	mv	s2,a0
 240:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 242:	4aa9                	li	s5,10
 244:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 246:	89a6                	mv	s3,s1
 248:	2485                	addiw	s1,s1,1
 24a:	0344d663          	bge	s1,s4,276 <gets+0x52>
    cc = read(0, &c, 1);
 24e:	4605                	li	a2,1
 250:	faf40593          	addi	a1,s0,-81
 254:	4501                	li	a0,0
 256:	1b2000ef          	jal	408 <read>
    if(cc < 1)
 25a:	00a05e63          	blez	a0,276 <gets+0x52>
    buf[i++] = c;
 25e:	faf44783          	lbu	a5,-81(s0)
 262:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 266:	01578763          	beq	a5,s5,274 <gets+0x50>
 26a:	0905                	addi	s2,s2,1
 26c:	fd679de3          	bne	a5,s6,246 <gets+0x22>
    buf[i++] = c;
 270:	89a6                	mv	s3,s1
 272:	a011                	j	276 <gets+0x52>
 274:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 276:	99de                	add	s3,s3,s7
 278:	00098023          	sb	zero,0(s3)
  return buf;
}
 27c:	855e                	mv	a0,s7
 27e:	60e6                	ld	ra,88(sp)
 280:	6446                	ld	s0,80(sp)
 282:	64a6                	ld	s1,72(sp)
 284:	6906                	ld	s2,64(sp)
 286:	79e2                	ld	s3,56(sp)
 288:	7a42                	ld	s4,48(sp)
 28a:	7aa2                	ld	s5,40(sp)
 28c:	7b02                	ld	s6,32(sp)
 28e:	6be2                	ld	s7,24(sp)
 290:	6125                	addi	sp,sp,96
 292:	8082                	ret

0000000000000294 <stat>:

int
stat(const char *n, struct stat *st)
{
 294:	1101                	addi	sp,sp,-32
 296:	ec06                	sd	ra,24(sp)
 298:	e822                	sd	s0,16(sp)
 29a:	e04a                	sd	s2,0(sp)
 29c:	1000                	addi	s0,sp,32
 29e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a0:	4581                	li	a1,0
 2a2:	18e000ef          	jal	430 <open>
  if(fd < 0)
 2a6:	02054263          	bltz	a0,2ca <stat+0x36>
 2aa:	e426                	sd	s1,8(sp)
 2ac:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2ae:	85ca                	mv	a1,s2
 2b0:	198000ef          	jal	448 <fstat>
 2b4:	892a                	mv	s2,a0
  close(fd);
 2b6:	8526                	mv	a0,s1
 2b8:	160000ef          	jal	418 <close>
  return r;
 2bc:	64a2                	ld	s1,8(sp)
}
 2be:	854a                	mv	a0,s2
 2c0:	60e2                	ld	ra,24(sp)
 2c2:	6442                	ld	s0,16(sp)
 2c4:	6902                	ld	s2,0(sp)
 2c6:	6105                	addi	sp,sp,32
 2c8:	8082                	ret
    return -1;
 2ca:	597d                	li	s2,-1
 2cc:	bfcd                	j	2be <stat+0x2a>

00000000000002ce <atoi>:

int
atoi(const char *s)
{
 2ce:	1141                	addi	sp,sp,-16
 2d0:	e422                	sd	s0,8(sp)
 2d2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2d4:	00054683          	lbu	a3,0(a0)
 2d8:	fd06879b          	addiw	a5,a3,-48
 2dc:	0ff7f793          	zext.b	a5,a5
 2e0:	4625                	li	a2,9
 2e2:	02f66863          	bltu	a2,a5,312 <atoi+0x44>
 2e6:	872a                	mv	a4,a0
  n = 0;
 2e8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2ea:	0705                	addi	a4,a4,1
 2ec:	0025179b          	slliw	a5,a0,0x2
 2f0:	9fa9                	addw	a5,a5,a0
 2f2:	0017979b          	slliw	a5,a5,0x1
 2f6:	9fb5                	addw	a5,a5,a3
 2f8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2fc:	00074683          	lbu	a3,0(a4)
 300:	fd06879b          	addiw	a5,a3,-48
 304:	0ff7f793          	zext.b	a5,a5
 308:	fef671e3          	bgeu	a2,a5,2ea <atoi+0x1c>
  return n;
}
 30c:	6422                	ld	s0,8(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret
  n = 0;
 312:	4501                	li	a0,0
 314:	bfe5                	j	30c <atoi+0x3e>

0000000000000316 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 316:	1141                	addi	sp,sp,-16
 318:	e422                	sd	s0,8(sp)
 31a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 31c:	02b57463          	bgeu	a0,a1,344 <memmove+0x2e>
    while(n-- > 0)
 320:	00c05f63          	blez	a2,33e <memmove+0x28>
 324:	1602                	slli	a2,a2,0x20
 326:	9201                	srli	a2,a2,0x20
 328:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 32c:	872a                	mv	a4,a0
      *dst++ = *src++;
 32e:	0585                	addi	a1,a1,1
 330:	0705                	addi	a4,a4,1
 332:	fff5c683          	lbu	a3,-1(a1)
 336:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 33a:	fef71ae3          	bne	a4,a5,32e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 33e:	6422                	ld	s0,8(sp)
 340:	0141                	addi	sp,sp,16
 342:	8082                	ret
    dst += n;
 344:	00c50733          	add	a4,a0,a2
    src += n;
 348:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 34a:	fec05ae3          	blez	a2,33e <memmove+0x28>
 34e:	fff6079b          	addiw	a5,a2,-1
 352:	1782                	slli	a5,a5,0x20
 354:	9381                	srli	a5,a5,0x20
 356:	fff7c793          	not	a5,a5
 35a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 35c:	15fd                	addi	a1,a1,-1
 35e:	177d                	addi	a4,a4,-1
 360:	0005c683          	lbu	a3,0(a1)
 364:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 368:	fee79ae3          	bne	a5,a4,35c <memmove+0x46>
 36c:	bfc9                	j	33e <memmove+0x28>

000000000000036e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 36e:	1141                	addi	sp,sp,-16
 370:	e422                	sd	s0,8(sp)
 372:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 374:	ca05                	beqz	a2,3a4 <memcmp+0x36>
 376:	fff6069b          	addiw	a3,a2,-1
 37a:	1682                	slli	a3,a3,0x20
 37c:	9281                	srli	a3,a3,0x20
 37e:	0685                	addi	a3,a3,1
 380:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 382:	00054783          	lbu	a5,0(a0)
 386:	0005c703          	lbu	a4,0(a1)
 38a:	00e79863          	bne	a5,a4,39a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 38e:	0505                	addi	a0,a0,1
    p2++;
 390:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 392:	fed518e3          	bne	a0,a3,382 <memcmp+0x14>
  }
  return 0;
 396:	4501                	li	a0,0
 398:	a019                	j	39e <memcmp+0x30>
      return *p1 - *p2;
 39a:	40e7853b          	subw	a0,a5,a4
}
 39e:	6422                	ld	s0,8(sp)
 3a0:	0141                	addi	sp,sp,16
 3a2:	8082                	ret
  return 0;
 3a4:	4501                	li	a0,0
 3a6:	bfe5                	j	39e <memcmp+0x30>

00000000000003a8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3a8:	1141                	addi	sp,sp,-16
 3aa:	e406                	sd	ra,8(sp)
 3ac:	e022                	sd	s0,0(sp)
 3ae:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3b0:	f67ff0ef          	jal	316 <memmove>
}
 3b4:	60a2                	ld	ra,8(sp)
 3b6:	6402                	ld	s0,0(sp)
 3b8:	0141                	addi	sp,sp,16
 3ba:	8082                	ret

00000000000003bc <sbrk>:

char *
sbrk(int n) {
 3bc:	1141                	addi	sp,sp,-16
 3be:	e406                	sd	ra,8(sp)
 3c0:	e022                	sd	s0,0(sp)
 3c2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3c4:	4585                	li	a1,1
 3c6:	0b2000ef          	jal	478 <sys_sbrk>
}
 3ca:	60a2                	ld	ra,8(sp)
 3cc:	6402                	ld	s0,0(sp)
 3ce:	0141                	addi	sp,sp,16
 3d0:	8082                	ret

00000000000003d2 <sbrklazy>:

char *
sbrklazy(int n) {
 3d2:	1141                	addi	sp,sp,-16
 3d4:	e406                	sd	ra,8(sp)
 3d6:	e022                	sd	s0,0(sp)
 3d8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3da:	4589                	li	a1,2
 3dc:	09c000ef          	jal	478 <sys_sbrk>
}
 3e0:	60a2                	ld	ra,8(sp)
 3e2:	6402                	ld	s0,0(sp)
 3e4:	0141                	addi	sp,sp,16
 3e6:	8082                	ret

00000000000003e8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3e8:	4885                	li	a7,1
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3f0:	4889                	li	a7,2
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3f8:	488d                	li	a7,3
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 400:	4891                	li	a7,4
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <read>:
.global read
read:
 li a7, SYS_read
 408:	4895                	li	a7,5
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <write>:
.global write
write:
 li a7, SYS_write
 410:	48c1                	li	a7,16
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <close>:
.global close
close:
 li a7, SYS_close
 418:	48d5                	li	a7,21
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <kill>:
.global kill
kill:
 li a7, SYS_kill
 420:	4899                	li	a7,6
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <exec>:
.global exec
exec:
 li a7, SYS_exec
 428:	489d                	li	a7,7
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <open>:
.global open
open:
 li a7, SYS_open
 430:	48bd                	li	a7,15
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 438:	48c5                	li	a7,17
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 440:	48c9                	li	a7,18
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 448:	48a1                	li	a7,8
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <link>:
.global link
link:
 li a7, SYS_link
 450:	48cd                	li	a7,19
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 458:	48d1                	li	a7,20
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 460:	48a5                	li	a7,9
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <dup>:
.global dup
dup:
 li a7, SYS_dup
 468:	48a9                	li	a7,10
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 470:	48ad                	li	a7,11
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 478:	48b1                	li	a7,12
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <pause>:
.global pause
pause:
 li a7, SYS_pause
 480:	48b5                	li	a7,13
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 488:	48b9                	li	a7,14
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <getprocsinfo>:
.global getprocsinfo
getprocsinfo:
 li a7, SYS_getprocsinfo
 490:	48d9                	li	a7,22
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 498:	48dd                	li	a7,23
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <sleep2>:
.global sleep2
sleep2:
 li a7, SYS_sleep2
 4a0:	48e1                	li	a7,24
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4a8:	1101                	addi	sp,sp,-32
 4aa:	ec06                	sd	ra,24(sp)
 4ac:	e822                	sd	s0,16(sp)
 4ae:	1000                	addi	s0,sp,32
 4b0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4b4:	4605                	li	a2,1
 4b6:	fef40593          	addi	a1,s0,-17
 4ba:	f57ff0ef          	jal	410 <write>
}
 4be:	60e2                	ld	ra,24(sp)
 4c0:	6442                	ld	s0,16(sp)
 4c2:	6105                	addi	sp,sp,32
 4c4:	8082                	ret

00000000000004c6 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4c6:	715d                	addi	sp,sp,-80
 4c8:	e486                	sd	ra,72(sp)
 4ca:	e0a2                	sd	s0,64(sp)
 4cc:	f84a                	sd	s2,48(sp)
 4ce:	0880                	addi	s0,sp,80
 4d0:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4d2:	c299                	beqz	a3,4d8 <printint+0x12>
 4d4:	0805c363          	bltz	a1,55a <printint+0x94>
  neg = 0;
 4d8:	4881                	li	a7,0
 4da:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4de:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4e0:	00000517          	auipc	a0,0x0
 4e4:	55050513          	addi	a0,a0,1360 # a30 <digits>
 4e8:	883e                	mv	a6,a5
 4ea:	2785                	addiw	a5,a5,1
 4ec:	02c5f733          	remu	a4,a1,a2
 4f0:	972a                	add	a4,a4,a0
 4f2:	00074703          	lbu	a4,0(a4)
 4f6:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4fa:	872e                	mv	a4,a1
 4fc:	02c5d5b3          	divu	a1,a1,a2
 500:	0685                	addi	a3,a3,1
 502:	fec773e3          	bgeu	a4,a2,4e8 <printint+0x22>
  if(neg)
 506:	00088b63          	beqz	a7,51c <printint+0x56>
    buf[i++] = '-';
 50a:	fd078793          	addi	a5,a5,-48
 50e:	97a2                	add	a5,a5,s0
 510:	02d00713          	li	a4,45
 514:	fee78423          	sb	a4,-24(a5)
 518:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 51c:	02f05a63          	blez	a5,550 <printint+0x8a>
 520:	fc26                	sd	s1,56(sp)
 522:	f44e                	sd	s3,40(sp)
 524:	fb840713          	addi	a4,s0,-72
 528:	00f704b3          	add	s1,a4,a5
 52c:	fff70993          	addi	s3,a4,-1
 530:	99be                	add	s3,s3,a5
 532:	37fd                	addiw	a5,a5,-1
 534:	1782                	slli	a5,a5,0x20
 536:	9381                	srli	a5,a5,0x20
 538:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 53c:	fff4c583          	lbu	a1,-1(s1)
 540:	854a                	mv	a0,s2
 542:	f67ff0ef          	jal	4a8 <putc>
  while(--i >= 0)
 546:	14fd                	addi	s1,s1,-1
 548:	ff349ae3          	bne	s1,s3,53c <printint+0x76>
 54c:	74e2                	ld	s1,56(sp)
 54e:	79a2                	ld	s3,40(sp)
}
 550:	60a6                	ld	ra,72(sp)
 552:	6406                	ld	s0,64(sp)
 554:	7942                	ld	s2,48(sp)
 556:	6161                	addi	sp,sp,80
 558:	8082                	ret
    x = -xx;
 55a:	40b005b3          	neg	a1,a1
    neg = 1;
 55e:	4885                	li	a7,1
    x = -xx;
 560:	bfad                	j	4da <printint+0x14>

0000000000000562 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 562:	711d                	addi	sp,sp,-96
 564:	ec86                	sd	ra,88(sp)
 566:	e8a2                	sd	s0,80(sp)
 568:	e0ca                	sd	s2,64(sp)
 56a:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 56c:	0005c903          	lbu	s2,0(a1)
 570:	28090663          	beqz	s2,7fc <vprintf+0x29a>
 574:	e4a6                	sd	s1,72(sp)
 576:	fc4e                	sd	s3,56(sp)
 578:	f852                	sd	s4,48(sp)
 57a:	f456                	sd	s5,40(sp)
 57c:	f05a                	sd	s6,32(sp)
 57e:	ec5e                	sd	s7,24(sp)
 580:	e862                	sd	s8,16(sp)
 582:	e466                	sd	s9,8(sp)
 584:	8b2a                	mv	s6,a0
 586:	8a2e                	mv	s4,a1
 588:	8bb2                	mv	s7,a2
  state = 0;
 58a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 58c:	4481                	li	s1,0
 58e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 590:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 594:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 598:	06c00c93          	li	s9,108
 59c:	a005                	j	5bc <vprintf+0x5a>
        putc(fd, c0);
 59e:	85ca                	mv	a1,s2
 5a0:	855a                	mv	a0,s6
 5a2:	f07ff0ef          	jal	4a8 <putc>
 5a6:	a019                	j	5ac <vprintf+0x4a>
    } else if(state == '%'){
 5a8:	03598263          	beq	s3,s5,5cc <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5ac:	2485                	addiw	s1,s1,1
 5ae:	8726                	mv	a4,s1
 5b0:	009a07b3          	add	a5,s4,s1
 5b4:	0007c903          	lbu	s2,0(a5)
 5b8:	22090a63          	beqz	s2,7ec <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 5bc:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5c0:	fe0994e3          	bnez	s3,5a8 <vprintf+0x46>
      if(c0 == '%'){
 5c4:	fd579de3          	bne	a5,s5,59e <vprintf+0x3c>
        state = '%';
 5c8:	89be                	mv	s3,a5
 5ca:	b7cd                	j	5ac <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5cc:	00ea06b3          	add	a3,s4,a4
 5d0:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5d4:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5d6:	c681                	beqz	a3,5de <vprintf+0x7c>
 5d8:	9752                	add	a4,a4,s4
 5da:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5de:	05878363          	beq	a5,s8,624 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5e2:	05978d63          	beq	a5,s9,63c <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5e6:	07500713          	li	a4,117
 5ea:	0ee78763          	beq	a5,a4,6d8 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5ee:	07800713          	li	a4,120
 5f2:	12e78963          	beq	a5,a4,724 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5f6:	07000713          	li	a4,112
 5fa:	14e78e63          	beq	a5,a4,756 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5fe:	06300713          	li	a4,99
 602:	18e78e63          	beq	a5,a4,79e <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 606:	07300713          	li	a4,115
 60a:	1ae78463          	beq	a5,a4,7b2 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 60e:	02500713          	li	a4,37
 612:	04e79563          	bne	a5,a4,65c <vprintf+0xfa>
        putc(fd, '%');
 616:	02500593          	li	a1,37
 61a:	855a                	mv	a0,s6
 61c:	e8dff0ef          	jal	4a8 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 620:	4981                	li	s3,0
 622:	b769                	j	5ac <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 624:	008b8913          	addi	s2,s7,8
 628:	4685                	li	a3,1
 62a:	4629                	li	a2,10
 62c:	000ba583          	lw	a1,0(s7)
 630:	855a                	mv	a0,s6
 632:	e95ff0ef          	jal	4c6 <printint>
 636:	8bca                	mv	s7,s2
      state = 0;
 638:	4981                	li	s3,0
 63a:	bf8d                	j	5ac <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 63c:	06400793          	li	a5,100
 640:	02f68963          	beq	a3,a5,672 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 644:	06c00793          	li	a5,108
 648:	04f68263          	beq	a3,a5,68c <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 64c:	07500793          	li	a5,117
 650:	0af68063          	beq	a3,a5,6f0 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 654:	07800793          	li	a5,120
 658:	0ef68263          	beq	a3,a5,73c <vprintf+0x1da>
        putc(fd, '%');
 65c:	02500593          	li	a1,37
 660:	855a                	mv	a0,s6
 662:	e47ff0ef          	jal	4a8 <putc>
        putc(fd, c0);
 666:	85ca                	mv	a1,s2
 668:	855a                	mv	a0,s6
 66a:	e3fff0ef          	jal	4a8 <putc>
      state = 0;
 66e:	4981                	li	s3,0
 670:	bf35                	j	5ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 672:	008b8913          	addi	s2,s7,8
 676:	4685                	li	a3,1
 678:	4629                	li	a2,10
 67a:	000bb583          	ld	a1,0(s7)
 67e:	855a                	mv	a0,s6
 680:	e47ff0ef          	jal	4c6 <printint>
        i += 1;
 684:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 686:	8bca                	mv	s7,s2
      state = 0;
 688:	4981                	li	s3,0
        i += 1;
 68a:	b70d                	j	5ac <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 68c:	06400793          	li	a5,100
 690:	02f60763          	beq	a2,a5,6be <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 694:	07500793          	li	a5,117
 698:	06f60963          	beq	a2,a5,70a <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 69c:	07800793          	li	a5,120
 6a0:	faf61ee3          	bne	a2,a5,65c <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a4:	008b8913          	addi	s2,s7,8
 6a8:	4681                	li	a3,0
 6aa:	4641                	li	a2,16
 6ac:	000bb583          	ld	a1,0(s7)
 6b0:	855a                	mv	a0,s6
 6b2:	e15ff0ef          	jal	4c6 <printint>
        i += 2;
 6b6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b8:	8bca                	mv	s7,s2
      state = 0;
 6ba:	4981                	li	s3,0
        i += 2;
 6bc:	bdc5                	j	5ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6be:	008b8913          	addi	s2,s7,8
 6c2:	4685                	li	a3,1
 6c4:	4629                	li	a2,10
 6c6:	000bb583          	ld	a1,0(s7)
 6ca:	855a                	mv	a0,s6
 6cc:	dfbff0ef          	jal	4c6 <printint>
        i += 2;
 6d0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d2:	8bca                	mv	s7,s2
      state = 0;
 6d4:	4981                	li	s3,0
        i += 2;
 6d6:	bdd9                	j	5ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6d8:	008b8913          	addi	s2,s7,8
 6dc:	4681                	li	a3,0
 6de:	4629                	li	a2,10
 6e0:	000be583          	lwu	a1,0(s7)
 6e4:	855a                	mv	a0,s6
 6e6:	de1ff0ef          	jal	4c6 <printint>
 6ea:	8bca                	mv	s7,s2
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	bd7d                	j	5ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f0:	008b8913          	addi	s2,s7,8
 6f4:	4681                	li	a3,0
 6f6:	4629                	li	a2,10
 6f8:	000bb583          	ld	a1,0(s7)
 6fc:	855a                	mv	a0,s6
 6fe:	dc9ff0ef          	jal	4c6 <printint>
        i += 1;
 702:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 704:	8bca                	mv	s7,s2
      state = 0;
 706:	4981                	li	s3,0
        i += 1;
 708:	b555                	j	5ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 70a:	008b8913          	addi	s2,s7,8
 70e:	4681                	li	a3,0
 710:	4629                	li	a2,10
 712:	000bb583          	ld	a1,0(s7)
 716:	855a                	mv	a0,s6
 718:	dafff0ef          	jal	4c6 <printint>
        i += 2;
 71c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 71e:	8bca                	mv	s7,s2
      state = 0;
 720:	4981                	li	s3,0
        i += 2;
 722:	b569                	j	5ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 724:	008b8913          	addi	s2,s7,8
 728:	4681                	li	a3,0
 72a:	4641                	li	a2,16
 72c:	000be583          	lwu	a1,0(s7)
 730:	855a                	mv	a0,s6
 732:	d95ff0ef          	jal	4c6 <printint>
 736:	8bca                	mv	s7,s2
      state = 0;
 738:	4981                	li	s3,0
 73a:	bd8d                	j	5ac <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 73c:	008b8913          	addi	s2,s7,8
 740:	4681                	li	a3,0
 742:	4641                	li	a2,16
 744:	000bb583          	ld	a1,0(s7)
 748:	855a                	mv	a0,s6
 74a:	d7dff0ef          	jal	4c6 <printint>
        i += 1;
 74e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 750:	8bca                	mv	s7,s2
      state = 0;
 752:	4981                	li	s3,0
        i += 1;
 754:	bda1                	j	5ac <vprintf+0x4a>
 756:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 758:	008b8d13          	addi	s10,s7,8
 75c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 760:	03000593          	li	a1,48
 764:	855a                	mv	a0,s6
 766:	d43ff0ef          	jal	4a8 <putc>
  putc(fd, 'x');
 76a:	07800593          	li	a1,120
 76e:	855a                	mv	a0,s6
 770:	d39ff0ef          	jal	4a8 <putc>
 774:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 776:	00000b97          	auipc	s7,0x0
 77a:	2bab8b93          	addi	s7,s7,698 # a30 <digits>
 77e:	03c9d793          	srli	a5,s3,0x3c
 782:	97de                	add	a5,a5,s7
 784:	0007c583          	lbu	a1,0(a5)
 788:	855a                	mv	a0,s6
 78a:	d1fff0ef          	jal	4a8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 78e:	0992                	slli	s3,s3,0x4
 790:	397d                	addiw	s2,s2,-1
 792:	fe0916e3          	bnez	s2,77e <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 796:	8bea                	mv	s7,s10
      state = 0;
 798:	4981                	li	s3,0
 79a:	6d02                	ld	s10,0(sp)
 79c:	bd01                	j	5ac <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 79e:	008b8913          	addi	s2,s7,8
 7a2:	000bc583          	lbu	a1,0(s7)
 7a6:	855a                	mv	a0,s6
 7a8:	d01ff0ef          	jal	4a8 <putc>
 7ac:	8bca                	mv	s7,s2
      state = 0;
 7ae:	4981                	li	s3,0
 7b0:	bbf5                	j	5ac <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7b2:	008b8993          	addi	s3,s7,8
 7b6:	000bb903          	ld	s2,0(s7)
 7ba:	00090f63          	beqz	s2,7d8 <vprintf+0x276>
        for(; *s; s++)
 7be:	00094583          	lbu	a1,0(s2)
 7c2:	c195                	beqz	a1,7e6 <vprintf+0x284>
          putc(fd, *s);
 7c4:	855a                	mv	a0,s6
 7c6:	ce3ff0ef          	jal	4a8 <putc>
        for(; *s; s++)
 7ca:	0905                	addi	s2,s2,1
 7cc:	00094583          	lbu	a1,0(s2)
 7d0:	f9f5                	bnez	a1,7c4 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7d2:	8bce                	mv	s7,s3
      state = 0;
 7d4:	4981                	li	s3,0
 7d6:	bbd9                	j	5ac <vprintf+0x4a>
          s = "(null)";
 7d8:	00000917          	auipc	s2,0x0
 7dc:	25090913          	addi	s2,s2,592 # a28 <malloc+0x144>
        for(; *s; s++)
 7e0:	02800593          	li	a1,40
 7e4:	b7c5                	j	7c4 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7e6:	8bce                	mv	s7,s3
      state = 0;
 7e8:	4981                	li	s3,0
 7ea:	b3c9                	j	5ac <vprintf+0x4a>
 7ec:	64a6                	ld	s1,72(sp)
 7ee:	79e2                	ld	s3,56(sp)
 7f0:	7a42                	ld	s4,48(sp)
 7f2:	7aa2                	ld	s5,40(sp)
 7f4:	7b02                	ld	s6,32(sp)
 7f6:	6be2                	ld	s7,24(sp)
 7f8:	6c42                	ld	s8,16(sp)
 7fa:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7fc:	60e6                	ld	ra,88(sp)
 7fe:	6446                	ld	s0,80(sp)
 800:	6906                	ld	s2,64(sp)
 802:	6125                	addi	sp,sp,96
 804:	8082                	ret

0000000000000806 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 806:	715d                	addi	sp,sp,-80
 808:	ec06                	sd	ra,24(sp)
 80a:	e822                	sd	s0,16(sp)
 80c:	1000                	addi	s0,sp,32
 80e:	e010                	sd	a2,0(s0)
 810:	e414                	sd	a3,8(s0)
 812:	e818                	sd	a4,16(s0)
 814:	ec1c                	sd	a5,24(s0)
 816:	03043023          	sd	a6,32(s0)
 81a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 81e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 822:	8622                	mv	a2,s0
 824:	d3fff0ef          	jal	562 <vprintf>
}
 828:	60e2                	ld	ra,24(sp)
 82a:	6442                	ld	s0,16(sp)
 82c:	6161                	addi	sp,sp,80
 82e:	8082                	ret

0000000000000830 <printf>:

void
printf(const char *fmt, ...)
{
 830:	711d                	addi	sp,sp,-96
 832:	ec06                	sd	ra,24(sp)
 834:	e822                	sd	s0,16(sp)
 836:	1000                	addi	s0,sp,32
 838:	e40c                	sd	a1,8(s0)
 83a:	e810                	sd	a2,16(s0)
 83c:	ec14                	sd	a3,24(s0)
 83e:	f018                	sd	a4,32(s0)
 840:	f41c                	sd	a5,40(s0)
 842:	03043823          	sd	a6,48(s0)
 846:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 84a:	00840613          	addi	a2,s0,8
 84e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 852:	85aa                	mv	a1,a0
 854:	4505                	li	a0,1
 856:	d0dff0ef          	jal	562 <vprintf>
}
 85a:	60e2                	ld	ra,24(sp)
 85c:	6442                	ld	s0,16(sp)
 85e:	6125                	addi	sp,sp,96
 860:	8082                	ret

0000000000000862 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 862:	1141                	addi	sp,sp,-16
 864:	e422                	sd	s0,8(sp)
 866:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 868:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86c:	00000797          	auipc	a5,0x0
 870:	7947b783          	ld	a5,1940(a5) # 1000 <freep>
 874:	a02d                	j	89e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 876:	4618                	lw	a4,8(a2)
 878:	9f2d                	addw	a4,a4,a1
 87a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 87e:	6398                	ld	a4,0(a5)
 880:	6310                	ld	a2,0(a4)
 882:	a83d                	j	8c0 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 884:	ff852703          	lw	a4,-8(a0)
 888:	9f31                	addw	a4,a4,a2
 88a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 88c:	ff053683          	ld	a3,-16(a0)
 890:	a091                	j	8d4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 892:	6398                	ld	a4,0(a5)
 894:	00e7e463          	bltu	a5,a4,89c <free+0x3a>
 898:	00e6ea63          	bltu	a3,a4,8ac <free+0x4a>
{
 89c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 89e:	fed7fae3          	bgeu	a5,a3,892 <free+0x30>
 8a2:	6398                	ld	a4,0(a5)
 8a4:	00e6e463          	bltu	a3,a4,8ac <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a8:	fee7eae3          	bltu	a5,a4,89c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8ac:	ff852583          	lw	a1,-8(a0)
 8b0:	6390                	ld	a2,0(a5)
 8b2:	02059813          	slli	a6,a1,0x20
 8b6:	01c85713          	srli	a4,a6,0x1c
 8ba:	9736                	add	a4,a4,a3
 8bc:	fae60de3          	beq	a2,a4,876 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8c0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8c4:	4790                	lw	a2,8(a5)
 8c6:	02061593          	slli	a1,a2,0x20
 8ca:	01c5d713          	srli	a4,a1,0x1c
 8ce:	973e                	add	a4,a4,a5
 8d0:	fae68ae3          	beq	a3,a4,884 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8d4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8d6:	00000717          	auipc	a4,0x0
 8da:	72f73523          	sd	a5,1834(a4) # 1000 <freep>
}
 8de:	6422                	ld	s0,8(sp)
 8e0:	0141                	addi	sp,sp,16
 8e2:	8082                	ret

00000000000008e4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8e4:	7139                	addi	sp,sp,-64
 8e6:	fc06                	sd	ra,56(sp)
 8e8:	f822                	sd	s0,48(sp)
 8ea:	f426                	sd	s1,40(sp)
 8ec:	ec4e                	sd	s3,24(sp)
 8ee:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f0:	02051493          	slli	s1,a0,0x20
 8f4:	9081                	srli	s1,s1,0x20
 8f6:	04bd                	addi	s1,s1,15
 8f8:	8091                	srli	s1,s1,0x4
 8fa:	0014899b          	addiw	s3,s1,1
 8fe:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 900:	00000517          	auipc	a0,0x0
 904:	70053503          	ld	a0,1792(a0) # 1000 <freep>
 908:	c915                	beqz	a0,93c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 90a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 90c:	4798                	lw	a4,8(a5)
 90e:	08977a63          	bgeu	a4,s1,9a2 <malloc+0xbe>
 912:	f04a                	sd	s2,32(sp)
 914:	e852                	sd	s4,16(sp)
 916:	e456                	sd	s5,8(sp)
 918:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 91a:	8a4e                	mv	s4,s3
 91c:	0009871b          	sext.w	a4,s3
 920:	6685                	lui	a3,0x1
 922:	00d77363          	bgeu	a4,a3,928 <malloc+0x44>
 926:	6a05                	lui	s4,0x1
 928:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 92c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 930:	00000917          	auipc	s2,0x0
 934:	6d090913          	addi	s2,s2,1744 # 1000 <freep>
  if(p == SBRK_ERROR)
 938:	5afd                	li	s5,-1
 93a:	a081                	j	97a <malloc+0x96>
 93c:	f04a                	sd	s2,32(sp)
 93e:	e852                	sd	s4,16(sp)
 940:	e456                	sd	s5,8(sp)
 942:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 944:	00001797          	auipc	a5,0x1
 948:	8cc78793          	addi	a5,a5,-1844 # 1210 <base>
 94c:	00000717          	auipc	a4,0x0
 950:	6af73a23          	sd	a5,1716(a4) # 1000 <freep>
 954:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 956:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 95a:	b7c1                	j	91a <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 95c:	6398                	ld	a4,0(a5)
 95e:	e118                	sd	a4,0(a0)
 960:	a8a9                	j	9ba <malloc+0xd6>
  hp->s.size = nu;
 962:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 966:	0541                	addi	a0,a0,16
 968:	efbff0ef          	jal	862 <free>
  return freep;
 96c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 970:	c12d                	beqz	a0,9d2 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 972:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 974:	4798                	lw	a4,8(a5)
 976:	02977263          	bgeu	a4,s1,99a <malloc+0xb6>
    if(p == freep)
 97a:	00093703          	ld	a4,0(s2)
 97e:	853e                	mv	a0,a5
 980:	fef719e3          	bne	a4,a5,972 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 984:	8552                	mv	a0,s4
 986:	a37ff0ef          	jal	3bc <sbrk>
  if(p == SBRK_ERROR)
 98a:	fd551ce3          	bne	a0,s5,962 <malloc+0x7e>
        return 0;
 98e:	4501                	li	a0,0
 990:	7902                	ld	s2,32(sp)
 992:	6a42                	ld	s4,16(sp)
 994:	6aa2                	ld	s5,8(sp)
 996:	6b02                	ld	s6,0(sp)
 998:	a03d                	j	9c6 <malloc+0xe2>
 99a:	7902                	ld	s2,32(sp)
 99c:	6a42                	ld	s4,16(sp)
 99e:	6aa2                	ld	s5,8(sp)
 9a0:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9a2:	fae48de3          	beq	s1,a4,95c <malloc+0x78>
        p->s.size -= nunits;
 9a6:	4137073b          	subw	a4,a4,s3
 9aa:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9ac:	02071693          	slli	a3,a4,0x20
 9b0:	01c6d713          	srli	a4,a3,0x1c
 9b4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9b6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9ba:	00000717          	auipc	a4,0x0
 9be:	64a73323          	sd	a0,1606(a4) # 1000 <freep>
      return (void*)(p + 1);
 9c2:	01078513          	addi	a0,a5,16
  }
}
 9c6:	70e2                	ld	ra,56(sp)
 9c8:	7442                	ld	s0,48(sp)
 9ca:	74a2                	ld	s1,40(sp)
 9cc:	69e2                	ld	s3,24(sp)
 9ce:	6121                	addi	sp,sp,64
 9d0:	8082                	ret
 9d2:	7902                	ld	s2,32(sp)
 9d4:	6a42                	ld	s4,16(sp)
 9d6:	6aa2                	ld	s5,8(sp)
 9d8:	6b02                	ld	s6,0(sp)
 9da:	b7f5                	j	9c6 <malloc+0xe2>
