#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"

void find(char *path, char *name)
{
  char buf[512], *p; 
  int fd; 
  struct dirent de; 
  struct stat st; 
  
  if ((fd = open(path, O_RDONLY)) < 0) 
  {
    fprintf(2, "find: cannot open %s\n", path); 
    return; 
  }

  if (fstat(fd, &st) < 0) 
  {
    fprintf(2, "find: cannot stat %s\n", path); 
    close(fd); 
    return; 
  }

  if (st.type != T_DIR) 
  {
    fprintf(2, "find: %s is not a directory\n", path); 
    close(fd); 
    return; 
  }

  if (strlen(path) + 1 + DIRSIZ + 1 > sizeof(buf)) 
  {
    fprintf(2, "find: path too long\n"); 
    close(fd); 
    return; 
  }

  strcpy(buf, path); 
  p = buf + strlen(buf); 
  *p++ = '/';  
  while(read(fd, &de, sizeof(de)) == sizeof(de)) 
  {
    if (de.inum == 0)
      continue; 
    memmove(p, de.name, DIRSIZ); 
    p[DIRSIZ] = 0;  
    if (strcmp(de.name, name) == 0)
      printf("%s\n", buf); 
    if (strcmp(de.name, ".") == 0 || strcmp(de.name, "..") == 0)
      continue;
    if (stat(buf, &st) < 0)
    {
      fprintf(2, "find: cannot stat %s\n", buf); 
      continue; 
    }
    if (st.type == T_DIR)
      find(buf, name); 
  }
}

int main(int argc, char *argv[]) 
{
  if (argc != 3) 
  {
    fprintf(2, "Usage: find <path> <name>\n"); 
    exit(1); 
  }
  char *path = argv[1]; 
  char *name = argv[2]; 
  find(path, name); 
}