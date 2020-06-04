#include "types.h"
#include "param.h"
#include "riscv.h"
#include "spinlock.h"
#include "defs.h"

#define LEAF_SIZE     32
#define NSIZES        8
#define MAX_SIZE     NSIZES-1
#define BLK_SIZE(k)   ((1L << (k)) * LEAF_SIZE) 
#define HEAP_SIZE     BLK_SIZE(MAX_SIZE) // 4096
#define ROUNDUP(n,sz) (((((n)-1)/(sz))+1)*(sz))
#define MAX_PAGES     16

struct bd_list {
  struct bd_list *prev;
  struct bd_list *next;
};

struct sz_info {
  struct bd_list free;
};

struct pagelist {
  int index;
  int isalloc;
  void *pageaddr;
  char alloc[NSIZES][16];
  // char split[NSIZES][16];
};

struct {
  struct spinlock lock;
  struct sz_info bd_sizes[NSIZES];
  struct pagelist plist[MAX_PAGES];
} bd_table;

void *bd_base;

void lst_init(struct bd_list*);
void lst_remove(struct bd_list*);
void lst_push(struct bd_list*, void *);
void *lst_pop(struct bd_list*);
void lst_print(struct bd_list*);
int lst_empty(struct bd_list*);
 
int bit_isset(char *map, int index) {
  char b = map[index/8];
  char m = (1 << (index % 8));
  return (b & m) == m;
}

void bit_set(char *map, int index) {
  char b = map[index/8];
  char m = (1 << (index % 8));
  map[index/8] = (b | m);
}

void bit_clear(char *map, int index) {
  char b = map[index/8];
  char m = (1 << (index % 8));
  map[index/8] = (b & ~m);
}

void
bd_init()
{
  initlock(&bd_table.lock, "buddytable");
  for (int i = 0; i < MAX_PAGES; i++) {
    bd_table.plist[i].index = i;
    bd_table.plist[i].isalloc = 1;
    bd_table.plist[i].pageaddr = kalloc();
    if (bd_table.plist[i].pageaddr == 0) {
      panic("kalloc() error!! in buddy.c");
    }
    int map_size = NSIZES * 16;
    memset(bd_table.plist[i].alloc, 0, map_size);
    // memset(bd_table.plist[i].split, 0, map_size);
  }

  for (int i = 0; i < NSIZES; i++) {
    lst_init(&bd_table.bd_sizes[i].free);
  }

  for (int i = 0; i < MAX_PAGES; i++) {
    lst_push(&bd_table.bd_sizes[MAX_SIZE].free, bd_table.plist[i].pageaddr);
  }
}

int
firstk(int n) {
  int k = 0;
  int size = LEAF_SIZE;
  while (size < n) {
    k++;
    size *= 2;
  }
  return k;
}

int get_page_index(void *addr) {
  for (int i = 0; i < MAX_PAGES; i++) {
    if (bd_table.plist[i].isalloc == 0)
      break;
    int offset = addr - bd_table.plist[i].pageaddr;
    if (0 <= offset && offset < HEAP_SIZE) {
      return i;
    }
  }
  return -1;
}

int blk_index(int k, char *p, void *base_addr) {
  int n = p - (char *) base_addr;
  return n / BLK_SIZE(k);
}

int blk_size(void *p, int pindex, void* base_addr) {
  for (int k = 0; k < NSIZES; k++) {
    if(bit_isset(bd_table.plist[pindex].alloc[k], blk_index(k, p, base_addr))) {
      return k;
    }
  }
  return 0;
}

void *addr(int k, int bi, void* base_addr) {
  int n = bi * BLK_SIZE(k);
  return base_addr + n;
}

void
bd_free(void *p)
{
  void *q;
  int k;
  int pindex = get_page_index(p);
  void *pbase = bd_table.plist[pindex].pageaddr;
  k = blk_size(p, pindex, pbase);
  for (k = blk_size(p, pindex, pbase); k < MAX_SIZE; k++) {
    int bi = blk_index(k, p, pbase);
    bit_clear(bd_table.plist[pindex].alloc[k], bi);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    if (bit_isset(bd_table.plist[pindex].alloc[k], buddy)) {
      break;
    }
    q = addr(k, buddy, pbase);
    lst_remove(q);
    if (buddy % 2 == 0) {
      p = q;
    }
    bit_clear(bd_table.plist[pindex].alloc[k+1], blk_index(k+1, p, pbase));
  }
  lst_push(&bd_table.bd_sizes[k].free, p);
}

void *
bd_alloc(int nbytes)
{
  int fk, k;

  fk = firstk(nbytes);
  for (k = fk; k < NSIZES; k++) {
    if(!lst_empty(&bd_table.bd_sizes[k].free))
      break;
  }
  if (k >= NSIZES)
    return 0;

  char *p = lst_pop(&bd_table.bd_sizes[k].free);
  int pindex = get_page_index(p);
  void *pbase = bd_table.plist[pindex].pageaddr;
  // printf("size: %d\n", nbytes);
  // printf("num: %d\n", num++);
  // printf("pindex: %d\n", pindex);
  // printf("pbase: %p %p %p\n", p, pbase, bd_table.plist[0].pageaddr);
  bit_set(bd_table.plist[pindex].alloc[k], blk_index(k, p, pbase));
  for (; k > fk; k--) {
    char *q = p + BLK_SIZE(k-1);
    // bit_set(bd_table.plist[pindex].split[k], blk_index(k, p, pbase));
    bit_set(bd_table.plist[pindex].alloc[k-1], blk_index(k-1, p, pbase));
    lst_push(&bd_table.bd_sizes[k-1].free, q);
  }
  return p;
}

void
lst_init(struct bd_list *lst)
{
  lst->next = lst;
  lst->prev = lst;
}

int
lst_empty(struct bd_list *lst) {
  return lst->next == lst;
}

void
lst_remove(struct bd_list *e) {
  e->prev->next = e->next;
  e->next->prev = e->prev;
}

void*
lst_pop(struct bd_list *lst) {
  struct bd_list *p = lst->next;
  lst_remove(p);
  return (void *)p;
}

void
lst_push(struct bd_list *lst, void *p)
{
  struct bd_list *e = (struct bd_list *) p;
  e->next = lst->next;
  e->prev = lst;
  lst->next->prev = p;
  lst->next = e;
}

