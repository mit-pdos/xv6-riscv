#include <sys/types.h>
 #include <stdio.h>
 #include <unistd.h>
 int value = 5;
 int main()
 {
 pid_t pid;
 printf("\nPre-Fork %d\n\n", pid);
 pid = fork();
 printf("\nPost-Fork %d\n\n", pid);
 if (pid == 0) { /* child process */
    printf("\nChild %d\n\n", pid);    
    printf("CHILD: value = %d",value); /* LINE A */
 value += 15;
 return 0;
 }
 else if (pid > 0) { /* parent process
     */
//  wait(NULL);
printf("\nParent %d\n\n", pid);    
 printf("PARENT: value = %d",value); /* LINE A */
 return 0;
 }
 }