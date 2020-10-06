#ifndef _XV6_IOCTL_H
#define _XV6_IOCTL_H

int ioctl(int fd, unsigned long request, ...);


/* 0x54 is just a magic number to make these relatively unique ('T') */
#define TCGETA		0x5405
#define TCSETA		0x5406

#endif
