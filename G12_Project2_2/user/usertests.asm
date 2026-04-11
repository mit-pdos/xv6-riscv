
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	711d                	addi	sp,sp,-96
       2:	ec86                	sd	ra,88(sp)
       4:	e8a2                	sd	s0,80(sp)
       6:	e4a6                	sd	s1,72(sp)
       8:	e0ca                	sd	s2,64(sp)
       a:	fc4e                	sd	s3,56(sp)
       c:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
       e:	00008797          	auipc	a5,0x8
      12:	8c278793          	addi	a5,a5,-1854 # 78d0 <malloc+0x2680>
      16:	638c                	ld	a1,0(a5)
      18:	6790                	ld	a2,8(a5)
      1a:	6b94                	ld	a3,16(a5)
      1c:	6f98                	ld	a4,24(a5)
      1e:	739c                	ld	a5,32(a5)
      20:	fab43423          	sd	a1,-88(s0)
      24:	fac43823          	sd	a2,-80(s0)
      28:	fad43c23          	sd	a3,-72(s0)
      2c:	fce43023          	sd	a4,-64(s0)
      30:	fcf43423          	sd	a5,-56(s0)
                     0xffffffffffffffff };

  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
      34:	fa840493          	addi	s1,s0,-88
      38:	fd040993          	addi	s3,s0,-48
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      3c:	0004b903          	ld	s2,0(s1)
      40:	20100593          	li	a1,513
      44:	854a                	mv	a0,s2
      46:	56f040ef          	jal	4db4 <open>
    if(fd >= 0){
      4a:	00055c63          	bgez	a0,62 <copyinstr1+0x62>
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
      4e:	04a1                	addi	s1,s1,8
      50:	ff3496e3          	bne	s1,s3,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", (void*)addr, fd);
      exit(1);
    }
  }
}
      54:	60e6                	ld	ra,88(sp)
      56:	6446                	ld	s0,80(sp)
      58:	64a6                	ld	s1,72(sp)
      5a:	6906                	ld	s2,64(sp)
      5c:	79e2                	ld	s3,56(sp)
      5e:	6125                	addi	sp,sp,96
      60:	8082                	ret
      printf("open(%p) returned %d, not -1\n", (void*)addr, fd);
      62:	862a                	mv	a2,a0
      64:	85ca                	mv	a1,s2
      66:	00005517          	auipc	a0,0x5
      6a:	2ea50513          	addi	a0,a0,746 # 5350 <malloc+0x100>
      6e:	12e050ef          	jal	519c <printf>
      exit(1);
      72:	4505                	li	a0,1
      74:	501040ef          	jal	4d74 <exit>

0000000000000078 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      78:	0000a797          	auipc	a5,0xa
      7c:	53078793          	addi	a5,a5,1328 # a5a8 <uninit>
      80:	0000d697          	auipc	a3,0xd
      84:	c3868693          	addi	a3,a3,-968 # ccb8 <buf>
    if(uninit[i] != '\0'){
      88:	0007c703          	lbu	a4,0(a5)
      8c:	e709                	bnez	a4,96 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      8e:	0785                	addi	a5,a5,1
      90:	fed79ce3          	bne	a5,a3,88 <bsstest+0x10>
      94:	8082                	ret
{
      96:	1141                	addi	sp,sp,-16
      98:	e406                	sd	ra,8(sp)
      9a:	e022                	sd	s0,0(sp)
      9c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      9e:	85aa                	mv	a1,a0
      a0:	00005517          	auipc	a0,0x5
      a4:	2d050513          	addi	a0,a0,720 # 5370 <malloc+0x120>
      a8:	0f4050ef          	jal	519c <printf>
      exit(1);
      ac:	4505                	li	a0,1
      ae:	4c7040ef          	jal	4d74 <exit>

00000000000000b2 <opentest>:
{
      b2:	1101                	addi	sp,sp,-32
      b4:	ec06                	sd	ra,24(sp)
      b6:	e822                	sd	s0,16(sp)
      b8:	e426                	sd	s1,8(sp)
      ba:	1000                	addi	s0,sp,32
      bc:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      be:	4581                	li	a1,0
      c0:	00005517          	auipc	a0,0x5
      c4:	2c850513          	addi	a0,a0,712 # 5388 <malloc+0x138>
      c8:	4ed040ef          	jal	4db4 <open>
  if(fd < 0){
      cc:	02054263          	bltz	a0,f0 <opentest+0x3e>
  close(fd);
      d0:	4cd040ef          	jal	4d9c <close>
  fd = open("doesnotexist", 0);
      d4:	4581                	li	a1,0
      d6:	00005517          	auipc	a0,0x5
      da:	2d250513          	addi	a0,a0,722 # 53a8 <malloc+0x158>
      de:	4d7040ef          	jal	4db4 <open>
  if(fd >= 0){
      e2:	02055163          	bgez	a0,104 <opentest+0x52>
}
      e6:	60e2                	ld	ra,24(sp)
      e8:	6442                	ld	s0,16(sp)
      ea:	64a2                	ld	s1,8(sp)
      ec:	6105                	addi	sp,sp,32
      ee:	8082                	ret
    printf("%s: open echo failed!\n", s);
      f0:	85a6                	mv	a1,s1
      f2:	00005517          	auipc	a0,0x5
      f6:	29e50513          	addi	a0,a0,670 # 5390 <malloc+0x140>
      fa:	0a2050ef          	jal	519c <printf>
    exit(1);
      fe:	4505                	li	a0,1
     100:	475040ef          	jal	4d74 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     104:	85a6                	mv	a1,s1
     106:	00005517          	auipc	a0,0x5
     10a:	2b250513          	addi	a0,a0,690 # 53b8 <malloc+0x168>
     10e:	08e050ef          	jal	519c <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	461040ef          	jal	4d74 <exit>

0000000000000118 <truncate2>:
{
     118:	7179                	addi	sp,sp,-48
     11a:	f406                	sd	ra,40(sp)
     11c:	f022                	sd	s0,32(sp)
     11e:	ec26                	sd	s1,24(sp)
     120:	e84a                	sd	s2,16(sp)
     122:	e44e                	sd	s3,8(sp)
     124:	1800                	addi	s0,sp,48
     126:	89aa                	mv	s3,a0
  unlink("truncfile");
     128:	00005517          	auipc	a0,0x5
     12c:	2b850513          	addi	a0,a0,696 # 53e0 <malloc+0x190>
     130:	495040ef          	jal	4dc4 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     134:	60100593          	li	a1,1537
     138:	00005517          	auipc	a0,0x5
     13c:	2a850513          	addi	a0,a0,680 # 53e0 <malloc+0x190>
     140:	475040ef          	jal	4db4 <open>
     144:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     146:	4611                	li	a2,4
     148:	00005597          	auipc	a1,0x5
     14c:	2a858593          	addi	a1,a1,680 # 53f0 <malloc+0x1a0>
     150:	445040ef          	jal	4d94 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     154:	40100593          	li	a1,1025
     158:	00005517          	auipc	a0,0x5
     15c:	28850513          	addi	a0,a0,648 # 53e0 <malloc+0x190>
     160:	455040ef          	jal	4db4 <open>
     164:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     166:	4605                	li	a2,1
     168:	00005597          	auipc	a1,0x5
     16c:	29058593          	addi	a1,a1,656 # 53f8 <malloc+0x1a8>
     170:	8526                	mv	a0,s1
     172:	423040ef          	jal	4d94 <write>
  if(n != -1){
     176:	57fd                	li	a5,-1
     178:	02f51563          	bne	a0,a5,1a2 <truncate2+0x8a>
  unlink("truncfile");
     17c:	00005517          	auipc	a0,0x5
     180:	26450513          	addi	a0,a0,612 # 53e0 <malloc+0x190>
     184:	441040ef          	jal	4dc4 <unlink>
  close(fd1);
     188:	8526                	mv	a0,s1
     18a:	413040ef          	jal	4d9c <close>
  close(fd2);
     18e:	854a                	mv	a0,s2
     190:	40d040ef          	jal	4d9c <close>
}
     194:	70a2                	ld	ra,40(sp)
     196:	7402                	ld	s0,32(sp)
     198:	64e2                	ld	s1,24(sp)
     19a:	6942                	ld	s2,16(sp)
     19c:	69a2                	ld	s3,8(sp)
     19e:	6145                	addi	sp,sp,48
     1a0:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1a2:	862a                	mv	a2,a0
     1a4:	85ce                	mv	a1,s3
     1a6:	00005517          	auipc	a0,0x5
     1aa:	25a50513          	addi	a0,a0,602 # 5400 <malloc+0x1b0>
     1ae:	7ef040ef          	jal	519c <printf>
    exit(1);
     1b2:	4505                	li	a0,1
     1b4:	3c1040ef          	jal	4d74 <exit>

00000000000001b8 <createtest>:
{
     1b8:	7179                	addi	sp,sp,-48
     1ba:	f406                	sd	ra,40(sp)
     1bc:	f022                	sd	s0,32(sp)
     1be:	ec26                	sd	s1,24(sp)
     1c0:	e84a                	sd	s2,16(sp)
     1c2:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1c4:	06100793          	li	a5,97
     1c8:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1cc:	fc040d23          	sb	zero,-38(s0)
     1d0:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     1d4:	06400913          	li	s2,100
    name[1] = '0' + i;
     1d8:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
     1dc:	20200593          	li	a1,514
     1e0:	fd840513          	addi	a0,s0,-40
     1e4:	3d1040ef          	jal	4db4 <open>
    close(fd);
     1e8:	3b5040ef          	jal	4d9c <close>
  for(i = 0; i < N; i++){
     1ec:	2485                	addiw	s1,s1,1
     1ee:	0ff4f493          	zext.b	s1,s1
     1f2:	ff2493e3          	bne	s1,s2,1d8 <createtest+0x20>
  name[0] = 'a';
     1f6:	06100793          	li	a5,97
     1fa:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1fe:	fc040d23          	sb	zero,-38(s0)
     202:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     206:	06400913          	li	s2,100
    name[1] = '0' + i;
     20a:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     20e:	fd840513          	addi	a0,s0,-40
     212:	3b3040ef          	jal	4dc4 <unlink>
  for(i = 0; i < N; i++){
     216:	2485                	addiw	s1,s1,1
     218:	0ff4f493          	zext.b	s1,s1
     21c:	ff2497e3          	bne	s1,s2,20a <createtest+0x52>
}
     220:	70a2                	ld	ra,40(sp)
     222:	7402                	ld	s0,32(sp)
     224:	64e2                	ld	s1,24(sp)
     226:	6942                	ld	s2,16(sp)
     228:	6145                	addi	sp,sp,48
     22a:	8082                	ret

000000000000022c <bigwrite>:
{
     22c:	715d                	addi	sp,sp,-80
     22e:	e486                	sd	ra,72(sp)
     230:	e0a2                	sd	s0,64(sp)
     232:	fc26                	sd	s1,56(sp)
     234:	f84a                	sd	s2,48(sp)
     236:	f44e                	sd	s3,40(sp)
     238:	f052                	sd	s4,32(sp)
     23a:	ec56                	sd	s5,24(sp)
     23c:	e85a                	sd	s6,16(sp)
     23e:	e45e                	sd	s7,8(sp)
     240:	0880                	addi	s0,sp,80
     242:	8baa                	mv	s7,a0
  unlink("bigwrite");
     244:	00005517          	auipc	a0,0x5
     248:	1e450513          	addi	a0,a0,484 # 5428 <malloc+0x1d8>
     24c:	379040ef          	jal	4dc4 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     250:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     254:	00005a97          	auipc	s5,0x5
     258:	1d4a8a93          	addi	s5,s5,468 # 5428 <malloc+0x1d8>
      int cc = write(fd, buf, sz);
     25c:	0000da17          	auipc	s4,0xd
     260:	a5ca0a13          	addi	s4,s4,-1444 # ccb8 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     264:	6b0d                	lui	s6,0x3
     266:	1c9b0b13          	addi	s6,s6,457 # 31c9 <rmdot+0x19>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     26a:	20200593          	li	a1,514
     26e:	8556                	mv	a0,s5
     270:	345040ef          	jal	4db4 <open>
     274:	892a                	mv	s2,a0
    if(fd < 0){
     276:	04054563          	bltz	a0,2c0 <bigwrite+0x94>
      int cc = write(fd, buf, sz);
     27a:	8626                	mv	a2,s1
     27c:	85d2                	mv	a1,s4
     27e:	317040ef          	jal	4d94 <write>
     282:	89aa                	mv	s3,a0
      if(cc != sz){
     284:	04a49863          	bne	s1,a0,2d4 <bigwrite+0xa8>
      int cc = write(fd, buf, sz);
     288:	8626                	mv	a2,s1
     28a:	85d2                	mv	a1,s4
     28c:	854a                	mv	a0,s2
     28e:	307040ef          	jal	4d94 <write>
      if(cc != sz){
     292:	04951263          	bne	a0,s1,2d6 <bigwrite+0xaa>
    close(fd);
     296:	854a                	mv	a0,s2
     298:	305040ef          	jal	4d9c <close>
    unlink("bigwrite");
     29c:	8556                	mv	a0,s5
     29e:	327040ef          	jal	4dc4 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a2:	1d74849b          	addiw	s1,s1,471
     2a6:	fd6492e3          	bne	s1,s6,26a <bigwrite+0x3e>
}
     2aa:	60a6                	ld	ra,72(sp)
     2ac:	6406                	ld	s0,64(sp)
     2ae:	74e2                	ld	s1,56(sp)
     2b0:	7942                	ld	s2,48(sp)
     2b2:	79a2                	ld	s3,40(sp)
     2b4:	7a02                	ld	s4,32(sp)
     2b6:	6ae2                	ld	s5,24(sp)
     2b8:	6b42                	ld	s6,16(sp)
     2ba:	6ba2                	ld	s7,8(sp)
     2bc:	6161                	addi	sp,sp,80
     2be:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     2c0:	85de                	mv	a1,s7
     2c2:	00005517          	auipc	a0,0x5
     2c6:	17650513          	addi	a0,a0,374 # 5438 <malloc+0x1e8>
     2ca:	6d3040ef          	jal	519c <printf>
      exit(1);
     2ce:	4505                	li	a0,1
     2d0:	2a5040ef          	jal	4d74 <exit>
      if(cc != sz){
     2d4:	89a6                	mv	s3,s1
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     2d6:	86aa                	mv	a3,a0
     2d8:	864e                	mv	a2,s3
     2da:	85de                	mv	a1,s7
     2dc:	00005517          	auipc	a0,0x5
     2e0:	17c50513          	addi	a0,a0,380 # 5458 <malloc+0x208>
     2e4:	6b9040ef          	jal	519c <printf>
        exit(1);
     2e8:	4505                	li	a0,1
     2ea:	28b040ef          	jal	4d74 <exit>

00000000000002ee <badwrite>:
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void
badwrite(char *s)
{
     2ee:	7179                	addi	sp,sp,-48
     2f0:	f406                	sd	ra,40(sp)
     2f2:	f022                	sd	s0,32(sp)
     2f4:	ec26                	sd	s1,24(sp)
     2f6:	e84a                	sd	s2,16(sp)
     2f8:	e44e                	sd	s3,8(sp)
     2fa:	e052                	sd	s4,0(sp)
     2fc:	1800                	addi	s0,sp,48
  int assumed_free = 600;
  
  unlink("junk");
     2fe:	00005517          	auipc	a0,0x5
     302:	17250513          	addi	a0,a0,370 # 5470 <malloc+0x220>
     306:	2bf040ef          	jal	4dc4 <unlink>
     30a:	25800913          	li	s2,600
  for(int i = 0; i < assumed_free; i++){
    int fd = open("junk", O_CREATE|O_WRONLY);
     30e:	00005997          	auipc	s3,0x5
     312:	16298993          	addi	s3,s3,354 # 5470 <malloc+0x220>
    if(fd < 0){
      printf("open junk failed\n");
      exit(1);
    }
    write(fd, (char*)0xffffffffffL, 1);
     316:	5a7d                	li	s4,-1
     318:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
     31c:	20100593          	li	a1,513
     320:	854e                	mv	a0,s3
     322:	293040ef          	jal	4db4 <open>
     326:	84aa                	mv	s1,a0
    if(fd < 0){
     328:	04054d63          	bltz	a0,382 <badwrite+0x94>
    write(fd, (char*)0xffffffffffL, 1);
     32c:	4605                	li	a2,1
     32e:	85d2                	mv	a1,s4
     330:	265040ef          	jal	4d94 <write>
    close(fd);
     334:	8526                	mv	a0,s1
     336:	267040ef          	jal	4d9c <close>
    unlink("junk");
     33a:	854e                	mv	a0,s3
     33c:	289040ef          	jal	4dc4 <unlink>
  for(int i = 0; i < assumed_free; i++){
     340:	397d                	addiw	s2,s2,-1
     342:	fc091de3          	bnez	s2,31c <badwrite+0x2e>
  }

  int fd = open("junk", O_CREATE|O_WRONLY);
     346:	20100593          	li	a1,513
     34a:	00005517          	auipc	a0,0x5
     34e:	12650513          	addi	a0,a0,294 # 5470 <malloc+0x220>
     352:	263040ef          	jal	4db4 <open>
     356:	84aa                	mv	s1,a0
  if(fd < 0){
     358:	02054e63          	bltz	a0,394 <badwrite+0xa6>
    printf("open junk failed\n");
    exit(1);
  }
  if(write(fd, "x", 1) != 1){
     35c:	4605                	li	a2,1
     35e:	00005597          	auipc	a1,0x5
     362:	09a58593          	addi	a1,a1,154 # 53f8 <malloc+0x1a8>
     366:	22f040ef          	jal	4d94 <write>
     36a:	4785                	li	a5,1
     36c:	02f50d63          	beq	a0,a5,3a6 <badwrite+0xb8>
    printf("write failed\n");
     370:	00005517          	auipc	a0,0x5
     374:	12050513          	addi	a0,a0,288 # 5490 <malloc+0x240>
     378:	625040ef          	jal	519c <printf>
    exit(1);
     37c:	4505                	li	a0,1
     37e:	1f7040ef          	jal	4d74 <exit>
      printf("open junk failed\n");
     382:	00005517          	auipc	a0,0x5
     386:	0f650513          	addi	a0,a0,246 # 5478 <malloc+0x228>
     38a:	613040ef          	jal	519c <printf>
      exit(1);
     38e:	4505                	li	a0,1
     390:	1e5040ef          	jal	4d74 <exit>
    printf("open junk failed\n");
     394:	00005517          	auipc	a0,0x5
     398:	0e450513          	addi	a0,a0,228 # 5478 <malloc+0x228>
     39c:	601040ef          	jal	519c <printf>
    exit(1);
     3a0:	4505                	li	a0,1
     3a2:	1d3040ef          	jal	4d74 <exit>
  }
  close(fd);
     3a6:	8526                	mv	a0,s1
     3a8:	1f5040ef          	jal	4d9c <close>
  unlink("junk");
     3ac:	00005517          	auipc	a0,0x5
     3b0:	0c450513          	addi	a0,a0,196 # 5470 <malloc+0x220>
     3b4:	211040ef          	jal	4dc4 <unlink>

  exit(0);
     3b8:	4501                	li	a0,0
     3ba:	1bb040ef          	jal	4d74 <exit>

00000000000003be <outofinodes>:
  }
}

void
outofinodes(char *s)
{
     3be:	715d                	addi	sp,sp,-80
     3c0:	e486                	sd	ra,72(sp)
     3c2:	e0a2                	sd	s0,64(sp)
     3c4:	fc26                	sd	s1,56(sp)
     3c6:	f84a                	sd	s2,48(sp)
     3c8:	f44e                	sd	s3,40(sp)
     3ca:	0880                	addi	s0,sp,80
  int nzz = 32*32;
  for(int i = 0; i < nzz; i++){
     3cc:	4481                	li	s1,0
    char name[32];
    name[0] = 'z';
     3ce:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     3d2:	40000993          	li	s3,1024
    name[0] = 'z';
     3d6:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     3da:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     3de:	41f4d71b          	sraiw	a4,s1,0x1f
     3e2:	01b7571b          	srliw	a4,a4,0x1b
     3e6:	009707bb          	addw	a5,a4,s1
     3ea:	4057d69b          	sraiw	a3,a5,0x5
     3ee:	0306869b          	addiw	a3,a3,48
     3f2:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     3f6:	8bfd                	andi	a5,a5,31
     3f8:	9f99                	subw	a5,a5,a4
     3fa:	0307879b          	addiw	a5,a5,48
     3fe:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     402:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     406:	fb040513          	addi	a0,s0,-80
     40a:	1bb040ef          	jal	4dc4 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
     40e:	60200593          	li	a1,1538
     412:	fb040513          	addi	a0,s0,-80
     416:	19f040ef          	jal	4db4 <open>
    if(fd < 0){
     41a:	00054763          	bltz	a0,428 <outofinodes+0x6a>
      // failure is eventually expected.
      break;
    }
    close(fd);
     41e:	17f040ef          	jal	4d9c <close>
  for(int i = 0; i < nzz; i++){
     422:	2485                	addiw	s1,s1,1
     424:	fb3499e3          	bne	s1,s3,3d6 <outofinodes+0x18>
     428:	4481                	li	s1,0
  }

  for(int i = 0; i < nzz; i++){
    char name[32];
    name[0] = 'z';
     42a:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     42e:	40000993          	li	s3,1024
    name[0] = 'z';
     432:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     436:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     43a:	41f4d71b          	sraiw	a4,s1,0x1f
     43e:	01b7571b          	srliw	a4,a4,0x1b
     442:	009707bb          	addw	a5,a4,s1
     446:	4057d69b          	sraiw	a3,a5,0x5
     44a:	0306869b          	addiw	a3,a3,48
     44e:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     452:	8bfd                	andi	a5,a5,31
     454:	9f99                	subw	a5,a5,a4
     456:	0307879b          	addiw	a5,a5,48
     45a:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     45e:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     462:	fb040513          	addi	a0,s0,-80
     466:	15f040ef          	jal	4dc4 <unlink>
  for(int i = 0; i < nzz; i++){
     46a:	2485                	addiw	s1,s1,1
     46c:	fd3493e3          	bne	s1,s3,432 <outofinodes+0x74>
  }
}
     470:	60a6                	ld	ra,72(sp)
     472:	6406                	ld	s0,64(sp)
     474:	74e2                	ld	s1,56(sp)
     476:	7942                	ld	s2,48(sp)
     478:	79a2                	ld	s3,40(sp)
     47a:	6161                	addi	sp,sp,80
     47c:	8082                	ret

000000000000047e <copyin>:
{
     47e:	7159                	addi	sp,sp,-112
     480:	f486                	sd	ra,104(sp)
     482:	f0a2                	sd	s0,96(sp)
     484:	eca6                	sd	s1,88(sp)
     486:	e8ca                	sd	s2,80(sp)
     488:	e4ce                	sd	s3,72(sp)
     48a:	e0d2                	sd	s4,64(sp)
     48c:	fc56                	sd	s5,56(sp)
     48e:	1880                	addi	s0,sp,112
  uint64 addrs[] = { 0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
     490:	00007797          	auipc	a5,0x7
     494:	44078793          	addi	a5,a5,1088 # 78d0 <malloc+0x2680>
     498:	638c                	ld	a1,0(a5)
     49a:	6790                	ld	a2,8(a5)
     49c:	6b94                	ld	a3,16(a5)
     49e:	6f98                	ld	a4,24(a5)
     4a0:	739c                	ld	a5,32(a5)
     4a2:	f8b43c23          	sd	a1,-104(s0)
     4a6:	fac43023          	sd	a2,-96(s0)
     4aa:	fad43423          	sd	a3,-88(s0)
     4ae:	fae43823          	sd	a4,-80(s0)
     4b2:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
     4b6:	f9840913          	addi	s2,s0,-104
     4ba:	fc040a93          	addi	s5,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     4be:	00005a17          	auipc	s4,0x5
     4c2:	fe2a0a13          	addi	s4,s4,-30 # 54a0 <malloc+0x250>
    uint64 addr = addrs[ai];
     4c6:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     4ca:	20100593          	li	a1,513
     4ce:	8552                	mv	a0,s4
     4d0:	0e5040ef          	jal	4db4 <open>
     4d4:	84aa                	mv	s1,a0
    if(fd < 0){
     4d6:	06054763          	bltz	a0,544 <copyin+0xc6>
    int n = write(fd, (void*)addr, 8192);
     4da:	6609                	lui	a2,0x2
     4dc:	85ce                	mv	a1,s3
     4de:	0b7040ef          	jal	4d94 <write>
    if(n >= 0){
     4e2:	06055a63          	bgez	a0,556 <copyin+0xd8>
    close(fd);
     4e6:	8526                	mv	a0,s1
     4e8:	0b5040ef          	jal	4d9c <close>
    unlink("copyin1");
     4ec:	8552                	mv	a0,s4
     4ee:	0d7040ef          	jal	4dc4 <unlink>
    n = write(1, (char*)addr, 8192);
     4f2:	6609                	lui	a2,0x2
     4f4:	85ce                	mv	a1,s3
     4f6:	4505                	li	a0,1
     4f8:	09d040ef          	jal	4d94 <write>
    if(n > 0){
     4fc:	06a04863          	bgtz	a0,56c <copyin+0xee>
    if(pipe(fds) < 0){
     500:	f9040513          	addi	a0,s0,-112
     504:	081040ef          	jal	4d84 <pipe>
     508:	06054d63          	bltz	a0,582 <copyin+0x104>
    n = write(fds[1], (char*)addr, 8192);
     50c:	6609                	lui	a2,0x2
     50e:	85ce                	mv	a1,s3
     510:	f9442503          	lw	a0,-108(s0)
     514:	081040ef          	jal	4d94 <write>
    if(n > 0){
     518:	06a04e63          	bgtz	a0,594 <copyin+0x116>
    close(fds[0]);
     51c:	f9042503          	lw	a0,-112(s0)
     520:	07d040ef          	jal	4d9c <close>
    close(fds[1]);
     524:	f9442503          	lw	a0,-108(s0)
     528:	075040ef          	jal	4d9c <close>
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
     52c:	0921                	addi	s2,s2,8
     52e:	f9591ce3          	bne	s2,s5,4c6 <copyin+0x48>
}
     532:	70a6                	ld	ra,104(sp)
     534:	7406                	ld	s0,96(sp)
     536:	64e6                	ld	s1,88(sp)
     538:	6946                	ld	s2,80(sp)
     53a:	69a6                	ld	s3,72(sp)
     53c:	6a06                	ld	s4,64(sp)
     53e:	7ae2                	ld	s5,56(sp)
     540:	6165                	addi	sp,sp,112
     542:	8082                	ret
      printf("open(copyin1) failed\n");
     544:	00005517          	auipc	a0,0x5
     548:	f6450513          	addi	a0,a0,-156 # 54a8 <malloc+0x258>
     54c:	451040ef          	jal	519c <printf>
      exit(1);
     550:	4505                	li	a0,1
     552:	023040ef          	jal	4d74 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", (void*)addr, n);
     556:	862a                	mv	a2,a0
     558:	85ce                	mv	a1,s3
     55a:	00005517          	auipc	a0,0x5
     55e:	f6650513          	addi	a0,a0,-154 # 54c0 <malloc+0x270>
     562:	43b040ef          	jal	519c <printf>
      exit(1);
     566:	4505                	li	a0,1
     568:	00d040ef          	jal	4d74 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", (void*)addr, n);
     56c:	862a                	mv	a2,a0
     56e:	85ce                	mv	a1,s3
     570:	00005517          	auipc	a0,0x5
     574:	f8050513          	addi	a0,a0,-128 # 54f0 <malloc+0x2a0>
     578:	425040ef          	jal	519c <printf>
      exit(1);
     57c:	4505                	li	a0,1
     57e:	7f6040ef          	jal	4d74 <exit>
      printf("pipe() failed\n");
     582:	00005517          	auipc	a0,0x5
     586:	f9e50513          	addi	a0,a0,-98 # 5520 <malloc+0x2d0>
     58a:	413040ef          	jal	519c <printf>
      exit(1);
     58e:	4505                	li	a0,1
     590:	7e4040ef          	jal	4d74 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", (void*)addr, n);
     594:	862a                	mv	a2,a0
     596:	85ce                	mv	a1,s3
     598:	00005517          	auipc	a0,0x5
     59c:	f9850513          	addi	a0,a0,-104 # 5530 <malloc+0x2e0>
     5a0:	3fd040ef          	jal	519c <printf>
      exit(1);
     5a4:	4505                	li	a0,1
     5a6:	7ce040ef          	jal	4d74 <exit>

00000000000005aa <copyout>:
{
     5aa:	7119                	addi	sp,sp,-128
     5ac:	fc86                	sd	ra,120(sp)
     5ae:	f8a2                	sd	s0,112(sp)
     5b0:	f4a6                	sd	s1,104(sp)
     5b2:	f0ca                	sd	s2,96(sp)
     5b4:	ecce                	sd	s3,88(sp)
     5b6:	e8d2                	sd	s4,80(sp)
     5b8:	e4d6                	sd	s5,72(sp)
     5ba:	e0da                	sd	s6,64(sp)
     5bc:	0100                	addi	s0,sp,128
  uint64 addrs[] = { 0LL, 0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
     5be:	00007797          	auipc	a5,0x7
     5c2:	31278793          	addi	a5,a5,786 # 78d0 <malloc+0x2680>
     5c6:	7788                	ld	a0,40(a5)
     5c8:	7b8c                	ld	a1,48(a5)
     5ca:	7f90                	ld	a2,56(a5)
     5cc:	63b4                	ld	a3,64(a5)
     5ce:	67b8                	ld	a4,72(a5)
     5d0:	6bbc                	ld	a5,80(a5)
     5d2:	f8a43823          	sd	a0,-112(s0)
     5d6:	f8b43c23          	sd	a1,-104(s0)
     5da:	fac43023          	sd	a2,-96(s0)
     5de:	fad43423          	sd	a3,-88(s0)
     5e2:	fae43823          	sd	a4,-80(s0)
     5e6:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
     5ea:	f9040913          	addi	s2,s0,-112
     5ee:	fc040b13          	addi	s6,s0,-64
    int fd = open("README", 0);
     5f2:	00005a17          	auipc	s4,0x5
     5f6:	f6ea0a13          	addi	s4,s4,-146 # 5560 <malloc+0x310>
    n = write(fds[1], "x", 1);
     5fa:	00005a97          	auipc	s5,0x5
     5fe:	dfea8a93          	addi	s5,s5,-514 # 53f8 <malloc+0x1a8>
    uint64 addr = addrs[ai];
     602:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     606:	4581                	li	a1,0
     608:	8552                	mv	a0,s4
     60a:	7aa040ef          	jal	4db4 <open>
     60e:	84aa                	mv	s1,a0
    if(fd < 0){
     610:	06054763          	bltz	a0,67e <copyout+0xd4>
    int n = read(fd, (void*)addr, 8192);
     614:	6609                	lui	a2,0x2
     616:	85ce                	mv	a1,s3
     618:	774040ef          	jal	4d8c <read>
    if(n > 0){
     61c:	06a04a63          	bgtz	a0,690 <copyout+0xe6>
    close(fd);
     620:	8526                	mv	a0,s1
     622:	77a040ef          	jal	4d9c <close>
    if(pipe(fds) < 0){
     626:	f8840513          	addi	a0,s0,-120
     62a:	75a040ef          	jal	4d84 <pipe>
     62e:	06054c63          	bltz	a0,6a6 <copyout+0xfc>
    n = write(fds[1], "x", 1);
     632:	4605                	li	a2,1
     634:	85d6                	mv	a1,s5
     636:	f8c42503          	lw	a0,-116(s0)
     63a:	75a040ef          	jal	4d94 <write>
    if(n != 1){
     63e:	4785                	li	a5,1
     640:	06f51c63          	bne	a0,a5,6b8 <copyout+0x10e>
    n = read(fds[0], (void*)addr, 8192);
     644:	6609                	lui	a2,0x2
     646:	85ce                	mv	a1,s3
     648:	f8842503          	lw	a0,-120(s0)
     64c:	740040ef          	jal	4d8c <read>
    if(n > 0){
     650:	06a04d63          	bgtz	a0,6ca <copyout+0x120>
    close(fds[0]);
     654:	f8842503          	lw	a0,-120(s0)
     658:	744040ef          	jal	4d9c <close>
    close(fds[1]);
     65c:	f8c42503          	lw	a0,-116(s0)
     660:	73c040ef          	jal	4d9c <close>
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
     664:	0921                	addi	s2,s2,8
     666:	f9691ee3          	bne	s2,s6,602 <copyout+0x58>
}
     66a:	70e6                	ld	ra,120(sp)
     66c:	7446                	ld	s0,112(sp)
     66e:	74a6                	ld	s1,104(sp)
     670:	7906                	ld	s2,96(sp)
     672:	69e6                	ld	s3,88(sp)
     674:	6a46                	ld	s4,80(sp)
     676:	6aa6                	ld	s5,72(sp)
     678:	6b06                	ld	s6,64(sp)
     67a:	6109                	addi	sp,sp,128
     67c:	8082                	ret
      printf("open(README) failed\n");
     67e:	00005517          	auipc	a0,0x5
     682:	eea50513          	addi	a0,a0,-278 # 5568 <malloc+0x318>
     686:	317040ef          	jal	519c <printf>
      exit(1);
     68a:	4505                	li	a0,1
     68c:	6e8040ef          	jal	4d74 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", (void*)addr, n);
     690:	862a                	mv	a2,a0
     692:	85ce                	mv	a1,s3
     694:	00005517          	auipc	a0,0x5
     698:	eec50513          	addi	a0,a0,-276 # 5580 <malloc+0x330>
     69c:	301040ef          	jal	519c <printf>
      exit(1);
     6a0:	4505                	li	a0,1
     6a2:	6d2040ef          	jal	4d74 <exit>
      printf("pipe() failed\n");
     6a6:	00005517          	auipc	a0,0x5
     6aa:	e7a50513          	addi	a0,a0,-390 # 5520 <malloc+0x2d0>
     6ae:	2ef040ef          	jal	519c <printf>
      exit(1);
     6b2:	4505                	li	a0,1
     6b4:	6c0040ef          	jal	4d74 <exit>
      printf("pipe write failed\n");
     6b8:	00005517          	auipc	a0,0x5
     6bc:	ef850513          	addi	a0,a0,-264 # 55b0 <malloc+0x360>
     6c0:	2dd040ef          	jal	519c <printf>
      exit(1);
     6c4:	4505                	li	a0,1
     6c6:	6ae040ef          	jal	4d74 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", (void*)addr, n);
     6ca:	862a                	mv	a2,a0
     6cc:	85ce                	mv	a1,s3
     6ce:	00005517          	auipc	a0,0x5
     6d2:	efa50513          	addi	a0,a0,-262 # 55c8 <malloc+0x378>
     6d6:	2c7040ef          	jal	519c <printf>
      exit(1);
     6da:	4505                	li	a0,1
     6dc:	698040ef          	jal	4d74 <exit>

00000000000006e0 <truncate1>:
{
     6e0:	711d                	addi	sp,sp,-96
     6e2:	ec86                	sd	ra,88(sp)
     6e4:	e8a2                	sd	s0,80(sp)
     6e6:	e4a6                	sd	s1,72(sp)
     6e8:	e0ca                	sd	s2,64(sp)
     6ea:	fc4e                	sd	s3,56(sp)
     6ec:	f852                	sd	s4,48(sp)
     6ee:	f456                	sd	s5,40(sp)
     6f0:	1080                	addi	s0,sp,96
     6f2:	8aaa                	mv	s5,a0
  unlink("truncfile");
     6f4:	00005517          	auipc	a0,0x5
     6f8:	cec50513          	addi	a0,a0,-788 # 53e0 <malloc+0x190>
     6fc:	6c8040ef          	jal	4dc4 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     700:	60100593          	li	a1,1537
     704:	00005517          	auipc	a0,0x5
     708:	cdc50513          	addi	a0,a0,-804 # 53e0 <malloc+0x190>
     70c:	6a8040ef          	jal	4db4 <open>
     710:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     712:	4611                	li	a2,4
     714:	00005597          	auipc	a1,0x5
     718:	cdc58593          	addi	a1,a1,-804 # 53f0 <malloc+0x1a0>
     71c:	678040ef          	jal	4d94 <write>
  close(fd1);
     720:	8526                	mv	a0,s1
     722:	67a040ef          	jal	4d9c <close>
  int fd2 = open("truncfile", O_RDONLY);
     726:	4581                	li	a1,0
     728:	00005517          	auipc	a0,0x5
     72c:	cb850513          	addi	a0,a0,-840 # 53e0 <malloc+0x190>
     730:	684040ef          	jal	4db4 <open>
     734:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     736:	02000613          	li	a2,32
     73a:	fa040593          	addi	a1,s0,-96
     73e:	64e040ef          	jal	4d8c <read>
  if(n != 4){
     742:	4791                	li	a5,4
     744:	0af51863          	bne	a0,a5,7f4 <truncate1+0x114>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     748:	40100593          	li	a1,1025
     74c:	00005517          	auipc	a0,0x5
     750:	c9450513          	addi	a0,a0,-876 # 53e0 <malloc+0x190>
     754:	660040ef          	jal	4db4 <open>
     758:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     75a:	4581                	li	a1,0
     75c:	00005517          	auipc	a0,0x5
     760:	c8450513          	addi	a0,a0,-892 # 53e0 <malloc+0x190>
     764:	650040ef          	jal	4db4 <open>
     768:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     76a:	02000613          	li	a2,32
     76e:	fa040593          	addi	a1,s0,-96
     772:	61a040ef          	jal	4d8c <read>
     776:	8a2a                	mv	s4,a0
  if(n != 0){
     778:	e949                	bnez	a0,80a <truncate1+0x12a>
  n = read(fd2, buf, sizeof(buf));
     77a:	02000613          	li	a2,32
     77e:	fa040593          	addi	a1,s0,-96
     782:	8526                	mv	a0,s1
     784:	608040ef          	jal	4d8c <read>
     788:	8a2a                	mv	s4,a0
  if(n != 0){
     78a:	e155                	bnez	a0,82e <truncate1+0x14e>
  write(fd1, "abcdef", 6);
     78c:	4619                	li	a2,6
     78e:	00005597          	auipc	a1,0x5
     792:	eca58593          	addi	a1,a1,-310 # 5658 <malloc+0x408>
     796:	854e                	mv	a0,s3
     798:	5fc040ef          	jal	4d94 <write>
  n = read(fd3, buf, sizeof(buf));
     79c:	02000613          	li	a2,32
     7a0:	fa040593          	addi	a1,s0,-96
     7a4:	854a                	mv	a0,s2
     7a6:	5e6040ef          	jal	4d8c <read>
  if(n != 6){
     7aa:	4799                	li	a5,6
     7ac:	0af51363          	bne	a0,a5,852 <truncate1+0x172>
  n = read(fd2, buf, sizeof(buf));
     7b0:	02000613          	li	a2,32
     7b4:	fa040593          	addi	a1,s0,-96
     7b8:	8526                	mv	a0,s1
     7ba:	5d2040ef          	jal	4d8c <read>
  if(n != 2){
     7be:	4789                	li	a5,2
     7c0:	0af51463          	bne	a0,a5,868 <truncate1+0x188>
  unlink("truncfile");
     7c4:	00005517          	auipc	a0,0x5
     7c8:	c1c50513          	addi	a0,a0,-996 # 53e0 <malloc+0x190>
     7cc:	5f8040ef          	jal	4dc4 <unlink>
  close(fd1);
     7d0:	854e                	mv	a0,s3
     7d2:	5ca040ef          	jal	4d9c <close>
  close(fd2);
     7d6:	8526                	mv	a0,s1
     7d8:	5c4040ef          	jal	4d9c <close>
  close(fd3);
     7dc:	854a                	mv	a0,s2
     7de:	5be040ef          	jal	4d9c <close>
}
     7e2:	60e6                	ld	ra,88(sp)
     7e4:	6446                	ld	s0,80(sp)
     7e6:	64a6                	ld	s1,72(sp)
     7e8:	6906                	ld	s2,64(sp)
     7ea:	79e2                	ld	s3,56(sp)
     7ec:	7a42                	ld	s4,48(sp)
     7ee:	7aa2                	ld	s5,40(sp)
     7f0:	6125                	addi	sp,sp,96
     7f2:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     7f4:	862a                	mv	a2,a0
     7f6:	85d6                	mv	a1,s5
     7f8:	00005517          	auipc	a0,0x5
     7fc:	e0050513          	addi	a0,a0,-512 # 55f8 <malloc+0x3a8>
     800:	19d040ef          	jal	519c <printf>
    exit(1);
     804:	4505                	li	a0,1
     806:	56e040ef          	jal	4d74 <exit>
    printf("aaa fd3=%d\n", fd3);
     80a:	85ca                	mv	a1,s2
     80c:	00005517          	auipc	a0,0x5
     810:	e0c50513          	addi	a0,a0,-500 # 5618 <malloc+0x3c8>
     814:	189040ef          	jal	519c <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     818:	8652                	mv	a2,s4
     81a:	85d6                	mv	a1,s5
     81c:	00005517          	auipc	a0,0x5
     820:	e0c50513          	addi	a0,a0,-500 # 5628 <malloc+0x3d8>
     824:	179040ef          	jal	519c <printf>
    exit(1);
     828:	4505                	li	a0,1
     82a:	54a040ef          	jal	4d74 <exit>
    printf("bbb fd2=%d\n", fd2);
     82e:	85a6                	mv	a1,s1
     830:	00005517          	auipc	a0,0x5
     834:	e1850513          	addi	a0,a0,-488 # 5648 <malloc+0x3f8>
     838:	165040ef          	jal	519c <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     83c:	8652                	mv	a2,s4
     83e:	85d6                	mv	a1,s5
     840:	00005517          	auipc	a0,0x5
     844:	de850513          	addi	a0,a0,-536 # 5628 <malloc+0x3d8>
     848:	155040ef          	jal	519c <printf>
    exit(1);
     84c:	4505                	li	a0,1
     84e:	526040ef          	jal	4d74 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     852:	862a                	mv	a2,a0
     854:	85d6                	mv	a1,s5
     856:	00005517          	auipc	a0,0x5
     85a:	e0a50513          	addi	a0,a0,-502 # 5660 <malloc+0x410>
     85e:	13f040ef          	jal	519c <printf>
    exit(1);
     862:	4505                	li	a0,1
     864:	510040ef          	jal	4d74 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     868:	862a                	mv	a2,a0
     86a:	85d6                	mv	a1,s5
     86c:	00005517          	auipc	a0,0x5
     870:	e1450513          	addi	a0,a0,-492 # 5680 <malloc+0x430>
     874:	129040ef          	jal	519c <printf>
    exit(1);
     878:	4505                	li	a0,1
     87a:	4fa040ef          	jal	4d74 <exit>

000000000000087e <writetest>:
{
     87e:	7139                	addi	sp,sp,-64
     880:	fc06                	sd	ra,56(sp)
     882:	f822                	sd	s0,48(sp)
     884:	f426                	sd	s1,40(sp)
     886:	f04a                	sd	s2,32(sp)
     888:	ec4e                	sd	s3,24(sp)
     88a:	e852                	sd	s4,16(sp)
     88c:	e456                	sd	s5,8(sp)
     88e:	e05a                	sd	s6,0(sp)
     890:	0080                	addi	s0,sp,64
     892:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     894:	20200593          	li	a1,514
     898:	00005517          	auipc	a0,0x5
     89c:	e0850513          	addi	a0,a0,-504 # 56a0 <malloc+0x450>
     8a0:	514040ef          	jal	4db4 <open>
  if(fd < 0){
     8a4:	08054f63          	bltz	a0,942 <writetest+0xc4>
     8a8:	892a                	mv	s2,a0
     8aa:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     8ac:	00005997          	auipc	s3,0x5
     8b0:	e1c98993          	addi	s3,s3,-484 # 56c8 <malloc+0x478>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     8b4:	00005a97          	auipc	s5,0x5
     8b8:	e4ca8a93          	addi	s5,s5,-436 # 5700 <malloc+0x4b0>
  for(i = 0; i < N; i++){
     8bc:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     8c0:	4629                	li	a2,10
     8c2:	85ce                	mv	a1,s3
     8c4:	854a                	mv	a0,s2
     8c6:	4ce040ef          	jal	4d94 <write>
     8ca:	47a9                	li	a5,10
     8cc:	08f51563          	bne	a0,a5,956 <writetest+0xd8>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     8d0:	4629                	li	a2,10
     8d2:	85d6                	mv	a1,s5
     8d4:	854a                	mv	a0,s2
     8d6:	4be040ef          	jal	4d94 <write>
     8da:	47a9                	li	a5,10
     8dc:	08f51863          	bne	a0,a5,96c <writetest+0xee>
  for(i = 0; i < N; i++){
     8e0:	2485                	addiw	s1,s1,1
     8e2:	fd449fe3          	bne	s1,s4,8c0 <writetest+0x42>
  close(fd);
     8e6:	854a                	mv	a0,s2
     8e8:	4b4040ef          	jal	4d9c <close>
  fd = open("small", O_RDONLY);
     8ec:	4581                	li	a1,0
     8ee:	00005517          	auipc	a0,0x5
     8f2:	db250513          	addi	a0,a0,-590 # 56a0 <malloc+0x450>
     8f6:	4be040ef          	jal	4db4 <open>
     8fa:	84aa                	mv	s1,a0
  if(fd < 0){
     8fc:	08054363          	bltz	a0,982 <writetest+0x104>
  i = read(fd, buf, N*SZ*2);
     900:	7d000613          	li	a2,2000
     904:	0000c597          	auipc	a1,0xc
     908:	3b458593          	addi	a1,a1,948 # ccb8 <buf>
     90c:	480040ef          	jal	4d8c <read>
  if(i != N*SZ*2){
     910:	7d000793          	li	a5,2000
     914:	08f51163          	bne	a0,a5,996 <writetest+0x118>
  close(fd);
     918:	8526                	mv	a0,s1
     91a:	482040ef          	jal	4d9c <close>
  if(unlink("small") < 0){
     91e:	00005517          	auipc	a0,0x5
     922:	d8250513          	addi	a0,a0,-638 # 56a0 <malloc+0x450>
     926:	49e040ef          	jal	4dc4 <unlink>
     92a:	08054063          	bltz	a0,9aa <writetest+0x12c>
}
     92e:	70e2                	ld	ra,56(sp)
     930:	7442                	ld	s0,48(sp)
     932:	74a2                	ld	s1,40(sp)
     934:	7902                	ld	s2,32(sp)
     936:	69e2                	ld	s3,24(sp)
     938:	6a42                	ld	s4,16(sp)
     93a:	6aa2                	ld	s5,8(sp)
     93c:	6b02                	ld	s6,0(sp)
     93e:	6121                	addi	sp,sp,64
     940:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     942:	85da                	mv	a1,s6
     944:	00005517          	auipc	a0,0x5
     948:	d6450513          	addi	a0,a0,-668 # 56a8 <malloc+0x458>
     94c:	051040ef          	jal	519c <printf>
    exit(1);
     950:	4505                	li	a0,1
     952:	422040ef          	jal	4d74 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     956:	8626                	mv	a2,s1
     958:	85da                	mv	a1,s6
     95a:	00005517          	auipc	a0,0x5
     95e:	d7e50513          	addi	a0,a0,-642 # 56d8 <malloc+0x488>
     962:	03b040ef          	jal	519c <printf>
      exit(1);
     966:	4505                	li	a0,1
     968:	40c040ef          	jal	4d74 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     96c:	8626                	mv	a2,s1
     96e:	85da                	mv	a1,s6
     970:	00005517          	auipc	a0,0x5
     974:	da050513          	addi	a0,a0,-608 # 5710 <malloc+0x4c0>
     978:	025040ef          	jal	519c <printf>
      exit(1);
     97c:	4505                	li	a0,1
     97e:	3f6040ef          	jal	4d74 <exit>
    printf("%s: error: open small failed!\n", s);
     982:	85da                	mv	a1,s6
     984:	00005517          	auipc	a0,0x5
     988:	db450513          	addi	a0,a0,-588 # 5738 <malloc+0x4e8>
     98c:	011040ef          	jal	519c <printf>
    exit(1);
     990:	4505                	li	a0,1
     992:	3e2040ef          	jal	4d74 <exit>
    printf("%s: read failed\n", s);
     996:	85da                	mv	a1,s6
     998:	00005517          	auipc	a0,0x5
     99c:	dc050513          	addi	a0,a0,-576 # 5758 <malloc+0x508>
     9a0:	7fc040ef          	jal	519c <printf>
    exit(1);
     9a4:	4505                	li	a0,1
     9a6:	3ce040ef          	jal	4d74 <exit>
    printf("%s: unlink small failed\n", s);
     9aa:	85da                	mv	a1,s6
     9ac:	00005517          	auipc	a0,0x5
     9b0:	dc450513          	addi	a0,a0,-572 # 5770 <malloc+0x520>
     9b4:	7e8040ef          	jal	519c <printf>
    exit(1);
     9b8:	4505                	li	a0,1
     9ba:	3ba040ef          	jal	4d74 <exit>

00000000000009be <writebig>:
{
     9be:	7139                	addi	sp,sp,-64
     9c0:	fc06                	sd	ra,56(sp)
     9c2:	f822                	sd	s0,48(sp)
     9c4:	f426                	sd	s1,40(sp)
     9c6:	f04a                	sd	s2,32(sp)
     9c8:	ec4e                	sd	s3,24(sp)
     9ca:	e852                	sd	s4,16(sp)
     9cc:	e456                	sd	s5,8(sp)
     9ce:	0080                	addi	s0,sp,64
     9d0:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     9d2:	20200593          	li	a1,514
     9d6:	00005517          	auipc	a0,0x5
     9da:	dba50513          	addi	a0,a0,-582 # 5790 <malloc+0x540>
     9de:	3d6040ef          	jal	4db4 <open>
     9e2:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     9e4:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     9e6:	0000c917          	auipc	s2,0xc
     9ea:	2d290913          	addi	s2,s2,722 # ccb8 <buf>
  for(i = 0; i < MAXFILE; i++){
     9ee:	10c00a13          	li	s4,268
  if(fd < 0){
     9f2:	06054463          	bltz	a0,a5a <writebig+0x9c>
    ((int*)buf)[0] = i;
     9f6:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     9fa:	40000613          	li	a2,1024
     9fe:	85ca                	mv	a1,s2
     a00:	854e                	mv	a0,s3
     a02:	392040ef          	jal	4d94 <write>
     a06:	40000793          	li	a5,1024
     a0a:	06f51263          	bne	a0,a5,a6e <writebig+0xb0>
  for(i = 0; i < MAXFILE; i++){
     a0e:	2485                	addiw	s1,s1,1
     a10:	ff4493e3          	bne	s1,s4,9f6 <writebig+0x38>
  close(fd);
     a14:	854e                	mv	a0,s3
     a16:	386040ef          	jal	4d9c <close>
  fd = open("big", O_RDONLY);
     a1a:	4581                	li	a1,0
     a1c:	00005517          	auipc	a0,0x5
     a20:	d7450513          	addi	a0,a0,-652 # 5790 <malloc+0x540>
     a24:	390040ef          	jal	4db4 <open>
     a28:	89aa                	mv	s3,a0
  n = 0;
     a2a:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a2c:	0000c917          	auipc	s2,0xc
     a30:	28c90913          	addi	s2,s2,652 # ccb8 <buf>
  if(fd < 0){
     a34:	04054863          	bltz	a0,a84 <writebig+0xc6>
    i = read(fd, buf, BSIZE);
     a38:	40000613          	li	a2,1024
     a3c:	85ca                	mv	a1,s2
     a3e:	854e                	mv	a0,s3
     a40:	34c040ef          	jal	4d8c <read>
    if(i == 0){
     a44:	c931                	beqz	a0,a98 <writebig+0xda>
    } else if(i != BSIZE){
     a46:	40000793          	li	a5,1024
     a4a:	08f51a63          	bne	a0,a5,ade <writebig+0x120>
    if(((int*)buf)[0] != n){
     a4e:	00092683          	lw	a3,0(s2)
     a52:	0a969163          	bne	a3,s1,af4 <writebig+0x136>
    n++;
     a56:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a58:	b7c5                	j	a38 <writebig+0x7a>
    printf("%s: error: creat big failed!\n", s);
     a5a:	85d6                	mv	a1,s5
     a5c:	00005517          	auipc	a0,0x5
     a60:	d3c50513          	addi	a0,a0,-708 # 5798 <malloc+0x548>
     a64:	738040ef          	jal	519c <printf>
    exit(1);
     a68:	4505                	li	a0,1
     a6a:	30a040ef          	jal	4d74 <exit>
      printf("%s: error: write big file failed i=%d\n", s, i);
     a6e:	8626                	mv	a2,s1
     a70:	85d6                	mv	a1,s5
     a72:	00005517          	auipc	a0,0x5
     a76:	d4650513          	addi	a0,a0,-698 # 57b8 <malloc+0x568>
     a7a:	722040ef          	jal	519c <printf>
      exit(1);
     a7e:	4505                	li	a0,1
     a80:	2f4040ef          	jal	4d74 <exit>
    printf("%s: error: open big failed!\n", s);
     a84:	85d6                	mv	a1,s5
     a86:	00005517          	auipc	a0,0x5
     a8a:	d5a50513          	addi	a0,a0,-678 # 57e0 <malloc+0x590>
     a8e:	70e040ef          	jal	519c <printf>
    exit(1);
     a92:	4505                	li	a0,1
     a94:	2e0040ef          	jal	4d74 <exit>
      if(n != MAXFILE){
     a98:	10c00793          	li	a5,268
     a9c:	02f49663          	bne	s1,a5,ac8 <writebig+0x10a>
  close(fd);
     aa0:	854e                	mv	a0,s3
     aa2:	2fa040ef          	jal	4d9c <close>
  if(unlink("big") < 0){
     aa6:	00005517          	auipc	a0,0x5
     aaa:	cea50513          	addi	a0,a0,-790 # 5790 <malloc+0x540>
     aae:	316040ef          	jal	4dc4 <unlink>
     ab2:	04054c63          	bltz	a0,b0a <writebig+0x14c>
}
     ab6:	70e2                	ld	ra,56(sp)
     ab8:	7442                	ld	s0,48(sp)
     aba:	74a2                	ld	s1,40(sp)
     abc:	7902                	ld	s2,32(sp)
     abe:	69e2                	ld	s3,24(sp)
     ac0:	6a42                	ld	s4,16(sp)
     ac2:	6aa2                	ld	s5,8(sp)
     ac4:	6121                	addi	sp,sp,64
     ac6:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     ac8:	8626                	mv	a2,s1
     aca:	85d6                	mv	a1,s5
     acc:	00005517          	auipc	a0,0x5
     ad0:	d3450513          	addi	a0,a0,-716 # 5800 <malloc+0x5b0>
     ad4:	6c8040ef          	jal	519c <printf>
        exit(1);
     ad8:	4505                	li	a0,1
     ada:	29a040ef          	jal	4d74 <exit>
      printf("%s: read failed %d\n", s, i);
     ade:	862a                	mv	a2,a0
     ae0:	85d6                	mv	a1,s5
     ae2:	00005517          	auipc	a0,0x5
     ae6:	d4650513          	addi	a0,a0,-698 # 5828 <malloc+0x5d8>
     aea:	6b2040ef          	jal	519c <printf>
      exit(1);
     aee:	4505                	li	a0,1
     af0:	284040ef          	jal	4d74 <exit>
      printf("%s: read content of block %d is %d\n", s,
     af4:	8626                	mv	a2,s1
     af6:	85d6                	mv	a1,s5
     af8:	00005517          	auipc	a0,0x5
     afc:	d4850513          	addi	a0,a0,-696 # 5840 <malloc+0x5f0>
     b00:	69c040ef          	jal	519c <printf>
      exit(1);
     b04:	4505                	li	a0,1
     b06:	26e040ef          	jal	4d74 <exit>
    printf("%s: unlink big failed\n", s);
     b0a:	85d6                	mv	a1,s5
     b0c:	00005517          	auipc	a0,0x5
     b10:	d5c50513          	addi	a0,a0,-676 # 5868 <malloc+0x618>
     b14:	688040ef          	jal	519c <printf>
    exit(1);
     b18:	4505                	li	a0,1
     b1a:	25a040ef          	jal	4d74 <exit>

0000000000000b1e <unlinkread>:
{
     b1e:	7179                	addi	sp,sp,-48
     b20:	f406                	sd	ra,40(sp)
     b22:	f022                	sd	s0,32(sp)
     b24:	ec26                	sd	s1,24(sp)
     b26:	e84a                	sd	s2,16(sp)
     b28:	e44e                	sd	s3,8(sp)
     b2a:	1800                	addi	s0,sp,48
     b2c:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b2e:	20200593          	li	a1,514
     b32:	00005517          	auipc	a0,0x5
     b36:	d4e50513          	addi	a0,a0,-690 # 5880 <malloc+0x630>
     b3a:	27a040ef          	jal	4db4 <open>
  if(fd < 0){
     b3e:	0a054f63          	bltz	a0,bfc <unlinkread+0xde>
     b42:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b44:	4615                	li	a2,5
     b46:	00005597          	auipc	a1,0x5
     b4a:	d6a58593          	addi	a1,a1,-662 # 58b0 <malloc+0x660>
     b4e:	246040ef          	jal	4d94 <write>
  close(fd);
     b52:	8526                	mv	a0,s1
     b54:	248040ef          	jal	4d9c <close>
  fd = open("unlinkread", O_RDWR);
     b58:	4589                	li	a1,2
     b5a:	00005517          	auipc	a0,0x5
     b5e:	d2650513          	addi	a0,a0,-730 # 5880 <malloc+0x630>
     b62:	252040ef          	jal	4db4 <open>
     b66:	84aa                	mv	s1,a0
  if(fd < 0){
     b68:	0a054463          	bltz	a0,c10 <unlinkread+0xf2>
  if(unlink("unlinkread") != 0){
     b6c:	00005517          	auipc	a0,0x5
     b70:	d1450513          	addi	a0,a0,-748 # 5880 <malloc+0x630>
     b74:	250040ef          	jal	4dc4 <unlink>
     b78:	e555                	bnez	a0,c24 <unlinkread+0x106>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     b7a:	20200593          	li	a1,514
     b7e:	00005517          	auipc	a0,0x5
     b82:	d0250513          	addi	a0,a0,-766 # 5880 <malloc+0x630>
     b86:	22e040ef          	jal	4db4 <open>
     b8a:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     b8c:	460d                	li	a2,3
     b8e:	00005597          	auipc	a1,0x5
     b92:	d6a58593          	addi	a1,a1,-662 # 58f8 <malloc+0x6a8>
     b96:	1fe040ef          	jal	4d94 <write>
  close(fd1);
     b9a:	854a                	mv	a0,s2
     b9c:	200040ef          	jal	4d9c <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     ba0:	660d                	lui	a2,0x3
     ba2:	0000c597          	auipc	a1,0xc
     ba6:	11658593          	addi	a1,a1,278 # ccb8 <buf>
     baa:	8526                	mv	a0,s1
     bac:	1e0040ef          	jal	4d8c <read>
     bb0:	4795                	li	a5,5
     bb2:	08f51363          	bne	a0,a5,c38 <unlinkread+0x11a>
  if(buf[0] != 'h'){
     bb6:	0000c717          	auipc	a4,0xc
     bba:	10274703          	lbu	a4,258(a4) # ccb8 <buf>
     bbe:	06800793          	li	a5,104
     bc2:	08f71563          	bne	a4,a5,c4c <unlinkread+0x12e>
  if(write(fd, buf, 10) != 10){
     bc6:	4629                	li	a2,10
     bc8:	0000c597          	auipc	a1,0xc
     bcc:	0f058593          	addi	a1,a1,240 # ccb8 <buf>
     bd0:	8526                	mv	a0,s1
     bd2:	1c2040ef          	jal	4d94 <write>
     bd6:	47a9                	li	a5,10
     bd8:	08f51463          	bne	a0,a5,c60 <unlinkread+0x142>
  close(fd);
     bdc:	8526                	mv	a0,s1
     bde:	1be040ef          	jal	4d9c <close>
  unlink("unlinkread");
     be2:	00005517          	auipc	a0,0x5
     be6:	c9e50513          	addi	a0,a0,-866 # 5880 <malloc+0x630>
     bea:	1da040ef          	jal	4dc4 <unlink>
}
     bee:	70a2                	ld	ra,40(sp)
     bf0:	7402                	ld	s0,32(sp)
     bf2:	64e2                	ld	s1,24(sp)
     bf4:	6942                	ld	s2,16(sp)
     bf6:	69a2                	ld	s3,8(sp)
     bf8:	6145                	addi	sp,sp,48
     bfa:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     bfc:	85ce                	mv	a1,s3
     bfe:	00005517          	auipc	a0,0x5
     c02:	c9250513          	addi	a0,a0,-878 # 5890 <malloc+0x640>
     c06:	596040ef          	jal	519c <printf>
    exit(1);
     c0a:	4505                	li	a0,1
     c0c:	168040ef          	jal	4d74 <exit>
    printf("%s: open unlinkread failed\n", s);
     c10:	85ce                	mv	a1,s3
     c12:	00005517          	auipc	a0,0x5
     c16:	ca650513          	addi	a0,a0,-858 # 58b8 <malloc+0x668>
     c1a:	582040ef          	jal	519c <printf>
    exit(1);
     c1e:	4505                	li	a0,1
     c20:	154040ef          	jal	4d74 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     c24:	85ce                	mv	a1,s3
     c26:	00005517          	auipc	a0,0x5
     c2a:	cb250513          	addi	a0,a0,-846 # 58d8 <malloc+0x688>
     c2e:	56e040ef          	jal	519c <printf>
    exit(1);
     c32:	4505                	li	a0,1
     c34:	140040ef          	jal	4d74 <exit>
    printf("%s: unlinkread read failed", s);
     c38:	85ce                	mv	a1,s3
     c3a:	00005517          	auipc	a0,0x5
     c3e:	cc650513          	addi	a0,a0,-826 # 5900 <malloc+0x6b0>
     c42:	55a040ef          	jal	519c <printf>
    exit(1);
     c46:	4505                	li	a0,1
     c48:	12c040ef          	jal	4d74 <exit>
    printf("%s: unlinkread wrong data\n", s);
     c4c:	85ce                	mv	a1,s3
     c4e:	00005517          	auipc	a0,0x5
     c52:	cd250513          	addi	a0,a0,-814 # 5920 <malloc+0x6d0>
     c56:	546040ef          	jal	519c <printf>
    exit(1);
     c5a:	4505                	li	a0,1
     c5c:	118040ef          	jal	4d74 <exit>
    printf("%s: unlinkread write failed\n", s);
     c60:	85ce                	mv	a1,s3
     c62:	00005517          	auipc	a0,0x5
     c66:	cde50513          	addi	a0,a0,-802 # 5940 <malloc+0x6f0>
     c6a:	532040ef          	jal	519c <printf>
    exit(1);
     c6e:	4505                	li	a0,1
     c70:	104040ef          	jal	4d74 <exit>

0000000000000c74 <linktest>:
{
     c74:	1101                	addi	sp,sp,-32
     c76:	ec06                	sd	ra,24(sp)
     c78:	e822                	sd	s0,16(sp)
     c7a:	e426                	sd	s1,8(sp)
     c7c:	e04a                	sd	s2,0(sp)
     c7e:	1000                	addi	s0,sp,32
     c80:	892a                	mv	s2,a0
  unlink("lf1");
     c82:	00005517          	auipc	a0,0x5
     c86:	cde50513          	addi	a0,a0,-802 # 5960 <malloc+0x710>
     c8a:	13a040ef          	jal	4dc4 <unlink>
  unlink("lf2");
     c8e:	00005517          	auipc	a0,0x5
     c92:	cda50513          	addi	a0,a0,-806 # 5968 <malloc+0x718>
     c96:	12e040ef          	jal	4dc4 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     c9a:	20200593          	li	a1,514
     c9e:	00005517          	auipc	a0,0x5
     ca2:	cc250513          	addi	a0,a0,-830 # 5960 <malloc+0x710>
     ca6:	10e040ef          	jal	4db4 <open>
  if(fd < 0){
     caa:	0c054f63          	bltz	a0,d88 <linktest+0x114>
     cae:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     cb0:	4615                	li	a2,5
     cb2:	00005597          	auipc	a1,0x5
     cb6:	bfe58593          	addi	a1,a1,-1026 # 58b0 <malloc+0x660>
     cba:	0da040ef          	jal	4d94 <write>
     cbe:	4795                	li	a5,5
     cc0:	0cf51e63          	bne	a0,a5,d9c <linktest+0x128>
  close(fd);
     cc4:	8526                	mv	a0,s1
     cc6:	0d6040ef          	jal	4d9c <close>
  if(link("lf1", "lf2") < 0){
     cca:	00005597          	auipc	a1,0x5
     cce:	c9e58593          	addi	a1,a1,-866 # 5968 <malloc+0x718>
     cd2:	00005517          	auipc	a0,0x5
     cd6:	c8e50513          	addi	a0,a0,-882 # 5960 <malloc+0x710>
     cda:	0fa040ef          	jal	4dd4 <link>
     cde:	0c054963          	bltz	a0,db0 <linktest+0x13c>
  unlink("lf1");
     ce2:	00005517          	auipc	a0,0x5
     ce6:	c7e50513          	addi	a0,a0,-898 # 5960 <malloc+0x710>
     cea:	0da040ef          	jal	4dc4 <unlink>
  if(open("lf1", 0) >= 0){
     cee:	4581                	li	a1,0
     cf0:	00005517          	auipc	a0,0x5
     cf4:	c7050513          	addi	a0,a0,-912 # 5960 <malloc+0x710>
     cf8:	0bc040ef          	jal	4db4 <open>
     cfc:	0c055463          	bgez	a0,dc4 <linktest+0x150>
  fd = open("lf2", 0);
     d00:	4581                	li	a1,0
     d02:	00005517          	auipc	a0,0x5
     d06:	c6650513          	addi	a0,a0,-922 # 5968 <malloc+0x718>
     d0a:	0aa040ef          	jal	4db4 <open>
     d0e:	84aa                	mv	s1,a0
  if(fd < 0){
     d10:	0c054463          	bltz	a0,dd8 <linktest+0x164>
  if(read(fd, buf, sizeof(buf)) != SZ){
     d14:	660d                	lui	a2,0x3
     d16:	0000c597          	auipc	a1,0xc
     d1a:	fa258593          	addi	a1,a1,-94 # ccb8 <buf>
     d1e:	06e040ef          	jal	4d8c <read>
     d22:	4795                	li	a5,5
     d24:	0cf51463          	bne	a0,a5,dec <linktest+0x178>
  close(fd);
     d28:	8526                	mv	a0,s1
     d2a:	072040ef          	jal	4d9c <close>
  if(link("lf2", "lf2") >= 0){
     d2e:	00005597          	auipc	a1,0x5
     d32:	c3a58593          	addi	a1,a1,-966 # 5968 <malloc+0x718>
     d36:	852e                	mv	a0,a1
     d38:	09c040ef          	jal	4dd4 <link>
     d3c:	0c055263          	bgez	a0,e00 <linktest+0x18c>
  unlink("lf2");
     d40:	00005517          	auipc	a0,0x5
     d44:	c2850513          	addi	a0,a0,-984 # 5968 <malloc+0x718>
     d48:	07c040ef          	jal	4dc4 <unlink>
  if(link("lf2", "lf1") >= 0){
     d4c:	00005597          	auipc	a1,0x5
     d50:	c1458593          	addi	a1,a1,-1004 # 5960 <malloc+0x710>
     d54:	00005517          	auipc	a0,0x5
     d58:	c1450513          	addi	a0,a0,-1004 # 5968 <malloc+0x718>
     d5c:	078040ef          	jal	4dd4 <link>
     d60:	0a055a63          	bgez	a0,e14 <linktest+0x1a0>
  if(link(".", "lf1") >= 0){
     d64:	00005597          	auipc	a1,0x5
     d68:	bfc58593          	addi	a1,a1,-1028 # 5960 <malloc+0x710>
     d6c:	00005517          	auipc	a0,0x5
     d70:	d0450513          	addi	a0,a0,-764 # 5a70 <malloc+0x820>
     d74:	060040ef          	jal	4dd4 <link>
     d78:	0a055863          	bgez	a0,e28 <linktest+0x1b4>
}
     d7c:	60e2                	ld	ra,24(sp)
     d7e:	6442                	ld	s0,16(sp)
     d80:	64a2                	ld	s1,8(sp)
     d82:	6902                	ld	s2,0(sp)
     d84:	6105                	addi	sp,sp,32
     d86:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     d88:	85ca                	mv	a1,s2
     d8a:	00005517          	auipc	a0,0x5
     d8e:	be650513          	addi	a0,a0,-1050 # 5970 <malloc+0x720>
     d92:	40a040ef          	jal	519c <printf>
    exit(1);
     d96:	4505                	li	a0,1
     d98:	7dd030ef          	jal	4d74 <exit>
    printf("%s: write lf1 failed\n", s);
     d9c:	85ca                	mv	a1,s2
     d9e:	00005517          	auipc	a0,0x5
     da2:	bea50513          	addi	a0,a0,-1046 # 5988 <malloc+0x738>
     da6:	3f6040ef          	jal	519c <printf>
    exit(1);
     daa:	4505                	li	a0,1
     dac:	7c9030ef          	jal	4d74 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     db0:	85ca                	mv	a1,s2
     db2:	00005517          	auipc	a0,0x5
     db6:	bee50513          	addi	a0,a0,-1042 # 59a0 <malloc+0x750>
     dba:	3e2040ef          	jal	519c <printf>
    exit(1);
     dbe:	4505                	li	a0,1
     dc0:	7b5030ef          	jal	4d74 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     dc4:	85ca                	mv	a1,s2
     dc6:	00005517          	auipc	a0,0x5
     dca:	bfa50513          	addi	a0,a0,-1030 # 59c0 <malloc+0x770>
     dce:	3ce040ef          	jal	519c <printf>
    exit(1);
     dd2:	4505                	li	a0,1
     dd4:	7a1030ef          	jal	4d74 <exit>
    printf("%s: open lf2 failed\n", s);
     dd8:	85ca                	mv	a1,s2
     dda:	00005517          	auipc	a0,0x5
     dde:	c1650513          	addi	a0,a0,-1002 # 59f0 <malloc+0x7a0>
     de2:	3ba040ef          	jal	519c <printf>
    exit(1);
     de6:	4505                	li	a0,1
     de8:	78d030ef          	jal	4d74 <exit>
    printf("%s: read lf2 failed\n", s);
     dec:	85ca                	mv	a1,s2
     dee:	00005517          	auipc	a0,0x5
     df2:	c1a50513          	addi	a0,a0,-998 # 5a08 <malloc+0x7b8>
     df6:	3a6040ef          	jal	519c <printf>
    exit(1);
     dfa:	4505                	li	a0,1
     dfc:	779030ef          	jal	4d74 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     e00:	85ca                	mv	a1,s2
     e02:	00005517          	auipc	a0,0x5
     e06:	c1e50513          	addi	a0,a0,-994 # 5a20 <malloc+0x7d0>
     e0a:	392040ef          	jal	519c <printf>
    exit(1);
     e0e:	4505                	li	a0,1
     e10:	765030ef          	jal	4d74 <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
     e14:	85ca                	mv	a1,s2
     e16:	00005517          	auipc	a0,0x5
     e1a:	c3250513          	addi	a0,a0,-974 # 5a48 <malloc+0x7f8>
     e1e:	37e040ef          	jal	519c <printf>
    exit(1);
     e22:	4505                	li	a0,1
     e24:	751030ef          	jal	4d74 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     e28:	85ca                	mv	a1,s2
     e2a:	00005517          	auipc	a0,0x5
     e2e:	c4e50513          	addi	a0,a0,-946 # 5a78 <malloc+0x828>
     e32:	36a040ef          	jal	519c <printf>
    exit(1);
     e36:	4505                	li	a0,1
     e38:	73d030ef          	jal	4d74 <exit>

0000000000000e3c <validatetest>:
{
     e3c:	7139                	addi	sp,sp,-64
     e3e:	fc06                	sd	ra,56(sp)
     e40:	f822                	sd	s0,48(sp)
     e42:	f426                	sd	s1,40(sp)
     e44:	f04a                	sd	s2,32(sp)
     e46:	ec4e                	sd	s3,24(sp)
     e48:	e852                	sd	s4,16(sp)
     e4a:	e456                	sd	s5,8(sp)
     e4c:	e05a                	sd	s6,0(sp)
     e4e:	0080                	addi	s0,sp,64
     e50:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
     e52:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
     e54:	00005997          	auipc	s3,0x5
     e58:	c4498993          	addi	s3,s3,-956 # 5a98 <malloc+0x848>
     e5c:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
     e5e:	6a85                	lui	s5,0x1
     e60:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
     e64:	85a6                	mv	a1,s1
     e66:	854e                	mv	a0,s3
     e68:	76d030ef          	jal	4dd4 <link>
     e6c:	01251f63          	bne	a0,s2,e8a <validatetest+0x4e>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
     e70:	94d6                	add	s1,s1,s5
     e72:	ff4499e3          	bne	s1,s4,e64 <validatetest+0x28>
}
     e76:	70e2                	ld	ra,56(sp)
     e78:	7442                	ld	s0,48(sp)
     e7a:	74a2                	ld	s1,40(sp)
     e7c:	7902                	ld	s2,32(sp)
     e7e:	69e2                	ld	s3,24(sp)
     e80:	6a42                	ld	s4,16(sp)
     e82:	6aa2                	ld	s5,8(sp)
     e84:	6b02                	ld	s6,0(sp)
     e86:	6121                	addi	sp,sp,64
     e88:	8082                	ret
      printf("%s: link should not succeed\n", s);
     e8a:	85da                	mv	a1,s6
     e8c:	00005517          	auipc	a0,0x5
     e90:	c1c50513          	addi	a0,a0,-996 # 5aa8 <malloc+0x858>
     e94:	308040ef          	jal	519c <printf>
      exit(1);
     e98:	4505                	li	a0,1
     e9a:	6db030ef          	jal	4d74 <exit>

0000000000000e9e <bigdir>:
{
     e9e:	715d                	addi	sp,sp,-80
     ea0:	e486                	sd	ra,72(sp)
     ea2:	e0a2                	sd	s0,64(sp)
     ea4:	fc26                	sd	s1,56(sp)
     ea6:	f84a                	sd	s2,48(sp)
     ea8:	f44e                	sd	s3,40(sp)
     eaa:	f052                	sd	s4,32(sp)
     eac:	ec56                	sd	s5,24(sp)
     eae:	e85a                	sd	s6,16(sp)
     eb0:	0880                	addi	s0,sp,80
     eb2:	89aa                	mv	s3,a0
  unlink("bd");
     eb4:	00005517          	auipc	a0,0x5
     eb8:	c1450513          	addi	a0,a0,-1004 # 5ac8 <malloc+0x878>
     ebc:	709030ef          	jal	4dc4 <unlink>
  fd = open("bd", O_CREATE);
     ec0:	20000593          	li	a1,512
     ec4:	00005517          	auipc	a0,0x5
     ec8:	c0450513          	addi	a0,a0,-1020 # 5ac8 <malloc+0x878>
     ecc:	6e9030ef          	jal	4db4 <open>
  if(fd < 0){
     ed0:	0c054163          	bltz	a0,f92 <bigdir+0xf4>
  close(fd);
     ed4:	6c9030ef          	jal	4d9c <close>
  for(i = 0; i < N; i++){
     ed8:	4901                	li	s2,0
    name[0] = 'x';
     eda:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
     ede:	00005a17          	auipc	s4,0x5
     ee2:	beaa0a13          	addi	s4,s4,-1046 # 5ac8 <malloc+0x878>
  for(i = 0; i < N; i++){
     ee6:	1f400b13          	li	s6,500
    name[0] = 'x';
     eea:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     eee:	41f9571b          	sraiw	a4,s2,0x1f
     ef2:	01a7571b          	srliw	a4,a4,0x1a
     ef6:	012707bb          	addw	a5,a4,s2
     efa:	4067d69b          	sraiw	a3,a5,0x6
     efe:	0306869b          	addiw	a3,a3,48
     f02:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     f06:	03f7f793          	andi	a5,a5,63
     f0a:	9f99                	subw	a5,a5,a4
     f0c:	0307879b          	addiw	a5,a5,48
     f10:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     f14:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
     f18:	fb040593          	addi	a1,s0,-80
     f1c:	8552                	mv	a0,s4
     f1e:	6b7030ef          	jal	4dd4 <link>
     f22:	84aa                	mv	s1,a0
     f24:	e149                	bnez	a0,fa6 <bigdir+0x108>
  for(i = 0; i < N; i++){
     f26:	2905                	addiw	s2,s2,1
     f28:	fd6911e3          	bne	s2,s6,eea <bigdir+0x4c>
  unlink("bd");
     f2c:	00005517          	auipc	a0,0x5
     f30:	b9c50513          	addi	a0,a0,-1124 # 5ac8 <malloc+0x878>
     f34:	691030ef          	jal	4dc4 <unlink>
    name[0] = 'x';
     f38:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
     f3c:	1f400a13          	li	s4,500
    name[0] = 'x';
     f40:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
     f44:	41f4d71b          	sraiw	a4,s1,0x1f
     f48:	01a7571b          	srliw	a4,a4,0x1a
     f4c:	009707bb          	addw	a5,a4,s1
     f50:	4067d69b          	sraiw	a3,a5,0x6
     f54:	0306869b          	addiw	a3,a3,48
     f58:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     f5c:	03f7f793          	andi	a5,a5,63
     f60:	9f99                	subw	a5,a5,a4
     f62:	0307879b          	addiw	a5,a5,48
     f66:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     f6a:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
     f6e:	fb040513          	addi	a0,s0,-80
     f72:	653030ef          	jal	4dc4 <unlink>
     f76:	e529                	bnez	a0,fc0 <bigdir+0x122>
  for(i = 0; i < N; i++){
     f78:	2485                	addiw	s1,s1,1
     f7a:	fd4493e3          	bne	s1,s4,f40 <bigdir+0xa2>
}
     f7e:	60a6                	ld	ra,72(sp)
     f80:	6406                	ld	s0,64(sp)
     f82:	74e2                	ld	s1,56(sp)
     f84:	7942                	ld	s2,48(sp)
     f86:	79a2                	ld	s3,40(sp)
     f88:	7a02                	ld	s4,32(sp)
     f8a:	6ae2                	ld	s5,24(sp)
     f8c:	6b42                	ld	s6,16(sp)
     f8e:	6161                	addi	sp,sp,80
     f90:	8082                	ret
    printf("%s: bigdir create failed\n", s);
     f92:	85ce                	mv	a1,s3
     f94:	00005517          	auipc	a0,0x5
     f98:	b3c50513          	addi	a0,a0,-1220 # 5ad0 <malloc+0x880>
     f9c:	200040ef          	jal	519c <printf>
    exit(1);
     fa0:	4505                	li	a0,1
     fa2:	5d3030ef          	jal	4d74 <exit>
      printf("%s: bigdir i=%d link(bd, %s) failed\n", s, i, name);
     fa6:	fb040693          	addi	a3,s0,-80
     faa:	864a                	mv	a2,s2
     fac:	85ce                	mv	a1,s3
     fae:	00005517          	auipc	a0,0x5
     fb2:	b4250513          	addi	a0,a0,-1214 # 5af0 <malloc+0x8a0>
     fb6:	1e6040ef          	jal	519c <printf>
      exit(1);
     fba:	4505                	li	a0,1
     fbc:	5b9030ef          	jal	4d74 <exit>
      printf("%s: bigdir unlink failed", s);
     fc0:	85ce                	mv	a1,s3
     fc2:	00005517          	auipc	a0,0x5
     fc6:	b5650513          	addi	a0,a0,-1194 # 5b18 <malloc+0x8c8>
     fca:	1d2040ef          	jal	519c <printf>
      exit(1);
     fce:	4505                	li	a0,1
     fd0:	5a5030ef          	jal	4d74 <exit>

0000000000000fd4 <pgbug>:
{
     fd4:	7179                	addi	sp,sp,-48
     fd6:	f406                	sd	ra,40(sp)
     fd8:	f022                	sd	s0,32(sp)
     fda:	ec26                	sd	s1,24(sp)
     fdc:	1800                	addi	s0,sp,48
  argv[0] = 0;
     fde:	fc043c23          	sd	zero,-40(s0)
  exec(big, argv);
     fe2:	00008497          	auipc	s1,0x8
     fe6:	01e48493          	addi	s1,s1,30 # 9000 <big>
     fea:	fd840593          	addi	a1,s0,-40
     fee:	6088                	ld	a0,0(s1)
     ff0:	5bd030ef          	jal	4dac <exec>
  pipe(big);
     ff4:	6088                	ld	a0,0(s1)
     ff6:	58f030ef          	jal	4d84 <pipe>
  exit(0);
     ffa:	4501                	li	a0,0
     ffc:	579030ef          	jal	4d74 <exit>

0000000000001000 <badarg>:
{
    1000:	7139                	addi	sp,sp,-64
    1002:	fc06                	sd	ra,56(sp)
    1004:	f822                	sd	s0,48(sp)
    1006:	f426                	sd	s1,40(sp)
    1008:	f04a                	sd	s2,32(sp)
    100a:	ec4e                	sd	s3,24(sp)
    100c:	0080                	addi	s0,sp,64
    100e:	64b1                	lui	s1,0xc
    1010:	35048493          	addi	s1,s1,848 # c350 <uninit+0x1da8>
    argv[0] = (char*)0xffffffff;
    1014:	597d                	li	s2,-1
    1016:	02095913          	srli	s2,s2,0x20
    exec("echo", argv);
    101a:	00004997          	auipc	s3,0x4
    101e:	36e98993          	addi	s3,s3,878 # 5388 <malloc+0x138>
    argv[0] = (char*)0xffffffff;
    1022:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1026:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    102a:	fc040593          	addi	a1,s0,-64
    102e:	854e                	mv	a0,s3
    1030:	57d030ef          	jal	4dac <exec>
  for(int i = 0; i < 50000; i++){
    1034:	34fd                	addiw	s1,s1,-1
    1036:	f4f5                	bnez	s1,1022 <badarg+0x22>
  exit(0);
    1038:	4501                	li	a0,0
    103a:	53b030ef          	jal	4d74 <exit>

000000000000103e <copyinstr2>:
{
    103e:	7155                	addi	sp,sp,-208
    1040:	e586                	sd	ra,200(sp)
    1042:	e1a2                	sd	s0,192(sp)
    1044:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    1046:	f6840793          	addi	a5,s0,-152
    104a:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    104e:	07800713          	li	a4,120
    1052:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    1056:	0785                	addi	a5,a5,1
    1058:	fed79de3          	bne	a5,a3,1052 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    105c:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    1060:	f6840513          	addi	a0,s0,-152
    1064:	561030ef          	jal	4dc4 <unlink>
  if(ret != -1){
    1068:	57fd                	li	a5,-1
    106a:	0cf51263          	bne	a0,a5,112e <copyinstr2+0xf0>
  int fd = open(b, O_CREATE | O_WRONLY);
    106e:	20100593          	li	a1,513
    1072:	f6840513          	addi	a0,s0,-152
    1076:	53f030ef          	jal	4db4 <open>
  if(fd != -1){
    107a:	57fd                	li	a5,-1
    107c:	0cf51563          	bne	a0,a5,1146 <copyinstr2+0x108>
  ret = link(b, b);
    1080:	f6840593          	addi	a1,s0,-152
    1084:	852e                	mv	a0,a1
    1086:	54f030ef          	jal	4dd4 <link>
  if(ret != -1){
    108a:	57fd                	li	a5,-1
    108c:	0cf51963          	bne	a0,a5,115e <copyinstr2+0x120>
  char *args[] = { "xx", 0 };
    1090:	00006797          	auipc	a5,0x6
    1094:	bd878793          	addi	a5,a5,-1064 # 6c68 <malloc+0x1a18>
    1098:	f4f43c23          	sd	a5,-168(s0)
    109c:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    10a0:	f5840593          	addi	a1,s0,-168
    10a4:	f6840513          	addi	a0,s0,-152
    10a8:	505030ef          	jal	4dac <exec>
  if(ret != -1){
    10ac:	57fd                	li	a5,-1
    10ae:	0cf51563          	bne	a0,a5,1178 <copyinstr2+0x13a>
  int pid = fork();
    10b2:	4bb030ef          	jal	4d6c <fork>
  if(pid < 0){
    10b6:	0c054d63          	bltz	a0,1190 <copyinstr2+0x152>
  if(pid == 0){
    10ba:	0e051863          	bnez	a0,11aa <copyinstr2+0x16c>
    10be:	00008797          	auipc	a5,0x8
    10c2:	4e278793          	addi	a5,a5,1250 # 95a0 <big.0>
    10c6:	00009697          	auipc	a3,0x9
    10ca:	4da68693          	addi	a3,a3,1242 # a5a0 <big.0+0x1000>
      big[i] = 'x';
    10ce:	07800713          	li	a4,120
    10d2:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    10d6:	0785                	addi	a5,a5,1
    10d8:	fed79de3          	bne	a5,a3,10d2 <copyinstr2+0x94>
    big[PGSIZE] = '\0';
    10dc:	00009797          	auipc	a5,0x9
    10e0:	4c078223          	sb	zero,1220(a5) # a5a0 <big.0+0x1000>
    char *args2[] = { big, big, big, 0 };
    10e4:	00006797          	auipc	a5,0x6
    10e8:	7ec78793          	addi	a5,a5,2028 # 78d0 <malloc+0x2680>
    10ec:	6fb0                	ld	a2,88(a5)
    10ee:	73b4                	ld	a3,96(a5)
    10f0:	77b8                	ld	a4,104(a5)
    10f2:	7bbc                	ld	a5,112(a5)
    10f4:	f2c43823          	sd	a2,-208(s0)
    10f8:	f2d43c23          	sd	a3,-200(s0)
    10fc:	f4e43023          	sd	a4,-192(s0)
    1100:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    1104:	f3040593          	addi	a1,s0,-208
    1108:	00004517          	auipc	a0,0x4
    110c:	28050513          	addi	a0,a0,640 # 5388 <malloc+0x138>
    1110:	49d030ef          	jal	4dac <exec>
    if(ret != -1){
    1114:	57fd                	li	a5,-1
    1116:	08f50663          	beq	a0,a5,11a2 <copyinstr2+0x164>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    111a:	55fd                	li	a1,-1
    111c:	00005517          	auipc	a0,0x5
    1120:	aa450513          	addi	a0,a0,-1372 # 5bc0 <malloc+0x970>
    1124:	078040ef          	jal	519c <printf>
      exit(1);
    1128:	4505                	li	a0,1
    112a:	44b030ef          	jal	4d74 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    112e:	862a                	mv	a2,a0
    1130:	f6840593          	addi	a1,s0,-152
    1134:	00005517          	auipc	a0,0x5
    1138:	a0450513          	addi	a0,a0,-1532 # 5b38 <malloc+0x8e8>
    113c:	060040ef          	jal	519c <printf>
    exit(1);
    1140:	4505                	li	a0,1
    1142:	433030ef          	jal	4d74 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1146:	862a                	mv	a2,a0
    1148:	f6840593          	addi	a1,s0,-152
    114c:	00005517          	auipc	a0,0x5
    1150:	a0c50513          	addi	a0,a0,-1524 # 5b58 <malloc+0x908>
    1154:	048040ef          	jal	519c <printf>
    exit(1);
    1158:	4505                	li	a0,1
    115a:	41b030ef          	jal	4d74 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    115e:	86aa                	mv	a3,a0
    1160:	f6840613          	addi	a2,s0,-152
    1164:	85b2                	mv	a1,a2
    1166:	00005517          	auipc	a0,0x5
    116a:	a1250513          	addi	a0,a0,-1518 # 5b78 <malloc+0x928>
    116e:	02e040ef          	jal	519c <printf>
    exit(1);
    1172:	4505                	li	a0,1
    1174:	401030ef          	jal	4d74 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1178:	567d                	li	a2,-1
    117a:	f6840593          	addi	a1,s0,-152
    117e:	00005517          	auipc	a0,0x5
    1182:	a2250513          	addi	a0,a0,-1502 # 5ba0 <malloc+0x950>
    1186:	016040ef          	jal	519c <printf>
    exit(1);
    118a:	4505                	li	a0,1
    118c:	3e9030ef          	jal	4d74 <exit>
    printf("fork failed\n");
    1190:	00006517          	auipc	a0,0x6
    1194:	03050513          	addi	a0,a0,48 # 71c0 <malloc+0x1f70>
    1198:	004040ef          	jal	519c <printf>
    exit(1);
    119c:	4505                	li	a0,1
    119e:	3d7030ef          	jal	4d74 <exit>
    exit(747); // OK
    11a2:	2eb00513          	li	a0,747
    11a6:	3cf030ef          	jal	4d74 <exit>
  int st = 0;
    11aa:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    11ae:	f5440513          	addi	a0,s0,-172
    11b2:	3cb030ef          	jal	4d7c <wait>
  if(st != 747){
    11b6:	f5442703          	lw	a4,-172(s0)
    11ba:	2eb00793          	li	a5,747
    11be:	00f71663          	bne	a4,a5,11ca <copyinstr2+0x18c>
}
    11c2:	60ae                	ld	ra,200(sp)
    11c4:	640e                	ld	s0,192(sp)
    11c6:	6169                	addi	sp,sp,208
    11c8:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    11ca:	00005517          	auipc	a0,0x5
    11ce:	a1e50513          	addi	a0,a0,-1506 # 5be8 <malloc+0x998>
    11d2:	7cb030ef          	jal	519c <printf>
    exit(1);
    11d6:	4505                	li	a0,1
    11d8:	39d030ef          	jal	4d74 <exit>

00000000000011dc <truncate3>:
{
    11dc:	7159                	addi	sp,sp,-112
    11de:	f486                	sd	ra,104(sp)
    11e0:	f0a2                	sd	s0,96(sp)
    11e2:	e8ca                	sd	s2,80(sp)
    11e4:	1880                	addi	s0,sp,112
    11e6:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    11e8:	60100593          	li	a1,1537
    11ec:	00004517          	auipc	a0,0x4
    11f0:	1f450513          	addi	a0,a0,500 # 53e0 <malloc+0x190>
    11f4:	3c1030ef          	jal	4db4 <open>
    11f8:	3a5030ef          	jal	4d9c <close>
  pid = fork();
    11fc:	371030ef          	jal	4d6c <fork>
  if(pid < 0){
    1200:	06054663          	bltz	a0,126c <truncate3+0x90>
  if(pid == 0){
    1204:	e55d                	bnez	a0,12b2 <truncate3+0xd6>
    1206:	eca6                	sd	s1,88(sp)
    1208:	e4ce                	sd	s3,72(sp)
    120a:	e0d2                	sd	s4,64(sp)
    120c:	fc56                	sd	s5,56(sp)
    120e:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    1212:	00004a17          	auipc	s4,0x4
    1216:	1cea0a13          	addi	s4,s4,462 # 53e0 <malloc+0x190>
      int n = write(fd, "1234567890", 10);
    121a:	00005a97          	auipc	s5,0x5
    121e:	a2ea8a93          	addi	s5,s5,-1490 # 5c48 <malloc+0x9f8>
      int fd = open("truncfile", O_WRONLY);
    1222:	4585                	li	a1,1
    1224:	8552                	mv	a0,s4
    1226:	38f030ef          	jal	4db4 <open>
    122a:	84aa                	mv	s1,a0
      if(fd < 0){
    122c:	04054e63          	bltz	a0,1288 <truncate3+0xac>
      int n = write(fd, "1234567890", 10);
    1230:	4629                	li	a2,10
    1232:	85d6                	mv	a1,s5
    1234:	361030ef          	jal	4d94 <write>
      if(n != 10){
    1238:	47a9                	li	a5,10
    123a:	06f51163          	bne	a0,a5,129c <truncate3+0xc0>
      close(fd);
    123e:	8526                	mv	a0,s1
    1240:	35d030ef          	jal	4d9c <close>
      fd = open("truncfile", O_RDONLY);
    1244:	4581                	li	a1,0
    1246:	8552                	mv	a0,s4
    1248:	36d030ef          	jal	4db4 <open>
    124c:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    124e:	02000613          	li	a2,32
    1252:	f9840593          	addi	a1,s0,-104
    1256:	337030ef          	jal	4d8c <read>
      close(fd);
    125a:	8526                	mv	a0,s1
    125c:	341030ef          	jal	4d9c <close>
    for(int i = 0; i < 100; i++){
    1260:	39fd                	addiw	s3,s3,-1
    1262:	fc0990e3          	bnez	s3,1222 <truncate3+0x46>
    exit(0);
    1266:	4501                	li	a0,0
    1268:	30d030ef          	jal	4d74 <exit>
    126c:	eca6                	sd	s1,88(sp)
    126e:	e4ce                	sd	s3,72(sp)
    1270:	e0d2                	sd	s4,64(sp)
    1272:	fc56                	sd	s5,56(sp)
    printf("%s: fork failed\n", s);
    1274:	85ca                	mv	a1,s2
    1276:	00005517          	auipc	a0,0x5
    127a:	9a250513          	addi	a0,a0,-1630 # 5c18 <malloc+0x9c8>
    127e:	71f030ef          	jal	519c <printf>
    exit(1);
    1282:	4505                	li	a0,1
    1284:	2f1030ef          	jal	4d74 <exit>
        printf("%s: open failed\n", s);
    1288:	85ca                	mv	a1,s2
    128a:	00005517          	auipc	a0,0x5
    128e:	9a650513          	addi	a0,a0,-1626 # 5c30 <malloc+0x9e0>
    1292:	70b030ef          	jal	519c <printf>
        exit(1);
    1296:	4505                	li	a0,1
    1298:	2dd030ef          	jal	4d74 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    129c:	862a                	mv	a2,a0
    129e:	85ca                	mv	a1,s2
    12a0:	00005517          	auipc	a0,0x5
    12a4:	9b850513          	addi	a0,a0,-1608 # 5c58 <malloc+0xa08>
    12a8:	6f5030ef          	jal	519c <printf>
        exit(1);
    12ac:	4505                	li	a0,1
    12ae:	2c7030ef          	jal	4d74 <exit>
    12b2:	eca6                	sd	s1,88(sp)
    12b4:	e4ce                	sd	s3,72(sp)
    12b6:	e0d2                	sd	s4,64(sp)
    12b8:	fc56                	sd	s5,56(sp)
    12ba:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    12be:	00004a17          	auipc	s4,0x4
    12c2:	122a0a13          	addi	s4,s4,290 # 53e0 <malloc+0x190>
    int n = write(fd, "xxx", 3);
    12c6:	00005a97          	auipc	s5,0x5
    12ca:	9b2a8a93          	addi	s5,s5,-1614 # 5c78 <malloc+0xa28>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    12ce:	60100593          	li	a1,1537
    12d2:	8552                	mv	a0,s4
    12d4:	2e1030ef          	jal	4db4 <open>
    12d8:	84aa                	mv	s1,a0
    if(fd < 0){
    12da:	02054d63          	bltz	a0,1314 <truncate3+0x138>
    int n = write(fd, "xxx", 3);
    12de:	460d                	li	a2,3
    12e0:	85d6                	mv	a1,s5
    12e2:	2b3030ef          	jal	4d94 <write>
    if(n != 3){
    12e6:	478d                	li	a5,3
    12e8:	04f51063          	bne	a0,a5,1328 <truncate3+0x14c>
    close(fd);
    12ec:	8526                	mv	a0,s1
    12ee:	2af030ef          	jal	4d9c <close>
  for(int i = 0; i < 150; i++){
    12f2:	39fd                	addiw	s3,s3,-1
    12f4:	fc099de3          	bnez	s3,12ce <truncate3+0xf2>
  wait(&xstatus);
    12f8:	fbc40513          	addi	a0,s0,-68
    12fc:	281030ef          	jal	4d7c <wait>
  unlink("truncfile");
    1300:	00004517          	auipc	a0,0x4
    1304:	0e050513          	addi	a0,a0,224 # 53e0 <malloc+0x190>
    1308:	2bd030ef          	jal	4dc4 <unlink>
  exit(xstatus);
    130c:	fbc42503          	lw	a0,-68(s0)
    1310:	265030ef          	jal	4d74 <exit>
      printf("%s: open failed\n", s);
    1314:	85ca                	mv	a1,s2
    1316:	00005517          	auipc	a0,0x5
    131a:	91a50513          	addi	a0,a0,-1766 # 5c30 <malloc+0x9e0>
    131e:	67f030ef          	jal	519c <printf>
      exit(1);
    1322:	4505                	li	a0,1
    1324:	251030ef          	jal	4d74 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1328:	862a                	mv	a2,a0
    132a:	85ca                	mv	a1,s2
    132c:	00005517          	auipc	a0,0x5
    1330:	95450513          	addi	a0,a0,-1708 # 5c80 <malloc+0xa30>
    1334:	669030ef          	jal	519c <printf>
      exit(1);
    1338:	4505                	li	a0,1
    133a:	23b030ef          	jal	4d74 <exit>

000000000000133e <exectest>:
{
    133e:	715d                	addi	sp,sp,-80
    1340:	e486                	sd	ra,72(sp)
    1342:	e0a2                	sd	s0,64(sp)
    1344:	f84a                	sd	s2,48(sp)
    1346:	0880                	addi	s0,sp,80
    1348:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    134a:	00004797          	auipc	a5,0x4
    134e:	03e78793          	addi	a5,a5,62 # 5388 <malloc+0x138>
    1352:	fcf43023          	sd	a5,-64(s0)
    1356:	00005797          	auipc	a5,0x5
    135a:	94a78793          	addi	a5,a5,-1718 # 5ca0 <malloc+0xa50>
    135e:	fcf43423          	sd	a5,-56(s0)
    1362:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    1366:	00005517          	auipc	a0,0x5
    136a:	94250513          	addi	a0,a0,-1726 # 5ca8 <malloc+0xa58>
    136e:	257030ef          	jal	4dc4 <unlink>
  pid = fork();
    1372:	1fb030ef          	jal	4d6c <fork>
  if(pid < 0) {
    1376:	02054f63          	bltz	a0,13b4 <exectest+0x76>
    137a:	fc26                	sd	s1,56(sp)
    137c:	84aa                	mv	s1,a0
  if(pid == 0) {
    137e:	e935                	bnez	a0,13f2 <exectest+0xb4>
    close(1);
    1380:	4505                	li	a0,1
    1382:	21b030ef          	jal	4d9c <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    1386:	20100593          	li	a1,513
    138a:	00005517          	auipc	a0,0x5
    138e:	91e50513          	addi	a0,a0,-1762 # 5ca8 <malloc+0xa58>
    1392:	223030ef          	jal	4db4 <open>
    if(fd < 0) {
    1396:	02054a63          	bltz	a0,13ca <exectest+0x8c>
    if(fd != 1) {
    139a:	4785                	li	a5,1
    139c:	04f50163          	beq	a0,a5,13de <exectest+0xa0>
      printf("%s: wrong fd\n", s);
    13a0:	85ca                	mv	a1,s2
    13a2:	00005517          	auipc	a0,0x5
    13a6:	92650513          	addi	a0,a0,-1754 # 5cc8 <malloc+0xa78>
    13aa:	5f3030ef          	jal	519c <printf>
      exit(1);
    13ae:	4505                	li	a0,1
    13b0:	1c5030ef          	jal	4d74 <exit>
    13b4:	fc26                	sd	s1,56(sp)
     printf("%s: fork failed\n", s);
    13b6:	85ca                	mv	a1,s2
    13b8:	00005517          	auipc	a0,0x5
    13bc:	86050513          	addi	a0,a0,-1952 # 5c18 <malloc+0x9c8>
    13c0:	5dd030ef          	jal	519c <printf>
     exit(1);
    13c4:	4505                	li	a0,1
    13c6:	1af030ef          	jal	4d74 <exit>
      printf("%s: create failed\n", s);
    13ca:	85ca                	mv	a1,s2
    13cc:	00005517          	auipc	a0,0x5
    13d0:	8e450513          	addi	a0,a0,-1820 # 5cb0 <malloc+0xa60>
    13d4:	5c9030ef          	jal	519c <printf>
      exit(1);
    13d8:	4505                	li	a0,1
    13da:	19b030ef          	jal	4d74 <exit>
    if(exec("echo", echoargv) < 0){
    13de:	fc040593          	addi	a1,s0,-64
    13e2:	00004517          	auipc	a0,0x4
    13e6:	fa650513          	addi	a0,a0,-90 # 5388 <malloc+0x138>
    13ea:	1c3030ef          	jal	4dac <exec>
    13ee:	00054d63          	bltz	a0,1408 <exectest+0xca>
  if (wait(&xstatus) != pid) {
    13f2:	fdc40513          	addi	a0,s0,-36
    13f6:	187030ef          	jal	4d7c <wait>
    13fa:	02951163          	bne	a0,s1,141c <exectest+0xde>
  if(xstatus != 0)
    13fe:	fdc42503          	lw	a0,-36(s0)
    1402:	c50d                	beqz	a0,142c <exectest+0xee>
    exit(xstatus);
    1404:	171030ef          	jal	4d74 <exit>
      printf("%s: exec echo failed\n", s);
    1408:	85ca                	mv	a1,s2
    140a:	00005517          	auipc	a0,0x5
    140e:	8ce50513          	addi	a0,a0,-1842 # 5cd8 <malloc+0xa88>
    1412:	58b030ef          	jal	519c <printf>
      exit(1);
    1416:	4505                	li	a0,1
    1418:	15d030ef          	jal	4d74 <exit>
    printf("%s: wait failed!\n", s);
    141c:	85ca                	mv	a1,s2
    141e:	00005517          	auipc	a0,0x5
    1422:	8d250513          	addi	a0,a0,-1838 # 5cf0 <malloc+0xaa0>
    1426:	577030ef          	jal	519c <printf>
    142a:	bfd1                	j	13fe <exectest+0xc0>
  fd = open("echo-ok", O_RDONLY);
    142c:	4581                	li	a1,0
    142e:	00005517          	auipc	a0,0x5
    1432:	87a50513          	addi	a0,a0,-1926 # 5ca8 <malloc+0xa58>
    1436:	17f030ef          	jal	4db4 <open>
  if(fd < 0) {
    143a:	02054463          	bltz	a0,1462 <exectest+0x124>
  if (read(fd, buf, 2) != 2) {
    143e:	4609                	li	a2,2
    1440:	fb840593          	addi	a1,s0,-72
    1444:	149030ef          	jal	4d8c <read>
    1448:	4789                	li	a5,2
    144a:	02f50663          	beq	a0,a5,1476 <exectest+0x138>
    printf("%s: read failed\n", s);
    144e:	85ca                	mv	a1,s2
    1450:	00004517          	auipc	a0,0x4
    1454:	30850513          	addi	a0,a0,776 # 5758 <malloc+0x508>
    1458:	545030ef          	jal	519c <printf>
    exit(1);
    145c:	4505                	li	a0,1
    145e:	117030ef          	jal	4d74 <exit>
    printf("%s: open failed\n", s);
    1462:	85ca                	mv	a1,s2
    1464:	00004517          	auipc	a0,0x4
    1468:	7cc50513          	addi	a0,a0,1996 # 5c30 <malloc+0x9e0>
    146c:	531030ef          	jal	519c <printf>
    exit(1);
    1470:	4505                	li	a0,1
    1472:	103030ef          	jal	4d74 <exit>
  unlink("echo-ok");
    1476:	00005517          	auipc	a0,0x5
    147a:	83250513          	addi	a0,a0,-1998 # 5ca8 <malloc+0xa58>
    147e:	147030ef          	jal	4dc4 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1482:	fb844703          	lbu	a4,-72(s0)
    1486:	04f00793          	li	a5,79
    148a:	00f71863          	bne	a4,a5,149a <exectest+0x15c>
    148e:	fb944703          	lbu	a4,-71(s0)
    1492:	04b00793          	li	a5,75
    1496:	00f70c63          	beq	a4,a5,14ae <exectest+0x170>
    printf("%s: wrong output\n", s);
    149a:	85ca                	mv	a1,s2
    149c:	00005517          	auipc	a0,0x5
    14a0:	86c50513          	addi	a0,a0,-1940 # 5d08 <malloc+0xab8>
    14a4:	4f9030ef          	jal	519c <printf>
    exit(1);
    14a8:	4505                	li	a0,1
    14aa:	0cb030ef          	jal	4d74 <exit>
    exit(0);
    14ae:	4501                	li	a0,0
    14b0:	0c5030ef          	jal	4d74 <exit>

00000000000014b4 <pipe1>:
{
    14b4:	711d                	addi	sp,sp,-96
    14b6:	ec86                	sd	ra,88(sp)
    14b8:	e8a2                	sd	s0,80(sp)
    14ba:	fc4e                	sd	s3,56(sp)
    14bc:	1080                	addi	s0,sp,96
    14be:	89aa                	mv	s3,a0
  if(pipe(fds) != 0){
    14c0:	fa840513          	addi	a0,s0,-88
    14c4:	0c1030ef          	jal	4d84 <pipe>
    14c8:	e92d                	bnez	a0,153a <pipe1+0x86>
    14ca:	e4a6                	sd	s1,72(sp)
    14cc:	f852                	sd	s4,48(sp)
    14ce:	84aa                	mv	s1,a0
  pid = fork();
    14d0:	09d030ef          	jal	4d6c <fork>
    14d4:	8a2a                	mv	s4,a0
  if(pid == 0){
    14d6:	c151                	beqz	a0,155a <pipe1+0xa6>
  } else if(pid > 0){
    14d8:	14a05e63          	blez	a0,1634 <pipe1+0x180>
    14dc:	e0ca                	sd	s2,64(sp)
    14de:	f456                	sd	s5,40(sp)
    close(fds[1]);
    14e0:	fac42503          	lw	a0,-84(s0)
    14e4:	0b9030ef          	jal	4d9c <close>
    total = 0;
    14e8:	8a26                	mv	s4,s1
    cc = 1;
    14ea:	4905                	li	s2,1
    while((n = read(fds[0], buf, cc)) > 0){
    14ec:	0000ba97          	auipc	s5,0xb
    14f0:	7cca8a93          	addi	s5,s5,1996 # ccb8 <buf>
    14f4:	864a                	mv	a2,s2
    14f6:	85d6                	mv	a1,s5
    14f8:	fa842503          	lw	a0,-88(s0)
    14fc:	091030ef          	jal	4d8c <read>
    1500:	0ea05a63          	blez	a0,15f4 <pipe1+0x140>
      for(i = 0; i < n; i++){
    1504:	0000b717          	auipc	a4,0xb
    1508:	7b470713          	addi	a4,a4,1972 # ccb8 <buf>
    150c:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    1510:	00074683          	lbu	a3,0(a4)
    1514:	0ff4f793          	zext.b	a5,s1
    1518:	2485                	addiw	s1,s1,1
    151a:	0af69d63          	bne	a3,a5,15d4 <pipe1+0x120>
      for(i = 0; i < n; i++){
    151e:	0705                	addi	a4,a4,1
    1520:	fec498e3          	bne	s1,a2,1510 <pipe1+0x5c>
      total += n;
    1524:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    1528:	0019179b          	slliw	a5,s2,0x1
    152c:	0007891b          	sext.w	s2,a5
      if(cc > sizeof(buf))
    1530:	670d                	lui	a4,0x3
    1532:	fd2771e3          	bgeu	a4,s2,14f4 <pipe1+0x40>
        cc = sizeof(buf);
    1536:	690d                	lui	s2,0x3
    1538:	bf75                	j	14f4 <pipe1+0x40>
    153a:	e4a6                	sd	s1,72(sp)
    153c:	e0ca                	sd	s2,64(sp)
    153e:	f852                	sd	s4,48(sp)
    1540:	f456                	sd	s5,40(sp)
    1542:	f05a                	sd	s6,32(sp)
    1544:	ec5e                	sd	s7,24(sp)
    printf("%s: pipe() failed\n", s);
    1546:	85ce                	mv	a1,s3
    1548:	00004517          	auipc	a0,0x4
    154c:	7d850513          	addi	a0,a0,2008 # 5d20 <malloc+0xad0>
    1550:	44d030ef          	jal	519c <printf>
    exit(1);
    1554:	4505                	li	a0,1
    1556:	01f030ef          	jal	4d74 <exit>
    155a:	e0ca                	sd	s2,64(sp)
    155c:	f456                	sd	s5,40(sp)
    155e:	f05a                	sd	s6,32(sp)
    1560:	ec5e                	sd	s7,24(sp)
    close(fds[0]);
    1562:	fa842503          	lw	a0,-88(s0)
    1566:	037030ef          	jal	4d9c <close>
    for(n = 0; n < N; n++){
    156a:	0000bb17          	auipc	s6,0xb
    156e:	74eb0b13          	addi	s6,s6,1870 # ccb8 <buf>
    1572:	416004bb          	negw	s1,s6
    1576:	0ff4f493          	zext.b	s1,s1
    157a:	409b0913          	addi	s2,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    157e:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    1580:	6a85                	lui	s5,0x1
    1582:	42da8a93          	addi	s5,s5,1069 # 142d <exectest+0xef>
{
    1586:	87da                	mv	a5,s6
        buf[i] = seq++;
    1588:	0097873b          	addw	a4,a5,s1
    158c:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1590:	0785                	addi	a5,a5,1
    1592:	ff279be3          	bne	a5,s2,1588 <pipe1+0xd4>
    1596:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    159a:	40900613          	li	a2,1033
    159e:	85de                	mv	a1,s7
    15a0:	fac42503          	lw	a0,-84(s0)
    15a4:	7f0030ef          	jal	4d94 <write>
    15a8:	40900793          	li	a5,1033
    15ac:	00f51a63          	bne	a0,a5,15c0 <pipe1+0x10c>
    for(n = 0; n < N; n++){
    15b0:	24a5                	addiw	s1,s1,9
    15b2:	0ff4f493          	zext.b	s1,s1
    15b6:	fd5a18e3          	bne	s4,s5,1586 <pipe1+0xd2>
    exit(0);
    15ba:	4501                	li	a0,0
    15bc:	7b8030ef          	jal	4d74 <exit>
        printf("%s: pipe1 oops 1\n", s);
    15c0:	85ce                	mv	a1,s3
    15c2:	00004517          	auipc	a0,0x4
    15c6:	77650513          	addi	a0,a0,1910 # 5d38 <malloc+0xae8>
    15ca:	3d3030ef          	jal	519c <printf>
        exit(1);
    15ce:	4505                	li	a0,1
    15d0:	7a4030ef          	jal	4d74 <exit>
          printf("%s: pipe1 oops 2\n", s);
    15d4:	85ce                	mv	a1,s3
    15d6:	00004517          	auipc	a0,0x4
    15da:	77a50513          	addi	a0,a0,1914 # 5d50 <malloc+0xb00>
    15de:	3bf030ef          	jal	519c <printf>
          return;
    15e2:	64a6                	ld	s1,72(sp)
    15e4:	6906                	ld	s2,64(sp)
    15e6:	7a42                	ld	s4,48(sp)
    15e8:	7aa2                	ld	s5,40(sp)
}
    15ea:	60e6                	ld	ra,88(sp)
    15ec:	6446                	ld	s0,80(sp)
    15ee:	79e2                	ld	s3,56(sp)
    15f0:	6125                	addi	sp,sp,96
    15f2:	8082                	ret
    if(total != N * SZ){
    15f4:	6785                	lui	a5,0x1
    15f6:	42d78793          	addi	a5,a5,1069 # 142d <exectest+0xef>
    15fa:	00fa0f63          	beq	s4,a5,1618 <pipe1+0x164>
    15fe:	f05a                	sd	s6,32(sp)
    1600:	ec5e                	sd	s7,24(sp)
      printf("%s: pipe1 oops 3 total %d\n", s, total);
    1602:	8652                	mv	a2,s4
    1604:	85ce                	mv	a1,s3
    1606:	00004517          	auipc	a0,0x4
    160a:	76250513          	addi	a0,a0,1890 # 5d68 <malloc+0xb18>
    160e:	38f030ef          	jal	519c <printf>
      exit(1);
    1612:	4505                	li	a0,1
    1614:	760030ef          	jal	4d74 <exit>
    1618:	f05a                	sd	s6,32(sp)
    161a:	ec5e                	sd	s7,24(sp)
    close(fds[0]);
    161c:	fa842503          	lw	a0,-88(s0)
    1620:	77c030ef          	jal	4d9c <close>
    wait(&xstatus);
    1624:	fa440513          	addi	a0,s0,-92
    1628:	754030ef          	jal	4d7c <wait>
    exit(xstatus);
    162c:	fa442503          	lw	a0,-92(s0)
    1630:	744030ef          	jal	4d74 <exit>
    1634:	e0ca                	sd	s2,64(sp)
    1636:	f456                	sd	s5,40(sp)
    1638:	f05a                	sd	s6,32(sp)
    163a:	ec5e                	sd	s7,24(sp)
    printf("%s: fork() failed\n", s);
    163c:	85ce                	mv	a1,s3
    163e:	00004517          	auipc	a0,0x4
    1642:	74a50513          	addi	a0,a0,1866 # 5d88 <malloc+0xb38>
    1646:	357030ef          	jal	519c <printf>
    exit(1);
    164a:	4505                	li	a0,1
    164c:	728030ef          	jal	4d74 <exit>

0000000000001650 <exitwait>:
{
    1650:	7139                	addi	sp,sp,-64
    1652:	fc06                	sd	ra,56(sp)
    1654:	f822                	sd	s0,48(sp)
    1656:	f426                	sd	s1,40(sp)
    1658:	f04a                	sd	s2,32(sp)
    165a:	ec4e                	sd	s3,24(sp)
    165c:	e852                	sd	s4,16(sp)
    165e:	0080                	addi	s0,sp,64
    1660:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    1662:	4901                	li	s2,0
    1664:	06400993          	li	s3,100
    pid = fork();
    1668:	704030ef          	jal	4d6c <fork>
    166c:	84aa                	mv	s1,a0
    if(pid < 0){
    166e:	02054863          	bltz	a0,169e <exitwait+0x4e>
    if(pid){
    1672:	c525                	beqz	a0,16da <exitwait+0x8a>
      if(wait(&xstate) != pid){
    1674:	fcc40513          	addi	a0,s0,-52
    1678:	704030ef          	jal	4d7c <wait>
    167c:	02951b63          	bne	a0,s1,16b2 <exitwait+0x62>
      if(i != xstate) {
    1680:	fcc42783          	lw	a5,-52(s0)
    1684:	05279163          	bne	a5,s2,16c6 <exitwait+0x76>
  for(i = 0; i < 100; i++){
    1688:	2905                	addiw	s2,s2,1 # 3001 <subdir+0x43f>
    168a:	fd391fe3          	bne	s2,s3,1668 <exitwait+0x18>
}
    168e:	70e2                	ld	ra,56(sp)
    1690:	7442                	ld	s0,48(sp)
    1692:	74a2                	ld	s1,40(sp)
    1694:	7902                	ld	s2,32(sp)
    1696:	69e2                	ld	s3,24(sp)
    1698:	6a42                	ld	s4,16(sp)
    169a:	6121                	addi	sp,sp,64
    169c:	8082                	ret
      printf("%s: fork failed\n", s);
    169e:	85d2                	mv	a1,s4
    16a0:	00004517          	auipc	a0,0x4
    16a4:	57850513          	addi	a0,a0,1400 # 5c18 <malloc+0x9c8>
    16a8:	2f5030ef          	jal	519c <printf>
      exit(1);
    16ac:	4505                	li	a0,1
    16ae:	6c6030ef          	jal	4d74 <exit>
        printf("%s: wait wrong pid\n", s);
    16b2:	85d2                	mv	a1,s4
    16b4:	00004517          	auipc	a0,0x4
    16b8:	6ec50513          	addi	a0,a0,1772 # 5da0 <malloc+0xb50>
    16bc:	2e1030ef          	jal	519c <printf>
        exit(1);
    16c0:	4505                	li	a0,1
    16c2:	6b2030ef          	jal	4d74 <exit>
        printf("%s: wait wrong exit status\n", s);
    16c6:	85d2                	mv	a1,s4
    16c8:	00004517          	auipc	a0,0x4
    16cc:	6f050513          	addi	a0,a0,1776 # 5db8 <malloc+0xb68>
    16d0:	2cd030ef          	jal	519c <printf>
        exit(1);
    16d4:	4505                	li	a0,1
    16d6:	69e030ef          	jal	4d74 <exit>
      exit(i);
    16da:	854a                	mv	a0,s2
    16dc:	698030ef          	jal	4d74 <exit>

00000000000016e0 <twochildren>:
{
    16e0:	1101                	addi	sp,sp,-32
    16e2:	ec06                	sd	ra,24(sp)
    16e4:	e822                	sd	s0,16(sp)
    16e6:	e426                	sd	s1,8(sp)
    16e8:	e04a                	sd	s2,0(sp)
    16ea:	1000                	addi	s0,sp,32
    16ec:	892a                	mv	s2,a0
    16ee:	3e800493          	li	s1,1000
    int pid1 = fork();
    16f2:	67a030ef          	jal	4d6c <fork>
    if(pid1 < 0){
    16f6:	02054663          	bltz	a0,1722 <twochildren+0x42>
    if(pid1 == 0){
    16fa:	cd15                	beqz	a0,1736 <twochildren+0x56>
      int pid2 = fork();
    16fc:	670030ef          	jal	4d6c <fork>
      if(pid2 < 0){
    1700:	02054d63          	bltz	a0,173a <twochildren+0x5a>
      if(pid2 == 0){
    1704:	c529                	beqz	a0,174e <twochildren+0x6e>
        wait(0);
    1706:	4501                	li	a0,0
    1708:	674030ef          	jal	4d7c <wait>
        wait(0);
    170c:	4501                	li	a0,0
    170e:	66e030ef          	jal	4d7c <wait>
  for(int i = 0; i < 1000; i++){
    1712:	34fd                	addiw	s1,s1,-1
    1714:	fcf9                	bnez	s1,16f2 <twochildren+0x12>
}
    1716:	60e2                	ld	ra,24(sp)
    1718:	6442                	ld	s0,16(sp)
    171a:	64a2                	ld	s1,8(sp)
    171c:	6902                	ld	s2,0(sp)
    171e:	6105                	addi	sp,sp,32
    1720:	8082                	ret
      printf("%s: fork failed\n", s);
    1722:	85ca                	mv	a1,s2
    1724:	00004517          	auipc	a0,0x4
    1728:	4f450513          	addi	a0,a0,1268 # 5c18 <malloc+0x9c8>
    172c:	271030ef          	jal	519c <printf>
      exit(1);
    1730:	4505                	li	a0,1
    1732:	642030ef          	jal	4d74 <exit>
      exit(0);
    1736:	63e030ef          	jal	4d74 <exit>
        printf("%s: fork failed\n", s);
    173a:	85ca                	mv	a1,s2
    173c:	00004517          	auipc	a0,0x4
    1740:	4dc50513          	addi	a0,a0,1244 # 5c18 <malloc+0x9c8>
    1744:	259030ef          	jal	519c <printf>
        exit(1);
    1748:	4505                	li	a0,1
    174a:	62a030ef          	jal	4d74 <exit>
        exit(0);
    174e:	626030ef          	jal	4d74 <exit>

0000000000001752 <forkfork>:
{
    1752:	7179                	addi	sp,sp,-48
    1754:	f406                	sd	ra,40(sp)
    1756:	f022                	sd	s0,32(sp)
    1758:	ec26                	sd	s1,24(sp)
    175a:	1800                	addi	s0,sp,48
    175c:	84aa                	mv	s1,a0
    int pid = fork();
    175e:	60e030ef          	jal	4d6c <fork>
    if(pid < 0){
    1762:	02054b63          	bltz	a0,1798 <forkfork+0x46>
    if(pid == 0){
    1766:	c139                	beqz	a0,17ac <forkfork+0x5a>
    int pid = fork();
    1768:	604030ef          	jal	4d6c <fork>
    if(pid < 0){
    176c:	02054663          	bltz	a0,1798 <forkfork+0x46>
    if(pid == 0){
    1770:	cd15                	beqz	a0,17ac <forkfork+0x5a>
    wait(&xstatus);
    1772:	fdc40513          	addi	a0,s0,-36
    1776:	606030ef          	jal	4d7c <wait>
    if(xstatus != 0) {
    177a:	fdc42783          	lw	a5,-36(s0)
    177e:	ebb9                	bnez	a5,17d4 <forkfork+0x82>
    wait(&xstatus);
    1780:	fdc40513          	addi	a0,s0,-36
    1784:	5f8030ef          	jal	4d7c <wait>
    if(xstatus != 0) {
    1788:	fdc42783          	lw	a5,-36(s0)
    178c:	e7a1                	bnez	a5,17d4 <forkfork+0x82>
}
    178e:	70a2                	ld	ra,40(sp)
    1790:	7402                	ld	s0,32(sp)
    1792:	64e2                	ld	s1,24(sp)
    1794:	6145                	addi	sp,sp,48
    1796:	8082                	ret
      printf("%s: fork failed", s);
    1798:	85a6                	mv	a1,s1
    179a:	00004517          	auipc	a0,0x4
    179e:	63e50513          	addi	a0,a0,1598 # 5dd8 <malloc+0xb88>
    17a2:	1fb030ef          	jal	519c <printf>
      exit(1);
    17a6:	4505                	li	a0,1
    17a8:	5cc030ef          	jal	4d74 <exit>
{
    17ac:	0c800493          	li	s1,200
        int pid1 = fork();
    17b0:	5bc030ef          	jal	4d6c <fork>
        if(pid1 < 0){
    17b4:	00054b63          	bltz	a0,17ca <forkfork+0x78>
        if(pid1 == 0){
    17b8:	cd01                	beqz	a0,17d0 <forkfork+0x7e>
        wait(0);
    17ba:	4501                	li	a0,0
    17bc:	5c0030ef          	jal	4d7c <wait>
      for(int j = 0; j < 200; j++){
    17c0:	34fd                	addiw	s1,s1,-1
    17c2:	f4fd                	bnez	s1,17b0 <forkfork+0x5e>
      exit(0);
    17c4:	4501                	li	a0,0
    17c6:	5ae030ef          	jal	4d74 <exit>
          exit(1);
    17ca:	4505                	li	a0,1
    17cc:	5a8030ef          	jal	4d74 <exit>
          exit(0);
    17d0:	5a4030ef          	jal	4d74 <exit>
      printf("%s: fork in child failed", s);
    17d4:	85a6                	mv	a1,s1
    17d6:	00004517          	auipc	a0,0x4
    17da:	61250513          	addi	a0,a0,1554 # 5de8 <malloc+0xb98>
    17de:	1bf030ef          	jal	519c <printf>
      exit(1);
    17e2:	4505                	li	a0,1
    17e4:	590030ef          	jal	4d74 <exit>

00000000000017e8 <reparent2>:
{
    17e8:	1101                	addi	sp,sp,-32
    17ea:	ec06                	sd	ra,24(sp)
    17ec:	e822                	sd	s0,16(sp)
    17ee:	e426                	sd	s1,8(sp)
    17f0:	1000                	addi	s0,sp,32
    17f2:	32000493          	li	s1,800
    int pid1 = fork();
    17f6:	576030ef          	jal	4d6c <fork>
    if(pid1 < 0){
    17fa:	00054b63          	bltz	a0,1810 <reparent2+0x28>
    if(pid1 == 0){
    17fe:	c115                	beqz	a0,1822 <reparent2+0x3a>
    wait(0);
    1800:	4501                	li	a0,0
    1802:	57a030ef          	jal	4d7c <wait>
  for(int i = 0; i < 800; i++){
    1806:	34fd                	addiw	s1,s1,-1
    1808:	f4fd                	bnez	s1,17f6 <reparent2+0xe>
  exit(0);
    180a:	4501                	li	a0,0
    180c:	568030ef          	jal	4d74 <exit>
      printf("fork failed\n");
    1810:	00006517          	auipc	a0,0x6
    1814:	9b050513          	addi	a0,a0,-1616 # 71c0 <malloc+0x1f70>
    1818:	185030ef          	jal	519c <printf>
      exit(1);
    181c:	4505                	li	a0,1
    181e:	556030ef          	jal	4d74 <exit>
      fork();
    1822:	54a030ef          	jal	4d6c <fork>
      fork();
    1826:	546030ef          	jal	4d6c <fork>
      exit(0);
    182a:	4501                	li	a0,0
    182c:	548030ef          	jal	4d74 <exit>

0000000000001830 <createdelete>:
{
    1830:	7175                	addi	sp,sp,-144
    1832:	e506                	sd	ra,136(sp)
    1834:	e122                	sd	s0,128(sp)
    1836:	fca6                	sd	s1,120(sp)
    1838:	f8ca                	sd	s2,112(sp)
    183a:	f4ce                	sd	s3,104(sp)
    183c:	f0d2                	sd	s4,96(sp)
    183e:	ecd6                	sd	s5,88(sp)
    1840:	e8da                	sd	s6,80(sp)
    1842:	e4de                	sd	s7,72(sp)
    1844:	e0e2                	sd	s8,64(sp)
    1846:	fc66                	sd	s9,56(sp)
    1848:	0900                	addi	s0,sp,144
    184a:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    184c:	4901                	li	s2,0
    184e:	4991                	li	s3,4
    pid = fork();
    1850:	51c030ef          	jal	4d6c <fork>
    1854:	84aa                	mv	s1,a0
    if(pid < 0){
    1856:	02054d63          	bltz	a0,1890 <createdelete+0x60>
    if(pid == 0){
    185a:	c529                	beqz	a0,18a4 <createdelete+0x74>
  for(pi = 0; pi < NCHILD; pi++){
    185c:	2905                	addiw	s2,s2,1
    185e:	ff3919e3          	bne	s2,s3,1850 <createdelete+0x20>
    1862:	4491                	li	s1,4
    wait(&xstatus);
    1864:	f7c40513          	addi	a0,s0,-132
    1868:	514030ef          	jal	4d7c <wait>
    if(xstatus != 0)
    186c:	f7c42903          	lw	s2,-132(s0)
    1870:	0a091e63          	bnez	s2,192c <createdelete+0xfc>
  for(pi = 0; pi < NCHILD; pi++){
    1874:	34fd                	addiw	s1,s1,-1
    1876:	f4fd                	bnez	s1,1864 <createdelete+0x34>
  name[0] = name[1] = name[2] = 0;
    1878:	f8040123          	sb	zero,-126(s0)
    187c:	03000993          	li	s3,48
    1880:	5a7d                	li	s4,-1
    1882:	07000c13          	li	s8,112
      if((i == 0 || i >= N/2) && fd < 0){
    1886:	4b25                	li	s6,9
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1888:	4ba1                	li	s7,8
    for(pi = 0; pi < NCHILD; pi++){
    188a:	07400a93          	li	s5,116
    188e:	aa39                	j	19ac <createdelete+0x17c>
      printf("%s: fork failed\n", s);
    1890:	85e6                	mv	a1,s9
    1892:	00004517          	auipc	a0,0x4
    1896:	38650513          	addi	a0,a0,902 # 5c18 <malloc+0x9c8>
    189a:	103030ef          	jal	519c <printf>
      exit(1);
    189e:	4505                	li	a0,1
    18a0:	4d4030ef          	jal	4d74 <exit>
      name[0] = 'p' + pi;
    18a4:	0709091b          	addiw	s2,s2,112
    18a8:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    18ac:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    18b0:	4951                	li	s2,20
    18b2:	a831                	j	18ce <createdelete+0x9e>
          printf("%s: create failed\n", s);
    18b4:	85e6                	mv	a1,s9
    18b6:	00004517          	auipc	a0,0x4
    18ba:	3fa50513          	addi	a0,a0,1018 # 5cb0 <malloc+0xa60>
    18be:	0df030ef          	jal	519c <printf>
          exit(1);
    18c2:	4505                	li	a0,1
    18c4:	4b0030ef          	jal	4d74 <exit>
      for(i = 0; i < N; i++){
    18c8:	2485                	addiw	s1,s1,1
    18ca:	05248e63          	beq	s1,s2,1926 <createdelete+0xf6>
        name[1] = '0' + i;
    18ce:	0304879b          	addiw	a5,s1,48
    18d2:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    18d6:	20200593          	li	a1,514
    18da:	f8040513          	addi	a0,s0,-128
    18de:	4d6030ef          	jal	4db4 <open>
        if(fd < 0){
    18e2:	fc0549e3          	bltz	a0,18b4 <createdelete+0x84>
        close(fd);
    18e6:	4b6030ef          	jal	4d9c <close>
        if(i > 0 && (i % 2 ) == 0){
    18ea:	10905063          	blez	s1,19ea <createdelete+0x1ba>
    18ee:	0014f793          	andi	a5,s1,1
    18f2:	fbf9                	bnez	a5,18c8 <createdelete+0x98>
          name[1] = '0' + (i / 2);
    18f4:	01f4d79b          	srliw	a5,s1,0x1f
    18f8:	9fa5                	addw	a5,a5,s1
    18fa:	4017d79b          	sraiw	a5,a5,0x1
    18fe:	0307879b          	addiw	a5,a5,48
    1902:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1906:	f8040513          	addi	a0,s0,-128
    190a:	4ba030ef          	jal	4dc4 <unlink>
    190e:	fa055de3          	bgez	a0,18c8 <createdelete+0x98>
            printf("%s: unlink failed\n", s);
    1912:	85e6                	mv	a1,s9
    1914:	00004517          	auipc	a0,0x4
    1918:	4f450513          	addi	a0,a0,1268 # 5e08 <malloc+0xbb8>
    191c:	081030ef          	jal	519c <printf>
            exit(1);
    1920:	4505                	li	a0,1
    1922:	452030ef          	jal	4d74 <exit>
      exit(0);
    1926:	4501                	li	a0,0
    1928:	44c030ef          	jal	4d74 <exit>
      exit(1);
    192c:	4505                	li	a0,1
    192e:	446030ef          	jal	4d74 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1932:	f8040613          	addi	a2,s0,-128
    1936:	85e6                	mv	a1,s9
    1938:	00004517          	auipc	a0,0x4
    193c:	4e850513          	addi	a0,a0,1256 # 5e20 <malloc+0xbd0>
    1940:	05d030ef          	jal	519c <printf>
        exit(1);
    1944:	4505                	li	a0,1
    1946:	42e030ef          	jal	4d74 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    194a:	034bfb63          	bgeu	s7,s4,1980 <createdelete+0x150>
      if(fd >= 0)
    194e:	02055663          	bgez	a0,197a <createdelete+0x14a>
    for(pi = 0; pi < NCHILD; pi++){
    1952:	2485                	addiw	s1,s1,1
    1954:	0ff4f493          	zext.b	s1,s1
    1958:	05548263          	beq	s1,s5,199c <createdelete+0x16c>
      name[0] = 'p' + pi;
    195c:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1960:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1964:	4581                	li	a1,0
    1966:	f8040513          	addi	a0,s0,-128
    196a:	44a030ef          	jal	4db4 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    196e:	00090463          	beqz	s2,1976 <createdelete+0x146>
    1972:	fd2b5ce3          	bge	s6,s2,194a <createdelete+0x11a>
    1976:	fa054ee3          	bltz	a0,1932 <createdelete+0x102>
        close(fd);
    197a:	422030ef          	jal	4d9c <close>
    197e:	bfd1                	j	1952 <createdelete+0x122>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1980:	fc0549e3          	bltz	a0,1952 <createdelete+0x122>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1984:	f8040613          	addi	a2,s0,-128
    1988:	85e6                	mv	a1,s9
    198a:	00004517          	auipc	a0,0x4
    198e:	4be50513          	addi	a0,a0,1214 # 5e48 <malloc+0xbf8>
    1992:	00b030ef          	jal	519c <printf>
        exit(1);
    1996:	4505                	li	a0,1
    1998:	3dc030ef          	jal	4d74 <exit>
  for(i = 0; i < N; i++){
    199c:	2905                	addiw	s2,s2,1
    199e:	2a05                	addiw	s4,s4,1
    19a0:	2985                	addiw	s3,s3,1
    19a2:	0ff9f993          	zext.b	s3,s3
    19a6:	47d1                	li	a5,20
    19a8:	02f90863          	beq	s2,a5,19d8 <createdelete+0x1a8>
    for(pi = 0; pi < NCHILD; pi++){
    19ac:	84e2                	mv	s1,s8
    19ae:	b77d                	j	195c <createdelete+0x12c>
  for(i = 0; i < N; i++){
    19b0:	2905                	addiw	s2,s2,1
    19b2:	0ff97913          	zext.b	s2,s2
    19b6:	03490c63          	beq	s2,s4,19ee <createdelete+0x1be>
  name[0] = name[1] = name[2] = 0;
    19ba:	84d6                	mv	s1,s5
      name[0] = 'p' + pi;
    19bc:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    19c0:	f92400a3          	sb	s2,-127(s0)
      unlink(name);
    19c4:	f8040513          	addi	a0,s0,-128
    19c8:	3fc030ef          	jal	4dc4 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    19cc:	2485                	addiw	s1,s1,1
    19ce:	0ff4f493          	zext.b	s1,s1
    19d2:	ff3495e3          	bne	s1,s3,19bc <createdelete+0x18c>
    19d6:	bfe9                	j	19b0 <createdelete+0x180>
    19d8:	03000913          	li	s2,48
  name[0] = name[1] = name[2] = 0;
    19dc:	07000a93          	li	s5,112
    for(pi = 0; pi < NCHILD; pi++){
    19e0:	07400993          	li	s3,116
  for(i = 0; i < N; i++){
    19e4:	04400a13          	li	s4,68
    19e8:	bfc9                	j	19ba <createdelete+0x18a>
      for(i = 0; i < N; i++){
    19ea:	2485                	addiw	s1,s1,1
    19ec:	b5cd                	j	18ce <createdelete+0x9e>
}
    19ee:	60aa                	ld	ra,136(sp)
    19f0:	640a                	ld	s0,128(sp)
    19f2:	74e6                	ld	s1,120(sp)
    19f4:	7946                	ld	s2,112(sp)
    19f6:	79a6                	ld	s3,104(sp)
    19f8:	7a06                	ld	s4,96(sp)
    19fa:	6ae6                	ld	s5,88(sp)
    19fc:	6b46                	ld	s6,80(sp)
    19fe:	6ba6                	ld	s7,72(sp)
    1a00:	6c06                	ld	s8,64(sp)
    1a02:	7ce2                	ld	s9,56(sp)
    1a04:	6149                	addi	sp,sp,144
    1a06:	8082                	ret

0000000000001a08 <linkunlink>:
{
    1a08:	711d                	addi	sp,sp,-96
    1a0a:	ec86                	sd	ra,88(sp)
    1a0c:	e8a2                	sd	s0,80(sp)
    1a0e:	e4a6                	sd	s1,72(sp)
    1a10:	e0ca                	sd	s2,64(sp)
    1a12:	fc4e                	sd	s3,56(sp)
    1a14:	f852                	sd	s4,48(sp)
    1a16:	f456                	sd	s5,40(sp)
    1a18:	f05a                	sd	s6,32(sp)
    1a1a:	ec5e                	sd	s7,24(sp)
    1a1c:	e862                	sd	s8,16(sp)
    1a1e:	e466                	sd	s9,8(sp)
    1a20:	1080                	addi	s0,sp,96
    1a22:	84aa                	mv	s1,a0
  unlink("x");
    1a24:	00004517          	auipc	a0,0x4
    1a28:	9d450513          	addi	a0,a0,-1580 # 53f8 <malloc+0x1a8>
    1a2c:	398030ef          	jal	4dc4 <unlink>
  pid = fork();
    1a30:	33c030ef          	jal	4d6c <fork>
  if(pid < 0){
    1a34:	02054b63          	bltz	a0,1a6a <linkunlink+0x62>
    1a38:	8caa                	mv	s9,a0
  unsigned int x = (pid ? 1 : 97);
    1a3a:	06100913          	li	s2,97
    1a3e:	c111                	beqz	a0,1a42 <linkunlink+0x3a>
    1a40:	4905                	li	s2,1
    1a42:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1a46:	41c65a37          	lui	s4,0x41c65
    1a4a:	e6da0a1b          	addiw	s4,s4,-403 # 41c64e6d <base+0x41c551b5>
    1a4e:	698d                	lui	s3,0x3
    1a50:	0399899b          	addiw	s3,s3,57 # 3039 <subdir+0x477>
    if((x % 3) == 0){
    1a54:	4a8d                	li	s5,3
    } else if((x % 3) == 1){
    1a56:	4b85                	li	s7,1
      unlink("x");
    1a58:	00004b17          	auipc	s6,0x4
    1a5c:	9a0b0b13          	addi	s6,s6,-1632 # 53f8 <malloc+0x1a8>
      link("cat", "x");
    1a60:	00004c17          	auipc	s8,0x4
    1a64:	410c0c13          	addi	s8,s8,1040 # 5e70 <malloc+0xc20>
    1a68:	a025                	j	1a90 <linkunlink+0x88>
    printf("%s: fork failed\n", s);
    1a6a:	85a6                	mv	a1,s1
    1a6c:	00004517          	auipc	a0,0x4
    1a70:	1ac50513          	addi	a0,a0,428 # 5c18 <malloc+0x9c8>
    1a74:	728030ef          	jal	519c <printf>
    exit(1);
    1a78:	4505                	li	a0,1
    1a7a:	2fa030ef          	jal	4d74 <exit>
      close(open("x", O_RDWR | O_CREATE));
    1a7e:	20200593          	li	a1,514
    1a82:	855a                	mv	a0,s6
    1a84:	330030ef          	jal	4db4 <open>
    1a88:	314030ef          	jal	4d9c <close>
  for(i = 0; i < 100; i++){
    1a8c:	34fd                	addiw	s1,s1,-1
    1a8e:	c495                	beqz	s1,1aba <linkunlink+0xb2>
    x = x * 1103515245 + 12345;
    1a90:	034907bb          	mulw	a5,s2,s4
    1a94:	013787bb          	addw	a5,a5,s3
    1a98:	0007891b          	sext.w	s2,a5
    if((x % 3) == 0){
    1a9c:	0357f7bb          	remuw	a5,a5,s5
    1aa0:	2781                	sext.w	a5,a5
    1aa2:	dff1                	beqz	a5,1a7e <linkunlink+0x76>
    } else if((x % 3) == 1){
    1aa4:	01778663          	beq	a5,s7,1ab0 <linkunlink+0xa8>
      unlink("x");
    1aa8:	855a                	mv	a0,s6
    1aaa:	31a030ef          	jal	4dc4 <unlink>
    1aae:	bff9                	j	1a8c <linkunlink+0x84>
      link("cat", "x");
    1ab0:	85da                	mv	a1,s6
    1ab2:	8562                	mv	a0,s8
    1ab4:	320030ef          	jal	4dd4 <link>
    1ab8:	bfd1                	j	1a8c <linkunlink+0x84>
  if(pid)
    1aba:	020c8263          	beqz	s9,1ade <linkunlink+0xd6>
    wait(0);
    1abe:	4501                	li	a0,0
    1ac0:	2bc030ef          	jal	4d7c <wait>
}
    1ac4:	60e6                	ld	ra,88(sp)
    1ac6:	6446                	ld	s0,80(sp)
    1ac8:	64a6                	ld	s1,72(sp)
    1aca:	6906                	ld	s2,64(sp)
    1acc:	79e2                	ld	s3,56(sp)
    1ace:	7a42                	ld	s4,48(sp)
    1ad0:	7aa2                	ld	s5,40(sp)
    1ad2:	7b02                	ld	s6,32(sp)
    1ad4:	6be2                	ld	s7,24(sp)
    1ad6:	6c42                	ld	s8,16(sp)
    1ad8:	6ca2                	ld	s9,8(sp)
    1ada:	6125                	addi	sp,sp,96
    1adc:	8082                	ret
    exit(0);
    1ade:	4501                	li	a0,0
    1ae0:	294030ef          	jal	4d74 <exit>

0000000000001ae4 <forktest>:
{
    1ae4:	7179                	addi	sp,sp,-48
    1ae6:	f406                	sd	ra,40(sp)
    1ae8:	f022                	sd	s0,32(sp)
    1aea:	ec26                	sd	s1,24(sp)
    1aec:	e84a                	sd	s2,16(sp)
    1aee:	e44e                	sd	s3,8(sp)
    1af0:	1800                	addi	s0,sp,48
    1af2:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    1af4:	4481                	li	s1,0
    1af6:	3e800913          	li	s2,1000
    pid = fork();
    1afa:	272030ef          	jal	4d6c <fork>
    if(pid < 0)
    1afe:	06054063          	bltz	a0,1b5e <forktest+0x7a>
    if(pid == 0)
    1b02:	cd11                	beqz	a0,1b1e <forktest+0x3a>
  for(n=0; n<N; n++){
    1b04:	2485                	addiw	s1,s1,1
    1b06:	ff249ae3          	bne	s1,s2,1afa <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    1b0a:	85ce                	mv	a1,s3
    1b0c:	00004517          	auipc	a0,0x4
    1b10:	3b450513          	addi	a0,a0,948 # 5ec0 <malloc+0xc70>
    1b14:	688030ef          	jal	519c <printf>
    exit(1);
    1b18:	4505                	li	a0,1
    1b1a:	25a030ef          	jal	4d74 <exit>
      exit(0);
    1b1e:	256030ef          	jal	4d74 <exit>
    printf("%s: no fork at all!\n", s);
    1b22:	85ce                	mv	a1,s3
    1b24:	00004517          	auipc	a0,0x4
    1b28:	35450513          	addi	a0,a0,852 # 5e78 <malloc+0xc28>
    1b2c:	670030ef          	jal	519c <printf>
    exit(1);
    1b30:	4505                	li	a0,1
    1b32:	242030ef          	jal	4d74 <exit>
      printf("%s: wait stopped early\n", s);
    1b36:	85ce                	mv	a1,s3
    1b38:	00004517          	auipc	a0,0x4
    1b3c:	35850513          	addi	a0,a0,856 # 5e90 <malloc+0xc40>
    1b40:	65c030ef          	jal	519c <printf>
      exit(1);
    1b44:	4505                	li	a0,1
    1b46:	22e030ef          	jal	4d74 <exit>
    printf("%s: wait got too many\n", s);
    1b4a:	85ce                	mv	a1,s3
    1b4c:	00004517          	auipc	a0,0x4
    1b50:	35c50513          	addi	a0,a0,860 # 5ea8 <malloc+0xc58>
    1b54:	648030ef          	jal	519c <printf>
    exit(1);
    1b58:	4505                	li	a0,1
    1b5a:	21a030ef          	jal	4d74 <exit>
  if (n == 0) {
    1b5e:	d0f1                	beqz	s1,1b22 <forktest+0x3e>
  for(; n > 0; n--){
    1b60:	00905963          	blez	s1,1b72 <forktest+0x8e>
    if(wait(0) < 0){
    1b64:	4501                	li	a0,0
    1b66:	216030ef          	jal	4d7c <wait>
    1b6a:	fc0546e3          	bltz	a0,1b36 <forktest+0x52>
  for(; n > 0; n--){
    1b6e:	34fd                	addiw	s1,s1,-1
    1b70:	f8f5                	bnez	s1,1b64 <forktest+0x80>
  if(wait(0) != -1){
    1b72:	4501                	li	a0,0
    1b74:	208030ef          	jal	4d7c <wait>
    1b78:	57fd                	li	a5,-1
    1b7a:	fcf518e3          	bne	a0,a5,1b4a <forktest+0x66>
}
    1b7e:	70a2                	ld	ra,40(sp)
    1b80:	7402                	ld	s0,32(sp)
    1b82:	64e2                	ld	s1,24(sp)
    1b84:	6942                	ld	s2,16(sp)
    1b86:	69a2                	ld	s3,8(sp)
    1b88:	6145                	addi	sp,sp,48
    1b8a:	8082                	ret

0000000000001b8c <kernmem>:
{
    1b8c:	715d                	addi	sp,sp,-80
    1b8e:	e486                	sd	ra,72(sp)
    1b90:	e0a2                	sd	s0,64(sp)
    1b92:	fc26                	sd	s1,56(sp)
    1b94:	f84a                	sd	s2,48(sp)
    1b96:	f44e                	sd	s3,40(sp)
    1b98:	f052                	sd	s4,32(sp)
    1b9a:	ec56                	sd	s5,24(sp)
    1b9c:	0880                	addi	s0,sp,80
    1b9e:	8aaa                	mv	s5,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1ba0:	4485                	li	s1,1
    1ba2:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    1ba4:	5a7d                	li	s4,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1ba6:	69b1                	lui	s3,0xc
    1ba8:	35098993          	addi	s3,s3,848 # c350 <uninit+0x1da8>
    1bac:	1003d937          	lui	s2,0x1003d
    1bb0:	090e                	slli	s2,s2,0x3
    1bb2:	48090913          	addi	s2,s2,1152 # 1003d480 <base+0x1002d7c8>
    pid = fork();
    1bb6:	1b6030ef          	jal	4d6c <fork>
    if(pid < 0){
    1bba:	02054763          	bltz	a0,1be8 <kernmem+0x5c>
    if(pid == 0){
    1bbe:	cd1d                	beqz	a0,1bfc <kernmem+0x70>
    wait(&xstatus);
    1bc0:	fbc40513          	addi	a0,s0,-68
    1bc4:	1b8030ef          	jal	4d7c <wait>
    if(xstatus != -1)  // did kernel kill child?
    1bc8:	fbc42783          	lw	a5,-68(s0)
    1bcc:	05479563          	bne	a5,s4,1c16 <kernmem+0x8a>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1bd0:	94ce                	add	s1,s1,s3
    1bd2:	ff2492e3          	bne	s1,s2,1bb6 <kernmem+0x2a>
}
    1bd6:	60a6                	ld	ra,72(sp)
    1bd8:	6406                	ld	s0,64(sp)
    1bda:	74e2                	ld	s1,56(sp)
    1bdc:	7942                	ld	s2,48(sp)
    1bde:	79a2                	ld	s3,40(sp)
    1be0:	7a02                	ld	s4,32(sp)
    1be2:	6ae2                	ld	s5,24(sp)
    1be4:	6161                	addi	sp,sp,80
    1be6:	8082                	ret
      printf("%s: fork failed\n", s);
    1be8:	85d6                	mv	a1,s5
    1bea:	00004517          	auipc	a0,0x4
    1bee:	02e50513          	addi	a0,a0,46 # 5c18 <malloc+0x9c8>
    1bf2:	5aa030ef          	jal	519c <printf>
      exit(1);
    1bf6:	4505                	li	a0,1
    1bf8:	17c030ef          	jal	4d74 <exit>
      printf("%s: oops could read %p = %x\n", s, a, *a);
    1bfc:	0004c683          	lbu	a3,0(s1)
    1c00:	8626                	mv	a2,s1
    1c02:	85d6                	mv	a1,s5
    1c04:	00004517          	auipc	a0,0x4
    1c08:	2e450513          	addi	a0,a0,740 # 5ee8 <malloc+0xc98>
    1c0c:	590030ef          	jal	519c <printf>
      exit(1);
    1c10:	4505                	li	a0,1
    1c12:	162030ef          	jal	4d74 <exit>
      exit(1);
    1c16:	4505                	li	a0,1
    1c18:	15c030ef          	jal	4d74 <exit>

0000000000001c1c <MAXVAplus>:
{
    1c1c:	7179                	addi	sp,sp,-48
    1c1e:	f406                	sd	ra,40(sp)
    1c20:	f022                	sd	s0,32(sp)
    1c22:	1800                	addi	s0,sp,48
  volatile uint64 a = MAXVA;
    1c24:	4785                	li	a5,1
    1c26:	179a                	slli	a5,a5,0x26
    1c28:	fcf43c23          	sd	a5,-40(s0)
  for( ; a != 0; a <<= 1){
    1c2c:	fd843783          	ld	a5,-40(s0)
    1c30:	cf85                	beqz	a5,1c68 <MAXVAplus+0x4c>
    1c32:	ec26                	sd	s1,24(sp)
    1c34:	e84a                	sd	s2,16(sp)
    1c36:	892a                	mv	s2,a0
    if(xstatus != -1)  // did kernel kill child?
    1c38:	54fd                	li	s1,-1
    pid = fork();
    1c3a:	132030ef          	jal	4d6c <fork>
    if(pid < 0){
    1c3e:	02054963          	bltz	a0,1c70 <MAXVAplus+0x54>
    if(pid == 0){
    1c42:	c129                	beqz	a0,1c84 <MAXVAplus+0x68>
    wait(&xstatus);
    1c44:	fd440513          	addi	a0,s0,-44
    1c48:	134030ef          	jal	4d7c <wait>
    if(xstatus != -1)  // did kernel kill child?
    1c4c:	fd442783          	lw	a5,-44(s0)
    1c50:	04979c63          	bne	a5,s1,1ca8 <MAXVAplus+0x8c>
  for( ; a != 0; a <<= 1){
    1c54:	fd843783          	ld	a5,-40(s0)
    1c58:	0786                	slli	a5,a5,0x1
    1c5a:	fcf43c23          	sd	a5,-40(s0)
    1c5e:	fd843783          	ld	a5,-40(s0)
    1c62:	ffe1                	bnez	a5,1c3a <MAXVAplus+0x1e>
    1c64:	64e2                	ld	s1,24(sp)
    1c66:	6942                	ld	s2,16(sp)
}
    1c68:	70a2                	ld	ra,40(sp)
    1c6a:	7402                	ld	s0,32(sp)
    1c6c:	6145                	addi	sp,sp,48
    1c6e:	8082                	ret
      printf("%s: fork failed\n", s);
    1c70:	85ca                	mv	a1,s2
    1c72:	00004517          	auipc	a0,0x4
    1c76:	fa650513          	addi	a0,a0,-90 # 5c18 <malloc+0x9c8>
    1c7a:	522030ef          	jal	519c <printf>
      exit(1);
    1c7e:	4505                	li	a0,1
    1c80:	0f4030ef          	jal	4d74 <exit>
      *(char*)a = 99;
    1c84:	fd843783          	ld	a5,-40(s0)
    1c88:	06300713          	li	a4,99
    1c8c:	00e78023          	sb	a4,0(a5)
      printf("%s: oops wrote %p\n", s, (void*)a);
    1c90:	fd843603          	ld	a2,-40(s0)
    1c94:	85ca                	mv	a1,s2
    1c96:	00004517          	auipc	a0,0x4
    1c9a:	27250513          	addi	a0,a0,626 # 5f08 <malloc+0xcb8>
    1c9e:	4fe030ef          	jal	519c <printf>
      exit(1);
    1ca2:	4505                	li	a0,1
    1ca4:	0d0030ef          	jal	4d74 <exit>
      exit(1);
    1ca8:	4505                	li	a0,1
    1caa:	0ca030ef          	jal	4d74 <exit>

0000000000001cae <stacktest>:
{
    1cae:	7179                	addi	sp,sp,-48
    1cb0:	f406                	sd	ra,40(sp)
    1cb2:	f022                	sd	s0,32(sp)
    1cb4:	ec26                	sd	s1,24(sp)
    1cb6:	1800                	addi	s0,sp,48
    1cb8:	84aa                	mv	s1,a0
  pid = fork();
    1cba:	0b2030ef          	jal	4d6c <fork>
  if(pid == 0) {
    1cbe:	cd11                	beqz	a0,1cda <stacktest+0x2c>
  } else if(pid < 0){
    1cc0:	02054c63          	bltz	a0,1cf8 <stacktest+0x4a>
  wait(&xstatus);
    1cc4:	fdc40513          	addi	a0,s0,-36
    1cc8:	0b4030ef          	jal	4d7c <wait>
  if(xstatus == -1)  // kernel killed child?
    1ccc:	fdc42503          	lw	a0,-36(s0)
    1cd0:	57fd                	li	a5,-1
    1cd2:	02f50d63          	beq	a0,a5,1d0c <stacktest+0x5e>
    exit(xstatus);
    1cd6:	09e030ef          	jal	4d74 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    1cda:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %d\n", s, *sp);
    1cdc:	77fd                	lui	a5,0xfffff
    1cde:	97ba                	add	a5,a5,a4
    1ce0:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <base+0xfffffffffffef348>
    1ce4:	85a6                	mv	a1,s1
    1ce6:	00004517          	auipc	a0,0x4
    1cea:	23a50513          	addi	a0,a0,570 # 5f20 <malloc+0xcd0>
    1cee:	4ae030ef          	jal	519c <printf>
    exit(1);
    1cf2:	4505                	li	a0,1
    1cf4:	080030ef          	jal	4d74 <exit>
    printf("%s: fork failed\n", s);
    1cf8:	85a6                	mv	a1,s1
    1cfa:	00004517          	auipc	a0,0x4
    1cfe:	f1e50513          	addi	a0,a0,-226 # 5c18 <malloc+0x9c8>
    1d02:	49a030ef          	jal	519c <printf>
    exit(1);
    1d06:	4505                	li	a0,1
    1d08:	06c030ef          	jal	4d74 <exit>
    exit(0);
    1d0c:	4501                	li	a0,0
    1d0e:	066030ef          	jal	4d74 <exit>

0000000000001d12 <nowrite>:
{
    1d12:	7159                	addi	sp,sp,-112
    1d14:	f486                	sd	ra,104(sp)
    1d16:	f0a2                	sd	s0,96(sp)
    1d18:	eca6                	sd	s1,88(sp)
    1d1a:	e8ca                	sd	s2,80(sp)
    1d1c:	e4ce                	sd	s3,72(sp)
    1d1e:	1880                	addi	s0,sp,112
    1d20:	89aa                	mv	s3,a0
  uint64 addrs[] = { 0, 0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
    1d22:	00006797          	auipc	a5,0x6
    1d26:	bae78793          	addi	a5,a5,-1106 # 78d0 <malloc+0x2680>
    1d2a:	7788                	ld	a0,40(a5)
    1d2c:	7b8c                	ld	a1,48(a5)
    1d2e:	7f90                	ld	a2,56(a5)
    1d30:	63b4                	ld	a3,64(a5)
    1d32:	67b8                	ld	a4,72(a5)
    1d34:	6bbc                	ld	a5,80(a5)
    1d36:	f8a43c23          	sd	a0,-104(s0)
    1d3a:	fab43023          	sd	a1,-96(s0)
    1d3e:	fac43423          	sd	a2,-88(s0)
    1d42:	fad43823          	sd	a3,-80(s0)
    1d46:	fae43c23          	sd	a4,-72(s0)
    1d4a:	fcf43023          	sd	a5,-64(s0)
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
    1d4e:	4481                	li	s1,0
    1d50:	4919                	li	s2,6
    pid = fork();
    1d52:	01a030ef          	jal	4d6c <fork>
    if(pid == 0) {
    1d56:	c105                	beqz	a0,1d76 <nowrite+0x64>
    } else if(pid < 0){
    1d58:	04054263          	bltz	a0,1d9c <nowrite+0x8a>
    wait(&xstatus);
    1d5c:	fcc40513          	addi	a0,s0,-52
    1d60:	01c030ef          	jal	4d7c <wait>
    if(xstatus == 0){
    1d64:	fcc42783          	lw	a5,-52(s0)
    1d68:	c7a1                	beqz	a5,1db0 <nowrite+0x9e>
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
    1d6a:	2485                	addiw	s1,s1,1
    1d6c:	ff2493e3          	bne	s1,s2,1d52 <nowrite+0x40>
  exit(0);
    1d70:	4501                	li	a0,0
    1d72:	002030ef          	jal	4d74 <exit>
      volatile int *addr = (int *) addrs[ai];
    1d76:	048e                	slli	s1,s1,0x3
    1d78:	fd048793          	addi	a5,s1,-48
    1d7c:	008784b3          	add	s1,a5,s0
    1d80:	fc84b603          	ld	a2,-56(s1)
      *addr = 10;
    1d84:	47a9                	li	a5,10
    1d86:	c21c                	sw	a5,0(a2)
      printf("%s: write to %p did not fail!\n", s, addr);
    1d88:	85ce                	mv	a1,s3
    1d8a:	00004517          	auipc	a0,0x4
    1d8e:	1be50513          	addi	a0,a0,446 # 5f48 <malloc+0xcf8>
    1d92:	40a030ef          	jal	519c <printf>
      exit(0);
    1d96:	4501                	li	a0,0
    1d98:	7dd020ef          	jal	4d74 <exit>
      printf("%s: fork failed\n", s);
    1d9c:	85ce                	mv	a1,s3
    1d9e:	00004517          	auipc	a0,0x4
    1da2:	e7a50513          	addi	a0,a0,-390 # 5c18 <malloc+0x9c8>
    1da6:	3f6030ef          	jal	519c <printf>
      exit(1);
    1daa:	4505                	li	a0,1
    1dac:	7c9020ef          	jal	4d74 <exit>
      exit(1);
    1db0:	4505                	li	a0,1
    1db2:	7c3020ef          	jal	4d74 <exit>

0000000000001db6 <manywrites>:
{
    1db6:	711d                	addi	sp,sp,-96
    1db8:	ec86                	sd	ra,88(sp)
    1dba:	e8a2                	sd	s0,80(sp)
    1dbc:	e4a6                	sd	s1,72(sp)
    1dbe:	e0ca                	sd	s2,64(sp)
    1dc0:	fc4e                	sd	s3,56(sp)
    1dc2:	f456                	sd	s5,40(sp)
    1dc4:	1080                	addi	s0,sp,96
    1dc6:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    1dc8:	4981                	li	s3,0
    1dca:	4911                	li	s2,4
    int pid = fork();
    1dcc:	7a1020ef          	jal	4d6c <fork>
    1dd0:	84aa                	mv	s1,a0
    if(pid < 0){
    1dd2:	02054963          	bltz	a0,1e04 <manywrites+0x4e>
    if(pid == 0){
    1dd6:	c139                	beqz	a0,1e1c <manywrites+0x66>
  for(int ci = 0; ci < nchildren; ci++){
    1dd8:	2985                	addiw	s3,s3,1
    1dda:	ff2999e3          	bne	s3,s2,1dcc <manywrites+0x16>
    1dde:	f852                	sd	s4,48(sp)
    1de0:	f05a                	sd	s6,32(sp)
    1de2:	ec5e                	sd	s7,24(sp)
    1de4:	4491                	li	s1,4
    int st = 0;
    1de6:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    1dea:	fa840513          	addi	a0,s0,-88
    1dee:	78f020ef          	jal	4d7c <wait>
    if(st != 0)
    1df2:	fa842503          	lw	a0,-88(s0)
    1df6:	0c051863          	bnez	a0,1ec6 <manywrites+0x110>
  for(int ci = 0; ci < nchildren; ci++){
    1dfa:	34fd                	addiw	s1,s1,-1
    1dfc:	f4ed                	bnez	s1,1de6 <manywrites+0x30>
  exit(0);
    1dfe:	4501                	li	a0,0
    1e00:	775020ef          	jal	4d74 <exit>
    1e04:	f852                	sd	s4,48(sp)
    1e06:	f05a                	sd	s6,32(sp)
    1e08:	ec5e                	sd	s7,24(sp)
      printf("fork failed\n");
    1e0a:	00005517          	auipc	a0,0x5
    1e0e:	3b650513          	addi	a0,a0,950 # 71c0 <malloc+0x1f70>
    1e12:	38a030ef          	jal	519c <printf>
      exit(1);
    1e16:	4505                	li	a0,1
    1e18:	75d020ef          	jal	4d74 <exit>
    1e1c:	f852                	sd	s4,48(sp)
    1e1e:	f05a                	sd	s6,32(sp)
    1e20:	ec5e                	sd	s7,24(sp)
      name[0] = 'b';
    1e22:	06200793          	li	a5,98
    1e26:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    1e2a:	0619879b          	addiw	a5,s3,97
    1e2e:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    1e32:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    1e36:	fa840513          	addi	a0,s0,-88
    1e3a:	78b020ef          	jal	4dc4 <unlink>
    1e3e:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    1e40:	0000bb17          	auipc	s6,0xb
    1e44:	e78b0b13          	addi	s6,s6,-392 # ccb8 <buf>
        for(int i = 0; i < ci+1; i++){
    1e48:	8a26                	mv	s4,s1
    1e4a:	0209c863          	bltz	s3,1e7a <manywrites+0xc4>
          int fd = open(name, O_CREATE | O_RDWR);
    1e4e:	20200593          	li	a1,514
    1e52:	fa840513          	addi	a0,s0,-88
    1e56:	75f020ef          	jal	4db4 <open>
    1e5a:	892a                	mv	s2,a0
          if(fd < 0){
    1e5c:	02054d63          	bltz	a0,1e96 <manywrites+0xe0>
          int cc = write(fd, buf, sz);
    1e60:	660d                	lui	a2,0x3
    1e62:	85da                	mv	a1,s6
    1e64:	731020ef          	jal	4d94 <write>
          if(cc != sz){
    1e68:	678d                	lui	a5,0x3
    1e6a:	04f51263          	bne	a0,a5,1eae <manywrites+0xf8>
          close(fd);
    1e6e:	854a                	mv	a0,s2
    1e70:	72d020ef          	jal	4d9c <close>
        for(int i = 0; i < ci+1; i++){
    1e74:	2a05                	addiw	s4,s4,1
    1e76:	fd49dce3          	bge	s3,s4,1e4e <manywrites+0x98>
        unlink(name);
    1e7a:	fa840513          	addi	a0,s0,-88
    1e7e:	747020ef          	jal	4dc4 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    1e82:	3bfd                	addiw	s7,s7,-1
    1e84:	fc0b92e3          	bnez	s7,1e48 <manywrites+0x92>
      unlink(name);
    1e88:	fa840513          	addi	a0,s0,-88
    1e8c:	739020ef          	jal	4dc4 <unlink>
      exit(0);
    1e90:	4501                	li	a0,0
    1e92:	6e3020ef          	jal	4d74 <exit>
            printf("%s: cannot create %s\n", s, name);
    1e96:	fa840613          	addi	a2,s0,-88
    1e9a:	85d6                	mv	a1,s5
    1e9c:	00004517          	auipc	a0,0x4
    1ea0:	0cc50513          	addi	a0,a0,204 # 5f68 <malloc+0xd18>
    1ea4:	2f8030ef          	jal	519c <printf>
            exit(1);
    1ea8:	4505                	li	a0,1
    1eaa:	6cb020ef          	jal	4d74 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    1eae:	86aa                	mv	a3,a0
    1eb0:	660d                	lui	a2,0x3
    1eb2:	85d6                	mv	a1,s5
    1eb4:	00003517          	auipc	a0,0x3
    1eb8:	5a450513          	addi	a0,a0,1444 # 5458 <malloc+0x208>
    1ebc:	2e0030ef          	jal	519c <printf>
            exit(1);
    1ec0:	4505                	li	a0,1
    1ec2:	6b3020ef          	jal	4d74 <exit>
      exit(st);
    1ec6:	6af020ef          	jal	4d74 <exit>

0000000000001eca <copyinstr3>:
{
    1eca:	7179                	addi	sp,sp,-48
    1ecc:	f406                	sd	ra,40(sp)
    1ece:	f022                	sd	s0,32(sp)
    1ed0:	ec26                	sd	s1,24(sp)
    1ed2:	1800                	addi	s0,sp,48
  sbrk(8192);
    1ed4:	6509                	lui	a0,0x2
    1ed6:	66b020ef          	jal	4d40 <sbrk>
  uint64 top = (uint64) sbrk(0);
    1eda:	4501                	li	a0,0
    1edc:	665020ef          	jal	4d40 <sbrk>
  if((top % PGSIZE) != 0){
    1ee0:	03451793          	slli	a5,a0,0x34
    1ee4:	e7bd                	bnez	a5,1f52 <copyinstr3+0x88>
  top = (uint64) sbrk(0);
    1ee6:	4501                	li	a0,0
    1ee8:	659020ef          	jal	4d40 <sbrk>
  if(top % PGSIZE){
    1eec:	03451793          	slli	a5,a0,0x34
    1ef0:	ebad                	bnez	a5,1f62 <copyinstr3+0x98>
  char *b = (char *) (top - 1);
    1ef2:	fff50493          	addi	s1,a0,-1 # 1fff <rwsbrk+0x31>
  *b = 'x';
    1ef6:	07800793          	li	a5,120
    1efa:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    1efe:	8526                	mv	a0,s1
    1f00:	6c5020ef          	jal	4dc4 <unlink>
  if(ret != -1){
    1f04:	57fd                	li	a5,-1
    1f06:	06f51763          	bne	a0,a5,1f74 <copyinstr3+0xaa>
  int fd = open(b, O_CREATE | O_WRONLY);
    1f0a:	20100593          	li	a1,513
    1f0e:	8526                	mv	a0,s1
    1f10:	6a5020ef          	jal	4db4 <open>
  if(fd != -1){
    1f14:	57fd                	li	a5,-1
    1f16:	06f51a63          	bne	a0,a5,1f8a <copyinstr3+0xc0>
  ret = link(b, b);
    1f1a:	85a6                	mv	a1,s1
    1f1c:	8526                	mv	a0,s1
    1f1e:	6b7020ef          	jal	4dd4 <link>
  if(ret != -1){
    1f22:	57fd                	li	a5,-1
    1f24:	06f51e63          	bne	a0,a5,1fa0 <copyinstr3+0xd6>
  char *args[] = { "xx", 0 };
    1f28:	00005797          	auipc	a5,0x5
    1f2c:	d4078793          	addi	a5,a5,-704 # 6c68 <malloc+0x1a18>
    1f30:	fcf43823          	sd	a5,-48(s0)
    1f34:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    1f38:	fd040593          	addi	a1,s0,-48
    1f3c:	8526                	mv	a0,s1
    1f3e:	66f020ef          	jal	4dac <exec>
  if(ret != -1){
    1f42:	57fd                	li	a5,-1
    1f44:	06f51a63          	bne	a0,a5,1fb8 <copyinstr3+0xee>
}
    1f48:	70a2                	ld	ra,40(sp)
    1f4a:	7402                	ld	s0,32(sp)
    1f4c:	64e2                	ld	s1,24(sp)
    1f4e:	6145                	addi	sp,sp,48
    1f50:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    1f52:	0347d513          	srli	a0,a5,0x34
    1f56:	6785                	lui	a5,0x1
    1f58:	40a7853b          	subw	a0,a5,a0
    1f5c:	5e5020ef          	jal	4d40 <sbrk>
    1f60:	b759                	j	1ee6 <copyinstr3+0x1c>
    printf("oops\n");
    1f62:	00004517          	auipc	a0,0x4
    1f66:	01e50513          	addi	a0,a0,30 # 5f80 <malloc+0xd30>
    1f6a:	232030ef          	jal	519c <printf>
    exit(1);
    1f6e:	4505                	li	a0,1
    1f70:	605020ef          	jal	4d74 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    1f74:	862a                	mv	a2,a0
    1f76:	85a6                	mv	a1,s1
    1f78:	00004517          	auipc	a0,0x4
    1f7c:	bc050513          	addi	a0,a0,-1088 # 5b38 <malloc+0x8e8>
    1f80:	21c030ef          	jal	519c <printf>
    exit(1);
    1f84:	4505                	li	a0,1
    1f86:	5ef020ef          	jal	4d74 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1f8a:	862a                	mv	a2,a0
    1f8c:	85a6                	mv	a1,s1
    1f8e:	00004517          	auipc	a0,0x4
    1f92:	bca50513          	addi	a0,a0,-1078 # 5b58 <malloc+0x908>
    1f96:	206030ef          	jal	519c <printf>
    exit(1);
    1f9a:	4505                	li	a0,1
    1f9c:	5d9020ef          	jal	4d74 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1fa0:	86aa                	mv	a3,a0
    1fa2:	8626                	mv	a2,s1
    1fa4:	85a6                	mv	a1,s1
    1fa6:	00004517          	auipc	a0,0x4
    1faa:	bd250513          	addi	a0,a0,-1070 # 5b78 <malloc+0x928>
    1fae:	1ee030ef          	jal	519c <printf>
    exit(1);
    1fb2:	4505                	li	a0,1
    1fb4:	5c1020ef          	jal	4d74 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1fb8:	567d                	li	a2,-1
    1fba:	85a6                	mv	a1,s1
    1fbc:	00004517          	auipc	a0,0x4
    1fc0:	be450513          	addi	a0,a0,-1052 # 5ba0 <malloc+0x950>
    1fc4:	1d8030ef          	jal	519c <printf>
    exit(1);
    1fc8:	4505                	li	a0,1
    1fca:	5ab020ef          	jal	4d74 <exit>

0000000000001fce <rwsbrk>:
{
    1fce:	1101                	addi	sp,sp,-32
    1fd0:	ec06                	sd	ra,24(sp)
    1fd2:	e822                	sd	s0,16(sp)
    1fd4:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    1fd6:	6509                	lui	a0,0x2
    1fd8:	569020ef          	jal	4d40 <sbrk>
  if(a == (uint64) SBRK_ERROR) {
    1fdc:	57fd                	li	a5,-1
    1fde:	04f50a63          	beq	a0,a5,2032 <rwsbrk+0x64>
    1fe2:	e426                	sd	s1,8(sp)
    1fe4:	84aa                	mv	s1,a0
  if (sbrk(-8192) == SBRK_ERROR) {
    1fe6:	7579                	lui	a0,0xffffe
    1fe8:	559020ef          	jal	4d40 <sbrk>
    1fec:	57fd                	li	a5,-1
    1fee:	04f50d63          	beq	a0,a5,2048 <rwsbrk+0x7a>
    1ff2:	e04a                	sd	s2,0(sp)
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    1ff4:	20100593          	li	a1,513
    1ff8:	00004517          	auipc	a0,0x4
    1ffc:	fc850513          	addi	a0,a0,-56 # 5fc0 <malloc+0xd70>
    2000:	5b5020ef          	jal	4db4 <open>
    2004:	892a                	mv	s2,a0
  if(fd < 0){
    2006:	04054b63          	bltz	a0,205c <rwsbrk+0x8e>
  n = write(fd, (void*)(a+PGSIZE), 1024);
    200a:	6785                	lui	a5,0x1
    200c:	94be                	add	s1,s1,a5
    200e:	40000613          	li	a2,1024
    2012:	85a6                	mv	a1,s1
    2014:	581020ef          	jal	4d94 <write>
    2018:	862a                	mv	a2,a0
  if(n >= 0){
    201a:	04054a63          	bltz	a0,206e <rwsbrk+0xa0>
    printf("write(fd, %p, 1024) returned %d, not -1\n", (void*)a+PGSIZE, n);
    201e:	85a6                	mv	a1,s1
    2020:	00004517          	auipc	a0,0x4
    2024:	fc050513          	addi	a0,a0,-64 # 5fe0 <malloc+0xd90>
    2028:	174030ef          	jal	519c <printf>
    exit(1);
    202c:	4505                	li	a0,1
    202e:	547020ef          	jal	4d74 <exit>
    2032:	e426                	sd	s1,8(sp)
    2034:	e04a                	sd	s2,0(sp)
    printf("sbrk(rwsbrk) failed\n");
    2036:	00004517          	auipc	a0,0x4
    203a:	f5250513          	addi	a0,a0,-174 # 5f88 <malloc+0xd38>
    203e:	15e030ef          	jal	519c <printf>
    exit(1);
    2042:	4505                	li	a0,1
    2044:	531020ef          	jal	4d74 <exit>
    2048:	e04a                	sd	s2,0(sp)
    printf("sbrk(rwsbrk) shrink failed\n");
    204a:	00004517          	auipc	a0,0x4
    204e:	f5650513          	addi	a0,a0,-170 # 5fa0 <malloc+0xd50>
    2052:	14a030ef          	jal	519c <printf>
    exit(1);
    2056:	4505                	li	a0,1
    2058:	51d020ef          	jal	4d74 <exit>
    printf("open(rwsbrk) failed\n");
    205c:	00004517          	auipc	a0,0x4
    2060:	f6c50513          	addi	a0,a0,-148 # 5fc8 <malloc+0xd78>
    2064:	138030ef          	jal	519c <printf>
    exit(1);
    2068:	4505                	li	a0,1
    206a:	50b020ef          	jal	4d74 <exit>
  close(fd);
    206e:	854a                	mv	a0,s2
    2070:	52d020ef          	jal	4d9c <close>
  unlink("rwsbrk");
    2074:	00004517          	auipc	a0,0x4
    2078:	f4c50513          	addi	a0,a0,-180 # 5fc0 <malloc+0xd70>
    207c:	549020ef          	jal	4dc4 <unlink>
  fd = open("README", O_RDONLY);
    2080:	4581                	li	a1,0
    2082:	00003517          	auipc	a0,0x3
    2086:	4de50513          	addi	a0,a0,1246 # 5560 <malloc+0x310>
    208a:	52b020ef          	jal	4db4 <open>
    208e:	892a                	mv	s2,a0
  if(fd < 0){
    2090:	02054363          	bltz	a0,20b6 <rwsbrk+0xe8>
  n = read(fd, (void*)(a+PGSIZE), 10);
    2094:	4629                	li	a2,10
    2096:	85a6                	mv	a1,s1
    2098:	4f5020ef          	jal	4d8c <read>
    209c:	862a                	mv	a2,a0
  if(n >= 0){
    209e:	02054563          	bltz	a0,20c8 <rwsbrk+0xfa>
    printf("read(fd, %p, 10) returned %d, not -1\n", (void*)a+PGSIZE, n);
    20a2:	85a6                	mv	a1,s1
    20a4:	00004517          	auipc	a0,0x4
    20a8:	f6c50513          	addi	a0,a0,-148 # 6010 <malloc+0xdc0>
    20ac:	0f0030ef          	jal	519c <printf>
    exit(1);
    20b0:	4505                	li	a0,1
    20b2:	4c3020ef          	jal	4d74 <exit>
    printf("open(README) failed\n");
    20b6:	00003517          	auipc	a0,0x3
    20ba:	4b250513          	addi	a0,a0,1202 # 5568 <malloc+0x318>
    20be:	0de030ef          	jal	519c <printf>
    exit(1);
    20c2:	4505                	li	a0,1
    20c4:	4b1020ef          	jal	4d74 <exit>
  close(fd);
    20c8:	854a                	mv	a0,s2
    20ca:	4d3020ef          	jal	4d9c <close>
  exit(0);
    20ce:	4501                	li	a0,0
    20d0:	4a5020ef          	jal	4d74 <exit>

00000000000020d4 <sbrkbasic>:
{
    20d4:	7139                	addi	sp,sp,-64
    20d6:	fc06                	sd	ra,56(sp)
    20d8:	f822                	sd	s0,48(sp)
    20da:	ec4e                	sd	s3,24(sp)
    20dc:	0080                	addi	s0,sp,64
    20de:	89aa                	mv	s3,a0
  pid = fork();
    20e0:	48d020ef          	jal	4d6c <fork>
  if(pid < 0){
    20e4:	02054b63          	bltz	a0,211a <sbrkbasic+0x46>
  if(pid == 0){
    20e8:	e939                	bnez	a0,213e <sbrkbasic+0x6a>
    a = sbrk(TOOMUCH);
    20ea:	40000537          	lui	a0,0x40000
    20ee:	453020ef          	jal	4d40 <sbrk>
    if(a == (char*)SBRK_ERROR){
    20f2:	57fd                	li	a5,-1
    20f4:	02f50f63          	beq	a0,a5,2132 <sbrkbasic+0x5e>
    20f8:	f426                	sd	s1,40(sp)
    20fa:	f04a                	sd	s2,32(sp)
    20fc:	e852                	sd	s4,16(sp)
    for(b = a; b < a+TOOMUCH; b += PGSIZE){
    20fe:	400007b7          	lui	a5,0x40000
    2102:	97aa                	add	a5,a5,a0
      *b = 99;
    2104:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += PGSIZE){
    2108:	6705                	lui	a4,0x1
      *b = 99;
    210a:	00d50023          	sb	a3,0(a0) # 40000000 <base+0x3fff0348>
    for(b = a; b < a+TOOMUCH; b += PGSIZE){
    210e:	953a                	add	a0,a0,a4
    2110:	fef51de3          	bne	a0,a5,210a <sbrkbasic+0x36>
    exit(1);
    2114:	4505                	li	a0,1
    2116:	45f020ef          	jal	4d74 <exit>
    211a:	f426                	sd	s1,40(sp)
    211c:	f04a                	sd	s2,32(sp)
    211e:	e852                	sd	s4,16(sp)
    printf("fork failed in sbrkbasic\n");
    2120:	00004517          	auipc	a0,0x4
    2124:	f1850513          	addi	a0,a0,-232 # 6038 <malloc+0xde8>
    2128:	074030ef          	jal	519c <printf>
    exit(1);
    212c:	4505                	li	a0,1
    212e:	447020ef          	jal	4d74 <exit>
    2132:	f426                	sd	s1,40(sp)
    2134:	f04a                	sd	s2,32(sp)
    2136:	e852                	sd	s4,16(sp)
      exit(0);
    2138:	4501                	li	a0,0
    213a:	43b020ef          	jal	4d74 <exit>
  wait(&xstatus);
    213e:	fcc40513          	addi	a0,s0,-52
    2142:	43b020ef          	jal	4d7c <wait>
  if(xstatus == 1){
    2146:	fcc42703          	lw	a4,-52(s0)
    214a:	4785                	li	a5,1
    214c:	00f70e63          	beq	a4,a5,2168 <sbrkbasic+0x94>
    2150:	f426                	sd	s1,40(sp)
    2152:	f04a                	sd	s2,32(sp)
    2154:	e852                	sd	s4,16(sp)
  a = sbrk(0);
    2156:	4501                	li	a0,0
    2158:	3e9020ef          	jal	4d40 <sbrk>
    215c:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    215e:	4901                	li	s2,0
    2160:	6a05                	lui	s4,0x1
    2162:	388a0a13          	addi	s4,s4,904 # 1388 <exectest+0x4a>
    2166:	a839                	j	2184 <sbrkbasic+0xb0>
    2168:	f426                	sd	s1,40(sp)
    216a:	f04a                	sd	s2,32(sp)
    216c:	e852                	sd	s4,16(sp)
    printf("%s: too much memory allocated!\n", s);
    216e:	85ce                	mv	a1,s3
    2170:	00004517          	auipc	a0,0x4
    2174:	ee850513          	addi	a0,a0,-280 # 6058 <malloc+0xe08>
    2178:	024030ef          	jal	519c <printf>
    exit(1);
    217c:	4505                	li	a0,1
    217e:	3f7020ef          	jal	4d74 <exit>
    2182:	84be                	mv	s1,a5
    b = sbrk(1);
    2184:	4505                	li	a0,1
    2186:	3bb020ef          	jal	4d40 <sbrk>
    if(b != a){
    218a:	04951263          	bne	a0,s1,21ce <sbrkbasic+0xfa>
    *b = 1;
    218e:	4785                	li	a5,1
    2190:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    2194:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    2198:	2905                	addiw	s2,s2,1
    219a:	ff4914e3          	bne	s2,s4,2182 <sbrkbasic+0xae>
  pid = fork();
    219e:	3cf020ef          	jal	4d6c <fork>
    21a2:	892a                	mv	s2,a0
  if(pid < 0){
    21a4:	04054263          	bltz	a0,21e8 <sbrkbasic+0x114>
  c = sbrk(1);
    21a8:	4505                	li	a0,1
    21aa:	397020ef          	jal	4d40 <sbrk>
  c = sbrk(1);
    21ae:	4505                	li	a0,1
    21b0:	391020ef          	jal	4d40 <sbrk>
  if(c != a + 1){
    21b4:	0489                	addi	s1,s1,2
    21b6:	04a48363          	beq	s1,a0,21fc <sbrkbasic+0x128>
    printf("%s: sbrk test failed post-fork\n", s);
    21ba:	85ce                	mv	a1,s3
    21bc:	00004517          	auipc	a0,0x4
    21c0:	efc50513          	addi	a0,a0,-260 # 60b8 <malloc+0xe68>
    21c4:	7d9020ef          	jal	519c <printf>
    exit(1);
    21c8:	4505                	li	a0,1
    21ca:	3ab020ef          	jal	4d74 <exit>
      printf("%s: sbrk test failed %d %p %p\n", s, i, a, b);
    21ce:	872a                	mv	a4,a0
    21d0:	86a6                	mv	a3,s1
    21d2:	864a                	mv	a2,s2
    21d4:	85ce                	mv	a1,s3
    21d6:	00004517          	auipc	a0,0x4
    21da:	ea250513          	addi	a0,a0,-350 # 6078 <malloc+0xe28>
    21de:	7bf020ef          	jal	519c <printf>
      exit(1);
    21e2:	4505                	li	a0,1
    21e4:	391020ef          	jal	4d74 <exit>
    printf("%s: sbrk test fork failed\n", s);
    21e8:	85ce                	mv	a1,s3
    21ea:	00004517          	auipc	a0,0x4
    21ee:	eae50513          	addi	a0,a0,-338 # 6098 <malloc+0xe48>
    21f2:	7ab020ef          	jal	519c <printf>
    exit(1);
    21f6:	4505                	li	a0,1
    21f8:	37d020ef          	jal	4d74 <exit>
  if(pid == 0)
    21fc:	00091563          	bnez	s2,2206 <sbrkbasic+0x132>
    exit(0);
    2200:	4501                	li	a0,0
    2202:	373020ef          	jal	4d74 <exit>
  wait(&xstatus);
    2206:	fcc40513          	addi	a0,s0,-52
    220a:	373020ef          	jal	4d7c <wait>
  exit(xstatus);
    220e:	fcc42503          	lw	a0,-52(s0)
    2212:	363020ef          	jal	4d74 <exit>

0000000000002216 <sbrkmuch>:
{
    2216:	7179                	addi	sp,sp,-48
    2218:	f406                	sd	ra,40(sp)
    221a:	f022                	sd	s0,32(sp)
    221c:	ec26                	sd	s1,24(sp)
    221e:	e84a                	sd	s2,16(sp)
    2220:	e44e                	sd	s3,8(sp)
    2222:	e052                	sd	s4,0(sp)
    2224:	1800                	addi	s0,sp,48
    2226:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    2228:	4501                	li	a0,0
    222a:	317020ef          	jal	4d40 <sbrk>
    222e:	892a                	mv	s2,a0
  a = sbrk(0);
    2230:	4501                	li	a0,0
    2232:	30f020ef          	jal	4d40 <sbrk>
    2236:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2238:	06400537          	lui	a0,0x6400
    223c:	9d05                	subw	a0,a0,s1
    223e:	303020ef          	jal	4d40 <sbrk>
  if (p != a) {
    2242:	08a49763          	bne	s1,a0,22d0 <sbrkmuch+0xba>
  *lastaddr = 99;
    2246:	064007b7          	lui	a5,0x6400
    224a:	06300713          	li	a4,99
    224e:	fee78fa3          	sb	a4,-1(a5) # 63fffff <base+0x63f0347>
  a = sbrk(0);
    2252:	4501                	li	a0,0
    2254:	2ed020ef          	jal	4d40 <sbrk>
    2258:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    225a:	757d                	lui	a0,0xfffff
    225c:	2e5020ef          	jal	4d40 <sbrk>
  if(c == (char*)SBRK_ERROR){
    2260:	57fd                	li	a5,-1
    2262:	08f50163          	beq	a0,a5,22e4 <sbrkmuch+0xce>
  c = sbrk(0);
    2266:	4501                	li	a0,0
    2268:	2d9020ef          	jal	4d40 <sbrk>
  if(c != a - PGSIZE){
    226c:	77fd                	lui	a5,0xfffff
    226e:	97a6                	add	a5,a5,s1
    2270:	08f51463          	bne	a0,a5,22f8 <sbrkmuch+0xe2>
  a = sbrk(0);
    2274:	4501                	li	a0,0
    2276:	2cb020ef          	jal	4d40 <sbrk>
    227a:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    227c:	6505                	lui	a0,0x1
    227e:	2c3020ef          	jal	4d40 <sbrk>
    2282:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    2284:	08a49663          	bne	s1,a0,2310 <sbrkmuch+0xfa>
    2288:	4501                	li	a0,0
    228a:	2b7020ef          	jal	4d40 <sbrk>
    228e:	6785                	lui	a5,0x1
    2290:	97a6                	add	a5,a5,s1
    2292:	06f51f63          	bne	a0,a5,2310 <sbrkmuch+0xfa>
  if(*lastaddr == 99){
    2296:	064007b7          	lui	a5,0x6400
    229a:	fff7c703          	lbu	a4,-1(a5) # 63fffff <base+0x63f0347>
    229e:	06300793          	li	a5,99
    22a2:	08f70363          	beq	a4,a5,2328 <sbrkmuch+0x112>
  a = sbrk(0);
    22a6:	4501                	li	a0,0
    22a8:	299020ef          	jal	4d40 <sbrk>
    22ac:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    22ae:	4501                	li	a0,0
    22b0:	291020ef          	jal	4d40 <sbrk>
    22b4:	40a9053b          	subw	a0,s2,a0
    22b8:	289020ef          	jal	4d40 <sbrk>
  if(c != a){
    22bc:	08a49063          	bne	s1,a0,233c <sbrkmuch+0x126>
}
    22c0:	70a2                	ld	ra,40(sp)
    22c2:	7402                	ld	s0,32(sp)
    22c4:	64e2                	ld	s1,24(sp)
    22c6:	6942                	ld	s2,16(sp)
    22c8:	69a2                	ld	s3,8(sp)
    22ca:	6a02                	ld	s4,0(sp)
    22cc:	6145                	addi	sp,sp,48
    22ce:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    22d0:	85ce                	mv	a1,s3
    22d2:	00004517          	auipc	a0,0x4
    22d6:	e0650513          	addi	a0,a0,-506 # 60d8 <malloc+0xe88>
    22da:	6c3020ef          	jal	519c <printf>
    exit(1);
    22de:	4505                	li	a0,1
    22e0:	295020ef          	jal	4d74 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    22e4:	85ce                	mv	a1,s3
    22e6:	00004517          	auipc	a0,0x4
    22ea:	e3a50513          	addi	a0,a0,-454 # 6120 <malloc+0xed0>
    22ee:	6af020ef          	jal	519c <printf>
    exit(1);
    22f2:	4505                	li	a0,1
    22f4:	281020ef          	jal	4d74 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %p c %p\n", s, a, c);
    22f8:	86aa                	mv	a3,a0
    22fa:	8626                	mv	a2,s1
    22fc:	85ce                	mv	a1,s3
    22fe:	00004517          	auipc	a0,0x4
    2302:	e4250513          	addi	a0,a0,-446 # 6140 <malloc+0xef0>
    2306:	697020ef          	jal	519c <printf>
    exit(1);
    230a:	4505                	li	a0,1
    230c:	269020ef          	jal	4d74 <exit>
    printf("%s: sbrk re-allocation failed, a %p c %p\n", s, a, c);
    2310:	86d2                	mv	a3,s4
    2312:	8626                	mv	a2,s1
    2314:	85ce                	mv	a1,s3
    2316:	00004517          	auipc	a0,0x4
    231a:	e6a50513          	addi	a0,a0,-406 # 6180 <malloc+0xf30>
    231e:	67f020ef          	jal	519c <printf>
    exit(1);
    2322:	4505                	li	a0,1
    2324:	251020ef          	jal	4d74 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    2328:	85ce                	mv	a1,s3
    232a:	00004517          	auipc	a0,0x4
    232e:	e8650513          	addi	a0,a0,-378 # 61b0 <malloc+0xf60>
    2332:	66b020ef          	jal	519c <printf>
    exit(1);
    2336:	4505                	li	a0,1
    2338:	23d020ef          	jal	4d74 <exit>
    printf("%s: sbrk downsize failed, a %p c %p\n", s, a, c);
    233c:	86aa                	mv	a3,a0
    233e:	8626                	mv	a2,s1
    2340:	85ce                	mv	a1,s3
    2342:	00004517          	auipc	a0,0x4
    2346:	ea650513          	addi	a0,a0,-346 # 61e8 <malloc+0xf98>
    234a:	653020ef          	jal	519c <printf>
    exit(1);
    234e:	4505                	li	a0,1
    2350:	225020ef          	jal	4d74 <exit>

0000000000002354 <sbrkarg>:
{
    2354:	7179                	addi	sp,sp,-48
    2356:	f406                	sd	ra,40(sp)
    2358:	f022                	sd	s0,32(sp)
    235a:	ec26                	sd	s1,24(sp)
    235c:	e84a                	sd	s2,16(sp)
    235e:	e44e                	sd	s3,8(sp)
    2360:	1800                	addi	s0,sp,48
    2362:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2364:	6505                	lui	a0,0x1
    2366:	1db020ef          	jal	4d40 <sbrk>
    236a:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    236c:	20100593          	li	a1,513
    2370:	00004517          	auipc	a0,0x4
    2374:	ea050513          	addi	a0,a0,-352 # 6210 <malloc+0xfc0>
    2378:	23d020ef          	jal	4db4 <open>
    237c:	84aa                	mv	s1,a0
  unlink("sbrk");
    237e:	00004517          	auipc	a0,0x4
    2382:	e9250513          	addi	a0,a0,-366 # 6210 <malloc+0xfc0>
    2386:	23f020ef          	jal	4dc4 <unlink>
  if(fd < 0)  {
    238a:	0204c963          	bltz	s1,23bc <sbrkarg+0x68>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    238e:	6605                	lui	a2,0x1
    2390:	85ca                	mv	a1,s2
    2392:	8526                	mv	a0,s1
    2394:	201020ef          	jal	4d94 <write>
    2398:	02054c63          	bltz	a0,23d0 <sbrkarg+0x7c>
  close(fd);
    239c:	8526                	mv	a0,s1
    239e:	1ff020ef          	jal	4d9c <close>
  a = sbrk(PGSIZE);
    23a2:	6505                	lui	a0,0x1
    23a4:	19d020ef          	jal	4d40 <sbrk>
  if(pipe((int *) a) != 0){
    23a8:	1dd020ef          	jal	4d84 <pipe>
    23ac:	ed05                	bnez	a0,23e4 <sbrkarg+0x90>
}
    23ae:	70a2                	ld	ra,40(sp)
    23b0:	7402                	ld	s0,32(sp)
    23b2:	64e2                	ld	s1,24(sp)
    23b4:	6942                	ld	s2,16(sp)
    23b6:	69a2                	ld	s3,8(sp)
    23b8:	6145                	addi	sp,sp,48
    23ba:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    23bc:	85ce                	mv	a1,s3
    23be:	00004517          	auipc	a0,0x4
    23c2:	e5a50513          	addi	a0,a0,-422 # 6218 <malloc+0xfc8>
    23c6:	5d7020ef          	jal	519c <printf>
    exit(1);
    23ca:	4505                	li	a0,1
    23cc:	1a9020ef          	jal	4d74 <exit>
    printf("%s: write sbrk failed\n", s);
    23d0:	85ce                	mv	a1,s3
    23d2:	00004517          	auipc	a0,0x4
    23d6:	e5e50513          	addi	a0,a0,-418 # 6230 <malloc+0xfe0>
    23da:	5c3020ef          	jal	519c <printf>
    exit(1);
    23de:	4505                	li	a0,1
    23e0:	195020ef          	jal	4d74 <exit>
    printf("%s: pipe() failed\n", s);
    23e4:	85ce                	mv	a1,s3
    23e6:	00004517          	auipc	a0,0x4
    23ea:	93a50513          	addi	a0,a0,-1734 # 5d20 <malloc+0xad0>
    23ee:	5af020ef          	jal	519c <printf>
    exit(1);
    23f2:	4505                	li	a0,1
    23f4:	181020ef          	jal	4d74 <exit>

00000000000023f8 <argptest>:
{
    23f8:	1101                	addi	sp,sp,-32
    23fa:	ec06                	sd	ra,24(sp)
    23fc:	e822                	sd	s0,16(sp)
    23fe:	e426                	sd	s1,8(sp)
    2400:	e04a                	sd	s2,0(sp)
    2402:	1000                	addi	s0,sp,32
    2404:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    2406:	4581                	li	a1,0
    2408:	00004517          	auipc	a0,0x4
    240c:	e4050513          	addi	a0,a0,-448 # 6248 <malloc+0xff8>
    2410:	1a5020ef          	jal	4db4 <open>
  if (fd < 0) {
    2414:	02054563          	bltz	a0,243e <argptest+0x46>
    2418:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    241a:	4501                	li	a0,0
    241c:	125020ef          	jal	4d40 <sbrk>
    2420:	567d                	li	a2,-1
    2422:	fff50593          	addi	a1,a0,-1
    2426:	8526                	mv	a0,s1
    2428:	165020ef          	jal	4d8c <read>
  close(fd);
    242c:	8526                	mv	a0,s1
    242e:	16f020ef          	jal	4d9c <close>
}
    2432:	60e2                	ld	ra,24(sp)
    2434:	6442                	ld	s0,16(sp)
    2436:	64a2                	ld	s1,8(sp)
    2438:	6902                	ld	s2,0(sp)
    243a:	6105                	addi	sp,sp,32
    243c:	8082                	ret
    printf("%s: open failed\n", s);
    243e:	85ca                	mv	a1,s2
    2440:	00003517          	auipc	a0,0x3
    2444:	7f050513          	addi	a0,a0,2032 # 5c30 <malloc+0x9e0>
    2448:	555020ef          	jal	519c <printf>
    exit(1);
    244c:	4505                	li	a0,1
    244e:	127020ef          	jal	4d74 <exit>

0000000000002452 <sbrkbugs>:
{
    2452:	1141                	addi	sp,sp,-16
    2454:	e406                	sd	ra,8(sp)
    2456:	e022                	sd	s0,0(sp)
    2458:	0800                	addi	s0,sp,16
  int pid = fork();
    245a:	113020ef          	jal	4d6c <fork>
  if(pid < 0){
    245e:	00054c63          	bltz	a0,2476 <sbrkbugs+0x24>
  if(pid == 0){
    2462:	e11d                	bnez	a0,2488 <sbrkbugs+0x36>
    int sz = (uint64) sbrk(0);
    2464:	0dd020ef          	jal	4d40 <sbrk>
    sbrk(-sz);
    2468:	40a0053b          	negw	a0,a0
    246c:	0d5020ef          	jal	4d40 <sbrk>
    exit(0);
    2470:	4501                	li	a0,0
    2472:	103020ef          	jal	4d74 <exit>
    printf("fork failed\n");
    2476:	00005517          	auipc	a0,0x5
    247a:	d4a50513          	addi	a0,a0,-694 # 71c0 <malloc+0x1f70>
    247e:	51f020ef          	jal	519c <printf>
    exit(1);
    2482:	4505                	li	a0,1
    2484:	0f1020ef          	jal	4d74 <exit>
  wait(0);
    2488:	4501                	li	a0,0
    248a:	0f3020ef          	jal	4d7c <wait>
  pid = fork();
    248e:	0df020ef          	jal	4d6c <fork>
  if(pid < 0){
    2492:	00054f63          	bltz	a0,24b0 <sbrkbugs+0x5e>
  if(pid == 0){
    2496:	e515                	bnez	a0,24c2 <sbrkbugs+0x70>
    int sz = (uint64) sbrk(0);
    2498:	0a9020ef          	jal	4d40 <sbrk>
    sbrk(-(sz - 3500));
    249c:	6785                	lui	a5,0x1
    249e:	dac7879b          	addiw	a5,a5,-596 # dac <linktest+0x138>
    24a2:	40a7853b          	subw	a0,a5,a0
    24a6:	09b020ef          	jal	4d40 <sbrk>
    exit(0);
    24aa:	4501                	li	a0,0
    24ac:	0c9020ef          	jal	4d74 <exit>
    printf("fork failed\n");
    24b0:	00005517          	auipc	a0,0x5
    24b4:	d1050513          	addi	a0,a0,-752 # 71c0 <malloc+0x1f70>
    24b8:	4e5020ef          	jal	519c <printf>
    exit(1);
    24bc:	4505                	li	a0,1
    24be:	0b7020ef          	jal	4d74 <exit>
  wait(0);
    24c2:	4501                	li	a0,0
    24c4:	0b9020ef          	jal	4d7c <wait>
  pid = fork();
    24c8:	0a5020ef          	jal	4d6c <fork>
  if(pid < 0){
    24cc:	02054263          	bltz	a0,24f0 <sbrkbugs+0x9e>
  if(pid == 0){
    24d0:	e90d                	bnez	a0,2502 <sbrkbugs+0xb0>
    sbrk((10*PGSIZE + 2048) - (uint64)sbrk(0));
    24d2:	06f020ef          	jal	4d40 <sbrk>
    24d6:	67ad                	lui	a5,0xb
    24d8:	8007879b          	addiw	a5,a5,-2048 # a800 <uninit+0x258>
    24dc:	40a7853b          	subw	a0,a5,a0
    24e0:	061020ef          	jal	4d40 <sbrk>
    sbrk(-10);
    24e4:	5559                	li	a0,-10
    24e6:	05b020ef          	jal	4d40 <sbrk>
    exit(0);
    24ea:	4501                	li	a0,0
    24ec:	089020ef          	jal	4d74 <exit>
    printf("fork failed\n");
    24f0:	00005517          	auipc	a0,0x5
    24f4:	cd050513          	addi	a0,a0,-816 # 71c0 <malloc+0x1f70>
    24f8:	4a5020ef          	jal	519c <printf>
    exit(1);
    24fc:	4505                	li	a0,1
    24fe:	077020ef          	jal	4d74 <exit>
  wait(0);
    2502:	4501                	li	a0,0
    2504:	079020ef          	jal	4d7c <wait>
  exit(0);
    2508:	4501                	li	a0,0
    250a:	06b020ef          	jal	4d74 <exit>

000000000000250e <sbrklast>:
{
    250e:	7179                	addi	sp,sp,-48
    2510:	f406                	sd	ra,40(sp)
    2512:	f022                	sd	s0,32(sp)
    2514:	ec26                	sd	s1,24(sp)
    2516:	e84a                	sd	s2,16(sp)
    2518:	e44e                	sd	s3,8(sp)
    251a:	e052                	sd	s4,0(sp)
    251c:	1800                	addi	s0,sp,48
  uint64 top = (uint64) sbrk(0);
    251e:	4501                	li	a0,0
    2520:	021020ef          	jal	4d40 <sbrk>
  if((top % PGSIZE) != 0)
    2524:	03451793          	slli	a5,a0,0x34
    2528:	ebad                	bnez	a5,259a <sbrklast+0x8c>
  sbrk(PGSIZE);
    252a:	6505                	lui	a0,0x1
    252c:	015020ef          	jal	4d40 <sbrk>
  sbrk(10);
    2530:	4529                	li	a0,10
    2532:	00f020ef          	jal	4d40 <sbrk>
  sbrk(-20);
    2536:	5531                	li	a0,-20
    2538:	009020ef          	jal	4d40 <sbrk>
  top = (uint64) sbrk(0);
    253c:	4501                	li	a0,0
    253e:	003020ef          	jal	4d40 <sbrk>
    2542:	84aa                	mv	s1,a0
  char *p = (char *) (top - 64);
    2544:	fc050913          	addi	s2,a0,-64 # fc0 <bigdir+0x122>
  p[0] = 'x';
    2548:	07800a13          	li	s4,120
    254c:	fd450023          	sb	s4,-64(a0)
  p[1] = '\0';
    2550:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR|O_CREATE);
    2554:	20200593          	li	a1,514
    2558:	854a                	mv	a0,s2
    255a:	05b020ef          	jal	4db4 <open>
    255e:	89aa                	mv	s3,a0
  write(fd, p, 1);
    2560:	4605                	li	a2,1
    2562:	85ca                	mv	a1,s2
    2564:	031020ef          	jal	4d94 <write>
  close(fd);
    2568:	854e                	mv	a0,s3
    256a:	033020ef          	jal	4d9c <close>
  fd = open(p, O_RDWR);
    256e:	4589                	li	a1,2
    2570:	854a                	mv	a0,s2
    2572:	043020ef          	jal	4db4 <open>
  p[0] = '\0';
    2576:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    257a:	4605                	li	a2,1
    257c:	85ca                	mv	a1,s2
    257e:	00f020ef          	jal	4d8c <read>
  if(p[0] != 'x')
    2582:	fc04c783          	lbu	a5,-64(s1)
    2586:	03479263          	bne	a5,s4,25aa <sbrklast+0x9c>
}
    258a:	70a2                	ld	ra,40(sp)
    258c:	7402                	ld	s0,32(sp)
    258e:	64e2                	ld	s1,24(sp)
    2590:	6942                	ld	s2,16(sp)
    2592:	69a2                	ld	s3,8(sp)
    2594:	6a02                	ld	s4,0(sp)
    2596:	6145                	addi	sp,sp,48
    2598:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    259a:	0347d513          	srli	a0,a5,0x34
    259e:	6785                	lui	a5,0x1
    25a0:	40a7853b          	subw	a0,a5,a0
    25a4:	79c020ef          	jal	4d40 <sbrk>
    25a8:	b749                	j	252a <sbrklast+0x1c>
    exit(1);
    25aa:	4505                	li	a0,1
    25ac:	7c8020ef          	jal	4d74 <exit>

00000000000025b0 <sbrk8000>:
{
    25b0:	1141                	addi	sp,sp,-16
    25b2:	e406                	sd	ra,8(sp)
    25b4:	e022                	sd	s0,0(sp)
    25b6:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    25b8:	80000537          	lui	a0,0x80000
    25bc:	0511                	addi	a0,a0,4 # ffffffff80000004 <base+0xffffffff7fff034c>
    25be:	782020ef          	jal	4d40 <sbrk>
  volatile char *top = sbrk(0);
    25c2:	4501                	li	a0,0
    25c4:	77c020ef          	jal	4d40 <sbrk>
  *(top-1) = *(top-1) + 1;
    25c8:	fff54783          	lbu	a5,-1(a0)
    25cc:	2785                	addiw	a5,a5,1 # 1001 <badarg+0x1>
    25ce:	0ff7f793          	zext.b	a5,a5
    25d2:	fef50fa3          	sb	a5,-1(a0)
}
    25d6:	60a2                	ld	ra,8(sp)
    25d8:	6402                	ld	s0,0(sp)
    25da:	0141                	addi	sp,sp,16
    25dc:	8082                	ret

00000000000025de <execout>:
{
    25de:	715d                	addi	sp,sp,-80
    25e0:	e486                	sd	ra,72(sp)
    25e2:	e0a2                	sd	s0,64(sp)
    25e4:	fc26                	sd	s1,56(sp)
    25e6:	f84a                	sd	s2,48(sp)
    25e8:	f44e                	sd	s3,40(sp)
    25ea:	f052                	sd	s4,32(sp)
    25ec:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    25ee:	4901                	li	s2,0
    25f0:	49bd                	li	s3,15
    int pid = fork();
    25f2:	77a020ef          	jal	4d6c <fork>
    25f6:	84aa                	mv	s1,a0
    if(pid < 0){
    25f8:	00054c63          	bltz	a0,2610 <execout+0x32>
    } else if(pid == 0){
    25fc:	c11d                	beqz	a0,2622 <execout+0x44>
      wait((int*)0);
    25fe:	4501                	li	a0,0
    2600:	77c020ef          	jal	4d7c <wait>
  for(int avail = 0; avail < 15; avail++){
    2604:	2905                	addiw	s2,s2,1
    2606:	ff3916e3          	bne	s2,s3,25f2 <execout+0x14>
  exit(0);
    260a:	4501                	li	a0,0
    260c:	768020ef          	jal	4d74 <exit>
      printf("fork failed\n");
    2610:	00005517          	auipc	a0,0x5
    2614:	bb050513          	addi	a0,a0,-1104 # 71c0 <malloc+0x1f70>
    2618:	385020ef          	jal	519c <printf>
      exit(1);
    261c:	4505                	li	a0,1
    261e:	756020ef          	jal	4d74 <exit>
        if(a == SBRK_ERROR)
    2622:	59fd                	li	s3,-1
        *(a + PGSIZE - 1) = 1;
    2624:	4a05                	li	s4,1
        char *a = sbrk(PGSIZE);
    2626:	6505                	lui	a0,0x1
    2628:	718020ef          	jal	4d40 <sbrk>
        if(a == SBRK_ERROR)
    262c:	01350763          	beq	a0,s3,263a <execout+0x5c>
        *(a + PGSIZE - 1) = 1;
    2630:	6785                	lui	a5,0x1
    2632:	953e                	add	a0,a0,a5
    2634:	ff450fa3          	sb	s4,-1(a0) # fff <pgbug+0x2b>
      while(1){
    2638:	b7fd                	j	2626 <execout+0x48>
      for(int i = 0; i < avail; i++)
    263a:	01205863          	blez	s2,264a <execout+0x6c>
        sbrk(-PGSIZE);
    263e:	757d                	lui	a0,0xfffff
    2640:	700020ef          	jal	4d40 <sbrk>
      for(int i = 0; i < avail; i++)
    2644:	2485                	addiw	s1,s1,1
    2646:	ff249ce3          	bne	s1,s2,263e <execout+0x60>
      close(1);
    264a:	4505                	li	a0,1
    264c:	750020ef          	jal	4d9c <close>
      char *args[] = { "echo", "x", 0 };
    2650:	00003517          	auipc	a0,0x3
    2654:	d3850513          	addi	a0,a0,-712 # 5388 <malloc+0x138>
    2658:	faa43c23          	sd	a0,-72(s0)
    265c:	00003797          	auipc	a5,0x3
    2660:	d9c78793          	addi	a5,a5,-612 # 53f8 <malloc+0x1a8>
    2664:	fcf43023          	sd	a5,-64(s0)
    2668:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    266c:	fb840593          	addi	a1,s0,-72
    2670:	73c020ef          	jal	4dac <exec>
      exit(0);
    2674:	4501                	li	a0,0
    2676:	6fe020ef          	jal	4d74 <exit>

000000000000267a <fourteen>:
{
    267a:	1101                	addi	sp,sp,-32
    267c:	ec06                	sd	ra,24(sp)
    267e:	e822                	sd	s0,16(sp)
    2680:	e426                	sd	s1,8(sp)
    2682:	1000                	addi	s0,sp,32
    2684:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2686:	00004517          	auipc	a0,0x4
    268a:	d9a50513          	addi	a0,a0,-614 # 6420 <malloc+0x11d0>
    268e:	74e020ef          	jal	4ddc <mkdir>
    2692:	e555                	bnez	a0,273e <fourteen+0xc4>
  if(mkdir("12345678901234/123456789012345") != 0){
    2694:	00004517          	auipc	a0,0x4
    2698:	be450513          	addi	a0,a0,-1052 # 6278 <malloc+0x1028>
    269c:	740020ef          	jal	4ddc <mkdir>
    26a0:	e94d                	bnez	a0,2752 <fourteen+0xd8>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    26a2:	20000593          	li	a1,512
    26a6:	00004517          	auipc	a0,0x4
    26aa:	c2a50513          	addi	a0,a0,-982 # 62d0 <malloc+0x1080>
    26ae:	706020ef          	jal	4db4 <open>
  if(fd < 0){
    26b2:	0a054a63          	bltz	a0,2766 <fourteen+0xec>
  close(fd);
    26b6:	6e6020ef          	jal	4d9c <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    26ba:	4581                	li	a1,0
    26bc:	00004517          	auipc	a0,0x4
    26c0:	c8c50513          	addi	a0,a0,-884 # 6348 <malloc+0x10f8>
    26c4:	6f0020ef          	jal	4db4 <open>
  if(fd < 0){
    26c8:	0a054963          	bltz	a0,277a <fourteen+0x100>
  close(fd);
    26cc:	6d0020ef          	jal	4d9c <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    26d0:	00004517          	auipc	a0,0x4
    26d4:	ce850513          	addi	a0,a0,-792 # 63b8 <malloc+0x1168>
    26d8:	704020ef          	jal	4ddc <mkdir>
    26dc:	c94d                	beqz	a0,278e <fourteen+0x114>
  if(mkdir("123456789012345/12345678901234") == 0){
    26de:	00004517          	auipc	a0,0x4
    26e2:	d3250513          	addi	a0,a0,-718 # 6410 <malloc+0x11c0>
    26e6:	6f6020ef          	jal	4ddc <mkdir>
    26ea:	cd45                	beqz	a0,27a2 <fourteen+0x128>
  unlink("123456789012345/12345678901234");
    26ec:	00004517          	auipc	a0,0x4
    26f0:	d2450513          	addi	a0,a0,-732 # 6410 <malloc+0x11c0>
    26f4:	6d0020ef          	jal	4dc4 <unlink>
  unlink("12345678901234/12345678901234");
    26f8:	00004517          	auipc	a0,0x4
    26fc:	cc050513          	addi	a0,a0,-832 # 63b8 <malloc+0x1168>
    2700:	6c4020ef          	jal	4dc4 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    2704:	00004517          	auipc	a0,0x4
    2708:	c4450513          	addi	a0,a0,-956 # 6348 <malloc+0x10f8>
    270c:	6b8020ef          	jal	4dc4 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    2710:	00004517          	auipc	a0,0x4
    2714:	bc050513          	addi	a0,a0,-1088 # 62d0 <malloc+0x1080>
    2718:	6ac020ef          	jal	4dc4 <unlink>
  unlink("12345678901234/123456789012345");
    271c:	00004517          	auipc	a0,0x4
    2720:	b5c50513          	addi	a0,a0,-1188 # 6278 <malloc+0x1028>
    2724:	6a0020ef          	jal	4dc4 <unlink>
  unlink("12345678901234");
    2728:	00004517          	auipc	a0,0x4
    272c:	cf850513          	addi	a0,a0,-776 # 6420 <malloc+0x11d0>
    2730:	694020ef          	jal	4dc4 <unlink>
}
    2734:	60e2                	ld	ra,24(sp)
    2736:	6442                	ld	s0,16(sp)
    2738:	64a2                	ld	s1,8(sp)
    273a:	6105                	addi	sp,sp,32
    273c:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    273e:	85a6                	mv	a1,s1
    2740:	00004517          	auipc	a0,0x4
    2744:	b1050513          	addi	a0,a0,-1264 # 6250 <malloc+0x1000>
    2748:	255020ef          	jal	519c <printf>
    exit(1);
    274c:	4505                	li	a0,1
    274e:	626020ef          	jal	4d74 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    2752:	85a6                	mv	a1,s1
    2754:	00004517          	auipc	a0,0x4
    2758:	b4450513          	addi	a0,a0,-1212 # 6298 <malloc+0x1048>
    275c:	241020ef          	jal	519c <printf>
    exit(1);
    2760:	4505                	li	a0,1
    2762:	612020ef          	jal	4d74 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2766:	85a6                	mv	a1,s1
    2768:	00004517          	auipc	a0,0x4
    276c:	b9850513          	addi	a0,a0,-1128 # 6300 <malloc+0x10b0>
    2770:	22d020ef          	jal	519c <printf>
    exit(1);
    2774:	4505                	li	a0,1
    2776:	5fe020ef          	jal	4d74 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    277a:	85a6                	mv	a1,s1
    277c:	00004517          	auipc	a0,0x4
    2780:	bfc50513          	addi	a0,a0,-1028 # 6378 <malloc+0x1128>
    2784:	219020ef          	jal	519c <printf>
    exit(1);
    2788:	4505                	li	a0,1
    278a:	5ea020ef          	jal	4d74 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    278e:	85a6                	mv	a1,s1
    2790:	00004517          	auipc	a0,0x4
    2794:	c4850513          	addi	a0,a0,-952 # 63d8 <malloc+0x1188>
    2798:	205020ef          	jal	519c <printf>
    exit(1);
    279c:	4505                	li	a0,1
    279e:	5d6020ef          	jal	4d74 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    27a2:	85a6                	mv	a1,s1
    27a4:	00004517          	auipc	a0,0x4
    27a8:	c8c50513          	addi	a0,a0,-884 # 6430 <malloc+0x11e0>
    27ac:	1f1020ef          	jal	519c <printf>
    exit(1);
    27b0:	4505                	li	a0,1
    27b2:	5c2020ef          	jal	4d74 <exit>

00000000000027b6 <diskfull>:
{
    27b6:	b8010113          	addi	sp,sp,-1152
    27ba:	46113c23          	sd	ra,1144(sp)
    27be:	46813823          	sd	s0,1136(sp)
    27c2:	46913423          	sd	s1,1128(sp)
    27c6:	47213023          	sd	s2,1120(sp)
    27ca:	45313c23          	sd	s3,1112(sp)
    27ce:	45413823          	sd	s4,1104(sp)
    27d2:	45513423          	sd	s5,1096(sp)
    27d6:	45613023          	sd	s6,1088(sp)
    27da:	43713c23          	sd	s7,1080(sp)
    27de:	43813823          	sd	s8,1072(sp)
    27e2:	43913423          	sd	s9,1064(sp)
    27e6:	48010413          	addi	s0,sp,1152
    27ea:	8caa                	mv	s9,a0
  unlink("diskfulldir");
    27ec:	00004517          	auipc	a0,0x4
    27f0:	c7c50513          	addi	a0,a0,-900 # 6468 <malloc+0x1218>
    27f4:	5d0020ef          	jal	4dc4 <unlink>
    27f8:	03000993          	li	s3,48
    name[0] = 'b';
    27fc:	06200b13          	li	s6,98
    name[1] = 'i';
    2800:	06900a93          	li	s5,105
    name[2] = 'g';
    2804:	06700a13          	li	s4,103
    2808:	10c00b93          	li	s7,268
  for(fi = 0; done == 0 && '0' + fi < 0177; fi++){
    280c:	07f00c13          	li	s8,127
    2810:	aab9                	j	296e <diskfull+0x1b8>
      printf("%s: could not create file %s\n", s, name);
    2812:	b8040613          	addi	a2,s0,-1152
    2816:	85e6                	mv	a1,s9
    2818:	00004517          	auipc	a0,0x4
    281c:	c6050513          	addi	a0,a0,-928 # 6478 <malloc+0x1228>
    2820:	17d020ef          	jal	519c <printf>
      break;
    2824:	a039                	j	2832 <diskfull+0x7c>
        close(fd);
    2826:	854a                	mv	a0,s2
    2828:	574020ef          	jal	4d9c <close>
    close(fd);
    282c:	854a                	mv	a0,s2
    282e:	56e020ef          	jal	4d9c <close>
  for(int i = 0; i < nzz; i++){
    2832:	4481                	li	s1,0
    name[0] = 'z';
    2834:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    2838:	08000993          	li	s3,128
    name[0] = 'z';
    283c:	bb240023          	sb	s2,-1120(s0)
    name[1] = 'z';
    2840:	bb2400a3          	sb	s2,-1119(s0)
    name[2] = '0' + (i / 32);
    2844:	41f4d71b          	sraiw	a4,s1,0x1f
    2848:	01b7571b          	srliw	a4,a4,0x1b
    284c:	009707bb          	addw	a5,a4,s1
    2850:	4057d69b          	sraiw	a3,a5,0x5
    2854:	0306869b          	addiw	a3,a3,48
    2858:	bad40123          	sb	a3,-1118(s0)
    name[3] = '0' + (i % 32);
    285c:	8bfd                	andi	a5,a5,31
    285e:	9f99                	subw	a5,a5,a4
    2860:	0307879b          	addiw	a5,a5,48
    2864:	baf401a3          	sb	a5,-1117(s0)
    name[4] = '\0';
    2868:	ba040223          	sb	zero,-1116(s0)
    unlink(name);
    286c:	ba040513          	addi	a0,s0,-1120
    2870:	554020ef          	jal	4dc4 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    2874:	60200593          	li	a1,1538
    2878:	ba040513          	addi	a0,s0,-1120
    287c:	538020ef          	jal	4db4 <open>
    if(fd < 0)
    2880:	00054763          	bltz	a0,288e <diskfull+0xd8>
    close(fd);
    2884:	518020ef          	jal	4d9c <close>
  for(int i = 0; i < nzz; i++){
    2888:	2485                	addiw	s1,s1,1
    288a:	fb3499e3          	bne	s1,s3,283c <diskfull+0x86>
  if(mkdir("diskfulldir") == 0)
    288e:	00004517          	auipc	a0,0x4
    2892:	bda50513          	addi	a0,a0,-1062 # 6468 <malloc+0x1218>
    2896:	546020ef          	jal	4ddc <mkdir>
    289a:	12050063          	beqz	a0,29ba <diskfull+0x204>
  unlink("diskfulldir");
    289e:	00004517          	auipc	a0,0x4
    28a2:	bca50513          	addi	a0,a0,-1078 # 6468 <malloc+0x1218>
    28a6:	51e020ef          	jal	4dc4 <unlink>
  for(int i = 0; i < nzz; i++){
    28aa:	4481                	li	s1,0
    name[0] = 'z';
    28ac:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    28b0:	08000993          	li	s3,128
    name[0] = 'z';
    28b4:	bb240023          	sb	s2,-1120(s0)
    name[1] = 'z';
    28b8:	bb2400a3          	sb	s2,-1119(s0)
    name[2] = '0' + (i / 32);
    28bc:	41f4d71b          	sraiw	a4,s1,0x1f
    28c0:	01b7571b          	srliw	a4,a4,0x1b
    28c4:	009707bb          	addw	a5,a4,s1
    28c8:	4057d69b          	sraiw	a3,a5,0x5
    28cc:	0306869b          	addiw	a3,a3,48
    28d0:	bad40123          	sb	a3,-1118(s0)
    name[3] = '0' + (i % 32);
    28d4:	8bfd                	andi	a5,a5,31
    28d6:	9f99                	subw	a5,a5,a4
    28d8:	0307879b          	addiw	a5,a5,48
    28dc:	baf401a3          	sb	a5,-1117(s0)
    name[4] = '\0';
    28e0:	ba040223          	sb	zero,-1116(s0)
    unlink(name);
    28e4:	ba040513          	addi	a0,s0,-1120
    28e8:	4dc020ef          	jal	4dc4 <unlink>
  for(int i = 0; i < nzz; i++){
    28ec:	2485                	addiw	s1,s1,1
    28ee:	fd3493e3          	bne	s1,s3,28b4 <diskfull+0xfe>
    28f2:	03000493          	li	s1,48
    name[0] = 'b';
    28f6:	06200a93          	li	s5,98
    name[1] = 'i';
    28fa:	06900a13          	li	s4,105
    name[2] = 'g';
    28fe:	06700993          	li	s3,103
  for(int i = 0; '0' + i < 0177; i++){
    2902:	07f00913          	li	s2,127
    name[0] = 'b';
    2906:	bb540023          	sb	s5,-1120(s0)
    name[1] = 'i';
    290a:	bb4400a3          	sb	s4,-1119(s0)
    name[2] = 'g';
    290e:	bb340123          	sb	s3,-1118(s0)
    name[3] = '0' + i;
    2912:	ba9401a3          	sb	s1,-1117(s0)
    name[4] = '\0';
    2916:	ba040223          	sb	zero,-1116(s0)
    unlink(name);
    291a:	ba040513          	addi	a0,s0,-1120
    291e:	4a6020ef          	jal	4dc4 <unlink>
  for(int i = 0; '0' + i < 0177; i++){
    2922:	2485                	addiw	s1,s1,1
    2924:	0ff4f493          	zext.b	s1,s1
    2928:	fd249fe3          	bne	s1,s2,2906 <diskfull+0x150>
}
    292c:	47813083          	ld	ra,1144(sp)
    2930:	47013403          	ld	s0,1136(sp)
    2934:	46813483          	ld	s1,1128(sp)
    2938:	46013903          	ld	s2,1120(sp)
    293c:	45813983          	ld	s3,1112(sp)
    2940:	45013a03          	ld	s4,1104(sp)
    2944:	44813a83          	ld	s5,1096(sp)
    2948:	44013b03          	ld	s6,1088(sp)
    294c:	43813b83          	ld	s7,1080(sp)
    2950:	43013c03          	ld	s8,1072(sp)
    2954:	42813c83          	ld	s9,1064(sp)
    2958:	48010113          	addi	sp,sp,1152
    295c:	8082                	ret
    close(fd);
    295e:	854a                	mv	a0,s2
    2960:	43c020ef          	jal	4d9c <close>
  for(fi = 0; done == 0 && '0' + fi < 0177; fi++){
    2964:	2985                	addiw	s3,s3,1
    2966:	0ff9f993          	zext.b	s3,s3
    296a:	ed8984e3          	beq	s3,s8,2832 <diskfull+0x7c>
    name[0] = 'b';
    296e:	b9640023          	sb	s6,-1152(s0)
    name[1] = 'i';
    2972:	b95400a3          	sb	s5,-1151(s0)
    name[2] = 'g';
    2976:	b9440123          	sb	s4,-1150(s0)
    name[3] = '0' + fi;
    297a:	b93401a3          	sb	s3,-1149(s0)
    name[4] = '\0';
    297e:	b8040223          	sb	zero,-1148(s0)
    unlink(name);
    2982:	b8040513          	addi	a0,s0,-1152
    2986:	43e020ef          	jal	4dc4 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    298a:	60200593          	li	a1,1538
    298e:	b8040513          	addi	a0,s0,-1152
    2992:	422020ef          	jal	4db4 <open>
    2996:	892a                	mv	s2,a0
    if(fd < 0){
    2998:	e6054de3          	bltz	a0,2812 <diskfull+0x5c>
    299c:	84de                	mv	s1,s7
      if(write(fd, buf, BSIZE) != BSIZE){
    299e:	40000613          	li	a2,1024
    29a2:	ba040593          	addi	a1,s0,-1120
    29a6:	854a                	mv	a0,s2
    29a8:	3ec020ef          	jal	4d94 <write>
    29ac:	40000793          	li	a5,1024
    29b0:	e6f51be3          	bne	a0,a5,2826 <diskfull+0x70>
    for(int i = 0; i < MAXFILE; i++){
    29b4:	34fd                	addiw	s1,s1,-1
    29b6:	f4e5                	bnez	s1,299e <diskfull+0x1e8>
    29b8:	b75d                	j	295e <diskfull+0x1a8>
    printf("%s: mkdir(diskfulldir) unexpectedly succeeded!\n", s);
    29ba:	85e6                	mv	a1,s9
    29bc:	00004517          	auipc	a0,0x4
    29c0:	adc50513          	addi	a0,a0,-1316 # 6498 <malloc+0x1248>
    29c4:	7d8020ef          	jal	519c <printf>
    29c8:	bdd9                	j	289e <diskfull+0xe8>

00000000000029ca <iputtest>:
{
    29ca:	1101                	addi	sp,sp,-32
    29cc:	ec06                	sd	ra,24(sp)
    29ce:	e822                	sd	s0,16(sp)
    29d0:	e426                	sd	s1,8(sp)
    29d2:	1000                	addi	s0,sp,32
    29d4:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    29d6:	00004517          	auipc	a0,0x4
    29da:	af250513          	addi	a0,a0,-1294 # 64c8 <malloc+0x1278>
    29de:	3fe020ef          	jal	4ddc <mkdir>
    29e2:	02054f63          	bltz	a0,2a20 <iputtest+0x56>
  if(chdir("iputdir") < 0){
    29e6:	00004517          	auipc	a0,0x4
    29ea:	ae250513          	addi	a0,a0,-1310 # 64c8 <malloc+0x1278>
    29ee:	3f6020ef          	jal	4de4 <chdir>
    29f2:	04054163          	bltz	a0,2a34 <iputtest+0x6a>
  if(unlink("../iputdir") < 0){
    29f6:	00004517          	auipc	a0,0x4
    29fa:	b1250513          	addi	a0,a0,-1262 # 6508 <malloc+0x12b8>
    29fe:	3c6020ef          	jal	4dc4 <unlink>
    2a02:	04054363          	bltz	a0,2a48 <iputtest+0x7e>
  if(chdir("/") < 0){
    2a06:	00004517          	auipc	a0,0x4
    2a0a:	b3250513          	addi	a0,a0,-1230 # 6538 <malloc+0x12e8>
    2a0e:	3d6020ef          	jal	4de4 <chdir>
    2a12:	04054563          	bltz	a0,2a5c <iputtest+0x92>
}
    2a16:	60e2                	ld	ra,24(sp)
    2a18:	6442                	ld	s0,16(sp)
    2a1a:	64a2                	ld	s1,8(sp)
    2a1c:	6105                	addi	sp,sp,32
    2a1e:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2a20:	85a6                	mv	a1,s1
    2a22:	00004517          	auipc	a0,0x4
    2a26:	aae50513          	addi	a0,a0,-1362 # 64d0 <malloc+0x1280>
    2a2a:	772020ef          	jal	519c <printf>
    exit(1);
    2a2e:	4505                	li	a0,1
    2a30:	344020ef          	jal	4d74 <exit>
    printf("%s: chdir iputdir failed\n", s);
    2a34:	85a6                	mv	a1,s1
    2a36:	00004517          	auipc	a0,0x4
    2a3a:	ab250513          	addi	a0,a0,-1358 # 64e8 <malloc+0x1298>
    2a3e:	75e020ef          	jal	519c <printf>
    exit(1);
    2a42:	4505                	li	a0,1
    2a44:	330020ef          	jal	4d74 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    2a48:	85a6                	mv	a1,s1
    2a4a:	00004517          	auipc	a0,0x4
    2a4e:	ace50513          	addi	a0,a0,-1330 # 6518 <malloc+0x12c8>
    2a52:	74a020ef          	jal	519c <printf>
    exit(1);
    2a56:	4505                	li	a0,1
    2a58:	31c020ef          	jal	4d74 <exit>
    printf("%s: chdir / failed\n", s);
    2a5c:	85a6                	mv	a1,s1
    2a5e:	00004517          	auipc	a0,0x4
    2a62:	ae250513          	addi	a0,a0,-1310 # 6540 <malloc+0x12f0>
    2a66:	736020ef          	jal	519c <printf>
    exit(1);
    2a6a:	4505                	li	a0,1
    2a6c:	308020ef          	jal	4d74 <exit>

0000000000002a70 <exitiputtest>:
{
    2a70:	7179                	addi	sp,sp,-48
    2a72:	f406                	sd	ra,40(sp)
    2a74:	f022                	sd	s0,32(sp)
    2a76:	ec26                	sd	s1,24(sp)
    2a78:	1800                	addi	s0,sp,48
    2a7a:	84aa                	mv	s1,a0
  pid = fork();
    2a7c:	2f0020ef          	jal	4d6c <fork>
  if(pid < 0){
    2a80:	02054e63          	bltz	a0,2abc <exitiputtest+0x4c>
  if(pid == 0){
    2a84:	e541                	bnez	a0,2b0c <exitiputtest+0x9c>
    if(mkdir("iputdir") < 0){
    2a86:	00004517          	auipc	a0,0x4
    2a8a:	a4250513          	addi	a0,a0,-1470 # 64c8 <malloc+0x1278>
    2a8e:	34e020ef          	jal	4ddc <mkdir>
    2a92:	02054f63          	bltz	a0,2ad0 <exitiputtest+0x60>
    if(chdir("iputdir") < 0){
    2a96:	00004517          	auipc	a0,0x4
    2a9a:	a3250513          	addi	a0,a0,-1486 # 64c8 <malloc+0x1278>
    2a9e:	346020ef          	jal	4de4 <chdir>
    2aa2:	04054163          	bltz	a0,2ae4 <exitiputtest+0x74>
    if(unlink("../iputdir") < 0){
    2aa6:	00004517          	auipc	a0,0x4
    2aaa:	a6250513          	addi	a0,a0,-1438 # 6508 <malloc+0x12b8>
    2aae:	316020ef          	jal	4dc4 <unlink>
    2ab2:	04054363          	bltz	a0,2af8 <exitiputtest+0x88>
    exit(0);
    2ab6:	4501                	li	a0,0
    2ab8:	2bc020ef          	jal	4d74 <exit>
    printf("%s: fork failed\n", s);
    2abc:	85a6                	mv	a1,s1
    2abe:	00003517          	auipc	a0,0x3
    2ac2:	15a50513          	addi	a0,a0,346 # 5c18 <malloc+0x9c8>
    2ac6:	6d6020ef          	jal	519c <printf>
    exit(1);
    2aca:	4505                	li	a0,1
    2acc:	2a8020ef          	jal	4d74 <exit>
      printf("%s: mkdir failed\n", s);
    2ad0:	85a6                	mv	a1,s1
    2ad2:	00004517          	auipc	a0,0x4
    2ad6:	9fe50513          	addi	a0,a0,-1538 # 64d0 <malloc+0x1280>
    2ada:	6c2020ef          	jal	519c <printf>
      exit(1);
    2ade:	4505                	li	a0,1
    2ae0:	294020ef          	jal	4d74 <exit>
      printf("%s: child chdir failed\n", s);
    2ae4:	85a6                	mv	a1,s1
    2ae6:	00004517          	auipc	a0,0x4
    2aea:	a7250513          	addi	a0,a0,-1422 # 6558 <malloc+0x1308>
    2aee:	6ae020ef          	jal	519c <printf>
      exit(1);
    2af2:	4505                	li	a0,1
    2af4:	280020ef          	jal	4d74 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2af8:	85a6                	mv	a1,s1
    2afa:	00004517          	auipc	a0,0x4
    2afe:	a1e50513          	addi	a0,a0,-1506 # 6518 <malloc+0x12c8>
    2b02:	69a020ef          	jal	519c <printf>
      exit(1);
    2b06:	4505                	li	a0,1
    2b08:	26c020ef          	jal	4d74 <exit>
  wait(&xstatus);
    2b0c:	fdc40513          	addi	a0,s0,-36
    2b10:	26c020ef          	jal	4d7c <wait>
  exit(xstatus);
    2b14:	fdc42503          	lw	a0,-36(s0)
    2b18:	25c020ef          	jal	4d74 <exit>

0000000000002b1c <dirtest>:
{
    2b1c:	1101                	addi	sp,sp,-32
    2b1e:	ec06                	sd	ra,24(sp)
    2b20:	e822                	sd	s0,16(sp)
    2b22:	e426                	sd	s1,8(sp)
    2b24:	1000                	addi	s0,sp,32
    2b26:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    2b28:	00004517          	auipc	a0,0x4
    2b2c:	a4850513          	addi	a0,a0,-1464 # 6570 <malloc+0x1320>
    2b30:	2ac020ef          	jal	4ddc <mkdir>
    2b34:	02054f63          	bltz	a0,2b72 <dirtest+0x56>
  if(chdir("dir0") < 0){
    2b38:	00004517          	auipc	a0,0x4
    2b3c:	a3850513          	addi	a0,a0,-1480 # 6570 <malloc+0x1320>
    2b40:	2a4020ef          	jal	4de4 <chdir>
    2b44:	04054163          	bltz	a0,2b86 <dirtest+0x6a>
  if(chdir("..") < 0){
    2b48:	00004517          	auipc	a0,0x4
    2b4c:	a4850513          	addi	a0,a0,-1464 # 6590 <malloc+0x1340>
    2b50:	294020ef          	jal	4de4 <chdir>
    2b54:	04054363          	bltz	a0,2b9a <dirtest+0x7e>
  if(unlink("dir0") < 0){
    2b58:	00004517          	auipc	a0,0x4
    2b5c:	a1850513          	addi	a0,a0,-1512 # 6570 <malloc+0x1320>
    2b60:	264020ef          	jal	4dc4 <unlink>
    2b64:	04054563          	bltz	a0,2bae <dirtest+0x92>
}
    2b68:	60e2                	ld	ra,24(sp)
    2b6a:	6442                	ld	s0,16(sp)
    2b6c:	64a2                	ld	s1,8(sp)
    2b6e:	6105                	addi	sp,sp,32
    2b70:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2b72:	85a6                	mv	a1,s1
    2b74:	00004517          	auipc	a0,0x4
    2b78:	95c50513          	addi	a0,a0,-1700 # 64d0 <malloc+0x1280>
    2b7c:	620020ef          	jal	519c <printf>
    exit(1);
    2b80:	4505                	li	a0,1
    2b82:	1f2020ef          	jal	4d74 <exit>
    printf("%s: chdir dir0 failed\n", s);
    2b86:	85a6                	mv	a1,s1
    2b88:	00004517          	auipc	a0,0x4
    2b8c:	9f050513          	addi	a0,a0,-1552 # 6578 <malloc+0x1328>
    2b90:	60c020ef          	jal	519c <printf>
    exit(1);
    2b94:	4505                	li	a0,1
    2b96:	1de020ef          	jal	4d74 <exit>
    printf("%s: chdir .. failed\n", s);
    2b9a:	85a6                	mv	a1,s1
    2b9c:	00004517          	auipc	a0,0x4
    2ba0:	9fc50513          	addi	a0,a0,-1540 # 6598 <malloc+0x1348>
    2ba4:	5f8020ef          	jal	519c <printf>
    exit(1);
    2ba8:	4505                	li	a0,1
    2baa:	1ca020ef          	jal	4d74 <exit>
    printf("%s: unlink dir0 failed\n", s);
    2bae:	85a6                	mv	a1,s1
    2bb0:	00004517          	auipc	a0,0x4
    2bb4:	a0050513          	addi	a0,a0,-1536 # 65b0 <malloc+0x1360>
    2bb8:	5e4020ef          	jal	519c <printf>
    exit(1);
    2bbc:	4505                	li	a0,1
    2bbe:	1b6020ef          	jal	4d74 <exit>

0000000000002bc2 <subdir>:
{
    2bc2:	1101                	addi	sp,sp,-32
    2bc4:	ec06                	sd	ra,24(sp)
    2bc6:	e822                	sd	s0,16(sp)
    2bc8:	e426                	sd	s1,8(sp)
    2bca:	e04a                	sd	s2,0(sp)
    2bcc:	1000                	addi	s0,sp,32
    2bce:	892a                	mv	s2,a0
  unlink("ff");
    2bd0:	00004517          	auipc	a0,0x4
    2bd4:	b2850513          	addi	a0,a0,-1240 # 66f8 <malloc+0x14a8>
    2bd8:	1ec020ef          	jal	4dc4 <unlink>
  if(mkdir("dd") != 0){
    2bdc:	00004517          	auipc	a0,0x4
    2be0:	9ec50513          	addi	a0,a0,-1556 # 65c8 <malloc+0x1378>
    2be4:	1f8020ef          	jal	4ddc <mkdir>
    2be8:	2e051263          	bnez	a0,2ecc <subdir+0x30a>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2bec:	20200593          	li	a1,514
    2bf0:	00004517          	auipc	a0,0x4
    2bf4:	9f850513          	addi	a0,a0,-1544 # 65e8 <malloc+0x1398>
    2bf8:	1bc020ef          	jal	4db4 <open>
    2bfc:	84aa                	mv	s1,a0
  if(fd < 0){
    2bfe:	2e054163          	bltz	a0,2ee0 <subdir+0x31e>
  write(fd, "ff", 2);
    2c02:	4609                	li	a2,2
    2c04:	00004597          	auipc	a1,0x4
    2c08:	af458593          	addi	a1,a1,-1292 # 66f8 <malloc+0x14a8>
    2c0c:	188020ef          	jal	4d94 <write>
  close(fd);
    2c10:	8526                	mv	a0,s1
    2c12:	18a020ef          	jal	4d9c <close>
  if(unlink("dd") >= 0){
    2c16:	00004517          	auipc	a0,0x4
    2c1a:	9b250513          	addi	a0,a0,-1614 # 65c8 <malloc+0x1378>
    2c1e:	1a6020ef          	jal	4dc4 <unlink>
    2c22:	2c055963          	bgez	a0,2ef4 <subdir+0x332>
  if(mkdir("/dd/dd") != 0){
    2c26:	00004517          	auipc	a0,0x4
    2c2a:	a1a50513          	addi	a0,a0,-1510 # 6640 <malloc+0x13f0>
    2c2e:	1ae020ef          	jal	4ddc <mkdir>
    2c32:	2c051b63          	bnez	a0,2f08 <subdir+0x346>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2c36:	20200593          	li	a1,514
    2c3a:	00004517          	auipc	a0,0x4
    2c3e:	a2e50513          	addi	a0,a0,-1490 # 6668 <malloc+0x1418>
    2c42:	172020ef          	jal	4db4 <open>
    2c46:	84aa                	mv	s1,a0
  if(fd < 0){
    2c48:	2c054a63          	bltz	a0,2f1c <subdir+0x35a>
  write(fd, "FF", 2);
    2c4c:	4609                	li	a2,2
    2c4e:	00004597          	auipc	a1,0x4
    2c52:	a4a58593          	addi	a1,a1,-1462 # 6698 <malloc+0x1448>
    2c56:	13e020ef          	jal	4d94 <write>
  close(fd);
    2c5a:	8526                	mv	a0,s1
    2c5c:	140020ef          	jal	4d9c <close>
  fd = open("dd/dd/../ff", 0);
    2c60:	4581                	li	a1,0
    2c62:	00004517          	auipc	a0,0x4
    2c66:	a3e50513          	addi	a0,a0,-1474 # 66a0 <malloc+0x1450>
    2c6a:	14a020ef          	jal	4db4 <open>
    2c6e:	84aa                	mv	s1,a0
  if(fd < 0){
    2c70:	2c054063          	bltz	a0,2f30 <subdir+0x36e>
  cc = read(fd, buf, sizeof(buf));
    2c74:	660d                	lui	a2,0x3
    2c76:	0000a597          	auipc	a1,0xa
    2c7a:	04258593          	addi	a1,a1,66 # ccb8 <buf>
    2c7e:	10e020ef          	jal	4d8c <read>
  if(cc != 2 || buf[0] != 'f'){
    2c82:	4789                	li	a5,2
    2c84:	2cf51063          	bne	a0,a5,2f44 <subdir+0x382>
    2c88:	0000a717          	auipc	a4,0xa
    2c8c:	03074703          	lbu	a4,48(a4) # ccb8 <buf>
    2c90:	06600793          	li	a5,102
    2c94:	2af71863          	bne	a4,a5,2f44 <subdir+0x382>
  close(fd);
    2c98:	8526                	mv	a0,s1
    2c9a:	102020ef          	jal	4d9c <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    2c9e:	00004597          	auipc	a1,0x4
    2ca2:	a5258593          	addi	a1,a1,-1454 # 66f0 <malloc+0x14a0>
    2ca6:	00004517          	auipc	a0,0x4
    2caa:	9c250513          	addi	a0,a0,-1598 # 6668 <malloc+0x1418>
    2cae:	126020ef          	jal	4dd4 <link>
    2cb2:	2a051363          	bnez	a0,2f58 <subdir+0x396>
  if(unlink("dd/dd/ff") != 0){
    2cb6:	00004517          	auipc	a0,0x4
    2cba:	9b250513          	addi	a0,a0,-1614 # 6668 <malloc+0x1418>
    2cbe:	106020ef          	jal	4dc4 <unlink>
    2cc2:	2a051563          	bnez	a0,2f6c <subdir+0x3aa>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2cc6:	4581                	li	a1,0
    2cc8:	00004517          	auipc	a0,0x4
    2ccc:	9a050513          	addi	a0,a0,-1632 # 6668 <malloc+0x1418>
    2cd0:	0e4020ef          	jal	4db4 <open>
    2cd4:	2a055663          	bgez	a0,2f80 <subdir+0x3be>
  if(chdir("dd") != 0){
    2cd8:	00004517          	auipc	a0,0x4
    2cdc:	8f050513          	addi	a0,a0,-1808 # 65c8 <malloc+0x1378>
    2ce0:	104020ef          	jal	4de4 <chdir>
    2ce4:	2a051863          	bnez	a0,2f94 <subdir+0x3d2>
  if(chdir("dd/../../dd") != 0){
    2ce8:	00004517          	auipc	a0,0x4
    2cec:	aa050513          	addi	a0,a0,-1376 # 6788 <malloc+0x1538>
    2cf0:	0f4020ef          	jal	4de4 <chdir>
    2cf4:	2a051a63          	bnez	a0,2fa8 <subdir+0x3e6>
  if(chdir("dd/../../../dd") != 0){
    2cf8:	00004517          	auipc	a0,0x4
    2cfc:	ac050513          	addi	a0,a0,-1344 # 67b8 <malloc+0x1568>
    2d00:	0e4020ef          	jal	4de4 <chdir>
    2d04:	2a051c63          	bnez	a0,2fbc <subdir+0x3fa>
  if(chdir("./..") != 0){
    2d08:	00004517          	auipc	a0,0x4
    2d0c:	ae850513          	addi	a0,a0,-1304 # 67f0 <malloc+0x15a0>
    2d10:	0d4020ef          	jal	4de4 <chdir>
    2d14:	2a051e63          	bnez	a0,2fd0 <subdir+0x40e>
  fd = open("dd/dd/ffff", 0);
    2d18:	4581                	li	a1,0
    2d1a:	00004517          	auipc	a0,0x4
    2d1e:	9d650513          	addi	a0,a0,-1578 # 66f0 <malloc+0x14a0>
    2d22:	092020ef          	jal	4db4 <open>
    2d26:	84aa                	mv	s1,a0
  if(fd < 0){
    2d28:	2a054e63          	bltz	a0,2fe4 <subdir+0x422>
  if(read(fd, buf, sizeof(buf)) != 2){
    2d2c:	660d                	lui	a2,0x3
    2d2e:	0000a597          	auipc	a1,0xa
    2d32:	f8a58593          	addi	a1,a1,-118 # ccb8 <buf>
    2d36:	056020ef          	jal	4d8c <read>
    2d3a:	4789                	li	a5,2
    2d3c:	2af51e63          	bne	a0,a5,2ff8 <subdir+0x436>
  close(fd);
    2d40:	8526                	mv	a0,s1
    2d42:	05a020ef          	jal	4d9c <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2d46:	4581                	li	a1,0
    2d48:	00004517          	auipc	a0,0x4
    2d4c:	92050513          	addi	a0,a0,-1760 # 6668 <malloc+0x1418>
    2d50:	064020ef          	jal	4db4 <open>
    2d54:	2a055c63          	bgez	a0,300c <subdir+0x44a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    2d58:	20200593          	li	a1,514
    2d5c:	00004517          	auipc	a0,0x4
    2d60:	b2450513          	addi	a0,a0,-1244 # 6880 <malloc+0x1630>
    2d64:	050020ef          	jal	4db4 <open>
    2d68:	2a055c63          	bgez	a0,3020 <subdir+0x45e>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    2d6c:	20200593          	li	a1,514
    2d70:	00004517          	auipc	a0,0x4
    2d74:	b4050513          	addi	a0,a0,-1216 # 68b0 <malloc+0x1660>
    2d78:	03c020ef          	jal	4db4 <open>
    2d7c:	2a055c63          	bgez	a0,3034 <subdir+0x472>
  if(open("dd", O_CREATE) >= 0){
    2d80:	20000593          	li	a1,512
    2d84:	00004517          	auipc	a0,0x4
    2d88:	84450513          	addi	a0,a0,-1980 # 65c8 <malloc+0x1378>
    2d8c:	028020ef          	jal	4db4 <open>
    2d90:	2a055c63          	bgez	a0,3048 <subdir+0x486>
  if(open("dd", O_RDWR) >= 0){
    2d94:	4589                	li	a1,2
    2d96:	00004517          	auipc	a0,0x4
    2d9a:	83250513          	addi	a0,a0,-1998 # 65c8 <malloc+0x1378>
    2d9e:	016020ef          	jal	4db4 <open>
    2da2:	2a055d63          	bgez	a0,305c <subdir+0x49a>
  if(open("dd", O_WRONLY) >= 0){
    2da6:	4585                	li	a1,1
    2da8:	00004517          	auipc	a0,0x4
    2dac:	82050513          	addi	a0,a0,-2016 # 65c8 <malloc+0x1378>
    2db0:	004020ef          	jal	4db4 <open>
    2db4:	2a055e63          	bgez	a0,3070 <subdir+0x4ae>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    2db8:	00004597          	auipc	a1,0x4
    2dbc:	b8858593          	addi	a1,a1,-1144 # 6940 <malloc+0x16f0>
    2dc0:	00004517          	auipc	a0,0x4
    2dc4:	ac050513          	addi	a0,a0,-1344 # 6880 <malloc+0x1630>
    2dc8:	00c020ef          	jal	4dd4 <link>
    2dcc:	2a050c63          	beqz	a0,3084 <subdir+0x4c2>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    2dd0:	00004597          	auipc	a1,0x4
    2dd4:	b7058593          	addi	a1,a1,-1168 # 6940 <malloc+0x16f0>
    2dd8:	00004517          	auipc	a0,0x4
    2ddc:	ad850513          	addi	a0,a0,-1320 # 68b0 <malloc+0x1660>
    2de0:	7f5010ef          	jal	4dd4 <link>
    2de4:	2a050a63          	beqz	a0,3098 <subdir+0x4d6>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    2de8:	00004597          	auipc	a1,0x4
    2dec:	90858593          	addi	a1,a1,-1784 # 66f0 <malloc+0x14a0>
    2df0:	00003517          	auipc	a0,0x3
    2df4:	7f850513          	addi	a0,a0,2040 # 65e8 <malloc+0x1398>
    2df8:	7dd010ef          	jal	4dd4 <link>
    2dfc:	2a050863          	beqz	a0,30ac <subdir+0x4ea>
  if(mkdir("dd/ff/ff") == 0){
    2e00:	00004517          	auipc	a0,0x4
    2e04:	a8050513          	addi	a0,a0,-1408 # 6880 <malloc+0x1630>
    2e08:	7d5010ef          	jal	4ddc <mkdir>
    2e0c:	2a050a63          	beqz	a0,30c0 <subdir+0x4fe>
  if(mkdir("dd/xx/ff") == 0){
    2e10:	00004517          	auipc	a0,0x4
    2e14:	aa050513          	addi	a0,a0,-1376 # 68b0 <malloc+0x1660>
    2e18:	7c5010ef          	jal	4ddc <mkdir>
    2e1c:	2a050c63          	beqz	a0,30d4 <subdir+0x512>
  if(mkdir("dd/dd/ffff") == 0){
    2e20:	00004517          	auipc	a0,0x4
    2e24:	8d050513          	addi	a0,a0,-1840 # 66f0 <malloc+0x14a0>
    2e28:	7b5010ef          	jal	4ddc <mkdir>
    2e2c:	2a050e63          	beqz	a0,30e8 <subdir+0x526>
  if(unlink("dd/xx/ff") == 0){
    2e30:	00004517          	auipc	a0,0x4
    2e34:	a8050513          	addi	a0,a0,-1408 # 68b0 <malloc+0x1660>
    2e38:	78d010ef          	jal	4dc4 <unlink>
    2e3c:	2c050063          	beqz	a0,30fc <subdir+0x53a>
  if(unlink("dd/ff/ff") == 0){
    2e40:	00004517          	auipc	a0,0x4
    2e44:	a4050513          	addi	a0,a0,-1472 # 6880 <malloc+0x1630>
    2e48:	77d010ef          	jal	4dc4 <unlink>
    2e4c:	2c050263          	beqz	a0,3110 <subdir+0x54e>
  if(chdir("dd/ff") == 0){
    2e50:	00003517          	auipc	a0,0x3
    2e54:	79850513          	addi	a0,a0,1944 # 65e8 <malloc+0x1398>
    2e58:	78d010ef          	jal	4de4 <chdir>
    2e5c:	2c050463          	beqz	a0,3124 <subdir+0x562>
  if(chdir("dd/xx") == 0){
    2e60:	00004517          	auipc	a0,0x4
    2e64:	c3050513          	addi	a0,a0,-976 # 6a90 <malloc+0x1840>
    2e68:	77d010ef          	jal	4de4 <chdir>
    2e6c:	2c050663          	beqz	a0,3138 <subdir+0x576>
  if(unlink("dd/dd/ffff") != 0){
    2e70:	00004517          	auipc	a0,0x4
    2e74:	88050513          	addi	a0,a0,-1920 # 66f0 <malloc+0x14a0>
    2e78:	74d010ef          	jal	4dc4 <unlink>
    2e7c:	2c051863          	bnez	a0,314c <subdir+0x58a>
  if(unlink("dd/ff") != 0){
    2e80:	00003517          	auipc	a0,0x3
    2e84:	76850513          	addi	a0,a0,1896 # 65e8 <malloc+0x1398>
    2e88:	73d010ef          	jal	4dc4 <unlink>
    2e8c:	2c051a63          	bnez	a0,3160 <subdir+0x59e>
  if(unlink("dd") == 0){
    2e90:	00003517          	auipc	a0,0x3
    2e94:	73850513          	addi	a0,a0,1848 # 65c8 <malloc+0x1378>
    2e98:	72d010ef          	jal	4dc4 <unlink>
    2e9c:	2c050c63          	beqz	a0,3174 <subdir+0x5b2>
  if(unlink("dd/dd") < 0){
    2ea0:	00004517          	auipc	a0,0x4
    2ea4:	c6050513          	addi	a0,a0,-928 # 6b00 <malloc+0x18b0>
    2ea8:	71d010ef          	jal	4dc4 <unlink>
    2eac:	2c054e63          	bltz	a0,3188 <subdir+0x5c6>
  if(unlink("dd") < 0){
    2eb0:	00003517          	auipc	a0,0x3
    2eb4:	71850513          	addi	a0,a0,1816 # 65c8 <malloc+0x1378>
    2eb8:	70d010ef          	jal	4dc4 <unlink>
    2ebc:	2e054063          	bltz	a0,319c <subdir+0x5da>
}
    2ec0:	60e2                	ld	ra,24(sp)
    2ec2:	6442                	ld	s0,16(sp)
    2ec4:	64a2                	ld	s1,8(sp)
    2ec6:	6902                	ld	s2,0(sp)
    2ec8:	6105                	addi	sp,sp,32
    2eca:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    2ecc:	85ca                	mv	a1,s2
    2ece:	00003517          	auipc	a0,0x3
    2ed2:	70250513          	addi	a0,a0,1794 # 65d0 <malloc+0x1380>
    2ed6:	2c6020ef          	jal	519c <printf>
    exit(1);
    2eda:	4505                	li	a0,1
    2edc:	699010ef          	jal	4d74 <exit>
    printf("%s: create dd/ff failed\n", s);
    2ee0:	85ca                	mv	a1,s2
    2ee2:	00003517          	auipc	a0,0x3
    2ee6:	70e50513          	addi	a0,a0,1806 # 65f0 <malloc+0x13a0>
    2eea:	2b2020ef          	jal	519c <printf>
    exit(1);
    2eee:	4505                	li	a0,1
    2ef0:	685010ef          	jal	4d74 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    2ef4:	85ca                	mv	a1,s2
    2ef6:	00003517          	auipc	a0,0x3
    2efa:	71a50513          	addi	a0,a0,1818 # 6610 <malloc+0x13c0>
    2efe:	29e020ef          	jal	519c <printf>
    exit(1);
    2f02:	4505                	li	a0,1
    2f04:	671010ef          	jal	4d74 <exit>
    printf("%s: subdir mkdir dd/dd failed\n", s);
    2f08:	85ca                	mv	a1,s2
    2f0a:	00003517          	auipc	a0,0x3
    2f0e:	73e50513          	addi	a0,a0,1854 # 6648 <malloc+0x13f8>
    2f12:	28a020ef          	jal	519c <printf>
    exit(1);
    2f16:	4505                	li	a0,1
    2f18:	65d010ef          	jal	4d74 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    2f1c:	85ca                	mv	a1,s2
    2f1e:	00003517          	auipc	a0,0x3
    2f22:	75a50513          	addi	a0,a0,1882 # 6678 <malloc+0x1428>
    2f26:	276020ef          	jal	519c <printf>
    exit(1);
    2f2a:	4505                	li	a0,1
    2f2c:	649010ef          	jal	4d74 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    2f30:	85ca                	mv	a1,s2
    2f32:	00003517          	auipc	a0,0x3
    2f36:	77e50513          	addi	a0,a0,1918 # 66b0 <malloc+0x1460>
    2f3a:	262020ef          	jal	519c <printf>
    exit(1);
    2f3e:	4505                	li	a0,1
    2f40:	635010ef          	jal	4d74 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    2f44:	85ca                	mv	a1,s2
    2f46:	00003517          	auipc	a0,0x3
    2f4a:	78a50513          	addi	a0,a0,1930 # 66d0 <malloc+0x1480>
    2f4e:	24e020ef          	jal	519c <printf>
    exit(1);
    2f52:	4505                	li	a0,1
    2f54:	621010ef          	jal	4d74 <exit>
    printf("%s: link dd/dd/ff dd/dd/ffff failed\n", s);
    2f58:	85ca                	mv	a1,s2
    2f5a:	00003517          	auipc	a0,0x3
    2f5e:	7a650513          	addi	a0,a0,1958 # 6700 <malloc+0x14b0>
    2f62:	23a020ef          	jal	519c <printf>
    exit(1);
    2f66:	4505                	li	a0,1
    2f68:	60d010ef          	jal	4d74 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    2f6c:	85ca                	mv	a1,s2
    2f6e:	00003517          	auipc	a0,0x3
    2f72:	7ba50513          	addi	a0,a0,1978 # 6728 <malloc+0x14d8>
    2f76:	226020ef          	jal	519c <printf>
    exit(1);
    2f7a:	4505                	li	a0,1
    2f7c:	5f9010ef          	jal	4d74 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    2f80:	85ca                	mv	a1,s2
    2f82:	00003517          	auipc	a0,0x3
    2f86:	7c650513          	addi	a0,a0,1990 # 6748 <malloc+0x14f8>
    2f8a:	212020ef          	jal	519c <printf>
    exit(1);
    2f8e:	4505                	li	a0,1
    2f90:	5e5010ef          	jal	4d74 <exit>
    printf("%s: chdir dd failed\n", s);
    2f94:	85ca                	mv	a1,s2
    2f96:	00003517          	auipc	a0,0x3
    2f9a:	7da50513          	addi	a0,a0,2010 # 6770 <malloc+0x1520>
    2f9e:	1fe020ef          	jal	519c <printf>
    exit(1);
    2fa2:	4505                	li	a0,1
    2fa4:	5d1010ef          	jal	4d74 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    2fa8:	85ca                	mv	a1,s2
    2faa:	00003517          	auipc	a0,0x3
    2fae:	7ee50513          	addi	a0,a0,2030 # 6798 <malloc+0x1548>
    2fb2:	1ea020ef          	jal	519c <printf>
    exit(1);
    2fb6:	4505                	li	a0,1
    2fb8:	5bd010ef          	jal	4d74 <exit>
    printf("%s: chdir dd/../../../dd failed\n", s);
    2fbc:	85ca                	mv	a1,s2
    2fbe:	00004517          	auipc	a0,0x4
    2fc2:	80a50513          	addi	a0,a0,-2038 # 67c8 <malloc+0x1578>
    2fc6:	1d6020ef          	jal	519c <printf>
    exit(1);
    2fca:	4505                	li	a0,1
    2fcc:	5a9010ef          	jal	4d74 <exit>
    printf("%s: chdir ./.. failed\n", s);
    2fd0:	85ca                	mv	a1,s2
    2fd2:	00004517          	auipc	a0,0x4
    2fd6:	82650513          	addi	a0,a0,-2010 # 67f8 <malloc+0x15a8>
    2fda:	1c2020ef          	jal	519c <printf>
    exit(1);
    2fde:	4505                	li	a0,1
    2fe0:	595010ef          	jal	4d74 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    2fe4:	85ca                	mv	a1,s2
    2fe6:	00004517          	auipc	a0,0x4
    2fea:	82a50513          	addi	a0,a0,-2006 # 6810 <malloc+0x15c0>
    2fee:	1ae020ef          	jal	519c <printf>
    exit(1);
    2ff2:	4505                	li	a0,1
    2ff4:	581010ef          	jal	4d74 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    2ff8:	85ca                	mv	a1,s2
    2ffa:	00004517          	auipc	a0,0x4
    2ffe:	83650513          	addi	a0,a0,-1994 # 6830 <malloc+0x15e0>
    3002:	19a020ef          	jal	519c <printf>
    exit(1);
    3006:	4505                	li	a0,1
    3008:	56d010ef          	jal	4d74 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    300c:	85ca                	mv	a1,s2
    300e:	00004517          	auipc	a0,0x4
    3012:	84250513          	addi	a0,a0,-1982 # 6850 <malloc+0x1600>
    3016:	186020ef          	jal	519c <printf>
    exit(1);
    301a:	4505                	li	a0,1
    301c:	559010ef          	jal	4d74 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    3020:	85ca                	mv	a1,s2
    3022:	00004517          	auipc	a0,0x4
    3026:	86e50513          	addi	a0,a0,-1938 # 6890 <malloc+0x1640>
    302a:	172020ef          	jal	519c <printf>
    exit(1);
    302e:	4505                	li	a0,1
    3030:	545010ef          	jal	4d74 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3034:	85ca                	mv	a1,s2
    3036:	00004517          	auipc	a0,0x4
    303a:	88a50513          	addi	a0,a0,-1910 # 68c0 <malloc+0x1670>
    303e:	15e020ef          	jal	519c <printf>
    exit(1);
    3042:	4505                	li	a0,1
    3044:	531010ef          	jal	4d74 <exit>
    printf("%s: create dd succeeded!\n", s);
    3048:	85ca                	mv	a1,s2
    304a:	00004517          	auipc	a0,0x4
    304e:	89650513          	addi	a0,a0,-1898 # 68e0 <malloc+0x1690>
    3052:	14a020ef          	jal	519c <printf>
    exit(1);
    3056:	4505                	li	a0,1
    3058:	51d010ef          	jal	4d74 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    305c:	85ca                	mv	a1,s2
    305e:	00004517          	auipc	a0,0x4
    3062:	8a250513          	addi	a0,a0,-1886 # 6900 <malloc+0x16b0>
    3066:	136020ef          	jal	519c <printf>
    exit(1);
    306a:	4505                	li	a0,1
    306c:	509010ef          	jal	4d74 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3070:	85ca                	mv	a1,s2
    3072:	00004517          	auipc	a0,0x4
    3076:	8ae50513          	addi	a0,a0,-1874 # 6920 <malloc+0x16d0>
    307a:	122020ef          	jal	519c <printf>
    exit(1);
    307e:	4505                	li	a0,1
    3080:	4f5010ef          	jal	4d74 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3084:	85ca                	mv	a1,s2
    3086:	00004517          	auipc	a0,0x4
    308a:	8ca50513          	addi	a0,a0,-1846 # 6950 <malloc+0x1700>
    308e:	10e020ef          	jal	519c <printf>
    exit(1);
    3092:	4505                	li	a0,1
    3094:	4e1010ef          	jal	4d74 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3098:	85ca                	mv	a1,s2
    309a:	00004517          	auipc	a0,0x4
    309e:	8de50513          	addi	a0,a0,-1826 # 6978 <malloc+0x1728>
    30a2:	0fa020ef          	jal	519c <printf>
    exit(1);
    30a6:	4505                	li	a0,1
    30a8:	4cd010ef          	jal	4d74 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    30ac:	85ca                	mv	a1,s2
    30ae:	00004517          	auipc	a0,0x4
    30b2:	8f250513          	addi	a0,a0,-1806 # 69a0 <malloc+0x1750>
    30b6:	0e6020ef          	jal	519c <printf>
    exit(1);
    30ba:	4505                	li	a0,1
    30bc:	4b9010ef          	jal	4d74 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    30c0:	85ca                	mv	a1,s2
    30c2:	00004517          	auipc	a0,0x4
    30c6:	90650513          	addi	a0,a0,-1786 # 69c8 <malloc+0x1778>
    30ca:	0d2020ef          	jal	519c <printf>
    exit(1);
    30ce:	4505                	li	a0,1
    30d0:	4a5010ef          	jal	4d74 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    30d4:	85ca                	mv	a1,s2
    30d6:	00004517          	auipc	a0,0x4
    30da:	91250513          	addi	a0,a0,-1774 # 69e8 <malloc+0x1798>
    30de:	0be020ef          	jal	519c <printf>
    exit(1);
    30e2:	4505                	li	a0,1
    30e4:	491010ef          	jal	4d74 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    30e8:	85ca                	mv	a1,s2
    30ea:	00004517          	auipc	a0,0x4
    30ee:	91e50513          	addi	a0,a0,-1762 # 6a08 <malloc+0x17b8>
    30f2:	0aa020ef          	jal	519c <printf>
    exit(1);
    30f6:	4505                	li	a0,1
    30f8:	47d010ef          	jal	4d74 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    30fc:	85ca                	mv	a1,s2
    30fe:	00004517          	auipc	a0,0x4
    3102:	93250513          	addi	a0,a0,-1742 # 6a30 <malloc+0x17e0>
    3106:	096020ef          	jal	519c <printf>
    exit(1);
    310a:	4505                	li	a0,1
    310c:	469010ef          	jal	4d74 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3110:	85ca                	mv	a1,s2
    3112:	00004517          	auipc	a0,0x4
    3116:	93e50513          	addi	a0,a0,-1730 # 6a50 <malloc+0x1800>
    311a:	082020ef          	jal	519c <printf>
    exit(1);
    311e:	4505                	li	a0,1
    3120:	455010ef          	jal	4d74 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3124:	85ca                	mv	a1,s2
    3126:	00004517          	auipc	a0,0x4
    312a:	94a50513          	addi	a0,a0,-1718 # 6a70 <malloc+0x1820>
    312e:	06e020ef          	jal	519c <printf>
    exit(1);
    3132:	4505                	li	a0,1
    3134:	441010ef          	jal	4d74 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3138:	85ca                	mv	a1,s2
    313a:	00004517          	auipc	a0,0x4
    313e:	95e50513          	addi	a0,a0,-1698 # 6a98 <malloc+0x1848>
    3142:	05a020ef          	jal	519c <printf>
    exit(1);
    3146:	4505                	li	a0,1
    3148:	42d010ef          	jal	4d74 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    314c:	85ca                	mv	a1,s2
    314e:	00003517          	auipc	a0,0x3
    3152:	5da50513          	addi	a0,a0,1498 # 6728 <malloc+0x14d8>
    3156:	046020ef          	jal	519c <printf>
    exit(1);
    315a:	4505                	li	a0,1
    315c:	419010ef          	jal	4d74 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3160:	85ca                	mv	a1,s2
    3162:	00004517          	auipc	a0,0x4
    3166:	95650513          	addi	a0,a0,-1706 # 6ab8 <malloc+0x1868>
    316a:	032020ef          	jal	519c <printf>
    exit(1);
    316e:	4505                	li	a0,1
    3170:	405010ef          	jal	4d74 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    3174:	85ca                	mv	a1,s2
    3176:	00004517          	auipc	a0,0x4
    317a:	96250513          	addi	a0,a0,-1694 # 6ad8 <malloc+0x1888>
    317e:	01e020ef          	jal	519c <printf>
    exit(1);
    3182:	4505                	li	a0,1
    3184:	3f1010ef          	jal	4d74 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3188:	85ca                	mv	a1,s2
    318a:	00004517          	auipc	a0,0x4
    318e:	97e50513          	addi	a0,a0,-1666 # 6b08 <malloc+0x18b8>
    3192:	00a020ef          	jal	519c <printf>
    exit(1);
    3196:	4505                	li	a0,1
    3198:	3dd010ef          	jal	4d74 <exit>
    printf("%s: unlink dd failed\n", s);
    319c:	85ca                	mv	a1,s2
    319e:	00004517          	auipc	a0,0x4
    31a2:	98a50513          	addi	a0,a0,-1654 # 6b28 <malloc+0x18d8>
    31a6:	7f7010ef          	jal	519c <printf>
    exit(1);
    31aa:	4505                	li	a0,1
    31ac:	3c9010ef          	jal	4d74 <exit>

00000000000031b0 <rmdot>:
{
    31b0:	1101                	addi	sp,sp,-32
    31b2:	ec06                	sd	ra,24(sp)
    31b4:	e822                	sd	s0,16(sp)
    31b6:	e426                	sd	s1,8(sp)
    31b8:	1000                	addi	s0,sp,32
    31ba:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    31bc:	00004517          	auipc	a0,0x4
    31c0:	98450513          	addi	a0,a0,-1660 # 6b40 <malloc+0x18f0>
    31c4:	419010ef          	jal	4ddc <mkdir>
    31c8:	e53d                	bnez	a0,3236 <rmdot+0x86>
  if(chdir("dots") != 0){
    31ca:	00004517          	auipc	a0,0x4
    31ce:	97650513          	addi	a0,a0,-1674 # 6b40 <malloc+0x18f0>
    31d2:	413010ef          	jal	4de4 <chdir>
    31d6:	e935                	bnez	a0,324a <rmdot+0x9a>
  if(unlink(".") == 0){
    31d8:	00003517          	auipc	a0,0x3
    31dc:	89850513          	addi	a0,a0,-1896 # 5a70 <malloc+0x820>
    31e0:	3e5010ef          	jal	4dc4 <unlink>
    31e4:	cd2d                	beqz	a0,325e <rmdot+0xae>
  if(unlink("..") == 0){
    31e6:	00003517          	auipc	a0,0x3
    31ea:	3aa50513          	addi	a0,a0,938 # 6590 <malloc+0x1340>
    31ee:	3d7010ef          	jal	4dc4 <unlink>
    31f2:	c141                	beqz	a0,3272 <rmdot+0xc2>
  if(chdir("/") != 0){
    31f4:	00003517          	auipc	a0,0x3
    31f8:	34450513          	addi	a0,a0,836 # 6538 <malloc+0x12e8>
    31fc:	3e9010ef          	jal	4de4 <chdir>
    3200:	e159                	bnez	a0,3286 <rmdot+0xd6>
  if(unlink("dots/.") == 0){
    3202:	00004517          	auipc	a0,0x4
    3206:	9a650513          	addi	a0,a0,-1626 # 6ba8 <malloc+0x1958>
    320a:	3bb010ef          	jal	4dc4 <unlink>
    320e:	c551                	beqz	a0,329a <rmdot+0xea>
  if(unlink("dots/..") == 0){
    3210:	00004517          	auipc	a0,0x4
    3214:	9c050513          	addi	a0,a0,-1600 # 6bd0 <malloc+0x1980>
    3218:	3ad010ef          	jal	4dc4 <unlink>
    321c:	c949                	beqz	a0,32ae <rmdot+0xfe>
  if(unlink("dots") != 0){
    321e:	00004517          	auipc	a0,0x4
    3222:	92250513          	addi	a0,a0,-1758 # 6b40 <malloc+0x18f0>
    3226:	39f010ef          	jal	4dc4 <unlink>
    322a:	ed41                	bnez	a0,32c2 <rmdot+0x112>
}
    322c:	60e2                	ld	ra,24(sp)
    322e:	6442                	ld	s0,16(sp)
    3230:	64a2                	ld	s1,8(sp)
    3232:	6105                	addi	sp,sp,32
    3234:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    3236:	85a6                	mv	a1,s1
    3238:	00004517          	auipc	a0,0x4
    323c:	91050513          	addi	a0,a0,-1776 # 6b48 <malloc+0x18f8>
    3240:	75d010ef          	jal	519c <printf>
    exit(1);
    3244:	4505                	li	a0,1
    3246:	32f010ef          	jal	4d74 <exit>
    printf("%s: chdir dots failed\n", s);
    324a:	85a6                	mv	a1,s1
    324c:	00004517          	auipc	a0,0x4
    3250:	91450513          	addi	a0,a0,-1772 # 6b60 <malloc+0x1910>
    3254:	749010ef          	jal	519c <printf>
    exit(1);
    3258:	4505                	li	a0,1
    325a:	31b010ef          	jal	4d74 <exit>
    printf("%s: rm . worked!\n", s);
    325e:	85a6                	mv	a1,s1
    3260:	00004517          	auipc	a0,0x4
    3264:	91850513          	addi	a0,a0,-1768 # 6b78 <malloc+0x1928>
    3268:	735010ef          	jal	519c <printf>
    exit(1);
    326c:	4505                	li	a0,1
    326e:	307010ef          	jal	4d74 <exit>
    printf("%s: rm .. worked!\n", s);
    3272:	85a6                	mv	a1,s1
    3274:	00004517          	auipc	a0,0x4
    3278:	91c50513          	addi	a0,a0,-1764 # 6b90 <malloc+0x1940>
    327c:	721010ef          	jal	519c <printf>
    exit(1);
    3280:	4505                	li	a0,1
    3282:	2f3010ef          	jal	4d74 <exit>
    printf("%s: chdir / failed\n", s);
    3286:	85a6                	mv	a1,s1
    3288:	00003517          	auipc	a0,0x3
    328c:	2b850513          	addi	a0,a0,696 # 6540 <malloc+0x12f0>
    3290:	70d010ef          	jal	519c <printf>
    exit(1);
    3294:	4505                	li	a0,1
    3296:	2df010ef          	jal	4d74 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    329a:	85a6                	mv	a1,s1
    329c:	00004517          	auipc	a0,0x4
    32a0:	91450513          	addi	a0,a0,-1772 # 6bb0 <malloc+0x1960>
    32a4:	6f9010ef          	jal	519c <printf>
    exit(1);
    32a8:	4505                	li	a0,1
    32aa:	2cb010ef          	jal	4d74 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    32ae:	85a6                	mv	a1,s1
    32b0:	00004517          	auipc	a0,0x4
    32b4:	92850513          	addi	a0,a0,-1752 # 6bd8 <malloc+0x1988>
    32b8:	6e5010ef          	jal	519c <printf>
    exit(1);
    32bc:	4505                	li	a0,1
    32be:	2b7010ef          	jal	4d74 <exit>
    printf("%s: unlink dots failed!\n", s);
    32c2:	85a6                	mv	a1,s1
    32c4:	00004517          	auipc	a0,0x4
    32c8:	93450513          	addi	a0,a0,-1740 # 6bf8 <malloc+0x19a8>
    32cc:	6d1010ef          	jal	519c <printf>
    exit(1);
    32d0:	4505                	li	a0,1
    32d2:	2a3010ef          	jal	4d74 <exit>

00000000000032d6 <dirfile>:
{
    32d6:	1101                	addi	sp,sp,-32
    32d8:	ec06                	sd	ra,24(sp)
    32da:	e822                	sd	s0,16(sp)
    32dc:	e426                	sd	s1,8(sp)
    32de:	e04a                	sd	s2,0(sp)
    32e0:	1000                	addi	s0,sp,32
    32e2:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    32e4:	20000593          	li	a1,512
    32e8:	00004517          	auipc	a0,0x4
    32ec:	93050513          	addi	a0,a0,-1744 # 6c18 <malloc+0x19c8>
    32f0:	2c5010ef          	jal	4db4 <open>
  if(fd < 0){
    32f4:	0c054563          	bltz	a0,33be <dirfile+0xe8>
  close(fd);
    32f8:	2a5010ef          	jal	4d9c <close>
  if(chdir("dirfile") == 0){
    32fc:	00004517          	auipc	a0,0x4
    3300:	91c50513          	addi	a0,a0,-1764 # 6c18 <malloc+0x19c8>
    3304:	2e1010ef          	jal	4de4 <chdir>
    3308:	c569                	beqz	a0,33d2 <dirfile+0xfc>
  fd = open("dirfile/xx", 0);
    330a:	4581                	li	a1,0
    330c:	00004517          	auipc	a0,0x4
    3310:	95450513          	addi	a0,a0,-1708 # 6c60 <malloc+0x1a10>
    3314:	2a1010ef          	jal	4db4 <open>
  if(fd >= 0){
    3318:	0c055763          	bgez	a0,33e6 <dirfile+0x110>
  fd = open("dirfile/xx", O_CREATE);
    331c:	20000593          	li	a1,512
    3320:	00004517          	auipc	a0,0x4
    3324:	94050513          	addi	a0,a0,-1728 # 6c60 <malloc+0x1a10>
    3328:	28d010ef          	jal	4db4 <open>
  if(fd >= 0){
    332c:	0c055763          	bgez	a0,33fa <dirfile+0x124>
  if(mkdir("dirfile/xx") == 0){
    3330:	00004517          	auipc	a0,0x4
    3334:	93050513          	addi	a0,a0,-1744 # 6c60 <malloc+0x1a10>
    3338:	2a5010ef          	jal	4ddc <mkdir>
    333c:	0c050963          	beqz	a0,340e <dirfile+0x138>
  if(unlink("dirfile/xx") == 0){
    3340:	00004517          	auipc	a0,0x4
    3344:	92050513          	addi	a0,a0,-1760 # 6c60 <malloc+0x1a10>
    3348:	27d010ef          	jal	4dc4 <unlink>
    334c:	0c050b63          	beqz	a0,3422 <dirfile+0x14c>
  if(link("README", "dirfile/xx") == 0){
    3350:	00004597          	auipc	a1,0x4
    3354:	91058593          	addi	a1,a1,-1776 # 6c60 <malloc+0x1a10>
    3358:	00002517          	auipc	a0,0x2
    335c:	20850513          	addi	a0,a0,520 # 5560 <malloc+0x310>
    3360:	275010ef          	jal	4dd4 <link>
    3364:	0c050963          	beqz	a0,3436 <dirfile+0x160>
  if(unlink("dirfile") != 0){
    3368:	00004517          	auipc	a0,0x4
    336c:	8b050513          	addi	a0,a0,-1872 # 6c18 <malloc+0x19c8>
    3370:	255010ef          	jal	4dc4 <unlink>
    3374:	0c051b63          	bnez	a0,344a <dirfile+0x174>
  fd = open(".", O_RDWR);
    3378:	4589                	li	a1,2
    337a:	00002517          	auipc	a0,0x2
    337e:	6f650513          	addi	a0,a0,1782 # 5a70 <malloc+0x820>
    3382:	233010ef          	jal	4db4 <open>
  if(fd >= 0){
    3386:	0c055c63          	bgez	a0,345e <dirfile+0x188>
  fd = open(".", 0);
    338a:	4581                	li	a1,0
    338c:	00002517          	auipc	a0,0x2
    3390:	6e450513          	addi	a0,a0,1764 # 5a70 <malloc+0x820>
    3394:	221010ef          	jal	4db4 <open>
    3398:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    339a:	4605                	li	a2,1
    339c:	00002597          	auipc	a1,0x2
    33a0:	05c58593          	addi	a1,a1,92 # 53f8 <malloc+0x1a8>
    33a4:	1f1010ef          	jal	4d94 <write>
    33a8:	0ca04563          	bgtz	a0,3472 <dirfile+0x19c>
  close(fd);
    33ac:	8526                	mv	a0,s1
    33ae:	1ef010ef          	jal	4d9c <close>
}
    33b2:	60e2                	ld	ra,24(sp)
    33b4:	6442                	ld	s0,16(sp)
    33b6:	64a2                	ld	s1,8(sp)
    33b8:	6902                	ld	s2,0(sp)
    33ba:	6105                	addi	sp,sp,32
    33bc:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    33be:	85ca                	mv	a1,s2
    33c0:	00004517          	auipc	a0,0x4
    33c4:	86050513          	addi	a0,a0,-1952 # 6c20 <malloc+0x19d0>
    33c8:	5d5010ef          	jal	519c <printf>
    exit(1);
    33cc:	4505                	li	a0,1
    33ce:	1a7010ef          	jal	4d74 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    33d2:	85ca                	mv	a1,s2
    33d4:	00004517          	auipc	a0,0x4
    33d8:	86c50513          	addi	a0,a0,-1940 # 6c40 <malloc+0x19f0>
    33dc:	5c1010ef          	jal	519c <printf>
    exit(1);
    33e0:	4505                	li	a0,1
    33e2:	193010ef          	jal	4d74 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    33e6:	85ca                	mv	a1,s2
    33e8:	00004517          	auipc	a0,0x4
    33ec:	88850513          	addi	a0,a0,-1912 # 6c70 <malloc+0x1a20>
    33f0:	5ad010ef          	jal	519c <printf>
    exit(1);
    33f4:	4505                	li	a0,1
    33f6:	17f010ef          	jal	4d74 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    33fa:	85ca                	mv	a1,s2
    33fc:	00004517          	auipc	a0,0x4
    3400:	87450513          	addi	a0,a0,-1932 # 6c70 <malloc+0x1a20>
    3404:	599010ef          	jal	519c <printf>
    exit(1);
    3408:	4505                	li	a0,1
    340a:	16b010ef          	jal	4d74 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    340e:	85ca                	mv	a1,s2
    3410:	00004517          	auipc	a0,0x4
    3414:	88850513          	addi	a0,a0,-1912 # 6c98 <malloc+0x1a48>
    3418:	585010ef          	jal	519c <printf>
    exit(1);
    341c:	4505                	li	a0,1
    341e:	157010ef          	jal	4d74 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    3422:	85ca                	mv	a1,s2
    3424:	00004517          	auipc	a0,0x4
    3428:	89c50513          	addi	a0,a0,-1892 # 6cc0 <malloc+0x1a70>
    342c:	571010ef          	jal	519c <printf>
    exit(1);
    3430:	4505                	li	a0,1
    3432:	143010ef          	jal	4d74 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3436:	85ca                	mv	a1,s2
    3438:	00004517          	auipc	a0,0x4
    343c:	8b050513          	addi	a0,a0,-1872 # 6ce8 <malloc+0x1a98>
    3440:	55d010ef          	jal	519c <printf>
    exit(1);
    3444:	4505                	li	a0,1
    3446:	12f010ef          	jal	4d74 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    344a:	85ca                	mv	a1,s2
    344c:	00004517          	auipc	a0,0x4
    3450:	8c450513          	addi	a0,a0,-1852 # 6d10 <malloc+0x1ac0>
    3454:	549010ef          	jal	519c <printf>
    exit(1);
    3458:	4505                	li	a0,1
    345a:	11b010ef          	jal	4d74 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    345e:	85ca                	mv	a1,s2
    3460:	00004517          	auipc	a0,0x4
    3464:	8d050513          	addi	a0,a0,-1840 # 6d30 <malloc+0x1ae0>
    3468:	535010ef          	jal	519c <printf>
    exit(1);
    346c:	4505                	li	a0,1
    346e:	107010ef          	jal	4d74 <exit>
    printf("%s: write . succeeded!\n", s);
    3472:	85ca                	mv	a1,s2
    3474:	00004517          	auipc	a0,0x4
    3478:	8e450513          	addi	a0,a0,-1820 # 6d58 <malloc+0x1b08>
    347c:	521010ef          	jal	519c <printf>
    exit(1);
    3480:	4505                	li	a0,1
    3482:	0f3010ef          	jal	4d74 <exit>

0000000000003486 <iref>:
{
    3486:	7139                	addi	sp,sp,-64
    3488:	fc06                	sd	ra,56(sp)
    348a:	f822                	sd	s0,48(sp)
    348c:	f426                	sd	s1,40(sp)
    348e:	f04a                	sd	s2,32(sp)
    3490:	ec4e                	sd	s3,24(sp)
    3492:	e852                	sd	s4,16(sp)
    3494:	e456                	sd	s5,8(sp)
    3496:	e05a                	sd	s6,0(sp)
    3498:	0080                	addi	s0,sp,64
    349a:	8b2a                	mv	s6,a0
    349c:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    34a0:	00004a17          	auipc	s4,0x4
    34a4:	8d0a0a13          	addi	s4,s4,-1840 # 6d70 <malloc+0x1b20>
    mkdir("");
    34a8:	00003497          	auipc	s1,0x3
    34ac:	3d048493          	addi	s1,s1,976 # 6878 <malloc+0x1628>
    link("README", "");
    34b0:	00002a97          	auipc	s5,0x2
    34b4:	0b0a8a93          	addi	s5,s5,176 # 5560 <malloc+0x310>
    fd = open("xx", O_CREATE);
    34b8:	00003997          	auipc	s3,0x3
    34bc:	7b098993          	addi	s3,s3,1968 # 6c68 <malloc+0x1a18>
    34c0:	a835                	j	34fc <iref+0x76>
      printf("%s: mkdir irefd failed\n", s);
    34c2:	85da                	mv	a1,s6
    34c4:	00004517          	auipc	a0,0x4
    34c8:	8b450513          	addi	a0,a0,-1868 # 6d78 <malloc+0x1b28>
    34cc:	4d1010ef          	jal	519c <printf>
      exit(1);
    34d0:	4505                	li	a0,1
    34d2:	0a3010ef          	jal	4d74 <exit>
      printf("%s: chdir irefd failed\n", s);
    34d6:	85da                	mv	a1,s6
    34d8:	00004517          	auipc	a0,0x4
    34dc:	8b850513          	addi	a0,a0,-1864 # 6d90 <malloc+0x1b40>
    34e0:	4bd010ef          	jal	519c <printf>
      exit(1);
    34e4:	4505                	li	a0,1
    34e6:	08f010ef          	jal	4d74 <exit>
      close(fd);
    34ea:	0b3010ef          	jal	4d9c <close>
    34ee:	a82d                	j	3528 <iref+0xa2>
    unlink("xx");
    34f0:	854e                	mv	a0,s3
    34f2:	0d3010ef          	jal	4dc4 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    34f6:	397d                	addiw	s2,s2,-1
    34f8:	04090263          	beqz	s2,353c <iref+0xb6>
    if(mkdir("irefd") != 0){
    34fc:	8552                	mv	a0,s4
    34fe:	0df010ef          	jal	4ddc <mkdir>
    3502:	f161                	bnez	a0,34c2 <iref+0x3c>
    if(chdir("irefd") != 0){
    3504:	8552                	mv	a0,s4
    3506:	0df010ef          	jal	4de4 <chdir>
    350a:	f571                	bnez	a0,34d6 <iref+0x50>
    mkdir("");
    350c:	8526                	mv	a0,s1
    350e:	0cf010ef          	jal	4ddc <mkdir>
    link("README", "");
    3512:	85a6                	mv	a1,s1
    3514:	8556                	mv	a0,s5
    3516:	0bf010ef          	jal	4dd4 <link>
    fd = open("", O_CREATE);
    351a:	20000593          	li	a1,512
    351e:	8526                	mv	a0,s1
    3520:	095010ef          	jal	4db4 <open>
    if(fd >= 0)
    3524:	fc0553e3          	bgez	a0,34ea <iref+0x64>
    fd = open("xx", O_CREATE);
    3528:	20000593          	li	a1,512
    352c:	854e                	mv	a0,s3
    352e:	087010ef          	jal	4db4 <open>
    if(fd >= 0)
    3532:	fa054fe3          	bltz	a0,34f0 <iref+0x6a>
      close(fd);
    3536:	067010ef          	jal	4d9c <close>
    353a:	bf5d                	j	34f0 <iref+0x6a>
    353c:	03300493          	li	s1,51
    chdir("..");
    3540:	00003997          	auipc	s3,0x3
    3544:	05098993          	addi	s3,s3,80 # 6590 <malloc+0x1340>
    unlink("irefd");
    3548:	00004917          	auipc	s2,0x4
    354c:	82890913          	addi	s2,s2,-2008 # 6d70 <malloc+0x1b20>
    chdir("..");
    3550:	854e                	mv	a0,s3
    3552:	093010ef          	jal	4de4 <chdir>
    unlink("irefd");
    3556:	854a                	mv	a0,s2
    3558:	06d010ef          	jal	4dc4 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    355c:	34fd                	addiw	s1,s1,-1
    355e:	f8ed                	bnez	s1,3550 <iref+0xca>
  chdir("/");
    3560:	00003517          	auipc	a0,0x3
    3564:	fd850513          	addi	a0,a0,-40 # 6538 <malloc+0x12e8>
    3568:	07d010ef          	jal	4de4 <chdir>
}
    356c:	70e2                	ld	ra,56(sp)
    356e:	7442                	ld	s0,48(sp)
    3570:	74a2                	ld	s1,40(sp)
    3572:	7902                	ld	s2,32(sp)
    3574:	69e2                	ld	s3,24(sp)
    3576:	6a42                	ld	s4,16(sp)
    3578:	6aa2                	ld	s5,8(sp)
    357a:	6b02                	ld	s6,0(sp)
    357c:	6121                	addi	sp,sp,64
    357e:	8082                	ret

0000000000003580 <openiputtest>:
{
    3580:	7179                	addi	sp,sp,-48
    3582:	f406                	sd	ra,40(sp)
    3584:	f022                	sd	s0,32(sp)
    3586:	ec26                	sd	s1,24(sp)
    3588:	1800                	addi	s0,sp,48
    358a:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    358c:	00004517          	auipc	a0,0x4
    3590:	81c50513          	addi	a0,a0,-2020 # 6da8 <malloc+0x1b58>
    3594:	049010ef          	jal	4ddc <mkdir>
    3598:	02054a63          	bltz	a0,35cc <openiputtest+0x4c>
  pid = fork();
    359c:	7d0010ef          	jal	4d6c <fork>
  if(pid < 0){
    35a0:	04054063          	bltz	a0,35e0 <openiputtest+0x60>
  if(pid == 0){
    35a4:	e939                	bnez	a0,35fa <openiputtest+0x7a>
    int fd = open("oidir", O_RDWR);
    35a6:	4589                	li	a1,2
    35a8:	00004517          	auipc	a0,0x4
    35ac:	80050513          	addi	a0,a0,-2048 # 6da8 <malloc+0x1b58>
    35b0:	005010ef          	jal	4db4 <open>
    if(fd >= 0){
    35b4:	04054063          	bltz	a0,35f4 <openiputtest+0x74>
      printf("%s: open directory for write succeeded\n", s);
    35b8:	85a6                	mv	a1,s1
    35ba:	00004517          	auipc	a0,0x4
    35be:	80e50513          	addi	a0,a0,-2034 # 6dc8 <malloc+0x1b78>
    35c2:	3db010ef          	jal	519c <printf>
      exit(1);
    35c6:	4505                	li	a0,1
    35c8:	7ac010ef          	jal	4d74 <exit>
    printf("%s: mkdir oidir failed\n", s);
    35cc:	85a6                	mv	a1,s1
    35ce:	00003517          	auipc	a0,0x3
    35d2:	7e250513          	addi	a0,a0,2018 # 6db0 <malloc+0x1b60>
    35d6:	3c7010ef          	jal	519c <printf>
    exit(1);
    35da:	4505                	li	a0,1
    35dc:	798010ef          	jal	4d74 <exit>
    printf("%s: fork failed\n", s);
    35e0:	85a6                	mv	a1,s1
    35e2:	00002517          	auipc	a0,0x2
    35e6:	63650513          	addi	a0,a0,1590 # 5c18 <malloc+0x9c8>
    35ea:	3b3010ef          	jal	519c <printf>
    exit(1);
    35ee:	4505                	li	a0,1
    35f0:	784010ef          	jal	4d74 <exit>
    exit(0);
    35f4:	4501                	li	a0,0
    35f6:	77e010ef          	jal	4d74 <exit>
  pause(1);
    35fa:	4505                	li	a0,1
    35fc:	009010ef          	jal	4e04 <pause>
  if(unlink("oidir") != 0){
    3600:	00003517          	auipc	a0,0x3
    3604:	7a850513          	addi	a0,a0,1960 # 6da8 <malloc+0x1b58>
    3608:	7bc010ef          	jal	4dc4 <unlink>
    360c:	c919                	beqz	a0,3622 <openiputtest+0xa2>
    printf("%s: unlink failed\n", s);
    360e:	85a6                	mv	a1,s1
    3610:	00002517          	auipc	a0,0x2
    3614:	7f850513          	addi	a0,a0,2040 # 5e08 <malloc+0xbb8>
    3618:	385010ef          	jal	519c <printf>
    exit(1);
    361c:	4505                	li	a0,1
    361e:	756010ef          	jal	4d74 <exit>
  wait(&xstatus);
    3622:	fdc40513          	addi	a0,s0,-36
    3626:	756010ef          	jal	4d7c <wait>
  exit(xstatus);
    362a:	fdc42503          	lw	a0,-36(s0)
    362e:	746010ef          	jal	4d74 <exit>

0000000000003632 <forkforkfork>:
{
    3632:	1101                	addi	sp,sp,-32
    3634:	ec06                	sd	ra,24(sp)
    3636:	e822                	sd	s0,16(sp)
    3638:	e426                	sd	s1,8(sp)
    363a:	1000                	addi	s0,sp,32
    363c:	84aa                	mv	s1,a0
  unlink("stopforking");
    363e:	00003517          	auipc	a0,0x3
    3642:	7b250513          	addi	a0,a0,1970 # 6df0 <malloc+0x1ba0>
    3646:	77e010ef          	jal	4dc4 <unlink>
  int pid = fork();
    364a:	722010ef          	jal	4d6c <fork>
  if(pid < 0){
    364e:	02054b63          	bltz	a0,3684 <forkforkfork+0x52>
  if(pid == 0){
    3652:	c139                	beqz	a0,3698 <forkforkfork+0x66>
  pause(20); // two seconds
    3654:	4551                	li	a0,20
    3656:	7ae010ef          	jal	4e04 <pause>
  close(open("stopforking", O_CREATE|O_RDWR));
    365a:	20200593          	li	a1,514
    365e:	00003517          	auipc	a0,0x3
    3662:	79250513          	addi	a0,a0,1938 # 6df0 <malloc+0x1ba0>
    3666:	74e010ef          	jal	4db4 <open>
    366a:	732010ef          	jal	4d9c <close>
  wait(0);
    366e:	4501                	li	a0,0
    3670:	70c010ef          	jal	4d7c <wait>
  pause(10); // one second
    3674:	4529                	li	a0,10
    3676:	78e010ef          	jal	4e04 <pause>
}
    367a:	60e2                	ld	ra,24(sp)
    367c:	6442                	ld	s0,16(sp)
    367e:	64a2                	ld	s1,8(sp)
    3680:	6105                	addi	sp,sp,32
    3682:	8082                	ret
    printf("%s: fork failed", s);
    3684:	85a6                	mv	a1,s1
    3686:	00002517          	auipc	a0,0x2
    368a:	75250513          	addi	a0,a0,1874 # 5dd8 <malloc+0xb88>
    368e:	30f010ef          	jal	519c <printf>
    exit(1);
    3692:	4505                	li	a0,1
    3694:	6e0010ef          	jal	4d74 <exit>
      int fd = open("stopforking", 0);
    3698:	00003497          	auipc	s1,0x3
    369c:	75848493          	addi	s1,s1,1880 # 6df0 <malloc+0x1ba0>
    36a0:	4581                	li	a1,0
    36a2:	8526                	mv	a0,s1
    36a4:	710010ef          	jal	4db4 <open>
      if(fd >= 0){
    36a8:	02055163          	bgez	a0,36ca <forkforkfork+0x98>
      if(fork() < 0){
    36ac:	6c0010ef          	jal	4d6c <fork>
    36b0:	fe0558e3          	bgez	a0,36a0 <forkforkfork+0x6e>
        close(open("stopforking", O_CREATE|O_RDWR));
    36b4:	20200593          	li	a1,514
    36b8:	00003517          	auipc	a0,0x3
    36bc:	73850513          	addi	a0,a0,1848 # 6df0 <malloc+0x1ba0>
    36c0:	6f4010ef          	jal	4db4 <open>
    36c4:	6d8010ef          	jal	4d9c <close>
    36c8:	bfe1                	j	36a0 <forkforkfork+0x6e>
        exit(0);
    36ca:	4501                	li	a0,0
    36cc:	6a8010ef          	jal	4d74 <exit>

00000000000036d0 <killstatus>:
{
    36d0:	7139                	addi	sp,sp,-64
    36d2:	fc06                	sd	ra,56(sp)
    36d4:	f822                	sd	s0,48(sp)
    36d6:	f426                	sd	s1,40(sp)
    36d8:	f04a                	sd	s2,32(sp)
    36da:	ec4e                	sd	s3,24(sp)
    36dc:	e852                	sd	s4,16(sp)
    36de:	0080                	addi	s0,sp,64
    36e0:	8a2a                	mv	s4,a0
    36e2:	06400913          	li	s2,100
    if(xst != -1) {
    36e6:	59fd                	li	s3,-1
    int pid1 = fork();
    36e8:	684010ef          	jal	4d6c <fork>
    36ec:	84aa                	mv	s1,a0
    if(pid1 < 0){
    36ee:	02054763          	bltz	a0,371c <killstatus+0x4c>
    if(pid1 == 0){
    36f2:	cd1d                	beqz	a0,3730 <killstatus+0x60>
    pause(1);
    36f4:	4505                	li	a0,1
    36f6:	70e010ef          	jal	4e04 <pause>
    kill(pid1);
    36fa:	8526                	mv	a0,s1
    36fc:	6a8010ef          	jal	4da4 <kill>
    wait(&xst);
    3700:	fcc40513          	addi	a0,s0,-52
    3704:	678010ef          	jal	4d7c <wait>
    if(xst != -1) {
    3708:	fcc42783          	lw	a5,-52(s0)
    370c:	03379563          	bne	a5,s3,3736 <killstatus+0x66>
  for(int i = 0; i < 100; i++){
    3710:	397d                	addiw	s2,s2,-1
    3712:	fc091be3          	bnez	s2,36e8 <killstatus+0x18>
  exit(0);
    3716:	4501                	li	a0,0
    3718:	65c010ef          	jal	4d74 <exit>
      printf("%s: fork failed\n", s);
    371c:	85d2                	mv	a1,s4
    371e:	00002517          	auipc	a0,0x2
    3722:	4fa50513          	addi	a0,a0,1274 # 5c18 <malloc+0x9c8>
    3726:	277010ef          	jal	519c <printf>
      exit(1);
    372a:	4505                	li	a0,1
    372c:	648010ef          	jal	4d74 <exit>
        getpid();
    3730:	6c4010ef          	jal	4df4 <getpid>
      while(1) {
    3734:	bff5                	j	3730 <killstatus+0x60>
       printf("%s: status should be -1\n", s);
    3736:	85d2                	mv	a1,s4
    3738:	00003517          	auipc	a0,0x3
    373c:	6c850513          	addi	a0,a0,1736 # 6e00 <malloc+0x1bb0>
    3740:	25d010ef          	jal	519c <printf>
       exit(1);
    3744:	4505                	li	a0,1
    3746:	62e010ef          	jal	4d74 <exit>

000000000000374a <preempt>:
{
    374a:	7139                	addi	sp,sp,-64
    374c:	fc06                	sd	ra,56(sp)
    374e:	f822                	sd	s0,48(sp)
    3750:	f426                	sd	s1,40(sp)
    3752:	f04a                	sd	s2,32(sp)
    3754:	ec4e                	sd	s3,24(sp)
    3756:	e852                	sd	s4,16(sp)
    3758:	0080                	addi	s0,sp,64
    375a:	892a                	mv	s2,a0
  pid1 = fork();
    375c:	610010ef          	jal	4d6c <fork>
  if(pid1 < 0) {
    3760:	00054563          	bltz	a0,376a <preempt+0x20>
    3764:	84aa                	mv	s1,a0
  if(pid1 == 0)
    3766:	ed01                	bnez	a0,377e <preempt+0x34>
    for(;;)
    3768:	a001                	j	3768 <preempt+0x1e>
    printf("%s: fork failed", s);
    376a:	85ca                	mv	a1,s2
    376c:	00002517          	auipc	a0,0x2
    3770:	66c50513          	addi	a0,a0,1644 # 5dd8 <malloc+0xb88>
    3774:	229010ef          	jal	519c <printf>
    exit(1);
    3778:	4505                	li	a0,1
    377a:	5fa010ef          	jal	4d74 <exit>
  pid2 = fork();
    377e:	5ee010ef          	jal	4d6c <fork>
    3782:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    3784:	00054463          	bltz	a0,378c <preempt+0x42>
  if(pid2 == 0)
    3788:	ed01                	bnez	a0,37a0 <preempt+0x56>
    for(;;)
    378a:	a001                	j	378a <preempt+0x40>
    printf("%s: fork failed\n", s);
    378c:	85ca                	mv	a1,s2
    378e:	00002517          	auipc	a0,0x2
    3792:	48a50513          	addi	a0,a0,1162 # 5c18 <malloc+0x9c8>
    3796:	207010ef          	jal	519c <printf>
    exit(1);
    379a:	4505                	li	a0,1
    379c:	5d8010ef          	jal	4d74 <exit>
  pipe(pfds);
    37a0:	fc840513          	addi	a0,s0,-56
    37a4:	5e0010ef          	jal	4d84 <pipe>
  pid3 = fork();
    37a8:	5c4010ef          	jal	4d6c <fork>
    37ac:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    37ae:	02054863          	bltz	a0,37de <preempt+0x94>
  if(pid3 == 0){
    37b2:	e921                	bnez	a0,3802 <preempt+0xb8>
    close(pfds[0]);
    37b4:	fc842503          	lw	a0,-56(s0)
    37b8:	5e4010ef          	jal	4d9c <close>
    if(write(pfds[1], "x", 1) != 1)
    37bc:	4605                	li	a2,1
    37be:	00002597          	auipc	a1,0x2
    37c2:	c3a58593          	addi	a1,a1,-966 # 53f8 <malloc+0x1a8>
    37c6:	fcc42503          	lw	a0,-52(s0)
    37ca:	5ca010ef          	jal	4d94 <write>
    37ce:	4785                	li	a5,1
    37d0:	02f51163          	bne	a0,a5,37f2 <preempt+0xa8>
    close(pfds[1]);
    37d4:	fcc42503          	lw	a0,-52(s0)
    37d8:	5c4010ef          	jal	4d9c <close>
    for(;;)
    37dc:	a001                	j	37dc <preempt+0x92>
     printf("%s: fork failed\n", s);
    37de:	85ca                	mv	a1,s2
    37e0:	00002517          	auipc	a0,0x2
    37e4:	43850513          	addi	a0,a0,1080 # 5c18 <malloc+0x9c8>
    37e8:	1b5010ef          	jal	519c <printf>
     exit(1);
    37ec:	4505                	li	a0,1
    37ee:	586010ef          	jal	4d74 <exit>
      printf("%s: preempt write error", s);
    37f2:	85ca                	mv	a1,s2
    37f4:	00003517          	auipc	a0,0x3
    37f8:	62c50513          	addi	a0,a0,1580 # 6e20 <malloc+0x1bd0>
    37fc:	1a1010ef          	jal	519c <printf>
    3800:	bfd1                	j	37d4 <preempt+0x8a>
  close(pfds[1]);
    3802:	fcc42503          	lw	a0,-52(s0)
    3806:	596010ef          	jal	4d9c <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    380a:	660d                	lui	a2,0x3
    380c:	00009597          	auipc	a1,0x9
    3810:	4ac58593          	addi	a1,a1,1196 # ccb8 <buf>
    3814:	fc842503          	lw	a0,-56(s0)
    3818:	574010ef          	jal	4d8c <read>
    381c:	4785                	li	a5,1
    381e:	02f50163          	beq	a0,a5,3840 <preempt+0xf6>
    printf("%s: preempt read error", s);
    3822:	85ca                	mv	a1,s2
    3824:	00003517          	auipc	a0,0x3
    3828:	61450513          	addi	a0,a0,1556 # 6e38 <malloc+0x1be8>
    382c:	171010ef          	jal	519c <printf>
}
    3830:	70e2                	ld	ra,56(sp)
    3832:	7442                	ld	s0,48(sp)
    3834:	74a2                	ld	s1,40(sp)
    3836:	7902                	ld	s2,32(sp)
    3838:	69e2                	ld	s3,24(sp)
    383a:	6a42                	ld	s4,16(sp)
    383c:	6121                	addi	sp,sp,64
    383e:	8082                	ret
  close(pfds[0]);
    3840:	fc842503          	lw	a0,-56(s0)
    3844:	558010ef          	jal	4d9c <close>
  printf("kill... ");
    3848:	00003517          	auipc	a0,0x3
    384c:	60850513          	addi	a0,a0,1544 # 6e50 <malloc+0x1c00>
    3850:	14d010ef          	jal	519c <printf>
  kill(pid1);
    3854:	8526                	mv	a0,s1
    3856:	54e010ef          	jal	4da4 <kill>
  kill(pid2);
    385a:	854e                	mv	a0,s3
    385c:	548010ef          	jal	4da4 <kill>
  kill(pid3);
    3860:	8552                	mv	a0,s4
    3862:	542010ef          	jal	4da4 <kill>
  printf("wait... ");
    3866:	00003517          	auipc	a0,0x3
    386a:	5fa50513          	addi	a0,a0,1530 # 6e60 <malloc+0x1c10>
    386e:	12f010ef          	jal	519c <printf>
  wait(0);
    3872:	4501                	li	a0,0
    3874:	508010ef          	jal	4d7c <wait>
  wait(0);
    3878:	4501                	li	a0,0
    387a:	502010ef          	jal	4d7c <wait>
  wait(0);
    387e:	4501                	li	a0,0
    3880:	4fc010ef          	jal	4d7c <wait>
    3884:	b775                	j	3830 <preempt+0xe6>

0000000000003886 <reparent>:
{
    3886:	7179                	addi	sp,sp,-48
    3888:	f406                	sd	ra,40(sp)
    388a:	f022                	sd	s0,32(sp)
    388c:	ec26                	sd	s1,24(sp)
    388e:	e84a                	sd	s2,16(sp)
    3890:	e44e                	sd	s3,8(sp)
    3892:	e052                	sd	s4,0(sp)
    3894:	1800                	addi	s0,sp,48
    3896:	89aa                	mv	s3,a0
  int master_pid = getpid();
    3898:	55c010ef          	jal	4df4 <getpid>
    389c:	8a2a                	mv	s4,a0
    389e:	0c800913          	li	s2,200
    int pid = fork();
    38a2:	4ca010ef          	jal	4d6c <fork>
    38a6:	84aa                	mv	s1,a0
    if(pid < 0){
    38a8:	00054e63          	bltz	a0,38c4 <reparent+0x3e>
    if(pid){
    38ac:	c121                	beqz	a0,38ec <reparent+0x66>
      if(wait(0) != pid){
    38ae:	4501                	li	a0,0
    38b0:	4cc010ef          	jal	4d7c <wait>
    38b4:	02951263          	bne	a0,s1,38d8 <reparent+0x52>
  for(int i = 0; i < 200; i++){
    38b8:	397d                	addiw	s2,s2,-1
    38ba:	fe0914e3          	bnez	s2,38a2 <reparent+0x1c>
  exit(0);
    38be:	4501                	li	a0,0
    38c0:	4b4010ef          	jal	4d74 <exit>
      printf("%s: fork failed\n", s);
    38c4:	85ce                	mv	a1,s3
    38c6:	00002517          	auipc	a0,0x2
    38ca:	35250513          	addi	a0,a0,850 # 5c18 <malloc+0x9c8>
    38ce:	0cf010ef          	jal	519c <printf>
      exit(1);
    38d2:	4505                	li	a0,1
    38d4:	4a0010ef          	jal	4d74 <exit>
        printf("%s: wait wrong pid\n", s);
    38d8:	85ce                	mv	a1,s3
    38da:	00002517          	auipc	a0,0x2
    38de:	4c650513          	addi	a0,a0,1222 # 5da0 <malloc+0xb50>
    38e2:	0bb010ef          	jal	519c <printf>
        exit(1);
    38e6:	4505                	li	a0,1
    38e8:	48c010ef          	jal	4d74 <exit>
      int pid2 = fork();
    38ec:	480010ef          	jal	4d6c <fork>
      if(pid2 < 0){
    38f0:	00054563          	bltz	a0,38fa <reparent+0x74>
      exit(0);
    38f4:	4501                	li	a0,0
    38f6:	47e010ef          	jal	4d74 <exit>
        kill(master_pid);
    38fa:	8552                	mv	a0,s4
    38fc:	4a8010ef          	jal	4da4 <kill>
        exit(1);
    3900:	4505                	li	a0,1
    3902:	472010ef          	jal	4d74 <exit>

0000000000003906 <sbrkfail>:
{
    3906:	7175                	addi	sp,sp,-144
    3908:	e506                	sd	ra,136(sp)
    390a:	e122                	sd	s0,128(sp)
    390c:	fca6                	sd	s1,120(sp)
    390e:	f8ca                	sd	s2,112(sp)
    3910:	f4ce                	sd	s3,104(sp)
    3912:	f0d2                	sd	s4,96(sp)
    3914:	ecd6                	sd	s5,88(sp)
    3916:	e8da                	sd	s6,80(sp)
    3918:	e4de                	sd	s7,72(sp)
    391a:	0900                	addi	s0,sp,144
    391c:	8b2a                	mv	s6,a0
  if(pipe(fds) != 0){
    391e:	fa040513          	addi	a0,s0,-96
    3922:	462010ef          	jal	4d84 <pipe>
    3926:	e919                	bnez	a0,393c <sbrkfail+0x36>
    3928:	8aaa                	mv	s5,a0
    392a:	f7040493          	addi	s1,s0,-144
    392e:	f9840993          	addi	s3,s0,-104
    3932:	8926                	mv	s2,s1
    if(pids[i] != -1) {
    3934:	5a7d                	li	s4,-1
      if(scratch == '0')
    3936:	03000b93          	li	s7,48
    393a:	a08d                	j	399c <sbrkfail+0x96>
    printf("%s: pipe() failed\n", s);
    393c:	85da                	mv	a1,s6
    393e:	00002517          	auipc	a0,0x2
    3942:	3e250513          	addi	a0,a0,994 # 5d20 <malloc+0xad0>
    3946:	057010ef          	jal	519c <printf>
    exit(1);
    394a:	4505                	li	a0,1
    394c:	428010ef          	jal	4d74 <exit>
      if (sbrk(BIG - (uint64)sbrk(0)) ==  (char*)SBRK_ERROR)
    3950:	3f0010ef          	jal	4d40 <sbrk>
    3954:	064007b7          	lui	a5,0x6400
    3958:	40a7853b          	subw	a0,a5,a0
    395c:	3e4010ef          	jal	4d40 <sbrk>
    3960:	57fd                	li	a5,-1
    3962:	02f50063          	beq	a0,a5,3982 <sbrkfail+0x7c>
        write(fds[1], "1", 1);
    3966:	4605                	li	a2,1
    3968:	00004597          	auipc	a1,0x4
    396c:	c8058593          	addi	a1,a1,-896 # 75e8 <malloc+0x2398>
    3970:	fa442503          	lw	a0,-92(s0)
    3974:	420010ef          	jal	4d94 <write>
      for(;;) pause(1000);
    3978:	3e800513          	li	a0,1000
    397c:	488010ef          	jal	4e04 <pause>
    3980:	bfe5                	j	3978 <sbrkfail+0x72>
        write(fds[1], "0", 1);
    3982:	4605                	li	a2,1
    3984:	00003597          	auipc	a1,0x3
    3988:	4ec58593          	addi	a1,a1,1260 # 6e70 <malloc+0x1c20>
    398c:	fa442503          	lw	a0,-92(s0)
    3990:	404010ef          	jal	4d94 <write>
    3994:	b7d5                	j	3978 <sbrkfail+0x72>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3996:	0911                	addi	s2,s2,4
    3998:	03390663          	beq	s2,s3,39c4 <sbrkfail+0xbe>
    if((pids[i] = fork()) == 0){
    399c:	3d0010ef          	jal	4d6c <fork>
    39a0:	00a92023          	sw	a0,0(s2)
    39a4:	d555                	beqz	a0,3950 <sbrkfail+0x4a>
    if(pids[i] != -1) {
    39a6:	ff4508e3          	beq	a0,s4,3996 <sbrkfail+0x90>
      read(fds[0], &scratch, 1);
    39aa:	4605                	li	a2,1
    39ac:	f9f40593          	addi	a1,s0,-97
    39b0:	fa042503          	lw	a0,-96(s0)
    39b4:	3d8010ef          	jal	4d8c <read>
      if(scratch == '0')
    39b8:	f9f44783          	lbu	a5,-97(s0)
    39bc:	fd779de3          	bne	a5,s7,3996 <sbrkfail+0x90>
        failed = 1;
    39c0:	4a85                	li	s5,1
    39c2:	bfd1                	j	3996 <sbrkfail+0x90>
  if(!failed) {
    39c4:	000a8863          	beqz	s5,39d4 <sbrkfail+0xce>
  c = sbrk(PGSIZE);
    39c8:	6505                	lui	a0,0x1
    39ca:	376010ef          	jal	4d40 <sbrk>
    39ce:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    39d0:	597d                	li	s2,-1
    39d2:	a821                	j	39ea <sbrkfail+0xe4>
    printf("%s: no allocation failed; allocate more?\n", s);
    39d4:	85da                	mv	a1,s6
    39d6:	00003517          	auipc	a0,0x3
    39da:	4a250513          	addi	a0,a0,1186 # 6e78 <malloc+0x1c28>
    39de:	7be010ef          	jal	519c <printf>
    39e2:	b7dd                	j	39c8 <sbrkfail+0xc2>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    39e4:	0491                	addi	s1,s1,4
    39e6:	01348b63          	beq	s1,s3,39fc <sbrkfail+0xf6>
    if(pids[i] == -1)
    39ea:	4088                	lw	a0,0(s1)
    39ec:	ff250ce3          	beq	a0,s2,39e4 <sbrkfail+0xde>
    kill(pids[i]);
    39f0:	3b4010ef          	jal	4da4 <kill>
    wait(0);
    39f4:	4501                	li	a0,0
    39f6:	386010ef          	jal	4d7c <wait>
    39fa:	b7ed                	j	39e4 <sbrkfail+0xde>
  if(c == (char*)SBRK_ERROR){
    39fc:	57fd                	li	a5,-1
    39fe:	02fa0a63          	beq	s4,a5,3a32 <sbrkfail+0x12c>
  pid = fork();
    3a02:	36a010ef          	jal	4d6c <fork>
  if(pid < 0){
    3a06:	04054063          	bltz	a0,3a46 <sbrkfail+0x140>
  if(pid == 0){
    3a0a:	e939                	bnez	a0,3a60 <sbrkfail+0x15a>
    a = sbrk(10*BIG);
    3a0c:	3e800537          	lui	a0,0x3e800
    3a10:	330010ef          	jal	4d40 <sbrk>
    if(a == (char*)SBRK_ERROR){
    3a14:	57fd                	li	a5,-1
    3a16:	04f50263          	beq	a0,a5,3a5a <sbrkfail+0x154>
    printf("%s: allocate a lot of memory succeeded %d\n", s, 10*BIG);
    3a1a:	3e800637          	lui	a2,0x3e800
    3a1e:	85da                	mv	a1,s6
    3a20:	00003517          	auipc	a0,0x3
    3a24:	4a850513          	addi	a0,a0,1192 # 6ec8 <malloc+0x1c78>
    3a28:	774010ef          	jal	519c <printf>
    exit(1);
    3a2c:	4505                	li	a0,1
    3a2e:	346010ef          	jal	4d74 <exit>
    printf("%s: failed sbrk leaked memory\n", s);
    3a32:	85da                	mv	a1,s6
    3a34:	00003517          	auipc	a0,0x3
    3a38:	47450513          	addi	a0,a0,1140 # 6ea8 <malloc+0x1c58>
    3a3c:	760010ef          	jal	519c <printf>
    exit(1);
    3a40:	4505                	li	a0,1
    3a42:	332010ef          	jal	4d74 <exit>
    printf("%s: fork failed\n", s);
    3a46:	85da                	mv	a1,s6
    3a48:	00002517          	auipc	a0,0x2
    3a4c:	1d050513          	addi	a0,a0,464 # 5c18 <malloc+0x9c8>
    3a50:	74c010ef          	jal	519c <printf>
    exit(1);
    3a54:	4505                	li	a0,1
    3a56:	31e010ef          	jal	4d74 <exit>
      exit(0);
    3a5a:	4501                	li	a0,0
    3a5c:	318010ef          	jal	4d74 <exit>
  wait(&xstatus);
    3a60:	fac40513          	addi	a0,s0,-84
    3a64:	318010ef          	jal	4d7c <wait>
  if(xstatus != 0)
    3a68:	fac42783          	lw	a5,-84(s0)
    3a6c:	ef81                	bnez	a5,3a84 <sbrkfail+0x17e>
}
    3a6e:	60aa                	ld	ra,136(sp)
    3a70:	640a                	ld	s0,128(sp)
    3a72:	74e6                	ld	s1,120(sp)
    3a74:	7946                	ld	s2,112(sp)
    3a76:	79a6                	ld	s3,104(sp)
    3a78:	7a06                	ld	s4,96(sp)
    3a7a:	6ae6                	ld	s5,88(sp)
    3a7c:	6b46                	ld	s6,80(sp)
    3a7e:	6ba6                	ld	s7,72(sp)
    3a80:	6149                	addi	sp,sp,144
    3a82:	8082                	ret
    exit(1);
    3a84:	4505                	li	a0,1
    3a86:	2ee010ef          	jal	4d74 <exit>

0000000000003a8a <mem>:
{
    3a8a:	7139                	addi	sp,sp,-64
    3a8c:	fc06                	sd	ra,56(sp)
    3a8e:	f822                	sd	s0,48(sp)
    3a90:	f426                	sd	s1,40(sp)
    3a92:	f04a                	sd	s2,32(sp)
    3a94:	ec4e                	sd	s3,24(sp)
    3a96:	0080                	addi	s0,sp,64
    3a98:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    3a9a:	2d2010ef          	jal	4d6c <fork>
    m1 = 0;
    3a9e:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    3aa0:	6909                	lui	s2,0x2
    3aa2:	71190913          	addi	s2,s2,1809 # 2711 <fourteen+0x97>
  if((pid = fork()) == 0){
    3aa6:	cd11                	beqz	a0,3ac2 <mem+0x38>
    wait(&xstatus);
    3aa8:	fcc40513          	addi	a0,s0,-52
    3aac:	2d0010ef          	jal	4d7c <wait>
    if(xstatus == -1){
    3ab0:	fcc42503          	lw	a0,-52(s0)
    3ab4:	57fd                	li	a5,-1
    3ab6:	04f50363          	beq	a0,a5,3afc <mem+0x72>
    exit(xstatus);
    3aba:	2ba010ef          	jal	4d74 <exit>
      *(char**)m2 = m1;
    3abe:	e104                	sd	s1,0(a0)
      m1 = m2;
    3ac0:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    3ac2:	854a                	mv	a0,s2
    3ac4:	78c010ef          	jal	5250 <malloc>
    3ac8:	f97d                	bnez	a0,3abe <mem+0x34>
    while(m1){
    3aca:	c491                	beqz	s1,3ad6 <mem+0x4c>
      m2 = *(char**)m1;
    3acc:	8526                	mv	a0,s1
    3ace:	6084                	ld	s1,0(s1)
      free(m1);
    3ad0:	6fe010ef          	jal	51ce <free>
    while(m1){
    3ad4:	fce5                	bnez	s1,3acc <mem+0x42>
    m1 = malloc(1024*20);
    3ad6:	6515                	lui	a0,0x5
    3ad8:	778010ef          	jal	5250 <malloc>
    if(m1 == 0){
    3adc:	c511                	beqz	a0,3ae8 <mem+0x5e>
    free(m1);
    3ade:	6f0010ef          	jal	51ce <free>
    exit(0);
    3ae2:	4501                	li	a0,0
    3ae4:	290010ef          	jal	4d74 <exit>
      printf("%s: couldn't allocate mem?!!\n", s);
    3ae8:	85ce                	mv	a1,s3
    3aea:	00003517          	auipc	a0,0x3
    3aee:	40e50513          	addi	a0,a0,1038 # 6ef8 <malloc+0x1ca8>
    3af2:	6aa010ef          	jal	519c <printf>
      exit(1);
    3af6:	4505                	li	a0,1
    3af8:	27c010ef          	jal	4d74 <exit>
      exit(0);
    3afc:	4501                	li	a0,0
    3afe:	276010ef          	jal	4d74 <exit>

0000000000003b02 <sharedfd>:
{
    3b02:	7159                	addi	sp,sp,-112
    3b04:	f486                	sd	ra,104(sp)
    3b06:	f0a2                	sd	s0,96(sp)
    3b08:	e0d2                	sd	s4,64(sp)
    3b0a:	1880                	addi	s0,sp,112
    3b0c:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    3b0e:	00003517          	auipc	a0,0x3
    3b12:	40a50513          	addi	a0,a0,1034 # 6f18 <malloc+0x1cc8>
    3b16:	2ae010ef          	jal	4dc4 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    3b1a:	20200593          	li	a1,514
    3b1e:	00003517          	auipc	a0,0x3
    3b22:	3fa50513          	addi	a0,a0,1018 # 6f18 <malloc+0x1cc8>
    3b26:	28e010ef          	jal	4db4 <open>
  if(fd < 0){
    3b2a:	04054863          	bltz	a0,3b7a <sharedfd+0x78>
    3b2e:	eca6                	sd	s1,88(sp)
    3b30:	e8ca                	sd	s2,80(sp)
    3b32:	e4ce                	sd	s3,72(sp)
    3b34:	fc56                	sd	s5,56(sp)
    3b36:	f85a                	sd	s6,48(sp)
    3b38:	f45e                	sd	s7,40(sp)
    3b3a:	892a                	mv	s2,a0
  pid = fork();
    3b3c:	230010ef          	jal	4d6c <fork>
    3b40:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    3b42:	07000593          	li	a1,112
    3b46:	e119                	bnez	a0,3b4c <sharedfd+0x4a>
    3b48:	06300593          	li	a1,99
    3b4c:	4629                	li	a2,10
    3b4e:	fa040513          	addi	a0,s0,-96
    3b52:	010010ef          	jal	4b62 <memset>
    3b56:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    3b5a:	4629                	li	a2,10
    3b5c:	fa040593          	addi	a1,s0,-96
    3b60:	854a                	mv	a0,s2
    3b62:	232010ef          	jal	4d94 <write>
    3b66:	47a9                	li	a5,10
    3b68:	02f51963          	bne	a0,a5,3b9a <sharedfd+0x98>
  for(i = 0; i < N; i++){
    3b6c:	34fd                	addiw	s1,s1,-1
    3b6e:	f4f5                	bnez	s1,3b5a <sharedfd+0x58>
  if(pid == 0) {
    3b70:	02099f63          	bnez	s3,3bae <sharedfd+0xac>
    exit(0);
    3b74:	4501                	li	a0,0
    3b76:	1fe010ef          	jal	4d74 <exit>
    3b7a:	eca6                	sd	s1,88(sp)
    3b7c:	e8ca                	sd	s2,80(sp)
    3b7e:	e4ce                	sd	s3,72(sp)
    3b80:	fc56                	sd	s5,56(sp)
    3b82:	f85a                	sd	s6,48(sp)
    3b84:	f45e                	sd	s7,40(sp)
    printf("%s: cannot open sharedfd for writing", s);
    3b86:	85d2                	mv	a1,s4
    3b88:	00003517          	auipc	a0,0x3
    3b8c:	3a050513          	addi	a0,a0,928 # 6f28 <malloc+0x1cd8>
    3b90:	60c010ef          	jal	519c <printf>
    exit(1);
    3b94:	4505                	li	a0,1
    3b96:	1de010ef          	jal	4d74 <exit>
      printf("%s: write sharedfd failed\n", s);
    3b9a:	85d2                	mv	a1,s4
    3b9c:	00003517          	auipc	a0,0x3
    3ba0:	3b450513          	addi	a0,a0,948 # 6f50 <malloc+0x1d00>
    3ba4:	5f8010ef          	jal	519c <printf>
      exit(1);
    3ba8:	4505                	li	a0,1
    3baa:	1ca010ef          	jal	4d74 <exit>
    wait(&xstatus);
    3bae:	f9c40513          	addi	a0,s0,-100
    3bb2:	1ca010ef          	jal	4d7c <wait>
    if(xstatus != 0)
    3bb6:	f9c42983          	lw	s3,-100(s0)
    3bba:	00098563          	beqz	s3,3bc4 <sharedfd+0xc2>
      exit(xstatus);
    3bbe:	854e                	mv	a0,s3
    3bc0:	1b4010ef          	jal	4d74 <exit>
  close(fd);
    3bc4:	854a                	mv	a0,s2
    3bc6:	1d6010ef          	jal	4d9c <close>
  fd = open("sharedfd", 0);
    3bca:	4581                	li	a1,0
    3bcc:	00003517          	auipc	a0,0x3
    3bd0:	34c50513          	addi	a0,a0,844 # 6f18 <malloc+0x1cc8>
    3bd4:	1e0010ef          	jal	4db4 <open>
    3bd8:	8baa                	mv	s7,a0
  nc = np = 0;
    3bda:	8ace                	mv	s5,s3
  if(fd < 0){
    3bdc:	02054363          	bltz	a0,3c02 <sharedfd+0x100>
    3be0:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    3be4:	06300493          	li	s1,99
      if(buf[i] == 'p')
    3be8:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    3bec:	4629                	li	a2,10
    3bee:	fa040593          	addi	a1,s0,-96
    3bf2:	855e                	mv	a0,s7
    3bf4:	198010ef          	jal	4d8c <read>
    3bf8:	02a05b63          	blez	a0,3c2e <sharedfd+0x12c>
    3bfc:	fa040793          	addi	a5,s0,-96
    3c00:	a839                	j	3c1e <sharedfd+0x11c>
    printf("%s: cannot open sharedfd for reading\n", s);
    3c02:	85d2                	mv	a1,s4
    3c04:	00003517          	auipc	a0,0x3
    3c08:	36c50513          	addi	a0,a0,876 # 6f70 <malloc+0x1d20>
    3c0c:	590010ef          	jal	519c <printf>
    exit(1);
    3c10:	4505                	li	a0,1
    3c12:	162010ef          	jal	4d74 <exit>
        nc++;
    3c16:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    3c18:	0785                	addi	a5,a5,1 # 6400001 <base+0x63f0349>
    3c1a:	fd2789e3          	beq	a5,s2,3bec <sharedfd+0xea>
      if(buf[i] == 'c')
    3c1e:	0007c703          	lbu	a4,0(a5)
    3c22:	fe970ae3          	beq	a4,s1,3c16 <sharedfd+0x114>
      if(buf[i] == 'p')
    3c26:	ff6719e3          	bne	a4,s6,3c18 <sharedfd+0x116>
        np++;
    3c2a:	2a85                	addiw	s5,s5,1
    3c2c:	b7f5                	j	3c18 <sharedfd+0x116>
  close(fd);
    3c2e:	855e                	mv	a0,s7
    3c30:	16c010ef          	jal	4d9c <close>
  unlink("sharedfd");
    3c34:	00003517          	auipc	a0,0x3
    3c38:	2e450513          	addi	a0,a0,740 # 6f18 <malloc+0x1cc8>
    3c3c:	188010ef          	jal	4dc4 <unlink>
  if(nc == N*SZ && np == N*SZ){
    3c40:	6789                	lui	a5,0x2
    3c42:	71078793          	addi	a5,a5,1808 # 2710 <fourteen+0x96>
    3c46:	00f99763          	bne	s3,a5,3c54 <sharedfd+0x152>
    3c4a:	6789                	lui	a5,0x2
    3c4c:	71078793          	addi	a5,a5,1808 # 2710 <fourteen+0x96>
    3c50:	00fa8c63          	beq	s5,a5,3c68 <sharedfd+0x166>
    printf("%s: nc/np test fails\n", s);
    3c54:	85d2                	mv	a1,s4
    3c56:	00003517          	auipc	a0,0x3
    3c5a:	34250513          	addi	a0,a0,834 # 6f98 <malloc+0x1d48>
    3c5e:	53e010ef          	jal	519c <printf>
    exit(1);
    3c62:	4505                	li	a0,1
    3c64:	110010ef          	jal	4d74 <exit>
    exit(0);
    3c68:	4501                	li	a0,0
    3c6a:	10a010ef          	jal	4d74 <exit>

0000000000003c6e <fourfiles>:
{
    3c6e:	7135                	addi	sp,sp,-160
    3c70:	ed06                	sd	ra,152(sp)
    3c72:	e922                	sd	s0,144(sp)
    3c74:	e526                	sd	s1,136(sp)
    3c76:	e14a                	sd	s2,128(sp)
    3c78:	fcce                	sd	s3,120(sp)
    3c7a:	f8d2                	sd	s4,112(sp)
    3c7c:	f4d6                	sd	s5,104(sp)
    3c7e:	f0da                	sd	s6,96(sp)
    3c80:	ecde                	sd	s7,88(sp)
    3c82:	e8e2                	sd	s8,80(sp)
    3c84:	e4e6                	sd	s9,72(sp)
    3c86:	e0ea                	sd	s10,64(sp)
    3c88:	fc6e                	sd	s11,56(sp)
    3c8a:	1100                	addi	s0,sp,160
    3c8c:	8caa                	mv	s9,a0
  char *names[] = { "f0", "f1", "f2", "f3" };
    3c8e:	00003797          	auipc	a5,0x3
    3c92:	32278793          	addi	a5,a5,802 # 6fb0 <malloc+0x1d60>
    3c96:	f6f43823          	sd	a5,-144(s0)
    3c9a:	00003797          	auipc	a5,0x3
    3c9e:	31e78793          	addi	a5,a5,798 # 6fb8 <malloc+0x1d68>
    3ca2:	f6f43c23          	sd	a5,-136(s0)
    3ca6:	00003797          	auipc	a5,0x3
    3caa:	31a78793          	addi	a5,a5,794 # 6fc0 <malloc+0x1d70>
    3cae:	f8f43023          	sd	a5,-128(s0)
    3cb2:	00003797          	auipc	a5,0x3
    3cb6:	31678793          	addi	a5,a5,790 # 6fc8 <malloc+0x1d78>
    3cba:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    3cbe:	f7040b93          	addi	s7,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    3cc2:	895e                	mv	s2,s7
  for(pi = 0; pi < NCHILD; pi++){
    3cc4:	4481                	li	s1,0
    3cc6:	4a11                	li	s4,4
    fname = names[pi];
    3cc8:	00093983          	ld	s3,0(s2)
    unlink(fname);
    3ccc:	854e                	mv	a0,s3
    3cce:	0f6010ef          	jal	4dc4 <unlink>
    pid = fork();
    3cd2:	09a010ef          	jal	4d6c <fork>
    if(pid < 0){
    3cd6:	02054e63          	bltz	a0,3d12 <fourfiles+0xa4>
    if(pid == 0){
    3cda:	c531                	beqz	a0,3d26 <fourfiles+0xb8>
  for(pi = 0; pi < NCHILD; pi++){
    3cdc:	2485                	addiw	s1,s1,1
    3cde:	0921                	addi	s2,s2,8
    3ce0:	ff4494e3          	bne	s1,s4,3cc8 <fourfiles+0x5a>
    3ce4:	4491                	li	s1,4
    wait(&xstatus);
    3ce6:	f6c40513          	addi	a0,s0,-148
    3cea:	092010ef          	jal	4d7c <wait>
    if(xstatus != 0)
    3cee:	f6c42a83          	lw	s5,-148(s0)
    3cf2:	0a0a9463          	bnez	s5,3d9a <fourfiles+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    3cf6:	34fd                	addiw	s1,s1,-1
    3cf8:	f4fd                	bnez	s1,3ce6 <fourfiles+0x78>
    3cfa:	03000b13          	li	s6,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    3cfe:	00009a17          	auipc	s4,0x9
    3d02:	fbaa0a13          	addi	s4,s4,-70 # ccb8 <buf>
    if(total != N*SZ){
    3d06:	6d05                	lui	s10,0x1
    3d08:	770d0d13          	addi	s10,s10,1904 # 1770 <forkfork+0x1e>
  for(i = 0; i < NCHILD; i++){
    3d0c:	03400d93          	li	s11,52
    3d10:	a0ed                	j	3dfa <fourfiles+0x18c>
      printf("%s: fork failed\n", s);
    3d12:	85e6                	mv	a1,s9
    3d14:	00002517          	auipc	a0,0x2
    3d18:	f0450513          	addi	a0,a0,-252 # 5c18 <malloc+0x9c8>
    3d1c:	480010ef          	jal	519c <printf>
      exit(1);
    3d20:	4505                	li	a0,1
    3d22:	052010ef          	jal	4d74 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    3d26:	20200593          	li	a1,514
    3d2a:	854e                	mv	a0,s3
    3d2c:	088010ef          	jal	4db4 <open>
    3d30:	892a                	mv	s2,a0
      if(fd < 0){
    3d32:	04054163          	bltz	a0,3d74 <fourfiles+0x106>
      memset(buf, '0'+pi, SZ);
    3d36:	1f400613          	li	a2,500
    3d3a:	0304859b          	addiw	a1,s1,48
    3d3e:	00009517          	auipc	a0,0x9
    3d42:	f7a50513          	addi	a0,a0,-134 # ccb8 <buf>
    3d46:	61d000ef          	jal	4b62 <memset>
    3d4a:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    3d4c:	00009997          	auipc	s3,0x9
    3d50:	f6c98993          	addi	s3,s3,-148 # ccb8 <buf>
    3d54:	1f400613          	li	a2,500
    3d58:	85ce                	mv	a1,s3
    3d5a:	854a                	mv	a0,s2
    3d5c:	038010ef          	jal	4d94 <write>
    3d60:	85aa                	mv	a1,a0
    3d62:	1f400793          	li	a5,500
    3d66:	02f51163          	bne	a0,a5,3d88 <fourfiles+0x11a>
      for(i = 0; i < N; i++){
    3d6a:	34fd                	addiw	s1,s1,-1
    3d6c:	f4e5                	bnez	s1,3d54 <fourfiles+0xe6>
      exit(0);
    3d6e:	4501                	li	a0,0
    3d70:	004010ef          	jal	4d74 <exit>
        printf("%s: create failed\n", s);
    3d74:	85e6                	mv	a1,s9
    3d76:	00002517          	auipc	a0,0x2
    3d7a:	f3a50513          	addi	a0,a0,-198 # 5cb0 <malloc+0xa60>
    3d7e:	41e010ef          	jal	519c <printf>
        exit(1);
    3d82:	4505                	li	a0,1
    3d84:	7f1000ef          	jal	4d74 <exit>
          printf("write failed %d\n", n);
    3d88:	00003517          	auipc	a0,0x3
    3d8c:	24850513          	addi	a0,a0,584 # 6fd0 <malloc+0x1d80>
    3d90:	40c010ef          	jal	519c <printf>
          exit(1);
    3d94:	4505                	li	a0,1
    3d96:	7df000ef          	jal	4d74 <exit>
      exit(xstatus);
    3d9a:	8556                	mv	a0,s5
    3d9c:	7d9000ef          	jal	4d74 <exit>
          printf("%s: wrong char\n", s);
    3da0:	85e6                	mv	a1,s9
    3da2:	00003517          	auipc	a0,0x3
    3da6:	24650513          	addi	a0,a0,582 # 6fe8 <malloc+0x1d98>
    3daa:	3f2010ef          	jal	519c <printf>
          exit(1);
    3dae:	4505                	li	a0,1
    3db0:	7c5000ef          	jal	4d74 <exit>
      total += n;
    3db4:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    3db8:	660d                	lui	a2,0x3
    3dba:	85d2                	mv	a1,s4
    3dbc:	854e                	mv	a0,s3
    3dbe:	7cf000ef          	jal	4d8c <read>
    3dc2:	02a05063          	blez	a0,3de2 <fourfiles+0x174>
    3dc6:	00009797          	auipc	a5,0x9
    3dca:	ef278793          	addi	a5,a5,-270 # ccb8 <buf>
    3dce:	00f506b3          	add	a3,a0,a5
        if(buf[j] != '0'+i){
    3dd2:	0007c703          	lbu	a4,0(a5)
    3dd6:	fc9715e3          	bne	a4,s1,3da0 <fourfiles+0x132>
      for(j = 0; j < n; j++){
    3dda:	0785                	addi	a5,a5,1
    3ddc:	fed79be3          	bne	a5,a3,3dd2 <fourfiles+0x164>
    3de0:	bfd1                	j	3db4 <fourfiles+0x146>
    close(fd);
    3de2:	854e                	mv	a0,s3
    3de4:	7b9000ef          	jal	4d9c <close>
    if(total != N*SZ){
    3de8:	03a91463          	bne	s2,s10,3e10 <fourfiles+0x1a2>
    unlink(fname);
    3dec:	8562                	mv	a0,s8
    3dee:	7d7000ef          	jal	4dc4 <unlink>
  for(i = 0; i < NCHILD; i++){
    3df2:	0ba1                	addi	s7,s7,8
    3df4:	2b05                	addiw	s6,s6,1
    3df6:	03bb0763          	beq	s6,s11,3e24 <fourfiles+0x1b6>
    fname = names[i];
    3dfa:	000bbc03          	ld	s8,0(s7)
    fd = open(fname, 0);
    3dfe:	4581                	li	a1,0
    3e00:	8562                	mv	a0,s8
    3e02:	7b3000ef          	jal	4db4 <open>
    3e06:	89aa                	mv	s3,a0
    total = 0;
    3e08:	8956                	mv	s2,s5
        if(buf[j] != '0'+i){
    3e0a:	000b049b          	sext.w	s1,s6
    while((n = read(fd, buf, sizeof(buf))) > 0){
    3e0e:	b76d                	j	3db8 <fourfiles+0x14a>
      printf("wrong length %d\n", total);
    3e10:	85ca                	mv	a1,s2
    3e12:	00003517          	auipc	a0,0x3
    3e16:	1e650513          	addi	a0,a0,486 # 6ff8 <malloc+0x1da8>
    3e1a:	382010ef          	jal	519c <printf>
      exit(1);
    3e1e:	4505                	li	a0,1
    3e20:	755000ef          	jal	4d74 <exit>
}
    3e24:	60ea                	ld	ra,152(sp)
    3e26:	644a                	ld	s0,144(sp)
    3e28:	64aa                	ld	s1,136(sp)
    3e2a:	690a                	ld	s2,128(sp)
    3e2c:	79e6                	ld	s3,120(sp)
    3e2e:	7a46                	ld	s4,112(sp)
    3e30:	7aa6                	ld	s5,104(sp)
    3e32:	7b06                	ld	s6,96(sp)
    3e34:	6be6                	ld	s7,88(sp)
    3e36:	6c46                	ld	s8,80(sp)
    3e38:	6ca6                	ld	s9,72(sp)
    3e3a:	6d06                	ld	s10,64(sp)
    3e3c:	7de2                	ld	s11,56(sp)
    3e3e:	610d                	addi	sp,sp,160
    3e40:	8082                	ret

0000000000003e42 <concreate>:
{
    3e42:	7135                	addi	sp,sp,-160
    3e44:	ed06                	sd	ra,152(sp)
    3e46:	e922                	sd	s0,144(sp)
    3e48:	e526                	sd	s1,136(sp)
    3e4a:	e14a                	sd	s2,128(sp)
    3e4c:	fcce                	sd	s3,120(sp)
    3e4e:	f8d2                	sd	s4,112(sp)
    3e50:	f4d6                	sd	s5,104(sp)
    3e52:	f0da                	sd	s6,96(sp)
    3e54:	ecde                	sd	s7,88(sp)
    3e56:	1100                	addi	s0,sp,160
    3e58:	89aa                	mv	s3,a0
  file[0] = 'C';
    3e5a:	04300793          	li	a5,67
    3e5e:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    3e62:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    3e66:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    3e68:	4b0d                	li	s6,3
    3e6a:	4a85                	li	s5,1
      link("C0", file);
    3e6c:	00003b97          	auipc	s7,0x3
    3e70:	1a4b8b93          	addi	s7,s7,420 # 7010 <malloc+0x1dc0>
  for(i = 0; i < N; i++){
    3e74:	02800a13          	li	s4,40
    3e78:	a41d                	j	409e <concreate+0x25c>
      link("C0", file);
    3e7a:	fa840593          	addi	a1,s0,-88
    3e7e:	855e                	mv	a0,s7
    3e80:	755000ef          	jal	4dd4 <link>
    if(pid == 0) {
    3e84:	a411                	j	4088 <concreate+0x246>
    } else if(pid == 0 && (i % 5) == 1){
    3e86:	4795                	li	a5,5
    3e88:	02f9693b          	remw	s2,s2,a5
    3e8c:	4785                	li	a5,1
    3e8e:	02f90563          	beq	s2,a5,3eb8 <concreate+0x76>
      fd = open(file, O_CREATE | O_RDWR);
    3e92:	20200593          	li	a1,514
    3e96:	fa840513          	addi	a0,s0,-88
    3e9a:	71b000ef          	jal	4db4 <open>
      if(fd < 0){
    3e9e:	1e055063          	bgez	a0,407e <concreate+0x23c>
        printf("concreate create %s failed\n", file);
    3ea2:	fa840593          	addi	a1,s0,-88
    3ea6:	00003517          	auipc	a0,0x3
    3eaa:	17250513          	addi	a0,a0,370 # 7018 <malloc+0x1dc8>
    3eae:	2ee010ef          	jal	519c <printf>
        exit(1);
    3eb2:	4505                	li	a0,1
    3eb4:	6c1000ef          	jal	4d74 <exit>
      link("C0", file);
    3eb8:	fa840593          	addi	a1,s0,-88
    3ebc:	00003517          	auipc	a0,0x3
    3ec0:	15450513          	addi	a0,a0,340 # 7010 <malloc+0x1dc0>
    3ec4:	711000ef          	jal	4dd4 <link>
      exit(0);
    3ec8:	4501                	li	a0,0
    3eca:	6ab000ef          	jal	4d74 <exit>
        exit(1);
    3ece:	4505                	li	a0,1
    3ed0:	6a5000ef          	jal	4d74 <exit>
  memset(fa, 0, sizeof(fa));
    3ed4:	02800613          	li	a2,40
    3ed8:	4581                	li	a1,0
    3eda:	f8040513          	addi	a0,s0,-128
    3ede:	485000ef          	jal	4b62 <memset>
  fd = open(".", 0);
    3ee2:	4581                	li	a1,0
    3ee4:	00002517          	auipc	a0,0x2
    3ee8:	b8c50513          	addi	a0,a0,-1140 # 5a70 <malloc+0x820>
    3eec:	6c9000ef          	jal	4db4 <open>
    3ef0:	892a                	mv	s2,a0
  n = 0;
    3ef2:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    3ef4:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    3ef8:	02700b13          	li	s6,39
      fa[i] = 1;
    3efc:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    3efe:	4641                	li	a2,16
    3f00:	f7040593          	addi	a1,s0,-144
    3f04:	854a                	mv	a0,s2
    3f06:	687000ef          	jal	4d8c <read>
    3f0a:	06a05a63          	blez	a0,3f7e <concreate+0x13c>
    if(de.inum == 0)
    3f0e:	f7045783          	lhu	a5,-144(s0)
    3f12:	d7f5                	beqz	a5,3efe <concreate+0xbc>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    3f14:	f7244783          	lbu	a5,-142(s0)
    3f18:	ff4793e3          	bne	a5,s4,3efe <concreate+0xbc>
    3f1c:	f7444783          	lbu	a5,-140(s0)
    3f20:	fff9                	bnez	a5,3efe <concreate+0xbc>
      i = de.name[1] - '0';
    3f22:	f7344783          	lbu	a5,-141(s0)
    3f26:	fd07879b          	addiw	a5,a5,-48
    3f2a:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    3f2e:	02eb6063          	bltu	s6,a4,3f4e <concreate+0x10c>
      if(fa[i]){
    3f32:	fb070793          	addi	a5,a4,-80
    3f36:	97a2                	add	a5,a5,s0
    3f38:	fd07c783          	lbu	a5,-48(a5)
    3f3c:	e78d                	bnez	a5,3f66 <concreate+0x124>
      fa[i] = 1;
    3f3e:	fb070793          	addi	a5,a4,-80
    3f42:	00878733          	add	a4,a5,s0
    3f46:	fd770823          	sb	s7,-48(a4)
      n++;
    3f4a:	2a85                	addiw	s5,s5,1
    3f4c:	bf4d                	j	3efe <concreate+0xbc>
        printf("%s: concreate weird file %s\n", s, de.name);
    3f4e:	f7240613          	addi	a2,s0,-142
    3f52:	85ce                	mv	a1,s3
    3f54:	00003517          	auipc	a0,0x3
    3f58:	0e450513          	addi	a0,a0,228 # 7038 <malloc+0x1de8>
    3f5c:	240010ef          	jal	519c <printf>
        exit(1);
    3f60:	4505                	li	a0,1
    3f62:	613000ef          	jal	4d74 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    3f66:	f7240613          	addi	a2,s0,-142
    3f6a:	85ce                	mv	a1,s3
    3f6c:	00003517          	auipc	a0,0x3
    3f70:	0ec50513          	addi	a0,a0,236 # 7058 <malloc+0x1e08>
    3f74:	228010ef          	jal	519c <printf>
        exit(1);
    3f78:	4505                	li	a0,1
    3f7a:	5fb000ef          	jal	4d74 <exit>
  close(fd);
    3f7e:	854a                	mv	a0,s2
    3f80:	61d000ef          	jal	4d9c <close>
  if(n != N){
    3f84:	02800793          	li	a5,40
    3f88:	00fa9763          	bne	s5,a5,3f96 <concreate+0x154>
    if(((i % 3) == 0 && pid == 0) ||
    3f8c:	4a8d                	li	s5,3
    3f8e:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    3f90:	02800a13          	li	s4,40
    3f94:	a079                	j	4022 <concreate+0x1e0>
    printf("%s: concreate not enough files in directory listing\n", s);
    3f96:	85ce                	mv	a1,s3
    3f98:	00003517          	auipc	a0,0x3
    3f9c:	0e850513          	addi	a0,a0,232 # 7080 <malloc+0x1e30>
    3fa0:	1fc010ef          	jal	519c <printf>
    exit(1);
    3fa4:	4505                	li	a0,1
    3fa6:	5cf000ef          	jal	4d74 <exit>
      printf("%s: fork failed\n", s);
    3faa:	85ce                	mv	a1,s3
    3fac:	00002517          	auipc	a0,0x2
    3fb0:	c6c50513          	addi	a0,a0,-916 # 5c18 <malloc+0x9c8>
    3fb4:	1e8010ef          	jal	519c <printf>
      exit(1);
    3fb8:	4505                	li	a0,1
    3fba:	5bb000ef          	jal	4d74 <exit>
      close(open(file, 0));
    3fbe:	4581                	li	a1,0
    3fc0:	fa840513          	addi	a0,s0,-88
    3fc4:	5f1000ef          	jal	4db4 <open>
    3fc8:	5d5000ef          	jal	4d9c <close>
      close(open(file, 0));
    3fcc:	4581                	li	a1,0
    3fce:	fa840513          	addi	a0,s0,-88
    3fd2:	5e3000ef          	jal	4db4 <open>
    3fd6:	5c7000ef          	jal	4d9c <close>
      close(open(file, 0));
    3fda:	4581                	li	a1,0
    3fdc:	fa840513          	addi	a0,s0,-88
    3fe0:	5d5000ef          	jal	4db4 <open>
    3fe4:	5b9000ef          	jal	4d9c <close>
      close(open(file, 0));
    3fe8:	4581                	li	a1,0
    3fea:	fa840513          	addi	a0,s0,-88
    3fee:	5c7000ef          	jal	4db4 <open>
    3ff2:	5ab000ef          	jal	4d9c <close>
      close(open(file, 0));
    3ff6:	4581                	li	a1,0
    3ff8:	fa840513          	addi	a0,s0,-88
    3ffc:	5b9000ef          	jal	4db4 <open>
    4000:	59d000ef          	jal	4d9c <close>
      close(open(file, 0));
    4004:	4581                	li	a1,0
    4006:	fa840513          	addi	a0,s0,-88
    400a:	5ab000ef          	jal	4db4 <open>
    400e:	58f000ef          	jal	4d9c <close>
    if(pid == 0)
    4012:	06090363          	beqz	s2,4078 <concreate+0x236>
      wait(0);
    4016:	4501                	li	a0,0
    4018:	565000ef          	jal	4d7c <wait>
  for(i = 0; i < N; i++){
    401c:	2485                	addiw	s1,s1,1
    401e:	0b448963          	beq	s1,s4,40d0 <concreate+0x28e>
    file[1] = '0' + i;
    4022:	0304879b          	addiw	a5,s1,48
    4026:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    402a:	543000ef          	jal	4d6c <fork>
    402e:	892a                	mv	s2,a0
    if(pid < 0){
    4030:	f6054de3          	bltz	a0,3faa <concreate+0x168>
    if(((i % 3) == 0 && pid == 0) ||
    4034:	0354e73b          	remw	a4,s1,s5
    4038:	00a767b3          	or	a5,a4,a0
    403c:	2781                	sext.w	a5,a5
    403e:	d3c1                	beqz	a5,3fbe <concreate+0x17c>
    4040:	01671363          	bne	a4,s6,4046 <concreate+0x204>
       ((i % 3) == 1 && pid != 0)){
    4044:	fd2d                	bnez	a0,3fbe <concreate+0x17c>
      unlink(file);
    4046:	fa840513          	addi	a0,s0,-88
    404a:	57b000ef          	jal	4dc4 <unlink>
      unlink(file);
    404e:	fa840513          	addi	a0,s0,-88
    4052:	573000ef          	jal	4dc4 <unlink>
      unlink(file);
    4056:	fa840513          	addi	a0,s0,-88
    405a:	56b000ef          	jal	4dc4 <unlink>
      unlink(file);
    405e:	fa840513          	addi	a0,s0,-88
    4062:	563000ef          	jal	4dc4 <unlink>
      unlink(file);
    4066:	fa840513          	addi	a0,s0,-88
    406a:	55b000ef          	jal	4dc4 <unlink>
      unlink(file);
    406e:	fa840513          	addi	a0,s0,-88
    4072:	553000ef          	jal	4dc4 <unlink>
    4076:	bf71                	j	4012 <concreate+0x1d0>
      exit(0);
    4078:	4501                	li	a0,0
    407a:	4fb000ef          	jal	4d74 <exit>
      close(fd);
    407e:	51f000ef          	jal	4d9c <close>
    if(pid == 0) {
    4082:	b599                	j	3ec8 <concreate+0x86>
      close(fd);
    4084:	519000ef          	jal	4d9c <close>
      wait(&xstatus);
    4088:	f6c40513          	addi	a0,s0,-148
    408c:	4f1000ef          	jal	4d7c <wait>
      if(xstatus != 0)
    4090:	f6c42483          	lw	s1,-148(s0)
    4094:	e2049de3          	bnez	s1,3ece <concreate+0x8c>
  for(i = 0; i < N; i++){
    4098:	2905                	addiw	s2,s2,1
    409a:	e3490de3          	beq	s2,s4,3ed4 <concreate+0x92>
    file[1] = '0' + i;
    409e:	0309079b          	addiw	a5,s2,48
    40a2:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    40a6:	fa840513          	addi	a0,s0,-88
    40aa:	51b000ef          	jal	4dc4 <unlink>
    pid = fork();
    40ae:	4bf000ef          	jal	4d6c <fork>
    if(pid && (i % 3) == 1){
    40b2:	dc050ae3          	beqz	a0,3e86 <concreate+0x44>
    40b6:	036967bb          	remw	a5,s2,s6
    40ba:	dd5780e3          	beq	a5,s5,3e7a <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    40be:	20200593          	li	a1,514
    40c2:	fa840513          	addi	a0,s0,-88
    40c6:	4ef000ef          	jal	4db4 <open>
      if(fd < 0){
    40ca:	fa055de3          	bgez	a0,4084 <concreate+0x242>
    40ce:	bbd1                	j	3ea2 <concreate+0x60>
}
    40d0:	60ea                	ld	ra,152(sp)
    40d2:	644a                	ld	s0,144(sp)
    40d4:	64aa                	ld	s1,136(sp)
    40d6:	690a                	ld	s2,128(sp)
    40d8:	79e6                	ld	s3,120(sp)
    40da:	7a46                	ld	s4,112(sp)
    40dc:	7aa6                	ld	s5,104(sp)
    40de:	7b06                	ld	s6,96(sp)
    40e0:	6be6                	ld	s7,88(sp)
    40e2:	610d                	addi	sp,sp,160
    40e4:	8082                	ret

00000000000040e6 <bigfile>:
{
    40e6:	7139                	addi	sp,sp,-64
    40e8:	fc06                	sd	ra,56(sp)
    40ea:	f822                	sd	s0,48(sp)
    40ec:	f426                	sd	s1,40(sp)
    40ee:	f04a                	sd	s2,32(sp)
    40f0:	ec4e                	sd	s3,24(sp)
    40f2:	e852                	sd	s4,16(sp)
    40f4:	e456                	sd	s5,8(sp)
    40f6:	0080                	addi	s0,sp,64
    40f8:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    40fa:	00003517          	auipc	a0,0x3
    40fe:	fbe50513          	addi	a0,a0,-66 # 70b8 <malloc+0x1e68>
    4102:	4c3000ef          	jal	4dc4 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    4106:	20200593          	li	a1,514
    410a:	00003517          	auipc	a0,0x3
    410e:	fae50513          	addi	a0,a0,-82 # 70b8 <malloc+0x1e68>
    4112:	4a3000ef          	jal	4db4 <open>
    4116:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    4118:	4481                	li	s1,0
    memset(buf, i, SZ);
    411a:	00009917          	auipc	s2,0x9
    411e:	b9e90913          	addi	s2,s2,-1122 # ccb8 <buf>
  for(i = 0; i < N; i++){
    4122:	4a51                	li	s4,20
  if(fd < 0){
    4124:	08054663          	bltz	a0,41b0 <bigfile+0xca>
    memset(buf, i, SZ);
    4128:	25800613          	li	a2,600
    412c:	85a6                	mv	a1,s1
    412e:	854a                	mv	a0,s2
    4130:	233000ef          	jal	4b62 <memset>
    if(write(fd, buf, SZ) != SZ){
    4134:	25800613          	li	a2,600
    4138:	85ca                	mv	a1,s2
    413a:	854e                	mv	a0,s3
    413c:	459000ef          	jal	4d94 <write>
    4140:	25800793          	li	a5,600
    4144:	08f51063          	bne	a0,a5,41c4 <bigfile+0xde>
  for(i = 0; i < N; i++){
    4148:	2485                	addiw	s1,s1,1
    414a:	fd449fe3          	bne	s1,s4,4128 <bigfile+0x42>
  close(fd);
    414e:	854e                	mv	a0,s3
    4150:	44d000ef          	jal	4d9c <close>
  fd = open("bigfile.dat", 0);
    4154:	4581                	li	a1,0
    4156:	00003517          	auipc	a0,0x3
    415a:	f6250513          	addi	a0,a0,-158 # 70b8 <malloc+0x1e68>
    415e:	457000ef          	jal	4db4 <open>
    4162:	8a2a                	mv	s4,a0
  total = 0;
    4164:	4981                	li	s3,0
  for(i = 0; ; i++){
    4166:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    4168:	00009917          	auipc	s2,0x9
    416c:	b5090913          	addi	s2,s2,-1200 # ccb8 <buf>
  if(fd < 0){
    4170:	06054463          	bltz	a0,41d8 <bigfile+0xf2>
    cc = read(fd, buf, SZ/2);
    4174:	12c00613          	li	a2,300
    4178:	85ca                	mv	a1,s2
    417a:	8552                	mv	a0,s4
    417c:	411000ef          	jal	4d8c <read>
    if(cc < 0){
    4180:	06054663          	bltz	a0,41ec <bigfile+0x106>
    if(cc == 0)
    4184:	c155                	beqz	a0,4228 <bigfile+0x142>
    if(cc != SZ/2){
    4186:	12c00793          	li	a5,300
    418a:	06f51b63          	bne	a0,a5,4200 <bigfile+0x11a>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    418e:	01f4d79b          	srliw	a5,s1,0x1f
    4192:	9fa5                	addw	a5,a5,s1
    4194:	4017d79b          	sraiw	a5,a5,0x1
    4198:	00094703          	lbu	a4,0(s2)
    419c:	06f71c63          	bne	a4,a5,4214 <bigfile+0x12e>
    41a0:	12b94703          	lbu	a4,299(s2)
    41a4:	06f71863          	bne	a4,a5,4214 <bigfile+0x12e>
    total += cc;
    41a8:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    41ac:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    41ae:	b7d9                	j	4174 <bigfile+0x8e>
    printf("%s: cannot create bigfile", s);
    41b0:	85d6                	mv	a1,s5
    41b2:	00003517          	auipc	a0,0x3
    41b6:	f1650513          	addi	a0,a0,-234 # 70c8 <malloc+0x1e78>
    41ba:	7e3000ef          	jal	519c <printf>
    exit(1);
    41be:	4505                	li	a0,1
    41c0:	3b5000ef          	jal	4d74 <exit>
      printf("%s: write bigfile failed\n", s);
    41c4:	85d6                	mv	a1,s5
    41c6:	00003517          	auipc	a0,0x3
    41ca:	f2250513          	addi	a0,a0,-222 # 70e8 <malloc+0x1e98>
    41ce:	7cf000ef          	jal	519c <printf>
      exit(1);
    41d2:	4505                	li	a0,1
    41d4:	3a1000ef          	jal	4d74 <exit>
    printf("%s: cannot open bigfile\n", s);
    41d8:	85d6                	mv	a1,s5
    41da:	00003517          	auipc	a0,0x3
    41de:	f2e50513          	addi	a0,a0,-210 # 7108 <malloc+0x1eb8>
    41e2:	7bb000ef          	jal	519c <printf>
    exit(1);
    41e6:	4505                	li	a0,1
    41e8:	38d000ef          	jal	4d74 <exit>
      printf("%s: read bigfile failed\n", s);
    41ec:	85d6                	mv	a1,s5
    41ee:	00003517          	auipc	a0,0x3
    41f2:	f3a50513          	addi	a0,a0,-198 # 7128 <malloc+0x1ed8>
    41f6:	7a7000ef          	jal	519c <printf>
      exit(1);
    41fa:	4505                	li	a0,1
    41fc:	379000ef          	jal	4d74 <exit>
      printf("%s: short read bigfile\n", s);
    4200:	85d6                	mv	a1,s5
    4202:	00003517          	auipc	a0,0x3
    4206:	f4650513          	addi	a0,a0,-186 # 7148 <malloc+0x1ef8>
    420a:	793000ef          	jal	519c <printf>
      exit(1);
    420e:	4505                	li	a0,1
    4210:	365000ef          	jal	4d74 <exit>
      printf("%s: read bigfile wrong data\n", s);
    4214:	85d6                	mv	a1,s5
    4216:	00003517          	auipc	a0,0x3
    421a:	f4a50513          	addi	a0,a0,-182 # 7160 <malloc+0x1f10>
    421e:	77f000ef          	jal	519c <printf>
      exit(1);
    4222:	4505                	li	a0,1
    4224:	351000ef          	jal	4d74 <exit>
  close(fd);
    4228:	8552                	mv	a0,s4
    422a:	373000ef          	jal	4d9c <close>
  if(total != N*SZ){
    422e:	678d                	lui	a5,0x3
    4230:	ee078793          	addi	a5,a5,-288 # 2ee0 <subdir+0x31e>
    4234:	02f99163          	bne	s3,a5,4256 <bigfile+0x170>
  unlink("bigfile.dat");
    4238:	00003517          	auipc	a0,0x3
    423c:	e8050513          	addi	a0,a0,-384 # 70b8 <malloc+0x1e68>
    4240:	385000ef          	jal	4dc4 <unlink>
}
    4244:	70e2                	ld	ra,56(sp)
    4246:	7442                	ld	s0,48(sp)
    4248:	74a2                	ld	s1,40(sp)
    424a:	7902                	ld	s2,32(sp)
    424c:	69e2                	ld	s3,24(sp)
    424e:	6a42                	ld	s4,16(sp)
    4250:	6aa2                	ld	s5,8(sp)
    4252:	6121                	addi	sp,sp,64
    4254:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4256:	85d6                	mv	a1,s5
    4258:	00003517          	auipc	a0,0x3
    425c:	f2850513          	addi	a0,a0,-216 # 7180 <malloc+0x1f30>
    4260:	73d000ef          	jal	519c <printf>
    exit(1);
    4264:	4505                	li	a0,1
    4266:	30f000ef          	jal	4d74 <exit>

000000000000426a <bigargtest>:
{
    426a:	7121                	addi	sp,sp,-448
    426c:	ff06                	sd	ra,440(sp)
    426e:	fb22                	sd	s0,432(sp)
    4270:	f726                	sd	s1,424(sp)
    4272:	0380                	addi	s0,sp,448
    4274:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    4276:	00003517          	auipc	a0,0x3
    427a:	f2a50513          	addi	a0,a0,-214 # 71a0 <malloc+0x1f50>
    427e:	347000ef          	jal	4dc4 <unlink>
  pid = fork();
    4282:	2eb000ef          	jal	4d6c <fork>
  if(pid == 0){
    4286:	c915                	beqz	a0,42ba <bigargtest+0x50>
  } else if(pid < 0){
    4288:	08054a63          	bltz	a0,431c <bigargtest+0xb2>
  wait(&xstatus);
    428c:	fdc40513          	addi	a0,s0,-36
    4290:	2ed000ef          	jal	4d7c <wait>
  if(xstatus != 0)
    4294:	fdc42503          	lw	a0,-36(s0)
    4298:	ed41                	bnez	a0,4330 <bigargtest+0xc6>
  fd = open("bigarg-ok", 0);
    429a:	4581                	li	a1,0
    429c:	00003517          	auipc	a0,0x3
    42a0:	f0450513          	addi	a0,a0,-252 # 71a0 <malloc+0x1f50>
    42a4:	311000ef          	jal	4db4 <open>
  if(fd < 0){
    42a8:	08054663          	bltz	a0,4334 <bigargtest+0xca>
  close(fd);
    42ac:	2f1000ef          	jal	4d9c <close>
}
    42b0:	70fa                	ld	ra,440(sp)
    42b2:	745a                	ld	s0,432(sp)
    42b4:	74ba                	ld	s1,424(sp)
    42b6:	6139                	addi	sp,sp,448
    42b8:	8082                	ret
    memset(big, ' ', sizeof(big));
    42ba:	19000613          	li	a2,400
    42be:	02000593          	li	a1,32
    42c2:	e4840513          	addi	a0,s0,-440
    42c6:	09d000ef          	jal	4b62 <memset>
    big[sizeof(big)-1] = '\0';
    42ca:	fc040ba3          	sb	zero,-41(s0)
    for(i = 0; i < MAXARG-1; i++)
    42ce:	00005797          	auipc	a5,0x5
    42d2:	1d278793          	addi	a5,a5,466 # 94a0 <args.1>
    42d6:	00005697          	auipc	a3,0x5
    42da:	2c268693          	addi	a3,a3,706 # 9598 <args.1+0xf8>
      args[i] = big;
    42de:	e4840713          	addi	a4,s0,-440
    42e2:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    42e4:	07a1                	addi	a5,a5,8
    42e6:	fed79ee3          	bne	a5,a3,42e2 <bigargtest+0x78>
    args[MAXARG-1] = 0;
    42ea:	00005597          	auipc	a1,0x5
    42ee:	1b658593          	addi	a1,a1,438 # 94a0 <args.1>
    42f2:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    42f6:	00001517          	auipc	a0,0x1
    42fa:	09250513          	addi	a0,a0,146 # 5388 <malloc+0x138>
    42fe:	2af000ef          	jal	4dac <exec>
    fd = open("bigarg-ok", O_CREATE);
    4302:	20000593          	li	a1,512
    4306:	00003517          	auipc	a0,0x3
    430a:	e9a50513          	addi	a0,a0,-358 # 71a0 <malloc+0x1f50>
    430e:	2a7000ef          	jal	4db4 <open>
    close(fd);
    4312:	28b000ef          	jal	4d9c <close>
    exit(0);
    4316:	4501                	li	a0,0
    4318:	25d000ef          	jal	4d74 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    431c:	85a6                	mv	a1,s1
    431e:	00003517          	auipc	a0,0x3
    4322:	e9250513          	addi	a0,a0,-366 # 71b0 <malloc+0x1f60>
    4326:	677000ef          	jal	519c <printf>
    exit(1);
    432a:	4505                	li	a0,1
    432c:	249000ef          	jal	4d74 <exit>
    exit(xstatus);
    4330:	245000ef          	jal	4d74 <exit>
    printf("%s: bigarg test failed!\n", s);
    4334:	85a6                	mv	a1,s1
    4336:	00003517          	auipc	a0,0x3
    433a:	e9a50513          	addi	a0,a0,-358 # 71d0 <malloc+0x1f80>
    433e:	65f000ef          	jal	519c <printf>
    exit(1);
    4342:	4505                	li	a0,1
    4344:	231000ef          	jal	4d74 <exit>

0000000000004348 <lazy_alloc>:
{
    4348:	1141                	addi	sp,sp,-16
    434a:	e406                	sd	ra,8(sp)
    434c:	e022                	sd	s0,0(sp)
    434e:	0800                	addi	s0,sp,16
  prev_end = sbrklazy(REGION_SZ);
    4350:	40000537          	lui	a0,0x40000
    4354:	203000ef          	jal	4d56 <sbrklazy>
  if (prev_end == (char *) SBRK_ERROR) {
    4358:	57fd                	li	a5,-1
    435a:	02f50a63          	beq	a0,a5,438e <lazy_alloc+0x46>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
    435e:	6605                	lui	a2,0x1
    4360:	962a                	add	a2,a2,a0
    4362:	400017b7          	lui	a5,0x40001
    4366:	00f50733          	add	a4,a0,a5
    436a:	87b2                	mv	a5,a2
    436c:	000406b7          	lui	a3,0x40
    *(char **)i = i;
    4370:	e39c                	sd	a5,0(a5)
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
    4372:	97b6                	add	a5,a5,a3
    4374:	fee79ee3          	bne	a5,a4,4370 <lazy_alloc+0x28>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
    4378:	000406b7          	lui	a3,0x40
    if (*(char **)i != i) {
    437c:	621c                	ld	a5,0(a2)
    437e:	02c79163          	bne	a5,a2,43a0 <lazy_alloc+0x58>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
    4382:	9636                	add	a2,a2,a3
    4384:	fee61ce3          	bne	a2,a4,437c <lazy_alloc+0x34>
  exit(0);
    4388:	4501                	li	a0,0
    438a:	1eb000ef          	jal	4d74 <exit>
    printf("sbrklazy() failed\n");
    438e:	00003517          	auipc	a0,0x3
    4392:	e6250513          	addi	a0,a0,-414 # 71f0 <malloc+0x1fa0>
    4396:	607000ef          	jal	519c <printf>
    exit(1);
    439a:	4505                	li	a0,1
    439c:	1d9000ef          	jal	4d74 <exit>
      printf("failed to read value from memory\n");
    43a0:	00003517          	auipc	a0,0x3
    43a4:	e6850513          	addi	a0,a0,-408 # 7208 <malloc+0x1fb8>
    43a8:	5f5000ef          	jal	519c <printf>
      exit(1);
    43ac:	4505                	li	a0,1
    43ae:	1c7000ef          	jal	4d74 <exit>

00000000000043b2 <lazy_unmap>:
{
    43b2:	7139                	addi	sp,sp,-64
    43b4:	fc06                	sd	ra,56(sp)
    43b6:	f822                	sd	s0,48(sp)
    43b8:	0080                	addi	s0,sp,64
  prev_end = sbrklazy(REGION_SZ);
    43ba:	40000537          	lui	a0,0x40000
    43be:	199000ef          	jal	4d56 <sbrklazy>
  if (prev_end == (char*)SBRK_ERROR) {
    43c2:	57fd                	li	a5,-1
    43c4:	04f50663          	beq	a0,a5,4410 <lazy_unmap+0x5e>
    43c8:	f426                	sd	s1,40(sp)
    43ca:	f04a                	sd	s2,32(sp)
    43cc:	ec4e                	sd	s3,24(sp)
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
    43ce:	6905                	lui	s2,0x1
    43d0:	992a                	add	s2,s2,a0
    43d2:	400017b7          	lui	a5,0x40001
    43d6:	00f504b3          	add	s1,a0,a5
    43da:	87ca                	mv	a5,s2
    43dc:	01000737          	lui	a4,0x1000
    *(char **)i = i;
    43e0:	e39c                	sd	a5,0(a5)
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
    43e2:	97ba                	add	a5,a5,a4
    43e4:	fe979ee3          	bne	a5,s1,43e0 <lazy_unmap+0x2e>
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
    43e8:	010009b7          	lui	s3,0x1000
    pid = fork();
    43ec:	181000ef          	jal	4d6c <fork>
    if (pid < 0) {
    43f0:	02054c63          	bltz	a0,4428 <lazy_unmap+0x76>
    } else if (pid == 0) {
    43f4:	c139                	beqz	a0,443a <lazy_unmap+0x88>
      wait(&status);
    43f6:	fcc40513          	addi	a0,s0,-52
    43fa:	183000ef          	jal	4d7c <wait>
      if (status == 0) {
    43fe:	fcc42783          	lw	a5,-52(s0)
    4402:	c7a9                	beqz	a5,444c <lazy_unmap+0x9a>
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
    4404:	994e                	add	s2,s2,s3
    4406:	fe9913e3          	bne	s2,s1,43ec <lazy_unmap+0x3a>
  exit(0);
    440a:	4501                	li	a0,0
    440c:	169000ef          	jal	4d74 <exit>
    4410:	f426                	sd	s1,40(sp)
    4412:	f04a                	sd	s2,32(sp)
    4414:	ec4e                	sd	s3,24(sp)
    printf("sbrklazy() failed\n");
    4416:	00003517          	auipc	a0,0x3
    441a:	dda50513          	addi	a0,a0,-550 # 71f0 <malloc+0x1fa0>
    441e:	57f000ef          	jal	519c <printf>
    exit(1);
    4422:	4505                	li	a0,1
    4424:	151000ef          	jal	4d74 <exit>
      printf("error forking\n");
    4428:	00003517          	auipc	a0,0x3
    442c:	e0850513          	addi	a0,a0,-504 # 7230 <malloc+0x1fe0>
    4430:	56d000ef          	jal	519c <printf>
      exit(1);
    4434:	4505                	li	a0,1
    4436:	13f000ef          	jal	4d74 <exit>
      sbrklazy(-1L * REGION_SZ);
    443a:	c0000537          	lui	a0,0xc0000
    443e:	119000ef          	jal	4d56 <sbrklazy>
      *(char **)i = i;
    4442:	01293023          	sd	s2,0(s2) # 1000 <badarg>
      exit(0);
    4446:	4501                	li	a0,0
    4448:	12d000ef          	jal	4d74 <exit>
        printf("memory not unmapped\n");
    444c:	00003517          	auipc	a0,0x3
    4450:	df450513          	addi	a0,a0,-524 # 7240 <malloc+0x1ff0>
    4454:	549000ef          	jal	519c <printf>
        exit(1);
    4458:	4505                	li	a0,1
    445a:	11b000ef          	jal	4d74 <exit>

000000000000445e <lazy_copy>:
{
    445e:	7159                	addi	sp,sp,-112
    4460:	f486                	sd	ra,104(sp)
    4462:	f0a2                	sd	s0,96(sp)
    4464:	eca6                	sd	s1,88(sp)
    4466:	e8ca                	sd	s2,80(sp)
    4468:	e4ce                	sd	s3,72(sp)
    446a:	e0d2                	sd	s4,64(sp)
    446c:	fc56                	sd	s5,56(sp)
    446e:	f85a                	sd	s6,48(sp)
    4470:	1880                	addi	s0,sp,112
    char *p = sbrk(0);
    4472:	4501                	li	a0,0
    4474:	0cd000ef          	jal	4d40 <sbrk>
    4478:	84aa                	mv	s1,a0
    sbrklazy(4*PGSIZE);
    447a:	6511                	lui	a0,0x4
    447c:	0db000ef          	jal	4d56 <sbrklazy>
    open(p + 8192, 0);
    4480:	4581                	li	a1,0
    4482:	6509                	lui	a0,0x2
    4484:	9526                	add	a0,a0,s1
    4486:	12f000ef          	jal	4db4 <open>
    void *xx = sbrk(0);
    448a:	4501                	li	a0,0
    448c:	0b5000ef          	jal	4d40 <sbrk>
    4490:	84aa                	mv	s1,a0
    void *ret = sbrk(-(((uint64) xx)+1));
    4492:	fff54513          	not	a0,a0
    4496:	2501                	sext.w	a0,a0
    4498:	0a9000ef          	jal	4d40 <sbrk>
    if(ret != xx){
    449c:	00a48c63          	beq	s1,a0,44b4 <lazy_copy+0x56>
    44a0:	85aa                	mv	a1,a0
      printf("sbrk(sbrk(0)+1) returned %p, not old sz\n", ret);
    44a2:	00003517          	auipc	a0,0x3
    44a6:	db650513          	addi	a0,a0,-586 # 7258 <malloc+0x2008>
    44aa:	4f3000ef          	jal	519c <printf>
      exit(1);
    44ae:	4505                	li	a0,1
    44b0:	0c5000ef          	jal	4d74 <exit>
  unsigned long bad[] = {
    44b4:	00003797          	auipc	a5,0x3
    44b8:	41c78793          	addi	a5,a5,1052 # 78d0 <malloc+0x2680>
    44bc:	7fa8                	ld	a0,120(a5)
    44be:	63cc                	ld	a1,128(a5)
    44c0:	67d0                	ld	a2,136(a5)
    44c2:	6bd4                	ld	a3,144(a5)
    44c4:	6fd8                	ld	a4,152(a5)
    44c6:	73dc                	ld	a5,160(a5)
    44c8:	f8a43823          	sd	a0,-112(s0)
    44cc:	f8b43c23          	sd	a1,-104(s0)
    44d0:	fac43023          	sd	a2,-96(s0)
    44d4:	fad43423          	sd	a3,-88(s0)
    44d8:	fae43823          	sd	a4,-80(s0)
    44dc:	faf43c23          	sd	a5,-72(s0)
  for(int i = 0; i < sizeof(bad)/sizeof(bad[0]); i++){
    44e0:	f9040913          	addi	s2,s0,-112
    44e4:	fc040b13          	addi	s6,s0,-64
    int fd = open("README", 0);
    44e8:	00001a17          	auipc	s4,0x1
    44ec:	078a0a13          	addi	s4,s4,120 # 5560 <malloc+0x310>
    fd = open("junk", O_CREATE|O_RDWR|O_TRUNC);
    44f0:	00001a97          	auipc	s5,0x1
    44f4:	f80a8a93          	addi	s5,s5,-128 # 5470 <malloc+0x220>
    int fd = open("README", 0);
    44f8:	4581                	li	a1,0
    44fa:	8552                	mv	a0,s4
    44fc:	0b9000ef          	jal	4db4 <open>
    4500:	84aa                	mv	s1,a0
    if(fd < 0) { printf("cannot open README\n"); exit(1); }
    4502:	04054663          	bltz	a0,454e <lazy_copy+0xf0>
    if(read(fd, (char*)bad[i], 512) >= 0) { printf("read succeeded\n");  exit(1); }
    4506:	00093983          	ld	s3,0(s2)
    450a:	20000613          	li	a2,512
    450e:	85ce                	mv	a1,s3
    4510:	07d000ef          	jal	4d8c <read>
    4514:	04055663          	bgez	a0,4560 <lazy_copy+0x102>
    close(fd);
    4518:	8526                	mv	a0,s1
    451a:	083000ef          	jal	4d9c <close>
    fd = open("junk", O_CREATE|O_RDWR|O_TRUNC);
    451e:	60200593          	li	a1,1538
    4522:	8556                	mv	a0,s5
    4524:	091000ef          	jal	4db4 <open>
    4528:	84aa                	mv	s1,a0
    if(fd < 0) { printf("cannot open junk\n"); exit(1); }
    452a:	04054463          	bltz	a0,4572 <lazy_copy+0x114>
    if(write(fd, (char*)bad[i], 512) >= 0) { printf("write succeeded\n"); exit(1); }
    452e:	20000613          	li	a2,512
    4532:	85ce                	mv	a1,s3
    4534:	061000ef          	jal	4d94 <write>
    4538:	04055663          	bgez	a0,4584 <lazy_copy+0x126>
    close(fd);
    453c:	8526                	mv	a0,s1
    453e:	05f000ef          	jal	4d9c <close>
  for(int i = 0; i < sizeof(bad)/sizeof(bad[0]); i++){
    4542:	0921                	addi	s2,s2,8
    4544:	fb691ae3          	bne	s2,s6,44f8 <lazy_copy+0x9a>
  exit(0);
    4548:	4501                	li	a0,0
    454a:	02b000ef          	jal	4d74 <exit>
    if(fd < 0) { printf("cannot open README\n"); exit(1); }
    454e:	00003517          	auipc	a0,0x3
    4552:	d3a50513          	addi	a0,a0,-710 # 7288 <malloc+0x2038>
    4556:	447000ef          	jal	519c <printf>
    455a:	4505                	li	a0,1
    455c:	019000ef          	jal	4d74 <exit>
    if(read(fd, (char*)bad[i], 512) >= 0) { printf("read succeeded\n");  exit(1); }
    4560:	00003517          	auipc	a0,0x3
    4564:	d4050513          	addi	a0,a0,-704 # 72a0 <malloc+0x2050>
    4568:	435000ef          	jal	519c <printf>
    456c:	4505                	li	a0,1
    456e:	007000ef          	jal	4d74 <exit>
    if(fd < 0) { printf("cannot open junk\n"); exit(1); }
    4572:	00003517          	auipc	a0,0x3
    4576:	d3e50513          	addi	a0,a0,-706 # 72b0 <malloc+0x2060>
    457a:	423000ef          	jal	519c <printf>
    457e:	4505                	li	a0,1
    4580:	7f4000ef          	jal	4d74 <exit>
    if(write(fd, (char*)bad[i], 512) >= 0) { printf("write succeeded\n"); exit(1); }
    4584:	00003517          	auipc	a0,0x3
    4588:	d4450513          	addi	a0,a0,-700 # 72c8 <malloc+0x2078>
    458c:	411000ef          	jal	519c <printf>
    4590:	4505                	li	a0,1
    4592:	7e2000ef          	jal	4d74 <exit>

0000000000004596 <lazy_sbrk>:
{
    4596:	1101                	addi	sp,sp,-32
    4598:	ec06                	sd	ra,24(sp)
    459a:	e822                	sd	s0,16(sp)
    459c:	e426                	sd	s1,8(sp)
    459e:	e04a                	sd	s2,0(sp)
    45a0:	1000                	addi	s0,sp,32
  char *p = sbrk(0);
    45a2:	4501                	li	a0,0
    45a4:	79c000ef          	jal	4d40 <sbrk>
    45a8:	84aa                	mv	s1,a0
  while ((uint64)p < MAXVA-(1<<30)) {
    45aa:	0ff00793          	li	a5,255
    45ae:	07fa                	slli	a5,a5,0x1e
    45b0:	00f57d63          	bgeu	a0,a5,45ca <lazy_sbrk+0x34>
    45b4:	893e                	mv	s2,a5
    p = sbrklazy(1<<30);
    45b6:	40000537          	lui	a0,0x40000
    45ba:	79c000ef          	jal	4d56 <sbrklazy>
    p = sbrklazy(0);
    45be:	4501                	li	a0,0
    45c0:	796000ef          	jal	4d56 <sbrklazy>
    45c4:	84aa                	mv	s1,a0
  while ((uint64)p < MAXVA-(1<<30)) {
    45c6:	ff2568e3          	bltu	a0,s2,45b6 <lazy_sbrk+0x20>
  int n = TRAPFRAME-PGSIZE-(uint64)p;
    45ca:	7975                	lui	s2,0xffffd
    45cc:	4099093b          	subw	s2,s2,s1
  char *p1 = sbrklazy(n);
    45d0:	854a                	mv	a0,s2
    45d2:	784000ef          	jal	4d56 <sbrklazy>
    45d6:	862a                	mv	a2,a0
  if (p1 < 0 || p1 != p) {
    45d8:	00950d63          	beq	a0,s1,45f2 <lazy_sbrk+0x5c>
    printf("sbrklazy(%d) returned %p, not expected %p\n", n, p1, p);
    45dc:	86a6                	mv	a3,s1
    45de:	85ca                	mv	a1,s2
    45e0:	00003517          	auipc	a0,0x3
    45e4:	d0050513          	addi	a0,a0,-768 # 72e0 <malloc+0x2090>
    45e8:	3b5000ef          	jal	519c <printf>
    exit(1);
    45ec:	4505                	li	a0,1
    45ee:	786000ef          	jal	4d74 <exit>
  p = sbrk(PGSIZE);
    45f2:	6505                	lui	a0,0x1
    45f4:	74c000ef          	jal	4d40 <sbrk>
    45f8:	862a                	mv	a2,a0
  if (p < 0 || (uint64)p != TRAPFRAME-PGSIZE) {
    45fa:	040007b7          	lui	a5,0x4000
    45fe:	17f5                	addi	a5,a5,-3 # 3fffffd <base+0x3ff0345>
    4600:	07b2                	slli	a5,a5,0xc
    4602:	00f50c63          	beq	a0,a5,461a <lazy_sbrk+0x84>
    printf("sbrk(%d) returned %p, not expected TRAPFRAME-PGSIZE\n", PGSIZE, p);
    4606:	6585                	lui	a1,0x1
    4608:	00003517          	auipc	a0,0x3
    460c:	d0850513          	addi	a0,a0,-760 # 7310 <malloc+0x20c0>
    4610:	38d000ef          	jal	519c <printf>
    exit(1);
    4614:	4505                	li	a0,1
    4616:	75e000ef          	jal	4d74 <exit>
  p[0] = 1;
    461a:	040007b7          	lui	a5,0x4000
    461e:	17f5                	addi	a5,a5,-3 # 3fffffd <base+0x3ff0345>
    4620:	07b2                	slli	a5,a5,0xc
    4622:	4705                	li	a4,1
    4624:	00e78023          	sb	a4,0(a5)
  if (p[1] != 0) {
    4628:	0017c783          	lbu	a5,1(a5)
    462c:	cb91                	beqz	a5,4640 <lazy_sbrk+0xaa>
    printf("sbrk() returned non-zero-filled memory\n");
    462e:	00003517          	auipc	a0,0x3
    4632:	d1a50513          	addi	a0,a0,-742 # 7348 <malloc+0x20f8>
    4636:	367000ef          	jal	519c <printf>
    exit(1);
    463a:	4505                	li	a0,1
    463c:	738000ef          	jal	4d74 <exit>
  p = sbrk(1);
    4640:	4505                	li	a0,1
    4642:	6fe000ef          	jal	4d40 <sbrk>
    4646:	85aa                	mv	a1,a0
  if ((uint64)p != -1) {
    4648:	57fd                	li	a5,-1
    464a:	00f50b63          	beq	a0,a5,4660 <lazy_sbrk+0xca>
    printf("sbrk(1) returned %p, expected error\n", p);
    464e:	00003517          	auipc	a0,0x3
    4652:	d2250513          	addi	a0,a0,-734 # 7370 <malloc+0x2120>
    4656:	347000ef          	jal	519c <printf>
    exit(1);
    465a:	4505                	li	a0,1
    465c:	718000ef          	jal	4d74 <exit>
  p = sbrklazy(1);
    4660:	4505                	li	a0,1
    4662:	6f4000ef          	jal	4d56 <sbrklazy>
    4666:	85aa                	mv	a1,a0
  if ((uint64)p != -1) {
    4668:	57fd                	li	a5,-1
    466a:	00f50b63          	beq	a0,a5,4680 <lazy_sbrk+0xea>
    printf("sbrklazy(1) returned %p, expected error\n", p);
    466e:	00003517          	auipc	a0,0x3
    4672:	d2a50513          	addi	a0,a0,-726 # 7398 <malloc+0x2148>
    4676:	327000ef          	jal	519c <printf>
    exit(1);
    467a:	4505                	li	a0,1
    467c:	6f8000ef          	jal	4d74 <exit>
  exit(0);
    4680:	4501                	li	a0,0
    4682:	6f2000ef          	jal	4d74 <exit>

0000000000004686 <fsfull>:
{
    4686:	7135                	addi	sp,sp,-160
    4688:	ed06                	sd	ra,152(sp)
    468a:	e922                	sd	s0,144(sp)
    468c:	e526                	sd	s1,136(sp)
    468e:	e14a                	sd	s2,128(sp)
    4690:	fcce                	sd	s3,120(sp)
    4692:	f8d2                	sd	s4,112(sp)
    4694:	f4d6                	sd	s5,104(sp)
    4696:	f0da                	sd	s6,96(sp)
    4698:	ecde                	sd	s7,88(sp)
    469a:	e8e2                	sd	s8,80(sp)
    469c:	e4e6                	sd	s9,72(sp)
    469e:	e0ea                	sd	s10,64(sp)
    46a0:	1100                	addi	s0,sp,160
  printf("fsfull test\n");
    46a2:	00003517          	auipc	a0,0x3
    46a6:	d2650513          	addi	a0,a0,-730 # 73c8 <malloc+0x2178>
    46aa:	2f3000ef          	jal	519c <printf>
  for(nfiles = 0; ; nfiles++){
    46ae:	4481                	li	s1,0
    name[0] = 'f';
    46b0:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    46b4:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    46b8:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    46bc:	4b29                	li	s6,10
    printf("writing %s\n", name);
    46be:	00003c97          	auipc	s9,0x3
    46c2:	d1ac8c93          	addi	s9,s9,-742 # 73d8 <malloc+0x2188>
    name[0] = 'f';
    46c6:	f7a40023          	sb	s10,-160(s0)
    name[1] = '0' + nfiles / 1000;
    46ca:	0384c7bb          	divw	a5,s1,s8
    46ce:	0307879b          	addiw	a5,a5,48
    46d2:	f6f400a3          	sb	a5,-159(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    46d6:	0384e7bb          	remw	a5,s1,s8
    46da:	0377c7bb          	divw	a5,a5,s7
    46de:	0307879b          	addiw	a5,a5,48
    46e2:	f6f40123          	sb	a5,-158(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    46e6:	0374e7bb          	remw	a5,s1,s7
    46ea:	0367c7bb          	divw	a5,a5,s6
    46ee:	0307879b          	addiw	a5,a5,48
    46f2:	f6f401a3          	sb	a5,-157(s0)
    name[4] = '0' + (nfiles % 10);
    46f6:	0364e7bb          	remw	a5,s1,s6
    46fa:	0307879b          	addiw	a5,a5,48
    46fe:	f6f40223          	sb	a5,-156(s0)
    name[5] = '\0';
    4702:	f60402a3          	sb	zero,-155(s0)
    printf("writing %s\n", name);
    4706:	f6040593          	addi	a1,s0,-160
    470a:	8566                	mv	a0,s9
    470c:	291000ef          	jal	519c <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4710:	20200593          	li	a1,514
    4714:	f6040513          	addi	a0,s0,-160
    4718:	69c000ef          	jal	4db4 <open>
    471c:	892a                	mv	s2,a0
    if(fd < 0){
    471e:	08055f63          	bgez	a0,47bc <fsfull+0x136>
      printf("open %s failed\n", name);
    4722:	f6040593          	addi	a1,s0,-160
    4726:	00003517          	auipc	a0,0x3
    472a:	cc250513          	addi	a0,a0,-830 # 73e8 <malloc+0x2198>
    472e:	26f000ef          	jal	519c <printf>
  while(nfiles >= 0){
    4732:	0604c163          	bltz	s1,4794 <fsfull+0x10e>
    name[0] = 'f';
    4736:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    473a:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    473e:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4742:	4929                	li	s2,10
  while(nfiles >= 0){
    4744:	5afd                	li	s5,-1
    name[0] = 'f';
    4746:	f7640023          	sb	s6,-160(s0)
    name[1] = '0' + nfiles / 1000;
    474a:	0344c7bb          	divw	a5,s1,s4
    474e:	0307879b          	addiw	a5,a5,48
    4752:	f6f400a3          	sb	a5,-159(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4756:	0344e7bb          	remw	a5,s1,s4
    475a:	0337c7bb          	divw	a5,a5,s3
    475e:	0307879b          	addiw	a5,a5,48
    4762:	f6f40123          	sb	a5,-158(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4766:	0334e7bb          	remw	a5,s1,s3
    476a:	0327c7bb          	divw	a5,a5,s2
    476e:	0307879b          	addiw	a5,a5,48
    4772:	f6f401a3          	sb	a5,-157(s0)
    name[4] = '0' + (nfiles % 10);
    4776:	0324e7bb          	remw	a5,s1,s2
    477a:	0307879b          	addiw	a5,a5,48
    477e:	f6f40223          	sb	a5,-156(s0)
    name[5] = '\0';
    4782:	f60402a3          	sb	zero,-155(s0)
    unlink(name);
    4786:	f6040513          	addi	a0,s0,-160
    478a:	63a000ef          	jal	4dc4 <unlink>
    nfiles--;
    478e:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4790:	fb549be3          	bne	s1,s5,4746 <fsfull+0xc0>
  printf("fsfull test finished\n");
    4794:	00003517          	auipc	a0,0x3
    4798:	c7450513          	addi	a0,a0,-908 # 7408 <malloc+0x21b8>
    479c:	201000ef          	jal	519c <printf>
}
    47a0:	60ea                	ld	ra,152(sp)
    47a2:	644a                	ld	s0,144(sp)
    47a4:	64aa                	ld	s1,136(sp)
    47a6:	690a                	ld	s2,128(sp)
    47a8:	79e6                	ld	s3,120(sp)
    47aa:	7a46                	ld	s4,112(sp)
    47ac:	7aa6                	ld	s5,104(sp)
    47ae:	7b06                	ld	s6,96(sp)
    47b0:	6be6                	ld	s7,88(sp)
    47b2:	6c46                	ld	s8,80(sp)
    47b4:	6ca6                	ld	s9,72(sp)
    47b6:	6d06                	ld	s10,64(sp)
    47b8:	610d                	addi	sp,sp,160
    47ba:	8082                	ret
    int total = 0;
    47bc:	4981                	li	s3,0
      int cc = write(fd, buf, BSIZE);
    47be:	00008a97          	auipc	s5,0x8
    47c2:	4faa8a93          	addi	s5,s5,1274 # ccb8 <buf>
      if(cc < BSIZE)
    47c6:	3ff00a13          	li	s4,1023
      int cc = write(fd, buf, BSIZE);
    47ca:	40000613          	li	a2,1024
    47ce:	85d6                	mv	a1,s5
    47d0:	854a                	mv	a0,s2
    47d2:	5c2000ef          	jal	4d94 <write>
      if(cc < BSIZE)
    47d6:	00aa5563          	bge	s4,a0,47e0 <fsfull+0x15a>
      total += cc;
    47da:	00a989bb          	addw	s3,s3,a0
    while(1){
    47de:	b7f5                	j	47ca <fsfull+0x144>
    printf("wrote %d bytes\n", total);
    47e0:	85ce                	mv	a1,s3
    47e2:	00003517          	auipc	a0,0x3
    47e6:	c1650513          	addi	a0,a0,-1002 # 73f8 <malloc+0x21a8>
    47ea:	1b3000ef          	jal	519c <printf>
    close(fd);
    47ee:	854a                	mv	a0,s2
    47f0:	5ac000ef          	jal	4d9c <close>
    if(total == 0)
    47f4:	f2098fe3          	beqz	s3,4732 <fsfull+0xac>
  for(nfiles = 0; ; nfiles++){
    47f8:	2485                	addiw	s1,s1,1
    47fa:	b5f1                	j	46c6 <fsfull+0x40>

00000000000047fc <run>:
//

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    47fc:	7179                	addi	sp,sp,-48
    47fe:	f406                	sd	ra,40(sp)
    4800:	f022                	sd	s0,32(sp)
    4802:	ec26                	sd	s1,24(sp)
    4804:	e84a                	sd	s2,16(sp)
    4806:	1800                	addi	s0,sp,48
    4808:	84aa                	mv	s1,a0
    480a:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    480c:	00003517          	auipc	a0,0x3
    4810:	c1450513          	addi	a0,a0,-1004 # 7420 <malloc+0x21d0>
    4814:	189000ef          	jal	519c <printf>
  if((pid = fork()) < 0) {
    4818:	554000ef          	jal	4d6c <fork>
    481c:	02054a63          	bltz	a0,4850 <run+0x54>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    4820:	c129                	beqz	a0,4862 <run+0x66>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    4822:	fdc40513          	addi	a0,s0,-36
    4826:	556000ef          	jal	4d7c <wait>
    if(xstatus != 0) 
    482a:	fdc42783          	lw	a5,-36(s0)
    482e:	cf9d                	beqz	a5,486c <run+0x70>
      printf("FAILED\n");
    4830:	00003517          	auipc	a0,0x3
    4834:	c1850513          	addi	a0,a0,-1000 # 7448 <malloc+0x21f8>
    4838:	165000ef          	jal	519c <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    483c:	fdc42503          	lw	a0,-36(s0)
  }
}
    4840:	00153513          	seqz	a0,a0
    4844:	70a2                	ld	ra,40(sp)
    4846:	7402                	ld	s0,32(sp)
    4848:	64e2                	ld	s1,24(sp)
    484a:	6942                	ld	s2,16(sp)
    484c:	6145                	addi	sp,sp,48
    484e:	8082                	ret
    printf("runtest: fork error\n");
    4850:	00003517          	auipc	a0,0x3
    4854:	be050513          	addi	a0,a0,-1056 # 7430 <malloc+0x21e0>
    4858:	145000ef          	jal	519c <printf>
    exit(1);
    485c:	4505                	li	a0,1
    485e:	516000ef          	jal	4d74 <exit>
    f(s);
    4862:	854a                	mv	a0,s2
    4864:	9482                	jalr	s1
    exit(0);
    4866:	4501                	li	a0,0
    4868:	50c000ef          	jal	4d74 <exit>
      printf("OK\n");
    486c:	00003517          	auipc	a0,0x3
    4870:	be450513          	addi	a0,a0,-1052 # 7450 <malloc+0x2200>
    4874:	129000ef          	jal	519c <printf>
    4878:	b7d1                	j	483c <run+0x40>

000000000000487a <runtests>:

int
runtests(struct test *tests, char *justone, int continuous) {
    487a:	7139                	addi	sp,sp,-64
    487c:	fc06                	sd	ra,56(sp)
    487e:	f822                	sd	s0,48(sp)
    4880:	f426                	sd	s1,40(sp)
    4882:	ec4e                	sd	s3,24(sp)
    4884:	0080                	addi	s0,sp,64
    4886:	84aa                	mv	s1,a0
  int ntests = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    4888:	6508                	ld	a0,8(a0)
    488a:	cd39                	beqz	a0,48e8 <runtests+0x6e>
    488c:	f04a                	sd	s2,32(sp)
    488e:	e852                	sd	s4,16(sp)
    4890:	e456                	sd	s5,8(sp)
    4892:	892e                	mv	s2,a1
    4894:	8a32                	mv	s4,a2
  int ntests = 0;
    4896:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      ntests++;
      if(!run(t->f, t->s)){
        if(continuous != 2){
    4898:	4a89                	li	s5,2
    489a:	a021                	j	48a2 <runtests+0x28>
  for (struct test *t = tests; t->s != 0; t++) {
    489c:	04c1                	addi	s1,s1,16
    489e:	6488                	ld	a0,8(s1)
    48a0:	c915                	beqz	a0,48d4 <runtests+0x5a>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    48a2:	00090663          	beqz	s2,48ae <runtests+0x34>
    48a6:	85ca                	mv	a1,s2
    48a8:	264000ef          	jal	4b0c <strcmp>
    48ac:	f965                	bnez	a0,489c <runtests+0x22>
      ntests++;
    48ae:	2985                	addiw	s3,s3,1 # 1000001 <base+0xff0349>
      if(!run(t->f, t->s)){
    48b0:	648c                	ld	a1,8(s1)
    48b2:	6088                	ld	a0,0(s1)
    48b4:	f49ff0ef          	jal	47fc <run>
    48b8:	f175                	bnez	a0,489c <runtests+0x22>
        if(continuous != 2){
    48ba:	ff5a01e3          	beq	s4,s5,489c <runtests+0x22>
          printf("SOME TESTS FAILED\n");
    48be:	00003517          	auipc	a0,0x3
    48c2:	b9a50513          	addi	a0,a0,-1126 # 7458 <malloc+0x2208>
    48c6:	0d7000ef          	jal	519c <printf>
          return -1;
    48ca:	59fd                	li	s3,-1
    48cc:	7902                	ld	s2,32(sp)
    48ce:	6a42                	ld	s4,16(sp)
    48d0:	6aa2                	ld	s5,8(sp)
    48d2:	a021                	j	48da <runtests+0x60>
    48d4:	7902                	ld	s2,32(sp)
    48d6:	6a42                	ld	s4,16(sp)
    48d8:	6aa2                	ld	s5,8(sp)
        }
      }
    }
  }
  return ntests;
}
    48da:	854e                	mv	a0,s3
    48dc:	70e2                	ld	ra,56(sp)
    48de:	7442                	ld	s0,48(sp)
    48e0:	74a2                	ld	s1,40(sp)
    48e2:	69e2                	ld	s3,24(sp)
    48e4:	6121                	addi	sp,sp,64
    48e6:	8082                	ret
  return ntests;
    48e8:	4981                	li	s3,0
    48ea:	bfc5                	j	48da <runtests+0x60>

00000000000048ec <countfree>:


// use sbrk() to count how many free physical memory pages there are.
int
countfree()
{
    48ec:	7179                	addi	sp,sp,-48
    48ee:	f406                	sd	ra,40(sp)
    48f0:	f022                	sd	s0,32(sp)
    48f2:	ec26                	sd	s1,24(sp)
    48f4:	e84a                	sd	s2,16(sp)
    48f6:	e44e                	sd	s3,8(sp)
    48f8:	1800                	addi	s0,sp,48
  int n = 0;
  uint64 sz0 = (uint64)sbrk(0);
    48fa:	4501                	li	a0,0
    48fc:	444000ef          	jal	4d40 <sbrk>
    4900:	89aa                	mv	s3,a0
  int n = 0;
    4902:	4481                	li	s1,0
  while(1){
    char *a = sbrk(PGSIZE);
    if(a == SBRK_ERROR){
    4904:	597d                	li	s2,-1
    4906:	a011                	j	490a <countfree+0x1e>
      break;
    }
    n += 1;
    4908:	2485                	addiw	s1,s1,1
    char *a = sbrk(PGSIZE);
    490a:	6505                	lui	a0,0x1
    490c:	434000ef          	jal	4d40 <sbrk>
    if(a == SBRK_ERROR){
    4910:	ff251ce3          	bne	a0,s2,4908 <countfree+0x1c>
  }
  sbrk(-((uint64)sbrk(0) - sz0));  
    4914:	4501                	li	a0,0
    4916:	42a000ef          	jal	4d40 <sbrk>
    491a:	40a9853b          	subw	a0,s3,a0
    491e:	422000ef          	jal	4d40 <sbrk>
  return n;
}
    4922:	8526                	mv	a0,s1
    4924:	70a2                	ld	ra,40(sp)
    4926:	7402                	ld	s0,32(sp)
    4928:	64e2                	ld	s1,24(sp)
    492a:	6942                	ld	s2,16(sp)
    492c:	69a2                	ld	s3,8(sp)
    492e:	6145                	addi	sp,sp,48
    4930:	8082                	ret

0000000000004932 <drivetests>:

int
drivetests(int quick, int continuous, char *justone) {
    4932:	7159                	addi	sp,sp,-112
    4934:	f486                	sd	ra,104(sp)
    4936:	f0a2                	sd	s0,96(sp)
    4938:	eca6                	sd	s1,88(sp)
    493a:	e8ca                	sd	s2,80(sp)
    493c:	e4ce                	sd	s3,72(sp)
    493e:	e0d2                	sd	s4,64(sp)
    4940:	fc56                	sd	s5,56(sp)
    4942:	f85a                	sd	s6,48(sp)
    4944:	f45e                	sd	s7,40(sp)
    4946:	f062                	sd	s8,32(sp)
    4948:	ec66                	sd	s9,24(sp)
    494a:	e86a                	sd	s10,16(sp)
    494c:	e46e                	sd	s11,8(sp)
    494e:	1880                	addi	s0,sp,112
    4950:	8aaa                	mv	s5,a0
    4952:	89ae                	mv	s3,a1
    4954:	8a32                	mv	s4,a2
  do {
    printf("usertests starting\n");
    4956:	00003c17          	auipc	s8,0x3
    495a:	b1ac0c13          	addi	s8,s8,-1254 # 7470 <malloc+0x2220>
    int free0 = countfree();
    int free1 = 0;
    int ntests = 0;
    int n;
    n = runtests(quicktests, justone, continuous);
    495e:	00004b97          	auipc	s7,0x4
    4962:	6b2b8b93          	addi	s7,s7,1714 # 9010 <quicktests>
    if (n < 0) {
      if(continuous != 2) {
    4966:	4b09                	li	s6,2
      ntests += n;
    }
    if(!quick) {
      if (justone == 0)
        printf("usertests slow tests starting\n");
      n = runtests(slowtests, justone, continuous);
    4968:	00005c97          	auipc	s9,0x5
    496c:	ab8c8c93          	addi	s9,s9,-1352 # 9420 <slowtests>
        printf("usertests slow tests starting\n");
    4970:	00003d97          	auipc	s11,0x3
    4974:	b18d8d93          	addi	s11,s11,-1256 # 7488 <malloc+0x2238>
      } else {
        ntests += n;
      }
    }
    if((free1 = countfree()) < free0) {
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    4978:	00003d17          	auipc	s10,0x3
    497c:	b30d0d13          	addi	s10,s10,-1232 # 74a8 <malloc+0x2258>
    4980:	a025                	j	49a8 <drivetests+0x76>
      if(continuous != 2) {
    4982:	09699063          	bne	s3,s6,4a02 <drivetests+0xd0>
    int ntests = 0;
    4986:	4481                	li	s1,0
    4988:	a835                	j	49c4 <drivetests+0x92>
        printf("usertests slow tests starting\n");
    498a:	856e                	mv	a0,s11
    498c:	011000ef          	jal	519c <printf>
    4990:	a835                	j	49cc <drivetests+0x9a>
        if(continuous != 2) {
    4992:	07699a63          	bne	s3,s6,4a06 <drivetests+0xd4>
    if((free1 = countfree()) < free0) {
    4996:	f57ff0ef          	jal	48ec <countfree>
    499a:	05254263          	blt	a0,s2,49de <drivetests+0xac>
      if(continuous != 2) {
        return 1;
      }
    }
    if (justone != 0 && ntests == 0) {
    499e:	000a0363          	beqz	s4,49a4 <drivetests+0x72>
    49a2:	c8a1                	beqz	s1,49f2 <drivetests+0xc0>
      printf("NO TESTS EXECUTED\n");
      return 1;
    }
  } while(continuous);
    49a4:	06098563          	beqz	s3,4a0e <drivetests+0xdc>
    printf("usertests starting\n");
    49a8:	8562                	mv	a0,s8
    49aa:	7f2000ef          	jal	519c <printf>
    int free0 = countfree();
    49ae:	f3fff0ef          	jal	48ec <countfree>
    49b2:	892a                	mv	s2,a0
    n = runtests(quicktests, justone, continuous);
    49b4:	864e                	mv	a2,s3
    49b6:	85d2                	mv	a1,s4
    49b8:	855e                	mv	a0,s7
    49ba:	ec1ff0ef          	jal	487a <runtests>
    49be:	84aa                	mv	s1,a0
    if (n < 0) {
    49c0:	fc0541e3          	bltz	a0,4982 <drivetests+0x50>
    if(!quick) {
    49c4:	fc0a99e3          	bnez	s5,4996 <drivetests+0x64>
      if (justone == 0)
    49c8:	fc0a01e3          	beqz	s4,498a <drivetests+0x58>
      n = runtests(slowtests, justone, continuous);
    49cc:	864e                	mv	a2,s3
    49ce:	85d2                	mv	a1,s4
    49d0:	8566                	mv	a0,s9
    49d2:	ea9ff0ef          	jal	487a <runtests>
      if (n < 0) {
    49d6:	fa054ee3          	bltz	a0,4992 <drivetests+0x60>
        ntests += n;
    49da:	9ca9                	addw	s1,s1,a0
    49dc:	bf6d                	j	4996 <drivetests+0x64>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    49de:	864a                	mv	a2,s2
    49e0:	85aa                	mv	a1,a0
    49e2:	856a                	mv	a0,s10
    49e4:	7b8000ef          	jal	519c <printf>
      if(continuous != 2) {
    49e8:	03699163          	bne	s3,s6,4a0a <drivetests+0xd8>
    if (justone != 0 && ntests == 0) {
    49ec:	fa0a1be3          	bnez	s4,49a2 <drivetests+0x70>
    49f0:	bf65                	j	49a8 <drivetests+0x76>
      printf("NO TESTS EXECUTED\n");
    49f2:	00003517          	auipc	a0,0x3
    49f6:	ae650513          	addi	a0,a0,-1306 # 74d8 <malloc+0x2288>
    49fa:	7a2000ef          	jal	519c <printf>
      return 1;
    49fe:	4505                	li	a0,1
    4a00:	a801                	j	4a10 <drivetests+0xde>
        return 1;
    4a02:	4505                	li	a0,1
    4a04:	a031                	j	4a10 <drivetests+0xde>
          return 1;
    4a06:	4505                	li	a0,1
    4a08:	a021                	j	4a10 <drivetests+0xde>
        return 1;
    4a0a:	4505                	li	a0,1
    4a0c:	a011                	j	4a10 <drivetests+0xde>
  return 0;
    4a0e:	854e                	mv	a0,s3
}
    4a10:	70a6                	ld	ra,104(sp)
    4a12:	7406                	ld	s0,96(sp)
    4a14:	64e6                	ld	s1,88(sp)
    4a16:	6946                	ld	s2,80(sp)
    4a18:	69a6                	ld	s3,72(sp)
    4a1a:	6a06                	ld	s4,64(sp)
    4a1c:	7ae2                	ld	s5,56(sp)
    4a1e:	7b42                	ld	s6,48(sp)
    4a20:	7ba2                	ld	s7,40(sp)
    4a22:	7c02                	ld	s8,32(sp)
    4a24:	6ce2                	ld	s9,24(sp)
    4a26:	6d42                	ld	s10,16(sp)
    4a28:	6da2                	ld	s11,8(sp)
    4a2a:	6165                	addi	sp,sp,112
    4a2c:	8082                	ret

0000000000004a2e <main>:

int
main(int argc, char *argv[])
{
    4a2e:	1101                	addi	sp,sp,-32
    4a30:	ec06                	sd	ra,24(sp)
    4a32:	e822                	sd	s0,16(sp)
    4a34:	e426                	sd	s1,8(sp)
    4a36:	e04a                	sd	s2,0(sp)
    4a38:	1000                	addi	s0,sp,32
    4a3a:	84aa                	mv	s1,a0
  int continuous = 0;
  int quick = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    4a3c:	4789                	li	a5,2
    4a3e:	00f50e63          	beq	a0,a5,4a5a <main+0x2c>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    4a42:	4785                	li	a5,1
    4a44:	06a7c663          	blt	a5,a0,4ab0 <main+0x82>
  char *justone = 0;
    4a48:	4601                	li	a2,0
  int quick = 0;
    4a4a:	4501                	li	a0,0
  int continuous = 0;
    4a4c:	4581                	li	a1,0
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    exit(1);
  }
  if (drivetests(quick, continuous, justone)) {
    4a4e:	ee5ff0ef          	jal	4932 <drivetests>
    4a52:	cd35                	beqz	a0,4ace <main+0xa0>
    exit(1);
    4a54:	4505                	li	a0,1
    4a56:	31e000ef          	jal	4d74 <exit>
    4a5a:	892e                	mv	s2,a1
  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    4a5c:	00003597          	auipc	a1,0x3
    4a60:	a9458593          	addi	a1,a1,-1388 # 74f0 <malloc+0x22a0>
    4a64:	00893503          	ld	a0,8(s2) # ffffffffffffd008 <base+0xfffffffffffed350>
    4a68:	0a4000ef          	jal	4b0c <strcmp>
    4a6c:	85aa                	mv	a1,a0
    4a6e:	e501                	bnez	a0,4a76 <main+0x48>
  char *justone = 0;
    4a70:	4601                	li	a2,0
    quick = 1;
    4a72:	4505                	li	a0,1
    4a74:	bfe9                	j	4a4e <main+0x20>
  } else if(argc == 2 && strcmp(argv[1], "-c") == 0){
    4a76:	00003597          	auipc	a1,0x3
    4a7a:	a8258593          	addi	a1,a1,-1406 # 74f8 <malloc+0x22a8>
    4a7e:	00893503          	ld	a0,8(s2)
    4a82:	08a000ef          	jal	4b0c <strcmp>
    4a86:	cd15                	beqz	a0,4ac2 <main+0x94>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    4a88:	00003597          	auipc	a1,0x3
    4a8c:	ac058593          	addi	a1,a1,-1344 # 7548 <malloc+0x22f8>
    4a90:	00893503          	ld	a0,8(s2)
    4a94:	078000ef          	jal	4b0c <strcmp>
    4a98:	c905                	beqz	a0,4ac8 <main+0x9a>
  } else if(argc == 2 && argv[1][0] != '-'){
    4a9a:	00893603          	ld	a2,8(s2)
    4a9e:	00064703          	lbu	a4,0(a2) # 1000 <badarg>
    4aa2:	02d00793          	li	a5,45
    4aa6:	00f70563          	beq	a4,a5,4ab0 <main+0x82>
  int quick = 0;
    4aaa:	4501                	li	a0,0
  int continuous = 0;
    4aac:	4581                	li	a1,0
    4aae:	b745                	j	4a4e <main+0x20>
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    4ab0:	00003517          	auipc	a0,0x3
    4ab4:	a5050513          	addi	a0,a0,-1456 # 7500 <malloc+0x22b0>
    4ab8:	6e4000ef          	jal	519c <printf>
    exit(1);
    4abc:	4505                	li	a0,1
    4abe:	2b6000ef          	jal	4d74 <exit>
  char *justone = 0;
    4ac2:	4601                	li	a2,0
    continuous = 1;
    4ac4:	4585                	li	a1,1
    4ac6:	b761                	j	4a4e <main+0x20>
    continuous = 2;
    4ac8:	85a6                	mv	a1,s1
  char *justone = 0;
    4aca:	4601                	li	a2,0
    4acc:	b749                	j	4a4e <main+0x20>
  }
  printf("ALL TESTS PASSED\n");
    4ace:	00003517          	auipc	a0,0x3
    4ad2:	a6250513          	addi	a0,a0,-1438 # 7530 <malloc+0x22e0>
    4ad6:	6c6000ef          	jal	519c <printf>
  exit(0);
    4ada:	4501                	li	a0,0
    4adc:	298000ef          	jal	4d74 <exit>

0000000000004ae0 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
    4ae0:	1141                	addi	sp,sp,-16
    4ae2:	e406                	sd	ra,8(sp)
    4ae4:	e022                	sd	s0,0(sp)
    4ae6:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
    4ae8:	f47ff0ef          	jal	4a2e <main>
  exit(r);
    4aec:	288000ef          	jal	4d74 <exit>

0000000000004af0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
    4af0:	1141                	addi	sp,sp,-16
    4af2:	e422                	sd	s0,8(sp)
    4af4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    4af6:	87aa                	mv	a5,a0
    4af8:	0585                	addi	a1,a1,1
    4afa:	0785                	addi	a5,a5,1
    4afc:	fff5c703          	lbu	a4,-1(a1)
    4b00:	fee78fa3          	sb	a4,-1(a5)
    4b04:	fb75                	bnez	a4,4af8 <strcpy+0x8>
    ;
  return os;
}
    4b06:	6422                	ld	s0,8(sp)
    4b08:	0141                	addi	sp,sp,16
    4b0a:	8082                	ret

0000000000004b0c <strcmp>:

int
strcmp(const char *p, const char *q)
{
    4b0c:	1141                	addi	sp,sp,-16
    4b0e:	e422                	sd	s0,8(sp)
    4b10:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    4b12:	00054783          	lbu	a5,0(a0)
    4b16:	cb91                	beqz	a5,4b2a <strcmp+0x1e>
    4b18:	0005c703          	lbu	a4,0(a1)
    4b1c:	00f71763          	bne	a4,a5,4b2a <strcmp+0x1e>
    p++, q++;
    4b20:	0505                	addi	a0,a0,1
    4b22:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    4b24:	00054783          	lbu	a5,0(a0)
    4b28:	fbe5                	bnez	a5,4b18 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    4b2a:	0005c503          	lbu	a0,0(a1)
}
    4b2e:	40a7853b          	subw	a0,a5,a0
    4b32:	6422                	ld	s0,8(sp)
    4b34:	0141                	addi	sp,sp,16
    4b36:	8082                	ret

0000000000004b38 <strlen>:

uint
strlen(const char *s)
{
    4b38:	1141                	addi	sp,sp,-16
    4b3a:	e422                	sd	s0,8(sp)
    4b3c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    4b3e:	00054783          	lbu	a5,0(a0)
    4b42:	cf91                	beqz	a5,4b5e <strlen+0x26>
    4b44:	0505                	addi	a0,a0,1
    4b46:	87aa                	mv	a5,a0
    4b48:	86be                	mv	a3,a5
    4b4a:	0785                	addi	a5,a5,1
    4b4c:	fff7c703          	lbu	a4,-1(a5)
    4b50:	ff65                	bnez	a4,4b48 <strlen+0x10>
    4b52:	40a6853b          	subw	a0,a3,a0
    4b56:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    4b58:	6422                	ld	s0,8(sp)
    4b5a:	0141                	addi	sp,sp,16
    4b5c:	8082                	ret
  for(n = 0; s[n]; n++)
    4b5e:	4501                	li	a0,0
    4b60:	bfe5                	j	4b58 <strlen+0x20>

0000000000004b62 <memset>:

void*
memset(void *dst, int c, uint n)
{
    4b62:	1141                	addi	sp,sp,-16
    4b64:	e422                	sd	s0,8(sp)
    4b66:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    4b68:	ca19                	beqz	a2,4b7e <memset+0x1c>
    4b6a:	87aa                	mv	a5,a0
    4b6c:	1602                	slli	a2,a2,0x20
    4b6e:	9201                	srli	a2,a2,0x20
    4b70:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    4b74:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    4b78:	0785                	addi	a5,a5,1
    4b7a:	fee79de3          	bne	a5,a4,4b74 <memset+0x12>
  }
  return dst;
}
    4b7e:	6422                	ld	s0,8(sp)
    4b80:	0141                	addi	sp,sp,16
    4b82:	8082                	ret

0000000000004b84 <strchr>:

char*
strchr(const char *s, char c)
{
    4b84:	1141                	addi	sp,sp,-16
    4b86:	e422                	sd	s0,8(sp)
    4b88:	0800                	addi	s0,sp,16
  for(; *s; s++)
    4b8a:	00054783          	lbu	a5,0(a0)
    4b8e:	cb99                	beqz	a5,4ba4 <strchr+0x20>
    if(*s == c)
    4b90:	00f58763          	beq	a1,a5,4b9e <strchr+0x1a>
  for(; *s; s++)
    4b94:	0505                	addi	a0,a0,1
    4b96:	00054783          	lbu	a5,0(a0)
    4b9a:	fbfd                	bnez	a5,4b90 <strchr+0xc>
      return (char*)s;
  return 0;
    4b9c:	4501                	li	a0,0
}
    4b9e:	6422                	ld	s0,8(sp)
    4ba0:	0141                	addi	sp,sp,16
    4ba2:	8082                	ret
  return 0;
    4ba4:	4501                	li	a0,0
    4ba6:	bfe5                	j	4b9e <strchr+0x1a>

0000000000004ba8 <gets>:

char*
gets(char *buf, int max)
{
    4ba8:	711d                	addi	sp,sp,-96
    4baa:	ec86                	sd	ra,88(sp)
    4bac:	e8a2                	sd	s0,80(sp)
    4bae:	e4a6                	sd	s1,72(sp)
    4bb0:	e0ca                	sd	s2,64(sp)
    4bb2:	fc4e                	sd	s3,56(sp)
    4bb4:	f852                	sd	s4,48(sp)
    4bb6:	f456                	sd	s5,40(sp)
    4bb8:	f05a                	sd	s6,32(sp)
    4bba:	ec5e                	sd	s7,24(sp)
    4bbc:	1080                	addi	s0,sp,96
    4bbe:	8baa                	mv	s7,a0
    4bc0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    4bc2:	892a                	mv	s2,a0
    4bc4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    4bc6:	4aa9                	li	s5,10
    4bc8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    4bca:	89a6                	mv	s3,s1
    4bcc:	2485                	addiw	s1,s1,1
    4bce:	0344d663          	bge	s1,s4,4bfa <gets+0x52>
    cc = read(0, &c, 1);
    4bd2:	4605                	li	a2,1
    4bd4:	faf40593          	addi	a1,s0,-81
    4bd8:	4501                	li	a0,0
    4bda:	1b2000ef          	jal	4d8c <read>
    if(cc < 1)
    4bde:	00a05e63          	blez	a0,4bfa <gets+0x52>
    buf[i++] = c;
    4be2:	faf44783          	lbu	a5,-81(s0)
    4be6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    4bea:	01578763          	beq	a5,s5,4bf8 <gets+0x50>
    4bee:	0905                	addi	s2,s2,1
    4bf0:	fd679de3          	bne	a5,s6,4bca <gets+0x22>
    buf[i++] = c;
    4bf4:	89a6                	mv	s3,s1
    4bf6:	a011                	j	4bfa <gets+0x52>
    4bf8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    4bfa:	99de                	add	s3,s3,s7
    4bfc:	00098023          	sb	zero,0(s3)
  return buf;
}
    4c00:	855e                	mv	a0,s7
    4c02:	60e6                	ld	ra,88(sp)
    4c04:	6446                	ld	s0,80(sp)
    4c06:	64a6                	ld	s1,72(sp)
    4c08:	6906                	ld	s2,64(sp)
    4c0a:	79e2                	ld	s3,56(sp)
    4c0c:	7a42                	ld	s4,48(sp)
    4c0e:	7aa2                	ld	s5,40(sp)
    4c10:	7b02                	ld	s6,32(sp)
    4c12:	6be2                	ld	s7,24(sp)
    4c14:	6125                	addi	sp,sp,96
    4c16:	8082                	ret

0000000000004c18 <stat>:

int
stat(const char *n, struct stat *st)
{
    4c18:	1101                	addi	sp,sp,-32
    4c1a:	ec06                	sd	ra,24(sp)
    4c1c:	e822                	sd	s0,16(sp)
    4c1e:	e04a                	sd	s2,0(sp)
    4c20:	1000                	addi	s0,sp,32
    4c22:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    4c24:	4581                	li	a1,0
    4c26:	18e000ef          	jal	4db4 <open>
  if(fd < 0)
    4c2a:	02054263          	bltz	a0,4c4e <stat+0x36>
    4c2e:	e426                	sd	s1,8(sp)
    4c30:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    4c32:	85ca                	mv	a1,s2
    4c34:	198000ef          	jal	4dcc <fstat>
    4c38:	892a                	mv	s2,a0
  close(fd);
    4c3a:	8526                	mv	a0,s1
    4c3c:	160000ef          	jal	4d9c <close>
  return r;
    4c40:	64a2                	ld	s1,8(sp)
}
    4c42:	854a                	mv	a0,s2
    4c44:	60e2                	ld	ra,24(sp)
    4c46:	6442                	ld	s0,16(sp)
    4c48:	6902                	ld	s2,0(sp)
    4c4a:	6105                	addi	sp,sp,32
    4c4c:	8082                	ret
    return -1;
    4c4e:	597d                	li	s2,-1
    4c50:	bfcd                	j	4c42 <stat+0x2a>

0000000000004c52 <atoi>:

int
atoi(const char *s)
{
    4c52:	1141                	addi	sp,sp,-16
    4c54:	e422                	sd	s0,8(sp)
    4c56:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    4c58:	00054683          	lbu	a3,0(a0)
    4c5c:	fd06879b          	addiw	a5,a3,-48 # 3ffd0 <base+0x30318>
    4c60:	0ff7f793          	zext.b	a5,a5
    4c64:	4625                	li	a2,9
    4c66:	02f66863          	bltu	a2,a5,4c96 <atoi+0x44>
    4c6a:	872a                	mv	a4,a0
  n = 0;
    4c6c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
    4c6e:	0705                	addi	a4,a4,1 # 1000001 <base+0xff0349>
    4c70:	0025179b          	slliw	a5,a0,0x2
    4c74:	9fa9                	addw	a5,a5,a0
    4c76:	0017979b          	slliw	a5,a5,0x1
    4c7a:	9fb5                	addw	a5,a5,a3
    4c7c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    4c80:	00074683          	lbu	a3,0(a4)
    4c84:	fd06879b          	addiw	a5,a3,-48
    4c88:	0ff7f793          	zext.b	a5,a5
    4c8c:	fef671e3          	bgeu	a2,a5,4c6e <atoi+0x1c>
  return n;
}
    4c90:	6422                	ld	s0,8(sp)
    4c92:	0141                	addi	sp,sp,16
    4c94:	8082                	ret
  n = 0;
    4c96:	4501                	li	a0,0
    4c98:	bfe5                	j	4c90 <atoi+0x3e>

0000000000004c9a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    4c9a:	1141                	addi	sp,sp,-16
    4c9c:	e422                	sd	s0,8(sp)
    4c9e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    4ca0:	02b57463          	bgeu	a0,a1,4cc8 <memmove+0x2e>
    while(n-- > 0)
    4ca4:	00c05f63          	blez	a2,4cc2 <memmove+0x28>
    4ca8:	1602                	slli	a2,a2,0x20
    4caa:	9201                	srli	a2,a2,0x20
    4cac:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    4cb0:	872a                	mv	a4,a0
      *dst++ = *src++;
    4cb2:	0585                	addi	a1,a1,1
    4cb4:	0705                	addi	a4,a4,1
    4cb6:	fff5c683          	lbu	a3,-1(a1)
    4cba:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    4cbe:	fef71ae3          	bne	a4,a5,4cb2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    4cc2:	6422                	ld	s0,8(sp)
    4cc4:	0141                	addi	sp,sp,16
    4cc6:	8082                	ret
    dst += n;
    4cc8:	00c50733          	add	a4,a0,a2
    src += n;
    4ccc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    4cce:	fec05ae3          	blez	a2,4cc2 <memmove+0x28>
    4cd2:	fff6079b          	addiw	a5,a2,-1
    4cd6:	1782                	slli	a5,a5,0x20
    4cd8:	9381                	srli	a5,a5,0x20
    4cda:	fff7c793          	not	a5,a5
    4cde:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    4ce0:	15fd                	addi	a1,a1,-1
    4ce2:	177d                	addi	a4,a4,-1
    4ce4:	0005c683          	lbu	a3,0(a1)
    4ce8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    4cec:	fee79ae3          	bne	a5,a4,4ce0 <memmove+0x46>
    4cf0:	bfc9                	j	4cc2 <memmove+0x28>

0000000000004cf2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    4cf2:	1141                	addi	sp,sp,-16
    4cf4:	e422                	sd	s0,8(sp)
    4cf6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    4cf8:	ca05                	beqz	a2,4d28 <memcmp+0x36>
    4cfa:	fff6069b          	addiw	a3,a2,-1
    4cfe:	1682                	slli	a3,a3,0x20
    4d00:	9281                	srli	a3,a3,0x20
    4d02:	0685                	addi	a3,a3,1
    4d04:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    4d06:	00054783          	lbu	a5,0(a0)
    4d0a:	0005c703          	lbu	a4,0(a1)
    4d0e:	00e79863          	bne	a5,a4,4d1e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    4d12:	0505                	addi	a0,a0,1
    p2++;
    4d14:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    4d16:	fed518e3          	bne	a0,a3,4d06 <memcmp+0x14>
  }
  return 0;
    4d1a:	4501                	li	a0,0
    4d1c:	a019                	j	4d22 <memcmp+0x30>
      return *p1 - *p2;
    4d1e:	40e7853b          	subw	a0,a5,a4
}
    4d22:	6422                	ld	s0,8(sp)
    4d24:	0141                	addi	sp,sp,16
    4d26:	8082                	ret
  return 0;
    4d28:	4501                	li	a0,0
    4d2a:	bfe5                	j	4d22 <memcmp+0x30>

0000000000004d2c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    4d2c:	1141                	addi	sp,sp,-16
    4d2e:	e406                	sd	ra,8(sp)
    4d30:	e022                	sd	s0,0(sp)
    4d32:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    4d34:	f67ff0ef          	jal	4c9a <memmove>
}
    4d38:	60a2                	ld	ra,8(sp)
    4d3a:	6402                	ld	s0,0(sp)
    4d3c:	0141                	addi	sp,sp,16
    4d3e:	8082                	ret

0000000000004d40 <sbrk>:

char *
sbrk(int n) {
    4d40:	1141                	addi	sp,sp,-16
    4d42:	e406                	sd	ra,8(sp)
    4d44:	e022                	sd	s0,0(sp)
    4d46:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
    4d48:	4585                	li	a1,1
    4d4a:	0b2000ef          	jal	4dfc <sys_sbrk>
}
    4d4e:	60a2                	ld	ra,8(sp)
    4d50:	6402                	ld	s0,0(sp)
    4d52:	0141                	addi	sp,sp,16
    4d54:	8082                	ret

0000000000004d56 <sbrklazy>:

char *
sbrklazy(int n) {
    4d56:	1141                	addi	sp,sp,-16
    4d58:	e406                	sd	ra,8(sp)
    4d5a:	e022                	sd	s0,0(sp)
    4d5c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
    4d5e:	4589                	li	a1,2
    4d60:	09c000ef          	jal	4dfc <sys_sbrk>
}
    4d64:	60a2                	ld	ra,8(sp)
    4d66:	6402                	ld	s0,0(sp)
    4d68:	0141                	addi	sp,sp,16
    4d6a:	8082                	ret

0000000000004d6c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    4d6c:	4885                	li	a7,1
 ecall
    4d6e:	00000073          	ecall
 ret
    4d72:	8082                	ret

0000000000004d74 <exit>:
.global exit
exit:
 li a7, SYS_exit
    4d74:	4889                	li	a7,2
 ecall
    4d76:	00000073          	ecall
 ret
    4d7a:	8082                	ret

0000000000004d7c <wait>:
.global wait
wait:
 li a7, SYS_wait
    4d7c:	488d                	li	a7,3
 ecall
    4d7e:	00000073          	ecall
 ret
    4d82:	8082                	ret

0000000000004d84 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    4d84:	4891                	li	a7,4
 ecall
    4d86:	00000073          	ecall
 ret
    4d8a:	8082                	ret

0000000000004d8c <read>:
.global read
read:
 li a7, SYS_read
    4d8c:	4895                	li	a7,5
 ecall
    4d8e:	00000073          	ecall
 ret
    4d92:	8082                	ret

0000000000004d94 <write>:
.global write
write:
 li a7, SYS_write
    4d94:	48c1                	li	a7,16
 ecall
    4d96:	00000073          	ecall
 ret
    4d9a:	8082                	ret

0000000000004d9c <close>:
.global close
close:
 li a7, SYS_close
    4d9c:	48d5                	li	a7,21
 ecall
    4d9e:	00000073          	ecall
 ret
    4da2:	8082                	ret

0000000000004da4 <kill>:
.global kill
kill:
 li a7, SYS_kill
    4da4:	4899                	li	a7,6
 ecall
    4da6:	00000073          	ecall
 ret
    4daa:	8082                	ret

0000000000004dac <exec>:
.global exec
exec:
 li a7, SYS_exec
    4dac:	489d                	li	a7,7
 ecall
    4dae:	00000073          	ecall
 ret
    4db2:	8082                	ret

0000000000004db4 <open>:
.global open
open:
 li a7, SYS_open
    4db4:	48bd                	li	a7,15
 ecall
    4db6:	00000073          	ecall
 ret
    4dba:	8082                	ret

0000000000004dbc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    4dbc:	48c5                	li	a7,17
 ecall
    4dbe:	00000073          	ecall
 ret
    4dc2:	8082                	ret

0000000000004dc4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    4dc4:	48c9                	li	a7,18
 ecall
    4dc6:	00000073          	ecall
 ret
    4dca:	8082                	ret

0000000000004dcc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    4dcc:	48a1                	li	a7,8
 ecall
    4dce:	00000073          	ecall
 ret
    4dd2:	8082                	ret

0000000000004dd4 <link>:
.global link
link:
 li a7, SYS_link
    4dd4:	48cd                	li	a7,19
 ecall
    4dd6:	00000073          	ecall
 ret
    4dda:	8082                	ret

0000000000004ddc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    4ddc:	48d1                	li	a7,20
 ecall
    4dde:	00000073          	ecall
 ret
    4de2:	8082                	ret

0000000000004de4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    4de4:	48a5                	li	a7,9
 ecall
    4de6:	00000073          	ecall
 ret
    4dea:	8082                	ret

0000000000004dec <dup>:
.global dup
dup:
 li a7, SYS_dup
    4dec:	48a9                	li	a7,10
 ecall
    4dee:	00000073          	ecall
 ret
    4df2:	8082                	ret

0000000000004df4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    4df4:	48ad                	li	a7,11
 ecall
    4df6:	00000073          	ecall
 ret
    4dfa:	8082                	ret

0000000000004dfc <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
    4dfc:	48b1                	li	a7,12
 ecall
    4dfe:	00000073          	ecall
 ret
    4e02:	8082                	ret

0000000000004e04 <pause>:
.global pause
pause:
 li a7, SYS_pause
    4e04:	48b5                	li	a7,13
 ecall
    4e06:	00000073          	ecall
 ret
    4e0a:	8082                	ret

0000000000004e0c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    4e0c:	48b9                	li	a7,14
 ecall
    4e0e:	00000073          	ecall
 ret
    4e12:	8082                	ret

0000000000004e14 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    4e14:	1101                	addi	sp,sp,-32
    4e16:	ec06                	sd	ra,24(sp)
    4e18:	e822                	sd	s0,16(sp)
    4e1a:	1000                	addi	s0,sp,32
    4e1c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    4e20:	4605                	li	a2,1
    4e22:	fef40593          	addi	a1,s0,-17
    4e26:	f6fff0ef          	jal	4d94 <write>
}
    4e2a:	60e2                	ld	ra,24(sp)
    4e2c:	6442                	ld	s0,16(sp)
    4e2e:	6105                	addi	sp,sp,32
    4e30:	8082                	ret

0000000000004e32 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
    4e32:	715d                	addi	sp,sp,-80
    4e34:	e486                	sd	ra,72(sp)
    4e36:	e0a2                	sd	s0,64(sp)
    4e38:	f84a                	sd	s2,48(sp)
    4e3a:	0880                	addi	s0,sp,80
    4e3c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
    4e3e:	c299                	beqz	a3,4e44 <printint+0x12>
    4e40:	0805c363          	bltz	a1,4ec6 <printint+0x94>
  neg = 0;
    4e44:	4881                	li	a7,0
    4e46:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
    4e4a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
    4e4c:	00003517          	auipc	a0,0x3
    4e50:	b2c50513          	addi	a0,a0,-1236 # 7978 <digits>
    4e54:	883e                	mv	a6,a5
    4e56:	2785                	addiw	a5,a5,1
    4e58:	02c5f733          	remu	a4,a1,a2
    4e5c:	972a                	add	a4,a4,a0
    4e5e:	00074703          	lbu	a4,0(a4)
    4e62:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
    4e66:	872e                	mv	a4,a1
    4e68:	02c5d5b3          	divu	a1,a1,a2
    4e6c:	0685                	addi	a3,a3,1
    4e6e:	fec773e3          	bgeu	a4,a2,4e54 <printint+0x22>
  if(neg)
    4e72:	00088b63          	beqz	a7,4e88 <printint+0x56>
    buf[i++] = '-';
    4e76:	fd078793          	addi	a5,a5,-48
    4e7a:	97a2                	add	a5,a5,s0
    4e7c:	02d00713          	li	a4,45
    4e80:	fee78423          	sb	a4,-24(a5)
    4e84:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    4e88:	02f05a63          	blez	a5,4ebc <printint+0x8a>
    4e8c:	fc26                	sd	s1,56(sp)
    4e8e:	f44e                	sd	s3,40(sp)
    4e90:	fb840713          	addi	a4,s0,-72
    4e94:	00f704b3          	add	s1,a4,a5
    4e98:	fff70993          	addi	s3,a4,-1
    4e9c:	99be                	add	s3,s3,a5
    4e9e:	37fd                	addiw	a5,a5,-1
    4ea0:	1782                	slli	a5,a5,0x20
    4ea2:	9381                	srli	a5,a5,0x20
    4ea4:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
    4ea8:	fff4c583          	lbu	a1,-1(s1)
    4eac:	854a                	mv	a0,s2
    4eae:	f67ff0ef          	jal	4e14 <putc>
  while(--i >= 0)
    4eb2:	14fd                	addi	s1,s1,-1
    4eb4:	ff349ae3          	bne	s1,s3,4ea8 <printint+0x76>
    4eb8:	74e2                	ld	s1,56(sp)
    4eba:	79a2                	ld	s3,40(sp)
}
    4ebc:	60a6                	ld	ra,72(sp)
    4ebe:	6406                	ld	s0,64(sp)
    4ec0:	7942                	ld	s2,48(sp)
    4ec2:	6161                	addi	sp,sp,80
    4ec4:	8082                	ret
    x = -xx;
    4ec6:	40b005b3          	neg	a1,a1
    neg = 1;
    4eca:	4885                	li	a7,1
    x = -xx;
    4ecc:	bfad                	j	4e46 <printint+0x14>

0000000000004ece <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    4ece:	711d                	addi	sp,sp,-96
    4ed0:	ec86                	sd	ra,88(sp)
    4ed2:	e8a2                	sd	s0,80(sp)
    4ed4:	e0ca                	sd	s2,64(sp)
    4ed6:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    4ed8:	0005c903          	lbu	s2,0(a1)
    4edc:	28090663          	beqz	s2,5168 <vprintf+0x29a>
    4ee0:	e4a6                	sd	s1,72(sp)
    4ee2:	fc4e                	sd	s3,56(sp)
    4ee4:	f852                	sd	s4,48(sp)
    4ee6:	f456                	sd	s5,40(sp)
    4ee8:	f05a                	sd	s6,32(sp)
    4eea:	ec5e                	sd	s7,24(sp)
    4eec:	e862                	sd	s8,16(sp)
    4eee:	e466                	sd	s9,8(sp)
    4ef0:	8b2a                	mv	s6,a0
    4ef2:	8a2e                	mv	s4,a1
    4ef4:	8bb2                	mv	s7,a2
  state = 0;
    4ef6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
    4ef8:	4481                	li	s1,0
    4efa:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
    4efc:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
    4f00:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
    4f04:	06c00c93          	li	s9,108
    4f08:	a005                	j	4f28 <vprintf+0x5a>
        putc(fd, c0);
    4f0a:	85ca                	mv	a1,s2
    4f0c:	855a                	mv	a0,s6
    4f0e:	f07ff0ef          	jal	4e14 <putc>
    4f12:	a019                	j	4f18 <vprintf+0x4a>
    } else if(state == '%'){
    4f14:	03598263          	beq	s3,s5,4f38 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
    4f18:	2485                	addiw	s1,s1,1
    4f1a:	8726                	mv	a4,s1
    4f1c:	009a07b3          	add	a5,s4,s1
    4f20:	0007c903          	lbu	s2,0(a5)
    4f24:	22090a63          	beqz	s2,5158 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
    4f28:	0009079b          	sext.w	a5,s2
    if(state == 0){
    4f2c:	fe0994e3          	bnez	s3,4f14 <vprintf+0x46>
      if(c0 == '%'){
    4f30:	fd579de3          	bne	a5,s5,4f0a <vprintf+0x3c>
        state = '%';
    4f34:	89be                	mv	s3,a5
    4f36:	b7cd                	j	4f18 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
    4f38:	00ea06b3          	add	a3,s4,a4
    4f3c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
    4f40:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
    4f42:	c681                	beqz	a3,4f4a <vprintf+0x7c>
    4f44:	9752                	add	a4,a4,s4
    4f46:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
    4f4a:	05878363          	beq	a5,s8,4f90 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
    4f4e:	05978d63          	beq	a5,s9,4fa8 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
    4f52:	07500713          	li	a4,117
    4f56:	0ee78763          	beq	a5,a4,5044 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
    4f5a:	07800713          	li	a4,120
    4f5e:	12e78963          	beq	a5,a4,5090 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
    4f62:	07000713          	li	a4,112
    4f66:	14e78e63          	beq	a5,a4,50c2 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
    4f6a:	06300713          	li	a4,99
    4f6e:	18e78e63          	beq	a5,a4,510a <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
    4f72:	07300713          	li	a4,115
    4f76:	1ae78463          	beq	a5,a4,511e <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
    4f7a:	02500713          	li	a4,37
    4f7e:	04e79563          	bne	a5,a4,4fc8 <vprintf+0xfa>
        putc(fd, '%');
    4f82:	02500593          	li	a1,37
    4f86:	855a                	mv	a0,s6
    4f88:	e8dff0ef          	jal	4e14 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
    4f8c:	4981                	li	s3,0
    4f8e:	b769                	j	4f18 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
    4f90:	008b8913          	addi	s2,s7,8
    4f94:	4685                	li	a3,1
    4f96:	4629                	li	a2,10
    4f98:	000ba583          	lw	a1,0(s7)
    4f9c:	855a                	mv	a0,s6
    4f9e:	e95ff0ef          	jal	4e32 <printint>
    4fa2:	8bca                	mv	s7,s2
      state = 0;
    4fa4:	4981                	li	s3,0
    4fa6:	bf8d                	j	4f18 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
    4fa8:	06400793          	li	a5,100
    4fac:	02f68963          	beq	a3,a5,4fde <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    4fb0:	06c00793          	li	a5,108
    4fb4:	04f68263          	beq	a3,a5,4ff8 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
    4fb8:	07500793          	li	a5,117
    4fbc:	0af68063          	beq	a3,a5,505c <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
    4fc0:	07800793          	li	a5,120
    4fc4:	0ef68263          	beq	a3,a5,50a8 <vprintf+0x1da>
        putc(fd, '%');
    4fc8:	02500593          	li	a1,37
    4fcc:	855a                	mv	a0,s6
    4fce:	e47ff0ef          	jal	4e14 <putc>
        putc(fd, c0);
    4fd2:	85ca                	mv	a1,s2
    4fd4:	855a                	mv	a0,s6
    4fd6:	e3fff0ef          	jal	4e14 <putc>
      state = 0;
    4fda:	4981                	li	s3,0
    4fdc:	bf35                	j	4f18 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    4fde:	008b8913          	addi	s2,s7,8
    4fe2:	4685                	li	a3,1
    4fe4:	4629                	li	a2,10
    4fe6:	000bb583          	ld	a1,0(s7)
    4fea:	855a                	mv	a0,s6
    4fec:	e47ff0ef          	jal	4e32 <printint>
        i += 1;
    4ff0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
    4ff2:	8bca                	mv	s7,s2
      state = 0;
    4ff4:	4981                	li	s3,0
        i += 1;
    4ff6:	b70d                	j	4f18 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    4ff8:	06400793          	li	a5,100
    4ffc:	02f60763          	beq	a2,a5,502a <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    5000:	07500793          	li	a5,117
    5004:	06f60963          	beq	a2,a5,5076 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    5008:	07800793          	li	a5,120
    500c:	faf61ee3          	bne	a2,a5,4fc8 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
    5010:	008b8913          	addi	s2,s7,8
    5014:	4681                	li	a3,0
    5016:	4641                	li	a2,16
    5018:	000bb583          	ld	a1,0(s7)
    501c:	855a                	mv	a0,s6
    501e:	e15ff0ef          	jal	4e32 <printint>
        i += 2;
    5022:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
    5024:	8bca                	mv	s7,s2
      state = 0;
    5026:	4981                	li	s3,0
        i += 2;
    5028:	bdc5                	j	4f18 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    502a:	008b8913          	addi	s2,s7,8
    502e:	4685                	li	a3,1
    5030:	4629                	li	a2,10
    5032:	000bb583          	ld	a1,0(s7)
    5036:	855a                	mv	a0,s6
    5038:	dfbff0ef          	jal	4e32 <printint>
        i += 2;
    503c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
    503e:	8bca                	mv	s7,s2
      state = 0;
    5040:	4981                	li	s3,0
        i += 2;
    5042:	bdd9                	j	4f18 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
    5044:	008b8913          	addi	s2,s7,8
    5048:	4681                	li	a3,0
    504a:	4629                	li	a2,10
    504c:	000be583          	lwu	a1,0(s7)
    5050:	855a                	mv	a0,s6
    5052:	de1ff0ef          	jal	4e32 <printint>
    5056:	8bca                	mv	s7,s2
      state = 0;
    5058:	4981                	li	s3,0
    505a:	bd7d                	j	4f18 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    505c:	008b8913          	addi	s2,s7,8
    5060:	4681                	li	a3,0
    5062:	4629                	li	a2,10
    5064:	000bb583          	ld	a1,0(s7)
    5068:	855a                	mv	a0,s6
    506a:	dc9ff0ef          	jal	4e32 <printint>
        i += 1;
    506e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
    5070:	8bca                	mv	s7,s2
      state = 0;
    5072:	4981                	li	s3,0
        i += 1;
    5074:	b555                	j	4f18 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5076:	008b8913          	addi	s2,s7,8
    507a:	4681                	li	a3,0
    507c:	4629                	li	a2,10
    507e:	000bb583          	ld	a1,0(s7)
    5082:	855a                	mv	a0,s6
    5084:	dafff0ef          	jal	4e32 <printint>
        i += 2;
    5088:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
    508a:	8bca                	mv	s7,s2
      state = 0;
    508c:	4981                	li	s3,0
        i += 2;
    508e:	b569                	j	4f18 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
    5090:	008b8913          	addi	s2,s7,8
    5094:	4681                	li	a3,0
    5096:	4641                	li	a2,16
    5098:	000be583          	lwu	a1,0(s7)
    509c:	855a                	mv	a0,s6
    509e:	d95ff0ef          	jal	4e32 <printint>
    50a2:	8bca                	mv	s7,s2
      state = 0;
    50a4:	4981                	li	s3,0
    50a6:	bd8d                	j	4f18 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
    50a8:	008b8913          	addi	s2,s7,8
    50ac:	4681                	li	a3,0
    50ae:	4641                	li	a2,16
    50b0:	000bb583          	ld	a1,0(s7)
    50b4:	855a                	mv	a0,s6
    50b6:	d7dff0ef          	jal	4e32 <printint>
        i += 1;
    50ba:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
    50bc:	8bca                	mv	s7,s2
      state = 0;
    50be:	4981                	li	s3,0
        i += 1;
    50c0:	bda1                	j	4f18 <vprintf+0x4a>
    50c2:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
    50c4:	008b8d13          	addi	s10,s7,8
    50c8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    50cc:	03000593          	li	a1,48
    50d0:	855a                	mv	a0,s6
    50d2:	d43ff0ef          	jal	4e14 <putc>
  putc(fd, 'x');
    50d6:	07800593          	li	a1,120
    50da:	855a                	mv	a0,s6
    50dc:	d39ff0ef          	jal	4e14 <putc>
    50e0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    50e2:	00003b97          	auipc	s7,0x3
    50e6:	896b8b93          	addi	s7,s7,-1898 # 7978 <digits>
    50ea:	03c9d793          	srli	a5,s3,0x3c
    50ee:	97de                	add	a5,a5,s7
    50f0:	0007c583          	lbu	a1,0(a5)
    50f4:	855a                	mv	a0,s6
    50f6:	d1fff0ef          	jal	4e14 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    50fa:	0992                	slli	s3,s3,0x4
    50fc:	397d                	addiw	s2,s2,-1
    50fe:	fe0916e3          	bnez	s2,50ea <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
    5102:	8bea                	mv	s7,s10
      state = 0;
    5104:	4981                	li	s3,0
    5106:	6d02                	ld	s10,0(sp)
    5108:	bd01                	j	4f18 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
    510a:	008b8913          	addi	s2,s7,8
    510e:	000bc583          	lbu	a1,0(s7)
    5112:	855a                	mv	a0,s6
    5114:	d01ff0ef          	jal	4e14 <putc>
    5118:	8bca                	mv	s7,s2
      state = 0;
    511a:	4981                	li	s3,0
    511c:	bbf5                	j	4f18 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
    511e:	008b8993          	addi	s3,s7,8
    5122:	000bb903          	ld	s2,0(s7)
    5126:	00090f63          	beqz	s2,5144 <vprintf+0x276>
        for(; *s; s++)
    512a:	00094583          	lbu	a1,0(s2)
    512e:	c195                	beqz	a1,5152 <vprintf+0x284>
          putc(fd, *s);
    5130:	855a                	mv	a0,s6
    5132:	ce3ff0ef          	jal	4e14 <putc>
        for(; *s; s++)
    5136:	0905                	addi	s2,s2,1
    5138:	00094583          	lbu	a1,0(s2)
    513c:	f9f5                	bnez	a1,5130 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
    513e:	8bce                	mv	s7,s3
      state = 0;
    5140:	4981                	li	s3,0
    5142:	bbd9                	j	4f18 <vprintf+0x4a>
          s = "(null)";
    5144:	00002917          	auipc	s2,0x2
    5148:	78490913          	addi	s2,s2,1924 # 78c8 <malloc+0x2678>
        for(; *s; s++)
    514c:	02800593          	li	a1,40
    5150:	b7c5                	j	5130 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
    5152:	8bce                	mv	s7,s3
      state = 0;
    5154:	4981                	li	s3,0
    5156:	b3c9                	j	4f18 <vprintf+0x4a>
    5158:	64a6                	ld	s1,72(sp)
    515a:	79e2                	ld	s3,56(sp)
    515c:	7a42                	ld	s4,48(sp)
    515e:	7aa2                	ld	s5,40(sp)
    5160:	7b02                	ld	s6,32(sp)
    5162:	6be2                	ld	s7,24(sp)
    5164:	6c42                	ld	s8,16(sp)
    5166:	6ca2                	ld	s9,8(sp)
    }
  }
}
    5168:	60e6                	ld	ra,88(sp)
    516a:	6446                	ld	s0,80(sp)
    516c:	6906                	ld	s2,64(sp)
    516e:	6125                	addi	sp,sp,96
    5170:	8082                	ret

0000000000005172 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5172:	715d                	addi	sp,sp,-80
    5174:	ec06                	sd	ra,24(sp)
    5176:	e822                	sd	s0,16(sp)
    5178:	1000                	addi	s0,sp,32
    517a:	e010                	sd	a2,0(s0)
    517c:	e414                	sd	a3,8(s0)
    517e:	e818                	sd	a4,16(s0)
    5180:	ec1c                	sd	a5,24(s0)
    5182:	03043023          	sd	a6,32(s0)
    5186:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    518a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    518e:	8622                	mv	a2,s0
    5190:	d3fff0ef          	jal	4ece <vprintf>
}
    5194:	60e2                	ld	ra,24(sp)
    5196:	6442                	ld	s0,16(sp)
    5198:	6161                	addi	sp,sp,80
    519a:	8082                	ret

000000000000519c <printf>:

void
printf(const char *fmt, ...)
{
    519c:	711d                	addi	sp,sp,-96
    519e:	ec06                	sd	ra,24(sp)
    51a0:	e822                	sd	s0,16(sp)
    51a2:	1000                	addi	s0,sp,32
    51a4:	e40c                	sd	a1,8(s0)
    51a6:	e810                	sd	a2,16(s0)
    51a8:	ec14                	sd	a3,24(s0)
    51aa:	f018                	sd	a4,32(s0)
    51ac:	f41c                	sd	a5,40(s0)
    51ae:	03043823          	sd	a6,48(s0)
    51b2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    51b6:	00840613          	addi	a2,s0,8
    51ba:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    51be:	85aa                	mv	a1,a0
    51c0:	4505                	li	a0,1
    51c2:	d0dff0ef          	jal	4ece <vprintf>
}
    51c6:	60e2                	ld	ra,24(sp)
    51c8:	6442                	ld	s0,16(sp)
    51ca:	6125                	addi	sp,sp,96
    51cc:	8082                	ret

00000000000051ce <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    51ce:	1141                	addi	sp,sp,-16
    51d0:	e422                	sd	s0,8(sp)
    51d2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    51d4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    51d8:	00004797          	auipc	a5,0x4
    51dc:	2b87b783          	ld	a5,696(a5) # 9490 <freep>
    51e0:	a02d                	j	520a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    51e2:	4618                	lw	a4,8(a2)
    51e4:	9f2d                	addw	a4,a4,a1
    51e6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    51ea:	6398                	ld	a4,0(a5)
    51ec:	6310                	ld	a2,0(a4)
    51ee:	a83d                	j	522c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    51f0:	ff852703          	lw	a4,-8(a0)
    51f4:	9f31                	addw	a4,a4,a2
    51f6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    51f8:	ff053683          	ld	a3,-16(a0)
    51fc:	a091                	j	5240 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    51fe:	6398                	ld	a4,0(a5)
    5200:	00e7e463          	bltu	a5,a4,5208 <free+0x3a>
    5204:	00e6ea63          	bltu	a3,a4,5218 <free+0x4a>
{
    5208:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    520a:	fed7fae3          	bgeu	a5,a3,51fe <free+0x30>
    520e:	6398                	ld	a4,0(a5)
    5210:	00e6e463          	bltu	a3,a4,5218 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5214:	fee7eae3          	bltu	a5,a4,5208 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    5218:	ff852583          	lw	a1,-8(a0)
    521c:	6390                	ld	a2,0(a5)
    521e:	02059813          	slli	a6,a1,0x20
    5222:	01c85713          	srli	a4,a6,0x1c
    5226:	9736                	add	a4,a4,a3
    5228:	fae60de3          	beq	a2,a4,51e2 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    522c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5230:	4790                	lw	a2,8(a5)
    5232:	02061593          	slli	a1,a2,0x20
    5236:	01c5d713          	srli	a4,a1,0x1c
    523a:	973e                	add	a4,a4,a5
    523c:	fae68ae3          	beq	a3,a4,51f0 <free+0x22>
    p->s.ptr = bp->s.ptr;
    5240:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    5242:	00004717          	auipc	a4,0x4
    5246:	24f73723          	sd	a5,590(a4) # 9490 <freep>
}
    524a:	6422                	ld	s0,8(sp)
    524c:	0141                	addi	sp,sp,16
    524e:	8082                	ret

0000000000005250 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5250:	7139                	addi	sp,sp,-64
    5252:	fc06                	sd	ra,56(sp)
    5254:	f822                	sd	s0,48(sp)
    5256:	f426                	sd	s1,40(sp)
    5258:	ec4e                	sd	s3,24(sp)
    525a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    525c:	02051493          	slli	s1,a0,0x20
    5260:	9081                	srli	s1,s1,0x20
    5262:	04bd                	addi	s1,s1,15
    5264:	8091                	srli	s1,s1,0x4
    5266:	0014899b          	addiw	s3,s1,1
    526a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    526c:	00004517          	auipc	a0,0x4
    5270:	22453503          	ld	a0,548(a0) # 9490 <freep>
    5274:	c915                	beqz	a0,52a8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5276:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5278:	4798                	lw	a4,8(a5)
    527a:	08977a63          	bgeu	a4,s1,530e <malloc+0xbe>
    527e:	f04a                	sd	s2,32(sp)
    5280:	e852                	sd	s4,16(sp)
    5282:	e456                	sd	s5,8(sp)
    5284:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    5286:	8a4e                	mv	s4,s3
    5288:	0009871b          	sext.w	a4,s3
    528c:	6685                	lui	a3,0x1
    528e:	00d77363          	bgeu	a4,a3,5294 <malloc+0x44>
    5292:	6a05                	lui	s4,0x1
    5294:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5298:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    529c:	00004917          	auipc	s2,0x4
    52a0:	1f490913          	addi	s2,s2,500 # 9490 <freep>
  if(p == SBRK_ERROR)
    52a4:	5afd                	li	s5,-1
    52a6:	a081                	j	52e6 <malloc+0x96>
    52a8:	f04a                	sd	s2,32(sp)
    52aa:	e852                	sd	s4,16(sp)
    52ac:	e456                	sd	s5,8(sp)
    52ae:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    52b0:	0000b797          	auipc	a5,0xb
    52b4:	a0878793          	addi	a5,a5,-1528 # fcb8 <base>
    52b8:	00004717          	auipc	a4,0x4
    52bc:	1cf73c23          	sd	a5,472(a4) # 9490 <freep>
    52c0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    52c2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    52c6:	b7c1                	j	5286 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    52c8:	6398                	ld	a4,0(a5)
    52ca:	e118                	sd	a4,0(a0)
    52cc:	a8a9                	j	5326 <malloc+0xd6>
  hp->s.size = nu;
    52ce:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    52d2:	0541                	addi	a0,a0,16
    52d4:	efbff0ef          	jal	51ce <free>
  return freep;
    52d8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    52dc:	c12d                	beqz	a0,533e <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    52de:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    52e0:	4798                	lw	a4,8(a5)
    52e2:	02977263          	bgeu	a4,s1,5306 <malloc+0xb6>
    if(p == freep)
    52e6:	00093703          	ld	a4,0(s2)
    52ea:	853e                	mv	a0,a5
    52ec:	fef719e3          	bne	a4,a5,52de <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    52f0:	8552                	mv	a0,s4
    52f2:	a4fff0ef          	jal	4d40 <sbrk>
  if(p == SBRK_ERROR)
    52f6:	fd551ce3          	bne	a0,s5,52ce <malloc+0x7e>
        return 0;
    52fa:	4501                	li	a0,0
    52fc:	7902                	ld	s2,32(sp)
    52fe:	6a42                	ld	s4,16(sp)
    5300:	6aa2                	ld	s5,8(sp)
    5302:	6b02                	ld	s6,0(sp)
    5304:	a03d                	j	5332 <malloc+0xe2>
    5306:	7902                	ld	s2,32(sp)
    5308:	6a42                	ld	s4,16(sp)
    530a:	6aa2                	ld	s5,8(sp)
    530c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    530e:	fae48de3          	beq	s1,a4,52c8 <malloc+0x78>
        p->s.size -= nunits;
    5312:	4137073b          	subw	a4,a4,s3
    5316:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5318:	02071693          	slli	a3,a4,0x20
    531c:	01c6d713          	srli	a4,a3,0x1c
    5320:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5322:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5326:	00004717          	auipc	a4,0x4
    532a:	16a73523          	sd	a0,362(a4) # 9490 <freep>
      return (void*)(p + 1);
    532e:	01078513          	addi	a0,a5,16
  }
}
    5332:	70e2                	ld	ra,56(sp)
    5334:	7442                	ld	s0,48(sp)
    5336:	74a2                	ld	s1,40(sp)
    5338:	69e2                	ld	s3,24(sp)
    533a:	6121                	addi	sp,sp,64
    533c:	8082                	ret
    533e:	7902                	ld	s2,32(sp)
    5340:	6a42                	ld	s4,16(sp)
    5342:	6aa2                	ld	s5,8(sp)
    5344:	6b02                	ld	s6,0(sp)
    5346:	b7f5                	j	5332 <malloc+0xe2>
