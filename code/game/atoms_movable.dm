/atom/movable
	layer = 3
	appearance_flags = TILE_BOUND
	glide_size = 8 // Default, adjusted when mobs move based on their movement delays
	var/last_move = null
	var/anchored = FALSE
	var/move_resist = MOVE_RESIST_DEFAULT
	var/move_force = MOVE_FORCE_DEFAULT
	var/pull_force = PULL_FORCE_DEFAULT
	// var/elevation = 2    - not used anywhere
	var/move_speed = 10
	var/l_move_time = 1
	var/datum/thrownthing/throwing = null
	var/throw_speed = 2 //How many tiles to move per ds when being thrown. Float values are fully supported
	var/throw_range = 7
	var/no_spin = FALSE
	var/no_spin_thrown = FALSE
	var/moved_recently = FALSE
	var/mob/pulledby = null
	var/atom/movable/pulling
	/// Face towards the atom while pulling it
	var/face_while_pulling = FALSE
	var/throwforce = 0

	var/inertia_dir = 0
	var/atom/inertia_last_loc
	var/inertia_moving = 0
	var/inertia_next_move = 0
	var/inertia_move_delay = 5

	var/moving_diagonally = 0 //0: not doing a diagonal move. 1 and 2: doing the first/second step of the diagonal move
	var/list/client_mobs_in_contents

	/// Either FALSE, [EMISSIVE_BLOCK_GENERIC], or [EMISSIVE_BLOCK_UNIQUE]
	var/blocks_emissive = FALSE
	///Internal holder for emissive blocker object, do not use directly use blocks_emissive
	var/atom/movable/emissive_blocker/em_block
	/// Icon state for thought bubbles. Normally set by mobs.
	var/thought_bubble_image = "thought_bubble"

/atom/movable/attempt_init(loc, ...)
	var/turf/T = get_turf(src)
	if(T && SSatoms.initialized != INITIALIZATION_INSSATOMS && GLOB.space_manager.is_zlevel_dirty(T.z))
		GLOB.space_manager.postpone_init(T.z, src)
		return
	. = ..()

/atom/movable/Initialize(mapload)
	. = ..()
	switch(blocks_emissive)
		if(EMISSIVE_BLOCK_GENERIC)
			var/mutable_appearance/gen_emissive_blocker = mutable_appearance(icon, icon_state, plane = EMISSIVE_PLANE, alpha = src.alpha)
			gen_emissive_blocker.color = EM_BLOCK_COLOR
			gen_emissive_blocker.dir = dir
			gen_emissive_blocker.appearance_flags |= appearance_flags
			AddComponent(/datum/component/emissive_blocker, gen_emissive_blocker)
		if(EMISSIVE_BLOCK_UNIQUE)
			render_target = ref(src)
			em_block = new(src, render_target)
			add_overlay(list(em_block))

/atom/movable/proc/update_emissive_block()
	if(!em_block && !QDELETED(src))
		render_target = ref(src)
		em_block = new(src, render_target)
	add_overlay(list(em_block))

/atom/movable/Destroy()
	unbuckle_all_mobs(force = TRUE)
	QDEL_NULL(em_block)
	. = ..()
	if(loc)
		loc.handle_atom_del(src)
	for(var/atom/movable/AM in contents)
		qdel(AM)
	LAZYCLEARLIST(client_mobs_in_contents)
	loc = null
	if(pulledby)
		pulledby.stop_pulling()

//Returns an atom's power cell, if it has one. Overload for individual items.
/atom/movable/proc/get_cell()
	return

/atom/movable/proc/start_pulling(atom/movable/AM, state, force = pull_force, show_message = FALSE)
	if(QDELETED(AM))
		return FALSE
	if(!(AM.can_be_pulled(src, state, force)))
		return FALSE

	// if we're pulling something then drop what we're currently pulling and pull this instead.
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
		if(show_message)
			visible_message("<span class='warning'>[src] has grabbed [M] passively!</span>")
	return TRUE

/atom/movable/proc/stop_pulling()
	if(pulling)
		pulling.pulledby = null
		pulling = null

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
		if(pulling.anchored || pulling.move_resist > move_force)
			stop_pulling()
			return
	if(pulledby && moving_diagonally != FIRST_DIAG_STEP && get_dist(src, pulledby) > 1)		//separated from our puller and not in the middle of a diagonal move.
		pulledby.stop_pulling()

