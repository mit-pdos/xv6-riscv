#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"

char buf[512];

// Flags for controlling output
int show_l = 0, show_w = 0, show_c = 0;

void
wc(int fd, char *name)
{
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
        inword = 0;
      else if(!inword){
        w++;
        inword = 1;
      }
    }
  }
  if(n < 0){
    printf("wc: read error\n");
    exit(1);
  }

  // Print only selected counts
  if(show_l)
    printf("%d ", l);
  if(show_w)
    printf("%d ", w);
  if(show_c)
    printf("%d ", c);
  printf("%s\n", name);
}

// Parse command line options (-l, -w, -c)
// Returns the index of the first non-option argument
int
parse_options(int argc, char *argv[])
{
  int i, j;
  int any_option = 0;

  for(i = 1; i < argc; i++){
    if(argv[i][0] == '-'){
      for(j = 1; argv[i][j]; j++){
        any_option = 1;
        if(argv[i][j] == 'l')
          show_l = 1;
        else if(argv[i][j] == 'w')
          show_w = 1;
        else if(argv[i][j] == 'c')
          show_c = 1;
      }
    } else {
      break;
    }
  }

  // If no options specified, show all
  if(!any_option){
    show_l = show_w = show_c = 1;
  }

  return i;  // Index of first file argument
}

int
main(int argc, char *argv[])
{
  int fd, i;
  int first_file;

  first_file = parse_options(argc, argv);

  if(first_file >= argc){
    // No files specified, read from stdin
    wc(0, "");
    exit(0);
  }

  for(i = first_file; i < argc; i++){
    if((fd = open(argv[i], O_RDONLY)) < 0){
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
    close(fd);
  }
  exit(0);
}
