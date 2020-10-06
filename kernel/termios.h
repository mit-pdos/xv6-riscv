#ifndef _UCC_TERMIOS_H
#define _UCC_TERMIOS_H

typedef unsigned int  tcflag_t;
typedef unsigned char cc_t;

#define NCCS 32
struct termios {
  tcflag_t c_iflag;      /* input modes */
  tcflag_t c_oflag;      /* output modes */
  tcflag_t c_cflag;      /* control modes */
  tcflag_t c_lflag;      /* local modes */
  cc_t     c_cc[NCCS];   /* special characters */
};

int tcgetattr(int,  struct termios *);
void cfmakeraw(struct termios *);
int tcsetattr(int, int, const struct termios *);

/* c_lflag bits */
#define ECHO	0000010
#define ICANON	0000002

/* tcsetattr uses these */
#define	TCSANOW		0

#endif
