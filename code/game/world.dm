#define RECOMMENDED_VERSION 510

var/global/list/map_transition_config = MAP_TRANSITION_CONFIG

/world/New()
	SetupLogs()
	log_world("World loaded at [time_stamp()]")
	log_world("[GLOB.vars.len - GLOB.gvars_datum_in_built_vars.len] global variables")

	if(byond_version < RECOMMENDED_VERSION)
		log_world("Your server's byond version does not meet the recommended requirements for this code. Please update BYOND")

	if(config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"

	GLOB.timezoneOffset = text2num(time2text(0, "hh")) * 36000

	makeDatumRefLists()
	callHook("startup")

	src.update_status()

	space_manager.initialize() //Before the MC starts up

	. = ..()

	// Create robolimbs for chargen.
	populate_robolimb_list()

	Master.Initialize(10, FALSE)


#undef RECOMMENDED_VERSION

	return

//world/Topic(href, href_list[])
//		to_chat(world, "Received a Topic() call!")
//		to_chat(world, "[href]")
//		for(var/a in href_list)
//			to_chat(world, "[a]")
//		if(href_list["hello"])
//			to_chat(world, "Hello world!")
//			return "Hello world!"
//		to_chat(world, "End of Topic() call.")
//		..()

var/world_topic_spam_protect_ip = "0.0.0.0"
var/world_topic_spam_protect_time = world.timeofday

/world/Topic(T, addr, master, key)
	log_misc("WORLD/TOPIC: \"[T]\", from:[addr], master:[master], key:[key]")

	var/list/input = params2list(T)
	var/key_valid = (config.comms_password && input["key"] == config.comms_password) //no password means no comms, not any password

	if("ping" in input)
		var/x = 1
		for(var/client/C)
			x++
		return x

	else if("players" in input)
		var/n = 0
		for(var/mob/M in GLOB.player_list)
			if(M.client)
				n++
		return n

	else if("status" in input)
		var/list/s = list()
		var/list/admins = list()
		s["version"] = game_version
		s["mode"] = master_mode
		s["respawn"] = config ? abandon_allowed : 0
		s["enter"] = enter_allowed
		s["vote"] = config.allow_vote_mode
		s["ai"] = config.allow_ai
		s["host"] = host ? host : null
		s["players"] = list()
		s["roundtime"] = worldtime2text()
		s["stationtime"] = station_time_timestamp()
		s["oldstationtime"] = classic_worldtime2text() // more "consistent" indication of the round's running time
		s["listed"] = "Public"
		if(!hub_password)
			s["listed"] = "Invisible"
		var/player_count = 0
		var/admin_count = 0

		for(var/client/C in GLOB.clients)
			if(C.holder)
				if(C.holder.fakekey)
					continue	//so stealthmins aren't revealed by the hub
				admin_count++
				admins += list(list(C.key, C.holder.rank))
			s["player[player_count]"] = C.key
			player_count++
		s["players"] = player_count
		s["admins"] = admin_count
		s["map_name"] = GLOB.map_name ? GLOB.map_name : "Unknown"

		if(key_valid)
			if(SSticker && SSticker.mode)
				s["real_mode"] = SSticker.mode.name
				s["security_level"] = get_security_level()
				s["ticker_state"] = SSticker.current_state

			if(SSshuttle && SSshuttle.emergency)
				// Shuttle status, see /__DEFINES/stat.dm
				s["shuttle_mode"] = SSshuttle.emergency.mode
				// Shuttle timer, in seconds
				s["shuttle_timer"] = SSshuttle.emergency.timeLeft()

			for(var/i in 1 to admins.len)
				var/list/A = admins[i]
				s["admin[i - 1]"] = A[1]
				s["adminrank[i - 1]"] = A[2]

		return list2params(s)

	else if("manifest" in input)
		var/list/positions = list()
		var/list/set_names = list(
			"heads" = command_positions,
			"sec" = security_positions,
			"eng" = engineering_positions,
			"med" = medical_positions,
			"sci" = science_positions,
			"car" = supply_positions,
			"srv" = service_positions,
			"civ" = civilian_positions,
			"bot" = nonhuman_positions
		)

		for(var/datum/data/record/t in data_core.general)
			var/name = t.fields["name"]
			var/rank = t.fields["rank"]
			var/real_rank = t.fields["real_rank"]

			var/department = 0
			for(var/k in set_names)
				if(real_rank in set_names[k])
					if(!positions[k])
						positions[k] = list()
					positions[k][name] = rank
					department = 1
			if(!department)
				if(!positions["misc"])
					positions["misc"] = list()
				positions["misc"][name] = rank

		return json_encode(positions)

	else if("adminmsg" in input)
		/*
			We got an adminmsg from IRC bot lets split the input then validate the input.
			expected output:
				1. adminmsg = ckey of person the message is to
				2. msg = contents of message, parems2list requires
				3. validatationkey = the key the bot has, it should match the gameservers commspassword in it's configuration.
				4. sender = the ircnick that send the message.
		*/
		if(!key_valid)
			return keySpamProtect(addr)

		var/client/C

		for(var/client/K in GLOB.clients)
			if(K.ckey == input["adminmsg"])
				C = K
				break
		if(!C)
			return "No client with that name on server"

		var/message =	"<font color='red'>IRC-Admin PM from <b><a href='?irc_msg=1'>[C.holder ? "IRC-" + input["sender"] : "Administrator"]</a></b>: [input["msg"]]</font>"
		var/amessage =  "<font color='blue'>IRC-Admin PM from <a href='?irc_msg=1'>IRC-[input["sender"]]</a> to <b>[key_name(C)]</b> : [input["msg"]]</font>"

		C.received_irc_pm = world.time
		C.irc_admin = input["sender"]

		C << 'sound/effects/adminhelp.ogg'
		to_chat(C, message)

		for(var/client/A in GLOB.admins)
			if(A != C)
				to_chat(A, amessage)

		return "Message Successful"

	else if("notes" in input)
		/*
			We got a request for notes from the IRC Bot
			expected output:
				1. notes = ckey of person the notes lookup is for
				2. validationkey = the key the bot has, it should match the gameservers commspassword in it's configuration.
		*/
		if(!key_valid)
			return keySpamProtect(addr)

		return show_player_info_irc(input["notes"])

	else if("announce" in input)
		if(config.comms_password)
			if(input["key"] != config.comms_password)
				return "Bad Key"
			else
				for(var/client/C in GLOB.clients)
					to_chat(C, "<span class='announce'>PR: [input["announce"]]</span>")

	else if("kick" in input)
		/*
			We have a kick request over coms.
			Only needed portion is the ckey
		*/
		if(!key_valid)
			return keySpamProtect(addr)

		var/client/C

		for(var/client/K in GLOB.clients)
			if(K.ckey == input["kick"])
				C = K
				break
		if(!C)
			return "No client with that name on server"

		del(C)

		return "Kick Successful"

	else if("setlog" in input)
		if(!key_valid)
			return keySpamProtect(addr)

		SetupLogs()

		return "Logs set to current date"

	else if("setlist" in input)
		if(!key_valid)
			return keySpamProtect(addr)
		if(input["req"] == "public")
			hub_password = hub_password_base
			update_status()
			return "Set listed status to public."
		else
			hub_password = ""
			update_status()
			return "Set listed status to invisible."

/proc/keySpamProtect(var/addr)
	if(world_topic_spam_protect_ip == addr && abs(world_topic_spam_protect_time - world.time) < 50)
		spawn(50)
			world_topic_spam_protect_time = world.time
			return "Bad Key (Throttled)"

	world_topic_spam_protect_time = world.time
	world_topic_spam_protect_ip = addr
	return "Bad Key"

/world/Reboot(var/reason, var/feedback_c, var/feedback_r, var/time)
	if(reason == 1) //special reboot, do none of the normal stuff
		if(usr)
			message_admins("[key_name_admin(usr)] has requested an immediate world restart via client side debugging tools")
			log_admin("[key_name(usr)] has requested an immediate world restart via client side debugging tools")
		spawn(0)
			to_chat(world, "<span class='boldannounce'>Rebooting world immediately due to host request</span>")
		shutdown_logging() // Past this point, no logging procs can be used, at risk of data loss.
		if(config && config.shutdown_on_reboot)
			sleep(0)
			if(shutdown_shell_command)
				shell(shutdown_shell_command)
			del(world)
			return
		else
			return ..(1)

	var/delay
	if(!isnull(time))
		delay = max(0,time)
	else
		delay = SSticker.restart_timeout
	if(SSticker.delay_end)
		to_chat(world, "<span class='boldannounce'>An admin has delayed the round end.</span>")
		return
	to_chat(world, "<span class='boldannounce'>Rebooting world in [delay/10] [delay > 10 ? "seconds" : "second"]. [reason]</span>")

	var/round_end_sound = pick(GLOB.round_end_sounds)
	var/sound_length = GLOB.round_end_sounds[round_end_sound]
	if(delay > sound_length) // If there's time, play the round-end sound before rebooting
		spawn(delay - sound_length)
			if(!SSticker.delay_end)
				world << round_end_sound
	sleep(delay)
	if(blackbox)
		blackbox.save_all_data_to_sql()
	if(SSticker.delay_end)
		to_chat(world, "<span class='boldannounce'>Reboot was cancelled by an admin.</span>")
		return
	feedback_set_details("[feedback_c]","[feedback_r]")
	log_game("<span class='boldannounce'>Rebooting world. [reason]</span>")
	//kick_clients_in_lobby("<span class='boldannounce'>The round came to an end with you in the lobby.</span>", 1)

	Master.Shutdown()	//run SS shutdowns
	dbcon.Disconnect() // DCs cleanly from the database
	shutdown_logging() // Past this point, no logging procs can be used, at risk of data loss.

	for(var/client/C in GLOB.clients)
		if(config.server)       //if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[config.server]")

	if(config && config.shutdown_on_reboot)
		sleep(0)
		if(shutdown_shell_command)
			shell(shutdown_shell_command)
		del(world)
		return
	else
		..(0)


/hook/startup/proc/loadMode()
	world.load_mode()
	return 1

/world/proc/load_mode()
	var/list/Lines = file2list("data/mode.txt")
	if(Lines.len)
		if(Lines[1])
			master_mode = Lines[1]
			log_game("Saved mode is '[master_mode]'")

/world/proc/save_mode(var/the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	F << the_mode

/hook/startup/proc/loadMOTD()
	world.load_motd()
	return 1

/world/proc/load_motd()
	join_motd = file2text("config/motd.txt")
	GLOB.join_tos = file2text("config/tos.txt")

/proc/load_configuration()
	config = new /datum/configuration()
	config.load("config/config.txt")
	config.load("config/game_options.txt","game_options")
	config.loadsql("config/dbconfig.txt")
	config.loadoverflowwhitelist("config/ofwhitelist.txt")
	// apply some settings from config..

/world/proc/update_status()
	status = get_status_text()

/proc/get_world_status_text()
	return world.get_status_text()

/world/proc/get_status_text()
	var/s = ""

	if(config && config.server_name)
		s += "<b>[config.server_name]</b> &#8212; "
	s += "<b>[station_name()]</b> "
	if(config && config.githuburl)
		s+= "([game_version])"

	if(config && config.server_tag_line)
		s += "<br>[config.server_tag_line]"

	if(SSticker && ROUND_TIME > 0)
		s += "<br>[round(ROUND_TIME / 36000)]:[add_zero(num2text(ROUND_TIME / 600 % 60), 2)], " + capitalize(get_security_level())
	else
		s += "<br><b>STARTING</b>"

	s += "<br>"
	var/list/features = list()

	if(!enter_allowed)
		features += "closed"

	if(config && config.server_extra_features)
		features += config.server_extra_features

	if(config && config.allow_vote_mode)
		features += "vote"

	if(config && config.wikiurl)
		features += "<a href=\"[config.wikiurl]\">Wiki</a>"

	if(abandon_allowed)
		features += "respawn"

	if(features)
		s += "[jointext(features, ", ")]"

	return s

#define FAILED_DB_CONNECTION_CUTOFF 5
var/failed_db_connections = 0
var/failed_old_db_connections = 0

/world/proc/SetupLogs()
	GLOB.log_directory = "data/logs/[time2text(world.realtime, "YYYY/MM-Month/DD-Day")]"
	GLOB.world_game_log = "[GLOB.log_directory]/game.log"
	GLOB.world_href_log = "[GLOB.log_directory]/hrefs.log"
	GLOB.world_runtime_log = "[GLOB.log_directory]/runtime.log"
	GLOB.world_qdel_log = "[GLOB.log_directory]/qdel.log"
	GLOB.world_asset_log = "[GLOB.log_directory]/asset.log"
	start_log(GLOB.world_game_log)
	start_log(GLOB.world_href_log)
	start_log(GLOB.world_runtime_log)
	start_log(GLOB.world_qdel_log)

	// This log follows a special format and this path should NOT be used for anything else
	GLOB.runtime_summary_log = "data/logs/runtime_summary.log"
	if(fexists(GLOB.runtime_summary_log))
		fdel(GLOB.runtime_summary_log)
	start_log(GLOB.runtime_summary_log)
	// And back to sanity

	if(fexists(GLOB.config_error_log))
		fcopy(GLOB.config_error_log, "[GLOB.log_directory]/config_error.log")
		fdel(GLOB.config_error_log)


/hook/startup/proc/connectDB()
	if(!setup_database_connection())
		log_world("Your server failed to establish a connection with the feedback database.")
	else
		log_world("Feedback database connection established.")
	return 1

/proc/setup_database_connection()

	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to conenct anymore.
		return 0

	if(!dbcon)
		dbcon = new()

	var/user = sqlfdbklogin
	var/pass = sqlfdbkpass
	var/db = sqlfdbkdb
	var/address = sqladdress
	var/port = sqlport

	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = dbcon.IsConnected()
	if( . )
		failed_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		failed_db_connections++		//If it failed, increase the failed connections counter.
		log_world(dbcon.ErrorMsg())

	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
proc/establish_db_connection()
	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	if(!dbcon || !dbcon.IsConnected())
		return setup_database_connection()
	else
		return 1

#undef FAILED_DB_CONNECTION_CUTOFF
