#include "kernel/types.h"
#include "kernel/stat.h"
#include "user.h"
#include <stddef.h>

int main(int argc, char*argv[]) {

	printf("Getting user ID before forking...\n");
	sleep(3);
	int uid = getuid();
	printf("User ID: %d\n", uid);

	printf("forking...\n");
	sleep(5);

	int pid = fork();

	if (pid == 0) {
		sleep(1);
		int c = getuid();
		printf("Child id: %d\n", c);
	} else if (pid > 0) {
		int a = getuid();
		printf("Parent id: %d\n", a);
	} else {
		printf("error: fork() failed.\n");
		return 1;
	}

	return 0;

}
