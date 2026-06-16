typedef unsigned int uint;
typedef unsigned short ushort;
typedef unsigned char uchar;

typedef unsigned char uint8;
typedef unsigned short uint16;
typedef unsigned int uint32;
typedef unsigned long uint64;

typedef uint64 pde_t;

// Memory info structure for meminfo() syscall
struct meminfo {
  uint64 free_pages;   // current free pages
  uint64 used_pages;   // current used pages
  uint64 total_pages;  // total physical pages
  uint64 frag_blocks;  // non-contiguous blocks in free list (fragmentation metric)
};
