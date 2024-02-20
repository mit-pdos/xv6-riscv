#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define BUFFER 512

int ptr = 0;
char buffer_[BUFFER];


void checking_exist(int i) {
    if ( i ==  1 && ptr == BUFFER) {
        fprintf(2, "ERROR: can't read first number\n");
        exit(1);
    }
    if ( i ==  2 && ptr == BUFFER) {
        fprintf(2, "ERROR: can't read second number\n");
        exit(1);
    }
}

void checking_space(int i){
    if (i == 1 && buffer_[ptr] != ' '){
        fprintf(2, "ERROR: need two integer numbers separated by a space\n");
        exit(1);
    }
    if (i == 2 && buffer_[ptr] != '\n'){
        fprintf(2, "ERROR: need two integers numbers separated by a space\n");
        exit(1);
    }
}

void checking_correct(int i){
    if ( i == 2 && !(ptr < BUFFER && '0' <= buffer_[ptr] && buffer_[ptr] <= '9')) {
        fprintf(2, "ERROR: the second number was incorrect\n");
        exit(1);
    }
    if ( i == 1 && !(ptr < BUFFER && '0' <= buffer_[ptr] && buffer_[ptr] <= '9')) {
        fprintf(2, "ERROR: the first number was incorrect\n");
        exit(1);
    }
}


char first[BUFFER], second[BUFFER];
int ptr_first = 0, ptr_second = 0;

void reading(){
    checking_exist(1); checking_correct(1);
    while (ptr < BUFFER && '0' <= buffer_[ptr] && buffer_[ptr] <= '9') {
        first[ptr_first++] = buffer_[ptr++];
    }
    checking_exist(2); checking_space(1); ptr++;
    checking_correct(2);
    while (ptr < BUFFER && '0' <= buffer_[ptr] && buffer_[ptr] <= '9') {
        second[ptr_second++] = buffer_[ptr++];
    }
    checking_space(2);
}

//пункт b
void get_b(){
    gets(buffer_, BUFFER);
    reading();
    printf("%d\n", atoi(first) + atoi(second));
    exit(0);
}

int main() {
    get_b();
    exit(0);
}