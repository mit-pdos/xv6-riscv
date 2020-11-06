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
#include "fs.h"
#include "rtc.h"
#include "sleeplock.h"
#include "file.h"
#include <stdarg.h>

// referred implimentation of TWL92230C
#define Reg(reg) ((volatile long *)(RTC0 + reg))
#define RTC_SECONDS 0x23
#define RTC_MINUTES 0x24
#define RTC_HOURS 0x25
#define RTC_DAY 0x26
#define RTC_MONTH 0x27
#define RTC_YEAR 0x28

#define ReadReg(reg) (*(Reg(reg)))
#define WriteReg(reg, v) (*(Reg(reg)) = (v))

static unsigned char get_rtc(unsigned long addr) {
    unsigned char val;

    // WriteReg(Reg(0x00), addr);
    // val = ReadReg(Reg(0x01));
    val = ReadReg(Reg(addr));

    // return val;
    return 0;
}

void fill_rtcdate(struct rtcdate *t) {
    unsigned char seconds = 0;
    unsigned char minutes = 0;
    unsigned char hours = 0;
    unsigned char month = 0;

    seconds = get_rtc(RTC_SECONDS);
    minutes = get_rtc(RTC_MINUTES);
    hours = get_rtc(RTC_HOURS);
    month = get_rtc(RTC_MONTH);
    t->seconds = seconds;
    t->minutes = minutes;
    t->hours = hours;
    t->month = month;
}

static int rtcread(int user_dst, uint64 dst, int n, ...) {
    va_list ap;
    struct rtcdate t, *tt;

    va_start(ap, n);
    tt = va_arg(ap, struct rtcdate *);

    /* Get the current time from RTC */
    unsigned char seconds = 0;
    unsigned char minutes = 0;
    unsigned char hours = 0;
    unsigned char month = 0;

    seconds = get_rtc(RTC_SECONDS);
    minutes = get_rtc(RTC_MINUTES);
    hours = get_rtc(RTC_HOURS);
    month = get_rtc(RTC_MONTH);
    t.seconds = seconds;
    t.minutes = minutes;
    t.hours = hours;
    t.month = month;
    tt = &t;

    va_end(ap);
    return sizeof(*tt);
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
