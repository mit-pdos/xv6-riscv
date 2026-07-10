#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/param.h"
#include "kernel/pinfo.h"
#include "user/user.h"

#define RANDOM_KIDS 12
#define PRIORITY_ROUNDS 5
#define HIGH_KIDS 16
#define LOW_KIDS 4
#define FIRST_CHECK 4
#define FAIR_KIDS 4
#define FAIR_SAMPLES 96
#define FAIR_TIMEOUT 400

static void
fail(char *msg)
{
  fprintf(2, "pritest: FAIL: %s\n", msg);
  exit(1);
}

static void
check(int ok, char *msg)
{
  if (!ok)
    fail(msg);
}

static int
findpid(struct pinfo *info, int pid)
{
  int i;

  for (i = 0; i < NPROC; i++) {
    if (info->inuse[i] && info->pid[i] == pid)
      return i;
  }
  return -1;
}

static int
getpriorityof(int pid, int *priority)
{
  struct pinfo info;
  int i;

  if (getpinfo(&info) < 0)
    return -1;

  i = findpid(&info, pid);
  if (i < 0)
    return -1;

  *priority = info.priority[i];
  return 0;
}

static void
waitn(int n)
{
  int i;

  for (i = 0; i < n; i++)
    wait(0);
}

static void
killall(int *pids, int n)
{
  int i;

  for (i = 0; i < n; i++) {
    if (pids[i] > 0)
      kill(pids[i]);
  }
}

static void
itoa(int n, char *buf)
{
  char tmp[16];
  int i = 0;
  int j = 0;
  int neg = 0;

  if (n < 0) {
    neg = 1;
    n = -n;
  }

  do {
    tmp[i++] = '0' + (n % 10);
    n /= 10;
  } while (n > 0);

  if (neg)
    tmp[i++] = '-';

  while (i > 0)
    buf[j++] = tmp[--i];
  buf[j] = '\0';
}

static int
run_chpri(int pid, char *priority)
{
  int child;
  int status = -1;
  char pidbuf[16];
  char *argv[] = {"chpri", pidbuf, priority, 0};

  itoa(pid, pidbuf);

  child = fork();
  if (child < 0)
    fail("fork chpri");

  if (child == 0) {
    exec("chpri", argv);
    fprintf(2, "pritest: exec chpri failed\n");
    exit(127);
  }

  check(wait(&status) == child, "wait chpri");
  return status;
}

static void
sleep_child(int ticks)
{
  pause(ticks);
  exit(0);
}

static void
test_setpriority_syscall(void)
{
  int me = getpid();
  int p;

  printf("pritest: syscall validation\n");

  check(setpriority(me, 42) == 0, "set self priority 42");
  check(getpriorityof(me, &p) == 0 && p == 42, "read back self priority 42");

  check(setpriority(me, -1) < 0, "reject priority -1");
  check(getpriorityof(me, &p) == 0 && p == 42, "priority changed after -1");

  check(setpriority(me, 101) < 0, "reject priority 101");
  check(getpriorityof(me, &p) == 0 && p == 42, "priority changed after 101");

  check(setpriority(99999, 50) < 0, "reject unknown pid");
  check(setpriority(me, 0) == 0, "set self priority 0");
  check(getpriorityof(me, &p) == 0 && p == 0, "read back self priority 0");
  check(setpriority(me, 100) == 0, "set self priority 100");
  check(getpriorityof(me, &p) == 0 && p == 100, "read back self priority 100");
  check(setpriority(me, 50) == 0, "restore self priority 50");
}

