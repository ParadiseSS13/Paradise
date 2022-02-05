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
	var/intercept_hacked = 0
	var/votable = 1
	var/probability = 0
	var/station_was_nuked = 0 //see nuclearbomb.dm and malfunction.dm
	var/explosion_in_progress = 0 //sit back and relax
	var/list/datum/mind/modePlayer = new
	var/list/restricted_jobs = list()	// Jobs it doesn't make sense to be.  I.E chaplain or AI cultist
	var/list/protected_jobs = list()	// Jobs that can't be traitors
	var/list/protected_species = list() // Species that can't be traitors
	var/required_players = 0
	var/required_enemies = 0
	var/recommended_enemies = 0
	var/newscaster_announcements = null
	var/ert_disabled = 0
	var/uplink_welcome = "Syndicate Uplink Console:"
	var/uplink_uses = 20

	var/const/waittime_l = 600  //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)
	var/list/player_draft_log = list()
	var/list/datum/mind/xenos = list()
	var/list/datum/mind/eventmiscs = list()

	var/list/datum/station_goal/station_goals = list() // A list of all station goals for this game mode

/datum/game_mode/proc/announce() //to be calles when round starts
	to_chat(world, "<B>Notice</B>: [src] did not define announce()")


///can_start()
///Checks to see if the game can be setup and ran with the current number of players or whatnot.
/datum/game_mode/proc/can_start()
	var/playerC = 0
	for(var/mob/new_player/player in GLOB.player_list)
		if((player.client)&&(player.ready))
			playerC++

	if(playerC < required_enemies)
		return 0
	if(!config.enable_gamemode_player_limit || (playerC >= config.mode_required_players[src.config_tag]))
		return 1
	return 0

//pre_pre_setup() For when you really don't want certain jobs ingame.
/datum/game_mode/proc/pre_pre_setup()

	return 1

///pre_setup()
///Attempts to select players for special roles the mode might have.
/datum/game_mode/proc/pre_setup()

	return 1


///post_setup()
///Everyone should now be on the station and have their normal gear.  This is the place to give the special roles extra things
/datum/game_mode/proc/post_setup()

	spawn (ROUNDSTART_LOGOUT_REPORT_TIME)
		display_roundstart_logout_report()

	if(SSticker && SSticker.mode && SSdbcore.IsConnected())
		var/datum/db_query/query_round_game_mode = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET game_mode=:gm WHERE id=:rid", list(
			"gm" = SSticker.mode,
			"rid" = GLOB.round_id
		))
		if(query_round_game_mode.warn_execute())
			qdel(query_round_game_mode)

	generate_station_goals()
	GLOB.start_state = new /datum/station_state()
	GLOB.start_state.count()
	return 1

///process()
///Called by the gameticker
/datum/game_mode/process()
	return 0

//Called by the gameticker
/datum/game_mode/proc/process_job_tasks()
	var/obj/machinery/message_server/useMS = null
	if(GLOB.message_servers)
		for(var/obj/machinery/message_server/MS in GLOB.message_servers)
			if(MS.active)
				useMS = MS
				break
	for(var/mob/M in GLOB.player_list)
		if(M.mind)
			var/obj/item/pda/P=null
			for(var/obj/item/pda/check_pda in GLOB.PDAs)
				if(check_pda.owner==M.name)
					P=check_pda
					break
			var/count=0
			for(var/datum/job_objective/objective in M.mind.job_objectives)
				count++
				var/msg=""
				var/pay=0
				if(objective.per_unit && objective.units_compensated<objective.units_completed)
					var/newunits = objective.units_completed - objective.units_compensated
					msg="We see that you completed [newunits] new unit[newunits>1?"s":""] for Task #[count]! "
					pay=objective.completion_payment * newunits
					objective.units_compensated += newunits
					objective.is_completed() // So we don't get many messages regarding completion
				else if(!objective.completed)
					if(objective.is_completed())
						pay=objective.completion_payment
						msg="Task #[count] completed! "
				if(pay>0)
					if(M.mind.initial_account)
						M.mind.initial_account.credit(pay, "Payment", "\[CLASSIFIED\] Terminal #[rand(111,333)]", "[command_name()] Payroll")
						msg += "You have been sent the $[pay], as agreed."
					else
						msg += "However, we were unable to send you the $[pay] you're entitled."
					if(useMS && P)
						useMS.send_pda_message("[P.owner]", "[command_name()] Payroll", msg)

						var/datum/data/pda/app/messenger/PM = P.find_program(/datum/data/pda/app/messenger)
						PM.notify("<b>Message from [command_name()] (Payroll), </b>\"[msg]\" (<i>Unable to Reply</i>)", 0)
					break

