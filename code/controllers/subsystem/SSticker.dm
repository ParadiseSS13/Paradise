SUBSYSTEM_DEF(ticker)
	name = "Ticker"
	init_order = INIT_ORDER_TICKER

	priority = FIRE_PRIORITY_TICKER
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME
	offline_implications = "The game is no longer aware of when the round ends. Immediate server restart recommended."
	cpu_display = SS_CPUDISPLAY_LOW

	/// Time the game should start, relative to world.time
	var/round_start_time = 0
	/// Time that the round started
	var/time_game_started = 0
	/// Default timeout for if world.Reboot() doesnt have a time specified
	var/const/restart_timeout = 75 SECONDS
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
	/// Gamemode result (For things like cult or nukies which can end multiple ways)
	var/mode_result = "undefined"
	/// Server end state (Did we end properly or reboot or nuke or what)
	var/end_state = "undefined"
	/// Time the real reboot kicks in
	var/real_reboot_time = 0
	/// Datum used to generate the end of round scoreboard.
	var/datum/scoreboard/score = null
	/// List of ckeys who had antag rolling issues flagged
	var/list/flagged_antag_rollers = list()

/datum/controller/subsystem/ticker/Initialize()
	login_music = pick(\
	'sound/music/thunderdome.ogg',\
	'sound/music/space.ogg',\
	'sound/music/title1.ogg',\
	'sound/music/title2.ogg',\
	'sound/music/title3.ogg',)


/datum/controller/subsystem/ticker/fire()
	switch(current_state)
		if(GAME_STATE_STARTUP)
			// This is ran as soon as the MC starts firing, and should only run ONCE, unless startup fails
			round_start_time = world.time + (GLOB.configuration.general.lobby_time SECONDS)
			to_chat(world, "<B><span class='darkmblue'>Welcome to the pre-game lobby!</span></B>")
			to_chat(world, "Please, setup your character and select ready. Game will start in [GLOB.configuration.general.lobby_time] seconds")
			current_state = GAME_STATE_PREGAME
			fire() // TG says this is a good idea
			for(var/mob/new_player/N in GLOB.player_list)
				if (N.client)
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

			if(world.time > next_autotransfer)
				SSvote.start_vote(new /datum/vote/crew_transfer)
				next_autotransfer = world.time + GLOB.configuration.vote.autotransfer_interval_time

			var/game_finished = SSshuttle.emergency.mode >= SHUTTLE_ENDGAME || mode.station_was_nuked
			if(GLOB.configuration.gamemode.disable_certain_round_early_end)
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
			addtimer(CALLBACK(src, PROC_REF(call_reboot)), 5 SECONDS)
			// Start a map vote IF
			// - Map rotate doesnt have a mode for today and map voting is enabled
			// - Map rotate has a mode for the day and it ISNT full random
			if(((!SSmaprotate.setup_done) && GLOB.configuration.vote.enable_map_voting) || (SSmaprotate.setup_done && (SSmaprotate.rotation_mode != MAPROTATION_MODE_FULL_RANDOM)))
				SSvote.start_vote(new /datum/vote/map)
			else
				// Pick random map
				var/list/pickable_types = list()
				for(var/x in subtypesof(/datum/map))
					var/datum/map/M = x
					if(initial(M.voteable))
						pickable_types += M

				var/datum/map/target_map = pick(pickable_types)
				SSmapping.next_map = new target_map
				to_chat(world, "<span class='interface'>Map for next round: [SSmapping.next_map.fluff_name] ([SSmapping.next_map.technical_name])</span>")

/datum/controller/subsystem/ticker/proc/call_reboot()
	if(mode.station_was_nuked)
		reboot_helper("Station destroyed by Nuclear Device.", "nuke")
	else
		reboot_helper("Round ended.", "proper completion")

