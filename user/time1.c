#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]){
	int pid;
	int start;
	int end;

	if(argc < 2){
		fprintf(2, "usage: time1 command [args...]\n");
		exit(1);
	}

	start = uptime();

	pid = fork();

	if(pid < 0){
		fprintf(2, "time1:fork failed\n");
		exit(1);
	}

	if(pid == 0){
		exec(argv[1], &argv[1]);

		fprintf(2, "time1: exec failed\n");
		exit(1);
	}

	end = uptime();

	printf("elapsed time: %d ticks\n", end - start);
	
	exit(0);
}

