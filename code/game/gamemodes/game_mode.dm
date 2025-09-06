/*
 * GAMEMODES (by Rastaf0)
 *
 * In the new mode system all special roles are fully supported.
 * You can have proper wizards/traitors/changelings/cultists during any mode.
 * Only two things really depends on gamemode:
 * 1. Starting roles, equipment and preparations
 * 2. Conditions of finishing the round.
 *
 */


/datum/game_mode
	var/name = "invalid"
	var/config_tag = null
	var/intercept_hacked = FALSE
	var/votable = TRUE
	/// This var is solely to track gamemodes to track suicides/cryoing/etc and doesnt declare this a "free for all" gamemode. This is for data tracking purposes only.
	var/tdm_gamemode = FALSE
	var/probability = 0
	var/station_was_nuked = FALSE //see nuclearbomb.dm and malfunction.dm
	var/explosion_in_progress = FALSE //sit back and relax
	var/list/restricted_jobs = list()	// Jobs it doesn't make sense to be.  I.E chaplain or AI cultist
	var/list/secondary_restricted_jobs = list() // Same as above, but for secondary antagonists
	var/list/protected_jobs = list()	// Jobs that can't be traitors
	/// Species that will become mindflayers if they're picked, instead of the regular antagonist
	var/list/species_to_mindflayer = list()
	var/required_players = 0
	var/required_enemies = 0
	var/recommended_enemies = 0
	var/secondary_enemies = 0
	var/secondary_enemies_scaling = 0 // Scaling rate of secondary enemies
	var/newscaster_announcements = null
	var/ert_disabled = FALSE
	var/uplink_welcome = "Syndicate Uplink Console:"

	var/list/player_draft_log = list()
	var/list/datum/mind/xenos = list()
	var/list/datum/mind/eventmiscs = list()
	var/list/blob_overminds = list()
	var/list/incursion_portals = list()

	var/list/datum/station_goal/station_goals = list() // A list of all station goals for this game mode
	var/list/secondary_goal_grab_bags = null // Once initialized, contains an associative list of department_name -> list(secondary_goal_type). When a goal is requested, a type will be pulled out of the department's grab bag. When the bag is empty, it will be refilled from the list of all goals in that department, with the amount of each set to the type's weight, max 10.
	var/list/datum/station_goal/secondary/secondary_goals = list() // A list of all secondary goals issued

	/// Each item in this list can only be rolled once on average.
	var/list/single_antag_positions = list("Head of Personnel", "Chief Engineer", "Research Director", "Chief Medical Officer", "Quartermaster")

	/// A list of all minds which have the traitor antag datum.
	var/list/datum/mind/traitors = list()
	/// An associative list with mindslave minds as keys and their master's minds as values.
	var/list/datum/mind/implanted = list()
	/// A list of all minds which have the changeling antag datum
	var/list/datum/mind/changelings = list()
	/// A list of all minds which have the vampire antag datum
	var/list/datum/mind/vampires = list()
	/// A list of all minds which are thralled by a vampire
	var/list/datum/mind/vampire_enthralled = list()
	/// A list of all minds which have the mindflayer antag datum
	var/list/datum/mind/mindflayers = list()

	/// A list containing references to the minds of soon-to-be traitors. This is seperate to avoid duplicate entries in the `traitors` list.
	var/list/datum/mind/pre_traitors = list()
	/// A list containing references to the minds of soon-to-be changelings. This is seperate to avoid duplicate entries in the `changelings` list.
	var/list/datum/mind/pre_changelings = list()
	///list of minds of soon to be vampires
	var/list/datum/mind/pre_vampires = list()
	/// A list containing references to the minds of soon-to-be mindflayers.
	var/list/datum/mind/pre_mindflayers = list()
	/// A list of all minds which have the wizard special role
	var/list/datum/mind/wizards = list()
	/// A list of all minds that are wizard apprentices
	var/list/datum/mind/apprentices = list()

	/// The cult team datum
	var/datum/team/cult/cult_team

	/// How many abductor teams do we have
	var/abductor_teams = 0
	/// A list which contains the minds of all abductors
	var/list/datum/mind/abductors = list()
	/// A list which contains the minds of all abductees
	var/list/datum/mind/abductees = list()
	/// A list which contains the all the abductor teams
	var/list/datum/team/abductor/actual_abductor_teams = list()

	/// A list of all the nuclear operatives' minds
	var/list/datum/mind/syndicates = list()

	/// A list of all the minds of head revolutionaries
	var/list/datum/mind/head_revolutionaries = list()
	/// A list of all the minds of revolutionaries
	var/list/datum/mind/revolutionaries = list()
	/// The revololution team datum
	var/datum/team/revolution/rev_team

	/// A list of all the minds with the superhero special role
	var/list/datum/mind/superheroes = list()
	/// A list of all the minds with the supervillain special role
	var/list/datum/mind/supervillains = list()
	/// A list of all the greyshirt minds
	var/list/datum/mind/greyshirts = list()

	/// A list of all the minds that have the ERT special role
	var/list/datum/mind/ert = list()

	/// A list of all minds that are zombies
	var/list/datum/mind/zombies = list()
	/// A list of all minds that are infected with the zombie virus, but aren't zombies yet
	var/list/datum/mind/zombie_infected = list()

