#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define CHILDREN 20
#define ROUNDS   10
#define PAGE_BYTES 4096

static void
fill(char *buf, int value)
{
  for(int i = 0; i < PAGE_BYTES; i++)
    buf[i] = (char)value;
}

static int
verify(char *buf, int value)
{
  for(int i = 0; i < PAGE_BYTES; i++){
    if(buf[i] != (char)value)
      return -1;
  }
  return 0;
}

int
main(void)
{
  for(int c = 0; c < CHILDREN; c++){
    int pid = fork();
    if(pid < 0){
      printf("swapstress: fork failed\n");
      exit(1);
    }
    if(pid == 0){
      char *blocks[ROUNDS];
      for(int r = 0; r < ROUNDS; r++){
        blocks[r] = malloc(PAGE_BYTES);
        if(blocks[r] == 0){
          printf("swapstress: malloc failed\n");
          exit(1);
        }
        fill(blocks[r], (c + r) & 0xff);
      }
      for(int r = 0; r < ROUNDS; r++){
        if(verify(blocks[r], (c + r) & 0xff) < 0){
          printf("swapstress: verify failed child %d round %d\n", c, r);
          exit(1);
        }
        free(blocks[r]);
      }
      exit(0);
    }
  }

  int status;
  int failures = 0;
  while(wait(&status) > 0){
    if(status != 0)
      failures = 1;
  }

  if(failures){
    printf("swapstress: FAILED\n");
    exit(1);
  }

  printf("swapstress: success\n");
  exit(0);
}
