/mob/dead/forceMove(atom/destination)
	// Overriden from code/game/atoms_movable.dm#141 to prevent things like mice squeaking when ghosts walk on them.
    var/oldloc = loc
    loc = destination
    Moved(oldloc, NONE, TRUE)
