#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#include <stdarg.h>

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
  write(fd, &c, 1);
}

static void
printint(int fd, long long xx, int base, int sgn)
{
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
  do{
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    putc(fd, buf[i]);
}

static void
printptr(int fd, uint64 x) {
  int i;
  putc(fd, '0');
  putc(fd, 'x');
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
}

// Print to the given fd. Understands %d, %x, %p, %c, %s, %ld, %lu, %lx,
// and optional width + left-align flag, e.g. %-6s, %7d, %-14s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    c0 = fmt[i] & 0xff;
    if(state == 0){
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
      // Parse optional left-align flag
      int left = 0;
      if(c0 == '-'){
        left = 1;
        i++;
        c0 = fmt[i] & 0xff;
      }
      // Parse optional width
      int width = 0;
      while(c0 >= '0' && c0 <= '9'){
        width = width * 10 + (c0 - '0');
        i++;
        c0 = fmt[i] & 0xff;
      }

      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;

      if(c0 == 'd'){
        // Convert int to string to measure length for padding
        char buf[22]; int blen = 0;
        long long v = va_arg(ap, int);
        int neg = 0;
        if(v < 0){ neg = 1; v = -v; }
        do { buf[blen++] = '0' + (v % 10); v /= 10; } while(v);
        if(neg) buf[blen++] = '-';
        // reverse
        for(int a=0,b=blen-1; a<b; a++,b--){ char t=buf[a];buf[a]=buf[b];buf[b]=t; }
        if(!left) for(int k=blen; k<width; k++) putc(fd, ' ');
        for(int k=0; k<blen; k++) putc(fd, buf[k]);
        if(left)  for(int k=blen; k<width; k++) putc(fd, ' ');
      } else if(c0 == 'l' && c1 == 'd'){
        char buf[22]; int blen = 0;
        long long v = va_arg(ap, uint64);
        int neg = 0;
        if(v < 0){ neg = 1; v = -v; }
        do { buf[blen++] = '0' + (v % 10); v /= 10; } while(v);
        if(neg) buf[blen++] = '-';
        for(int a=0,b=blen-1; a<b; a++,b--){ char t=buf[a];buf[a]=buf[b];buf[b]=t; }
        if(!left) for(int k=blen; k<width; k++) putc(fd, ' ');
        for(int k=0; k<blen; k++) putc(fd, buf[k]);
        if(left)  for(int k=blen; k<width; k++) putc(fd, ' ');
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        char buf[22]; int blen = 0;
        long long v = va_arg(ap, uint64);
        int neg = 0;
        if(v < 0){ neg = 1; v = -v; }
        do { buf[blen++] = '0' + (v % 10); v /= 10; } while(v);
        if(neg) buf[blen++] = '-';
        for(int a=0,b=blen-1; a<b; a++,b--){ char t=buf[a];buf[a]=buf[b];buf[b]=t; }
        if(!left) for(int k=blen; k<width; k++) putc(fd, ' ');
        for(int k=0; k<blen; k++) putc(fd, buf[k]);
        if(left)  for(int k=blen; k<width; k++) putc(fd, ' ');
        i += 2;
      } else if(c0 == 'u'){
        printint(fd, va_arg(ap, uint32), 10, 0);
      } else if(c0 == 'l' && c1 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
        printint(fd, va_arg(ap, uint32), 16, 0);
      } else if(c0 == 'l' && c1 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        int slen = 0;
        for(char *p = s; *p; p++) slen++;
        if(!left) for(int k=slen; k<width; k++) putc(fd, ' ');
        for(; *s; s++) putc(fd, *s);
        if(left)  for(int k=slen; k<width; k++) putc(fd, ' ');
      } else if(c0 == '%'){
        putc(fd, '%');
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
    }
  }
}

void
fprintf(int fd, const char *fmt, ...)
{
  va_list ap;

  va_start(ap, fmt);
  vprintf(fd, fmt, ap);
}

void
printf(const char *fmt, ...)
{
  va_list ap;

  va_start(ap, fmt);
  vprintf(1, fmt, ap);
}