/datum/game_mode/proc/check_finished() //to be called by ticker
	if((SSshuttle.emergency && SSshuttle.emergency.mode >= SHUTTLE_ENDGAME) || station_was_nuked)
		return 1
	return 0

/datum/game_mode/proc/cleanup()	//This is called when the round has ended but not the game, if any cleanup would be necessary in that case.
	return

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
	var/escaped_on_pod_5 = 0
	var/escaped_on_shuttle = 0

	var/list/area/escape_locations = list(/area/shuttle/escape, /area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod5/centcom)

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

				if(M.loc && M.loc.loc && M.loc.loc.type == /area/shuttle/escape_pod1/centcom)
					escaped_on_pod_1++
				if(M.loc && M.loc.loc && M.loc.loc.type == /area/shuttle/escape_pod2/centcom)
					escaped_on_pod_2++
				if(M.loc && M.loc.loc && M.loc.loc.type == /area/shuttle/escape_pod3/centcom)
					escaped_on_pod_3++
				if(M.loc && M.loc.loc && M.loc.loc.type == /area/shuttle/escape_pod5/centcom)
					escaped_on_pod_5++

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
	if(escaped_on_pod_5)
		SSblackbox.record_feedback("nested tally", "round_end_stats", escaped_on_pod_5, list("escapees", "on_pod_5"))

	SSdiscord.send2discord_simple(DISCORD_WEBHOOK_PRIMARY, "A round of [name] has ended - [surviving_total] survivors, [ghosts] ghosts.")
	return 0


/datum/game_mode/proc/check_win() //universal trigger to be called at mob death, nuke explosion, etc. To be called from everywhere.
	return 0

/datum/game_mode/proc/get_players_for_role(var/role, override_jobbans=0)
	var/list/players = list()
	var/list/candidates = list()
	//var/list/drafted = list()
	//var/datum/mind/applicant = null

	var/roletext = get_roletext(role)

	// Assemble a list of active players without jobbans.
	for(var/mob/new_player/player in GLOB.player_list)
		if(player.client && player.ready && player.has_valid_preferences())
			if(!jobban_isbanned(player, "Syndicate") && !jobban_isbanned(player, roletext))
				if(player_old_enough_antag(player.client,role))
					players += player

	// Shuffle the players list so that it becomes ping-independent.
	players = shuffle(players)

	// Get a list of all the people who want to be the antagonist for this round, except those with incompatible species
	for(var/mob/new_player/player in players)
		if(!player.client.skip_antag)
			if((role in player.client.prefs.be_special) && !(player.client.prefs.species in protected_species))
				player_draft_log += "[player.key] had [roletext] enabled, so we are drafting them."
				candidates += player.mind
				players -= player

	// If we don't have enough antags, draft people who voted for the round.
	if(candidates.len < recommended_enemies)
		for(var/key in SSvote.round_voters)
			for(var/mob/new_player/player in players)
				if(player.ckey == key)
					player_draft_log += "[player.key] voted for this round, so we are drafting them."
					candidates += player.mind
					players -= player
					break

	// Remove candidates who want to be antagonist but have a job that precludes it
	if(restricted_jobs)
		for(var/datum/mind/player in candidates)
			for(var/job in restricted_jobs)
				if(player.assigned_role == job)
					candidates -= player


	return candidates		// Returns: The number of people who had the antagonist role set to yes, regardless of recomended_enemies, if that number is greater than recommended_enemies
							//			recommended_enemies if the number of people with that role set to yes is less than recomended_enemies,
							//			Less if there are not enough valid players in the game entirely to make recommended_enemies.


