// an IP packet header (comes after an Ethernet header).
struct ipv4 {
  uint8  ip_vhl; // version << 4 | header length >> 2
  uint8  ip_tos; // type of service
  uint16 ip_len; // total length
  uint16 ip_id;  // identification
  uint16 ip_off; // fragment offset field
  uint8  ip_ttl; // time to live
  uint8  ip_p;   // protocol
  uint16 ip_sum; // checksum
  uint32 ip_src, ip_dst;
};

#define IPPROTO_ICMP 1  // Control message protocol
#define IPPROTO_TCP  6  // Transmission control protocol
#define IPPROTO_UDP  17 // User datagram protocol

#define IP_GET_FLG(off) (off & 0xe000)
#define IP_GET_OFF(off) (off & 0x1fff)

#define MAKE_IP_ADDR(a, b, c, d)           \
  (((uint32)a << 24) | ((uint32)b << 16) | \
   ((uint32)c << 8) | (uint32)d)


