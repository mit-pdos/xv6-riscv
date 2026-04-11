#include <stdio.h>

#define MAX 10

typedef struct {
    int id;
    int at, bt;
    int rt;         // remaining time
    int ct, tat, wt;
    int qlevel;     // current queue
    int qticks;     // ticks used in current queue
} Process;

int tq[3] = {1, 2, 4};

int main() {
    int n = 3;

    Process p[MAX] = {
        {1, 0, 5, 5, 0, 0, 0, 0, 0},
        {2, 1, 3, 3, 0, 0, 0, 0, 0},
        {3, 2, 4, 4, 0, 0, 0, 0, 0}
    };

    int time = 0, completed = 0;

    printf("Timeline:\n");

    while (completed < n) {
        int found = 0;

        for (int q = 0; q < 3; q++) {
            for (int i = 0; i < n; i++) {
                if (p[i].at <= time && p[i].rt > 0 && p[i].qlevel == q) {

                    printf("Time %d: P%d (Q%d)\n", time, p[i].id, q);

                    p[i].rt--;
                    p[i].qticks++;
                    time++;
                    found = 1;

                    // if finished
                    if (p[i].rt == 0) {
                        p[i].ct = time;
                        completed++;
                        p[i].qticks = 0;
                    }
                    // if time slice exhausted → demote
                    else if (p[i].qticks == tq[q]) {
                        if (p[i].qlevel < 2)
                            p[i].qlevel++;

                        p[i].qticks = 0;
                    }

                    break;
                }
            }
            if (found) break;
        }

        if (!found) {
            printf("Time %d: Idle\n", time);
            time++;
        }
    }

    printf("\nPID\tAT\tBT\tCT\tTAT\tWT\n");

    for (int i = 0; i < n; i++) {
        p[i].tat = p[i].ct - p[i].at;
        p[i].wt = p[i].tat - p[i].bt;

        printf("P%d\t%d\t%d\t%d\t%d\t%d\n",
               p[i].id, p[i].at, p[i].bt,
               p[i].ct, p[i].tat, p[i].wt);
    }

    return 0;
}
