#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

int
main(int argc, char** argv) {
    if (argc != 3) {
        fprintf(2, "Usage: setpriority pid priority");
        exit(1);
    }
    int priority = atoi(argv[1]);
    int pid = atoi(argv[2]);
    if (priority < 0 || priority > 100) {
        fprintf(2, "Priority must be between 0 and 100");
        exit(1);
    }
    if (set_priority(priority, pid) < 0) {
        fprintf(2, "Failed to set priority");
        exit(1);
    }
}