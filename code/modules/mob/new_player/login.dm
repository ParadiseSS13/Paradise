/mob/new_player/Login()
	update_Login_details()	//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
	if(GLOB.join_motd)
		to_chat(src, "<div class=\"motd\">[GLOB.join_motd]</div>")

	if(!mind)
		mind = new /datum/mind(key)
		mind.active = 1
		mind.current = src

	if(length(GLOB.newplayer_start))
		loc = pick(GLOB.newplayer_start)
	else
		loc = locate(1,1,1)
	lastarea = loc

	client.screen = list() // Remove HUD items just in case.
	client.images = list()
	if(!hud_used)
		create_mob_hud()
	if(hud_used)
		hud_used.show_hud(hud_used.hud_version)

	sight |= SEE_TURFS
	GLOB.player_list |= src

	new_player_panel()

	if(ckey in GLOB.deadmins)
		verbs += /client/proc/readmin
	spawn(40)
		if(client)
			client.playtitlemusic()

	if(config.player_overflow_cap && config.overflow_server_url) //Overflow rerouting, if set, forces players to be moved to a different server once a player cap is reached. Less rough than a pure kick.
		if(src.client.holder)	return //admins are immune to overflow rerouting
		if(config.overflow_whitelist.Find(lowertext(src.ckey)))	return //Whitelisted people are immune to overflow rerouting.
		var/tally = 0
		for(var/client/C in GLOB.clients)
			tally++
		if(tally > config.player_overflow_cap)
			src << link(config.overflow_server_url)
