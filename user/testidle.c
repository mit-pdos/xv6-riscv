//
// testidle.c — Unit test for Feature 4: Halt-on-Idle (CPU Idle State)
//
// Verifies:
//   1. idlestat syscall works and returns data
//   2. WFI is being used (wfi_count > 0 on at least one CPU)
//   3. Idle percentage decreases under CPU load
//   4. Idle percentage recovers after load completes
//

#include "kernel/types.h"
#include "kernel/param.h"
#include "user/user.h"

struct idleinfo {
  uint64 idle_ticks;
  uint64 total_ticks;
  uint64 wfi_count;
};

// Busy-loop to simulate CPU work
void
burn_cpu(void)
{
  volatile int x = 0;
  for(int i = 0; i < 5000000; i++){
    x = x + 1;
  }
}

int
main(int argc, char *argv[])
{
  struct idleinfo info[NCPU];
  int passed = 0;
  int failed = 0;
  uint64 load_idle_pct = 0;

  printf("\n=== Halt-on-Idle Unit Tests ===\n\n");

  // -----------------------------------------------------------
  // Test 1: idlestat syscall works
  // -----------------------------------------------------------
  printf("Test 1: idlestat syscall returns successfully... ");
  if(idlestat(info, NCPU) < 0){
    printf("FAIL (syscall returned -1)\n");
    failed++;
  } else {
    printf("PASS\n");
    passed++;
  }

  // -----------------------------------------------------------
  // Test 2: WFI has been entered at least once
  // -----------------------------------------------------------
  printf("Test 2: WFI has been used (wfi_count > 0)...     ");
  uint64 total_wfi = 0;
  for(int i = 0; i < NCPU; i++){
    total_wfi += info[i].wfi_count;
  }
  if(total_wfi > 0){
    printf("PASS (total wfi_count=%ld)\n", total_wfi);
    passed++;
  } else {
    printf("FAIL (wfi_count=0 on all CPUs)\n");
    failed++;
  }

  // -----------------------------------------------------------
  // Test 3: Scheduler loop count is non-zero
  // -----------------------------------------------------------
  printf("Test 3: Scheduler has been running (total > 0).. ");
  uint64 total_sched = 0;
  for(int i = 0; i < NCPU; i++){
    total_sched += info[i].total_ticks;
  }
  if(total_sched > 0){
    printf("PASS (total_ticks=%ld)\n", total_sched);
    passed++;
  } else {
    printf("FAIL\n");
    failed++;
  }

  // -----------------------------------------------------------
  // Test 4: Idle % decreases under CPU load
  // -----------------------------------------------------------
  printf("Test 4: Idle decreases under load...             ");

  // Snapshot before load
  struct idleinfo before[NCPU];
  idlestat(before, NCPU);
  uint64 wfi_before = 0;
  uint64 sched_before = 0;
  for(int i = 0; i < NCPU; i++){
    wfi_before += before[i].wfi_count;
    sched_before += before[i].total_ticks;
  }

  // Spawn CPU-intensive children on multiple cores
  int nchildren = 3;
  for(int i = 0; i < nchildren; i++){
    int pid = fork();
    if(pid == 0){
      burn_cpu();
      exit(0);
    }
  }

  // Wait for all children
  for(int i = 0; i < nchildren; i++){
    wait(0);
  }

  // Snapshot after load
  struct idleinfo after[NCPU];
  idlestat(after, NCPU);
  uint64 wfi_after = 0;
  uint64 sched_after = 0;
  for(int i = 0; i < NCPU; i++){
    wfi_after += after[i].wfi_count;
    sched_after += after[i].total_ticks;
  }

  // During load, the proportion of WFI entries per scheduler loop
  // should be lower than the baseline
  uint64 delta_wfi = wfi_after - wfi_before;
  uint64 delta_sched = sched_after - sched_before;

  if(delta_sched > 0){
    load_idle_pct = (delta_wfi * 100) / delta_sched;
    // With 3 busy processes on 3 CPUs, idle should be noticeably less than 100%
    if(load_idle_pct < 95){
      printf("PASS (idle during load: %ld%%)\n", load_idle_pct);
      passed++;
    } else {
      printf("FAIL (idle during load: %ld%%, expected < 95%%)\n", load_idle_pct);
      failed++;
    }
  } else {
    printf("FAIL (no scheduler ticks during load)\n");
    failed++;
  }

  // -----------------------------------------------------------
  // Test 5: Idle % recovers after load ends
  // -----------------------------------------------------------
  printf("Test 5: Idle recovers after load completes...    ");

  // Wait a bit for system to settle
  pause(10);

  struct idleinfo recovered[NCPU];
  idlestat(recovered, NCPU);
  uint64 wfi_recovered = 0;
  uint64 sched_recovered = 0;
  for(int i = 0; i < NCPU; i++){
    wfi_recovered += recovered[i].wfi_count;
    sched_recovered += recovered[i].total_ticks;
  }

  uint64 delta_wfi_r = wfi_recovered - wfi_after;
  uint64 delta_sched_r = sched_recovered - sched_after;

  if(delta_sched_r > 0){
    uint64 recovery_pct = (delta_wfi_r * 100) / delta_sched_r;
    if(recovery_pct > load_idle_pct){
      printf("PASS (idle after load: %ld%%)\n", recovery_pct);
      passed++;
    } else {
      printf("FAIL (idle after: %ld%%, during: %ld%%)\n", recovery_pct, load_idle_pct);
      failed++;
    }
  } else {
    printf("FAIL (no scheduler ticks during recovery)\n");
    failed++;
  }

  // -----------------------------------------------------------
  // Summary
  // -----------------------------------------------------------
  printf("\n--- Results ---\n");
  printf("Passed: %d / %d\n", passed, passed + failed);
  if(failed == 0){
    printf("ALL TESTS PASSED\n");
  } else {
    printf("%d TEST(S) FAILED\n", failed);
  }
  printf("\n");

  exit(0);
}
