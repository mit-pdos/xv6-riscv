#include "user.h"

// Does nothing
// If provided, set tickets
int main(int argc, char **argv) {
    if (argc >= 2) {
        int tickets = atoi(argv[1]);
        if (settickets(tickets) != 0) {
            printf("settickets failed\n");
            exit(1);
        }
    }
    int i = 0;
    while(1) {
        i++;
    }
}