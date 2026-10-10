#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

static void
barrier(int child, int parent_to_child[2], int child_to_parent[2])
{
  char byte = 'x';

  if(child){
    if(write(child_to_parent[1], &byte, 1) != 1 ||
       read(parent_to_child[0], &byte, 1) != 1){
      fprintf(2, "mutextest: barrier failed\n");
      exit(1);
    }
  } else {
    if(read(child_to_parent[0], &byte, 1) != 1 ||
       write(parent_to_child[1], &byte, 1) != 1){
      fprintf(2, "mutextest: barrier failed\n");
      exit(1);
    }
  }
}

static void
print_arguments(int mutex_fd, int synchronized, int argc, char **argv)
{
  int pid = getpid();

  for(int i = 1; i < argc; i++){
    for(int j = 0; argv[i][j] != 0; j++){
      if(synchronized && mutex_lock(mutex_fd) < 0){
        fprintf(2, "mutextest: mutex_lock failed for pid %d\n", pid);
        exit(1);
      }

      printf("%d: arg %d, char '%c'\n", pid, i, argv[i][j]);

      if(synchronized && mutex_unlock(mutex_fd) < 0){
        fprintf(2, "mutextest: mutex_unlock failed for pid %d\n", pid);
        exit(1);
      }
    }
  }
}

static void
check_file_operations(int mutex_fd)
{
  struct stat st;
  char byte = 'x';
  int read_result = read(mutex_fd, &byte, 1);
  int write_result = write(mutex_fd, &byte, 1);
  int stat_result = fstat(mutex_fd, &st);

  printf("read(mutex) = %d, expected -1\n", read_result);
  printf("write(mutex) = %d, expected -1\n", write_result);
  printf("fstat(mutex) = %d, expected -1\n", stat_result);
}

int
main(int argc, char **argv)
{
  int parent_to_child[2];
  int child_to_parent[2];

  if(argc < 2){
    fprintf(2, "usage: mutextest arguments...\n");
    exit(1);
  }

  int mutex_fd = mutex();
  if(mutex_fd < 0){
    fprintf(2, "mutextest: mutex creation failed\n");
    exit(1);
  }

  if(pipe(parent_to_child) < 0 || pipe(child_to_parent) < 0){
    fprintf(2, "mutextest: pipe creation failed\n");
    close(mutex_fd);
    exit(1);
  }

  printf("without mutex \n");

  int pid = fork();
  if(pid < 0){
    fprintf(2, "mutextest: fork failed\n");
    close(mutex_fd);
    exit(1);
  }

  int child = pid == 0;
  if(child){
    close(parent_to_child[1]);
    close(child_to_parent[0]);
  } else {
    close(parent_to_child[0]);
    close(child_to_parent[1]);
  }

  barrier(child, parent_to_child, child_to_parent);
  print_arguments(mutex_fd, 0, argc, argv);

  barrier(child, parent_to_child, child_to_parent);
  if(!child)
    printf("with mutex\n");
  barrier(child, parent_to_child, child_to_parent);

  print_arguments(mutex_fd, 1, argc, argv);
  barrier(child, parent_to_child, child_to_parent);

  if(child){
    close(parent_to_child[0]);
    close(child_to_parent[1]);
    close(mutex_fd);
    exit(0);
  }

  close(parent_to_child[1]);
  close(child_to_parent[0]);
  wait(0);

  printf("invalid file operations\n");
  check_file_operations(mutex_fd);

  close(mutex_fd);
  exit(0);
}
