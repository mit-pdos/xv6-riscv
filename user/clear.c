#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
    // ANSI escape sequence to clear screen and move cursor to top
    printf("\033[2J");
    printf("\033[H");

    exit(0);
}
