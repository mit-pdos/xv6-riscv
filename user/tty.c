#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include "kernel/termios.h"

struct termios saved;
struct termios termios;
char ch;

// term
void init_term(){
  memset(&termios, 0, sizeof(struct termios));
  memset(&saved, 0, sizeof(struct termios));
  tcgetattr(0, &saved);
  printf("init_term2 %p\nand %d\n", &saved, saved.c_lflag);
  termios.c_lflag &= ~ICANON;
  termios.c_lflag &= ~ECHO;
  printf("init_term3 %p\nand %d\n", &termios, termios.c_lflag);
  tcsetattr(0, TCSANOW, &termios);
}

void restore_term(){
  printf("restore_term2 %p\nand %d\n", &saved, saved.c_lflag);
  tcsetattr(0, TCSANOW, &saved);
  printf("restore_term3 %p\nand %d\n", &termios, termios.c_lflag);
}

// main
int main(int argc, char *argv[]){

  printf("Starting tty. test\n");

  init_term();

  char c;
  char fence = '|';
  
  while(1){
    read(0, &c, 1);
    if(c == 'q') break;
    write(1, &fence, 1);
    write(1, &c, 1);
  }

  restore_term();

  exit(0);
}
