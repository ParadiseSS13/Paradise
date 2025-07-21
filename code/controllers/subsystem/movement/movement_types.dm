///Template class of the movement datums, handles the timing portion of the loops
/datum/move_loop
	///The movement packet that owns us
	var/datum/movement_packet/owner
	///The subsystem we're processing on
	var/datum/controller/subsystem/movement/controller
	///An extra reference we pass around
	///It is on occasion useful to have a reference to some datum without storing it on the moving object
	///Mostly comes up in high performance senarios where we care about things being singletons
	///This feels horrible, but constantly making components seems worse
	var/datum/extra_info
	///The thing we're moving about
	var/atom/movable/moving
	///Defines how different move loops override each other. Higher numbers beat lower numbers
	var/priority = MOVEMENT_DEFAULT_PRIORITY
	///Bitfield of different things that affect how a loop operates, and other mechanics around it as well.
	var/flags
	///Time till we stop processing in deci-seconds, defaults to forever
	var/lifetime = INFINITY
	///Delay between each move in deci-seconds
	var/delay = 1
	///The next time we should process
	///Used primarially as a hint to be reasoned about by our [controller], and as the id of our bucket
	var/timer = 0
	///The time we are CURRENTLY queued for processing
	///Do not modify this directly
	var/queued_time = -1
	/// Status bitfield for what state the move loop is currently in
	var/status = NONE

/datum/move_loop/New(datum/movement_packet/owner, datum/controller/subsystem/movement/controller, atom/moving, priority, flags, datum/extra_info)
	src.owner = owner
	src.controller = controller
	src.extra_info = extra_info
	if(extra_info)
		RegisterSignal(extra_info, COMSIG_PARENT_QDELETING, PROC_REF(info_deleted))
	src.moving = moving
	src.priority = priority
	src.flags = flags

/datum/move_loop/proc/setup(delay = 1, timeout = INFINITY)
	if(!ismovable(moving) || !owner)
		return FALSE

	src.delay = max(delay, world.tick_lag) //Please...
	src.lifetime = timeout
	return TRUE

///check if this exact moveloop datum already exists (in terms of vars) so we can avoid creating a new one to overwrite the old duplicate
/datum/move_loop/proc/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay = 1, timeout = INFINITY)
	SHOULD_CALL_PARENT(TRUE)
	if(loop_type == type && priority == src.priority && flags == src.flags && delay == src.delay && timeout == lifetime)
		return TRUE
	return FALSE

///Called when a loop is starting by a movement subsystem
/datum/move_loop/proc/loop_started()
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOVELOOP_START)
	status |= MOVELOOP_STATUS_RUNNING
	//If this is our first time starting to move with this loop
	//And we're meant to start instantly
	if(!timer && flags & MOVEMENT_LOOP_START_FAST)
		timer = world.time
		return
	timer = world.time + delay

///Called when a loop is stopped, doesn't stop the loop itself
/datum/move_loop/proc/loop_stopped()
	SHOULD_CALL_PARENT(TRUE)
	status &= ~MOVELOOP_STATUS_RUNNING
	SEND_SIGNAL(src, COMSIG_MOVELOOP_STOP)

/datum/move_loop/proc/info_deleted(datum/source)
	SIGNAL_HANDLER
	extra_info = null

/datum/move_loop/Destroy()
	if(owner)
		owner.remove_loop(controller, src)
	owner = null
	moving = null
	controller = null
	extra_info = null
	return ..()

///Exists as a helper so outside code can modify delay in a sane way
/datum/move_loop/proc/set_delay(new_delay)
	delay =  max(new_delay, world.tick_lag)

///Pauses the move loop for some passed in period
///This functionally means shifting its timer up, and clearing it from its current bucket
/datum/move_loop/proc/pause_for(time)
	if(!controller || !(status & MOVELOOP_STATUS_RUNNING)) //No controller or not running? go away
		return
	//Dequeue us from our current bucket
	controller.dequeue_loop(src)
	//Offset our timer
	timer = world.time + time
	//Now requeue us with our new target start time
	controller.queue_loop(src)

