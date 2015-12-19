// To add a rev to the list of revolutionaries, make sure it's rev (with if(ticker.mode.name == "revolution)),
// then call ticker.mode:add_revolutionary(_THE_PLAYERS_MIND_)
// nothing else needs to be done, as that proc will check if they are a valid target.
// Just make sure the converter is a head before you call it!
// To remove a rev (from brainwashing or w/e), call ticker.mode:remove_revolutionary(_THE_PLAYERS_MIND_),
// this will also check they're not a head, so it can just be called freely
// If the rev icons start going wrong for some reason, ticker.mode:update_all_rev_icons() can be called to correct them.
// If the game somtimes isn't registering a win properly, then ticker.mode.check_win() isn't being called somewhere.

/datum/game_mode
	var/list/datum/mind/head_revolutionaries = list()
	var/list/datum/mind/revolutionaries = list()
	var/extra_heads = 0

/datum/game_mode/revolution
	name = "revolution"
	config_tag = "revolution"
	restricted_jobs = list("Security Officer", "Warden", "Detective", "Internal Affairs Agent", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Blueshield", "Nanotrasen Representative", "Security Pod Pilot", "Magistrate", "Brig Physician")
	protected_jobs = list()
	required_players = 4
	required_players_secret = 15
	required_enemies = 3
	recommended_enemies = 3


	uplink_welcome = "Revolutionary Uplink Console:"
	uplink_uses = 20

	var/finished = 0
	var/checkwin_counter = 0
	var/max_headrevs = 3
///////////////////////////
//Announces the game type//
///////////////////////////
/datum/game_mode/revolution/announce()
	world << "<B>The current game mode is - Revolution!</B>"
	world << "<B>Some crewmembers are attempting to start a revolution!<BR>\nRevolutionaries - Kill the Captain, HoP, HoS, CE, RD and CMO. Convert other crewmembers (excluding the heads of staff, and security officers) to your cause by flashing them. Protect your leaders.<BR>\nPersonnel - Protect the heads of staff. Kill the leaders of the revolution, and brainwash the other revolutionaries (by beating them in the head).</B>"


///////////////////////////////////////////////////////////////////////////////
//Gets the round setup, cancelling if there's not enough players at the start//
///////////////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_headrevs = get_players_for_role(BE_REV)

	for (var/i=1 to max_headrevs)
		if(possible_headrevs.len==0)
			break
		var/datum/mind/lenin = pick(possible_headrevs)
		possible_headrevs -= lenin
		head_revolutionaries += lenin
		lenin.restricted_roles = restricted_jobs

	if(head_revolutionaries.len < required_enemies)
		return 0

	return 1


/datum/game_mode/revolution/post_setup()
	var/list/heads = get_living_heads()
	if(num_players_started() >= 30)
		heads += get_extra_living_heads()
		extra_heads = 1

	for(var/datum/mind/rev_mind in head_revolutionaries)
		for(var/datum/mind/head_mind in heads)
			var/datum/objective/mutiny/rev_obj = new
			rev_obj.owner = rev_mind
			rev_obj.target = head_mind
			rev_obj.explanation_text = "Assassinate [head_mind.name], the [head_mind.assigned_role]."
			rev_mind.objectives += rev_obj

	//	equip_traitor(rev_mind.current, 1) //changing how revs get assigned their uplink so they can get PDA uplinks. --NEO
	//	Removing revolutionary uplinks.	-Pete
		equip_revolutionary(rev_mind.current)
		update_rev_icons_added(rev_mind)

	for(var/datum/mind/rev_mind in head_revolutionaries)
		greet_revolutionary(rev_mind)
	modePlayer += head_revolutionaries
	if(shuttle_master)
		shuttle_master.emergencyNoEscape = 1
	..()


/datum/game_mode/revolution/process()
	checkwin_counter++
	if(checkwin_counter >= 5)
		if(!finished)
			ticker.mode.check_win()
		checkwin_counter = 0
	return 0

/proc/get_rev_mode()
	if(!ticker || !istype(ticker.mode, /datum/game_mode/revolution))
		return null

/**
 * LateSpawn hook.
 * Called in newplayer.dm when a humanoid character joins the round after it started.
 * Parameters: var/mob/living/carbon/human, var/rank
 */
/hook/latespawn/proc/add_latejoiner_heads(var/mob/living/carbon/human/H)
	var/datum/game_mode/revolution/mode = get_rev_mode()
	if (!mode) return 1

	var/list/heads = list()
	var/list/alt_positions = list("Warden", "Magistrate", "Blueshield", "Nanotrasen Representative")

	if(H.stat!=2 && H.mind && (H.mind.assigned_role in command_positions))
		heads += H

	if(mode.extra_heads)
		if(H.stat!=2 && H.mind && (H.mind.assigned_role in alt_positions))
			heads += H

	for(var/datum/mind/rev_mind in mode.head_revolutionaries)
		for(var/datum/mind/head_mind in heads)
			var/datum/objective/mutiny/rev_obj = new
			rev_obj.owner = rev_mind
			rev_obj.target = head_mind
			rev_obj.explanation_text = "Assassinate [head_mind.name], the [head_mind.assigned_role]."
			rev_mind.objectives += rev_obj
			rev_mind.current << "Additional Objective: Assassinate [head_mind.name], the [head_mind.assigned_role]."

	for(var/datum/mind/rev_mind in mode.revolutionaries)
		for(var/datum/mind/head_mind in heads)
			var/datum/objective/mutiny/rev_obj = new
			rev_obj.owner = rev_mind
			rev_obj.target = head_mind
			rev_obj.explanation_text = "Assassinate [head_mind.name], the [head_mind.assigned_role]."
			rev_mind.objectives += rev_obj
			rev_mind.current << "Additional Objective: Assassinate [head_mind.name], the [head_mind.assigned_role]."


/datum/game_mode/proc/forge_revolutionary_objectives(var/datum/mind/rev_mind)
	var/list/heads = get_living_heads()
	if(num_players_started() >= 30)
		heads += get_extra_living_heads()
		extra_heads = 1
	for(var/datum/mind/head_mind in heads)
		var/datum/objective/mutiny/rev_obj = new
		rev_obj.owner = rev_mind
		rev_obj.target = head_mind
		rev_obj.explanation_text = "Assassinate [head_mind.name], the [head_mind.assigned_role]."
		rev_mind.objectives += rev_obj

/datum/game_mode/proc/greet_revolutionary(var/datum/mind/rev_mind, var/you_are=1)
	var/obj_count = 1
	if (you_are)
		rev_mind.current << "\blue You are a member of the revolutionaries' leadership!"
	for(var/datum/objective/objective in rev_mind.objectives)
		rev_mind.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		rev_mind.special_role = "Head Revolutionary"
		obj_count++

/////////////////////////////////////////////////////////////////////////////////
//This are equips the rev heads with their gear, and makes the clown not clumsy//
/////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/equip_revolutionary(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	if (mob.mind)
		if (mob.mind.assigned_role == "Clown")
			mob << "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
			mob.mutations.Remove(CLUMSY)


	var/obj/item/device/flash/T = new(mob)

	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)
	var/where = mob.equip_in_one_of_slots(T, slots)
	if (!where)
		mob << "The Syndicate were unfortunately unable to get you a flash."
	else
		mob << "The flash in your [where] will help you to persuade the crew to join your cause."
		mob.update_icons()
		return 1

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
	if(config.continous_rounds)
		if(finished != 0)
			if(shuttle_master && shuttle_master.emergencyNoEscape)
				shuttle_master.emergencyNoEscape = 0
		return ..()
	if(finished != 0)
		return 1
	else
		return 0

