#include "types.h"
#include "param.h"
#include "arch/riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "net/byteorder.h"
#include "net/mbuf.h"
#include "net/netutil.h"
#include "net/ethernet.h"

uint16 cksum16(uint16 *data, uint16 size, uint32 init) {
  uint32 sum;
  sum = init;
  while(size > 1) {
    sum += *(data++);
    size -= 2;
  }
  if (size) {
    sum += *(uint8 *)data;
  }
  sum = (sum & 0xffff) + (sum >> 16);
  sum = (sum & 0xffff) + (sum >> 16);
  return ~(uint16)sum;
}
