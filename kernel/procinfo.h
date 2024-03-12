#pragma once

typedef struct procinfo {
    char name[16];       
    int state;              
    int parent_pid;          
} procinfo_t;

enum procinfostate {
    STATE_UNUSED,
    STATE_USED,
    STATE_SLEEPING,
    STATE_RUNNABLE,
    STATE_RUNNING,
    STATE_ZOMBIE
};