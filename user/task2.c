#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"

#define BUFSIZE 20
#define MSG_START_PROCESS "Error: can't start new process\n"
#define MSG_READING_ERROR "Error: reading error\n"
#define MSG_BUFFER_OVERFLOW "Error: buffer overflow\n"

int main(int argc, char** argv) {
    int status;
    int pr[2];
    pipe(pr); 
    const int sizeOfBuffer = BUFSIZE + 1; //including space for '\0'
    int pid = fork();
    if (pid == 0) {
        close(pr[1]);
        char buf[sizeOfBuffer];
        int n;
        while ((n = read(pr[0], buf, sizeOfBuffer)) > 0) {
            printf("%s", buf);
        }
        close(pr[0]);
        if (n < 0) {
            write(2, MSG_READING_ERROR, sizeof(MSG_READING_ERROR) - 1);
            exit(4);
        }
        exit(0);
    }
    else if (pid < 0) {
        write(2, MSG_START_PROCESS, sizeof(MSG_START_PROCESS) - 1);
        exit(1);
    }
    else {
        close(pr[0]);
        char buf[sizeOfBuffer];
        for (int i = 1; i < argc; ++i) {
            if (strlen(argv[i]) >= sizeOfBuffer) {
                close(pr[1]);
                wait(&status);
                write(2, MSG_BUFFER_OVERFLOW, sizeof(MSG_BUFFER_OVERFLOW) - 1);
                exit(2);
            }
            strcpy(buf, argv[i]);
            buf[strlen(argv[i])] = '\n';
            write(pr[1], buf, strlen(argv[i]) + 1);
        }
        close(pr[1]);
        wait(&status);
        exit(0);
    }
}