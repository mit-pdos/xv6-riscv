struct mbuf;
struct ipv4;

void net_tx_tcp(struct mbuf*, uint32, uint16, uint16);
void net_rx_tcp(struct mbuf*, uint16, struct ipv4 *);

void net_tx_udp(struct mbuf*, uint32, uint16, uint16);
void net_rx_udp(struct mbuf*, uint16, struct ipv4 *);

int net_tx_arp(uint16, uint8[], uint32);
void net_rx_arp(struct mbuf *);

void net_tx_ip(struct mbuf *, uint8, uint32);
void net_rx_ip(struct mbuf *);

void net_tx_eth(struct mbuf*, uint16);
void net_rx(struct mbuf*);

// util
uint16 cksum16(uint16 *, uint16, uint32);