/atom/movable/proc/can_be_pulled(user, grab_state, force, show_message = FALSE)
	if(src == user || !isturf(loc))
		return FALSE
	if(anchored || move_resist == INFINITY)
		if(show_message)
			to_chat(user, "<span class='warning'>[src] appears to be anchored to the ground!</span>")
		return FALSE
	if(throwing)
		return FALSE
	if(force < (move_resist * MOVE_FORCE_PULL_RATIO))
		if(show_message)
			to_chat(user, "<span class='warning'>[src] is too heavy to pull!</span>")
		return FALSE
	if(user in buckled_mobs)
		return FALSE
	return TRUE

// Used in shuttle movement and AI eye stuff.
// Primarily used to notify objects being moved by a shuttle/bluespace fuckup.
/atom/movable/proc/setLoc(T, teleported=0)
	var/old_loc = loc
	loc = T
	Moved(old_loc, get_dir(old_loc, loc))

/atom/movable/Move(atom/newloc, direct = 0, movetime)
	if(!loc || !newloc) return 0
	var/atom/oldloc = loc

	if(loc != newloc)
		if(movetime > 0)
			glide_for(movetime)
		if(!(direct & (direct - 1))) //Cardinal move
			. = ..(newloc, direct) // don't pass up movetime
		else //Diagonal move, split it into cardinal moves
			moving_diagonally = FIRST_DIAG_STEP
			var/first_step_dir
			// The `&& moving_diagonally` checks are so that a forceMove taking
			// place due to a Crossed, Bumped, etc. call will interrupt
			// the second half of the diagonal movement, or the second attempt
			// at a first half if the cardinal Move() fails because we hit something.
			if(direct & NORTH)
				if(direct & EAST)
					if(Move(get_step(src,  NORTH),  NORTH) && moving_diagonally)
						first_step_dir = NORTH
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src,  EAST),  EAST)
					else if(moving_diagonally && Move(get_step(src,  EAST),  EAST))
						first_step_dir = EAST
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src,  NORTH),  NORTH)
				else if(direct & WEST)
					if(Move(get_step(src,  NORTH),  NORTH) && moving_diagonally)
						first_step_dir = NORTH
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src,  WEST),  WEST)
					else if(moving_diagonally && Move(get_step(src,  WEST),  WEST))
						first_step_dir = WEST
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src,  NORTH),  NORTH)
			else if(direct & SOUTH)
				if(direct & EAST)
					if(Move(get_step(src,  SOUTH),  SOUTH) && moving_diagonally)
						first_step_dir = SOUTH
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src,  EAST),  EAST)
					else if(moving_diagonally && Move(get_step(src,  EAST),  EAST))
						first_step_dir = EAST
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src,  SOUTH),  SOUTH)
				else if(direct & WEST)
					if(Move(get_step(src,  SOUTH),  SOUTH) && moving_diagonally)
						first_step_dir = SOUTH
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src,  WEST),  WEST)
					else if(moving_diagonally && Move(get_step(src,  WEST),  WEST))
						first_step_dir = WEST
						moving_diagonally = SECOND_DIAG_STEP
						. = Move(get_step(src,  SOUTH),  SOUTH)
			if(moving_diagonally == SECOND_DIAG_STEP)
				if(!.)
					setDir(first_step_dir)
				else if(!inertia_moving)
					inertia_next_move = world.time + inertia_move_delay
					newtonian_move(direct)
			moving_diagonally = 0
			return

	if(!loc || (loc == oldloc && oldloc != newloc))
		last_move = 0
		return

	if(.)
		Moved(oldloc, direct)

	last_move = direct
	move_speed = world.time - l_move_time
	l_move_time = world.time

	if(. && has_buckled_mobs() && !handle_buckled_mob_movement(loc, direct, movetime)) //movement failed due to buckled mob
		. = 0

// Called after a successful Move(). By this point, we've already moved
/atom/movable/proc/Moved(atom/OldLoc, Dir, Forced = FALSE)
	SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, OldLoc, Dir, Forced)
	if(!inertia_moving)
		inertia_next_move = world.time + inertia_move_delay
		newtonian_move(Dir)
	if(length(client_mobs_in_contents))
		update_parallax_contents()

	var/datum/light_source/L
	var/thing
	for (thing in light_sources) // Cycle through the light sources on this atom and tell them to update.
		L = thing
		L.source_atom.update_light()
	return TRUE

