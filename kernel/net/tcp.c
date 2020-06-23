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
#include "net/tcp.h"

static struct spinlock lock;
struct tcp_cb tcb[TCP_CB_LEN];

struct tcp_cb* _get_tcb(uint32 raddr, uint16 rport, uint32 c) {
  return &tcb[(raddr + rport + COLLISION_NUM * c) % TCP_CB_LEN];
}

struct tcp_cb* get_tcb(uint32 raddr, uint16 rport) {
  struct tcp_cb* tcb;
  for (int i = 0; i < TCP_CB_LEN; i++) {
    tcb = _get_tcb(raddr, rport, i);
    if (tcb->peer.addr == raddr && tcb->peer.port == rport) {
      return tcb;
    }
    if (!tcb->used) {
      tcb->port = TCP_MIN_PORT + i;
      return tcb;
    }
  }
  return 0;
}

void tcpinit() {
  initlock(&lock, "tcblock");
  for (int i = 0; i < TCP_CB_LEN; i++) {
    tcb[i].used = 0;
  }
}

struct tcp_cb* init_tcp_cb(uint32 raddr, uint16 rport) {
  struct tcp_cb *tcb = get_tcb(raddr, rport);

  if (tcb != 0) {
    acquire(&lock);
    tcb->used = 1;
    tcb->state = CLOSED;
    tcb->peer.addr = 0;
    tcb->peer.port = 0;
    release(&lock);
    return tcb;
  } else {
    return 0;
  }
}

static uint16 tcp_checksum(struct ipv4 *iphdr , struct tcp *tcphdr, uint16 len) {
  uint32 pseudo = 0;

  pseudo += ntohs((iphdr->ip_src >> 16) & 0xffff);
  pseudo += ntohs(iphdr->ip_src & 0xffff);
  pseudo += ntohs((iphdr->ip_dst >> 16) & 0xffff);
  pseudo += ntohs(iphdr->ip_dst & 0xffff);
  pseudo += (uint16)iphdr->ip_p;
  pseudo += len;
  return cksum16((uint16 *)tcphdr, len, pseudo);
}

void net_tx_tcp(struct mbuf *m, uint32 raddr, uint16 lport, uint16 rport) {
}

void net_rx_tcp(struct mbuf *m, uint16 len, struct ipv4 * iphdr) {
  struct tcp *tcphdr;
  uint16 sport, dport;
  uint32 raddr;

  tcphdr = mbufpullhdr(m, *tcphdr);
  if (!tcphdr)
    goto fail;

  uint16 sum = tcp_checksum(iphdr, tcphdr, len);
  if (sum != 0) {
    printf("[bad tcp] checksum doesn't match\n");
    goto fail;
  }

  raddr = ntohl(iphdr->ip_src);
  dport = ntohs(tcphdr->dport);
  sport = ntohs(tcphdr->sport);

  struct tcp_cb *tcb = get_tcb(raddr, dport);
  printf("%p, %d\n", tcb, sport);

  return;
fail:
  mbuffree(m);
}
