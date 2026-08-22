#include "kernel/types.h"
#include "user.h"

int main(void)
{
	int ping[2];
  int pong[2];
  (void)pipe(ping);
  (void)pipe(pong);

	int pid = fork();
	if (pid == 0) {
    // close and dup stdin to ping's readend
    close(0);
    (void)dup(ping[0]);

    // close read and write end before catting
    close(ping[0]);
    close(ping[1]);

    // write pong message and close before catting
    char msg[] = "pong\n";
    (void)write(pong[1], msg, sizeof(msg));
    close(pong[0]);
    close(pong[1]);

    char *argv[] = { "cat", 0 };
    exec("cat", argv);
	} else if (pid > 0) {
    // write ping message needs to happen before waiting or it'll deadlock
    char msg[] = "ping\n";
    (void)write(ping[1], msg, sizeof(msg));
    close(ping[0]);
    close(ping[1]);

    // wait for child
    wait(0);

    // redirect pong to cat
    close(0);
    (void)dup(pong[0]);

    // close fds before catting
    close(pong[0]);
    close(pong[1]);

    // cat pong message
    char *argv[] = { "cat", 0 };
    exec("cat", argv);
  }

  exit(0);
}
