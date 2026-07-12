#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/param.h"
#include "kernel/pinfo.h"
#include "user/user.h"

#define RANDOM_KIDS 12
#define LOCK_SPINS 6
#define LOCK_WORKERS 4
#define LOCK_ROUNDS 100
#define SPIN_START_TIMEOUT 50

#ifdef PRIORITY
#define PRIORITY_ROUNDS 5
#define HIGH_KIDS 16
#define LOW_KIDS 4
#define FIRST_CHECK 4
#define FAIR_KIDS 4
#define FAIR_SAMPLES 96
#define FAIR_TIMEOUT 400
#endif

#if defined(DEFAULT) || defined(PRIORITY)
#define RR_SPINS 6
#define RR_RUN_TICKS 60
#define RR_MAX_SPREAD 15
#endif

#ifdef LOTTERY
#define LOTTERY_KIDS 8
#define LOTTERY_LOW_KIDS 4
#define LOTTERY_HIGH_TICKETS 20
#define LOTTERY_RUN_TICKS 60
#endif

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

static int
getticketsof(int pid, int *tickets)
{
  struct pinfo info;
  int i;

  if (getpinfo(&info) < 0)
    return -1;

  i = findpid(&info, pid);
  if (i < 0)
    return -1;

  *tickets = info.tickets[i];
  return 0;
}

static int
snapshot_spins(int *pids, int n, int *runtimes)
{
  struct pinfo info;
  int i;

  if (getpinfo(&info) < 0)
    return -1;

  for (i = 0; i < n; i++) {
    int index = findpid(&info, pids[i]);

    if (index < 0 || strcmp(info.name[index], "spin") != 0)
      return -1;
    runtimes[i] = info.runtime[index];
  }
  return 0;
}

static void
report_spin_wait(int *pids, int n)
{
  struct pinfo info;
  int i;

  if (getpinfo(&info) < 0)
    return;

  for (i = 0; i < n; i++) {
    int index = findpid(&info, pids[i]);

    if (index < 0)
      fprintf(2, "pritest: missing spin pid=%d\n", pids[i]);
    else
      fprintf(2, "pritest: spin wait pid=%d name=%s state=%d\n",
              pids[i], info.name[index], info.status[index]);
  }
}

