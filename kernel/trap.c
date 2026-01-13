#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

struct spinlock tickslock;
uint ticks;

extern char trampoline[], uservec[];

// in kernelvec.S, calls kerneltrap().
void kernelvec();

extern int devintr();

void
trapinit(void)
{
  initlock(&tickslock, "time");
}

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
  w_stvec((uint64)kernelvec);
}

// handle an interrupt, exception, or system call from user space.
// called from, and returns to, trampoline.S
// return value is user satp for trampoline.S to switch to.
uint64 usertrap(void) {
  int which_dev = 0;
  struct proc *p = myproc();

  if ((r_sstatus() & SSTATUS_SPP) != 0)
    panic("usertrap: not from user mode");

  w_stvec((uint64)kernelvec);

  // save user pc
  p->trapframe->epc = r_sepc();

  if (r_scause() == 8) { // system call
    if (killed(p)) kexit(-1);
    p->trapframe->epc += 4;
    intr_on();
    syscall();
  } else if ((which_dev = devintr()) != 0) {
    // handled below
  } else if ((r_scause() == 15 || r_scause() == 13) &&
             vmfault(p->pagetable, r_stval(), (r_scause() == 13) ? 1 : 0) != 0) {
    // page fault
  } else {
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    setkilled(p);
  }

  if (killed(p)) kexit(-1);

  if (which_dev == 2) { // timer interrupt
    acquire(&p->lock);
    p->ticks_used++;

    if (p->ticks_used >= time_quantum[p->priority]) {
      p->ticks_used = 0;
      if (p->priority < NQUEUE - 1)
        p->priority++;
      release(&p->lock);
      yield();
    } else {
      int myprio = p->priority;
      release(&p->lock);

      // <-- ΕΔΩ: preempt αν υπάρχει higher-priority runnable
      for (struct proc *q = proc; q < &proc[NPROC]; q++) {
        acquire(&q->lock);
        int higher = (q->state == RUNNABLE && q->priority < myprio);
        release(&q->lock);
        if (higher) { yield(); break; }
      }
    }
  }

  prepare_return();
  return MAKE_SATP(p->pagetable);
}

// set up trapframe and control registers for a return to user space
void
prepare_return(void)
{
  struct proc *p = myproc();

  // we're about to switch the destination of traps from
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
  p->trapframe->kernel_trap = (uint64)usertrap;
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()

  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
  x |= SSTATUS_SPIE; // enable interrupts in user mode
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
}

// interrupts and exceptions from kernel code go here via kernelvec,
// on whatever the current kernel stack is.
void
kerneltrap(void)
{
  int which_dev = devintr();
  uint64 sepc = r_sepc();
  uint64 sstatus = r_sstatus();

  if ((sstatus & SSTATUS_SPP) == 0)
    panic("kerneltrap: not from supervisor mode");
  if (intr_get() != 0)
    panic("kerneltrap: interrupts enabled");

  struct proc *p = myproc();

  if (which_dev == 2 && p != 0 && p->state == RUNNING) {
    int need_yield = 0;
    int myprio;

    acquire(&p->lock);
    p->ticks_used++;
    myprio = p->priority;

    if (p->ticks_used >= time_quantum[myprio]) {
      p->ticks_used = 0;
      if (myprio < NQUEUE - 1)
        p->priority = myprio + 1;   // demote
      need_yield = 1;               // quantum expired
    }
    release(&p->lock);

    // Preemption: if any higher-priority runnable exists, yield.
    if (!need_yield) {
      for (struct proc *q = proc; q < &proc[NPROC]; q++) {
        acquire(&q->lock);
        int higher = (q->state == RUNNABLE && q->priority < myprio);
        release(&q->lock);
        if (higher) { need_yield = 1; break; }
      }
    }

    if (need_yield)
      yield();
  }

  w_sepc(sepc);
  w_sstatus(sstatus);
}

void
clockintr(void)
{
  if (cpuid() == 0) {
    acquire(&tickslock);
    ticks++;
    wakeup(&ticks);
    release(&tickslock);

    // Aging / boosting: run once per tick (on CPU 0 only)
    for (struct proc *p = proc; p < &proc[NPROC]; p++) {
      acquire(&p->lock);
      if (p->state == RUNNABLE) {
        p->wait_ticks++;
        if (p->priority > 0 &&
            p->wait_ticks >= 10 * time_quantum[p->priority]) {
          p->priority--;      // boost
          p->wait_ticks = 0;
          p->ticks_used = 0;  // fresh quantum after boost
        }
      }
      release(&p->lock);
    }
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
}

// check if it's an external interrupt or software interrupt,
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    // this is a supervisor external interrupt, via PLIC.

    // irq indicates which device interrupted.
    int irq = plic_claim();

    if(irq == UART0_IRQ){
      uartintr();
    } else if(irq == VIRTIO0_IRQ){
      virtio_disk_intr();
    } else if(irq){
      printf("unexpected interrupt irq=%d\n", irq);
    }

    // the PLIC allows each device to raise at most one
    // interrupt at a time; tell the PLIC the device is
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
  }
}