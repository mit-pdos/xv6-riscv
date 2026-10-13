#ifndef _TYPES_H_
#define _TYPES_H_

typedef unsigned int uint;
typedef unsigned short ushort;
typedef unsigned char uchar;

typedef unsigned char uint8;
typedef unsigned short uint16;
typedef unsigned int uint32;
typedef unsigned long uint64;

typedef uint64 pde_t;

// CPU usage information returned by wait2.
struct rusage {
  uint cputime;
};

#endif
