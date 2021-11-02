/mob/new_player/Login()
	update_Login_details()	//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying

	//Overflow rerouting, if set, forces players to be moved to a different server once a player cap is reached. Less rough than a pure kick.
	if(config.player_overflow_cap && config.overflow_server_url)
		if(!whitelist_check())
			if(config.player_overflow_cap == 1 || length(GLOB.clients) > config.player_overflow_cap)
				src << browse(null, "window=privacy_consent")
				src << link(config.overflow_server_url)

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

/mob/new_player/proc/whitelist_check()
	// Admins are immune to overflow rerouting
	if(check_rights(rights_required = 0, show_msg = 0))
		return TRUE

	if(config.usewhitelist_nojobbanned && GLOB.jobban_assoclist[src.ckey])
		return FALSE

	//Whitelisted people are immune to overflow rerouting.
	if(config.usewhitelist_database && SSdbcore.IsConnected())
		var/datum/db_query/find_ticket = SSdbcore.NewQuery(
			"SELECT ckey FROM [sqlfdbkdbutil].[format_table_name("ckey_whitelist")] WHERE ckey=:ckey AND is_valid=true AND port=:port AND date_start<=NOW() AND (NOW()<date_end OR date_end IS NULL)",
			list("ckey" = src.ckey, "port" = "[world.port]")
		)
		if(!find_ticket.warn_execute(async = FALSE))
			QDEL_NULL(find_ticket)
			return FALSE
		if(!find_ticket.NextRow())
			QDEL_NULL(find_ticket)
			return FALSE
		QDEL_NULL(find_ticket)
		return TRUE
	else if(config.overflow_whitelist.Find(lowertext(src.ckey)))
		return TRUE
	return FALSE
