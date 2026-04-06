#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// ---------- Prime ----------
int is_prime(int n) {
  if (n < 2) return 0;
  for (int i = 2; i * i <= n; i++) {
    if (n % i == 0) return 0;
  }
  return 1;
}

void prime_bench(int limit) {
  int count = 0;
  for (int i = 2; i < limit; i++) {
    if (is_prime(i)) count++;
  }
  printf("Primes up to %d: %d\n", limit, count);
}

// ---------- Fibonacci ----------
int fib(int n) {
  if (n <= 1) return n;
  return fib(n - 1) + fib(n - 2);
}

void fib_bench(int n) {
  int result = fib(n);
  printf("Fib(%d) = %d\n", n, result);
}

// ---------- Matrix ----------
#define SIZE 50

void matrix_bench() {
  int A[SIZE][SIZE], B[SIZE][SIZE], C[SIZE][SIZE];

  for (int i = 0; i < SIZE; i++) {
    for (int j = 0; j < SIZE; j++) {
      A[i][j] = i + j;
      B[i][j] = i * j;
      C[i][j] = 0;
    }
  }

  for (int i = 0; i < SIZE; i++) {
    for (int j = 0; j < SIZE; j++) {
      for (int k = 0; k < SIZE; k++) {
        C[i][j] += A[i][k] * B[k][j];
      }
    }
  }

  printf("Matrix multiplication done\n");
}

// ---------- Main ----------
int main(int argc, char *argv[]) {

  if (argc < 2) {
    printf("Usage: cpubench [prime|fib|matrix]\n");
    exit(0);
  }

  int start = uptime();

  if (strcmp(argv[1], "prime") == 0) {
    prime_bench(200000);
  } 
  else if (strcmp(argv[1], "fib") == 0) {
    fib_bench(35);
  } 
  else if (strcmp(argv[1], "matrix") == 0) {
    matrix_bench();
  } 
  else {
    printf("Unknown benchmark\n");
  }

  int end = uptime();

  printf("Execution time: %d ticks\n", end - start);

  exit(0);
}