static void
test_child_priority_and_random(void)
{
  int kids[RANDOM_KIDS];
  int priorities[RANDOM_KIDS];
  int i;
  int distinct = 0;
  int sum = 0;
  int target;

  printf("pritest: child priorities and random range\n");

  for (i = 0; i < RANDOM_KIDS; i++) {
    kids[i] = fork();
    if (kids[i] < 0) {
      killall(kids, i);
      waitn(i);
      fail("fork random child");
    }
    if (kids[i] == 0)
      sleep_child(500);
  }

  pause(2);

  for (i = 0; i < RANDOM_KIDS; i++) {
    if (getpriorityof(kids[i], &priorities[i]) < 0) {
      killall(kids, RANDOM_KIDS);
      waitn(RANDOM_KIDS);
      fail("missing random child");
    }
    if (priorities[i] < 0 || priorities[i] > 100) {
      killall(kids, RANDOM_KIDS);
      waitn(RANDOM_KIDS);
      fail("child random priority out of range");
    }
    sum += priorities[i];
    if (i > 0 && priorities[i] != priorities[0])
      distinct = 1;
  }

  if (!distinct) {
    killall(kids, RANDOM_KIDS);
    waitn(RANDOM_KIDS);
    fail("random priorities did not vary");
  }

  if (sum / RANDOM_KIDS < 20 || sum / RANDOM_KIDS > 80) {
    killall(kids, RANDOM_KIDS);
    waitn(RANDOM_KIDS);
    fail("random priority average far from 50");
  }

  for (i = 0; i < RANDOM_KIDS; i++) {
    target = (i * 9 + 7) % 101;
    if (setpriority(kids[i], target) < 0) {
      killall(kids, RANDOM_KIDS);
      waitn(RANDOM_KIDS);
      fail("set child priority");
    }
    if (getpriorityof(kids[i], &priorities[i]) < 0 || priorities[i] != target) {
      killall(kids, RANDOM_KIDS);
      waitn(RANDOM_KIDS);
      fail("read back child priority");
    }
  }

  killall(kids, RANDOM_KIDS);
  waitn(RANDOM_KIDS);
}

static void
test_chpri_command(void)
{
  int child;
  int p;

  printf("pritest: chpri command\n");

  child = fork();
  if (child < 0)
    fail("fork chpri target");
  if (child == 0)
    sleep_child(500);

  pause(1);

  check(run_chpri(child, "33") == 0, "chpri valid priority");
  check(getpriorityof(child, &p) == 0 && p == 33, "chpri did not set 33");

  check(run_chpri(child, "101") != 0, "chpri accepted 101");
  check(getpriorityof(child, &p) == 0 && p == 33, "chpri 101 changed priority");

  check(run_chpri(child, "-1") != 0, "chpri accepted -1");
  check(getpriorityof(child, &p) == 0 && p == 33, "chpri -1 changed priority");

  check(run_chpri(child, "abc") != 0, "chpri accepted abc");
  check(getpriorityof(child, &p) == 0 && p == 33, "chpri abc changed priority");

  kill(child);
  wait(0);
}

static void
priority_reporter(int start_read, int start_write, int done_read, int done_write,
                  char label)
{
  char go;

  close(start_write);
  close(done_read);

  if (read(start_read, &go, 1) == 1)
    write(done_write, &label, 1);

  close(start_read);
  close(done_write);
  exit(0);
}

static void
run_priority_round(int round)
{
  int start[2];
  int done[2];
  int pids[HIGH_KIDS + LOW_KIDS];
  int i;
  int n;
  int high_seen = 0;
  int low_seen = 0;
  int bad_first = 0;
  char c = 'x';
  char got;

  if (pipe(start) < 0 || pipe(done) < 0)
    fail("pipe priority scheduler");

  for (i = 0; i < HIGH_KIDS + LOW_KIDS; i++) {
    pids[i] = fork();
    if (pids[i] < 0) {
      killall(pids, i);
      waitn(i);
      fail("fork priority scheduler child");
    }
    if (pids[i] == 0) {
      priority_reporter(start[0], start[1], done[0], done[1],
                        i < HIGH_KIDS ? 'H' : 'L');
    }
  }

  for (i = 0; i < HIGH_KIDS; i++)
    check(setpriority(pids[i], 0) == 0, "set high child priority");
  for (i = HIGH_KIDS; i < HIGH_KIDS + LOW_KIDS; i++)
    check(setpriority(pids[i], 100) == 0, "set low child priority");

  pause(2);
  close(start[0]);
  close(done[1]);

  for (i = 0; i < HIGH_KIDS + LOW_KIDS; i++)
    check(write(start[1], &c, 1) == 1, "release priority child");
  close(start[1]);

  for (i = 0; i < HIGH_KIDS + LOW_KIDS; i++) {
    n = read(done[0], &got, 1);
    if (n != 1) {
      killall(pids, HIGH_KIDS + LOW_KIDS);
      waitn(HIGH_KIDS + LOW_KIDS);
      fail("read priority scheduler result");
    }
    if (got == 'H')
      high_seen++;
    else if (got == 'L')
      low_seen++;
    else
      bad_first = 1;

    if (i < FIRST_CHECK && got != 'H')
      bad_first = 1;
  }

  close(done[0]);
  waitn(HIGH_KIDS + LOW_KIDS);

  if (bad_first || high_seen != HIGH_KIDS || low_seen != LOW_KIDS) {
    fprintf(2, "pritest: round %d high=%d low=%d badfirst=%d\n",
            round, high_seen, low_seen, bad_first);
    fail("scheduler did not prefer high priority");
  }
}