/datum/game_mode/proc/announce() //to be calles when round starts
	to_chat(world, "<B>Notice</B>: [src] did not define announce()")


///can_start()
///Checks to see if the game can be setup and ran with the current number of players or whatnot.
/datum/game_mode/proc/can_start()
	var/playerC = 0
	for(var/mob/new_player/player in GLOB.player_list)
		if((player.client) && (player.ready))
			playerC++

	if(!GLOB.configuration.gamemode.enable_gamemode_player_limit || (playerC >= required_players))
		return TRUE
	return FALSE

///pre_setup()
///Attempts to select players for special roles the mode might have.
/datum/game_mode/proc/pre_setup()
	return TRUE


///post_setup()
///Everyone should now be on the station and have their normal gear.  This is the place to give the special roles extra things
/datum/game_mode/proc/post_setup()

	spawn (ROUNDSTART_LOGOUT_REPORT_TIME)
		display_roundstart_logout_report()

	INVOKE_ASYNC(src, PROC_REF(set_mode_in_db)) // Async query), dont bother slowing roundstart

	generate_station_goals()
	generate_station_trait_report()

	GLOB.start_state = new /datum/station_state()
	GLOB.start_state.count()

	for(var/datum/mind/flayer as anything in pre_mindflayers) //Mindflayers need to be all the way out here since they could come from most gamemodes
		flayer.make_mind_flayer()

	return TRUE

///process()
///Called by the gameticker
/datum/game_mode/process()
	return FALSE

// I wonder what this could do guessing by the name
/datum/game_mode/proc/set_mode_in_db()
	if(SSticker?.mode && SSdbcore.IsConnected())
		var/datum/db_query/query_round_game_mode = SSdbcore.NewQuery("UPDATE round SET game_mode=:gm WHERE id=:rid", list(
			"gm" = SSticker.mode.name,
			"rid" = GLOB.round_id
		))
		// We dont do anything with output. Dont bother wrapping with if()
		query_round_game_mode.warn_execute()
		qdel(query_round_game_mode)

/datum/game_mode/proc/check_finished() //to be called by ticker
	if((SSshuttle.emergency && SSshuttle.emergency.mode >= SHUTTLE_ENDGAME) || station_was_nuked)
		return 1
	return 0

