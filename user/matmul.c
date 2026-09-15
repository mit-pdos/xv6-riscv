/****************************************
 ***
 *** SQUARE Matrix Multiplication (serial)
 ***
 ****************************************/

#include "kernel/types.h"
#include "user/user.h"

#define ROWS    1000
#define COLUMNS 1000

int
main(int argc, char **argv)
{

  int i, j, k, iterations, ii;
  //int echo;
  int a[ROWS][COLUMNS];
  int b[ROWS][COLUMNS];
  int c[ROWS][COLUMNS];

  /* Start timing */
  int start_time = uptime();

  iterations = 1;
  if (argc == 2)
    iterations = atoi(argv[1]);

  for (ii = 0; ii < iterations; ii++) {
    /* Initialize */
    for (i = 0; i < ROWS; i++) {
      for (j = 0; j < COLUMNS; j++) {
        a[i][j] = 3;
        b[i][j] = 2;
        c[i][j] = 0;
      }
    }

    if (ROWS < 10) {
      /* TEST PRINT */
      for (i = 0; i < ROWS; i++) {
        for (j = 0; j < COLUMNS; j++) {
          printf("%d ", a[i][j]);
        }
        printf("\n");
      }

      for (i = 0; i < ROWS; i++) {
        for (j = 0; j < COLUMNS; j++) {
          printf("%d ", b[i][j]);
        }
        printf("\n");
      }

      for (i = 0; i < ROWS; i++) {
        for (j = 0; j < COLUMNS; j++) {
          printf("%d ", c[i][j]);
        }
        printf("\n");
      }
      printf("\n");
    }

    /* 
    Multiply Matrices 
    (SQUARE)
  */
    for (i = 0; i < ROWS; i++) {
      for (j = 0; j < COLUMNS; j++) {
        for (k = 0; k < COLUMNS; k++) {
          c[i][j] += a[i][k] * b[k][j];
        }
      }
    }

    /* PRINT RESULT */
    if (ROWS < 10) {
      for (i = 0; i < ROWS; i++) {
        for (j = 0; j < COLUMNS; j++) {
          printf("%d ", c[i][j]);
        }
        printf("\n");
      }
    }
  }
  /* Stop Timing */
  int end_time = uptime();

  /* Report Time */
  printf("Time: %d ticks\n", end_time - start_time);

  exit(0);
}
