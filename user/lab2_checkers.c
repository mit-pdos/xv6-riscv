#ifndef XV6_RISCV_OS_LAB2_CHECKERS_C
#define XV6_RISCV_OS_LAB2_CHECKERS_C

const int STDERR_D = 2;

void fork_check(int pid) {
    char *err_msg = "Fork error.\n";
    if (pid < 0) {
        write(STDERR_D, err_msg, strlen(err_msg));
        exit(1);
    }
}

void kill_check(int kill_status) {
    char *err_msg = "THIS CHILD IS IMMORTAL!!!\n";
    if (kill_status < 0) {
        write(STDERR_D, err_msg, strlen(err_msg));
        exit(1);
    }
}

#endif