/datum/move_loop/process()
	if(isnull(controller))
		qdel(src)
		return

	var/old_delay = delay //The signal can sometimes change delay

	if(SEND_SIGNAL(src, COMSIG_MOVELOOP_PREPROCESS_CHECK) & MOVELOOP_SKIP_STEP) //Chance for the object to react
		return

	lifetime -= old_delay //This needs to be based on work over time, not just time passed

	if(lifetime < 0) //Otherwise lag would make things look really weird
		qdel(src)
		return

	var/visual_delay = controller.visual_delay
	var/old_dir = moving.dir
	var/old_loc = moving.loc

	owner?.processing_move_loop_flags = flags
	var/result = move() // Result is an enum value. Enums defined in __DEFINES/movement_defines.dm
	if(moving)
		var/direction = get_dir(old_loc, moving.loc)
		SEND_SIGNAL(moving, COMSIG_MOVABLE_MOVED_FROM_LOOP, src, old_dir, direction)
	owner?.processing_move_loop_flags = NONE

	SEND_SIGNAL(src, COMSIG_MOVELOOP_POSTPROCESS, result, delay * visual_delay)

	if(QDELETED(src) || result != MOVELOOP_SUCCESS) //Can happen
		return

	if(flags & MOVEMENT_LOOP_IGNORE_GLIDE)
		return

	var/glide_multiplier = visual_delay
	if(IS_DIR_DIAGONAL(get_dir(old_loc, moving.loc)) && !(moving.appearance_flags & LONG_GLIDE))
		glide_multiplier *= sqrt(2)
	moving.set_glide_size(MOVEMENT_ADJUSTED_GLIDE_SIZE(delay, glide_multiplier))

///Handles the actual move, overriden by children
///Returns FALSE if nothing happen, TRUE otherwise
/datum/move_loop/proc/move()
	return MOVELOOP_FAILURE


///Pause our loop untill restarted with resume_loop()
/datum/move_loop/proc/pause_loop()
	if(!controller || !(status & MOVELOOP_STATUS_RUNNING) || (status & MOVELOOP_STATUS_PAUSED)) //we dead
		return

	//Dequeue us from our current bucket
	controller.dequeue_loop(src)
	status |= MOVELOOP_STATUS_PAUSED

///Resume our loop after being paused by pause_loop()
/datum/move_loop/proc/resume_loop()
	if(!controller || (status & MOVELOOP_STATUS_RUNNING|MOVELOOP_STATUS_PAUSED) != (MOVELOOP_STATUS_RUNNING|MOVELOOP_STATUS_PAUSED))
		return

	timer = world.time
	controller.queue_loop(src)
	status &= ~MOVELOOP_STATUS_PAUSED

///Removes the atom from some movement subsystem. Defaults to SSmovement
/datum/move_manager/proc/stop_looping(atom/movable/moving, datum/controller/subsystem/movement/subsystem = SSmovement)
	var/datum/movement_packet/our_info = moving.move_packet
	if(!our_info)
		return FALSE
	return our_info.remove_subsystem(subsystem)

/**
 * Replacement for walk()
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * direction - The direction we want to move in
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check __DEFINES/movement_defines.dm
 *
**/
/datum/move_manager/proc/move(moving, direction, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/move, priority, flags, extra_info, delay, timeout, direction)

///Replacement for walk()
/datum/move_loop/move
	var/direction

/datum/move_loop/move/setup(delay, timeout, dir)
	. = ..()
	if(!.)
		return
	direction = dir

/datum/move_loop/move/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, dir)
	if(..() && direction == dir)
		return TRUE
	return FALSE

/datum/move_loop/move/move()
	var/atom/old_loc = moving.loc
	if(flags & MOVEMENT_LOOP_FORCE_MOVE)
		moving.forceMove(get_step(moving, direction))
	else
		moving.Move(get_step(moving, direction), direction, FALSE, !(flags & MOVEMENT_LOOP_NO_DIR_UPDATE), !(flags & MOVEMENT_LOOP_NO_MOMENTUM_CHANGE))
	// We cannot rely on the return value of Move(), we care about teleports and it doesn't
	// Moving also can be null on occasion, if the move deleted it and therefor us
	return old_loc != moving?.loc ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE

