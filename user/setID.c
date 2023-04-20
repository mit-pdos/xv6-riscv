#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include <stddef.h>

int main(int argc, char *argv[]) {
        printf("testing setID...\n");
	int a = getuid();
	printf("User id: %d\n", a);
	printf("Changing user id...\n");
	sleep(3);
	//setuid();
	setID();
	int b = getuid();
	printf("User id: %d\n", b);
	printf("user ID changed!\n");
        exit(1);

}
