/mob/dead/forceMove(atom/destination)
	// Overriden from code/game/atoms_movable.dm#141 to prevent things like mice squeaking when ghosts walk on them.
	// Same as parent, except that it does not include Uncrossed or Crossed calls.
	var/turf/old_loc = loc
	loc = destination

	if(old_loc)
		old_loc.Exited(src, destination)

	if(destination)
		destination.Entered(src)

	return 1
