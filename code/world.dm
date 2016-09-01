var/global/datum/global_init/init = new ()

/*
	Pre-map initialization stuff should go here.
*/
/datum/global_init/New()

	makeDatumRefLists()
	load_configuration()

	del(src)

/world
	mob = /mob/new_player
	turf = /turf/space
	area = /area/space
	view = "15x15"
	cache_lifespan = 0	//stops player uploaded stuff from being kept in the rsc past the current session


#define RECOMMENDED_VERSION 510

var/global/list/map_transition_config = MAP_TRANSITION_CONFIG

/world/New()
	//logs
	var/date_string = time2text(world.realtime, "YYYY/MM-Month/DD-Day")
	href_logfile = file("data/logs/[date_string] hrefs.htm")
	diary = file("data/logs/[date_string].log")
	diaryofmeanpeople = file("data/logs/[date_string] Attack.log")
	diary << "\n\nStarting up. [time2text(world.timeofday, "hh:mm.ss")]\n---------------------"
	diaryofmeanpeople << "\n\nStarting up. [time2text(world.timeofday, "hh:mm.ss")]\n---------------------"

	if(byond_version < RECOMMENDED_VERSION)
		log_to_dd("Your server's byond version does not meet the recommended requirements for this code. Please update BYOND")

	if(config && config.log_runtimes)
		log = file("data/logs/runtime/[time2text(world.realtime,"YYYY-MM-DD-(hh-mm-ss)")]-runtime.log")

	if(config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"

	timezoneOffset = text2num(time2text(0,"hh")) * 36000

	callHook("startup")

	src.update_status()

	. = ..()

	plant_controller = new()
	// Create robolimbs for chargen.
	populate_robolimb_list()

	space_manager.initialize() //Before the MC starts up

	processScheduler = new
	master_controller = new /datum/controller/game_controller()
	spawn(1)
		processScheduler.deferSetupFor(/datum/controller/process/ticker)
		processScheduler.setup()

		master_controller.setup()
		sleep_offline = 1

	#ifdef MAP_NAME
	map_name = "[MAP_NAME]"
	#else
	map_name = "Unknown"
	#endif




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
	diary << "TOPIC: \"[T]\", from:[addr], master:[master], key:[key]"

	var/list/input = params2list(T)
	var/key_valid = (config.comms_password && input["key"] == config.comms_password) //no password means no comms, not any password

	if("ping" in input)
		var/x = 1
		for(var/client/C)
			x++
		return x

	else if("players" in input)
		var/n = 0
		for(var/mob/M in player_list)
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
		s["stationtime"] = worldtime2text()
		var/player_count = 0
		var/admin_count = 0

		for(var/client/C in clients)
			if(C.holder)
				if(C.holder.fakekey)
					continue	//so stealthmins aren't revealed by the hub
				admin_count++
				admins += list(list(C.key, C.holder.rank))
			s["player[player_count]"] = C.key
			player_count++
		s["players"] = player_count
		s["admins"] = admin_count
		s["map_name"] = map_name ? map_name : "Unknown"

		if(key_valid)
			if(ticker && ticker.mode)
				s["real_mode"] = ticker.mode.name

			s["security_level"] = get_security_level()

			if(shuttle_master && shuttle_master.emergency)
				// Shuttle status, see /__DEFINES/stat.dm
				s["shuttle_mode"] = shuttle_master.emergency.mode
				// Shuttle timer, in seconds
				s["shuttle_timer"] = shuttle_master.emergency.timeLeft()

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

		for(var/client/K in clients)
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

		for(var/client/A in admins)
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
				for(var/client/C in clients)
					to_chat(C, "<span class='announce'>PR: [input["announce"]]</span>")

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
		return ..(1)
	var/delay
	if(!isnull(time))
		delay = max(0,time)
	else
		delay = ticker.restart_timeout
	if(ticker.delay_end)
		to_chat(world, "<span class='boldannounce'>An admin has delayed the round end.</span>")
		return
	to_chat(world, "<span class='boldannounce'>Rebooting world in [delay/10] [delay > 10 ? "seconds" : "second"]. [reason]</span>")
	sleep(delay)
	if(blackbox)
		blackbox.save_all_data_to_sql()
	if(ticker.delay_end)
		to_chat(world, "<span class='boldannounce'>Reboot was cancelled by an admin.</span>")
		return
	feedback_set_details("[feedback_c]","[feedback_r]")
	log_game("<span class='boldannounce'>Rebooting world. [reason]</span>")
	//kick_clients_in_lobby("<span class='boldannounce'>The round came to an end with you in the lobby.</span>", 1)

	spawn(0)
		world << sound(pick('sound/AI/newroundsexy.ogg','sound/misc/apcdestroyed.ogg','sound/misc/bangindonk.ogg', 'sound/goonstation/misc/newround1.ogg', 'sound/goonstation/misc/newround2.ogg'))// random end sounds!! - LastyBatsy


	processScheduler.stop()

	for(var/client/C in clients)
		if(config.server)	//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[config.server]")
	..(0)

#define INACTIVITY_KICK	6000	//10 minutes in ticks (approx.)
/world/proc/KickInactiveClients()
	var/tmp/sleep_check = 0 // buffer for checking elapsed ticks
	var/tmp/work_length = 2 // number of ticks to run before yielding cpu
	var/tmp/sleep_length = 5 // number of ticks to yield
	var/waiting=1

	sleep_check = world.timeofday

	while(waiting)
		waiting = 0
		sleep(INACTIVITY_KICK)
		for(var/client/C in clients)
			if(C.holder) return
			if(C.is_afk(INACTIVITY_KICK))
				if(!istype(C.mob, /mob/dead))
					log_access("AFK: [key_name(C)]")
					to_chat(C, "\red You have been inactive for more than 10 minutes and have been disconnected.")
					del(C)
		if( ((world.timeofday - sleep_check) > work_length) || ((world.timeofday - sleep_check) < 0) )
			sleep(sleep_length)
			sleep_check = world.timeofday
		waiting++
//#undef INACTIVITY_KICK

/hook/startup/proc/loadMode()
	world.load_mode()
	return 1

/world/proc/load_mode()
	var/list/Lines = file2list("data/mode.txt")
	if(Lines.len)
		if(Lines[1])
			master_mode = Lines[1]
			diary << "Saved mode is '[master_mode]'"

/world/proc/save_mode(var/the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	F << the_mode

/hook/startup/proc/loadMOTD()
	world.load_motd()
	return 1

/world/proc/load_motd()
	join_motd = file2text("config/motd.txt")


/proc/load_configuration()
	config = new /datum/configuration()
	config.load("config/config.txt")
	config.load("config/game_options.txt","game_options")
	config.loadsql("config/dbconfig.txt")
	config.loadoverflowwhitelist("config/ofwhitelist.txt")
	// apply some settings from config..

/world/proc/update_status()
	var/s = ""

	if(config && config.server_name)
		s += "<b>[config.server_name]</b> &#8212; "

	s += "<b>[station_name()]</b>";
	s += " ("
	s += "<a href=\"http://nanotrasen.se/phpBB3/index.php\">" //Change this to wherever you want the hub to link to.
	s += "[game_version]"
	s += "</a>"
	s += ")"
	s += "<br>The Perfect Mix of RP & Action<br>"




	var/list/features = list()

	if(ticker)
		if(master_mode)
			features += master_mode
	else
		features += "<b>STARTING</b>"

	if(!enter_allowed)
		features += "closed"

	features += abandon_allowed ? "respawn" : "no respawn"

	if(config && config.allow_vote_mode)
		features += "vote"

	if(config && config.allow_ai)
		features += "AI allowed"

	var/n = 0
	for(var/mob/M in player_list)
		if(M.client)
			n++

	if(n > 1)
		features += "~[n] players"
	else if(n > 0)
		features += "~[n] player"

	/*
	is there a reason for this? the byond site shows 'hosted by X' when there is a proper host already.
	if(host)
		features += "hosted by <b>[host]</b>"
	*/

//	if(!host && config && config.hostedby)
//		features += "hosted by <b>[config.hostedby]</b>"

	if(features)
		s += ": [jointext(features, ", ")]"

	/* does this help? I do not know */
	if(src.status != s)
		src.status = s

#define FAILED_DB_CONNECTION_CUTOFF 5
var/failed_db_connections = 0
var/failed_old_db_connections = 0

/hook/startup/proc/connectDB()
	if(!setup_database_connection())
		log_to_dd("Your server failed to establish a connection with the feedback database.")
	else
		log_to_dd("Feedback database connection established.")
	return 1

proc/setup_database_connection()

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
		log_to_dd(dbcon.ErrorMsg())

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
