/atom/movable
	layer = 3
	appearance_flags = TILE_BOUND
	glide_size = 8 // Default, adjusted when mobs move based on their movement delays
	var/last_move = null
	/// A list containing arguments for Moved().
	VAR_PRIVATE/tmp/list/active_movement
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
	var/mob/pulledby = null

	var/atom/movable/pulling
	/// Face towards the atom while pulling it
	var/face_while_pulling = FALSE
	/// Whether this atom should have its dir automatically changed when it
	/// moves. Setting this to FALSE allows for things such as directional windows
	/// to retain dir on moving without snowflake code all of the place.
	/// PARA: Doesn't set this currently to maintain current behavior for pulling items around,
	/// because modifying direction on pull is expected.
	var/set_dir_on_move = TRUE
	var/throwforce = 0

	///Are we moving with inertia? Mostly used as an optimization
	var/inertia_moving = FALSE
	///Delay in deciseconds between inertia based movement
	var/inertia_move_delay = 5
	///The last time we pushed off something
	///This is a hack to get around dumb him him me scenarios
	var/last_pushoff

	var/moving_diagonally = 0 //0: not doing a diagonal move. 1 and 2: doing the first/second step of the diagonal move
	var/list/client_mobs_in_contents

	/// Either FALSE, [EMISSIVE_BLOCK_GENERIC], or [EMISSIVE_BLOCK_UNIQUE]
	var/blocks_emissive = FALSE
	///Internal holder for emissive blocker object, do not use directly use blocks_emissive
	var/atom/movable/emissive_blocker/em_block
	/// Icon state for thought bubbles. Normally set by mobs.
	var/thought_bubble_image = "thought_bubble"

	// Atmos
	var/pressure_resistance = 10
	var/last_high_pressure_movement_time = 0

	/// UID for the atom which the current atom is orbiting
	var/orbiting_uid = null

	/*
	Buckling Vars
	*/
	var/can_buckle = FALSE
	/// Bed-like behaviour, forces the mob to lie down if buckle_lying != -1
	var/buckle_lying = -1
	/// Require people to be handcuffed before being able to buckle. eg: pipes
	var/buckle_requires_restraints = 0
	/// Lazylist of the mobs buckled to this object.
	var/list/buckled_mobs = null
	/// The Pixel_y to offset the buckled mob by
	var/buckle_offset = 0
	/// The max amount of mobs that can be buckled to this object. Currently set to 1 on every movable
	var/max_buckled_mobs = 1
	/// Can we pull the mob while they're buckled. Currently set to false on every movable
	var/buckle_prevents_pull = FALSE

	/// Used for icon smoothing. Won't smooth if it ain't anchored and can be unanchored. Only set to true on windows
	var/can_be_unanchored = FALSE

	///attempt to resume grab after moving instead of before.
	var/atom/movable/moving_from_pull
	///Holds information about any movement loops currently running/waiting to run on the movable. Lazy, will be null if nothing's going on
	var/datum/movement_packet/move_packet
	/// How far (in pixels) should this atom scatter when created/dropped/etc. Does not apply to mapped-in items.
	var/scatter_distance = 0

	/**
	 * an associative lazylist of relevant nested contents by "channel", the list is of the form: list(channel = list(important nested contents of that type))
	 * each channel has a specific purpose and is meant to replace potentially expensive nested contents iteration.
	 * do NOT add channels to this for little reason as it can add considerable memory usage.
	 */
	var/list/important_recursive_contents

	/// String representing the spatial grid groups we want to be held in.
	/// acts as a key to the list of spatial grid contents types we exist in via SSspatial_grid.spatial_grid_categories.
	/// We do it like this to prevent people trying to mutate them and to save memory on holding the lists ourselves
	var/spatial_grid_key

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
	if(opacity)
		AddElement(/datum/element/light_blocking)

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
	if(move_packet)
		if(!QDELETED(move_packet))
			qdel(move_packet)
		move_packet = null

	if(opacity)
		RemoveElement(/datum/element/light_blocking)

	moveToNullspace()

	// This absolutely must be after moveToNullspace()
	// We rely on Entered and Exited to manage this list, and the copy of this list that is on any /atom/movable "Containers"
	// If we clear this before the nullspace move, a ref to this object will be hung in any of its movable containers
	LAZYNULL(important_recursive_contents)

//Returns an atom's power cell, if it has one. Overload for individual items.
/atom/movable/proc/get_cell()
	return

/atom/movable/proc/compressor_grind()
	ex_act(EXPLODE_DEVASTATE)

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