/datum/game_mode/proc/declare_completion()
	var/clients = 0
	var/surviving_humans = 0
	var/surviving_total = 0
	var/ghosts = 0
	var/escaped_humans = 0
	var/escaped_total = 0
	var/escaped_on_pod_1 = 0
	var/escaped_on_pod_2 = 0
	var/escaped_on_pod_3 = 0
	var/escaped_on_pod_4 = 0
	var/escaped_on_shuttle = 0

	var/list/area/escape_locations = list(
		/area/shuttle/escape,
		/area/shuttle/pod_1,
		/area/shuttle/pod_2,
		/area/shuttle/pod_3,
		/area/shuttle/pod_4
	)

	if(SSshuttle.emergency.mode < SHUTTLE_ENDGAME) //shuttle didn't get to centcom
		escape_locations -= /area/shuttle/escape

	for(var/mob/M in GLOB.player_list)
		if(M.client)
			clients++
			if(ishuman(M))
				if(!M.stat)
					surviving_humans++
					if(M.loc && M.loc.loc && (M.loc.loc.type in escape_locations))
						escaped_humans++
			if(!M.stat)
				surviving_total++
				if(M.loc && M.loc.loc && (M.loc.loc.type in escape_locations))
					escaped_total++

				if(M.loc && M.loc.loc && M.loc.loc.type == SSshuttle.emergency.areaInstance.type && SSshuttle.emergency.mode >= SHUTTLE_ENDGAME)
					escaped_on_shuttle++

				if(M.loc && M.loc.loc && M.loc.loc.type == /area/shuttle/pod_1)
					escaped_on_pod_1++
				if(M.loc && M.loc.loc && M.loc.loc.type == /area/shuttle/pod_2)
					escaped_on_pod_2++
				if(M.loc && M.loc.loc && M.loc.loc.type == /area/shuttle/pod_3)
					escaped_on_pod_3++
				if(M.loc && M.loc.loc && M.loc.loc.type == /area/shuttle/pod_4)
					escaped_on_pod_4++

			if(isobserver(M))
				ghosts++

	if(clients)
		SSblackbox.record_feedback("nested tally", "round_end_stats", clients, list("clients"))
	if(ghosts)
		SSblackbox.record_feedback("nested tally", "round_end_stats", ghosts, list("ghosts"))
	if(surviving_humans)
		SSblackbox.record_feedback("nested tally", "round_end_stats", surviving_humans, list("survivors", "human"))
	if(surviving_total)
		SSblackbox.record_feedback("nested tally", "round_end_stats", surviving_total, list("survivors", "total"))
	if(escaped_humans)
		SSblackbox.record_feedback("nested tally", "round_end_stats", escaped_humans, list("escapees", "human"))
	if(escaped_total)
		SSblackbox.record_feedback("nested tally", "round_end_stats", escaped_total, list("escapees", "total"))
	if(escaped_on_shuttle)
		SSblackbox.record_feedback("nested tally", "round_end_stats", escaped_on_shuttle, list("escapees", "on_shuttle"))
	if(escaped_on_pod_1)
		SSblackbox.record_feedback("nested tally", "round_end_stats", escaped_on_pod_1, list("escapees", "on_pod_1"))
	if(escaped_on_pod_2)
		SSblackbox.record_feedback("nested tally", "round_end_stats", escaped_on_pod_2, list("escapees", "on_pod_2"))
	if(escaped_on_pod_3)
		SSblackbox.record_feedback("nested tally", "round_end_stats", escaped_on_pod_3, list("escapees", "on_pod_3"))
	if(escaped_on_pod_4)
		SSblackbox.record_feedback("nested tally", "round_end_stats", escaped_on_pod_4, list("escapees", "on_pod_4"))
	for(var/tech_id in SSeconomy.tech_levels)
		SSblackbox.record_feedback("tally", "cargo max tech level sold", SSeconomy.tech_levels[tech_id], tech_id)

	var/round_text = GLOB.round_id ? "Round [GLOB.round_id]" : "Unknown Round"
	GLOB.discord_manager.send2discord_simple(DISCORD_WEBHOOK_PRIMARY, "[round_text] of [get_webhook_name()] has ended - [surviving_total] survivors, [ghosts] ghosts.")
	if(SSredis.connected)
		// Send our presence to required channels
		var/list/presence_data = list()
		presence_data["author"] = "system"
		presence_data["source"] = GLOB.configuration.system.instance_id
		presence_data["message"] = "Round [GLOB.round_id] ended at `[SQLtime()]`"

		var/presence_text = json_encode(presence_data)

		for(var/channel in list("byond.asay", "byond.msay")) // Channels to announce to
			SSredis.publish(channel, presence_text)

		// Report detailed presence info to system
		var/list/presence_data_2 = list()
		presence_data_2["source"] = GLOB.configuration.system.instance_id
		presence_data_2["round_id"] = GLOB.round_id
		presence_data_2["event"] = "round_end"
		SSredis.publish("byond.system", json_encode(presence_data_2))

	return 0


