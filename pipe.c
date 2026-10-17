#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char* argv[]) {
    int pid = fork();

    if (pid < 0) {
        printf("Process error\n");

        exit(1);
    }

    else if (pid == 0) {
        

        close(0);
        dup(pipefd[0]);
    }

    else {
    
        close(pipefd[0]);
    }
}



/*

int p[2];
char *argv[2];
argv[0] = "wc";
argv[1] = 0;
pipe(p);

if (fork() == 0) {
    close(0); // Закрываем stdin
    dup(p[0]); // Закрываем исходный дескриптор
    close(p[0]);
    close(p[1]);
    exec("/bin/wc", argv);
}

else {
    close(p[0]);
    write(p[1], "hello, world\n", 12); 
    close(p[1]);
}



*/