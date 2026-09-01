#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

int main() {
    int fd = open("test_peek.txt", O_CREATE | O_RDWR);
    if(fd < 0) {
        printf("open failed\n");
        exit(1);
    }

    char* hello = "hello world";
    write(fd, hello, strlen(hello));
    close(fd);
    
    fd = open("test_peek.txt", O_RDONLY);
    char buf[64];
    
    peek2(fd, buf, 5);
    buf[5] = 0;
    printf("peeking 5 bytes: %s\n", buf);
    
    peek2(fd, buf, 5);
    buf[5] = 0;
    printf("peeking 5 bytes again: %s\n", buf);
    
    peek2(fd, buf, 2);
    buf[2] = 0;
    printf("peeking 2 bytes: %s\n", buf);
    
    read(fd, buf, 2);
    buf[2] = 0;
    printf("reading 2 bytes: %s\n", buf);
    
    peek2(fd, buf, 3);
    buf[3] = 0;
    printf("peeking 3 bytes after reading: %s\n", buf);
    
    close(fd);
    exit(0);
}
