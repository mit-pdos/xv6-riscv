#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

const int BUF_SIZE = 10; // max_int длинной в 10 цифр
const int STDERR_D = 2;

// Ладно, не поленился я и потыкал указатели)
// Считывает число (1 или 2 на выбор) со строки вида "s1 s2"
int int_scanline(char *buffer, char *c, int *bytes_read_overall, uint8 is_fst_num) {
    int read_status, bytes_read = 0;

    while ((read_status = read(0, c, 1)) != 0) {
        if (*bytes_read_overall >= BUF_SIZE) {
            fprintf(STDERR_D, "Buffer overflow.\n");
            exit(1);
        }
        if (read_status == -1) {
            fprintf(STDERR_D, "Error occurred while reading input.\n");
            exit(1);
        }
        if (*c == '\n' || *c == '\r' || (is_fst_num && (*c == ' '))) break;

        (*bytes_read_overall)++;
        buffer[bytes_read++] = *c;
    }
    buffer[bytes_read++] = '\0';
    return atoi(buffer);
}

int main() {
    char c;
    int a, b, bytes_read_overall = 0;
    char buffer[BUF_SIZE];

    a = int_scanline(buffer, &c, &bytes_read_overall, 1);

    if (c != ' ') {  // Если все, что мы прочитали - это только первое число
        fprintf(STDERR_D, "Not enough / invalid arguments.\n");
        exit(1);
    }

    b = int_scanline(buffer, &c, &bytes_read_overall, 0);

    printf("%d\n", a + b);
    exit(0);
}