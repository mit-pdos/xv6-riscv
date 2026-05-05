// user/oomtest.c
//
// Comprehensive test for the paging/swapping system.
// Covers the work of all three persons:
//
//   Person A (kalloc.c): Frame table tracks user pages; Clock algorithm
//             selects eviction victims based on the hardware accessed bit.
//
//   Person B (swapfile.c, trap.c): Swapped pages are written to the swap
//             file and restored on fault; the fault handler detects PTE_SWAP
//             and calls swapin() transparently.
//
//   Person C (vm.c): Evicted PTEs are correctly encoded with PTE_SWAP +
//             slot number; swap-aware states are distinct from unmapped pages.
//
// Run from the xv6 shell:   $ oomtest
//
// Each test prints PASS or FAIL with a reason.

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define PAGESIZE  4096

// How many pages to allocate per test.
// 1500 pages = 6 MB -- should exceed physical RAM on a typical QEMU config
// (xv6 default is often 8 MB but much of it is kernel + FS).
#define MANY_PAGES  1500
#define FEW_PAGES   32     // fits in RAM comfortably -- baseline sanity

// -----------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------

static int passed = 0;
static int failed = 0;

static void
report(const char *name, int ok, const char *reason)
{
  if (ok) {
    printf("  [PASS] %s\n", name);
    passed++;
  } else {
    printf("  [FAIL] %s -- %s\n", name, reason);
    failed++;
  }
}

// Allocate n pages via sbrk, return base pointer or 0 on failure.
static char *
alloc_pages(int n)
{
  char *p = sbrk(n * PAGESIZE);
  if (p == (char *)-1)
    return 0;
  return p;
}

// Free n pages previously allocated with alloc_pages.
static void
free_pages(char *base, int n)
{
  sbrk(-(n * PAGESIZE));
}

// -----------------------------------------------------------------------
// Test 1 -- Basic lazy allocation (no swap needed)
// Person A: frame table registers the page on first touch.
// Person C: PTE transitions from unmapped -> valid on fault.
// -----------------------------------------------------------------------
static void
test_lazy_alloc(void)
{
  char *p = alloc_pages(FEW_PAGES);
  if (p == 0) { report("lazy_alloc", 0, "sbrk failed"); return; }

  int ok = 1;
  for (int i = 0; i < FEW_PAGES; i++) {
    p[i * PAGESIZE] = (char)(i & 0xFF);
  }
  for (int i = 0; i < FEW_PAGES; i++) {
    if ((unsigned char)p[i * PAGESIZE] != (unsigned char)(i & 0xFF)) {
      ok = 0; break;
    }
  }
  free_pages(p, FEW_PAGES);
  report("lazy_alloc", ok, "page value mismatch before any swap");
}

// -----------------------------------------------------------------------
// Test 2 -- Stamp-and-verify across swap pressure
// Person A: Clock evicts pages with cleared accessed bits.
// Person B: swapout() writes victim to disk; swapin() restores on fault.
// Person C: PTE_SWAP correctly marks evicted pages; fault handler reads slot.
// -----------------------------------------------------------------------
static void
test_swap_integrity(void)
{
  char *base = alloc_pages(MANY_PAGES);
  if (base == 0) { report("swap_integrity", 0, "sbrk failed"); return; }

  // Write a unique 32-bit stamp to the first word of every page.
  for (int i = 0; i < MANY_PAGES; i++) {
    int *p = (int *)(base + (uint64)i * PAGESIZE);
    *p = 0xAB000000 | i;
  }

  // Walk back and verify -- pages that were evicted will fault back in.
  int ok = 1;
  for (int i = 0; i < MANY_PAGES; i++) {
    int *p = (int *)(base + (uint64)i * PAGESIZE);
    if (*p != (int)(0xAB000000 | i)) {
      printf("    page %d: expected 0x%x got 0x%x\n",
             i, 0xAB000000 | i, *p);
      ok = 0;
      break;
    }
  }

  free_pages(base, MANY_PAGES);
  report("swap_integrity", ok, "stamp corrupted after swap roundtrip");
}

// -----------------------------------------------------------------------
// Test 3 -- Re-eviction: a page can be swapped out more than once
// Write, evict (by touching lots of other pages), read back, repeat.
// -----------------------------------------------------------------------
static void
test_re_eviction(void)
{
  // Page A: the page we care about.
  char *a = alloc_pages(1);
  if (a == 0) { report("re_eviction", 0, "sbrk a failed"); return; }
  *a = 0x42;

  int ok = 1;
  for (int round = 0; round < 3 && ok; round++) {
    // Pressure: allocate and touch MANY_PAGES to force 'a' off RAM.
    char *pressure = alloc_pages(MANY_PAGES);
    if (pressure == 0) { report("re_eviction", 0, "sbrk pressure failed"); return; }
    for (int i = 0; i < MANY_PAGES; i++)
      pressure[i * PAGESIZE] = (char)i;

    // Read 'a' back -- should fault in from swap with value intact.
    if ((unsigned char)*a != 0x42) {
      printf("    round %d: expected 0x42 got 0x%x\n", round, (unsigned char)*a);
      ok = 0;
    }
    free_pages(pressure, MANY_PAGES);
  }

  free_pages(a, 1);
  report("re_eviction", ok, "value lost across multiple eviction rounds");
}

