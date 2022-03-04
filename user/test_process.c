#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define SLEEPTICKS 10000

//We want Child 1 to execute first, then Child 2, and finally Parent.
int main() {
 	int pid = fork(); //fork the first child

	if (pid < 0) {
 		printf("Error forking first child.\n");
 	} else if (pid == 0) {
		sleep(30);
 		printf("Child 1 Executing\n");
		exit(0);
 	} else {
		wait((int *) 0);
 		pid = fork(); //fork the second child
 		if (pid < 0) {
 			printf("Error forking second child.\n");
 		} else if (pid == 0) {
 			printf("Child 2 Executing\n");
			sleep(30);
			exit(0);
 		} else {
 			printf("Parent Waiting\n");
			wait((int *) 0);
 			printf("Children completed\n");
 			printf("Parent Executing\n");
 			printf("Parent exiting.\n");
 		}
 	}
 exit(0);
}