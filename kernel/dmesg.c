#include "types.h"
#include "param.h"
#include "riscv.h"
#include "defs.h"
#include "spinlock.h"

#define DIAGNOSTIC_BUFFER_SIZE (4 * PGSIZE) //buffer with size of 4 pages

extern int consolewrite(int user_src, uint64 src, int n);

static char *end; // buffer ending, "\0" sign
static char buffer[DIAGNOSTIC_BUFFER_SIZE]; 
static struct spinlock mutex;  // block for dmesg 

static void append_char(char c) {
  if (end < buffer + DIAGNOSTIC_BUFFER_SIZE - 1) {
    *end++ = c;
    *end = '\0';
  }
}

static void append(const char *str) {
  for (; end < buffer + DIAGNOSTIC_BUFFER_SIZE - 1 && *str != 0; ++end, ++str)
    *end = *str;
  *end = '\0';
}

static void append_uint(unsigned number) {
  if (number == 0)
    return append_char('0');

  static char string_format[12];
  char *head = string_format + 11;
  *head = '\0';
  for (; number > 0; number /= 10)
    *(--head) = '0' + (number % 10);
  append(head);
}

void dmesg_init() {
  initlock(&mutex, "dmesg_block");
  end = buffer;
  *end = '\0';
}

void pr_msg(const char *msg) {
  acquire(&mutex);
  append("[time: ");
  acquire(&tickslock);
  unsigned current_time = ticks;
  release(&tickslock);
  append_uint(current_time);
  append(" ticks]: ");
  append(msg);
  append_char('\n');
  release(&mutex);
}

uint64 sys_dmesg() {
  consolewrite(0, (uint64)buffer, end - buffer + 1);
  return 0;
}