#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

// Limiting input size to 20 KB here as per assignment note for simplicity
#define MAX_BUFFER_SIZE (20 * 1024)
#define DEFAULT_LINES 10

static char buffer[MAX_BUFFER_SIZE];  

void usage() {
    printf("Usage: tail [-n N] [file]\n");
    exit(1);
}

// Minimal atoi; returns –1 if the string isn’t a positive number
int str_to_int(char *str) {
    int num = 0;
    if (!str || *str == '\0') return -1;
    for (; *str; str++) {
        if (*str < '0' || *str > '9') return -1;
        num = num * 10 + (*str - '0');
    }
    return num;
}

// Print the last N lines contained in buffer[0..total)
void print_tail(char *buf, int total, int lines) {
    int line_count = 0, i;

    for (i = 0; i < total; i++)
        if (buf[i] == '\n') line_count++;

    if (line_count <= lines) {          // file shorter than request
        write(1, buf, total);
        return;
    }

    int skip = line_count - lines;
    for (i = 0; i < total; i++) {
        if (buf[i] == '\n' && --skip == 0) {
            int start = (i + 1 < total) ? i + 1 : i; // avoid past-end
            write(1, buf + start, total - start);
            return;
        }
    }
}

int main(int argc, char *argv[]) {
    int fd = 0, lines = DEFAULT_LINES;
    int total = 0, n;

    // argument parsing
    if (argc == 1) {                                    // stdin → tail
        fd = 0;
    } else if (argc == 2) {                             // tail file
        if (argv[1][0] == '-') usage();
        fd = open(argv[1], 0);
        if (fd < 0) { printf("tail: cannot open %s\n", argv[1]); exit(1); }
    } else if (argc == 3) {                             // tail -n N  (stdin)
        if (strcmp(argv[1], "-n")) usage();
        lines = str_to_int(argv[2]);
        if (lines < 0) { printf("tail: invalid -n\n"); exit(1); }
    } else if (argc == 4) {                             // tail -n N file
        if (strcmp(argv[1], "-n")) usage();
        lines = str_to_int(argv[2]);
        if (lines < 0) { printf("tail: invalid -n\n"); exit(1); }
        fd = open(argv[3], 0);
        if (fd < 0) { printf("tail: cannot open %s\n", argv[3]); exit(1); }
    } else {
        usage();
    }

    // Read input up to 20 KB
    while ((n = read(fd, buffer + total, MAX_BUFFER_SIZE - total)) > 0) {
        total += n;
        if (total >= MAX_BUFFER_SIZE) break;            // stop at hard cap
    }
    if (fd > 0) close(fd);

    print_tail(buffer, total, lines);
    exit(0);
}
