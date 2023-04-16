#include "kernel/types.h"
#include "kernel/stat.h"
#include "user.h"

int main(int argc, char*argv[]) {

	int a = getuid();		
	printf("User id: %d\n", a);
	exit(0);

}