/datum/move_loop/has_target
	///The thing we're moving in relation to, either at or away from
	var/atom/target

/datum/move_loop/has_target/setup(delay, timeout, atom/chasing)
	. = ..()
	if(!.)
		return
	if(!isatom(chasing))
		qdel(src)
		return FALSE

	target = chasing

	if(!isturf(target))
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(handle_no_target)) //Don't do this for turfs, because we don't care

/datum/move_loop/has_target/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, atom/chasing)
	if(..() && chasing == target)
		return TRUE
	return FALSE

/datum/move_loop/has_target/Destroy()
	target = null
	return ..()

/datum/move_loop/has_target/proc/handle_no_target()
	SIGNAL_HANDLER
	qdel(src)

/**
 * Used for following jps defined paths. The proc signature here's a bit long, I'm sorry
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * repath_delay - How often we're allowed to recalculate our path
 * max_path_length - The maximum number of steps we can take in a given path to search (default: 30, 0 = infinite)
 * miminum_distance - Minimum distance to the target before path returns, could be used to get near a target, but not right to it - for an AI mob with a gun, for example
 * access - A list representing what access we have and what doors we can open
 * simulated_only -  Whether we consider turfs without atmos simulation (AKA do we want to ignore space)
 * avoid - If we want to avoid a specific turf, like if we're a mulebot who already got blocked by some turf
 * skip_first -  Whether or not to delete the first item in the path. This would be done because the first item is the starting tile, which can break things
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check __DEFINES/movement_defines.dm
 *
**/
/datum/move_manager/proc/jps_move(moving,
	chasing,
	delay,
	timeout,
	repath_delay,
	max_path_length,
	minimum_distance,
	list/access,
	simulated_only,
	turf/avoid,
	skip_first,
	subsystem,
	diagonal_handling,
	priority,
	flags,
	datum/extra_info,
	initial_path)
	return add_to_loop(moving,
		subsystem,
		/datum/move_loop/has_target/jps,
		priority,
		flags,
		extra_info,
		delay,
		timeout,
		chasing,
		repath_delay,
		max_path_length,
		minimum_distance,
		access,
		simulated_only,
		avoid,
		skip_first,
		diagonal_handling,
		initial_path)

/datum/move_loop/has_target/jps
	///How often we're allowed to recalculate our path
	var/repath_delay
	///Max amount of steps to search
	var/max_path_length
	///Minimum distance to the target before path returns
	var/minimum_distance
	///A list representing what access we have and what doors we can open.
	var/list/access
	///Whether we consider turfs without atmos simulation (AKA do we want to ignore space)
	var/simulated_only
	///A perticular turf to avoid
	var/turf/avoid
	///Should we skip the first step? This is the tile we're currently on, which breaks some things
	var/skip_first
	///Whether we replace diagonal movements with cardinal movements or follow through with them
	var/diagonal_handling
	///A list for the path we're currently following
	var/list/movement_path
	///Cooldown for repathing, prevents spam
	COOLDOWN_DECLARE(repath_cooldown)
	///Bool used to determine if we're already making a path in JPS. this prevents us from re-pathing while we're already busy.
	var/is_pathing = FALSE
	///Callbacks to invoke once we make a path
	var/list/datum/callback/on_finish_callbacks = list()

/datum/move_loop/has_target/jps/New(datum/movement_packet/owner, datum/controller/subsystem/movement/controller, atom/moving, priority, flags, datum/extra_info)
	. = ..()
	on_finish_callbacks += CALLBACK(src, PROC_REF(on_finish_pathing))

