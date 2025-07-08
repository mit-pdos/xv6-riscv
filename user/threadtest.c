#include "kernel/types.h"
#include "user/user.h"

#define STACK_SIZE 100

void safe_print(const char *s, uint64 num) {
 int tid = gettid();
 char buf[64];
 int i = 0;

 buf[i++] = '[';
 if (tid == 0) { buf[i++] = '0'; }
 else {
 char tmp[16]; int t = 0;
 while (tid) { tmp[t++] = '0' + (tid % 10); tid /= 10; }
 while (t--) buf[i++] = tmp[t];
 }
 buf[i++] = ']';
 buf[i++] = ' ';

 for (const char *p = s; *p; p++)
 buf[i++] = *p;

 if (num == 0) { buf[i++] = '0'; }
 else {
 char tmp[32]; int t = 0;
 while (num) { tmp[t++] = '0' + (num % 10); num /= 10; }
 while (t--) buf[i++] = tmp[t];
 }

 buf[i++] = '\n';
 write(1, buf, i);
}

void *my_thread(void *arg) {
 uint64 number = (uint64)arg;
 for (int i = 0; i < 100; i++) {
 number++;
 safe_print("thread:", number);
 }
 return (void *)number;
}

int main(int argc, char *argv[]) {
 int sp1[STACK_SIZE], sp2[STACK_SIZE], sp3[STACK_SIZE];

  
 int ta = thread(my_thread, sp1 + STACK_SIZE, (void *)100);
 safe_print("NEW THREAD CREATED ", ta);

 int tb = thread(my_thread, sp2 + STACK_SIZE, (void *)200);
 safe_print("NEW THREAD CREATED ", tb);

 int tc = thread(my_thread, sp3 + STACK_SIZE, (void *)300);
 safe_print("NEW THREAD CREATED ", tc);

 jointhread(ta);
 jointhread(tb);
 jointhread(tc);

 write(1, "DONE\n", 5);
 exit(0);
}
