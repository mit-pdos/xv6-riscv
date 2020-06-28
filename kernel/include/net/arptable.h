
#define ARP_DEFUALT_ENTRY_NUM 32

struct arp_entry {
  uint32 ip;
  uint8 mac[ETHADDR_LEN];
};

struct arp_table {
  struct spinlock lock;
  struct arp_entry entries[ARP_DEFUALT_ENTRY_NUM];
};

void arptable_add(uint32, uint8*);
int arptable_get(uint32, uint8*);
void arptable_del(uint32);