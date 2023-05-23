#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/fs.h"

char buf[BSIZE];

int main(int argc, char* argv[]) {

    if (argc != 3) {
        printf("Usage: create file_name block_amount\n");
    }

    char* file_name = argv[1];
    int blocks = atoi(argv[2]);

    int i;

    int fd = open(file_name, O_CREATE | O_WRONLY);
    if (fd < 0) {
        printf("create: cannot open %s for writing\n", file_name);
        return -1;
    }

    for (i = 0; i < blocks; i++) {
        int cc = write(fd, buf, sizeof(buf));
        if (cc <= 0)
            break;
    }

    printf("create: wrote %d blocks\n", i);
    close(fd);
    return 0;
}
