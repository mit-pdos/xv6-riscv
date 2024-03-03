#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define BUFSIZE 20
#define MSG_START_PROCESS "Error: can't start new process\n"
#define MSG_READING_ERROR "Error: reading error\n"
#define MSG_BUFFER_OVERFLOW "Error: buffer overflow\n"
#define MSG_CANT_EXEC_WC "Error: can't execute wc program\n"

int main(int argc, char** argv) {
    int status;
    int pr[2];
    pipe(pr);
    const int sizeOfBuffer = BUFSIZE + 1; //including space for '\0'
    int pid = fork();
    if (pid == 0) {
        close(pr[1]);
        close(0);
        dup(pr[0]);
        close(pr[0]);
        char* argv[] = {"/wc", 0};
        exec("/wc", argv);
        write(2, MSG_CANT_EXEC_WC, sizeof(MSG_CANT_EXEC_WC) - 1);
        exit(3);
    }
    else if (pid < 0) {
        write(2, MSG_START_PROCESS, sizeof(MSG_START_PROCESS) - 1);
        exit(1);
    }
    else {
        close(pr[0]);
        char buf[sizeOfBuffer];
        for (int i = 1; i < argc; ++i) {
            int len = strlen(argv[i]);
            if (len >= sizeOfBuffer) {
                close(pr[1]);
                wait(&status);
                const int msg_len = 16;
                write(2, MSG_BUFFER_OVERFLOW, sizeof(MSG_BUFFER_OVERFLOW) - 1);
                exit(2);
            }
            strcpy(buf, argv[i]);
            buf[len] = '\n';
            write(pr[1], buf, len + 1);
        }
        close(pr[1]);
        wait(&status);
        exit(0);
    }
}