#include "kernel/pstat.h"
#include "kernel/types.h"
#include "user/user.h"

#define NCHILDREN 7

#define SHORT_WORK  1000000
#define MEDIUM_WORK 5000000
#define LONG_WORK   15000000

#define ARRIVAL_DELAY 10
#define SLEEP_DURATION 20

#define CHILD_A       0
#define CHILD_B       1
#define CHILD_C       2
#define CHILD_D       3
#define CHILD_E       4
#define CHILD_F       5
#define CHILD_WEIGHT  6

int pids[NCHILDREN];
struct pstat results[NCHILDREN];
int exit_statuses[NCHILDREN];
int expected_status[NCHILDREN] = {
  10, 20, 30, 40, 50, 60, 70
};

void
cpu_work(int iterations)
{
  volatile uint64 x = 0;

  for (int i = 0; i < iterations; i++) {
    x += (uint64)i;
  }
}

void
assert(int condition, char *message)
{
  if (!condition) {
    printf("FAIL: %s\n", message);
    exit(1);
  }
}

void
print_stats(struct pstat *s)
{
  printf("\n");
  printf("  PID:            %d\n", s->pid);
  printf("  arrival_time:   %d\n", s->arrival);
  printf("  first_run:      %d\n", s->first_run);
  printf("  etime:          %d\n", s->etime);

  printf("  run_ticks:      %d\n", s->run_ticks);
  printf("  runnable_ticks: %d\n", s->runnable_ticks);
  printf("  sleep_ticks:    %d\n", s->sleep_ticks);

  printf("  sched_count:    %d\n", s->sched_count);

  printf("  max_wait:       %d\n", s->max_wait);
  printf("  cur_wait:       %d\n", s->cur_wait);
  printf("  weight:         %d\n", s->weight);
}

int
create_child(int index, int workload, int exit_code)
{
  int pid = fork();

  if (pid < 0) {
    printf("fork failed\n");
    exit(1);
  }

  if (pid == 0) {
    cpu_work(workload);
    exit(exit_code);
  }

  pids[index] = pid;
  return pid;
}

void
init_process(void)
{
  create_child(CHILD_A, SHORT_WORK, 10);

  sleep(ARRIVAL_DELAY);

  create_child(CHILD_B, MEDIUM_WORK, 20);

  sleep(ARRIVAL_DELAY);

  create_child(CHILD_C, LONG_WORK, 30);

  sleep(ARRIVAL_DELAY);

  // Child D
  int pid = fork();

  if (pid < 0) {
    printf("fork failed\n");
    exit(1);
  }

  if (pid == 0) {
    sleep(SLEEP_DURATION);
    cpu_work(MEDIUM_WORK);
    exit(40);
  }

  pids[CHILD_D] = pid;

  sleep(ARRIVAL_DELAY);

  create_child(CHILD_E, LONG_WORK, 50);
  create_child(CHILD_F, LONG_WORK, 60);

  sleep(ARRIVAL_DELAY);

  // Child with weight
  pid = fork();

  if (pid < 0) {
    printf("fork failed\n");
    exit(1);
  }

  if (pid == 0) {
    if (setweight(25) != 0)
      exit(1);

    sleep(ARRIVAL_DELAY);

    cpu_work(MEDIUM_WORK);

    exit(70);
  }

  pids[CHILD_WEIGHT] = pid;
}

void
collect_results(void)
{
  int completed = 0;

  while (completed < NCHILDREN) {
    struct pstat stats;
    int status;
    int pid = waitstat(&status, &stats);

    if (pid < 0) {
      printf("waitstat failed\n");
      exit(1);
    }

    int i;

    for (i = 0; i < NCHILDREN; i++) {
      if (pids[i] == pid) break;
    }

    assert(i < NCHILDREN, "Unexpected child PID");

    results[i] = stats;
    exit_statuses[i] = status;

    completed++;

    printf("Collected child PID %d\n", pid);
  }
}

