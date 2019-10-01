#pragma once

#include "buf.h"

void        binit(void);
struct buf* bread(uint, uint);
void        brelse(struct buf*);
void        bwrite(struct buf*);
void        bpin(struct buf*);
void        bunpin(struct buf*);
