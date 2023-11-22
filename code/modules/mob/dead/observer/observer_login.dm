/mob/dead/observer/Login()
	..()
	if(ghostimage)
		ghostimage.icon_state = src.icon_state
	updateghostimages()

	if(isliving(mind?.current))
		mind.current.med_hud_set_status()

	if(GLOB.non_respawnable_keys[ckey])
		can_reenter_corpse = 0
		REMOVE_TRAIT(src, TRAIT_RESPAWNABLE, GHOSTED)