/datum/move_loop/has_target/jps/setup(delay, timeout, atom/chasing, repath_delay, max_path_length, minimum_distance, list/access, simulated_only, turf/avoid, skip_first, diagonal_handling, list/initial_path)
	. = ..()
	if(!.)
		return
	src.repath_delay = repath_delay
	src.max_path_length = max_path_length
	src.minimum_distance = minimum_distance
	src.access = access
	src.simulated_only = simulated_only
	src.avoid = avoid
	src.skip_first = skip_first
	src.diagonal_handling = diagonal_handling
	movement_path = initial_path?.Copy()

/datum/move_loop/has_target/jps/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, atom/chasing, repath_delay, max_path_length, minimum_distance, list/access, simulated_only, turf/avoid, skip_first, initial_path)
	if(..() && repath_delay == src.repath_delay && max_path_length == src.max_path_length && minimum_distance == src.minimum_distance && access ~= src.access && simulated_only == src.simulated_only && avoid == src.avoid)
		return TRUE
	return FALSE

/datum/move_loop/has_target/jps/loop_started()
	. = ..()
	if(!movement_path)
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))

/datum/move_loop/has_target/jps/loop_stopped()
	. = ..()
	movement_path = null

/datum/move_loop/has_target/jps/Destroy()
	avoid = null
	on_finish_callbacks = null
	return ..()

///Tries to calculate a new path for this moveloop.
/datum/move_loop/has_target/jps/proc/recalculate_path()
	if(!COOLDOWN_FINISHED(src, repath_cooldown))
		return
	COOLDOWN_START(src, repath_cooldown, repath_delay)
	if(SSpathfinder.pathfind(moving, target, max_path_length, minimum_distance, access, simulated_only, avoid, skip_first, diagonal_handling, on_finish = on_finish_callbacks))
		is_pathing = TRUE
		SEND_SIGNAL(src, COMSIG_MOVELOOP_JPS_REPATH)

///Called when a path has finished being created
/datum/move_loop/has_target/jps/proc/on_finish_pathing(list/path)
	movement_path = path
	is_pathing = FALSE
	SEND_SIGNAL(src, COMSIG_MOVELOOP_JPS_FINISHED_PATHING, path)

/datum/move_loop/has_target/jps/move()
	if(!length(movement_path))
		if(is_pathing)
			return MOVELOOP_NOT_READY
		else
			INVOKE_ASYNC(src, PROC_REF(recalculate_path))
			return MOVELOOP_FAILURE

	var/turf/next_step = movement_path[1]
	var/atom/old_loc = moving.loc

	if(flags & MOVEMENT_LOOP_FORCE_MOVE)
		moving.forceMove(next_step)
	else
		moving.Move(next_step, get_dir(moving, next_step), FALSE, !(flags & MOVEMENT_LOOP_NO_DIR_UPDATE))
	. = (old_loc != moving?.loc) ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE

	// this check if we're on exactly the next tile may be overly brittle for dense objects who may get bumped slightly
	// to the side while moving but could maybe still follow their path without needing a whole new path
	if(get_turf(moving) == next_step)
		if(length(movement_path))
			movement_path.Cut(1,2)
	else
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))
		return MOVELOOP_FAILURE


///Base class of move_to and move_away, deals with the distance and target aspect of things
/datum/move_loop/has_target/dist_bound
	var/distance = 0

/datum/move_loop/has_target/dist_bound/setup(delay, timeout, atom/chasing, dist = 0)
	. = ..()
	if(!.)
		return
	distance = dist

/datum/move_loop/has_target/dist_bound/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, atom/chasing, dist = 0)
	if(..() && distance == dist)
		return TRUE
	return FALSE

///Returns FALSE if the movement should pause, TRUE otherwise
/datum/move_loop/has_target/dist_bound/proc/check_dist()
	return FALSE

/datum/move_loop/has_target/dist_bound/move()
	if(!check_dist()) //If we're too close don't do the move
		return MOVELOOP_FAILURE
	return MOVELOOP_SUCCESS


/**
 * Wrapper around walk_to()
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * min_dist - the closest we're allower to get to the target
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check __DEFINES/movement_defines.dm
 *
**/
/datum/move_manager/proc/move_to(moving, chasing, min_dist, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/has_target/dist_bound/move_to, priority, flags, extra_info, delay, timeout, chasing, min_dist)

