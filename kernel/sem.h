struct sem {
  struct spinlock lock;
  int value;
  int key;
  int ref_count;
};
