/world
	mob = /mob/new_player
	turf = /turf/space
	area = /area
	view = "17x17"
	cache_lifespan = 0	//stops player uploaded stuff from being kept in the rsc past the current session


#define RECOMMENDED_VERSION 501

/world/New()
	//logs
	var/date_string = time2text(world.realtime, "YYYY/MM-Month/DD-Day")
	href_logfile = file("data/logs/[date_string] hrefs.htm")
	diary = file("data/logs/[date_string].log")
	diaryofmeanpeople = file("data/logs/[date_string] Attack.log")
	diary << "\n\nStarting up. [time2text(world.timeofday, "hh:mm.ss")]\n---------------------"
	diaryofmeanpeople << "\n\nStarting up. [time2text(world.timeofday, "hh:mm.ss")]\n---------------------"

	if(byond_version < RECOMMENDED_VERSION)
		world.log << "Your server's byond version does not meet the recommended requirements for this code. Please update BYOND"

	if(config && config.log_runtimes)
		log = file("data/logs/runtime/[time2text(world.realtime,"YYYY-MM-DD-(hh-mm-ss)")]-runtime.log")

	load_configuration()
	SetupHooks() // /vg/

	if(config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"

	if(config && config.log_runtime)
		log = file("data/logs/runtime/[time2text(world.realtime,"YYYY-MM-DD-(hh-mm-ss)")]-runtime.log")

	callHook("startup")

	src.update_status()

	. = ..()

	sleep_offline = 1

	plant_controller = new()
	// Create robolimbs for chargen.
	populate_robolimb_list()

	setup_map_transitions() //Before the MC starts up

	processScheduler = new
	master_controller = new /datum/controller/game_controller()
	spawn(1)
		processScheduler.deferSetupFor(/datum/controller/process/ticker)
		processScheduler.setup()

		master_controller.setup()

	#ifdef MAP_NAME
	map_name = "[MAP_NAME]"
	#else
	map_name = "Unknown"
	#endif

	spawn(3000)		//so we aren't adding to the round-start lag
		if(config.ToRban)
			ToRban_autoupdate()
		/*if(config.kick_inactive) HANDLED IN PROCESS SCHEDULER
			KickInactiveClients()*/


#undef RECOMMENDED_VERSION

	return

//world/Topic(href, href_list[])
//		world << "Received a Topic() call!"
//		world << "[href]"
//		for(var/a in href_list)
//			world << "[a]"
//		if(href_list["hello"])
//			world << "Hello world!"
//			return "Hello world!"
//		world << "End of Topic() call."
//		..()

var/world_topic_spam_protect_ip = "0.0.0.0"
var/world_topic_spam_protect_time = world.timeofday

/world/Topic(T, addr, master, key)
	diary << "TOPIC: \"[T]\", from:[addr], master:[master], key:[key]"

	if (T == "ping")
		var/x = 1
		for (var/client/C)
			x++
		return x

	else if(T == "players")
		var/n = 0
		for(var/mob/M in player_list)
			if(M.client)
				n++
		return n

	else if (T == "status")
		var/list/s = list()
		s["version"] = game_version
		s["mode"] = master_mode
		s["respawn"] = config ? abandon_allowed : 0
		s["enter"] = enter_allowed
		s["vote"] = config.allow_vote_mode
		s["ai"] = config.allow_ai
		s["host"] = host ? host : null
		s["players"] = list()
		s["stationtime"] = worldtime2text()
		var/n = 0
		var/admins = 0

		for(var/client/C in clients)
			if(C.holder)
				if(C.holder.fakekey)
					continue	//so stealthmins aren't revealed by the hub
				admins++
			s["player[n]"] = C.key
			n++
		s["players"] = n

//		if(revdata)	s["revision"] = revdata.revision
		s["admins"] = admins
		s["map_name"] = map_name ? map_name : "Unknown"

		return list2params(s)

	else if(copytext(T,1,9) == "adminmsg")
		/*
			We got an adminmsg from IRC bot lets split the input then validate the input.
			expected output:
				1. adminmsg = ckey of person the message is to
				2. msg = contents of message, parems2list requires
				3. validatationkey = the key the bot has, it should match the gameservers commspassword in it's configuration.
				4. sender = the ircnick that send the message.
		*/


		var/input[] = params2list(T)
		if(input["key"] != config.comms_password)
			if(world_topic_spam_protect_ip == addr && abs(world_topic_spam_protect_time - world.time) < 50)

				spawn(50)
					world_topic_spam_protect_time = world.time
					return "Bad Key (Throttled)"

			world_topic_spam_protect_time = world.time
			world_topic_spam_protect_ip = addr

			return "Bad Key"

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
		C << message


		for(var/client/A in admins)
			if(A != C)
				A << amessage

		return "Message Successful"

	else if(copytext(T,1,6) == "notes")
		/*
			We got a request for notes from the IRC Bot
			expected output:
				1. notes = ckey of person the notes lookup is for
				2. validationkey = the key the bot has, it should match the gameservers commspassword in it's configuration.
		*/
		var/input[] = params2list(T)
		if(input["key"] != config.comms_password)
			if(world_topic_spam_protect_ip == addr && abs(world_topic_spam_protect_time - world.time) < 50)

				spawn(50)
					world_topic_spam_protect_time = world.time
					return "Bad Key (Throttled)"

			world_topic_spam_protect_time = world.time
			world_topic_spam_protect_ip = addr
			return "Bad Key"

		return show_player_info_irc(input["notes"])





/world/Reboot(var/reason)
	spawn(0)
		world << sound(pick('sound/AI/newroundsexy.ogg','sound/misc/apcdestroyed.ogg','sound/misc/bangindonk.ogg')) // random end sounds!! - LastyBatsy

	processScheduler.stop()

	for(var/client/C in clients)
		if(config.server)	//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[config.server]")
		else
			C << link("byond://[world.address]:[world.port]")

	..(reason)


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
					C << "\red You have been inactive for more than 10 minutes and have been disconnected."
					del(C)
		if ( ((world.timeofday - sleep_check) > work_length) || ((world.timeofday - sleep_check) < 0) )
			sleep(sleep_length)
			sleep_check = world.timeofday
		waiting++
//#undef INACTIVITY_KICK
/*
#define DISCONNECTED_DELETE	6000	//10 minutes in ticks (approx)
/world/proc/KickDisconnectedClients()
	spawn(-1)
		//set background = 1
		while(1)
			sleep(DISCONNECTED_DELETE)
			for(var/mob/living/carbon/human/C in living_mob_list)
				if (dd_hasprefix(C.key,@)) return
				if(!C.client && C.brain_op_stage!=4.0 && C.lastKnownIP)
					sleep(600)
					if(!C.client && C.stat != DEAD && C.brain_op_stage!=4.0)
						job_master.FreeRole(C.job)
						message_admins("<b>[C.name]</b> ([C.ckey]), the [C.job] has been freed due to (<font color='#ffcc00'><b>Client disconnect for 10 minutes</b></font>)\n")
						for(var/obj/item/W in C)
							C.unEquip(W)
						del(C)
					else if(!C.key && C.stat != DEAD && C.brain_op_stage!=4.0)
						job_master.FreeRole(C.job)
						message_admins("<b>[C.name]</b> ([C.ckey]), the [C.job] has been freed due to (<font color='#ffcc00'><b>Client quit BYOND</b></font>)\n")
						for(var/obj/item/W in C)
							C.unEquip(W)
						del(C)
#undef INACTIVITY_KICK
*/

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

/hook/startup/proc/loadMusic()
	for(var/obj/machinery/media/jukebox/J in machines)
		J.process()
	return 1

/hook/startup/proc/loadMOTD()
	world.load_motd()
	return 1

/world/proc/load_motd()
	join_motd = file2text("config/motd.txt")


/world/proc/load_configuration()
	config = new /datum/configuration()
	config.load("config/config.txt")
	config.load("config/game_options.txt","game_options")
	config.loadsql("config/dbconfig.txt")
	config.loadforumsql("config/forumdbconfig.txt")
	// apply some settings from config..

/hook/startup/proc/loadMods()
	world.load_mods()
	return 1

/world/proc/load_mods()
	if(config.admin_legacy_system)
		var/text = file2text("config/moderators.txt")
		if (!text)
			diary << "Failed to load config/mods.txt\n"
		else
			var/list/lines = text2list(text, "\n")
			for(var/line in lines)
				if (!line)
					continue

				if (copytext(line, 1, 2) == ";")
					continue

				var/title = "Moderator"
				if(config.mods_are_mentors) title = "Mentor"
				var/rights = admin_ranks[title]

				var/ckey = copytext(line, 1, length(line)+1)
				var/datum/admins/D = new /datum/admins(title, rights, ckey)
				D.associate(directory[ckey])

/world/proc/update_status()
	var/s = ""

	if (config && config.server_name)
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

	if (!enter_allowed)
		features += "closed"

	features += abandon_allowed ? "respawn" : "no respawn"

	if (config && config.allow_vote_mode)
		features += "vote"

	if (config && config.allow_ai)
		features += "AI allowed"

	var/n = 0
	for (var/mob/M in player_list)
		if (M.client)
			n++

	if (n > 1)
		features += "~[n] players"
	else if (n > 0)
		features += "~[n] player"

	/*
	is there a reason for this? the byond site shows 'hosted by X' when there is a proper host already.
	if (host)
		features += "hosted by <b>[host]</b>"
	*/

//	if (!host && config && config.hostedby)
//		features += "hosted by <b>[config.hostedby]</b>"

	if (features)
		s += ": [list2text(features, ", ")]"

	/* does this help? I do not know */
	if (src.status != s)
		src.status = s

#define FAILED_DB_CONNECTION_CUTOFF 5
var/failed_db_connections = 0
var/failed_old_db_connections = 0

/hook/startup/proc/connectDB()
	if(!setup_database_connection())
		world.log << "Your server failed to establish a connection with the feedback database."
	else
		world.log << "Feedback database connection established."
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
	if ( . )
		failed_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		failed_db_connections++		//If it failed, increase the failed connections counter.
		world.log << dbcon.ErrorMsg()

	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
proc/establish_db_connection()
	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	if(!dbcon || !dbcon.IsConnected())
		return setup_database_connection()
	else
		return 1


/hook/startup/proc/connectOldDB()
	if(!setup_old_database_connection())
		world.log << "Your server failed to establish a connection with the SQL database."
	else
		world.log << "SQL database connection established."
	return 1

//These two procs are for the old database, while it's being phased out. See the tgstation.sql file in the SQL folder for more information.
proc/setup_old_database_connection()

	if(failed_old_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to conenct anymore.
		return 0

	if(!dbcon_old)
		dbcon_old = new()

	var/user = sqllogin
	var/pass = sqlpass
	var/db = sqldb
	var/address = sqladdress
	var/port = sqlport

	dbcon_old.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = dbcon_old.IsConnected()
	if ( . )
		failed_old_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		failed_old_db_connections++		//If it failed, increase the failed connections counter.
		world.log << dbcon.ErrorMsg()

	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
proc/establish_old_db_connection()
	if(failed_old_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	if(!dbcon_old || !dbcon_old.IsConnected())
		return setup_old_database_connection()
	else
		return 1

#undef FAILED_DB_CONNECTION_CUTOFF
