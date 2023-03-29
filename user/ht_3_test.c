#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int big_arr_taking_pages[(1 << 12)];

int main(){
    printf("\n-----------------------------------------------------------\n");
    printf("First vmprint:\n");
    printf("-----------------------------------------------------------\n");
    vmprint();
    printf("\n-----------------------------------------------------------\n");
    printf("First pgaccess:\n");
    printf("-----------------------------------------------------------\n");
    pgaccess();
    printf("\n-----------------------------------------------------------\n");
    printf("Pgaccess after pgaccess:\n");
    printf("-----------------------------------------------------------\n");
    pgaccess();
    big_arr_taking_pages[0] = 1;
    big_arr_taking_pages[64] = 1;
    big_arr_taking_pages[128] = 1;
    big_arr_taking_pages[256] = 1;
    big_arr_taking_pages[512] = 1;
    big_arr_taking_pages[1024] = 1;
    big_arr_taking_pages[2048] = 1;

    printf("\n-----------------------------------------------------------\n");
    printf("Vmprint after filling buffer:\n");
    printf("-----------------------------------------------------------\n");
    vmprint();
    printf("\n-----------------------------------------------------------\n");
    printf("Pgaccess after filling buffer:\n");
    printf("-----------------------------------------------------------\n");
    pgaccess();
    printf("\n-----------------------------------------------------------\n");
    printf("Pgaccess to check removing PTE_A:\n");
    printf("-----------------------------------------------------------\n");
    pgaccess();
    exit(0);
}