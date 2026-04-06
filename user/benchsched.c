// benchsched — scheduler benchmark for xv6
//
// Forks CPU-bound and I/O-bound worker processes, collects per-process
// scheduling statistics via getprocstat(), and prints a comparison table.
//
// Usage: benchsched [ncpu [nio [cpu_iters [io_rounds]]]]
//   ncpu      number of CPU-bound workers (default 6)
//   nio       number of I/O-bound workers (default 8)
//   cpu_iters LCG iterations per CPU worker (default 100M; ~10-30 ticks each)
//   io_rounds sleep(3) cycles per I/O worker (default 5)
//
// Design: CPU workers do ~100M iterations → spend 10-30+ ticks computing,
// getting preempted multiple times and sinking through MLFQ priority levels.
// IO workers each do 5 rounds of sleep(3) → short bursts, stay high-priority.

#include "kernel/types.h"
#include "kernel/procstat.h"
#include "kernel/fcntl.h"
#include "user/user.h"

#define MAX_WORKERS 20
#define DEFAULT_NCPU      6
#define DEFAULT_NIO       8
#define DEFAULT_CPU_ITERS 100000000   // 100 million
#define DEFAULT_IO_ROUNDS 5

// Result written by each worker to the pipe before exiting.
// Kept global to avoid blowing xv6's single-page user stack (4KB).
struct result {
  int  pid;
  int  type;            // 0 = CPU-bound, 1 = I/O-bound
  uint response_time;
  uint turnaround_time;
  uint total_wait_time;
  uint context_switches;
  uint total_runtime;
  uint64 io_count;
};

// Global to avoid blowing the single-page (4 KB) user stack.
static struct result results[MAX_WORKERS];
// Global to prevent compiler register aliasing with cpu_iters (both are int,
// compiler may reuse the same register; BSS guarantees zero-init each run).
static int nresults;

static void
cpu_worker(int iters, int pipefd)
{
  // CPU-bound: tight LCG loop — spends many ticks computing, gets preempted
  // repeatedly, and sinks through MLFQ priority levels as its quantum drains.
  volatile uint64 x = 1;
  for(int i = 0; i < iters; i++)
    x = x * 6364136223846793005ULL + 1442695040888963407ULL;
  (void)x;

  struct procstat ps;
  getprocstat(-1, &ps);

  struct result r;
  r.pid             = ps.pid;
  r.type            = 0;
  r.response_time   = ps.response_time;
  r.turnaround_time = ps.turnaround_time;
  r.total_wait_time = ps.total_wait_time;
  r.context_switches= ps.context_switches;
  r.total_runtime   = ps.total_runtime;
  r.io_count        = ps.io_count;

  write(pipefd, &r, sizeof(r));
  exit(0);
}

static void
io_worker(int rounds, int pipefd)
{
  // I/O-bound: repeatedly sleep to simulate short I/O bursts.
  // After each sleep the process wakes at high priority (MLFQ boost).
  for(int i = 0; i < rounds; i++)
    sleep(3);

  struct procstat ps;
  getprocstat(-1, &ps);

  struct result r;
  r.pid             = ps.pid;
  r.type            = 1;
  r.response_time   = ps.response_time;
  r.turnaround_time = ps.turnaround_time;
  r.total_wait_time = ps.total_wait_time;
  r.context_switches= ps.context_switches;
  r.total_runtime   = ps.total_runtime;
  r.io_count        = ps.io_count;

  write(pipefd, &r, sizeof(r));
  exit(0);
}

static int
xatoi(const char *s)
{
  int n = 0;
  while(*s >= '0' && *s <= '9')
    n = n * 10 + (*s++ - '0');
  return n;
}

