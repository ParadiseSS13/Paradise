/mob/new_player/Logout()
	ready = FALSE
	..()
	if(!spawning)//Here so that if they are spawning and log out, the other procs can play out and they will have a mob to come back to.
		mind.current = null // We best null their mind as well, otherwise /every/ single new player is going to explode the server a little more by logging out
		key = null//We null their key before deleting the mob, so they are properly kicked out.
		qdel(src)
	return
