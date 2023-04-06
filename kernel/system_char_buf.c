#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "stat.h"
#include "spinlock.h"
#include "proc.h"
#include "fs.h"
#include "sleeplock.h"
#include "file.h"
#include "fcntl.h"

#define NUMBER_OF_CHARS (1 << 21)
#define TICKS_BUFFER_SIZE 16

short flag = 1;

struct {
    int last_pos;
    struct spinlock spnlock;
    char buffer[NUMBER_OF_CHARS];
} spinned_buffer;

int min(int a, int b){
    if (a < b)
        return a;
    return b;
}

void lock_init() {
    initlock(&spinned_buffer.spnlock, "spnlock");
}

void writer(const char *str, const char *ticks){
    int len_to_write = min(strlen(str), NUMBER_OF_CHARS - spinned_buffer.last_pos - 1);
    if (len_to_write < 0)
        return;
    for (int ind = 0; ind < len_to_write; ind++)
        spinned_buffer.buffer[spinned_buffer.last_pos + ind] = str[ind];
    spinned_buffer.last_pos += len_to_write;
    len_to_write = min(strlen(ticks), NUMBER_OF_CHARS - spinned_buffer.last_pos - 1);
    if (len_to_write < 0)
        return;
    for (int ind = 0; ind < len_to_write; ind++)
        spinned_buffer.buffer[spinned_buffer.last_pos + ind] = ticks[ind];
    spinned_buffer.last_pos += len_to_write;
    spinned_buffer.buffer[spinned_buffer.last_pos++] = '\n';
    
}

void pr_msg (const char *str){   
    acquire(&spinned_buffer.spnlock);

    acquire(&tickslock);
    uint ticks_at_start = ticks;
    release(&tickslock);
    
    if (flag){
        flag = 0;
        spinned_buffer.last_pos = 0;
    }

    char number_rev[TICKS_BUFFER_SIZE - 1];
    char number[TICKS_BUFFER_SIZE];
    number[0] = ' ';

    int len_of_num = (ticks_at_start == 0);
    number_rev[0] = '0';
    while (ticks_at_start > 0 && len_of_num < TICKS_BUFFER_SIZE - 1) {
        number_rev[len_of_num++] = '0' + ticks_at_start % 10;
        ticks_at_start /= 10;
    }
    for (int i = len_of_num - 1; i >= 0; i--)
        number[len_of_num - i] = number_rev[i];
    number[len_of_num + 1] = 0;
    writer(str, number);
    release(&spinned_buffer.spnlock);  
}

uint64 
sys_dmesg(void) 
{
    for (int i = 0; i < spinned_buffer.last_pos; i++)
        consputc(spinned_buffer.buffer[i]);
    return 0;
}