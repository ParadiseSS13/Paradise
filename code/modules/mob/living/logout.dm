/mob/living/Logout()
	..()
	if(mind)
		if(!key) //key and mind have become seperated. I believe this is for when a staff member aghosts.
			mind.active = 0	//This is to stop say, a mind.transfer_to call on a corpse causing a ghost to re-enter its body.
		//This causes instant sleep and tags a player as SSD. See life.dm for furthering SSD.
		if(sleeping < 2 && mind.active)
			sleeping = 2
			player_logged = 1