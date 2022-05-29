#include "kernel/types.h"
#include "user/user.h"

#define LIMIT 1000
#define KEY 20
#define KEY2 26

int main(void) {

  int semid, i = 0;

  /*checking for non process sema access*/
  int chk = semup(20);
  if (chk < 0)
    printf("Testing non adquired semaphore (up): OK!\n");
  else
    printf("Testing non adquired semaphore (up): FAILED.\n");

  chk = semdown(20);
  if (chk < 0)
    printf("Testing non adquired semaphore (down): OK!\n");
  else
    printf("Testing non adquired semaphore (down): FAILED.\n");

  /*checking for close non requested semaphore*/
  chk = semclose(8);
  if (chk < 0)
    printf("Testing semclose: OK!.\n");
  else
    printf("Testing semclose: FAILED!.\n");

  /*checking for getting all the resources*/
  int countsem = 0, it;
  chk = 0;
  for (it = 0; it < LIMIT && chk >= 0; it++, countsem++) {
    chk = semget(KEY, 4);
    printf("semget: %d\n", chk);
  }
  printf("Testing get all semaphores availables (%d availables?).\n",
         countsem - 1);

  /*checking for close: sem 0 was adquired*/
  chk = semclose(0);
  if (chk == 0)
    printf("Testing semclose sem 0: OK!.\n");
  else
    printf("Testing semclose sem 0: FAILED!.\n");

  /*checking for close: but not twice!*/
  chk = semclose(0);
  if (chk < 0)
    printf("Testing semclose sem 0 (second time): OK!.\n");
  else
    printf("Testing semclose sem 0 (second time): FAILED!.\n");

  /*cheching binary semaphore locking*/

  /*cheching n-ary semaphore*/

  /* We changed KEY to KEY2 because there was already a semaphore created using
   * KEY and value=4, and that caused semget to find that semaphore and change
   * the behavior with respect to value=2, allowing both children as well as the
   * parent process to enter the critical region.
   */
  semid = semget(KEY2, 2);

  if (fork() == 0) {
    /*
    ** semget(semid, -1); -- we think that instead of semid, the param should be
    ** KEY. Anyhow, given our
    ** implementation of semaphores, it's not necessary to get them again
    ** because we can use the parent's
    ** semid instead.
    */
    for (i = 0; i < 10; i++) {
      printf("1st child trying... \n");
      timeout(100000);
      /*
      ** In cases like these we added the if condition because it is important
      ** (given our implementation)
      ** to check the return value of semdown to verify that the process did
      ** indeed gain access to the
      ** critical region or not.
      */
      if (semdown(semid) == 0) {
        printf("1st child in critical region \n");
        timeout(100000);
        semup(semid);
        printf("1st child out \n");
      }
    }
    exit(0);
  }

  /*second child*/

  if (fork() == 0) {
    /*
    ** semget(semid, -1); -- we think that instead of semid, the param should be
    ** KEY. Anyhow, given our
    ** implementation of semaphores, it's not necessary to get them again
    ** because we can use the parent's
    ** semid instead.
    */
    for (i = 0; i < 10; i++) {
      printf("2nd child trying... \n");
      timeout(100000);
      if (semdown(semid) == 0) {
        printf("2nd child in critical region \n");
        timeout(100000);
        semup(semid);
        printf("2nd child out \n");
      }
    }
    exit(0);
  }

  /*Parent code*/
  for (i = 0; i < 10; i++) {
    printf("Parent trying... \n");
    timeout(100000);
    if (semdown(semid) == 0) {
      printf("Parent in critical region \n");
      timeout(100000);
      semup(semid);
      printf("Parent out \n");
    }
  }

  wait(0);
  wait(0);
  exit(0);
}
