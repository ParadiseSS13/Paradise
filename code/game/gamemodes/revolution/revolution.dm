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

/datum/game_mode/revolution
	name = "revolution"
	config_tag = "revolution"
	restricted_jobs = list("Security Officer", "Warden", "Detective", "Internal Affairs Agent", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Blueshield", "Nanotrasen Representative", "Magistrate")
	required_players = 20
	required_enemies = 1
	recommended_enemies = 3

	var/finished = 0
	var/max_headrevs = 3
	var/check_counter = 0
	var/list/datum/mind/heads_to_kill = list()
	var/list/possible_revolutionaries = list()

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
	possible_revolutionaries = get_players_for_role(ROLE_REV)

	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		restricted_jobs += protected_jobs

	for(var/i=1 to max_headrevs)
		if(possible_revolutionaries.len==0)
			break
		var/datum/mind/new_headrev = pick(possible_revolutionaries)
		possible_revolutionaries -= new_headrev
		head_revolutionaries += new_headrev
		new_headrev.restricted_roles = restricted_jobs

	if(head_revolutionaries.len < required_enemies)
		return FALSE

	return TRUE


/datum/game_mode/revolution/post_setup()
	var/list/heads = get_living_heads()
	var/list/sec = get_living_sec()
	var/weighted_score = min(max(round(heads.len - ((8 - sec.len) / 3)),1),max_headrevs)

	while(weighted_score < head_revolutionaries.len) //das vi danya
		var/datum/mind/removable_headrev = pick_n_take(head_revolutionaries)
		possible_revolutionaries += removable_headrev
		update_rev_icons_removed(removable_headrev)

	for(var/datum/mind/rev_mind in head_revolutionaries)
		log_game("[key_name(rev_mind)] has been selected as a head rev")
		for(var/datum/mind/head_mind in heads)
			mark_for_death(rev_mind, head_mind)

		addtimer(CALLBACK(src, PROC_REF(equip_revolutionary), rev_mind.current), rand(10, 100))

	for(var/datum/mind/rev_mind in head_revolutionaries)
		greet_revolutionary(rev_mind)
	modePlayer += head_revolutionaries
	if(SSshuttle)
		SSshuttle.emergencyNoEscape = 1
	..()

/datum/game_mode/revolution/process() // to anyone who thinks "why don't we use a normal actually sane check here instead of process for checking Z level changes" It's because equip code is dogshit and you change z levels upon spawning in
	check_counter++
	if(check_counter >= 5)
		if(!finished)
			check_heads()
		check_counter = 0
	return FALSE

/datum/game_mode/revolution/proc/check_heads()
	var/list/heads = get_all_heads()
	if(length(heads_to_kill) < length(heads))
		var/list/new_heads = heads - heads_to_kill
		for(var/datum/mind/head_mind in new_heads)
			for(var/datum/mind/rev_mind in head_revolutionaries)
				mark_for_death(rev_mind, head_mind)


/datum/game_mode/proc/forge_revolutionary_objectives(datum/mind/rev_mind)
	var/list/heads = get_living_heads()
	for(var/datum/mind/head_mind in heads)
		var/datum/objective/mutiny/rev_obj = new
		rev_obj.owner = rev_mind
		rev_obj.target = head_mind
		rev_obj.explanation_text = "Assassinate or exile [head_mind.name], the [head_mind.assigned_role]."
		rev_mind.objectives += rev_obj

/datum/game_mode/proc/greet_revolutionary(datum/mind/rev_mind, you_are=1)
	var/obj_count = 1
	update_rev_icons_added(rev_mind)
	if(you_are)
		to_chat(rev_mind.current, "<span class='userdanger'>You are a member of the revolutionaries' leadership!</span>")
	for(var/datum/objective/objective in rev_mind.objectives)
		to_chat(rev_mind.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		rev_mind.special_role = SPECIAL_ROLE_HEAD_REV
		obj_count++
	to_chat(rev_mind.current, "<span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/Revolution)</span>")
	rev_mind.current.create_log(MISC_LOG, "[rev_mind.current] was made into a head revolutionary")

/////////////////////////////////////////////////////////////////////////////////
//This are equips the rev heads with their gear, and makes the clown not clumsy//
/////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/equip_revolutionary(mob/living/carbon/human/revolutionary)
	if(!istype(revolutionary))
		return

	if(revolutionary.mind)
		if(revolutionary.mind.assigned_role == "Clown")
			to_chat(revolutionary, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			revolutionary.dna.SetSEState(GLOB.clumsyblock, FALSE)
			singlemutcheck(revolutionary, GLOB.clumsyblock, MUTCHK_FORCED)
			var/datum/action/innate/toggle_clumsy/A = new
			A.Grant(revolutionary)

	var/obj/item/flash/T = new(revolutionary)
	var/obj/item/toy/crayon/spraycan/R = new(revolutionary)
	var/obj/item/clothing/glasses/hud/security/chameleon/C = new(revolutionary)

	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)
	var/where = revolutionary.equip_in_one_of_slots(T, slots)
	var/where2 = revolutionary.equip_in_one_of_slots(C, slots)
	revolutionary.equip_in_one_of_slots(R,slots)

	revolutionary.update_icons()

	if(!where2)
		to_chat(revolutionary, "The Syndicate were unfortunately unable to get you a chameleon security HUD.")
	else
		to_chat(revolutionary, "The chameleon security HUD in your [where2] will help you keep track of who is mindshield-implanted, and unable to be recruited.")

	if(!where)
		to_chat(revolutionary, "The Syndicate were unfortunately unable to get you a flash.")
	else
		to_chat(revolutionary, "The flash in your [where] will help you to persuade the crew to join your cause.")
		return 1

/////////////////////////////////
//Gives head revs their targets//
/////////////////////////////////
/datum/game_mode/revolution/proc/mark_for_death(datum/mind/rev_mind, datum/mind/head_mind)
	var/datum/objective/mutiny/rev_obj = new
	rev_obj.owner = rev_mind
	rev_obj.target = head_mind
	rev_obj.explanation_text = "Assassinate [head_mind.name], the [head_mind.assigned_role]."
	rev_mind.objectives += rev_obj
	heads_to_kill += head_mind

////////////////////////////////////////////
//Checks if new heads have joined midround//
////////////////////////////////////////////
/datum/game_mode/revolution/latespawn(mob/living/carbon/human/player)
	..()
	var/datum/mind/player_mind = player.mind
	if(player_mind && (player_mind.assigned_role in GLOB.command_head_positions))
		for(var/datum/mind/rev_mind in head_revolutionaries)
			mark_for_death(rev_mind, player_mind)

	var/list/heads = get_all_heads()
	var/list/sec = get_all_sec()
	if(head_revolutionaries.len < max_headrevs && head_revolutionaries.len < round(heads.len - ((8 - sec.len) / 3)))
		latejoin_headrev()

///////////////////////////////
//Adds a new headrev midround//
///////////////////////////////
/datum/game_mode/revolution/proc/latejoin_headrev()
	if(revolutionaries) //Head Revs are not in this list
		var/list/promotable_revs = list()
		for(var/datum/mind/potential_new_headrev in revolutionaries)
			if(potential_new_headrev.current && potential_new_headrev.current.client && potential_new_headrev.current.stat != DEAD)
				if(ROLE_REV in potential_new_headrev.current.client.prefs.be_special)
					promotable_revs += potential_new_headrev
		if(promotable_revs.len)
			var/datum/mind/new_headrev = pick(promotable_revs)
			revolutionaries -= new_headrev
			head_revolutionaries += new_headrev
			log_game("[key_name(new_headrev)] has been promoted to a head rev")
			equip_revolutionary(new_headrev.current)
			forge_revolutionary_objectives(new_headrev)
			greet_revolutionary(new_headrev)

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
			SSshuttle.emergencyNoEscape = 0
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
	revolutionaries += rev_mind
	if(conversion_target)
		conversion_target.Silence(10 SECONDS)
		conversion_target.Stun(10 SECONDS)
	to_chat(rev_mind.current, "<span class='danger'><FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</FONT></span>")
	rev_mind.current.create_attack_log("<font color='red'>Has been converted to the revolution!</font>")
	rev_mind.current.create_log(CONVERSION_LOG, "converted to the revolution")
	rev_mind.special_role = SPECIAL_ROLE_REV
	update_rev_icons_added(rev_mind)
	if(jobban_isbanned(rev_mind.current, ROLE_REV) || jobban_isbanned(rev_mind.current, ROLE_SYNDICATE))
		replace_jobbanned_player(rev_mind.current, ROLE_REV)
	return TRUE
//////////////////////////////////////////////////////////////////////////////
//Deals with players being converted from the revolution (Not a rev anymore)//  // Modified to handle borged MMIs.  Accepts another var if the target is being borged at the time  -- Polymorph.
//////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/remove_revolutionary(datum/mind/rev_mind, beingborged, activate_protection)
	var/remove_head = FALSE
	var/mob/revolutionary = rev_mind.current
	if(beingborged && (rev_mind in head_revolutionaries))
		head_revolutionaries -= rev_mind
		remove_head = TRUE

	if((rev_mind in revolutionaries) || remove_head)
		revolutionaries -= rev_mind
		rev_mind.special_role = null
		rev_mind.current.create_attack_log("<font color='red'>Has renounced the revolution!</font>")
		rev_mind.current.create_log(CONVERSION_LOG, "renounced the revolution")
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
		update_rev_icons_removed(rev_mind)
		if(activate_protection && isliving(revolutionary))
			var/mob/living/living_rev = revolutionary
			living_rev.apply_status_effect(STATUS_EFFECT_REVOLUTION_PROTECT)
		return TRUE

/////////////////////////////////////
//Adds the rev hud to a new convert//
/////////////////////////////////////
/datum/game_mode/proc/update_rev_icons_added(datum/mind/rev_mind)
	var/datum/atom_hud/antag/revhud = GLOB.huds[ANTAG_HUD_REV]
	revhud.join_hud(rev_mind.current)
	set_antag_hud(rev_mind.current, ((rev_mind in head_revolutionaries) ? "hudheadrevolutionary" : "hudrevolutionary"))

/////////////////////////////////////////
//Removes the hud from deconverted revs//
/////////////////////////////////////////
/datum/game_mode/proc/update_rev_icons_removed(datum/mind/rev_mind)
	var/datum/atom_hud/antag/revhud = GLOB.huds[ANTAG_HUD_REV]
	revhud.leave_hud(rev_mind.current)
	set_antag_hud(rev_mind.current, null)

//////////////////////////
//Checks for rev victory//
//////////////////////////
/datum/game_mode/revolution/proc/check_rev_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		for(var/datum/objective/mutiny/objective in rev_mind.objectives)
			if(!(objective.check_completion()))
				return FALSE
	return TRUE

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
	if(head_revolutionaries.len || GAMEMODE_IS_REVOLUTION)
		var/num_revs = 0
		var/num_survivors = 0
		for(var/mob/living/carbon/survivor in GLOB.alive_mob_list)
			if(survivor.ckey)
				num_survivors++
				if(survivor.mind)
					if((survivor.mind in head_revolutionaries) || (survivor.mind in revolutionaries))
						num_revs++
		if(num_survivors)
			to_chat(world, "[TAB]Command's Approval Rating: <B>[100 - round((num_revs/num_survivors)*100, 0.1)]%</B>") // % of loyal crew
		var/text = "<br><font size=3><b>The head revolutionaries were:</b></font>"
		for(var/datum/mind/headrev in head_revolutionaries)
			text += printplayer(headrev, 1)
		text += "<br>"
		to_chat(world, text)

	if(revolutionaries.len || GAMEMODE_IS_REVOLUTION)
		var/text = "<br><font size=3><b>The revolutionaries were:</b></font>"
		for(var/datum/mind/rev in revolutionaries)
			text += printplayer(rev, 1)
		text += "<br>"
		to_chat(world, text)

	if( head_revolutionaries.len || revolutionaries.len || GAMEMODE_IS_REVOLUTION )
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

	for(var/I in GLOB.human_list)
		var/mob/living/carbon/human/H = I
		if(H.stat == DEAD && H.mind?.assigned_role)
			if(H.mind.assigned_role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
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
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/player = thing
		if(player.mind)
			var/role = player.mind.assigned_role
			if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
				if(player.stat != DEAD)
					comcount++
			else
				if(player.mind in SSticker.mode.revolutionaries) continue
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

/proc/is_revolutionary(mob/living/M)
	return istype(M) && (M?.mind in SSticker?.mode?.revolutionaries)

/proc/is_headrev(mob/living/M)
	return istype(M) && (M?.mind in SSticker?.mode?.head_revolutionaries)

/proc/is_any_revolutionary(mob/living/M)
	return is_revolutionary(M) || is_headrev(M)
