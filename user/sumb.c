#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "user/lab1_checkers.c"

const int BUF_SIZE = 12;

int main(int argc, char *argv[]) {
    char buffer[BUF_SIZE];
    gets(buffer, BUF_SIZE);

    // Нуль-терминируем инпут
    int newline_ind = 0;
    while (buffer[newline_ind] != '\n' && buffer[newline_ind] != '\r' && buffer[newline_ind] != '\0') { newline_ind++; }
    buffer[newline_ind] = '\0';

    int space_ind = 0;
    while (buffer[space_ind] != ' ') { // Прочитаем первое число
        check_for_space(space_ind, &buffer[space_ind], BUF_SIZE);
        space_ind++;
    }
    buffer[space_ind] = '\0';
    printf("%d\n", add(s_atoi(buffer), s_atoi(buffer + space_ind + 1)));
    return 0;
}