/datum/controller/subsystem/ticker/proc/setup()
	cultdat = setupcult()
	score = new()

	// Create and announce mode
	if(GLOB.master_mode == "secret")
		hide_mode = TRUE

	var/list/datum/game_mode/runnable_modes

	if(GLOB.master_mode == "random" || GLOB.master_mode == "secret")
		runnable_modes = GLOB.configuration.gamemode.get_runnable_modes()
		if(!length(runnable_modes))
			to_chat(world, "<B>Unable to choose playable game mode.</B> Reverting to pre-game lobby.")
			force_start = FALSE
			current_state = GAME_STATE_PREGAME
			Master.SetRunLevel(RUNLEVEL_LOBBY)
			return FALSE
		if(GLOB.secret_force_mode != "secret")
			var/datum/game_mode/M = GLOB.configuration.gamemode.pick_mode(GLOB.secret_force_mode)
			if(M.can_start())
				mode = GLOB.configuration.gamemode.pick_mode(GLOB.secret_force_mode)
		SSjobs.ResetOccupations()
		if(!mode)
			mode = pickweight(runnable_modes)
		if(mode)
			var/mtype = mode.type
			mode = new mtype
	else
		mode = GLOB.configuration.gamemode.pick_mode(GLOB.master_mode)

	if(!mode.can_start())
		to_chat(world, "<B>Unable to start [mode.name].</B> Not enough players, [mode.required_players] players needed. Reverting to pre-game lobby.")
		mode = null
		current_state = GAME_STATE_PREGAME
		force_start = FALSE
		SSjobs.ResetOccupations()
		Master.SetRunLevel(RUNLEVEL_LOBBY)
		return FALSE

	// Randomise characters now. This avoids rare cases where a human is set as a changeling then they randomise to an IPC
	for(var/mob/new_player/player in GLOB.player_list)
		if(player.client.prefs.toggles2 & PREFTOGGLE_2_RANDOMSLOT)
			player.client.prefs.load_random_character_slot(player.client)

	// Lets check if people who ready should or shouldnt be
	for(var/mob/new_player/P in GLOB.player_list)
		// Not logged in
		if(!P.client)
			continue
		// Not ready
		if(!P.ready)
			continue
		// Not set to return if nothing available
		if(P.client.prefs.active_character.alternate_option != RETURN_TO_LOBBY)
			continue

		var/has_antags = (length(P.client.prefs.be_special) > 0)
		if(!P.client.prefs.active_character.check_any_job())
			to_chat(P, "<span class='danger'>You have no jobs enabled, along with return to lobby if job is unavailable. This makes you ineligible for any round start role, please update your job preferences.</span>")
			if(has_antags)
				// We add these to a list so we can deal with them as a batch later
				// A lot of DB tracking stuff needs doing, so we may as well async it
				flagged_antag_rollers |= P.ckey

			P.ready = FALSE

	//Configure mode and assign player to special mode stuff
	mode.pre_pre_setup()
	var/can_continue = FALSE
	can_continue = mode.pre_setup() //Setup special modes. This also does the antag fishing checks.
	SSjobs.DivideOccupations() //Distribute jobs
	if(!can_continue)
		QDEL_NULL(mode)
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
	for(var/obj/effect/landmark/start/ai/A in GLOB.landmarks_list)
		if(locate(/mob/living) in get_turf(A))
			continue
		GLOB.empty_playable_ai_cores += new /obj/structure/AIcore/deactivated(get_turf(A))


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
		if(!istype(S, /obj/effect/landmark/start/ai))
			qdel(S)

	SSdbcore.SetRoundStart()
	to_chat(world, "<span class='darkmblue'><B>Enjoy the game!</B></span>")
	SEND_SOUND(world, sound('sound/AI/welcome.ogg'))

	if(SSholiday.holidays)
		to_chat(world, "<span class='darkmblue'>and...</span>")
		for(var/holidayname in SSholiday.holidays)
			var/datum/holiday/holiday = SSholiday.holidays[holidayname]
			to_chat(world, "<h4>[holiday.greet()]</h4>")

	GLOB.discord_manager.send2discord_simple_noadmins("**\[Info]** Round has started")
	auto_toggle_ooc(FALSE) // Turn it off
	time_game_started = world.time

	// Sets the auto shuttle vote to happen after the config duration
	next_autotransfer = world.time + GLOB.configuration.vote.autotransfer_initial_time

	for(var/mob/new_player/N in GLOB.mob_list)
		if(N.client)
			N.new_player_panel_proc()

	// Now that every other piece of the round has initialized, lets setup player job scaling
	var/playercount = length(GLOB.clients)
	var/highpop_trigger = 80

	if(playercount >= highpop_trigger)
		log_debug("Playercount: [playercount] versus trigger: [highpop_trigger] - loading highpop job config")
		SSjobs.LoadJobs(TRUE)
	else
		log_debug("Playercount: [playercount] versus trigger: [highpop_trigger] - keeping standard job config")

	SSnightshift.check_nightshift(TRUE)

	#ifdef UNIT_TESTS
	// Run map tests first in case unit tests futz with map state
	GLOB.test_runner.RunMap()
	GLOB.test_runner.Run()
	#endif

	// Do this 10 second after roundstart because of roundstart lag, and make it more visible
	addtimer(CALLBACK(src, PROC_REF(handle_antagfishing_reporting)), 10 SECONDS)
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
	cinematic.screen_loc = "1,1"

	if(station_missed)
		for(var/mob/M in GLOB.mob_list)
			if(M.client)
				M.client.screen += cinematic	//show every client the cinematic
	else	//nuke kills everyone on z-level 1 to prevent "hurr-durr I survived"
		for(var/mob/M in GLOB.mob_list)
			if(M.stat != DEAD)
				var/turf/T = get_turf(M)
				if(T && is_station_level(T.z) && !istype(M.loc, /obj/structure/closet/secure_closet/freezer) && !(issilicon(M) && override == "AI malfunction"))
					to_chat(M, "<span class='danger'><B>The blast wave from the explosion tears you atom from atom!</B></span>")
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
					SEND_SOUND(world, sound('sound/effects/explosion_distant.ogg'))
					flick("station_intact_fade_red", cinematic)
					cinematic.icon_state = "summary_nukefail"
				if("fake") //The round isn't over, we're just freaking people out for fun
					flick("intro_nuke", cinematic)
					sleep(35)
					SEND_SOUND(world, sound('sound/items/bikehorn.ogg'))
					flick("summary_selfdes", cinematic)
				else
					flick("intro_nuke", cinematic)
					sleep(35)
					SEND_SOUND(world, sound('sound/effects/explosion_distant.ogg'))


		if(2)	//nuke was nowhere nearby	//TODO: a really distant explosion animation
			sleep(50)
			SEND_SOUND(world, sound('sound/effects/explosion_distant.ogg'))
		else	//station was destroyed
			if(mode && !override)
				override = mode.name
			switch(override)
				if("nuclear emergency") //Nuke Ops successfully bombed the station
					flick("intro_nuke", cinematic)
					sleep(35)
					flick("station_explode_fade_red", cinematic)
					SEND_SOUND(world, sound('sound/effects/explosion_distant.ogg'))
					cinematic.icon_state = "summary_nukewin"
				if("AI malfunction") //Malf (screen,explosion,summary)
					flick("intro_malf", cinematic)
					sleep(76)
					flick("station_explode_fade_red", cinematic)
					SEND_SOUND(world, sound('sound/effects/explosion_distant.ogg'))
					cinematic.icon_state = "summary_malf"
				else //Station nuked (nuke,explosion,summary)
					flick("intro_nuke", cinematic)
					sleep(35)
					flick("station_explode_fade_red", cinematic)
					SEND_SOUND(world, sound('sound/effects/explosion_distant.ogg'))
					cinematic.icon_state = "summary_selfdes"
			stop_delta_alarm()

	//If its actually the end of the round, wait for it to end.
	//Otherwise if its a verb it will continue on afterwards.
	spawn(300)
		stop_delta_alarm() // If we've not stopped this alarm yet, do so now.
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
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(player && player.mind && player.mind.assigned_role && player.mind.assigned_role != player.mind.special_role)
			SSjobs.AssignRank(player, player.mind.assigned_role, FALSE)
			SSjobs.EquipRank(player, player.mind.assigned_role, FALSE)
			equip_cuis(player)

