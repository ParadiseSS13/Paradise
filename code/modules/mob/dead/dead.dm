/mob/dead/forceMove(atom/destination)
	// Overriden from code/game/atoms_movable.dm#141 to prevent things like mice squeaking when ghosts walk on them.
	// Same as parent, except that it does not include Uncrossed or Crossed calls.
	var/turf/old_loc = loc
	loc = destination

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
