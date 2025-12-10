#ifndef RBT_H
#define RBT_H
#include "memlayout.h"
#include "types.h"
#include "param.h"  
#include "spinlock.h"
#include "proc.h"   
#define RBT_RED 0
#define RBT_BLACK 1

struct rbt_node {
  struct rbt_node *left;
  struct rbt_node *right;
  struct rbt_node *parent;
  unsigned char color;     
  uint64 key_vruntime;      
  int tie_pid;              
  struct proc *p;           
  int in_use;               
};

struct rbt {
  struct rbt_node *root;
  int count;
  struct rbt_node pool[NPROC];
  struct rbt_node *freelist; 
};

void rbt_init(struct rbt *t);
int rbt_insert(struct rbt *t, struct proc *p);
void rbt_remove(struct rbt *t, struct proc *p);
struct proc *rbt_min(struct rbt *t);
struct proc *rbt_pop_min(struct rbt *t);
static inline int rbt_empty(struct rbt *t) { return t->root == 0; }
void rbt_check_invariants(struct rbt *t);
#endif 
