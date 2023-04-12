#include <stdarg.h>

#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "spinlock.h"
#include "proc.h"
#include "fs.h"
#include "sleeplock.h"
#include "file.h"
#include "memlayout.h"

#define NUMBER_OF_CHARS ((1 << 11) - 1)
#define TICKS_BUFFER_SIZE 24
static char digits_custom[] = "0123456789abcdef";

short flag = 1;

struct {
    short was_reset;
    int number_of_words;
    int last_pos;
    struct spinlock spnlock;
    char buffer[NUMBER_OF_CHARS];
} spinned_buffer;

uint64 prev_pos(uint64 pos){
  if (pos == 0)
    return NUMBER_OF_CHARS - 1;
  else
    return pos - 1;
}

void helping_printer(){
    for (int i = 0; i < NUMBER_OF_CHARS; i++){
        if (spinned_buffer.buffer[i] == '\n')
            consputc('.');
        else if (spinned_buffer.buffer[i] == 0)
            consputc(',');
        else
            consputc(spinned_buffer.buffer[i]);
    }
    consputc('\n');
}

void lock_init() {
    initlock(&spinned_buffer.spnlock, "spnlock");
    spinned_buffer.was_reset = 0;
    spinned_buffer.number_of_words = 0;
    spinned_buffer.last_pos = 0;
}

//write \n wich deletes next string. Do not delete string if only 1 \n left or replaced symbol is \n.

void write_n(){
    if (spinned_buffer.last_pos == NUMBER_OF_CHARS){
        spinned_buffer.was_reset = 1;
        spinned_buffer.last_pos = 0;
    }

    if (spinned_buffer.buffer[spinned_buffer.last_pos] == 0){
        spinned_buffer.last_pos++;
        if (!spinned_buffer.was_reset)
          spinned_buffer.number_of_words++;
        return;
    }

    spinned_buffer.buffer[spinned_buffer.last_pos++] = 0;
    spinned_buffer.number_of_words++;
    if (spinned_buffer.last_pos == NUMBER_OF_CHARS){
        spinned_buffer.was_reset = 1;
        spinned_buffer.last_pos = 0;
    }  

    if (spinned_buffer.number_of_words == 1)
        return;
    if (spinned_buffer.was_reset == 0)
        return;

    int pos = spinned_buffer.last_pos;
    if (pos == NUMBER_OF_CHARS) 
        pos = 0;
    while (spinned_buffer.buffer[pos] != 0){
        spinned_buffer.buffer[pos++] = 0;
        spinned_buffer.number_of_words++;
        if (pos == NUMBER_OF_CHARS) 
            pos = 0;
    }
}

void writer_chr(const char ch){
    if (spinned_buffer.last_pos == NUMBER_OF_CHARS){
        spinned_buffer.was_reset = 1;
        spinned_buffer.last_pos = 0;
    }
    if (spinned_buffer.was_reset &&  spinned_buffer.buffer[spinned_buffer.last_pos] == 0)
        spinned_buffer.number_of_words--;
    spinned_buffer.buffer[spinned_buffer.last_pos++] = ch;
    //helping_printer();   
}

static void
pr_msg_int(int xx, int base, int sign)
{
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    x = -xx;
  else
    x = xx;

  i = 0;
  do {
    buf[i++] = digits_custom[x % base];
  } while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
    writer_chr(buf[i]);
}

static void
pr_msg_ptr(uint64 x)
{
  int i;
  writer_chr('0');
  writer_chr('x');
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    writer_chr(digits_custom[x >> (sizeof(uint64) * 8 - 4)]);
}

// Print to the console. only understands %d, %x, %p, %s.
void
pr_msg(char *fmt, ...)
{
  va_list ap;
  int i, c;//, locking;
  char *s;

  acquire(&spinned_buffer.spnlock);

  acquire(&tickslock);
  uint ticks_at_start = ticks;
  release(&tickslock);

  if (fmt == 0)
    return;

  va_start(ap, fmt);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    if(c != '%'){
      writer_chr(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    case 'd':
      pr_msg_int(va_arg(ap, int), 10, 1);
      break;
    case 'x':
      pr_msg_int(va_arg(ap, int), 16, 1);
      break;
    case 'p':
      pr_msg_ptr(va_arg(ap, uint64));
      break;
    case 's':
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        writer_chr(*s);
      break;
    case '%':
      writer_chr('%');
      break;
    default:
      // Print unknown % sequence to draw attention.
      writer_chr('%');
      writer_chr(c);
      break;
    }
  }

  char number_rev[TICKS_BUFFER_SIZE - 1];
  writer_chr(' ');
  writer_chr('[');  

  int len_of_num = (ticks_at_start == 0);
  number_rev[0] = '0';
  while (ticks_at_start > 0 && len_of_num < TICKS_BUFFER_SIZE - 1) {
      number_rev[len_of_num++] = '0' + ticks_at_start % 10;
      ticks_at_start /= 10;
  }
  for (int i = len_of_num - 1; i >= 0; i--)
      writer_chr(number_rev[i]);
  writer_chr(']');
  write_n();
  //helping_printer();
  va_end(ap);


  release(&spinned_buffer.spnlock);
}

uint64 
sys_dmesg(void) 
{
  acquire(&spinned_buffer.spnlock);
  
  uint64 u_buf;
  argaddr(0, &u_buf);
 
  if (spinned_buffer.was_reset == 0) {
    printf("%d\n",spinned_buffer.last_pos);
    if (copyout(myproc()->pagetable, u_buf, spinned_buffer.buffer, sizeof(char) * (long long)spinned_buffer.last_pos) < 0){
      release(&spinned_buffer.spnlock);
      return -1;
    }
    release(&spinned_buffer.spnlock);
    return spinned_buffer.last_pos;
  }
  else {
    if (copyout(myproc()->pagetable, u_buf, spinned_buffer.buffer + spinned_buffer.last_pos, sizeof(char) * (NUMBER_OF_CHARS - spinned_buffer.last_pos)) != 0){
      release(&spinned_buffer.spnlock);
      return -1;
    }
    u_buf += sizeof(char) * (NUMBER_OF_CHARS - spinned_buffer.last_pos);
    if (copyout(myproc()->pagetable, u_buf, spinned_buffer.buffer, sizeof(char) * spinned_buffer.last_pos) != 0){
      release(&spinned_buffer.spnlock);
      return -1;
    }
    release(&spinned_buffer.spnlock);
    return NUMBER_OF_CHARS;
  }

  
}

/*
    if (spinned_buffer.was_reset == 0){
        for (int i = 0; i < spinned_buffer.last_pos; i++)
            if (spinned_buffer.buffer[i] == 0)
              consputc('\n');
            else
              consputc(spinned_buffer.buffer[i]);
    } else {
        int pos = spinned_buffer.last_pos;
        if (pos == NUMBER_OF_CHARS)
            pos = 0;
        while (pos != prev_pos(spinned_buffer.last_pos)){
            if (spinned_buffer.buffer[pos] == 0 && spinned_buffer.buffer[prev_pos(pos)] != 0)
              consputc('\n');
            if (spinned_buffer.buffer[pos] != 0)
                consputc(spinned_buffer.buffer[pos]);
            pos++;
            if (pos == NUMBER_OF_CHARS)
                pos = 0;           
        }
        consputc('\n');
    }
    return 0;
*/