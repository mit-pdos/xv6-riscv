# xv6 (RISCV)

Contained are a series of modifications from the XV6 kernel for educational purposes. These projects are inspired by https://github.com/remzi-arpacidusseau/ostep-projects.

## Scheduler - Proportional Share

**xv6** ships with a rudimentary Round-Robin scheduler, which simply cycles through the proccess list and runs the next runnable process it finds. 

In order to increase fairness, this Round-Robin scheduler was replaced with a lottery-based proportional share scheduler. This new scheduler aims to share CPU time proportionally, according to the number of tickets assigned to a process.

[Inspiration](https://github.com/remzi-arpacidusseau/ostep-projects/blob/master/scheduling-xv6-lottery/README.md)

### Scheduling Algorithm

An outline of the scheduling algorithm (in pseudocode) can be found below. 

Note that this is approximately `o(2N)`. Computing the sum of runnable tickets on every schedule is notably expensive, nearly doubling scheduling latency.  However, the alternative is overly complex. There are many pathways through which a process's state can change to/from runnable. Updating a global total through each of these pathways could prove error-prone. For this reason, we prefer the simpler approach here.

```python
def schedule():
    # ensure that concurrent CPUs do not modify the list of runnable processes while we search it.
    acquire(scheduler_lock)

    total_runnable_tickets = sum_runnable_tickets()
    
    # get a random number in [0, total_runnable_tickets)
    winning_ticket = rand(0, total_runnable_tickets)
    
    # find winning process
    running_total = 0
    for process in process_list:
        if process.state == RUNNABLE:
            running_total += process.tickets
            if running_total > winning_ticket:
                schedule(process)
                release(scheduler_lock)
                context_switch()

# Sum all ticket counts for currently runnable processes
def sum_runnable_tickets():
    sum = 0
    for process in process_list:
        if process.state == RUNNABLE:
            sum += process.tickets
    return sum
```

### New System Calls

In order to enable proportional share, it was necessary to expose the per-process ticket count to the user. This was enable through two new system calls.

```c
// Sets the ticket count for the currently running process
// Accepts values between 1 & MAX_TICKETS
// Returns 0 on success
int settickets(int tickets);
```
```c
// Get a summary of all processes in the process list and copy to stat.
// Returns 0 on success
int getpinfo(struct pstat *stat);
```
```c
struct pstat {
  int inuse[NPROC];   // whether this slot of the process table is in use (1 or 0)
  int tickets[NPROC]; // the number of tickets this process has
  int pid[NPROC];     // the PID of each process 
  int ticks[NPROC];   // the number of ticks each process has accumulated 
};
```

### In Practice
Below are some snapshots of xv6 with 3 active processes on 1 CPU. These processes were assigned 10, 20, and 30 tickets respectively. 

As you can see, the share of CPU time (as denoted by `TICKS`) is *roughly* proportional.
```
$ ps
PID,INUSE,TICKETS,TICKS
4,1,10,1185
6,1,20,2237
8,1,30,3160

$ ps
PID,INUSE,TICKETS,TICKS
4,1,10,2024
6,1,20,3933
8,1,30,5563

$ ps
PID,INUSE,TICKETS,TICKS
4,1,10,2385
6,1,20,4631
8,1,30,6589
```

## ACKNOWLEDGMENTS

xv6 is inspired by John Lions's Commentary on UNIX 6th Edition (Peer
to Peer Communications; ISBN: 1-57398-013-7; 1st edition (June 14,
2000)). See also https://pdos.csail.mit.edu/6.828/, which
provides pointers to on-line resources for v6.

The following people have made contributions: Russ Cox (context switching,
locking), Cliff Frey (MP), Xiao Yu (MP), Nickolai Zeldovich, and Austin
Clements.

We are also grateful for the bug reports and patches contributed by
Takahiro Aoyagi, Silas Boyd-Wickizer, Anton Burtsev, Ian Chen, Dan
Cross, Cody Cutler, Mike CAT, Tej Chajed, Asami Doi, eyalz800, Nelson
Elhage, Saar Ettinger, Alice Ferrazzi, Nathaniel Filardo, flespark,
Peter Froehlich, Yakir Goaron,Shivam Handa, Matt Harvey, Bryan Henry,
jaichenhengjie, Jim Huang, Matúš Jókay, Alexander Kapshuk, Anders
Kaseorg, kehao95, Wolfgang Keller, Jungwoo Kim, Jonathan Kimmitt,
Eddie Kohler, Vadim Kolontsov , Austin Liew, l0stman, Pavan
Maddamsetti, Imbar Marinescu, Yandong Mao, , Matan Shabtay, Hitoshi
Mitake, Carmi Merimovich, Mark Morrissey, mtasm, Joel Nider,
OptimisticSide, Greg Price, Jude Rich, Ayan Shafqat, Eldar Sehayek,
Yongming Shen, Fumiya Shigemitsu, Cam Tenny, tyfkda, Warren Toomey,
Stephen Tu, Rafael Ubal, Amane Uehara, Pablo Ventura, Xi Wang, Keiichi
Watanabe, Nicolas Wolovick, wxdao, Grant Wu, Jindong Zhang, Icenowy
Zheng, ZhUyU1997, and Zou Chang Wei.

The code in the files that constitute xv6 is
Copyright 2006-2020 Frans Kaashoek, Robert Morris, and Russ Cox.