/atom/movable
	layer = 3
	appearance_flags = TILE_BOUND
	var/last_move = null
	var/anchored = 0
	// var/elevation = 2    - not used anywhere
	var/move_speed = 10
	var/l_move_time = 1
	var/datum/thrownthing/throwing = null
	var/throw_speed = 2 //How many tiles to move per ds when being thrown. Float values are fully supported
	var/throw_range = 7
	var/no_spin = 0
	var/no_spin_thrown = 0
	var/moved_recently = 0
	var/mob/pulledby = null

	var/inertia_dir = 0
	var/atom/inertia_last_loc
	var/inertia_moving = 0
	var/inertia_next_move = 0
	var/inertia_move_delay = 5

	var/moving_diagonally = 0 //0: not doing a diagonal move. 1 and 2: doing the first/second step of the diagonal move

	var/area/areaMaster

	var/auto_init = 1

/atom/movable/New()
	. = ..()
	areaMaster = get_area_master(src)

	// If you're wondering what goofery this is, this is for things that need the environment
	// around them set up - like `air_update_turf` and the like
	if((ticker && ticker.current_state >= GAME_STATE_SETTING_UP))
		attempt_init()

/atom/movable/Destroy()
	for(var/atom/movable/AM in contents)
		qdel(AM)
	var/turf/un_opaque
	if(opacity && isturf(loc))
		un_opaque = loc

	loc = null
	if(un_opaque)
		un_opaque.recalc_atom_opacity()
	if(pulledby)
		if(pulledby.pulling == src)
			pulledby.pulling = null
		pulledby = null
	return ..()

// used to provide a good interface for the init delay system to step in
// and we don't need to call `get_turf` until the game's started
// at which point object creations are a fair toss more seldom
/atom/movable/proc/attempt_init()
	var/turf/T = get_turf(src)
	if(T && space_manager.is_zlevel_dirty(T.z))
		space_manager.postpone_init(T.z, src)
	else if(auto_init)
		initialize()

/atom/movable/proc/initialize()
	return

// Used in shuttle movement and AI eye stuff.
// Primarily used to notify objects being moved by a shuttle/bluespace fuckup.
/atom/movable/proc/setLoc(var/T, var/teleported=0)
	loc = T

/atom/movable/Move(atom/newloc, direct = 0)
	if(!loc || !newloc) return 0
	var/atom/oldloc = loc

	if(loc != newloc)
		if(!(direct & (direct - 1))) //Cardinal move
			. = ..()
		else //Diagonal move, split it into cardinal moves
			moving_diagonally = FIRST_DIAG_STEP
			if(direct & 1)
				if(direct & 4)
					if(step(src, NORTH))
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, EAST)
					else if(step(src, EAST))
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, NORTH)
				else if(direct & 8)
					if(step(src, NORTH))
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, WEST)
					else if(step(src, WEST))
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, NORTH)
			else if(direct & 2)
				if(direct & 4)
					if(step(src, SOUTH))
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, EAST)
					else if(step(src, EAST))
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, SOUTH)
				else if(direct & 8)
					if(step(src, SOUTH))
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, WEST)
					else if(step(src, WEST))
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, SOUTH)
			moving_diagonally = 0
			return

	if(!loc || (loc == oldloc && oldloc != newloc))
		last_move = 0
		return

	if(.)
		Moved(oldloc, direct)

	last_move = direct
	src.move_speed = world.time - src.l_move_time
	src.l_move_time = world.time

	if(. && buckled_mob && !handle_buckled_mob_movement(loc, direct)) //movement failed due to buckled mob
		. = 0

// Called after a successful Move(). By this point, we've already moved
/atom/movable/proc/Moved(atom/OldLoc, Dir)
	if(!inertia_moving)
		inertia_next_move = world.time + inertia_move_delay
		newtonian_move(Dir)
	return 1

// Previously known as HasEntered()
// This is automatically called when something enters your square
/atom/movable/Crossed(atom/movable/AM)
	return

/atom/movable/Bump(atom/A, yes) //the "yes" arg is to differentiate our Bump proc from byond's, without it every Bump() call would become a double Bump().
	if(A && yes)
		if(throwing)
			throwing.hit_atom(A)
			. = 1
			if(!A || qdeleted(A))
				return
		A.Bumped(src)

/atom/movable/proc/forceMove(atom/destination)
	var/turf/old_loc = loc
	loc = destination

	if(old_loc)
		old_loc.Exited(src, destination)
		for(var/atom/movable/AM in old_loc)
			AM.Uncrossed(src)

	if(destination)
		destination.Entered(src)
		for(var/atom/movable/AM in destination)
			AM.Crossed(src)

		if(isturf(destination) && opacity)
			var/turf/new_loc = destination
			new_loc.reconsider_lights()

	if(isturf(old_loc) && opacity)
		old_loc.reconsider_lights()

	for(var/datum/light_source/L in light_sources)
		L.source_atom.update_light()

	return 1

/mob/living/forceMove(atom/destination)
	if(buckled)
		addtimer(src, "check_buckled", 1, TRUE)
	if(buckled_mob)
		addtimer(buckled_mob, "check_buckled", 1, TRUE)
	if(pulling)
		addtimer(src, "check_pull", 1, TRUE)
	. = ..()
	if(client)
		reset_perspective(destination)
	update_canmove() //if the mob was asleep inside a container and then got forceMoved out we need to make them fall.


