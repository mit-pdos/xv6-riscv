#include "defs.h"
#include "kernel/proc.h"
#include "memlayout.h"
#include "param.h"
#include "procinfo.h"
#include "riscv.h"
#include "spinlock.h"
#include "types.h"
#include "vm.h"

uint64 sys_exit(void) {
  int n;
  argint(0, &n);
  kexit(n);
  return 0; // not reached
}

uint64 sys_getpid(void) { return myproc()->pid; }

uint64 sys_fork(void) { return kfork(); }

uint64 sys_wait(void) {
  uint64 p;
  argaddr(0, &p);
  return kwait(p);
}

uint64 sys_sbrk(void) {
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
  argint(1, &t);
  addr = myproc()->sz;

  if (t == SBRK_EAGER || n < 0) {
    if (growproc(n) < 0) {
      return -1;
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
      return -1;
    if (addr + n > TRAPFRAME)
      return -1;
    myproc()->sz += n;
  }
  return addr;
}

uint64 sys_pause(void) {
  int n;
  uint ticks0;

  argint(0, &n);
  if (n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64 sys_kill(void) {
  int pid;

  argint(0, &pid);
  return kkill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64 sys_uptime(void) {
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

extern struct proc proc[];
extern struct spinlock wait_lock;

uint64 sys_ps_listinfo(void) {
  struct procinfo *plist = 0;
  int lim;
  argaddr(0, (uint64 *)&plist);
  argint(1, &lim);

  struct proc *p;
  int cnt_used = 0;
  for (p = proc; p < &proc[NPROC]; ++p) {
    acquire(&p->lock);
    if (p->state != UNUSED) {
      cnt_used++;
    }
    release(&p->lock);
  }
  if (plist == 0)
    return cnt_used;

  if (cnt_used > lim)
    return -1;

  for (p = proc; p < &proc[NPROC]; ++p) {
    acquire(&p->lock);
    if (p->state == UNUSED) {
      release(&p->lock);
      continue;
    }
    struct procinfo cur_proc_info;
    cur_proc_info.pid = p->pid;
    cur_proc_info.name = p->name;
    cur_proc_info.state = p->state;

    acquire(&wait_lock);
    cur_proc_info.ppid = p->parent->pid;
    cur_proc_info.pname = p->parent->name;
    release(&wait_lock);

    int err = copyout(p->pagetable, (uint64)plist, (char *)&cur_proc_info,
                      sizeof(cur_proc_info));
    if (err != 0) {
      release(&p->lock);
      return -1;
    }
    plist += sizeof(cur_proc_info);

    release(&p->lock);
  }

  return cnt_used;
}
