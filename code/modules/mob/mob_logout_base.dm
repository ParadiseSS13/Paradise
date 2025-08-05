/mob/Logout()
	SEND_SIGNAL(src, COMSIG_MOB_LOGOUT)
	set_typing_indicator(FALSE)
	SStgui.on_logout(src) // Cleanup any TGUIs the user has open
	unset_machine()
	GLOB.player_list -= src
	log_access_out(src)
	create_attack_log("<font color='red'>Logged out at [atom_loc_line(get_turf(src))]</font>")
	create_log(MISC_LOG, "Logged out")
	// `holder` is nil'd out by now, so we check the `admin_datums` array directly
	// Only report this stuff if we are currently playing.
	if(GLOB.admin_datums[ckey] && SSticker.current_state == GAME_STATE_PLAYING)
		var/datum/admins/temp_admin = GLOB.admin_datums[ckey]
		if(temp_admin.rights & R_BAN)
			message_admins("Admin logout: [key_name_admin(src)]")
			var/list/admincounter = staff_countup(R_BAN)
			if(admincounter[1] == 0) // No active admins
				GLOB.discord_manager.send2discord_simple(DISCORD_WEBHOOK_ADMIN, "[key_name(src)] logged out - 0 active admins, [admincounter[2]] non-admin staff, [admincounter[3]] inactive staff.")
		else if(temp_admin.rights & R_MENTOR)
			var/list/mentorcounter = staff_countup(R_MENTOR)
			if(mentorcounter[1] == 0) // No active mentors
				GLOB.discord_manager.send2discord_simple(DISCORD_WEBHOOK_MENTOR, "[key_name(src)] logged out - 0 active mentors, [mentorcounter[2]] non-mentor staff, [mentorcounter[3]] inactive mentors.")

	..()
	update_morgue()
	return 1
