GLOBAL_LIST_INIT(map_transition_config, list(CC_TRANSITION_CONFIG))

#ifdef TEST_RUNNER
GLOBAL_DATUM(test_runner, /datum/test_runner)
#endif

/world/New()
	// IMPORTANT
	// If you do any SQL operations inside this proc, they must ***NOT*** be ran async. Otherwise players can join mid query
	// This is BAD.


	SSmetrics.world_init_time = REALTIMEOFDAY

	// Do sanity checks to ensure RUST actually exists
	if((!fexists(RUST_G)) && world.system_type == MS_WINDOWS)
		DIRECT_OUTPUT(world.log, "ERROR: RUSTG was not found and is required for the game to function. Server will now exit.")
		del(world)

	var/rustg_version = rustg_get_version()
	if(rustg_version != RUST_G_VERSION)
		DIRECT_OUTPUT(world.log, "ERROR: RUSTG version mismatch. Library is [rustg_version], code wants [RUST_G_VERSION]. Server will now exit.")
		del(world)

	//temporary file used to record errors with loading config and the database, moved to log directory once logging is set up
	GLOB.config_error_log = GLOB.world_game_log = GLOB.world_runtime_log = GLOB.sql_log = "data/logs/config_error.log"
	GLOB.configuration.load_configuration() // Load up the base config.toml
	// Load up overrides for this specific instance, based on port
	// If this instance is listening on port 6666, the server will look for config/overrides_6666.toml
	GLOB.configuration.load_overrides("config/overrides_[world.port].toml")

	#ifdef TEST_CONFIG_OVERRIDE
	GLOB.configuration.load_overrides("config/tests/config_[TEST_CONFIG_OVERRIDE].toml")
	#endif

	// Right off the bat, load up the DB
	SSdbcore.CheckSchemaVersion() // This doesnt just check the schema version, it also connects to the db! This needs to happen super early! I cannot stress this enough!
	SSdbcore.SetRoundID() // Set the round ID here
	#ifdef MULTIINSTANCE
	SSinstancing.seed_data() // Set us up in the DB
	#endif

	// Setup all log paths and stamp them with startups, including round IDs
	SetupLogs()
	load_files() // Loads up the MOTD (Welcome message players see when joining the server), TOS and gamemode

	// This needs to happen early, otherwise people can get a null species, nuking their character
	makeDatumRefLists()

	InitTGS() // creates a new TGS object
	log_world("World loaded at [time_stamp()]")
	log_world("[length(GLOB.vars) - length(GLOB.gvars_datum_in_built_vars)] global variables")
	GLOB.revision_info.log_info()
	load_admins(run_async = FALSE) // This better happen early on.

	if(TgsAvailable())
		world.log = file("[GLOB.log_directory]/dd.log") //not all runtimes trigger world/Error, so this is the only way to ensure we can see all of them.

	#ifdef TEST_RUNNER
	log_world("Test runner enabled.")
	#endif

	if(byond_version < MIN_COMPILER_VERSION || byond_build < MIN_COMPILER_BUILD)
		log_world("Your server's byond version does not meet the recommended requirements for this code. Please update BYOND")

	GLOB.timezoneOffset = world.timezone * 36000

	update_status()

	GLOB.space_manager.initialize() //Before the MC starts up

	. = ..()

	Master.Initialize(10, FALSE, TRUE)


	#ifdef TEST_RUNNER
	GLOB.test_runner = new
	GLOB.test_runner.Start()
	#endif


/world/proc/InitTGS()
	TgsNew(new /datum/tgs_event_handler/impl, TGS_SECURITY_TRUSTED) // creates a new TGS object
	GLOB.revision_info.load_tgs_info() // Loads git and TM info from TGS itself

/// List of all world topic spam prevention handlers. See code/modules/world_topic/_spam_prevention_handler.dm
GLOBAL_LIST_EMPTY(world_topic_spam_prevention_handlers)
/// List of all world topic handler datums. Populated inside makeDatumRefLists()
GLOBAL_LIST_EMPTY(world_topic_handlers)


/world/Topic(T, addr, master, key)
	TGS_TOPIC
	log_misc("WORLD/TOPIC: \"[T]\", from:[addr], master:[master], key:[key]")

	// Handle spam prevention, if their IP isnt in the whitelist
	if(!(addr in GLOB.configuration.system.topic_ip_ratelimit_bypass))
		if(!GLOB.world_topic_spam_prevention_handlers[addr])
			GLOB.world_topic_spam_prevention_handlers[addr] = new /datum/world_topic_spam_prevention_handler(addr)

		var/datum/world_topic_spam_prevention_handler/sph = GLOB.world_topic_spam_prevention_handlers[addr]

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