static void
test_priority_scheduler(void)
{
  int r;

  printf("pritest: scheduler high-priority preference\n");

  for (r = 0; r < PRIORITY_ROUNDS; r++)
    run_priority_round(r);
}

static void
fair_worker(int start_read, int start_write, int done_read, int done_write,
            char label)
{
  char go;
  int last;
  int now;

  close(start_write);
  close(done_read);

  if (read(start_read, &go, 1) != 1)
    exit(1);

  last = uptime();
  for (;;) {
    now = uptime();
    if (now != last) {
      last = now;
      if (write(done_write, &label, 1) != 1)
        exit(1);
    }
  }
}

static void
fair_killer(int *pids, int n, int start_read, int start_write, int done_read,
            int done_write)
{
  int i;

  close(start_read);
  close(start_write);
  close(done_read);
  close(done_write);

  setpriority(getpid(), 0);
  pause(FAIR_TIMEOUT);

  for (i = 0; i < n; i++)
    kill(pids[i]);

  exit(0);
}

static void
test_same_priority_round_robin(void)
{
  int start[2];
  int done[2];
  int pids[FAIR_KIDS];
  int killer;
  int counts[FAIR_KIDS];
  int i;
  int gotn = 0;
  int min = FAIR_SAMPLES;
  int max = 0;
  char c = 'x';
  char got;

  printf("pritest: same-priority round-robin fairness\n");

  memset(counts, 0, sizeof(counts));

  if (pipe(start) < 0 || pipe(done) < 0)
    fail("pipe fair scheduler");

  for (i = 0; i < FAIR_KIDS; i++) {
    pids[i] = fork();
    if (pids[i] < 0) {
      killall(pids, i);
      waitn(i);
      fail("fork fair child");
    }
    if (pids[i] == 0)
      fair_worker(start[0], start[1], done[0], done[1], 'A' + i);
  }

  for (i = 0; i < FAIR_KIDS; i++)
    check(setpriority(pids[i], 50) == 0, "set fair child priority");

  killer = fork();
  if (killer < 0) {
    killall(pids, FAIR_KIDS);
    waitn(FAIR_KIDS);
    fail("fork fair killer");
  }
  if (killer == 0)
    fair_killer(pids, FAIR_KIDS, start[0], start[1], done[0], done[1]);

  pause(2);
  close(start[0]);
  close(done[1]);

  for (i = 0; i < FAIR_KIDS; i++)
    check(write(start[1], &c, 1) == 1, "release fair child");
  close(start[1]);

  while (gotn < FAIR_SAMPLES && read(done[0], &got, 1) == 1) {
    if (got >= 'A' && got < 'A' + FAIR_KIDS)
      counts[got - 'A']++;
    gotn++;
  }

  close(done[0]);
  killall(pids, FAIR_KIDS);
  kill(killer);
  waitn(FAIR_KIDS + 1);

  check(gotn >= FAIR_SAMPLES, "fair scheduler timed out");

  for (i = 0; i < FAIR_KIDS; i++) {
    if (counts[i] < min)
      min = counts[i];
    if (counts[i] > max)
      max = counts[i];
  }

  printf("pritest: fair counts");
  for (i = 0; i < FAIR_KIDS; i++)
    printf(" %d", counts[i]);
  printf("\n");

  check(min >= 1, "same-priority process starved");
  check(max <= (FAIR_SAMPLES * 3) / 4, "same-priority counts too uneven");
}

int
main(int argc, char *argv[])
{
  if (argc != 1) {
    fprintf(2, "usage: pritest\n");
    exit(1);
  }

  printf("pritest: starting\n");

  test_setpriority_syscall();
  test_child_priority_and_random();
  test_chpri_command();
  test_priority_scheduler();
  test_same_priority_round_robin();

  printf("pritest: OK\n");
  exit(0);
}
