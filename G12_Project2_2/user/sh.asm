
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getcmd>:
  exit(0);
}

int
getcmd(char *buf, int nbuf)
{
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	e04a                	sd	s2,0(sp)
       a:	1000                	addi	s0,sp,32
       c:	84aa                	mv	s1,a0
       e:	892e                	mv	s2,a1
  write(2, "$ ", 2);
      10:	4609                	li	a2,2
      12:	00001597          	auipc	a1,0x1
      16:	1fe58593          	addi	a1,a1,510 # 1210 <malloc+0x106>
      1a:	4509                	li	a0,2
      1c:	433000ef          	jal	c4e <write>
  memset(buf, 0, nbuf);
      20:	864a                	mv	a2,s2
      22:	4581                	li	a1,0
      24:	8526                	mv	a0,s1
      26:	1f7000ef          	jal	a1c <memset>
  gets(buf, nbuf);
      2a:	85ca                	mv	a1,s2
      2c:	8526                	mv	a0,s1
      2e:	235000ef          	jal	a62 <gets>
  if(buf[0] == 0) // EOF
      32:	0004c503          	lbu	a0,0(s1)
      36:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
      3a:	40a00533          	neg	a0,a0
      3e:	60e2                	ld	ra,24(sp)
      40:	6442                	ld	s0,16(sp)
      42:	64a2                	ld	s1,8(sp)
      44:	6902                	ld	s2,0(sp)
      46:	6105                	addi	sp,sp,32
      48:	8082                	ret

000000000000004a <panic>:
  exit(0);
}

void
panic(char *s)
{
      4a:	1141                	addi	sp,sp,-16
      4c:	e406                	sd	ra,8(sp)
      4e:	e022                	sd	s0,0(sp)
      50:	0800                	addi	s0,sp,16
      52:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
      54:	00001597          	auipc	a1,0x1
      58:	1cc58593          	addi	a1,a1,460 # 1220 <malloc+0x116>
      5c:	4509                	li	a0,2
      5e:	7cf000ef          	jal	102c <fprintf>
  exit(1);
      62:	4505                	li	a0,1
      64:	3cb000ef          	jal	c2e <exit>

0000000000000068 <fork1>:
}

int
fork1(void)
{
      68:	1141                	addi	sp,sp,-16
      6a:	e406                	sd	ra,8(sp)
      6c:	e022                	sd	s0,0(sp)
      6e:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
      70:	3b7000ef          	jal	c26 <fork>
  if(pid == -1)
      74:	57fd                	li	a5,-1
      76:	00f50663          	beq	a0,a5,82 <fork1+0x1a>
    panic("fork");
  return pid;
}
      7a:	60a2                	ld	ra,8(sp)
      7c:	6402                	ld	s0,0(sp)
      7e:	0141                	addi	sp,sp,16
      80:	8082                	ret
    panic("fork");
      82:	00001517          	auipc	a0,0x1
      86:	1a650513          	addi	a0,a0,422 # 1228 <malloc+0x11e>
      8a:	fc1ff0ef          	jal	4a <panic>

