#include "kernel/types.h"
#include "kernel/procinfo.h"
#include "kernel/param.h"
#include "user/user.h"

#define ERROR_PS_LISTINFO "Error: ps_listinfo failed %d\n"

char *states[] = {
    [STATE_UNUSED]    "UNUSED  ",
    [STATE_USED]      "USED    ",
    [STATE_SLEEPING]  "SLEEPING",
    [STATE_RUNNABLE]  "RUNNABLE",
    [STATE_RUNNING]   "RUNNING ",
    [STATE_ZOMBIE]    "ZOMBIE  "
};

int main(void) {
    procinfo_t buf[NPROC];

    int cnt_proc = ps_listinfo(buf, NPROC);
    if (cnt_proc < 0 || cnt_proc > NPROC) {
        fprintf(2, ERROR_PS_LISTINFO, cnt_proc);
        exit(1);
    }

    for (int i = 0; i < cnt_proc; ++i) {
        printf("%s %d %s\n", states[buf[i].state], buf[i].parent_pid, buf[i].name);
    }

    exit(0);
}
