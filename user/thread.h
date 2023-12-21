#define FREE 0x0
#define RUNNING 0x1
#define RUNNABLE 0x2
#define STACK_SIZE 8192
#define MAX_THREAD 4

typedef struct thread thread_t, *thread_p;

struct thread {
    int        sp;                /* curent stack pointer */
    char stack[STACK_SIZE];       /* the thread's stack */
    int        state;             /* running, runnable */
    int         priority;
    // int         counter;
    int   thread_id;
    // long long int stamp;
};

static thread_t all_thread[MAX_THREAD];

thread_p  current_thread;
thread_p  next_thread;