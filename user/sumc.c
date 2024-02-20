#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"


int main() {
    const int BUF_SIZE = 20;
    char c;
    int a, b;

    // Я решил сэкономить на памяти: будем работать с одним буфером аккуратненько
    char buffer[BUF_SIZE];
    // TODO: ВЫВЕДИ В СТДЭРР ЛЕНИВЕЦ
    // ПЕРЕПОЛНЕНИЕ ТОЖЕ ОБРАБОТАЙ
    int i = 0;
    // Первый чек на нормальный рид, второй - на переполнение буфера
    while (read(0, &c, 1) > 0 && i < sizeof buffer) {
        if (c == '\n' || c == '\r' || c == ' ') break;
        buffer[i++] = c;
    }
    buffer[i] = '\0';
    a = atoi(buffer);

    // Если все, что мы прочитали - это только одно число
    if (c != ' ') {
        printf("Not enough / invalid arguments!\n");
        exit(1);
    }

    // Знаю, что прям конкретная копипаста, но лень запихивать в отдельный метод и мучиться с этими указателями... Может потом покопаю
    i = 0;
    while (read(0, &c, 1) > 0 && i < sizeof buffer) {
        if (c == '\n' || c == '\r') break;
        buffer[i++] = c;
    }
    buffer[i] = '\0';
    b = atoi(buffer);
    // -------------------

    printf("%d\n", a + b);
    exit(0);
}