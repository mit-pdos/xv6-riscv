/****************************************************************************/
/*  Random Number Generator, from Knuth, Vol II, 3rd edition, p. 186-187.                */
/****************************************************************************/

#define KK 100
#define LL 37
#define MM (1L<<30)
#define mod_diff(x,y) (((x) - (y))&(MM-1))
#define TT 70
#define is_odd(x) ((x)&1)
#define evenize(x) ((x)&(MM-2))

long ran_x[KK];
long aa[2000];
int rand_index=0;
void ran_array(long aa[], int n)
{
    register int i,j;
    for (j=0; j<KK;j++)aa[j]=ran_x[j];
    for (;j<n;j++) aa[j]=mod_diff(aa[j-KK], aa[j-LL]);
    for(i=0;i<LL;i++,j++) ran_x[i]= mod_diff(aa[j-KK], aa[j-LL]);
    for (;i<KK;i++,j++) ran_x[i]= mod_diff(aa[j-KK], ran_x[i-LL]);
}

void ran_start(int seed)
{
    register int t,j;
    long x[KK+KK-1];
    register long ss=evenize(seed+2);
    for (j=0; j<KK;j++)
    {
        x[j]=ss;
        ss<<=1; 
        if (ss>=MM) ss -= MM-2;
    }
    for (;j<KK+KK-1;j++) x[j]=0;
    x[1]++;
    ss=seed&(MM-1);
    t=TT-1;
    while (t)
    {
        for (j=KK-1;j>0;j--) x[j+j]= x[j];
        for (j=KK+KK-2; j>KK-LL;j-=2) x[KK+KK-1-j] = evenize(x[j]);
        for (j=KK+KK-2; j >=KK; j--) 
            if (is_odd(x[j]))
            {
                x[j-(KK-LL)]=mod_diff(x[j-(KK-LL)],x[j]);
                x[j-KK]= mod_diff(x[j-KK],x[j]);
            }
        if (is_odd(ss))
        {
            for(j=KK;j>0;j--) x[j]=x[j-1];
            x[0]=x[KK];
            if (is_odd(x[KK])) x[LL]=mod_diff(x[LL],x[KK]);
        }
        if (ss) ss>>=1; 
        else t--;
    }
    for (j=0;j<LL;j++) ran_x[j+KK-LL]=x[j];
    for(;j<KK;j++) ran_x[j-LL]=x[j];
    ran_array(aa,1009);
    rand_index=0;
}

int nextRand()
{
    if (++rand_index > 100)
    {
        ran_array(aa,1009);
        rand_index=0;
    }
    return aa[rand_index];
}

void rand_init(int seed)
{
  ran_start(seed);
}

int scaled_random(int low, int high)
{
  int range = (high-low+1);
  int val = nextRand();
  return (val % range)+low;
}
