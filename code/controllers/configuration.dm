/datum/configuration
	var/server_name = null				// server name (for world name / status)
	var/server_suffix = 0				// generate numeric suffix based on server port

	var/nudge_script_path = "nudge.py"  // where the nudge.py script is located

	var/log_ooc = 0						// log OOC channel
	var/log_access = 0					// log login/logout
	var/log_say = 0						// log client say
	var/log_admin = 0					// log admin actions
	var/log_debug = 1					// log debug output
	var/log_game = 0					// log game events
	var/log_vote = 0					// log voting
	var/log_whisper = 0					// log client whisper
	var/log_emote = 0					// log emotes
	var/log_attack = 0					// log attack messages
	var/log_adminchat = 0				// log admin chat messages
	var/log_adminwarn = 0				// log warnings admins get about bomb construction and such
	var/log_pda = 0						// log pda messages
	var/log_world_output = 0			// log world.log << messages
	var/log_runtimes = 0                // logs world.log to a file
	var/log_hrefs = 0					// logs all links clicked in-game. Could be used for debugging and tracking down exploits
	var/sql_enabled = 0					// for sql switching
	var/allow_admin_ooccolor = 0		// Allows admins with relevant permissions to have their own ooc colour
	var/allow_vote_restart = 0 			// allow votes to restart
	var/allow_vote_mode = 0				// allow votes to change mode
	var/vote_delay = 6000				// minimum time between voting sessions (deciseconds, 10 minute default)
	var/vote_period = 600				// length of voting period (deciseconds, default 1 minute)
	var/vote_autotransfer_initial = 72000 // Length of time before the first autotransfer vote is called
	var/vote_autotransfer_interval = 18000 // length of time before next sequential autotransfer vote
	var/vote_no_default = 0				// vote does not default to nochange/norestart (tbi)
	var/vote_no_dead = 0				// dead people can't vote (tbi)