/// Used in shuttle movement and camera eye stuff.
/// Primarily used to notify objects being moved by a shuttle/bluespace fuckup.
/atom/movable/proc/set_loc(T, teleported=0)
	var/old_loc = loc
	loc = T
	Moved(old_loc, get_dir(old_loc, loc), null, null, FALSE)


/**
 * Meant for movement with zero side effects. Only use for objects that are supposed to move "invisibly" (like camera mobs or ghosts).
 * If you want something to move onto a tile with a beartrap or recycler or tripmine or mouse without that object knowing about it at all, use this.
 * Most of the time you want [forceMove()].
 */
/atom/movable/proc/abstract_move(atom/new_loc)
	RESOLVE_ACTIVE_MOVEMENT // This should NEVER happen, but, just in case...
	var/atom/old_loc = loc
	var/direction = get_dir(old_loc, new_loc)
	loc = new_loc
	Moved(old_loc, direction, TRUE)

/// Here's where we rewrite how byond handles movement except slightly different.
/// To be removed on step_ conversion.
/// All this work to prevent a second bump.
/atom/movable/Move(atom/newloc, direction, glide_size_override = 0, update_dir = TRUE, momentum_change = TRUE)
	CAN_BE_REDEFINED(TRUE)
	. = FALSE
	if(!newloc || newloc == loc)
		return

	// A mid-movement... movement... occured, resolve that first.
	RESOLVE_ACTIVE_MOVEMENT

	if(!direction)
		direction = get_dir(src, newloc)

	if(set_dir_on_move && dir != direction && update_dir)
		setDir(direction)

	var/is_multi_tile_object = is_multi_tile_object(src)

	var/list/old_locs
	if(is_multi_tile_object && isturf(loc))
		old_locs = locs // locs is a special list, this is effectively the same as .Copy() but with less steps
		for(var/atom/exiting_loc as anything in old_locs)
			if(!exiting_loc.Exit(src, direction))
				return
	else
		if(!loc.Exit(src, direction))
			return

	var/list/new_locs
	if(is_multi_tile_object && isturf(newloc))
		new_locs = block(
			newloc,
			locate(
				min(world.maxx, newloc.x + CEILING(bound_width / 32, 1)),
				min(world.maxy, newloc.y + CEILING(bound_height / 32, 1)),
				newloc.z
				)
		) // If this is a multi-tile object then we need to predict the new locs and check if they allow our entrance.
		for(var/atom/entering_loc as anything in new_locs)
			if(!entering_loc.Enter(src))
				return
			if(SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_MOVE, entering_loc) & COMPONENT_MOVABLE_BLOCK_PRE_MOVE)
				return
	else // Else just try to enter the single destination.
		if(!newloc.Enter(src))
			return
		if(SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_MOVE, newloc) & COMPONENT_MOVABLE_BLOCK_PRE_MOVE)
			return

	// Past this is the point of no return
	var/atom/oldloc = loc
	var/area/oldarea = get_area(oldloc)
	var/area/newarea = get_area(newloc)

	SET_ACTIVE_MOVEMENT(oldloc, direction, FALSE, old_locs, momentum_change)
	loc = newloc

	. = TRUE

	if(old_locs) // This condition will only be true if it is a multi-tile object.
		for(var/atom/exited_loc as anything in (old_locs - new_locs))
			exited_loc.Exited(src, direction)
	else // Else there's just one loc to be exited.
		oldloc.Exited(src, direction)
	if(oldarea != newarea)
		oldarea.Exited(src, direction)

	if(new_locs) // Same here, only if multi-tile.
		for(var/atom/entered_loc as anything in (new_locs - old_locs))
			entered_loc.Entered(src, oldloc, old_locs)
	else
		newloc.Entered(src, oldloc, old_locs)
	if(oldarea != newarea)
		newarea.Entered(src, oldarea)

	RESOLVE_ACTIVE_MOVEMENT

