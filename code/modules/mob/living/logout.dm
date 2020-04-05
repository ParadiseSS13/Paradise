/mob/living/Logout()
	update_z(null)
	if(ranged_ability && client)
		ranged_ability.remove_mousepointer(client)
	..()
	if(mind)
		if(!key) //key and mind have become seperated. I believe this is for when a staff member aghosts.
			mind.active = 0	//This is to stop say, a mind.transfer_to call on a corpse causing a ghost to re-enter its body.
		//This causes instant sleep and tags a player as SSD. See life.dm for furthering SSD.
		if(mind.active)
			Sleeping(2)
			player_logged = 1
			last_logout = world.time
