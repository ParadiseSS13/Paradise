SUBSYSTEM_DEF(ticker)
	name = "Ticker"
	init_order = INIT_ORDER_TICKER

	priority = FIRE_PRIORITY_TICKER
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME
	offline_implications = "The game is no longer aware of when the round ends. Immediate server restart recommended."
	cpu_display = SS_CPUDISPLAY_LOW
	wait = 1 SECONDS

	/// Time the game should start, relative to world.time
	var/round_start_time = 0
	/// Time that the round started
	var/time_game_started = 0
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
	/// Name of the bible deity
	var/Bible_deity_name
	/// Cult static info, used for things like sprites. Someone should refactor the sprites out of it someday and just use SEPERATE ICONS DEPNDING ON THE TYPE OF CULT... like a sane person
	var/datum/cult_info/cult_data
	/// If set to nonzero, ALL players who latejoin or declare-ready join will have random appearances/genders
	var/random_players = FALSE
	/// Did we broadcast the tip of the round yet?
	var/tipped = FALSE
	/// What will be the tip of the round?
	var/selected_tip
	/// Did we broadcast the fact of the round yet?
	var/facted = FALSE
	/// What will be the fact of the round?
	var/selected_fact
	/// This is used for calculations for the statpanel
	var/pregame_timeleft
	/// If set to TRUE, the round will not restart on it's own
	var/delay_end = FALSE
	/// Global holder for triple AI mode
	var/triai = FALSE
	/// Holder for inital autotransfer vote timer
	var/next_autotransfer = 0
	/// Used for station explosion cinematic
	var/atom/movable/screen/cinematic = null
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
	/// List of biohazards keyed to the last time their population was sampled.
	var/list/biohazard_pop_times = list()
	var/list/biohazard_included_admin_spawns = list()

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
			pregame_timeleft = GLOB.configuration.general.lobby_time SECONDS
			round_start_time = world.time + pregame_timeleft
			to_chat(world, "<B><span class='darkmblue'>Welcome to the pre-game lobby!</span></B>")
			to_chat(world, "Please, setup your character and select ready. Game will start in [GLOB.configuration.general.lobby_time] seconds")
			current_state = GAME_STATE_PREGAME
			fire() // TG says this is a good idea
			for(var/mob/new_player/N in GLOB.player_list)
				if(N.client)
					N.new_player_panel_proc() // to enable the observe option
		if(GAME_STATE_PREGAME)
			if(!SSticker.ticker_going) // This has to be referenced like this, and I dont know why. If you dont put SSticker. it will break
				return

			// This is so we dont have sleeps in controllers, because that is a bad, bad thing
			pregame_timeleft = max(0, round_start_time - world.time)

			if(pregame_timeleft <= 1 MINUTES && !tipped)
				send_tip_of_the_round()
				tipped = TRUE

			if(pregame_timeleft <= 120 SECONDS && !facted)
				send_fact_of_the_round()
				facted = TRUE

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

			for(var/biohazard in biohazard_pop_times)
				if(world.time - biohazard_pop_times[biohazard] > BIOHAZARD_POP_INTERVAL)
					sample_biohazard_population(biohazard)

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
			if(SSshuttle.emergency.mode >= SHUTTLE_ENDGAME && !mode.station_was_nuked)
				record_biohazard_results()
			current_state = GAME_STATE_FINISHED
			Master.SetRunLevel(RUNLEVEL_POSTGAME) // This shouldnt process more than once, but you never know
			auto_toggle_ooc(TRUE) // Turn it on
			declare_completion()
			addtimer(CALLBACK(src, PROC_REF(call_reboot)), 5 SECONDS)
			// Start a map vote IF
			// - Map rotate doesnt have a mode for today and map voting is enabled
			// - Map rotate has a mode for the day and it ISNT full random
			if(SSmaprotate.setup_done && (SSmaprotate.rotation_mode == MAPROTATION_MODE_HYBRID_FPTP_NO_DUPLICATES))
				SSmaprotate.decide_next_map()
				return
			if(((!SSmaprotate.setup_done) && GLOB.configuration.vote.enable_map_voting) || (SSmaprotate.setup_done && (SSmaprotate.rotation_mode != MAPROTATION_MODE_FULL_RANDOM)))
				SSvote.start_vote(new /datum/vote/map)
			else
				// Pick random map
				var/list/pickable_types = list()
				for(var/x in subtypesof(/datum/map))
					var/datum/map/M = x
					if(istype(SSmapping.map_datum, M)) // Random will never choose the same map twice in a row.
						continue
					if(initial(M.voteable) && length(GLOB.clients) >= initial(M.min_players_random))
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
	var/random_cult = pick(typesof(/datum/cult_info))
	cult_data = new random_cult()
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

	var/can_continue = FALSE
	can_continue = mode.pre_setup() //Setup special modes. This also does the antag fishing checks.

	if(!can_continue)
		QDEL_NULL(mode)
		to_chat(world, "<B>Error setting up [GLOB.master_mode].</B> Reverting to pre-game lobby.")
		current_state = GAME_STATE_PREGAME
		force_start = FALSE
		SSjobs.ResetOccupations()
		Master.SetRunLevel(RUNLEVEL_LOBBY)
		return FALSE

	// Enable highpop slots just before we distribute jobs.
	var/playercount = length(GLOB.clients)
	var/highpop_trigger = 80

	if(playercount >= highpop_trigger)
		log_debug("Playercount: [playercount] versus trigger: [highpop_trigger] - loading highpop job config")
		SSjobs.LoadJobs(TRUE)
	else
		log_debug("Playercount: [playercount] versus trigger: [highpop_trigger] - keeping standard job config")

	SSjobs.job_selector = new()
	SSjobs.job_selector.assign_all_roles()
	SSjobs.job_selector.apply_roles_to_players()

	if(hide_mode)
		var/list/modes = list()
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
	SEND_SIGNAL(src, COMSIG_TICKER_ROUND_STARTING, world.time)

	// Update the MC and state to game playing
	current_state = GAME_STATE_PLAYING
	Master.SetRunLevel(RUNLEVEL_GAME)

	// Generate the list of empty playable AI cores in the world
	if(HAS_TRAIT(SSstation, STATION_TRAIT_TRIAI))
		for(var/obj/effect/landmark/tripai in GLOB.landmarks_list)
			if(tripai.name == "tripai")
				if(locate(/mob/living) in get_turf(tripai))
					continue
				GLOB.empty_playable_ai_cores += new /obj/structure/ai_core/deactivated(get_turf(tripai))
	for(var/obj/effect/landmark/start/ai/A in GLOB.landmarks_list)
		if(locate(/mob/living) in get_turf(A))
			continue
		GLOB.empty_playable_ai_cores += new /obj/structure/ai_core/deactivated(get_turf(A))


	// Setup pregenerated newsfeeds
	setup_news_feeds()

	// Generate code phrases and responses
	if(!GLOB.syndicate_code_phrase)
		var/temp_syndicate_code_phrase = generate_code_phrase(return_list = TRUE)

		var/codewords = jointext(temp_syndicate_code_phrase, "|")
		var/regex/codeword_match = new("([codewords])", "ig")

		GLOB.syndicate_code_phrase_regex = codeword_match
		temp_syndicate_code_phrase = jointext(temp_syndicate_code_phrase, ", ")
		GLOB.syndicate_code_phrase = temp_syndicate_code_phrase


	if(!GLOB.syndicate_code_response)
		var/temp_syndicate_code_response = generate_code_phrase(return_list = TRUE)

		var/codewords = jointext(temp_syndicate_code_response, "|")
		var/regex/codeword_match = new("([codewords])", "ig")

		GLOB.syndicate_code_response_regex = codeword_match
		temp_syndicate_code_response = jointext(temp_syndicate_code_response, ", ")
		GLOB.syndicate_code_response = temp_syndicate_code_response

	// Run post setup stuff
	mode.post_setup()

	// Delete starting landmarks (not AI ones because we need those for AI-ize)
	for(var/obj/effect/landmark/start/S in GLOB.landmarks_list)
		if(!istype(S, /obj/effect/landmark/start/ai))
			qdel(S)

	SSdbcore.SetRoundStart()
	to_chat(world, "<span class='darkmblue'><B>Enjoy the game!</B></span>")
	SEND_SOUND(world, sound(SSmapping.map_datum.welcome_sound))

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

	if(GLOB.configuration.general.enable_night_shifts)
		SSnightshift.check_nightshift(TRUE)

	#ifdef TEST_RUNNER
	GLOB.test_runner.RunAll()
	#endif

	// Do this 10 second after roundstart because of roundstart lag, and make it more visible
	addtimer(CALLBACK(src, PROC_REF(handle_antagfishing_reporting)), 10 SECONDS)
	return TRUE


