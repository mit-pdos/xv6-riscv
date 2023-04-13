#include "types.h"
#include "param.h"
#include "riscv.h"
#include "defs.h"
#include "spinlock.h"
#include "proc.h"

#include <stdarg.h>

#define NULL 0
#define BUFSIZE DMESGPS * PGSIZE

static struct {
    char buf[BUFSIZE];
    struct spinlock lock;
    int cycled;
} debug_buffer;

static char * beg = debug_buffer.buf;
static char * end = debug_buffer.buf + BUFSIZE;

static void push_char(char c) {
    *beg++ = c;
    if (beg == end) {
        beg = debug_buffer.buf;
        debug_buffer.cycled = 1;
    }
}

static void push_str(const char* str) {
    while (*str)
        push_char(*str++);
}

static char digit(int i) {
    if (0 <= i && i < 10) {
        return i + '0';
    }
    else {
        return i + 'A';
    }
} 

static void push_ptr(uint64 ptr) {
    push_str("0x");
    for (int i = sizeof(uint64) * 2 - 4; i >= 0; i -= 4)
        push_char(digit((ptr >> i) & 15));
}

static void push_int(int x, int base) {
    char digits[10];
    if (x < 0) {
        push_char('-');
        x = -x;
    }
    int i = 0;
    do {
        digits[i++] = digit(x % base);
        x /= base;
    } while (x);

    while(--i >= 0)
        push_char(digits[i]);
}

void debug_buffer_init() {
    initlock(&debug_buffer.lock, "debug buffer");
    debug_buffer.cycled = 0;
}

// In realization there is no panics so additional field for locking isn't needed
void pr_msg(char *fmt, ...) {
    if (fmt == NULL) {
        panic("No formatter");
    }
    acquire(&debug_buffer.lock);
    va_list list;
    va_start(list, fmt);
    char c = fmt[0];
    for (uint32 i = 0; (c = fmt[i]) != 0; ++i) {
        if (c != '%') {
            push_char(c);
            continue;
        }
        c = fmt[++i];
        if (c == 0) {
            break;
        } else if (c == 'd') {
            push_int(va_arg(list, int), 10);
        } else if (c == 'x') {
            push_int(va_arg(list, int), 16);
        } else if (c == 'p') {
            push_ptr(va_arg(list, uint64));
        } else if (c == 's') {
            char* s;
            if ((s = va_arg(list, char*)) != 0) {
                push_str(s);
            } else {
                push_str("(null)");
            }
        } else if (c == '%') {
            push_char('%');
        } else {
            push_char('%');
            push_char(c);
        }
    }
    va_end(list);
    release(&debug_buffer.lock);
}

static uint64 min(uint64 a, uint64 b) {
    if (a < b)
        return a;
    else
        return b;
}

// copy size bytes from start of kernel debug buffer into user buffer
// starting from more old info
int sys_dmesg(void) {
    uint64 buffer_ptr, size;
    argaddr(0, &buffer_ptr);
    argaddr(1, &size);
    uint64 head, tail;
    if (debug_buffer.cycled) {
        // note that negative values cannot be received
        tail = min(end - beg, size);
        head = min(size - tail, beg - debug_buffer.buf);

    } else {
        head = min(beg - debug_buffer.buf, size);
        tail = 0;
    }
    int first_copy = copyout(myproc()->pagetable, buffer_ptr, beg, tail);
    int last_copy = copyout(myproc()->pagetable, buffer_ptr + tail, debug_buffer.buf, head);
    if (first_copy == -1 || last_copy == -1)
        return -1;
    return first_copy + last_copy;
}