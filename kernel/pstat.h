//Funcao: define a estrutura que será retornada pela syscall `getpinfo()`

#ifndef _KERNEL_PSTAT_H_
#define _KERNEL_PSTAT_H_

#include "types.h"

#define NPROC 64

struct pstat {
  int pid;
  int tickets;  // Número de bilhetes (lottery tickets)
  int ticks;    // Quantos ticks foi escalonado para o processo
};

#endif