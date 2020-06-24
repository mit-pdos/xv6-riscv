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
#include "net/ipv4.h"
#include "net/tcp.h"

struct tcp_cb tcb_table[TCP_CB_LEN];

struct tcp_cb* _get_tcb(uint32 raddr, uint16 dport, uint32 c) {
  return &tcb_table[(raddr + dport + TCP_COLLISION_NUM * c) % TCP_CB_LEN];
}

struct tcp_cb* get_tcb(uint32 raddr, uint16 dport) {
  struct tcp_cb* tcb;
  for (int i = 0; i < TCP_CB_LEN; i++) {
    tcb = _get_tcb(raddr, dport, i);
    if (tcb->used && tcb->raddr == raddr && tcb->dport == dport) {
      return tcb;
    }
    if (!tcb->used) {
      return tcb;
    }
  }
  return 0;
}

void tcpinit() {
  memset(tcb_table, 0, sizeof(tcb_table));
  for (int i = 0; i < TCP_CB_LEN; i++) {
    tcb_table[i].used = 0;
    initlock(&tcb_table[i].lock, "tcblock");
    mbufq_init(&tcb_table[i].txq);
  }
}

void init_tcp_cb(struct tcp_cb *tcb) {
  if (tcb != 0) {
    acquire(&tcb->lock);
    tcb->used = 1;
    tcb->state = CLOSED;
    tcb->raddr = 0;
    tcb->dport = 0;
    release(&tcb->lock);
  }
}

