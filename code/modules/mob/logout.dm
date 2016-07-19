/mob/Logout()
	nanomanager.user_logout(src) // this is used to clean up (remove) this user's Nano UIs
	player_list -= src
	log_access("Logout: [key_name(src)]")
	if(admin_datums[src.ckey])
		if(ticker && ticker.current_state == GAME_STATE_PLAYING) //Only report this stuff if we are currently playing.
			var/admins_number = admins.len

			message_admins("Admin logout: [key_name_admin(src)]")
			if(admins_number == 0) //Apparently the admin logging out is no longer an admin at this point, so we have to check this towards 0 and not towards 1. Awell.
				send2adminirc("[key_name(src)] logged out - no more admins online.")
	..()
	
	callHook("mob_logout", list("client" = client, "mob" = src))	
	
	return 1