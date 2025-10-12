#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"

char*
fmtname(char *p)
{
  static char buf[DIRSIZ+1];

  // Return blank-padded name.
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  buf[sizeof(buf)-1] = '\0';
  return buf;
}

void
ls(char *path)
{
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, O_RDONLY)) < 0){
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  if (st.type == T_FILE || st.type == T_DEVICE){
    printf("%s %d %d %d\n", fmtname(path), st.type, st.ino, (int) st.size);
  } else {
    if (chdir(path) < 0){
      printf("ls: cannot cd %s\n", path);
      close(fd);
      return;
    }

    while(read(fd, &de, sizeof(de)) == sizeof(de)){
      if(de.inum == 0)
        continue;
      if(stat(de.name, &st) < 0){
        printf("ls: cannot stat %s\n", de.name);
        continue;
      }
      printf("%s %d %d %d\n", fmtname(de.name), st.type, st.ino, (int) st.size);
    }
  }
  close(fd);
}

int
main(int argc, char *argv[])
{
  int i, pid;

  if(argc < 2){
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++){
    pid = fork();
    if(pid < 0)
      break;
    if (pid == 0){
      ls(argv[i]);
      exit(0);
    } else
      wait(0);
  }
  exit(0);
}
