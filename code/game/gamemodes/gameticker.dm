var/global/datum/controller/gameticker/ticker
var/round_start_time = 0

/datum/controller/gameticker
	var/const/restart_timeout = 600
	var/current_state = GAME_STATE_PREGAME
	var/force_ending = 0

	var/hide_mode = 0 // leave here at 0 ! setup() will take care of it when needed for Secret mode -walter0o
	var/datum/game_mode/mode = null
	var/event_time = null
	var/event = 0

	var/login_music // music played in pregame lobby

	var/list/datum/mind/minds = list()//The people in the game. Used for objective tracking.

	var/Bible_icon_state	// icon_state the chaplain has chosen for his bible
	var/Bible_item_state	// item_state the chaplain has chosen for his bible
	var/Bible_name			// name of the bible
	var/Bible_deity_name

	var/datum/cult_info/cultdat = null //here instead of cult for adminbus purposes

	var/random_players = 0 	// if set to nonzero, ALL players who latejoin or declare-ready join will have random appearances/genders

	var/list/syndicate_coalition = list() // list of traitor-compatible factions
	var/list/factions = list()			  // list of all factions
	var/list/availablefactions = list()	  // list of factions with openings

	var/pregame_timeleft = 0
	var/delay_end = 0	//if set to nonzero, the round will not restart on it's own

	var/triai = 0//Global holder for Triumvirate
	var/initialtpass = 0 //holder for inital autotransfer vote timer

	var/obj/screen/cinematic = null			//used for station explosion cinematic

	var/round_end_announced = 0 // Spam Prevention. Announce round end only once.\


/datum/controller/gameticker/proc/pregame()
	login_music = pick(\
	'sound/music/thunderdome.ogg',\
	'sound/music/space.ogg',\
	'sound/music/title1.ogg',\
	'sound/music/title2.ogg',\
	'sound/music/title3.ogg',)
	do
		pregame_timeleft = config.pregame_timestart
		to_chat(world, "<B><FONT color='blue'>Welcome to the pre-game lobby!</FONT></B>")
		to_chat(world, "Please, setup your character and select ready. Game will start in [pregame_timeleft] seconds")
		while(current_state == GAME_STATE_PREGAME)
			sleep(10)
			if(going)
				pregame_timeleft--

			if(pregame_timeleft <= 0)
				current_state = GAME_STATE_SETTING_UP
				Master.SetRunLevel(RUNLEVEL_SETUP)
	while(!setup())

/datum/controller/gameticker/proc/votetimer()
	var/timerbuffer = 0
	if(initialtpass == 0)
		timerbuffer = config.vote_autotransfer_initial
	else
		timerbuffer = config.vote_autotransfer_interval
	spawn(timerbuffer)
		vote.autotransfer()
		initialtpass = 1
		votetimer()

