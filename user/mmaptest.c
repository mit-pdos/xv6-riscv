#include "kernel/param.h"
#include "kernel/fcntl.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/riscv.h"
#include "kernel/fs.h"
#include "user/user.h"

void mmap_test();
void fork_test();
void more_test();
char buf[PGSIZE];

#define MAP_FAILED ((char *) -1)

#define min(a, b) ((a) < (b) ? (a) : (b))

int
main(int argc, char *argv[])
{
  mmap_test();
  fork_test();
  more_test();
  printf("mmaptest: all tests succeeded\n");
  exit(0);
}

void
err(char *why)
{
  printf("mmaptest failure: %s, pid=%d\n", why, getpid());
  exit(1);
}

//
// check the content of the two mapped pages.
//
void
_v1(char *p)
{
  int i;
  for (i = 0; i < PGSIZE*2; i++) {
    if (i < PGSIZE + (PGSIZE/2)) {
      if (p[i] != 'A') {
        printf("mismatch at %d, wanted 'A', got 0x%x\n", i, p[i]);
        err("v1 mismatch (1)");
      }
    } else {
      if (p[i] != 0) {
        printf("mismatch at %d, wanted zero, got 0x%x\n", i, p[i]);
        err("v1 mismatch (2)");
      }
    }
  }
}

//
// create a file to be mapped, containing
// 1.5 pages of 'A' and half a page of zeros.
//
void
makefile(const char *f)
{
  int i;
  int n = PGSIZE + (PGSIZE/2);  

  unlink(f);
  int fd = open(f, O_WRONLY | O_CREATE);
  if (fd == -1)
    err("open");
  memset(buf, 'A', BSIZE);
  // write 1.5 page
  for(i = 0; i < n; i += PGSIZE) {
    int n1 = min(BSIZE, n - i); 
    if (write(fd, buf, n1) != n1)
      err("write 0 makefile"); 
  }
  if (close(fd) == -1)
    err("close");
}

