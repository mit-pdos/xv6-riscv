# include "kernel/types.h"
#include "user/user.h"

int main(void) {
  int size = 1, n = 0;
  dump_heap_structure();
  int *a = (int*)malloc(size * sizeof(int));
  if (!a) { printf("malloc failed\n"); exit(1); }

  for (int i = 0; i < 200; i++) {
    if (n == size) {
      dump_heap_structure();
      size *= 2;
      int *na = (int*)malloc(size * sizeof(int));
      if (!na) { printf("realloc failed\n"); exit(1); }
      for (int j = 0; j < n; j++) na[j] = a[j];
      free(a);
      a = na;
    }
    a[n++] = i;
  }

  int sum = 0;
  for (int i = 0; i < n; i++) sum += a[i];
  int expected = n * (n - 1) / 2;
  if (sum != expected) {
    printf("Fail: sum=%d, expected=%d\n", sum, expected);
    free(a);
    exit(1);
  }

  printf("OK: n=%d, sum=%d\n", n, sum);
  free(a);
  exit(0); 

  free(a);
  exit(0);
}