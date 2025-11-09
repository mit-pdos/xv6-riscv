#include "../kernel/types.h"
#include "../user/user.h"

int main(void) {
    int p[2];  // 父进程到子进程的管道
    int c[2];  // 子进程到父进程的管道
    char buf[1];
    int pid;

    // 创建两个管道
    if (pipe(p) < 0 || pipe(c) < 0) {
        printf("pipe failed\n");
        exit(1);
    }

    // 创建子进程
    pid = fork();
    if (pid < 0) {
        printf("fork failed\n");
        exit(1);
    }

    if (pid == 0) {  // 子进程
        // 关闭不需要的管道端
        close(p[1]);  // 关闭父到子的写端
        close(c[0]);  // 关闭子到父的读端

        // 从父进程读取数据
        read(p[0], buf, 1);
        printf("%d: received ping\n", getpid());

        // 向父进程发送数据
        write(c[1], buf, 1);

        // 关闭管道
        close(p[0]);
        close(c[1]);
        exit(0);
    } else {  // 父进程
        // 关闭不需要的管道端
        close(p[0]);  // 关闭父到子的读端
        close(c[1]);  // 关闭子到父的写端

        // 向子进程发送数据
        write(p[1], "x", 1);

        // 等待子进程响应
        read(c[0], buf, 1);
        printf("%d: received pong\n", getpid());

        // 关闭管道
        close(p[1]);
        close(c[0]);
        wait(0);  // 等待子进程结束
        exit(0);
    }
}
