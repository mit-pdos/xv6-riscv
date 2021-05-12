#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "kernel/syscall.h"
#include "kernel/memlayout.h"
#include "kernel/riscv.h"
int wait_sig =0;
void handler1(int x){
    fprintf(2,"the x i got:%d\n",x);
    fprintf(2,"handler1 initiated\n");
    
}
void test_handler(int signum){
    wait_sig = 1;
    printf("Received sigtest\n");
}
void signal_test(char *s){
    int pid;
    int testsig;
    testsig=15;
    struct sigaction_ act = {
        .sa_handler_ = test_handler, 
        .sigmask = (uint)(1 << 29)};
    struct sigaction_ old;

    sigprocmask(0);
    sigaction(testsig, &act, &old);
    if((pid = fork()) == 0){
        while(!wait_sig){
        //    fprintf(2,"sliping\n");
            sleep(1);

        }
        exit(0);
    }
    kill(pid, testsig);
    wait(&pid);
    printf("Finished testing signals\n");
}
void signal_blocked_test(){
    int pid;
    int testsig;
    testsig=15;
    struct sigaction_ act = {
        .sa_handler_ = test_handler, 
        .sigmask = (uint)(1 << 29)};
    struct sigaction_ old;

    sigaction(testsig, &act, &old);
    if((pid = fork()) == 0){
        while(!wait_sig){
        //    fprintf(2,"sliping\n");
            sleep(1);

        }
        exit(0);
    }
    kill(pid, testsig);
    wait(&pid);
    printf("Finished testing signals\n");
}
void mysignaltest(){
    fprintf(2, "strating usertests!\n");
    int pid = fork();
    if(pid==0){
        fprintf(2, "Im the child\n");
        struct sigaction_ sigaction1={
            .sigmask= 0,
            .sa_handler_ = &handler1
        };
        struct sigaction_ oldaction; 
        fprintf(2,"sigaction answer:%d\n",sigaction(5,&sigaction1,&oldaction));
        fprintf(2,"%d\n",oldaction);
    }
    else{
        fprintf(2,"",kill(pid,1<<5));
        // fprintf(2,"SIGSTOP response:%d\n",kill(pid,SIGSTOP));
      
        // fprintf(2,"SIGCONT response:%d\n",kill(pid,SIGCONT));
        wait(&pid);
        fprintf(2,"I'm the parent\n");
    }
    exit(0);

}
void sigprocmask_block_error_test(){
    printf("error_on_blocking_kill_and_stop_test\n");
    fprintf(2,"should be -1:%d\n",sigprocmask(~0));
}
void sigaction_block_error_test(){
    fprintf(2,"sigaction_blovk_error_test");
    int testsig=15;
    struct sigaction_ act = {
        .sa_handler_ = test_handler, 
        .sigmask = ~0};
    struct sigaction_ old;

    fprintf(2, "should be -1: %d\n",sigaction(testsig, &act, &old));
    act.sigmask = 1<<SIGSTOP;
    fprintf(2, "should be -1: %d\n",sigaction(testsig, &act, &old));
}
void sigstop_sigcontinue_test(){
    int pid;
    if((pid = fork()) == 0){
        sleep(3);
        fprintf(2,"child finished\n");
        exit(0);
    }
    if(kill(pid, SIGSTOP)!=0){
        fprintf(2,"kill isn't working\n");
    };
    for(int i=0; i<5; i++){
        fprintf(2,"parent waiting\n");
        sleep(1);
    }
    kill(pid, SIGCONT);
    wait(&pid);
}
void bsemtests(){
    int bsem_descriptor = bsem_alloc();
    bsem_down(bsem_descriptor);

    bsem_up(bsem_descriptor);

    bsem_up(bsem_descriptor);
}
int main(int argc, char *argv[])
{
    // signal_test("");
    // sigprocmask_block_error_test();
    // sigaction_block_error_test();
    // sigstop_sigcontinue_test();
    bsemtests();
    // mysignaltest();
    exit(0);
}