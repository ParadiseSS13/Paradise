/mob/dead/observer/Login()
	..()
	if(ghostimage)
		ghostimage.icon_state = src.icon_state
	updateghostimages()

	if(non_respawnable_keys[ckey])
		can_reenter_corpse = 0
		respawnable_list -= src
	
	update_interface()