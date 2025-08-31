#include "kernel/types.h"
#include "user/user.h"

// --- Configuration must match gamemaster ---
#define SHM_KEY         1
#define PGSIZE          4096
#define END_MARK        0xFFFF
#define EDGE_CAP        ((PGSIZE - 8) / 2)

// Shared memory page layout
struct MazePage {
    ushort a_start;
    ushort b_start;
    ushort end_marker;
    ushort pad;
    ushort edge[EDGE_CAP];
};

int main(int argc, char *argv[]) {
    if (argc != 5) {
        printf("player: incorrect arguments\n");
        exit(1);
    }

    char role = argv[1][0];
    int a2b_mbox = atoi(argv[2]);
    int b2a_mbox = atoi(argv[3]);
    int prn_mbox = atoi(argv[4]);

    // 1. Attach to the shared memory page.
    shm_create(SHM_KEY); // Does nothing if it already exists
    struct MazePage *maze = (struct MazePage *)shm_get(SHM_KEY);
    if (maze == 0) {
        printf("player %c: shm_get failed\n", role);
        exit(1);
    }

    // 2. Determine start position based on role.
    ushort my_cur = (role == 'A') ? maze->a_start : maze->b_start;
    int steps = 0;

    // 3. Main traversal loop.
    while (1) {
        int other_pos_int;
        ushort other_pos;

        // 4. Follow the strict send/receive protocol to avoid deadlock. [cite: 455]
        if (role == 'A') {
            mbox_send(a2b_mbox, my_cur); // A sends first [cite: 456]
            mbox_recv(b2a_mbox, &other_pos_int);
        } else { // Role is 'B'
            mbox_recv(a2b_mbox, &other_pos_int); // B receives first [cite: 457]
            mbox_send(b2a_mbox, my_cur);
        }
        other_pos = (ushort)other_pos_int;

        // 5. Compute next positions from the shared maze. [cite: 482]
        ushort my_next = END_MARK;
        ushort partner_next = END_MARK;
        if (other_pos < EDGE_CAP) {
            my_next = maze->edge[other_pos];
        }
        if (my_cur < EDGE_CAP) {
            partner_next = maze->edge[my_cur];
        }

        // 6. Use the print baton for synchronized logging. [cite: 490]
        int token;
mbox_recv(prn_mbox, &token);

// Convert END_MARK to -1 for cleaner printing, as shown in the PDF
int my_next_print = (my_next == END_MARK) ? -1 : my_next;
int partner_next_print = (partner_next == END_MARK) ? -1 : partner_next;

// CORRECTED: The format string now starts with %c to match the 'role' argument.
        printf("%d ", (role- 'A'));
        printf("step=%d cur=%d other=%d -> my_next=%d partner_next=%d\n",
            steps, 
            my_cur, 
            other_pos,
            my_next_print,
            partner_next_print);

        mbox_send(prn_mbox, token);
        // 7. Check for termination condition. [cite: 501]
        if (my_next == END_MARK && partner_next == END_MARK) {
            break;
        }

        // 8. Advance to the next position. [cite: 502]
        if (my_next != END_MARK) {
            my_cur = my_next;
        }
        
        steps++;
        // Safety guard against infinite loops [cite: 504]
        if(steps > 2000) {
            mbox_recv(prn_mbox, &token);
            printf("%c: safety break!\n", role);
            mbox_send(prn_mbox, token);
            break;
        }
    }

    // 9. Clean up.
    shm_close(SHM_KEY);
    exit(0);
}