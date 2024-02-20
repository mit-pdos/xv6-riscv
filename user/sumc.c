#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

const int BUF_SIZE = 10; // max_int длинной в 10 цифр
const int STDERR_D = 2;

// Ладно, не поленился я и потыкал указатели)
int int_scanline(char *buffer, char *c, bool is_fst_num) {
    int read_status, bytes_read = 0;

    while ((read_status = read(0, c, 1)) != 0 && bytes_read < BUF_SIZE) {
        if (read_status == -1) { // Если ошибка при чтении
            fprintf(STDERR_D, "Error occurred while reading input.\n");
            exit(1);
        }
        if (*c == '\n' || *c == '\r' || (is_fst_num && (*c == ' '))) break;

        buffer[bytes_read++] = *c;
    }
    buffer[bytes_read++] = '\0';
    return atoi(buffer);
}

int main() {
    char c;
    int a, b;

    // Я решил сэкономить на памяти: будем работать с одним буфером аккуратненько
    char buffer[BUF_SIZE];

    a = int_scanline(buffer, &c, true);
    // Если все, что мы прочитали - это только одно число
    if (c != ' ') {
        fprintf(STDERR_D, "Not enough / invalid arguments.\n");
        exit(1);
    }

    b = int_scanline(buffer, &c, false);

    printf("%d\n", a + b);
    exit(0);
}