///////////////////////////////////////////////////
//Deals with converting players to the revolution//
///////////////////////////////////////////////////
/datum/game_mode/proc/add_revolutionary(datum/mind/rev_mind)
	if(rev_mind.assigned_role in command_positions)
		return 0
	var/mob/living/carbon/human/H = rev_mind.current//Check to see if the potential rev is implanted
	for(var/obj/item/weapon/implant/loyalty/L in H)//Checking that there is a loyalty implant in the contents
		if(L.imp_in == H)//Checking that it's actually implanted
			return 0
	if((rev_mind in revolutionaries) || (rev_mind in head_revolutionaries))
		return 0
	revolutionaries += rev_mind
	rev_mind.current << "\red <FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</FONT>"
	rev_mind.special_role = "Revolutionary"
	update_rev_icons_added(rev_mind)
	return 1
//////////////////////////////////////////////////////////////////////////////
//Deals with players being converted from the revolution (Not a rev anymore)//  // Modified to handle borged MMIs.  Accepts another var if the target is being borged at the time  -- Polymorph.
//////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/remove_revolutionary(datum/mind/rev_mind , beingborged)
	if(rev_mind in revolutionaries)
		revolutionaries -= rev_mind
		rev_mind.special_role = null

		if(beingborged)
			rev_mind.current << "\red <FONT size = 3><B>The frame's firmware detects and deletes your neural reprogramming!  You remember nothing from the moment you were flashed until now.</B></FONT>"
			message_admins("[key_name_admin(rev_mind.current)] has been borged while being a member of the revolution.")
		else
			rev_mind.current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a revolutionary! Your memory is hazy from the time you were a rebel...the only thing you remember is the name of the one who brainwashed you...</B></FONT>"

		update_rev_icons_removed(rev_mind)
		for(var/mob/living/M in view(rev_mind.current))
			if(beingborged)
				M << "The frame beeps contentedly, purging the hostile memory engram from the MMI before initalizing it."

			else
				M << "[rev_mind.current] looks like they just remembered their real allegiance!"


