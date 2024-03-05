#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "user/lab1_checkers.c"

const int BUF_SIZE = 12;

// Ладно, не поленился я и потыкал указатели)
// Считывает число (1 или 2 на выбор) со строки вида "s1 s2"
char *int_scanline(char *buffer, char *c, int *bytes_read_overall, uint8 is_fst_num) {
    int read_status, bytes_read = 0;

    while ((read_status = read(0, c, 1)) != 0) {
        check_read_status(read_status);
        check_buffer_overflow(*bytes_read_overall, BUF_SIZE);

        if (is_fst_num) check_for_space(*bytes_read_overall, c, BUF_SIZE);
        if (*c == '\n' || *c == '\r' || (is_fst_num && (*c == ' '))) break;

        (*bytes_read_overall)++;
        buffer[bytes_read++] = *c;
    }
    buffer[bytes_read] = '\0';
    return buffer;
}

int main() {
    int bytes_read_overall = 0;
    char buffer[BUF_SIZE], c;

    printf("%d\n",
           s_atoi(int_scanline(buffer, &c, &bytes_read_overall, 1)) +
           s_atoi(int_scanline(buffer, &c, &bytes_read_overall, 0)));
    exit(0);
}
