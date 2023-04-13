#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char* argv[]) {
    const int buffsize = 5000;
    char* buff = malloc(buffsize);
    int res = dmesg(buff, 5000);
    buff[5000 - 1] = 0; 
    printf("dmesg: exited with code %p\n res: %s\n", res, buff);
    return 0;
}