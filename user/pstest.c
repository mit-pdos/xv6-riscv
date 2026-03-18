#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/procinfo.h"
#include "user/user.h"

static void
test_count_only(void)
{
  int n = ps_listinfo(0, 0);
  if (n >= 0)
    printf("test_count_only: OK\n");
  else
    printf("test_count_only: FAIL\n");
}

static void
test_small_buffer(void)
{
  struct procinfo x[1];
  int r = ps_listinfo(x, 1);

  if (r > 1)
    printf("test_small_buffer: OK\n");
  else
    printf("test_small_buffer: FAIL\n");
}

static void
test_good_buffer(void)
{
  int n = ps_listinfo(0, 0);
  if (n < 0) {
    printf("test_good_buffer: FAIL (count=%d)\n", n);
    return;
  }

  struct procinfo* buf = malloc((n + 8) * sizeof(struct procinfo));
  if (buf == 0) {
    printf("test_good_buffer: FAIL (malloc)\n");
    return;
  }

  int r = ps_listinfo(buf, n + 8);
  if (r >= 0 && r <= n + 8) {
    printf("test_good_buffer: OK (%d)\n", r);
    for (int i = 0; i < r && i < 5; i++) {
      printf("  pid=%d name=%s ppid=%d pname=%s state=%d\n",
        buf[i].pid, buf[i].name, buf[i].ppid, buf[i].pname, buf[i].state);
    }
  }
  else {
    printf("test_good_buffer: FAIL");
  }

  free(buf);
}

static void
test_bad_addr(void)
{
  int r = ps_listinfo((struct procinfo*)0xffffffffffffULL, 4);

  if (r < 0)
    printf("test_bad_addr: OK\n");
  else
    printf("test_bad_addr: FAIL\n");
}

static void
test_negative_lim(void)
{
  struct procinfo x[1];
  int r = ps_listinfo(x, -1);

  if (r < 0)
    printf("test_negative_lim: OK\n");
  else
    printf("test_negative_lim: FAIL\n");
}

static void
test_zero_lim(void)
{
  struct procinfo x[1];
  int r = ps_listinfo(x, 0);

  if (r > 0)
    printf("test_zero_lim: OK\n");
  else
    printf("test_zero_lim: FAIL\n");
}

int
main(void)
{
  test_count_only();
  test_small_buffer();
  test_good_buffer();
  test_bad_addr();
  test_negative_lim();
  test_zero_lim();
  exit(0);
}