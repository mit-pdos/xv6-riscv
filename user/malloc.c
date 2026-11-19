#include <limits.h>

#include "kernel/types.h"
#include "kernel/riscv.h"
#include "user/user.h"

enum {
  ALIGNMENT = 16,
  FIRST_BIN_LIMIT = 64,
  BIN_COUNT = 22,
};

struct block {
  struct block *prev;
  struct block *next;
  uint64 size;
  uint requested;
  ushort available;
  ushort padding;
} __attribute__((aligned(ALIGNMENT)));

struct free_links {
  struct block *prev;
  struct block *next;
};

#define MIN_BLOCK_SIZE (sizeof(struct block) + sizeof(struct free_links))

static struct block *heap_first;
static struct block *heap_last;
static struct block *bins[BIN_COUNT];
static int trace_heap;

static uint64
align_up(uint64 size)
{
  return (size + ALIGNMENT - 1) & ~(uint64)(ALIGNMENT - 1);
}

static char *
block_end(struct block *block)
{
  return (char *)block + block->size;
}

static struct free_links *
free_links(struct block *block)
{
  return (struct free_links *)(block + 1);
}

static int
bin_index(uint64 size)
{
  int index = 0;
  uint64 limit = FIRST_BIN_LIMIT;

  while (size > limit && index < BIN_COUNT - 1) {
    limit <<= 1;
    index++;
  }
  return index;
}

static void
bin_insert(struct block *block)
{
  int index = bin_index(block->size);
  struct block *first = bins[index];

  *free_links(block) = (struct free_links){0, first};
  if (first)
    free_links(first)->prev = block;
  bins[index] = block;
}

static void
bin_remove(struct block *block)
{
  struct free_links *links = free_links(block);

  if (links->prev)
    free_links(links->prev)->next = links->next;
  else
    bins[bin_index(block->size)] = links->next;
  if (links->next)
    free_links(links->next)->prev = links->prev;
}

static struct block *
find_block(uint64 size)
{
  for (int i = bin_index(size); i < BIN_COUNT; i++) {
    for (struct block *block = bins[i]; block;
         block = free_links(block)->next) {
      if (block->size >= size) {
        bin_remove(block);
        return block;
      }
    }
  }
  return 0;
}

static void
link_block(struct block *block)
{
  if (block->prev)
    block->prev->next = block;
  else
    heap_first = block;
  if (block->next)
    block->next->prev = block;
  else
    heap_last = block;
}

static int
adjacent(struct block *left, struct block *right)
{
  return block_end(left) == (char *)right - right->padding;
}

static void
merge_blocks(struct block *left, struct block *right)
{
  left->size += right->padding + right->size;
  left->next = right->next;
  link_block(left);
}

static struct block *
grow_heap(uint64 size)
{
  char *brk = sbrk(0);
  if (brk == SBRK_ERROR)
    return 0;

  struct block *tail = heap_last;
  int extend_tail = tail && tail->available && block_end(tail) == brk;
  uint64 padding = align_up((uint64)brk) - (uint64)brk;
  uint64 missing = extend_tail ? size - tail->size : size + padding;
  uint64 growth = PGROUNDUP(missing);
  char *start;

  if (growth > INT_MAX || (start = sbrk((int)growth)) == SBRK_ERROR)
    return 0;

  if (extend_tail) {
    bin_remove(tail);
    tail->size += growth;
    return tail;
  }

  struct block *block = (struct block *)(start + padding);
  *block =
    (struct block){.prev = tail, .size = growth - padding, .padding = padding};
  link_block(block);
  return block;
}

static void
trim_heap(struct block *block)
{
  uint64 span = block->padding + block->size;
  uint64 release = PGROUNDDOWN(span);

  if (release && release != span &&
      span - release < MIN_BLOCK_SIZE + block->padding)
    release -= PGSIZE;
  if (release > PGROUNDDOWN(INT_MAX))
    release = PGROUNDDOWN(INT_MAX);

  if (release && block_end(block) == sbrk(0)) {
    struct block *prev = block->prev;
    if (sbrk(-(int)release) != SBRK_ERROR) {
      if (release == span) {
        heap_last = prev;
        if (prev)
          prev->next = 0;
        else
          heap_first = 0;
        return;
      }
      block->size -= release;
    }
  }
  bin_insert(block);
}

static void
dump_heap(const char *operation, uint requested, void *ptr)
{
  uint64 reserved = 0, used = 0, free_bytes = 0;

  fprintf(2, "heap after %s (%u bytes, %p), brk=%p\n", operation, requested,
          ptr, (void *)sbrk(0));
  for (struct block *block = heap_first; block; block = block->next) {
    fprintf(2, "  %p %s size=%lu requested=%u\n", (void *)block,
            block->available ? "free" : "used", block->size, block->requested);
    reserved += block->padding + block->size;
    used += block->requested;
    if (block->available)
      free_bytes += block->size - sizeof(*block);
  }

  for (int i = 0; i < BIN_COUNT; i++) {
    if (!bins[i])
      continue;
    if (i == BIN_COUNT - 1)
      fprintf(2, "  bin >%u:", (uint)FIRST_BIN_LIMIT << (i - 1));
    else
      fprintf(2, "  bin <=%u:", (uint)FIRST_BIN_LIMIT << i);
    for (struct block *block = bins[i]; block; block = free_links(block)->next)
      fprintf(2, " %p", (void *)block);
    fprintf(2, "\n");
  }

  fprintf(2, "  used=%lu/%lu bytes (%lu%%), free payload=%lu bytes\n", used,
          reserved, reserved ? 100 * used / reserved : 0, free_bytes);
}

void
malloc_debug(int enabled)
{
  trace_heap = enabled;
}

void *
malloc(uint nbytes)
{
  uint64 size = align_up((uint64)nbytes + sizeof(struct block));
  if (size < MIN_BLOCK_SIZE)
    size = MIN_BLOCK_SIZE;

  struct block *block = find_block(size);
  if (!block)
    block = grow_heap(size);
  if (!block)
    return 0;

  if (block->size - size >= MIN_BLOCK_SIZE) {
    struct block *rest = (struct block *)((char *)block + size);
    *rest = (struct block){.prev = block,
                           .next = block->next,
                           .size = block->size - size,
                           .available = 1};
    block->size = size;
    link_block(rest);
    bin_insert(rest);
  }
  block->available = 0;
  block->requested = nbytes;
  if (trace_heap)
    dump_heap("malloc", nbytes, block + 1);
  return block + 1;
}

void
free(void *ptr)
{
  if (!ptr)
    return;

  struct block *block = (struct block *)ptr - 1;
  uint requested = block->requested;
  block->requested = 0;
  block->available = 1;

  struct block *prev = block->prev;
  if (prev && prev->available && adjacent(prev, block)) {
    bin_remove(prev);
    merge_blocks(prev, block);
    block = prev;
  }
  struct block *next = block->next;
  if (next && next->available && adjacent(block, next)) {
    bin_remove(next);
    merge_blocks(block, next);
  }

  if (block == heap_last)
    trim_heap(block);
  else
    bin_insert(block);
  if (trace_heap)
    dump_heap("free", requested, ptr);
}
