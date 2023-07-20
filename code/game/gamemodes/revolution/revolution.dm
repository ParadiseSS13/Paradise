// To add a rev to the list of revolutionaries, make sure it's rev (with if(ticker.mode.name == "revolution)),
// then call ticker.mode:add_revolutionary(_THE_PLAYERS_MIND_)
// nothing else needs to be done, as that proc will check if they are a valid target.
// Just make sure the converter is a head before you call it!
// To remove a rev (from brainwashing or w/e), call ticker.mode:remove_revolutionary(_THE_PLAYERS_MIND_),
// this will also check they're not a head, so it can just be called freely
// If the game somtimes isn't registering a win properly, then ticker.mode.check_win() isn't being called somewhere.

/datum/game_mode
	var/list/datum/mind/head_revolutionaries = list()
	var/list/datum/mind/revolutionaries = list()
	var/datum/team/revolution/rev_team

/datum/game_mode/revolution
	name = "revolution"
	config_tag = "revolution"
	restricted_jobs = list("Security Officer", "Warden", "Detective", "Internal Affairs Agent", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Blueshield", "Nanotrasen Representative", "Magistrate")
	required_players = 20
	required_enemies = 1
	recommended_enemies = 3

	var/finished = 0
	var/check_counter = 0
	var/list/pre_revolutionaries = list()

///////////////////////////
//Announces the game type//
///////////////////////////
/datum/game_mode/revolution/announce()
	to_chat(world, "<B>The current game mode is - Revolution!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a revolution!<BR>\nRevolutionaries - Kill the Captain, HoP, HoS, CE, RD and CMO. Convert other crewmembers (excluding the heads of staff, and security officers) to your cause by flashing them. Protect your leaders.<BR>\nPersonnel - Protect the heads of staff. Kill the leaders of the revolution, and brainwash the other revolutionaries (by beating them in the head).</B>")


///////////////////////////////////////////////////////////////////////////////
//Gets the round setup, cancelling if there's not enough players at the start//
///////////////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/pre_setup()
	var/list/datum/mind/possible_revolutionaries = get_players_for_role(ROLE_REV)

	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		restricted_jobs |= protected_jobs

	for(var/i = 1 to REVOLUTION_MAX_HEADREVS)
		if(!length(possible_revolutionaries))
			break
		var/datum/mind/new_headrev = pick_n_take(possible_revolutionaries)
		pre_revolutionaries |= new_headrev
		new_headrev.restricted_roles = restricted_jobs

	if(length(pre_revolutionaries) < required_enemies)
		return FALSE

	return TRUE


/datum/game_mode/revolution/post_setup()
	// var/list/heads = get_living_heads()
	// var/list/sec = get_living_sec()
	// var/weighted_score = min(max(round(heads.len - ((8 - sec.len) / 3)),1),max_headrevs) // some magic bullshit idk contra todo

	rev_team = new /datum/team/revolution(head_revolutionaries)

	for(var/i in 1 to rev_team.need_another_headrev(1)) //das vi danya
		if(!length(pre_revolutionaries))
			break
		var/datum/mind/new_headrev = pick_n_take(pre_revolutionaries)
		new_headrev.add_antag_datum(/datum/antagonist/rev/head)

	modePlayer += head_revolutionaries
	SSshuttle.registerHostileEnvironment(src)

	..()

/datum/game_mode/revolution/process() // to anyone who thinks "why don't we use a normal actually sane check here instead of process for checking Z level changes" It's because equip code is dogshit and you change z levels upon spawning in
	check_counter++
	if(check_counter >= 5)
		if(!finished)
			check_heads()
		check_counter = 0
	return FALSE

/datum/game_mode/revolution/proc/check_heads()
	rev_team.update_team_objectives()

/datum/game_mode/proc/get_rev_team(list/head_revolutionaries)
	if(!rev_team)
		rev_team = new /datum/team/revolution(head_revolutionaries)
	return rev_team

//////////////////////////////////////
//Checks if the revs have won or not//
//////////////////////////////////////
/datum/game_mode/revolution/check_win()
	if(check_rev_victory())
		finished = 1
	else if(check_heads_victory())
		finished = 2
	return

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/revolution/check_finished()
	if(GLOB.configuration.gamemode.disable_certain_round_early_end)
		if(finished != 0)
			SSshuttle.clearHostileEnvironment(src)
			if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
				SSshuttle.emergency.mode = SHUTTLE_DOCKED
				SSshuttle.emergency.timer = world.time
				GLOB.major_announcement.Announce("Hostile environment resolved. You have 3 minutes to board the Emergency Shuttle.", null, 'sound/AI/eshuttle_dock.ogg')
		return ..()
	if(finished != 0)
		return TRUE
	else
		return ..()

///////////////////////////////////////////////////
//Deals with converting players to the revolution//
///////////////////////////////////////////////////
/datum/game_mode/proc/add_revolutionary(datum/mind/rev_mind)
	var/mob/living/carbon/human/conversion_target = rev_mind.current
	if(rev_mind.assigned_role in GLOB.command_positions)
		return FALSE
	if(ismindshielded(conversion_target))
		return FALSE
	if((rev_mind in revolutionaries) || (rev_mind in head_revolutionaries))
		return FALSE
	if(!conversion_target)
		return FALSE
	rev_team.add_member(rev_mind)

	conversion_target.Silence(10 SECONDS)
	conversion_target.Stun(10 SECONDS)
	return TRUE
//////////////////////////////////////////////////////////////////////////////
//Deals with players being converted from the revolution (Not a rev anymore)//  // Modified to handle borged MMIs.  Accepts another var if the target is being borged at the time  -- Polymorph.
//////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/remove_revolutionary(datum/mind/rev_mind , beingborged)
	var/remove_head = FALSE
	var/mob/revolutionary = rev_mind.current
	if(beingborged && (rev_mind in head_revolutionaries))
		head_revolutionaries -= rev_mind
		remove_head = TRUE

	if((rev_mind in revolutionaries) || remove_head)
		rev_team.remove_member(rev_mind)
		if(beingborged)
			revolutionary.visible_message(
				"<span class='userdanger'>The frame beeps contentedly, purging the hostile memory engram from the MMI before initalizing it.</span>",
				"<span class='userdanger'>The frame's firmware detects and deletes your neural reprogramming! You remember nothing[remove_head ? "." : " but the name of the one who flashed you."]</span>")
			message_admins("[key_name_admin(rev_mind.current)] [ADMIN_QUE(rev_mind.current,"?")] ([ADMIN_FLW(rev_mind.current,"FLW")]) has been borged while being a [remove_head ? "leader" : " member"] of the revolution.")
		else
			revolutionary.visible_message(
				"<span class='userdanger'>[rev_mind.current] looks like [rev_mind.current.p_they()] just remembered [rev_mind.current.p_their()] real allegiance!</span>",
				"<span class='userdanger'>You have been brainwashed! You are no longer a revolutionary! Your memory is hazy from the time you were a rebel... the only thing you remember is the name of the one who brainwashed you...</span>")
			rev_mind.current.Paralyse(10 SECONDS)

//////////////////////////
//Checks for rev victory//
//////////////////////////
/datum/game_mode/revolution/proc/check_rev_victory()
	return rev_team.check_rev_victory()

/////////////////////////////
//Checks for a head victory//
/////////////////////////////
/datum/game_mode/revolution/proc/check_heads_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		var/turf/T = get_turf(rev_mind.current)
		if((rev_mind) && (rev_mind.current) && (rev_mind.current.stat != DEAD) && rev_mind.current.client && T && is_station_level(T.z))
			if(ishuman(rev_mind.current))
				return FALSE
	return TRUE

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relavent information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/declare_completion()
	if(finished == 1)
		SSticker.mode_result = "revolution win - heads killed"
		to_chat(world, "<span class='redtext'>The heads of staff were killed or exiled! The revolutionaries win!</span>")
	else if(finished == 2)
		SSticker.mode_result = "revolution loss - rev heads killed"
		to_chat(world, "<span class='redtext'>The heads of staff managed to stop the revolution!</span>")
	..()
	return TRUE

/datum/game_mode/proc/auto_declare_completion_revolution()
	var/list/targets = list()
	if(length(head_revolutionaries) || GAMEMODE_IS_REVOLUTION)
		var/num_revs = 0
		var/num_survivors = 0
		for(var/mob/living/carbon/survivor in GLOB.alive_mob_list)
			if(survivor.ckey)
				num_survivors++
				if(survivor?.mind.has_antag_datum(/datum/antagonist/rev))
					num_revs++
		if(num_survivors)
			to_chat(world, "[TAB]Command's Approval Rating: <B>[100 - round((num_revs/num_survivors)*100, 0.1)]%</B>") // % of loyal crew
		var/text = "<br><font size=3><b>The head revolutionaries were:</b></font>"
		for(var/datum/mind/headrev in head_revolutionaries)
			text += printplayer(headrev, 1)
		text += "<br>"
		to_chat(world, text)

	// if(revolutionaries.len || GAMEMODE_IS_REVOLUTION)
	// 	var/text = "<br><font size=3><b>The revolutionaries were:</b></font>"
	// 	for(var/datum/mind/rev in revolutionaries)
	// 		text += printplayer(rev, 1)
	// 	text += "<br>"
	// 	to_chat(world, text)

	if(length(head_revolutionaries) || length(revolutionaries) || GAMEMODE_IS_REVOLUTION )
		var/text = "<br><font size=3><b>The heads of staff were:</b></font>"
		var/list/heads = get_all_heads()
		for(var/datum/mind/head in heads)
			var/target = (head in targets)
			if(target)
				text += "<span class='boldannounce'>Target</span>"
			text += printplayer(head, 1)
		text += "<br>"
		to_chat(world, text)

/datum/game_mode/revolution/set_scoreboard_vars()
	var/datum/scoreboard/scoreboard = SSticker.score
	var/foecount = 0

	for(var/datum/mind/M in SSticker.mode.head_revolutionaries)
		foecount++
		if(!M || !M.current)
			scoreboard.score_ops_killed++
			continue

		if(M.current.stat == DEAD)
			scoreboard.score_ops_killed++

		else if(M.current.restrained())
			scoreboard.score_arrested++

	if(foecount == scoreboard.score_arrested)
		scoreboard.all_arrested = TRUE

	for(var/datum/mind/head_mind in get_all_heads())
		var/mob/living/carbon/human/H = head_mind.current
		if(H.stat == DEAD)
			scoreboard.score_dead_command++


	var/arrestpoints = scoreboard.score_arrested * 1000
	var/killpoints = scoreboard.score_ops_killed * 500
	var/comdeadpts = scoreboard.score_dead_command * 500
	if(scoreboard.score_greentext)
		scoreboard.crewscore -= 10000

	scoreboard.crewscore += arrestpoints
	scoreboard.crewscore += killpoints
	scoreboard.crewscore -= comdeadpts


/datum/game_mode/revolution/get_scoreboard_stats()
	var/datum/scoreboard/scoreboard = SSticker.score
	var/foecount = 0
	var/comcount = 0
	var/revcount = 0
	var/loycount = 0
	for(var/datum/mind/M in SSticker.mode:head_revolutionaries)
		if(M.current && M.current.stat != DEAD)
			foecount++
	for(var/datum/mind/M in SSticker.mode:revolutionaries)
		if(M.current && M.current.stat != DEAD)
			revcount++

	var/list/real_command_positions = GLOB.command_positions.Copy() - "Nanotrasen Representative"
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/player = thing
		if(player.mind)
			if(player.mind.assigned_role in real_command_positions)
				if(player.stat != DEAD)
					comcount++
				continue
			if(player.mind in SSticker.mode.revolutionaries)
				continue
			loycount++

	for(var/beepboop in GLOB.silicon_mob_list)
		var/mob/living/silicon/X = beepboop
		if(X.stat != DEAD)
			loycount++


	var/dat = ""

	dat += "<b><u>Mode Statistics</u></b><br>"
	dat += "<b>Number of Surviving Revolution Heads:</b> [foecount]<br>"
	dat += "<b>Number of Surviving Command Staff:</b> [comcount]<br>"
	dat += "<b>Number of Surviving Revolutionaries:</b> [revcount]<br>"
	dat += "<b>Number of Surviving Loyal Crew:</b> [loycount]<br>"

	dat += "<br>"
	dat += "<b>Revolution Heads Arrested:</b> [scoreboard.score_arrested] ([scoreboard.score_arrested * 1000] Points)<br>"
	dat += "<b>All Revolution Heads Arrested:</b> [scoreboard.all_arrested ? "Yes" : "No"] (Score tripled)<br>"

	dat += "<b>Revolution Heads Slain:</b> [scoreboard.score_ops_killed] ([scoreboard.score_ops_killed * 500] Points)<br>"
	dat += "<b>Command Staff Slain:</b> [scoreboard.score_dead_command] (-[scoreboard.score_dead_command * 500] Points)<br>"
	dat += "<b>Revolution Successful:</b> [scoreboard.score_greentext ? "Yes" : "No"] (-[scoreboard.score_greentext * 10000] Points)<br>"
	dat += "<HR>"

	return dat
