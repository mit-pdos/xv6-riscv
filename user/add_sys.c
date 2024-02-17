#include "kernel/types.h"

#include "kernel/stat.h"
#include "user/user.h"

#define BUF_SIZE 512

char buf[BUF_SIZE];
int ptr_buf = 0;
char a[BUF_SIZE], b[BUF_SIZE];
int ptr_a = 0, ptr_b = 0;

int
main()
{
  gets(buf, BUF_SIZE);
  if (ptr_buf < BUF_SIZE && (buf[ptr_buf] == '-' || buf[ptr_buf] == '+')) {
    a[ptr_a++] = buf[ptr_buf++];
  }
  while (ptr_buf < BUF_SIZE && '0' <= buf[ptr_buf] && buf[ptr_buf] <= '9') {
    a[ptr_a++] = buf[ptr_buf++];
  }
  if (ptr_buf == BUF_SIZE) {
    fprintf(2, "add: cannot read second number\n");
    exit(1);
  }
  if (buf[ptr_buf] != ' ') {
    fprintf(2, "add: input string must contain two numbers and a space between them\n");
    exit(1);
  }
  ptr_buf++;
  if (ptr_buf < BUF_SIZE && (buf[ptr_buf] == '-' || buf[ptr_buf] == '+')) {
    b[ptr_b++] = buf[ptr_buf++];
  }
  while (ptr_buf < BUF_SIZE && '0' <= buf[ptr_buf] && buf[ptr_buf] <= '9') {
    b[ptr_b++] = buf[ptr_buf++];
  }
  if (ptr_buf != BUF_SIZE && buf[ptr_buf] != '\n') {
    fprintf(2, "add: input string must contain two numbers and a space between them\n");
    exit(1);
  }   
  printf("%d\n", sys_add(atoi(a), atoi(b)));

  exit(0);
}
