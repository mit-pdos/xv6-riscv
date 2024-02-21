#ifndef XV6_RISCV_OS_LAB1_CHECKERS_H
#define XV6_RISCV_OS_LAB1_CHECKERS_H


const int STDERR_D = 2;

void check_read_status(int read_status) {
    if (read_status == -1) {
        fprintf(STDERR_D, "Error occurred while reading input.\n");
        exit(1);
    }
}

void read_until_newline(void) {
    int read_status;
    char c;
    while ((read_status = read(0, &c, 1)) != 0) {
        check_read_status(read_status);
        if (c == '\n' || c == '\r') break;
    }
}

void check_buffer_overflow(int bytes_read, int BUF_SIZE) {
    if (bytes_read >= BUF_SIZE) {
        // Дочитаем до перевода на новую строку, раз уж хочется бЕзОпАсНосТи
        read_until_newline();
        fprintf(STDERR_D, "Buffer overflow.\n");
        exit(1);
    }
}

// Останется ли место для второго аргумента
void check_for_space(int read_first_bytes, int BUF_SIZE) {
    if (read_first_bytes >= BUF_SIZE - 2) {
        fprintf(STDERR_D, "Not enough arguments.\n");
        exit(1);
    }
}

int is_digit(char c) {
    return c >= '0' && c <= '9';
}

int s_atoi(char *str) { // Если данная строка - число, то выведется ее версия в инте
    int i = 0;
    do {
        if (!is_digit(str[i]) || strlen(str) == 0) {
            fprintf(STDERR_D, "Invalid arguments.\n");
            exit(1);
        }
        i++;
    } while (str[i] != '\0');
    return atoi(str);
}

#endif
