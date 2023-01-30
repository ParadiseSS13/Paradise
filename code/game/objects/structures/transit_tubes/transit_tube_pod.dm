/obj/structure/transit_tube_pod
	icon = 'icons/obj/pipes/transit_tube_pod.dmi'
	icon_state = "pod"
	animate_movement = FORWARD_STEPS
	anchored = TRUE
	density = TRUE
	var/moving = FALSE
	var/datum/gas_mixture/air_contents = new()

/obj/structure/transit_tube_pod/New(loc)
	..(loc)

	air_contents.oxygen = MOLES_O2STANDARD * 2
	air_contents.nitrogen = MOLES_N2STANDARD
	air_contents.temperature = T20C

	// Give auto tubes time to align before trying to start moving
	spawn(5)
		follow_tube()

/obj/structure/transit_tube_pod/Destroy()
	for(var/atom/movable/AM in contents)
		AM.forceMove(get_turf(src))
	return ..()

/obj/structure/transit_tube_pod/Process_Spacemove()
	if(moving) //No drifting while moving in the tubes
		return TRUE
	else return ..()

/obj/structure/transit_tube_pod/proc/follow_tube(reverse_launch)
	if(moving)
		return

	moving = TRUE

	spawn()
		var/obj/structure/transit_tube/current_tube = null
		var/next_dir
		var/next_loc
		var/last_delay = 0
		var/exit_delay

		if(reverse_launch)
			dir = turn(dir, 180) // Back it up

		for(var/obj/structure/transit_tube/tube in loc)
			if(tube.has_exit(dir))
				current_tube = tube
				break

		while(current_tube)
			next_dir = current_tube.get_exit(dir)

			if(!next_dir)
				break

			exit_delay = current_tube.exit_delay(src, dir)
			last_delay += exit_delay

			sleep(exit_delay)

			next_loc = get_step(loc, next_dir)

			current_tube = null
			for(var/obj/structure/transit_tube/tube in next_loc)
				if(tube.has_entrance(next_dir))
					current_tube = tube
					break

			if(current_tube == null)
				setDir(next_dir)
				Move(get_step(loc, dir), dir) // Allow collisions when leaving the tubes.
				break

			last_delay = current_tube.enter_delay(src, next_dir)
			sleep(last_delay)
			setDir(next_dir)
			forceMove(next_loc) // When moving from one tube to another, skip collision and such.
			density = current_tube.density

			if(current_tube && current_tube.should_stop_pod(src, next_dir))
				current_tube.pod_stopped(src, dir)
				break

		density = TRUE

		moving = FALSE


// Should I return a copy here? If the caller edits or qdel()s the returned
//  datum, there might be problems if I don't...
/obj/structure/transit_tube_pod/return_air()
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
	icon_state = "pod_occupied"
	A.forceMove(src)

/obj/structure/transit_tube_pod/proc/eject_mindless(direction)
	for(var/atom/movable/A in contents)
		if(ismob(A))
			var/mob/M = A
			if(M.mind) // Only eject mindless mobs
				continue
		eject(A, direction)
		A.Move(get_step(loc, direction), direction)


/obj/structure/transit_tube_pod/proc/eject(atom/movable/A, direction)
	icon_state = "pod"
	A.forceMove(loc)
	A.Move(get_step(loc, direction), direction)
	if(ismob(A))
		var/mob/M = A
		M.reset_perspective(null)
