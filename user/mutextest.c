#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

static int nfail;

static void ok(const char *msg)
{
  printf("OK: %s\n", msg);
}

static void fail(const char *msg)
{
  printf("FAIL: %s\n", msg);
  nfail++;
}

static void check_nlive(const char *where)
{
  int n;

  n = mutex_debug(-1);
  if (n != 0) {
    printf("ОШИБКА в «%s»: mutex_debug(-1) nlive=%d (ожидалось 0)\n", where, n);
    nfail++;
  }
}

int main(int argc, char *argv[])
{
  int fd, pid, st;
  char buf[4];
  struct stat stbuf;
  int sync[2];

  (void)argc;
  (void)argv;

  mutex_debug(1);

  fd = mutex();
  if (fd < 0) {
    fail("mutex()");
    exit(1);
  }

  if (read(fd, buf, 1) != -1)
    fail("read для мьютекса должен возвращать -1");

  if (write(fd, "x", 1) != -1)
    fail("write для мьютекса должен возвращать -1");

  if (fstat(fd, &stbuf) != -1)
    fail("fstat для мьютекса должен возвращать -1");

  close(fd);
  check_nlive("после read/write/fstat");

  fd = mutex();
  if (fd < 0 || mutex_lock(fd) != 0) {
    fail("mutex + lock (1) закрытие захваченного своим процессом");
    exit(1);
  }

  close(fd);
  check_nlive("после теста 1");

  fd = mutex();
  if (fd < 0) {
    fail("mutex()");
    exit(1);
  }

  if (pipe(sync) < 0) {
    fail("pipe");
    close(fd);
    exit(1);
  }

  pid = fork();

  if (pid < 0) {
    fail("fork");
    close(fd);
    close(sync[0]);
    close(sync[1]);
    exit(1);
  }

  if (pid == 0) {
    close(sync[1]);

    if (read(sync[0], buf, 1) != 1)
      exit(2);

    close(sync[0]);
    st = (mutex_unlock(fd) == -1) ? 0 : 1;
    close(fd);
    exit(st);
  }

  close(sync[0]);
  if (mutex_lock(fd) != 0) {
    fail("блокировка родителем");
    close(sync[1]);
    close(fd);
    wait(0);
    exit(1);
  }

  if (write(sync[1], "g", 1) != 1) {
    fail("запись в pipe синхронизации");
    close(sync[1]);
    mutex_unlock(fd);
    close(fd);
    wait(0);
    exit(1);
  }

  close(sync[1]);
  wait(&st);
  if (st != 0)
    fail("child: unlock при удержании другим процессом должен дать ошибку");

  mutex_unlock(fd);
  close(fd);
  check_nlive("после теста 1");

  fd = mutex();
  if (fd < 0) {
    fail("mutex()");
    exit(1);
  }

  pid = fork();
  if (pid < 0) {
    fail("fork()");
    close(fd);
    exit(1);
  }

  if (pid == 0) {
    close(fd);
    exit(0);
  }

  if (mutex_lock(fd) != 0) {
    fail("блокировка родителем");
    close(fd);
    wait(0);
    exit(1);
  }

  wait(0);
  mutex_unlock(fd);
  close(fd);
  check_nlive("после теста 2 потомок закрыл свою копию fd");

  fd = mutex();
  if (fd < 0) {
    fail("mutex()");
    exit(1);
  }

  pid = fork();
  if (pid < 0) {
    fail("fork()");
    close(fd);
    exit(1);
  }

  if (pid == 0) {
    exit(0);
  }

  wait(0);
  close(fd);
  check_nlive("после exit потомка с незакрытым мьютексом");

  if (pipe(sync) < 0) {
    fail("pipe()");
    exit(1);
  }

  fd = mutex();
  if (fd < 0) {
    fail("mutex()");
    close(sync[0]);
    close(sync[1]);
    exit(1);
  }

  pid = fork();
  if (pid < 0) {
    fail("fork()");
    close(fd);
    close(sync[0]);
    close(sync[1]);
    exit(1);
  }

  if (pid == 0) {
    close(sync[0]);

    if (mutex_lock(fd) != 0)
      exit(3);

    if (write(sync[1], "g", 1) != 1)
      exit(4);

    pause(100);
    exit(0);
  }

  close(sync[1]);
  if (read(sync[0], buf, 1) != 1) {
    fail("чтение из pipe синхронизации");
    close(sync[0]);
    close(fd);
    wait(0);
    exit(1);
  }

  close(sync[0]);
  if (mutex_lock(fd) != 0)
    fail("родитель должен получить lock после exit");

  mutex_unlock(fd);
  close(fd);
  wait(0);
  check_nlive("после теста 4");

  mutex_debug(0);
  if (mutex_debug(-1) != 0)
    fail("nlive после всех тестов (ожидалось 0)");

  if (nfail == 0)
    ok("все тесты пройдены успешно");
  else
    printf("mutextest: неудачные проверки: %d\n", nfail);

  exit(nfail == 0 ? 0 : 1);
}
