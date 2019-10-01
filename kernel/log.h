#pragma once

#include "buf.h"
#include "fs_format.h"

void initlog(int, struct superblock*);
void log_write(struct buf*);
void begin_op();
void end_op();