// Change glide size for the duration of one movement
/atom/movable/proc/glide_for(movetime)
	if(movetime)
		glide_size = world.icon_size/max(DS2TICKS(movetime), 1)
		spawn(movetime)
			glide_size = initial(glide_size)
	else
		glide_size = initial(glide_size)

// Previously known as HasEntered()
// This is automatically called when something enters your square
/atom/movable/Crossed(atom/movable/AM, oldloc)
	SEND_SIGNAL(src, COMSIG_MOVABLE_CROSSED, AM)
	SEND_SIGNAL(AM, COMSIG_CROSSED_MOVABLE, src)

/atom/movable/Uncrossed(atom/movable/AM)
	SEND_SIGNAL(src, COMSIG_MOVABLE_UNCROSSED, AM)

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
	moving_diagonally = 0

	if(old_loc)
		old_loc.Exited(src, destination)
		for(var/atom/movable/AM in old_loc)
			AM.Uncrossed(src)

	if(destination)
		destination.Entered(src)
		for(var/atom/movable/AM in destination)
			if(AM == src)
				continue
			AM.Crossed(src, old_loc)
		var/turf/oldturf = get_turf(old_loc)
		var/turf/destturf = get_turf(destination)
		var/old_z = (oldturf ? oldturf.z : null)
		var/dest_z = (destturf ? destturf.z : null)
		if(old_z != dest_z)
			onTransitZ(old_z, dest_z)

	Moved(old_loc, NONE)

	return 1

/atom/movable/proc/onTransitZ(old_z,new_z)
	for(var/item in src) // Notify contents of Z-transition. This can be overridden if we know the items contents do not care.
		var/atom/movable/AM = item
		AM.onTransitZ(old_z,new_z)
	SEND_SIGNAL(src, COMSIG_MOVABLE_Z_CHANGED)

/mob/living/forceMove(atom/destination)
	if(buckled)
		addtimer(CALLBACK(src, PROC_REF(check_buckled)), 1, TIMER_UNIQUE)
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			addtimer(CALLBACK(buckled_mob, PROC_REF(check_buckled)), 1, TIMER_UNIQUE)
	if(pulling)
		addtimer(CALLBACK(src, PROC_REF(check_pull)), 1, TIMER_UNIQUE)
	. = ..()
	if(client)
		reset_perspective(destination)
		if(hud_used && length(client.parallax_layers))
			hud_used.update_parallax()
	update_runechat_msg_location()


//Called whenever an object moves and by mobs when they attempt to move themselves through space
//And when an object or action applies a force on src, see newtonian_move() below
//Return 0 to have src start/keep drifting in a no-grav area and 1 to stop/not start drifting
//Mobs should return 1 if they should be able to move of their own volition, see client/Move() in mob_movement.dm
//movement_dir == 0 when stopping or any dir when trying to move
/atom/movable/proc/Process_Spacemove(movement_dir = 0)
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

/// called after an items throw is ended.
/atom/movable/proc/end_throw()
	return

/atom/movable/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked, datum/thrownthing/throwingdatum)
	if(!anchored && hitpush && (!throwingdatum || (throwingdatum.force >= (move_resist * MOVE_FORCE_PUSH_RATIO))))
		step(src, AM.dir)
	..()

/atom/movable/proc/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = INFINITY, dodgeable = TRUE)
	if(!target || (flags & NODROP) || speed <= 0)
		return 0

	if(pulledby)
		pulledby.stop_pulling()

	// They are moving! Wouldn't it be cool if we calculated their momentum and added it to the throw?
	if(istype(thrower) && thrower.last_move && thrower.client && thrower.client.move_delay >= world.time + world.tick_lag * 2)
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
	TT.dodgeable = dodgeable

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

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_THROW, TT, spin)
	SSthrowing.processing[src] = TT
	TT.tick()

	return TRUE

//Overlays
/atom/movable/overlay
	var/atom/master = null
	anchored = TRUE
	simulated = FALSE

/atom/movable/overlay/New()
	. = ..()
	verbs.Cut()
	return

