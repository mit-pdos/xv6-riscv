//
// rtc driver
//

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
// #include "traps.h"
#include "fs.h"
// #include "mmu.h"
#include "rtc.h"
#include "sleeplock.h"
#include "file.h"

#define Reg(reg) ((volatile unsigned char *)(RTC0 + reg))
#define RTC_SECONDS 0
#define RTC_MINUTES 2
#define RTC_HOURS 4
#define RTC_MONTH 8

#define ReadReg(reg) (*(Reg(reg)))
#define WriteReg(reg, v) (*(Reg(reg)) = (v))

static unsigned char get_rtc(unsigned char addr) {
    unsigned char val;

    WriteReg(Reg(0), addr);
    val = ReadReg(Reg(1));

    return val;
    // return 0;
}

static int rtcread(int user_dst, uint64 dst, int n) {
    struct rtcdate t;

    /* Get the current time from RTC */
    unsigned char seconds;
    unsigned char minutes;
    unsigned char hours;
    unsigned char month;

    seconds = get_rtc(RTC_SECONDS);
    minutes = get_rtc(RTC_MINUTES);
    hours = get_rtc(RTC_HOURS);
    month = get_rtc(RTC_MONTH);
    t.seconds = seconds;
    t.minutes = minutes;
    t.hours = hours;
    t.month = month;
    *((struct rtcdate *)dst) = t;

    return sizeof(t);
    // return 0;
}

// int rtcwrite(int user_src, uint64 src, int n) {
//     struct rtcdate t;
//     t = *((struct rtcdate *)dst);

//     outb(RTC_PORT(0), RTC_MINUTES);
//     outb(RTC_PORT(1), t.minutes);
//     outb(RTC_PORT(0), RTC_HOURS);
//     outb(RTC_PORT(1), t.hours);
//     outb(RTC_PORT(0), RTC_SECONDS);
//     outb(RTC_PORT(1), t.seconds);
//     outb(RTC_PORT(0), RTC_MONTH);
//     outb(RTC_PORT(1), t.month);

//     return sizeof(t);
// }

void rtcinit(void) {
    devsw[RTC].read = rtcread;
    // devsw[RTC].write = rtcwrite;
}
