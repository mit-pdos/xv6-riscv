#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/param.h"
#include "kernel/riscv.h"

#define NUM_CLASSES 4

#define GET_PTRS(block) ((SFL_ptrs *)((block)->payload))

typedef struct Header {
  unsigned int size;
  int is_free;
  struct Header *next_phys;
  struct Header *prev_phys;

  char payload[0];
} Header;

static Header *free_lists[NUM_CLASSES];
static Header *last_phys_block = 0;

typedef struct SFL_ptrs {
  struct Header *next_free;
  struct Header *prev_free;
} SFL_ptrs;

#define MIN_PAYLOAD sizeof(SFL_ptrs)
#define HEADER_SIZE sizeof(Header)

static unsigned long total_allocated_payload = 0;
static unsigned long total_heap_sbrk_bytes = 0;

static int
get_class_index(uint size)
{
  if (size <= 64) {
    return 0;
  }
  if (size <= 256) {
    return 1;
  }
  if (size <= 1024) {
    return 2;
  }
  return 3;
}

static void
remove_from_free_list(Header *block)
{
  int idx = get_class_index(block->size);
  SFL_ptrs *pointers = GET_PTRS(block);

  if (pointers->prev_free) {
    GET_PTRS(pointers->prev_free)->next_free = pointers->next_free;
  } else {
    free_lists[idx] = pointers->next_free;
  }

  if (pointers->next_free) {
    GET_PTRS(pointers->next_free)->prev_free = pointers->prev_free;
  }

  pointers->next_free = 0;
  pointers->prev_free = 0;
}

static void
insert_into_free_list(Header *block)
{
  int idx = get_class_index(block->size);
  SFL_ptrs *pointers = GET_PTRS(block);

  pointers->next_free = free_lists[idx];
  pointers->prev_free = 0;

  if (free_lists[idx]) {
    GET_PTRS(free_lists[idx])->prev_free = block;
  }

  free_lists[idx] = block;
}

static Header *
grow_heap(uint size)
{

  uint needed_payload = size < MIN_PAYLOAD ? MIN_PAYLOAD : size;
  uint alloc_size = HEADER_SIZE + needed_payload;
  alloc_size = PGROUNDUP(alloc_size);

  void *p = sbrk(alloc_size);
  if (p == (void *)-1) {
    return 0;
  }

  Header *block = (Header *)p;
  block->size = alloc_size - HEADER_SIZE;
  block->is_free = 1;
  block->next_phys = 0;
  block->prev_phys = last_phys_block;

  if (last_phys_block) {
    last_phys_block->next_phys = block;
  }

  last_phys_block = block;
  SFL_ptrs *pointers = GET_PTRS(block);
  pointers->next_free = 0;
  pointers->prev_free = 0;

  return block;
}

void *
malloc(uint nbytes)
{

  uint needed_size = nbytes < MIN_PAYLOAD ? MIN_PAYLOAD : nbytes;

  int idx = get_class_index(needed_size);
  Header *found_block = 0;

  for (int i = idx; i < NUM_CLASSES; i++) {
    Header *curr = free_lists[i];
    while (curr) {
      if (curr->size >= needed_size) {
        found_block = curr;
        break;
      }

      curr = GET_PTRS(curr)->next_free;
    }

    if (found_block) {
      break;
    }
  }

  if (!found_block) {
    found_block = grow_heap(needed_size);
    if (!found_block) {
      return 0;
    }
  } else {
    remove_from_free_list(found_block);
  }

  if (found_block->size >= HEADER_SIZE + MIN_PAYLOAD) {
    Header *remainder =
      (Header *)((char *)found_block + HEADER_SIZE + needed_size);

    remainder->size = found_block->size - needed_size - HEADER_SIZE;
    found_block->size = needed_size;
    remainder->is_free = 1;

    remainder->next_phys = found_block->next_phys;
    remainder->prev_phys = found_block;

    if (found_block->next_phys) {
      found_block->next_phys->prev_phys = remainder;
    } else {
      last_phys_block = remainder;
    }
    found_block->next_phys = remainder;

    insert_into_free_list(remainder);
  }

  found_block->is_free = 0;
  return (void *)(found_block->payload);
}

void
free(void *ap)
{
  Header *block = (Header *)((char *)ap - HEADER_SIZE);

  if (block->is_free) {
    return;
  }

  block->is_free = 1;

  if (block->next_phys && block->next_phys->is_free) {
    Header *old_right = block->next_phys;
    Header *second_right = block->next_phys->next_phys;

    remove_from_free_list(old_right);

    if (second_right) {
      second_right->prev_phys = block;
    } else {
      last_phys_block = block;
    }
    block->next_phys = second_right;

    block->size += HEADER_SIZE + old_right->size;
  }

  if (block->prev_phys && block->prev_phys->is_free) {
    Header *left = block->prev_phys;
    Header *right = block->next_phys;

    remove_from_free_list(left);

    if (right) {
      right->prev_phys = left;
    } else {
      last_phys_block = left;
    }
    left->next_phys = right;

    left->size += HEADER_SIZE + block->size;
    block = left;
  }

  insert_into_free_list(block);
}
