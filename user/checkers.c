#ifndef XV6_RISCV_OS_LAB1_CHECKERS_H
#define XV6_RISCV_OS_LAB1_CHECKERS_H


const int STDERR_D = 2;

void check_read_status(int read_status) {
    if (read_status == -1) {
        fprintf(STDERR_D, "Error occurred while reading input.\n");
        exit(1);
    }
}

void check_buffer_overflow(int bytes_read, int BUF_SIZE) {
    if (bytes_read >= BUF_SIZE) {
        fprintf(STDERR_D, "Buffer overflow.\n");
        exit(1);
    }
}

// Останется ли место для второго аргумента
void check_for_space(int read_first_bytes, char* read_char, int BUF_SIZE) {
    if (read_first_bytes >= BUF_SIZE - 2 || *read_char == '\n' || *read_char == '\r') {
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
