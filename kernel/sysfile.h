#pragma once

#include "types.h"

uint64 sys_dup(void);
uint64 sys_read(void);
uint64 sys_write(void);
uint64 sys_close(void);
uint64 sys_fstat(void);
uint64 sys_link(void);
uint64 sys_unlink(void);
uint64 sys_open(void);
uint64 sys_mkdir(void);
uint64 sys_mknod(void);
uint64 sys_chdir(void);
uint64 sys_exec(void);
uint64 sys_pipe(void);
