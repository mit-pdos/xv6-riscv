#include "kernel/types.h"
#include "user/user.h"

// Тест вызова sys_add
int main(int argc, char *argv[]) {
    // Копипаста b решения
    const int BUF_SIZE = 20;
    char buffer[BUF_SIZE];

    // Читаем строку в буфер
    if (!gets(buffer, BUF_SIZE)) {
        printf("Invalid arguments!\n");
        exit(1);
    }

    // Бежим по прочитанной строке, ищем пробел-разделитель
    int space_ind = 0;
    while (space_ind < BUF_SIZE && buffer[++space_ind] != ' ');

    if (space_ind == BUF_SIZE) {
        printf("Not enough arguments!\n");
        exit(1);
    }

    // Заведем наши будущие числа, и будем в них писать
    char a[space_ind], b[BUF_SIZE - space_ind];

    for (int i = 0; i < space_ind; i++) {
        a[i] = buffer[i];
    }

    // Сдвинем метку разделителя направо на 1 и пойдем изучать второе число
    for (int i = space_ind++; buffer[i] != '\0'; i++) {
        b[i - space_ind] = buffer[i];
    }
    // ---------------

    add(atoi(a), atoi(b));
    exit(0);
}