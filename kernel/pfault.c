#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "elf.h"

#include "sleeplock.h"
#include "fs.h"
#include "buf.h"

int loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz);
int flags2perm(int flags);

// Read current time
uint64 read_current_timestamp() {
  uint64 curticks = 0;
  acquire(&tickslock);
  curticks = ticks;
  wakeup(&ticks);
  release(&tickslock);
  return curticks;
}

bool psa_tracker[PSASIZE];

// All blocks are free during initialization
void init_psa_regions(void)
{
    for (int i = 0; i < PSASIZE; i++) 
        psa_tracker[i] = false;
}

// Find if virtual address is a heap page
int find_heap_page(struct proc* p, uint64 va) {
    for (int i=0; i<MAXHEAP; i++) {
        if (va == p->heap_tracker[i].addr) {
            return i;
        }
    }
    return -1;
}

/* FIFO Algorithm to determine which page to evict */
int fifo_page_eviction(struct proc* p) {
    int least_idx = -1;
    // Since read_current_timestamp() rounds off to 1/10th of a second,
    // it is likely that all pages have same timestamp. So, add 1.
    uint64 least_time = read_current_timestamp() + 1;
    for (int i=0; i<MAXHEAP; i++) {
        if (!p->heap_tracker[i].loaded) {
            continue;
        }
        if (p->heap_tracker[i].last_load_time < least_time) {
            least_idx = i;
            least_time = p->heap_tracker[i].last_load_time;
        }
    }
    return least_idx;
}

/* Working Set Algorithm to determine which page to evict */
int working_set_page_eviction(struct proc* p) {
    uint64 check_time = read_current_timestamp();
    for (int i=0; i<MAXHEAP; i++) {
        if (!p->heap_tracker[i].loaded) {
            continue;
        }
        // If current time - last access time > threshold, 
        // the page is allowed to be evicted since it is not in working set
        if (check_time - p->heap_tracker[i].last_load_time > WS_THRESHOLD) {
            return i;
        }
    }
    // If all pages are part of the working set, evict the oldest page overall
    return fifo_page_eviction(p);
}

/* Evict heap page to disk when resident pages exceed limit */
void evict_page_to_disk(struct proc* p, bool working_set) {
    // Find free block
    int blockno = -1;
    // Find free PSA blocks
    int free_blocks = 0;
    for (int i = 0; i < PSASIZE; i++) {
        if (psa_tracker[i] == false) {
            if (free_blocks == 0) {
                blockno = i;
            }
            free_blocks++;
            if (free_blocks == 4) {
                break;
            }
        } else {
            free_blocks = 0;
            blockno = -1;
        }
    }
    for (int i = blockno; i < blockno + 4; i++) {
        psa_tracker[i] = true;
    }
    if (blockno < 0) {
        printf("Cannot evict page. Not enough disk space");
        return;
    }
    // Find victim page using either FIFO or Working Set Algorithm
    int evict_idx;
    if (working_set) {
        evict_idx = working_set_page_eviction(p);
    } else {
        evict_idx = fifo_page_eviction(p);
    }
    p->heap_tracker[evict_idx].startblock = blockno;

    print_evict_page(p->heap_tracker[evict_idx].addr, blockno);

    // Read memory from the user to kernel memory firs
    char *kpage = kalloc();
    if (kpage == 0) {
        panic("Failed to allocate kernel page\n");
    }
    if (copyin(p->pagetable, kpage, p->heap_tracker[evict_idx].addr, PGSIZE) != 0) {
        panic("Failed to copy page to kernel memory");
    }

    // Write evict page to the chosen PSA blocks
    for (int i = 0; i < 4; i++) {
        struct buf *b = bread(1, PSASTART + (blockno + i));
        // Copy page contents to b->data using memmove
        memmove(b->data, kpage + (i * BSIZE), BSIZE);
        bwrite(b);
        brelse(b);
    }
    kfree(kpage);
    // Unmap swapped out page
    uvmunmap(p->pagetable, PGROUNDDOWN(p->heap_tracker[evict_idx].addr), 1, 0);
    // Update the resident heap tracker
    p->heap_tracker[evict_idx].loaded = false;
    p->resident_heap_pages--;
}

