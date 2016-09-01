/atom/movable
	layer = 3
	appearance_flags = TILE_BOUND
	var/last_move = null
	var/anchored = 0
	// var/elevation = 2    - not used anywhere
	var/move_speed = 10
	var/l_move_time = 1
	var/throwing = 0
	var/thrower
	var/turf/throw_source = null
	var/throw_speed = 2
	var/throw_range = 7
	var/no_spin_thrown = 0 //set this to 1 if you don't want an item that you throw to spin, no matter what. -Fox
	var/moved_recently = 0
	var/mob/pulledby = null
	var/inertia_dir = 0

	var/area/areaMaster

	var/auto_init = 1

/atom/movable/New()
	. = ..()
	areaMaster = get_area_master(src)

	// If you're wondering what goofery this is, this is for things that need the environment
	// around them set up - like `air_update_turf` and the like
	if((ticker && ticker.current_state == GAME_STATE_PLAYING))
		attempt_init()

/atom/movable/Destroy()
	for(var/atom/movable/AM in contents)
		qdel(AM)
	loc = null
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
			if(direct & 1)
				if(direct & 4)
					if(step(src, NORTH))
						. = step(src, EAST)
					else if(step(src, EAST))
						. = step(src, NORTH)
				else if(direct & 8)
					if(step(src, NORTH))
						. = step(src, WEST)
					else if(step(src, WEST))
						. = step(src, NORTH)
			else if(direct & 2)
				if(direct & 4)
					if(step(src, SOUTH))
						. = step(src, EAST)
					else if(step(src, EAST))
						. = step(src, SOUTH)
				else if(direct & 8)
					if(step(src, SOUTH))
						. = step(src, WEST)
					else if(step(src, WEST))
						. = step(src, SOUTH)


	if(!loc || (loc == oldloc && oldloc != newloc))
		last_move = 0
		return

	last_move = direct
	src.move_speed = world.time - src.l_move_time
	src.l_move_time = world.time

	spawn(5)	// Causes space drifting. /tg/station has no concept of speed, we just use 5
		if(loc && direct && last_move == direct)
			if(loc == newloc) //Remove this check and people can accelerate. Not opening that can of worms just yet.
				newtonian_move(last_move)

	if(. && buckled_mob && !handle_buckled_mob_movement(loc, direct)) //movement failed due to buckled mob
		. = 0


// Previously known as Crossed()
// This is automatically called when something enters your square
/atom/movable/Crossed(atom/movable/AM)
	return

/atom/movable/Bump(var/atom/A as mob|obj|turf|area, sendBump)
	if(src.throwing)
		src.throw_impact(A)

	if(A && sendBump)
		A.last_bumped = world.time
		A.Bumped(src)
	else
		..()

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

//called when src is thrown into hit_atom
/atom/movable/proc/throw_impact(atom/hit_atom, var/speed)
	if(istype(hit_atom,/mob/living))
		var/mob/living/M = hit_atom
		M.hitby(src,speed)

	else if(isobj(hit_atom))
		var/obj/O = hit_atom
		if(!O.anchored)
			step(O, src.dir)
		O.hitby(src,speed)

	else if(isturf(hit_atom))
		src.throwing = 0
		var/turf/T = hit_atom
		if(T.density)
			spawn(2)
				step(src, turn(src.dir, 180))
			if(istype(src,/mob/living))
				var/mob/living/M = src
				M.turf_collision(T, speed)


//Called whenever an object moves and by mobs when they attempt to move themselves through space
//And when an object or action applies a force on src, see newtonian_move() below
//Return 0 to have src start/keep drifting in a no-grav area and 1 to stop/not start drifting
//Mobs should return 1 if they should be able to move of their own volition, see client/Move() in mob_movement.dm
//movement_dir == 0 when stopping or any dir when trying to move
/atom/movable/proc/Process_Spacemove(var/movement_dir = 0)
	if(has_gravity(src))
		return 1

	if(pulledby)
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

	var/old_dir = dir
	. = step(src, direction)
	dir = old_dir

//decided whether a movable atom being thrown can pass through the turf it is in.
/atom/movable/proc/hit_check(var/speed)
	if(src.throwing)
		for(var/atom/A in get_turf(src))
			if(A == src) continue
			if(istype(A,/mob/living))
				if(A:lying) continue
				src.throw_impact(A,speed)
			if(isobj(A))
				if(A.density && !A.throwpass)	// **TODO: Better behaviour for windows which are dense, but shouldn't always stop movement
					src.throw_impact(A,speed)

/atom/movable/proc/throw_at(atom/target, range, speed, thrower, no_spin)
	if(!target || !src || (flags & NODROP))
		return 0
	//use a modified version of Bresenham's algorithm to get from the atom's current position to that of the target

	src.throwing = 1
	src.thrower = thrower
	src.throw_source = get_turf(src)	//store the origin turf
	if(target.allow_spin) // turns out 1000+ spinning objects being thrown at the singularity creates lag - Iamgoofball
		if(!no_spin_thrown && !no_spin)
			SpinAnimation(5, 1)
	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)

	var/dx
	if(target.x > src.x)
		dx = EAST
	else
		dx = WEST

	var/dy
	if(target.y > src.y)
		dy = NORTH
	else
		dy = SOUTH
	var/dist_travelled = 0
	var/dist_since_sleep = 0
	var/area/a = get_area(src.loc)
	if(dist_x > dist_y)
		var/error = dist_x/2 - dist_y
		while(src && target &&((((src.x < target.x && dx == EAST) || (src.x > target.x && dx == WEST)) && dist_travelled < range) || (a && a.has_gravity == 0)  || istype(src.loc, /turf/space)) && src.throwing && istype(src.loc, /turf))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
			if(error < 0)
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.Move(step, get_dir(loc, step))
				hit_check(speed)
				error += dist_x
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(1)
			else
				var/atom/step = get_step(src, dx)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.Move(step)
				hit_check(speed)
				error -= dist_y
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(1)
			a = get_area(src.loc)
	else
		var/error = dist_y/2 - dist_x
		while(src && target &&((((src.y < target.y && dy == NORTH) || (src.y > target.y && dy == SOUTH)) && dist_travelled < range) || (a && a.has_gravity == 0)  || istype(src.loc, /turf/space)) && src.throwing && istype(src.loc, /turf))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
			if(error < 0)
				var/atom/step = get_step(src, dx)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.Move(step)
				hit_check(speed)
				error += dist_y
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(1)
			else
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.Move(step)
				hit_check(speed)
				error -= dist_x
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(1)

			a = get_area(src.loc)

	//done throwing, either because it hit something or it finished moving
	if(isobj(src)) src.throw_impact(get_turf(src),speed)
	src.throwing = 0
	src.thrower = null
	src.throw_source = null


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
