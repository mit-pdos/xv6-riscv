#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/alert.h"
#include "kernel/elog.h"
#include "user/user.h"

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
  printf("  alertsys demo\n");
  printf("  alertsys show\n");
  printf("  alertsys setthresh <sensor_id> <min> <max>\n");
  printf("sensor ids: 1=temp 2=air 3=humidity 4=energy 5=water\n");
  exit(1);
}

static void
print_alerts(void)
{
  struct alert_entry entries[ALERT_BUF_SIZE];
  int n;

  n = getalerts(entries, ALERT_BUF_SIZE);
  if(n < 0){
    printf("alertsys: getalerts failed\n");
    exit(1);
  }

  printf("--- alerts: %d ---\n", n);
  for(int i = 0; i < n; i++){
    printf("[tick %d] ALERT: sensor=%s value=%d exceeded threshold=%d\n",
           entries[i].timestamp,
           sensor_name(entries[i].sensor_id),
           entries[i].value,
           entries[i].threshold);
  }
}

static void
print_logs(void)
{
  struct elog_entry entries[ELOG_SIZE];
  int n;

  n = getlogs(entries, ELOG_SIZE);
  if(n < 0){
    printf("alertsys: getlogs failed\n");
    exit(1);
  }

  printf("--- event log: %d entries ---\n", n);
  for(int i = 0; i < n; i++){
    char *etype;
    switch(entries[i].event_type){
    case EVENT_SENSOR_UPDATE:      etype = "sensor-update"; break;
    case EVENT_THRESHOLD_EXCEEDED: etype = "threshold-exceeded"; break;
    case EVENT_BACK_TO_NORMAL:     etype = "back-to-normal"; break;
    case EVENT_INVALID_READING:    etype = "invalid-reading"; break;
    default:                       etype = "unknown"; break;
    }
    printf("[tick %d] sensor=%s event=%s value=%d\n",
           entries[i].timestamp,
           sensor_name(entries[i].sensor_id),
           etype,
           entries[i].value);
  }
}

static void
demo(void)
{
  printf("Setting thresholds for all sensors...\n");
  setalert(SENSOR_TEMPERATURE,  0, 35);
  printf("  temperature: min=0 max=35\n");
  setalert(SENSOR_AIR_QUALITY,  0, 150);
  printf("  air-quality: min=0 max=150\n");
  setalert(SENSOR_HUMIDITY,     20, 80);
  printf("  humidity:    min=20 max=80\n");
  setalert(SENSOR_ENERGY_USAGE, 0, 90);
  printf("  energy:      min=0 max=90\n");
  setalert(SENSOR_WATER_USAGE,  0, 100);
  printf("  water:       min=0 max=100\n");
  printf("\n");

  printf("Logging sensor readings...\n");

  // Normal readings (no alert)
  logevent(EVENT_SENSOR_UPDATE, SENSOR_TEMPERATURE, 24);
  printf("  temperature=24 (normal)\n");

  logevent(EVENT_SENSOR_UPDATE, SENSOR_HUMIDITY, 55);
  printf("  humidity=55 (normal)\n");

  logevent(EVENT_SENSOR_UPDATE, SENSOR_WATER_USAGE, 50);
  printf("  water=50 (normal)\n");

  // Readings that exceed thresholds (trigger alerts)
  logevent(EVENT_SENSOR_UPDATE, SENSOR_TEMPERATURE, 38);
  printf("  temperature=38 (EXCEEDS max=35)\n");

  logevent(EVENT_SENSOR_UPDATE, SENSOR_AIR_QUALITY, 160);
  printf("  air-quality=160 (EXCEEDS max=150)\n");

  logevent(EVENT_SENSOR_UPDATE, SENSOR_ENERGY_USAGE, 95);
  printf("  energy=95 (EXCEEDS max=90)\n");

  printf("\n");
  print_alerts();
  printf("\n");
  print_logs();
}

int
main(int argc, char **argv)
{
  if(argc < 2)
    usage();

  if(strcmp(argv[1], "demo") == 0){
    demo();
    exit(0);
  }

  if(strcmp(argv[1], "show") == 0){
    print_alerts();
    exit(0);
  }

  if(strcmp(argv[1], "setthresh") == 0){
    if(argc != 5)
      usage();
    int sid = atoi(argv[2]);
    int lo  = atoi(argv[3]);
    int hi  = atoi(argv[4]);
    if(setalert(sid, lo, hi) < 0){
      printf("alertsys: setalert failed (bad args)\n");
      exit(1);
    }
    printf("threshold set: sensor=%s min=%d max=%d\n",
           sensor_name(sid), lo, hi);
    exit(0);
  }

  usage();
  return 0;
}
