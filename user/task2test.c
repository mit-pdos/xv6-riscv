#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "kernel/syscall.h"
#include "kernel/memlayout.h"
#include "kernel/riscv.h"


// #################################### TESTS ##########################

int
sysForkTest(){
  int currentProcPid = getpid();
  int mask = (1 << SYS_fork);
  trace(mask, currentProcPid);
  int pid = fork();
  if(pid >0){
    sbrk(5000);
    return 0;
  }
  else{
    exit(0);
  }
  return -1;
}

int
sysKillAndWriteAndExitAndSbrkTest(){
  int currentProcPid = getpid();
  int mask=(1<< SYS_fork)|( 1<< SYS_kill)| ( 1<< SYS_sbrk) | ( 1<< SYS_write);
  trace(mask,currentProcPid);

  int sonPid = fork();
  if(sonPid>0){
    // father fork again and kill son
    int son2Pid = fork();
    if(son2Pid>0){
      kill(son2Pid);
      kill(1000000);
      printf("test write\n");
      exit(1);
      
    }
    else{
      // son sleep until kill
      sleep(100000000);
      exit(2);
    }

  }
  else{
    // son inherit sbrk mask
    sbrk(4000);
    exit(0);
  }
  return 0;
}



// #################################### runner ##########################


int
main(void)
{
  
  int test1res = sysForkTest();
  printf("test1 res: %d\n", test1res);
  
  int test2res = sysKillAndWriteAndExitAndSbrkTest();
  printf("test1 res: %d\n", test2res);

  return 0;
}
