# MLFQ Scheduling (Project 2)

## Overview

This program implements the Multilevel Feedback Queue (MLFQ) scheduling algorithm using a simple array-based approach.

It simulates how processes are scheduled across multiple priority queues based on their CPU usage.

---

## Algorithm

The scheduler uses 3 queues:

* Q0 → Time slice = 1 (highest priority)
* Q1 → Time slice = 2
* Q2 → Time slice = 4 (lowest priority)

### Working:

* All processes start in Q0
* If a process uses its full time slice → it is moved to a lower queue
* Scheduler always selects from the highest priority queue available

---

## Input

Processes used:

```
P1: AT=0, BT=5
P2: AT=1, BT=3
P3: AT=2, BT=4
```

---

## Output

### Timeline

```
| T0:P1(Q0) | T1:P2(Q0) | T2:P3(Q0) | T3:P1(Q1) | T4:P1(Q1) |
| T5:P2(Q1) | T6:P2(Q1) | T7:P3(Q1) | T8:P3(Q1) |
| T9:P1(Q2) | T10:P1(Q2) | T11:P3(Q2) |
```

---

### Metrics

* Completion Time (CT)
* Turnaround Time (TAT = CT - AT)
* Waiting Time (WT = TAT - BT)

Average values:

* Average Turnaround Time = 9.00
* Average Waiting Time = 5.00

---

## How to Run

```
gcc mlfq.c -o mlfq
./mlfq
```

---

## Key Features

* Array-based implementation
* Multiple priority queues
* Dynamic priority adjustment (demotion)
* Clear timeline visualization
* Performance metrics calculation

---

## Note

Promotion (aging) is not implemented for simplicity.
In real systems, promotion is used to prevent starvation.

---

## Conclusion

MLFQ improves responsiveness by prioritizing short processes while still allowing long processes to execute. It balances fairness and efficiency.