/atom/movable/Move(atom/newloc, direct = 0, glide_size_override = 0, update_dir = TRUE, momentum_change = TRUE)
	var/atom/movable/pullee = pulling
	var/turf/current_turf = loc
	if(!loc || !newloc)
		return FALSE
	var/atom/oldloc = loc

	if(SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_MOVE, newloc) & COMPONENT_MOVABLE_BLOCK_PRE_MOVE)
		return FALSE

	if(glide_size_override && glide_size != glide_size_override)
		set_glide_size(glide_size_override)

	if(loc != newloc)
		if(!IS_DIR_DIAGONAL(direct)) //Cardinal move
			. = ..(newloc, direct, momentum_change = momentum_change)
		else //Diagonal move, split it into cardinal moves
			moving_diagonally = FIRST_DIAG_STEP
			var/first_step_dir = 0
			// For each diagonal direction, we try moving NORTH/SOUTH first, and if it fails, we try moving EAST/WEST first.
			// As long as either succeeds, we try the other.
			var/direct_NS = direct & (NORTH | SOUTH)
			var/direct_EW = direct & (EAST | WEST)
			var/first_step_target = get_step(src, direct_NS)
			// .() is rarely seen (for good reason), but it calls the same proc we're in.
			// We cant' avoid it here, because oour overloading of Move() makes it call the wrong one.
			. = .(first_step_target, direct_NS, glide_size_override, FALSE, momentum_change)
			if(loc == first_step_target)
				first_step_dir = direct_NS
				moving_diagonally = SECOND_DIAG_STEP
				. = .(newloc, direct_EW, glide_size_override, FALSE, momentum_change)
			else if(loc == oldloc)
				first_step_target = get_step(src, direct_EW)
				. = .(first_step_target, direct_EW, glide_size_override, FALSE, momentum_change)
				if(loc == first_step_target)
					first_step_dir = direct_EW
					moving_diagonally = SECOND_DIAG_STEP
					. = .(newloc, direct_NS, glide_size_override, FALSE, momentum_change)
			if(first_step_dir != 0)
				if(!. && set_dir_on_move && update_dir)
					setDir(first_step_dir)
					Moved(oldloc, first_step_dir, FALSE, null, TRUE)
				else if(!inertia_moving)
					newtonian_move(direct)
				if(client_mobs_in_contents)
					update_parallax_contents()
			moving_diagonally = 0
			return

	if(!loc || (loc == oldloc && oldloc != newloc))
		last_move = 0

		return

	if(. && pulling && pulling == pullee && pulling != moving_from_pull) //we were pulling a thing and didn't lose it during our move.
		if(pulling.anchored)
			stop_pulling()
		else
			//puller and pullee more than one tile away or in diagonal position and whatever the pullee is pulling isn't already moving from a pull as it'll most likely result in an infinite loop a la ouroborus.
			if(!pulling.pulling?.moving_from_pull)
				var/pull_dir = get_dir(pulling, src)
				var/target_turf = current_turf

				if(target_turf != current_turf || (moving_diagonally != SECOND_DIAG_STEP && IS_DIR_DIAGONAL(pull_dir)) || get_dist(src, pulling) > 1)
					pulling.move_from_pull(src, target_turf, glide_size)

			// PARA: There was code here for handling multi-z, which isn't relevant to us.
			check_pulling()

	//glide_size strangely enough can change mid movement animation and update correctly while the animation is playing
	//This means that if you don't override it late like this, it will just be set back by the movement update that's called when you move turfs.
	if(glide_size_override)
		set_glide_size(glide_size_override)

	last_move = direct
	l_move_time = world.time

	if(. && has_buckled_mobs() && !handle_buckled_mob_movement(loc, direct, glide_size_override)) //movement failed due to buckled mob
		. = FALSE

/**
 * Called after a successful Move(). By this point, we've already moved.
 * Arguments:
 * * old_loc is the location prior to the move. Can be null to indicate nullspace.
 * * movement_dir is the direction the movement took place. Can be NONE if it was some sort of teleport.
 * * The forced flag indicates whether this was a forced move, which skips many checks of regular movement.
 * * The old_locs is an optional argument, in case the moved movable was present in multiple locations before the movement.
 * * momentum_change represents whether this movement is due to a "new" force if TRUE or an already "existing" force if FALSE
 **/
/atom/movable/proc/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, old_loc, movement_dir, forced, old_locs, momentum_change)

	if(!inertia_moving && momentum_change)
		newtonian_move(movement_dir)
	if(length(client_mobs_in_contents))
		update_parallax_contents()

	var/turf/old_turf = get_turf(old_loc)
	var/turf/new_turf = get_turf(src)

	if(old_turf?.z != new_turf?.z)
		on_changed_z_level(old_turf, new_turf)

	var/datum/light_source/L
	var/thing
	for(thing in light_sources) // Cycle through the light sources on this atom and tell them to update.
		L = thing
		L.source_atom.update_light()
	return TRUE

