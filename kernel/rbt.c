#include "rbt.h"
#include "vm.h"
#include "proc.h"   
#include "spinlock.h"
#include "types.h"
#include "defs.h"
#include "memlayout.h"

static struct rbt_node* rbt_alloc_node(struct rbt *t);
static void rbt_free_node(struct rbt *t, struct rbt_node *n);
static void rbt_left_rotate(struct rbt *t, struct rbt_node *x);
static void rbt_right_rotate(struct rbt *t, struct rbt_node *y);
static void rbt_insert_fixup(struct rbt *t, struct rbt_node *z);
static void rbt_transplant(struct rbt *t, struct rbt_node *u, struct rbt_node *v);
static struct rbt_node* rbt_tree_min_node(struct rbt_node *x);
static void rbt_delete_fixup(struct rbt *t, struct rbt_node *x, struct rbt_node *x_parent);

void
rbt_init(struct rbt *t)
{
  int i;
  t->root = 0;
  t->count = 0;
  t->freelist = 0;
  for(i = 0; i < NPROC; i++){
    t->pool[i].left = t->freelist;
    t->pool[i].in_use = 0;
    t->freelist = &t->pool[i];
    t->pool[i].right = 0;
    t->pool[i].parent = 0;
    t->pool[i].p = 0;
    t->pool[i].color = RBT_BLACK;
  }
}

static struct rbt_node*
rbt_alloc_node(struct rbt *t)
{
  struct rbt_node *n = t->freelist;
  if(!n) return 0;
  t->freelist = n->left; // next
  n->left = n->right = n->parent = 0;
  n->color = RBT_RED;
  n->p = 0;
  n->in_use = 1;
  return n;
}

static void
rbt_free_node(struct rbt *t, struct rbt_node *n)
{
  if(!n) return;
  n->in_use = 0;
  n->p = 0;
  n->left = t->freelist;
  n->right = 0;
  n->parent = 0;
  n->color = RBT_BLACK;
  t->freelist = n;
}

// Compare keys
static int
rbt_cmp(uint64 va, int pa, uint64 vb, int pb)
{
  if(va < vb) return -1;
  if(va > vb) return 1;
  if(pa < pb) return -1;
  if(pa > pb) return 1;
  return 0;
}

static void
rbt_left_rotate(struct rbt *t, struct rbt_node *x)
{
  struct rbt_node *y = x->right;
  x->right = y->left;
  if(y->left) y->left->parent = x;
  y->parent = x->parent;
  if(!x->parent) t->root = y;
  else if(x == x->parent->left) x->parent->left = y;
  else x->parent->right = y;
  y->left = x;
  x->parent = y;
}

static void
rbt_right_rotate(struct rbt *t, struct rbt_node *y)
{
  struct rbt_node *x = y->left;
  y->left = x->right;
  if(x->right) x->right->parent = y;
  x->parent = y->parent;
  if(!y->parent) t->root = x;
  else if(y == y->parent->right) y->parent->right = x;
  else y->parent->left = x;
  x->right = y;
  y->parent = x;
}

int
rbt_insert(struct rbt *t, struct proc *p)
{
  if(!p) return -1;
  struct rbt_node *z = rbt_alloc_node(t);
  if(!z) return -1;

  z->key_vruntime = p->vruntime;
  z->tie_pid = p->pid;
  z->p = p;

  // standard BST insert
  struct rbt_node *y = 0;
  struct rbt_node *x = t->root;
  while(x){
    y = x;
    int cmp = rbt_cmp(z->key_vruntime, z->tie_pid, x->key_vruntime, x->tie_pid);
    if(cmp < 0) x = x->left;
    else x = x->right;
  }
  z->parent = y;
  if(!y) t->root = z;
  else{
    int cmp = rbt_cmp(z->key_vruntime, z->tie_pid, y->key_vruntime, y->tie_pid);
    if(cmp < 0) y->left = z;
    else y->right = z;
  }

  rbt_insert_fixup(t, z);
  t->count++;
  return 0;
}

static void
rbt_insert_fixup(struct rbt *t, struct rbt_node *z)
{
  while(z->parent && z->parent->color == RBT_RED){
    if(z->parent == z->parent->parent->left){
      struct rbt_node *y = z->parent->parent->right;
      if(y && y->color == RBT_RED){
        z->parent->color = RBT_BLACK;
        y->color = RBT_BLACK;
        z->parent->parent->color = RBT_RED;
        z = z->parent->parent;
      } else {
        if(z == z->parent->right){
          z = z->parent;
          rbt_left_rotate(t, z);
        }
        z->parent->color = RBT_BLACK;
        z->parent->parent->color = RBT_RED;
        rbt_right_rotate(t, z->parent->parent);
      }
    } else {
      struct rbt_node *y = z->parent->parent->left;
      if(y && y->color == RBT_RED){
        z->parent->color = RBT_BLACK;
        y->color = RBT_BLACK;
        z->parent->parent->color = RBT_RED;
        z = z->parent->parent;
      } else {
        if(z == z->parent->left){
          z = z->parent;
          rbt_right_rotate(t, z);
        }
        z->parent->color = RBT_BLACK;
        z->parent->parent->color = RBT_RED;
        rbt_left_rotate(t, z->parent->parent);
      }
    }
  }
  t->root->color = RBT_BLACK;
}

