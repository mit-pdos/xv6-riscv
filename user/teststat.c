#include "kernel/pstat.h"
#include "kernel/types.h"
#include "user/user.h"

#define NCHILDREN 7

#define SHORT_WORK  100000000
#define MEDIUM_WORK 200000000
#define LONG_WORK   400000000

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

int
cpu_work(int iterations)
{
  volatile uint64 x = 0;

  for (int i = 0; i < iterations; i++) {
    x += (uint64)i;
  }

  return x;
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

void
print_fixed2(int value_x100)
{
  int fractional = value_x100 % 100;

  printf("%d.", value_x100 / 100);
  if (fractional < 10)
    printf("0");
  printf("%d", fractional);
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

  pause(ARRIVAL_DELAY);

  create_child(CHILD_B, MEDIUM_WORK, 20);

  pause(ARRIVAL_DELAY);

  create_child(CHILD_C, LONG_WORK, 30);

  pause(ARRIVAL_DELAY);

  create_child(CHILD_D, SHORT_WORK, 40);

  pause(ARRIVAL_DELAY);

  create_child(CHILD_E, LONG_WORK, 50);
  create_child(CHILD_F, LONG_WORK, 60);

  pause(ARRIVAL_DELAY);

  // Child with weight
  int pid = fork();

  if (pid < 0) {
    printf("fork failed\n");
    exit(1);
  }

  if (pid == 0) {
    if (setweight(25) != 0)
      exit(1);

    pause(ARRIVAL_DELAY);

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
  printf("\nAll basic stats tests passed!\n");
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

  assert(results[CHILD_D].arrival < results[CHILD_E].arrival,
        "E should arrive after D");

  printf("\nAll arrival order tests passed!\n");
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

  printf("\nAll wait stats tests passed!\n");
}
void
test_weight_stats(void)
{
  assert(results[CHILD_WEIGHT].weight == 25,
        "Valid weight should be preserved");

  printf("\nAll weight stats tests passed!\n");
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

  int turn_around_time = 0;
  int response_time = 0;
  int first_arrival = results[0].arrival;
  int last_exit = results[0].etime;
  int total_dispatches = 0;
  int waiting_processes = 0;
  uint64 total_run_ticks = 0;
  uint64 squared_run_ticks = 0;

  for (int i = 0; i < NCHILDREN; i++) {
    turn_around_time += results[i].etime - results[i].arrival;
    response_time += results[i].first_run - results[i].arrival;

    if (results[i].arrival < first_arrival)
      first_arrival = results[i].arrival;
    if (results[i].etime > last_exit)
      last_exit = results[i].etime;

    total_dispatches += results[i].sched_count;
    if (results[i].max_wait > 0)
      waiting_processes++;

    total_run_ticks += results[i].run_ticks;
    squared_run_ticks += (uint64)results[i].run_ticks *
                         (uint64)results[i].run_ticks;

    print_stats(&results[i]);
  }

  int avg_turnaround_x100 = (turn_around_time * 100) / NCHILDREN;
  int avg_response_x100 = (response_time * 100) / NCHILDREN;

  printf("Average turnaround time: ");
  print_fixed2(avg_turnaround_x100);
  printf(" ticks\n");

  printf("Average response time: ");
  print_fixed2(avg_response_x100);
  printf(" ticks\n");

  int elapsed_ticks = last_exit - first_arrival;
  int throughput_x100 = 0;
  if (elapsed_ticks > 0)
    throughput_x100 = (NCHILDREN * 100) / elapsed_ticks;

  printf("Throughput: ");
  print_fixed2(throughput_x100);
  printf(" processes/tick\n");

  printf("Total scheduling dispatches: %d\n", total_dispatches);

  printf("Processes that experienced CPU waiting: %d/%d\n",
         waiting_processes, NCHILDREN);

  if (squared_run_ticks > 0) {
    uint64 fairness_x100 =
      (total_run_ticks * total_run_ticks * 100) /
      ((uint64)NCHILDREN * squared_run_ticks);
    printf("CPU-time fairness (Jain index): ");
    print_fixed2((int)fairness_x100);
    printf("\n");
  }

  test_basic_stats();
  test_arrival_order();
  test_wait_stats();
  test_weight_stats();

  printf("\n================================\n");
  printf(" ALL TESTS PASSED!\n");
  printf("================================\n");

  exit(0);
}