/datum/game_mode/proc/latespawn(var/mob)

/*
/datum/game_mode/proc/check_player_role_pref(var/role, var/mob/player)
	if(player.preferences.be_special & role)
		return 1
	return 0
*/

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
		var/list/real_command_positions = GLOB.command_positions.Copy() - "Nanotrasen Representative"
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in real_command_positions))
			. |= player.mind


////////////////////////////
//Keeps track of all heads//
////////////////////////////
/datum/game_mode/proc/get_all_heads()
	. = list()
	for(var/mob/player in GLOB.mob_list)
		var/list/real_command_positions = GLOB.command_positions.Copy() - "Nanotrasen Representative"
		if(player.mind && (player.mind.assigned_role in real_command_positions))
			. |= player.mind

//////////////////////////////////////////////
//Keeps track of all living security members//
//////////////////////////////////////////////
/datum/game_mode/proc/get_living_sec()
	. = list()
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/player = thing
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in GLOB.security_positions))
			. |= player.mind

////////////////////////////////////////
//Keeps track of all  security members//
////////////////////////////////////////
/datum/game_mode/proc/get_all_sec()
	. = list()
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/player = thing
		if(player.mind && (player.mind.assigned_role in GLOB.security_positions))
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
		for(var/mob/dead/observer/D in GLOB.mob_list)
			if(D.mind && (D.mind.original == L || D.mind.current == L))
				if(L.stat == DEAD)
					if(L.suiciding)	//Suicider
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<font color='red'><b>Suicide</b></font>)\n"
						continue //Disconnected client
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (Dead)\n"
						continue //Dead mob, ghost abandoned
				else
					if(D.can_reenter_corpse)
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
/proc/show_generic_antag_text(var/datum/mind/player)
	if(player.current)
		to_chat(player.current, "You are an antagonist! <font color=blue>Within the rules,</font> \
		try to act as an opposing force to the crew. Further RP and try to make sure \
		other players have <i>fun</i>! If you are confused or at a loss, always adminhelp, \
		and before taking extreme actions, please try to also contact the administration! \
		Think through your actions and make the roleplay immersive! <b>Please remember all \
		rules aside from those without explicit exceptions apply to antagonists.</b>")

