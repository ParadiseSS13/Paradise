#define MC_TICK_CHECK ( ( TICK_USAGE > Master.current_ticklimit || src.state != SS_RUNNING ) ? pause() : 0 )

#define MC_SPLIT_TICK_INIT(phase_count) var/original_tick_limit = Master.current_ticklimit; var/split_tick_phases = ##phase_count
#define MC_SPLIT_TICK \
	if(split_tick_phases > 1){\
		Master.current_ticklimit = ((original_tick_limit - TICK_USAGE) / split_tick_phases) + TICK_USAGE;\
		--split_tick_phases;\
	} else {\
		Master.current_ticklimit = original_tick_limit;\
	}

// Used to smooth out costs to try and avoid oscillation.
#define MC_AVERAGE_FAST(average, current) (0.7 * (average) + 0.3 * (current))
#define MC_AVERAGE(average, current) (0.8 * (average) + 0.2 * (current))
#define MC_AVERAGE_SLOW(average, current) (0.9 * (average) + 0.1 * (current))

#define MC_AVG_FAST_UP_SLOW_DOWN(average, current) (average > current ? MC_AVERAGE_SLOW(average, current) : MC_AVERAGE_FAST(average, current))
#define MC_AVG_SLOW_UP_FAST_DOWN(average, current) (average < current ? MC_AVERAGE_SLOW(average, current) : MC_AVERAGE_FAST(average, current))

///creates a running average of "things elapsed" per time period when you need to count via a smaller time period.
///eg you want an average number of things happening per second but you measure the event every tick (50 milliseconds).
///make sure both time intervals are in the same units. doesnt work if current_duration > total_duration or if total_duration == 0
#define MC_AVG_OVER_TIME(average, current, total_duration, current_duration) (((total_duration - current_duration) / (total_duration)) * (average) + (current))

#define MC_AVG_MINUTES(average, current, current_duration) (MC_AVG_OVER_TIME(average, current, 1 MINUTES, current_duration))

#define MC_AVG_SECONDS(average, current, current_duration) (MC_AVG_OVER_TIME(average, current, 1 SECONDS, current_duration))

#define NEW_SS_GLOBAL(varname) if(varname != src){if(istype(varname)){Recover();qdel(varname);}varname = src;}

#define START_PROCESSING(Processor, Datum) if(!Datum.isprocessing) {Datum.isprocessing = TRUE;Processor.processing += Datum}
#define STOP_PROCESSING(Processor, Datum) Datum.isprocessing = FALSE;Processor.processing -= Datum

//SubSystem flags (Please design any new flags so that the default is off, to make adding flags to subsystems easier)

//subsystem does not initialize.
#define SS_NO_INIT 1

//subsystem does not fire.
//	(like can_fire = 0, but keeps it from getting added to the processing subsystems list)
//	(Requires a MC restart to change)
#define SS_NO_FIRE 2

/** Subsystem only runs on spare cpu (after all non-background subsystems have ran that tick) */
/// SS_BACKGROUND has its own priority bracket, this overrides SS_TICKER's priority bump
#define SS_BACKGROUND 4

//subsystem does not tick check, and should not run unless there is enough time (or its running behind (unless background))
#define SS_NO_TICK_CHECK 8

//Treat wait as a tick count, not DS, run every wait ticks.
/// (also forces it to run first in the tick (unless SS_BACKGROUND))
//	(implies all runlevels because of how it works)
//	This is designed for basically anything that works as a mini-mc (like SStimer)
#define SS_TICKER 16

//keep the subsystem's timing on point by firing early if it fired late last fire because of lag
//	ie: if a 20ds subsystem fires say 5 ds late due to lag or what not, its next fire would be in 15ds, not 20ds.
#define SS_KEEP_TIMING 32

//Calculate its next fire after its fired.
//	(IE: if a 5ds wait SS takes 2ds to run, its next fire should be 5ds away, not 3ds like it normally would be)
//	This flag overrides SS_KEEP_TIMING
#define SS_POST_FIRE_TIMING 64

//SUBSYSTEM STATES
#define SS_IDLE 0		//aint doing shit.
#define SS_QUEUED 1		//queued to run
#define SS_RUNNING 2	//actively running
#define SS_PAUSED 3		//paused by mc_tick_check
#define SS_SLEEPING 4	//fire() slept.
#define SS_PAUSING 5 	//in the middle of pausing

#define SUBSYSTEM_DEF(X) GLOBAL_REAL(SS##X, /datum/controller/subsystem/##X);\
/datum/controller/subsystem/##X/New(){\
	NEW_SS_GLOBAL(SS##X);\
	PreInit();\
	ss_id=#X;\
}\
/datum/controller/subsystem/##X

#define PROCESSING_SUBSYSTEM_DEF(X) GLOBAL_REAL(SS##X, /datum/controller/subsystem/processing/##X);\
/datum/controller/subsystem/processing/##X/New(){\
	NEW_SS_GLOBAL(SS##X);\
	PreInit();\
	ss_id="processing_[#X]";\
}\
/datum/controller/subsystem/processing/##X

#define TIMER_SUBSYSTEM_DEF(X) GLOBAL_REAL(SS##X, /datum/controller/subsystem/timer/##X);\
/datum/controller/subsystem/timer/##X/New(){\
	NEW_SS_GLOBAL(SS##X);\
	PreInit();\
	ss_id="timer_[#X]";\
}\
/datum/controller/subsystem/timer/##X/fire() {..() /*just so it shows up on the profiler*/} \
/datum/controller/subsystem/timer/##X