/// Called when src is being moved to a target turf because another movable (puller) is moving around.
/atom/movable/proc/move_from_pull(atom/movable/puller, turf/target_turf, puller_glide_size)
	moving_from_pull = puller
	var/new_glide_size = puller_glide_size
	var/pull_dir = get_dir(src, target_turf)
	// Adjust diagonal pulls for LONG_GLIDE differences.
	if(IS_DIR_DIAGONAL(pull_dir))
		if((puller.appearance_flags & LONG_GLIDE) && !(appearance_flags & LONG_GLIDE))
			new_glide_size *= sqrt(2)
		if(!(puller.appearance_flags & LONG_GLIDE) && (appearance_flags & LONG_GLIDE))
			new_glide_size /= sqrt(2)
	set_glide_size(new_glide_size)
	if(isliving(src))
		var/mob/living/M = src
		if(IS_HORIZONTAL(M) && !M.buckled && (prob(M.getBruteLoss() * 200 / M.maxHealth))) // So once you reach 50 brute damage you hit 100% chance to leave a blood trail for every tile you're pulled
			M.makeTrail(target_turf)
	Move(target_turf, pull_dir)
	moving_from_pull = null

// Make sure you know what you're doing if you call this
// You probably want CanPass()
/atom/movable/Cross(atom/movable/crossed_atom)
	if(SEND_SIGNAL(src, COMSIG_MOVABLE_CHECK_CROSS, crossed_atom) & COMPONENT_BLOCK_CROSS)
		return FALSE
	if(SEND_SIGNAL(crossed_atom, COMSIG_MOVABLE_CHECK_CROSS_OVER, src) & COMPONENT_BLOCK_CROSS)
		return FALSE
	return CanPass(crossed_atom, get_dir(src, crossed_atom))

///default byond proc that is deprecated for us in lieu of signals. do not call
/atom/movable/Crossed(atom/movable/crossed_atom, oldloc)
	SHOULD_NOT_OVERRIDE(TRUE)
	CRASH("atom/movable/Crossed() was called!")

/**
 * `Uncross()` is a default BYOND proc that is called when something is *going*
 * to exit this atom's turf. It is prefered over `Uncrossed` when you want to
 * deny that movement, such as in the case of border objects, objects that allow
 * you to walk through them in any direction except the one they block
 * (think side windows).
 *
 * While being seemingly harmless, most everything doesn't actually want to
 * use this, meaning that we are wasting proc calls for every single atom
 * on a turf, every single time something exits it, when basically nothing
 * cares.
 *
 * If you want to replicate the old `Uncross()` behavior, the most apt
 * replacement is [`/datum/element/connect_loc`] while hooking onto
 * [`COMSIG_ATOM_EXIT`].
 */
/atom/movable/Uncross()
	SHOULD_NOT_OVERRIDE(TRUE)
	CRASH("Unexpected atom/movable/Uncross() call")

/**
 * default byond proc that is normally called on everything inside the previous turf
 * a movable was in after moving to its current turf
 * this is wasteful since the vast majority of objects do not use Uncrossed
 * use connect_loc to register to COMSIG_ATOM_EXITED instead
 */
/atom/movable/Uncrossed(atom/movable/uncrossed_atom)
	SHOULD_NOT_OVERRIDE(TRUE)
	CRASH("/atom/movable/Uncrossed() was called")

// Change glide size for the duration of one movement
/atom/movable/proc/glide_for(movetime)
	if(movetime)
		glide_size = world.icon_size/max(DS2TICKS(movetime), 1)
		spawn(movetime)
			glide_size = initial(glide_size)
	else
		glide_size = initial(glide_size)

/atom/movable/Bump(atom/bumped_atom)
	if(!bumped_atom)
		CRASH("Bump was called with no argument.")
	if(SEND_SIGNAL(src, COMSIG_MOVABLE_BUMP, bumped_atom) & COMPONENT_INTERCEPT_BUMPED)
		return
	. = ..()
	if(!QDELETED(throwing))
		throwing.finalize(hit = TRUE, target = bumped_atom)
		. = TRUE
		if(QDELETED(bumped_atom))
			return
	bumped_atom.Bumped(src)

/atom/movable/proc/forceMove(atom/destination)
	. = FALSE
	if(destination)
		. = doMove(destination)
	else
		CRASH("No valid destination passed into forceMove")

/*
 * Move ourself to nullspace. Use to indicate clearly that you
 * know that you are doing so, as opposed to calling forceMove(null),
 * accidentally or otherwise.
 */
/atom/movable/proc/moveToNullspace()
	return doMove(null)