/proc/show_objectives(var/datum/mind/player)
	if(!player || !player.current) return

	var/obj_count = 1
	to_chat(player.current, "<span class='notice'>Your current objectives:</span>")
	for(var/datum/objective/objective in player.objectives)
		to_chat(player.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++

/proc/get_roletext(var/role)
	return role

/proc/get_nuke_code()
	var/nukecode = "ERROR"
	for(var/obj/machinery/nuclearbomb/bomb in GLOB.machines)
		if(bomb && bomb.r_code && is_station_level(bomb.z))
			nukecode = bomb.r_code
	return nukecode

/datum/game_mode/proc/replace_jobbanned_player(mob/living/M, role_type)
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as a [role_type]?", role_type, FALSE, 10 SECONDS)
	var/mob/dead/observer/theghost = null
	if(length(candidates))
		theghost = pick(candidates)
		to_chat(M, "<span class='userdanger'>Your mob has been taken over by a ghost! Appeal your job ban if you want to avoid this in the future!</span>")
		message_admins("[key_name_admin(theghost)] has taken control of ([key_name_admin(M)]) to replace a jobbanned player.")
		M.ghostize()
		M.key = theghost.key
	else
		message_admins("[M] ([M.key] has been converted into [role_type] with an active antagonist jobban for said role since no ghost has volunteered to take [M.p_their()] place.")
		to_chat(M, "<span class='biggerdanger'>You have been converted into [role_type] with an active jobban. Any further violations of the rules on your part are likely to result in a permanent ban.</span>")

/proc/printplayer(datum/mind/ply, fleecheck)
	var/jobtext = ""
	if(ply.assigned_role)
		jobtext = " the <b>[ply.assigned_role]</b>"
	var/text = "<b>[ply.key]</b> was <b>[ply.name]</b>[jobtext] and"
	if(ply.current)
		if(ply.current.stat == DEAD)
			text += " <span class='redtext'>died</span>"
		else
			text += " <span class='greentext'>survived</span>"
		if(fleecheck)
			var/turf/T = get_turf(ply.current)
			if(!T || !is_station_level(T.z))
				text += " while <span class='redtext'>fleeing the station</span>"
		if(ply.current.real_name != ply.name)
			text += " as <b>[ply.current.real_name]</b>"
	else
		text += " <span class='redtext'>had [ply.p_their()] body destroyed</span>"
	return text

/proc/printeventplayer(datum/mind/ply)
	var/text = "<b>[ply.key]</b> was <b>[ply.name]</b>"
	if(ply.special_role != SPECIAL_ROLE_EVENTMISC)
		text += " the [ply.special_role]"
	text += " and"
	if(ply.current)
		if(ply.current.stat == DEAD)
			text += " <b>died</b>"
		else
			text += " <b>survived</b>"
	else
		text += " <b>had [ply.p_their()] body destroyed</b>"
	return text

/proc/printobjectives(datum/mind/ply)
	var/list/objective_parts = list()
	var/count = 1
	for(var/datum/objective/objective in ply.objectives)
		if(objective.check_completion())
			objective_parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='greentext'>Success!</span>"
		else
			objective_parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
		count++
	return objective_parts.Join("<br>")

/datum/game_mode/proc/generate_station_goals()
	var/list/possible = list()
	for(var/T in subtypesof(/datum/station_goal))
		var/datum/station_goal/G = T
		if(config_tag in initial(G.gamemode_blacklist))
			continue
		possible += T
	var/goal_weights = 0
	while(possible.len && goal_weights < STATION_GOAL_BUDGET)
		var/datum/station_goal/picked = pick_n_take(possible)
		goal_weights += initial(picked.weight)
		station_goals += new picked

	if(station_goals.len)
		send_station_goals_message()

/datum/game_mode/proc/send_station_goals_message()
	var/message_text = "<div style='text-align:center;'><img src='ntlogo.png'>"
	message_text += "<h3>Приказания [command_name()]</h3></div><hr>"
	message_text += "<b>Особые указания для [station_name()]</b><br><br>"

	for(var/datum/station_goal/G in station_goals)
		G.on_report()
		message_text += G.get_report()
		message_text += "<hr>"

	print_command_report(message_text, "Приказания [command_name()]", FALSE)

/datum/game_mode/proc/declare_station_goal_completion()
	for(var/V in station_goals)
		var/datum/station_goal/G = V
		G.print_result()

/datum/game_mode/proc/update_eventmisc_icons_added(datum/mind/mob_mind)
	var/datum/atom_hud/antag/antaghud = GLOB.huds[ANTAG_HUD_EVENTMISC]
	antaghud.join_hud(mob_mind.current)
	set_antag_hud(mob_mind.current, "hudevent")

/datum/game_mode/proc/update_eventmisc_icons_removed(datum/mind/mob_mind)
	var/datum/atom_hud/antag/antaghud = GLOB.huds[ANTAG_HUD_EVENTMISC]
	antaghud.leave_hud(mob_mind.current)
	set_antag_hud(mob_mind.current, null)
