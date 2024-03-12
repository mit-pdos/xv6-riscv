#include "kernel/types.h"
#include "kernel/procinfo.h"
#include "kernel/param.h"
#include "user/user.h"

#define ERROR_NON_POSITIVE "Error: ps_listinfo returned non-positive value\n"

int writeWork() {
    struct procinfo pinfo[NPROC];
    int cnt_proc = ps_listinfo(pinfo, NPROC);
    //printf("Number of processes: %d\n", cnt_proc);
    if (cnt_proc <= 0) {
        printf(ERROR_NON_POSITIVE);
        return 0;
    }
    return 1;
}

int badAddress() {
    int cnt_proc = ps_listinfo(0, NPROC);
    //printf("Number of processes: %d\n", cnt_proc);
    return cnt_proc > 0;
}

int smallSpace() {
    struct procinfo pinfo[1];
    int cnt_proc = ps_listinfo(pinfo, 1);
    //printf("Number of processes: %d\n", cnt_proc);
    return (cnt_proc != -1);
}

int main(void) {
    int failed = 0;
    if (!writeWork()) {
        failed++;
        printf("writeWork test is failed\n");
    }
    if (!badAddress()) {
        failed++;
        printf("badAddress test is failed\n");
    }
    if (!smallSpace()) {
        failed++;
        printf("smallSpace test is failed\n");
    }
    if (!failed) {
        printf("ALL TESTS PASSED\n");
    }
    exit(0);
}
