#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

//void errors(int num) {
//   
//}

int main (int argc, char** argv) {
    int pid = fork ();
    if (pid < 0) {
        write (2, "error", 12); // дописать обработку ошибок и вынести в отдельную функцию
        exit (2);
    }
    else if (pid == 0) {
        sleep (10);
        exit (1);
    }
    printf ("return parent id, child id"); // дописать потом
    char flag = "-b";
    if () {
        
    }

}