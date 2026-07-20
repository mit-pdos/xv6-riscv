#include "kernel/types.h"
#include "user/user.h"


void process_file(char *filename) {
    int fd;

    fd = open(filename, 0); 
    if (fd < 0) {
        fprintf(2, "sixfive: cannot open %s\n", filename);
        exit(1);
    }

    char buf[512];
    int n;
    int num = 0;
    while ((n = read(fd, buf, sizeof(buf))) > 0) {
        for (int i = 0; i < n; i++) {
            char c = buf[i];
            switch(c) {
                case '-':
                case '\r':
                case '\t':
                case '\n':
                case '.':
                case '/':
                case ',':
                    if(num % 5 == 0 || num % 6 == 0) printf("%d\n", num);
                    num = 0;
                    break;
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                case '8':
                case '9':
                    if(num == 0 && c == '0') break;
                    num = num * 10 + c - '0';
                    break;
                default:
                    fprintf(1, "unknown symbol\n");
                    break;
            } 
        }
        if(num % 5 == 0 || num % 6 == 0) printf("%d\n", num);
    }

    if (n < 0) {
        fprintf(2, "sixfive: read error\n");
        exit(1);
    }

    close(fd);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(2, "Usage: %s <filename1> ...\n", argv[0]);
        exit(1);
    }

    for (int i = 1; i < argc; i++) {
        process_file(argv[i]);
    }
    exit(0);
}