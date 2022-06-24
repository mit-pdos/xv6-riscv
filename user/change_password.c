#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"
#include "user/md5.h"

#define MAX_BUFFER_SIZE 100
#define HASH_LENGTH 32

int main(void){

  int i, j;
  char input_user[MAX_BUFFER_SIZE]= {};
  char input_password[MAX_BUFFER_SIZE]={};
  char user_passPair[MAX_BUFFER_SIZE]= {};
  char read_buf[MAX_BUFFER_SIZE] = {};
  int loop_count = 0;
  char newPassword[MAX_BUFFER_SIZE];
  char confirmedPassword[MAX_BUFFER_SIZE];
  char user_name[MAX_BUFFER_SIZE];
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

    //Passwordsファイルからuserとpassをそれぞれ抽出する。
    for(i = 0; user_passPair[i] != ':'; i++){
      preserved_user[i] = user_passPair[i];
    }
    
    for(j = 0; user_passPair[j+i+1] != 0; j++){ 
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
      password_hash[32] = '\n'; //語尾を改行にする理由は、write(password_hash)を行い、user_passが改行されて格納したいから。


      while(strcmp(preserved_password, password_hash) != 0) { // incorrect password
        write(1, "Incorrect Password.\nPlease enter correct Password : ", 53);
        gets(input_password, MAX_BUFFER_SIZE);
        //ソルト
        for(i = 0; i<strlen(salt); i++){
          input_password[strlen(input_password)-1 + i] = salt[i];
        }
        getmd5(input_password, strlen(input_password), password_hash);
        password_hash[32] = '\n';
      }

      if (strcmp(preserved_password, password_hash) == 0) { // correct password
        printf("Change Password\n");
        int fd = open("Passwords", O_RDWR);

        //既存のuser:passwordに新しいuser_passwordを上書きする。
        for(i = 0; i<loop_count; i++){
          read(fd, read_buf, MAX_BUFFER_SIZE);
        }

        
        // user名をもう一回求める。
        write(1, "Enter Your Username : ", 22);
        gets(user_name, MAX_BUFFER_SIZE);
        user_name[strlen(user_name)-1] = 0; //改行を消す

        // 新しいパスワードの入力
        write(1, "Enter New Password : ", 22);
        gets(newPassword, MAX_BUFFER_SIZE);
        write(1, "Enter Again : ", 15);
        gets(confirmedPassword, MAX_BUFFER_SIZE);

        // check that the two passwords match
        if (strcmp(newPassword, confirmedPassword) == 0) { // passwords match, proceed
          write(1, "You Can Change Password\n", 31);
          //ソルト
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

          exit(0);
          
        }
        else{
          printf("Password Is Not Same\n");
          exit(1);
        }
      }
    }
    loop_count++;
  }
  printf("user is not found\n");
  return 0;
}