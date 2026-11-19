#include "kernel/types.h"
#include "kernel/riscv.h"
#include "user/user.h"

struct node {
  int value;
  struct node *next;
};

static void
check(int ok, const char *message)
{
  if (!ok) {
    fprintf(2, "malloctest: %s\n", message);
    exit(1);
  }
}

static void
test_list(void)
{
  char *base = sbrk(0);
  struct node *head = 0;
  struct node **link = &head;

  for (int i = 0; i < 4; i++) {
    struct node *node = malloc(sizeof(*node));
    check(node != 0, "could not allocate list node");
    *node = (struct node){.value = i};
    *link = node;
    link = &node->next;
  }
  check(sbrk(0) == base + PGSIZE, "four nodes should fit in one page");

  struct node *removed = head->next;
  uint64 address = (uint64)removed;
  head->next = removed->next;
  free(removed);
  check(head->next->value == 2, "deleting a node damaged the list");

  struct node *replacement = malloc(sizeof(*replacement));
  check(replacement != 0 && (uint64)replacement == address,
        "allocator did not reuse the freed node's block");
  *replacement = (struct node){1, head->next};
  head->next = replacement;

  for (int expected = 0; expected < 4; expected++) {
    check(head != 0 && head->value == expected, "list contents are incorrect");
    struct node *next = head->next;
    free(head);
    head = next;
  }
  check(head == 0 && sbrk(0) == base,
        "freeing the list did not return its page");
}

static void
test_coalescing(void)
{
  char *base = sbrk(0);
  char *left = malloc(96);
  char *right = malloc(96);
  char *guard = malloc(96);
  check(left && right && guard, "could not allocate coalescing test blocks");
  uint64 address = (uint64)left;
  guard[0] = 'g';
  free(right);
  free(left);

  char *joined = malloc(192);
  check(joined && (uint64)joined == address && sbrk(0) == base + PGSIZE,
        "adjacent blocks did not coalesce");
  memset(joined, 'j', 192);
  check(guard[0] == 'g', "joined block overwrote its neighbor");
  free(joined);
  free(guard);
  check(sbrk(0) == base, "coalesced page was not returned");
}

static void
test_large(void)
{
  char *base = sbrk(0);
  char *small = malloc(1);
  check(small != 0, "could not allocate a small block");
  small[0] = 's';
  char *one_page = sbrk(0);

  uint size = 2 * PGSIZE + 17;
  char *large = malloc(size);
  check(large != 0, "could not allocate a multi-page block");
  char *top = sbrk(0);
  check(top > one_page && (top - one_page) % PGSIZE == 0,
        "large allocation did not grow the heap by whole pages");
  memset(large, 'l', size);
  check(large[0] == 'l' && large[PGSIZE] == 'l' && large[size - 1] == 'l',
        "could not use the entire multi-page block");

  free(large);
  check(sbrk(0) == one_page && small[0] == 's',
        "trimming tail pages damaged a live block or left excess pages");
  free(small);
  check(sbrk(0) == base, "heap did not return to its original break");
}

static void
test_direct_sbrk(void)
{
  char *base = sbrk(0);
  void *first = malloc(1);
  check(first != 0, "could not allocate before direct sbrk");
  char *gap = sbrk(1);
  check(gap != SBRK_ERROR, "direct sbrk failed");
  gap[0] = 'x';

  void *second = malloc(PGSIZE);
  check(second && (uint64)second % 16 == 0,
        "unaligned break misaligned malloc");
  free(first);
  free(second);
  check(sbrk(0) == gap + 1 && gap[0] == 'x',
        "allocator trampled direct sbrk space");
  check(sbrk(-1) == gap + 1, "could not remove direct sbrk space");
  first = malloc(1);
  check(first != 0, "could not reuse the page below the former gap");
  free(first);
  check(sbrk(0) == base, "page below former sbrk gap was not returned");
}

int
main(int argc, char *argv[])
{
  malloc_debug(argc == 1 || strcmp(argv[1], "-q") != 0);
  test_list();
  test_coalescing();
  test_large();
  test_direct_sbrk();

  char *base = sbrk(0);
  check(malloc((uint)-1) == 0 && sbrk(0) == base,
        "oversized allocation changed the heap");
  void *empty = malloc(0);
  check(empty != 0, "zero-size allocation failed");
  free(empty);
  free(0);
  check(sbrk(0) == base, "zero-size allocation left pages behind");
  printf("malloctest: OK\n");
  exit(0);
}
