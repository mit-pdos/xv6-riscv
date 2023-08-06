#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "elf.h"

void print_static_proc(char* name) {
    printf("Static process creation (proc: %s)\n", name);
}

void print_ondemand_proc(char* name) {
    printf("Ondemand process creation (proc: %s)\n", name);
}

void print_skip_section(char* name, uint64 vaddr, int size) {
    printf("Skipping program section loading (proc: %s, addr: %x, size: %d)\n", 
        name, vaddr, size);
}

void print_page_fault(char* name, uint64 vaddr) {
    printf("----------------------------------------\n");
    printf("#PF: Proc (%s), Page (%x)\n", name, vaddr);
}

void print_evict_page(uint64 vaddr, int startblock) {
    printf("EVICT: Page (%x) --> PSA (%d - %d)\n", vaddr, startblock, startblock+3);
}

void print_retrieve_page(uint64 vaddr, int startblock) {
    printf("RETRIEVE: Page (%x) --> PSA (%d - %d)\n", vaddr, startblock, startblock+3);
}

void print_load_seg(uint64 vaddr, uint64 seg, int size) {
    printf("LOAD: Addr (%x), SEG: (%x), SIZE (%d)\n", vaddr, seg, size);
}

void print_skip_heap_region(char* name, uint64 vaddr, int npages) {
    printf("Skipping heap region allocation (proc: %s, addr: %x, npages: %d)\n", 
        name, vaddr, npages);
}
