/mob/new_player/Login()
	update_Login_details()	//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
	if(join_motd)
		to_chat(src, "<div class=\"motd\">[join_motd]</div>")

	if(!mind)
		mind = new /datum/mind(key)
		mind.active = 1
		mind.current = src

	if(length(newplayer_start))
		loc = pick(newplayer_start)
	else
		loc = locate(1,1,1)
	lastarea = loc

	sight |= SEE_TURFS
	GLOB.player_list |= src

/*
	var/list/watch_locations = list()
	for(var/obj/effect/landmark/landmark in GLOB.landmarks_list)
		if(landmark.tag == "landmark*new_player")
			watch_locations += landmark.loc

	if(watch_locations.len>0)
		loc = pick(watch_locations)
*/

	callHook("mob_login", list("client" = client, "mob" = src))

	new_player_panel()

	spawn(30)
		// Annoy the player with polls.
		establish_db_connection()
		if(dbcon.IsConnected() && client && client.can_vote())
			var/isadmin = 0
			if(client && client.holder)
				isadmin = 1
			var/DBQuery/query = dbcon.NewQuery("SELECT id FROM [format_table_name("poll_question")] WHERE [(isadmin ? "" : "adminonly = false AND")] Now() BETWEEN starttime AND endtime AND id NOT IN (SELECT pollid FROM [format_table_name("poll_vote")] WHERE ckey = \"[ckey]\") AND id NOT IN (SELECT pollid FROM [format_table_name("poll_textreply")] WHERE ckey = \"[ckey]\")")
			query.Execute()
			var/newpoll = 0
			while(query.NextRow())
				newpoll = 1
				break
			if(newpoll)
				client.handle_player_polling()

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
