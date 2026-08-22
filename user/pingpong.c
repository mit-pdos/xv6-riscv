#include "kernel/types.h"
#include "user.h"
#include "printf.h"

int main(int argc, char *argv[])
{
	int ping[2];
  int pong[2];
  (void)pipe(ping);
  (void)pipe(pong);

  uint64 start = uptime();
  uint64 pingpongs;

  if (argc < 2) {
    pingpongs = 10000000;
  } else {
    pingpongs = (uint64)atoi(argv[1]);
  }

  char b = 0x41; // A
  char buf;
  int stdout = 1;

	int pid = fork();

  if (pid > 0) {
    fprintf(stdout, "starting %ld pingpongs\n", pingpongs);
  }

  for (uint64 i = 0; i < pingpongs; i++) {
    if (pid > 0) {
      // parent writes ping, reads pong
      write(ping[1], &b, sizeof(b));
      (void)read(pong[0], &buf, sizeof(buf));
    } else if (pid == 0) {
      // child reads ping, writes pong
      (void)read(ping[0], &buf, sizeof(buf));
      write(pong[1], &b, sizeof(b));
    }
  }

  uint64 end = uptime();

  if (pid == wait(0)) {
    fprintf(stdout, "start: %ld, end: %ld, duration: %ld\n", start, end, (end - start));
  }

  exit(0);
}
