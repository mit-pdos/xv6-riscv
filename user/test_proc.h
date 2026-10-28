// Test về process (phần của B)
// Dùng lại: info, find_proc, find_file, sysinfo_check (sysinfo_print.h)
// Trạng thái: 0 UNUSED, 1 USED, 2 SLEEPING, 3 RUNNABLE, 4 RUNNING, 5 ZOMBIE

#include "kernel/fcntl.h"

// fileid của fd trong process p, -1 nếu p không giữ fd đó
static int
proc_fileid(struct procinfo *p, int fd)
{
  for(int k = 0; k < p->nfd; k++)
    if(p->fds[k] == fd)
      return p->fileids[k];
  return -1;
}

// Cho n con chờ trên pipe (chưa thoát). Trả về số con tạo được, pid lưu vào pids[].
// Ghi vào gate[1] một byte mỗi con để thả chúng ra.
static int
proc_spawn_waiters(int n, int *pids, int *gate)
{
  int made = 0;
  if(pipe(gate) < 0)
    return 0;
  for(int i = 0; i < n; i++){
    int pid = fork();
    if(pid < 0)
      break;
    if(pid == 0){
      char c;
      close(gate[1]);
      read(gate[0], &c, 1);
      exit(0);
    }
    pids[made++] = pid;
  }
  return made;
}

static void
proc_release_waiters(int made, int *gate)
{
  char c = 'x';
  for(int i = 0; i < made; i++)
    write(gate[1], &c, 1);
  close(gate[0]);
  close(gate[1]);
  for(int i = 0; i < made; i++)
    wait(0);
}

