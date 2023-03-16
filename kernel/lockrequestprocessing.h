int catch_error(int lock_id);

void initialize_locks();

int give_lock();

int free_lock(int lock_id);

int acquire_lock(int lock_id);

int release_lock(int lock_id);