/atom/movable/proc/doMove(atom/destination)
	. = FALSE
	RESOLVE_ACTIVE_MOVEMENT

	var/atom/oldloc = loc
	var/is_multi_tile = bound_width > world.icon_size || bound_height > world.icon_size

	SET_ACTIVE_MOVEMENT(oldloc, NONE, TRUE, null, TRUE)

	if(destination)
		if(pulledby && !HAS_TRAIT(src, TRAIT_CURRENTLY_Z_MOVING))
			pulledby.stop_pulling()

		var/same_loc = oldloc == destination
		var/area/old_area = get_area(oldloc)
		var/area/destarea = get_area(destination)
		var/movement_dir = get_dir(src, destination)

		moving_diagonally = 0

		loc = destination

		if(!same_loc)
			if(is_multi_tile && isturf(destination))
				var/list/new_locs = block(
					destination,
					locate(
						min(world.maxx, destination.x + ROUND_UP(bound_width / 32)),
						min(world.maxy, destination.y + ROUND_UP(bound_height / 32)),
						destination.z
					)
				)
				if(old_area && old_area != destarea)
					old_area.Exited(src, movement_dir)
				for(var/atom/left_loc as anything in locs - new_locs)
					left_loc.Exited(src, movement_dir)

				for(var/atom/entering_loc as anything in new_locs - locs)
					entering_loc.Entered(src, movement_dir)

				if(old_area && old_area != destarea)
					destarea.Entered(src, movement_dir)
			else
				if(oldloc)
					oldloc.Exited(src, movement_dir)
					if(old_area && old_area != destarea)
						old_area.Exited(src, movement_dir)
				destination.Entered(src, oldloc)
				if(destarea && old_area != destarea)
					destarea.Entered(src, old_area)

		. = TRUE

	//If no destination, move the atom into nullspace (don't do this unless you know what you're doing)
	else
		. = TRUE

		if(oldloc)
			loc = null
			var/area/old_area = get_area(oldloc)
			if(is_multi_tile && isturf(oldloc))
				for(var/atom/old_loc as anything in locs)
					old_loc.Exited(src, NONE)
			else
				oldloc.Exited(src, NONE)

			if(old_area)
				old_area.Exited(src, NONE)

	RESOLVE_ACTIVE_MOVEMENT

/**
 * Called when a movable changes z-levels.
 *
 * Arguments:
 * * old_turf - The previous turf they were on before.
 * * new_turf - The turf they have now entered.
 * * notify_contents - Whether or not to notify the movable's contents that their z-level has changed.
 */
/atom/movable/proc/on_changed_z_level(turf/old_turf, turf/new_turf, notify_contents = TRUE)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOVABLE_Z_CHANGED, old_turf, new_turf)

	if(!notify_contents)
		return

	for(var/atom/movable/content as anything in src) // Notify contents of Z-transition.
		content.on_changed_z_level(old_turf, new_turf)

/mob/living/forceMove(atom/destination)
	if(buckled)
		addtimer(CALLBACK(src, PROC_REF(check_buckled)), 1, TIMER_UNIQUE)
	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		addtimer(CALLBACK(buckled_mob, PROC_REF(check_buckled)), 1, TIMER_UNIQUE)
	if(pulling)
		addtimer(CALLBACK(src, PROC_REF(check_pull)), 1, TIMER_UNIQUE)
	. = ..()
	if(client)
		reset_perspective(destination)
		if(hud_used && length(client.parallax_layers))
			hud_used.update_parallax()
	update_runechat_msg_location()


/**
 * Called whenever an object moves and by mobs when they attempt to move themselves through space
 * And when an object or action applies a force on src, see [newtonian_move][/atom/movable/proc/newtonian_move]
 *
 * Return FALSE to have src start/keep drifting in a no-grav area and TRUE to stop/not start drifting
 *
 * Mobs should return TRUE if they should be able to move of their own volition, see [/client/proc/Move]
 *
 * Arguments:
 * * movement_dir - 0 when stopping or any dir when trying to move
 * * continuous_move - If this check is coming from something in the context of already drifting
 */
/atom/movable/proc/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	if(has_gravity(src))
		return TRUE

	if(SEND_SIGNAL(src, COMSIG_MOVABLE_SPACEMOVE, movement_dir, continuous_move) & COMSIG_MOVABLE_STOP_SPACEMOVE)
		return TRUE

	if(pulledby && pulledby.pulledby != src)
		return TRUE

	if(throwing)
		return TRUE

	if(locate(/obj/structure/lattice) in range(1, get_turf(src))) //Not realistic but makes pushing things in space easier
		return TRUE

	return FALSE

