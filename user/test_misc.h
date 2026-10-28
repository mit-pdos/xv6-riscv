// Test tổng hợp và trường hợp biên 

static struct sysinfo misc_info;

void
test_misc(void)
{
  int i, ok;

  printf("[misc] repeated calls\n");
  int r1 = sysinfo(&info);
  int r2 = sysinfo(&misc_info);
  sysinfo_check("sysinfo returns 0", r1 == 0 && r2 == 0);
  sysinfo_check("nfile stable across calls", info.nfile == misc_info.nfile);
  sysinfo_check("nproc stable across calls", info.nproc == misc_info.nproc);

  printf("[misc] sanity of results\n");
  sysinfo_check("nproc >= 3 (init, sh, this program)", info.nproc >= 3);
  sysinfo_check("nfile >= 1", info.nfile >= 1);
  sysinfo_check("nfile within limit", info.nfile <= MAXFILEINFO);
  sysinfo_check("nproc within limit", info.nproc <= MAXPROCINFO);

  struct procinfo *self = find_proc(&info, getpid());
  sysinfo_check("own pid is listed", self != 0);
  if(self){
    sysinfo_check("own state is RUNNING", self->state == 4);
    sysinfo_check("own ppid > 0", self->ppid > 0);
    sysinfo_check("own sched_count >= 1", self->sched_count >= 1);
  }

  ok = 0;
  for(i = 0; i < info.nfile; i++)
    if(info.files[i].type == 3 && info.files[i].readable && info.files[i].writable)
      ok = 1;
  sysinfo_check("console (DEVICE, rw) is listed", ok);

  ok = 1;
  for(i = 0; i < info.nproc; i++)
    if(info.procs[i].state == 0)
      ok = 0;
  sysinfo_check("no UNUSED process is listed", ok);

  printf("[misc] cross-check files <-> processes\n");
  ok = 1;
  for(i = 0; i < info.nfile; i++){
    struct fileinfo *f = &info.files[i];
    if(f->ref < f->npid)
      ok = 0;
    for(int j = 0; j < f->npid; j++){
      struct procinfo *p = find_proc(&info, f->pids[j]);
      int found = 0;
      if(p){
        for(int k = 0; k < p->nfd; k++)
          if(p->fileids[k] == f->id)
            found = 1;
      }
      if(!found)
        ok = 0;
    }
  }
  sysinfo_check("every pid of a file exists and holds that file", ok);

  ok = 1;
  for(i = 0; i < info.nproc; i++){
    struct procinfo *p = &info.procs[i];
    for(int k = 0; k < p->nfd; k++){
      struct fileinfo *f = find_file(&info, p->fileids[k]);
      int found = 0;
      if(f){
        for(int j = 0; j < f->npid; j++)
          if(f->pids[j] == p->pid)
            found = 1;
      }
      if(!found)
        ok = 0;
    }
  }
  sysinfo_check("every file of a process lists that pid", ok);

  printf("[misc] invalid addresses\n");
  sysinfo_check("address above MAXVA returns -1",
                sysinfo((struct sysinfo *)0x4000000000UL) == -1);
  sysinfo_check("unmapped address returns -1",
                sysinfo((struct sysinfo *)((uint64)sbrk(0) + 0x10000)) == -1);
  // struct dài hơn phần bộ nhớ còn lại: copyout phải thất bại giữa chừng
  sysinfo_check("struct crossing end of memory returns -1",
                sysinfo((struct sysinfo *)((uint64)sbrk(0) - 64)) == -1);
  sysinfo_check("still works after bad calls", sysinfo(&info) == 0);

  printf("[misc] no leak over many calls\n");
  ok = 1;
  for(i = 0; i < 100; i++){
    if(sysinfo(&misc_info) != 0 || misc_info.nfile != info.nfile ||
       misc_info.nproc != info.nproc)
      ok = 0;
  }
  sysinfo_check("100 calls: all succeed, counts unchanged", ok);
}