/datum/controller/subsystem/ticker/proc/equip_cuis(mob/living/carbon/human/H)
	if(!H.client)
		return // If they are spawning without a client (somehow), they *cant* have a CUI list
	for(var/datum/custom_user_item/cui in H.client.cui_entries)
		// Skip items with invalid character names
		if((cui.characer_name != H.real_name) && !cui.all_characters_allowed)
			continue

		var/ok = FALSE

		if(!cui.all_jobs_allowed)
			var/alt_blocked = FALSE
			if(H.mind.role_alt_title)
				if(!(H.mind.role_alt_title in cui.allowed_jobs))
					alt_blocked = TRUE
			if(!(H.mind.assigned_role in cui.allowed_jobs) || alt_blocked)
				continue

		var/obj/item/I = new cui.object_typepath()
		var/name_override = cui.item_name_override
		var/desc_override = cui.item_desc_override

		if(name_override)
			I.name = name_override
		if(desc_override)
			I.desc = desc_override

		if(isstorage(H.back)) // Try to place it in something on the mob's back
			var/obj/item/storage/S = H.back
			if(length(S.contents) < S.storage_slots)
				I.forceMove(H.back)
				ok = TRUE
				to_chat(H, "<span class='notice'>Your [I.name] has been added to your [H.back.name].</span>")

		if(!ok)
			for(var/obj/item/storage/S in H.contents) // Try to place it in any item that can store stuff, on the mob.
				if(length(S.contents) < S.storage_slots)
					I.forceMove(S)
					ok = TRUE
					to_chat(H, "<span class='notice'>Your [I.name] has been added to your [S.name].</span>")
					break

		if(!ok) // Finally, since everything else failed, place it on the ground
			var/turf/T = get_turf(H)
			if(T)
				I.forceMove(T)
				to_chat(H, "<span class='notice'>Your [I.name] is on the [T.name] below you.</span>")
			else
				to_chat(H, "<span class='notice'>Your [I.name] couldnt spawn anywhere on you or even on the floor below you. Please file a bug report.</span>")
				qdel(I)


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
	set_observer_default_invisibility(0) //spooks things up
	//Round statistics report
	var/datum/station_state/ending_station_state = new /datum/station_state()
	ending_station_state.count()
	var/station_integrity = min(round( 100.0 *  GLOB.start_state.score(ending_station_state), 0.1), 100.0)

	to_chat(world, "<BR>[TAB]Shift Duration: <B>[round(ROUND_TIME / 36000)]:[add_zero("[ROUND_TIME / 600 % 60]", 2)]:[ROUND_TIME / 100 % 6][ROUND_TIME / 100 % 10]</B>")
	to_chat(world, "<BR>[TAB]Station Integrity: <B>[mode.station_was_nuked ? "<font color='red'>Destroyed</font>" : "[station_integrity]%"]</B>")
	to_chat(world, "<BR>")

	//Silicon laws report
	for(var/mob/living/silicon/ai/aiPlayer in GLOB.mob_list)
		var/ai_ckey = safe_get_ckey(aiPlayer)

		if(aiPlayer.stat != 2)
			to_chat(world, "<b>[aiPlayer.name] (Played by: [ai_ckey])'s laws at the end of the game were:</b>")
		else
			to_chat(world, "<b>[aiPlayer.name] (Played by: [ai_ckey])'s laws when it was deactivated were:</b>")
		aiPlayer.show_laws(TRUE)

		if(aiPlayer.connected_robots.len)
			var/robolist = "<b>The AI's loyal minions were:</b> "
			for(var/mob/living/silicon/robot/robo in aiPlayer.connected_robots)
				var/robo_ckey = safe_get_ckey(robo)
				robolist += "[robo.name][robo.stat ? " (Deactivated)" : ""] (Played by: [robo_ckey])"
			to_chat(world, "[robolist]")

	var/dronecount = 0

	for(var/mob/living/silicon/robot/robo in GLOB.mob_list)

		if(isdrone(robo))
			dronecount++
			continue

		var/robo_ckey = safe_get_ckey(robo)

		if(!robo.connected_ai)
			if(robo.stat != 2)
				to_chat(world, "<b>[robo.name] (Played by: [robo_ckey]) survived as an AI-less borg! Its laws were:</b>")
			else
				to_chat(world, "<b>[robo.name] (Played by: [robo_ckey]) was unable to survive the rigors of being a cyborg without an AI. Its laws were:</b>")

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

	// Display the scoreboard window
	score.scoreboard()

	// Declare the completion of the station goals
	mode.declare_station_goal_completion()

	//Ask the event manager to print round end information
	SSevents.RoundEnd()

	// Save the data before end of the round griefing
	SSpersistent_data.save()

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

