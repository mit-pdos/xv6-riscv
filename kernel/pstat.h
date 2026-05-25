// Estrutura retornada pela syscall getpinfo()
// Contém informações de todos os NPROC slots da tabela de processos

#ifndef _KERNEL_PSTAT_H_
#define _KERNEL_PSTAT_H_

#include "param.h"

struct pstat {
  int inuse[NPROC];    // 1 se o slot está em uso, 0 caso contrário
  int pid[NPROC];      // PID do processo
  int tickets[NPROC];  // Número de tickets (lottery)
  int ticks[NPROC];    // Ticks de CPU recebidos pelo processo
};

#endif
