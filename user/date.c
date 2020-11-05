#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "user/rtc.h"

int main(int argc, char *argv[]) {
    int fd;
    struct rtcdate t;
    fd = open("rtc", O_RDWR);

    if (argc == 1) {
        read(fd, &t, sizeof(t));
        printf("hello\n");
        // printf(0, "BSD: MM:hh:mm:ss: %d:%d:%d:%d: \n", t.month, t.hours,
        //        t.minutes, t.seconds);
        // printf(0, "MM:hh:mm:ss:  %d%d:%d%d:%d%d:%d%d\n", (t.month & 0xF0) >>
        // 4,
        //        t.month & 0x0F, (t.hours & 0xF0) >> 4, t.hours & 0x0F,
        //        (t.minutes & 0xF0) >> 4, t.minutes & 0x0F,
        //        (t.seconds & 0xF0) >> 4, t.seconds & 0x0F);
    }
    exit(0);
}
