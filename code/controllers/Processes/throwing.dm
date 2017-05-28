#define MAX_THROWING_DIST 512 // 2 z-levels on default width
#define MAX_TICKS_TO_MAKE_UP 3 //how many missed ticks will we attempt to make up for this run.

var/global/datum/controller/process/throwing/throw_master

/datum/controller/process/throwing
	var/list/processing_list

/datum/controller/process/throwing/setup()
	name = "throwing"
	schedule_interval = 1
	start_delay = 20
	log_startup_progress("Throw ticker starting up.")

/datum/controller/process/throwing/statProcess()
	..()
	stat(null, "P:[processing_list.len]")

/datum/controller/process/throwing/started()
	..()
	if(!processing_list)
		processing_list = list()

/datum/controller/process/throwing/doWork()
	for(last_object in processing_list)
		var/atom/movable/AM = last_object
		if(istype(AM) && isnull(AM.gcDestroyed))
			var/datum/thrownthing/TT = processing_list[AM]
			if(istype(TT) && isnull(TT.gcDestroyed))
				TT.tick()
				SCHECK
			else
				catchBadType(TT)
				processing_list -= AM
				AM.throwing = null
		else
			catchBadType(AM)
			processing_list -= AM
		SCHECK

DECLARE_GLOBAL_CONTROLLER(throwing, throw_master)

/datum/thrownthing
	var/atom/movable/thrownthing
	var/atom/target
	var/turf/target_turf
	var/init_dir
	var/maxrange
	var/speed
	var/mob/thrower
	var/diagonals_first
	var/dist_travelled = 0
	var/start_time
	var/dist_x
	var/dist_y
	var/dx
	var/dy
	var/pure_diagonal
	var/diagonal_error
	var/datum/callback/callback

/datum/thrownthing/proc/tick()
	var/atom/movable/AM = thrownthing
	if(!isturf(AM.loc) || !AM.throwing)
		finalize()
		return

	if(dist_travelled && hitcheck()) //to catch sneaky things moving on our tile while we slept
		finalize()
		return

	var/atom/step

	// calculate how many tiles to move, making up for any missed ticks.
	if((dist_travelled >= maxrange || AM.loc == target_turf) && has_gravity(AM, AM.loc))
		finalize()
		return

	if(dist_travelled <= max(dist_x, dist_y)) //if we haven't reached the target yet we home in on it, otherwise we use the initial direction
		step = get_step(AM, get_dir(AM, target_turf))
	else
		step = get_step(AM, init_dir)

	if(!pure_diagonal && !diagonals_first) // not a purely diagonal trajectory and we don't want all diagonal moves to be done first
		if(diagonal_error >= 0 && max(dist_x, dist_y) - dist_travelled != 1) // we do a step forward unless we're right before the target
			step = get_step(AM, dx)
		diagonal_error += (diagonal_error < 0) ? dist_x / 2 : -dist_y

	if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
		finalize()
		return

	AM.Move(step, get_dir(AM, step))

	if(!AM.throwing) // we hit something during our move
		finalize(hit = TRUE)
		return

	dist_travelled++

	if(dist_travelled > MAX_THROWING_DIST)
		finalize()
		return

/datum/thrownthing/proc/finalize(hit = FALSE)
	set waitfor = 0
	throw_master.processing_list -= thrownthing
	// done throwning, either because it hit something or it finished moving
	thrownthing.throwing = null
	if(!hit)
		for(var/thing in get_turf(thrownthing)) //looking for our target on the turf we land on.
			var/atom/A = thing
			if(A == target)
				hit = 1
				thrownthing.throw_impact(A, src)
				break
		if(!hit)
			thrownthing.throw_impact(get_turf(thrownthing), src) // we haven't hit something yet and we still must, let's hit the ground.
			thrownthing.newtonian_move(init_dir)
	else
		thrownthing.newtonian_move(init_dir)
	if(callback)
		callback.Invoke()

/datum/thrownthing/proc/hit_atom(atom/A)
	thrownthing.throw_impact(A, src)
	thrownthing.newtonian_move(init_dir)
	finalize(TRUE)

/datum/thrownthing/proc/hitcheck()
	for(var/thing in get_turf(thrownthing))
		var/atom/movable/AM = thing
		if(AM == thrownthing)
			continue
		if(AM.density && !(AM.pass_flags & LETPASSTHROW) && !(AM.flags & ON_BORDER))
			thrownthing.throwing = null
			thrownthing.throw_impact(AM, src)
			return TRUE