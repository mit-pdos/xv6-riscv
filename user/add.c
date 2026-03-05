#include "kernel/types.h"
#include "user/user.h"

#define BUFSIZE 128



int
is_number(const char *s)
{
    if (*s == '-' || *s == '+') s++;
    if (*s == '\0') return 0;
    
    while (*s) {
        if (*s < '0' || *s > '9') return 0;
        s++;
    }

    return 1;
}

int
parse_line(char *buf, int *a, int *b)
{
    char *space = 0;
    char *p = buf;

    while (*p) {
        if (*p == ' ') {
            space = p;
            break;
        }
        p++;
    }

    if (!space) return -1;

    *space = '\0';

    if (!is_number(buf) || !is_number(space + 1))
        return -2;

    *a = atoi(buf);
    *b = atoi(space + 1);

    return 0;
}

int 
main (int argc, char *argv[])
{
    char buf[BUFSIZE];
    int n, total = 0;
    int a, b;

    printf("Enter two numbers separated by space: ");

    while (total < BUFSIZE - 1) {
        n = read(0, buf + total, 1);
        
        if (n < 0) {
            printf("Error: read failed\n");
            exit(1);
        }
        if (n == 0) {
            break;
        }
        if (buf[total] == '\n') {
            break;
        }
        total++;
    }

    buf[total] = '\0';

    printf("|%s|\n", buf);

    if (total == 0) {
        printf("Error: empty input\n");
        exit(1);
    }

    if (total == BUFSIZE - 1 && buf[total-1] != '\n') {
        printf("Error: input too long (max %d characters)\n", BUFSIZE - 1);
        exit(1);
    }

    int r = parse_line(buf, &a, &b);
    if (r == -1) {
        printf("Error: space separator not found\n");
        exit(1);
    }
    if (r == -2) {
        printf("Error: invalid number format\n");
        exit(1);
    }

    int sum = add(a, b);

    printf("Sum: %d + %d = %d\n", a, b, sum);

    exit(0);
}
