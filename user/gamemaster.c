#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define MAX_TEAMS 10
#define MAZE_SIZE 8          
#define LOCATION_CAPACITY 2  
#define CONSOLE_LOCK (MAZE_SIZE + MAX_TEAMS * 2) 

// Shared memory structure
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

// Helper function to convert an integer to a string
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

void setup_maze(struct shared_game *game) {
    printf("Setting up race track (length: ");
    printf("%d", MAZE_SIZE);
    printf(")...\n");
    
    for(int i = 0; i < MAZE_SIZE - 1; i++) {
        game->maze_a[i] = i + 1;
        game->maze_b[i] = i + 1;
    }
    
    game->maze_a[MAZE_SIZE-1] = MAZE_SIZE-1;
    game->maze_b[MAZE_SIZE-1] = MAZE_SIZE-1;
    
    printf("Race track: 0 -> 1 -> 2 -> ... -> ");
    printf("%d", MAZE_SIZE-1);
    printf(" (FINISH)\n");
    printf("Players must coordinate to advance through each location.\n");
}

void init_semaphores() {
    printf("Initializing semaphores...\n");
    
    for(int i = 0; i < MAZE_SIZE; i++) {
        if(sem_init(i, LOCATION_CAPACITY) < 0) {
            printf("Failed to initialize location semaphore ");
            printf("%d\n", i);
            exit(1);
        }
    }
    
    for(int team = 0; team < MAX_TEAMS; team++) {
        if(sem_init(MAZE_SIZE + team*2, 0) < 0 ||
           sem_init(MAZE_SIZE + team*2 + 1, 0) < 0) {
            printf("Failed to initialize communication semaphores for team ");
            printf("%d\n", team);
            exit(1);
        }
    }

    if(sem_init(CONSOLE_LOCK, 1) < 0) {
        printf("Failed to initialize console lock semaphore\n");
        exit(1);
    }
    
    printf("Semaphores initialized: ");
    printf("%d", MAZE_SIZE);
    printf(" location + ");
    printf("%d", MAX_TEAMS*2);
    printf(" communication + 1 console lock\n");
}

int main(int argc, char *argv[]) {
    int num_teams = 2;
    
    if(argc > 1) {
        num_teams = atoi(argv[1]);
        if(num_teams <= 0 || num_teams > MAX_TEAMS) {
            printf("Invalid number of teams. Using default: 2\n");
            num_teams = 2;
        }
    }
    
    printf("=== The Indian Grand Prix ===\n");
    printf("Race track length: ");
    printf("%d", MAZE_SIZE);
    printf(" locations (0 to ");
    printf("%d", MAZE_SIZE-1);
    printf(")\n");
    printf("Starting game with ");
    printf("%d", num_teams);
    printf(" teams\n\n");
    
    void *shm = (void*)shm_get(1337);
    if(shm == 0) {
        printf("Failed to get shared memory\n");
        exit(1);
    }
    
    struct shared_game *game = (struct shared_game*)shm;
    
    memset(game, 0, sizeof(struct shared_game));
    game->winner_team = -1;
    game->total_teams = num_teams;
    game->race_step = 0;
    
    setup_maze(game);
    init_semaphores();
    
    for(int i = 0; i < num_teams; i++) {
        game->mailbox[i].a_ready = 0;
        game->mailbox[i].b_ready = 0;
        game->mailbox[i].a_at_finish = 0;
        game->mailbox[i].b_at_finish = 0;
        game->mailbox[i].a_location = 0;
        game->mailbox[i].b_location = 0;
    }
    
    printf("Launching ");
    printf("%d", num_teams);
    printf(" teams...\n");
    
    for(int team = 0; team < num_teams; team++) {
        char team_str[4];
        char player_a_str[] = "A";
        char player_b_str[] = "B";
        char *exec_argv[4];

        itoa(team, team_str);

        exec_argv[0] = "player";
        exec_argv[1] = team_str;
        exec_argv[2] = player_a_str;
        exec_argv[3] = 0;

        int pid_a = fork();
        if(pid_a == 0) {
            exec("player", exec_argv);
            printf("Failed to exec player A for team ");
            printf("%d\n", team);
            exit(1);
        }

        exec_argv[0] = "player";
        exec_argv[1] = team_str;
        exec_argv[2] = player_b_str;
        exec_argv[3] = 0;
        
        int pid_b = fork();
        if(pid_b == 0) {
            exec("player", exec_argv);
            printf("Failed to exec player B for team ");
            printf("%d\n", team);
            exit(1);
        }
        
        printf("Team ");
        printf("%d", team);
        printf(": Player A (PID ");
        printf("%d", pid_a);
        printf("), Player B (PID ");
        printf("%d", pid_b);
        printf(")\n");
    }
    
    sleep(20);
    
    game->game_started = 1;
    
    sem_down(CONSOLE_LOCK);
    printf("\n=== RACE STARTED! ===\n");
    printf("Progress: 0 -> 1 -> 2 -> ... -> ");
    printf("%d", MAZE_SIZE-1);
    printf(" (FINISH)\n\n");
    sem_up(CONSOLE_LOCK);
    
    // Wait for players to start before monitoring
    sleep(100);
    
    int last_step = 0;
    while(game->winner_team == -1) {
        sleep(100);
        
        if(game->race_step > last_step && (game->race_step % 3 == 0)) {
            sem_down(CONSOLE_LOCK);
            printf("\n--- Race Status (Step ");
            printf("%d", game->race_step);
            printf(") ---\n");
            for(int team = 0; team < num_teams; team++) {
                printf("Team ");
                printf("%d", team);
                printf(": A@");
                printf("%d", game->mailbox[team].a_location);
                printf(", B@");
                printf("%d", game->mailbox[team].b_location);
                printf("\n");
            }
            printf("\n");
            sem_up(CONSOLE_LOCK);
            last_step = game->race_step;
        }
        
        for(int team = 0; team < num_teams; team++) {
            if(game->mailbox[team].a_at_finish && game->mailbox[team].b_at_finish) {
                if(game->winner_team == -1) {
                    game->winner_team = team;
                    sem_down(CONSOLE_LOCK);
                    printf("\n=== TEAM ");
                    printf("%d", team);
                    printf(" WINS THE RACE! ===\n");
                    printf("Both players reached location ");
                    printf("%d", MAZE_SIZE-1);
                    printf(" (FINISH)!\n");
                    sem_up(CONSOLE_LOCK);
                }
            }
        }
    }
    
    sleep(200);
    
    sem_down(CONSOLE_LOCK);
    printf("\nRace completed! Final positions:\n");
    for(int team = 0; team < num_teams; team++) {
        printf("Team ");
        printf("%d", team);
        printf(": A@");
        printf("%d", game->mailbox[team].a_location);
        printf(", B@");
        printf("%d", game->mailbox[team].b_location);
        if(team == game->winner_team) {
            printf(" (WINNER)");
        }
        printf("\n");
    }
    printf("\nWaiting for all processes to complete...\n");
    sem_up(CONSOLE_LOCK);
    
    for(int i = 0; i < num_teams * 2; i++) {
        wait(0);
    }
    
    sem_down(CONSOLE_LOCK);
    printf("Game Master shutting down...\n");
    sem_up(CONSOLE_LOCK);
    shm_close(1337);
    
    return 0;
}