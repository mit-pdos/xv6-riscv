#include "kernel/types.h"

#include "kernel/param.h"
#include "user/user.h"

#define MAX_LEN 512

int main(int argc, char *argv[]) {
    if (argc - 1 >= MAXARG) { //参数过多
        fprintf(2, "xargs: too many arguments.\n");
        exit(1);
    }

    char line[MAX_LEN];   //存储一行
    char *p = line;       //定位指针
    char *x_argv[MAXARG]; //exec的参数数组
    int i;
    for (i = 1; i < argc; i++) { //存储初始参数
        x_argv[i - 1] = argv[i];
    }

    int rsz = sizeof(char); //readSize,读取到的数据字节数
    while (rsz == sizeof(char)) {
        int word_begin = 0;  //定位参数起始位置
        int word_end = 0;    //定位参数结束位置
        int arg_cnt = i - 1; //当前参数次序

        while (1) { //读取一行
            rsz = read(0, p, sizeof(char));
            if (++word_end >= MAX_LEN) {
                fprintf(2, "xargs: arguments too long.\n");
                exit(1);
            }

            if (*p == ' ' || *p == '\n' || rsz != sizeof(char)) {
                *p = 0; //用字符串结束标志替换' '，'\n'和空字符
                x_argv[arg_cnt++] = &line[word_begin];
                word_begin = word_end; //下一个参数的起始位置在当前参数结束符之后

                if (arg_cnt >= MAXARG) { //参数过多
                    fprintf(2, "xargs: too many arguments.\n");
                    exit(1);
                }

                if (*p == '\n' || rsz != sizeof(char))
                    break;
            }
            ++p;
        }

        if (fork() == 0) {
            exec(argv[1], x_argv);
        }

        wait(0);
    }
    exit(0);
}
