// pingpong.c for xv6 (assignment #1 for CSC.T371)
// name: <<<your name>>>
// id: <<<your student id>>>

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// <<<remove this comment and fill your code here if needed>>>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(1, "usage: %s N\n", argv[0]);
        exit(1);
    }

    // # of rounds
    int n = atoi(argv[1]);

    // tick value before starting rounds
    int start_tick = uptime();

    // <<<remove this comment and fill your code here>>>

    // print # of ticks in nrounds
    printf("# of ticks in %d rounds: %d\n", n, uptime() - start_tick);
    exit(0);
}