/atom/movable/proc/newtonian_move(direction, instant = FALSE, start_delay = 0)
	if(!isturf(loc) || Process_Spacemove(direction, continuous_move = TRUE))
		return FALSE

	if(SEND_SIGNAL(src, COMSIG_MOVABLE_NEWTONIAN_MOVE, direction, start_delay) & COMPONENT_MOVABLE_NEWTONIAN_BLOCK)
		return TRUE

	AddComponent(/datum/component/drift, direction, instant, start_delay)

	return TRUE

/mob/newtonian_move(direction, instant = FALSE, start_delay = 0)
	if(buckled)
		return FALSE
	return ..()

//called when src is thrown into hit_atom
/atom/movable/proc/throw_impact(atom/hit_atom, throwingdatum)
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_MOVABLE_IMPACT, hit_atom, throwingdatum)
	if(!QDELETED(hit_atom))
		return hit_atom.hitby(src, throwingdatum=throwingdatum)

/// called after an items throw is ended.
/atom/movable/proc/end_throw()
	return

/atom/movable/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked, datum/thrownthing/throwingdatum)
	if(!anchored && hitpush && (!throwingdatum || (throwingdatum.force >= (move_resist * MOVE_FORCE_PUSH_RATIO))))
		step(src, AM.dir)
	..()

/atom/movable/proc/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = INFINITY, dodgeable = TRUE, block_movement = TRUE)
	if(QDELETED(src))
		CRASH("Qdeleted thing being thrown around.")

	if(!target || (flags & NODROP) || speed <= 0)
		return FALSE

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

	var/target_zone
	if(QDELETED(thrower))
		thrower = null //Let's not pass a qdeleting reference if any.
	else
		target_zone = thrower.zone_selected

	var/datum/thrownthing/thrown_thing = new(src, target, get_dir(src, target), range, speed, thrower, diagonals_first, force, callback, dodgeable, block_movement, target_zone)

	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)
	var/dx = (target.x > src.x) ? EAST : WEST
	var/dy = (target.y > src.y) ? NORTH : SOUTH

	if(dist_x == dist_y)
		thrown_thing.pure_diagonal = 1

	else if(dist_x <= dist_y)
		var/olddist_x = dist_x
		var/olddx = dx
		dist_x = dist_y
		dist_y = olddist_x
		dx = dy
		dy = olddx
	thrown_thing.dist_x = dist_x
	thrown_thing.dist_y = dist_y
	thrown_thing.dx = dx
	thrown_thing.dy = dy
	thrown_thing.diagonal_error = dist_x / 2 - dist_y
	thrown_thing.start_time = world.time

	if(pulledby)
		pulledby.stop_pulling()

	throwing = thrown_thing
	if(spin && !no_spin && !no_spin_thrown)
		SpinAnimation(5, 1)

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_THROW, thrown_thing, spin)
	SSthrowing.processing[src] = thrown_thing
	thrown_thing.tick()

	return TRUE

/// This proc is recursive, and calls itself to constantly set the glide size of an atom/movable
/atom/movable/proc/set_glide_size(target = 8)
	if(glide_size == target)
		return

	var/old_value = glide_size
	glide_size = target
	SEND_SIGNAL(src, COMSIG_MOVABLE_UPDATED_GLIDE_SIZE, old_value)

	for(var/mob/buckled_mob as anything in buckled_mobs)
		buckled_mob.set_glide_size(target)

//Overlays
/atom/movable/overlay
	var/atom/master = null
	anchored = TRUE
	simulated = FALSE

/atom/movable/overlay/New()
	. = ..()
	verbs.Cut()
	return

/atom/movable/overlay/attackby__legacy__attackchain(a, b, c)
	if(master)
		return master.attackby__legacy__attackchain(a, b, c)

/atom/movable/overlay/attack_hand(a, b, c)
	if(master)
		return master.attack_hand(a, b, c)

/atom/movable/proc/handle_buckled_mob_movement(newloc, direct, glide_size_override)
	for(var/m in buckled_mobs)
		var/mob/living/buckled_mob = m
		if(!buckled_mob.Move(newloc, direct, glide_size_override))
			forceMove(buckled_mob.loc)
			last_move = buckled_mob.last_move
			return FALSE
	return TRUE

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

/atom/movable/CanPass(atom/movable/mover, border_dir)
	// This condition is copied from atom to avoid an extra parent call, because this is a very hot proc.
	if(!density)
		return TRUE
	return LAZYIN(buckled_mobs, mover)

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
	SEND_SIGNAL(src, COMSIG_MOVABLE_SHOVE_IMPACT, target, attacker)
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
	DeleteComponent(/datum/component/deadchat_control)

