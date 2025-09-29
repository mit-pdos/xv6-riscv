#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
// This helper converts the ELF program header flags (PF_X, PF_W, PF_R bits
// defined in elf.h) into the page table entry permission bits used by xv6's
// pagetable (PTE_X for execute, PTE_W for write, PTE_R implicit via valid).
// Note: ELF uses a bitmask where 0x1 typically denotes executable, 0x2 write,
// etc. This function maps those to the kernel's PTE_* constants.
// Keeping mapping in a single function makes it easy to adjust policy (e.g. to
// make read-only mappings explicit) and centralizes any platform-specific
// differences.
int flags2perm(int flags)
{
    int perm = 0;
    // If the ELF segment is executable, mark PTE_X so the hardware allows
    // instruction fetches from these pages.
    if(flags & 0x1)
      perm = PTE_X;
    // If the ELF segment is writable, include the write permission bit.
    // Note: read permission is implied by the valid PTE in this xv6 port.
    if(flags & 0x2)
      perm |= PTE_W;
    return perm;
}

//
// the implementation of the exec() system call
//
// kexec replaces the calling process's memory image with a new program
// loaded from the given path. It sets up a fresh pagetable, loads all
// loadable ELF segments into the new address space, creates a user stack,
// copies program arguments, and updates the process's trapframe so that
// when the process resumes in user space it begins execution at the new
// program's entry point with the provided argc/argv.
//
// The function returns the argument count (argc) on success which ends up
// in a0 for the new program's main(argc, argv). On failure it returns -1.
//
// Important points:
// - We allocate a new pagetable and populate it with user mappings for the
//   ELF segments. We do not reuse the old pagetable; we free the old one
//   only after the new image is fully prepared and committed.
// - We strictly check ELF headers and program headers for consistency.
// - The stack gets a guard page (an inaccessible page) followed by USERSTACK
//   pages for the user stack itself. This is done by allocating an extra
//   page and then clearing the guard page using uvmclear.
// - Arguments are copied into the new user stack and pointers are built there.
// - All resources are cleaned up on error paths through the 'bad' label.
int
kexec(char *path, char **argv)
{
  char *s, *last;
  int i, off;
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;           // on-disk ELF header (read from file)
  struct inode *ip;            // inode for the executable file
  struct proghdr ph;           // program header (per-segment metadata)
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();

  // begin_op/end_op pair: start a filesystem operation so that the file
  // system remains consistent while we access the executable file.
  begin_op();

  // Open the executable file by name. namei returns an inode pointer or 0.
  if((ip = namei(path)) == 0){
    end_op();
    return -1;
  }
  // Lock the inode to prevent concurrent modifications while we read it.
  ilock(ip);

  // Read the ELF header from the file into 'elf'. We check that we were
  // able to read the full header; otherwise the file is invalid/corrupt.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    goto bad;

  // Validate the ELF magic number to ensure this file is an ELF binary.
  if(elf.magic != ELF_MAGIC)
    goto bad;

  // Create a fresh user page table for the process. proc_pagetable() sets
  // up kernel mappings needed for traps/syscalls and returns a pagetable
  // that we can populate with user mappings.
  if((pagetable = proc_pagetable(p)) == 0)
    goto bad;

  // Load program into memory by iterating over ELF program headers.
  // For each PT_LOAD segment, we allocate pages, then load the file data.
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    // Read the i-th program header into 'ph'.
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    // Ignore non-loadable segments (e.g., PT_NOTE)
    if(ph.type != ELF_PROG_LOAD)
      continue;
    // Sanity checks:
    // - memsz must be at least filesz
    // - vaddr + memsz must not wrap around
    // - segment vaddr must be page-aligned for our mapping routines
    if(ph.memsz < ph.filesz)
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
      goto bad;

    // uvmalloc extends the user address space in the given pagetable from
    // 'sz' up to (ph.vaddr + ph.memsz), allocating pages with the given
    // permission bits. It returns the new size (end of allocated space)
    // or 0 on failure.
    uint64 sz1;
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
      goto bad;
    // Update 'sz' to reflect the highest allocated address so far.
    sz = sz1;

    // Load the segment data from the file into the already-allocated pages.
    // loadseg assumes the virtual pages have been mapped and will call readi
    // to copy file bytes into the physical pages backing those virtual pages.
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  // We've finished using the inode; unlock and release it.
  iunlockput(ip);
  end_op();
  ip = 0;

  // Re-fetch current process pointer (defensive; unchanged) and save old size.
  p = myproc();
  uint64 oldsz = p->sz;

  // Allocate the user stack:
  // - Round the current program size up to the next page boundary.
  // - Allocate USERSTACK pages plus one extra page which will serve as a
  //   guard (inaccessible) to catch stack overflows.
  // - The call to uvmalloc returns the new top address. We then clear the
  //   guard page so accesses fault.
  sz = PGROUNDUP(sz);
  uint64 sz1;
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    goto bad;
  sz = sz1;
  // Make the first of the newly allocated pages inaccessible: the guard page.
  // uvmclear clears the PTE so that any access to that page will cause a fault.
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
  // Set the initial user stack pointer to the top of the newly allocated area.
  sp = sz;
  // Compute the base address of the usable stack (after the guard page).
  stackbase = sp - USERSTACK*PGSIZE;

  // Copy argument strings into the new user stack, keeping track of the
  // virtual addresses we stored them at in ustack[]. We also ensure the
  // stack pointer remains 16-byte aligned as required by RISC-V ABI.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
    // Make room for the argument string bytes (including NUL).
    sp -= strlen(argv[argc]) + 1;
    // Align the stack pointer to a 16-byte boundary (RISC-V ABI requirement).
    sp -= sp % 16;
    // Ensure we didn't overflow into the guard page / below allocated stack.
    if(sp < stackbase)
      goto bad;
    // Copy the argument string from kernel memory into the new process's
    // user memory at virtual address 'sp'. copyout uses the provided pagetable.
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    // Record the user-space pointer for this argument.
    ustack[argc] = sp;
  }
  // NULL-terminate the argv array for the user program.
  ustack[argc] = 0;

  // Push a copy of the ustack[] (the array of argv pointers) onto the user stack.
  // This makes the layout expected by C startup code: argv pointer array resides
  // on the stack and is passed as second argument to main.
  sp -= (argc+1) * sizeof(uint64);
  // Ensure stack alignment again.
  sp -= sp % 16;
  if(sp < stackbase)
    goto bad;
  // Copy the argv pointer array into user memory.
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    goto bad;

  // Prepare the user trapframe so that when the process returns to user
  // space, its registers hold the expected values:
  // - a0 should contain argc (the return value of exec is placed in a0)
  // - a1 should contain argv (pointer to argv array on the user stack)
  // Note: a0 will be set by the syscall return path with the return value.
  p->trapframe->a1 = sp;

  // Save program name (basename of path) in proc structure for debugging.
  for(last=s=path; *s; s++)
    if(*s == '/')
      last = s+1;
  safestrcpy(p->name, last, sizeof(p->name));
    
  // Commit to the new user image:
  // - Replace the process's pagetable with the newly created one
  // - Update process size (sz)
  // - Set the trapframe's epc (entry point) and sp (stack pointer)
  // - Free the old pagetable and its pages (using the saved old size)
  oldpagetable = p->pagetable;
  p->pagetable = pagetable;
  p->sz = sz;
  // The new program will start executing at elf.entry with stack pointer sp.
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
  p->trapframe->sp = sp; // initial stack pointer
  // Free the previous user pagetable and associated physical pages.
  proc_freepagetable(oldpagetable, oldsz);

  // Return argc. This value will be delivered to the new program in a0
  // as the return value of exec (and thus becomes the first argument to main).
  return argc;

 bad:
  // Error handling path: free any partially created pagetable, release the
  // inode if it was locked, and end the filesystem op.
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    end_op();
  }
  return -1;
}

// Load an ELF program segment into pagetable at virtual address va.
// va must be page-aligned and the pages from va to va+sz must already be
// mapped. This function reads the file data for the segment directly into
// the physical pages backing the provided pagetable. It does not perform
// allocation; allocation must be performed by the caller (uvmalloc).
// Returns 0 on success, -1 on failure.
static int
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  // Iterate over the segment region, page by page.
  // For each page we compute the physical address using walkaddr which
  // translates a virtual address to a physical address in the provided
  // pagetable. If walkaddr returns 0 then the mapping is missing, which
  // indicates a programming error (the pages should have been allocated).
  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    // Determine how many bytes to read for this page. The last page may be
    // partially filled (sz - i < PGSIZE).
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    // Read 'n' bytes from the file into the physical address. readi requires
    // the physical address in this kernel and will perform the copy.
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
      return -1;
  }
  
  return 0;
}
