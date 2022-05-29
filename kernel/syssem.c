#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "sem.h"

uint64
sys_semget(void)
{
  int key;
  argint(0, &key);
  int value;
  argint(1, &value);
  return semget(key,value);
}

uint64
sys_semdown(void)
{
  int sid;
  argint(0, &sid);
  return semdown(sid);
}

uint64
sys_semup(void)
{
  int sid;
  argint(0, &sid);
  return semup(sid);
}

uint64
sys_semclose(void)
{
  int sid;
  argint(0, &sid);
  return semclose(sid);
}
