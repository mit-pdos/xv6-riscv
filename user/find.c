#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "kernel/param.h"

int has_exec = 0;
char **exec_argv = 0;
int exec_argc = 0;

void run_exec(char *path) {
  int pid = fork();
  if(pid < 0) {
    fprintf(2, "find: fork failed\n");
    exit(1);
  }
  if(pid == 0) {
    char *new_argv[MAXARG];
    if(exec_argc + 1 >= MAXARG) {
      fprintf(2, "find: too many arguments for -exec\n");
      exit(1);
    }
    for(int i = 0; i < exec_argc; i++) {
      new_argv[i] = exec_argv[i];
    }
    new_argv[exec_argc] = path;
    new_argv[exec_argc + 1] = 0;

    exec(new_argv[0], new_argv);
    fprintf(2, "find: exec %s failed\n", new_argv[0]);
    exit(1);
  } else {
    wait(0);
  }
}

void find(char* path, char* pattern) {
  char buf[512], *p;
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

	switch(st.type) {
		case T_DEVICE:
		case T_FILE: {
			char *f;
			for(f = path + strlen(path); f >= path && *f != '/'; f--)
				;
			f++; 

			if(strcmp(f, pattern) == 0) {
        if(has_exec) run_exec(path);
        else printf("%s\n", path);
			}
			break;
		}
            
		case T_DIR:
			if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
				printf("find: path too long\n"); 
				break;
			}
			strcpy(buf, path);
			p = buf+strlen(buf);
			*p++ = '/';
			while(read(fd, &de, sizeof(de)) == sizeof(de)){
				if(de.inum == 0)
					continue;
				memmove(p, de.name, DIRSIZ);
				p[DIRSIZ] = 0;
				if(strcmp(p, ".") == 0 || strcmp(p, "..") == 0)
    				continue;

				find(buf, pattern); 
			}
			break;
	}
	close(fd);
}

int
main(int argc, char *argv[])
{
  if(argc < 3) {
    if(argc == 1 || strcmp(argv[1], ".") == 0) printf("find what?\n");
    exit(1);
  }
  // 解析并捕获 -exec 参数及其后的命令
  for (int i = 3; i < argc; i++) {
    if (strcmp(argv[i], "-exec") == 0) {
      if (i + 1 >= argc) {
        fprintf(2, "find: -exec requires a command\n");
        exit(1);
      }
      has_exec = 1;
      exec_argv = &argv[i + 1];
      exec_argc = argc - (i + 1);
      break;
    }
  }

  find(argv[1], argv[2]);
  exit(0);
}