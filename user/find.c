#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
// assuming find takes in three arguments, find {path where it starts searching} {name of the file to find}

char* get_file_name(char* path){
    char *p;

    for(p=path+strlen(path);p >= path && *p != '/';p--);
    p++;
    return p;
}

void find (char *path, char *target_file_name){
    char buf[512], *p; //we need the buf as in the while read, we are changing the complete path to visit the child directory
    int fd, ret;
    struct stat st;
    struct dirent de;
    
    if((fd = open(path,0)) < 0){
        fprintf(2,"find: cannot open %s\n",path);
        return;
    }

    if (fstat(fd,&st) < 0){
        fprintf(2,"find: cannot stat %s\n",path);
        close(fd);
        return;
    }

    //s.type 1 T_DIR; 2 T_FILE; 3 T_DEVICE. this has been defined in stat.h
    switch(st.type){
        case T_DEVICE:
        case T_FILE:
            if ((ret = strcmp(get_file_name(path),target_file_name)) == 0){
                printf("%s\n",path);
            }
            break;
        case T_DIR:
            strcpy(buf,path);
            p = buf + strlen(buf);
            *p++ = '/';
            while (read(fd, &de, sizeof(de)) == sizeof(de)){
                if (strcmp(de.name, ".") == 0 || strcmp(de.name, "..") == 0 || de.inum == 0) continue; //do not recurse
                memmove(p,de.name,strlen(de.name));
                p[strlen(de.name)] = 0;//终止符号
                // printf("In Dir type%s\n",buf);
                find(buf,target_file_name); //recurse to next level
            }
            break;
    }
    close(fd);
}



int main(int argc, char * argv[]){
    if (argc != 3){
        printf("There shall be 3 arguments\n");
        exit(1);
    };
    find(argv[1],argv[2]);      
    return 0;
}
