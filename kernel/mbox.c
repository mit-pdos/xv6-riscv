// kernel/mbox.c

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

#define MAX_MAILBOXES 16
#define MBOX_SIZE 8

struct mailbox {
    int key;
    int messages[MBOX_SIZE];
    int head;
    int tail;
    int count;
    int in_use;
    struct spinlock lock;
};

static struct mailbox mailboxes[MAX_MAILBOXES];
static struct spinlock mbox_table_lock;

void
mbox_init(void)
{
    initlock(&mbox_table_lock, "mbox_table");
    for(int i = 0; i < MAX_MAILBOXES; i++) {
        mailboxes[i].in_use = 0;
        mailboxes[i].key = -1;
        mailboxes[i].head = 0;
        mailboxes[i].tail = 0;
        mailboxes[i].count = 0;
        initlock(&mailboxes[i].lock, "mailbox");
    }
}

int
mbox_create(int key)
{
    acquire(&mbox_table_lock);
    
    for(int i = 0; i < MAX_MAILBOXES; i++) {
        if(mailboxes[i].in_use && mailboxes[i].key == key) {
            release(&mbox_table_lock);
            return i;
        }
    }
    
    int mbox_id = -1;
    for(int i = 0; i < MAX_MAILBOXES; i++) {
        if(!mailboxes[i].in_use) {
            mbox_id = i;
            break;
        }
    }
    
    if(mbox_id == -1) {
        release(&mbox_table_lock);
        return -1;
    }
    
    mailboxes[mbox_id].key = key;
    mailboxes[mbox_id].head = 0;
    mailboxes[mbox_id].tail = 0;
    mailboxes[mbox_id].count = 0;
    mailboxes[mbox_id].in_use = 1;
    
    release(&mbox_table_lock);
    return mbox_id;
}

int
mbox_send(int mbox_id, int msg)
{
    if(mbox_id < 0 || mbox_id >= MAX_MAILBOXES || !mailboxes[mbox_id].in_use) {
        return -1;
    }
    
    struct mailbox* mb = &mailboxes[mbox_id];
    
    acquire(&mb->lock);
    
    while(mb->count >= MBOX_SIZE) {
        sleep(mb, &mb->lock);
    }
    
    mb->messages[mb->tail] = msg;
    mb->tail = (mb->tail + 1) % MBOX_SIZE;
    mb->count++;
    
    wakeup(mb);
    
    release(&mb->lock);
    return 0;
}

int
mbox_recv(int mbox_id, uint64 user_addr_msg)
{
    if(mbox_id < 0 || mbox_id >= MAX_MAILBOXES || !mailboxes[mbox_id].in_use) {
        return -1;
    }
    
    if(user_addr_msg == 0) {
        return -1;
    }
    
    struct mailbox* mb = &mailboxes[mbox_id];
    int received_msg;
    
    acquire(&mb->lock);
    
    while(mb->count == 0) {
        sleep(mb, &mb->lock);
    }
    
    received_msg = mb->messages[mb->head];
    mb->head = (mb->head + 1) % MBOX_SIZE;
    mb->count--;
    
    wakeup(mb);
    
    release(&mb->lock);
    
    if(copyout(myproc()->pagetable, user_addr_msg, (char*)&received_msg, sizeof(int)) < 0) {
        return -1;
    }
    
    return 0;
}