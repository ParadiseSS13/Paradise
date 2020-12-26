SUBSYSTEM_DEF(ticker)
	name = "Ticker"
	init_order = INIT_ORDER_TICKER

	priority = FIRE_PRIORITY_TICKER
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME
	offline_implications = "The game is no longer aware of when the round ends. Immediate server restart recommended."

	/// Time the world started, relative to world.time
	var/round_start_time = 0
	/// Default timeout for if world.Reboot() doesnt have a time specified
	var/const/restart_timeout = 600
	/// Current status of the game. See code\__DEFINES\game.dm
	var/current_state = GAME_STATE_STARTUP
	/// Do we want to force-start as soon as we can
	var/force_start = FALSE
	/// Do we want to force-end as soon as we can
	var/force_ending = FALSE
	/// Leave here at FALSE ! setup() will take care of it when needed for Secret mode -walter0o
	var/hide_mode = FALSE
	/// Our current game mode
	var/datum/game_mode/mode = null
	/// The current pick of lobby music played in the lobby
	var/login_music
	/// List of all minds in the game. Used for objective tracking
	var/list/datum/mind/minds = list()
	/// icon_state the chaplain has chosen for his bible
	var/Bible_icon_state
	/// item_state the chaplain has chosen for his bible
	var/Bible_item_state
	/// Name of the bible
	var/Bible_name
	/// Name of the bible deity
	var/Bible_deity_name
	/// Cult data. Here instead of cult for adminbus purposes
	var/datum/cult_info/cultdat = null
	/// If set to nonzero, ALL players who latejoin or declare-ready join will have random appearances/genders
	var/random_players = FALSE
	/// Did we broadcast the tip of the round yet?
	var/tipped = FALSE
	/// What will be the tip of the round?
	var/selected_tip
	/// This is used for calculations for the statpanel
	var/pregame_timeleft
	/// If set to TRUE, the round will not restart on it's own
	var/delay_end = FALSE
	/// Global holder for triple AI mode
	var/triai = FALSE
	/// Holder for inital autotransfer vote timer
	var/next_autotransfer = 0
	/// Used for station explosion cinematic
	var/obj/screen/cinematic = null
	/// Spam Prevention. Announce round end only once.
	var/round_end_announced = FALSE
	/// Is the ticker currently processing? If FALSE, roundstart is delayed
	var/ticker_going = TRUE
	/// Gamemode result (For things like shadowlings or nukies which can end multiple ways)
	var/mode_result = "undefined"
	/// Server end state (Did we end properly or reboot or nuke or what)
	var/end_state = "undefined"

/datum/controller/subsystem/ticker/Initialize()
	login_music = pick(\
	'sound/music/thunderdome.ogg',\
	'sound/music/space.ogg',\
	'sound/music/title1.ogg',\
	'sound/music/title2.ogg',\
	'sound/music/title3.ogg',)

	return ..()


/datum/controller/subsystem/ticker/fire()
	switch(current_state)
		if(GAME_STATE_STARTUP)
			// This is ran as soon as the MC starts firing, and should only run ONCE, unless startup fails
			round_start_time = world.time + (config.pregame_timestart * 10)
			to_chat(world, "<B><span class='darkmblue'>Welcome to the pre-game lobby!</span></B>")
			to_chat(world, "Please, setup your character and select ready. Game will start in [config.pregame_timestart] seconds")
			current_state = GAME_STATE_PREGAME
			fire() // TG says this is a good idea
			for(var/mob/new_player/N in GLOB.player_list)
				N.new_player_panel_proc() // to enable the observe option
		if(GAME_STATE_PREGAME)
			if(!SSticker.ticker_going) // This has to be referenced like this, and I dont know why. If you dont put SSticker. it will break
				return

			// This is so we dont have sleeps in controllers, because that is a bad, bad thing
			if(!delay_end)
				pregame_timeleft = max(0, round_start_time - world.time) // Normal lobby countdown when roundstart was not delayed
			else
				pregame_timeleft = max(0, pregame_timeleft - 20) // If roundstart was delayed, we should resume the countdown where it left off

			if(pregame_timeleft <= 600 && !tipped) // 60 seconds
				send_tip_of_the_round()
				tipped = TRUE

			if(pregame_timeleft <= 0 || force_start)
				current_state = GAME_STATE_SETTING_UP
				Master.SetRunLevel(RUNLEVEL_SETUP)
		if(GAME_STATE_SETTING_UP)
			if(!setup()) // Setup failed
				current_state = GAME_STATE_STARTUP
				Master.SetRunLevel(RUNLEVEL_LOBBY)
		if(GAME_STATE_PLAYING)
			delay_end = FALSE // reset this in case round start was delayed
			mode.process()
			mode.process_job_tasks()

			if(world.time > next_autotransfer)
				SSvote.autotransfer()
				next_autotransfer = world.time + config.vote_autotransfer_interval

			var/game_finished = SSshuttle.emergency.mode >= SHUTTLE_ENDGAME || mode.station_was_nuked
			if(config.continuous_rounds)
				mode.check_finished() // some modes contain var-changing code in here, so call even if we don't uses result
			else
				game_finished |= mode.check_finished()
			if(game_finished || force_ending)
				current_state = GAME_STATE_FINISHED
		if(GAME_STATE_FINISHED)
			current_state = GAME_STATE_FINISHED
			Master.SetRunLevel(RUNLEVEL_POSTGAME) // This shouldnt process more than once, but you never know
			auto_toggle_ooc(TRUE) // Turn it on

			declare_completion()

			spawn(50)
				if(mode.station_was_nuked)
					world.Reboot("Station destroyed by Nuclear Device.", "nuke")
				else
					world.Reboot("Round ended.", "proper completion")

