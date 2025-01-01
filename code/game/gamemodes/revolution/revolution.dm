// To remove a rev (from brainwashing or w/e), call SSticker.mode.remove_revolutionary(_THE_PLAYERS_MIND_),
// this will also check they're not a head, so it can just be called freely

#define REV_VICTORY 1
#define STATION_VICTORY 2

/datum/game_mode/revolution
	name = "revolution"
	config_tag = "revolution"
	restricted_jobs = list("Security Officer", "Warden", "Detective", "Internal Affairs Agent", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Blueshield", "Nanotrasen Representative", "Magistrate", "Quartermaster", "Nanotrasen Career Trainer")
	required_players = 20
	required_enemies = 1
	recommended_enemies = 3

	var/finished
	var/check_counter = 0
	var/list/pre_revolutionaries = list()

///////////////////////////
//Announces the game type//
///////////////////////////
/datum/game_mode/revolution/announce()
	to_chat(world, "<B>The current game mode is - Revolution!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a revolution!<BR>\nRevolutionaries - Kill the Captain, HoP, HoS, CE, QM, RD and CMO. Convert other crewmembers (excluding the heads of staff, and security officers) to your cause by flashing them. Protect your leaders.<BR>\nPersonnel - Protect the heads of staff. Kill the leaders of the revolution, and brainwash the other revolutionaries (by beating them in the head).</B>")


///////////////////////////////////////////////////////////////////////////////
//Gets the round setup, cancelling if there's not enough players at the start//
///////////////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/pre_setup()
	var/list/datum/mind/possible_revolutionaries = get_players_for_role(ROLE_REV)

	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		restricted_jobs |= protected_jobs

	for(var/i in 1 to REVOLUTION_MAX_HEADREVS)
		if(!length(possible_revolutionaries))
			break
		var/datum/mind/new_headrev = pick_n_take(possible_revolutionaries)
		pre_revolutionaries |= new_headrev
		new_headrev.restricted_roles = restricted_jobs
		new_headrev.special_role = SPECIAL_ROLE_HEAD_REV

	if(length(pre_revolutionaries) < required_enemies)
		return FALSE

	return TRUE


/datum/game_mode/revolution/post_setup()

	get_rev_team()

	for(var/i in 1 to rev_team.need_another_headrev(1)) // yes this is a ONE, not a true
		if(!length(pre_revolutionaries))
			break
		var/datum/mind/new_headrev = pick_n_take(pre_revolutionaries)
		new_headrev.add_antag_datum(/datum/antagonist/rev/head)

	..()

/datum/game_mode/revolution/Destroy(force, ...)
	pre_revolutionaries.Cut()
	return ..()

/datum/game_mode/revolution/process() // to anyone who thinks "why don't we use a normal actually sane check here instead of process for checking Z level changes" It's because equip code is dogshit and you change z levels upon spawning in
	check_counter++
	if(check_counter >= 5)
		if(!finished)
			rev_team.check_all_victory()
		check_counter = 0
	return FALSE

/datum/game_mode/proc/get_rev_team()
	if(!rev_team)
		new /datum/team/revolution() // assignment happens in create_team()
	return rev_team

//////////////////////////////////////
//Checks if the revs have won or not//
//////////////////////////////////////
/datum/game_mode/revolution/check_win()
	if(rev_team.check_rev_victory())
		finished = REV_VICTORY
	else if(rev_team.check_heads_victory())
		finished = STATION_VICTORY

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/revolution/check_finished()
	if(GLOB.configuration.gamemode.disable_certain_round_early_end)
		if(finished)
			SSshuttle.clearHostileEnvironment(rev_team)
			if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
				SSshuttle.emergency.mode = SHUTTLE_DOCKED
				SSshuttle.emergency.timer = world.time
				GLOB.major_announcement.Announce("Hostile environment resolved. You have 3 minutes to board the Emergency Shuttle.", null, 'sound/AI/eshuttle_dock.ogg')
		return ..()
	if(finished)
		return TRUE
	return ..()

//////////////////////////////////////////////////////////////////////////////
//Deals with players being converted from the revolution (Not a rev anymore)//  // Modified to handle borged MMIs.  Accepts another var if the target is being borged at the time  -- Polymorph.
//////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/remove_revolutionary(datum/mind/rev_mind, beingborged, activate_protection)
	var/mob/revolutionary = rev_mind.current
	var/remove_head = (beingborged && rev_mind.has_antag_datum(/datum/antagonist/rev/head))

	if(rev_mind.has_antag_datum(/datum/antagonist/rev, FALSE) || remove_head)
		// We have some custom text, lets make the removal silent
		rev_mind.remove_antag_datum(/datum/antagonist/rev, silent_removal = TRUE)

		if(beingborged)
			revolutionary.visible_message(
				"<span class='userdanger'>The frame beeps contentedly, purging the hostile memory engram from the MMI before initalizing it.</span>",
				"<span class='userdanger'>The frame's firmware detects and deletes your neural reprogramming! You remember nothing[remove_head ? "." : " but the name of the one who flashed you."]</span>")
			message_admins("[key_name_admin(rev_mind.current)] [ADMIN_QUE(rev_mind.current,"?")] ([ADMIN_FLW(rev_mind.current,"FLW")]) has been borged while being a [remove_head ? "leader" : " member"] of the revolution.")
		else
			var/class = activate_protection ? "biggerdanger" : "userdanger" // biggerdanger only shows up when protection happens (usually in a red-flood of combat text)
			revolutionary.visible_message(
				"<span class='[class]'>[rev_mind.current] looks like [rev_mind.current.p_they()] just remembered [rev_mind.current.p_their()] real allegiance!</span>",
				"<span class='[class]'>You have been brainwashed! You are no longer a revolutionary! Your memory is hazy from the time you were a rebel... the only thing you remember is the name of the one who brainwashed you...</span>")
			rev_mind.current.Paralyse(10 SECONDS)
		if(activate_protection && isliving(revolutionary))
			var/mob/living/living_rev = revolutionary
			living_rev.apply_status_effect(STATUS_EFFECT_REVOLUTION_PROTECT)
		return TRUE

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relavent information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/declare_completion()
	if(finished == REV_VICTORY)
		SSticker.mode_result = "revolution win - heads killed"
		to_chat(world, "<span class='redtext'>The heads of staff were killed or exiled! The revolutionaries win!</span>")
	else if(finished == STATION_VICTORY)
		SSticker.mode_result = "revolution loss - rev heads killed"
		to_chat(world, "<span class='redtext'>The heads of staff managed to stop the revolution!</span>")
	..()
	return TRUE

/datum/game_mode/proc/auto_declare_completion_revolution()
	var/list/targets = list()
	if(length(rev_team?.members) || GAMEMODE_IS_REVOLUTION)
		var/num_revs = 0
		var/num_survivors = 0
		for(var/mob/living/carbon/human/survivor in GLOB.player_list)
			if(!istype(survivor) || survivor.stat == DEAD)
				continue
			num_survivors++
			if(survivor.mind?.has_antag_datum(/datum/antagonist/rev))
				num_revs++
		if(num_survivors)
			to_chat(world, "[TAB]Command's Approval Rating: <B>[100 - round((num_revs/num_survivors)*100, 0.1)]%</B>") // % of loyal crew
		var/list/text = list("<br><font size=3><b>The head revolutionaries were:</b></font>")
		for(var/datum/mind/headrev in head_revolutionaries)
			text += printplayer(headrev, 1)
		text += "<br>"

		// we dont show the revolutionaries because there are a LOT of them

		text = list("<br><font size=3><b>The heads of staff were:</b></font>")
		var/list/heads = get_all_heads()
		for(var/datum/mind/head in heads)
			var/target = (head in targets)
			if(target)
				text += "<span class='boldannounceic'>Target</span>"
			text += printplayer(head, 1)
		text += "<br>"
		return text.Join("")

/datum/game_mode/revolution/set_scoreboard_vars() // this proc is never called, someone remove it
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
		if(isnull(H) || H.stat == DEAD)
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
	for(var/datum/mind/M in SSticker.mode.head_revolutionaries)
		if(M.current && M.current.stat != DEAD)
			foecount++
	for(var/datum/mind/M in SSticker.mode.revolutionaries)
		if(M.current && M.current.stat != DEAD)
			revcount++

	var/list/real_command_positions = GLOB.command_positions.Copy() - "Nanotrasen Representative"
	for(var/mob/living/carbon/human/player in GLOB.human_list)
		if(player.mind)
			if(player.mind.assigned_role in real_command_positions)
				if(player.stat != DEAD)
					comcount++
				continue
			if(player.mind.has_antag_datum(/datum/antagonist/rev))
				continue
			loycount++

	// we dont count silicons because well, they follow their laws, not the crew, and there is no easy way to tell if theyre subverted


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

/proc/is_revolutionary(mob/living/M)
	return istype(M) && M?.mind?.has_antag_datum(/datum/antagonist/rev, FALSE)

/proc/is_headrev(mob/living/M)
	return istype(M) && M?.mind?.has_antag_datum(/datum/antagonist/rev/head)

/proc/is_any_revolutionary(mob/living/M)
	return istype(M) && M?.mind?.has_antag_datum(/datum/antagonist/rev)

#undef REV_VICTORY
#undef STATION_VICTORY