/datum/controller/subsystem/ticker/proc/station_explosion_cinematic(nuke_site = NUKE_SITE_ON_STATION, override = null)
	if(cinematic)
		return	//already a cinematic in progress!

	auto_toggle_ooc(TRUE) // Turn it on
	//initialise our cinematic screen object
	cinematic = new /atom/movable/screen(src)
	cinematic.icon = 'icons/effects/station_explosion.dmi'
	cinematic.icon_state = "station_intact"
	cinematic.layer = 21
	cinematic.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	cinematic.screen_loc = "1,1"

	if(nuke_site == NUKE_SITE_ON_STATION)
		// Kill everyone on z-level 1 except for mobs in freezers and
		// malfunctioning AIs.
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
	else
		for(var/mob/M in GLOB.mob_list)
			if(M.client)
				M.client.screen += cinematic	//show every client the cinematic

	switch(nuke_site)
		//Now animate the cinematic
		if(NUKE_SITE_ON_STATION)
			// station was destroyed
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

		if(NUKE_SITE_ON_STATION_ZLEVEL)
			// nuke was nearby but (mostly) missed
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
		if(NUKE_SITE_OFF_STATION_ZLEVEL, NUKE_SITE_INVALID)
			// nuke was nowhere nearby
			// TODO: a really distant explosion animation
			sleep(50)
			SEND_SOUND(world, sound('sound/effects/explosion_distant.ogg'))

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
		if(length(randomtips) && prob(95))
			m = pick(randomtips)
		else if(length(memetips))
			m = pick(memetips)

	if(m)
		to_chat(world, "<span class='purple'><b>Tip of the round: </b>[html_encode(m)]</span>")

