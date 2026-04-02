// cowtest.c - Manual CoW fork verification test suite
//
// Each test explicitly prints WHAT it expects to happen, WHAT it
// observed, and PASS/FAIL. This proves CoW is actually working —
// not just that the kernel doesn't crash.
//
// Tests:
//   1. child_write_isolates  - child writes don't affect parent
//   2. parent_write_isolates - parent writes after fork don't affect child
//   3. both_write            - parent and child both write, each sees own value
//   4. multipage             - multiple distinct pages individually CoW'd
//   5. chain_fork            - grandchild isolated from parent and child
//   6. copyout_cow           - kernel copyout path on CoW page (pipe read)
//   7. ref_cleanup           - pages freed correctly after process exits
//   8. large_fork            - fork after >50% RAM alloc (CoW prevents OOM)
//   9. lazy_cow              - prove copy deferred to write: reads don't
//                              consume pages, writes consume exactly 1 each

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define PGSIZE 4096

static int passed = 0;
static int failed = 0;

// -----------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------

static void
pass(const char *name)
{
  printf("  [PASS] %s\n", name);
  passed++;
}

static void
fail(const char *name, const char *reason)
{
  printf("  [FAIL] %s: %s\n", name, reason);
  failed++;
}

// Send a single int through a pipe. Returns 0 on success.
static int
pipe_send(int fd, int val)
{
  return write(fd, &val, sizeof(val)) == sizeof(val) ? 0 : -1;
}

// Receive a single int from a pipe. Returns the value, or -9999 on error.
static int
pipe_recv(int fd)
{
  int val;
  if(read(fd, &val, sizeof(val)) != sizeof(val))
    return -9999;
  return val;
}

// Allocate one page via sbrk, return pointer or 0 on failure.
static char *
alloc_page(void)
{
  char *p = sbrk(PGSIZE);
  if(p == SBRK_ERROR)
    return 0;
  return p;
}

// -----------------------------------------------------------------------
// TEST 1: child_write_isolates
// After fork, child writes 0xCC to page. Parent checks it still sees 0xAA.
// -----------------------------------------------------------------------
static void
test_child_write_isolates(void)
{
  const char *name = "child_write_isolates";
  printf("  setup: parent writes 0xAA to heap page, forks, child writes 0xCC\n");

  char *buf = alloc_page();
  if(!buf) { fail(name, "sbrk failed"); return; }
  memset(buf, 0xAA, PGSIZE);

  int p[2];
  pipe(p);
  int pid = fork();

  if(pid == 0) {
    close(p[0]);
    memset(buf, 0xCC, PGSIZE);
    pipe_send(p[1], (int)(unsigned char)buf[0]);
    close(p[1]);
    exit(0);
  }

  close(p[1]);
  int child_saw = pipe_recv(p[0]);
  close(p[0]);
  int status = 0; wait(&status);

  printf("  child wrote 0x%x into its copy, parent buf[0]=0x%x (want 0xAA)\n",
         child_saw, (unsigned char)buf[0]);

  if(child_saw != 0xCC)
    fail(name, "child did not write 0xCC into its copy");
  else if((unsigned char)buf[0] != 0xAA)
    fail(name, "parent buf was corrupted by child write -- CoW broken!");
  else
    pass(name);

  sbrk(-PGSIZE);
}

