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

// Pick darkness list
/mob/dead/observer/pick_darkness()
	set name = "Pick Darkness"
	set desc = "Choose how much darkness you want to see."
	set category = "Ghost"

	if(!client)
		return

	var/darkness_level = tgui_input_list(usr, "Choose your darkness", "Pick Darkness", list("Darkness", "Twilight", "Brightness", "Custom"))
	if(!darkness_level)
		return

	var/new_darkness
	switch(darkness_level)
		if("Darkness")
			new_darkness = 255
		if("Twilight")
			new_darkness = 210
		if("Brightness")
			new_darkness = 0
		if("Custom")
			new_darkness = input(usr, "Введите новое значение (0 - 255). Больше - темнее.", "Pick Darkness") as null|num

	if(isnull(new_darkness))
		return

	client.prefs.ghost_darkness_level = new_darkness
	client.prefs.save_preferences(src)
	lighting_alpha = client.prefs.ghost_darkness_level
	update_sight()

/mob/dead/observer/dead_tele()
	set category = "Ghost"
	set name = "Teleport"
	set desc= "Teleport to a location"

	if(!isobserver(usr))
		to_chat(usr, "Ты ещё не мёртв!")
		return

	var/target = tgui_input_list(usr, "Куда телепортируемся?", "Телепортация", SSmapping.ghostteleportlocs)
	teleport(SSmapping.ghostteleportlocs[target])