///Wrapper around walk_to()
/datum/move_loop/has_target/dist_bound/move_to

/datum/move_loop/has_target/dist_bound/move_to/check_dist()
	return (get_dist(moving, target) > distance) //If you get too close, stop moving closer

/datum/move_loop/has_target/dist_bound/move_to/move()
	. = ..()
	if(!.)
		return
	var/atom/old_loc = moving.loc
	var/turf/next = get_step_to(moving, target)
	if(flags & MOVEMENT_LOOP_FORCE_MOVE)
		moving.forceMove(next)
	else
		moving.Move(next, get_dir(moving, next), FALSE, !(flags & MOVEMENT_LOOP_NO_DIR_UPDATE))
	return old_loc != moving?.loc ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE

/**
 * Wrapper around GLOB.move_manager.move_away()
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * max_dist - the furthest away from the target we're allowed to get
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check __DEFINES/movement_defines.dm
 *
**/
/datum/move_manager/proc/move_away(moving, chasing, max_dist, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/has_target/dist_bound/move_away, priority, flags, extra_info, delay, timeout, chasing, max_dist)

///Wrapper around GLOB.move_manager.move_away()
/datum/move_loop/has_target/dist_bound/move_away

/datum/move_loop/has_target/dist_bound/move_away/check_dist()
	return (get_dist(moving, target) < distance) //If you get too far out, stop moving away

/datum/move_loop/has_target/dist_bound/move_away/move()
	. = ..()
	if(!.)
		return
	var/atom/old_loc = moving.loc
	var/turf/next = get_step_away(moving, target)
	if(flags & MOVEMENT_LOOP_FORCE_MOVE)
		moving.forceMove(next)
	else
		moving.Move(next, get_dir(moving, next), FALSE, !(flags & MOVEMENT_LOOP_NO_DIR_UPDATE))
	return old_loc != moving?.loc ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE


/**
 * Helper proc for the move_towards datum
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * home - Should we move towards the object at all times? Or launch towards them, but allow walls and such to take us off track. Defaults to FALSE
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to INFINITY
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check __DEFINES/movement_defines.dm
 *
**/
/datum/move_manager/proc/move_towards(moving, chasing, delay, home, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/has_target/move_towards, priority, flags, extra_info, delay, timeout, chasing, home)

/**
 * Helper proc for homing onto something with move_towards
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * home - Should we move towards the object at all times? Or launch towards them, but allow walls and such to take us off track. Defaults to FALSE
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to INFINITY
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check __DEFINES/movement_defines.dm
 *
**/
/datum/move_manager/proc/home_onto(moving, chasing, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return move_towards(moving, chasing, delay, TRUE, timeout, subsystem, priority, flags, extra_info)

///Used as a alternative to GLOB.move_manager.home_onto
/datum/move_loop/has_target/move_towards
	/// Should we track our target, so we won't end up in the wrong place if it moves or if something knocks us off course?
	var/home = FALSE
	// This tracks our location with sub-tile precision, allowing us to move along a smooth line. We assume that we started at the center of the tile, so that our shifts along the shorter axis are centered in the movement path, rather than biased towards the start or end. It also makes floating point errors less problematic, because neither 0.4999 nor 0.5001 will cross a tile boundary.
	var/precise_x
	var/precise_y
	/// The speed at which we move along each axis, between -1 and 1
	var/x_speed
	var/y_speed

/datum/move_loop/has_target/move_towards/setup(delay, timeout, atom/chasing, home = FALSE)
	. = ..()
	if(!.)
		return FALSE
	src.home = home
	precise_x = moving.x + 0.5
	precise_y = moving.y + 0.5

	if(home && ismovable(target))
		// If we're following something that can move, make sure we keep moving towards it.
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(update_angle))
	update_angle()

/datum/move_loop/has_target/move_towards/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, atom/chasing, home = FALSE)
	if(..() && home == src.home)
		return TRUE
	return FALSE

