#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"

void main();
void timerinit();

static void pmpinit();

// entry.S needs one stack per CPU.
__attribute__ ((aligned (16))) char stack0[4096 * NCPU];

// a scratch area per CPU for machine-mode timer interrupts.
uint64 timer_scratch[NCPU][5];

// assembly code in kernelvec.S for machine-mode timer interrupt.
extern void timervec();

// entry.S jumps here in machine mode on stack0.
void
start()
{
  // set M Previous Privilege mode to Supervisor, for mret.
  unsigned long x = r_mstatus();
  x &= ~MSTATUS_MPP_MASK;
  x |= MSTATUS_MPP_S;
  w_mstatus(x);

  // set M Exception Program Counter to main, for mret.
  // requires gcc -mcmodel=medany
  w_mepc((uint64)main);

  // disable paging for now.
  w_satp(0);

  // delegate all interrupts and exceptions to supervisor mode.
  w_medeleg(0xffff);
  w_mideleg(0xffff);
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);

  // ask for clock interrupts.
  timerinit();

  // keep each CPU's hartid in its tp register, for cpuid().
  int id = r_mhartid();
  w_tp(id);

  // allow access to all physical memory by S mode
  pmpinit();

  // switch to supervisor mode and jump to main().
  asm volatile("mret");
}

// configures the pmp registers trivially so we can boot. it is not permitted
// to jump to S mode without having these configured as instruction fetch will
// fail, however we do not actually use them for protection in xv6, so we just
// need to put something trivial there.
//
// see section 3.6.1 "Physical Memory Protection CSRs" in the RISC-V privileged
// specification (v20190608)
//
// "If no PMP entry matches an M-mode access, the access succeeds. If no PMP
// entry matches an S-mode or U-mode access, but at least one PMP entry is
// implemented, the access fails." (3.6.1)
static void
pmpinit()
{
  // see figure 3.27 "PMP address register format, RV64" and table 3.10 "NAPOT
  // range encoding in PMP address and configuration registers" in the RISC-V
  // privileged specification
  // we set the bits such that this matches any 56-bit physical address
  w_pmpaddr0((~0ULL) >> 10);
  // then we allow the access
  w_pmpcfg0(PMP_R | PMP_W | PMP_X | PMP_MATCH_NAPOT);
}

// set up to receive timer interrupts in machine mode,
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
  scratch[3] = CLINT_MTIMECMP(id);
  scratch[4] = interval;
  w_mscratch((uint64)scratch);

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
}