/datum/game_mode/proc/check_win() //universal trigger to be called at mob death, nuke explosion, etc. To be called from everywhere.
	if(rev_team)
		rev_team.check_all_victory()

/datum/game_mode/proc/get_players_for_role(role, override_jobbans = FALSE, species_exclusive = null)
	var/list/players = list()
	var/list/candidates = list()

	// Assemble a list of active players without jobbans.
	for(var/mob/new_player/player in GLOB.player_list)
		if(player.client && player.ready)
			if(!jobban_isbanned(player, ROLE_SYNDICATE) && !jobban_isbanned(player, role))
				if(player_old_enough_antag(player.client,role))
					players += player

	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(jobban_isbanned(player, ROLE_SYNDICATE) || jobban_isbanned(player, role))
			continue
		if(player_old_enough_antag(player.client, role))
			players += player

	// Shuffle the players list so that it becomes ping-independent.
	players = shuffle(players)
	// Get a list of all the people who want to be the antagonist for this round
	for(var/mob/eligible_player in players)
		if(!eligible_player.client.persistent.skip_antag)
			if(species_exclusive && (eligible_player.client.prefs.active_character.species != species_exclusive))
				continue
			if(role in eligible_player.client.prefs.be_special)
				player_draft_log += "[eligible_player.key] had [role] enabled, so we are drafting them."
				candidates += eligible_player.mind
				players -= eligible_player

	// Remove candidates who want to be antagonist but have a job (or other antag datum) that precludes it
	if(restricted_jobs)
		for(var/datum/mind/player_mind in candidates)
			if((player_mind.assigned_role in restricted_jobs) || player_mind.special_role)
				candidates -= player_mind


	return candidates		// Returns: The number of people who had the antagonist role set to yes, regardless of recomended_enemies, if that number is greater than recommended_enemies
							//			recommended_enemies if the number of people with that role set to yes is less than recomended_enemies,
							//			Less if there are not enough valid players in the game entirely to make recommended_enemies.

// Just the above proc but for alive players
/**
 * DEPRECATED!
 * Gets all alive players for a specific role. Disables offstation roles by default
 */
/datum/game_mode/proc/get_alive_players_for_role(role, override_jobbans = FALSE, allow_offstation_roles = FALSE)
	var/list/players = list()
	var/list/candidates = list()

	// Assemble a list of active players without jobbans.
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(!player.client || (locate(player) in SSafk.afk_players))
			continue
		if(!jobban_isbanned(player, ROLE_SYNDICATE) && !jobban_isbanned(player, role))
			players += player

	// Shuffle the players list so that it becomes ping-independent.
	players = shuffle(players)

	// Get a list of all the people who want to be the antagonist for this round, except those with incompatible species, and those who are already antagonists
	for(var/mob/living/carbon/human/player in players)
		if(player.client.persistent.skip_antag || !(allow_offstation_roles || !player.mind?.offstation_role) || player.mind?.special_role)
			continue

		if(!(role in player.client.prefs.be_special) || (player.client.prefs.active_character.species in species_to_mindflayer))
			continue

		player_draft_log += "[player.key] had [role] enabled, so we are drafting them."
		candidates += player.mind
		players -= player

	// Remove candidates who want to be antagonist but have a job that precludes it
	if(restricted_jobs)
		for(var/datum/mind/player in candidates)
			if(player.assigned_role in restricted_jobs)
				candidates -= player
	return candidates

/datum/game_mode/proc/latespawn(mob)
	if(rev_team)
		rev_team.update_team_objectives()
		rev_team.process_promotion(REVOLUTION_PROMOTION_OPTIONAL)

/datum/game_mode/proc/num_players()
	. = 0
	for(var/mob/new_player/P in GLOB.player_list)
		if(P.client && P.ready)
			.++

