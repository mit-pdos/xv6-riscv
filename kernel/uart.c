//
// low-level driver for 16550a UART.
//

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "proc.h"
#include "defs.h"

struct uart {
  uint64 base;
  void (*rx)(int);
  struct spinlock tx_lock;
};

struct uart uarts[] = {
  [0] = {.base = UART0, .rx = consoleintr},
  [1] = {.base = UART1, .rx = 0},
};

// the UART control registers are memory-mapped at u->base.
// this macro returns the address of one of the registers.
#define Reg(u, reg) ((volatile unsigned char *)((u)->base + (reg)))

#define ReadReg(u, reg)     (*(Reg(u, reg)))
#define WriteReg(u, reg, v) (*(Reg(u, reg)) = (v))

// the UART control registers.
// some have different meanings for read vs write.
// see http://byterunner.com/16550.html
#define RHR             0        // receive holding register (for input bytes)
#define THR             0        // transmit holding register (for output bytes)
#define IER             1        // interrupt enable register
#define IER_RX_ENABLE   (1 << 0) // receiver interrupts
#define IER_TX_ENABLE   (1 << 1) // transmit interrupts
#define FCR             2        // FIFO control register
#define FCR_FIFO_ENABLE (1 << 0)
#define FCR_FIFO_CLEAR  (3 << 1) // clear the content of the two FIFOs
#define ISR             2        // interrupt status register
#define LCR             3        // line control register
#define LCR_EIGHT_BITS  (3 << 0)
#define LCR_BAUD_LATCH  (1 << 7) // special mode to set baud rate
#define LSR             5        // line status register
#define LSR_RX_READY    (1 << 0) // input is waiting to be read from RHR
#define LSR_TX_IDLE     (1 << 5) // THR can accept another character to send

static void
uartinitone(struct uart *u, char *name)
{
  // disable interrupts.
  WriteReg(u, IER, 0x00);

  // special mode to set baud rate.
  WriteReg(u, LCR, LCR_BAUD_LATCH);

  // LSB for baud rate of 38.4K.
  WriteReg(u, 0, 0x03);

  // MSB for baud rate of 38.4K.
  WriteReg(u, 1, 0x00);

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(u, LCR, LCR_EIGHT_BITS);

  // reset and enable FIFOs.
  WriteReg(u, FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);

  // enable transmit interrupts, and receive interrupts only if
  // there is somewhere for the input to go.
  WriteReg(u, IER, IER_TX_ENABLE | (u->rx ? IER_RX_ENABLE : 0));

  initlock(&u->tx_lock, name);
}

void
uartinit(void)
{
  uartinitone(&uarts[0], "uart0");
  uartinitone(&uarts[1], "uart1");
}

// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(int uid, char buf[], int n)
{
  struct uart *u = &uarts[uid];
  int i = 0;
  while (i < n) {
    sleep_prepare(u);
    acquire(&u->tx_lock);
    if (ReadReg(u, LSR) & LSR_TX_IDLE) {
      WriteReg(u, THR, buf[i]);
      release(&u->tx_lock);
      i += 1;
    } else {
      release(&u->tx_lock);
      sleep();
    }
  }
}

// write a byte to the uart without using
// interrupts, for use by kernel printk() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int uid, int c)
{
  struct uart *u = &uarts[uid];
  acquire(&u->tx_lock);

  // wait for UART to set Transmit Holding Empty in LSR.
  while ((ReadReg(u, LSR) & LSR_TX_IDLE) == 0)
    ;
  WriteReg(u, THR, c);

  release(&u->tx_lock);
}

// try to read one input character from the UART.
// return -1 if none is waiting.
static int
uartgetc(struct uart *u)
{
  // is input ready?
  if (ReadReg(u, LSR) & LSR_RX_READY) {
    return ReadReg(u, RHR);
  } else {
    return -1;
  }
}

// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(int uid)
{
  struct uart *u = &uarts[uid];

  ReadReg(u, ISR); // acknowledge the interrupt

  if (ReadReg(u, LSR) & LSR_TX_IDLE) {
    // UART finished transmitting; wake up sending thread.
    wakeup(u);
  }

  // read and process incoming characters, if any.
  while (1) {
    int c = uartgetc(u);
    if (c == -1)
      break;
    if (u->rx)
      u->rx(c);
  }
}
