enum BSSTATE {BSUNUSED, BSFREE, BSACQUIRED};
struct bsem
{
    enum BSSTATE state;
    struct spinlock bslock;
};
