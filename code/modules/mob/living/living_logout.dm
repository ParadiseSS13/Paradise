/mob/living/Logout()
	update_z(null)
	if(isobj(loc))
		var/obj/our_location = loc
		if(length(our_location.client_mobs_in_contents))
			our_location.client_mobs_in_contents -= src // if you jackhammer click this as an admeme you can cause runtimes without a length check
	..()
	update_pipe_vision()
	if(mind)
		if(!key) //key and mind have become seperated. I believe this is for when a staff member aghosts.
			mind.active = FALSE	//This is to stop say, a mind.transfer_to call on a corpse causing a ghost to re-enter its body.
		//This causes instant sleep and tags a player as SSD. See life.dm for furthering SSD.
		if(mind.active)
			Sleeping(4 SECONDS)
			player_logged = 1
			last_logout = world.time
