#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"

#define BUF_SIZE 64

int isGap(char c) {
  char *gaps = " -\r\t\n./,";

  for (int i=0; i<8; i++) {
    if (gaps[i] == c) { return 1; }
  }
  return 0;
}

int main(int argc, char* argv[]) {
  for (int i=1; i<argc; i++) {
    printf("loop: %d\n", i);
    if (!argv[i]) {
      printf("Missing Argument");
      exit(1);
    }
  
    int fd = open(argv[i], O_RDONLY);
    if (fd == -1) { 
        printf("Could not find %s", argv[i]);
        exit(1);
    }

    char buf[BUF_SIZE];
    char c = ' '; 
    int bufI = 0;
    int n = 0;
    int valid_num = 1;

    while (read(fd, &c, 1) == 1) {

      if (!isGap(c) && valid_num) {
        if ('0' <= c && c <= '9') {
          buf[bufI] = c;
          bufI++;
        } else {
          valid_num = 0;
        }

      } else {
        buf[bufI] = '\0';
        if (bufI > 0) {
          n = atoi(buf);
          if (n%6==0 || n%5==0) { printf("%d\n", n); }
        }
        bufI = 0;
        valid_num = 1;
      }
    }

    if (bufI > 0) {
      buf[bufI] = '\0';
      n = atoi(buf);
      if (n%6==0 || n%5==0) { printf("%d\n", n); } 
    }
  }
  exit(0);
}
