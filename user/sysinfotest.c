#include "kernel/types.h"
#include "kernel/sysinfo.h"
#include "user/user.h"

static struct sysinfo info;

#include "user/test_file.h"
#include "user/test_proc.h"
#include "user/test_misc.h"

int
main(void)
{
  if(sysinfo(&info) < 0){
    printf("sysinfo failed\n");
    exit(1);
  }
  printf("nfile=%d nproc=%d\n", info.nfile, info.nproc);

  test_file();
  test_proc();
  test_misc();
  exit(0);
}