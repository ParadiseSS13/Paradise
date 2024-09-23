/mob/dead/observer/Logout()
	if(client)
		client.images -= GLOB.ghost_images
	if(mob_observed && ismob(locateUID(mob_observed)))
		cleanup_observe()

	..()
	spawn(0)
		if(src && !key)	//we've transferred to another mob. This ghost should be deleted.
			qdel(src)
		if(isliving(mind?.current))
			mind.current.med_hud_set_status()
