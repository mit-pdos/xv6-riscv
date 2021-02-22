#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"


int checktype(char *path){
        struct stat st;
        int type = 0; /* 1: file, 2: directory */

        if(stat(path, &st) < 0){
                fprintf(2, "find: cannot stat %s\n", path);
                return 0;
        }
        
        switch(st.type){
                case T_FILE:
                        type = T_FILE;
                        break;
                case T_DIR:
                        type = T_DIR;
                        break;
        }
        
        return type;
}

void find(char *path, char *fname){
        char buf[512], *p;
        int fd;
        struct dirent de;
        struct stat st;

        if((fd = open(path, 0)) < 0){
                fprintf(2, "find: cannot open %s\n", path);
                return;
        }
        
        if(strlen(path) + 1 + DIRSIZ + 1 > sizeof(buf)){
                printf("ls: path too long\n");
                return;
        } 
                
        strcpy(buf, path);
        p = buf + strlen(buf);
        *p++ = '/';

        while(read(fd, &de, sizeof(de)) == sizeof(de)){
                if(de.inum == 0) continue;
                
                if(strcmp(de.name, fname) == 0){
                        memmove(p, de.name, DIRSIZ);
                        p[DIRSIZ] = '\0';
                        if(stat(buf, &st) < 0){
                                printf("find: cannot stat %s\n", buf);
                                continue;
                        }
                        printf("%s\n", buf);
                }
        }
        close(fd);
         
        if((fd = open(path, 0)) < 0){
                fprintf(2, "find: cannot open %s\n", path);
        }
        
        while(read(fd, &de, sizeof(de)) == sizeof(de)){
                if(de.inum == 0) continue;
                
                memmove(p, de.name, DIRSIZ);
               
                p[DIRSIZ] = 0;
                if(stat(buf, &st) < 0){
                        printf("find: cannot stat %s\n", buf);
                        continue;
                }
               
                if(checktype(buf) == T_DIR && strcmp(".", de.name) != 0 
                && strcmp("..", de.name) != 0){
                        find(buf, fname);
                }
        }
        close(fd);
}

int main(int argc, char *argv[]){
        
        if(argc < 3){
                fprintf(2, "Error: there exists some missing argument...\n");
                exit(1);
        }
 
        if(checktype(argv[1]) == T_DIR){
                find(argv[1], argv[2]);
        }

        exit(0);
}
