#include <stdarg.h>
#include "types.h"
#include "param.h"
#include "riscv.h"
#include "defs.h"
#include "spinlock.h"
#include "proc.h"

#define DIAGNOSTIC_BUFFER_SIZE (1 * PGSIZE) //buffer with size of 1 page

extern int consolewrite(int user_src, uint64 src, int n);

static char *start; //pointer to the start of a buffer 
static char *end; //pointer to the start of a buffer, sign "\0"
static char buffer[DIAGNOSTIC_BUFFER_SIZE];
static char const *const_buffer_end = buffer + DIAGNOSTIC_BUFFER_SIZE;
static struct spinlock mutex; //blocking for dmesg buffer operations -> they should be called only with mutex is activated




static void append_char(char c) {
  *end = c;
  ++end;                                                                     
  if (end == const_buffer_end)                                               
    end = buffer; 
  *end = '\0';
  if (start == end){
    ++start;                                                                     
    if (start == const_buffer_end)                                               
      start = buffer; 
  }
}

static void append_string(const char *str) {
  for (; *str; ++str)
    append_char(*str);
}

static const char digits[] = "0123456789abcdef";

static void append_unsigned_int(unsigned number, int base) {
  char as_str[16];
  char *start = as_str + 15;
  *start = '\0';
  for (; number > 0; number /= base) {
    *(--start) = digits[number % base];
  }
  append_string(start);
}

static void append_signed_int(int number, int base) {
  if (number == 0)
    return append_char('0');
  if (number < 0) {
    append_char('-');
    number = -number;
  }
  append_unsigned_int((unsigned)number, base);
}

static void append_ptr(uint64 ptr) {
  append_char('0');
  append_char('x');
  for (int block = 1; block <= sizeof(uint64) * 2; ++block) {          //sizeof(uint64) equals 8*2=16, since adresses are in hexadecimal format
    unsigned digit = (ptr >> (sizeof(uint64) * 8 - 4 * block)) & 15;   //sizeof(uint64) equals 8*8=64, which exactly 16 times for 4-bit chuncks (4 bits for one hexfor 4-bit chuncks  number)
    append_char(digits[digit]);
  }
}





void dmesg_init() {
  initlock(&mutex, "dmesg_block");
  start = buffer;
  end = buffer;
  *end = '\0';
}





void pr_msg(const char *format, ...) {
  acquire(&mutex);
  append_string("[time: ");
  unsigned int current_time = ticks;
  append_signed_int(current_time, 10);
  append_string(" ticks]: ");

  va_list args;
  va_start(args, format);
  while (*format) {
    if (*format != '%') {
      append_char(*format++);
      continue;
    }
    char ch = *(++format);
    if (!ch)
      break;
    switch (ch) {
    case 'd':
      append_signed_int(va_arg(args, int), 10);
      break;
    case 'x':
      append_signed_int(va_arg(args, int), 16);
      break;
    case 'p':
      append_ptr(va_arg(args, uint64));
      break;
    case 's': {
      const char *s = va_arg(args, const char *);
      if (!s)
        s = "(null)";
      append_string(s);
      break;
    }
    case '%':
      append_char('%');
      break;
    default: {
      append_char('%');
      append_char(ch);
      break;
    }
    }
    ++format;
  }
  va_end(args);

  append_char('\n');
  release(&mutex);
}





uint64 sys_dmesg() {
  uint64 user_buffer_address;
  argaddr(0, &user_buffer_address);

  int user_buffer_size;
  argint(1, &user_buffer_size);
  if (user_buffer_size <= 0)
    return 0; 

  pagetable_t pagetable = myproc()->pagetable;

  uint64 return_code = 0;



#define append(src, _length)                                                          \
  do {                                                                                \
    uint64 length = _length;                                                          \
    if (length >= user_buffer_size)                                                   \
      length = user_buffer_size - 1;                                                  \
    return_code |= copyout(pagetable, user_buffer_address, src, length);              \
    user_buffer_address += length;                                                    \
    user_buffer_size -= length;                                                       \
  } while (0)




  if (start < end) {
    append(start, end - start);
  } else {
    append(start, const_buffer_end - start);
    append(buffer, end - buffer);
  }
  append("\0", 1);

  return return_code;
}