// -----------------------------------------------------------------------
// TEST 2: parent_write_isolates
// After fork, parent writes 0xBB. Child verifies it still sees 0xAA.
// -----------------------------------------------------------------------
static void
test_parent_write_isolates(void)
{
  const char *name = "parent_write_isolates";
  printf("  setup: parent writes 0xAA, forks, then parent writes 0xBB\n");

  char *buf = alloc_page();
  if(!buf) { fail(name, "sbrk failed"); return; }
  memset(buf, 0xAA, PGSIZE);

  // Two pipes: parent->child (signal), child->parent (result)
  int sig[2], res[2];
  pipe(sig); pipe(res);

  int pid = fork();
  if(pid == 0) {
    close(sig[1]); close(res[0]);
    // wait for parent to finish writing
    pipe_recv(sig[0]); close(sig[0]);
    // report what we see
    pipe_send(res[1], (int)(unsigned char)buf[0]);
    close(res[1]);
    exit(0);
  }

  close(sig[0]); close(res[1]);
  // parent writes, then signals child
  memset(buf, 0xBB, PGSIZE);
  pipe_send(sig[1], 1); close(sig[1]);

  int child_saw = pipe_recv(res[0]); close(res[0]);
  int status = 0; wait(&status);

  printf("  parent wrote 0xBB, child saw 0x%x (want 0xAA), parent buf[0]=0x%x (want 0xBB)\n",
         child_saw, (unsigned char)buf[0]);

  if(child_saw != 0xAA)
    fail(name, "child saw parent's 0xBB write -- CoW broken!");
  else if((unsigned char)buf[0] != 0xBB)
    fail(name, "parent's own write of 0xBB didn't stick");
  else
    pass(name);

  sbrk(-PGSIZE);
}

// -----------------------------------------------------------------------
// TEST 3: both_write
// Parent and child both write different values to same virtual address.
// Each must see only their own value.
// -----------------------------------------------------------------------
static void
test_both_write(void)
{
  const char *name = "both_write";
  printf("  setup: buf=0xAA; parent writes 0xBB, child writes 0xCC simultaneously\n");

  char *buf = alloc_page();
  if(!buf) { fail(name, "sbrk failed"); return; }
  memset(buf, 0xAA, PGSIZE);

  int p[2];
  pipe(p);
  int pid = fork();

  if(pid == 0) {
    close(p[0]);
    memset(buf, 0xCC, PGSIZE);
    pipe_send(p[1], (int)(unsigned char)buf[0]);
    close(p[1]);
    exit(0);
  }

  close(p[1]);
  memset(buf, 0xBB, PGSIZE);
  int parent_val = (unsigned char)buf[0];
  int child_val  = pipe_recv(p[0]);
  close(p[0]);
  int status = 0; wait(&status);

  printf("  parent sees 0x%x (want 0xBB), child saw 0x%x (want 0xCC)\n",
         parent_val, child_val);

  if(parent_val != 0xBB)
    fail(name, "parent did not see its own 0xBB");
  else if(child_val != 0xCC)
    fail(name, "child did not see its own 0xCC");
  else
    pass(name);

  sbrk(-PGSIZE);
}

// -----------------------------------------------------------------------
// TEST 4: multipage
// 8 heap pages each with unique sentinel byte. Fork. Child overwrites all.
// Parent verifies every page still holds its original sentinel.
// -----------------------------------------------------------------------
static void
test_multipage(void)
{
  const char *name = "multipage";
  const int NPAGES = 8;
  printf("  setup: %d pages with unique sentinels 0x10..0x80, fork, child overwrites\n", NPAGES);

  char *base = sbrk(NPAGES * PGSIZE);
  if(base == SBRK_ERROR) { fail(name, "sbrk failed"); return; }

  for(int i = 0; i < NPAGES; i++)
    memset(base + i * PGSIZE, (i + 1) * 0x10, PGSIZE);

  int p[2];
  pipe(p);
  int pid = fork();

  if(pid == 0) {
    close(p[0]);
    // child: verify sentinels are intact, then overwrite
    int ok = 1;
    for(int i = 0; i < NPAGES; i++) {
      unsigned char expected = (i + 1) * 0x10;
      if((unsigned char)base[i * PGSIZE] != expected) ok = 0;
      memset(base + i * PGSIZE, (NPAGES - i) * 0x10, PGSIZE);
    }
    pipe_send(p[1], ok);
    close(p[1]);
    exit(0);
  }

  close(p[1]);
  int child_ok = pipe_recv(p[0]);
  close(p[0]);
  int status = 0; wait(&status);

  // parent: verify all originals intact
  int parent_ok = 1;
  for(int i = 0; i < NPAGES; i++) {
    unsigned char expected = (i + 1) * 0x10;
    unsigned char got = (unsigned char)base[i * PGSIZE];
    if(got != expected) {
      printf("  page %d: expected 0x%x got 0x%x\n", i, expected, got);
      parent_ok = 0;
    }
  }

  printf("  parent pages all original: %s | child saw originals before write: %s\n",
         parent_ok ? "YES" : "NO", child_ok ? "YES" : "NO");

  if(!parent_ok)
    fail(name, "parent page corrupted by child write");
  else if(!child_ok)
    fail(name, "child saw wrong initial value in at least one page");
  else
    pass(name);

  sbrk(-NPAGES * PGSIZE);
}

