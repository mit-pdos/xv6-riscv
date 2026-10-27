#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

static volatile int count_g = 0;

static void
bubble_sort(int *numbers, int count)
{
  int i, j, temporary, swapped;

  for (i = 0; i < count - 1; i++) {
    pwalk();
    count_g ++;
    swapped = 0;
    for (j = 0; j < count - i - 1; j++) {
      if (numbers[j] > numbers[j + 1]) {
        temporary = numbers[j];
        numbers[j] = numbers[j + 1];
        numbers[j + 1] = temporary;
        swapped = 1;
      }
    }
    if (!swapped)
      break;
  }
}

static int
parse_integer(char *text)
{
  int number, sign;

  sign = 1;
  if (*text == '-') {
    sign = -1;
    text++;
  }

  number = 0;
  while ('0' <= *text && *text <= '9')
    number = number * 10 + *text++ - '0';
  return sign * number;
}

int
main(int argc, char *argv[])
{
  kwalk();
  int i;
  int *numbers;

  if (argc < 2) {
    fprintf(2, "usage: bubblesort number...\n");
    exit(1);
  }

  numbers = malloc((argc - 1) * sizeof(*numbers));
  if (numbers == 0) {
    fprintf(2, "bubblesort: cannot allocate memory\n");
    exit(1);
  }

  for (i = 1; i < argc; i++)
    numbers[i - 1] = parse_integer(argv[i]);

  bubble_sort(numbers, argc - 1);

  for (i = 0; i < argc - 1; i++) {
    if (i > 0)
      printf(" ");
    printf("%d", numbers[i]);
  }
  printf("\n");

  kwalk();
  free(numbers);
  exit(0);
}