void free_tcp_cb(struct tcp_cb *tcb) {
  if (tcb != 0) {
    acquire(&tcb->lock);
    memset(tcb, 0, sizeof(*tcb));
    tcb->state = CLOSED;
    release(&tcb->lock);
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

struct tcp_cb *tcp_open(uint32 raddr, uint16 dport, int stype) {
  struct tcp_cb *tcb;

  tcb = get_tcb(raddr, dport);
  if (tcb != 0 && !tcb->used) {
    init_tcp_cb(tcb);

    tcb->raddr = raddr;
    tcb->dport = dport;

    if (stype == SOCK_TCP) {
      struct mbuf *m = mbufalloc(ETH_MAX_SIZE);
      net_tx_tcp(tcb, m, TCP_FLG_SYN);
      tcb->state = SYN_SENT;
    } else {
      tcb->state = LISTEN;
    }
  // TODO LISTEN STATE
  // -> chenge the connection from passive to active
  } else {
    // "error: connection already exists"
    return 0;
  }

  return tcb;
}

// https://tools.ietf.org/html/rfc793#page-56
int tcp_send(struct tcp_cb *tcb) {
  enum tcp_cb_state state = tcb->state;

  if (TCP_FLG_ISSET(state, CLOSED) || tcb->used == 0) {
    // "error: connection illegal for this process"
    return -1;
  }

  if (TCP_FLG_ISSET(state, LISTEN)) {
    if (tcb->raddr) {
      uint32 seq = 0; // initial send sequence number;
      // uint8 flag = TCP_FLG_SYN;

      acquire(&tcb->lock);
      tcb->snd.unack = seq;
      tcb->snd.nxt_seq = seq+1;
      tcb->state = SYN_SENT;
      // TODO The urgent bit if requested in the command must be sent with the data segments sent
      // as a result of this command.

      release(&tcb->lock);

      return 0;
    } else {
      // "error: foreign socket unspecified";
      return -1;
    }
  }

  // TODO
  // SYN_SENT
  // SYN_RCVD
  // ESTAB
  // CLOSE_WAIT
  // FIN_WAIT_1
  // FIN_WAIT_2
  // CLOSING
  // LAST_ACK
  // TIME_WAIT
  return -1;
}

int tcp_recv(struct tcp_cb *tcb, struct mbuf *m, struct tcp *tcphdr) {
  enum tcp_cb_state state = tcb->state;
  if (TCP_FLG_ISSET(state, CLOSED) || tcb->used == 0) {
    // "error: connection illegal for this process"
    return -1;
  }

  // LISTEN
  // SYN_SENT
  // SYN_RCVD
  if (
    TCP_FLG_ISSET(state, LISTEN) ||
    TCP_FLG_ISSET(state, SYN_SENT) ||
    TCP_FLG_ISSET(state, SYN_RCVD)
  ) {
    // queue mbuf
  }
  
  // ESTAB
  // FIN_WAIT_1
  // FIN_WAIT_2
  //
  // CLOSE_WAIT
  //
  // CLOSING
  // LAST_ACK
  // TIME_WAIT
  return -1;
}

int tcp_close(struct tcp_cb *tcb) {
  return -1;
}

int tcp_abort() {
  return -1;
}

void net_tx_tcp(struct tcp_cb *tcb, struct mbuf *m, uint8 flg) {
  struct tcp *tcphdr;

  tcphdr = mbufpushhdr(m, *tcphdr);
  tcphdr->sport = htons(tcb->sport);
  tcphdr->dport = htons(tcb->dport);
  tcphdr->seq = htonl(tcb->snd.nxt_seq);
  tcphdr->ack = htonl(tcb->rcv.nxt_seq);
  tcphdr->off = (sizeof(struct tcp) >> 2) << 4;
  tcphdr->flg = flg;
  printf("flg: %d\n", flg);
  tcphdr->wnd = htons(tcb->rcv.wnd);
  tcphdr->sum = 0;
  tcphdr->urg = 0;

  net_tx_ip(m, IPPROTO_TCP, tcb->raddr);
}


// void tcp_rx_core(struct tcp_cb *tcb, struct mbuf *m, struct tcphdr *tcphdr, struct ipv4 *iphdr) {
// }

// segment arrives
void net_rx_tcp(struct mbuf *m, uint16 len, struct ipv4 *iphdr) {
  struct tcp *tcphdr;
  uint16 dport;
  uint32 raddr;
  struct tcp_cb *tcb = 0;

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

  tcb = get_tcb(raddr, dport);

  acquire(&tcb->lock);
  if (tcb == 0 || !tcb->used) {
    goto fail;
  }

  if (tcb->used) {
    uint8 flg = tcphdr->flg;

    // TODO check seq & ack

    if (tcb->state == CLOSED) {
      goto fail;
    } else if (tcb->state == LISTEN) {
      // If received SYN, send SYN,ACK
      if (TCP_FLG_ISSET(flg, TCP_FLG_RST)) {
        goto fail;
      } else if (TCP_FLG_ISSET(flg, TCP_FLG_ACK)) {
        goto fail;
        // TODO send RST
      } else if (TCP_FLG_ISSET(flg, TCP_FLG_SYN)) {
        // TODO check security
        // TODO If the SEG.PRC is greater than the TCB.PRC

        tcb->rcv.wnd = sizeof(tcb->window);
        tcb->rcv.init_seq = ntohl(tcphdr->seq);
        tcb->rcv.nxt_seq = tcb->rcv.init_seq + 1;
        tcb->snd.init_seq = 0;
        tcb->snd.nxt_seq = 0;
        struct mbuf *m = mbufalloc(ETH_MAX_SIZE);
        net_tx_tcp(tcb, m, TCP_FLG_SYN | TCP_FLG_ACK);
        tcb->snd.nxt_seq = tcb->rcv.init_seq + 1;
        tcb->snd.unack = tcb->rcv.init_seq;
        // TODO timeout
        tcb->state = SYN_RCVD;
      } else {
        goto fail;
      }
    } else if (tcb->state == SYN_SENT) {
    } else if (tcb->state == SYN_RCVD) {
    } else if (tcb->state == ESTAB) {
    } else if (tcb->state == FIN_WAIT_1) {
    } else if (tcb->state == FIN_WAIT_2) {
    } else if (tcb->state == CLOSING) {
    } else if (tcb->state == TIME_WAIT) {
    } else if (tcb->state == CLOSE_WAIT) {
    } else if (tcb->state == LAST_ACK) {
    } else {

    }

    // TODO URG process
  }

  release(&tcb->lock);
  return;

fail:
  if(tcb != 0)
    release(&tcb->lock);
  mbuffree(m);
}
