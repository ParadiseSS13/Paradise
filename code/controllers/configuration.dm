/datum/configuration
	var/server_name = null				// server name (for world name / status)
	var/server_tag_line = null			// server tagline (for showing on hub entry)
	var/server_extra_features = null		// server-specific extra features (for hub entry)
	var/server_suffix = 0				// generate numeric suffix based on server port

	var/minimum_client_build = 1421		// Build 1421 due to the middle mouse button exploit

	var/pregame_timestart = 240			// Time it takes for the server to start the game

//	var/enable_authentication = 0		// goon authentication
	var/allow_Metadata = 0				// Metadata is supported.
	var/popup_admin_pm = 0				//adminPMs to non-admins show in a pop-up 'reply' window when set to 1.
	var/antag_hud_allowed = 0      // Ghosts can turn on Antagovision to see a HUD of who is the bad guys this round.
	var/antag_hud_restricted = 0                    // Ghosts that turn on Antagovision cannot rejoin the round.

	var/respawn = 0
	var/guest_jobban = 1
	var/panic_bunker_threshold = 150	// above this player count threshold, never-before-seen players are blocked from connecting
	var/usewhitelist = 0
	var/automute_on = 0					//enables automuting/spam prevention
	var/round_abandon_penalty_period = 30 MINUTES // Time from round start during which ghosting out is penalized

	var/reactionary_explosions = 0 //If we use reactionary explosions, explosions that react to walls and doors

	var/ssd_warning = 0

	var/list_afk_minimum = 5 // How long people have to be AFK before it's listed on the "List AFK players" verb

	var/max_maint_drones = 5				//This many drones can spawn,
	var/allow_drone_spawn = 1				//assuming the admin allow them to.
	var/drone_build_time = 1200				//A drone will become available every X ticks since last drone spawn. Default is 2 minutes.

	var/forbid_singulo_possession = 0

	var/check_randomizer = 0

	//game_options.txt configs

	var/bones_can_break = 1

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

	//IP Intel vars
	var/ipintel_email
	var/ipintel_rating_bad = 1
	var/ipintel_save_good = 12
	var/ipintel_save_bad = 1
	var/ipintel_domain = "check.getipintel.net"
	var/ipintel_maxplaytime = 0
	var/ipintel_whitelist = 0
	var/ipintel_detailsurl = "https://iphub.info/?ip="

	var/ban_legacy_system = 0	//Defines whether the server uses the legacy banning system with the files in /data or the SQL system. Config option in config.txt

	var/simultaneous_pm_warning_timeout = 100

	var/ghost_interaction = 0


	var/default_laws = 0 //Controls what laws the AI spawns with.

	var/starlight = 0	// Whether space turfs have ambient light or not
	var/allow_holidays = 0

	var/ooc_allowed = 1
	var/looc_allowed = 1
	var/dooc_allowed = 1
	var/dsay_allowed = 1

	var/disable_lobby_music = 0 // Disables the lobby music
	var/disable_cid_warn_popup = 0 //disables the annoying "You have already logged in this round, disconnect or be banned" popup, because it annoys the shit out of me when testing.

	var/max_loadout_points = 5 // How many points can be spent on extra items in character setup

	var/disable_ooc_emoji = 0 // prevents people from using emoji in OOC

	var/disable_karma = 0 // Disable all karma functions and unlock karma jobs by default

	// Nightshift
	var/randomize_shift_time = FALSE
	var/enable_night_shifts = FALSE

	// Developer
	var/developer_express_start = 0

	//Start now warning
	var/start_now_confirmation = 0

	//cube monkey limit
	var/cubemonkeycap = 20

	/// BYOND account age limit for notifcations of new accounts (Any accounts older than this value will not send notifications on first join)
	var/byond_account_age_threshold = 7


	/// Max amount of CIDs that one ckey can have attached to them before they trip a warning
	var/max_client_cid_history = 3

	/// Enable auto profiler of rounds
	var/auto_profile = FALSE

