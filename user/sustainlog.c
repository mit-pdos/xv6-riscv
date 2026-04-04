#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/elog.h"
#include "user/user.h"

static char *
event_name(int event_type)
{
  switch(event_type){
  case EVENT_SENSOR_UPDATE:
    return "sensor-update";
  case EVENT_THRESHOLD_EXCEEDED:
    return "threshold-exceeded";
  case EVENT_BACK_TO_NORMAL:
    return "back-to-normal";
  case EVENT_INVALID_READING:
    return "invalid-reading";
  default:
    return "unknown";
  }
}

static char *
sensor_name(int sensor_id)
{
  switch(sensor_id){
  case SENSOR_TEMPERATURE:
    return "temperature";
  case SENSOR_AIR_QUALITY:
    return "air-quality";
  case SENSOR_HUMIDITY:
    return "humidity";
  case SENSOR_ENERGY_USAGE:
    return "energy";
  case SENSOR_WATER_USAGE:
    return "water";
  default:
    return "unknown";
  }
}

static void
usage(void)
{
  printf("usage:\n");
  printf("  sustainlog demo\n");
  printf("  sustainlog show\n");
  printf("  sustainlog log <event_type> <sensor_id> <value>\n");
  printf("sensor ids: 1=temp 2=air 3=humidity 4=energy 5=water\n");
  exit(1);
}

static void
print_logs(void)
{
  struct elog_entry entries[ELOG_SIZE];
  int n;

  n = getlogs(entries, ELOG_SIZE);
  if(n < 0){
    printf("sustainlog: getlogs failed\n");
    exit(1);
  }

  printf("sustainability log entries: %d\n", n);
  for(int i = 0; i < n; i++){
    printf("[%d] sensor=%s event=%s value=%d\n",
           entries[i].timestamp,
           sensor_name(entries[i].sensor_id),
           event_name(entries[i].event_type),
           entries[i].value);
  }
}

static void
must_log(int event_type, int sensor_id, int value)
{
  if(logevent(event_type, sensor_id, value) < 0){
    printf("sustainlog: logevent failed\n");
    exit(1);
  }
}

static void
add_demo_entries(void)
{
  must_log(EVENT_SENSOR_UPDATE, SENSOR_TEMPERATURE, 24);
  must_log(EVENT_SENSOR_UPDATE, SENSOR_HUMIDITY, 61);
  must_log(EVENT_THRESHOLD_EXCEEDED, SENSOR_AIR_QUALITY, 151);
  must_log(EVENT_THRESHOLD_EXCEEDED, SENSOR_ENERGY_USAGE, 92);
  must_log(EVENT_BACK_TO_NORMAL, SENSOR_AIR_QUALITY, 73);
  must_log(EVENT_INVALID_READING, SENSOR_WATER_USAGE, -1);
}

int
main(int argc, char **argv)
{
  if(argc == 1 || strcmp(argv[1], "demo") == 0){
    add_demo_entries();
    print_logs();
    exit(0);
  }

  if(strcmp(argv[1], "show") == 0){
    print_logs();
    exit(0);
  }

  if(strcmp(argv[1], "log") == 0){
    if(argc != 5)
      usage();
    must_log(atoi(argv[2]), atoi(argv[3]), atoi(argv[4]));
    print_logs();
    exit(0);
  }

  usage();
  return 0;
}
