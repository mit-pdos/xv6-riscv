#include "types.h"
#include "rand.h"

// Source: https://stackoverflow.com/a/52520577

static uint32 prev = 134775813U;

// seed the random number generator
void 
srand(uint32 seed) 
{
  prev = seed;
}

// generate a random number
uint32
rand(void) 
{
  prev = prev*1664525U + 1013904223U;
  return prev;
}

