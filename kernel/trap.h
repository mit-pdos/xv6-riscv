#pragma once

#include "spinlock.h"
#include "types.h"

extern uint     ticks;
extern struct spinlock tickslock;
void            trapinit(void);
void            trapinithart(void);
void            usertrapret(void);
