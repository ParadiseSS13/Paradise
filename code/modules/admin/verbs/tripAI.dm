/client/proc/triple_ai()
	set category = "Event"
	set name = "Create AI Triumvirate"

	if(SSticker.current_state > GAME_STATE_PREGAME)
		to_chat(usr, "This option is currently only usable during pregame. This may change at a later date.")
		return

	var/datum/job/job = SSjobs.GetJob("AI")
	if(!job)
		to_chat(usr, "Unable to locate the AI job")
		return
	SSticker.triai = !SSticker.triai
	to_chat(usr, "There will be [SSticker.triai ? "an AI Triumvirate" : "only one AI"] at round start.")
	message_admins("<span class='notice'>[key_name_admin(usr)] has toggled [SSticker.triai ? "on" : "off"] triple AIs at round start.</span>", 1)
	return
