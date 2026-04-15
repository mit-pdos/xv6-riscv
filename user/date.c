#include "kernel/types.h"
#include "user/user.h"

#define SEC_PER_MIN   60
#define SEC_PER_HOUR  3600
#define SEC_PER_DAY   86400

static int is_leap(int y) {
    return (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
}

static void print2(int x) {
    if(x < 10)
        printf("0");
    printf("%d", x);
}

static void print9(uint64 x) {
    uint64 div = 100000000;
    for(int i = 0; i < 9; i++){
        printf("%d", (int)(x / div));
        x %= div;
        div /= 10;
    }
}

int main(void) {
    uint64 t = rtc();

    uint64 sec = t / 1000000000;
    uint64 nsec = t % 1000000000;

    uint64 days = sec / SEC_PER_DAY;
    uint64 day_sec = sec % SEC_PER_DAY;

    int hour = day_sec / SEC_PER_HOUR;
    int min  = (day_sec % SEC_PER_HOUR) / SEC_PER_MIN;
    int sec2 = day_sec % SEC_PER_MIN;

    int year = 1970;

    while(1){
        int dy = is_leap(year) ? 366 : 365;
        if(days >= dy){
            days -= dy;
            year++;
        } else {
            break;
        }
    }

    int mdays[] = {
        31,28,31,30,31,30,
        31,31,30,31,30,31
    };

    int month = 0;

    for(int i = 0; i < 12; i++){
        int dim = mdays[i];

        if(i == 1 && is_leap(year))
            dim = 29;

        if(days >= dim){
            days -= dim;
            month++;
        } else {
            break;
        }
    }

    int day = days + 1;

    printf("%d-", year);
    print2(month + 1);
    printf("-");
    print2(day);

    printf(" ");
    print2(hour);
    printf(":");
    print2(min);
    printf(":");
    print2(sec2);

    printf(".");
    print9(nsec);

    printf("\n");

    exit(0);
}