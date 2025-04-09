#include "types.h"
#include "riscv.h"
#include "logger.h"
#include "defs.h"

static inline int kstrlen(const char *s) {
    int n;
    for(n = 0; s[n]; n++)
        ;
    return n;
}
#define MAX_MESSAGE_LENGTH 512

void log_message(int level, const char *message) {
    char *prefix;
    
    if (level == LOG_INFO) {
        prefix = "INFO";
    } else if (level == LOG_WARN) {
        prefix = "WARNING";
    } else if (level == LOG_ERROR) {
        prefix = "ERROR";
    } else {
        prefix = "UNKNOWN";
    }
    
    if (kstrlen(message) > MAX_MESSAGE_LENGTH) {
        printf("%s - Message too long\n", prefix);
    } else {
        printf("%s - %s\n", prefix, message);
    }
}

