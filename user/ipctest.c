// user/ipctest.c
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define EMPTY 0
#define FULL 1
#define MUTEX 2

int main()
{
  printf("IPC test starting\n");

  void* shm = shm_get(123);
  if(shm == 0){
    printf("shm_get failed\n");
    exit(1);
  }
  printf("Parent shared memory acquired at VA: %p\n", shm);
  
  int *shared_counter = (int*)shm;
  *shared_counter = 0;

  if(sem_init(EMPTY, 1) < 0 || sem_init(FULL, 0) < 0 || sem_init(MUTEX, 1) < 0){
    printf("sem_init failed\n");
    exit(1);
  }

  int pid = fork();

  if(pid < 0){
    printf("fork failed\n");
    exit(1);
  }

  if(pid == 0) { // Child process (Consumer)
    void* child_shm = shm_get(123);
    if(child_shm == 0){
      printf("child shm_get failed\n");
      exit(1);
    }
    shared_counter = (int*)child_shm; 
    printf("Child shared memory re-acquired at VA: %p\n", child_shm);

    for(int i = 0; i < 5; i++){
      sem_down(FULL);
      
      sem_down(MUTEX);
      printf("Consumer: read %d\n", *shared_counter);
      sem_up(MUTEX);
      
      sem_up(EMPTY);
      sleep(10);
    }
    
    // Child cleans up its own mapping
    shm_close(123);
    exit(0);
  } else { // Parent process (Producer)
    for(int i = 0; i < 5; i++){
      sem_down(EMPTY);
      
      sem_down(MUTEX);
      *shared_counter = i + 1;
      printf("Producer: wrote %d\n", *shared_counter);
      sem_up(MUTEX);

      sem_up(FULL);
      sleep(5);
    }
    wait(0);
    
    // Parent cleans up its own mapping
    shm_close(123);
  }

  printf("IPC test finished\n");
  exit(0);
}