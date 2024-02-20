#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
    char input[100];
    char *token1, *token2;
    int num1, num2;

        if (!gets(input, sizeof(input))) {
            fprintf(2, "Ошибка чтения ввода.\n");
            exit(1);
        }

        if (strchr(input, ' ') == input){
            token1 = strchr(input, ' ');
            token1++;
        }
        else {
            token1 = input;
        }
        if (!token1 ||( *token1 == '\n')) {
            fprintf(2, "Некорректный формат данных.\n");
            exit(1);
        }

        num1 = atoi(token1);

        token2 = strchr(token1, ' ');
        token2++;
        if (!token2 ||( *token2 == '\n')) {
            fprintf(2, "Некорректный формат данных. Отсутствует второе число.\n");
            exit(1);
        }


        num2 = atoi(token2);
    if (!num1 || !num2) {
        fprintf(2, "Некорректный формат данных.\n");
        exit(1);
    }
        int sum =  num1 + num2;
        printf("%d\n", sum);

    exit(0);
}