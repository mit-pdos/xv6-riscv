#include "kernel/types.h"
#include "kernel/fcntl.h"
#include "user/user.h"

char buf[512];

#define MAXLINE 512
char linebuf[MAXLINE];

// Read a line from file descriptor into buffer
// Returns number of chars read (including newline), 0 on EOF, -1 on error
int
readline(int fd, char *buf, int maxlen)
{
  int n;
  char c;
  int i = 0;

  // Read one character at a time from fd
  while((n = read(fd, &c, 1)) > 0){
    buf[i] = c;
    // Look for the newline character
    if(c == '\n'){
      // We are at the end of the line, so stop reading
      break;
    }
    i += 1;
    // We don't want to read more characters than we have room
    if(i >= (maxlen - 1)){
      // We can't recover, so just print a message and exit
      fprintf(2, "readline() - line too long\n");
      exit(-1);
    }
  }

  // If read() returns 0 AND we didn't read previous characters for this line,
  // then we want to return 0. Also, if read returns a value less than 0,
  // we want to return this error condition.
  if(((n == 0) && (i == 0)) || (n < 0))
    return n;

  // Add the null terminator to the end for the string buffer
  i += 1;
  buf[i] = '\0';

  return i;
}

// Global line number counter for -n option
int linenum = 1;

void
cat(int fd, int show_n)
{
  int n;

  if(show_n){
    // Line-by-line reading with line numbers
    while((n = readline(fd, linebuf, MAXLINE)) > 0){
      printf("%6d  %s", linenum++, linebuf);
    }
    if(n < 0){
      fprintf(2, "cat: read error\n");
      exit(1);
    }
  } else {
    // Original chunk-based reading
    while((n = read(fd, buf, sizeof(buf))) > 0){
      if(write(1, buf, n) != n){
        fprintf(2, "cat: write error\n");
        exit(1);
      }
    }
    if(n < 0){
      fprintf(2, "cat: read error\n");
      exit(1);
    }
  }
}

int
main(int argc, char *argv[])
{
  int fd, i;
  int show_n = 0;
  int first_file = 1;

  // Check for -n option
  if(argc > 1 && strcmp(argv[1], "-n") == 0){
    show_n = 1;
    first_file = 2;
  }

  if(first_file >= argc){
    // No files specified, read from stdin
    cat(0, show_n);
    exit(0);
  }

  for(i = first_file; i < argc; i++){
    if((fd = open(argv[i], O_RDONLY)) < 0){
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd, show_n);
    close(fd);
  }
  exit(0);
}
