#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define MAZE_SIZE 11
#define END_MARKER 10

// Same structure as in master.c
struct maze_data {
    int path_a[MAZE_SIZE];
    int path_b[MAZE_SIZE];
    int process_a_pos;
    int process_b_pos;
    int process_a_finished;
    int process_b_finished;
    int game_over;
};

void process_printf(char process_type, char* msg, int val) {
    printf("Process %c: %s %d\n", process_type, msg, val);
}

void process_printf_simple(char process_type, char* msg) {
    printf("Process %c: %s\n", process_type, msg);
}

int main(int argc, char *argv[]) {
    if(argc != 3) {
        printf("Usage: process <type> <start_pos>\n");
        exit(1);
    }
    
    char process_type = argv[1][0];  // 'A' or 'B'
    int start_pos = atoi(argv[2]);
    
    if(process_type != 'A' && process_type != 'B') {
        printf("Invalid process type. Must be A or B\n");
        exit(1);
    }
    
    // Attach to shared memory
    struct maze_data *maze = (struct maze_data*)shm_get(1337);
    if(maze == 0) {
        printf("Failed to attach to shared memory\n");
        exit(1);
    }
    
    // Determine mailbox IDs based on process type
    int send_mbox, recv_mbox;
    if(process_type == 'A') {
        send_mbox = 100;  // A sends to mailbox 100 (A->B)
        recv_mbox = 101;  // A receives from mailbox 101 (B->A)
    } else {
        send_mbox = 101;  // B sends to mailbox 101 (B->A)
        recv_mbox = 100;  // B receives from mailbox 100 (A->B)
    }
    
    process_printf_simple(process_type, "Starting challenge");
    process_printf(process_type, "Initial position:", start_pos);
    
    int current_pos = start_pos;
    int steps = 0;
    
    // Update initial position in shared memory
    if(process_type == 'A') {
        maze->process_a_pos = current_pos;
    } else {
        maze->process_b_pos = current_pos;
    }
    
    // Main traversal loop
    while(!maze->game_over && current_pos != END_MARKER) {
        steps++;
        
        /*
         * DEADLOCK AVOIDANCE STRATEGY:
         * Process A always sends first, then receives
         * Process B always receives first, then sends
         * This ensures no circular wait condition
         */
        
        if(process_type == 'A') {
            // Process A: Send first, then receive
            process_printf(process_type, "Sending current position to B:", current_pos);
            if(mbox_send(send_mbox, current_pos) < 0) {
                process_printf_simple(process_type, "Failed to send message");
                break;
            }
            
            int teammate_pos;
            process_printf_simple(process_type, "Waiting for B's position...");
            if(mbox_recv(recv_mbox, &teammate_pos) < 0) {
                process_printf_simple(process_type, "Failed to receive message");
                break;
            }
            process_printf(process_type, "Received B's position:", teammate_pos);
            
            // Look up next position from B's location in path_b
            int next_pos = maze->path_b[teammate_pos];
            process_printf(process_type, "My next position (from B's path):", next_pos);
            
            current_pos = next_pos;
            maze->process_a_pos = current_pos;
            
        } else {
            // Process B: Receive first, then send
            int teammate_pos;
            process_printf_simple(process_type, "Waiting for A's position...");
            if(mbox_recv(recv_mbox, &teammate_pos) < 0) {
                process_printf_simple(process_type, "Failed to receive message");
                break;
            }
            process_printf(process_type, "Received A's position:", teammate_pos);
            
            process_printf(process_type, "Sending current position to A:", current_pos);
            if(mbox_send(send_mbox, current_pos) < 0) {
                process_printf_simple(process_type, "Failed to send message");
                break;
            }
            
            // Look up next position from A's location in path_a
            int next_pos = maze->path_a[teammate_pos];
            process_printf(process_type, "My next position (from A's path):", next_pos);
            
            current_pos = next_pos;
            maze->process_b_pos = current_pos;
        }
        
        process_printf(process_type, "Moved to position:", current_pos);
        
        // Check if reached end marker
        if(current_pos == END_MARKER) {
            process_printf_simple(process_type, "REACHED END_MARKER!");
            if(process_type == 'A') {
                maze->process_a_finished = 1;
            } else {
                maze->process_b_finished = 1;
            }
            break;
        }
        
        // Add some delay for readability
        sleep(30);
    }
    
    // Final status
    process_printf(process_type, "Completed in steps:", steps);
    process_printf(process_type, "Final position:", current_pos);
    
    if(current_pos == END_MARKER) {
        process_printf_simple(process_type, "SUCCESS: Reached the end!");
    } else {
        process_printf_simple(process_type, "Challenge incomplete");
    }
    
    // Wait a bit before closing
    sleep(50);
    
    // Clean up
    shm_close(1337);
    process_printf_simple(process_type, "Process terminating");
    
    return 0;
}