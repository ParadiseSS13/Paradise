/mob/dead/observer/Login()
	. = ..()

	if(isliving(mind?.current))
		mind.current.med_hud_set_status()

	if(GLOB.non_respawnable_keys[ckey])
		ghost_flags &= ~GHOST_RESPAWNABLE
		REMOVE_TRAIT(src, TRAIT_RESPAWNABLE, GHOSTED)
	update_admin_actions()
