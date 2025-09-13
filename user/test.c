 // test.c:
 #include "kernel/types.h"
 #include "kernel/stat.h"
 #include "user/user.h"
 int main(int argc, char *argv[]) {
 // We expect one argument, so argc should be 2:
 // 1. program name (argv[0])
 // 2. the argument (argv[1])
 if (argc < 2) {
 printf("Need at least one arguement\n");
 exit(1);
 }
 // Loop 5 times to print the argument
 for (int i = 0; i < 5; i++) {
 printf("%s\n", argv[1]);
 }
 exit(0);
 }