#pragma once

#include "types.h"

struct file; // avoid circular dependency
struct pipe;

int  pipealloc(struct file**, struct file**);
void pipeclose(struct pipe*, int);
int  piperead(struct pipe*, uint64, int);
int  pipewrite(struct pipe*, uint64, int);