/datum/game_mode/proc/num_players_started()
	. = 0
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.client)
			.++

///////////////////////////////////
//Keeps track of all living heads//
///////////////////////////////////
/datum/game_mode/proc/get_living_heads()
	. = list()
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/player = thing
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in GLOB.command_head_positions))
			. |= player.mind


////////////////////////////
//Keeps track of all heads//
////////////////////////////
/datum/game_mode/proc/get_all_heads()
	. = list()
	for(var/mob/player in GLOB.mob_list)
		if(player.mind && (player.mind.assigned_role in GLOB.command_head_positions))
			. |= player.mind

//////////////////////////////////////////////
//Keeps track of all living security members//
//////////////////////////////////////////////
/datum/game_mode/proc/get_living_sec()
	. = list()
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/player = thing
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in GLOB.active_security_positions))
			. |= player.mind

////////////////////////////////////////
//Keeps track of all  security members//
////////////////////////////////////////
/datum/game_mode/proc/get_all_sec()
	. = list()
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/player = thing
		if(player.mind && (player.mind.assigned_role in GLOB.active_security_positions))
			. |= player.mind

/datum/game_mode/proc/check_antagonists_topic(href, href_list[])
	return 0

/datum/game_mode/New()
	newscaster_announcements = pick(GLOB.newscaster_standard_feeds)

//////////////////////////
//Reports player logouts//
//////////////////////////
/proc/display_roundstart_logout_report()
	var/msg = "<span class='notice'>Roundstart logout report</span>\n\n"
	for(var/mob/living/L in GLOB.mob_list)

		if(L.ckey)
			var/found = 0
			for(var/client/C in GLOB.clients)
				if(C.ckey == L.ckey)
					found = 1
					break
			if(!found)
				msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='#ffcc00'><b>Disconnected</b></font>)\n"


		if(L.ckey && L.client)
			if(L.client.inactivity >= (ROUNDSTART_LOGOUT_REPORT_TIME / 2))	//Connected, but inactive (alt+tabbed or something)
				msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='#ffcc00'><b>Connected, Inactive</b></font>)\n"
				continue //AFK client
			if(L.stat)
				if(L.suiciding)	//Suicider
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='red'><b>Suicide</b></font>)\n"
					SSjobs.FreeRole(L.job)
					message_admins("<b>[key_name_admin(L)]</b>, the [L.job] has been freed due to (<font color='#ffcc00'><b>Early Round Suicide</b></font>)\n")
					continue //Disconnected client
				if(L.stat == UNCONSCIOUS)
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (Dying)\n"
					continue //Unconscious
				if(L.stat == DEAD)
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (Dead)\n"
					continue //Dead

			continue //Happy connected client
		for(var/mob/dead/observer/D in GLOB.dead_mob_list)
			if(D.mind && (D.mind.is_original_mob(L) || D.mind.current == L))
				if(L.stat == DEAD)
					if(L.suiciding)	//Suicider
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<font color='red'><b>Suicide</b></font>)\n"
						continue //Disconnected client
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (Dead)\n"
						continue //Dead mob, ghost abandoned
				else
					if(D.ghost_flags & GHOST_CAN_REENTER)
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<font color='red'><b>This shouldn't appear.</b></font>)\n"
						continue //Lolwhat
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<font color='red'><b>Ghosted</b></font>)\n"
						SSjobs.FreeRole(L.job)
						message_admins("<b>[key_name_admin(L)]</b>, the [L.job] has been freed due to (<font color='#ffcc00'><b>Early Round Ghosted While Alive</b></font>)\n")
						continue //Ghosted while alive



	for(var/mob/M in GLOB.mob_list)
		if(check_rights(R_ADMIN, 0, M))
			to_chat(M, msg)

//Announces objectives/generic antag text.
/proc/show_generic_antag_text(datum/mind/player)
	if(player.current)
		to_chat(player.current, "You are an antagonist! <font color=blue>Within the rules,</font> \
		try to act as an opposing force to the crew. Further RP and try to make sure \
		other players have <i>fun</i>! If you are confused or at a loss, always adminhelp, \
		and before taking extreme actions, please try to also contact the administration! \
		Think through your actions and make the roleplay immersive! <b>Please remember all \
		rules aside from those without explicit exceptions apply to antagonists.</b>")

