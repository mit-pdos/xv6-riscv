struct sock {
  struct sock *next; // the next socket in the list
  uint32 raddr;      // the remote IPv4 address
  uint16 sport;      // the local UDP port number
  uint16 dport;      // the remote UDP port number
  int stype;
  struct spinlock lock; // protects the rxq
  struct mbufq rxq;  // a queue of packets waiting to be received
  struct tcp_cb *tcb;
};

