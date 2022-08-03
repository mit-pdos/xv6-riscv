#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include "kernel/termios.h"

// screen
//  statusbar is append after SCREEN_HEIGHT screen
//  actual screen height is SCREEN_HEIGHT+1
#define SCREEN_WIDTH  30
#define SCREEN_HEIGHT 20

// line buffer length
#define LINE_BUFFER_LENGTH 128

// mode
#define MODE_NORMAL 1
#define MODE_INSERT 2

// statusbar
#define STATUSBAR_VISIBLE 1
#define STATUSBAR_HIDE    2
#define STATUSBAR_MESSAGE_LENGTH 64
#define STATUSBAR_MESSAGE_START  11

// keycode
#define KEYCODE_ESC  0x1b
#define KEYCODE_LF   0x0A
#define KEYCODE_CR   0x0D
#define KEYCODE_DEL  0x7f
#define KEYCODE_AT   0x40

// esc sequence
#define term_cursor_location(x,y) fprintf(stdout, "\033[%d;%dH" ,y,x)

// globals
int mode;
int command;
int quit_flg;

struct linebuffer{
  char *buf;
  int  size;
  struct linebuffer *prev;
  struct linebuffer *next;
} linebuffer_head, linebuffer_tail;

struct cursor{
  int x;
  int y;
  struct linebuffer *linebuffer;
} cursor;

struct statusbar{
  int  visibility;
  char mode[16];
  char msg[STATUSBAR_MESSAGE_LENGTH];
  int  msglength;
} statusbar;

struct screen{
  int line;
  struct linebuffer *upperline;
}screen;

struct termios termios;

char inputfilename[64];
char outputfilename[64];

// protos
void save();
void load();
void quit();

// screen
void screen_init(){
  screen.upperline = linebuffer_head.next;
  screen.line = 1;
}
void screen_up(){
  if(screen.upperline->prev == &linebuffer_head)
    return;
  screen.upperline = screen.upperline->prev;
  screen.line--;
}
void screen_down(){
  if(screen.upperline->next == &linebuffer_tail)
    return;
  screen.upperline = screen.upperline->next;
  screen.line++;
}
int is_screen_up(){
  return screen.upperline->prev == cursor.linebuffer;
}
int is_screen_down(){
  int i;
  struct linebuffer *lbp;

  lbp = screen.upperline;
  for(i=1; i<SCREEN_HEIGHT; i++){
    lbp = lbp->next;
  }
  return lbp->next == cursor.linebuffer;
}
struct linebuffer *screen_top(){
  int i;
  struct linebuffer *top;

  top = &linebuffer_head;
  for(i=0; i<screen.line; i++){
    top = top->next;
  }
  return top;
}

//cursor
void cursor_init(struct linebuffer *lbp){
  cursor.x          = 0;
  cursor.y          = 1;
  cursor.linebuffer = lbp;
}
void terminal_cursor_update(){
  if(command){
    term_cursor_location(STATUSBAR_MESSAGE_START+statusbar.msglength, SCREEN_HEIGHT+1);
    fflush(stdout);
  }else{
    term_cursor_location(cursor.x+1, cursor.y-screen.line+1);
    fflush(stdout);
  }
}
void cursor_up(){
  if(cursor.linebuffer->prev == &linebuffer_head)
    return;
  cursor.linebuffer = cursor.linebuffer->prev;
  cursor.y--;
  if(cursor.x >= cursor.linebuffer->size)
    cursor.x = cursor.linebuffer->size;

  if(is_screen_up())
    screen_up();
}
void cursor_down(){
  if(cursor.linebuffer->next == &linebuffer_tail)
    return;
  cursor.linebuffer = cursor.linebuffer->next;
  cursor.y++;
  if(cursor.x >= cursor.linebuffer->size)
    cursor.x = cursor.linebuffer->size;

  if(is_screen_down())
    screen_down();
}
void cursor_left(){
  if(cursor.x > 0)
    cursor.x--;
}
void cursor_right(){
  if(cursor.x < cursor.linebuffer->size)
    cursor.x++;
}

