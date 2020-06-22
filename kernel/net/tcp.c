#include "types.h"
#include "param.h"
#include "arch/riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "net/byteorder.h"
#include "net/mbuf.h"
#include "net/netutil.h"
#include "net/ipv4.h"

struct tcp_cb tcb[TCP_CB_LEN];

static uint16 tcp_checksum(uint32 saddr, uint32 taddr, uint8 *segment, uint32 len) {
  uint32 pseudo = 0;
  
  pseudo += (saddr >> 16) & 0xffff;
  pseudo += saddr & 0xffff;
  pseudo += (taddr >> 16) & 0xffff;
  pseudo += taddr & 0xffff; 
  pseudo += htons((uint16)IPPROTO_TCP);
  pseudo += htons(len);
  return cksum16((uint16 *)segment, len, pseudo);
}

struct tcp_cb* init_tcp_cb() {
  
}

void net_tx_tcp(struct mbuf *m, uint32 raddr, uint16 lport, uint16 rport) {
}

void net_rx_tcp(struct mbuf *m, uint16 len, struct ipv4 *) {
}
