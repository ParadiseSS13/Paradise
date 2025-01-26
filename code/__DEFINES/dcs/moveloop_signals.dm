///from [/datum/move_loop/start_loop] ():
#define COMSIG_MOVELOOP_START "moveloop_start"
///from [/datum/move_loop/stop_loop] ():
#define COMSIG_MOVELOOP_STOP "moveloop_stop"
///from [/datum/move_loop/process] ():
#define COMSIG_MOVELOOP_PREPROCESS_CHECK "moveloop_preprocess_check"
	#define MOVELOOP_SKIP_STEP (1<<0)
///from [/datum/move_loop/process] (succeeded, visual_delay):
#define COMSIG_MOVELOOP_POSTPROCESS "moveloop_postprocess"
//from [/datum/move_loop/has_target/jps/recalculate_path] ():
#define COMSIG_MOVELOOP_JPS_REPATH "moveloop_jps_repath"
///From base of /datum/move_loop/process() after attempting to move a movable: (datum/move_loop/loop, old_dir)
#define COMSIG_MOVABLE_MOVED_FROM_LOOP "movable_moved_from_loop"
///from [/datum/move_loop/has_target/jps/on_finish_pathing]
#define COMSIG_MOVELOOP_JPS_FINISHED_PATHING "moveloop_jps_finished_pathing"
