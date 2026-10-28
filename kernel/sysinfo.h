#ifndef SYSINFO_H
#define SYSINFO_H

#ifndef offsetof
#define offsetof(t, m) __builtin_offsetof(t, m)
#endif

#define MAXFILEINFO 100   // = NFILE
#define MAXPROCINFO 64    // = NPROC
#define MAXFD       16    // = NOFILE
#define MAXPIDREF   16    // số pid tối đa liệt kê cho 1 file

struct fileinfo {
  int id;                 // chỉ số trong ftable.file
  int type;               // 0 NONE, 1 PIPE, 2 INODE, 3 DEVICE
  int readable;
  int writable;
  int ref;
  int npid;
  int pids[MAXPIDREF];
};

struct procinfo {
  int pid;
  int state;              // 0 UNUSED,1 USED,2 SLEEPING,3 RUNNABLE,4 RUNNING,5 ZOMBIE
  int ppid;               // 0 nếu không có cha
  int sched_count;
  int nfd;
  int fds[MAXFD];         // số fd đang mở
  int fileids[MAXFD];     // fileinfo.id tương ứng với fds[i]
};

struct sysinfo {
  int nfile;
  int nproc;
  struct fileinfo files[MAXFILEINFO];
  struct procinfo procs[MAXPROCINFO];
};

#endif