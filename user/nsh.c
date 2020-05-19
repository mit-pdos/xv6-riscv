#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

#define CMDSIZE 128
#define MAXARGS 10
#define MAXPIPE 4

#define STDIN   0
#define STDOUT  1

struct command {
  char *argv[MAXARGS];
};

struct commands {
  struct command cmds[MAXPIPE];
  char *in_file;
  char *out_file;
};

enum {
  STR   = 0,
  PIPE  = 1,  // '|'
  R_IN  = 2,  // '<'
  R_OUT = 4,  // '>'
};

// store next word to "word"
char* getword(char *cmd, char **word) {
  while(*cmd == ' ')
    cmd++;
  *word = cmd;
  while(*cmd != ' ' && *cmd != '\t' && *cmd != '\n' && *cmd != 0) {
    cmd++;
    if(*cmd == '|' || *cmd == '<' || *cmd == '>')
      *(++cmd) = 0;
  }
  *cmd = 0;
  return cmd+1;
}

int fork1() {
  int pid = fork();
  if(pid < 0) {
    fprintf(2, "fork failed\n");
    exit(1);
  }
  return pid;
}

void
main(int argc, char **argv)
{
  char cmdstr[CMDSIZE];
  // TODO one liner nsh
  if(argc > 2) {
    
  }

  // start inputing cmd
  while(1) {
    // struct cmd execcmd;
    printf("@ ");
    gets(cmdstr, CMDSIZE);

    if(cmdstr[0] == 0) {
      printf("\n");
      break;
    }

    // parse cmd
    // cd
    char *cmdstrp = cmdstr;
    if(cmdstrp[0] == 'c' && cmdstrp[1] == 'd' && cmdstrp[2] == ' ') {
      cmdstrp += 3;
      if(chdir(cmdstrp) < 0) {
        fprintf(2, "cannot cd %s\n", cmdstrp+3);
      }
      continue;
    }

    // other
    struct commands cmds;
    for(int i = 0; i < MAXPIPE; i++) {
      for(int j = 0; j < MAXARGS; j++) {
        cmds.cmds[i].argv[j] = 0;
      }
    }
    cmds.in_file = 0;
    cmds.out_file = 0;
    int cmdpos = 0;
    int argpos = 0;
    int parse_status = STR;
    char *word = 0;
    // TODO allow to make no space on front and back of PIPE, R_IN and R_OUT.
    while(*cmdstrp > 0) {
      cmdstrp = getword(cmdstrp, &word);
      switch(parse_status) {
        case STR:
          if(word[0] == '|') {
            cmdpos++;
            argpos = 0;
            if(cmdpos >= MAXPIPE) {
              fprintf(2, "too many pipe\n");
              break;
            }
          } else if(word[0] == '<') {
            parse_status = R_IN;
          } else if(word[0] == '>') {
            parse_status = R_OUT;
          } else {
            if(argpos == MAXARGS) {
              fprintf(2, "Command is too many arguments\n");
              continue;
            }
            cmds.cmds[cmdpos].argv[argpos++] = word;
          }
          break;
        case R_IN:
            if(cmds.in_file != 0) {
              fprintf(2, "There are redirect's input twice\n");
              exit(1);
            }
            cmds.in_file = word;
            parse_status = STR;
          break;
        case R_OUT:
            if(cmds.out_file != 0) {
              fprintf(2, "There are redirect's output twice\n");
              exit(1);
            }
            cmds.out_file = word; 
            parse_status = STR;
          break;
      }
    }

    if(cmds.cmds[0].argv[0][0] == 0 || cmdpos >= MAXPIPE) {
      continue;
    }

    int p[MAXPIPE][2];
    for(int i = 0; i <= cmdpos; i++) {
      pipe(p[i]);
      if(fork1() == 0) {
        if(i == 0) {
          if(cmds.in_file != 0) {
            close(STDIN);
            if(open(cmds.in_file, O_RDWR) < 0) {
              fprintf(2, "cannot open %s\n", cmds.in_file);
              exit(1);
            }
          }
        } else {
          close(0);
          dup(p[i-1][0]);
          close(p[i-1][0]);
          close(p[i-1][1]);
        }

        if(i == cmdpos) {
          if(cmds.out_file != 0) {
            close(STDOUT);
            if(open(cmds.out_file, O_RDWR|O_CREATE) < 0) {
              fprintf(2, "cannot open %s\n", cmds.out_file);
              exit(1);
            }
          }
        } else {
          close(1);
          dup(p[i][1]);
          close(p[i][1]);
          close(p[i][0]);
        }
        
        if(exec(cmds.cmds[i].argv[0], cmds.cmds[i].argv) != 0) {
          fprintf(2, "cannot exec %s\n", cmds.cmds[i].argv[0]);
          close(STDIN);
          close(STDOUT);
          exit(1);
        }
      }
    }
    for(int i = 0; i <= cmdpos; i++) {
      close(p[i][0]);
      close(p[i][1]);
      wait(0);
    }
  }
  exit(0);
}