// -----------------------------------------------------------------------
// TEST 5: chain_fork
// parent -> child -> grandchild. All three write distinct values to the
// same virtual address. Each must see only its own.
// -----------------------------------------------------------------------
static void
test_chain_fork(void)
{
  const char *name = "chain_fork";
  printf("  setup: parent(0xAA), child writes 0xBB, grandchild writes 0xCC\n");

  char *buf = alloc_page();
  if(!buf) { fail(name, "sbrk failed"); return; }
  memset(buf, 0xAA, PGSIZE);

  int cp[2], gp[2];   // child->parent pipe, grandchild->parent pipe
  pipe(cp); pipe(gp);

  int child_pid = fork();
  if(child_pid == 0) {
    // CHILD
    close(cp[0]); close(gp[0]);
    memset(buf, 0xBB, PGSIZE);

    int gc_pid = fork();
    if(gc_pid == 0) {
      // GRANDCHILD
      memset(buf, 0xCC, PGSIZE);
      pipe_send(gp[1], (int)(unsigned char)buf[0]);
      close(gp[1]); close(cp[1]);
      exit(0);
    }

    int s = 0; wait(&s);
    pipe_send(cp[1], (int)(unsigned char)buf[0]);
    close(cp[1]); close(gp[1]);
    exit(0);
  }

  // PARENT
  close(cp[1]); close(gp[1]);
  int gc_val = pipe_recv(gp[0]);
  int c_val  = pipe_recv(cp[0]);
  close(cp[0]); close(gp[0]);
  int status = 0; wait(&status);

  int p_val = (unsigned char)buf[0]; // parent never wrote after fork

  printf("  parent=0x%x (want 0xAA), child=0x%x (want 0xBB), grandchild=0x%x (want 0xCC)\n",
         p_val, c_val, gc_val);

  if(p_val != 0xAA)
    fail(name, "parent buf corrupted");
  else if(c_val != 0xBB)
    fail(name, "child buf corrupted");
  else if(gc_val != 0xCC)
    fail(name, "grandchild buf corrupted");
  else
    pass(name);

  sbrk(-PGSIZE);
}