/atom/movable/overlay/attackby(a, b, c)
	if(master)
		return master.attackby(a, b, c)

/atom/movable/overlay/attack_hand(a, b, c)
	if(master)
		return master.attack_hand(a, b, c)

/atom/movable/proc/handle_buckled_mob_movement(newloc,direct,movetime)
	for(var/m in buckled_mobs)
		var/mob/living/buckled_mob = m
		if(!buckled_mob.Move(newloc, direct, movetime))
			forceMove(buckled_mob.loc)
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
	if(mover in buckled_mobs)
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

/atom/movable/proc/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && (visual_effect_icon || used_item))
		do_item_attack_animation(A, visual_effect_icon, used_item)

	if(A == src)
		return //don't do an animation if attacking self
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0
	var/turn_dir = 1

	var/direction = get_dir(src, A)
	if(direction & NORTH)
		pixel_y_diff = 8
		turn_dir = prob(50) ? -1 : 1
	else if(direction & SOUTH)
		pixel_y_diff = -8
		turn_dir = prob(50) ? -1 : 1

	if(direction & EAST)
		pixel_x_diff = 8
	else if(direction & WEST)
		pixel_x_diff = -8
		turn_dir = -1

	var/matrix/initial_transform = matrix(transform)
	var/matrix/rotated_transform = transform.Turn(5 * turn_dir)
	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, transform = rotated_transform, time = 0.1 SECONDS, easing = CUBIC_EASING)
	animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, transform = initial_transform, time = 0.2 SECONDS, easing = SINE_EASING)

/atom/movable/proc/do_item_attack_animation(atom/A, visual_effect_icon, obj/item/used_item)
	var/image/I
	if(visual_effect_icon)
		I = image('icons/effects/effects.dmi', A, visual_effect_icon, A.layer + 0.1)
	else if(used_item)
		I = image(icon = used_item, loc = A, layer = A.layer + 0.1)
		I.plane = GAME_PLANE

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
		if(M.client && M.client.prefs.toggles2 & PREFTOGGLE_2_ITEMATTACK)
			viewing |= M.client

	I.appearance_flags |= RESET_TRANSFORM | KEEP_APART
	flick_overlay(I, viewing, 7) // 7 ticks/half a second

	// And animate the attack!
	var/t_color = "#ffffff"
	if(ismob(src) && ismob(A) && !used_item)
		var/mob/M = src
		t_color = M.a_intent == INTENT_HARM ? "#ff0000" : "#ffffff"
	animate(I, alpha = 175, pixel_x = 0, pixel_y = 0, pixel_z = 0, time = 0.3 SECONDS, color = t_color)
	animate(time = 0.1 SECONDS)
	animate(alpha = 0, time = 0.3 SECONDS, easing = CIRCULAR_EASING | EASE_OUT)

/atom/movable/proc/portal_destroyed(obj/effect/portal/P)
	return

/atom/movable/proc/decompile_act(obj/item/matter_decompiler/C, mob/user) // For drones to decompile mobs and objs. See drone for an example.
	return FALSE

/// called when a mob gets shoved into an items turf. false means the mob will be shoved backwards normally, true means the mob will not be moved by the disarm proc.
/atom/movable/proc/shove_impact(mob/living/target, mob/living/attacker)
	return FALSE

/**
 * Adds the deadchat_plays component to this atom with simple movement commands.
 *
 * Returns the component added.
 * Arguments:
 * * mode - Either DEADCHAT_ANARCHY_MODE or DEADCHAT_DEMOCRACY_MODE passed to the deadchat_control component. See [/datum/component/deadchat_control] for more info.
 * * cooldown - The cooldown between command inputs passed to the deadchat_control component. See [/datum/component/deadchat_control] for more info.
 */
/atom/movable/proc/deadchat_plays(mode = DEADCHAT_ANARCHY_MODE, cooldown = 12 SECONDS)
	return AddComponent(/datum/component/deadchat_control/cardinal_movement, mode, list(), cooldown)

/// Easy way to remove the component when the fun has been played out
/atom/movable/proc/stop_deadchat_plays()
	var/datum/component/deadchat_control/comp = GetComponent(/datum/component/deadchat_control)
	if(!QDELETED(comp))
		qdel(comp)

