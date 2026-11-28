#include "kernel/types.h"
#include "kernel/riscv.h"
#include "kernel/param.h"
#include "user/user.h"

#define AD (PTE_A | PTE_D)
static volatile char global = 7;

static void
check(int ok, const char *name)
{
  if (!ok) {
    printf("FAIL %s\n", name);
    exit(1);
  }
}

static void
snapshot(const char *name)
{
  printf("\n[%s]\n", name);
  pgdump();
}

int
main(void)
{
  volatile char scalar = 9, array[32] = {3};
  snapshot("start");
  int bytes = 4 * PGSIZE;
  char *base = sbrk(bytes);
  check(base != SBRK_ERROR, "heap allocation");
  volatile char *heap = base;
  char *guard = base - (USERSTACK + 1) * PGSIZE;
  printf("VA global=%p scalar=%p array[1]=%p heap=%p guard=%p\n",
         (void *)&global, (void *)&scalar, (void *)&array[1], base, guard);
  snapshot("after allocation");

  // exec puts the guard just below the user stack. Clear both user ranges.
  check(pgclear(0, (uint64)guard, AD) == 0, "clear program image");
  check(pgclear(guard + PGSIZE, (USERSTACK + 4) * PGSIZE, AD) == 0,
        "clear stack and heap");
  snapshot("after clear");
  check(pgcheck(heap, bytes, AD) == 0, "heap starts clear");

  (void)global;
  (void)scalar;
  (void)array[1];
  (void)heap[PGSIZE - 2];
  (void)heap[PGSIZE];
  check(pgcheck(&global, 1, PTE_A) == 1 &&
        pgcheck(&scalar, 1, PTE_A) == 1 &&
        pgcheck(&array[1], 1, PTE_A) == 1, "global and stack reads");
  check(pgcheck(heap + PGSIZE - 2, 3, PTE_A) == 1 &&
        pgcheck(heap, bytes, PTE_D) == 0, "read without write");
  snapshot("after reads");

  global = 1;
  scalar = 2;
  array[1] = 3;
  heap[PGSIZE] = 4;
  heap[2 * PGSIZE] = 5;
  check(pgcheck(&global, 1, PTE_D) == 1 &&
        pgcheck(&scalar, 1, PTE_D) == 1 &&
        pgcheck(&array[1], 1, PTE_D) == 1, "global and stack writes");
  check(pgcheck(heap, PGSIZE, PTE_D) == 0 &&
        pgcheck(heap + PGSIZE - 2, 2, PTE_D) == 0 &&
        pgcheck(heap + PGSIZE - 2, 3, PTE_D) == 1, "exclusive end");
  snapshot("after writes");
  check(pgclear(heap + PGSIZE - 2, 3, PTE_D) == 0 &&
        pgcheck(heap + PGSIZE, 1, PTE_A) == 1 &&
        pgcheck(heap, 2 * PGSIZE, PTE_D) == 0 &&
        pgcheck(heap + 2 * PGSIZE, 1, PTE_D) == 1, "selective clear");
  check(pgclear(heap + 2 * PGSIZE, 1, PTE_A) == 0 &&
        pgcheck(heap + 2 * PGSIZE, 1, PTE_D) == 1 &&
        pgcheck(heap + 2 * PGSIZE, 1, PTE_A) == 0, "clear A alone");
  check(pgcheck(heap, 1, 0) == -1 && pgclear(heap, 1, AD | PTE_U) == -1 &&
        pgcheck(heap, (uint64)-1, AD) == -1 &&
        pgcheck(guard, 1, AD) == -1 && pgclear(guard, 1, AD) == -1 &&
        pgcheck(base + bytes, 0, AD) == 0, "invalid arguments and empty range");

  check(sbrklazy(PGSIZE) == base + bytes, "reserve unmapped tail");
  check(pgcheck(heap, bytes + 1, AD) == -1 &&
        pgclear(heap, bytes + 1, AD) == -1 &&
        pgcheck(heap + 2 * PGSIZE, 1, PTE_D) == 1, "invalid tail is atomic");
  check(sbrk(-PGSIZE) != SBRK_ERROR && sbrk(-bytes) != SBRK_ERROR,
        "release heap");
  check(pgcheck(heap, 1, AD) == -1, "released page");
  snapshot("after release");

  // Cross both the small pointer buffer and a full kernel scratch page.
  int pages = 540;
  base = sbrk(pages * PGSIZE);
  check(base != SBRK_ERROR, "large allocation");
  heap = base;
  for (int i = 0; i < pages; i++)
    heap[i * PGSIZE] = 1;
  check(pgclear(heap, pages * PGSIZE, AD) == 0 &&
        pgcheck(heap, pages * PGSIZE, AD) == 0, "large clear");
  check(sbrk(-pages * PGSIZE) != SBRK_ERROR, "large release");
  printf("pgdemo: PASS\n");
  exit(0);
}