/datum/controller/subsystem/ticker/proc/setup()
	cultdat = setupcult()

	// Create and announce mode
	if(GLOB.master_mode == "secret")
		hide_mode = TRUE

	var/list/datum/game_mode/runnable_modes

	if(GLOB.master_mode == "random" || GLOB.master_mode == "secret")
		runnable_modes = config.get_runnable_modes()
		if(!length(runnable_modes))
			to_chat(world, "<B>Unable to choose playable game mode.</B> Reverting to pre-game lobby.")
			force_start = FALSE
			current_state = GAME_STATE_PREGAME
			Master.SetRunLevel(RUNLEVEL_LOBBY)
			return FALSE
		if(GLOB.secret_force_mode != "secret")
			var/datum/game_mode/M = config.pick_mode(GLOB.secret_force_mode)
			if(M.can_start())
				mode = config.pick_mode(GLOB.secret_force_mode)
		SSjobs.ResetOccupations()
		if(!mode)
			mode = pickweight(runnable_modes)
		if(mode)
			var/mtype = mode.type
			mode = new mtype
	else
		mode = config.pick_mode(GLOB.master_mode)

	if(!mode.can_start())
		to_chat(world, "<B>Unable to start [mode.name].</B> Not enough players, [mode.required_players] players needed. Reverting to pre-game lobby.")
		mode = null
		current_state = GAME_STATE_PREGAME
		force_start = FALSE
		SSjobs.ResetOccupations()
		Master.SetRunLevel(RUNLEVEL_LOBBY)
		return FALSE

	//Configure mode and assign player to special mode stuff
	mode.pre_pre_setup()
	var/can_continue
	can_continue = mode.pre_setup() //Setup special modes
	SSjobs.DivideOccupations() //Distribute jobs
	if(!can_continue)
		qdel(mode)
		to_chat(world, "<B>Error setting up [GLOB.master_mode].</B> Reverting to pre-game lobby.")
		current_state = GAME_STATE_PREGAME
		force_start = FALSE
		SSjobs.ResetOccupations()
		Master.SetRunLevel(RUNLEVEL_LOBBY)
		return FALSE

	if(hide_mode)
		var/list/modes = new
		for(var/datum/game_mode/M in runnable_modes)
			modes += M.name
		modes = sortList(modes)
		to_chat(world, "<B>The current game mode is - Secret!</B>")
		to_chat(world, "<B>Possibilities:</B> [english_list(modes)]")
	else
		mode.announce()

	// Behold, a rough way of figuring out what takes 10 years
	var/watch = start_watch()
	create_characters() // Create player characters and transfer clients
	log_debug("Creating characters took [stop_watch(watch)]s")

	watch = start_watch()
	populate_spawn_points() // Put mobs in their spawn locations
	log_debug("Populating spawn points took [stop_watch(watch)]s")

	// Gather everyones minds
	for(var/mob/living/player in GLOB.player_list)
		if(player.mind)
			minds += player.mind

	watch = start_watch()
	equip_characters() // Apply outfits and loadouts to the characters
	log_debug("Equipping characters took [stop_watch(watch)]s")

	watch = start_watch()
	GLOB.data_core.manifest() // Create the manifest
	log_debug("Manifest creation took [stop_watch(watch)]s")

	// Update the MC and state to game playing
	current_state = GAME_STATE_PLAYING
	Master.SetRunLevel(RUNLEVEL_GAME)

	// Generate the list of empty playable AI cores in the world
	for(var/obj/effect/landmark/start/S in GLOB.landmarks_list)
		if(S.name != "AI")
			continue
		if(locate(/mob/living) in S.loc)
			continue
		GLOB.empty_playable_ai_cores += new /obj/structure/AIcore/deactivated(get_turf(S))


	// Setup pregenerated newsfeeds
	setup_news_feeds()

	// Generate code phrases and responses
	if(!GLOB.syndicate_code_phrase)
		GLOB.syndicate_code_phrase = generate_code_phrase()
	if(!GLOB.syndicate_code_response)
		GLOB.syndicate_code_response = generate_code_phrase()

	// Run post setup stuff
	mode.post_setup()

	// Delete starting landmarks (not AI ones because we need those for AI-ize)
	for(var/obj/effect/landmark/start/S in GLOB.landmarks_list)
		if(S.name != "AI")
			qdel(S)

	SSdbcore.SetRoundStart()
	to_chat(world, "<span class='darkmblue'><B>Enjoy the game!</B></span>")
	world << sound('sound/AI/welcome.ogg')

	if(SSholiday.holidays)
		to_chat(world, "<span class='darkmblue'>and...</span>")
		for(var/holidayname in SSholiday.holidays)
			var/datum/holiday/holiday = SSholiday.holidays[holidayname]
			to_chat(world, "<h4>[holiday.greet()]</h4>")
	
	SSdiscord.send2discord_simple("**\[Info]** Round has started") //El _noadmins al final de SSdiscord.send2discord_simple hacia que mencione a los admins cada vez que comenzaba una ronda, lo cual era innecesario
	auto_toggle_ooc(FALSE) // Turn it off
	round_start_time = world.time

	// Sets the auto shuttle vote to happen after the config duration
	next_autotransfer = world.time + config.vote_autotransfer_initial

	for(var/mob/new_player/N in GLOB.mob_list)
		if(N.client)
			N.new_player_panel_proc()

	// Now that every other piece of the round has initialized, lets setup player job scaling
	var/playercount = length(GLOB.clients)
	var/highpop_trigger = 80

	if(playercount >= highpop_trigger)
		log_debug("Playercount: [playercount] versus trigger: [highpop_trigger] - loading highpop job config")
		SSjobs.LoadJobs("config/jobs_highpop.txt")
	else
		log_debug("Playercount: [playercount] versus trigger: [highpop_trigger] - keeping standard job config")

	#ifdef UNIT_TESTS
	RunUnitTests()
	#endif
	return TRUE


