#include "../kernel/types.h"
#include "../user/user.h"
#include "../kernel/fcntl.h"
#include <stdint.h>

void memdump(char *fmt, char *data, int len);

int
main(int argc, char *argv[])
{
  if (argc == 1) {
    printf("Example 1:\n");
    int a[2] = {61810, 2026};
    memdump("ii", (char *)a, sizeof(a));

    printf("Example 2:\n");
    memdump("S", "a string", sizeof("a string"));

    printf("Example 3:\n");
    char *s = "another";
    memdump("s", (char *)&s, sizeof(s));

    struct sss {
      char *ptr;
      int num1;
      short num2;
      char byte;
      char bytes[8];
    } example;

    example.ptr = "hello";
    example.num1 = 1819438967;
    example.num2 = 100;
    example.byte = 'z';
    strcpy(example.bytes, "xyzzy");

    printf("Example 4:\n");
    memdump("pihcS", (char *)&example, sizeof(example));

    printf("Example 5:\n");
    memdump("sccccc", (char *)&example, sizeof(example));
  } else if (argc == 2) {
    // format in argv[1], up to 512 bytes of data from standard input.
    char data[512];
    int n = 0;
    memset(data, '\0', sizeof(data));
    while (n < sizeof(data)) {
      int nn = read(0, data + n, sizeof(data) - n);
      if (nn <= 0)
        break;
      n += nn;
    }
    memdump(argv[1], data, n);
  } else {
    printf("Usage: memdump [format]\n");
    exit(1);
  }
  exit(0);
}

void
memdump(char *fmt, char *data, int len)
{
  int offset = 0;

  for (int i = 0; fmt[i] != '\0'; i++) {

    if (fmt[i] == 'i') {
      if (len - offset < 4) {
        printf("i\n");
        break;
      }

      uint32 value = *(uint32 *)(data + offset);
      printf("%d\n", value);
      offset += 4;
    }

    else if (fmt[i] == 'p') {
      if (len - offset < 8) {
        printf("p\n");
        break;
      }

      uint64 value = *(uint64 *)(data + offset);
      printf("%lx\n", value);
      offset += 8;
    }

    else if (fmt[i] == 'h') {
      if (len - offset < 2) {
        printf("h\n");
        break;
      }

      uint16 value = *(uint16 *)(data + offset);
      printf("%d\n", value);
      offset += 2;
    }

    else if (fmt[i] == 'c') {
      if (len - offset < 1) {
        printf("c\n");
        break;
      }

      uint8 value = *(uint8 *)(data + offset);
      printf("%c\n", value);
      offset += 1;
    }

    else if (fmt[i] == 's') {
      if (len - offset < 8) {
        printf("s\n");
        break;
      }

      uint64 ptr = *(uint64 *)(data + offset);
      printf("%s\n", (char *)ptr);
      offset += 8;
    }

    else if (fmt[i] == 'S') {
      // Print until null byte OR end of valid data.
      while (offset < len && data[offset] != '\0') {
        printf("%c", data[offset]);
        offset++;
      }

      printf("\n");
      break;
    }
  }
}
