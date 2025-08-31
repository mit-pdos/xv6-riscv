#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define MAX_TEAMS 10
#define MAZE_SIZE 8
#define CONSOLE_LOCK (MAZE_SIZE + MAX_TEAMS * 2)

// Same shared memory structure as gamemaster
struct shared_game {
    int maze_a[MAZE_SIZE];
    int maze_b[MAZE_SIZE];
    
    struct {
        int a_to_b;
        int b_to_a;
        int a_ready;
        int b_ready;
        int a_at_finish;
        int b_at_finish;
        int a_location;
        int b_location;
    } mailbox[MAX_TEAMS];
    
    int winner_team;
    int game_started;
    int total_teams;
    int race_step;
};

// Simple, safe printf functions
void player_printf_simple(int team, char player, char *msg) {
    sem_down(CONSOLE_LOCK);
    printf("T");
    printf("%d", team);
    printf(player == 'A' ? "A: " : "B: ");
    printf("%s", msg);
    printf("\n");
    sem_up(CONSOLE_LOCK);
}

void player_printf_with_int(int team, char player, char *msg, int val) {
    sem_down(CONSOLE_LOCK);
    printf("T");
    printf("%d", team);
    printf(player == 'A' ? "A: " : "B: ");
    printf("%s", msg);
    printf(" ");
    printf("%d", val);
    printf("\n");
    sem_up(CONSOLE_LOCK);
}

void player_printf_movement(int team, char player, int from, int to) {
    sem_down(CONSOLE_LOCK);
    printf("T");
    printf("%d", team);
    printf(player == 'A' ? "A: " : "B: ");
    printf("Moving ");
    printf("%d", from);
    printf(" -> ");
    printf("%d", to);
    printf("\n");
    sem_up(CONSOLE_LOCK);
}

void send_message_to_teammate(struct shared_game *game, int team_id, char player_type, int message) {
    if(player_type == 'A') {
        game->mailbox[team_id].a_to_b = message;
        game->mailbox[team_id].a_ready = 1;
        sem_up(MAZE_SIZE + team_id * 2); // Signal B
    } else {
        game->mailbox[team_id].b_to_a = message;
        game->mailbox[team_id].b_ready = 1;
        sem_up(MAZE_SIZE + team_id * 2 + 1); // Signal A
    }
}

int receive_message_from_teammate(struct shared_game *game, int team_id, char player_type) {
    int message;
    
    if(player_type == 'A') {
        sem_down(MAZE_SIZE + team_id * 2 + 1); // Wait for B
        while(!game->mailbox[team_id].b_ready) {
            sleep(1);
        }
        message = game->mailbox[team_id].b_to_a;
        game->mailbox[team_id].b_ready = 0;
    } else {
        sem_down(MAZE_SIZE + team_id * 2); // Wait for A
        while(!game->mailbox[team_id].a_ready) {
            sleep(1);
        }
        message = game->mailbox[team_id].a_to_b;
        game->mailbox[team_id].a_ready = 0;
    }
    
    return message;
}

int main(int argc, char *argv[]) {
    if(argc != 3) {
        printf("Usage: player <team_id> <player_type>\n");
        exit(1);
    }
    
    int team_id = atoi(argv[1]);
    char player_type = argv[2][0];
    
    if(team_id < 0 || team_id >= MAX_TEAMS || (player_type != 'A' && player_type != 'B')) {
        printf("Invalid team ID or player type\n");
        exit(1);
    }
    
    void *shm = (void*)shm_get(1337);
    if(shm == 0) {
        printf("Failed to get shared memory\n");
        exit(1);
    }
    
    struct shared_game *game = (struct shared_game*)shm;
    
    // Wait for game to start
    while(!game->game_started) {
        sleep(10);
    }
    
    // Stagger player start messages to reduce output collision
    sleep((team_id * 20) + (player_type == 'B' ? 15 : 0));
    
    player_printf_simple(team_id, player_type, "Starting race");
    
    int current_location = 0;
    int steps = 0;
    
    // Update initial location
    if(player_type == 'A') {
        game->mailbox[team_id].a_location = current_location;
    } else {
        game->mailbox[team_id].b_location = current_location;
    }
    
    // Main race loop
    while(game->winner_team == -1 && current_location < MAZE_SIZE - 1) {
        steps++;
        if(player_type == 'A') {
            game->race_step = steps;
        }
        
        // Try to acquire location semaphore
        sem_down(current_location);
        
        // Update location in shared memory
        if(player_type == 'A') {
            game->mailbox[team_id].a_location = current_location;
        } else {
            game->mailbox[team_id].b_location = current_location;
        }
        
        // Get next location for teammate from maze
        int teammate_next_location;
        if(player_type == 'A') {
            teammate_next_location = game->maze_a[current_location];
        } else {
            teammate_next_location = game->maze_b[current_location];
        }
        
        // DEADLOCK AVOIDANCE: Release location before communicating
        sem_up(current_location);
        
        // Send message to teammate
        send_message_to_teammate(game, team_id, player_type, teammate_next_location);
        
        // Receive message from teammate
        int next_location = receive_message_from_teammate(game, team_id, player_type);
        
        // Move to next location
        if(next_location != current_location) {
            player_printf_movement(team_id, player_type, current_location, next_location);
            current_location = next_location;
        }
        
        // Simulate movement time with some variation
        sleep(50 + (team_id * 15) + (player_type == 'B' ? 10 : 0));
        
        // Check if we've reached the finish
        if(current_location >= MAZE_SIZE - 1) {
            current_location = MAZE_SIZE - 1;
            break;
        }
    }
    
    // Handle finish line
    if(current_location >= MAZE_SIZE - 1) {
        player_printf_with_int(team_id, player_type, "REACHED FINISH at position", MAZE_SIZE - 1);
        
        // Acquire finish line location
        sem_down(MAZE_SIZE - 1);
        
        // Mark as finished
        if(player_type == 'A') {
            game->mailbox[team_id].a_at_finish = 1;
            game->mailbox[team_id].a_location = MAZE_SIZE - 1;
        } else {
            game->mailbox[team_id].b_at_finish = 1;
            game->mailbox[team_id].b_location = MAZE_SIZE - 1;
        }
        
        // Release finish line location
        sem_up(MAZE_SIZE - 1);
    }
    
    // Wait and stagger final messages
    sleep(100 + (team_id * 30) + (player_type == 'B' ? 20 : 0));
    
    // Report results
    if(game->winner_team == team_id) {
        player_printf_simple(team_id, player_type, "WE WON!");
    } else if(game->winner_team != -1) {
        player_printf_with_int(team_id, player_type, "Race won by team", game->winner_team);
    }
    
    player_printf_with_int(team_id, player_type, "Completed in steps", steps);
    shm_close(1337);
    
    return 0;
}