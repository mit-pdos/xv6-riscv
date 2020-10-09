#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include "kernel/termios.h"

struct termios termios;
char ch;

// term
void init_term(){
  memset(&termios, 0, sizeof(termios));
  printf("init_term1 %p\nand %d\n", &termios, termios.c_lflag);
  tcgetattr(0, &termios);
  printf("init_term2 %p\nand %d\n", &termios, termios.c_lflag);
  termios.c_lflag &= ~ICANON;
  printf("init_term3 %p\nand %d\n", &termios, termios.c_lflag);
  tcsetattr(0, TCSANOW, &termios);
  printf("init_term4 %p\nand %d\n", &termios, termios.c_lflag);
}
void restore_term(){
  printf("restore_term1 %p\nand %d\n", &termios, termios.c_lflag);
  termios.c_lflag |= ICANON;
  printf("restore_term2 %p\nand %d\n", &termios, termios.c_lflag);
  tcsetattr(0, TCSANOW, &termios);
  printf("restore_term3 %p\nand %d\n", &termios, termios.c_lflag);
}

// main
int main(int argc, char *argv[]){

  printf("Starting tty. test\n");

  init_term();

//   char c;

//   while(1){
//     read(0, &c, 1);
//     if(ch == 'q') break;
//     write(1, &c, 1);
//   }

  restore_term();

  exit(0);
}