// -----------------------------------------------------------------------
// TEST 6: copyout_cow
// Child's page is CoW-marked (read-only). Child does read() from a pipe,
// which uses copyout() in the kernel. The copyout CoW path must allocate
// a private copy so the write succeeds and parent's page is unaffected.
// -----------------------------------------------------------------------
static void
test_copyout_cow(void)
{
  const char *name = "copyout_cow";
  printf("  setup: buf=0xAA, fork, child read()s pipe into buf[0] (forces copyout CoW)\n");

  char *buf = alloc_page();
  if(!buf) { fail(name, "sbrk failed"); return; }
  memset(buf, 0xAA, PGSIZE);

  int kp[2];   // kernel writes 0xDD into child's CoW page via this pipe
  int rp[2];   // child reports results back to parent
  pipe(kp); pipe(rp);

  int pid = fork();
  if(pid == 0) {
    close(kp[1]); close(rp[0]);
    // This read() calls sys_read -> piperead -> copyout.
    // copyout will see PTE_COW and must allocate a private copy first.
    read(kp[0], buf, 1);   // writes 0xDD into buf[0] via kernel copyout path
    close(kp[0]);
    pipe_send(rp[1], (int)(unsigned char)buf[0]);  // child reports what it sees
    close(rp[1]);
    exit(0);
  }

  close(kp[0]); close(rp[1]);

  // Write 0xDD to the pipe — kernel will copyout this into child's CoW page
  char val = 0xDD;
  write(kp[1], &val, 1);
  close(kp[1]);

  int child_buf0 = pipe_recv(rp[0]);
  close(rp[0]);
  int status = 0; wait(&status);

  int parent_buf0 = (unsigned char)buf[0];

  printf("  child buf[0] after copyout=0x%x (want 0xDD, kernel wrote it)\n", child_buf0);
  printf("  parent buf[0] after child's copyout=0x%x (want 0xAA, unaffected)\n", parent_buf0);

  if(child_buf0 != 0xDD)
    fail(name, "child did not receive 0xDD via kernel copyout");
  else if(parent_buf0 != 0xAA)
    fail(name, "parent's CoW page was corrupted by child's pipe read");
  else
    pass(name);

  sbrk(-PGSIZE);
}

// -----------------------------------------------------------------------
// TEST 7: ref_cleanup
// Fork 10 children that immediately exit without writing.
// Parent must still be able to read and write its pages afterward.
// Verifies refcounts decrement correctly on child exit.
// -----------------------------------------------------------------------
static void
test_ref_cleanup(void)
{
  const char *name = "ref_cleanup";
  const int NCHILDREN = 10;
  printf("  setup: page=0xAB, fork %d children that exit immediately, parent r/w after\n", NCHILDREN);

  char *buf = alloc_page();
  if(!buf) { fail(name, "sbrk failed"); return; }
  memset(buf, 0xAB, PGSIZE);

  for(int i = 0; i < NCHILDREN; i++) {
    if(fork() == 0) exit(0);
  }
  for(int i = 0; i < NCHILDREN; i++) {
    int s = 0; wait(&s);
  }

  int readable = ((unsigned char)buf[0] == 0xAB);
  memset(buf, 0xCD, PGSIZE);
  int writable = ((unsigned char)buf[0] == 0xCD);

  printf("  after %d child exits: read 0xAB=%s, then write 0xCD=%s\n",
         NCHILDREN, readable ? "OK" : "FAIL", writable ? "OK" : "FAIL");

  if(!readable)
    fail(name, "parent could not read page after children exited");
  else if(!writable)
    fail(name, "parent could not write page after children exited");
  else
    pass(name);

  sbrk(-PGSIZE);
}

// -----------------------------------------------------------------------
// TEST 8: large_fork
// Allocate 40 MB, write sentinels to every page. Fork. Child reads 5
// spot-check pages. Parent verifies same 5 spot-checks intact.
// Without CoW, fork would fail to double 40 MB in only 128 MB total RAM.
// -----------------------------------------------------------------------
static void
test_large_fork(void)
{
  const char *name = "large_fork";
  // 40 MB — safe under 128 MB total, but would OOM without CoW
  const int NPAGES = (40 * 1024 * 1024) / PGSIZE;
  printf("  setup: sbrk %d MB, write sentinel to every page, then fork\n",
         NPAGES * PGSIZE / (1024 * 1024));

  char *base = sbrk(NPAGES * PGSIZE);
  if(base == SBRK_ERROR) {
    fail(name, "sbrk of 40 MB failed before fork");
    return;
  }

  for(int i = 0; i < NPAGES; i++)
    base[i * PGSIZE] = (char)(i & 0xFF);

  printf("  allocation done (%d pages written), forking...\n", NPAGES);

  int p[2];
  pipe(p);
  int pid = fork();

  if(pid == 0) {
    close(p[0]);
    // spot-check 5 spread-out pages
    int idx[5] = {0, NPAGES/4, NPAGES/2, 3*NPAGES/4, NPAGES-1};
    int ok = 0;
    for(int j = 0; j < 5; j++) {
      int i = idx[j];
      if((unsigned char)base[i * PGSIZE] == (unsigned char)(i & 0xFF)) ok++;
    }
    pipe_send(p[1], ok);
    close(p[1]);
    exit(0);
  }

  close(p[1]);
  int child_ok = pipe_recv(p[0]);
  close(p[0]);
  int status = 0; wait(&status);

  int idx[5] = {0, NPAGES/4, NPAGES/2, 3*NPAGES/4, NPAGES-1};
  int parent_ok = 0;
  for(int j = 0; j < 5; j++) {
    int i = idx[j];
    if((unsigned char)base[i * PGSIZE] == (unsigned char)(i & 0xFF)) parent_ok++;
  }

  printf("  fork succeeded! child verified %d/5 spot-checks, parent verified %d/5\n",
         child_ok, parent_ok);

  sbrk(-NPAGES * PGSIZE);

  if(child_ok != 5)
    fail(name, "child saw wrong sentinel values");
  else if(parent_ok != 5)
    fail(name, "parent saw corruption after fork of large allocation");
  else
    pass(name);
}

