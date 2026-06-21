#include "kernel/types.h"
#include "kernel/pstat.h"
#include "user/user.h"

// Número de ticks que o pai espera antes de amostrar os contadores.
#define SAMPLE_TICKS 500

// Gira a CPU sem fazer nada útil para forçar o escalonador a agir.
static void
spin_cpu(void)
{
  volatile int x = 0;
  for (;;)
    x++;
}

int
main(void)
{
  int pid1, pid2;
  int p1 = -1, p2 = -1;
  struct pstat st;

  // CORREÇÃO 1: configura 3 tickets ANTES do fork,
  // para o filho herdar corretamente via fork().
  settickets(3);
  pid1 = fork();
  if (pid1 == 0) {
    spin_cpu();
    exit(0);
  }

  // Volta para 1 ticket antes de criar o segundo filho.
  settickets(1);
  pid2 = fork();
  if (pid2 == 0) {
    spin_cpu();
    exit(0);
  }

  // CORREÇÃO 2: usa pause() em vez de busy-wait,
  // para que o pai fique SLEEPING e não participe da loteria.
  pause(SAMPLE_TICKS);

  if (getpinfo(&st) < 0) {
    printf("testlottery: getpinfo falhou\n");
    kill(pid1);
    kill(pid2);
    wait(0);
    wait(0);
    exit(1);
  }

  // Localiza os índices dos filhos na tabela
  for (int i = 0; i < NPROC; i++) {
    if (st.inuse[i] && st.pid[i] == pid1) p1 = i;
    if (st.inuse[i] && st.pid[i] == pid2) p2 = i;
  }

  printf("PID\ttickets\tticks\n");
  if (p1 >= 0)
    printf("%d\t%d\t%d\n", pid1, st.tickets[p1], st.ticks[p1]);
  if (p2 >= 0)
    printf("%d\t%d\t%d\n", pid2, st.tickets[p2], st.ticks[p2]);

  if (p1 >= 0 && p2 >= 0 && st.ticks[p2] > 0) {
    printf("razao ticks[pid1]/ticks[pid2] = %d/%d\n",
           st.ticks[p1], st.ticks[p2]);
  }

  kill(pid1);
  kill(pid2);
  wait(0);
  wait(0);

  exit(0);
}