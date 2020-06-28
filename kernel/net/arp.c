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
#include "net/arp.h"
#include "net/arptable.h"

extern struct arp_tabel arptable;
extern uint8 local_mac[];
extern uint32 local_ip;

// sends an ARP packet
int
net_tx_arp(uint16 op, uint8 dmac[ETHADDR_LEN], uint32 dip)
{
  struct mbuf *m;
  struct arp *arphdr;

  m = mbufalloc(MBUF_DEFAULT_HEADROOM);
  if (!m)
    return -1;

  // generic part of ARP header
  arphdr = mbufputhdr(m, *arphdr);
  arphdr->hrd = htons(ARP_HRD_ETHER);
  arphdr->pro = htons(ETHTYPE_IP);
  arphdr->hln = ETHADDR_LEN;
  arphdr->pln = sizeof(uint32);
  arphdr->op = htons(op);

  // ethernet + IP part of ARP header
  memmove(arphdr->sha, local_mac, ETHADDR_LEN);
  arphdr->sip = htonl(local_ip);
  memmove(arphdr->tha, dmac, ETHADDR_LEN);
  arphdr->tip = htonl(dip);

  // header is ready, send the packet
  net_tx_eth(m, ETHTYPE_ARP, dip);
  return 0;
}

// receives an ARP packet
void
net_rx_arp(struct mbuf *m)
{
  struct arp *arphdr;
  uint8 smac[ETHADDR_LEN];
  uint32 sip, tip;

  arphdr = mbufpullhdr(m, *arphdr);
  if (!arphdr)
    goto done;

  // validate the ARP header
  if (ntohs(arphdr->hrd) != ARP_HRD_ETHER ||
      ntohs(arphdr->pro) != ETHTYPE_IP ||
      arphdr->hln != ETHADDR_LEN ||
      arphdr->pln != sizeof(uint32)) {
    goto done;
  }

  
  memmove(smac, arphdr->sha, ETHADDR_LEN); // sender's ethernet address
  tip = ntohl(arphdr->tip); // target IP address
  sip = ntohl(arphdr->sip); // sender's IP address (qemu's slirp)
  arptable_add(sip, smac);

  // only requests are supported so far
  // check if our IP was solicited
  if (ntohs(arphdr->op) != ARP_OP_REQUEST || tip != local_ip)
    goto done;

  // handle the ARP request
  net_tx_arp(ARP_OP_REPLY, smac, sip);

done:
  mbuffree(m);
}