/proc/get_nuke_code()
	var/nukecode = "ERROR"
	for(var/obj/machinery/nuclearbomb/bomb in GLOB.nuke_list)
		if(bomb && bomb.r_code && is_station_level(bomb.z))
			nukecode = bomb.r_code
	return nukecode

/proc/get_nuke_status()
	var/nuke_status = NUKE_MISSING
	for(var/obj/machinery/nuclearbomb/bomb in GLOB.nuke_list)
		if(is_station_level(bomb.z))
			nuke_status = NUKE_CORE_MISSING
			if(bomb.core)
				nuke_status = NUKE_STATUS_INTACT
	return nuke_status

/datum/game_mode/proc/replace_jobbanned_player(mob/living/M, role_type)
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as a [role_type]?", role_type, FALSE, 10 SECONDS)
	var/mob/dead/observer/theghost = null
	if(length(candidates))
		theghost = pick(candidates)
		to_chat(M, "<span class='userdanger'>Your mob has been taken over by a ghost! Appeal your job ban if you want to avoid this in the future!</span>")
		message_admins("[key_name_admin(theghost)] has taken control of ([key_name_admin(M)]) to replace a jobbanned player.")
		M.ghostize()
		M.key = theghost.key
		dust_if_respawnable(theghost)
	else
		message_admins("[M] ([M.key]) has been converted into [role_type] with an active antagonist jobban for said role since no ghost has volunteered to take [M.p_their()] place.")
		to_chat(M, "<span class='biggerdanger'>You have been converted into [role_type] with an active jobban. Your body was offered up but there were no ghosts to take over. You will be allowed to continue as [role_type], but any further violations of the rules on your part are likely to result in a permanent ban.</span>")

/proc/printplayer(datum/mind/ply, fleecheck)
	var/jobtext = ""
	if(ply.assigned_role)
		jobtext = " the <b>[ply.assigned_role]</b>"
	var/text = "<br><b>[ply.get_display_key()]</b> was <b>[ply.name]</b>[jobtext] and "
	if(ply.current)
		if(ply.current.stat == DEAD)
			text += "<span class='bold'>died!</span>"
		else
			text += "<span class='bold'>survived</span>"
		if(fleecheck)
			var/turf/T = get_turf(ply.current)
			if(!T || !is_station_level(T.z))
				text += " while <span class='bold'>fleeing the station</span>"
		if(ply.current.real_name != ply.name)
			text += " as <b>[ply.current.real_name]!</b>"
		else
			text += "!"
	else
		text += "<span class='bold'>had [ply.p_their()] body destroyed!</span>"
	return text

/proc/printeventplayer(datum/mind/ply)
	var/text = "<b>[ply.get_display_key()]</b> was <b>[ply.name]</b>"
	if(ply.special_role != SPECIAL_ROLE_EVENTMISC)
		text += " the [ply.special_role]"
	text += " and "
	if(ply.current)
		if(ply.current.stat == DEAD)
			text += "<span class='bold'>died!</span>"
		else
			text += "<span class='bold'>survived!</span>"
	else
		text += "<span class='bold'>had [ply.p_their()] body destroyed!</span>"
	return text

/proc/printobjectives(datum/mind/ply)
	var/list/objective_parts = list()
	var/count = 1
	for(var/datum/objective/objective in ply.get_all_objectives(include_team = FALSE))
		objective_parts += "<b>Objective #[count]</b>: [objective.explanation_text]"
		count++
	return objective_parts.Join("<br>")

/datum/game_mode/proc/generate_station_goals()
	var/list/possible = list()
	for(var/T in subtypesof(/datum/station_goal))
		if(ispath(T, /datum/station_goal/secondary))
			continue
		var/datum/station_goal/G = T
		if(config_tag in initial(G.gamemode_blacklist))
			continue
		possible += G
	var/goal_weights = 0
	while(length(possible) && goal_weights < STATION_GOAL_BUDGET)
		var/datum/station_goal/picked = pick_n_take(possible)
		goal_weights += initial(picked.weight)
		station_goals += new picked

	if(length(station_goals))
		send_station_goals_message()

