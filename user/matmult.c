#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"


int A[4][4] = { {1, 2, 3, 4}, {1, 2, 3, 4}, {1, 2, 3, 4}, {1, 2, 3, 4} };
int B[4][4] = { {1, 0, 0, 0}, {0, 2, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1} };
int C[4][4];

int int_log2(unsigned int x) {
    int log = 0;
    while (x >>= 1) { 
        log++;
    }
    return log;
}


int binary2int(int id [], int size) {
   int conv_int = 0;
   for (int i = 0; i < size; i++) {
      conv_int += id[i] << i;
   }
   return conv_int;
}

void printrow(int col [], int size) {
   for(int j = 0; j<size; j++) {
      printf("%d ", col[j]);
   }
   printf("\n");
}


int main(int argc, char *argv[]) {

   int rows_col = sizeof(A[0])/sizeof(A[0][0]);

   //# of forks(), assuming square matrix (powers of 2)
   const int n = int_log2(rows_col);

   //id array to identify processes, max forks = 5, max process = 2^5
   int id [5] = {0, 0, 0, 0, 0};

   //pipe so everyone shares it
   int p [2];
   pipe(p);

   //generate all needed process now
   for(int i=0; i < n; i++) {
      if (fork() > 0)   id[i] = 1;  
      else id[i] = 0;
   }
   //every process has its binary id corresponding to a row in A
   int row = binary2int(id, n);
   
   //compute dot product
   for(int i=0; i<rows_col; i++) {
      int c_row_j = 0;
      for (int j=0; j<rows_col; j++) {
         c_row_j += A[row][j] * B[j][i];
      }
      C[row][i] = c_row_j;
   }

   //pipe all results to 1st parent = highest row number
   //set up pipe to parent
   if (row == rows_col-1) { //parent

      close(p[1]);   //close pipe write end
      close(0);      //close stdin
      dup(p[0]);     //duplicare pipe read to lowest fd (0)

   } else { //all childs
      close(p[0]);   //close pipe read end
   }

   //loop through all rows
   for (int r=0; r<rows_col-1; r++) {           //start from row 0 process, go up
      if (row != r) {
         wait(0);                               //all other processes wait
      } else {
         write(p[1], C[row], sizeof(C[row]));   //write to pipe then close
         close(p[1]);
         exit(0);
      }
      if(row == rows_col-1) {
         read(0, C[r], sizeof(C[row]));
      }
   }

   for (int i = 0; i<rows_col; i++) {
      for(int j = 0; j<rows_col; j++) {
         printf("%d ", C[i][j]);
      }
      printf("\n");
   }

   exit(0);
}