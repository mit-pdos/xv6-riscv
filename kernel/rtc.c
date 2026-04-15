#include "types.h"
#include "memlayout.h"

#define LOW_IND 0
#define HIGH_IND 1
#define RtcReg(i) (*(volatile uint32 *)(RTC_BASE + 4 * (i)))

uint32 rtc_read_low(void) {
    return RtcReg(LOW_IND);
}

uint32 rtc_read_high(void) {
    return RtcReg(HIGH_IND);
}

uint64 rtc_read_time(void) {
    uint32 low = rtc_read_low();
    uint32 high = rtc_read_high();
    return ((uint64)high << 32) | low;
}
