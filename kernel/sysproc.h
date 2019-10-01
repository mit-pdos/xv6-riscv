#pragma once

#include "types.h"

uint64 sys_exit(void);
uint64 sys_getpid(void);
uint64 sys_fork(void);
uint64 sys_wait(void);
uint64 sys_sbrk(void);
uint64 sys_sleep(void);
uint64 sys_kill(void);
uint64 sys_uptime(void);
