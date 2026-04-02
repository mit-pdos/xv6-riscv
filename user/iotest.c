#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  uint64 io0, wt0, vy0;
  uint64 io1, wt1, vy1;
  uint64 io2, wt2, vy2;
  int i;
  uint64 dio, dwt, dvy;

  (void)argc;
  (void)argv;

  if(getprociostats(&io0, &wt0, &vy0) < 0){
    printf("iotest: getprociostats failed\n");
    exit(1);
  }

  if(pause(5) < 0){
    printf("iotest: pause failed\n");
    exit(1);
  }

  if(getprociostats(&io1, &wt1, &vy1) < 0){
    printf("iotest: getprociostats failed\n");
    exit(1);
  }

  for(i = 0; i < 10; i++){
    if(yield() < 0){
      printf("iotest: yield failed\n");
      exit(1);
    }
  }

  if(getprociostats(&io2, &wt2, &vy2) < 0){
    printf("iotest: getprociostats failed\n");
    exit(1);
  }

  dio = io1 - io0;
  dwt = wt1 - wt0;
  dvy = vy2 - vy1;

  printf("iotest: before pause io=%ld wait=%ld vy=%ld\n", io0, wt0, vy0);
  printf("iotest: pause delta io=%ld wait=%ld\n", dio, dwt);
  printf("iotest: after 10 yields io=%ld (delta from post-pause %ld) vy_delta=%ld\n",
         io2, io2 - io1, dvy);

  if(dio < 3){
    printf("iotest: FAIL expected io_count delta >= 3 after pause(5)\n");
    exit(1);
  }
  if(dwt < 3){
    printf("iotest: FAIL expected wait_time delta >= 3 after pause(5)\n");
    exit(1);
  }
  if(dvy != 10){
    printf("iotest: FAIL expected 10 voluntary yields, got %ld\n", dvy);
    exit(1);
  }
  if(io2 != io1){
    printf("iotest: FAIL io_count should not change from yield-only\n");
    exit(1);
  }

  printf("iotest: OK\n");
  exit(0);
}