/datum/move_loop/has_target/move_towards/Destroy()
	if(home)
		if(ismovable(target))
			UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	return ..()

/datum/move_loop/has_target/move_towards/move()
	var/old_turf = get_turf(moving)
	if(!old_turf)
		// If we aren't anywhere, we should stop moving.
		qdel(src)
		return

	// If we're not where we expect to be along either axis, we re-center ourselves within the correct tile along that axis.
	var/off_course = FALSE
	if(floor(precise_x) != moving.x)
		precise_x = moving.x + 0.5
		off_course = TRUE
	if(floor(precise_y) != moving.y)
		precise_y = moving.y + 0.5
		off_course = TRUE
	// And if we're homing, get back on course.
	if(home && off_course)
		update_angle()

	// Update our position based on our current speed.
	// We will always move at least one tile, because one of these is always 1 or -1.
	precise_x += x_speed
	precise_y += y_speed

	var/next_turf = locate(floor(precise_x), floor(precise_y), moving.z)
	if(flags & MOVEMENT_LOOP_FORCE_MOVE)
		moving.forceMove(next_turf)
	else
		moving.Move(next_turf, get_dir(old_turf, next_turf), FALSE, !(flags & MOVEMENT_LOOP_NO_DIR_UPDATE))

	var/turf/here = get_turf(moving)
	if(!here)
		// If we aren't anywhere, we should stop moving.
		qdel(src)
		return

	// If we didn't move the way we expected, re-center ourselves along the relevant axis/axes.
	off_course = FALSE
	if(here.x != floor(precise_x))
		precise_x = here.x + 0.5
		off_course = TRUE
	if(here.y != floor(precise_y))
		precise_y = here.y + 0.5
		off_course = TRUE

	// If we're homing, get back on course.
	if(home && off_course)
		update_angle()
	else if(get_turf(moving) == get_turf(target))
		// YOU FOUND IT! GOOD JOB!
		x_speed = 0
		y_speed = 0

	// If we moved at all, that's a win.
	return old_turf != here ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE

/datum/move_loop/has_target/move_towards/handle_no_target()
	if(home)
		return ..()
	target = null

/**
 * Recalculates the angle we're moving at, so that we get a smooth movement line, rather than awkwardly bending from orthogonal to diagonal (or vice versa) at some point.
 *
 * The way we set the angle is by adjusting the speed we move in each direction.
 * We always move at full speed along the longer axis towards our target.
 * For the other axis, we calculate the right speed to reach our target at the same time we did on the longer axis.
 * The net result is that every time we move, we approach the target along the longer axis, but we only move along the shorter axis at regular intervals, creating as smooth a line as possible.
**/
/datum/move_loop/has_target/move_towards/proc/update_angle()
	SIGNAL_HANDLER  // COMSIG_MOVABLE_MOVED

	var/delta_x = target.x - moving.x
	var/delta_y = target.y - moving.y
	if(delta_x == 0 && delta_y == 0)
		// We ain't goin nowhere.
		x_speed = 0
		y_speed = 0
		return

	if(abs(delta_x) >= abs(delta_y))
		// We need to move farther in the X direction, so always move along X.
		x_speed = sign(delta_x)
		// Move along Y often enough to smoothly reach the target.
		y_speed = delta_y / abs(delta_x)
	else
		// We need to move farther in the Y direction, so always move along Y.
		y_speed = sign(delta_y)
		// Move along X often enough to smoothly reach the target.
		x_speed = delta_x / abs(delta_y)

/**
 * Alternative to GLOB.move_manager.home_onto. Not reccomended, as it ends up putting a kink in the movement path if it's not directly along one of the 8 directions.
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check __DEFINES/movement_defines.dm
 *
**/
/datum/move_manager/proc/move_towards_legacy(moving, chasing, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/has_target/move_towards_budget, priority, flags, extra_info, delay, timeout, chasing)

///The actual implementation of GLOB.move_manager.home_onto()
/datum/move_loop/has_target/move_towards_budget

