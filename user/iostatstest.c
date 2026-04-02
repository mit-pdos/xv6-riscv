// Verify I/O vs yield counters (kernel sleep/yield instrumentation).

#include "kernel/types.h"
#include "user/user.h"

static void
fail(const char *msg)
{
  printf("iostatstest FAIL: %s\n", msg);
  exit(1);
}

int
main(int argc, char *argv[])
{
  uint64 io0, wt0, y0, io1, wt1, y1, io2, wt2, y2;

  (void)argc;
  (void)argv;

  if(getschedstats(&io0, &wt0, &y0) < 0)
    fail("getschedstats initial");

  pause(5);
  if(getschedstats(&io1, &wt1, &y1) < 0)
    fail("getschedstats after pause");

  if(io1 <= io0)
    fail("expected io_count to increase after pause (sleep)");
  if(wt1 <= wt0)
    fail("expected wait_time to increase after pause");
  /* Timer interrupts may call yield() during pause(); only check io/wt here. */

  for(int i = 0; i < 7; i++)
    yield();

  if(getschedstats(&io2, &wt2, &y2) < 0)
    fail("getschedstats after yields");

  if(io2 != io1)
    fail("yield should not increment io_count");
  if(wt2 != wt1)
    fail("yield should not add sleep wait_time");
  if(y2 < y1 + 7)
    fail("expected voluntary_yields to increase by yield calls");

  printf("iostatstest OK io %d->%d wt %d->%d y %d->%d\n",
         (int)io0, (int)io2, (int)wt0, (int)wt2, (int)y0, (int)y2);
  exit(0);
}