void
mmap_test(void)
{
  int fd;
  int i;
  const char * const f = "mmap.dur";

  //
  // create a file with known content, map it into memory, check that
  // the mapped memory has the same bytes as originally written to the
  // file.
  //
  makefile(f);
  if ((fd = open(f, O_RDONLY)) == -1)
    err("open (1)");

  printf("test basic mmap\n");
  //
  // this call to mmap() asks the kernel to map the content
  // of open file fd into the address space. the first
  // 0 argument indicates that the kernel should choose the
  // virtual address. the second argument indicates how many
  // bytes to map. the third argument indicates that the
  // mapped memory should be read-only. the fourth argument
  // indicates that, if the process modifies the mapped memory,
  // that the modifications should not be written back to
  // the file nor shared with other processes mapping the
  // same file (of course in this case updates are prohibited
  // due to PROT_READ). the fifth argument is the file descriptor
  // of the file to be mapped. the last argument is the starting
  // offset in the file.
  //
  char *p = mmap(0, PGSIZE*2, PROT_READ, MAP_PRIVATE, fd, 0);
  if (p == MAP_FAILED)
    err("mmap (1)");
  _v1(p);
  if (munmap(p, PGSIZE*2) == -1)
    err("munmap (1)");

  printf("test basic mmap: OK\n");

  printf("test mmap private\n");
  // should be able to map file opened read-only with private writable
  // mapping
  p = mmap(0, PGSIZE*2, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);
  if (p == MAP_FAILED)
    err("mmap (2)");
  if (close(fd) == -1)
    err("close (1)");
  _v1(p);
  for (i = 0; i < PGSIZE*2; i++)
    p[i] = 'Z';
  if (munmap(p, PGSIZE*2) == -1)
    err("munmap (2)");
  close(fd);

  // file should not have been modified.
  if((fd = open(f, O_RDONLY)) < 0) err("open");
  if(read(fd, buf, PGSIZE) != PGSIZE) err("read");
  if(buf[0] != 'A')
    err("write to MAP_PRIVATE was written to file");
  if(read(fd, buf, PGSIZE) != PGSIZE/2) err("read");
  if(buf[0] != 'A')
    err("write to MAP_PRIVATE was written to file");
  close(fd);

  printf("test mmap private: OK\n");

  printf("test mmap read-only\n");

  // check that mmap doesn't allow read/write mapping of a
  // file opened read-only.
  if ((fd = open(f, O_RDONLY)) == -1)
    err("open (2)");
  p = mmap(0, PGSIZE*2, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
  if (p != MAP_FAILED)
    err("mmap (3)");
  if (close(fd) == -1)
    err("close (2)");

  printf("test mmap read-only: OK\n");

  printf("test mmap read/write\n");

  // check that mmap does allow read/write mapping of a
  // file opened read/write.
  if ((fd = open(f, O_RDWR)) == -1)
    err("open (3)");
  p = mmap(0, PGSIZE*3, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
  if (p == MAP_FAILED)
    err("mmap (4)");
  if (close(fd) == -1)
    err("close (3)");

  // check that the mapping still works after close(fd).
  _v1(p);

  // write the mapped memory.
  for (i = 0; i < PGSIZE; i++)
    p[i] = 'B';
  for (i = PGSIZE; i < PGSIZE*2; i++)
    p[i] = 'C';

  // unmap just the first two of three pages of mapped memory.
  if (munmap(p, PGSIZE*2) == -1)
    err("munmap (3)");

  printf("test mmap read/write: OK\n");

  printf("test mmap dirty\n");

  // check that the writes to the mapped memory were
  // written to the file.
  if ((fd = open(f, O_RDONLY)) == -1)
    err("open (4)");
  if(read(fd, buf, PGSIZE) != PGSIZE)
    err("dirty read #1");
  for (i = 0; i < PGSIZE; i++){
    if (buf[i] != 'B')
      err("file page 0 does not contain modifications");
  }
  if(read(fd, buf, PGSIZE) != PGSIZE/2)
    err("dirty read #2");
  for (i = 0; i < PGSIZE/2; i++){
    if (buf[i] != 'C')
      err("file page 1 does not contain modifications");
  }
  if (close(fd) == -1)
    err("close (4)");

  printf("test mmap dirty: OK\n");

  printf("test not-mapped unmap\n");

  // unmap the rest of the mapped memory.
  if (munmap(p+PGSIZE*2, PGSIZE) == -1)
    err("munmap (4)");

  printf("test not-mapped unmap: OK\n");

  printf("test lazy access\n");

  if(unlink(f) != 0) err("unlink");
  makefile(f);

  if ((fd = open(f, O_RDWR)) == -1)
    err("open");
  p = mmap(0, PGSIZE*2, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
  if (p == MAP_FAILED)
    err("mmap");
  close(fd);

  // mmap() should not have read the file at this point,
  // so that the file modification we're about to make
  // ought to be visible to a subsequent read of the
  // mapped memory.

  if((fd = open(f, O_RDWR)) == -1)
    err("open");
  if(write(fd, "m", 1) != 1)
    err("write");
  close(fd);

  if(*p != 'm')
    err("read was not lazy");

  if(munmap(p, PGSIZE*2) == -1)
    err("munmap");

  printf("test lazy access: OK\n");

  printf("test mmap two files\n");

  //
  // mmap two different files at the same time.
  //
  int fd1;
  if((fd1 = open("mmap1", O_RDWR|O_CREATE)) < 0)
    err("open (5)");
  if(write(fd1, "12345", 5) != 5)
    err("write (1)");
  char *p1 = mmap(0, PGSIZE, PROT_READ, MAP_PRIVATE, fd1, 0);
  if(p1 == MAP_FAILED)
    err("mmap (5)");
  if (close(fd1) == -1)
    err("close (5)");
  if (unlink("mmap1") == -1)
    err("unlink (1)");

  int fd2;
  if((fd2 = open("mmap2", O_RDWR|O_CREATE)) < 0)
    err("open (6)");
  if(write(fd2, "67890", 5) != 5)
    err("write (2)");
  char *p2 = mmap(0, PGSIZE, PROT_READ, MAP_PRIVATE, fd2, 0);
  if(p2 == MAP_FAILED)
    err("mmap (6)");
  if (close(fd2) == -1)
    err("close (6)");
  if (unlink("mmap2") == -1)
    err("unlink (2)");

  if(memcmp(p1, "12345", 5) != 0)
    err("mmap1 mismatch");
  if(memcmp(p2, "67890", 5) != 0)
    err("mmap2 mismatch");

  if (munmap(p1, PGSIZE) == -1)
    err("munmap (5)");
  if(memcmp(p2, "67890", 5) != 0)
    err("mmap2 mismatch (2)");
  if (munmap(p2, PGSIZE) == -1)
    err("munmap (6)");

  printf("test mmap two files: OK\n");
}

//
// mmap a file, then fork.
// check that the child sees the mapped file.
//
void
fork_test(void)
{
  int fd;
  int pid;
  const char * const f = "mmap.dur";

  printf("test fork\n");

  // mmap the file twice.
  makefile(f);
  if ((fd = open(f, O_RDONLY)) == -1)
    err("open (7)");
  if (unlink(f) == -1)
    err("unlink (3)");
  char *p1 = mmap(0, PGSIZE*2, PROT_READ, MAP_SHARED, fd, 0);
  if (p1 == MAP_FAILED)
    err("mmap (7)");
  char *p2 = mmap(0, PGSIZE*2, PROT_READ, MAP_SHARED, fd, 0);
  if (p2 == MAP_FAILED)
    err("mmap (8)");

  // read just 2nd page.
  if(*(p1+PGSIZE) != 'A')
    err("fork mismatch (1)");

  if((pid = fork()) < 0)
    err("fork");
  if (pid == 0) {
    _v1(p1);
    if (munmap(p1, PGSIZE) == -1) // just the first page
      err("munmap (7)");
    exit(0); // tell the parent that the mapping looks OK.
  }

  int status = -1;
  wait(&status);

  if(status != 0){
    printf("fork_test failed\n");
    exit(1);
  }

  // check that the parent's mappings are still there.
  _v1(p1);
  _v1(p2);

  printf("test fork: OK\n");
}

void
more_test()
{
  int fd, pid;
  char *p;
  const char * const f = "mmap.dur";
  
  printf("test munmap prevents access\n");
  
  makefile(f);
  if ((fd = open(f, O_RDWR)) == -1)
    err("open");
  p = mmap(0, PGSIZE*2, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
  if (p == MAP_FAILED)
    err("mmap");
  close(fd);

  *p = 'X';
  *(p+PGSIZE) = 'Y';

  pid = fork();
  if(pid < 0) err("fork");
  if(pid == 0){
    *p = 'a';
    *(p+PGSIZE) = 'b';
    if(munmap(p+PGSIZE, PGSIZE) == -1)
      err("munmap");
    // this should cause a fatal fault
    printf("*(p+PGSIZE) = %x\n", *(p+PGSIZE));
    exit(0);
  }
  int st = 0;
  wait(&st);
  if(st != -1)
    err("child #1 read unmapped memory");

  pid = fork();
  if(pid < 0) err("fork");
  if(pid == 0){
    *p = 'c';
    *(p+PGSIZE) = 'd';
    if(munmap(p, PGSIZE) == -1)
      err("munmap");
    // this should cause a fatal fault
    printf("*p = %x\n", *p);
    exit(0);
  }
  st = 0;
  wait(&st);
  if(st != -1)
    err("child #2 read unmapped memory");

  // parent should still be able to access the memory.
  *p = 'P';
  *(p+PGSIZE) = 'Q';

  if(munmap(p, PGSIZE) == -1)
    err("munmap");

  *(p+PGSIZE) = 'R';
  if(munmap(p+PGSIZE, PGSIZE) == -1)
    err("munmap");

  // read the file, check that the first page starts
  // with P and the second page with R.
  fd = open(f, O_RDONLY);
  if(fd < 0) err("open");
  if(read(fd, buf, PGSIZE) != PGSIZE) err("read");
  if(buf[0] != 'P') err("first byte of file is wrong");
  if(read(fd, buf, PGSIZE) != PGSIZE/2) err("read");
  if(buf[0] != 'R') err("first byte of 2nd page of file is wrong");
  close(fd);

  printf("test munmap prevents access: OK\n");

  printf("test writes to read-only mapped memory\n");

  makefile(f);

  pid = fork();
  if(pid < 0) err("fork");
  if(pid == 0){
    if ((fd = open(f, O_RDWR)) == -1)
      err("open");
    p = mmap(0, PGSIZE*2, PROT_READ, MAP_SHARED, fd, 0);
    if (p == MAP_FAILED)
      err("mmap");
    // this should cause a fatal fault
    *p = 0;
    exit(*p);
  }

  st = 0;
  wait(&st);
  if(st != -1)
    err("child wrote read-only mapping");

  printf("test writes to read-only mapped memory: OK\n");

  printf("test shared mappings\n"); 
  
  makefile(f); 
  if ((fd = open(f, O_RDWR)) == -1)
    err("open"); 
  p = mmap(0, PGSIZE*2, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
  if (p == MAP_FAILED)
    err("mmap"); 
  close(fd); 

  *p = 'B'; 

  pid = fork(); 
  if(pid < 0) err("fork"); 
  if(pid == 0){
    if ((fd = open(f, O_RDWR)) == -1)
      err("open"); 
    p = mmap(0, PGSIZE*2, PROT_READ, MAP_SHARED, fd, 0); 
    if (p == MAP_FAILED)
      err("mmap"); 
    close(fd); 
    if (*p != 'B')
      err("child mapping does not contain modifications"); 
    exit(0); 
  }

  st = 0; 
  wait(&st); 
  if(st != 0){
    printf("shared mapping test failed\n"); 
    exit(1); 
  }

  printf("test shared mappings: OK\n");
}
