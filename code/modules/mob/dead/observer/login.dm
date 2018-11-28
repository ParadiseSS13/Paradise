/mob/dead/observer/Login()
	..()
	if(ghostimage)
		ghostimage.icon_state = src.icon_state
	updateghostimages()

	if(GLOB.non_respawnable_keys[ckey])
		can_reenter_corpse = 0
		GLOB.respawnable_list -= src

	var/turf/T = get_turf(src)
	if(isturf(T))
		update_z(T.z)
	
	update_interface()