/datum/controller/gameticker/proc/setup()
	cultdat = setupcult()
	//Create and announce mode
	if(master_mode=="secret")
		src.hide_mode = 1
	var/list/datum/game_mode/runnable_modes
	if((master_mode=="random") || (master_mode=="secret"))
		runnable_modes = config.get_runnable_modes()
		if(runnable_modes.len==0)
			current_state = GAME_STATE_PREGAME
			Master.SetRunLevel(RUNLEVEL_LOBBY)
			to_chat(world, "<B>Unable to choose playable game mode.</B> Reverting to pre-game lobby.")
			return 0
		if(secret_force_mode != "secret")
			var/datum/game_mode/M = config.pick_mode(secret_force_mode)
			if(M.can_start())
				src.mode = config.pick_mode(secret_force_mode)
		job_master.ResetOccupations()
		if(!src.mode)
			src.mode = pickweight(runnable_modes)
		if(src.mode)
			var/mtype = src.mode.type
			src.mode = new mtype
	else
		src.mode = config.pick_mode(master_mode)
	if(!src.mode.can_start())
		to_chat(world, "<B>Unable to start [mode.name].</B> Not enough players, [mode.required_players] players needed. Reverting to pre-game lobby.")
		mode = null
		current_state = GAME_STATE_PREGAME
		job_master.ResetOccupations()
		Master.SetRunLevel(RUNLEVEL_LOBBY)
		return 0

	//Configure mode and assign player to special mode stuff
	src.mode.pre_pre_setup()
	var/can_continue
	can_continue = src.mode.pre_setup()//Setup special modes
	job_master.DivideOccupations() //Distribute jobs
	if(!can_continue)
		qdel(mode)
		current_state = GAME_STATE_PREGAME
		to_chat(world, "<B>Error setting up [master_mode].</B> Reverting to pre-game lobby.")
		job_master.ResetOccupations()
		Master.SetRunLevel(RUNLEVEL_LOBBY)
		return 0

	if(hide_mode)
		var/list/modes = new
		for(var/datum/game_mode/M in runnable_modes)
			modes+=M.name
		modes = sortList(modes)
		to_chat(world, "<B>The current game mode is - Secret!</B>")
		to_chat(world, "<B>Possibilities:</B> [english_list(modes)]")
	else
		src.mode.announce()

	create_characters() //Create player characters and transfer them
	collect_minds()
	equip_characters()
	data_core.manifest()
	current_state = GAME_STATE_PLAYING
	Master.SetRunLevel(RUNLEVEL_GAME)

	callHook("roundstart")

	//here to initialize the random events nicely at round start
	setup_economy()

	//shuttle_controller.setup_shuttle_docks()

	spawn(0)//Forking here so we dont have to wait for this to finish
		mode.post_setup()
		//Cleanup some stuff
		for(var/obj/effect/landmark/start/S in GLOB.landmarks_list)
			//Deleting Startpoints but we need the ai point to AI-ize people later
			if(S.name != "AI")
				qdel(S)

		// take care of random spesspod spawning
		var/list/obj/effect/landmark/spacepod/random/L = list()
		for(var/obj/effect/landmark/spacepod/random/SS in GLOB.landmarks_list)
			if(istype(SS))
				L += SS
		if(L.len)
			var/obj/effect/landmark/spacepod/random/S = pick(L)
			new /obj/spacepod/random(S.loc)
			for(var/obj/effect/landmark/spacepod/random/R in L)
				qdel(R)

		to_chat(world, "<FONT color='blue'><B>Enjoy the game!</B></FONT>")
		world << sound('sound/AI/welcome.ogg')// Skie

		if(holiday_master.holidays)
			to_chat(world, "<font color='blue'>and...</font>")
			for(var/holidayname in holiday_master.holidays)
				var/datum/holiday/holiday = holiday_master.holidays[holidayname]
				to_chat(world, "<h4>[holiday.greet()]</h4>")

	spawn(0) // Forking dynamic room selection
		var/list/area/dynamic/source/available_source_candidates = subtypesof(/area/dynamic/source)
		var/list/area/dynamic/destination/available_destination_candidates = subtypesof(/area/dynamic/destination)

		for(var/area/dynamic/destination/current_destination_candidate in available_destination_candidates)
			var/area/dynamic/destination/current_destination = locate(current_destination_candidate)

			if(!current_destination)
				continue

			if(current_destination.match_width == 0 || current_destination.match_height == 0)
				message_admins("Dynamic area destination '[current_destination.name]' does not have its size requirements set.")
				continue

			var/list/area/dynamic/source/candidate_source_areas = new /list(0)
			for(var/area/dynamic/source/candidate_source_area in available_source_candidates)
				var/area/dynamic/source/candidate_source = locate(candidate_source_area)

				if(!candidate_source)
					continue

				if(candidate_source.match_tag != current_destination.match_tag)
					continue

				if(candidate_source.match_width != current_destination.match_width || \
					candidate_source.match_height != current_destination.match_height)
					continue

				candidate_source_areas += candidate_source

			if(candidate_source_areas.len == 0)
				message_admins("Failed to find a matching source for dynamic area: [current_destination.name]")
				continue

			var/area/dynamic/source/selected_source = pick(candidate_source_areas)
			available_source_candidates -= selected_source

			selected_source.copy_contents_to(current_destination, 0)

			if(current_destination.enable_lights || selected_source.enable_lights)
				current_destination.power_light = 1
			else
				current_destination.power_light = 0
			current_destination.power_change()

	//start_events() //handles random events and space dust.
	//new random event system is handled from the MC.

	var/list/admins_number = staff_countup(R_BAN)
	if(admins_number[1] == 0 && admins_number[3] == 0)
		send2irc(config.admin_notify_irc, "Round has started with no admins online.")
	auto_toggle_ooc(0) // Turn it off
	round_start_time = world.time

	/* DONE THROUGH PROCESS SCHEDULER
	supply_controller.process() 		//Start the supply shuttle regenerating points -- TLE
	master_controller.process()		//Start master_controller.process()
	lighting_controller.process()	//Start processing DynamicAreaLighting updates
	*/

	processScheduler.start()

	if(config.sql_enabled)
		spawn(3000)
			statistic_cycle() // Polls population totals regularly and stores them in an SQL DB

	votetimer()

	for(var/mob/new_player/N in GLOB.mob_list)
		if(N.client)
			N.new_player_panel_proc()

	return 1

	//Plus it provides an easy way to make cinematics for other events. Just use this as a template :)