//	var/enable_authentication = 0		// goon authentication
	var/del_new_on_log = 1				// del's new players if they log before they spawn in
	var/feature_object_spell_system = 0 //spawns a spellbook which gives object-type spells instead of verb-type spells for the wizard
	var/traitor_scaling = 0 			//if amount of traitors scales based on amount of players
	var/protect_roles_from_antagonist = 0// If security and such can be tratior/cult/other
	var/continuous_rounds = 0			// Gamemodes which end instantly will instead keep on going until the round ends by escape shuttle or nuke.
	var/allow_Metadata = 0				// Metadata is supported.
	var/popup_admin_pm = 0				//adminPMs to non-admins show in a pop-up 'reply' window when set to 1.
	var/Ticklag = 0.9
	var/Tickcomp = 0
	var/socket_talk	= 0					// use socket_talk to communicate with other processes
	var/list/resource_urls = null
	var/antag_hud_allowed = 0      // Ghosts can turn on Antagovision to see a HUD of who is the bad guys this round.
	var/antag_hud_restricted = 0                    // Ghosts that turn on Antagovision cannot rejoin the round.
	var/list/mode_names = list()
	var/list/modes = list()				// allowed modes
	var/list/votable_modes = list()		// votable modes
	var/list/probabilities = list()		// relative probability of each mode
	var/humans_need_surnames = 0
	var/allow_random_events = 0			// enables random events mid-round when set to 1
	var/allow_ai = 1					// allow ai job
	var/hostedby = null
	var/respawn = 0
	var/guest_jobban = 1
	var/usewhitelist = 0
	var/mods_are_mentors = 0
	var/kick_inactive = 0				//force disconnect for inactive players
	var/load_jobs_from_txt = 0
	var/ToRban = 0
	var/automute_on = 0					//enables automuting/spam prevention
	var/jobs_have_minimal_access = 0	//determines whether jobs use minimal access or expanded access.
	var/round_abandon_penalty_period = 30 MINUTES // Time from round start during which ghosting out is penalized

	var/reactionary_explosions = 0 //If we use reactionary explosions, explosions that react to walls and doors

	var/assistantlimit = 0 //enables assistant limiting
	var/assistantratio = 2 //how many assistants to security members

	var/traitor_objectives_amount = 2

	var/max_maint_drones = 5				//This many drones can spawn,
	var/allow_drone_spawn = 1				//assuming the admin allow them to.
	var/drone_build_time = 1200				//A drone will become available every X ticks since last drone spawn. Default is 2 minutes.

	var/usealienwhitelist = 0
	var/limitalienplayers = 0
	var/alien_to_human_ratio = 0.5

	var/server
	var/banappeals
	var/wikiurl = "http://example.org"
	var/forumurl = "http://example.org"
	var/rulesurl = "http://example.org"
	var/donationsurl = "http://example.org"
	var/repositoryurl = "http://example.org"

	var/overflow_server_url
	var/forbid_singulo_possession = 0

	//game_options.txt configs

	var/health_threshold_softcrit = 0
	var/health_threshold_crit = 0
	var/health_threshold_dead = -100

	var/organ_health_multiplier = 1
	var/organ_regeneration_multiplier = 1

	var/bones_can_break = 1
	var/limbs_can_break = 1

	var/revival_pod_plants = 1
	var/revival_cloning = 1
	var/revival_brain_life = -1

	var/auto_toggle_ooc_during_round = 0

	var/shuttle_refuel_delay = 12000

	//Used for modifying movement speed for mobs.
	//Unversal modifiers
	var/run_speed = 0
	var/walk_speed = 0

	//Mob specific modifiers. NOTE: These will affect different mob types in different ways
	var/human_delay = 0
	var/robot_delay = 0
	var/monkey_delay = 0
	var/alien_delay = 0
	var/slime_delay = 0
	var/animal_delay = 0

	var/admin_legacy_system = 0	//Defines whether the server uses the legacy admin system with admins.txt or the SQL system. Config option in config.txt
	var/ban_legacy_system = 0	//Defines whether the server uses the legacy banning system with the files in /data or the SQL system. Config option in config.txt
	var/use_age_restriction_for_jobs = 0 //Do jobs use account age restrictions? --requires database
	var/use_age_restriction_for_antags = 0 //Do antags use account age restrictions? --requires database

	var/simultaneous_pm_warning_timeout = 100

	var/assistant_maint = 0 //Do assistants get maint access?
	var/gateway_delay = 6000 //How long the gateway takes before it activates. Default is half an hour.
	var/ghost_interaction = 0

	var/comms_password = ""

	var/use_irc_bot = 0
	var/list/irc_bot_host = list()
	var/main_irc = ""
	var/admin_irc = ""
	var/python_path = "" //Path to the python executable.  Defaults to "python" on windows and "/usr/bin/env python2" on unix

	var/default_laws = 0 //Controls what laws the AI spawns with.

	var/list/station_levels = list(1)				// Defines which Z-levels the station exists on.
	var/list/admin_levels= list(2)					// Defines which Z-levels which are for admin functionality, for example including such areas as Central Command and the Syndicate Shuttle
	var/list/contact_levels = list(1, 5)			// Defines which Z-levels which, for example, a Code Red announcement may affect
	var/list/player_levels = list(1, 3, 4, 5, 6, 7)	// Defines all Z-levels a character can typically reach

	var/const/minutes_to_ticks = 60 * 10
	// Event settings
	var/expected_round_length = 60 * 2 * minutes_to_ticks // 2 hours
	// If the first delay has a custom start time
	// No custom time, no custom time, between 80 to 100 minutes respectively.
	var/list/event_first_run   = list(EVENT_LEVEL_MUNDANE = null, 	EVENT_LEVEL_MODERATE = null,	EVENT_LEVEL_MAJOR = list("lower" = 48000, "upper" = 60000))
	// The lowest delay until next event
	// 10, 30, 50 minutes respectively
	var/list/event_delay_lower = list(EVENT_LEVEL_MUNDANE = 6000,	EVENT_LEVEL_MODERATE = 18000,	EVENT_LEVEL_MAJOR = 30000)
	// The upper delay until next event
	// 15, 45, 70 minutes respectively
	var/list/event_delay_upper = list(EVENT_LEVEL_MUNDANE = 9000,	EVENT_LEVEL_MODERATE = 27000,	EVENT_LEVEL_MAJOR = 42000)

	var/starlight = 0	// Whether space turfs have ambient light or not
	var/allow_holidays = 0
	var/player_overflow_cap = 0 //number of players before the server starts rerouting
	var/list/overflow_whitelist = list() //whitelist for overflow

	var/disable_away_missions = 0 // disable away missions
	var/disable_space_ruins = 0 //disable space ruins

	var/ooc_allowed = 1
	var/looc_allowed = 1
	var/dooc_allowed = 1
	var/dsay_allowed = 1

	var/disable_lobby_music = 0 // Disables the lobby music
	var/disable_cid_warn_popup = 0 //disables the annoying "You have already logged in this round, disconnect or be banned" popup, because it annoys the shit out of me when testing.

	var/max_loadout_points = 5 // How many points can be spent on extra items in character setup

