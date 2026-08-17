// Software integer multiply / divide / remainder for RV64I (no M extension).
//
// When compiled with -march=rv64ia... (no 'm'), gcc lowers C's * / % on
// variables into calls to these libgcc routines. The system libgcc.a is
// built for the lp64d ABI and won't link against lp64 objects, so we
// provide freestanding replacements.
//
// CAREFUL: inside these functions we must not use * / % on variables --
// gcc would compile them into calls to these very functions (recursion).
// Everything is shift-and-add / shift-and-subtract.
//
// Division semantics follow the RISC-V M spec:
//   x / 0 == all-ones quotient, x % 0 == x.

typedef unsigned long u64;
typedef long i64;

// one pass of binary long division: returns quotient, stores remainder.
static u64
udivmod(u64 n, u64 d, u64 *rem)
{
  u64 q = 0, r = 0;
  int i;

  if(d == 0){
    if(rem) *rem = n;      // RISC-V: rem of div-by-zero is the dividend
    return ~0UL;           // quotient: all ones
  }
  for(i = 63; i >= 0; i--){
    r = (r << 1) | ((n >> i) & 1);
    if(r >= d){
      r -= d;
      q |= (1UL << i);
    }
  }
  if(rem) *rem = r;
  return q;
}

u64
__udivdi3(u64 n, u64 d)
{
  return udivmod(n, d, 0);
}

u64
__umoddi3(u64 n, u64 d)
{
  u64 r;
  udivmod(n, d, &r);
  return r;
}

i64
__divdi3(i64 n, i64 d)
{
  u64 un = n < 0 ? -(u64)n : (u64)n;
  u64 ud = d < 0 ? -(u64)d : (u64)d;
  u64 q = udivmod(un, ud, 0);
  return ((n < 0) != (d < 0) && d != 0) ? -(i64)q : (i64)q;
}

i64
__moddi3(i64 n, i64 d)
{
  u64 un = n < 0 ? -(u64)n : (u64)n;
  u64 ud = d < 0 ? -(u64)d : (u64)d;
  u64 r;
  udivmod(un, ud, &r);
  return n < 0 ? -(i64)r : (i64)r;   // remainder takes dividend's sign
}

// shift-and-add multiply; correct mod 2^64 for signed too (two's complement).
u64
__muldi3(u64 a, u64 b)
{
  u64 r = 0;
  while(b){
    if(b & 1)
      r += a;
    a <<= 1;
    b >>= 1;
  }
  return r;
}