// Retrieve faulted page from disk
void retrieve_page_from_disk(struct proc* p, uint64 uvaddr, int heap_idx) {
    // Find where the page is located in disk
    int blockno = p->heap_tracker[heap_idx].startblock;
    print_retrieve_page(uvaddr, blockno);

    // Create a kernel page to read memory temporarily into first
    char *kpage = kalloc();
    if(kpage == 0){
        panic("Failed to allocate kernel page\n");
    }

    // Read the disk block into temp kernel page
    for (int i = 0; i < 4; i++) {
        struct buf *b = bread(1, PSASTART + (blockno + i));
        // Copy page contents to kpage using memmove
        memmove(kpage + (i * BSIZE), b->data, BSIZE);
        brelse(b);
    }

    // Copy from temp kernel page to uvaddr (use copyout)
    if(copyout(p->pagetable, uvaddr, kpage, PGSIZE) != 0){
        panic("Failed to copy page from kernel memory\n");
    }
    kfree(kpage);

    // Update heap tracker and psa_tracker */
    p->heap_tracker[heap_idx].loaded = true;
    for (int i = blockno; i < blockno + 4; i++) {
        psa_tracker[i] = false;
    }
}

void page_fault_handler(void) 
{
    // Current process struct
    struct proc *p = myproc();
    struct inode *ip;
    struct elfhdr elf;
    struct proghdr ph;

    // Track whether the heap page should be brought back from disk or not
    bool load_from_disk = false;

    // Find faulting address
    uint64 stval = r_stval(); // Read the stval register to get faulting address
    uint64 faulting_addr = PGROUNDDOWN(stval); // Address of the Page Fault

    print_page_fault(p->name, faulting_addr);

    /* Check if the fault address is a heap page. Use p->heap_tracker */
    int heap_idx = find_heap_page(p, faulting_addr);
    if (heap_idx >= 0) {
        load_from_disk = p->heap_tracker[heap_idx].startblock >= 0;
        goto heap_handle;
    }

    begin_op();
    if((ip = namei(p->name)) == 0){
        printf("Error");
        return;
    }
    ilock(ip);
    if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf)) {
        printf("Read Error");
        return;
    }  
    if(elf.magic != ELF_MAGIC) {
        printf("Not so magical");
        return;
    }

    // Iterate through program sections to find the program binary page
    for (int i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)) {
        if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
            return;
        if(ph.type != ELF_PROG_LOAD)
            continue;
        if(ph.memsz < ph.filesz)
            return;
        if(ph.vaddr + ph.memsz < ph.vaddr)
            return;
        if(ph.vaddr % PGSIZE != 0)
            return;
            
        // Check if faulting address belongs to this section
        uint64 section_end = ph.vaddr + ph.memsz;
        if (faulting_addr >= ph.vaddr && faulting_addr < section_end) {
            // printf("Found the section of the faulting addr\n");
            // Allocate a free physical page for the program binary page
            uint64 pg = uvmalloc(p->pagetable, faulting_addr, faulting_addr + PGSIZE, flags2perm(ph.flags));
            if (pg == 0) {
                printf("Page Fault Handler: uvmalloc failed\n");
                break;
            }
            // Load the required page from the program binary
            if (loadseg(p->pagetable, faulting_addr, ip, ph.off, PGSIZE) < 0) {
                printf("Page Fault Handler: loadseg failed\n");
                break;
            }
            print_load_seg(faulting_addr, faulting_addr + PGSIZE, PGSIZE);
            break;
        }
    }

    iunlockput(ip);
    end_op();
    // Go to out, since the remainder of this code is for the heap
    goto out;

heap_handle:
    /* Check if resident pages are more than heap pages. If yes, evict. */
    if (p->resident_heap_pages == MAXRESHEAP) {
        // Pass true for working set algorithm
        evict_page_to_disk(p, true);
    }

    // Map a heap page into the process' address space. (Hint: check growproc)
    if(uvmalloc(p->pagetable, faulting_addr, faulting_addr + PGSIZE, PTE_W) == 0) {
        panic("Error allocating new page");
    }

    // Update the last load time for the loaded heap page in p->heap_tracker
    p->heap_tracker[heap_idx].last_load_time = read_current_timestamp();

    // Heap page was swapped to disk previously. We must load it from disk
    if (load_from_disk) {
        retrieve_page_from_disk(p, faulting_addr, heap_idx);
    }

    // Track that another heap page has been brought into memory
    p->heap_tracker[heap_idx].loaded = true;
    p->resident_heap_pages++;
    goto out;

out:
    /* Flush stale page table entries. This is important to always do. */
    sfence_vma();
    return;
}