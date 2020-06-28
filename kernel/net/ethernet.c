#include "types.h"
#include "param.h"
#include "arch/riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "net/byteorder.h"
#include "net/mbuf.h"
#include "net/ethernet.h"
#include "net/arptable.h"
#include "net/arp.h"
#include "net/netutil.h"

uint8 local_mac[ETHADDR_LEN] = { 0x52, 0x54, 0x00, 0x12, 0x34, 0x56 };
uint8 broadcast_mac[ETHADDR_LEN] = { 0xFF, 0XFF, 0XFF, 0XFF, 0XFF, 0XFF };

// sends an ethernet packet
void
net_tx_eth(struct mbuf *m, uint16 ethtype, uint32 dip)
{
  struct eth *ethhdr;

  ethhdr = mbufpushhdr(m, *ethhdr);
  memmove(ethhdr->shost, local_mac, ETHADDR_LEN);

  if (ethtype != ETHTYPE_ARP && arptable_get(dip, (uint8 *)&ethhdr->dhost) == -1) {
    net_tx_arp(ARP_OP_REQUEST, broadcast_mac, dip);
    mbuffree(m);
    return;
  }

  // memmove(ethhdr->dhost, broadcast_mac, ETHADDR_LEN);
  ethhdr->type = htons(ethtype);
  if (e1000_transmit(m)) {
    mbuffree(m);
  }
}

// called by e1000 driver's interrupt handler to deliver a packet to the
// networking stack
void net_rx(struct mbuf *m)
{
  struct eth *ethhdr;
  uint16 type;

  ethhdr = mbufpullhdr(m, *ethhdr);
  if (!ethhdr) {
    mbuffree(m);
    return;
  }

  type = ntohs(ethhdr->type);
  if (type == ETHTYPE_IP)
    net_rx_ip(m);
  else if (type == ETHTYPE_ARP)
    net_rx_arp(m);
  else
    mbuffree(m);
}
