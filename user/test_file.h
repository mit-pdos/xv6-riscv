// Test về file (phần của A)
// Chỉ dựa vào info.files[], không phụ thuộc fill_procinfo của B.
#include "kernel/fcntl.h"

#define FI_PIPE   1
#define FI_INODE  2
#define FI_DEVICE 3

static int
tf_has_pid(struct fileinfo *f, int pid)
{
  for (int j = 0; j < f->npid; j++)
    if (f->pids[j] == pid)
      return 1;
  return 0;
}

// Gọi sysinfo, trả về nfile (hoặc -1 nếu lỗi).
static int
tf_nfile(void)
{
  if (sysinfo(&info) < 0)
    return -1;
  return info.nfile;
}

// File đầu tiên có type/readable/writable khớp và có pid của mình trong danh sách.
// r, w = -1 nghĩa là không quan tâm.
static struct fileinfo *
tf_mine(int type, int r, int w)
{
  int me = getpid();
  for (int i = 0; i < info.nfile; i++) {
    struct fileinfo *f = &info.files[i];
    if (f->type != type)
      continue;
    if (r >= 0 && f->readable != r)
      continue;
    if (w >= 0 && f->writable != w)
      continue;
    if (tf_has_pid(f, me))
      return f;
  }
  return 0;
}

static int
tf_count_mine(int type)
{
  int me = getpid(), c = 0;
  for (int i = 0; i < info.nfile; i++)
    if (info.files[i].type == type && tf_has_pid(&info.files[i], me))
      c++;
  return c;
}

// 1. open rồi close
static void
tf_open_close(void)
{
  printf("[file] open / close\n");
  int base = tf_nfile();
  int fd = open("README", O_RDONLY);
  sysinfo_check("open README succeeds", fd >= 0);
  if (fd < 0)
    return;

  sysinfo_check("nfile +1 after open", tf_nfile() == base + 1);
  struct fileinfo *f = tf_mine(FI_INODE, 1, 0);
  sysinfo_check("listed as INODE, mode r-", f != 0);
  sysinfo_check("ref == 1", f && f->ref == 1);
  sysinfo_check("pid list is only me",
                f && f->npid == 1 && f->pids[0] == getpid());

  close(fd);
  sysinfo_check("nfile back to base after close", tf_nfile() == base);
  sysinfo_check("file no longer listed", tf_mine(FI_INODE, -1, -1) == 0);
}

// 2. mở cùng 1 file 2 lần -> 2 entry khác nhau trong ftable
static void
tf_open_twice(void)
{
  printf("[file] open same file twice\n");
  int base = tf_nfile();
  int fd1 = open("README", O_RDONLY);
  int fd2 = open("README", O_RDONLY);
  sysinfo_check("both opens succeed", fd1 >= 0 && fd2 >= 0);
  if (fd1 < 0 || fd2 < 0)
    return;

  sysinfo_check("nfile +2 (open creates a new entry each time)",
                tf_nfile() == base + 2);
  sysinfo_check("2 INODE entries are mine", tf_count_mine(FI_INODE) == 2);
  int ok = 1, id[2] = {-1, -1}, k = 0, me = getpid();
  for (int i = 0; i < info.nfile && k < 2; i++) {
    struct fileinfo *f = &info.files[i];
    if (f->type == FI_INODE && tf_has_pid(f, me)) {
      if (f->ref != 1)
        ok = 0;
      id[k++] = f->id;
    }
  }
  sysinfo_check("each entry has ref == 1", ok);
  sysinfo_check("the 2 entries have different ids", id[0] != id[1]);

  close(fd1);
  sysinfo_check("close one: 1 entry left",
                tf_nfile() == base + 1 && tf_count_mine(FI_INODE) == 1);
  close(fd2);
  sysinfo_check("close both: back to base", tf_nfile() == base);
}