//Update the screentip to reflect what we're hovering over
/atom/movable/MouseEntered(location, control, params)
	if(invisibility > usr.see_invisible)
		return
	var/datum/hud/active_hud = usr.hud_used // Don't nullcheck this stuff, if it breaks we wanna know it breaks
	var/screentip_mode = usr.client.prefs.screentip_mode
	if(screentip_mode == 0 || (flags & NO_SCREENTIPS))
		active_hud.screentip_text.maptext = ""
		return
	//We inline a MAPTEXT() here, because there's no good way to statically add to a string like this
	active_hud.screentip_text.maptext = "<span class='maptext' style='font-family: sans-serif; text-align: center; font-size: [screentip_mode]px; color: [usr.client.prefs.screentip_color]'>[name]</span>"
	usr.client.moused_over = UID()

/atom/movable/MouseExited(location, control, params)
	usr.hud_used.screentip_text.maptext = ""
	usr.client.moused_over = null

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

	if(target_turf.is_blocked_turf(exclude_mobs = TRUE, ignore_atoms = list(src)))
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

			if(L.incorporeal_move)
				continue

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
		AddComponent(/datum/component/tilted, 4 SECONDS, block_interactions_until_righted, rot_angle)

/// Untilt a tilted object.
/atom/movable/proc/untilt(mob/living/user, duration = 10 SECONDS)
	SEND_SIGNAL(src, COMSIG_MOVABLE_TRY_UNTILT, user)


/// useful callback for things that want special behavior on crush
/atom/movable/proc/on_crush_thing(atom/thing)
	return

/// Used to scatter atoms so that multiple copies aren't all at the exact same spot.
/atom/movable/proc/scatter_atom(x_offset = 0, y_offset = 0)
	pixel_x = x_offset + rand(-scatter_distance, scatter_distance)
	pixel_y = y_offset + rand(-scatter_distance, scatter_distance)

/**
 * A backwards depth-limited breadth-first-search to see if the target is
 * logically "in" anything adjacent to us.
 *
 * Arguments:
 * * ultimate_target - the specific item we're attempting to reach.
 * * tool - if present, checked to see if the tool can reach the target via [/obj/item/var/reach].
 * * view_only - if TRUE, only considers locations in atoms visible to us, as opposed to nested inventories.
 */
/atom/movable/proc/can_reach_nested_adjacent(atom/ultimate_target, obj/item/tool, view_only = FALSE)
	var/list/direct_access = direct_access()
	var/depth = 1 + (view_only ? STORAGE_VIEW_DEPTH : INVENTORY_DEPTH)

	var/list/closed = list()
	var/list/checking = list(ultimate_target)

	while(length(checking) && depth > 0)
		var/list/next = list()
		--depth

		for(var/atom/target in checking)  // will filter out nulls
			if(closed[target] || isarea(target))  // avoid infinity situations
				continue

			if(isturf(target) || isturf(target.loc) || (target in direct_access)) //Directly accessible atoms
				if(Adjacent(target) || (tool && check_tool_reach(src, target, tool.reach))) //Adjacent or reaching attacks
					return TRUE

			closed[target] = TRUE

			if(!target.loc)
				continue

		checking = next
	return FALSE

/atom/movable/Exited(atom/movable/gone, direction)
	. = ..()

	if(!LAZYLEN(gone.important_recursive_contents))
		return
	var/list/nested_locs = get_nested_locs(src) + src
	for(var/channel in gone.important_recursive_contents)
		for(var/atom/movable/location as anything in nested_locs)
			LAZYINITLIST(location.important_recursive_contents)
			var/list/recursive_contents = location.important_recursive_contents // blue hedgehog velocity
			LAZYINITLIST(recursive_contents[channel])
			recursive_contents[channel] -= gone.important_recursive_contents[channel]
			switch(channel)
				if(RECURSIVE_CONTENTS_CLIENT_MOBS, RECURSIVE_CONTENTS_HEARING_SENSITIVE)
					if(!length(recursive_contents[channel]))
						// This relies on a nice property of the linked recursive and gridmap types
						// They're defined in relation to each other, so they have the same value
						SSspatial_grid.remove_grid_awareness(location, channel)
			ASSOC_UNSETEMPTY(recursive_contents, channel)
			UNSETEMPTY(location.important_recursive_contents)