/datum/move_loop/has_target/move_towards_budget/move()
	var/turf/target_turf = get_step_towards(moving, target)
	var/atom/old_loc = moving.loc
	if(flags & MOVEMENT_LOOP_FORCE_MOVE)
		moving.forceMove(target_turf)
	else
		moving.Move(target_turf, get_dir(moving, target_turf), FALSE, !(flags & MOVEMENT_LOOP_NO_DIR_UPDATE))
	return old_loc != moving?.loc ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE

/**
 * Assigns a target to a move loop that immediately freezes for a set duration of time.
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * halted_turf - The turf we want to freeze on. This should typically be the loc of moving.
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. This should be considered extremely non-optional as it will completely stun out the movement loop <i>forever</i> if unset.
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check __DEFINES/movement_defines.dm
 */
/datum/move_manager/proc/freeze(moving, halted_turf, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/freeze, priority, flags, extra_info, delay, timeout, halted_turf)

/// As close as you can get to a "do-nothing" move loop, the pure intention of this is to absolutely resist all and any automated movement until the move loop times out.
/datum/move_loop/freeze

/datum/move_loop/freeze/move()
	return MOVELOOP_SUCCESS // it's successful because it's not moving. we autoclear outselves when `timeout` is reached

/**
 * Helper proc for the move_rand datum
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * directions - A list of acceptable directions to try and move in. Defaults to GLOB.alldirs
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check __DEFINES/movement_defines.dm
 *
**/
/datum/move_manager/proc/move_rand(moving, directions, delay, timeout, subsystem, priority, flags, datum/extra_info)
	if(!directions)
		directions = GLOB.alldirs
	return add_to_loop(moving, subsystem, /datum/move_loop/move_rand, priority, flags, extra_info, delay, timeout, directions)

/**
 * This isn't actually the same as walk_rand
 * Because walk_rand is really more like walk_to_rand
 * It appears to pick a spot outside of range, and move towards it, then pick a new spot, etc.
 * I can't actually replicate this on our side, because of how bad our pathfinding is, and cause I'm not totally sure I know what it's doing.
 * I can just implement a random-walk though
**/
/datum/move_loop/move_rand
	var/list/potential_directions

/datum/move_loop/move_rand/setup(delay, timeout, list/directions)
	. = ..()
	if(!.)
		return
	potential_directions = directions

/datum/move_loop/move_rand/compare_loops(datum/move_loop/loop_type, priority, flags, extra_info, delay, timeout, list/directions)
	if(..() && (length(potential_directions | directions) == length(potential_directions))) //i guess this could be useful if actually it really has yet to move
		return MOVELOOP_SUCCESS
	return MOVELOOP_FAILURE

/datum/move_loop/move_rand/move()
	var/list/potential_dirs = potential_directions.Copy()
	while(potential_dirs.len)
		var/testdir = pick(potential_dirs)
		var/turf/moving_towards = get_step(moving, testdir)
		var/atom/old_loc = moving.loc
		if(flags & MOVEMENT_LOOP_FORCE_MOVE)
			moving.forceMove(moving_towards)
		else
			moving.Move(moving_towards, testdir, FALSE, !(flags & MOVEMENT_LOOP_NO_DIR_UPDATE))
		if(old_loc != moving?.loc)  //If it worked, we're done
			return MOVELOOP_SUCCESS
		potential_dirs -= testdir
	return MOVELOOP_FAILURE

/**
 * Wrapper around walk_rand(), doesn't actually result in a random walk, it's more like moving to random places in viewish
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check __DEFINES/movement_defines.dm
 *
**/
/datum/move_manager/proc/move_to_rand(moving, delay, timeout, subsystem, priority, flags, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/move_to_rand, priority, flags, extra_info, delay, timeout)

///Wrapper around step_rand
/datum/move_loop/move_to_rand

