// init: The initial user-level program

#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/spinlock.h"
#include "kernel/sleeplock.h"
#include "kernel/fs.h"
#include "kernel/file.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "user/set_password.h"
#include "user/md5.h"

#define MAX_BUFFER_SIZE 100
#define HASH_LENGTH 32 

char *argv[] = { "sh", 0 };

void login() { //パスワードの入力と、照合

  int i, j;
  char input_user[MAX_BUFFER_SIZE]= {};
  char input_password[MAX_BUFFER_SIZE]={}; 
  char user_passPair[MAX_BUFFER_SIZE]= {};
  char salt[] = {"00000000000000000\n"};

  

  // open passwords file
  int fd = open("Passwords", O_RDONLY);
  

  // prompt user for password
  write(1, "Enter Username : ", 18);
  gets(input_user, MAX_BUFFER_SIZE);


  input_user[strlen(input_user)-1] = 0; //input_userの語尾の改行を消す。


  while(read(fd, user_passPair, MAX_BUFFER_SIZE)){


    char preserved_user[MAX_BUFFER_SIZE] = {};
    char preserved_password[MAX_BUFFER_SIZE] ={};
    
    //Passwordsファイルからuserとpasswordを抽出。
    for(i = 0; user_passPair[i] != ':'; i++){
      preserved_user[i] = user_passPair[i];
    }
    
    for(j = 0; user_passPair[j+i+1] != 0; j++){//ハッシュ関数の0は'0'なのでOK
      preserved_password[j] = user_passPair[j+i+1];
    }
    
    if(strcmp(input_user, preserved_user) == 0){

      write(1, "Enter Password : ", 18);
      gets(input_password, MAX_BUFFER_SIZE);

      //文字列にソルトを追加
      for(i = 0; i<strlen(salt); i++){
        input_password[strlen(input_password)-1 + i] = salt[i];
      }


      char password_hash[33] = {};
      getmd5(input_password, strlen(input_password), password_hash);
      password_hash[32] = '\n'; //語尾を改行にする理由は、write(password_hash)を行い、user_passが改行されて格納されたいから。

      while(strcmp(preserved_password, password_hash) != 0) { // incorrect password
        write(1, "Incorrect Password.\nPlease enter correct Password : ", 53);
        gets(input_password, MAX_BUFFER_SIZE);
        input_password[strlen(input_password) -1] = 0;
        getmd5(input_password, strlen(input_password), password_hash);
        password_hash[32] = '\n';
      }

      if (strcmp(preserved_password, password_hash) == 0) { // correct password
        write(1, "Logging in...\n\n", 16); 
      }
      close(fd);
      return;
    }
  }
  printf("You Are Not Registered\n");
  login();
}



int
main(void)
{
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
    mknod("console", CONSOLE, 0);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  dup(0);  // stderr

  // password
  int fd = open("Passwords", O_RDWR);
  if (fd < 0) { // no password
    close(fd);
    write(1, "No Password set.\nPlease set your Password\n", 43);
    fd = open("Passwords", O_CREATE|O_RDWR);
    setPassword(fd);
  }


  for(;;){
    login();
    printf("init: starting sh\n");
    pid = fork();
    if(pid < 0){
      printf("init: fork failed\n");
      exit(1);
    }
    if(pid == 0){
      exec("sh", argv);
      printf("init: exec sh failed\n");
      exit(1);
    }

    for(;;){
      // this call to wait() returns if the shell exits,
      // or if a parentless process exits.
      wpid = wait((int *) 0);
      if(wpid == pid){
        // the shell exited; restart it.
        break;
      } else if(wpid < 0){
        printf("init: wait returned an error\n");
        exit(1);
      } else {
        // it was a parentless process; do nothing.
      }
    }
  }

}