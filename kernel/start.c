#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "sbi.h"

void main();

// entry.S needs one stack per CPU.
__attribute__ ((aligned (16))) char stack0[4096 * NCPU];

// entry.S jumps here in supervisor mode on stack0.
void
start(uint64 hartid, uint64 fdt)
{
  // disable paging for now.
  w_satp(0);

  // enable interrupts.
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);

  // keep each CPU's hartid in its tp register.
  w_tp(hartid);

  // Jump to main
  main();
}
