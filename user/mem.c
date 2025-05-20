#include <stddef.h>
#include "kernel/types.h"
#include "user/user.h"
// #include <assert.h>

int
main(int argc, char *argv[])
{
int *p = malloc(sizeof(int)); // a1
if(p==NULL){
    printf("Failed");
    exit(1);
}
//assert(p != NULL);
printf("(%d) address pointed to by p: %p\n",
getpid(), p); // a2
*p = 0; // a3
while (1) {
sleep(1);
*p = *p + 1;
printf("(%d) p: %d\n", getpid(), *p); // a4
}
return 0;
}
