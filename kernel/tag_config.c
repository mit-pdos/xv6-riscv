#define MAX_TAG_CONFIG 20

struct tag_priority {
  char tag[16];
  int priority;
};

struct tag_priority tag_table[MAX_TAG_CONFIG];

int tag_count = 0;

void load_tag_config()
{
  // open .ptfs_config
  // read lines
  // parse tag + priority
  // store in tag_table
}

int get_tag_priority(struct inode *ip)
{
  int max = 0;

  for(int i=0;i<ip->tag_count;i++){
    for(int j=0;j<tag_count;j++){

      if(strcmp(ip->tags[i],
                tag_table[j].tag) == 0){

        if(tag_table[j].priority > max)
          max = tag_table[j].priority;
      }
    }
  }

  return max;
}
