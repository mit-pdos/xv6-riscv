#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define PGSIZE 4096

int global_var = 42;

void
check_and_report(const char *name, void *addr, int len)
{
  int a = pgcheck(addr, len, PTE_A);
  int d = pgcheck(addr, len, PTE_D);
  printf("  %-18s: A=%d, D=%d\n", name, a, d);
}

int
main(int argc, char *argv[])
{
  int stack_var = 10;
  int stack_arr[64];
  volatile int tmp = 0;

  printf("Pagetable at startup\n");
  pgprint();

  // Выделяем массив в куче на 3 страницы (12 КБ)
  int heap_size = 3 * PGSIZE;
  char *heap_arr = sbrk(heap_size);
  if (heap_arr == (char*)-1) {
    printf("sbrk failed\n");
    exit(1);
  }
  // Первичная инициализация, чтобы страницы гарантированно были в памяти
  heap_arr[0] = 1;
  heap_arr[PGSIZE] = 2;
  heap_arr[2 * PGSIZE] = 3;

  printf("\nPagetable after heap allocation\n");
  pgprint();

  // Снимаем A и D у глобальной переменной, стека и кучи
  printf("\nClearing A and D flags\n");
  if (pgclear(&global_var, sizeof(global_var), PTE_A | PTE_D) < 0)
    printf("pgclear global failed\n");
  if (pgclear(&stack_var, sizeof(stack_var), PTE_A | PTE_D) < 0)
    printf("pgclear stack_var failed\n");
  if (pgclear(stack_arr, sizeof(stack_arr), PTE_A | PTE_D) < 0)
    printf("pgclear stack_arr failed\n");
  if (pgclear(heap_arr, heap_size, PTE_A | PTE_D) < 0)
    printf("pgclear heap_arr failed\n");

  pgprint();
  check_and_report("global_var", &global_var, sizeof(global_var));
  check_and_report("heap_arr[0..3pg]", heap_arr, heap_size);

  // Чтение данных (должен выставиться только A)
  printf("\nAfter READING data\n");
  tmp += global_var;
  tmp += stack_var;
  tmp += stack_arr[10];
  // Невыровненный доступ через границу 1-й и 2-й страниц кучи
  tmp += heap_arr[PGSIZE - 1];
  tmp += heap_arr[PGSIZE + 1];

  pgprint();
  check_and_report("global_var", &global_var, sizeof(global_var));
  check_and_report("heap page 0-1", heap_arr + PGSIZE - 4, 8);
  check_and_report("heap page 2", heap_arr + 2 * PGSIZE, 16);

  // Изменение данных (должны выставиться A и D)
  printf("\nAfter WRITING data\n");
  global_var = 99;
  stack_var = 20;
  stack_arr[10] = 30;
  heap_arr[2 * PGSIZE + 5] = 77;

  pgprint();
  check_and_report("global_var", &global_var, sizeof(global_var));
  check_and_report("heap page 2", heap_arr + 2 * PGSIZE, 16);

  // Проверка обработки ошибок
  printf("\nError handling checks\n");
  printf("Invalid flags (0): %d (expect -1)\n", pgclear(heap_arr, 10, 0));
  printf("Invalid flags (PTE_R=2): %d (expect -1)\n", pgcheck(heap_arr, 10, 2));
  printf("Out-of-bounds VA: %d (expect -1)\n", pgcheck((void*)0x3ffffff000ULL, 16, PTE_A));

  // Освобождение памяти в куче
  printf("\nPagetable after freeing heap\n");
  sbrk(-heap_size);
  pgprint();

  // Используем tmp, чтобы компилятор не выкинул чтения
  printf("Done (tmp=%d)\n", tmp);
  exit(0);
}
