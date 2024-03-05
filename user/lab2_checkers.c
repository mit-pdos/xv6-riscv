#ifndef XV6_RISCV_OS_LAB2_CHECKERS_C
#define XV6_RISCV_OS_LAB2_CHECKERS_C

const int STDERR_D = 2;

void raise_err(char *err_msg) {
    write(STDERR_D, err_msg, strlen(err_msg));
    exit(1);
}

void fork_check(int pid) {
    if (pid < 0) {
        raise_err("Fork error.\n");
    }
}

void kill_check(int kill_status) {
    if (kill_status < 0) {
        raise_err("THIS CHILD IS IMMORTAL!!!\n");
    }
}

void check_read_status(int read_status) {
    if (read_status == -1) {
        raise_err("Error occurred while reading input.\n");
    }
}


#endif