#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "user/set_password.h"

#define MAX_BUFFER_SIZE 100

int main(void){
    
    char buf[MAX_BUFFER_SIZE] = {};

    printf("Add New User\n");

    int fd = open("Passwords", O_RDWR);

    while(read(fd, buf, sizeof(buf))){};
    
    setPassword(fd);

    exit(0); 

}