// Easy handler to make rebooting the world not a massive sleep in world/Reboot()
/datum/controller/subsystem/ticker/proc/reboot_helper(reason, end_string, delay)
	// Admins delayed round end. Just alert and dont bother with anything else.
	if(delay_end)
		to_chat(world, "<span class='boldannounce'>An admin has delayed the round end.</span>")
		return

	if(!isnull(delay))
		// Delay time was present. Use that.
		delay = max(0, delay)
	else
		// Use default restart timeout
		delay = restart_timeout

	to_chat(world, "<span class='boldannounce'>Rebooting world in [delay/10] [delay > 10 ? "seconds" : "second"]. [reason]</span>")

	real_reboot_time = world.time + delay
	UNTIL(world.time > real_reboot_time) // Hold it here

	// And if we re-delayed, bail again
	if(delay_end)
		to_chat(world, "<span class='boldannounce'>Reboot was cancelled by an admin.</span>")
		return

	if(end_string)
		end_state = end_string

	// Play a haha funny noise
	var/round_end_sound = pick(GLOB.round_end_sounds)
	var/sound_length = GLOB.round_end_sounds[round_end_sound]
	SEND_SOUND(world, sound(round_end_sound))
	sleep(sound_length)

	world.Reboot()

// Timers invoke this async
/datum/controller/subsystem/ticker/proc/handle_antagfishing_reporting()
	// This needs the DB
	if(!SSdbcore.IsConnected())
		return
	// Dont need to do anything
	if(!length(flagged_antag_rollers))
		return

	// Records themselves
	var/list/datum/antag_record/records = list()
	// Queries to load data (executed as async batch)
	var/list/datum/db_query/load_queries = list()
	// Queries to save data (executed as async batch)
	var/list/datum/db_query/save_queries = list()


	for(var/ckey in flagged_antag_rollers)
		var/datum/antag_record/AR = new /datum/antag_record(ckey)
		records[ckey] = AR
		load_queries[ckey] = AR.get_load_query()

	// Explanation for parameters:
	// TRUE: We want warnings if these fail
	// FALSE: Do NOT qdel() queries here, otherwise they wont be read. At all.
	// TRUE: This is an assoc list, so it needs to prepare for that
	SSdbcore.MassExecute(load_queries, TRUE, FALSE, TRUE)

	// Report on things
	var/list/log_text = list("The following players attempted to roll antag with no jobs (total infractions listed)")

	for(var/ckey in flagged_antag_rollers)
		var/datum/antag_record/AR = records[ckey]
		AR.handle_data(load_queries[ckey])
		save_queries[ckey] = AR.get_save_query()

		log_text += "<small>- <a href='?priv_msg=[ckey]'>[ckey]</a>: [AR.infraction_count]</small>"

	log_text += "Investigation advised if there are a high number of infractions"

	message_admins(log_text.Join("<br>"))

	// Now do a ton of saves
	SSdbcore.MassExecute(save_queries, TRUE, TRUE, TRUE)

	// And cleanup
	QDEL_LIST_ASSOC_VAL(load_queries)
	records.Cut()
	flagged_antag_rollers.Cut()
