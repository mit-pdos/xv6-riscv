#define LEAF_SIZE     32
#define NSIZES        8
#define MAX_SIZE     NSIZES-1
#define BLK_SIZE(k)   ((1L << (k)) * LEAF_SIZE) 
#define HEAP_SIZE     BLK_SIZE(MAX_SIZE) // 4096
#define ROUNDUP(n,sz) (((((n)-1)/(sz))+1)*(sz))
#define MAX_PAGES     64