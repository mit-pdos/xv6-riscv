#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

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

int main(int argc, char *argv[]) {
    int num_teams = 10; // Default
    
    if(argc > 1) {
        num_teams = atoi(argv[1]);
    }
    
    printf("Launching Indian Grand Prix with %d teams...\n", num_teams);
    
    int pid = fork();
    if(pid == 0) {
        char teams_str[4];
        char *exec_argv[3];

        itoa(num_teams, teams_str);
        
        exec_argv[0] = "gamemaster";
        exec_argv[1] = teams_str;
        exec_argv[2] = 0;
        
        exec("gamemaster", exec_argv);
        printf("Failed to exec gamemaster\n");
        exit(1);
    }
    
    wait(0);
    printf("Race completed!\n");
    return 0;
}
