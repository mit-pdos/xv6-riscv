#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

int main() {
    int fd = open("dummy3", O_CREATE | O_RDWR);
    if(fd < 0) {
        printf("open failed\n");
        exit(1);
    }

    write(fd, "hello world\n", 12);
    close(fd);
    
    fd = open("dummy3", O_RDONLY);
    
    printf("[parent] fd=%d, inode=%d, offset=%d\n", fd, (int)get_inode_num(fd), (int)get_inode_num(fd));
    printf("[parent] forking a child...\n");
    
    int pid = fork();
    if (pid == 0) {
        printf("[child] fd=%d, inode=%d, offset=%d\n", fd, (int)get_inode_num(fd), (int)get_read_offset(fd));
        char buf[64];
        int n = 5;
        printf("[child] reading %d bytes from fd=%d\n", n, fd);
        read(fd, buf, n);
        printf("[child] fd=%d, inode=%d, offset=%d\n", fd, (int)get_inode_num(fd), (int)get_read_offset(fd));
        exit(0);
    }
    
    wait(0);
    printf("[parent] reaping child...\n");
    printf("[parent] fd=%d, inode=%d, offset=%d\n", fd, (int)get_inode_num(fd), (int)get_read_offset(fd));
    
    close(fd);
    exit(0);
}
