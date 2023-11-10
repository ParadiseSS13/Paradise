/mob/new_player/Login()
	update_Login_details()	//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
	if(GLOB.join_motd)
		to_chat(src, "<div class=\"motd\">[GLOB.join_motd]</div>")

	if(!mind)
		mind = new /datum/mind(key)
		mind.active = TRUE
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

	if((ckey in GLOB.de_admins) || (ckey in GLOB.de_mentors))
		client.verbs += /client/proc/readmin

	client.playtitlemusic()
	client.update_active_keybindings()

	//Overflow rerouting, if set, forces players to be moved to a different server once a player cap is reached. Less rough than a pure kick.
	if(GLOB.configuration.overflow.reroute_cap && GLOB.configuration.overflow.overflow_server_location)
		if(client.holder)
			return //admins are immune to overflow rerouting
		if(ckey in GLOB.configuration.overflow.overflow_whitelist)
			return //Whitelisted people are immune to overflow rerouting.
		if(length(GLOB.clients) > GLOB.configuration.overflow.reroute_cap)
			src << link(GLOB.configuration.overflow.overflow_server_location)