// 3. dup -> cùng entry, ref tăng, nfile không đổi
static void
tf_dup_close(void)
{
  printf("[file] dup / close\n");
  int base = tf_nfile();
  int fd = open("README", O_RDONLY);
  if (fd < 0) {
    sysinfo_check("open README succeeds", 0);
    return;
  }
  int d = dup(fd);
  sysinfo_check("dup succeeds", d >= 0);
  if (d < 0) {
    close(fd);
    return;
  }

  sysinfo_check("nfile +1 only (dup shares the entry)", tf_nfile() == base + 1);
  struct fileinfo *f = tf_mine(FI_INODE, 1, 0);
  sysinfo_check("ref == 2 after dup", f && f->ref == 2);
  sysinfo_check("npid == 1 (2 fds, same process)", f && f->npid == 1);

  close(fd);
  tf_nfile();
  f = tf_mine(FI_INODE, 1, 0);
  sysinfo_check("close original: ref == 1, still listed", f && f->ref == 1);
  sysinfo_check("nfile unchanged after first close", tf_nfile() == base + 1);

  close(d);
  sysinfo_check("close dup: entry freed",
                tf_nfile() == base && tf_mine(FI_INODE, -1, -1) == 0);
}

// 4. fork -> con dùng chung entry, ref và npid tăng
static void
tf_fork_share(void)
{
  printf("[file] fork shares open files\n");
  int p[2];
  if (pipe(p) < 0) {
    sysinfo_check("pipe succeeds", 0);
    return;
  }
  int base = tf_nfile(); // đã tính pipe
  int fd = open("README", O_RDONLY);
  if (fd < 0) {
    sysinfo_check("open README succeeds", 0);
    return;
  }

  int pid = fork();
  if (pid < 0) {
    sysinfo_check("fork succeeds", 0);
    return;
  }
  if (pid == 0) {
    close(p[1]);
    char c;
    read(p[0], &c, 1); // chờ cha cho phép thoát
    exit(0);
  }

  sysinfo_check("nfile +1 only (fork creates no new entry)",
                tf_nfile() == base + 1);
  struct fileinfo *f = tf_mine(FI_INODE, 1, 0);
  sysinfo_check("ref == 2 (parent + child)", f && f->ref == 2);
  sysinfo_check("npid == 2", f && f->npid == 2);
  sysinfo_check("child pid is listed", f && tf_has_pid(f, pid));
  sysinfo_check("parent pid is listed", f && tf_has_pid(f, getpid()));

  write(p[1], "x", 1); // cho con thoát
  wait(0);

  f = (tf_nfile() >= 0) ? tf_mine(FI_INODE, 1, 0) : 0;
  sysinfo_check("after child exits: ref == 1", f && f->ref == 1);
  sysinfo_check("after child exits: npid == 1", f && f->npid == 1);

  close(fd);
  close(p[0]);
  close(p[1]);
  sysinfo_check("all closed: back to before-pipe count",
                tf_nfile() == base - 2);
}

// 5. pipe: 2 entry (đầu đọc, đầu ghi)
static void
tf_pipe(void)
{
  printf("[file] pipe\n");
  int base = tf_nfile();
  int p[2];
  if (pipe(p) < 0) {
    sysinfo_check("pipe succeeds", 0);
    return;
  }

  sysinfo_check("nfile +2 after pipe", tf_nfile() == base + 2);
  struct fileinfo *rd = tf_mine(FI_PIPE, 1, 0);
  sysinfo_check("read end: PIPE r-, ref == 1", rd && rd->ref == 1);
  struct fileinfo *wr = tf_mine(FI_PIPE, 0, 1);
  sysinfo_check("write end: PIPE -w, ref == 1", wr && wr->ref == 1);

  int d = dup(p[1]);
  wr = tf_nfile() >= 0 ? tf_mine(FI_PIPE, 0, 1) : 0;
  sysinfo_check("dup write end: ref == 2, nfile unchanged",
                wr && wr->ref == 2 && info.nfile == base + 2);
  close(d);

  close(p[0]);
  sysinfo_check("close read end: nfile +1", tf_nfile() == base + 1);
  sysinfo_check("read end no longer listed", tf_mine(FI_PIPE, 1, 0) == 0);
  close(p[1]);
  sysinfo_check("close write end: back to base", tf_nfile() == base);
}

