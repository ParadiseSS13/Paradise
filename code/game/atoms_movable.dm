/atom/movable
	layer = 3
	appearance_flags = TILE_BOUND
	var/last_move = null
	var/anchored = 0
	var/move_resist = MOVE_RESIST_DEFAULT
	var/move_force = MOVE_FORCE_DEFAULT
	var/pull_force = PULL_FORCE_DEFAULT
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
	var/atom/movable/pulling
	var/canmove = 1

	var/inertia_dir = 0
	var/atom/inertia_last_loc
	var/inertia_moving = 0
	var/inertia_next_move = 0
	var/inertia_move_delay = 5

	var/moving_diagonally = 0 //0: not doing a diagonal move. 1 and 2: doing the first/second step of the diagonal move

	var/area/areaMaster

/atom/movable/New()
	. = ..()
	areaMaster = get_area(src)

/atom/movable/attempt_init(loc, ...)
	var/turf/T = get_turf(src)
	if(T && SSatoms.initialized != INITIALIZATION_INSSATOMS && space_manager.is_zlevel_dirty(T.z))
		space_manager.postpone_init(T.z, src)
		return
	. = ..()

/atom/movable/Destroy()
	if(loc)
		loc.handle_atom_del(src)
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

/atom/movable/proc/start_pulling(atom/movable/AM, state, force = move_force, supress_message = FALSE)
	if(QDELETED(AM))
		return FALSE
	if(!(AM.can_be_pulled(src, state, force)))
		return FALSE

	// If we're pulling something then drop what we're currently pulling and pull this instead.
	if(pulling)
		if(state == 0)
			stop_pulling()
			return FALSE
		// Are we trying to pull something we are already pulling? Then enter grab cycle and end.
		if(AM == pulling)
			if(isliving(AM))
				var/mob/living/AMob = AM
				AMob.grabbedby(src)
			return TRUE
		stop_pulling()
	if(AM.pulledby)
		add_attack_logs(AM, AM.pulledby, "pulled from", ATKLOG_ALMOSTALL)
		AM.pulledby.stop_pulling() //an object can't be pulled by two mobs at once.
	pulling = AM
	AM.pulledby = src
	if(ismob(AM))
		var/mob/M = AM
		add_attack_logs(src, M, "passively grabbed", ATKLOG_ALMOSTALL)
		if(!supress_message)
			visible_message("<span class='warning'>[src] has grabbed [M] passively!</span>")
	return TRUE

/atom/movable/proc/stop_pulling()
	if(pulling)
		pulling.pulledby = null
		var/mob/living/ex_pulled = pulling
		pulling = null
		pulledby = null
		if(isliving(ex_pulled))
			var/mob/living/L = ex_pulled
			L.update_canmove()// mob gets up if it was lyng down in a chokehold

/atom/movable/proc/check_pulling()
	if(pulling)
		var/atom/movable/pullee = pulling
		if(pullee && get_dist(src, pullee) > 1)
			stop_pulling()
			return
		if(!isturf(loc))
			stop_pulling()
			return
		if(pullee && !isturf(pullee.loc) && pullee.loc != loc) //to be removed once all code that changes an object's loc uses forceMove().
			log_game("DEBUG:[src]'s pull on [pullee] wasn't broken despite [pullee] being in [pullee.loc]. Pull stopped manually.")
			stop_pulling()
			return
		if(pulling.anchored)
			stop_pulling()
			return

/atom/movable/proc/can_be_pulled(user, grab_state, force)
	if(src == user || !isturf(loc))
		return FALSE
	if(anchored || throwing)
		return FALSE
	if(force < (move_resist * MOVE_FORCE_PULL_RATIO))
		return FALSE
	return TRUE
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
	SEND_SIGNAL(src, COMSIG_MOVABLE_CROSSED, AM)

/atom/movable/Bump(atom/A, yes) //the "yes" arg is to differentiate our Bump proc from byond's, without it every Bump() call would become a double Bump().
	if(A && yes)
		SEND_SIGNAL(src, COMSIG_MOVABLE_BUMP, A)
		if(throwing)
			throwing.hit_atom(A)
			. = 1
			if(!A || QDELETED(A))
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
		addtimer(CALLBACK(src, .proc/check_buckled), 1, TIMER_UNIQUE)
	if(buckled_mob)
		addtimer(CALLBACK(buckled_mob, .proc/check_buckled), 1, TIMER_UNIQUE)
	if(pulling)
		addtimer(CALLBACK(src, .proc/check_pull), 1, TIMER_UNIQUE)
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
	SSspacedrift.processing[src] = src
	return 1


