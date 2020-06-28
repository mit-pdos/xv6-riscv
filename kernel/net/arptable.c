#include "types.h"
#include "param.h"
#include "arch/riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "net/byteorder.h"
#include "net/mbuf.h"
#include "net/ethernet.h"
#include "net/netutil.h"
#include "net/arptable.h"

struct arp_table arptable;

struct arp_entry* _get_arp_entry(uint32 ip, uint32 c) {
  return &arptable.entries[(ip + c) % ARP_DEFUALT_ENTRY_NUM];
}

struct arp_entry* get_arp_entry(uint32 ip) {
  struct arp_entry *entry;
  for (int i = 0; i < ARP_DEFUALT_ENTRY_NUM; i++) {
    entry = _get_arp_entry(ip, i);
    if (entry->ip == 0 || entry->ip == ip) {
      return entry;
    }
  }
  return 0;
}

void arptable_init() {
  memset(&arptable, 0, sizeof(arptable));
  initlock(&arptable.lock, "arp table lock");
}

void arptable_add(uint32 ip, uint8 *mac) {
  struct arp_entry *entry;

  acquire(&arptable.lock);
  entry = get_arp_entry(ip);
  if (entry == 0)
    panic("There are no remaining arp entries");
  entry->ip = ip;
  memmove(entry->mac, mac, ETHADDR_LEN);
  release(&arptable.lock);
}

int arptable_get(uint32 ip, uint8 *mac) {
  struct arp_entry *entry;

  acquire(&arptable.lock);
  entry = get_arp_entry(ip);
  if (entry == 0)
    panic("There are no remaining arp entries");
  if (entry->ip == 0)
    return -1;
  memmove(mac, entry->mac, ETHADDR_LEN);
  return 0;
}

void arptable_del(uint32 ip) {
  struct arp_entry *entry;

  acquire(&arptable.lock);
  entry = get_arp_entry(ip);
  if (entry == 0)
    panic("There are no remaining arp entries");
  entry->ip = 0;
  memset(entry->mac, 0, ETHADDR_LEN);
  release(&arptable.lock);
}
