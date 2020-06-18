/mob/Logout()
	SSnanoui.user_logout(src) // this is used to clean up (remove) this user's Nano UIs
	unset_machine()
	GLOB.player_list -= src
	log_access_out(src)
	create_attack_log("<font color='red'>Logged out at [atom_loc_line(get_turf(src))]</font>")
	create_log(MISC_LOG, "Logged out")
	// `holder` is nil'd out by now, so we check the `admin_datums` array directly
	//Only report this stuff if we are currently playing.
	if(GLOB.admin_datums[ckey] && SSticker && SSticker.current_state == GAME_STATE_PLAYING)
		var/datum/admins/temp_admin = GLOB.admin_datums[ckey]
		// Triggers on people with banhammer power only - no mentors tripping the alarm
		if(temp_admin.rights & R_BAN)
			message_admins("Admin logout: [key_name_admin(src)]")
			var/list/admincounter = staff_countup(R_BAN)
			if(admincounter[1] == 0) // No active admins
				send2irc(config.admin_notify_irc, "[key_name(src)] logged out - No active admins, [admincounter[2]] non-admin staff, [admincounter[3]] inactive staff.")

	..()
	update_morgue()
	return 1