void
test_proc(void)
{
  int me = getpid();
  int base_nproc, ok;
  struct procinfo *p;

  printf("[proc] nproc before/after fork\n");
  sysinfo(&info);
  base_nproc = info.nproc;

  int pids[4], gate[2];
  int made = proc_spawn_waiters(3, pids, gate);
  sysinfo_check("forked 3 children", made == 3);

  sysinfo(&info);
  sysinfo_check("nproc increases by 3 after 3 forks", info.nproc == base_nproc + 3);

  printf("[proc] ppid of children\n");
  ok = (made == 3);
  for(int i = 0; i < made; i++){
    p = find_proc(&info, pids[i]);
    if(!p || p->ppid != me)
      ok = 0;
  }
  sysinfo_check("every child is listed with ppid == my pid", ok);

  ok = 1;
  for(int i = 0; i < made; i++){
    p = find_proc(&info, pids[i]);
    if(!p || p->state == 0)
      ok = 0;
  }
  sysinfo_check("children are not UNUSED", ok);

  p = find_proc(&info, me);
  sysinfo_check("parent still RUNNING", p && p->state == 4);

  printf("[proc] children inherit fds\n");
  ok = (p != 0);
  for(int i = 0; i < made && ok; i++){
    struct procinfo *c = find_proc(&info, pids[i]);
    if(!c)
      ok = 0;
    else
      for(int fd = 0; fd < 3; fd++)
        if(proc_fileid(c, fd) != proc_fileid(p, fd) || proc_fileid(c, fd) < 0)
          ok = 0;
  }
  sysinfo_check("children hold same file ids as parent for fd 0,1,2", ok);

  // pipe cha mở trước fork: con phải thấy cả hai đầu pipe lúc mới fork
  // (con đóng gate[1] ngay sau khi chạy nên chỉ kiểm tra gate[0])
  ok = (p != 0);
  for(int i = 0; i < made && ok; i++){
    struct procinfo *c = find_proc(&info, pids[i]);
    if(!c || proc_fileid(c, gate[0]) != proc_fileid(p, gate[0]) ||
       proc_fileid(c, gate[0]) < 0)
      ok = 0;
  }
  sysinfo_check("children share the pipe read end with parent", ok);

  proc_release_waiters(made, gate);
  sysinfo(&info);
  sysinfo_check("nproc back to base after children exit and are waited",
                info.nproc == base_nproc);
  ok = 1;
  for(int i = 0; i < made; i++)
    if(find_proc(&info, pids[i]))
      ok = 0;
  sysinfo_check("reaped children are no longer listed", ok);

  printf("[proc] several children holding one file\n");
  int fd = open("proc_test_file", O_CREATE | O_RDWR);
  sysinfo_check("created test file", fd >= 0);
  sysinfo(&info);
  p = find_proc(&info, me);
  int shared_id = p ? proc_fileid(p, fd) : -1;
  sysinfo_check("parent lists the new fd", shared_id >= 0);
  int nfd_with_file = p ? p->nfd : 0;

  made = proc_spawn_waiters(3, pids, gate);
  sysinfo(&info);
  ok = (made == 3 && shared_id >= 0);
  for(int i = 0; i < made && ok; i++){
    struct procinfo *c = find_proc(&info, pids[i]);
    if(!c || proc_fileid(c, fd) != shared_id)
      ok = 0;
  }
  sysinfo_check("3 children + parent all point at the same file id", ok);

  p = find_proc(&info, me);
  sysinfo_check("parent nfd grows by 2 for the pipe", p && p->nfd == nfd_with_file + 2);
  proc_release_waiters(made, gate);

  printf("[proc] open / dup / close change the fd list\n");
  sysinfo(&info);
  p = find_proc(&info, me);
  int nfd0 = p ? p->nfd : 0;

  int d = dup(fd);
  sysinfo(&info);
  p = find_proc(&info, me);
  sysinfo_check("dup adds one fd", p && p->nfd == nfd0 + 1);
  sysinfo_check("dup'd fd has the same file id", p && proc_fileid(p, d) == shared_id);

  int o = open("proc_test_file", O_RDWR);
  sysinfo(&info);
  p = find_proc(&info, me);
  sysinfo_check("second open adds one fd", p && p->nfd == nfd0 + 2);
  sysinfo_check("second open gets a different file id",
                p && proc_fileid(p, o) >= 0 && proc_fileid(p, o) != shared_id);

  close(d);
  close(o);
  sysinfo(&info);
  p = find_proc(&info, me);
  sysinfo_check("close removes the fds again", p && p->nfd == nfd0 &&
                proc_fileid(p, d) == -1 && proc_fileid(p, o) == -1);
  close(fd);
  unlink("proc_test_file");

  printf("[proc] zombie\n");
  sysinfo(&info);
  base_nproc = info.nproc;
  int zp = fork();
  if(zp == 0)
    exit(0);
  pause(5);   // cho con kịp chạy và thoát; cha chưa wait
  sysinfo(&info);
  p = find_proc(&info, zp);
  sysinfo_check("exited-but-not-waited child is still listed", p != 0);
  sysinfo_check("it is in ZOMBIE state", p && p->state == 5);
  sysinfo_check("zombie holds no open files", p && p->nfd == 0);
  sysinfo_check("zombie ppid is still my pid", p && p->ppid == me);
  sysinfo_check("zombie was scheduled at least once", p && p->sched_count >= 1);
  sysinfo_check("zombie counts toward nproc", info.nproc == base_nproc + 1);
  wait(0);
  sysinfo(&info);
  sysinfo_check("zombie disappears after wait", find_proc(&info, zp) == 0 &&
                info.nproc == base_nproc);

  printf("[proc] sched_count grows over time\n");
  sysinfo(&info);
  p = find_proc(&info, me);
  int s1 = p ? p->sched_count : 0;
  for(int i = 0; i < 3; i++)
    pause(1);   // mỗi lần ngủ buộc phải được lập lịch lại
  sysinfo(&info);
  p = find_proc(&info, me);
  int s2 = p ? p->sched_count : 0;
  sysinfo_check("my sched_count increases after sleeping", s2 > s1);

  // init và sh ngủ chờ nên có sched_count >= 1, và không bị đổi sang UNUSED
  ok = 1;
  for(int i = 0; i < info.nproc; i++)
    if(info.procs[i].sched_count < 1)
      ok = 0;
  sysinfo_check("every listed process has sched_count >= 1", ok);

  printf("[proc] parent of init and ordering\n");
  p = find_proc(&info, 1);
  sysinfo_check("init (pid 1) is listed with ppid 0", p && p->ppid == 0);
  ok = 1;
  for(int i = 0; i < info.nproc; i++){
    struct procinfo *q = &info.procs[i];
    if(q->pid != 1 && (q->ppid <= 0 || !find_proc(&info, q->ppid)))
      ok = 0;
  }
  sysinfo_check("every other process has a listed parent", ok);
}