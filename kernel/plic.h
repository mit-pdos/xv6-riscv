#pragma once

#include "types.h"

void            plicinit(void);
void            plicinithart(void);
uint64          plic_pending(void);
int             plic_claim(void);
void            plic_complete(int);