/////////////////////////////////////
//Adds the rev hud to a new convert//
/////////////////////////////////////
/datum/game_mode/proc/update_rev_icons_added(datum/mind/rev_mind)
	var/datum/atom_hud/antag/revhud = huds[ANTAG_HUD_REV]
	revhud.join_hud(rev_mind.current)
	set_antag_hud(rev_mind.current, ((rev_mind in head_revolutionaries) ? "hudheadrevolutionary" : "hudrevolutionary"))

/////////////////////////////////////////
//Removes the hud from deconverted revs//
/////////////////////////////////////////
/datum/game_mode/proc/update_rev_icons_removed(datum/mind/rev_mind)
	var/datum/atom_hud/antag/revhud = huds[ANTAG_HUD_REV]
	revhud.leave_hud(rev_mind.current)
	set_antag_hud(rev_mind.current, null)
//////////////////////////
//Checks for rev victory//
//////////////////////////
/datum/game_mode/revolution/proc/check_rev_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		for(var/datum/objective/mutiny/objective in rev_mind.objectives)
			if(!(objective.check_completion()))
				return 0

		return 1

/////////////////////////////
//Checks for a head victory//
/////////////////////////////
/datum/game_mode/revolution/proc/check_heads_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		var/turf/T = get_turf(rev_mind.current)
		if((rev_mind) && (rev_mind.current) && (rev_mind.current.stat != 2) && rev_mind.current.client && T && (T.z in config.station_levels))
			if(ishuman(rev_mind.current))
				return 0
	return 1

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relavent information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/declare_completion()
	if(finished == 1)
		feedback_set_details("round_end_result","win - heads killed")
		world << "\red <FONT size = 3><B> The heads of staff were killed or abandoned the station! The revolutionaries win!</B></FONT>"
	else if(finished == 2)
		feedback_set_details("round_end_result","loss - rev heads killed")
		world << "\red <FONT size = 3><B> The heads of staff managed to stop the revolution!</B></FONT>"
	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_revolution()
	var/list/targets = list()

	if(head_revolutionaries.len || istype(ticker.mode,/datum/game_mode/revolution))
		var/text = "<FONT size = 2><B>The head revolutionaries were:</B></FONT>"

		for(var/datum/mind/headrev in head_revolutionaries)
			text += "<br>[headrev.key] was [headrev.name] ("
			if(headrev.current)
				if(headrev.current.stat == DEAD)
					text += "died"
				else if(!(headrev.current.z in config.station_levels))
					text += "fled the station"
				else
					text += "survived the revolution"
				if(headrev.current.real_name != headrev.name)
					text += " as [headrev.current.real_name]"
			else
				text += "body destroyed"
			text += ")"

			for(var/datum/objective/mutiny/objective in headrev.objectives)
				targets |= objective.target

		world << text

	if(revolutionaries.len || istype(ticker.mode,/datum/game_mode/revolution))
		var/text = "<FONT size = 2><B>The revolutionaries were:</B></FONT>"

		for(var/datum/mind/rev in revolutionaries)
			text += "<br>[rev.key] was [rev.name] ("
			if(rev.current)
				if(rev.current.stat == DEAD)
					text += "died"
				else if(!(rev.current.z in config.station_levels))
					text += "fled the station"
				else
					text += "survived the revolution"
				if(rev.current.real_name != rev.name)
					text += " as [rev.current.real_name]"
			else
				text += "body destroyed"
			text += ")"

		world << text


	if( head_revolutionaries.len || revolutionaries.len || istype(ticker.mode,/datum/game_mode/revolution) )
		var/text = "<FONT size = 2><B>The heads of staff were:</B></FONT>"

		var/list/heads = get_all_heads()
		if(extra_heads)
			heads += get_extra_heads()
		for(var/datum/mind/head in heads)
			var/target = (head in targets)
			if(target)
				text += "<font color='red'>"
			text += "<br>[head.key] was [head.name] ("
			if(head.current)
				if(head.current.stat == DEAD)
					text += "died"
				else if(!(head.current.z in config.station_levels))
					text += "fled the station"
				else
					text += "survived the revolution"
				if(head.current.real_name != head.name)
					text += " as [head.current.real_name]"
			else
				text += "body destroyed"
			text += ")"
			if(target)
				text += "</font>"

		world << text

