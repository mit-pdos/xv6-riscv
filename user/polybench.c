#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define NI 40
#define NJ 50
#define NK 60
#define NL 70

static int A[NI][NK];
static int B[NK][NJ];
static int C[NJ][NL];
static int D[NI][NL];
static int tmp[NI][NJ];

static void
initialize(void)
{
  int i, j;

  for (i = 0; i < NI; i++) {
    for (j = 0; j < NK; j++)
      A[i][j] = (i * j) % 9 + 1;
    for (j = 0; j < NL; j++)
      D[i][j] = (i + j) % 9 + 1;
  }

  for (i = 0; i < NK; i++)
    for (j = 0; j < NJ; j++)
      B[i][j] = (i * j) % 9 + 1;

  for (i = 0; i < NJ; i++)
    for (j = 0; j < NL; j++)
      C[i][j] = (i * j) % 9 + 1;
}

static void
kernel_2mm(void)
{
  int i, j, k;

  for (i = 0; i < NI; i++) {
    for (j = 0; j < NJ; j++) {
      tmp[i][j] = 0;
      for (k = 0; k < NK; k++)
        tmp[i][j] += 3 * A[i][k] * B[k][j];
    }
  }

  for (i = 0; i < NI; i++) {
    for (j = 0; j < NL; j++) {
      D[i][j] *= 2;
      for (k = 0; k < NJ; k++)
        D[i][j] += tmp[i][k] * C[k][j];
    }
  }
}

int
main(void)
{
  int i, j;
  int start, elapsed;
  uint64 checksum;

  initialize();
  start = uptime();
  kernel_2mm();
  elapsed = uptime() - start;

  checksum = 0;
  for (i = 0; i < NI; i++)
    for (j = 0; j < NL; j++)
      checksum += D[i][j];

  printf("polybench 2mm: ticks=%d checksum=%lu\n", elapsed, checksum);
  exit(0);
}
