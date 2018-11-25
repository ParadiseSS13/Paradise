/mob/dead/forceMove(atom/destination)
	// Overriden from code/game/atoms_movable.dm#141 to prevent things like mice squeaking when ghosts walk on them.
	// Same as parent, except that it does not include Uncrossed or Crossed calls.
	var/turf/old_loc = loc
	loc = destination

	var/turf/old_turf = get_turf(src)
	var/turf/new_turf = get_turf(destination)
	if(old_turf?.z != new_turf?.z)
		onTransitZ(old_turf?.z, new_turf?.z)

	if(old_loc)
		old_loc.Exited(src, destination)

	if(destination)
		destination.Entered(src)

		if(isturf(destination) && opacity)
			var/turf/new_loc = destination
			new_loc.reconsider_lights()

	if(isturf(old_loc) && opacity)
		old_loc.reconsider_lights()

	for(var/datum/light_source/L in light_sources)
		L.source_atom.update_light()

	return 1

/mob/dead/proc/update_z(new_z) // 1+ to register, null to unregister
	if(registered_z != new_z)
		if(registered_z)
			SSmobs.dead_players_by_zlevel[registered_z] -= src
		if(client)
			if(new_z)
				SSmobs.dead_players_by_zlevel[new_z] += src
			registered_z = new_z
		else
			registered_z = null

/mob/dead/Login()
	. = ..()
	var/turf/T = get_turf(src)
	if(isturf(T))
		update_z(T.z)

/mob/dead/Logout()
	update_z(null)
	return ..()

/mob/dead/onTransitZ(old_z,new_z)
	..()
	update_z(new_z)