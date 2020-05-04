#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

void find(char *dir, char*filename)
{
  struct stat st;
  int fd;
  
  if((fd = open(dir, 0)) < 0) {
    fprintf(2, "find: cannot open %s\n", dir);
    return;
  }

  if(fstat(fd, &st) < 0) {
    fprintf(2, "find: cannot stat %s\n", dir);
    close(fd);
    return;
  }

  char buf[255], *p;
  struct dirent de;
  switch(st.type) {
    case T_DIR:
      strcpy(buf, dir);
      p = buf+strlen(buf)-1;
      if(*p != '/')
        *(++p) = '/';
      p++;
      while(read(fd, &de, sizeof(de)) == sizeof(de)) {
        if(de.inum == 0 || strcmp(de.name, ".") == 0 || strcmp(de.name, "..") == 0)
          continue;
        memmove(p, de.name, DIRSIZ);
        p[DIRSIZ] = 0;
        if(stat(buf, &st) < 0) {
          fprintf(2, "find: cannot stat %s\n", buf);
          continue;
        }
        if(strcmp(de.name, filename) == 0) {
          printf("%s\n", buf);
        }
        if(st.type == T_DIR) {
          find(buf, filename);
        }
      }
      break;
  }
  close(fd);
}

int main(int argc, char **argv)
{
  if(argc == 2) {
    find(".", argv[1]);
  } else if(argc == 3) {
    find(argv[1], argv[2]);
  } else {
    fprintf(2, "usage: %s <dir> <filename>\n", argv[0]);
    exit(1);
  }
  exit(0);
}
