//Deathsquad

/client/proc/deathsquad_spawn()
	set name = "Dispatch Deathsquad"
	set category = "Event"
	set desc = "Send in Special Operations to the clean up the station."

	if(!check_rights(R_EVENT))
		return

	if(!SSticker)
		to_chat(usr, "<span class='warning'>The game hasn't started yet!</span>")
		return

	if(SSticker.current_state == GAME_STATE_PREGAME)
		to_chat(usr, "<span class='warning'>The round hasn't started yet!</span>")
		return

	var/datum/ui_module/ds_manager/E = new()
	E.ui_interact(usr)

	/* if(GLOB.sent_strike_team == 1)
		to_chat(usr, "<span class='userdanger'>CentComm is already sending a team.</span>")
		return */

	if(GLOB.sent_strike_team == 1)
		if(alert("Someone is already sending a deathsquad, are you sure you want to send another?",,"Yes","No")!="Yes") //todo: use this var properly
			alert("coder hasnt coded this yet, yell at them")
		return