/datum/configuration/proc/load(filename, type = "config") //the type can also be game_options, in which case it uses a different switch. not making it separate to not copypaste code - Urist
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='boldannounce'>Config reload blocked: Advanced ProcCall detected.</span>")
		message_admins("[key_name(usr)] attempted to reload configuration via advanced proc-call")
		log_admin("[key_name(usr)] attempted to reload configuration via advanced proc-call")
		return
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
				if("ban_legacy_system")
					config.ban_legacy_system = 1

				if("ssd_warning")
					config.ssd_warning = 1

				if("list_afk_minimum")
					config.list_afk_minimum = text2num(value)

				if("ipintel_email")
					if(value != "ch@nge.me")
						config.ipintel_email = value
				if("ipintel_rating_bad")
					config.ipintel_rating_bad = text2num(value)
				if("ipintel_domain")
					config.ipintel_domain = value
				if("ipintel_save_good")
					config.ipintel_save_good = text2num(value)
				if("ipintel_save_bad")
					config.ipintel_save_bad = text2num(value)
				if("ipintel_maxplaytime")
					config.ipintel_maxplaytime = text2num(value)
				if("ipintel_whitelist")
					config.ipintel_whitelist = 1
				if("ipintel_detailsurl")
					config.ipintel_detailsurl = value

				if("pregame_timestart")
					config.pregame_timestart = text2num(value)

				if("norespawn")
					config.respawn = 0

				if("servername")
					config.server_name = value

				if("server_tag_line")
					config.server_tag_line = value

				if("server_extra_features")
					config.server_extra_features = value

				if("serversuffix")
					config.server_suffix = 1

				if("minimum_client_build")
					config.minimum_client_build = text2num(value)

				if("guest_ban")
					#warn AA clear this up
					GLOB.guests_allowed = 0

				if("panic_bunker_threshold")
					config.panic_bunker_threshold = text2num(value)

				if("usewhitelist")
					config.usewhitelist = 1

				if("allow_metadata")
					config.allow_Metadata = 1

				if("forbid_singulo_possession")
					forbid_singulo_possession = 1

				if("check_randomizer")
					check_randomizer = 1

				if("popup_admin_pm")
					config.popup_admin_pm = 1

				if("allow_holidays")
					config.allow_holidays = 1

				if("allow_antag_hud")
					config.antag_hud_allowed = 1

				if("antag_hud_restricted")
					config.antag_hud_restricted = 1

				if("automute_on")
					automute_on = 1

				if("ghost_interaction")
					config.ghost_interaction = 1

				if("allow_drone_spawn")
					config.allow_drone_spawn = text2num(value)

				if("drone_build_time")
					config.drone_build_time = text2num(value)

				if("max_maint_drones")
					config.max_maint_drones = text2num(value)

				if("starlight")
					config.starlight = 1

				if("disable_lobby_music")
					config.disable_lobby_music = 1

				if("disable_cid_warn_popup")
					config.disable_cid_warn_popup = 1

				if("max_loadout_points")
					config.max_loadout_points = text2num(value)

				if("round_abandon_penalty_period")
					config.round_abandon_penalty_period = text2num(value) MINUTES

				if("disable_ooc_emoji")
					config.disable_ooc_emoji = 1

				if("disable_karma")
					config.disable_karma = 1

				if("start_now_confirmation")
					config.start_now_confirmation = 1

				if("developer_express_start")
					config.developer_express_start = 1
				if("byond_account_age_threshold")
					config.byond_account_age_threshold = text2num(value)

				if("max_client_cid_history")
					max_client_cid_history = text2num(value)
				if("enable_auto_profiler")
					auto_profile = TRUE
				else
					log_config("Unknown setting in configuration: '[name]'")


		else if(type == "game_options")
			value = text2num(value)

			switch(name)
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
				if("bones_can_break")
					config.bones_can_break = value
				if("shuttle_refuel_delay")
					config.shuttle_refuel_delay     = text2num(value)
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

					#warn AA clear this up
					GLOB.max_ex_devastation_range = round(BombCap/4)
					GLOB.max_ex_heavy_range = round(BombCap/2)
					GLOB.max_ex_light_range = BombCap
					GLOB.max_ex_flash_range = BombCap
					GLOB.max_ex_flame_range = BombCap
				if("default_laws")
					config.default_laws = text2num(value)
				if("randomize_shift_time")
					config.randomize_shift_time = TRUE
				if("enable_night_shifts")
					config.enable_night_shifts = TRUE
				if("cubemonkey_cap")
					config.cubemonkeycap = text2num(value)
				else
					log_config("Unknown setting in configuration: '[name]'")