/datum/controller/subsystem/ticker/proc/send_fact_of_the_round()
	var/factoid
	if(selected_fact)
		factoid = selected_fact
	else
		var/list/random_facts = file2list("strings/facts.txt")
		if(length(random_facts))
			factoid = pick(random_facts)

	if(length(factoid))
		to_chat(world, "<span class='green'><b>Fact of the round: </b>[html_encode(factoid)]</span>")

/datum/controller/subsystem/ticker/proc/declare_completion()
	GLOB.nologevent = TRUE //end of round murder and shenanigans are legal; there's no need to jam up attack logs past this point.
	GLOB.disable_explosions = TRUE // that said, if people want to be """FUNNY""" and bomb at EORG, they can fuck themselves up
	set_observer_default_invisibility(0) //spooks things up
	//Round statistics report
	var/datum/station_state/ending_station_state = new /datum/station_state()
	ending_station_state.count()
	var/station_integrity = min(round( 100.0 *  GLOB.start_state.score(ending_station_state), 0.1), 100.0)

	var/list/end_of_round_info = list()
	end_of_round_info += "<BR>[TAB]Shift Duration: <B>[round(ROUND_TIME / 36000)]:[add_zero("[ROUND_TIME / 600 % 60]", 2)]:[ROUND_TIME / 100 % 6][ROUND_TIME / 100 % 10]</B>"
	end_of_round_info += "<BR>[TAB]Station Integrity: <B>[mode.station_was_nuked ? "<font color='red'>Destroyed</font>" : "[station_integrity]%"]</B>"
	end_of_round_info += "<BR>"

	//Silicon laws report
	for(var/mob/living/silicon/ai/aiPlayer in GLOB.ai_list)
		var/ai_ckey = safe_get_ckey(aiPlayer)

		if(aiPlayer.stat != DEAD)
			end_of_round_info += "<b>[aiPlayer.name] (Played by: [ai_ckey])'s laws at the end of the game were:</b>"
		else
			end_of_round_info += "<b>[aiPlayer.name] (Played by: [ai_ckey])'s laws when it was deactivated were:</b>"
		aiPlayer.laws_sanity_check()
		for(var/datum/ai_law/law as anything in aiPlayer.laws.sorted_laws)
			if(law == aiPlayer.laws.zeroth_law)
				end_of_round_info += "<span class='danger'>[law.get_index()]. [law.law]</span>"
			else
				end_of_round_info += "[law.get_index()]. [law.law]"

		if(length(aiPlayer.connected_robots))
			end_of_round_info += "<b>The AI's loyal minions were:</b> "
			for(var/mob/living/silicon/robot/robo in aiPlayer.connected_robots)
				var/robo_ckey = safe_get_ckey(robo)
				end_of_round_info += "[robo.name][robo.stat ? " (Deactivated)" : ""] (Played by: [robo_ckey])"

	var/dronecount = 0

	for(var/mob/living/silicon/robot/robo in GLOB.mob_list)

		if(isdrone(robo))
			dronecount++
			continue

		var/robo_ckey = safe_get_ckey(robo)

		if(!robo.connected_ai)
			if(robo.stat != DEAD)
				end_of_round_info += "<b>[robo.name] (Played by: [robo_ckey]) survived as an AI-less borg! Its laws were:</b>"
			else
				end_of_round_info += "<b>[robo.name] (Played by: [robo_ckey]) was unable to survive the rigors of being a cyborg without an AI. Its laws were:</b>"

			robo.laws_sanity_check()
			for(var/datum/ai_law/law as anything in robo.laws.sorted_laws)
				if(law == robo.laws.zeroth_law)
					end_of_round_info += "<span class='danger'>[law.get_index()]. [law.law]</span>"
				else
					end_of_round_info += "[law.get_index()]. [law.law]"

	if(dronecount)
		end_of_round_info += "<b>There [dronecount > 1 ? "were" : "was"] [dronecount] industrious maintenance [dronecount > 1 ? "drones" : "drone"] this round.</b>"

	if(length(mode.eventmiscs))
		for(var/datum/mind/eventmind in mode.eventmiscs)
			end_of_round_info += printeventplayer(eventmind)
			end_of_round_info += printobjectives(eventmind)
		end_of_round_info += "<br>"

	mode.declare_completion()//To declare normal completion.

	end_of_round_info += mode.get_end_of_round_antagonist_statistics()

	for(var/datum/team/team in GLOB.antagonist_teams)
		team.on_round_end()

	// Save the data before end of the round griefing
	SSpersistent_data.save()
	to_chat(world, end_of_round_info.Join("<br>"))

	// Display the scoreboard window
	score.scoreboard()

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

	var/static/list/base_encouragement_messages = list(
		"Keep on keeping on!",
		"Great job!",
		"Keep up the good work!",
		"Nice going!"
	)

	var/static/list/special_encouragement_messages = list(
		"Outstanding!",
		"This is going on the fridge!",
		"Looks like you're popular!",
		"That's what we like to see!",
		"Hell yeah, brother!",
		"Honestly, quite incredible!"
	)

	// Tell people how many kudos they got this round
	// Besides, what's another loop over the /entire player list/
	var/kudos_message
	for(var/mob/M in GLOB.player_list)
		var/kudos = M.client?.persistent.kudos_received_from
		if(length(kudos))
			kudos_message = pick(length(kudos) > 5 ? special_encouragement_messages : base_encouragement_messages)
			to_chat(M, "<span class='green big'>You received <b>[length(kudos)]</b> kudos from other players this round! [kudos_message]</span>")

	// Seal the blackbox, stop collecting info
	SSblackbox.Seal()
	SSdbcore.SetRoundEnd()

	return TRUE

