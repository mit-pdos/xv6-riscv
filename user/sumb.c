#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

const int BUF_SIZE = 20;


int main(int argc, char *argv[]) {
    char buffer[BUF_SIZE], a[BUF_SIZE], b[BUF_SIZE]; // Так-то можно память оптимизировать, записывая сразу в а, а потом отделить \0
    gets(buffer, BUF_SIZE);

    int input_len = 0;
    while (buffer[input_len] != '\n') {
        if (input_len >= BUF_SIZE) {
            fprintf(2, "Buffer overflow!\n");
            exit(1);
        }
        input_len++;
    }

    int space_ind = 0;
    while (buffer[space_ind] != ' ') { // Прочитаем первое число
        // Т.к. плохой случай может иметь вид: {'a', 'b', 'c', ' ', '\0'}, где BUF_SIZE = 5
        if (space_ind >= BUF_SIZE - 2) {
            fprintf(2, "Not enough arguments!\n");
            exit(1);
        }
        a[space_ind] = buffer[space_ind];
        space_ind++;
    }
    a[space_ind] = '\0';

    // Эта строка будет нуль-терминирована из-за инварианта gets (возможно, обыграю отрезание второй цифры, но в асм точно нет)
    strcpy(b, buffer + space_ind + 1);
    printf("%d\n", atoi(a) + atoi(b));
    return 0;
}
