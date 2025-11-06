#define MAX_THROWING_DIST 512 // 2 z-levels on default width
#define MAX_TICKS_TO_MAKE_UP 3 //how many missed ticks will we attempt to make up for this run.

SUBSYSTEM_DEF(throwing)
	name = "Throwing"
	priority = FIRE_PRIORITY_THROWING
	wait = 1
	flags = SS_NO_INIT|SS_KEEP_TIMING|SS_TICKER
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	offline_implications = "Thrown objects may not react properly. Shuttle call recommended."
	cpu_display = SS_CPUDISPLAY_LOW

	var/list/currentrun
	var/list/processing = list()

	/// How many throw impact sounds have happened this tick.
	var/impact_sounds = 0
	/// How many throw impact sounds we allow per tick.
	var/impact_sounds_cap = 20
	/// How many sounds we've skipped due to hitting the per-tick cap.
	var/skipped_sounds = 0
	/// How many sounds there were last tick.
	var/last_impact_sounds = 0

/datum/controller/subsystem/throwing/get_stat_details()
	return "P:[length(processing)]"

/datum/controller/subsystem/throwing/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["processing"] = length(processing)
	.["custom"] = cust

/datum/controller/subsystem/throwing/fire(resumed = 0)
	if(!resumed)
		src.currentrun = processing.Copy()
		last_impact_sounds = impact_sounds
		impact_sounds = 0

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(length(currentrun))
		var/atom/movable/AM = currentrun[length(currentrun)]
		var/datum/thrownthing/thrown_thing = currentrun[AM]
		currentrun.len--
		if(QDELETED(AM) || QDELETED(thrown_thing))
			processing -= AM
			if(MC_TICK_CHECK)
				return
			continue

		thrown_thing.tick()

		if(MC_TICK_CHECK)
			return

	currentrun = null

/datum/controller/subsystem/throwing/proc/playsound_capped(atom/source, soundin, vol, vary, extrarange, falloff_exponent = SOUND_FALLOFF_EXPONENT, frequency, channel = 0, pressure_affected = TRUE, ignore_walls = TRUE, falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE, use_reverb = TRUE)
	if(impact_sounds < impact_sounds_cap)
		impact_sounds++
		playsound(source, soundin, vol, vary, extrarange, falloff_exponent, frequency, channel, pressure_affected, ignore_walls, falloff_distance, use_reverb)
	else
		skipped_sounds++

/datum/thrownthing
	///Thrown atom this datum is attached to
	var/atom/movable/thrownthing
	///UID of the original intended target of the throw, to prevent hardDels
	var/initial_target_uid
	///The turf that the target was on, if it's not a turf itself.
	var/turf/target_turf
	///The turf that we were thrown from.
	var/turf/starting_turf
	///If the target happens to be a carbon and that carbon has a body zone aimed at, this is carried on here.
	var/target_zone
	///The initial direction of the thrower of the thrownthing for building the trajectory of the throw.
	var/init_dir
	///The maximum number of turfs that the thrownthing will travel to reach it's target.
	var/maxrange
	///Turfs to travel per tick
	var/speed
	///If a mob is the one who has thrown the object, then its UID is stored here. This can be null and must be null checked before trying to use it.
	var/thrower_uid
	///A variable that helps in describing objects thrown at an angle, if it should be moved diagonally first or last.
	var/diagonals_first
	///Set to TRUE if the throw is exclusively diagonal (45 Degree angle throws for example)
	var/pure_diagonal
	///Tracks how far a thrownthing has traveled mid-throw for the purposes of maxrange
	var/dist_travelled = 0
	///The start_time obtained via world.time for the purposes of tiles moved/tick.
	var/start_time
	///Distance to travel in the X axis/direction.
	var/dist_x
	///Distance to travel in the y axis/direction.
	var/dist_y
	///The Horizontal direction we're traveling (EAST or WEST)
	var/dx
	///The VERTICAL direction we're traveling (NORTH or SOUTH)
	var/dy
	///The movement force provided to a given object in transit. More info on these in move_force.dm
	var/force = MOVE_FORCE_DEFAULT
	///How many tiles that need to be moved in order to travel to the target.
	var/diagonal_error
	///If a thrown thing has a callback, it can be invoked here within thrownthing.
	var/datum/callback/callback
	///Mainly exists for things that would freeze a thrown object in place, like a timestop'd tile. Or a Tractor Beam.
	var/paused = FALSE
	///How long an object has been paused for, to be added to the travel time.
	var/delayed_time = 0
	///The last world.time value stored when the thrownthing was moving.
	var/last_move = 0
	///When this variable is false, non dense mobs will be hit by a thrown item. useful for things that you dont want to be cheesed by crawling, EG. gravitational anomalies
	var/dodgeable = TRUE
	/// Can a thrown mob move themselves to stop the throw?
	var/should_block_movement = TRUE
	/// Will thrownthing datum actually block movement? this might be FALSE with some circumstances even if var/should_block_movement is TRUE. This variable change automatically during the throw
	var/block_movement = TRUE

/datum/thrownthing/New(thrownthing, atom/target, init_dir, maxrange, speed, atom/thrower, diagonals_first, force, callback, dodgeable, block_movement, target_zone)
	src.thrownthing = thrownthing
	RegisterSignal(thrownthing, COMSIG_PARENT_QDELETING, PROC_REF(on_thrownthing_qdel))
	src.starting_turf = get_turf(thrownthing)
	src.target_turf = get_turf(target)
	if(target_turf != target)
		src.initial_target_uid = target.UID()
	src.init_dir = init_dir
	src.maxrange = maxrange
	src.speed = speed
	if(thrower)
		src.thrower_uid = thrower.UID()
	src.diagonals_first = diagonals_first
	src.force = force
	src.callback = callback
	src.dodgeable = dodgeable
	src.should_block_movement = block_movement
	src.target_zone = target_zone