/datum/controller/subsystem/ticker/proc/HasRoundStarted()
	return current_state >= GAME_STATE_PLAYING

/datum/controller/subsystem/ticker/proc/IsRoundInProgress()
	return current_state == GAME_STATE_PLAYING


/datum/controller/subsystem/ticker/proc/setup_news_feeds()
	for(var/feed_channel_type in subtypesof(/datum/feed_channel))
		GLOB.news_network.channels += new feed_channel_type

	for(var/loc_type in subtypesof(/datum/trade_destination))
		var/datum/trade_destination/D = new loc_type
		GLOB.weighted_randomevent_locations[D] = length(D.viable_random_events)
		GLOB.weighted_mundaneevent_locations[D] = length(D.viable_mundane_events)

// Easy handler to make rebooting the world not a massive sleep in world/Reboot()
/datum/controller/subsystem/ticker/proc/reboot_helper(reason, end_string, delay)
	// Admins delayed round end. Just alert and dont bother with anything else.
	if(delay_end)
		to_chat(world, "<span class='boldannounceooc'>An admin has delayed the round end.</span>")
		return
	if(delay)
		INVOKE_ASYNC(src, TYPE_PROC_REF(/datum/controller/subsystem/ticker, show_server_restart_blurb), reason)

	if(!isnull(delay))
		// Delay time was present. Use that.
		delay = max(0, delay)
	else
		// Use default restart timeout
		delay = max(0, GLOB.configuration.general.restart_timeout SECONDS)

	to_chat(world, "<span class='boldannounceooc'>Rebooting world in [delay/10] [delay > 10 ? "seconds" : "second"]. [reason]</span>")

	real_reboot_time = world.time + delay
	UNTIL(world.time > real_reboot_time) // Hold it here

	// And if we re-delayed, bail again
	if(delay_end)
		to_chat(world, "<span class='boldannounceooc'>Reboot was cancelled by an admin.</span>")
		return

	if(end_string)
		end_state = end_string

	// Play a haha funny noise for those who want to hear it :)
	var/round_end_sound = pick(GLOB.round_end_sounds)
	var/sound_length = GLOB.round_end_sounds[round_end_sound]

	for(var/mob/M in GLOB.player_list)
		if(!(M.client.prefs.sound & SOUND_MUTE_END_OF_ROUND))
			SEND_SOUND(M, round_end_sound)

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

		log_text += "<small>- <a href='byond://?priv_msg=[ckey]'>[ckey]</a>: [AR.infraction_count]</small>"

	log_text += "Investigation advised if there are a high number of infractions"

	message_admins(log_text.Join("<br>"))

	// Now do a ton of saves
	SSdbcore.MassExecute(save_queries, TRUE, TRUE, TRUE)

	// And cleanup
	QDEL_LIST_ASSOC_VAL(load_queries)
	records.Cut()
	flagged_antag_rollers.Cut()

