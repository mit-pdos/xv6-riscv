#ifndef _ALERT_H_
#define _ALERT_H_

#define MAX_SENSORS      5
#define ALERT_BUF_SIZE  32

#define ALERT_WARNING    1
#define ALERT_CRITICAL   2

struct alert_threshold {
  int sensor_id;
  int min_val;
  int max_val;
  int active;
};

struct alert_entry {
  int timestamp;
  int sensor_id;
  int value;
  int threshold;
  int alert_type;
};

void alertinit(void);
void alertcheck(int sensor_id, int value);
int  alertsetthreshold(int sensor_id, int min_val, int max_val);
int  alertgetpending(struct alert_entry *dst, int max);

#endif
