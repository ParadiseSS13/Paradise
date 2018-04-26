// Process status defines
#define PROCESS_STATUS_IDLE 1
#define PROCESS_STATUS_QUEUED 2
#define PROCESS_STATUS_RUNNING 3
#define PROCESS_STATUS_MAYBE_HUNG 4
#define PROCESS_STATUS_PROBABLY_HUNG 5
#define PROCESS_STATUS_HUNG 6

// Process time thresholds
#define PROCESS_DEFAULT_HANG_WARNING_TIME 300 // 30 seconds
#define PROCESS_DEFAULT_HANG_ALERT_TIME   600 // 60 seconds
#define PROCESS_DEFAULT_HANG_RESTART_TIME 900 // 90 seconds
#define PROCESS_DEFAULT_SCHEDULE_INTERVAL 50  // 50 ticks
#define PROCESS_DEFAULT_SLEEP_INTERVAL    20  // 20% of a tick
#define PROCESS_DEFAULT_DEFER_USAGE       90  // 90% of a tick

// Sleep check macro
#define SCHECK if(world.tick_usage >= next_sleep_usage) defer()

//Timing Controller
#define GLOBAL_PROC	"some_magic_bullshit"

#define DECLARE_GLOBAL_CONTROLLER(PROCESS,VARNAME) \
/datum/controller/process/##PROCESS/assertGlobality(){\
	if(##VARNAME){\
		message_admins("Controller '[name]' tried to become global but found another controller there already. Deleting the old controller.");\
		qdel(##VARNAME);}\
	##VARNAME = src;}\
\
/datum/controller/process/##PROCESS/releaseGlobality(){\
	if(##VARNAME == src)\
		##VARNAME = null;\
	else\
		message_admins("Controller '[name]' asked to release global control in spite of not having it!");}
