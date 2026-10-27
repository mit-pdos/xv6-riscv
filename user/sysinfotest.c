#include "kernel/types.h"
#include "kernel/sysinfo.h"
#include "user/user.h"

static struct sysinfo info;

#include "user/sysinfo_print.h"
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
  print_sysinfo(&info);

  test_file();
  test_proc();
  test_misc();

  printf("\nTOTAL: %d passed, %d failed\n", sysinfo_npass, sysinfo_nfail);
  exit(sysinfo_nfail ? 1 : 0);
}