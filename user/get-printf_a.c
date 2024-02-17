#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define BUFFER 512

int ptr = 0;
char buffer_[BUFFER];
char first[BUFFER], second[BUFFER];
int ptr_first = 0, ptr_second = 0;

void checking_exist() {
    if (ptr == BUFFER) {
        fprintf(2, "can't read second number\n");
        exit(1);
    }
}

void checking_space(int i){
    if ( i == 1 && buffer_[ptr] != ' '){
        fprintf(2, "enter two numbers separated by a space\n");
        exit(1);
    }
    if (i == 2 && buffer_[ptr] != '\n'){
        fprintf(2, "enter two numbers separated by a space\n");
        exit(1);
    }
}


int main(){
    gets(buffer_, BUFFER);
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
    printf("%d\n", sys_add(atoi(first), atoi(second)));
    exit(0);
}