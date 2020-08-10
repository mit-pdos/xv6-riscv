//
// run random system calls in parallel forever.
//

#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "kernel/syscall.h"
#include "kernel/memlayout.h"
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
/*
 * Compute x = (7^5 * x) mod (2^31 - 1)
 * without overflowing 31 bits:
 *      (2^31 - 1) = 127773 * (7^5) + 2836
 * From "Random number generators: good ones are hard to find",
 * Park and Miller, Communications of the ACM, vol. 31, no. 10,
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
    hi = x / 127773;
    lo = x % 127773;
    x = 16807 * lo - 2836 * hi;
    if (x < 0)
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
    *ctx = x;
    return (x);
}

unsigned long rand_next = 1;

int
rand(void)
{
    return (do_rand(&rand_next));
}

void
go(int which_child)
{
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
  uint64 iters = 0;

  mkdir("grindir");
  if(chdir("grindir") != 0){
    printf("chdir grindir failed\n");
    exit(1);
  }
  chdir("/");
  
  while(1){
    iters++;
    if((iters % 500) == 0)
      write(1, which_child?"B":"A", 1);
    int what = rand() % 23;
    if(what == 1){
      close(open("grindir/../a", O_CREATE|O_RDWR));
    } else if(what == 2){
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
    } else if(what == 3){
      unlink("grindir/../a");
    } else if(what == 4){
      if(chdir("grindir") != 0){
        printf("chdir grindir failed\n");
        exit(1);
      }
      unlink("../b");
      chdir("/");
    } else if(what == 5){
      close(fd);
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
    } else if(what == 6){
      close(fd);
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
    } else if(what == 9){
      mkdir("grindir/../a");
      close(open("a/../a/./a", O_CREATE|O_RDWR));
      unlink("a/a");
    } else if(what == 10){
      mkdir("/../b");
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
      unlink("b/b");
    } else if(what == 11){
      unlink("b");
      link("../grindir/./../a", "../b");
    } else if(what == 12){
      unlink("../grindir/../a");
      link(".././b", "/grindir/../a");
    } else if(what == 13){
      int pid = fork();
      if(pid == 0){
        exit(0);
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 14){
      int pid = fork();
      if(pid == 0){
        fork();
        fork();
        exit(0);
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 15){
      sbrk(6011);
    } else if(what == 16){
      if(sbrk(0) > break0)
        sbrk(-(sbrk(0) - break0));
    } else if(what == 17){
      int pid = fork();
      if(pid == 0){
        close(open("a", O_CREATE|O_RDWR));
        exit(0);
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      if(chdir("../grindir/..") != 0){
        printf("chdir failed\n");
        exit(1);
      }
      kill(pid);
      wait(0);
    } else if(what == 18){
      int pid = fork();
      if(pid == 0){
        kill(getpid());
        exit(0);
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 19){
      int fds[2];
      if(pipe(fds) < 0){
        printf("grind: pipe failed\n");
        exit(1);
      }
      int pid = fork();
      if(pid == 0){
        fork();
        fork();
        if(write(fds[1], "x", 1) != 1)
          printf("grind: pipe write failed\n");
        char c;
        if(read(fds[0], &c, 1) != 1)
          printf("grind: pipe read failed\n");
        exit(0);
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      close(fds[0]);
      close(fds[1]);
      wait(0);
    } else if(what == 20){
      int pid = fork();
      if(pid == 0){
        unlink("a");
        mkdir("a");
        chdir("a");
        unlink("../a");
        fd = open("x", O_CREATE|O_RDWR);
        unlink("x");
        exit(0);
      } else if(pid < 0){
        printf("fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 21){
      unlink("c");
      // should always succeed. check that there are free i-nodes,
      // file descriptors, blocks.
      int fd1 = open("c", O_CREATE|O_RDWR);
      if(fd1 < 0){
        printf("create c failed\n");
        exit(1);
      }
      if(write(fd1, "x", 1) != 1){
        printf("write c failed\n");
        exit(1);
      }
      struct stat st;
      if(fstat(fd1, &st) != 0){
        printf("fstat failed\n");
        exit(1);
      }
      if(st.size != 1){
        printf("fstat reports wrong size %d\n", (int)st.size);
        exit(1);
      }
      if(st.ino > 200){
        printf("fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
      unlink("c");
    } else if(what == 22){
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
        fprintf(2, "pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
        fprintf(2, "pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
      if(pid1 == 0){
        close(bb[0]);
        close(bb[1]);
        close(aa[0]);
        close(1);
        if(dup(aa[1]) != 1){
          fprintf(2, "dup failed\n");
          exit(1);
        }
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
        fprintf(2, "fork failed\n");
        exit(3);
      }
      int pid2 = fork();
      if(pid2 == 0){
        close(aa[1]);
        close(bb[0]);
        close(0);
        if(dup(aa[0]) != 0){
          fprintf(2, "dup failed\n");
          exit(4);
        }
        close(aa[0]);
        close(1);
        if(dup(bb[1]) != 1){
          fprintf(2, "dup failed\n");
          exit(5);
        }
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
        fprintf(2, "fork failed\n");
        exit(7);
      }
      close(aa[0]);
      close(aa[1]);
      close(bb[1]);
      char buf[3] = { 0, 0, 0 };
      read(bb[0], buf+0, 1);
      read(bb[0], buf+1, 1);
      close(bb[0]);
      int st1, st2;
      wait(&st1);
      wait(&st2);
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi") != 0){
        printf("exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
        exit(1);
      }
    }
  }
}

int
main()
{
  unlink("a");
  unlink("b");
  
  int pid1 = fork();
  if(pid1 < 0){
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
    rand_next = 31;
    go(0);
    exit(0);
  }

  int pid2 = fork();
  if(pid2 < 0){
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
    rand_next = 7177;
    go(1);
    exit(0);
  }

  int st1 = -1;
  wait(&st1);
  if(st1 != 0){
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
  wait(&st2);

  exit(0);
}
