#include "../kernel/types.h"
#include "../user/user.h"

int main(int argc, char *argv[]) {
  int n;

  if (argc < 2) {
    fprintf(2, "Usage: sleep <seconds>\n");
    exit(1);
  }

  n = atoi(argv[1]);
  if (n < 0) {
    n = 0;
  }

  // 在用户空间,能使用的函数只有user.h头文件中定义的函数
  // 所以不能直接调用内核的sleep函数,而应该使用pause系统调用
  pause(n); 
  exit(0);
  return 0;
}
