void processlocks_init();

/// Allocate an unused process lock.
///
/// \return id of allocated process lock,
/// or -1 if all locks are allocated
int processlocks_allocate();

/// Frees allocated process lock.
/// Fails when the process lock is acquired by someone.
///
/// Double free is allowed.
///
/// \return 0 on success
int processlocks_free(int processlock_id);

/// Acquire a process lock.
/// Process is put to sleep until the lock is acquired.
///
/// \return 0 on success
int processlocks_acquire(int processlock_id);

/// Release a process lock.
///
/// \return 0 on success
int processlocks_release(int processlock_id);
