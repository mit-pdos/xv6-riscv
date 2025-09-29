#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"

/*
 * start.c - early kernel start-up (entered from entry.S)
 *
 * High-level sequence:
 * 1) entry.S sets up an initial stack per hart and then jumps to start().
 * 2) start() runs in machine mode and prepares the machine for switching
 *    to supervisor mode (where the kernel main() executes).
 * 3) start() sets up MSTATUS, MEPC, disables paging, delegates traps,
 *    configures PMP to grant supervisor full physical access, enables timer
 *    interrupts and sets the hart id in tp, then executes mret to enter S-mode.
 *
 * The following comments explain each step and the RISC-V CSRs used so that
 * the comments alone describe the purpose of the code.
 */

void main();
void timerinit();

// entry.S needs one stack per CPU.
__attribute__ ((aligned (16))) char stack0[4096 * NCPU];

// entry.S jumps here in machine mode on stack0.
void
start()
{
  // r_mstatus(): read the machine status CSR (mstatus).
  // We will modify the MPP field to set the privilege we return to after mret.
  unsigned long x = r_mstatus();

  // Clear current MPP bits and set them to Supervisor (MPP = 1).
  // MSTATUS_MPP_MASK masks the MPP bits; MSTATUS_MPP_S is the value for S-mode.
  // This ensures that mret will drop from machine mode to supervisor mode.
  x &= ~MSTATUS_MPP_MASK;
  x |= MSTATUS_MPP_S;
  w_mstatus(x); // write back updated mstatus.

  // Set MEPC (machine exception program counter) to point to main().
  // After mret, execution will continue at the address stored in mepc.
  // Note: main() is the supervisor-mode kernel entry and requires -mcmodel=medany.
  w_mepc((uint64)main);

  // Disable paging by writing 0 to SATP so that virtual memory is off for now.
  // Supervisor translation will be enabled later when the kernel sets up page tables.
  w_satp(0);

  // Delegate interrupts and exceptions to supervisor mode:
  // - medeleg: which synchronous exceptions are delegated to S-mode.
  // - mideleg: which asynchronous interrupts are delegated to S-mode.
  // Here we delegate all (0xffff) so the supervisor kernel handles them.
  w_medeleg(0xffff);
  w_mideleg(0xffff);

  // Enable supervisor-level external and timer interrupts in SIE by OR'ing bits.
  // r_sie() reads Supervisor Interrupt-Enable; SIE_SEIE and SIE_STIE enable
  // external and timer interrupts respectively for supervisor mode.
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);

  // Configure Physical Memory Protection (PMP) entries so supervisor has full
  // access to physical memory:
  // - w_pmpaddr0 sets the upper bound of the PMP region (here very large).
  // - w_pmpcfg0 configures the PMP entry (0xf = NAPOT RWX in this context).
  // This avoids supervisor being blocked by PMP when accessing physical RAM.
  w_pmpaddr0(0x3fffffffffffffull);
  w_pmpcfg0(0xf);

  // Initialize the timer subsystem and request timer interrupts.
  // timerinit() sets up CSRs so S-mode can receive timer interrupts and schedules
  // the first timer interrupt via stimecmp.
  timerinit();

  // Keep each CPU's hartid in its tp register for cpuid() and per-hart data.
  // r_mhartid() reads the hart id; w_tp() writes the thread pointer register (tp).
  int id = r_mhartid();
  w_tp(id);

  // Finally, switch to supervisor mode and jump to the address in mepc (main).
  // The mret instruction will use the MEPC and MSTATUS.MPP fields set above.
  asm volatile("mret");
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
  // Enable supervisor-mode timer interrupts globally in MIE:
  // r_mie() reads machine interrupt-enable CSR; set MIE_STIE to allow S-mode timers.
  w_mie(r_mie() | MIE_STIE);
  
  // Enable the sstc extension (stimecmp access) by setting the appropriate bit
  // in menvcfg. This allows supervisor code to write/read stimecmp.
  // (1L << 63) is the sstc enable bit for this platform.
  w_menvcfg(r_menvcfg() | (1L << 63)); 
  
  // Allow supervisor to read stime and use stimecmp by enabling the appropriate
  // bits in mcounteren. Here we set the bit that enables supervisor access to time.
  w_mcounteren(r_mcounteren() | 2);
  
  // Ask for the very first timer interrupt by setting stimecmp to a time
  // slightly in the future (current time + offset).
  // r_time() returns the current time; adding 1000000 schedules the interrupt.
  w_stimecmp(r_time() + 1000000);
}