// debug, dump

/*
void dump(){
  struct linebuffer *lbp;

  fprintf(stdout, "\n=== dump ===\n");

  lbp = &linebuffer_head;
  fprintf(stdout, "---buffer---\n");
  while(lbp != &linebuffer_tail){
    fprintf(stdout, "%s", lbp->buf);
    lbp = lbp->next;
  }
  fprintf(stdout, ":::buffer:::\n");
  fprintf(stdout, "---cursor---\n");
  fprintf(stdout, "x:%d, y:%d, line:%s\n", cursor.x, cursor.y, cursor.linebuffer->buf);
  fprintf(stdout, ":::cursor:::\n");
//  fprintf(stdout, "---command---\n");
//  fprintf(stdout, "%d\n", command);
//  fprintf(stdout, ":::command:::\n");
}
*/

// display
void display(struct linebuffer *head){
  int i, v;
  int last1istail = 0, last2istail = 0;
  struct linebuffer *lbp;

  v = statusbar.visibility == STATUSBAR_VISIBLE;
  i = v ? SCREEN_HEIGHT : SCREEN_HEIGHT-1;
  lbp = head;

  term_cursor_location(0,0);
  fprintf(stdout,"\033[2J");
  while(i-->0){
    fprintf(stdout, "%s", lbp->buf);
    lbp = lbp->next;
    if(i == 2 && lbp == &linebuffer_tail)
      last2istail = 1;
    if(i == 1 && lbp == &linebuffer_tail)
      last1istail = 1;
  }

  if(last1istail && last2istail)
    fprintf(stdout, "~\n");

  if(v)
    fprintf(stdout, "%s  %s", statusbar.mode, statusbar.msg);

  // for debug
  // dump();

  terminal_cursor_update();
}

// status bar
void set_statusbar_mode(char *m){
  strcpy(statusbar.mode, m);
}
void statusbar_init(){
  set_statusbar_mode("[normal]");
  statusbar.visibility = STATUSBAR_VISIBLE;
  statusbar.msglength  = 0;
}
void set_statusbar_message(char *m){
  int i=0;
  while(*(m+i) != '\0') i++;

  statusbar.msglength = i;
  strcpy(statusbar.msg, m);
}
void set_statusbar_visibility(int v){
  statusbar.visibility = v;
}
void insert_statusbar_message(char c){
  int i;
  for(i=0; i+1<STATUSBAR_MESSAGE_LENGTH; i++){
    if(statusbar.msg[i] == '\0'){
      statusbar.msglength++;
      statusbar.msg[i] = c;
      statusbar.msg[i+1] = '\0';
      return;
    }
  }
}
void clear_statusbar_message(){
  statusbar.msg[0] = '\0';
  statusbar.msglength = 0;
}

void statusbar_command_begin(){
  command = 1;
  set_statusbar_message(":");
}
void statusbar_command_end(){
  command = 0;
  clear_statusbar_message();
}
void statusbar_command_exec(){
  int i;
  char *arg1, *arg2;


  i=0;
  while((statusbar.msg[i] == ' ' || statusbar.msg[i] == ':') && statusbar.msg[i] != '\0') i++;
  arg1 = statusbar.msg+i;

  if(statusbar.msg[i] != '\0')
    i++;

  while(statusbar.msg[i] == ' ' && statusbar.msg[i] != '\0') i++;
  arg2 = statusbar.msg+i;

  switch(*arg1){
  case 'e':
    if(*arg2 != '\0'){
      strcpy(inputfilename, arg2);
      load();
    }
    break;
  case 'w':
    if(*arg2 != '\0')
      strcpy(outputfilename, arg2);
    else
      strcpy(outputfilename, "default.viout");
    save();
    break;
  case 'q':
    quit();
    break;
  default:
    break;
  }
  clear_statusbar_message();
}