/world/Reboot(reason, fast_track = FALSE)
	//special reboot, do none of the normal stuff
	if((reason == 1) || fast_track) // Do NOT change this to if(reason). You WILL break the entirety of world rebooting
		if(usr)
			if(!check_rights(R_SERVER))
				message_admins("[key_name_admin(usr)] attempted to restart the server via the Profiler, without access.")
				log_admin("[key_name(usr)] attempted to restart the server via the Profiler, without access.")
				return
			message_admins("[key_name_admin(usr)] has requested an immediate world restart via client side debugging tools")
			log_admin("[key_name(usr)] has requested an immediate world restart via client side debugging tools")
			to_chat(world, "<span class='boldannounceooc'>Rebooting world immediately due to host request</span>")
		rustlibs_log_close_all() // Past this point, no logging procs can be used, at risk of data loss.
		// Now handle a reboot
		if(GLOB.configuration.system.shutdown_on_reboot)
			sleep(0)
			if(GLOB.configuration.system.shutdown_shell_command)
				shell(GLOB.configuration.system.shutdown_shell_command)
			del(world)
			TgsEndProcess() // We want to shutdown on reboot. That means kill our TGS process "gracefully", instead of the watchdog crying
			return
		else
			TgsReboot() // Tell TGS we did a reboot
			return ..(1)

	// If we got here, we are in a "normal" reboot
	Master.Shutdown() // Shutdown subsystems

	// If we were running unit tests, finish that run
	#ifdef TEST_RUNNER
	GLOB.test_runner.Finalize()
	return
	#endif

	// Send the stats URL if applicable
	if(GLOB.configuration.url.round_stats_url && GLOB.round_id)
		var/stats_link = "[GLOB.configuration.url.round_stats_url][GLOB.round_id]"
		to_chat(world, "<span class='notice'>Stats for this round can be viewed at <a href=\"[stats_link]\">[stats_link]</a></span>")

	// If the server has been gracefully shutdown in TGS, have a 60 seconds grace period for SQL updates and stuff
	if(GLOB.slower_restart)
		server_announce_global("Reboot will take a little longer due to pending backend changes.")

	// Send the reboot banner to all players
	for(var/client/C in GLOB.clients)
		C?.tgui_panel?.send_roundrestart()
		if(C.prefs.server_region)
			// Keep them on the same relay
			C << link(GLOB.configuration.system.region_map[C.prefs.server_region])
		else
			// Use the default
			if(GLOB.configuration.url.server_url) // If you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
				C << link("byond://[GLOB.configuration.url.server_url]")

	// And begin the real shutdown
	rustlibs_log_close_all() // Past this point, no logging procs can be used, at risk of data loss.
	if(GLOB.configuration.system.shutdown_on_reboot)
		sleep(0)
		if(GLOB.configuration.system.shutdown_shell_command)
			shell(GLOB.configuration.system.shutdown_shell_command)
		rustlibs_log_close_all() // Past this point, no logging procs can be used, at risk of data loss.
		del(world)
		TgsEndProcess() // We want to shutdown on reboot. That means kill our TGS process "gracefully", instead of the watchdog crying
		return
	else
		TgsReboot() // We did a normal reboot. Tell TGS we did a normal reboot.
		..(0)

/world/proc/load_mode()
	var/list/Lines = file2list("data/mode.txt")
	if(length(Lines))
		if(Lines[1])
			GLOB.master_mode = Lines[1]
			log_game("Saved mode is '[GLOB.master_mode]'")

/world/proc/save_mode(the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	F << the_mode

/world/proc/load_files()
	GLOB.join_motd = file2text("config/motd.txt")
	GLOB.join_tos = file2text("config/tos.txt")
	load_mode()

/world/proc/update_status()
	status = get_status_text()

/world/proc/get_status_text()
	var/s = ""

	if(GLOB.configuration.general.server_name)
		s += "<b>[GLOB.configuration.general.server_name]</b>] &#8212; "

		s += "<b>[station_name()]</b>"
	else // else so it neatly closes the byond hub initial square bracket even without a server name
		s += "<b>[station_name()]</b>]"

	if(GLOB.configuration.url.discord_url)
		s += " (<a href=\"[GLOB.configuration.url.discord_url]\">Discord</a>)"

	if(GLOB.configuration.general.server_tag_line)
		s += "<br>[GLOB.configuration.general.server_tag_line]"

	if(SSticker && ROUND_TIME > 0)
		s += "<br>[round(ROUND_TIME / 36000)]:[add_zero(num2text(ROUND_TIME / 600 % 60), 2)], [capitalize(SSsecurity_level.get_current_level_as_text())]"
	else
		s += "<br><b>STARTING</b>"

	s += "<br>"

	s += "\["

	var/list/features = list()

	if(!GLOB.enter_allowed)
		features += "closed"

	if(GLOB.configuration.general.server_features)
		features += GLOB.configuration.general.server_features

	if(GLOB.configuration.url.wiki_url)
		features += "<a href=\"[GLOB.configuration.url.wiki_url]\">Wiki</a>"

	if(GLOB.configuration.general.respawn_enabled)
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
	GLOB.tgui_log = "[GLOB.log_directory]/tgui.log"
	GLOB.http_log = "[GLOB.log_directory]/http.log"
	GLOB.sql_log = "[GLOB.log_directory]/sql.log"
	GLOB.chat_debug_log = "[GLOB.log_directory]/chat_debug.log"
	start_log(GLOB.world_game_log)
	start_log(GLOB.world_href_log)
	start_log(GLOB.world_runtime_log)
	start_log(GLOB.world_qdel_log)
	start_log(GLOB.tgui_log)
	start_log(GLOB.http_log)
	start_log(GLOB.sql_log)
	start_log(GLOB.chat_debug_log)

	#ifdef REFERENCE_TRACKING
	GLOB.gc_log = "[GLOB.log_directory]/gc_debug.log"
	start_log(GLOB.gc_log)
	#endif

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

/world/Del()
	rustlibs_http_shutdown_client() // Close the HTTP client. If you dont do this, youll get phantom threads which can crash DD from memory access violations
	disable_auxtools_debugger() // Disables the debugger if running. See above comment

	if(SSredis.connected)
		rustlibs_redis_disconnect() // Disconnects the redis connection. See above.

	#ifdef ENABLE_BYOND_TRACY
	CALL_EXT("prof.dll", "destroy")() // Setup Tracy integration
	#endif
	..()
