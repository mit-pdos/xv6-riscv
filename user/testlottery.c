#include "kernel/types.h"
#include "kernel/pstat.h"
#include "user/user.h"

// Número de ticks que o pai espera antes de amostrar os contadores.
// Ajuste para obter resultados mais estáveis (mais ticks = melhor convergência).
#define SAMPLE_TICKS 200

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
  uint t0;

  // Filho 1: recebe 3 tickets (mais favorecido)
  pid1 = fork();
  if (pid1 == 0) {
    settickets(3);
    spin_cpu();
    exit(0);
  }

  // Filho 2: mantém 1 ticket (padrão)
  pid2 = fork();
  if (pid2 == 0) {
    spin_cpu();
    exit(0);
  }

  // Aguarda SAMPLE_TICKS ticks para acumular amostras
  t0 = uptime();
  while (uptime() - t0 < SAMPLE_TICKS)
    ;

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
    // Mostra a razão observada vs esperada (3:1)
    printf("razao ticks[pid1]/ticks[pid2] = %d/%d  (esperado ~3/1)\n",
           st.ticks[p1], st.ticks[p2]);
  }

  kill(pid1);
  kill(pid2);
  wait(0);
  wait(0);

  exit(0);
}