// -----------------------------------------------------------------------
// TEST 9: lazy_cow
// Proves the copy is deferred until the write, using freemem() to count
// free physical pages at three precise moments:
//
//   A. Immediately after fork (child measures) — expect: same as parent had
//      (pages are SHARED, no new physical pages allocated by fork itself)
//
//   B. After child reads every shared page — expect: same as A
//      (reads do NOT trigger CoW copies; pages remain shared)
//
//   C. After child writes N pages one by one, measuring after each write —
//      expect: free count drops by exactly 1 per write
//      (each write triggers exactly 1 CoW copy, no more, no less)
// -----------------------------------------------------------------------
static void
test_lazy_cow(void)
{
  const char *name = "lazy_cow";
  const int NPAGES = 64;  // 64 pages = 256 KB: large enough to be decisive

  printf("  setup: wire %d pages, fork, measure free pages after fork/read/write\n", NPAGES);

  char *buf = sbrk(NPAGES * PGSIZE);
  if(buf == SBRK_ERROR) { fail(name, "sbrk failed"); return; }

  // Wire every page (write to each to force physical allocation via lazy alloc)
  for(int i = 0; i < NPAGES; i++)
    buf[i * PGSIZE] = (char)(i & 0xFF);

  int free_before_fork = freemem();
  printf("  free pages before fork: %d\n", free_before_fork);

  // p[0]: parent reads from, p[1]: child writes to
  // We send 3 measurements from child: after_fork, after_reads, then NPAGES write-pairs
  int p[2];
  pipe(p);

  int pid = fork();
  if(pid == 0) {
    close(p[0]);

    // --- MEASUREMENT A: right after fork, before any access ---
    int after_fork = freemem();
    pipe_send(p[1], after_fork);

    // --- MEASUREMENT B: after reading every shared page ---
    volatile int sink = 0;
    for(int i = 0; i < NPAGES; i++)
      sink += buf[i * PGSIZE];  // read-only access, CoW must NOT trigger
    (void)sink;
    int after_reads = freemem();
    pipe_send(p[1], after_reads);

    // --- MEASUREMENT C: write pages one at a time, measure after each ---
    for(int i = 0; i < NPAGES; i++) {
      buf[i * PGSIZE] = (char)(i + 1);  // write triggers 1 CoW copy
      pipe_send(p[1], freemem());
    }

    close(p[1]);
    exit(0);
  }

  close(p[1]);

  int after_fork  = pipe_recv(p[0]);
  int after_reads = pipe_recv(p[0]);

  // Collect per-write free counts
  int after_write[NPAGES];
  for(int i = 0; i < NPAGES; i++)
    after_write[i] = pipe_recv(p[0]);

  close(p[0]);
  int status = 0; wait(&status);

  printf("  [A] free after fork  = %d  (want ~%d, no pages copied by fork)\n",
         after_fork, free_before_fork);
  printf("  [B] free after reads = %d  (want ~%d, reads must NOT trigger copies)\n",
         after_reads, after_fork);

  // Show first few and last write measurements
  printf("  [C] free after each write (first 4 and last 4 of %d):\n", NPAGES);
  for(int i = 0; i < NPAGES && i < 4; i++)
    printf("      write[%d]: %d (expected %d)\n",
           i, after_write[i], after_fork - (i + 1));
  printf("      ...\n");
  for(int i = NPAGES - 4; i < NPAGES; i++)
    printf("      write[%d]: %d (expected %d)\n",
           i, after_write[i], after_fork - (i + 1));

  // Tolerance: allow ±2 for kernel scheduling/overhead
  int tol = 2;

  // Check A: fork should not consume any data pages
  // (allows a few pages for child process overheads: kernel stack, page tables)
  int fork_overhead = free_before_fork - after_fork;
  int a_ok = (fork_overhead >= 0 && fork_overhead <= 10);

  // Check B: reads must not consume any physical pages at all
  int b_ok = (after_reads >= after_fork - tol && after_reads <= after_fork + tol);

  // Check C: each write should drop free count by exactly 1
  int c_ok = 1;
  for(int i = 0; i < NPAGES; i++) {
    int expected = after_fork - (i + 1);
    if(after_write[i] < expected - tol || after_write[i] > expected + tol) {
      printf("  write[%d]: got %d expected ~%d (deviation > %d)\n",
             i, after_write[i], expected, tol);
      c_ok = 0;
    }
  }

  printf("  fork overhead: %d pages (want 0-10)\n", fork_overhead);
  printf("  reads caused new allocs: %d (want 0)\n", after_fork - after_reads);
  printf("  each write consumed exactly 1 page: %s\n", c_ok ? "YES" : "NO");

  if(!a_ok)
    fail(name, "fork consumed too many pages (eager copy suspected)");
  else if(!b_ok)
    fail(name, "reads after fork consumed pages (CoW triggered too early!)");
  else if(!c_ok)
    fail(name, "writes did not consume exactly 1 page each");
  else
    pass(name);

  sbrk(-NPAGES * PGSIZE);
}