int
main(int argc, char *argv[])
{
  int ncpu      = DEFAULT_NCPU;
  int nio       = DEFAULT_NIO;
  int cpu_iters = DEFAULT_CPU_ITERS;
  int io_rounds = DEFAULT_IO_ROUNDS;

  if(argc > 1) ncpu      = xatoi(argv[1]);
  if(argc > 2) nio       = xatoi(argv[2]);
  if(argc > 3) cpu_iters = xatoi(argv[3]);
  if(argc > 4) io_rounds = xatoi(argv[4]);

  int nworkers = ncpu + nio;
  if(nworkers > MAX_WORKERS){
    printf("benchsched: too many workers (max %d)\n", MAX_WORKERS);
    exit(1);
  }

  // Create pipe for collecting results.
  int pipefd[2];
  if(pipe(pipefd) < 0){
    printf("benchsched: pipe failed\n");
    exit(1);
  }

  // Record system state before benchmark.
  struct sysstats pre, post;
  getsysstats(&pre);
  uint t_start = uptime();

  printf("\n=== SCHEDULER BENCHMARK ===\n");
  printf("Workers: %d CPU-bound + %d IO-bound\n", ncpu, nio);
  printf("CPU iters: %d  IO rounds: %d\n\n", cpu_iters, io_rounds);

  // Fork all workers.
  for(int i = 0; i < ncpu + nio; i++){
    int pid = fork();
    if(pid < 0){
      printf("benchsched: fork failed\n");
      exit(1);
    }
    if(pid == 0){
      // Child: close read end, do work, write result, exit.
      close(pipefd[0]);
      if(i < ncpu)
        cpu_worker(cpu_iters, pipefd[1]);
      else
        io_worker(io_rounds, pipefd[1]);
      // not reached
    }
  }

  // Parent: close write end so we can detect EOF when all children exit.
  close(pipefd[1]);

  // Interleave wait() and read(): each child writes its result BEFORE calling
  // exit(), so after wait() returns we can always read one completed result.
  // This avoids deadlock if the pipe buffer fills up with many workers.
  nresults = 0;
  for(int i = 0; i < nworkers; i++){
    wait(0);
    if(nresults < MAX_WORKERS){
      int n = read(pipefd[0], &results[nresults], sizeof(struct result));
      if(n == (int)sizeof(struct result))
        nresults++;
    }
  }

  uint t_end = uptime();
  getsysstats(&post);

  close(pipefd[0]);

  // --- Print per-process table ---
  printf("PID  TYPE  RESP  TURN  WAIT  CTXSW  RUNTIME  IO\n");
  printf("---  ----  ----  ----  ----  -----  -------  --\n");

  // Aggregate accumulators.
  uint sum_resp_cpu = 0, sum_turn_cpu = 0, sum_wait_cpu = 0, cnt_cpu = 0;
  uint sum_resp_io  = 0, sum_turn_io  = 0, sum_wait_io  = 0, cnt_io  = 0;
  uint sum_ctx = 0;

  for(int i = 0; i < nresults; i++){
    struct result *r = &results[i];
    printf("%d  %s  %d  %d  %d  %d  %d  %d\n",
           r->pid,
           r->type == 0 ? "CPU" : "IO",
           r->response_time,
           r->turnaround_time,
           r->total_wait_time,
           r->context_switches,
           r->total_runtime,
           (int)r->io_count);
    sum_ctx += r->context_switches;
    if(r->type == 0){
      sum_resp_cpu += r->response_time;
      sum_turn_cpu += r->turnaround_time;
      sum_wait_cpu += r->total_wait_time;
      cnt_cpu++;
    } else {
      sum_resp_io  += r->response_time;
      sum_turn_io  += r->turnaround_time;
      sum_wait_io  += r->total_wait_time;
      cnt_io++;
    }
  }

  uint elapsed = t_end > t_start ? t_end - t_start : 1;

  // --- Print summary ---
  printf("\n--- CPU-bound summary (%d workers) ---\n", cnt_cpu);
  if(cnt_cpu > 0){
    printf("  Avg response:   %d ticks\n", sum_resp_cpu / cnt_cpu);
    printf("  Avg turnaround: %d ticks\n", sum_turn_cpu / cnt_cpu);
    printf("  Avg wait:       %d ticks\n", sum_wait_cpu / cnt_cpu);
  }

  printf("\n--- IO-bound summary (%d workers) ---\n", cnt_io);
  if(cnt_io > 0){
    printf("  Avg response:   %d ticks\n", sum_resp_io / cnt_io);
    printf("  Avg turnaround: %d ticks\n", sum_turn_io / cnt_io);
    printf("  Avg wait:       %d ticks\n", sum_wait_io / cnt_io);
  }

  printf("\n--- System-wide ---\n");
  printf("  Elapsed:           %d ticks\n", elapsed);
  printf("  Total processes:   %d\n", nworkers);
  printf("  Throughput:        %d proc / 100 ticks\n",
         elapsed > 0 ? (nworkers * 100) / elapsed : 0);
  printf("  Ctx switches (all):%d\n", sum_ctx);
  printf("  Sys ctx switches:  %d\n",
         (int)(post.total_context_switches - pre.total_context_switches));
  printf("  Total CPU time:    %d ticks\n",
         (int)(post.total_cpu_time - pre.total_cpu_time));

  printf("\n=== END BENCHMARK ===\n\n");
  exit(0);
}