/atom/movable/vv_get_dropdown()
	. = ..()
	if(!GetComponent(/datum/component/deadchat_control))
		.["Give deadchat control"] = "?_src_=vars;grantdeadchatcontrol=[UID()]"
	else
		.["Remove deadchat control"] = "?_src_=vars;removedeadchatcontrol=[UID()]"


//Update the screentip to reflect what we're hovering over
/atom/movable/MouseEntered(location, control, params)
	var/datum/hud/active_hud = usr.hud_used // Don't nullcheck this stuff, if it breaks we wanna know it breaks
	var/screentip_mode = usr.client.prefs.screentip_mode
	if(screentip_mode == 0 || (flags & NO_SCREENTIPS))
		active_hud.screentip_text.maptext = ""
		return
	//We inline a MAPTEXT() here, because there's no good way to statically add to a string like this
	active_hud.screentip_text.maptext = "<span class='maptext' style='font-family: sans-serif; text-align: center; font-size: [screentip_mode]px; color: [usr.client.prefs.screentip_color]'>[name]</span>"

/atom/movable/MouseExited(location, control, params)
	usr.hud_used.screentip_text.maptext = ""

/atom/movable/proc/choose_crush_crit(mob/living/carbon/victim)
	if(!length(GLOB.tilt_crits))
		return
	for(var/crit_path in shuffle(GLOB.tilt_crits))
		var/datum/tilt_crit/C = GLOB.tilt_crits[crit_path]
		if(C.is_valid(src, victim))
			return C

/atom/movable/proc/handle_squish_carbon(mob/living/carbon/victim, damage_to_deal, datum/tilt_crit/crit)

	// Damage points to "refund", if a crit already beats the shit out of you we can shelve some of the extra damage.
	var/crit_rebate = 0

	if(HAS_TRAIT(victim, TRAIT_DWARF))
		// also double damage if you're short
		damage_to_deal *= 2

	if(crit)
		crit_rebate = crit.tip_crit_effect(src, victim)
		if(crit.harmless)
			return

		add_attack_logs(null, victim, "critically crushed by [src] causing [crit]")
	else
		add_attack_logs(null, victim, "crushed by [src]")

	// 30% chance to spread damage across the entire body, 70% chance to target two limbs in particular
	damage_to_deal = max(damage_to_deal - crit_rebate, 0)
	if(prob(30))
		victim.apply_damage(damage_to_deal, BRUTE, BODY_ZONE_CHEST, spread_damage = TRUE)
	else
		var/picked_zone
		var/num_parts_to_pick = 2
		for(var/i in 1 to num_parts_to_pick)
			picked_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_R_LEG)
			victim.apply_damage((damage_to_deal) * (1 / num_parts_to_pick), BRUTE, picked_zone)

	victim.AddElement(/datum/element/squish, 80 SECONDS)

#define NO_CRUSH_DIR "no_dir"

/**
 * Tip over this atom onto a turf, crushing things in its path.
 *
 * Arguments:
 * * target_turf - The turf to fall onto.
 * * should_crit - If true, we'll try to crit things that we crush.
 * * crit_damage_factor - If a crit is rolled, crush_damage will be multiplied by this amount.
 * * forced_crit - If passed, this crit will be applied to everything it crushes.
 * * weaken_time - The amount of time that weaken will be applied to crushed mobs.
 * * knockdown_time - The amount of time that knockdown will be applied to crushed mobs.
 * * ignore_gravity - If false, we won't fall over in zero G.
 * * should_rotate - If false, we won't rotate when we fall.
 * * angle - The angle by which we'll rotate. If this is null/0, we'll randomly rotate 90 degrees clockwise or counterclockwise.
 * * rightable - If true, the tilted component will be applied, allowing people to alt-click to right it.
 * * block_interactions_until_righted - If true, interactions with the object will be blocked until it's righted.
 * * crush_dir - An override on the cardinal direction we're crushing.
 */
