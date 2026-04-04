#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

int main(int argc, char *argv[]) {
  if (argc < 3) {
    printf("Usage: iobench iterations sleep_ticks\n");
    exit(1);
  }

  int iterations = atoi(argv[1]);
  int sleep_ticks = atoi(argv[2]);

  int fd;
  char buf[512];

  for (int i = 0; i < 512; i++)
    buf[i] = 'A';

  // WRITE BENCHMARK
  int write_start = uptime();

  fd = open("testfile", O_CREATE | O_RDWR);
  if (fd < 0) {
    printf("open failed\n");
    exit(1);
  }

  for(int i = 0; i < iterations; i++) {
    if (write(fd, buf, sizeof(buf)) != sizeof(buf)) {
      printf("write error\n");
      exit(1);
    }
    sleep(sleep_ticks);
  }

  close(fd);

  int write_end = uptime();

  // READ BENCHMARK
  int read_start = uptime();

  fd = open("testfile", O_RDONLY);
  if (fd < 0) {
    printf("open failed for read\n");
    exit(1);
  }

  for(int i = 0; i < iterations; i++) {
    if (read(fd, buf, sizeof(buf)) < 0) {
      printf("read error\n");
      exit(1);
    }
  }

  close(fd);
  int read_end = uptime();

  unlink("testfile");

  printf("Write time: %d ticks\n", write_end - write_start);
  printf("Read time: %d ticks\n", read_end - read_start);

  exit(0);
}