static int
wait_for_spins(int *pids, int n, int *runtimes)
{
  int i;

  for (i = 0; i < SPIN_START_TIMEOUT; i++) {
    if (snapshot_spins(pids, n, runtimes) == 0)
      return 0;
    pause(1);
  }

  report_spin_wait(pids, n);
  return -1;
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
prepare_spins(int *pids, int n, int *start)
{
  int i;

  memset(pids, 0, n * sizeof(*pids));
  if (pipe(start) < 0)
    fail("pipe spin start");

  for (i = 0; i < n; i++) {
    pids[i] = fork();
    if (pids[i] < 0) {
      close(start[0]);
      close(start[1]);
      killall(pids, i);
      waitn(i);
      fail("fork spin");
    }

    if (pids[i] == 0) {
      char go;
      char *argv[] = {"spin", 0};

      close(start[1]);
      if (read(start[0], &go, 1) != 1)
        exit(1);
      close(start[0]);
      exec("spin", argv);
      fprintf(2, "pritest: exec spin failed\n");
      exit(127);
    }
  }
}

static void
release_spins(int *start, int n)
{
  char go = 'x';
  int i;

  close(start[0]);
  for (i = 0; i < n; i++)
    check(write(start[1], &go, 1) == 1, "release spin");
  close(start[1]);
  pause(2);
}

static void
stop_spins(int *pids, int n)
{
  killall(pids, n);
  waitn(n);
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

static int
run_chtickets(int pid, char *number)
{
  int child;
  int status = -1;
  char pidbuf[16];
  char *argv[] = {"chtickets", pidbuf, number, 0};

  itoa(pid, pidbuf);

  child = fork();
  if (child < 0)
    fail("fork chtickets");

  if (child == 0) {
    exec("chtickets", argv);
    fprintf(2, "pritest: exec chtickets failed\n");
    exit(127);
  }

  check(wait(&status) == child, "wait chtickets");
  return status;
}

static void
show_ps(void)
{
  int child;
  int status = -1;
  char *argv[] = {"ps", 0};

  child = fork();
  if (child < 0)
    fail("fork ps");

  if (child == 0) {
    exec("ps", argv);
    fprintf(2, "pritest: exec ps failed\n");
    exit(127);
  }

  check(setpriority(child, 0) == 0, "set ps priority");
  check(settickets(child, 100) == 0, "set ps tickets");
  check(wait(&status) == child && status == 0, "run ps");
}

static void
sleep_child(int ticks)
{
  pause(ticks);
  exit(0);
}

static void
test_settickets_syscall_and_fork(void)
{
  int child;
  int me = getpid();
  int parent_tickets;
  int child_tickets;

  printf("pritest: settickets syscall and fork inheritance\n");

  check(getticketsof(me, &parent_tickets) == 0, "read parent tickets");
  check(parent_tickets == 1, "new process does not have one ticket");

  check(settickets(me, 17) == 0, "set parent tickets to 17");
  check(getticketsof(me, &parent_tickets) == 0 && parent_tickets == 17,
        "read back parent tickets");

  check(settickets(me, 0) < 0, "accepted zero tickets");
  check(settickets(me, -1) < 0, "accepted negative tickets");
  check(settickets(99999, 10) < 0, "accepted unknown pid");
  check(getticketsof(me, &parent_tickets) == 0 && parent_tickets == 17,
        "invalid settickets changed parent tickets");

  child = fork();
  if (child < 0)
    fail("fork ticket child");
  if (child == 0)
    sleep_child(500);

  pause(1);
  if (getticketsof(child, &child_tickets) < 0) {
    kill(child);
    wait(0);
    fail("read child tickets");
  }

  if (child_tickets != parent_tickets) {
    kill(child);
    wait(0);
    fail("child did not inherit parent tickets");
  }

  check(settickets(child, 29) == 0, "set child tickets to 29");
  check(getticketsof(child, &child_tickets) == 0 && child_tickets == 29,
        "read back child tickets");
  check(getticketsof(me, &parent_tickets) == 0 && parent_tickets == 17,
        "changing child tickets changed parent tickets");

  kill(child);
  wait(0);

  check(settickets(me, 1) == 0, "restore parent tickets");
}

static void
test_chtickets_command(void)
{
  int child;
  int tickets;

  printf("pritest: chtickets command\n");

  child = fork();
  if (child < 0)
    fail("fork chtickets target");
  if (child == 0)
    sleep_child(500);

  pause(1);

  check(run_chtickets(child, "41") == 0, "chtickets valid number");
  check(getticketsof(child, &tickets) == 0 && tickets == 41,
        "chtickets did not set 41");

  check(run_chtickets(child, "0") != 0, "chtickets accepted zero");
  check(run_chtickets(child, "-1") != 0, "chtickets accepted negative");
  check(run_chtickets(child, "abc") != 0, "chtickets accepted text");
  check(getticketsof(child, &tickets) == 0 && tickets == 41,
        "invalid chtickets changed tickets");

  kill(child);
  wait(0);
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
lock_stress_worker(int worker, int *pids, int n)
{
  struct pinfo info;
  int i;

  if (setpriority(getpid(), 0) < 0 || settickets(getpid(), 100) < 0)
    exit(1);

  for (i = 0; i < LOCK_ROUNDS; i++) {
    int target = pids[(i + worker) % n];
    int tickets = (i * 17 + worker * 11) % 97 + 1;
    int priority = (i * 13 + worker * 7) % 101;

    if (settickets(target, tickets) < 0 ||
        setpriority(target, priority) < 0 ||
        getpinfo(&info) < 0)
      exit(1);
  }

  exit(0);
}

static void
test_process_lock_stress(void)
{
  int spins[LOCK_SPINS];
  int workers[LOCK_WORKERS];
  int start[2];
  int status;
  int i;

  printf("pritest: concurrent process-lock stress\n");
  prepare_spins(spins, LOCK_SPINS, start);

  for (i = 0; i < LOCK_SPINS; i++) {
    check(setpriority(spins[i], 50) == 0, "set lock spin priority");
    check(settickets(spins[i], 10) == 0, "set lock spin tickets");
  }

  check(setpriority(getpid(), 0) == 0, "raise lock test priority");
  check(settickets(getpid(), 100) == 0, "raise lock test tickets");
  release_spins(start, LOCK_SPINS);

  memset(workers, 0, sizeof(workers));
  for (i = 0; i < LOCK_WORKERS; i++) {
    workers[i] = fork();
    if (workers[i] < 0) {
      killall(workers, i);
      killall(spins, LOCK_SPINS);
      waitn(i + LOCK_SPINS);
      fail("fork lock stress worker");
    }
    if (workers[i] == 0)
      lock_stress_worker(i, spins, LOCK_SPINS);
    check(setpriority(workers[i], 0) == 0, "set lock worker priority");
    check(settickets(workers[i], 100) == 0, "set lock worker tickets");
  }

  for (i = 0; i < LOCK_WORKERS; i++) {
    check(wait(&status) > 0, "wait lock stress worker");
    check(status == 0, "lock stress worker failed");
  }

  stop_spins(spins, LOCK_SPINS);
  check(setpriority(getpid(), 50) == 0, "restore lock test priority");
  check(settickets(getpid(), 1) == 0, "restore lock test tickets");

  printf("pritest: lock stress completed %d operations\n",
         LOCK_WORKERS * LOCK_ROUNDS * 3);
}

#ifdef PRIORITY
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
#endif

#if defined(DEFAULT) || defined(PRIORITY)
static void
test_spin_round_robin(void)
{
  int pids[RR_SPINS];
  int before[RR_SPINS];
  int after[RR_SPINS];
  int start[2];
  int min = RR_RUN_TICKS * NPROC;
  int max = 0;
  int i;

#ifdef DEFAULT
  printf("pritest: default round-robin ignores metadata\n");
#else
  printf("pritest: spin round-robin runtime\n");
#endif
  prepare_spins(pids, RR_SPINS, start);

  for (i = 0; i < RR_SPINS; i++) {
#ifdef DEFAULT
    int priority = i < RR_SPINS / 2 ? 0 : 100;
    int tickets = i < RR_SPINS / 2 ? 100 : 1;
#else
    int priority = 50;
    int tickets = 1;
#endif

    check(setpriority(pids[i], priority) == 0, "set round-robin priority");
    check(settickets(pids[i], tickets) == 0, "set round-robin tickets");
  }

  check(setpriority(getpid(), 0) == 0, "raise round-robin test priority");
  release_spins(start, RR_SPINS);
  check(wait_for_spins(pids, RR_SPINS, before) == 0,
        "wait for round-robin spins");

  pause(RR_RUN_TICKS);

  check(snapshot_spins(pids, RR_SPINS, after) == 0,
        "snapshot round-robin end");
  for (i = 0; i < RR_SPINS; i++) {
    int runtime = after[i] - before[i];

#ifdef DEFAULT
    int priority = i < RR_SPINS / 2 ? 0 : 100;
    int tickets = i < RR_SPINS / 2 ? 100 : 1;

    printf("pritest: default pid=%d priority=%d tickets=%d runtime=%d\n",
           pids[i], priority, tickets, runtime);
#else
    printf("pritest: rr pid=%d priority=50 runtime=%d\n",
           pids[i], runtime);
#endif
    if (runtime < min)
      min = runtime;
    if (runtime > max)
      max = runtime;
  }

  show_ps();
  stop_spins(pids, RR_SPINS);
  check(setpriority(getpid(), 50) == 0,
        "restore round-robin test priority");

  check(min > 0, "round-robin spin starved");
  check(max - min <= RR_MAX_SPREAD, "round-robin runtime spread too large");
}
#endif

#ifdef LOTTERY
static void
test_lottery_scheduler(void)
{
  int pids[LOTTERY_KIDS];
  int phase1_start[LOTTERY_KIDS];
  int phase1_end[LOTTERY_KIDS];
  int phase2_start[LOTTERY_KIDS];
  int phase2_end[LOTTERY_KIDS];
  int start[2];
  int phase1_low = 0;
  int phase1_high = 0;
  int phase2_low = 0;
  int phase2_high = 0;
  int i;

  printf("pritest: spin lottery weighted runtime\n");
  prepare_spins(pids, LOTTERY_KIDS, start);

  for (i = 0; i < LOTTERY_KIDS; i++) {
    check(setpriority(pids[i], 50) == 0, "set lottery spin priority");
    check(settickets(pids[i], 100) == 0, "set lottery startup tickets");
  }

  check(settickets(getpid(), 100) == 0, "raise lottery test tickets");
  release_spins(start, LOTTERY_KIDS);
  check(wait_for_spins(pids, LOTTERY_KIDS, phase1_start) == 0,
        "wait for lottery spins");

  for (i = 0; i < LOTTERY_KIDS; i++) {
    int tickets = i < LOTTERY_LOW_KIDS ? 1 : LOTTERY_HIGH_TICKETS;

    check(settickets(pids[i], tickets) == 0, "set lottery phase one tickets");
  }
  check(snapshot_spins(pids, LOTTERY_KIDS, phase1_start) == 0,
        "snapshot lottery phase one start");

  pause(LOTTERY_RUN_TICKS);

  check(snapshot_spins(pids, LOTTERY_KIDS, phase1_end) == 0,
        "snapshot lottery phase one end");
  for (i = 0; i < LOTTERY_KIDS; i++) {
    int runtime = phase1_end[i] - phase1_start[i];
    int tickets = i < LOTTERY_LOW_KIDS ? 1 : LOTTERY_HIGH_TICKETS;

    printf("pritest: lottery phase=1 pid=%d tickets=%d runtime=%d\n",
           pids[i], tickets, runtime);
    if (i < LOTTERY_LOW_KIDS)
      phase1_low += runtime;
    else
      phase1_high += runtime;
  }
  printf("pritest: lottery phase=1 low=%d high=%d\n",
         phase1_low, phase1_high);
  show_ps();

  for (i = 0; i < LOTTERY_KIDS; i++) {
    int tickets = i < LOTTERY_LOW_KIDS ? LOTTERY_HIGH_TICKETS : 1;

    check(settickets(pids[i], tickets) == 0, "set lottery phase two tickets");
  }
  check(snapshot_spins(pids, LOTTERY_KIDS, phase2_start) == 0,
        "snapshot lottery phase two start");

  pause(LOTTERY_RUN_TICKS);

  check(snapshot_spins(pids, LOTTERY_KIDS, phase2_end) == 0,
        "snapshot lottery phase two end");
  for (i = 0; i < LOTTERY_KIDS; i++) {
    int runtime = phase2_end[i] - phase2_start[i];
    int tickets = i < LOTTERY_LOW_KIDS ? LOTTERY_HIGH_TICKETS : 1;

    printf("pritest: lottery phase=2 pid=%d tickets=%d runtime=%d\n",
           pids[i], tickets, runtime);
    if (i < LOTTERY_LOW_KIDS)
      phase2_high += runtime;
    else
      phase2_low += runtime;
  }
  printf("pritest: lottery phase=2 low=%d high=%d\n",
         phase2_low, phase2_high);
  show_ps();

  stop_spins(pids, LOTTERY_KIDS);
  check(settickets(getpid(), 1) == 0, "restore lottery test tickets");

  check(phase1_high > phase1_low * 2,
        "phase one tickets did not increase CPU time");
  check(phase2_high > phase2_low * 2,
        "phase two tickets did not increase CPU time");
}
#endif

int
main(int argc, char *argv[])
{
  if (argc != 1) {
    fprintf(2, "usage: pritest\n");
    exit(1);
  }

  printf("pritest: starting\n");

  test_settickets_syscall_and_fork();
  test_chtickets_command();
  test_setpriority_syscall();
  test_child_priority_and_random();
  test_chpri_command();
  test_process_lock_stress();

#ifdef PRIORITY
  test_priority_scheduler();
  test_same_priority_round_robin();
#endif

#if defined(DEFAULT) || defined(PRIORITY)
  test_spin_round_robin();
#endif

#ifdef LOTTERY
  test_lottery_scheduler();
#endif

  printf("pritest: OK\n");
  exit(0);
}