void error(char *msg){
  set_statusbar_message(msg);
}

// buffer
void link_linebuffer(struct linebuffer *l, struct linebuffer *r){
  l->next = r;
  r->prev = l;
}
void alloc_linebuffer(struct linebuffer *lb){
  lb->buf  = malloc(LINE_BUFFER_LENGTH);
  lb->size = 0;
  lb->prev = 0;
  lb->next = 0;
}
struct linebuffer *create_linebuffer(){
  struct linebuffer *lbp;
  lbp = malloc(sizeof(struct linebuffer));
  alloc_linebuffer(lbp);
  return lbp;
}

// mode
void mode_change(int m){
  mode = m;
  switch(m){
  case MODE_INSERT:
    set_statusbar_mode("[insert]");
    return;
  case MODE_NORMAL:
    set_statusbar_mode("[normal]");
    return;
  }
}

void delete_normal(){
  if(*(cursor.linebuffer->buf+cursor.x) == '\n' || cursor.x == cursor.linebuffer->size)
    return;
  memmove(cursor.linebuffer->buf+cursor.x, cursor.linebuffer->buf+cursor.x+1, cursor.linebuffer->size-cursor.x);

  cursor.linebuffer->buf[cursor.linebuffer->size] = '\0';
  if(cursor.linebuffer->size > 0)
    cursor.linebuffer->size--;

  if(cursor.x >= cursor.linebuffer->size)
    cursor_left();
}
void deleteline_normal(){
  struct linebuffer *p, *n;

  p = cursor.linebuffer->prev;
  n = cursor.linebuffer->next;

  if(p == &linebuffer_head && n == &linebuffer_tail){
    memset(cursor.linebuffer->buf, '\0', sizeof(cursor.linebuffer->buf));
    cursor.linebuffer->size = 0;
    return;
  }

  link_linebuffer(p,n);

  free(cursor.linebuffer->buf);
  free(cursor.linebuffer);

  if(n != &linebuffer_tail){
    cursor.linebuffer = n;
  }else{
    cursor_up();
    cursor.linebuffer = p;
  }
}

void save(){
  FILE *ofile;
  struct linebuffer *lbp;

  ofile = fopen(outputfilename, "w+");

  lbp = linebuffer_head.next;
  while(lbp != &linebuffer_tail){
    fprintf(ofile, "%s", lbp->buf);
    lbp = lbp->next;
  }
  fclose(ofile);
}

void load(){
  FILE *ifile;
  char buf[LINE_BUFFER_LENGTH];
  //int len;
  struct linebuffer *lbp,*lbpnext;

  ifile = fopen(inputfilename, "r");
  if(ifile == 0) return;

  lbp  = &linebuffer_head;
  while(fgets(buf, sizeof(buf), ifile) != 0){
    lbpnext = create_linebuffer();
    strcpy(lbpnext->buf, buf);
    lbpnext->size = strlen(buf)-1;
    link_linebuffer(lbp, lbpnext);
    lbp  = lbpnext;
    memset(buf, '\0', sizeof(buf));
  }
  link_linebuffer(lbp, &linebuffer_tail);
  
  cursor.linebuffer = linebuffer_head.next;
  cursor.x = 0;
  cursor.y = 1;
  screen.upperline = linebuffer_head.next;

  fclose(ifile);
}

void quit(){
  quit_flg = 1;
}

int ischaracter(char c){
  return 0x20 <= c && c <= 0x7e;
}

void input_command(char c){
  switch(c){
  case KEYCODE_ESC:
    statusbar_command_end();
    return;
  case KEYCODE_CR:
  case KEYCODE_LF:
    statusbar_command_exec();
    statusbar_command_begin();
    return;
  default:
    if(!ischaracter(c))
      return;
    insert_statusbar_message(c);
    return;
  }
}