/atom/movable/proc/fall_and_crush(turf/target_turf, crush_damage, should_crit = FALSE, crit_damage_factor = 2, datum/tilt_crit/forced_crit, weaken_time = 4 SECONDS, knockdown_time = 10 SECONDS, ignore_gravity = FALSE, should_rotate = TRUE, angle, rightable = FALSE, block_interactions_until_righted = FALSE, crush_dir = NO_CRUSH_DIR)
	if(QDELETED(src) || isnull(target_turf))
		return

	if(crush_dir == NO_CRUSH_DIR)
		crush_dir = get_dir(get_turf(src), target_turf)

	var/has_tried_to_move = FALSE

	if(is_blocked_turf(target_turf, TRUE, excluded_objs=list(src)))
		has_tried_to_move = TRUE
		if(!Move(target_turf, crush_dir))
			// we'll try to move, and if we didn't end up going anywhere, then we do nothing.
			visible_message("<span class='warning'>[src] seems to rock, but doesn't fall over!</span>")
			return

	for(var/atom/target in (target_turf.contents) + target_turf)
		if(isarea(target) || target == src)  // don't crush ourselves
			continue

		if(isobserver(target))
			continue

		// ignore things that are under the ground
		if(isobj(target) && (target.invisibility > SEE_INVISIBLE_LIVING) || iseffect(target) || isitem(target) || target.level == 1)
			continue

		var/datum/tilt_crit/crit_case = forced_crit
		if(isnull(forced_crit) && should_crit)
			crit_case = choose_crush_crit(target)
		// note that it could still be null after this point, in which case it won't crit
		var/damage_to_deal = crush_damage

		if(isliving(target))
			var/mob/living/L = target

			if(crit_case)
				damage_to_deal *= crit_damage_factor
			if(iscarbon(L))
				handle_squish_carbon(L, damage_to_deal, crit_case)
			else
				L.apply_damage(damage_to_deal, BRUTE)
			L.Weaken(weaken_time)
			L.emote("scream")
			L.KnockDown(knockdown_time)
			playsound(L, 'sound/effects/blobattack.ogg', 40, TRUE)
			playsound(L, 'sound/effects/splat.ogg', 50, TRUE)
			add_attack_logs(src, L, "crushed by [src]")


		else if(isobj(target))  // don't crush things on the floor, that'd probably be annoying
			var/obj/O = target
			O.take_damage(damage_to_deal, BRUTE, "", FALSE)
		else
			continue

		target.visible_message(
			"<span class='danger'>[target] is crushed by [src]!</span>",
			"<span class='userdanger'>[src] crushes you!</span>",
			"<span class='warning'>You hear a loud crunch!</span>"
		)

	tilt_over(target_turf, angle, should_rotate, rightable, block_interactions_until_righted)
	// for things that trigger on Crossed()
	if(!has_tried_to_move)
		Move(target_turf, crush_dir)

	return TRUE

#undef NO_CRUSH_DIR

/**
 * Tip over an atom without too much fuss. This won't cause damage to anything, and just rotates the thing and (optionally) adds the component.
 *
 * Arguments:
 * * target - The turf to tilt over onto
 * * rotation_angle - The angle to rotate by. If not given, defaults to random rotating by 90 degrees clockwise or counterclockwise
 * * should_rotate - Whether or not we should rotate at all
 * * rightable - Whether or not this object should be rightable, attaching the tilted component to it
 * * block_interactions_until_righted - If true, this object will need to be righted before it can be interacted with
 */
/atom/movable/proc/tilt_over(turf/target, rotation_angle, should_rotate, rightable, block_interactions_until_righted)
	visible_message("<span class='danger'>[src] tips over!</span>", "<span class='danger'>You hear a loud crash!</span>")
	playsound(src, "sound/effects/bang.ogg", 100, TRUE)
	var/rot_angle = rotation_angle ? rotation_angle : pick(90, -90)
	if(should_rotate)
		var/matrix/to_turn = turn(transform, rot_angle)
		animate(src, transform = to_turn, 0.2 SECONDS)
	if(target && target != get_turf(src))
		throw_at(target, 1, 1, spin = FALSE)
	if(rightable)
		layer = ABOVE_MOB_LAYER
		AddComponent(/datum/component/tilted, 14 SECONDS, block_interactions_until_righted, rot_angle)

/// Untilt a tilted object.
/atom/movable/proc/untilt(mob/living/user, duration = 10 SECONDS)
	SEND_SIGNAL(src, COMSIG_MOVABLE_TRY_UNTILT, user)


/// useful callback for things that want special behavior on crush
/atom/movable/proc/on_crush_thing(atom/thing)
	return
