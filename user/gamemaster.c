#include "kernel/types.h"
#include "user/user.h"

// --- Configuration based on your lab report ---
#define SHM_KEY         1       // Shared page key [cite: 451]
#define MREQ_KEY        100     // Mailbox for A->B communication [cite: 452]
#define MRESP_KEY       101     // Mailbox for B->A communication [cite: 453]
#define PRINT_KEY       200     // Mailbox for print baton [cite: 454]

#define PGSIZE          4096    // Page size [cite: 382]
#define END_MARK        0xFFFF  // Maze termination marker [cite: 389]
#define EDGE_CAP        ((PGSIZE - 8) / 2) // Max edges in the maze page [cite: 384, 385]

// Shared memory page layout [cite: 406]
struct MazePage {
    ushort a_start;
    ushort b_start;
    ushort end_marker; // Should be 0xFFFF [cite: 411]
    ushort pad;        // Keeps header at 8 bytes [cite: 413]
    ushort edge[EDGE_CAP]; // Intertwined edges [cite: 416]
};

// Simple, xv6-safe integer-to-string conversion [cite: 549]
static void itoa(int val, char *buf) {
    char tmp[16];
    int i = 0, j = 0;
    if (val == 0) {
        buf[0] = '0';
        buf[1] = '\0';
        return;
    }
    while (val > 0) {
        tmp[i++] = '0' + (val % 10);
        val /= 10;
    }
    while (i > 0) {
        buf[j++] = tmp[--i];
    }
    buf[j] = '\0';
}

// Initializes the maze with intertwined paths [cite: 428]
void init_maze(struct MazePage *m) {
    // 1. Fill the entire maze with the end marker first. [cite: 429]
    for (int i = 0; i < EDGE_CAP; i++) {
        m->edge[i] = END_MARK;
    }

    // 2. Define two distinct paths. [cite: 431, 433]
    int path_a[] = {5, 20, 40, 77};
    int path_b[] = {10, 25, 41, 90};
    int na = sizeof(path_a) / sizeof(path_a[0]);
    int nb = sizeof(path_b) / sizeof(path_b[0]);

    // 3. Set start points and the end marker in the header. [cite: 438, 440, 442]
    m->a_start = (ushort)path_a[0];
    m->b_start = (ushort)path_b[0];
    m->end_marker = END_MARK;

    // 4. Stitch the paths together in an intertwined manner. [cite: 443, 445]
    // A's current location stores B's next location.
    for (int i = 0; i + 1 < na; i++) {
        m->edge[path_a[i]] = (ushort)path_b[i+1];
    }
    // B's current location stores A's next location.
    for (int i = 0; i + 1 < nb; i++) {
        m->edge[path_b[i]] = (ushort)path_a[i+1];
    }
}

// Helper to launch a player process [cite: 534]
void spawn(char role, int a2b_id, int b2a_id, int prn_id) {
    char role_str[] = {role, '\0'};
    char a2b_str[16], b2a_str[16], prn_str[16];

    itoa(a2b_id, a2b_str);
    itoa(b2a_id, b2a_str);
    itoa(prn_id, prn_str);

    if (fork() == 0) {
        char *argv[] = {"player", role_str, a2b_str, b2a_str, prn_str, 0};
        exec("player", argv);
        printf("gamemaster: exec player %c failed\n", role);
        exit(1);
    }
}

int main(void) {
    printf("Gamemaster: Setting up...\n");

    // 1. Create and attach to the shared memory page. [cite: 517, 519]
    shm_create(SHM_KEY);
    struct MazePage *maze = (struct MazePage *)shm_get(SHM_KEY);
    if (maze == 0) {
        printf("gamemaster: shm_get failed\n");
        exit(1);
    }

    // 2. Initialize the maze data within the shared page.
    init_maze(maze);
    printf("Gamemaster: Maze initialized in shared memory.\n");

    // 3. Create the three required mailboxes. [cite: 522, 523, 524]
    int a2b = mbox_create(MREQ_KEY);
    int b2a = mbox_create(MRESP_KEY);
    int prn = mbox_create(PRINT_KEY);
    if (a2b < 0 || b2a < 0 || prn < 0) {
        printf("gamemaster: mbox_create failed\n");
        exit(1);
    }

    // 4. Seed the print baton so one process can print first. [cite: 527, 528]
    mbox_send(prn, 1);

    // 5. Spawn the two player processes.
    printf("Gamemaster: Spawning players A and B...\n\n");
    spawn('A', a2b, b2a, prn);
    spawn('B', a2b, b2a, prn);

    // 6. Wait for both children to terminate. [cite: 560, 561]
    wait(0);
    wait(0);

    // 7. Clean up the shared memory region. [cite: 562]
    shm_close(SHM_KEY);
    printf("\nGamemaster: Players finished. Cleaning up.\n");

    exit(0);
}