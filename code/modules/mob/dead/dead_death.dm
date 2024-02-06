/mob/dead/dust()	//ghosts can't be vaporised.
	return

/mob/dead/gib()		//ghosts can't be gibbed.
	return

/mob/dead
	move_resist = INFINITY
	flags_2 = IMMUNE_TO_SHUTTLECRUSH_2