/datum/controller/subsystem/ticker/proc/station_explosion_cinematic(station_missed = 0, override = null)
	if(cinematic)
		return	//already a cinematic in progress!

	auto_toggle_ooc(TRUE) // Turn it on
	//initialise our cinematic screen object
	cinematic = new /obj/screen(src)
	cinematic.icon = 'icons/effects/station_explosion.dmi'
	cinematic.icon_state = "station_intact"
	cinematic.layer = 21
	cinematic.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	cinematic.screen_loc = "1,0"

	if(station_missed)
		for(var/mob/M in GLOB.mob_list)
			if(M.client)
				M.client.screen += cinematic	//show every client the cinematic
	else	//nuke kills everyone on z-level 1 to prevent "hurr-durr I survived"
		for(var/mob/M in GLOB.mob_list)
			if(M.stat != DEAD)
				var/turf/T = get_turf(M)
				if(T && is_station_level(T.z) && !istype(M.loc, /obj/structure/closet/secure_closet/freezer))
					var/mob/ghost = M.ghostize()
					M.dust() //no mercy
					if(ghost && ghost.client) //Play the victims an uninterrupted cinematic.
						ghost.client.screen += cinematic
					CHECK_TICK
			if(M && M.client) //Play the survivors a cinematic.
				M.client.screen += cinematic

	//Now animate the cinematic
	switch(station_missed)
		if(1)	//nuke was nearby but (mostly) missed
			if(mode && !override)
				override = mode.name
			switch(override)
				if("nuclear emergency") //Nuke wasn't on station when it blew up
					flick("intro_nuke", cinematic)
					sleep(35)
					world << sound('sound/effects/explosionfar.ogg')
					flick("station_intact_fade_red", cinematic)
					cinematic.icon_state = "summary_nukefail"
				if("fake") //The round isn't over, we're just freaking people out for fun
					flick("intro_nuke", cinematic)
					sleep(35)
					world << sound('sound/items/bikehorn.ogg')
					flick("summary_selfdes", cinematic)
				else
					flick("intro_nuke", cinematic)
					sleep(35)
					world << sound('sound/effects/explosionfar.ogg')


		if(2)	//nuke was nowhere nearby	//TODO: a really distant explosion animation
			sleep(50)
			world << sound('sound/effects/explosionfar.ogg')
		else	//station was destroyed
			if(mode && !override)
				override = mode.name
			switch(override)
				if("nuclear emergency") //Nuke Ops successfully bombed the station
					flick("intro_nuke", cinematic)
					sleep(35)
					flick("station_explode_fade_red", cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_nukewin"
				if("AI malfunction") //Malf (screen,explosion,summary)
					flick("intro_malf", cinematic)
					sleep(76)
					flick("station_explode_fade_red", cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_malf"
				if("blob") //Station nuked (nuke,explosion,summary)
					flick("intro_nuke", cinematic)
					sleep(35)
					flick("station_explode_fade_red", cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_selfdes"
				else //Station nuked (nuke,explosion,summary)
					flick("intro_nuke", cinematic)
					sleep(35)
					flick("station_explode_fade_red", cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_selfdes"
	//If its actually the end of the round, wait for it to end.
	//Otherwise if its a verb it will continue on afterwards.
	spawn(300)
		QDEL_NULL(cinematic)		//end the cinematic



/datum/controller/subsystem/ticker/proc/create_characters()
	for(var/mob/new_player/player in GLOB.player_list)
		if(player.ready && player.mind)
			if(player.mind.assigned_role == "AI")
				player.close_spawn_windows()
				var/mob/living/silicon/ai/ai_character = player.AIize()
				ai_character.moveToAILandmark()
			else if(!player.mind.assigned_role)
				continue
			else
				player.create_character()
				qdel(player)

/datum/controller/subsystem/ticker/proc/equip_characters()
	var/captainless = TRUE
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(player && player.mind && player.mind.assigned_role)
			if(player.mind.assigned_role == "Captain")
				captainless = FALSE
			if(player.mind.assigned_role != player.mind.special_role)
				SSjobs.AssignRank(player, player.mind.assigned_role, FALSE)
				SSjobs.EquipRank(player, player.mind.assigned_role, FALSE)
				EquipCustomItems(player)
				if(config.roundstart_traits && ishuman(player))
					SSquirks.AssignQuirks(player, player.client, TRUE)
	if(captainless)
		for(var/mob/M in GLOB.player_list)
			if(!isnewplayer(M))
				to_chat(M, "Captainship not forced on anyone.")

/datum/controller/subsystem/ticker/proc/send_tip_of_the_round()
	var/m
	if(selected_tip)
		m = selected_tip
	else
		var/list/randomtips = file2list("strings/tips.txt")
		var/list/memetips = file2list("strings/sillytips.txt")
		if(randomtips.len && prob(95))
			m = pick(randomtips)
		else if(memetips.len)
			m = pick(memetips)

	if(m)
		to_chat(world, "<span class='purple'><b>Tip of the round: </b>[html_encode(m)]</span>")

/datum/controller/subsystem/ticker/proc/declare_completion()
	GLOB.nologevent = TRUE //end of round murder and shenanigans are legal; there's no need to jam up attack logs past this point.
	//Round statistics report
	var/datum/station_state/ending_station_state = new /datum/station_state()
	ending_station_state.count()
	var/station_integrity = min(round( 100.0 *  GLOB.start_state.score(ending_station_state), 0.1), 100.0)

	to_chat(world, "<BR>[TAB]Shift Duration: <B>[round(ROUND_TIME / 36000)]:[add_zero("[ROUND_TIME / 600 % 60]", 2)]:[ROUND_TIME / 100 % 6][ROUND_TIME / 100 % 10]</B>")
	to_chat(world, "<BR>[TAB]Station Integrity: <B>[mode.station_was_nuked ? "<font color='red'>Destroyed</font>" : "[station_integrity]%"]</B>")
	to_chat(world, "<BR>")

	//Silicon laws report
	for(var/mob/living/silicon/ai/aiPlayer in GLOB.mob_list)
		if(aiPlayer.stat != 2)
			to_chat(world, "<b>[aiPlayer.name] (Played by: [aiPlayer.key])'s laws at the end of the game were:</b>")
		else
			to_chat(world, "<b>[aiPlayer.name] (Played by: [aiPlayer.key])'s laws when it was deactivated were:</b>")
		aiPlayer.show_laws(TRUE)

		if(aiPlayer.connected_robots.len)
			var/robolist = "<b>The AI's loyal minions were:</b> "
			for(var/mob/living/silicon/robot/robo in aiPlayer.connected_robots)
				robolist += "[robo.name][robo.stat?" (Deactivated) (Played by: [robo.key]), ":" (Played by: [robo.key]), "]"
			to_chat(world, "[robolist]")

	var/dronecount = 0

	for(var/mob/living/silicon/robot/robo in GLOB.mob_list)

		if(istype(robo,/mob/living/silicon/robot/drone))
			dronecount++
			continue

		if(!robo.connected_ai)
			if(robo.stat != 2)
				to_chat(world, "<b>[robo.name] (Played by: [robo.key]) survived as an AI-less borg! Its laws were:</b>")
			else
				to_chat(world, "<b>[robo.name] (Played by: [robo.key]) was unable to survive the rigors of being a cyborg without an AI. Its laws were:</b>")

			if(robo) //How the hell do we lose robo between here and the world messages directly above this?
				robo.laws.show_laws(world)

	if(dronecount)
		to_chat(world, "<b>There [dronecount>1 ? "were" : "was"] [dronecount] industrious maintenance [dronecount>1 ? "drones" : "drone"] this round.")

	if(mode.eventmiscs.len)
		var/emobtext = ""
		for(var/datum/mind/eventmind in mode.eventmiscs)
			emobtext += printeventplayer(eventmind)
			emobtext += "<br>"
			emobtext += printobjectives(eventmind)
			emobtext += "<br>"
		emobtext += "<br>"
		to_chat(world, emobtext)

	mode.declare_completion()//To declare normal completion.

	//calls auto_declare_completion_* for all modes
	for(var/handler in typesof(/datum/game_mode/proc))
		if(findtext("[handler]","auto_declare_completion_"))
			call(mode, handler)()

	scoreboard()

	// Declare the completion of the station goals
	mode.declare_station_goal_completion()

	//Ask the event manager to print round end information
	SSevents.RoundEnd()

	//make big obvious note in game logs that round ended
	log_game("///////////////////////////////////////////////////////")
	log_game("///////////////////// ROUND ENDED /////////////////////")
	log_game("///////////////////////////////////////////////////////")

	// Add AntagHUD to everyone, see who was really evil the whole time!
	for(var/datum/atom_hud/antag/H in GLOB.huds)
		for(var/m in GLOB.player_list)
			var/mob/M = m
			H.add_hud_to(M)

	// Seal the blackbox, stop collecting info
	SSblackbox.Seal()
	SSdbcore.SetRoundEnd()

	return TRUE

/datum/controller/subsystem/ticker/proc/HasRoundStarted()
	return current_state >= GAME_STATE_PLAYING

/datum/controller/subsystem/ticker/proc/IsRoundInProgress()
	return current_state == GAME_STATE_PLAYING


/datum/controller/subsystem/ticker/proc/setup_news_feeds()
	var/datum/feed_channel/newChannel = new /datum/feed_channel
	newChannel.channel_name = "Public Station Announcements"
	newChannel.author = "Automated Announcement Listing"
	newChannel.icon = "bullhorn"
	newChannel.frozen = TRUE
	newChannel.admin_locked = TRUE
	GLOB.news_network.channels += newChannel

	newChannel = new /datum/feed_channel
	newChannel.channel_name = "Nyx Daily"
	newChannel.author = "CentComm Minister of Information"
	newChannel.icon = "meteor"
	newChannel.frozen = TRUE
	newChannel.admin_locked = TRUE
	GLOB.news_network.channels += newChannel

	newChannel = new /datum/feed_channel
	newChannel.channel_name = "The Gibson Gazette"
	newChannel.author = "Editor Mike Hammers"
	newChannel.icon = "star"
	newChannel.frozen = TRUE
	newChannel.admin_locked = TRUE
	GLOB.news_network.channels += newChannel

	for(var/loc_type in subtypesof(/datum/trade_destination))
		var/datum/trade_destination/D = new loc_type
		GLOB.weighted_randomevent_locations[D] = D.viable_random_events.len
		GLOB.weighted_mundaneevent_locations[D] = D.viable_mundane_events.len
