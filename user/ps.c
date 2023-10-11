#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int arc, char *argv[]) {
    printf("%d Processes running.\n", ps());
    exit(0);
}