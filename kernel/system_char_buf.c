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

void writer(const char *str, short needs_n){
    int len_to_write = min(strlen(str), NUMBER_OF_CHARS - spinned_buffer.last_pos - 1);
    if (len_to_write < 0)
        return;
    for (int ind = 0; ind < len_to_write; ind++)
        spinned_buffer.buffer[spinned_buffer.last_pos + ind] = str[ind];
    spinned_buffer.last_pos += len_to_write;
    if (needs_n){
        spinned_buffer.buffer[spinned_buffer.last_pos++] = '\n';
    }
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

    writer(str, 0);

    char msg[32];
    char number[TICKS_BUFFER_SIZE];

    const char *tks_msg_b = ", ticks: ";
    const char *tks_msg_e = "; ";
    
    strncpy(msg, tks_msg_b, strlen(tks_msg_b));

    int len_of_num = (ticks_at_start == 0);
    number[0] = '0';
    while (ticks_at_start > 0 && len_of_num < TICKS_BUFFER_SIZE) {
        number[len_of_num++] = '0' + ticks_at_start % 10;
        ticks_at_start /= 10;
    }
    for (int i = len_of_num - 1; i >= 0; i--)
        msg[strlen(tks_msg_b) + (len_of_num - 1 - i)] = number[i];
    
    strncpy(msg + strlen(tks_msg_b) + len_of_num, tks_msg_e, strlen(tks_msg_e));

    writer(msg, 1);
    release(&spinned_buffer.spnlock);  
}

uint64 
sys_dmesg(void) 
{
    for (int i = 0; i < spinned_buffer.last_pos; i++)
        consputc(spinned_buffer.buffer[i]);
    return 0;
}