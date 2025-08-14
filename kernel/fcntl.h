#ifndef xv6_fcntl_h
#define xv6_fcntl_h

#define O_RDONLY  0x000
#define O_WRONLY  0x001
#define O_RDWR    0x002
#define O_CREATE  0x200
#define O_TRUNC   0x400

// mmap
#define PROT_READ   0x1
#define PROT_WRITE  0x2
#define MAP_PRIVATE 0x1
#define MAP_SHARED  0x2

#define MMAP_FAILED 0xffffffffffffffff

typedef struct {
  uint64 addr;
  size_t len;
  int flags;
  int prot;
  struct file *file;
} MappedMem;

#endif // !xv6_fcntl_h

