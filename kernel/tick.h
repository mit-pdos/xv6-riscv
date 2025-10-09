#include "types.h"
#include "param.h"

struct tick {
  uint count;
} __attribute__((aligned(CACHE_LINE_SIZE)));
