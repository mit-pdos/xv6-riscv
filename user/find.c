#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"

char* homeStrCat(char* s1, char* s2) {
  int l1 = strlen(s1);
  int l2 = strlen(s2);
  int ln = l1+l2;
  char* newStr = (char*)malloc(ln+2);

  for (int i=0; i<ln+1; i++) {
    if (i < l1) {
      newStr[i] = s1[i];
    } else if (i==l1) {
      newStr[i] = '/';
    } else {
      newStr[i] = s2[i-(l1+1)];
    }
  }
  newStr[ln+1] = '\0';
  return newStr;
}

char* getName(char* path) {
  int path_len = strlen(path);
  int file_len = 0;
  int i = 0;
  int i2 = 0;

  i = path_len-1;
  while (path[i] != '/' && &path[i] != path) {
    i--;
  }

  file_len = path_len - i;
  char* rt_file = (char*)malloc(file_len);
  
  i++;
  while (path[i] != '\0') {
    rt_file[i2] = path[i];
    i++;
    i2++;
  }
  rt_file[i2] = '\0';

  return rt_file;
}

void cmd_exec(char* path, char* argv[], int argc) {
  if (argc > 3 && !strcmp(argv[3], "-exec")) {
    int* status = 0;

    int n_argc = argc-4;
    char* n_argv[n_argc+2];

    for (int i=0; i<n_argc; i++) {
      n_argv[i] = argv[i+4];
    }
    n_argv[n_argc] = path;
    n_argv[n_argc+1] = '\0';

    if (fork()==0) {
      exec(n_argv[0], n_argv);
      exit(0);
    } else {
      wait(status);
    }
  } else {
    printf("%s\n", path);
  }
} 

void find(char* s, char* path, char* argv[], int argc) {
  int fd;
  struct stat st;
  
  if ((fd = open(path, O_RDONLY)) < 0) {
    fprintf(2, "Error: cannot open %s\n", path);
    return;
  }
  if (fstat(fd, &st) < 0) {
    fprintf(2, "Error: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch (st.type) {
    case T_DEVICE:
      
      close(fd);
      return;

    case T_FILE:

      char* file_name = getName(path);

      if (!strcmp(file_name, s)) {
        cmd_exec(path, argv, argc);
      }

      free(file_name);
      close(fd);
      return;

    case T_DIR:

      int c_fd;
      struct dirent e;
      char* dir_name = getName(path);
      if (!strcmp(dir_name, s)) {
        cmd_exec(path, argv, argc);        
      }
      free(dir_name);

      if ((c_fd = open(path, O_RDONLY)) < 0) {
        fprintf(2, "Error: cannot open %s\n", path);
        return;
      }
      
      while (read(c_fd, &e, sizeof(e)) == sizeof(e)) {
        char* curr_path;
        
        if (e.inum == 0) { continue; }
        
        if (strcmp(e.name, ".") && strcmp(e.name, "..")) {
          curr_path = homeStrCat(path, e.name);
          find(s, curr_path, argv, argc);
          free(curr_path);
        }
      }
      close(c_fd);
      close(fd);
      return;

    default:
      close(fd);
      return;
  }

}


int main(int argc, char* argv[]) {
  
  if (argc < 3) {
    fprintf(2, "Error, incorrect usage: find [start_path] [name]\n");
    fprintf(2, "Optional Usage: find [start_path] [name] -exec [command]\n");
    exit(1);

  } 

  find(argv[2], argv[1], argv, argc);
  exit(0);
}