/// This proc is for recording biohazard events, and blackboxing if they lived,
/// died, or ended the round. This currently applies to: Terror spiders,
/// Xenomorphs, and Blob.
///
/// This code is predicated on the assumption that multiple midrounds
/// of the same type are either extremely rare or impossible. We don't want to get
/// into the insanity of trying to record if the first xeno biohazard was defeated
/// but the second xeno biohazard was nuked.
/datum/controller/subsystem/ticker/proc/record_biohazard_results()
	for(var/biohazard in SSevents.biohazards_this_round)
		if(biohazard_active_threat(biohazard))
			SSblackbox.record_feedback("nested tally", "biohazards", 1, list("survived", biohazard))
		else
			SSblackbox.record_feedback("nested tally", "biohazards", 1, list("defeated", biohazard))

	for(var/biohazard in SSticker.biohazard_included_admin_spawns)
		SSblackbox.record_feedback("nested tally", "biohazards", 1, list("included_admin_spawns", biohazard))

/datum/controller/subsystem/ticker/proc/count_xenomorps()
	. = 0
	for(var/datum/mind/xeno_mind in SSticker.mode.xenos)
		if(xeno_mind.current?.stat == DEAD)
			continue
		.++

/datum/controller/subsystem/ticker/proc/sample_biohazard_population(biohazard)
	SSblackbox.record_feedback("ledger", "biohazard_pop_[BIOHAZARD_POP_INTERVAL_STR]_interval", biohazard_count(biohazard), biohazard)
	if(any_admin_spawned_mobs(biohazard) && !(biohazard in biohazard_included_admin_spawns))
		biohazard_included_admin_spawns[biohazard] = TRUE

	biohazard_pop_times[biohazard] = world.time