/datum/thrownthing/Destroy()
	SSthrowing.processing -= thrownthing
	SSthrowing.currentrun -= thrownthing
	thrownthing.throwing = null
	thrownthing = null
	thrower_uid = null
	initial_target_uid = null
	callback = null
	return ..()

///Defines the datum behavior on the thrownthing's qdeletion event.
/datum/thrownthing/proc/on_thrownthing_qdel(atom/movable/source, force)
	SIGNAL_HANDLER	// COMSIG_PARENT_QDELETING

	qdel(src)

/// Returns the mob thrower, or null
/datum/thrownthing/proc/get_thrower()
	. = locateUID(thrower_uid)
	if(isnull(.))
		thrower_uid = null

/datum/thrownthing/proc/tick()
	var/atom/movable/AM = thrownthing
	if(!isturf(AM.loc) || !AM.throwing)
		finalize()
		return

	if(paused)
		delayed_time += world.time - last_move
		return

	var/atom/movable/actual_target = locateUID(initial_target_uid)
	var/mob/mob_thrower = get_thrower()

	if(dist_travelled) //to catch sneaky things moving on our tile while we slept
		for(var/atom/movable/obstacle as anything in get_turf(thrownthing))
			if(obstacle == thrownthing || (obstacle == mob_thrower && !ismob(thrownthing)))
				continue
			if(ismob(obstacle) && (thrownthing.pass_flags & PASSMOB) && (obstacle != actual_target))
				continue
			if(obstacle.pass_flags_self & LETPASSTHROW)
				continue
			if(obstacle == actual_target || (obstacle.density && !(obstacle.flags & ON_BORDER) && !(obstacle in AM.buckled_mobs)))
				finalize(TRUE, obstacle)
				return

	var/atom/step

	last_move = world.time

	//calculate how many tiles to move, making up for any missed ticks.
	var/tilestomove = CEILING(min(((((world.time + world.tick_lag) - start_time + delayed_time) * speed) - (dist_travelled ? dist_travelled : -1)), speed * MAX_TICKS_TO_MAKE_UP) * (world.tick_lag * SSthrowing.wait), 1)
	while(tilestomove-- > 0)
		var/gravity
		if(ismob(AM))
			var/mob/mob = AM
			gravity = mob.mob_has_gravity(mob.loc)
		else
			gravity = has_gravity(AM, AM.loc)

		if((dist_travelled >= maxrange || AM.loc == target_turf) && gravity)
			finalize()
			return

		if(gravity)
			block_movement = should_block_movement
		else
			block_movement = FALSE	// you should be able to move if there is no gravity, supports jetpack movement during throw

		if(dist_travelled <= max(dist_x, dist_y)) //if we haven't reached the target yet we home in on it, otherwise we use the initial direction
			step = get_step(AM, get_dir(AM, target_turf))
		else
			step = get_step(AM, init_dir)

		if(!pure_diagonal && !diagonals_first) // not a purely diagonal trajectory and we don't want all diagonal moves to be done first
			if(diagonal_error >= 0 && max(dist_x, dist_y) - dist_travelled != 1) //we do a step forward unless we're right before the target
				step = get_step(AM, dx)
			diagonal_error += (diagonal_error < 0) ? dist_x / 2 : -dist_y

		if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
			finalize()
			return

		if(!AM.Move(step, get_dir(AM, step), DELAY_TO_GLIDE_SIZE(1 / speed))) // we hit something during our move...
			if(AM.throwing) // ...but finalize() wasn't called on Bump() because of a higher level definition that doesn't always call parent.
				finalize()
			return

		dist_travelled++

		if(actual_target && !(actual_target.pass_flags_self & LETPASSTHROW) && actual_target.loc == AM.loc) // we crossed a movable with no density (e.g. a mouse or APC) we intend to hit anyway.
			finalize(TRUE, actual_target)
			return

		if(dist_travelled > MAX_THROWING_DIST)
			finalize()
			return

/datum/thrownthing/proc/finalize(hit = FALSE, target = null)
	set waitfor = FALSE
	//done throwing, either because it hit something or it finished moving
	if(!thrownthing)
		return
	thrownthing.throwing = null
	if(!hit)
		if(get_turf(target) == get_turf(thrownthing))
			hit = TRUE
			thrownthing.throw_impact(target, src)
		if(!hit)
			thrownthing.throw_impact(get_turf(thrownthing), src)  // we haven't hit something yet and we still must, let's hit the ground.
			if(QDELETED(thrownthing)) //throw_impact can delete things, such as glasses smashing
				return //deletion should already be handled by on_thrownthing_qdel()
			thrownthing.newtonian_move(init_dir)
	else
		thrownthing.newtonian_move(init_dir)

	// Attempt to reset glide size once throw ends
	thrownthing.set_glide_size(initial(thrownthing.glide_size))

	if(target)
		thrownthing.throw_impact(target, src)
		if(QDELETED(thrownthing)) //throw_impact can delete things, such as glasses smashing
			return //deletion should already be handled by on_thrownthing_qdel()

	if(callback)
		callback.Invoke()

	if(thrownthing)
		SEND_SIGNAL(thrownthing, COMSIG_MOVABLE_THROW_LANDED, src)
		thrownthing.end_throw()

	qdel(src)

#undef MAX_THROWING_DIST
#undef MAX_TICKS_TO_MAKE_UP
