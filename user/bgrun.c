// test freeze with fork()
#include "kernel/types.h"
#include "user/user.h"

#define TICK_TIME 100
#define THRESHHOLD 5000

int main(int argc, char *argv[])
{
    printf("[DEBUG] Started\n");
    uint64 start = uptime() * TICK_TIME;
    uint64 end = uptime() * TICK_TIME;
    while (1)
    {
        uint64 elapsed = end - start;
        if (elapsed >= THRESHHOLD)
        {
            start = uptime() * TICK_TIME;
            printf("[DEBUG] Start: %ld, End: %ld, Elapsed: %ld\n", start, end, elapsed);
        }
        end = uptime() * TICK_TIME;
    }

    return 0;
}