/datum/game_mode/proc/send_station_goals_message()
	var/message_text = "<div style='text-align:center;'><img src='ntlogo.png'>"
	message_text += "<h3>NAS Trurl Orders</h3></div><hr>"
	message_text += "<b>Special Orders for [station_name()]:</b><br><br>"

	for(var/datum/station_goal/G in station_goals)
		G.on_report()
		message_text += G.get_report()
		message_text += "<hr>"

	print_command_report(message_text, "NAS Trurl Orders", FALSE)

/datum/game_mode/proc/declare_station_goal_completion()
	for(var/datum/station_goal/goal in station_goals)
		goal.print_result()

	var/departments = list()
	for(var/datum/station_goal/secondary/goal in secondary_goals)
		if(goal.completed)
			if(!departments[goal.department])
				departments[goal.department] = 0
			departments[goal.department]++

	to_chat(world, "<b>Secondary Goals</b>:")
	var/any = FALSE
	for(var/department in departments)
		if(departments[department])
			any = TRUE
			to_chat(world, "<b>[department]</b>: <span class='greenannounce'>[departments[department]] completed!</span>")
	if(!any)
		to_chat(world, "<span class='boldannounceic'>None completed!</span>")

/datum/game_mode/proc/generate_station_trait_report()
	var/something_to_print = FALSE
	var/list/trait_list_desc = list("<hr><b>Identified shift divergencies:</b>")
	for(var/datum/station_trait/station_trait as anything in SSstation.station_traits)
		if(!station_trait.show_in_report)
			continue
		trait_list_desc += station_trait.get_report()
		something_to_print = TRUE
	if(something_to_print)
		print_command_report(trait_list_desc.Join("<br>"), "NAS Trurl Detected Divergencies", FALSE)

/// Gets the value of all end of round stats through auto_declare and returns them
/datum/game_mode/proc/get_end_of_round_antagonist_statistics()
	. = list()
	. += auto_declare_completion_traitor()
	. += auto_declare_completion_vampire()
	. += auto_declare_completion_enthralled()
	. += auto_declare_completion_mindflayer()
	. += auto_declare_completion_changeling()
	. += auto_declare_completion_nuclear()
	. += auto_declare_completion_wizard()
	. += auto_declare_completion_revolution()
	. += auto_declare_completion_abduction()
	listclearnulls(.)

/// Returns how many traitors should be added to the round
/datum/game_mode/proc/traitors_to_add()
	return 0

/**
 * DEPRECATED!
 */
/datum/game_mode/proc/fill_antag_slots()
	var/traitors_to_add = 0

	traitors_to_add += traitors_to_add()

	if(length(traitors) < traitors_to_add())
		traitors_to_add += (traitors_to_add() - length(traitors))

	if(traitors_to_add <= 0)
		return

	var/list/potential_recruits = get_alive_players_for_role(ROLE_TRAITOR)
	for(var/datum/mind/candidate as anything in potential_recruits)
		if(candidate.special_role) // no traitor vampires or changelings or traitors or wizards or ... yeah you get the deal
			potential_recruits.Remove(candidate)

	if(!length(potential_recruits))
		return

	log_admin("Attempting to add [traitors_to_add] traitors to the round. There are [length(potential_recruits)] potential recruits.")

	for(var/i in 1 to traitors_to_add)
		var/datum/mind/traitor = pick_n_take(potential_recruits)
		traitor.special_role = SPECIAL_ROLE_TRAITOR
		traitor.restricted_roles = restricted_jobs
		traitor.add_antag_datum(/datum/antagonist/traitor) // They immediately get a new objective

/datum/game_mode/proc/get_webhook_name()
	return name

/datum/game_mode/proc/on_mob_cryo(mob/sleepy_mob, obj/machinery/cryopod/cryopod)
	return
