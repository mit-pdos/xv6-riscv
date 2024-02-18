#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
    add(); // do syscall
    exit(0);
}