//Plus it provides an easy way to make cinematics for other events. Just use this as a template
/datum/controller/gameticker/proc/station_explosion_cinematic(station_missed = 0, override = null)
	if(cinematic)
		return	//already a cinematic in progress!

	auto_toggle_ooc(1) // Turn it on
	//initialise our cinematic screen object
	cinematic = new /obj/screen(src)
	cinematic.icon = 'icons/effects/station_explosion.dmi'
	cinematic.icon_state = "station_intact"
	cinematic.layer = 21
	cinematic.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	cinematic.screen_loc = "1,0"

	var/obj/structure/bed/temp_buckle = new(src)
	if(station_missed)
		for(var/mob/M in GLOB.mob_list)
			M.buckled = temp_buckle				//buckles the mob so it can't do anything
			if(M.client)
				M.client.screen += cinematic	//show every client the cinematic
	else	//nuke kills everyone on z-level 1 to prevent "hurr-durr I survived"
		for(var/mob/M in GLOB.mob_list)
			M.buckled = temp_buckle
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
		if(temp_buckle)
			qdel(temp_buckle)	//release everybody



/datum/controller/gameticker/proc/create_characters()
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


/datum/controller/gameticker/proc/collect_minds()
	for(var/mob/living/player in GLOB.player_list)
		if(player.mind)
			ticker.minds += player.mind


/datum/controller/gameticker/proc/equip_characters()
	var/captainless=1
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(player && player.mind && player.mind.assigned_role)
			if(player.mind.assigned_role == "Captain")
				captainless=0
			if(player.mind.assigned_role != player.mind.special_role)
				job_master.AssignRank(player, player.mind.assigned_role, 0)
				job_master.EquipRank(player, player.mind.assigned_role, 0)
				EquipCustomItems(player)
	if(captainless)
		for(var/mob/M in GLOB.player_list)
			if(!istype(M,/mob/new_player))
				to_chat(M, "Captainship not forced on anyone.")


/datum/controller/gameticker/proc/process()
	if(current_state != GAME_STATE_PLAYING)
		return 0

	mode.process()
	mode.process_job_tasks()

	//emergency_shuttle.process() DONE THROUGH PROCESS SCHEDULER

	var/game_finished = SSshuttle.emergency.mode >= SHUTTLE_ENDGAME || mode.station_was_nuked
	if(config.continuous_rounds)
		mode.check_finished() // some modes contain var-changing code in here, so call even if we don't uses result
	else
		game_finished |= mode.check_finished()

	if((!mode.explosion_in_progress && game_finished) || force_ending)
		current_state = GAME_STATE_FINISHED
		Master.SetRunLevel(RUNLEVEL_POSTGAME)
		auto_toggle_ooc(1) // Turn it on
		spawn
			declare_completion()

		spawn(50)
			callHook("roundend")

			if(mode.station_was_nuked)
				world.Reboot("Station destroyed by Nuclear Device.", "end_proper", "nuke")
			else
				world.Reboot("Round ended.", "end_proper", "proper completion")

	return 1

/datum/controller/gameticker/proc/getfactionbyname(var/name)
	for(var/datum/faction/F in factions)
		if(F.name == name)
			return F


/datum/controller/gameticker/proc/declare_completion()
	nologevent = 1 //end of round murder and shenanigans are legal; there's no need to jam up attack logs past this point.
	//Round statistics report
	var/datum/station_state/end_state = new /datum/station_state()
	end_state.count()
	var/station_integrity = min(round( 100.0 *  start_state.score(end_state), 0.1), 100.0)

	to_chat(world, "<BR>[TAB]Shift Duration: <B>[round(ROUND_TIME / 36000)]:[add_zero("[ROUND_TIME / 600 % 60]", 2)]:[ROUND_TIME / 100 % 6][ROUND_TIME / 100 % 10]</B>")
	to_chat(world, "<BR>[TAB]Station Integrity: <B>[mode.station_was_nuked ? "<font color='red'>Destroyed</font>" : "[station_integrity]%"]</B>")
	to_chat(world, "<BR>")

	//Silicon laws report
	for(var/mob/living/silicon/ai/aiPlayer in GLOB.mob_list)
		if(aiPlayer.stat != 2)
			to_chat(world, "<b>[aiPlayer.name] (Played by: [aiPlayer.key])'s laws at the end of the game were:</b>")
		else
			to_chat(world, "<b>[aiPlayer.name] (Played by: [aiPlayer.key])'s laws when it was deactivated were:</b>")
		aiPlayer.show_laws(1)

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

	if(ticker.mode.eventmiscs.len)
		var/emobtext = ""
		for(var/datum/mind/eventmind in ticker.mode.eventmiscs)
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
	event_manager.RoundEnd()

	return 1

/datum/controller/gameticker/proc/HasRoundStarted()
	return current_state >= GAME_STATE_PLAYING
