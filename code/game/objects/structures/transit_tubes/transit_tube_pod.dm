#define MOVE_ANIMATION_STAGE_ONE 1
#define MOVE_ANIMATION_STAGE_TWO 2

/obj/structure/transit_tube_pod
	icon = 'icons/obj/pipes/transit_tube_pod.dmi'
	icon_state = "pod"
	animate_movement = FORWARD_STEPS
	anchored = TRUE
	density = TRUE
	var/moving = FALSE
	var/datum/gas_mixture/air_contents = new()
	/// The tube we're currently traveling through
	var/obj/structure/transit_tube/current_tube = null
	/// The direction of our next transit from pipe to pipe. Stored between process calls here.
	var/next_dir
	/// The location of our next target tube. Stored same as above
	var/next_loc
	/// How long to wait when entering a new tube
	var/enter_delay = 0
	/// How long to wait when exiting a new tube
	var/exit_delay
	/// The next time we'll be moving
	COOLDOWN_DECLARE(move_cooldown)
	/// The move animation mode for the next processing tick
	var/current_move_anim_mode = MOVE_ANIMATION_STAGE_ONE
	/// Icon state in use while we're occupied
	var/occupied_icon_state = "pod_occupied"

/obj/structure/transit_tube_pod/Initialize(mapload)
	. = ..()

	air_contents.oxygen = MOLES_O2STANDARD * 2
	air_contents.nitrogen = MOLES_N2STANDARD
	air_contents.temperature = T20C

	// Give auto tubes time to align before trying to start moving
	spawn(5)
		follow_tube()

/obj/structure/transit_tube_pod/update_icon_state()
	. = ..()
	icon_state = length(contents) ? occupied_icon_state : initial(icon_state)

/obj/structure/transit_tube_pod/proc/stop_following()
	STOP_PROCESSING(SStransit_tube, src)

/obj/structure/transit_tube_pod/Destroy()
	empty_pod()
	stop_following()
	return ..()

/obj/structure/transit_tube_pod/Process_Spacemove()
	if(moving) //No drifting while moving in the tubes
		return TRUE
	else return ..()

/obj/structure/transit_tube_pod/proc/empty_pod(atom/location)
	if(!location)
		location = get_turf(src)
	for(var/atom/movable/M in contents)
		M.forceMove(location)
	update_appearance()

/obj/structure/transit_tube_pod/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(moving)
		return

	if(length(contents))
		I.play_tool_sound(src)
		user.visible_message("<span class='notice'>[user] pries [src] open.</span>")
		empty_pod()

/obj/structure/transit_tube_pod/process()
	..()

	if(!COOLDOWN_FINISHED(src, move_cooldown))
		return

	var/move_result = move_animation(current_move_anim_mode)
	if(isnull(move_result))
		if(isnull(current_tube) || (!(dir in current_tube.directions()) && !(reverse_direction(dir) in current_tube.directions())))
			outside_tube()
		return PROCESS_KILL

	current_move_anim_mode = move_result

/obj/structure/transit_tube_pod/proc/outside_tube()
	var/list/savedcontents = contents.Copy()
	var/saveddir = dir
	var/turf/destination = get_edge_target_turf(src, saveddir)
	visible_message("<span class='warning'>[src] ejects its insides out!</span>")
	deconstruct(FALSE)//we automatically deconstruct the pod
	for(var/i in savedcontents)
		var/atom/movable/AM = i
		AM.throw_at(destination, rand(1, 3), 5)


/obj/structure/transit_tube_pod/proc/move_animation(stage = MOVE_ANIMATION_STAGE_ONE)
	if(stage == MOVE_ANIMATION_STAGE_ONE)
		next_dir = current_tube.get_exit(dir)

		if(!next_dir)
			moving = FALSE
			density = TRUE
			return
		exit_delay = current_tube.exit_delay
		next_loc = get_step(src, next_dir)
		current_tube = null
		for(var/obj/structure/transit_tube/tube in next_loc)
			if(tube.has_entrance(next_dir))
				current_tube = tube
				break

		if(isnull(current_tube))
			setDir(next_dir)
			Move(get_step(loc, dir), dir) // Allow collisions when leaving the tubes.
			moving = FALSE
			density = TRUE
			return

		enter_delay = current_tube.enter_delay(src, next_dir)
		if(enter_delay > 0)
			COOLDOWN_START(src, move_cooldown, enter_delay)
			return MOVE_ANIMATION_STAGE_TWO

		stage = MOVE_ANIMATION_STAGE_TWO

	if(stage == MOVE_ANIMATION_STAGE_TWO)
		setDir(next_dir)
		forceMove(next_loc) // When moving from one tube to another, skip collision and such.
		density = current_tube.density

		if(current_tube?.should_stop_pod(src, next_dir))
			current_tube.pod_stopped(src, dir)
		else
			COOLDOWN_START(src, move_cooldown, exit_delay)
			return MOVE_ANIMATION_STAGE_ONE

	density = TRUE
	moving = FALSE

	return MOVE_ANIMATION_STAGE_ONE


