#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    sigprocmask();
    fprintf(2, "Test sigprocmask\n");
    exit(0);
}
