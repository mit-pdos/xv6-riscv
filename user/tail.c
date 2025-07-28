#include "kernel/types.h"
#include "user/user.h"

#define MAX_LINE 512
#define MAX_LINES 1000  // Increased buffer size

char buf[MAX_LINES][MAX_LINE];

int main(int argc, char *argv[]) {
    int n = 10;  // default number of lines
    int fd = 0;  // default to stdin
    int argi = 1;
    
    // Parse command line arguments
    if (argc > 1 && strcmp(argv[1], "-n") == 0) {
        if (argc < 3) {
            fprintf(2, "tail: missing line count after -n\n");
            exit(1);
        }
        n = atoi(argv[2]);
        if (n <= 0) {
            fprintf(2, "tail: invalid line count %d\n", n);
            exit(1);
        }
        argi = 3;
    }
    
    // Open file if specified
    if (argc > argi) {
        fd = open(argv[argi], 0);
        if (fd < 0) {
            fprintf(2, "tail: cannot open %s\n", argv[argi]);
            exit(1);
        }
    }
    
    int total_lines = 0;
    int cur = 0;
    int len = 0;
    char c;
    
    // Read input character by character
    while (read(fd, &c, 1) == 1) {
        if (c == '\n') {
            buf[cur][len] = '\0';  // Null-terminate the line
            cur = (cur + 1) % MAX_LINES;
            len = 0;
            total_lines++;
        } else if (len < MAX_LINE - 1) {  // Prevent buffer overflow
            buf[cur][len++] = c;
        }
        // If line is too long, we just ignore extra characters until newline
    }
    
    // Handle final line without trailing newline
    if (len > 0) {
        buf[cur][len] = '\0';
        cur = (cur + 1) % MAX_LINES;
        total_lines++;
    }
    
    // Calculate how many lines to print and where to start
    int to_print = (n < total_lines) ? n : total_lines;
    int start;
    
    if (total_lines <= MAX_LINES) {
        // All lines fit in buffer
        start = (cur - to_print + MAX_LINES) % MAX_LINES;
    } else {
        // Buffer wrapped around, start from current position
        start = cur;
        to_print = (n < MAX_LINES) ? n : MAX_LINES;
    }
    
    // Print the last n lines
    for (int i = 0; i < to_print; i++) {
        int pos = (start + i) % MAX_LINES;
        printf("%s\n", buf[pos]);
    }
    
    if (fd != 0) {
        close(fd);
    }
    
    exit(0);
}