void
test_basic_stats(void)
{
  for (int i = 0; i < NCHILDREN; i++) {
    struct pstat *s = &results[i];

    assert(s->pid == pids[i],
           "Incorrect PID");

    assert(exit_statuses[i] == expected_status[i],
           "Incorrect exit status");

    assert(s->arrival <= s->first_run,
          "Arrival must not occur after first run");

    assert(s->first_run <= s->etime,
           "First run must not occur after completion");

    assert(s->run_ticks > 0,
           "Process should accumulate CPU time");

    assert(s->runnable_ticks >= 0,
          "Runnable ticks cannot be negative");

    assert(s->sleep_ticks >= 0,
          "Sleep ticks cannot be negative");

    assert(s->sched_count > 0,
          "Process should be scheduled at least once");
  }
}

void
test_arrival_order(void)
{
  assert(results[CHILD_A].arrival < results[CHILD_B].arrival,
        "B should arrive after A");

  assert(results[CHILD_B].arrival < results[CHILD_C].arrival,
        "C should arrive after B");

  assert(results[CHILD_C].arrival < results[CHILD_D].arrival,
        "D should arrive after C");
}

void
test_sleep_ticks(void)
{
  assert(results[CHILD_D].sleep_ticks > 0,
        "D should accumulate sleep ticks");

  assert(results[CHILD_A].sleep_ticks == 0,
        "A should not accumulate sleep ticks");

  assert(results[CHILD_B].sleep_ticks == 0,
        "B should not accumulate sleep ticks");

  assert(results[CHILD_C].sleep_ticks == 0,
        "C should not accumulate sleep ticks");

  assert(results[CHILD_E].sleep_ticks == 0,
        "E should not accumulate sleep ticks");

  assert(results[CHILD_F].sleep_ticks == 0,
        "F should not accumulate sleep ticks");
}

void
test_wait_stats(void)
{
  for (int i = 0; i < NCHILDREN; i++) {
    struct pstat *s = &results[i];

    assert(s->max_wait >= 0,
          "max_wait cannot be negative");

    assert(s->cur_wait >= 0,
          "cur_wait cannot be negative");

    assert(s->max_wait >= s->cur_wait,
          "max_wait must be >= cur_wait");
  }

  assert(results[CHILD_E].max_wait > 0,
        "E should experience CPU waiting");

  assert(results[CHILD_F].max_wait > 0,
        "F should experience CPU waiting");

  printf("Wait accounting passed\n");
}
void
test_weight_stats(void)
{
  printf("\n[TEST 8] Weight accounting\n");

  assert(results[CHILD_WEIGHT].weight == 25,
        "Valid weight should be preserved");

  printf("Weight accounting passed\n");
}

void
print_derived_metrics(void)
{
  int total_response_time = 0;
  int total_turnaround_time = 0;

  for (int i = 0; i < NCHILDREN; i++) {
    struct pstat *s = &results[i];

    int response_time =
      s->first_run - s->arrival;

    int turnaround_time =
      s->etime - s->arrival;

    total_response_time += response_time;
    total_turnaround_time += turnaround_time;

    assert(response_time >= 0,
          "Response time cannot be negative");

    assert(turnaround_time >= 0,
          "Turnaround time cannot be negative");

    printf("PID %d: response=%d, turnaround=%d\n",
           s->pid,
           response_time,
           turnaround_time);
  }

  printf("Average response time: %.2f\n", (float)(total_response_time) / (float)(NCHILDREN));
  printf("Average turnaround time: %.2f\n", (float)(total_turnaround_time) / (float)(NCHILDREN));
}

int
main(void)
{
  printf("\n================================\n");
  printf("     XV6 SCHEDULER TEST\n");
  printf("================================\n");

  init_process();
  collect_results();

  printf("\n========== ALL RESULTS ==========\n");

  for (int i = 0; i < NCHILDREN; i++)
    print_stats(&results[i]);

  test_basic_stats();
  test_arrival_order();
  test_sleep_ticks();
  test_wait_stats();
  test_weight_stats();
  print_derived_metrics();

  printf("\n================================\n");
  printf(" ALL TESTS PASSED!\n");
  printf("================================\n");

  exit(0);
}
