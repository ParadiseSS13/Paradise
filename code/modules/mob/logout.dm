/mob/Logout()
	nanomanager.user_logout(src) // this is used to clean up (remove) this user's Nano UIs
	player_list -= src
	log_access("Logout: [key_name(src)]")
	if(admin_datums[src.ckey])
		if (ticker && ticker.current_state == GAME_STATE_PLAYING) //Only report this stuff if we are currently playing.
			var/admins_number = admins.len

			message_admins("Admin logout: [key_name(src)]")
			if(admins_number == 0) //Apparently the admin logging out is no longer an admin at this point, so we have to check this towards 0 and not towards 1. Awell.
				send2adminirc("[key_name(src)] logged out - no more admins online.")
	..()
	
	//Update morgues on login/logout
	if (stat == DEAD)
		var/obj/structure/morgue/Morgue = null
		var/mob/living/carbon/human/C = null
		if (istype(src,/mob/dead/observer)) //We're a ghost, let's find our corpse
			var/mob/dead/observer/G = src
			if (G.can_reenter_corpse && G.mind.current)
				C = G.mind.current
		else if (istype(src,/mob/living/carbon/human))
			C = src
		
		if (C) //We found our corpse, is it inside a morgue?
			if (istype(C.loc,/obj/structure/morgue))
				Morgue = C.loc
			else if (istype(C.loc,/obj/structure/closet/body_bag))
				var/obj/structure/closet/body_bag/B = C.loc
				if (istype(B.loc,/obj/structure/morgue))
					Morgue = B.loc
			if (Morgue)
				Morgue.update()

	return 1