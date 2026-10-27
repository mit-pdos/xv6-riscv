// Helper dùng chung, không tự viết hàm kiểm tra riêng.

int sysinfo_npass = 0;
int sysinfo_nfail = 0;

const char *state_name[] = {"UNUSED", "USED", "SLEEPING", "RUNNABLE", "RUNNING", "ZOMBIE"};
const char *type_name[]  = {"NONE", "PIPE", "INODE", "DEVICE"};

const char *
sname(int s)
{
  return (s >= 0 && s < 6) ? state_name[s] : "?";
}

const char *
tname(int t)
{
  return (t >= 0 && t < 4) ? type_name[t] : "?";
}

void
sysinfo_check(const char *name, int cond)
{
  if(cond){
    sysinfo_npass++;
    printf("  PASS: %s\n", name);
  } else {
    sysinfo_nfail++;
    printf("  FAIL: %s\n", name);
  }
}

struct procinfo *
find_proc(struct sysinfo *si, int pid)
{
  for(int i = 0; i < si->nproc; i++)
    if(si->procs[i].pid == pid)
      return &si->procs[i];
  return 0;
}

struct fileinfo *
find_file(struct sysinfo *si, int id)
{
  for(int i = 0; i < si->nfile; i++)
    if(si->files[i].id == id)
      return &si->files[i];
  return 0;
}

void
print_sysinfo(struct sysinfo *si)
{
  printf("== open files: %d ==\n", si->nfile);
  for(int i = 0; i < si->nfile; i++){
    struct fileinfo *f = &si->files[i];
    printf("  file#%d type=%s mode=%c%c ref=%d pids:", f->id, tname(f->type),
           f->readable ? 'r' : '-', f->writable ? 'w' : '-', f->ref);
    for(int j = 0; j < f->npid; j++)
      printf(" %d", f->pids[j]);
    printf("\n");
  }
  printf("== processes: %d ==\n", si->nproc);
  for(int i = 0; i < si->nproc; i++){
    struct procinfo *p = &si->procs[i];
    printf("  pid=%d state=%s ppid=%d sched=%d files:", p->pid, sname(p->state),
           p->ppid, p->sched_count);
    for(int j = 0; j < p->nfd; j++)
      printf(" fd%d->#%d", p->fds[j], p->fileids[j]);
    printf("\n");
  }
}