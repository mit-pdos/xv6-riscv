#include "kernel/types.h"
#include "user/user.h"

#define O_RDONLY 0

int main(int argc, char *argv[]){
    int file = open(argv[1], O_RDONLY);

    if(file < 0){
        fprintf(2, "sixfive: cannot open %s\n", argv[1]);
        return -1;
    }

    char buffer[512];

    while(read(file, buffer, 512) > 0){
        int i = 0;

        // printf("%s\n", buffer);
        while(buffer[i] != '\0'){
            char c = buffer[i];
            char num[512];
            int j=0;

            int convert = 1;
            if(c == ' ' || c == '/' || c == ',' || c == '\t'
            || c == '\r' || c == '\n' || c == '-'){
                i++;
                continue;
            }
            else {
                convert = 1;
                while(buffer[i] != '\0' && buffer[i] != ' ' && buffer[i] != '/' && buffer[i] != ',' && buffer[i] != '\t'
                    && buffer[i] != '\r' && buffer[i] != '\n' && buffer[i] != '-'){
                        if(buffer[i] < '0' ||  buffer[i] > '9'){
                            convert = 0;
                        }
                        
                        num[j++] = buffer[i];
                        i++;
                        // printf("%s\n", num);
                    }
                }
                    
            int number = atoi(num);

            if(convert == 1 && number != 0 && (number%6 == 0 || number%5 == 0)){
                printf("%d \n", number);
            }
        }
    }

    close(file);
    return 0;
}