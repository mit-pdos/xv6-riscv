#ifndef _ELOG_H_
#define _ELOG_H_

#define ELOG_SIZE 64

#define SENSOR_TEMPERATURE        1
#define SENSOR_AIR_QUALITY        2
#define SENSOR_HUMIDITY           3
#define SENSOR_ENERGY_USAGE       4
#define SENSOR_WATER_USAGE        5

#define EVENT_SENSOR_UPDATE       1
#define EVENT_THRESHOLD_EXCEEDED  2
#define EVENT_BACK_TO_NORMAL      3
#define EVENT_INVALID_READING     4

struct elog_entry {
  int timestamp;
  int event_type;
  int sensor_id;
  int value;
};

void eloginit(void);
void elogadd(int event_type, int sensor_id, int value);
int elogread(struct elog_entry *dst, int max);

#endif