// user/printflag.c

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h" // Chứa khai báo setvmprintflag(int)

int
main(int argc, char *argv[])
{
  if(argc < 2){
    fprintf(2, "Usage: printflag <0|1>\n");
    exit(1);
  }

  int flag = atoi(argv[1]); // Chuyển đổi chuỗi tham số thành số nguyên
  
  if (flag != 0 && flag != 1) {
    fprintf(2, "Flag must be 0 or 1.\n");
    exit(1);
  }

  // Gọi syscall 
  if (setvmprintflag(flag) < 0) {
    fprintf(2, "setvmprintflag syscall failed.\n");
    exit(1);
  }
  
  exit(0);
}