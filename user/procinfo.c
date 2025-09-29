#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

char *states[] = {
  [0]    "UNUSED",
  [1]    "USED",
  [2]    "SLEEPING",
  [3]    "RUNNABLE",
  [4]    "RUNNING",
  [5]    "ZOMBIE"
};

int
main(int argc, char *argv[])
{
  struct proc_info info;
  int pid;

  if(argc < 2){
    printf("Usage: procinfo <pid>\n");
    exit(1);
  }

  // Validate that the argument is a number
  for(int i = 0; argv[1][i] != '\0'; i++) {
    if(argv[1][i] < '0' || argv[1][i] > '9') {
      printf("Error: PID must be a positive integer.\n");
      exit(1);
    }
  }

  pid = atoi(argv[1]);
  if(pid <= 0) {
    printf("Error: Invalid PID.\n");
    exit(1);
  }

  if(getprocinfo(pid, &info) < 0){
    printf("Error: Process not found.\n");
    exit(1);
  }

  // Print process information
  printf("Process Info for PID %d:\n", info.pid);
  printf("  Name: %s\n", info.name);
  printf("  State: %s\n", states[info.state]);
  printf("  Parent PID: %d\n", info.parent_pid);
  printf("  Killed: %d\n", info.killed);
  printf("  Exit status: %d\n", info.xstate);
  printf("  Memory Size: %lu bytes\n", info.sz); // Use %lu for uint64
  printf("  Kernel Stack: 0x%lx\n", info.kstack); // Use %lx for uint64 in hexadecimal
  printf("  Page table: 0x%lx\n", info.pagetable);
  printf("  Trapframe: 0x%lx\n", info.trapframe);
  printf("  Context SP: 0x%lx\n", info.context_sp);
  printf("  CWD: 0x%lx\n", info.cwd);
  printf("  Chan: 0x%lx\n", info.chan);
  printf("  Open files:\n");
  for(int i = 0; i < 16; i++){
    if(info.ofile[i])
      printf("    [%d] 0x%lx\n", i, info.ofile[i]);
  }

  exit(0);
}