/atom/movable/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()

	if(!LAZYLEN(arrived.important_recursive_contents))
		return
	var/list/nested_locs = get_nested_locs(src) + src
	for(var/channel in arrived.important_recursive_contents)
		for(var/atom/movable/location as anything in nested_locs)
			LAZYINITLIST(location.important_recursive_contents)
			var/list/recursive_contents = location.important_recursive_contents // blue hedgehog velocity
			LAZYINITLIST(recursive_contents[channel])
			switch(channel)
				if(RECURSIVE_CONTENTS_CLIENT_MOBS, RECURSIVE_CONTENTS_HEARING_SENSITIVE)
					if(!length(recursive_contents[channel]))
						SSspatial_grid.add_grid_awareness(location, channel)
			recursive_contents[channel] |= arrived.important_recursive_contents[channel]

///allows this movable to hear and adds itself to the important_recursive_contents list of itself and every movable loc its in
/atom/movable/proc/become_hearing_sensitive(trait_source = TRAIT_GENERIC)
	var/already_hearing_sensitive = HAS_TRAIT(src, TRAIT_HEARING_SENSITIVE)
	ADD_TRAIT(src, TRAIT_HEARING_SENSITIVE, trait_source)
	if(already_hearing_sensitive) // If we were already hearing sensitive, we don't wanna be in important_recursive_contents twice, else we'll have potential issues like one radio sending the same message multiple times
		return

	for(var/atom/movable/location as anything in get_nested_locs(src) + src)
		LAZYINITLIST(location.important_recursive_contents)
		var/list/recursive_contents = location.important_recursive_contents // blue hedgehog velocity
		if(!length(recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE]))
			SSspatial_grid.add_grid_awareness(location, SPATIAL_GRID_CONTENTS_TYPE_HEARING)
		recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE] += list(src)

	var/turf/our_turf = get_turf(src)
	SSspatial_grid.add_grid_membership(src, our_turf, SPATIAL_GRID_CONTENTS_TYPE_HEARING)

/**
 * removes the hearing sensitivity channel from the important_recursive_contents list of this and all nested locs containing us if there are no more sources of the trait left
 * since RECURSIVE_CONTENTS_HEARING_SENSITIVE is also a spatial grid content type, removes us from the spatial grid if the trait is removed
 *
 * * trait_source - trait source define or ALL, if ALL, force removes hearing sensitivity. if a trait source define, removes hearing sensitivity only if the trait is removed
 */
/atom/movable/proc/lose_hearing_sensitivity(trait_source = TRAIT_GENERIC)
	if(!HAS_TRAIT(src, TRAIT_HEARING_SENSITIVE))
		return
	REMOVE_TRAIT(src, TRAIT_HEARING_SENSITIVE, trait_source)
	if(HAS_TRAIT(src, TRAIT_HEARING_SENSITIVE))
		return

	var/turf/our_turf = get_turf(src)
	/// We get our awareness updated by the important recursive contents stuff, here we remove our membership
	SSspatial_grid.remove_grid_membership(src, our_turf, SPATIAL_GRID_CONTENTS_TYPE_HEARING)

	for(var/atom/movable/location as anything in get_nested_locs(src) + src)
		var/list/recursive_contents = location.important_recursive_contents // blue hedgehog velocity
		recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE] -= src
		if(!length(recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE]))
			SSspatial_grid.remove_grid_awareness(location, SPATIAL_GRID_CONTENTS_TYPE_HEARING)
		ASSOC_UNSETEMPTY(recursive_contents, RECURSIVE_CONTENTS_HEARING_SENSITIVE)
		UNSETEMPTY(location.important_recursive_contents)

///allows this movable to know when it has "entered" another area no matter how many movable atoms its stuffed into, uses important_recursive_contents
/atom/movable/proc/become_area_sensitive(trait_source = TRAIT_GENERIC)
	if(!HAS_TRAIT(src, TRAIT_AREA_SENSITIVE))
		for(var/atom/movable/location as anything in get_nested_locs(src) + src)
			LAZYADDASSOCLIST(location.important_recursive_contents, RECURSIVE_CONTENTS_AREA_SENSITIVE, src)
	ADD_TRAIT(src, TRAIT_AREA_SENSITIVE, trait_source)

///removes the area sensitive channel from the important_recursive_contents list of this and all nested locs containing us if there are no more source of the trait left
/atom/movable/proc/lose_area_sensitivity(trait_source = TRAIT_GENERIC)
	if(!HAS_TRAIT(src, TRAIT_AREA_SENSITIVE))
		return
	REMOVE_TRAIT(src, TRAIT_AREA_SENSITIVE, trait_source)
	if(HAS_TRAIT(src, TRAIT_AREA_SENSITIVE))
		return

	for(var/atom/movable/location as anything in get_nested_locs(src) + src)
		LAZYREMOVEASSOC(location.important_recursive_contents, RECURSIVE_CONTENTS_AREA_SENSITIVE, src)