/datum/move_loop/move_to_rand/move()
	var/atom/old_loc = moving.loc
	var/turf/next = get_step_rand(moving)
	if(flags & MOVEMENT_LOOP_FORCE_MOVE)
		moving.forceMove(next)
	else
		moving.Move(next, get_dir(moving, next), FALSE, !(flags & MOVEMENT_LOOP_NO_DIR_UPDATE))
	return old_loc != moving?.loc ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE

/**
 * Used for getting to a vent in a connected pipeline when ventcrawling.
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
 *
 * Arguments:
 * moving - The atom we want to move
 * chasing - The atom we want to move towards
 * min_dist - the closest we're allower to get to the target
 * delay - How many deci-seconds to wait between fires. Defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires. Defaults to infinity
 * subsystem - The movement subsystem to use. Defaults to SSmovement. Only one loop can exist for any one subsystem
 * priority - Defines how different move loops override each other. Lower numbers beat higher numbers, equal defaults to what currently exists. Defaults to MOVEMENT_DEFAULT_PRIORITY
 * flags - Set of bitflags that effect move loop behavior in some way. Check __DEFINES/movement_defines.dm
 *
**/
/datum/move_manager/proc/ventcrawl(moving, chasing, delay, timeout, subsystem, priority, flags, skip_first = TRUE, datum/extra_info)
	return add_to_loop(moving, subsystem, /datum/move_loop/has_target/ventcrawl, priority, flags, extra_info, delay, timeout, chasing, skip_first)

// Move loop for ventcrawling
/datum/move_loop/has_target/ventcrawl
	flags = MOVEMENT_LOOP_IGNORE_GLIDE
	///A list for the path we're currently following
	var/list/movement_path
	///Cooldown for repathing, prevents spam
	COOLDOWN_DECLARE(repath_cooldown)
	///Bool used to determine if we're already making a path in JPS. this prevents us from re-pathing while we're already busy.
	var/is_pathing = FALSE
	///Should we skip the first step? This is the tile we're currently on, which breaks some things
	var/skip_first

/datum/move_loop/has_target/ventcrawl/setup(delay, timeout, atom/chasing, skip_first)
	. = ..()
	if(!.)
		return
	src.skip_first = skip_first

/datum/move_loop/has_target/ventcrawl/loop_started()
	. = ..()
	if(!movement_path)
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))

/datum/move_loop/has_target/ventcrawl/loop_stopped()
	. = ..()
	movement_path = null

///Tries to calculate a new path for this moveloop.
/datum/move_loop/has_target/ventcrawl/proc/recalculate_path()
	if(!COOLDOWN_FINISHED(src, repath_cooldown))
		return
	COOLDOWN_START(src, repath_cooldown, 0.5 SECONDS)
	if(SSpathfinder.ventcrawl_pathfind(moving, target, skip_first, list(CALLBACK(src, PROC_REF(on_finish_pathing)))))
		is_pathing = TRUE

///Called when a path has finished being created
/datum/move_loop/has_target/ventcrawl/proc/on_finish_pathing(list/path)
	movement_path = path
	is_pathing = FALSE

/datum/move_loop/has_target/ventcrawl/move()
	// jps has skip_first for this purpose i think but we're not jps
	// while(length(movement_path) && movement_path[1] == moving.loc)
	// 	movement_path.Cut(1, 2)
	if(!length(movement_path))
		if(is_pathing)
			return MOVELOOP_NOT_READY
		INVOKE_ASYNC(src, PROC_REF(recalculate_path))
		return MOVELOOP_FAILURE

	var/obj/machinery/atmospherics/next_step = movement_path[1]
	var/atom/old_loc = moving.loc
	old_loc.relaymove(moving, get_dir(moving, next_step))
	. = (old_loc != moving?.loc) ? MOVELOOP_SUCCESS : MOVELOOP_FAILURE

	// this check if we're on exactly the next tile may be overly brittle for dense objects who may get bumped slightly
	// to the side while moving but could maybe still follow their path without needing a whole new path
	if(.)
		if(length(movement_path))
			movement_path.Cut(1, 2)
		return
	INVOKE_ASYNC(src, PROC_REF(recalculate_path))
	return MOVELOOP_FAILURE