void input_mode_normal(char c){
  if(command){
    input_command(c);
    return;
  }

  switch(c){
  case 'a':
    cursor_right();
    mode_change(MODE_INSERT);
    return;
  case 'i':
    mode_change(MODE_INSERT);
    return;
  case 'h':
    cursor_left();
    return;
  case 'j':
    cursor_down();
    return;
  case 'k':
    cursor_up();
    return;
  case 'l':
    cursor_right();
    return;
  case 'x':
    delete_normal();
    return;
  case 'd':
    deleteline_normal();
    return;
  case ':':
    statusbar_command_begin();
    return;
  }
}

void enter_insert(){
  struct linebuffer *lbp, *lbpnext;
  lbp = create_linebuffer();

  strcpy(lbp->buf, cursor.linebuffer->buf+cursor.x);
  lbp->size = cursor.linebuffer->size - cursor.x;
  cursor.linebuffer->size = cursor.x;
  cursor.linebuffer->buf[cursor.x] = '\n';
  memset(cursor.linebuffer->buf+cursor.x+1, '\0', LINE_BUFFER_LENGTH-cursor.x-1);

  lbpnext = cursor.linebuffer->next;
  link_linebuffer(cursor.linebuffer, lbp);
  link_linebuffer(lbp, lbpnext);

  cursor_down();
  cursor.x = 0;
}

void character_insert(char c){
  memmove(cursor.linebuffer->buf+(cursor.x+1), cursor.linebuffer->buf+cursor.x, cursor.linebuffer->size-cursor.x+1);
  cursor.linebuffer->buf[cursor.x] = c;

  cursor.linebuffer->size++;
  cursor_right();
}

void input_mode_insert(char c){
  switch(c){
  case KEYCODE_ESC:
    mode_change(MODE_NORMAL);
    return;
  case KEYCODE_CR:
  case KEYCODE_LF:
    enter_insert();
    return;
  default:
    if(!ischaracter(c))
      return;
    character_insert(c);
    return;
  }
}

void input_hook(){
  char c;
  read(0, &c, 1);

  switch(mode){
  case MODE_NORMAL:
    set_statusbar_mode("[normal]");
    input_mode_normal(c);
    return;
  case MODE_INSERT:
    set_statusbar_mode("[insert]");
    input_mode_insert(c);
    return;
  default:
    error("undefined mode");
    return;
  }
}

// term
void init_term(){
  tcgetattr(0, &termios);
  termios.c_lflag &= ~ICANON;
  tcsetattr(0, TCSANOW, &termios);
}
void restore_term(){
  termios.c_lflag |= ICANON;
  tcsetattr(0, TCSANOW, &termios);
}

// init
void init(){
  struct linebuffer *lbp;
  lbp = create_linebuffer();

  mode     = MODE_NORMAL;
  quit_flg = 0;
  cursor_init(lbp);
  statusbar_init();

  alloc_linebuffer(&linebuffer_head);
  alloc_linebuffer(&linebuffer_tail);
  link_linebuffer(&linebuffer_tail, &linebuffer_tail);
  link_linebuffer(&linebuffer_head, lbp);
  link_linebuffer(lbp, &linebuffer_tail);
  strcpy(linebuffer_tail.buf,"~\n");

  // screen_init: after buffer initialization
  screen_init();
}

void cleanup(){
  struct linebuffer *lbp, *lbptmp;
  lbp = (&linebuffer_tail)->prev;
  while(lbp != &linebuffer_head){
    lbptmp = lbp;
    lbp    = lbp->prev;
    free(lbptmp->buf);
    free(lbptmp);
  }
  free(linebuffer_head.buf);
  free(linebuffer_tail.buf);
}

// main
int main(int argc, char *argv[]){
  struct linebuffer *top;

  init();
  init_term();

  if(argc == 2){
    strcpy(inputfilename, argv[1]);
    load();
  }

  while(1){
    top = screen_top();
    display(top);
    input_hook();

    if(quit_flg) break;
  }
  printf("\n");
  term_cursor_location(0,0);
  fprintf(stdout,"\033[2J");

  restore_term();
  cleanup();

  exit(0);
}
