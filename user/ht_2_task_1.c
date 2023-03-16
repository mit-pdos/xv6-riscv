#define STDOUT 1
#define STDERR 2
#define SYS_GIVE_LOCK 0
#define SYS_FREE_LOCK 1
#define SYS_ACQUIRE_LOCK 2
#define SYS_RELEASE_LOCK 3

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int safe_sleeplock_request_processing(int type, int lock_id){
   int result = sleeplock_request_processing(type, lock_id);
   if (result < 0) {
      fprintf(STDERR, "Critical error\n");
      exit(1);
   }
   return result;
}

int safe_read(int fd, char* buffer, int to_read){
   short bytes_amount_read = read(fd, buffer, to_read);
   if (bytes_amount_read < 0) {
      write(2, "Error in read", 14);
      exit(-1);
   }
   return bytes_amount_read;
}

int safe_write(int fd, char* buffer, int to_write){
   short bytes_amount_write = write(fd, buffer, to_write);
   if (bytes_amount_write < 0) {
      write(2, "Error in write", 15);
      exit(-1);
   }
      return bytes_amount_write;
}

int main(int argc, char **argv)
{
  if (argc < 2) {
    fprintf(STDERR, "missing argument\n");
    exit(1);
  }

   int p_par[2];
   int p_ch[2];

   pipe(p_par);
   pipe(p_ch);

   int current_lock = safe_sleeplock_request_processing(SYS_GIVE_LOCK, 0);

   if(fork() == 0) {
      close(p_par[1]);
      close(p_ch[0]);

      int c_pid = getpid();
      char elem_c;
      while (safe_read(p_par[0], &elem_c, 1) == 1){
         safe_sleeplock_request_processing(SYS_ACQUIRE_LOCK, current_lock);
         fprintf(STDOUT, "%d: recived %c\n", c_pid, elem_c);
         safe_write(p_ch[1], &elem_c, 1);     
         safe_sleeplock_request_processing(SYS_RELEASE_LOCK, current_lock);
      }   

      close(p_par[0]);
      close(p_ch[1]);
   } else {
      close(p_par[0]);
      close(p_ch[1]);    

      char* elem_p = argv[1];
      while(*elem_p != 0){
         safe_write(p_par[1], elem_p, 1);         
         elem_p += 1;
      }

      close(p_par[1]);
      
      int c_pid = getpid();
      while (safe_read(p_ch[0], elem_p, 1) == 1) {
         safe_sleeplock_request_processing(SYS_ACQUIRE_LOCK, current_lock);
         fprintf(STDOUT, "%d: recived %c\n", c_pid, *elem_p);   
         safe_sleeplock_request_processing(SYS_RELEASE_LOCK, current_lock);
      }
      close(p_ch[0]);
      wait((int *) 0);

      safe_sleeplock_request_processing(SYS_FREE_LOCK, current_lock);      
   }
   exit(0);
}