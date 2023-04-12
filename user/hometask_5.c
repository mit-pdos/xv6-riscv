#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define CHARS ((1 << 11) - 1)

int main(){
    char u_buf[CHARS];
    uint64 len = dmesg(u_buf);
    if (len == -1)
        exit(-1);       
    int first_not_0 = 1;
    for (int i = 0; i < len; i++){
        if (first_not_0 && u_buf[i] != 0){
            first_not_0 = 0;
            write(1, u_buf + i, 1);
            continue;
        }
        if (u_buf[i] != 0)
            write(1, u_buf + i, 1);
        else
            write(1, "\n", 1);

    }


    exit(0);
}