// 6. console
static void
tf_console(void)
{
  printf("[file] console\n");
  struct fileinfo *c = (tf_nfile() >= 0) ? tf_mine(FI_DEVICE, 1, 1) : 0;
  sysinfo_check("stdin/out/err entry is DEVICE rw", c != 0);
  if (!c)
    return;
  sysinfo_check("fd 0,1,2 share one entry: ref >= 3", c->ref >= 3);
  int id = c->id, ref0 = c->ref, base = info.nfile;

  int d = dup(0);
  sysinfo_check("dup(0) succeeds", d >= 0);
  if (d >= 0) {
    tf_nfile();
    struct fileinfo *c2 = find_file(&info, id);
    sysinfo_check("dup(0): same entry, ref +1", c2 && c2->ref == ref0 + 1);
    sysinfo_check("dup(0): nfile unchanged", info.nfile == base);
    close(d);
    tf_nfile();
    c2 = find_file(&info, id);
    sysinfo_check("close dup: ref back", c2 && c2->ref == ref0);
  }

  int fd = open("console", O_RDWR);
  sysinfo_check("open console succeeds", fd >= 0);
  if (fd >= 0) {
    sysinfo_check("open console: new entry, nfile +1", tf_nfile() == base + 1);
    sysinfo_check("2 DEVICE entries are mine", tf_count_mine(FI_DEVICE) == 2);
    close(fd);
    sysinfo_check("close: nfile back", tf_nfile() == base);
  }
}

// 7. mode readable/writable theo cờ open
static void
tf_modes(void)
{
  printf("[file] open modes\n");
  int fd = open("tf_mode", O_CREATE | O_RDWR);
  sysinfo_check("create tf_mode (O_RDWR)", fd >= 0);
  if (fd < 0)
    return;
  tf_nfile();
  struct fileinfo *f = tf_mine(FI_INODE, -1, -1);
  sysinfo_check("O_RDWR -> rw", f && f->readable == 1 && f->writable == 1);
  close(fd);

  fd = open("tf_mode", O_WRONLY);
  tf_nfile();
  f = tf_mine(FI_INODE, -1, -1);
  sysinfo_check("O_WRONLY -> -w",
                fd >= 0 && f && f->readable == 0 && f->writable == 1);
  if (fd >= 0)
    close(fd);

  fd = open("tf_mode", O_RDONLY);
  tf_nfile();
  f = tf_mine(FI_INODE, -1, -1);
  sysinfo_check("O_RDONLY -> r-",
                fd >= 0 && f && f->readable == 1 && f->writable == 0);
  if (fd >= 0)
    close(fd);

  unlink("tf_mode");
}

// 8. mở đến hết fd
#define TF_MAXTRY 64
static void
tf_exhaust_fds(void)
{
  printf("[file] open until out of fds\n");
  int fds[TF_MAXTRY];
  int base = tf_nfile();
  int n = 0;
  while (n < TF_MAXTRY) {
    int fd = open("README", O_RDONLY);
    if (fd < 0)
      break;
    fds[n++] = fd;
  }
  sysinfo_check("open eventually fails (per-process fd limit)",
                n > 0 && n < TF_MAXTRY);
  sysinfo_check("nfile == base + number opened", tf_nfile() == base + n);
  sysinfo_check("my INODE entries == number opened",
                tf_count_mine(FI_INODE) == n);
  int allref1 = 1;
  for (int i = 0; i < info.nfile; i++)
    if (info.files[i].type == FI_INODE && info.files[i].ref != 1)
      allref1 = 0;
  sysinfo_check("every INODE entry has ref == 1", allref1);
  sysinfo_check("failed open leaked no entry",
                open("README", O_RDONLY) < 0 && tf_nfile() == base + n);

  for (int i = 0; i < n; i++)
    close(fds[i]);
  sysinfo_check("close all: back to base", tf_nfile() == base);
}

void
test_file(void)
{
  tf_open_close();
  tf_open_twice();
  tf_dup_close();
  tf_fork_share();
  tf_pipe();
  tf_console();
  tf_modes();
  tf_exhaust_fds();
}