#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "user/md5.h"

#define MAX_BUFFER_SIZE 100
#define HASH_LENGTH 32





void setPassword(int fd) { //パスワードの設定


  char newPassword[MAX_BUFFER_SIZE];
  char confirmedPassword[MAX_BUFFER_SIZE];
  char user_name[MAX_BUFFER_SIZE];
  char salt[] = {"00000000000000000\n"};
  char buf[MAX_BUFFER_SIZE];
  int i;

  // user名を設定
  write(1, "Enter New Username : ", 22);
  gets(user_name, MAX_BUFFER_SIZE);
  user_name[strlen(user_name)-1] = 0; //改行を消す

  // prompt to enter password
  write(1, "Enter New Password : ", 22);
  gets(newPassword, MAX_BUFFER_SIZE);
  write(1, "Enter Again : ", 15);
  gets(confirmedPassword, MAX_BUFFER_SIZE);

  // check that the two passwords match
  if (strcmp(newPassword, confirmedPassword) == 0) { // passwords match, proceed
    write(1, "Password Is Set Successfully \n", 31);

    
    //文字列にソルトを追加
    for(i = 0; i<strlen(salt); i++){
       confirmedPassword[strlen(confirmedPassword)-1 + i] = salt[i];
    }

    char password_hash[33] ={};
    getmd5(confirmedPassword, strlen(confirmedPassword), password_hash);
    password_hash[32] = '\n';

    //ファイルにuser:passwordを格納(1行、max_buffer_size)
    write(fd, user_name , strlen(user_name));
    write(fd, ":", 1);
    write(fd, password_hash, MAX_BUFFER_SIZE - strlen(user_name)-1); // Passwordsファイルの一行の長さをMAX_BUFFER_SIZEにするため
    close(fd);

    int fd = open("Passwords", O_RDONLY);
    read(fd, buf, MAX_BUFFER_SIZE);
    close(fd);

    
    return;
  }

  else { // passwords do not match
    printf("Passwords Do Not match. Try Again.\n", 36);
    setPassword(fd);
  }

}