/datum/configuration/New()
	var/list/L = subtypesof(/datum/game_mode)
	for(var/T in L)
		// I wish I didn't have to instance the game modes in order to look up
		// their information, but it is the only way (at least that I know of).
		var/datum/game_mode/M = new T()

		if(M.config_tag)
			if(!(M.config_tag in modes))		// ensure each mode is added only once
				diary << "Adding game mode [M.name] ([M.config_tag]) to configuration."
				src.modes += M.config_tag
				src.mode_names[M.config_tag] = M.name
				src.probabilities[M.config_tag] = M.probability
				if(M.votable)
					src.votable_modes += M.config_tag
		qdel(M)
	src.votable_modes += "secret"

/datum/configuration/proc/load(filename, type = "config") //the type can also be game_options, in which case it uses a different switch. not making it separate to not copypaste code - Urist
	var/list/Lines = file2list(filename)

	for(var/t in Lines)
		if(!t)	continue

		t = trim(t)
		if(length(t) == 0)
			continue
		else if(copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if(pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if(!name)
			continue

		if(type == "config")
			switch(name)
				if("resource_urls")
					config.resource_urls = splittext(value, " ")

				if("admin_legacy_system")
					config.admin_legacy_system = 1

				if("ban_legacy_system")
					config.ban_legacy_system = 1

				if("use_age_restriction_for_jobs")
					config.use_age_restriction_for_jobs = 1

				if("use_age_restriction_for_antags")
					config.use_age_restriction_for_antags = 1

				if("jobs_have_minimal_access")
					config.jobs_have_minimal_access = 1

				if("log_ooc")
					config.log_ooc = 1

				if("log_access")
					config.log_access = 1

				if("log_say")
					config.log_say = 1

				if("log_admin")
					config.log_admin = 1

				if("log_debug")
					config.log_debug = text2num(value)

				if("log_game")
					config.log_game = 1

				if("log_vote")
					config.log_vote = 1

				if("log_whisper")
					config.log_whisper = 1

				if("log_attack")
					config.log_attack = 1

				if("log_emote")
					config.log_emote = 1

				if("log_adminchat")
					config.log_adminchat = 1

				if("log_adminwarn")
					config.log_adminwarn = 1

				if("log_pda")
					config.log_pda = 1

				if("log_world_output")
					config.log_world_output = 1

				if("log_hrefs")
					config.log_hrefs = 1

				if("log_runtime")
					config.log_runtimes = 1

				if("mentors")
					config.mods_are_mentors = 1

				if("allow_admin_ooccolor")
					config.allow_admin_ooccolor = 1

				if("allow_vote_restart")
					config.allow_vote_restart = 1

				if("allow_vote_mode")
					config.allow_vote_mode = 1

				if("no_dead_vote")
					config.vote_no_dead = 1

				if("default_no_vote")
					config.vote_no_default = 1

				if("vote_delay")
					config.vote_delay = text2num(value)

				if("vote_period")
					config.vote_period = text2num(value)

				if("allow_ai")
					config.allow_ai = 1

//				if("authentication")
//					config.enable_authentication = 1

				if("norespawn")
					config.respawn = 0

				if("servername")
					config.server_name = value

				if("serversuffix")
					config.server_suffix = 1

				if("nudge_script_path")
					config.nudge_script_path = value

				if("hostedby")
					config.hostedby = value

				if("server")
					config.server = value

				if("banappeals")
					config.banappeals = value

				if("wikiurl")
					config.wikiurl = value

				if("forumurl")
					config.forumurl = value

				if("rulesurl")
					config.rulesurl = value

				if("donationsurl")
					config.donationsurl = value

				if("repositoryurl")
					config.repositoryurl = value

				if("guest_jobban")
					config.guest_jobban = 1

				if("guest_ban")
					guests_allowed = 0

				if("usewhitelist")
					config.usewhitelist = 1

				if("feature_object_spell_system")
					config.feature_object_spell_system = 1

				if("allow_metadata")
					config.allow_Metadata = 1

				if("traitor_scaling")
					config.traitor_scaling = 1

				if("protect_roles_from_antagonist")
					config.protect_roles_from_antagonist = 1

				if("probability")
					var/prob_pos = findtext(value, " ")
					var/prob_name = null
					var/prob_value = null

					if(prob_pos)
						prob_name = lowertext(copytext(value, 1, prob_pos))
						prob_value = copytext(value, prob_pos + 1)
						if(prob_name in config.modes)
							config.probabilities[prob_name] = text2num(prob_value)
						else
							diary << "Unknown game mode probability configuration definition: [prob_name]."
					else
						diary << "Incorrect probability configuration definition: [prob_name]  [prob_value]."

				if("allow_random_events")
					config.allow_random_events = 1

				if("kick_inactive")
					config.kick_inactive = 1

				if("load_jobs_from_txt")
					load_jobs_from_txt = 1

				if("forbid_singulo_possession")
					forbid_singulo_possession = 1

				if("popup_admin_pm")
					config.popup_admin_pm = 1

				if("allow_holidays")
					config.allow_holidays = 1

				if("use_irc_bot")
					use_irc_bot = 1

				if("ticklag")
					Ticklag = text2num(value)

				if("socket_talk")
					socket_talk = text2num(value)

				if("tickcomp")
					Tickcomp = 1

				if("allow_antag_hud")
					config.antag_hud_allowed = 1

				if("antag_hud_restricted")
					config.antag_hud_restricted = 1

				if("humans_need_surnames")
					humans_need_surnames = 1

				if("tor_ban")
					ToRban = 1

				if("automute_on")
					automute_on = 1

				if("usealienwhitelist")
					usealienwhitelist = 1

				if("alien_player_ratio")
					limitalienplayers = 1
					alien_to_human_ratio = text2num(value)

				if("assistant_maint")
					config.assistant_maint = 1

				if("gateway_delay")
					config.gateway_delay = text2num(value)

				if("continuous_rounds")
					config.continuous_rounds = 1

				if("ghost_interaction")
					config.ghost_interaction = 1

				if("comms_password")
					config.comms_password = value

				if("irc_bot_host")
					config.irc_bot_host = splittext(value, ";")

				if("main_irc")
					config.main_irc = value

				if("admin_irc")
					config.admin_irc = value

				if("python_path")
					if(value)
						config.python_path = value
					else
						if(world.system_type == UNIX)
							config.python_path = "/usr/bin/env python2"
						else //probably windows, if not this should work anyway
							config.python_path = "pythonw"

				if("assistant_limit")
					config.assistantlimit = 1

				if("assistant_ratio")
					config.assistantratio = text2num(value)

				if("allow_drone_spawn")
					config.allow_drone_spawn = text2num(value)

				if("drone_build_time")
					config.drone_build_time = text2num(value)

				if("max_maint_drones")
					config.max_maint_drones = text2num(value)

				if("expected_round_length")
					config.expected_round_length = MinutesToTicks(text2num(value))

				if("event_custom_start_mundane")
					var/values = text2numlist(value, ";")
					config.event_first_run[EVENT_LEVEL_MUNDANE] = list("lower" = MinutesToTicks(values[1]), "upper" = MinutesToTicks(values[2]))

				if("event_custom_start_moderate")
					var/values = text2numlist(value, ";")
					config.event_first_run[EVENT_LEVEL_MODERATE] = list("lower" = MinutesToTicks(values[1]), "upper" = MinutesToTicks(values[2]))

				if("event_custom_start_major")
					var/values = text2numlist(value, ";")
					config.event_first_run[EVENT_LEVEL_MAJOR] = list("lower" = MinutesToTicks(values[1]), "upper" = MinutesToTicks(values[2]))

				if("event_delay_lower")
					var/values = text2numlist(value, ";")
					config.event_delay_lower[EVENT_LEVEL_MUNDANE] = MinutesToTicks(values[1])
					config.event_delay_lower[EVENT_LEVEL_MODERATE] = MinutesToTicks(values[2])
					config.event_delay_lower[EVENT_LEVEL_MAJOR] = MinutesToTicks(values[3])

				if("event_delay_upper")
					var/values = text2numlist(value, ";")
					config.event_delay_upper[EVENT_LEVEL_MUNDANE] = MinutesToTicks(values[1])
					config.event_delay_upper[EVENT_LEVEL_MODERATE] = MinutesToTicks(values[2])
					config.event_delay_upper[EVENT_LEVEL_MAJOR] = MinutesToTicks(values[3])

				if("starlight")
					var/vvalue = text2num(value)
					config.starlight = vvalue >= 0 ? vvalue : 0

				if("player_reroute_cap")
					var/vvalue = text2num(value)
					config.player_overflow_cap = vvalue >= 0 ? vvalue : 0

				if("overflow_server_url")
					config.overflow_server_url = value

				if("disable_away_missions")
					config.disable_away_missions = 1

				if("disable_space_ruins")
					config.disable_space_ruins = 1

				if("disable_lobby_music")
					config.disable_lobby_music = 1

				if("disable_cid_warn_popup")
					config.disable_cid_warn_popup = 1

				if("max_loadout_points")
					config.max_loadout_points = text2num(value)

				if("round_abandon_penalty_period")
					config.round_abandon_penalty_period = MinutesToTicks(text2num(value))

				else
					diary << "Unknown setting in configuration: '[name]'"


		else if(type == "game_options")
			if(!value)
				diary << "Unknown value for setting [name] in [filename]."
			value = text2num(value)

			switch(name)
				if("health_threshold_crit")
					config.health_threshold_crit = value
				if("health_threshold_dead")
					config.health_threshold_dead = value
				if("revival_pod_plants")
					config.revival_pod_plants = value
				if("revival_cloning")
					config.revival_cloning = value
				if("revival_brain_life")
					config.revival_brain_life = value
				if("auto_toggle_ooc_during_round")
					config.auto_toggle_ooc_during_round	= 1
				if("run_speed")
					config.run_speed = value
				if("walk_speed")
					config.walk_speed = value
				if("human_delay")
					config.human_delay = value
				if("robot_delay")
					config.robot_delay = value
				if("monkey_delay")
					config.monkey_delay = value
				if("alien_delay")
					config.alien_delay = value
				if("slime_delay")
					config.slime_delay = value
				if("animal_delay")
					config.animal_delay = value
				if("organ_health_multiplier")
					config.organ_health_multiplier = value / 100
				if("organ_regeneration_multiplier")
					config.organ_regeneration_multiplier = value / 100
				if("bones_can_break")
					config.bones_can_break = value
				if("limbs_can_break")
					config.limbs_can_break = value
				if("shuttle_refuel_delay")
					config.shuttle_refuel_delay     = text2num(value)
				if("traitor_objectives_amount")
					config.traitor_objectives_amount = text2num(value)
				if("reactionary_explosions")
					config.reactionary_explosions	= 1
				if("bombcap")
					var/BombCap = text2num(value)
					if(!BombCap)
						continue
					if(BombCap < 4)
						BombCap = 4
					if(BombCap > 128)
						BombCap = 128

					MAX_EX_DEVESTATION_RANGE = round(BombCap/4)
					MAX_EX_HEAVY_RANGE = round(BombCap/2)
					MAX_EX_LIGHT_RANGE = BombCap
					MAX_EX_FLASH_RANGE = BombCap
					MAX_EX_FLAME_RANGE = BombCap
				if("default_laws")
					config.default_laws = text2num(value)
				else
					diary << "Unknown setting in configuration: '[name]'"

/datum/configuration/proc/loadsql(filename)  // -- TLE
	var/list/Lines = file2list(filename)
	for(var/t in Lines)
		if(!t)	continue

		t = trim(t)
		if(length(t) == 0)
			continue
		else if(copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if(pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if(!name)
			continue

		switch(name)
			if("sql_enabled")
				config.sql_enabled = 1
			if("address")
				sqladdress = value
			if("port")
				sqlport = value
			if("feedback_database")
				sqlfdbkdb = value
			if("feedback_login")
				sqlfdbklogin = value
			if("feedback_password")
				sqlfdbkpass = value
			if("feedback_tableprefix")
				sqlfdbktableprefix = value
			else
				diary << "Unknown setting in configuration: '[name]'"

/datum/configuration/proc/loadoverflowwhitelist(filename)
	var/list/Lines = file2list(filename)
	for(var/t in Lines)
		if(!t)	continue

		t = trim(t)
		if(length(t) == 0)
			continue
		else if(copytext(t, 1, 2) == "#")
			continue

		config.overflow_whitelist += t

/datum/configuration/proc/pick_mode(mode_name)
	// I wish I didn't have to instance the game modes in order to look up
	// their information, but it is the only way (at least that I know of).
	for(var/T in subtypesof(/datum/game_mode))
		var/datum/game_mode/M = new T()
		if(M.config_tag && M.config_tag == mode_name)
			return M
		qdel(M)
	return new /datum/game_mode/extended()

/datum/configuration/proc/get_runnable_modes()
	var/list/datum/game_mode/runnable_modes = new
	for(var/T in subtypesof(/datum/game_mode))
		var/datum/game_mode/M = new T()
//		to_chat(world, "DEBUG: [T], tag=[M.config_tag], prob=[probabilities[M.config_tag]]")
		if(!(M.config_tag in modes))
			qdel(M)
			continue
		if(probabilities[M.config_tag]<=0)
			qdel(M)
			continue
		if(M.can_start())
			runnable_modes[M] = probabilities[M.config_tag]
//			to_chat(world, "DEBUG: runnable_mode\[[runnable_modes.len]\] = [M.config_tag]")
	return runnable_modes
