/mob/dead/observer/Logout()
	if(client)
		client.images -= GLOB.ghost_images
	..()
	spawn(0)
		if(src && !key)	//we've transferred to another mob. This ghost should be deleted.
			qdel(src)
		if(mind?.current)
			mind.current.med_hud_set_status()
