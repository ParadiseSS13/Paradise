GLOBAL_LIST_INIT(map_transition_config, MAP_TRANSITION_CONFIG)

/world/New()
	// IMPORTANT
	// If you do any SQL operations inside this proc, they must ***NOT*** be ran async. Otherwise players can join mid query
	// This is BAD.

	//temporary file used to record errors with loading config and the database, moved to log directory once logging is set up
	GLOB.config_error_log = GLOB.world_game_log = GLOB.world_runtime_log = GLOB.sql_log = "data/logs/config_error.log"
	load_configuration()
	enable_debugger() // Enable the extools debugger

	// Right off the bat, load up the DB
	SSdbcore.CheckSchemaVersion() // This doesnt just check the schema version, it also connects to the db! This needs to happen super early! I cannot stress this enough!
	SSdbcore.SetRoundID() // Set the round ID here

	// Setup all log paths and stamp them with startups, including round IDs
	SetupLogs()

	// This needs to happen early, otherwise people can get a null species, nuking their character
	makeDatumRefLists()

	TgsNew(new /datum/tgs_event_handler/impl, TGS_SECURITY_TRUSTED) // creates a new TGS object
	log_world("World loaded at [time_stamp()]")
	log_world("[GLOB.vars.len - GLOB.gvars_datum_in_built_vars.len] global variables")
	GLOB.revision_info.log_info()
	load_admins(run_async=FALSE) // This better happen early on.

	#ifdef UNIT_TESTS
	log_world("Unit Tests Are Enabled!")
	#endif


	if(byond_version < MIN_COMPILER_VERSION || byond_build < MIN_COMPILER_BUILD)
		log_world("Your server's byond version does not meet the recommended requirements for this code. Please update BYOND")

	if(config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"

	GLOB.timezoneOffset = text2num(time2text(0, "hh")) * 36000

	startup_procs() // Call procs that need to occur on startup (Generate lists, load MOTD, etc)

	src.update_status()

	GLOB.space_manager.initialize() //Before the MC starts up

	. = ..()

	Master.Initialize(10, FALSE, TRUE)


	#ifdef UNIT_TESTS
	HandleTestRun()
	#endif

	return

// This is basically a replacement for hook/startup. Please dont shove random bullshit here
// If it doesnt need to happen IMMEDIATELY on world load, make a subsystem for it
/world/proc/startup_procs()
	LoadBans() // Load up who is banned and who isnt. DONT PUT THIS IN A SUBSYSTEM IT WILL TAKE TOO LONG TO BE CALLED
	jobban_loadbanfile() // Load up jobbans. Again, DO NOT PUT THIS IN A SUBSYSTEM IT WILL TAKE TOO LONG TO BE CALLED
	load_motd() // Loads up the MOTD (Welcome message players see when joining the server)
	load_mode() // Loads up the gamemode
	investigate_reset() // This is part of the admin investigate system. PLEASE DONT SS THIS EITHER

/// List of all world topic spam prevention handlers. See code/modules/world_topic/_spam_prevention_handler.dm
GLOBAL_LIST_EMPTY(world_topic_spam_prevention_handlers)
/// List of all world topic handler datums. Populated inside makeDatumRefLists()
GLOBAL_LIST_EMPTY(world_topic_handlers)


/world/Topic(T, addr, master, key)
	TGS_TOPIC
	log_misc("WORLD/TOPIC: \"[T]\", from:[addr], master:[master], key:[key]")

	// Handle spam prevention
	if(!GLOB.world_topic_spam_prevention_handlers[address])
		GLOB.world_topic_spam_prevention_handlers[address] = new /datum/world_topic_spam_prevention_handler

	var/datum/world_topic_spam_prevention_handler/sph = GLOB.world_topic_spam_prevention_handlers[address]

	// Lock the user out and cancel their topic if needed
	if(sph.check_lockout())
		return

	var/list/input = params2list(T)

	var/datum/world_topic_handler/wth

	for(var/H in GLOB.world_topic_handlers)
		if(H in input)
			wth = GLOB.world_topic_handlers[H]
			break

	if(!wth)
		return

	// If we are here, the handler exists, so it needs to be invoked
	wth = new wth()
	return wth.invoke(input)

/world/Reboot(var/reason, end_string, var/time)
	//special reboot, do none of the normal stuff
	if(reason == 1) // Do NOT change this to if(reason). You WILL break the entirety of world rebooting
		if(usr)
			if(!check_rights(R_SERVER))
				message_admins("[key_name_admin(usr)] attempted to restart the server via the Profiler, without access.")
				log_admin("[key_name(usr)] attempted to restart the server via the Profiler, without access.")
				return
			message_admins("[key_name_admin(usr)] has requested an immediate world restart via client side debugging tools")
			log_admin("[key_name(usr)] has requested an immediate world restart via client side debugging tools")
		spawn(0)
			to_chat(world, "<span class='boldannounce'>Rebooting world immediately due to host request</span>")
		rustg_log_close_all() // Past this point, no logging procs can be used, at risk of data loss.
		TgsReboot()
		if(config && config.shutdown_on_reboot)
			sleep(0)
			if(GLOB.shutdown_shell_command)
				shell(GLOB.shutdown_shell_command)
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
	if(SSticker.delay_end)
		to_chat(world, "<span class='boldannounce'>Reboot was cancelled by an admin.</span>")
		return
	log_game("<span class='boldannounce'>Rebooting world. [reason]</span>")
	//kick_clients_in_lobby("<span class='boldannounce'>The round came to an end with you in the lobby.</span>", 1)

	if(end_string)
		SSticker.end_state = end_string

	Master.Shutdown()	//run SS shutdowns
	rustg_log_close_all() // Past this point, no logging procs can be used, at risk of data loss.
	TgsReboot()

	#ifdef UNIT_TESTS
	FinishTestRun()
	return
	#endif

	var/secs_before_auto_reconnect = 10
	if(GLOB.pending_server_update)
		secs_before_auto_reconnect = 60
		to_chat(world, "<span class='boldannounce'>Reboot will take a little longer, due to pending updates.</span>")

	for(var/client/C in GLOB.clients)
		C << output(list2params(list(secs_before_auto_reconnect)), "browseroutput:reboot")
		if(config.server)       //if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[config.server]")

	if(config && config.shutdown_on_reboot)
		sleep(0)
		if(GLOB.shutdown_shell_command)
			shell(GLOB.shutdown_shell_command)
		del(world)
		return
	else
		..(0)

/world/proc/load_mode()
	var/list/Lines = file2list("data/mode.txt")
	if(Lines.len)
		if(Lines[1])
			GLOB.master_mode = Lines[1]
			log_game("Saved mode is '[GLOB.master_mode]'")

/world/proc/save_mode(var/the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	F << the_mode

/world/proc/load_motd()
	GLOB.join_motd = file2text("config/motd.txt")
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
		s+= "([GLOB.game_version])"

	if(config && config.server_tag_line)
		s += "<br>[config.server_tag_line]"

	if(SSticker && ROUND_TIME > 0)
		s += "<br>[round(ROUND_TIME / 36000)]:[add_zero(num2text(ROUND_TIME / 600 % 60), 2)], " + capitalize(get_security_level())
	else
		s += "<br><b>STARTING</b>"

	s += "<br>"
	var/list/features = list()

	if(!GLOB.enter_allowed)
		features += "closed"

	if(config && config.server_extra_features)
		features += config.server_extra_features

	if(config && config.allow_vote_mode)
		features += "vote"

	if(config && config.wikiurl)
		features += "<a href=\"[config.wikiurl]\">Wiki</a>"

	if(GLOB.abandon_allowed)
		features += "respawn"

	if(features)
		s += "[jointext(features, ", ")]"

	return s

/world/proc/SetupLogs()
	if(GLOB.round_id)
		GLOB.log_directory = "data/logs/[time2text(world.realtime, "YYYY/MM-Month/DD-Day")]/round-[GLOB.round_id]"
	else
		GLOB.log_directory = "data/logs/[time2text(world.realtime, "YYYY/MM-Month/DD-Day")]" // Dont stick a round ID if we dont have one
	GLOB.world_game_log = "[GLOB.log_directory]/game.log"
	GLOB.world_href_log = "[GLOB.log_directory]/hrefs.log"
	GLOB.world_runtime_log = "[GLOB.log_directory]/runtime.log"
	GLOB.world_qdel_log = "[GLOB.log_directory]/qdel.log"
	GLOB.world_asset_log = "[GLOB.log_directory]/asset.log"
	GLOB.tgui_log = "[GLOB.log_directory]/tgui.log"
	GLOB.http_log = "[GLOB.log_directory]/http.log"
	GLOB.sql_log = "[GLOB.log_directory]/sql.log"
	start_log(GLOB.world_game_log)
	start_log(GLOB.world_href_log)
	start_log(GLOB.world_runtime_log)
	start_log(GLOB.world_qdel_log)
	start_log(GLOB.tgui_log)
	start_log(GLOB.http_log)
	start_log(GLOB.sql_log)

	// This log follows a special format and this path should NOT be used for anything else
	GLOB.runtime_summary_log = "data/logs/runtime_summary.log"
	if(fexists(GLOB.runtime_summary_log))
		fdel(GLOB.runtime_summary_log)
	start_log(GLOB.runtime_summary_log)
	// And back to sanity

	if(fexists(GLOB.config_error_log))
		fcopy(GLOB.config_error_log, "[GLOB.log_directory]/config_error.log")
		fdel(GLOB.config_error_log)

	// Save the current round's log path to a text file for other scripts to use.
	var/F = file("data/logpath.txt")
	fdel(F)
	F << GLOB.log_directory

// Proc to enable the extools debugger, which allows breakpoints, live var checking, and many other useful tools
// The DLL is injected into the env by visual studio code. If not running VSCode, the proc will not call the initialization
/world/proc/enable_debugger()
    var/dll = world.GetConfig("env", "EXTOOLS_DLL")
    if (dll)
        call(dll, "debug_initialize")()


/world/Del()
	rustg_close_async_http_client() // Close the HTTP client. If you dont do this, youll get phantom threads which can crash DD from memory access violations
	..()
