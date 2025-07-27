#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[]) {
    int x1 = getreadcount();

    int rc = fork();

    int total = 0;
    int i;
    for (i = 0; i < 100000; i++) {
	char buf[100];
	(void) read(4, buf, 1);
    }
    // https://wiki.osdev.org/Shutdown
    // (void) shutdown();

    if (rc > 0) {
        (void) wait(0);
        int x2 = getreadcount();
        total += (x2 - x1);
        fprintf(1, "XV6_TEST_OUTPUT %d\n", total);
    }
    exit(0);
}
