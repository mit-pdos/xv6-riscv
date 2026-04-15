#include "types.h"
#include "memlayout.h"

#define RtcReg(addr) (*(volatile uint32 *)(addr))

uint32 rtc_read_low(void) {
    return RtcReg(RTC_LOW);
}

uint32 rtc_read_high(void) {
    return RtcReg(RTC_HIGH);
}

uint64 rtc_read_time(void) {
  uint32 high1, high2, low;

  do {
    high1 = rtc_read_high();
    low  = rtc_read_low();
    high2 = rtc_read_high();
  } while (high1 != high2);

  return ((uint64)high1 << 32) | low;
}
