#include "types.h"
#include "param.h"
#include "riscv.h"
#include "defs.h"
#include "spinlock.h"


#define BUFSIZE DMESGPS * PGSIZE

static struct {
    char buf[BUFSIZE];
    struct spinlock lock;
} debug_buffer;

static char * beg = debug_buffer.buf;

static void push(const char *t, int zero) {
  while((*beg++ = *t++) != 0);
  if (!zero)
    --beg;
}

// requires that str is null-terminated 
int pr_msg(const char * str) {
    acquire(&debug_buffer.lock);
    uint x = ticks, len = strlen(str);
    char digits[10];
    int i = 0;
    while (x) {
        digits[i++] = x % 10 + '0';
        x /= 10;
    }
    if (i + len + 2 > BUFSIZE) {
        release(&debug_buffer.lock);
        return -1;
    }
    while (--i >= 0) {
        *beg++ = digits[i];
    }
    push(": ", 0);
    push(str, 1);
    release(&debug_buffer.lock);
    return 0;
}

int sys_dmesg() {
    for (char *it = debug_buffer.buf; it != beg; it++)
        consputc(*it ? *it : '\n');
    return 0;
}