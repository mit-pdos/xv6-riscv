#include "kernel/types.h"
#include "kernel/fcntl.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  if (argc != 3) {
    printf("Usage: cp [source_file_path] [destination_file_path]");
    exit(1);
  }
  int rfd = open(argv[1],O_RDONLY);
  if (rfd < 0) {
    printf("failed to open file\n");
    exit(1);
  }
  int wfd = open(argv[2],O_WRONLY|O_CREATE|O_TRUNC);
  if (wfd < 0) {
    printf("failed to open file");
    close(rfd);
    exit(1);
  }
  char buffer[512];
  while (1) {
    int bytesRead = read(rfd, buffer, sizeof(buffer));
    if (bytesRead < 0) {
      printf("read failed\n");
      close(rfd);
      close(wfd);
      exit(1);
    }
    if (bytesRead == 0) {
      break;
    }
    int bytesWrote = write(wfd, buffer, bytesRead);
    if (bytesWrote < 0) {
      printf("write failed\n");
      close(rfd);
      close(wfd);
      exit(1);
    }
  }
  close(rfd);
  close(wfd);
  exit(0);
}