//Called whenever an object moves and by mobs when they attempt to move themselves through space
//And when an object or action applies a force on src, see newtonian_move() below
//Return 0 to have src start/keep drifting in a no-grav area and 1 to stop/not start drifting
//Mobs should return 1 if they should be able to move of their own volition, see client/Move() in mob_movement.dm
//movement_dir == 0 when stopping or any dir when trying to move
/atom/movable/proc/Process_Spacemove(var/movement_dir = 0)
	if(has_gravity(src))
		return 1

	if(pulledby && !pulledby.pulling)
		return 1

	if(throwing)
		return 1

	if(locate(/obj/structure/lattice) in range(1, get_turf(src))) //Not realistic but makes pushing things in space easier
		return 1

	return 0

/atom/movable/proc/newtonian_move(direction) //Only moves the object if it's under no gravity
	if(!loc || Process_Spacemove(0))
		inertia_dir = 0
		return 0

	inertia_dir = direction
	if(!direction)
		return 1

	inertia_last_loc = loc
	drift_master.processing_list[src] = src
	return 1


//called when src is thrown into hit_atom
/atom/movable/proc/throw_impact(atom/hit_atom, throwingdatum)
	set waitfor = 0
	return hit_atom.hitby(src)

/atom/movable/hitby(atom/movable/AM, skipcatch, hitpush = 1, blocked)
	if(!anchored && hitpush)
		step(src, AM.dir)
	..()

/atom/movable/proc/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, var/datum/callback/callback)
	if(!target || (flags & NODROP) || speed <= 0)
		return 0

	if(pulledby)
		pulledby.stop_pulling()

	// They are moving! Wouldn't it be cool if we calculated their momentum and added it to the throw?
	if(thrower && thrower.last_move && thrower.client && thrower.client.move_delay >= world.time + world.tick_lag * 2)
		var/user_momentum = thrower.movement_delay()
		if(!user_momentum) // no movement_delay, this means they move once per byond tick, let's calculate from that instead
			user_momentum = world.tick_lag

		user_momentum = 1 / user_momentum // convert from ds to the tiles per ds that throw_at uses

		if(get_dir(thrower, target) & last_move)
			user_momentum = user_momentum // basically a noop, but needed
		else if(get_dir(target, thrower) & last_move)
			user_momentum = -user_momentum // we are moving away from the target, lets slowdown the throw accordingly
		else
			user_momentum = 0

		if(user_momentum)
			// first lets add that momentum to range
			range *= (user_momentum / speed) + 1
			//then lets add it to speed
			speed += user_momentum
			if(speed <= 0)
				return //no throw speed, the user was moving too fast.

	var/datum/thrownthing/TT = new()
	TT.thrownthing = src
	TT.target = target
	TT.target_turf = get_turf(target)
	TT.init_dir = get_dir(src, target)
	TT.maxrange = range
	TT.speed = speed
	TT.thrower = thrower
	TT.diagonals_first = diagonals_first
	TT.callback = callback

	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)
	var/dx = (target.x > src.x) ? EAST : WEST
	var/dy = (target.y > src.y) ? NORTH : SOUTH

	if(dist_x == dist_y)
		TT.pure_diagonal = 1

	else if(dist_x <= dist_y)
		var/olddist_x = dist_x
		var/olddx = dx
		dist_x = dist_y
		dist_y = olddist_x
		dx = dy
		dy = olddx
	TT.dist_x = dist_x
	TT.dist_y = dist_y
	TT.dx = dx
	TT.dy = dy
	TT.diagonal_error = dist_x / 2 - dist_y
	TT.start_time = world.time

	if(pulledby)
		pulledby.stop_pulling()

	throwing = TT
	if(spin && !no_spin && !no_spin_thrown)
		SpinAnimation(5, 1)

	throw_master.processing_list[src] = TT
	TT.tick()


//Overlays
/atom/movable/overlay
	var/atom/master = null
	anchored = 1

/atom/movable/overlay/New()
	verbs.Cut()
	return

/atom/movable/overlay/attackby(a, b, c)
	if(src.master)
		return src.master.attackby(a, b, c)
	return


/atom/movable/overlay/attack_hand(a, b, c)
	if(src.master)
		return src.master.attack_hand(a, b, c)
	return


/atom/movable/proc/water_act(var/volume, var/temperature, var/source) //amount of water acting : temperature of water in kelvin : object that called it (for shennagins)
	return 1

/atom/movable/proc/handle_buckled_mob_movement(newloc,direct)
	if(!buckled_mob.Move(newloc, direct))
		loc = buckled_mob.loc
		last_move = buckled_mob.last_move
		inertia_dir = last_move
		buckled_mob.inertia_dir = last_move
		return 0
	return 1

/atom/movable/CanPass(atom/movable/mover, turf/target, height=1.5)
	if(buckled_mob == mover)
		return 1
	return ..()

/atom/movable/proc/get_spacemove_backup()
	var/atom/movable/dense_object_backup
	for(var/A in orange(1, get_turf(src)))
		if(isarea(A))
			continue
		else if(isturf(A))
			var/turf/turf = A
			if(!turf.density)
				continue
			return turf
		else
			var/atom/movable/AM = A
			if(!AM.CanPass(src) || AM.density)
				if(AM.anchored)
					return AM
				dense_object_backup = AM
				break
	. = dense_object_backup
