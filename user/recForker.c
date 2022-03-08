#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"

#define IOCOUNT 10
#define WAIT_DURATION 1000000000

char filenames[100][15] = {"test_case_0", "test_case_1", "test_case_2", "test_case_3", "test_case_4", "test_case_5", "test_case_6", "test_case_7", "test_case_8", "test_case_9", "test_case_10", "test_case_11", "test_case_12", "test_case_13", "test_case_14", "test_case_15", "test_case_16", "test_case_17", "test_case_18", "test_case_19", "test_case_20", "test_case_21", "test_case_22", "test_case_23", "test_case_24", "test_case_25", "test_case_26", "test_case_27", "test_case_28", "test_case_29", "test_case_30", "test_case_31", "test_case_32", "test_case_33", "test_case_34", "test_case_35", "test_case_36", "test_case_37", "test_case_38", "test_case_39", "test_case_40", "test_case_41", "test_case_42", "test_case_43", "test_case_44", "test_case_45", "test_case_46", "test_case_47", "test_case_48", "test_case_49", "test_case_50", "test_case_51", "test_case_52", "test_case_53", "test_case_54", "test_case_55", "test_case_56", "test_case_57", "test_case_58", "test_case_59", "test_case_60", "test_case_61", "test_case_62", "test_case_63", "test_case_64", "test_case_65", "test_case_66", "test_case_67", "test_case_68", "test_case_69", "test_case_70", "test_case_71", "test_case_72", "test_case_73", "test_case_74", "test_case_75", "test_case_76", "test_case_77", "test_case_78", "test_case_79", "test_case_80", "test_case_81", "test_case_82", "test_case_83", "test_case_84", "test_case_85", "test_case_86", "test_case_87", "test_case_88", "test_case_89", "test_case_90", "test_case_91", "test_case_92", "test_case_93", "test_case_94", "test_case_95", "test_case_96", "test_case_97", "test_case_98", "test_case_99"};

void recursiveForker(int n) {
    if (n < 0) return;
    int pid = fork();
    if(pid > 0) {
        printf("I'm the parent doing  CPU bound task: my child=%d\n", pid);
        recursiveForker(n-1);
        for (uint64 i = 0; i < WAIT_DURATION; ) ++i;
    } else if (pid == 0) {
        printf("I'm the child doing IO :: n=%d\n", n);
        int fd1 = open(filenames[n], O_CREATE|O_WRONLY|O_TRUNC);
        for(int i = 0; i < IOCOUNT; i++)
        {
            write(fd1, "I'm writing into a testfile.", 29);
        }
        close(fd1);
    }
}

int main() {
    recursiveForker(25);
    exit(0);
}