//walk the tree
static struct rbt_node*
rbt_find_node_by_proc(struct rbt *t, struct proc *p)
{
  if(!p) return 0;
  struct rbt_node *x = t->root;
  while(x){
    int cmp = rbt_cmp(p->vruntime, p->pid, x->key_vruntime, x->tie_pid);
    if(cmp == 0){
      if(x->p == p) return x;
      struct rbt_node *l = x->left;
      struct rbt_node *r = x->right;
      //struct rbt_node *res = 0;
      struct rbt_node *stack[NPROC];
      int sp = 0;
      if(l){ stack[sp++] = l; }
      while(sp){
        struct rbt_node *n = stack[--sp];
        if(n->p == p) return n;
        if(n->left) stack[sp++] = n->left;
        if(n->right) stack[sp++] = n->right;
      }
      sp = 0;
      if(r){ stack[sp++] = r; }
      while(sp){
        struct rbt_node *n = stack[--sp];
        if(n->p == p) return n;
        if(n->left) stack[sp++] = n->left;
        if(n->right) stack[sp++] = n->right;
      }
      return 0;
    } else if(cmp < 0) x = x->left;
    else x = x->right;
  }
  return 0;
}

void
rbt_remove(struct rbt *t, struct proc *p)
{
  if(!p) return;
  struct rbt_node *z = rbt_find_node_by_proc(t, p);
  if(!z) return; // not found

  struct rbt_node *y = z;
  struct rbt_node *x;
  unsigned char y_original_color = y->color;
  if(!z->left){
    x = z->right;
    rbt_transplant(t, z, z->right);
  } else if(!z->right){
    x = z->left;
    rbt_transplant(t, z, z->left);
  } else {
    y = rbt_tree_min_node(z->right);
    y_original_color = y->color;
    x = y->right;
    if(y->parent == z){
      if(x) x->parent = y;
    } else {
      rbt_transplant(t, y, y->right);
      y->right = z->right;
      if(y->right) y->right->parent = y;
    }
    rbt_transplant(t, z, y);
    y->left = z->left;
    if(y->left) y->left->parent = y;
    y->color = z->color;
  }

  if(y_original_color == RBT_BLACK){
    rbt_delete_fixup(t, x, (x?x->parent:0));
  }

  // free node z 
  rbt_free_node(t, z);
  t->count--;
}

// transplant subtree u -> v
static void
rbt_transplant(struct rbt *t, struct rbt_node *u, struct rbt_node *v)
{
  if(!u->parent) t->root = v;
  else if(u == u->parent->left) u->parent->left = v;
  else u->parent->right = v;
  if(v) v->parent = u->parent;
}

static struct rbt_node*
rbt_tree_min_node(struct rbt_node *x)
{
  while(x && x->left) x = x->left;
  return x;
}

// delete fixup
static void
rbt_delete_fixup(struct rbt *t, struct rbt_node *x, struct rbt_node *x_parent)
{
  while((x != t->root) && (x == 0 || x->color == RBT_BLACK)){
    struct rbt_node *w;
    if(x_parent && x_parent->left == x){
      w = x_parent->right;
      if(w && w->color == RBT_RED){
        w->color = RBT_BLACK;
        x_parent->color = RBT_RED;
        rbt_left_rotate(t, x_parent);
        w = x_parent->right;
      }
      if((!w) || (( (!w->left) || (w->left->color == RBT_BLACK)) && ((!w->right) || (w->right->color == RBT_BLACK)))){
        if(w) w->color = RBT_RED;
        x = x_parent;
        x_parent = x ? x->parent : 0;
      } else {
        if((!w->right) || (w->right->color == RBT_BLACK)){
          if(w->left) w->left->color = RBT_BLACK;
          w->color = RBT_RED;
          rbt_right_rotate(t, w);
          w = x_parent->right;
        }
        if(w) w->color = x_parent->color;
        x_parent->color = RBT_BLACK;
        if(w && w->right) w->right->color = RBT_BLACK;
        rbt_left_rotate(t, x_parent);
        x = t->root;
        break;
      }
    } else {
      w = x_parent ? x_parent->left : 0;
      if(w && w->color == RBT_RED){
        w->color = RBT_BLACK;
        if(x_parent){ x_parent->color = RBT_RED; rbt_right_rotate(t, x_parent); }
        w = x_parent ? x_parent->left : 0;
      }
      if((!w) || (((!w->right) || (w->right->color == RBT_BLACK)) && ((!w->left) || (w->left->color == RBT_BLACK)))){
        if(w) w->color = RBT_RED;
        x = x_parent;
        x_parent = x ? x->parent : 0;
      } else {
        if((!w->left) || (w->left->color == RBT_BLACK)){
          if(w->right) w->right->color = RBT_BLACK;
          w->color = RBT_RED;
          rbt_left_rotate(t, w);
          w = x_parent ? x_parent->left : 0;
        }
        if(w) w->color = x_parent ? x_parent->color : RBT_BLACK;
        if(x_parent) x_parent->color = RBT_BLACK;
        if(w && w->left) w->left->color = RBT_BLACK;
        if(x_parent) rbt_right_rotate(t, x_parent);
        x = t->root;
        break;
      }
    }
  }
  if(x) x->color = RBT_BLACK;
}

struct proc*
rbt_min(struct rbt *t)
{
  if(!t->root) return 0;
  struct rbt_node *n = rbt_tree_min_node(t->root);
  return n ? n->p : 0;
}

struct proc*
rbt_pop_min(struct rbt *t)
{
  struct rbt_node *n = rbt_tree_min_node(t->root);
  if(!n) return 0;
  struct proc *p = n->p;
  rbt_remove(t, p);
  return p;
}

void
rbt_check_invariants(struct rbt *t)
{
  int used = 0;
  for(int i = 0; i < NPROC; i++) if(t->pool[i].in_use) used++;
  (void)used;
}
