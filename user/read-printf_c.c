#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define BUFFER 512

char buffer_[BUFFER];
int ptr = 0;
char first[BUFFER], second[BUFFER];
int ptr_first = 0, ptr_second = 0;
char sym;

void checking_exist() {
    if (ptr == BUFFER) {
        fprintf(2, "can't read second number\n");
        exit(1);
    }
}

void checking_space(int i){
    if (i == 1 && buffer_[ptr] != ' '){
        fprintf(2, "enter two numbers separated by a space\n");
        exit(1);
    }
    if (i == 2 && buffer_[ptr] != '\n'){
        fprintf(2, "enter two numbers separated by a space\n");
        exit(1);
    }

}


void pre_reading(){
    while (ptr < BUFFER - 1) {
        if (read(0, &sym, 1) < 1) {
            break;
        }
        buffer_[ptr] = sym;
        ptr++;
        if (sym == '\n'){
            break;
        }
    }
}

int main() {
    pre_reading();
    buffer_[ptr] = '\0';
    ptr = 0;

    while (ptr < BUFFER && '0' <= buffer_[ptr] && buffer_[ptr] <= '9') {
        first[ptr_first++] = buffer_[ptr++];
    }
    checking_exist();
    checking_space(1);
    ptr++;
    while (ptr < BUFFER && '0' <= buffer_[ptr] && buffer_[ptr] <= '9') {
        second[ptr_second++] = buffer_[ptr++];
    }
    checking_space(2);
    printf("%d\n", atoi(first) + atoi(second));
    exit(0);
}