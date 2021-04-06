#include "kernel/types.h"
#include "user/user.h"

#define RD 0
#define WR 1

const uint INT_LEN = sizeof(int);

/**
 * @brief 读取左邻居的第一个数据
 * @param lpipe 左邻居的管道符
 * @param pfirst 用于存储第一个数据的地址
 * @return 如果没有数据返回1,有数据返回0
 */
int read_first_data(const int lpipe[], int *pfirst) {
    if (read(lpipe[RD], pfirst, INT_LEN) > 0) {
        printf("prime %d\n", *pfirst);
        return 0;
    }
    return 1;
}

/**
 * @brief 读取左邻居的数据，将不能被first整除的写入右邻居
 * @param lpipe 左邻居的管道符
 * @param rpipe 右邻居的管道符
 * @param first 左邻居的第一个数据
 */
void transmit_data(int lpipe[], int rpipe[], int first) {
    int tmp = 0;

    while (read(lpipe[RD], &tmp, INT_LEN) > 0) {
        if (tmp % first != 0) { //只有不能被第一个数据整除的才传给右邻居
            write(rpipe[WR], &tmp, INT_LEN);
        }
    }

    close(lpipe[RD]);
    close(rpipe[WR]);
}

/**
 * @brief 寻找素数
 * @param lpipe 左邻居管道
 */
void primes(int lpipe[]) {
    close(lpipe[WR]); //关闭左邻居的写端

    int p[2];
    pipe(p);
    int first_of_left; //左邻居的第一个数据

    if (read_first_data(lpipe, &first_of_left) == 0) {
        if (fork() == 0)
            primes(p); //创建新进程，当前进程成为了新进程的左邻居

        close(p[RD]);
        transmit_data(lpipe, p, first_of_left); //将左进程的数据传入右进程
        wait(0);
        exit(0);
    } else {
        close(p[WR]);
        close(p[RD]);
        exit(0);
    }
}

int main(int argc, char const *argv[]) {
    int p[2];
    pipe(p);

    for (int i = 2; i <= 35; ++i) //写入初始数据
        write(p[WR], &i, INT_LEN);

    if (fork() == 0) {
        primes(p);
    }

    close(p[WR]);
    close(p[RD]);
    wait(0);
    exit(0);
}
