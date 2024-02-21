#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "user/checkers.h"

const int BUF_SIZE = 12;

int main(int argc, char *argv[]) {
    char buffer[BUF_SIZE], a[BUF_SIZE], b[BUF_SIZE];
    gets(buffer, BUF_SIZE);

    int newline_ind = 0;
    while (buffer[newline_ind] != '\n' && buffer[newline_ind] != '\r') {
        check_buffer_overflow(newline_ind, BUF_SIZE);
        newline_ind++;
    }
    buffer[newline_ind] = '\0';

    int space_ind = 0;
    while (buffer[space_ind] != ' ') { // Прочитаем первое число
        check_for_space(space_ind, &buffer[space_ind], BUF_SIZE);
        a[space_ind] = buffer[space_ind];
        space_ind++;
    }
    a[space_ind] = '\0';

    strcpy(b, buffer + space_ind + 1);
    printf("%d\n", s_atoi(a) + s_atoi(b));
    return 0;
}
