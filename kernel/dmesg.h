#define NULL 0
#define BUFSIZE DMESGPS * PGSIZE

struct log_level {
    int interrupt;
    int context_switch;
    int syscall;
};

struct log {
    struct log_level level;
    struct spinlock lock;
    int tick_start;
    int tick_count;
};

extern struct log logger;

#define LOG_IF(type, ...) do {  \
    if (logger.level.type && (logger.tick_count == 0 || ticks - logger.tick_start <= logger.tick_count))       \
        pr_msg(__VA_ARGS__);    \
} while(0);
