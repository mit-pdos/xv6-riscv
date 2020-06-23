
#define COLLISION_NUM 11

#define TCP_CB_LEN 256

#define TCP_FLG_FIN 0x01
#define TCP_FLG_SYN 0x02
#define TCP_FLG_RST 0x04
#define TCP_FLG_PSH 0x08
#define TCP_FLG_ACK 0x10
#define TCP_FLG_URG 0x20

#define TCP_MIN_PORT 25000

#define TCP_HDR_LEN(hdr) (((hdr)->offset >> 4) << 2)
#define TCP_DATA_LEN(hdr, len) ((len)-TCP_HDR_LEN(hdr))

struct tcp {
  uint16 sport;
  uint16 dport;
  uint32 seq;
  uint32 ack;
// little endian only
// use #define to check endian if you want to support big endian
  uint8 offset;
  uint8 flags;
  uint16 window;
  uint16 sum;
  uint16 urg;
};

enum tcp_cb_state {
  CLOSED,
  LISTEN,
  SYN_SENT,
  SYN_RCVD,
  ESTAB,
  FIN_WAIT_1,
  FIN_WAIT_2,
  CLOSING,
  TIME_WAIT,
  CLOSE_WAIT,
  LAST_ACK
};

struct tcp_cb {
  int used;
  enum tcp_cb_state state;
  uint16 port;
  struct {
    uint32 addr;
    uint16 port;
  } peer;
};
