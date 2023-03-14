/mob/dead/observer/Login()
	..()
	if(ghostimage)
		ghostimage.icon_state = src.icon_state
	updateghostimages()

	if(GLOB.non_respawnable_keys[ckey])
		can_reenter_corpse = 0
		remove_from_respawnable_list()