000000000000008e <runcmd>:
{
      8e:	7179                	addi	sp,sp,-48
      90:	f406                	sd	ra,40(sp)
      92:	f022                	sd	s0,32(sp)
      94:	1800                	addi	s0,sp,48
  if(cmd == 0)
      96:	c115                	beqz	a0,ba <runcmd+0x2c>
      98:	ec26                	sd	s1,24(sp)
      9a:	84aa                	mv	s1,a0
  switch(cmd->type){
      9c:	4118                	lw	a4,0(a0)
      9e:	4795                	li	a5,5
      a0:	02e7e163          	bltu	a5,a4,c2 <runcmd+0x34>
      a4:	00056783          	lwu	a5,0(a0)
      a8:	078a                	slli	a5,a5,0x2
      aa:	00001717          	auipc	a4,0x1
      ae:	27e70713          	addi	a4,a4,638 # 1328 <malloc+0x21e>
      b2:	97ba                	add	a5,a5,a4
      b4:	439c                	lw	a5,0(a5)
      b6:	97ba                	add	a5,a5,a4
      b8:	8782                	jr	a5
      ba:	ec26                	sd	s1,24(sp)
    exit(1);
      bc:	4505                	li	a0,1
      be:	371000ef          	jal	c2e <exit>
    panic("runcmd");
      c2:	00001517          	auipc	a0,0x1
      c6:	16e50513          	addi	a0,a0,366 # 1230 <malloc+0x126>
      ca:	f81ff0ef          	jal	4a <panic>
    if(ecmd->argv[0] == 0)
      ce:	6508                	ld	a0,8(a0)
      d0:	c105                	beqz	a0,f0 <runcmd+0x62>
    exec(ecmd->argv[0], ecmd->argv);
      d2:	00848593          	addi	a1,s1,8
      d6:	391000ef          	jal	c66 <exec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
      da:	6490                	ld	a2,8(s1)
      dc:	00001597          	auipc	a1,0x1
      e0:	15c58593          	addi	a1,a1,348 # 1238 <malloc+0x12e>
      e4:	4509                	li	a0,2
      e6:	747000ef          	jal	102c <fprintf>
  exit(0);
      ea:	4501                	li	a0,0
      ec:	343000ef          	jal	c2e <exit>
      exit(1);
      f0:	4505                	li	a0,1
      f2:	33d000ef          	jal	c2e <exit>
    close(rcmd->fd);
      f6:	5148                	lw	a0,36(a0)
      f8:	35f000ef          	jal	c56 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
      fc:	508c                	lw	a1,32(s1)
      fe:	6888                	ld	a0,16(s1)
     100:	36f000ef          	jal	c6e <open>
     104:	00054563          	bltz	a0,10e <runcmd+0x80>
    runcmd(rcmd->cmd);
     108:	6488                	ld	a0,8(s1)
     10a:	f85ff0ef          	jal	8e <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     10e:	6890                	ld	a2,16(s1)
     110:	00001597          	auipc	a1,0x1
     114:	13858593          	addi	a1,a1,312 # 1248 <malloc+0x13e>
     118:	4509                	li	a0,2
     11a:	713000ef          	jal	102c <fprintf>
      exit(1);
     11e:	4505                	li	a0,1
     120:	30f000ef          	jal	c2e <exit>
    if(fork1() == 0)
     124:	f45ff0ef          	jal	68 <fork1>
     128:	e501                	bnez	a0,130 <runcmd+0xa2>
      runcmd(lcmd->left);
     12a:	6488                	ld	a0,8(s1)
     12c:	f63ff0ef          	jal	8e <runcmd>
    wait(0);
     130:	4501                	li	a0,0
     132:	305000ef          	jal	c36 <wait>
    runcmd(lcmd->right);
     136:	6888                	ld	a0,16(s1)
     138:	f57ff0ef          	jal	8e <runcmd>
    if(pipe(p) < 0)
     13c:	fd840513          	addi	a0,s0,-40
     140:	2ff000ef          	jal	c3e <pipe>
     144:	02054763          	bltz	a0,172 <runcmd+0xe4>
    if(fork1() == 0){
     148:	f21ff0ef          	jal	68 <fork1>
     14c:	e90d                	bnez	a0,17e <runcmd+0xf0>
      close(1);
     14e:	4505                	li	a0,1
     150:	307000ef          	jal	c56 <close>
      dup(p[1]);
     154:	fdc42503          	lw	a0,-36(s0)
     158:	34f000ef          	jal	ca6 <dup>
      close(p[0]);
     15c:	fd842503          	lw	a0,-40(s0)
     160:	2f7000ef          	jal	c56 <close>
      close(p[1]);
     164:	fdc42503          	lw	a0,-36(s0)
     168:	2ef000ef          	jal	c56 <close>
      runcmd(pcmd->left);
     16c:	6488                	ld	a0,8(s1)
     16e:	f21ff0ef          	jal	8e <runcmd>
      panic("pipe");
     172:	00001517          	auipc	a0,0x1
     176:	0e650513          	addi	a0,a0,230 # 1258 <malloc+0x14e>
     17a:	ed1ff0ef          	jal	4a <panic>
    if(fork1() == 0){
     17e:	eebff0ef          	jal	68 <fork1>
     182:	e115                	bnez	a0,1a6 <runcmd+0x118>
      close(0);
     184:	2d3000ef          	jal	c56 <close>
      dup(p[0]);
     188:	fd842503          	lw	a0,-40(s0)
     18c:	31b000ef          	jal	ca6 <dup>
      close(p[0]);
     190:	fd842503          	lw	a0,-40(s0)
     194:	2c3000ef          	jal	c56 <close>
      close(p[1]);
     198:	fdc42503          	lw	a0,-36(s0)
     19c:	2bb000ef          	jal	c56 <close>
      runcmd(pcmd->right);
     1a0:	6888                	ld	a0,16(s1)
     1a2:	eedff0ef          	jal	8e <runcmd>
    close(p[0]);
     1a6:	fd842503          	lw	a0,-40(s0)
     1aa:	2ad000ef          	jal	c56 <close>
    close(p[1]);
     1ae:	fdc42503          	lw	a0,-36(s0)
     1b2:	2a5000ef          	jal	c56 <close>
    wait(0);
     1b6:	4501                	li	a0,0
     1b8:	27f000ef          	jal	c36 <wait>
    wait(0);
     1bc:	4501                	li	a0,0
     1be:	279000ef          	jal	c36 <wait>
    break;
     1c2:	b725                	j	ea <runcmd+0x5c>
    if(fork1() == 0)
     1c4:	ea5ff0ef          	jal	68 <fork1>
     1c8:	f20511e3          	bnez	a0,ea <runcmd+0x5c>
      runcmd(bcmd->cmd);
     1cc:	6488                	ld	a0,8(s1)
     1ce:	ec1ff0ef          	jal	8e <runcmd>

00000000000001d2 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     1d2:	1101                	addi	sp,sp,-32
     1d4:	ec06                	sd	ra,24(sp)
     1d6:	e822                	sd	s0,16(sp)
     1d8:	e426                	sd	s1,8(sp)
     1da:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     1dc:	0a800513          	li	a0,168
     1e0:	72b000ef          	jal	110a <malloc>
     1e4:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     1e6:	0a800613          	li	a2,168
     1ea:	4581                	li	a1,0
     1ec:	031000ef          	jal	a1c <memset>
  cmd->type = EXEC;
     1f0:	4785                	li	a5,1
     1f2:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     1f4:	8526                	mv	a0,s1
     1f6:	60e2                	ld	ra,24(sp)
     1f8:	6442                	ld	s0,16(sp)
     1fa:	64a2                	ld	s1,8(sp)
     1fc:	6105                	addi	sp,sp,32
     1fe:	8082                	ret

0000000000000200 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     200:	7139                	addi	sp,sp,-64
     202:	fc06                	sd	ra,56(sp)
     204:	f822                	sd	s0,48(sp)
     206:	f426                	sd	s1,40(sp)
     208:	f04a                	sd	s2,32(sp)
     20a:	ec4e                	sd	s3,24(sp)
     20c:	e852                	sd	s4,16(sp)
     20e:	e456                	sd	s5,8(sp)
     210:	e05a                	sd	s6,0(sp)
     212:	0080                	addi	s0,sp,64
     214:	8b2a                	mv	s6,a0
     216:	8aae                	mv	s5,a1
     218:	8a32                	mv	s4,a2
     21a:	89b6                	mv	s3,a3
     21c:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     21e:	02800513          	li	a0,40
     222:	6e9000ef          	jal	110a <malloc>
     226:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     228:	02800613          	li	a2,40
     22c:	4581                	li	a1,0
     22e:	7ee000ef          	jal	a1c <memset>
  cmd->type = REDIR;
     232:	4789                	li	a5,2
     234:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     236:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     23a:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     23e:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     242:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     246:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     24a:	8526                	mv	a0,s1
     24c:	70e2                	ld	ra,56(sp)
     24e:	7442                	ld	s0,48(sp)
     250:	74a2                	ld	s1,40(sp)
     252:	7902                	ld	s2,32(sp)
     254:	69e2                	ld	s3,24(sp)
     256:	6a42                	ld	s4,16(sp)
     258:	6aa2                	ld	s5,8(sp)
     25a:	6b02                	ld	s6,0(sp)
     25c:	6121                	addi	sp,sp,64
     25e:	8082                	ret

0000000000000260 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     260:	7179                	addi	sp,sp,-48
     262:	f406                	sd	ra,40(sp)
     264:	f022                	sd	s0,32(sp)
     266:	ec26                	sd	s1,24(sp)
     268:	e84a                	sd	s2,16(sp)
     26a:	e44e                	sd	s3,8(sp)
     26c:	1800                	addi	s0,sp,48
     26e:	89aa                	mv	s3,a0
     270:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     272:	4561                	li	a0,24
     274:	697000ef          	jal	110a <malloc>
     278:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     27a:	4661                	li	a2,24
     27c:	4581                	li	a1,0
     27e:	79e000ef          	jal	a1c <memset>
  cmd->type = PIPE;
     282:	478d                	li	a5,3
     284:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     286:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     28a:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     28e:	8526                	mv	a0,s1
     290:	70a2                	ld	ra,40(sp)
     292:	7402                	ld	s0,32(sp)
     294:	64e2                	ld	s1,24(sp)
     296:	6942                	ld	s2,16(sp)
     298:	69a2                	ld	s3,8(sp)
     29a:	6145                	addi	sp,sp,48
     29c:	8082                	ret

000000000000029e <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     29e:	7179                	addi	sp,sp,-48
     2a0:	f406                	sd	ra,40(sp)
     2a2:	f022                	sd	s0,32(sp)
     2a4:	ec26                	sd	s1,24(sp)
     2a6:	e84a                	sd	s2,16(sp)
     2a8:	e44e                	sd	s3,8(sp)
     2aa:	1800                	addi	s0,sp,48
     2ac:	89aa                	mv	s3,a0
     2ae:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     2b0:	4561                	li	a0,24
     2b2:	659000ef          	jal	110a <malloc>
     2b6:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     2b8:	4661                	li	a2,24
     2ba:	4581                	li	a1,0
     2bc:	760000ef          	jal	a1c <memset>
  cmd->type = LIST;
     2c0:	4791                	li	a5,4
     2c2:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     2c4:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     2c8:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     2cc:	8526                	mv	a0,s1
     2ce:	70a2                	ld	ra,40(sp)
     2d0:	7402                	ld	s0,32(sp)
     2d2:	64e2                	ld	s1,24(sp)
     2d4:	6942                	ld	s2,16(sp)
     2d6:	69a2                	ld	s3,8(sp)
     2d8:	6145                	addi	sp,sp,48
     2da:	8082                	ret

00000000000002dc <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     2dc:	1101                	addi	sp,sp,-32
     2de:	ec06                	sd	ra,24(sp)
     2e0:	e822                	sd	s0,16(sp)
     2e2:	e426                	sd	s1,8(sp)
     2e4:	e04a                	sd	s2,0(sp)
     2e6:	1000                	addi	s0,sp,32
     2e8:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     2ea:	4541                	li	a0,16
     2ec:	61f000ef          	jal	110a <malloc>
     2f0:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     2f2:	4641                	li	a2,16
     2f4:	4581                	li	a1,0
     2f6:	726000ef          	jal	a1c <memset>
  cmd->type = BACK;
     2fa:	4795                	li	a5,5
     2fc:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     2fe:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     302:	8526                	mv	a0,s1
     304:	60e2                	ld	ra,24(sp)
     306:	6442                	ld	s0,16(sp)
     308:	64a2                	ld	s1,8(sp)
     30a:	6902                	ld	s2,0(sp)
     30c:	6105                	addi	sp,sp,32
     30e:	8082                	ret

0000000000000310 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     310:	7139                	addi	sp,sp,-64
     312:	fc06                	sd	ra,56(sp)
     314:	f822                	sd	s0,48(sp)
     316:	f426                	sd	s1,40(sp)
     318:	f04a                	sd	s2,32(sp)
     31a:	ec4e                	sd	s3,24(sp)
     31c:	e852                	sd	s4,16(sp)
     31e:	e456                	sd	s5,8(sp)
     320:	e05a                	sd	s6,0(sp)
     322:	0080                	addi	s0,sp,64
     324:	8a2a                	mv	s4,a0
     326:	892e                	mv	s2,a1
     328:	8ab2                	mv	s5,a2
     32a:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     32c:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     32e:	00002997          	auipc	s3,0x2
     332:	cda98993          	addi	s3,s3,-806 # 2008 <whitespace>
     336:	00b4fc63          	bgeu	s1,a1,34e <gettoken+0x3e>
     33a:	0004c583          	lbu	a1,0(s1)
     33e:	854e                	mv	a0,s3
     340:	6fe000ef          	jal	a3e <strchr>
     344:	c509                	beqz	a0,34e <gettoken+0x3e>
    s++;
     346:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     348:	fe9919e3          	bne	s2,s1,33a <gettoken+0x2a>
     34c:	84ca                	mv	s1,s2
  if(q)
     34e:	000a8463          	beqz	s5,356 <gettoken+0x46>
    *q = s;
     352:	009ab023          	sd	s1,0(s5)
  ret = *s;
     356:	0004c783          	lbu	a5,0(s1)
     35a:	00078a9b          	sext.w	s5,a5
  switch(*s){
     35e:	03c00713          	li	a4,60
     362:	06f76463          	bltu	a4,a5,3ca <gettoken+0xba>
     366:	03a00713          	li	a4,58
     36a:	00f76e63          	bltu	a4,a5,386 <gettoken+0x76>
     36e:	cf89                	beqz	a5,388 <gettoken+0x78>
     370:	02600713          	li	a4,38
     374:	00e78963          	beq	a5,a4,386 <gettoken+0x76>
     378:	fd87879b          	addiw	a5,a5,-40
     37c:	0ff7f793          	zext.b	a5,a5
     380:	4705                	li	a4,1
     382:	06f76b63          	bltu	a4,a5,3f8 <gettoken+0xe8>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     386:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     388:	000b0463          	beqz	s6,390 <gettoken+0x80>
    *eq = s;
     38c:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     390:	00002997          	auipc	s3,0x2
     394:	c7898993          	addi	s3,s3,-904 # 2008 <whitespace>
     398:	0124fc63          	bgeu	s1,s2,3b0 <gettoken+0xa0>
     39c:	0004c583          	lbu	a1,0(s1)
     3a0:	854e                	mv	a0,s3
     3a2:	69c000ef          	jal	a3e <strchr>
     3a6:	c509                	beqz	a0,3b0 <gettoken+0xa0>
    s++;
     3a8:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     3aa:	fe9919e3          	bne	s2,s1,39c <gettoken+0x8c>
     3ae:	84ca                	mv	s1,s2
  *ps = s;
     3b0:	009a3023          	sd	s1,0(s4)
  return ret;
}
     3b4:	8556                	mv	a0,s5
     3b6:	70e2                	ld	ra,56(sp)
     3b8:	7442                	ld	s0,48(sp)
     3ba:	74a2                	ld	s1,40(sp)
     3bc:	7902                	ld	s2,32(sp)
     3be:	69e2                	ld	s3,24(sp)
     3c0:	6a42                	ld	s4,16(sp)
     3c2:	6aa2                	ld	s5,8(sp)
     3c4:	6b02                	ld	s6,0(sp)
     3c6:	6121                	addi	sp,sp,64
     3c8:	8082                	ret
  switch(*s){
     3ca:	03e00713          	li	a4,62
     3ce:	02e79163          	bne	a5,a4,3f0 <gettoken+0xe0>
    s++;
     3d2:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     3d6:	0014c703          	lbu	a4,1(s1)
     3da:	03e00793          	li	a5,62
      s++;
     3de:	0489                	addi	s1,s1,2
      ret = '+';
     3e0:	02b00a93          	li	s5,43
    if(*s == '>'){
     3e4:	faf702e3          	beq	a4,a5,388 <gettoken+0x78>
    s++;
     3e8:	84b6                	mv	s1,a3
  ret = *s;
     3ea:	03e00a93          	li	s5,62
     3ee:	bf69                	j	388 <gettoken+0x78>
  switch(*s){
     3f0:	07c00713          	li	a4,124
     3f4:	f8e789e3          	beq	a5,a4,386 <gettoken+0x76>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     3f8:	00002997          	auipc	s3,0x2
     3fc:	c1098993          	addi	s3,s3,-1008 # 2008 <whitespace>
     400:	00002a97          	auipc	s5,0x2
     404:	c00a8a93          	addi	s5,s5,-1024 # 2000 <symbols>
     408:	0324fd63          	bgeu	s1,s2,442 <gettoken+0x132>
     40c:	0004c583          	lbu	a1,0(s1)
     410:	854e                	mv	a0,s3
     412:	62c000ef          	jal	a3e <strchr>
     416:	e11d                	bnez	a0,43c <gettoken+0x12c>
     418:	0004c583          	lbu	a1,0(s1)
     41c:	8556                	mv	a0,s5
     41e:	620000ef          	jal	a3e <strchr>
     422:	e911                	bnez	a0,436 <gettoken+0x126>
      s++;
     424:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     426:	fe9913e3          	bne	s2,s1,40c <gettoken+0xfc>
  if(eq)
     42a:	84ca                	mv	s1,s2
    ret = 'a';
     42c:	06100a93          	li	s5,97
  if(eq)
     430:	f40b1ee3          	bnez	s6,38c <gettoken+0x7c>
     434:	bfb5                	j	3b0 <gettoken+0xa0>
    ret = 'a';
     436:	06100a93          	li	s5,97
     43a:	b7b9                	j	388 <gettoken+0x78>
     43c:	06100a93          	li	s5,97
     440:	b7a1                	j	388 <gettoken+0x78>
     442:	06100a93          	li	s5,97
  if(eq)
     446:	f40b13e3          	bnez	s6,38c <gettoken+0x7c>
     44a:	b79d                	j	3b0 <gettoken+0xa0>

000000000000044c <peek>:

int
peek(char **ps, char *es, char *toks)
{
     44c:	7139                	addi	sp,sp,-64
     44e:	fc06                	sd	ra,56(sp)
     450:	f822                	sd	s0,48(sp)
     452:	f426                	sd	s1,40(sp)
     454:	f04a                	sd	s2,32(sp)
     456:	ec4e                	sd	s3,24(sp)
     458:	e852                	sd	s4,16(sp)
     45a:	e456                	sd	s5,8(sp)
     45c:	0080                	addi	s0,sp,64
     45e:	8a2a                	mv	s4,a0
     460:	892e                	mv	s2,a1
     462:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     464:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     466:	00002997          	auipc	s3,0x2
     46a:	ba298993          	addi	s3,s3,-1118 # 2008 <whitespace>
     46e:	00b4fc63          	bgeu	s1,a1,486 <peek+0x3a>
     472:	0004c583          	lbu	a1,0(s1)
     476:	854e                	mv	a0,s3
     478:	5c6000ef          	jal	a3e <strchr>
     47c:	c509                	beqz	a0,486 <peek+0x3a>
    s++;
     47e:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     480:	fe9919e3          	bne	s2,s1,472 <peek+0x26>
     484:	84ca                	mv	s1,s2
  *ps = s;
     486:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     48a:	0004c583          	lbu	a1,0(s1)
     48e:	4501                	li	a0,0
     490:	e991                	bnez	a1,4a4 <peek+0x58>
}
     492:	70e2                	ld	ra,56(sp)
     494:	7442                	ld	s0,48(sp)
     496:	74a2                	ld	s1,40(sp)
     498:	7902                	ld	s2,32(sp)
     49a:	69e2                	ld	s3,24(sp)
     49c:	6a42                	ld	s4,16(sp)
     49e:	6aa2                	ld	s5,8(sp)
     4a0:	6121                	addi	sp,sp,64
     4a2:	8082                	ret
  return *s && strchr(toks, *s);
     4a4:	8556                	mv	a0,s5
     4a6:	598000ef          	jal	a3e <strchr>
     4aa:	00a03533          	snez	a0,a0
     4ae:	b7d5                	j	492 <peek+0x46>

00000000000004b0 <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     4b0:	711d                	addi	sp,sp,-96
     4b2:	ec86                	sd	ra,88(sp)
     4b4:	e8a2                	sd	s0,80(sp)
     4b6:	e4a6                	sd	s1,72(sp)
     4b8:	e0ca                	sd	s2,64(sp)
     4ba:	fc4e                	sd	s3,56(sp)
     4bc:	f852                	sd	s4,48(sp)
     4be:	f456                	sd	s5,40(sp)
     4c0:	f05a                	sd	s6,32(sp)
     4c2:	ec5e                	sd	s7,24(sp)
     4c4:	1080                	addi	s0,sp,96
     4c6:	8a2a                	mv	s4,a0
     4c8:	89ae                	mv	s3,a1
     4ca:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     4cc:	00001a97          	auipc	s5,0x1
     4d0:	db4a8a93          	addi	s5,s5,-588 # 1280 <malloc+0x176>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     4d4:	06100b13          	li	s6,97
      panic("missing file for redirection");
    switch(tok){
     4d8:	03c00b93          	li	s7,60
  while(peek(ps, es, "<>")){
     4dc:	a00d                	j	4fe <parseredirs+0x4e>
      panic("missing file for redirection");
     4de:	00001517          	auipc	a0,0x1
     4e2:	d8250513          	addi	a0,a0,-638 # 1260 <malloc+0x156>
     4e6:	b65ff0ef          	jal	4a <panic>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     4ea:	4701                	li	a4,0
     4ec:	4681                	li	a3,0
     4ee:	fa043603          	ld	a2,-96(s0)
     4f2:	fa843583          	ld	a1,-88(s0)
     4f6:	8552                	mv	a0,s4
     4f8:	d09ff0ef          	jal	200 <redircmd>
     4fc:	8a2a                	mv	s4,a0
  while(peek(ps, es, "<>")){
     4fe:	8656                	mv	a2,s5
     500:	85ca                	mv	a1,s2
     502:	854e                	mv	a0,s3
     504:	f49ff0ef          	jal	44c <peek>
     508:	c525                	beqz	a0,570 <parseredirs+0xc0>
    tok = gettoken(ps, es, 0, 0);
     50a:	4681                	li	a3,0
     50c:	4601                	li	a2,0
     50e:	85ca                	mv	a1,s2
     510:	854e                	mv	a0,s3
     512:	dffff0ef          	jal	310 <gettoken>
     516:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     518:	fa040693          	addi	a3,s0,-96
     51c:	fa840613          	addi	a2,s0,-88
     520:	85ca                	mv	a1,s2
     522:	854e                	mv	a0,s3
     524:	dedff0ef          	jal	310 <gettoken>
     528:	fb651be3          	bne	a0,s6,4de <parseredirs+0x2e>
    switch(tok){
     52c:	fb748fe3          	beq	s1,s7,4ea <parseredirs+0x3a>
     530:	03e00793          	li	a5,62
     534:	02f48263          	beq	s1,a5,558 <parseredirs+0xa8>
     538:	02b00793          	li	a5,43
     53c:	fcf491e3          	bne	s1,a5,4fe <parseredirs+0x4e>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     540:	4705                	li	a4,1
     542:	20100693          	li	a3,513
     546:	fa043603          	ld	a2,-96(s0)
     54a:	fa843583          	ld	a1,-88(s0)
     54e:	8552                	mv	a0,s4
     550:	cb1ff0ef          	jal	200 <redircmd>
     554:	8a2a                	mv	s4,a0
      break;
     556:	b765                	j	4fe <parseredirs+0x4e>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     558:	4705                	li	a4,1
     55a:	60100693          	li	a3,1537
     55e:	fa043603          	ld	a2,-96(s0)
     562:	fa843583          	ld	a1,-88(s0)
     566:	8552                	mv	a0,s4
     568:	c99ff0ef          	jal	200 <redircmd>
     56c:	8a2a                	mv	s4,a0
      break;
     56e:	bf41                	j	4fe <parseredirs+0x4e>
    }
  }
  return cmd;
}
     570:	8552                	mv	a0,s4
     572:	60e6                	ld	ra,88(sp)
     574:	6446                	ld	s0,80(sp)
     576:	64a6                	ld	s1,72(sp)
     578:	6906                	ld	s2,64(sp)
     57a:	79e2                	ld	s3,56(sp)
     57c:	7a42                	ld	s4,48(sp)
     57e:	7aa2                	ld	s5,40(sp)
     580:	7b02                	ld	s6,32(sp)
     582:	6be2                	ld	s7,24(sp)
     584:	6125                	addi	sp,sp,96
     586:	8082                	ret

0000000000000588 <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     588:	7159                	addi	sp,sp,-112
     58a:	f486                	sd	ra,104(sp)
     58c:	f0a2                	sd	s0,96(sp)
     58e:	eca6                	sd	s1,88(sp)
     590:	e0d2                	sd	s4,64(sp)
     592:	fc56                	sd	s5,56(sp)
     594:	1880                	addi	s0,sp,112
     596:	8a2a                	mv	s4,a0
     598:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     59a:	00001617          	auipc	a2,0x1
     59e:	cee60613          	addi	a2,a2,-786 # 1288 <malloc+0x17e>
     5a2:	eabff0ef          	jal	44c <peek>
     5a6:	e915                	bnez	a0,5da <parseexec+0x52>
     5a8:	e8ca                	sd	s2,80(sp)
     5aa:	e4ce                	sd	s3,72(sp)
     5ac:	f85a                	sd	s6,48(sp)
     5ae:	f45e                	sd	s7,40(sp)
     5b0:	f062                	sd	s8,32(sp)
     5b2:	ec66                	sd	s9,24(sp)
     5b4:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     5b6:	c1dff0ef          	jal	1d2 <execcmd>
     5ba:	8c2a                	mv	s8,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     5bc:	8656                	mv	a2,s5
     5be:	85d2                	mv	a1,s4
     5c0:	ef1ff0ef          	jal	4b0 <parseredirs>
     5c4:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     5c6:	008c0913          	addi	s2,s8,8
     5ca:	00001b17          	auipc	s6,0x1
     5ce:	cdeb0b13          	addi	s6,s6,-802 # 12a8 <malloc+0x19e>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
     5d2:	06100c93          	li	s9,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     5d6:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     5d8:	a815                	j	60c <parseexec+0x84>
    return parseblock(ps, es);
     5da:	85d6                	mv	a1,s5
     5dc:	8552                	mv	a0,s4
     5de:	170000ef          	jal	74e <parseblock>
     5e2:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     5e4:	8526                	mv	a0,s1
     5e6:	70a6                	ld	ra,104(sp)
     5e8:	7406                	ld	s0,96(sp)
     5ea:	64e6                	ld	s1,88(sp)
     5ec:	6a06                	ld	s4,64(sp)
     5ee:	7ae2                	ld	s5,56(sp)
     5f0:	6165                	addi	sp,sp,112
     5f2:	8082                	ret
      panic("syntax");
     5f4:	00001517          	auipc	a0,0x1
     5f8:	c9c50513          	addi	a0,a0,-868 # 1290 <malloc+0x186>
     5fc:	a4fff0ef          	jal	4a <panic>
    ret = parseredirs(ret, ps, es);
     600:	8656                	mv	a2,s5
     602:	85d2                	mv	a1,s4
     604:	8526                	mv	a0,s1
     606:	eabff0ef          	jal	4b0 <parseredirs>
     60a:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     60c:	865a                	mv	a2,s6
     60e:	85d6                	mv	a1,s5
     610:	8552                	mv	a0,s4
     612:	e3bff0ef          	jal	44c <peek>
     616:	ed15                	bnez	a0,652 <parseexec+0xca>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     618:	f9040693          	addi	a3,s0,-112
     61c:	f9840613          	addi	a2,s0,-104
     620:	85d6                	mv	a1,s5
     622:	8552                	mv	a0,s4
     624:	cedff0ef          	jal	310 <gettoken>
     628:	c50d                	beqz	a0,652 <parseexec+0xca>
    if(tok != 'a')
     62a:	fd9515e3          	bne	a0,s9,5f4 <parseexec+0x6c>
    cmd->argv[argc] = q;
     62e:	f9843783          	ld	a5,-104(s0)
     632:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     636:	f9043783          	ld	a5,-112(s0)
     63a:	04f93823          	sd	a5,80(s2)
    argc++;
     63e:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     640:	0921                	addi	s2,s2,8
     642:	fb799fe3          	bne	s3,s7,600 <parseexec+0x78>
      panic("too many args");
     646:	00001517          	auipc	a0,0x1
     64a:	c5250513          	addi	a0,a0,-942 # 1298 <malloc+0x18e>
     64e:	9fdff0ef          	jal	4a <panic>
  cmd->argv[argc] = 0;
     652:	098e                	slli	s3,s3,0x3
     654:	9c4e                	add	s8,s8,s3
     656:	000c3423          	sd	zero,8(s8)
  cmd->eargv[argc] = 0;
     65a:	040c3c23          	sd	zero,88(s8)
     65e:	6946                	ld	s2,80(sp)
     660:	69a6                	ld	s3,72(sp)
     662:	7b42                	ld	s6,48(sp)
     664:	7ba2                	ld	s7,40(sp)
     666:	7c02                	ld	s8,32(sp)
     668:	6ce2                	ld	s9,24(sp)
  return ret;
     66a:	bfad                	j	5e4 <parseexec+0x5c>

000000000000066c <parsepipe>:
{
     66c:	7179                	addi	sp,sp,-48
     66e:	f406                	sd	ra,40(sp)
     670:	f022                	sd	s0,32(sp)
     672:	ec26                	sd	s1,24(sp)
     674:	e84a                	sd	s2,16(sp)
     676:	e44e                	sd	s3,8(sp)
     678:	1800                	addi	s0,sp,48
     67a:	892a                	mv	s2,a0
     67c:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     67e:	f0bff0ef          	jal	588 <parseexec>
     682:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     684:	00001617          	auipc	a2,0x1
     688:	c2c60613          	addi	a2,a2,-980 # 12b0 <malloc+0x1a6>
     68c:	85ce                	mv	a1,s3
     68e:	854a                	mv	a0,s2
     690:	dbdff0ef          	jal	44c <peek>
     694:	e909                	bnez	a0,6a6 <parsepipe+0x3a>
}
     696:	8526                	mv	a0,s1
     698:	70a2                	ld	ra,40(sp)
     69a:	7402                	ld	s0,32(sp)
     69c:	64e2                	ld	s1,24(sp)
     69e:	6942                	ld	s2,16(sp)
     6a0:	69a2                	ld	s3,8(sp)
     6a2:	6145                	addi	sp,sp,48
     6a4:	8082                	ret
    gettoken(ps, es, 0, 0);
     6a6:	4681                	li	a3,0
     6a8:	4601                	li	a2,0
     6aa:	85ce                	mv	a1,s3
     6ac:	854a                	mv	a0,s2
     6ae:	c63ff0ef          	jal	310 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     6b2:	85ce                	mv	a1,s3
     6b4:	854a                	mv	a0,s2
     6b6:	fb7ff0ef          	jal	66c <parsepipe>
     6ba:	85aa                	mv	a1,a0
     6bc:	8526                	mv	a0,s1
     6be:	ba3ff0ef          	jal	260 <pipecmd>
     6c2:	84aa                	mv	s1,a0
  return cmd;
     6c4:	bfc9                	j	696 <parsepipe+0x2a>

00000000000006c6 <parseline>:
{
     6c6:	7179                	addi	sp,sp,-48
     6c8:	f406                	sd	ra,40(sp)
     6ca:	f022                	sd	s0,32(sp)
     6cc:	ec26                	sd	s1,24(sp)
     6ce:	e84a                	sd	s2,16(sp)
     6d0:	e44e                	sd	s3,8(sp)
     6d2:	e052                	sd	s4,0(sp)
     6d4:	1800                	addi	s0,sp,48
     6d6:	892a                	mv	s2,a0
     6d8:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     6da:	f93ff0ef          	jal	66c <parsepipe>
     6de:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     6e0:	00001a17          	auipc	s4,0x1
     6e4:	bd8a0a13          	addi	s4,s4,-1064 # 12b8 <malloc+0x1ae>
     6e8:	a819                	j	6fe <parseline+0x38>
    gettoken(ps, es, 0, 0);
     6ea:	4681                	li	a3,0
     6ec:	4601                	li	a2,0
     6ee:	85ce                	mv	a1,s3
     6f0:	854a                	mv	a0,s2
     6f2:	c1fff0ef          	jal	310 <gettoken>
    cmd = backcmd(cmd);
     6f6:	8526                	mv	a0,s1
     6f8:	be5ff0ef          	jal	2dc <backcmd>
     6fc:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     6fe:	8652                	mv	a2,s4
     700:	85ce                	mv	a1,s3
     702:	854a                	mv	a0,s2
     704:	d49ff0ef          	jal	44c <peek>
     708:	f16d                	bnez	a0,6ea <parseline+0x24>
  if(peek(ps, es, ";")){
     70a:	00001617          	auipc	a2,0x1
     70e:	bb660613          	addi	a2,a2,-1098 # 12c0 <malloc+0x1b6>
     712:	85ce                	mv	a1,s3
     714:	854a                	mv	a0,s2
     716:	d37ff0ef          	jal	44c <peek>
     71a:	e911                	bnez	a0,72e <parseline+0x68>
}
     71c:	8526                	mv	a0,s1
     71e:	70a2                	ld	ra,40(sp)
     720:	7402                	ld	s0,32(sp)
     722:	64e2                	ld	s1,24(sp)
     724:	6942                	ld	s2,16(sp)
     726:	69a2                	ld	s3,8(sp)
     728:	6a02                	ld	s4,0(sp)
     72a:	6145                	addi	sp,sp,48
     72c:	8082                	ret
    gettoken(ps, es, 0, 0);
     72e:	4681                	li	a3,0
     730:	4601                	li	a2,0
     732:	85ce                	mv	a1,s3
     734:	854a                	mv	a0,s2
     736:	bdbff0ef          	jal	310 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     73a:	85ce                	mv	a1,s3
     73c:	854a                	mv	a0,s2
     73e:	f89ff0ef          	jal	6c6 <parseline>
     742:	85aa                	mv	a1,a0
     744:	8526                	mv	a0,s1
     746:	b59ff0ef          	jal	29e <listcmd>
     74a:	84aa                	mv	s1,a0
  return cmd;
     74c:	bfc1                	j	71c <parseline+0x56>

000000000000074e <parseblock>:
{
     74e:	7179                	addi	sp,sp,-48
     750:	f406                	sd	ra,40(sp)
     752:	f022                	sd	s0,32(sp)
     754:	ec26                	sd	s1,24(sp)
     756:	e84a                	sd	s2,16(sp)
     758:	e44e                	sd	s3,8(sp)
     75a:	1800                	addi	s0,sp,48
     75c:	84aa                	mv	s1,a0
     75e:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     760:	00001617          	auipc	a2,0x1
     764:	b2860613          	addi	a2,a2,-1240 # 1288 <malloc+0x17e>
     768:	ce5ff0ef          	jal	44c <peek>
     76c:	c539                	beqz	a0,7ba <parseblock+0x6c>
  gettoken(ps, es, 0, 0);
     76e:	4681                	li	a3,0
     770:	4601                	li	a2,0
     772:	85ca                	mv	a1,s2
     774:	8526                	mv	a0,s1
     776:	b9bff0ef          	jal	310 <gettoken>
  cmd = parseline(ps, es);
     77a:	85ca                	mv	a1,s2
     77c:	8526                	mv	a0,s1
     77e:	f49ff0ef          	jal	6c6 <parseline>
     782:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     784:	00001617          	auipc	a2,0x1
     788:	b5460613          	addi	a2,a2,-1196 # 12d8 <malloc+0x1ce>
     78c:	85ca                	mv	a1,s2
     78e:	8526                	mv	a0,s1
     790:	cbdff0ef          	jal	44c <peek>
     794:	c90d                	beqz	a0,7c6 <parseblock+0x78>
  gettoken(ps, es, 0, 0);
     796:	4681                	li	a3,0
     798:	4601                	li	a2,0
     79a:	85ca                	mv	a1,s2
     79c:	8526                	mv	a0,s1
     79e:	b73ff0ef          	jal	310 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     7a2:	864a                	mv	a2,s2
     7a4:	85a6                	mv	a1,s1
     7a6:	854e                	mv	a0,s3
     7a8:	d09ff0ef          	jal	4b0 <parseredirs>
}
     7ac:	70a2                	ld	ra,40(sp)
     7ae:	7402                	ld	s0,32(sp)
     7b0:	64e2                	ld	s1,24(sp)
     7b2:	6942                	ld	s2,16(sp)
     7b4:	69a2                	ld	s3,8(sp)
     7b6:	6145                	addi	sp,sp,48
     7b8:	8082                	ret
    panic("parseblock");
     7ba:	00001517          	auipc	a0,0x1
     7be:	b0e50513          	addi	a0,a0,-1266 # 12c8 <malloc+0x1be>
     7c2:	889ff0ef          	jal	4a <panic>
    panic("syntax - missing )");
     7c6:	00001517          	auipc	a0,0x1
     7ca:	b1a50513          	addi	a0,a0,-1254 # 12e0 <malloc+0x1d6>
     7ce:	87dff0ef          	jal	4a <panic>

00000000000007d2 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     7d2:	1101                	addi	sp,sp,-32
     7d4:	ec06                	sd	ra,24(sp)
     7d6:	e822                	sd	s0,16(sp)
     7d8:	e426                	sd	s1,8(sp)
     7da:	1000                	addi	s0,sp,32
     7dc:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     7de:	c131                	beqz	a0,822 <nulterminate+0x50>
    return 0;

  switch(cmd->type){
     7e0:	4118                	lw	a4,0(a0)
     7e2:	4795                	li	a5,5
     7e4:	02e7ef63          	bltu	a5,a4,822 <nulterminate+0x50>
     7e8:	00056783          	lwu	a5,0(a0)
     7ec:	078a                	slli	a5,a5,0x2
     7ee:	00001717          	auipc	a4,0x1
     7f2:	b5270713          	addi	a4,a4,-1198 # 1340 <malloc+0x236>
     7f6:	97ba                	add	a5,a5,a4
     7f8:	439c                	lw	a5,0(a5)
     7fa:	97ba                	add	a5,a5,a4
     7fc:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     7fe:	651c                	ld	a5,8(a0)
     800:	c38d                	beqz	a5,822 <nulterminate+0x50>
     802:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     806:	67b8                	ld	a4,72(a5)
     808:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     80c:	07a1                	addi	a5,a5,8
     80e:	ff87b703          	ld	a4,-8(a5)
     812:	fb75                	bnez	a4,806 <nulterminate+0x34>
     814:	a039                	j	822 <nulterminate+0x50>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     816:	6508                	ld	a0,8(a0)
     818:	fbbff0ef          	jal	7d2 <nulterminate>
    *rcmd->efile = 0;
     81c:	6c9c                	ld	a5,24(s1)
     81e:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     822:	8526                	mv	a0,s1
     824:	60e2                	ld	ra,24(sp)
     826:	6442                	ld	s0,16(sp)
     828:	64a2                	ld	s1,8(sp)
     82a:	6105                	addi	sp,sp,32
     82c:	8082                	ret
    nulterminate(pcmd->left);
     82e:	6508                	ld	a0,8(a0)
     830:	fa3ff0ef          	jal	7d2 <nulterminate>
    nulterminate(pcmd->right);
     834:	6888                	ld	a0,16(s1)
     836:	f9dff0ef          	jal	7d2 <nulterminate>
    break;
     83a:	b7e5                	j	822 <nulterminate+0x50>
    nulterminate(lcmd->left);
     83c:	6508                	ld	a0,8(a0)
     83e:	f95ff0ef          	jal	7d2 <nulterminate>
    nulterminate(lcmd->right);
     842:	6888                	ld	a0,16(s1)
     844:	f8fff0ef          	jal	7d2 <nulterminate>
    break;
     848:	bfe9                	j	822 <nulterminate+0x50>
    nulterminate(bcmd->cmd);
     84a:	6508                	ld	a0,8(a0)
     84c:	f87ff0ef          	jal	7d2 <nulterminate>
    break;
     850:	bfc9                	j	822 <nulterminate+0x50>

0000000000000852 <parsecmd>:
{
     852:	7179                	addi	sp,sp,-48
     854:	f406                	sd	ra,40(sp)
     856:	f022                	sd	s0,32(sp)
     858:	ec26                	sd	s1,24(sp)
     85a:	e84a                	sd	s2,16(sp)
     85c:	1800                	addi	s0,sp,48
     85e:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     862:	84aa                	mv	s1,a0
     864:	18e000ef          	jal	9f2 <strlen>
     868:	1502                	slli	a0,a0,0x20
     86a:	9101                	srli	a0,a0,0x20
     86c:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     86e:	85a6                	mv	a1,s1
     870:	fd840513          	addi	a0,s0,-40
     874:	e53ff0ef          	jal	6c6 <parseline>
     878:	892a                	mv	s2,a0
  peek(&s, es, "");
     87a:	00001617          	auipc	a2,0x1
     87e:	99e60613          	addi	a2,a2,-1634 # 1218 <malloc+0x10e>
     882:	85a6                	mv	a1,s1
     884:	fd840513          	addi	a0,s0,-40
     888:	bc5ff0ef          	jal	44c <peek>
  if(s != es){
     88c:	fd843603          	ld	a2,-40(s0)
     890:	00961c63          	bne	a2,s1,8a8 <parsecmd+0x56>
  nulterminate(cmd);
     894:	854a                	mv	a0,s2
     896:	f3dff0ef          	jal	7d2 <nulterminate>
}
     89a:	854a                	mv	a0,s2
     89c:	70a2                	ld	ra,40(sp)
     89e:	7402                	ld	s0,32(sp)
     8a0:	64e2                	ld	s1,24(sp)
     8a2:	6942                	ld	s2,16(sp)
     8a4:	6145                	addi	sp,sp,48
     8a6:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     8a8:	00001597          	auipc	a1,0x1
     8ac:	a5058593          	addi	a1,a1,-1456 # 12f8 <malloc+0x1ee>
     8b0:	4509                	li	a0,2
     8b2:	77a000ef          	jal	102c <fprintf>
    panic("syntax");
     8b6:	00001517          	auipc	a0,0x1
     8ba:	9da50513          	addi	a0,a0,-1574 # 1290 <malloc+0x186>
     8be:	f8cff0ef          	jal	4a <panic>

00000000000008c2 <main>:
{
     8c2:	7139                	addi	sp,sp,-64
     8c4:	fc06                	sd	ra,56(sp)
     8c6:	f822                	sd	s0,48(sp)
     8c8:	f426                	sd	s1,40(sp)
     8ca:	f04a                	sd	s2,32(sp)
     8cc:	ec4e                	sd	s3,24(sp)
     8ce:	e852                	sd	s4,16(sp)
     8d0:	e456                	sd	s5,8(sp)
     8d2:	e05a                	sd	s6,0(sp)
     8d4:	0080                	addi	s0,sp,64
  while((fd = open("console", O_RDWR)) >= 0){
     8d6:	00001497          	auipc	s1,0x1
     8da:	a3248493          	addi	s1,s1,-1486 # 1308 <malloc+0x1fe>
     8de:	4589                	li	a1,2
     8e0:	8526                	mv	a0,s1
     8e2:	38c000ef          	jal	c6e <open>
     8e6:	00054763          	bltz	a0,8f4 <main+0x32>
    if(fd >= 3){
     8ea:	4789                	li	a5,2
     8ec:	fea7d9e3          	bge	a5,a0,8de <main+0x1c>
      close(fd);
     8f0:	366000ef          	jal	c56 <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     8f4:	00001a17          	auipc	s4,0x1
     8f8:	72ca0a13          	addi	s4,s4,1836 # 2020 <buf.0>
    while (*cmd == ' ' || *cmd == '\t')
     8fc:	02000913          	li	s2,32
     900:	49a5                	li	s3,9
    if (*cmd == '\n') // is a blank command
     902:	4aa9                	li	s5,10
    if(cmd[0] == 'c' && cmd[1] == 'd' && cmd[2] == ' '){
     904:	06300b13          	li	s6,99
     908:	a805                	j	938 <main+0x76>
      cmd++;
     90a:	0485                	addi	s1,s1,1
    while (*cmd == ' ' || *cmd == '\t')
     90c:	0004c783          	lbu	a5,0(s1)
     910:	ff278de3          	beq	a5,s2,90a <main+0x48>
     914:	ff378be3          	beq	a5,s3,90a <main+0x48>
    if (*cmd == '\n') // is a blank command
     918:	03578063          	beq	a5,s5,938 <main+0x76>
    if(cmd[0] == 'c' && cmd[1] == 'd' && cmd[2] == ' '){
     91c:	01679863          	bne	a5,s6,92c <main+0x6a>
     920:	0014c703          	lbu	a4,1(s1)
     924:	06400793          	li	a5,100
     928:	02f70463          	beq	a4,a5,950 <main+0x8e>
      if(fork1() == 0)
     92c:	f3cff0ef          	jal	68 <fork1>
     930:	cd29                	beqz	a0,98a <main+0xc8>
      wait(0);
     932:	4501                	li	a0,0
     934:	302000ef          	jal	c36 <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     938:	06400593          	li	a1,100
     93c:	8552                	mv	a0,s4
     93e:	ec2ff0ef          	jal	0 <getcmd>
     942:	04054963          	bltz	a0,994 <main+0xd2>
    char *cmd = buf;
     946:	00001497          	auipc	s1,0x1
     94a:	6da48493          	addi	s1,s1,1754 # 2020 <buf.0>
     94e:	bf7d                	j	90c <main+0x4a>
    if(cmd[0] == 'c' && cmd[1] == 'd' && cmd[2] == ' '){
     950:	0024c783          	lbu	a5,2(s1)
     954:	fd279ce3          	bne	a5,s2,92c <main+0x6a>
      cmd[strlen(cmd)-1] = 0;  // chop \n
     958:	8526                	mv	a0,s1
     95a:	098000ef          	jal	9f2 <strlen>
     95e:	fff5079b          	addiw	a5,a0,-1
     962:	1782                	slli	a5,a5,0x20
     964:	9381                	srli	a5,a5,0x20
     966:	97a6                	add	a5,a5,s1
     968:	00078023          	sb	zero,0(a5)
      if(chdir(cmd+3) < 0)
     96c:	048d                	addi	s1,s1,3
     96e:	8526                	mv	a0,s1
     970:	32e000ef          	jal	c9e <chdir>
     974:	fc0552e3          	bgez	a0,938 <main+0x76>
        fprintf(2, "cannot cd %s\n", cmd+3);
     978:	8626                	mv	a2,s1
     97a:	00001597          	auipc	a1,0x1
     97e:	99658593          	addi	a1,a1,-1642 # 1310 <malloc+0x206>
     982:	4509                	li	a0,2
     984:	6a8000ef          	jal	102c <fprintf>
     988:	bf45                	j	938 <main+0x76>
        runcmd(parsecmd(cmd));
     98a:	8526                	mv	a0,s1
     98c:	ec7ff0ef          	jal	852 <parsecmd>
     990:	efeff0ef          	jal	8e <runcmd>
  exit(0);
     994:	4501                	li	a0,0
     996:	298000ef          	jal	c2e <exit>

000000000000099a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
     99a:	1141                	addi	sp,sp,-16
     99c:	e406                	sd	ra,8(sp)
     99e:	e022                	sd	s0,0(sp)
     9a0:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     9a2:	f21ff0ef          	jal	8c2 <main>
  exit(r);
     9a6:	288000ef          	jal	c2e <exit>

00000000000009aa <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     9aa:	1141                	addi	sp,sp,-16
     9ac:	e422                	sd	s0,8(sp)
     9ae:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     9b0:	87aa                	mv	a5,a0
     9b2:	0585                	addi	a1,a1,1
     9b4:	0785                	addi	a5,a5,1
     9b6:	fff5c703          	lbu	a4,-1(a1)
     9ba:	fee78fa3          	sb	a4,-1(a5)
     9be:	fb75                	bnez	a4,9b2 <strcpy+0x8>
    ;
  return os;
}
     9c0:	6422                	ld	s0,8(sp)
     9c2:	0141                	addi	sp,sp,16
     9c4:	8082                	ret

00000000000009c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     9c6:	1141                	addi	sp,sp,-16
     9c8:	e422                	sd	s0,8(sp)
     9ca:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     9cc:	00054783          	lbu	a5,0(a0)
     9d0:	cb91                	beqz	a5,9e4 <strcmp+0x1e>
     9d2:	0005c703          	lbu	a4,0(a1)
     9d6:	00f71763          	bne	a4,a5,9e4 <strcmp+0x1e>
    p++, q++;
     9da:	0505                	addi	a0,a0,1
     9dc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     9de:	00054783          	lbu	a5,0(a0)
     9e2:	fbe5                	bnez	a5,9d2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     9e4:	0005c503          	lbu	a0,0(a1)
}
     9e8:	40a7853b          	subw	a0,a5,a0
     9ec:	6422                	ld	s0,8(sp)
     9ee:	0141                	addi	sp,sp,16
     9f0:	8082                	ret

00000000000009f2 <strlen>:

uint
strlen(const char *s)
{
     9f2:	1141                	addi	sp,sp,-16
     9f4:	e422                	sd	s0,8(sp)
     9f6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     9f8:	00054783          	lbu	a5,0(a0)
     9fc:	cf91                	beqz	a5,a18 <strlen+0x26>
     9fe:	0505                	addi	a0,a0,1
     a00:	87aa                	mv	a5,a0
     a02:	86be                	mv	a3,a5
     a04:	0785                	addi	a5,a5,1
     a06:	fff7c703          	lbu	a4,-1(a5)
     a0a:	ff65                	bnez	a4,a02 <strlen+0x10>
     a0c:	40a6853b          	subw	a0,a3,a0
     a10:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     a12:	6422                	ld	s0,8(sp)
     a14:	0141                	addi	sp,sp,16
     a16:	8082                	ret
  for(n = 0; s[n]; n++)
     a18:	4501                	li	a0,0
     a1a:	bfe5                	j	a12 <strlen+0x20>

0000000000000a1c <memset>:

void*
memset(void *dst, int c, uint n)
{
     a1c:	1141                	addi	sp,sp,-16
     a1e:	e422                	sd	s0,8(sp)
     a20:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     a22:	ca19                	beqz	a2,a38 <memset+0x1c>
     a24:	87aa                	mv	a5,a0
     a26:	1602                	slli	a2,a2,0x20
     a28:	9201                	srli	a2,a2,0x20
     a2a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     a2e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     a32:	0785                	addi	a5,a5,1
     a34:	fee79de3          	bne	a5,a4,a2e <memset+0x12>
  }
  return dst;
}
     a38:	6422                	ld	s0,8(sp)
     a3a:	0141                	addi	sp,sp,16
     a3c:	8082                	ret

0000000000000a3e <strchr>:

char*
strchr(const char *s, char c)
{
     a3e:	1141                	addi	sp,sp,-16
     a40:	e422                	sd	s0,8(sp)
     a42:	0800                	addi	s0,sp,16
  for(; *s; s++)
     a44:	00054783          	lbu	a5,0(a0)
     a48:	cb99                	beqz	a5,a5e <strchr+0x20>
    if(*s == c)
     a4a:	00f58763          	beq	a1,a5,a58 <strchr+0x1a>
  for(; *s; s++)
     a4e:	0505                	addi	a0,a0,1
     a50:	00054783          	lbu	a5,0(a0)
     a54:	fbfd                	bnez	a5,a4a <strchr+0xc>
      return (char*)s;
  return 0;
     a56:	4501                	li	a0,0
}
     a58:	6422                	ld	s0,8(sp)
     a5a:	0141                	addi	sp,sp,16
     a5c:	8082                	ret
  return 0;
     a5e:	4501                	li	a0,0
     a60:	bfe5                	j	a58 <strchr+0x1a>

0000000000000a62 <gets>:

char*
gets(char *buf, int max)
{
     a62:	711d                	addi	sp,sp,-96
     a64:	ec86                	sd	ra,88(sp)
     a66:	e8a2                	sd	s0,80(sp)
     a68:	e4a6                	sd	s1,72(sp)
     a6a:	e0ca                	sd	s2,64(sp)
     a6c:	fc4e                	sd	s3,56(sp)
     a6e:	f852                	sd	s4,48(sp)
     a70:	f456                	sd	s5,40(sp)
     a72:	f05a                	sd	s6,32(sp)
     a74:	ec5e                	sd	s7,24(sp)
     a76:	1080                	addi	s0,sp,96
     a78:	8baa                	mv	s7,a0
     a7a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     a7c:	892a                	mv	s2,a0
     a7e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     a80:	4aa9                	li	s5,10
     a82:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     a84:	89a6                	mv	s3,s1
     a86:	2485                	addiw	s1,s1,1
     a88:	0344d663          	bge	s1,s4,ab4 <gets+0x52>
    cc = read(0, &c, 1);
     a8c:	4605                	li	a2,1
     a8e:	faf40593          	addi	a1,s0,-81
     a92:	4501                	li	a0,0
     a94:	1b2000ef          	jal	c46 <read>
    if(cc < 1)
     a98:	00a05e63          	blez	a0,ab4 <gets+0x52>
    buf[i++] = c;
     a9c:	faf44783          	lbu	a5,-81(s0)
     aa0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     aa4:	01578763          	beq	a5,s5,ab2 <gets+0x50>
     aa8:	0905                	addi	s2,s2,1
     aaa:	fd679de3          	bne	a5,s6,a84 <gets+0x22>
    buf[i++] = c;
     aae:	89a6                	mv	s3,s1
     ab0:	a011                	j	ab4 <gets+0x52>
     ab2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     ab4:	99de                	add	s3,s3,s7
     ab6:	00098023          	sb	zero,0(s3)
  return buf;
}
     aba:	855e                	mv	a0,s7
     abc:	60e6                	ld	ra,88(sp)
     abe:	6446                	ld	s0,80(sp)
     ac0:	64a6                	ld	s1,72(sp)
     ac2:	6906                	ld	s2,64(sp)
     ac4:	79e2                	ld	s3,56(sp)
     ac6:	7a42                	ld	s4,48(sp)
     ac8:	7aa2                	ld	s5,40(sp)
     aca:	7b02                	ld	s6,32(sp)
     acc:	6be2                	ld	s7,24(sp)
     ace:	6125                	addi	sp,sp,96
     ad0:	8082                	ret

0000000000000ad2 <stat>:

int
stat(const char *n, struct stat *st)
{
     ad2:	1101                	addi	sp,sp,-32
     ad4:	ec06                	sd	ra,24(sp)
     ad6:	e822                	sd	s0,16(sp)
     ad8:	e04a                	sd	s2,0(sp)
     ada:	1000                	addi	s0,sp,32
     adc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     ade:	4581                	li	a1,0
     ae0:	18e000ef          	jal	c6e <open>
  if(fd < 0)
     ae4:	02054263          	bltz	a0,b08 <stat+0x36>
     ae8:	e426                	sd	s1,8(sp)
     aea:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     aec:	85ca                	mv	a1,s2
     aee:	198000ef          	jal	c86 <fstat>
     af2:	892a                	mv	s2,a0
  close(fd);
     af4:	8526                	mv	a0,s1
     af6:	160000ef          	jal	c56 <close>
  return r;
     afa:	64a2                	ld	s1,8(sp)
}
     afc:	854a                	mv	a0,s2
     afe:	60e2                	ld	ra,24(sp)
     b00:	6442                	ld	s0,16(sp)
     b02:	6902                	ld	s2,0(sp)
     b04:	6105                	addi	sp,sp,32
     b06:	8082                	ret
    return -1;
     b08:	597d                	li	s2,-1
     b0a:	bfcd                	j	afc <stat+0x2a>

0000000000000b0c <atoi>:

int
atoi(const char *s)
{
     b0c:	1141                	addi	sp,sp,-16
     b0e:	e422                	sd	s0,8(sp)
     b10:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     b12:	00054683          	lbu	a3,0(a0)
     b16:	fd06879b          	addiw	a5,a3,-48
     b1a:	0ff7f793          	zext.b	a5,a5
     b1e:	4625                	li	a2,9
     b20:	02f66863          	bltu	a2,a5,b50 <atoi+0x44>
     b24:	872a                	mv	a4,a0
  n = 0;
     b26:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     b28:	0705                	addi	a4,a4,1
     b2a:	0025179b          	slliw	a5,a0,0x2
     b2e:	9fa9                	addw	a5,a5,a0
     b30:	0017979b          	slliw	a5,a5,0x1
     b34:	9fb5                	addw	a5,a5,a3
     b36:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     b3a:	00074683          	lbu	a3,0(a4)
     b3e:	fd06879b          	addiw	a5,a3,-48
     b42:	0ff7f793          	zext.b	a5,a5
     b46:	fef671e3          	bgeu	a2,a5,b28 <atoi+0x1c>
  return n;
}
     b4a:	6422                	ld	s0,8(sp)
     b4c:	0141                	addi	sp,sp,16
     b4e:	8082                	ret
  n = 0;
     b50:	4501                	li	a0,0
     b52:	bfe5                	j	b4a <atoi+0x3e>

0000000000000b54 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     b54:	1141                	addi	sp,sp,-16
     b56:	e422                	sd	s0,8(sp)
     b58:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     b5a:	02b57463          	bgeu	a0,a1,b82 <memmove+0x2e>
    while(n-- > 0)
     b5e:	00c05f63          	blez	a2,b7c <memmove+0x28>
     b62:	1602                	slli	a2,a2,0x20
     b64:	9201                	srli	a2,a2,0x20
     b66:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     b6a:	872a                	mv	a4,a0
      *dst++ = *src++;
     b6c:	0585                	addi	a1,a1,1
     b6e:	0705                	addi	a4,a4,1
     b70:	fff5c683          	lbu	a3,-1(a1)
     b74:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     b78:	fef71ae3          	bne	a4,a5,b6c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     b7c:	6422                	ld	s0,8(sp)
     b7e:	0141                	addi	sp,sp,16
     b80:	8082                	ret
    dst += n;
     b82:	00c50733          	add	a4,a0,a2
    src += n;
     b86:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     b88:	fec05ae3          	blez	a2,b7c <memmove+0x28>
     b8c:	fff6079b          	addiw	a5,a2,-1
     b90:	1782                	slli	a5,a5,0x20
     b92:	9381                	srli	a5,a5,0x20
     b94:	fff7c793          	not	a5,a5
     b98:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     b9a:	15fd                	addi	a1,a1,-1
     b9c:	177d                	addi	a4,a4,-1
     b9e:	0005c683          	lbu	a3,0(a1)
     ba2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     ba6:	fee79ae3          	bne	a5,a4,b9a <memmove+0x46>
     baa:	bfc9                	j	b7c <memmove+0x28>

0000000000000bac <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     bac:	1141                	addi	sp,sp,-16
     bae:	e422                	sd	s0,8(sp)
     bb0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     bb2:	ca05                	beqz	a2,be2 <memcmp+0x36>
     bb4:	fff6069b          	addiw	a3,a2,-1
     bb8:	1682                	slli	a3,a3,0x20
     bba:	9281                	srli	a3,a3,0x20
     bbc:	0685                	addi	a3,a3,1
     bbe:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     bc0:	00054783          	lbu	a5,0(a0)
     bc4:	0005c703          	lbu	a4,0(a1)
     bc8:	00e79863          	bne	a5,a4,bd8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     bcc:	0505                	addi	a0,a0,1
    p2++;
     bce:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     bd0:	fed518e3          	bne	a0,a3,bc0 <memcmp+0x14>
  }
  return 0;
     bd4:	4501                	li	a0,0
     bd6:	a019                	j	bdc <memcmp+0x30>
      return *p1 - *p2;
     bd8:	40e7853b          	subw	a0,a5,a4
}
     bdc:	6422                	ld	s0,8(sp)
     bde:	0141                	addi	sp,sp,16
     be0:	8082                	ret
  return 0;
     be2:	4501                	li	a0,0
     be4:	bfe5                	j	bdc <memcmp+0x30>

0000000000000be6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     be6:	1141                	addi	sp,sp,-16
     be8:	e406                	sd	ra,8(sp)
     bea:	e022                	sd	s0,0(sp)
     bec:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     bee:	f67ff0ef          	jal	b54 <memmove>
}
     bf2:	60a2                	ld	ra,8(sp)
     bf4:	6402                	ld	s0,0(sp)
     bf6:	0141                	addi	sp,sp,16
     bf8:	8082                	ret

0000000000000bfa <sbrk>:

char *
sbrk(int n) {
     bfa:	1141                	addi	sp,sp,-16
     bfc:	e406                	sd	ra,8(sp)
     bfe:	e022                	sd	s0,0(sp)
     c00:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
     c02:	4585                	li	a1,1
     c04:	0b2000ef          	jal	cb6 <sys_sbrk>
}
     c08:	60a2                	ld	ra,8(sp)
     c0a:	6402                	ld	s0,0(sp)
     c0c:	0141                	addi	sp,sp,16
     c0e:	8082                	ret

0000000000000c10 <sbrklazy>:

char *
sbrklazy(int n) {
     c10:	1141                	addi	sp,sp,-16
     c12:	e406                	sd	ra,8(sp)
     c14:	e022                	sd	s0,0(sp)
     c16:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
     c18:	4589                	li	a1,2
     c1a:	09c000ef          	jal	cb6 <sys_sbrk>
}
     c1e:	60a2                	ld	ra,8(sp)
     c20:	6402                	ld	s0,0(sp)
     c22:	0141                	addi	sp,sp,16
     c24:	8082                	ret

0000000000000c26 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     c26:	4885                	li	a7,1
 ecall
     c28:	00000073          	ecall
 ret
     c2c:	8082                	ret

0000000000000c2e <exit>:
.global exit
exit:
 li a7, SYS_exit
     c2e:	4889                	li	a7,2
 ecall
     c30:	00000073          	ecall
 ret
     c34:	8082                	ret

0000000000000c36 <wait>:
.global wait
wait:
 li a7, SYS_wait
     c36:	488d                	li	a7,3
 ecall
     c38:	00000073          	ecall
 ret
     c3c:	8082                	ret

0000000000000c3e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     c3e:	4891                	li	a7,4
 ecall
     c40:	00000073          	ecall
 ret
     c44:	8082                	ret

0000000000000c46 <read>:
.global read
read:
 li a7, SYS_read
     c46:	4895                	li	a7,5
 ecall
     c48:	00000073          	ecall
 ret
     c4c:	8082                	ret

0000000000000c4e <write>:
.global write
write:
 li a7, SYS_write
     c4e:	48c1                	li	a7,16
 ecall
     c50:	00000073          	ecall
 ret
     c54:	8082                	ret

0000000000000c56 <close>:
.global close
close:
 li a7, SYS_close
     c56:	48d5                	li	a7,21
 ecall
     c58:	00000073          	ecall
 ret
     c5c:	8082                	ret

0000000000000c5e <kill>:
.global kill
kill:
 li a7, SYS_kill
     c5e:	4899                	li	a7,6
 ecall
     c60:	00000073          	ecall
 ret
     c64:	8082                	ret

0000000000000c66 <exec>:
.global exec
exec:
 li a7, SYS_exec
     c66:	489d                	li	a7,7
 ecall
     c68:	00000073          	ecall
 ret
     c6c:	8082                	ret

0000000000000c6e <open>:
.global open
open:
 li a7, SYS_open
     c6e:	48bd                	li	a7,15
 ecall
     c70:	00000073          	ecall
 ret
     c74:	8082                	ret

0000000000000c76 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     c76:	48c5                	li	a7,17
 ecall
     c78:	00000073          	ecall
 ret
     c7c:	8082                	ret

0000000000000c7e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     c7e:	48c9                	li	a7,18
 ecall
     c80:	00000073          	ecall
 ret
     c84:	8082                	ret

0000000000000c86 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     c86:	48a1                	li	a7,8
 ecall
     c88:	00000073          	ecall
 ret
     c8c:	8082                	ret

0000000000000c8e <link>:
.global link
link:
 li a7, SYS_link
     c8e:	48cd                	li	a7,19
 ecall
     c90:	00000073          	ecall
 ret
     c94:	8082                	ret

0000000000000c96 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     c96:	48d1                	li	a7,20
 ecall
     c98:	00000073          	ecall
 ret
     c9c:	8082                	ret

0000000000000c9e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     c9e:	48a5                	li	a7,9
 ecall
     ca0:	00000073          	ecall
 ret
     ca4:	8082                	ret

0000000000000ca6 <dup>:
.global dup
dup:
 li a7, SYS_dup
     ca6:	48a9                	li	a7,10
 ecall
     ca8:	00000073          	ecall
 ret
     cac:	8082                	ret

0000000000000cae <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     cae:	48ad                	li	a7,11
 ecall
     cb0:	00000073          	ecall
 ret
     cb4:	8082                	ret

0000000000000cb6 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
     cb6:	48b1                	li	a7,12
 ecall
     cb8:	00000073          	ecall
 ret
     cbc:	8082                	ret

0000000000000cbe <pause>:
.global pause
pause:
 li a7, SYS_pause
     cbe:	48b5                	li	a7,13
 ecall
     cc0:	00000073          	ecall
 ret
     cc4:	8082                	ret

0000000000000cc6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     cc6:	48b9                	li	a7,14
 ecall
     cc8:	00000073          	ecall
 ret
     ccc:	8082                	ret

0000000000000cce <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     cce:	1101                	addi	sp,sp,-32
     cd0:	ec06                	sd	ra,24(sp)
     cd2:	e822                	sd	s0,16(sp)
     cd4:	1000                	addi	s0,sp,32
     cd6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     cda:	4605                	li	a2,1
     cdc:	fef40593          	addi	a1,s0,-17
     ce0:	f6fff0ef          	jal	c4e <write>
}
     ce4:	60e2                	ld	ra,24(sp)
     ce6:	6442                	ld	s0,16(sp)
     ce8:	6105                	addi	sp,sp,32
     cea:	8082                	ret

0000000000000cec <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
     cec:	715d                	addi	sp,sp,-80
     cee:	e486                	sd	ra,72(sp)
     cf0:	e0a2                	sd	s0,64(sp)
     cf2:	f84a                	sd	s2,48(sp)
     cf4:	0880                	addi	s0,sp,80
     cf6:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
     cf8:	c299                	beqz	a3,cfe <printint+0x12>
     cfa:	0805c363          	bltz	a1,d80 <printint+0x94>
  neg = 0;
     cfe:	4881                	li	a7,0
     d00:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
     d04:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
     d06:	00000517          	auipc	a0,0x0
     d0a:	65250513          	addi	a0,a0,1618 # 1358 <digits>
     d0e:	883e                	mv	a6,a5
     d10:	2785                	addiw	a5,a5,1
     d12:	02c5f733          	remu	a4,a1,a2
     d16:	972a                	add	a4,a4,a0
     d18:	00074703          	lbu	a4,0(a4)
     d1c:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
     d20:	872e                	mv	a4,a1
     d22:	02c5d5b3          	divu	a1,a1,a2
     d26:	0685                	addi	a3,a3,1
     d28:	fec773e3          	bgeu	a4,a2,d0e <printint+0x22>
  if(neg)
     d2c:	00088b63          	beqz	a7,d42 <printint+0x56>
    buf[i++] = '-';
     d30:	fd078793          	addi	a5,a5,-48
     d34:	97a2                	add	a5,a5,s0
     d36:	02d00713          	li	a4,45
     d3a:	fee78423          	sb	a4,-24(a5)
     d3e:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
     d42:	02f05a63          	blez	a5,d76 <printint+0x8a>
     d46:	fc26                	sd	s1,56(sp)
     d48:	f44e                	sd	s3,40(sp)
     d4a:	fb840713          	addi	a4,s0,-72
     d4e:	00f704b3          	add	s1,a4,a5
     d52:	fff70993          	addi	s3,a4,-1
     d56:	99be                	add	s3,s3,a5
     d58:	37fd                	addiw	a5,a5,-1
     d5a:	1782                	slli	a5,a5,0x20
     d5c:	9381                	srli	a5,a5,0x20
     d5e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
     d62:	fff4c583          	lbu	a1,-1(s1)
     d66:	854a                	mv	a0,s2
     d68:	f67ff0ef          	jal	cce <putc>
  while(--i >= 0)
     d6c:	14fd                	addi	s1,s1,-1
     d6e:	ff349ae3          	bne	s1,s3,d62 <printint+0x76>
     d72:	74e2                	ld	s1,56(sp)
     d74:	79a2                	ld	s3,40(sp)
}
     d76:	60a6                	ld	ra,72(sp)
     d78:	6406                	ld	s0,64(sp)
     d7a:	7942                	ld	s2,48(sp)
     d7c:	6161                	addi	sp,sp,80
     d7e:	8082                	ret
    x = -xx;
     d80:	40b005b3          	neg	a1,a1
    neg = 1;
     d84:	4885                	li	a7,1
    x = -xx;
     d86:	bfad                	j	d00 <printint+0x14>

0000000000000d88 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     d88:	711d                	addi	sp,sp,-96
     d8a:	ec86                	sd	ra,88(sp)
     d8c:	e8a2                	sd	s0,80(sp)
     d8e:	e0ca                	sd	s2,64(sp)
     d90:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     d92:	0005c903          	lbu	s2,0(a1)
     d96:	28090663          	beqz	s2,1022 <vprintf+0x29a>
     d9a:	e4a6                	sd	s1,72(sp)
     d9c:	fc4e                	sd	s3,56(sp)
     d9e:	f852                	sd	s4,48(sp)
     da0:	f456                	sd	s5,40(sp)
     da2:	f05a                	sd	s6,32(sp)
     da4:	ec5e                	sd	s7,24(sp)
     da6:	e862                	sd	s8,16(sp)
     da8:	e466                	sd	s9,8(sp)
     daa:	8b2a                	mv	s6,a0
     dac:	8a2e                	mv	s4,a1
     dae:	8bb2                	mv	s7,a2
  state = 0;
     db0:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
     db2:	4481                	li	s1,0
     db4:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
     db6:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
     dba:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
     dbe:	06c00c93          	li	s9,108
     dc2:	a005                	j	de2 <vprintf+0x5a>
        putc(fd, c0);
     dc4:	85ca                	mv	a1,s2
     dc6:	855a                	mv	a0,s6
     dc8:	f07ff0ef          	jal	cce <putc>
     dcc:	a019                	j	dd2 <vprintf+0x4a>
    } else if(state == '%'){
     dce:	03598263          	beq	s3,s5,df2 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
     dd2:	2485                	addiw	s1,s1,1
     dd4:	8726                	mv	a4,s1
     dd6:	009a07b3          	add	a5,s4,s1
     dda:	0007c903          	lbu	s2,0(a5)
     dde:	22090a63          	beqz	s2,1012 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
     de2:	0009079b          	sext.w	a5,s2
    if(state == 0){
     de6:	fe0994e3          	bnez	s3,dce <vprintf+0x46>
      if(c0 == '%'){
     dea:	fd579de3          	bne	a5,s5,dc4 <vprintf+0x3c>
        state = '%';
     dee:	89be                	mv	s3,a5
     df0:	b7cd                	j	dd2 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
     df2:	00ea06b3          	add	a3,s4,a4
     df6:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
     dfa:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
     dfc:	c681                	beqz	a3,e04 <vprintf+0x7c>
     dfe:	9752                	add	a4,a4,s4
     e00:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
     e04:	05878363          	beq	a5,s8,e4a <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
     e08:	05978d63          	beq	a5,s9,e62 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
     e0c:	07500713          	li	a4,117
     e10:	0ee78763          	beq	a5,a4,efe <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
     e14:	07800713          	li	a4,120
     e18:	12e78963          	beq	a5,a4,f4a <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
     e1c:	07000713          	li	a4,112
     e20:	14e78e63          	beq	a5,a4,f7c <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
     e24:	06300713          	li	a4,99
     e28:	18e78e63          	beq	a5,a4,fc4 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
     e2c:	07300713          	li	a4,115
     e30:	1ae78463          	beq	a5,a4,fd8 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
     e34:	02500713          	li	a4,37
     e38:	04e79563          	bne	a5,a4,e82 <vprintf+0xfa>
        putc(fd, '%');
     e3c:	02500593          	li	a1,37
     e40:	855a                	mv	a0,s6
     e42:	e8dff0ef          	jal	cce <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
     e46:	4981                	li	s3,0
     e48:	b769                	j	dd2 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
     e4a:	008b8913          	addi	s2,s7,8
     e4e:	4685                	li	a3,1
     e50:	4629                	li	a2,10
     e52:	000ba583          	lw	a1,0(s7)
     e56:	855a                	mv	a0,s6
     e58:	e95ff0ef          	jal	cec <printint>
     e5c:	8bca                	mv	s7,s2
      state = 0;
     e5e:	4981                	li	s3,0
     e60:	bf8d                	j	dd2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
     e62:	06400793          	li	a5,100
     e66:	02f68963          	beq	a3,a5,e98 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     e6a:	06c00793          	li	a5,108
     e6e:	04f68263          	beq	a3,a5,eb2 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
     e72:	07500793          	li	a5,117
     e76:	0af68063          	beq	a3,a5,f16 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
     e7a:	07800793          	li	a5,120
     e7e:	0ef68263          	beq	a3,a5,f62 <vprintf+0x1da>
        putc(fd, '%');
     e82:	02500593          	li	a1,37
     e86:	855a                	mv	a0,s6
     e88:	e47ff0ef          	jal	cce <putc>
        putc(fd, c0);
     e8c:	85ca                	mv	a1,s2
     e8e:	855a                	mv	a0,s6
     e90:	e3fff0ef          	jal	cce <putc>
      state = 0;
     e94:	4981                	li	s3,0
     e96:	bf35                	j	dd2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     e98:	008b8913          	addi	s2,s7,8
     e9c:	4685                	li	a3,1
     e9e:	4629                	li	a2,10
     ea0:	000bb583          	ld	a1,0(s7)
     ea4:	855a                	mv	a0,s6
     ea6:	e47ff0ef          	jal	cec <printint>
        i += 1;
     eaa:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     eac:	8bca                	mv	s7,s2
      state = 0;
     eae:	4981                	li	s3,0
        i += 1;
     eb0:	b70d                	j	dd2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     eb2:	06400793          	li	a5,100
     eb6:	02f60763          	beq	a2,a5,ee4 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     eba:	07500793          	li	a5,117
     ebe:	06f60963          	beq	a2,a5,f30 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
     ec2:	07800793          	li	a5,120
     ec6:	faf61ee3          	bne	a2,a5,e82 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
     eca:	008b8913          	addi	s2,s7,8
     ece:	4681                	li	a3,0
     ed0:	4641                	li	a2,16
     ed2:	000bb583          	ld	a1,0(s7)
     ed6:	855a                	mv	a0,s6
     ed8:	e15ff0ef          	jal	cec <printint>
        i += 2;
     edc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
     ede:	8bca                	mv	s7,s2
      state = 0;
     ee0:	4981                	li	s3,0
        i += 2;
     ee2:	bdc5                	j	dd2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     ee4:	008b8913          	addi	s2,s7,8
     ee8:	4685                	li	a3,1
     eea:	4629                	li	a2,10
     eec:	000bb583          	ld	a1,0(s7)
     ef0:	855a                	mv	a0,s6
     ef2:	dfbff0ef          	jal	cec <printint>
        i += 2;
     ef6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
     ef8:	8bca                	mv	s7,s2
      state = 0;
     efa:	4981                	li	s3,0
        i += 2;
     efc:	bdd9                	j	dd2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
     efe:	008b8913          	addi	s2,s7,8
     f02:	4681                	li	a3,0
     f04:	4629                	li	a2,10
     f06:	000be583          	lwu	a1,0(s7)
     f0a:	855a                	mv	a0,s6
     f0c:	de1ff0ef          	jal	cec <printint>
     f10:	8bca                	mv	s7,s2
      state = 0;
     f12:	4981                	li	s3,0
     f14:	bd7d                	j	dd2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     f16:	008b8913          	addi	s2,s7,8
     f1a:	4681                	li	a3,0
     f1c:	4629                	li	a2,10
     f1e:	000bb583          	ld	a1,0(s7)
     f22:	855a                	mv	a0,s6
     f24:	dc9ff0ef          	jal	cec <printint>
        i += 1;
     f28:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
     f2a:	8bca                	mv	s7,s2
      state = 0;
     f2c:	4981                	li	s3,0
        i += 1;
     f2e:	b555                	j	dd2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     f30:	008b8913          	addi	s2,s7,8
     f34:	4681                	li	a3,0
     f36:	4629                	li	a2,10
     f38:	000bb583          	ld	a1,0(s7)
     f3c:	855a                	mv	a0,s6
     f3e:	dafff0ef          	jal	cec <printint>
        i += 2;
     f42:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
     f44:	8bca                	mv	s7,s2
      state = 0;
     f46:	4981                	li	s3,0
        i += 2;
     f48:	b569                	j	dd2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
     f4a:	008b8913          	addi	s2,s7,8
     f4e:	4681                	li	a3,0
     f50:	4641                	li	a2,16
     f52:	000be583          	lwu	a1,0(s7)
     f56:	855a                	mv	a0,s6
     f58:	d95ff0ef          	jal	cec <printint>
     f5c:	8bca                	mv	s7,s2
      state = 0;
     f5e:	4981                	li	s3,0
     f60:	bd8d                	j	dd2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
     f62:	008b8913          	addi	s2,s7,8
     f66:	4681                	li	a3,0
     f68:	4641                	li	a2,16
     f6a:	000bb583          	ld	a1,0(s7)
     f6e:	855a                	mv	a0,s6
     f70:	d7dff0ef          	jal	cec <printint>
        i += 1;
     f74:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
     f76:	8bca                	mv	s7,s2
      state = 0;
     f78:	4981                	li	s3,0
        i += 1;
     f7a:	bda1                	j	dd2 <vprintf+0x4a>
     f7c:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
     f7e:	008b8d13          	addi	s10,s7,8
     f82:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
     f86:	03000593          	li	a1,48
     f8a:	855a                	mv	a0,s6
     f8c:	d43ff0ef          	jal	cce <putc>
  putc(fd, 'x');
     f90:	07800593          	li	a1,120
     f94:	855a                	mv	a0,s6
     f96:	d39ff0ef          	jal	cce <putc>
     f9a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     f9c:	00000b97          	auipc	s7,0x0
     fa0:	3bcb8b93          	addi	s7,s7,956 # 1358 <digits>
     fa4:	03c9d793          	srli	a5,s3,0x3c
     fa8:	97de                	add	a5,a5,s7
     faa:	0007c583          	lbu	a1,0(a5)
     fae:	855a                	mv	a0,s6
     fb0:	d1fff0ef          	jal	cce <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     fb4:	0992                	slli	s3,s3,0x4
     fb6:	397d                	addiw	s2,s2,-1
     fb8:	fe0916e3          	bnez	s2,fa4 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
     fbc:	8bea                	mv	s7,s10
      state = 0;
     fbe:	4981                	li	s3,0
     fc0:	6d02                	ld	s10,0(sp)
     fc2:	bd01                	j	dd2 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
     fc4:	008b8913          	addi	s2,s7,8
     fc8:	000bc583          	lbu	a1,0(s7)
     fcc:	855a                	mv	a0,s6
     fce:	d01ff0ef          	jal	cce <putc>
     fd2:	8bca                	mv	s7,s2
      state = 0;
     fd4:	4981                	li	s3,0
     fd6:	bbf5                	j	dd2 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
     fd8:	008b8993          	addi	s3,s7,8
     fdc:	000bb903          	ld	s2,0(s7)
     fe0:	00090f63          	beqz	s2,ffe <vprintf+0x276>
        for(; *s; s++)
     fe4:	00094583          	lbu	a1,0(s2)
     fe8:	c195                	beqz	a1,100c <vprintf+0x284>
          putc(fd, *s);
     fea:	855a                	mv	a0,s6
     fec:	ce3ff0ef          	jal	cce <putc>
        for(; *s; s++)
     ff0:	0905                	addi	s2,s2,1
     ff2:	00094583          	lbu	a1,0(s2)
     ff6:	f9f5                	bnez	a1,fea <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
     ff8:	8bce                	mv	s7,s3
      state = 0;
     ffa:	4981                	li	s3,0
     ffc:	bbd9                	j	dd2 <vprintf+0x4a>
          s = "(null)";
     ffe:	00000917          	auipc	s2,0x0
    1002:	32290913          	addi	s2,s2,802 # 1320 <malloc+0x216>
        for(; *s; s++)
    1006:	02800593          	li	a1,40
    100a:	b7c5                	j	fea <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
    100c:	8bce                	mv	s7,s3
      state = 0;
    100e:	4981                	li	s3,0
    1010:	b3c9                	j	dd2 <vprintf+0x4a>
    1012:	64a6                	ld	s1,72(sp)
    1014:	79e2                	ld	s3,56(sp)
    1016:	7a42                	ld	s4,48(sp)
    1018:	7aa2                	ld	s5,40(sp)
    101a:	7b02                	ld	s6,32(sp)
    101c:	6be2                	ld	s7,24(sp)
    101e:	6c42                	ld	s8,16(sp)
    1020:	6ca2                	ld	s9,8(sp)
    }
  }
}
    1022:	60e6                	ld	ra,88(sp)
    1024:	6446                	ld	s0,80(sp)
    1026:	6906                	ld	s2,64(sp)
    1028:	6125                	addi	sp,sp,96
    102a:	8082                	ret

000000000000102c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    102c:	715d                	addi	sp,sp,-80
    102e:	ec06                	sd	ra,24(sp)
    1030:	e822                	sd	s0,16(sp)
    1032:	1000                	addi	s0,sp,32
    1034:	e010                	sd	a2,0(s0)
    1036:	e414                	sd	a3,8(s0)
    1038:	e818                	sd	a4,16(s0)
    103a:	ec1c                	sd	a5,24(s0)
    103c:	03043023          	sd	a6,32(s0)
    1040:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1044:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1048:	8622                	mv	a2,s0
    104a:	d3fff0ef          	jal	d88 <vprintf>
}
    104e:	60e2                	ld	ra,24(sp)
    1050:	6442                	ld	s0,16(sp)
    1052:	6161                	addi	sp,sp,80
    1054:	8082                	ret

0000000000001056 <printf>:

void
printf(const char *fmt, ...)
{
    1056:	711d                	addi	sp,sp,-96
    1058:	ec06                	sd	ra,24(sp)
    105a:	e822                	sd	s0,16(sp)
    105c:	1000                	addi	s0,sp,32
    105e:	e40c                	sd	a1,8(s0)
    1060:	e810                	sd	a2,16(s0)
    1062:	ec14                	sd	a3,24(s0)
    1064:	f018                	sd	a4,32(s0)
    1066:	f41c                	sd	a5,40(s0)
    1068:	03043823          	sd	a6,48(s0)
    106c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1070:	00840613          	addi	a2,s0,8
    1074:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1078:	85aa                	mv	a1,a0
    107a:	4505                	li	a0,1
    107c:	d0dff0ef          	jal	d88 <vprintf>
}
    1080:	60e2                	ld	ra,24(sp)
    1082:	6442                	ld	s0,16(sp)
    1084:	6125                	addi	sp,sp,96
    1086:	8082                	ret

0000000000001088 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1088:	1141                	addi	sp,sp,-16
    108a:	e422                	sd	s0,8(sp)
    108c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    108e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1092:	00001797          	auipc	a5,0x1
    1096:	f7e7b783          	ld	a5,-130(a5) # 2010 <freep>
    109a:	a02d                	j	10c4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    109c:	4618                	lw	a4,8(a2)
    109e:	9f2d                	addw	a4,a4,a1
    10a0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    10a4:	6398                	ld	a4,0(a5)
    10a6:	6310                	ld	a2,0(a4)
    10a8:	a83d                	j	10e6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    10aa:	ff852703          	lw	a4,-8(a0)
    10ae:	9f31                	addw	a4,a4,a2
    10b0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    10b2:	ff053683          	ld	a3,-16(a0)
    10b6:	a091                	j	10fa <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    10b8:	6398                	ld	a4,0(a5)
    10ba:	00e7e463          	bltu	a5,a4,10c2 <free+0x3a>
    10be:	00e6ea63          	bltu	a3,a4,10d2 <free+0x4a>
{
    10c2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    10c4:	fed7fae3          	bgeu	a5,a3,10b8 <free+0x30>
    10c8:	6398                	ld	a4,0(a5)
    10ca:	00e6e463          	bltu	a3,a4,10d2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    10ce:	fee7eae3          	bltu	a5,a4,10c2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    10d2:	ff852583          	lw	a1,-8(a0)
    10d6:	6390                	ld	a2,0(a5)
    10d8:	02059813          	slli	a6,a1,0x20
    10dc:	01c85713          	srli	a4,a6,0x1c
    10e0:	9736                	add	a4,a4,a3
    10e2:	fae60de3          	beq	a2,a4,109c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    10e6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    10ea:	4790                	lw	a2,8(a5)
    10ec:	02061593          	slli	a1,a2,0x20
    10f0:	01c5d713          	srli	a4,a1,0x1c
    10f4:	973e                	add	a4,a4,a5
    10f6:	fae68ae3          	beq	a3,a4,10aa <free+0x22>
    p->s.ptr = bp->s.ptr;
    10fa:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    10fc:	00001717          	auipc	a4,0x1
    1100:	f0f73a23          	sd	a5,-236(a4) # 2010 <freep>
}
    1104:	6422                	ld	s0,8(sp)
    1106:	0141                	addi	sp,sp,16
    1108:	8082                	ret

000000000000110a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    110a:	7139                	addi	sp,sp,-64
    110c:	fc06                	sd	ra,56(sp)
    110e:	f822                	sd	s0,48(sp)
    1110:	f426                	sd	s1,40(sp)
    1112:	ec4e                	sd	s3,24(sp)
    1114:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1116:	02051493          	slli	s1,a0,0x20
    111a:	9081                	srli	s1,s1,0x20
    111c:	04bd                	addi	s1,s1,15
    111e:	8091                	srli	s1,s1,0x4
    1120:	0014899b          	addiw	s3,s1,1
    1124:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1126:	00001517          	auipc	a0,0x1
    112a:	eea53503          	ld	a0,-278(a0) # 2010 <freep>
    112e:	c915                	beqz	a0,1162 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1130:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1132:	4798                	lw	a4,8(a5)
    1134:	08977a63          	bgeu	a4,s1,11c8 <malloc+0xbe>
    1138:	f04a                	sd	s2,32(sp)
    113a:	e852                	sd	s4,16(sp)
    113c:	e456                	sd	s5,8(sp)
    113e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    1140:	8a4e                	mv	s4,s3
    1142:	0009871b          	sext.w	a4,s3
    1146:	6685                	lui	a3,0x1
    1148:	00d77363          	bgeu	a4,a3,114e <malloc+0x44>
    114c:	6a05                	lui	s4,0x1
    114e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1152:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1156:	00001917          	auipc	s2,0x1
    115a:	eba90913          	addi	s2,s2,-326 # 2010 <freep>
  if(p == SBRK_ERROR)
    115e:	5afd                	li	s5,-1
    1160:	a081                	j	11a0 <malloc+0x96>
    1162:	f04a                	sd	s2,32(sp)
    1164:	e852                	sd	s4,16(sp)
    1166:	e456                	sd	s5,8(sp)
    1168:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    116a:	00001797          	auipc	a5,0x1
    116e:	f1e78793          	addi	a5,a5,-226 # 2088 <base>
    1172:	00001717          	auipc	a4,0x1
    1176:	e8f73f23          	sd	a5,-354(a4) # 2010 <freep>
    117a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    117c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1180:	b7c1                	j	1140 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    1182:	6398                	ld	a4,0(a5)
    1184:	e118                	sd	a4,0(a0)
    1186:	a8a9                	j	11e0 <malloc+0xd6>
  hp->s.size = nu;
    1188:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    118c:	0541                	addi	a0,a0,16
    118e:	efbff0ef          	jal	1088 <free>
  return freep;
    1192:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1196:	c12d                	beqz	a0,11f8 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1198:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    119a:	4798                	lw	a4,8(a5)
    119c:	02977263          	bgeu	a4,s1,11c0 <malloc+0xb6>
    if(p == freep)
    11a0:	00093703          	ld	a4,0(s2)
    11a4:	853e                	mv	a0,a5
    11a6:	fef719e3          	bne	a4,a5,1198 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    11aa:	8552                	mv	a0,s4
    11ac:	a4fff0ef          	jal	bfa <sbrk>
  if(p == SBRK_ERROR)
    11b0:	fd551ce3          	bne	a0,s5,1188 <malloc+0x7e>
        return 0;
    11b4:	4501                	li	a0,0
    11b6:	7902                	ld	s2,32(sp)
    11b8:	6a42                	ld	s4,16(sp)
    11ba:	6aa2                	ld	s5,8(sp)
    11bc:	6b02                	ld	s6,0(sp)
    11be:	a03d                	j	11ec <malloc+0xe2>
    11c0:	7902                	ld	s2,32(sp)
    11c2:	6a42                	ld	s4,16(sp)
    11c4:	6aa2                	ld	s5,8(sp)
    11c6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    11c8:	fae48de3          	beq	s1,a4,1182 <malloc+0x78>
        p->s.size -= nunits;
    11cc:	4137073b          	subw	a4,a4,s3
    11d0:	c798                	sw	a4,8(a5)
        p += p->s.size;
    11d2:	02071693          	slli	a3,a4,0x20
    11d6:	01c6d713          	srli	a4,a3,0x1c
    11da:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    11dc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    11e0:	00001717          	auipc	a4,0x1
    11e4:	e2a73823          	sd	a0,-464(a4) # 2010 <freep>
      return (void*)(p + 1);
    11e8:	01078513          	addi	a0,a5,16
  }
}
    11ec:	70e2                	ld	ra,56(sp)
    11ee:	7442                	ld	s0,48(sp)
    11f0:	74a2                	ld	s1,40(sp)
    11f2:	69e2                	ld	s3,24(sp)
    11f4:	6121                	addi	sp,sp,64
    11f6:	8082                	ret
    11f8:	7902                	ld	s2,32(sp)
    11fa:	6a42                	ld	s4,16(sp)
    11fc:	6aa2                	ld	s5,8(sp)
    11fe:	6b02                	ld	s6,0(sp)
    1200:	b7f5                	j	11ec <malloc+0xe2>