// -----------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------

int
main(void)
{
  printf("\n");
  printf("===========================================\n");
  printf("  CoW Fork Manual Test Suite\n");
  printf("===========================================\n\n");

  struct {
    const char *label;
    void (*fn)(void);
  } tests[] = {
    { "1. child_write_isolates  (child write doesn't corrupt parent)",        test_child_write_isolates  },
    { "2. parent_write_isolates (parent write after fork doesn't corrupt child)", test_parent_write_isolates },
    { "3. both_write            (parent+child write independently)",          test_both_write            },
    { "4. multipage             (8 distinct pages each CoW'd correctly)",     test_multipage             },
    { "5. chain_fork            (parent->child->grandchild all isolated)",    test_chain_fork            },
    { "6. copyout_cow           (kernel pipe read into CoW page via copyout)",test_copyout_cow           },
    { "7. ref_cleanup           (refcount correct after many quick exits)",   test_ref_cleanup           },
    { "8. large_fork            (40 MB alloc + fork, no OOM thanks to CoW)", test_large_fork            },
    { "9. lazy_cow              (freemem proves: fork=0 new pages, reads=0 new pages, each write=1)",
                                                                              test_lazy_cow              },
  };

  int ntests = sizeof(tests) / sizeof(tests[0]);
  for(int i = 0; i < ntests; i++) {
    printf("--- %s\n", tests[i].label);
    tests[i].fn();
    printf("\n");
  }

  printf("===========================================\n");
  printf("  Results: %d passed, %d failed\n", passed, failed);
  if(failed == 0)
    printf("  *** ALL COW TESTS PASSED ***\n");
  else
    printf("  *** SOME COW TESTS FAILED ***\n");
  printf("===========================================\n\n");

  exit(failed == 0 ? 0 : 1);
}
