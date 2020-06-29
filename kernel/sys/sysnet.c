//
// network system calls.
//

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "arch/riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "fs.h"
#include "sleeplock.h"
#include "file.h"
#include "net/mbuf.h"
#include "net/netutil.h"
#include "net/tcp.h"
#include "sys/sysnet.h"

static struct spinlock lock;
static struct sock *sockets;

void
sockinit(void)
{
  initlock(&lock, "socktbl");
}

int
sockalloc(struct file **f, uint32 raddr, uint16 sport, uint16 dport, int stype)
{
  struct sock *si, *pos;

  si = 0;
  *f = 0;
  if ((*f = filealloc()) == 0)
    goto bad;
  if ((si = (struct sock*)kalloc()) == 0)
    goto bad;

  // initialize objects
  si->raddr = raddr;
  // TODO source port decision
  si->sport = sport;
  si->dport = dport;
  si->stype = stype;

  if(stype == SOCK_TCP || stype == SOCK_TCP_LISTEN) {
    si->tcb = tcp_open(raddr, sport, dport, stype);
    if (si->tcb == 0) {
      goto bad;
    }
  } else {
    si->tcb = 0;
  }

  initlock(&si->lock, "sock");
  mbufq_init(&si->rxq);
  (*f)->type = FD_SOCK;
  (*f)->readable = 1;
  (*f)->writable = 1;
  (*f)->sock = si;

  // add to list of sockets
  acquire(&lock);
  pos = sockets;
  while (pos) {
    if (pos->raddr == raddr &&
        pos->sport == sport &&
        pos->dport == dport
    ) {
      release(&lock);
      goto bad;
    }
    pos = pos->next;
  }
  si->next = sockets;
  sockets = si;
  release(&lock);
  return 0;

bad:
  if (si)
    kfree((char*)si);
  if (*f)
    fileclose(*f);
  return -1;
}

void sockfree(struct sock *si) {
  kfree((char*)si);
}

// called by protocol handler layer to deliver UDP packets
void
sockrecvudp(struct mbuf *m, uint32 raddr, uint16 sport, uint16 dport)
{
  acquire(&lock);
  struct sock *sock;
  sock = sockets;
  while (sock) {
    if (sock->raddr == raddr &&
        sock->sport == sport &&
        sock->dport == dport) {
      release(&lock);
      acquire(&sock->lock);
      mbufq_pushtail(&sock->rxq, m);
      release(&sock->lock);
      return;
    }
    sock = sock->next;
  }
  release(&lock);
  mbuffree(m);
}

uint64
sys_socket(void)
{
  struct file *f;
  int raddr;
  int sport, dport;
  int stype;

  if(
    argint(0, (int *)&raddr) < 0 ||
    argint(1, (int *)&sport) < 0 ||
    argint(2, (int *)&dport) < 0 ||
    argint(3, (int *)&stype) < 0
  )
    return -1;

  int fd;
  if(sockalloc(&f, (uint32)raddr, (uint16)sport, (uint16)dport, stype) != 0 || (fd = fdalloc(f)) < 0)
    return -1;

  return fd;
}

// UDP only now
int
sys_socksend(struct file *f, uint64 addr, int n)
{
  // TODO split data
  struct sock *s = f->sock;
  struct mbuf *m = mbufalloc(1518-(n+1));
  struct proc *pr = myproc();

  copyin(pr->pagetable, m->head, addr, n);

  mbufput(m, n);
  if (s->stype == SOCK_TCP || s->stype == SOCK_TCP_LISTEN) {
    // TODO 
    if (s->tcb != 0)
      net_tx_tcp(s->tcb, m, 0);
  } else {
    net_tx_udp(m, s->raddr, s->sport, s->dport);
  }
  return n;
}

int
sys_sockrecv(struct file *f, uint64 addr, int n)
{
  struct sock *sock = f->sock;
  struct mbufq *rxq = &sock->rxq;
  struct proc *pr = myproc();

  struct mbuf *m = mbufq_pophead(rxq);
  // TODO fix busy wait
  while (m == 0x0) {
    m = mbufq_pophead(rxq);
  }
  copyout(pr->pagetable, addr, m->head, n);
  mbuffree(m);
  return n;
}

