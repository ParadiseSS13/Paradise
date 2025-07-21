/// The minimum for glide_size to be clamped to.
#define MIN_GLIDE_SIZE 1
/// The maximum for glide_size to be clamped to.
/// This shouldn't be higher than the icon size, and generally you shouldn't be changing this, but it's here just in case.
#define MAX_GLIDE_SIZE 32

//Movement loop priority. Only one loop can run at a time, this dictates that
// Higher numbers beat lower numbers
///Standard, go lower then this if you want to override, higher otherwise
#define MOVEMENT_DEFAULT_PRIORITY 10
///Very few things should override this
#define MOVEMENT_SPACE_PRIORITY 100
///Higher then the heavens
#define MOVEMENT_ABOVE_SPACE_PRIORITY (MOVEMENT_SPACE_PRIORITY + 1)

//Movement loop flags
///Should the loop act immediately following its addition?
#define MOVEMENT_LOOP_START_FAST (1<<0)
///Do we not use the priority system?
#define MOVEMENT_LOOP_IGNORE_PRIORITY (1<<1)
///Should we override the loop's glide?
#define MOVEMENT_LOOP_IGNORE_GLIDE (1<<2)
///Should we not update our movables dir on move?
#define MOVEMENT_LOOP_NO_DIR_UPDATE (1<<3)
///Controls how the loop will set momentum_change in its Move call.
#define MOVEMENT_LOOP_NO_MOMENTUM_CHANGE (1<<4)
/// Should we forceMove instead of Move?
#define MOVEMENT_LOOP_FORCE_MOVE (1<<5)

// Movement loop status flags
/// Has the loop been paused, soon to be resumed?
#define MOVELOOP_STATUS_PAUSED (1<<0)
/// Is the loop running? (Is true even when paused)
#define MOVELOOP_STATUS_RUNNING (1<<1)
/// Is the loop queued in a subsystem?
#define MOVELOOP_STATUS_QUEUED (1<<2)

/**
 * Returns a bitfield containing flags both present in `flags` arg and the `processing_move_loop_flags` move_packet variable.
 * Has no use outside of procs called within the movement proc chain.
 */
#define CHECK_MOVE_LOOP_FLAGS(movable, flags) (movable.move_packet ? (movable.move_packet.processing_move_loop_flags & (flags)) : NONE)

//Index defines for movement bucket data packets
#define MOVEMENT_BUCKET_TIME 1
#define MOVEMENT_BUCKET_LIST 2

///Return values for moveloop Move()
#define MOVELOOP_FAILURE 0
#define MOVELOOP_SUCCESS 1
#define MOVELOOP_NOT_READY 2

#define ACTIVE_MOVEMENT_OLDLOC 1
#define ACTIVE_MOVEMENT_DIRECTION 2
#define ACTIVE_MOVEMENT_FORCED 3
#define ACTIVE_MOVEMENT_OLDLOCS 4

/// The arguments of this macro correspond directly to the argument order of /atom/movable/proc/Moved
#define SET_ACTIVE_MOVEMENT(_old_loc, _direction, _forced, _oldlocs, _momentum_change) \
	active_movement = list( \
		_old_loc, \
		_direction, \
		_forced, \
		_oldlocs, \
		_momentum_change, \
	)

/// Finish any active movements
#define RESOLVE_ACTIVE_MOVEMENT \
	if(active_movement) { \
		var/__move_args = active_movement; \
		active_movement = null; \
		Moved(arglist(__move_args)); \
	}
