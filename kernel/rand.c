#include "types.h"
#include "rand.h"
#include <limits.h>

// Source: https://stackoverflow.com/a/15038230

static uint32 prev = 0;

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
  prev = (prev * 25214903917 + 11);
  return prev;
}

