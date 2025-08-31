#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define MAZE_SIZE 11  // 0-9 are valid positions, 10 is finish
#define END_MARKER 10

// Structure for the intertwined maze in shared memory
struct maze_data {
    int path_a[MAZE_SIZE];  // Path for process A
    int path_b[MAZE_SIZE];  // Path for process B
    int process_a_pos;      // Current position of process A
    int process_b_pos;      // Current position of process B
    int process_a_finished; // Flag indicating A reached end
    int process_b_finished; // Flag indicating B reached end
    int game_over;          // Flag indicating game completion
};

// Simple random number generator
static unsigned int rand_seed = 42;

void srand(unsigned int seed) {
    rand_seed = seed;
}

int rand() {
    rand_seed = rand_seed * 1103515245 + 12345;
    return (rand_seed / 65536) % 32768;
}

// Helper function to convert integer to string
void itoa(int n, char *s) {
    int i, sign;
    if ((sign = n) < 0) n = -n;
    i = 0;
    do {
        s[i++] = n % 10 + '0';
    } while ((n /= 10) > 0);
    if (sign < 0) s[i++] = '-';
    s[i] = '\0';
    
    // Reverse the string
    for (int j = 0, k = i - 1; j < k; j++, k--) {
        char temp = s[j];
        s[j] = s[k];
        s[k] = temp;
    }
}

void setup_maze(struct maze_data *maze) {
    printf("=== Setting up Intertwined Memory Challenge ===\n");
    printf("Maze positions: 0-9 (valid), 10 (END_MARKER)\n\n");
    
    // Initialize random seed
    srand(123);
    
    // Create intertwined paths with logical constraints
    // Each position 0-8 points to a valid next position (0-9)
    // Position 9 points to END_MARKER (10)
    // END_MARKER (10) points to itself
    
    for(int i = 0; i < MAZE_SIZE - 2; i++) {  // 0-8
        maze->path_a[i] = rand() % 10;  // Points to 0-9
        maze->path_b[i] = rand() % 10;  // Points to 0-9
    }
    
    // Position 9 points to END_MARKER for both paths
    maze->path_a[9] = END_MARKER;
    maze->path_b[9] = END_MARKER;
    
    // END_MARKER points to itself
    maze->path_a[END_MARKER] = END_MARKER;
    maze->path_b[END_MARKER] = END_MARKER;
    
    // Initialize process positions
    maze->process_a_pos = 0;  // Both start at position 0
    maze->process_b_pos = 0;
    maze->process_a_finished = 0;
    maze->process_b_finished = 0;
    maze->game_over = 0;
    
    printf("=== MAZE CONFIGURATION ===\n");
    printf("Path A (what A reads gives B's next position):\n");
    for(int i = 0; i < MAZE_SIZE; i++) {
        printf("   Position %d -> %d", i, maze->path_a[i]);
        if(i == END_MARKER) printf(" (END_MARKER)");
        printf("\n");
    }
    
    printf("\nPath B (what B reads gives A's next position):\n");
    for(int i = 0; i < MAZE_SIZE; i++) {
        printf("   Position %d -> %d", i, maze->path_b[i]);
        if(i == END_MARKER) printf(" (END_MARKER)");
        printf("\n");
    }
    printf("==============================\n\n");
}

int main(int argc, char *argv[]) {
    printf("=== The Intertwined Memory Challenge ===\n");
    printf("Master process starting...\n\n");
    
    // Create shared memory for the maze
    int shm_handle = shm_create(1337);
    if(shm_handle < 0) {
        printf("Failed to create shared memory\n");
        exit(1);
    }
    
    // Get pointer to shared memory
    struct maze_data *maze = (struct maze_data*)shm_get(1337);
    if(maze == 0) {
        printf("Failed to get shared memory pointer\n");
        exit(1);
    }
    
    // Setup the maze
    setup_maze(maze);
    
    // Create mailboxes for communication
    int mbox_a_to_b = mbox_create(100);  // A sends to B
    int mbox_b_to_a = mbox_create(101);  // B sends to A
    
    if(mbox_a_to_b < 0 || mbox_b_to_a < 0) {
        printf("Failed to create mailboxes\n");
        exit(1);
    }
    
    printf("Created mailboxes: A->B (ID: %d), B->A (ID: %d)\n", mbox_a_to_b, mbox_b_to_a);
    
    // Fork and exec process A
    int pid_a = fork();
    if(pid_a == 0) {
        char *exec_argv[4];
        exec_argv[0] = "process";
        exec_argv[1] = "A";  // Process type
        exec_argv[2] = "0";  // Starting position
        exec_argv[3] = 0;
        
        exec("process", exec_argv);
        printf("Failed to exec process A\n");
        exit(1);
    }
    
    // Fork and exec process B
    int pid_b = fork();
    if(pid_b == 0) {
        char *exec_argv[4];
        exec_argv[0] = "process";
        exec_argv[1] = "B";  // Process type
        exec_argv[2] = "0";  // Starting position
        exec_argv[3] = 0;
        
        exec("process", exec_argv);
        printf("Failed to exec process B\n");
        exit(1);
    }
    
    printf("Launched processes: A (PID: %d), B (PID: %d)\n", pid_a, pid_b);
    printf("\n=== CHALLENGE STARTED! ===\n");
    printf("Both processes start at position 0\n");
    printf("Goal: Both must reach position 10 (END_MARKER)\n\n");
    
    // Monitor the game progress
    int step = 0;
    while(!maze->game_over) {
        sleep(50);  // Check every 500ms
        step++;
        
        if(step % 10 == 0) {  // Print status every 5 seconds
            printf("--- Status (Step %d) ---\n", step);
            printf("Process A: Position %d", maze->process_a_pos);
            if(maze->process_a_finished) printf(" (FINISHED)");
            printf("\n");
            printf("Process B: Position %d", maze->process_b_pos);
            if(maze->process_b_finished) printf(" (FINISHED)");
            printf("\n\n");
        }
        
        // Check win condition
        if(maze->process_a_finished && maze->process_b_finished) {
            maze->game_over = 1;
            printf("=== CHALLENGE COMPLETED! ===\n");
            printf("Both processes reached the END_MARKER!\n");
            printf("Process A final position: %d\n", maze->process_a_pos);
            printf("Process B final position: %d\n", maze->process_b_pos);
        }
    }
    
    // Wait for child processes to complete
    wait(0);
    wait(0);
    
    printf("\nMaster process: Cleaning up...\n");
    shm_close(1337);
    
    printf("Challenge completed successfully!\n");
    return 0;
}