//called when src is thrown into hit_atom
/atom/movable/proc/throw_impact(atom/hit_atom, throwingdatum)
	set waitfor = 0
	SEND_SIGNAL(src, COMSIG_MOVABLE_IMPACT, hit_atom, throwingdatum)
	if(!QDELETED(hit_atom))
		return hit_atom.hitby(src)

/atom/movable/hitby(atom/movable/AM, skipcatch, hitpush = 1, blocked, datum/thrownthing/throwingdatum)
	if(!anchored && hitpush && (!throwingdatum || (throwingdatum.force >= (move_resist * MOVE_FORCE_PUSH_RATIO))))
		step(src, AM.dir)
	..()

/atom/movable/proc/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = INFINITY)
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

	SSthrowing.processing[src] = TT
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

/atom/movable/proc/force_pushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return FALSE

/atom/movable/proc/force_push(atom/movable/AM, force = move_force, direction, silent = FALSE)
	. = AM.force_pushed(src, force, direction)
	if(!silent && .)
		visible_message("<span class='warning'>[src] forcefully pushes against [AM]!</span>", "<span class='warning'>You forcefully push against [AM]!</span>")

/atom/movable/proc/move_crush(atom/movable/AM, force = move_force, direction, silent = FALSE)
	. = AM.move_crushed(src, force, direction)
	if(!silent && .)
		visible_message("<span class='danger'>[src] crushes past [AM]!</span>", "<span class='danger'>You crush [AM]!</span>")

/atom/movable/proc/move_crushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return FALSE

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

/atom/movable/proc/transfer_prints_to(atom/movable/target = null, overwrite = FALSE)
	if(!target)
		return
	if(overwrite)
		target.fingerprints = fingerprints
		target.fingerprintshidden = fingerprintshidden
	else
		target.fingerprints += fingerprints
		target.fingerprintshidden += fingerprintshidden
	target.fingerprintslast = fingerprintslast

/atom/movable/proc/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect, end_pixel_y)
	if(!no_effect && (visual_effect_icon || used_item))
		do_item_attack_animation(A, visual_effect_icon, used_item)

	if(A == src)
		return //don't do an animation if attacking self
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0
	var/final_pixel_y = initial(pixel_y)
	if(end_pixel_y)
		final_pixel_y = end_pixel_y

	var/direction = get_dir(src, A)
	if(direction & NORTH)
		pixel_y_diff = 8
	else if(direction & SOUTH)
		pixel_y_diff = -8

	if(direction & EAST)
		pixel_x_diff = 8
	else if(direction & WEST)
		pixel_x_diff = -8

	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 2)
	animate(pixel_x = initial(pixel_x), pixel_y = final_pixel_y, time = 2)

/atom/movable/proc/do_item_attack_animation(atom/A, visual_effect_icon, obj/item/used_item)
	var/image/I
	if(visual_effect_icon)
		I = image('icons/effects/effects.dmi', A, visual_effect_icon, A.layer + 0.1)
	else if(used_item)
		I = image(used_item.icon, A, used_item.icon_state, A.layer + 0.1)

		// Scale the icon.
		I.transform *= 0.75
		// The icon should not rotate.
		I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

		// Set the direction of the icon animation.
		var/direction = get_dir(src, A)
		if(direction & NORTH)
			I.pixel_y = -16
		else if(direction & SOUTH)
			I.pixel_y = 16

		if(direction & EAST)
			I.pixel_x = -16
		else if(direction & WEST)
			I.pixel_x = 16

		if(!direction) // Attacked self?!
			I.pixel_z = 16

	if(!I)
		return

	// Who can see the attack?
	var/list/viewing = list()
	for(var/mob/M in viewers(A))
		if(M.client && M.client.prefs.show_ghostitem_attack)
			viewing |= M.client

	flick_overlay(I, viewing, 5) // 5 ticks/half a second

	// And animate the attack!
	var/t_color = "#ffffff"
	if(ismob(src) &&  ismob(A) && (!used_item))
		var/mob/M = src
		t_color = M.a_intent == INTENT_HARM ? "#ff0000" : "#ffffff"
	animate(I, alpha = 175, pixel_x = 0, pixel_y = 0, pixel_z = 0, time = 3, color = t_color)

/atom/movable/proc/portal_destroyed(obj/effect/portal/P)
	return