/// Record the initial time that a biohazard spawned.
/datum/controller/subsystem/ticker/proc/record_biohazard_start(biohazard)
	SSblackbox.record_feedback("associative", "biohazard_starts", 1, list("type" = biohazard, "time_ds" = world.time - time_game_started))
	sample_biohazard_population(biohazard)

/// Returns whether the given biohazard includes mobs that were admin spawned.
/// Only returns TRUE or FALSE, does not attempt to track which mobs were
/// admin-spawned and which ones weren't.
/datum/controller/subsystem/ticker/proc/any_admin_spawned_mobs(biohazard)
	switch(biohazard)
		if(TS_INFESTATION_GREEN_SPIDER, TS_INFESTATION_WHITE_SPIDER, TS_INFESTATION_PRINCESS_SPIDER, TS_INFESTATION_QUEEN_SPIDER, TS_INFESTATION_PRINCE_SPIDER)
			for(var/mob/living/simple_animal/hostile/poison/terror_spider/S in GLOB.ts_spiderlist)
				if(S.admin_spawned)
					return TRUE
		if(BIOHAZARD_XENO)
			for(var/datum/mind/xeno_mind in SSticker.mode.xenos)
				if(xeno_mind.current?.admin_spawned)
					return TRUE
		if(BIOHAZARD_BLOB)
			for(var/atom/blob_overmind in SSticker.mode.blob_overminds)
				if(blob_overmind.admin_spawned)
					return TRUE
		if(INCURSION_DEMONS)
			for(var/obj/portal in SSticker.mode.incursion_portals)
				if(portal.admin_spawned)
					return TRUE

/datum/controller/subsystem/ticker/proc/biohazard_count(biohazard)
	switch(biohazard)
		if(TS_INFESTATION_GREEN_SPIDER, TS_INFESTATION_WHITE_SPIDER, TS_INFESTATION_PRINCESS_SPIDER, TS_INFESTATION_QUEEN_SPIDER)
			var/spiders = 0
			for(var/mob/living/simple_animal/hostile/poison/terror_spider/S in GLOB.ts_spiderlist)
				if(S.ckey)
					spiders++
			return spiders
		if(TS_INFESTATION_PRINCE_SPIDER)
			return length(GLOB.ts_spiderlist)
		if(BIOHAZARD_XENO)
			return count_xenomorps()
		if(BIOHAZARD_BLOB)
			return length(SSticker.mode.blob_overminds)
		if(INCURSION_DEMONS)
			return length(SSticker.mode.incursion_portals)

	CRASH("biohazard_count got unexpected [biohazard]")

/// Return whether or not a given biohazard is an active threat.
/// For blobs, this is simply if there are any overminds left. For terrors and
/// xenomorphs, this is whether they have overwhelming numbers.
/datum/controller/subsystem/ticker/proc/biohazard_active_threat(biohazard)
	var/count = biohazard_count(biohazard)
	switch(biohazard)
		if(TS_INFESTATION_GREEN_SPIDER, TS_INFESTATION_WHITE_SPIDER, TS_INFESTATION_PRINCESS_SPIDER, TS_INFESTATION_QUEEN_SPIDER)
			return count >= 5
		if(TS_INFESTATION_PRINCE_SPIDER)
			return count > 0
		if(BIOHAZARD_XENO)
			return count > 5
		if(BIOHAZARD_BLOB)
			return count > 0
		if(INCURSION_DEMONS)
			return count > 0

	return FALSE
