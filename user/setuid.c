#include "kernel/types.h"
#include "kernel/stat.h"
#include "user.h"
#include <stddef.h>

int main(int argc, char*argv[]) {
	
	setuid();
	printf("testing set id");
	
	return 0;
}
