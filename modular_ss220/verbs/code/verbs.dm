/*
	Respawn to OOC
	May be returned in the future by offs (because it's commented in code\modules\mob)
*/
/mob/verb/abandon_mob()
	set name = "Respawn"
	set category = "OOC"

	if(!GLOB.configuration.general.respawn_enabled)
		to_chat(usr, "<span class='warning'>Respawning is disabled.</span>")
		return

	if(stat != DEAD || !SSticker)
		to_chat(usr, "<span class='boldnotice'>You must be dead to use this!</span>")
		return

	log_game("[key_name(usr)] has respawned.")

	to_chat(usr, "<span class='boldnotice'>Make sure to play a different character, and please roleplay correctly!</span>")

	if(!client)
		log_game("[key_name(usr)] respawn failed due to disconnect.")
		return
	client.screen.Cut()
	client.screen += client.void

	if(!client)
		log_game("[key_name(usr)] respawn failed due to disconnect.")
		return

	var/mob/new_player/M = new /mob/new_player()
	if(!client)
		log_game("[key_name(usr)] respawn failed due to disconnect.")
		qdel(M)
		return

	M.key = key
	return
