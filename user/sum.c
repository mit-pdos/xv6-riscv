#include "kernel/types.h"
#include "user/user.h"

#define MAX_BUF_SIZE 30

int
main(int argc, char *argv[])
{
      char buf[MAX_BUF_SIZE];
  gets(buf, MAX_BUF_SIZE);

  int num1 = -1;
  num1 = atoi(buf);
  int space_count = 0;
  int digits_count = 0;
  for (int i = 0; i < MAX_BUF_SIZE; i++) {
    if (buf[i] == '\0') {
      if (digits_count + space_count != i - 1 || space_count != 1 || buf[i - 2] > '9' || buf[i - 2] < '0') {
        printf("Incorrect data format\n");
        return 1;
      }
      break;
    }
    if (buf[i] >= '0' && buf[i] <= '9')
      digits_count++;
    if (buf[i] == ' ')
      space_count++;
  }
  if (buf[0] > '9' || buf[0] < '0') {
    printf("Incorrect data format\n");
    return 1;
  }
  int rank = 1, i = 0;
  for (i = 0; num1 / rank != 0; i++)
    rank *= 10;
  int num2 = -1;
  num2 = atoi(buf + (i + 1) + (int)(num1 == 0));

  printf("%d\n", add(num1, num2));

  exit(0);
}