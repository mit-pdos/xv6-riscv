#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define BUF_SIZE 12000

int main() {
	char buf[BUF_SIZE];
	int res = dmesg(buf);

	buf[BUF_SIZE - 1] = 0;

	for (int i = 0; i < res; ++i)
		if (buf[i] != '\0')
			write(1, buf + i, 1);
		else
			write(1, "\n", 1);

	exit(0);
}