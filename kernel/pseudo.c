#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "fs.h"
#include "file.h"

#define CHUNK 128

struct {
  struct spinlock lock;
  uint64 seed;
  uint64 nbytes;
} pseudo;

int
readzero(int user_dst, uint64 dst, int n)
{
  char buf[CHUNK];
  int done = 0;
  int m;

  memset(buf, 0, sizeof(buf));
  while (done < n) {
    m = n - done;
    if (m > CHUNK)
      m = CHUNK;
    if (either_copyout(user_dst, dst + done, buf, m) == -1)
      break;
    done += m;
  }
  return done;
}

int
readurandom(int user_dst, uint64 dst, int n)
{
  char buf[CHUNK];
  int done = 0;
  int m, i;

  while (done < n) {
    m = n - done;
    if (m > CHUNK)
      m = CHUNK;
    acquire(&pseudo.lock);
    for (i = 0; i < m; i++) {
      pseudo.seed = pseudo.seed * 6364136223846793005ULL + 1442695040888963407ULL;
      buf[i] = (pseudo.seed >> 56) & 0xFF;
    }
    release(&pseudo.lock);
    if (either_copyout(user_dst, dst + done, buf, m) == -1)
      break;
    done += m;
  }
  return done;
}

int
readnullstat(int user_dst, uint64 dst, int n)
{
  uint64 v;

  if (n != sizeof(v))
    return -1;
  acquire(&pseudo.lock);
  v = pseudo.nbytes;
  release(&pseudo.lock);
  if (either_copyout(user_dst, dst, &v, sizeof(v)) == -1)
    return -1;
  return n;
}

int
writeurandom(int user_src, uint64 src, int n)
{
  uint64 s;

  if (n != sizeof(s))
    return -1;
  if (either_copyin(&s, user_src, src, sizeof(s)) == -1)
    return -1;
  acquire(&pseudo.lock);
  pseudo.seed = s;
  release(&pseudo.lock);
  return n;
}

int
writenullstat(int n)
{
  acquire(&pseudo.lock);
  pseudo.nbytes += n;
  release(&pseudo.lock);
  return n;
}

int
pseudoread(int user_dst, int minor, uint64 dst, int n)
{
  if (minor == DEV_NULL)
    return 0;
  if (minor == DEV_ZERO)
    return readzero(user_dst, dst, n);
  if (minor == DEV_URANDOM)
    return readurandom(user_dst, dst, n);
  if (minor == DEV_NULLSTAT)
    return readnullstat(user_dst, dst, n);
  return -1;
}

int
pseudowrite(int user_src, int minor, uint64 src, int n)
{
  if (minor == DEV_NULL)
    return n;
  if (minor == DEV_URANDOM)
    return writeurandom(user_src, src, n);
  if (minor == DEV_NULLSTAT)
    return writenullstat(n);
  return -1;
}

void
pseudoinit(void)
{
  initlock(&pseudo.lock, "pseudo");
  pseudo.seed = 1;
  pseudo.nbytes = 0;

  devsw[PSEUDO].read = pseudoread;
  devsw[PSEUDO].write = pseudowrite;
}