/obj/structure/transit_tube_pod/proc/follow_tube(reverse_launch)
	if(moving)
		return

	moving = TRUE

	for(var/obj/structure/transit_tube/tube in loc)
		if(tube.has_exit(dir))
			current_tube = tube
			break

	if(!isnull(current_tube))
		START_PROCESSING(SStransit_tube, src)
		// move_animation(MOVE_ANIMATION_STAGE_ONE)
	else
		moving = FALSE

// Should I return a copy here? If the caller edits or qdel()s the returned
//  datum, there might be problems if I don't...
/obj/structure/transit_tube_pod/return_air()
	RETURN_TYPE(/datum/gas_mixture)
	var/datum/gas_mixture/GM = new()
	GM.copy_from(air_contents)
	return GM

// For now, copying what I found in an unused FEA file (and almost identical in a
//  used ZAS file). Means that assume_air and remove_air don't actually alter the
//  air contents.
/obj/structure/transit_tube_pod/assume_air(datum/gas_mixture/giver)
	return air_contents.merge(giver)

/obj/structure/transit_tube_pod/remove_air(amount)
	return air_contents.remove(amount)



// Called when a pod arrives at, and before a pod departs from a station,
//  giving it a chance to mix its internal air supply with the turf it is
//  currently on.
/obj/structure/transit_tube_pod/proc/mix_air()
	var/datum/gas_mixture/environment = loc.return_air()
	var/env_pressure = environment.return_pressure()
	var/int_pressure = air_contents.return_pressure()
	var/total_pressure = env_pressure + int_pressure

	if(total_pressure == 0)
		return

	// Math here: Completely made up, not based on realistic equasions.
	//  Goal is to balance towards equal pressure, but ensure some gas
	//  transfer in both directions regardless.
	// Feel free to rip this out and replace it with something better,
	//  I don't really know muhch about how gas transfer rates work in
	//  SS13.
	var/transfer_in = max(0.1, 0.5 * (env_pressure - int_pressure) / total_pressure)
	var/transfer_out = max(0.1, 0.3 * (int_pressure - env_pressure) / total_pressure)

	var/datum/gas_mixture/from_env = loc.remove_air(environment.total_moles() * transfer_in)
	var/datum/gas_mixture/from_int = air_contents.remove(air_contents.total_moles() * transfer_out)

	loc.assume_air(from_int)
	air_contents.merge(from_env)



// When the player moves, check if the pos is currently stopped at a station.
//  if it is, check the direction. If the direction matches the direction of
//  the station, try to exit. If the direction matches one of the station's
//  tube directions, launch the pod in that direction.
/obj/structure/transit_tube_pod/relaymove(mob/mob, direction)
	if(istype(mob) && mob.client)
		// If the pod is not in a tube at all, you can get out at any time.
		if(!(locate(/obj/structure/transit_tube) in loc))
			eject(mob, direction)
			return

			//if(moving && istype(loc, /turf/space))
				// Todo: If you get out of a moving pod in space, you should move as well.
				//  Same direction as pod? Direcion you moved? Halfway between?

		if(!moving)
			for(var/obj/structure/transit_tube/station/station in loc)
				if(dir in station.directions())
					if(!station.pod_moving)
						if(direction == station.dir)
							if(station.hatch_state == TRANSIT_TUBE_OPEN)
								eject(mob, direction)

							else
								station.open_hatch()

						else if(direction in station.directions())
							setDir(direction)
							station.launch_pod()
					return

			for(var/obj/structure/transit_tube/tube in loc)
				if(dir in tube.directions())
					if(tube.has_exit(direction))
						setDir(direction)
						return

/obj/structure/transit_tube_pod/proc/move_into(atom/movable/A)
	A.forceMove(src)
	update_appearance()

/obj/structure/transit_tube_pod/proc/eject_mindless(direction)
	for(var/atom/movable/A in contents)
		if(ismob(A))
			var/mob/M = A
			if(M.mind) // Only eject mindless mobs
				continue
		eject(A, direction)
		A.Move(get_step(loc, direction), direction)


/obj/structure/transit_tube_pod/proc/eject(atom/movable/A, direction)
	A.forceMove(loc)
	update_appearance()
	A.Move(get_step(loc, direction), direction)
	if(ismob(A))
		var/mob/M = A
		M.reset_perspective(null)


/obj/structure/transit_tube_pod/dispensed
	name = "temporary transit tube pod"
	desc = "Gets you from here to there, and no further."
	icon_state = "temppod"
	occupied_icon_state = "temppod_occupied"


/obj/structure/transit_tube_pod/dispensed/outside_tube()
	if(!QDELETED(src))
		qdel(src)

#undef MOVE_ANIMATION_STAGE_TWO
#undef MOVE_ANIMATION_STAGE_ONE