/proc/is_convertable_to_rev(datum/mind/mind)
	return istype(mind) && \
		istype(mind.current, /mob/living/carbon/human) && \
		!(mind.assigned_role in command_positions) && \
		!(mind.assigned_role in list("Security Officer", "Detective", "Warden", "Nanotrasen Representative"))



/datum/game_mode/revolution/set_scoreboard_gvars()
	var/foecount = 0
	for(var/datum/mind/M in ticker.mode.head_revolutionaries)
		foecount++
		if(!M || !M.current)
			score_opkilled++
			continue

		if(M.current.stat == DEAD)
			score_opkilled++

		else if(M.current.restrained())
			score_arrested++

	if(foecount == score_arrested)
		score_allarrested = 1

	for(var/mob/living/carbon/human/player in world)
		if(player.mind)
			var/role = player.mind.assigned_role
			if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
				if(player.stat == DEAD)
					score_deadcommand++


	var/arrestpoints = score_arrested * 1000
	var/killpoints = score_opkilled * 500
	var/comdeadpts = score_deadcommand * 500
	if(score_traitorswon)
		score_crewscore -= 10000

	score_crewscore += arrestpoints
	score_crewscore += killpoints
	score_crewscore -= comdeadpts


/datum/game_mode/revolution/get_scoreboard_stats()
	var/foecount = 0
	var/comcount = 0
	var/revcount = 0
	var/loycount = 0
	for(var/datum/mind/M in ticker.mode:head_revolutionaries)
		if (M.current && M.current.stat != DEAD)
			foecount++
	for(var/datum/mind/M in ticker.mode:revolutionaries)
		if (M.current && M.current.stat != DEAD)
			revcount++
	for(var/mob/living/carbon/human/player in world)
		if(player.mind)
			var/role = player.mind.assigned_role
			if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
				if(player.stat != DEAD)
					comcount++
			else
				if(player.mind in ticker.mode.revolutionaries) continue
				loycount++

	for(var/mob/living/silicon/X in world)
		if(X.stat != DEAD)
			loycount++


	var/dat = ""

	dat += "<b><u>Mode Statistics</u></b><br>"
	dat += "<b>Number of Surviving Revolution Heads:</b> [foecount]<br>"
	dat += "<b>Number of Surviving Command Staff:</b> [comcount]<br>"
	dat += "<b>Number of Surviving Revolutionaries:</b> [revcount]<br>"
	dat += "<b>Number of Surviving Loyal Crew:</b> [loycount]<br>"

	dat += "<br>"
	dat += "<b>Revolution Heads Arrested:</b> [score_arrested] ([score_arrested * 1000] Points)<br>"
	dat += "<b>All Revolution Heads Arrested:</b> [score_allarrested ? "Yes" : "No"] (Score tripled)<br>"

	dat += "<b>Revolution Heads Slain:</b> [score_opkilled] ([score_opkilled * 500] Points)<br>"
	dat += "<b>Command Staff Slain:</b> [score_deadcommand] (-[score_deadcommand * 500] Points)<br>"
	dat += "<b>Revolution Successful:</b> [score_traitorswon ? "Yes" : "No"] (-[score_traitorswon * 10000] Points)<br>"
	dat += "<HR>"

	return dat