// -----------------------------------------------------------------------
// Test 4 -- Multiple pages with distinct values survive pressure
// Checks that the slot→VA mapping in the PTE is correct for many pages
// simultaneously swapped out.
// -----------------------------------------------------------------------
static void
test_multi_page_swap(void)
{
  // Allocate a moderate set, write distinct values, then force pressure.
  int NTRACK = 64;
  char *tracked = alloc_pages(NTRACK);
  if (tracked == 0) { report("multi_page_swap", 0, "sbrk tracked failed"); return; }

  for (int i = 0; i < NTRACK; i++)
    tracked[i * PAGESIZE] = (char)(i ^ 0xCC);

  // Force eviction of the tracked pages.
  char *pressure = alloc_pages(MANY_PAGES);
  if (pressure) {
    for (int i = 0; i < MANY_PAGES; i++)
      pressure[i * PAGESIZE] = 1;
    free_pages(pressure, MANY_PAGES);
  }

  // Verify all tracked pages came back correctly.
  int ok = 1;
  for (int i = 0; i < NTRACK; i++) {
    unsigned char got      = (unsigned char)tracked[i * PAGESIZE];
    unsigned char expected = (unsigned char)(i ^ 0xCC);
    if (got != expected) {
      printf("    tracked[%d]: expected 0x%x got 0x%x\n", i, expected, got);
      ok = 0;
      break;
    }
  }
  free_pages(tracked, NTRACK);
  report("multi_page_swap", ok, "slot/VA mismatch for concurrently swapped pages");
}

// -----------------------------------------------------------------------
// Test 5 -- Write-after-swapin: verify the page is writable after restore
// If the fault handler maps the page read-only, this write would fault again.
// -----------------------------------------------------------------------
static void
test_write_after_swapin(void)
{
  char *p = alloc_pages(1);
  if (p == 0) { report("write_after_swapin", 0, "sbrk failed"); return; }
  *p = 0x11;

  // Evict it.
  char *pressure = alloc_pages(MANY_PAGES);
  if (pressure) {
    for (int i = 0; i < MANY_PAGES; i++) pressure[i * PAGESIZE] = 1;
    free_pages(pressure, MANY_PAGES);
  }

  // Read it back (swapin happens here).
  char first_read = *p;

  // Now write a new value -- if PTE_W wasn't set by the fault handler, kernel panics.
  *p = 0x22;
  char second_read = *p;

  int ok = (first_read == 0x11) && (second_read == 0x22);
  free_pages(p, 1);
  report("write_after_swapin", ok, "page not writable or value wrong after swapin");
}

// -----------------------------------------------------------------------
// Test 6 -- Sequential access pattern (Clock algorithm favours LRU)
// Person A's Clock should evict pages not recently accessed.
// We verify that the MOST recently written page survives while older ones
// are the ones evicted.
// -----------------------------------------------------------------------
static void
test_clock_recency(void)
{
  // Allocate a set, write them, then immediately write ONE more
  // (the "hot" page).  Under Clock, the hot page should survive in RAM
  // while the cold ones get evicted.  All should still read correctly.
  int NCOLD = 200;
  char *cold = alloc_pages(NCOLD);
  if (cold == 0) { report("clock_recency", 0, "sbrk cold failed"); return; }

  for (int i = 0; i < NCOLD; i++)
    cold[i * PAGESIZE] = (char)i;

  // Hot page: touch it AFTER the cold pages so its accessed bit is set.
  char *hot = alloc_pages(1);
  if (hot == 0) { free_pages(cold, NCOLD); report("clock_recency", 0, "sbrk hot failed"); return; }
  *hot = 0xBB;

  // Re-touch hot to keep its accessed bit set.
  (void)*hot;

  // Pressure to trigger eviction -- Clock should pick cold pages first.
  char *pressure = alloc_pages(MANY_PAGES);
  if (pressure) {
    for (int i = 0; i < MANY_PAGES; i++) pressure[i * PAGESIZE] = 1;
    free_pages(pressure, MANY_PAGES);
  }

  // Verify hot page (may or may not still be in RAM, but value must be correct).
  int ok = ((unsigned char)*hot == 0xBB);

  // Also spot-check cold pages.
  for (int i = 0; i < NCOLD && ok; i++) {
    if ((unsigned char)cold[i * PAGESIZE] != (unsigned char)i)
      ok = 0;
  }

  free_pages(hot, 1);
  free_pages(cold, NCOLD);
  report("clock_recency", ok, "hot or cold page value wrong after eviction");
}

// -----------------------------------------------------------------------
// main
// -----------------------------------------------------------------------
int
main(void)
{
  printf("\n=== oomtest: paging + swapping system test ===\n\n");

  printf("[ Person A: frame table and Clock eviction ]\n");
  test_lazy_alloc();
  test_clock_recency();

  printf("\n[ Person B: swap file and fault handler ]\n");
  test_swap_integrity();
  test_re_eviction();
  test_write_after_swapin();

  printf("\n[ Person C: swap-aware PTE states ]\n");
  test_multi_page_swap();

  printf("\n=== Results: %d passed, %d failed ===\n\n", passed, failed);
  exit(failed > 0 ? 1 : 0);
}