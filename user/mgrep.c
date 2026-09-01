// Multi-process grep for xv6

#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"

char buf[1024];

int match(char *, char *);

void
mgrep_search(char *pattern, int fd)
{
  int n, m;
  char *p, *q;
  int pid = getpid();

  m = 0;
  while ((n = read(fd, buf + m, sizeof(buf) - m - 1)) > 0) {
    m += n;
    buf[m] = '\0';
    p = buf;
    while ((q = strchr(p, '\n')) != 0) {
      *q = 0;
      if (match(pattern, p)) {
        printf("(Worker PID: %d) %s\n", pid, p);
      }
      p = q + 1;
    }
    if (m > 0) {
      m -= p - buf;
      memmove(buf, p, m);
    }
  }
  if (m > 0) {
    buf[m] = '\0';
    if (match(pattern, buf)) {
      printf("(Worker PID: %d) %s\n", pid, buf);
    }
  }
}

int
main(int argc, char *argv[])
{
  int i, pid;
  char *pattern;

  if (argc < 3) {
    fprintf(2, "usage: mgrep pattern file1 file2 ...\n");
    exit(1);
  }

  pattern = argv[1];

  for (i = 2; i < argc; i++) {
    pid = fork();
    if (pid < 0) {
      fprintf(2, "mgrep: fork failed\n");
      exit(1);
    }
    if (pid == 0) {
      // Child process / worker
      int fd = open(argv[i], O_RDONLY);
      if (fd < 0) {
        printf("mgrep: cannot open %s\n", argv[i]);
        exit(1);
      }
      mgrep_search(pattern, fd);
      close(fd);
      exit(0);
    }
    wait(0);
  }
  exit(0);
}

// Regexp matcher from Kernighan & Pike (same as user/grep.c)

int matchhere(char *, char *);
int matchstar(int, char *, char *);

int
match(char *re, char *text)
{
  if (re[0] == '^')
    return matchhere(re + 1, text);
  do { // must look at empty string
    if (matchhere(re, text))
      return 1;
  } while (*text++ != '\0');
  return 0;
}

// matchhere: search for re at beginning of text
int
matchhere(char *re, char *text)
{
  if (re[0] == '\0')
    return 1;
  if (re[1] == '*')
    return matchstar(re[0], re + 2, text);
  if (re[0] == '$' && re[1] == '\0')
    return *text == '\0';
  if (*text != '\0' && (re[0] == '.' || re[0] == *text))
    return matchhere(re + 1, text + 1);
  return 0;
}

// matchstar: search for c*re at beginning of text
int
matchstar(int c, char *re, char *text)
{
  do { // a * matches zero or more instances
    if (matchhere(re, text))
      return 1;
  } while (*text != '\0' && (*text++ == c || c == '.'));
  return 0;
}
