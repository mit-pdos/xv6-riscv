#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char* argv[]) {
    int MAX_SIZE = 100;
    char buf[MAX_SIZE];

    int i, cc;
    char c;

    for(i = 0; i + 1 < MAX_SIZE; i++) {
        cc = read(0, &c, 1);
        if(cc < 1) break;
        buf[i] = c;
        if(c == '\n') break;
    }
    buf[i] = '\0';

    printf("|%s|\n", buf);

    int a, b;
    char* p = buf;

    a = atoi(p);

    while (*p && *p != ' ') p++;
    if (*p == ' ') p++;

    b = atoi(p);

    int sum = a + b;

    printf("%d\n", sum);

    exit(0);
}
