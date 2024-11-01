/client/proc/one_click_antag()
	set name = "Create Antagonist"
	set desc = "Auto-create an antagonist of your choice"
	set category = "Event"

	if(!check_rights(R_SERVER|R_EVENT))	return

	if(holder)
		holder.one_click_antag()
	return


/datum/admins/proc/one_click_antag()

	var/dat = {"<B>One-click Antagonist</B><br>
		<a href='byond://?src=[UID()];makeAntag=1'>Make Traitors</a><br>
		<a href='byond://?src=[UID()];makeAntag=2'>Make Changelings</a><br>
		<a href='byond://?src=[UID()];makeAntag=3'>Make Revolutionaries</a><br>
		<a href='byond://?src=[UID()];makeAntag=4'>Make Cult</a><br>
		<a href='byond://?src=[UID()];makeAntag=5'>Make Wizard (Requires Ghosts)</a><br>
		<a href='byond://?src=[UID()];makeAntag=6'>Make Vampires</a><br>
		<a href='byond://?src=[UID()];makeAntag=7'>Make Abductor Team (Requires Ghosts)</a><br>
		<a href='byond://?src=[UID()];makeAntag=8'>Make Mindflayers</a><br>
		"}
	// SS220 ADD - Start
	dat += {"
		<a href='byond://?src=[UID()];makeAntag=8'>Make Blood Brothers Team</a><br>
		<a href='byond://?src=[UID()];makeAntag=9'>Make Vox Raiders</a><br>
		"}
	// SS220 ASS - End
	usr << browse(dat, "window=oneclickantag;size=400x400")
	return

/datum/admins/proc/CandCheck(role = null, mob/living/carbon/human/M, datum/game_mode/temp = null)
	// You pass in ROLE define (optional), the applicant, and the gamemode, and it will return true / false depending on whether the applicant qualify for the candidacy in question
	if(jobban_isbanned(M, ROLE_SYNDICATE))
		return FALSE
	if(M.stat || !M.mind || M.mind.special_role || M.mind.offstation_role)
		return FALSE
	if(temp)
		if((M.mind.assigned_role in temp.restricted_jobs) || (M.client.prefs.active_character.species in temp.species_to_mindflayer))
			return FALSE
	if(role) // Don't even bother evaluating if there's no role
		if(player_old_enough_antag(M.client,role) && (role in M.client.prefs.be_special) && !M.client.skip_antag && (!jobban_isbanned(M, role)))
			return TRUE
		else
			return FALSE
	else
		return TRUE

/datum/admins/proc/makeTraitors()
	var/datum/game_mode/traitor/temp = new

	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		temp.restricted_jobs += temp.protected_jobs

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	var/antnum = input(owner, "How many traitors you want to create? Enter 0 to cancel","Amount:", 0) as num
	if(!antnum || antnum <= 0)
		return
	log_admin("[key_name(owner)] tried making [antnum] traitors with One-Click-Antag")
	message_admins("[key_name_admin(owner)] tried making [antnum] traitors with One-Click-Antag")

	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		if(CandCheck(ROLE_TRAITOR, applicant, temp))
			candidates += applicant

	if(length(candidates))
		var/numTraitors = min(length(candidates), antnum)

		for(var/i = 0, i<numTraitors, i++)
			H = pick(candidates)
			H.mind.make_Traitor()
			candidates.Remove(H)

		return 1
	return 0


/datum/admins/proc/makeChangelings()

	var/datum/game_mode/changeling/temp = new
	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		temp.restricted_jobs += temp.protected_jobs

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	var/antnum = input(owner, "How many changelings you want to create? Enter 0 to cancel.","Amount:", 0) as num
	if(!antnum || antnum <= 0)
		return
	log_admin("[key_name(owner)] tried making [antnum] changelings with One-Click-Antag")
	message_admins("[key_name_admin(owner)] tried making [antnum] changelings with One-Click-Antag")

	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		if(CandCheck(ROLE_CHANGELING, applicant, temp))
			candidates += applicant

	if(length(candidates))
		var/numChangelings = min(length(candidates), antnum)

		for(var/i = 0, i<numChangelings, i++)
			H = pick(candidates)
			H.mind.add_antag_datum(/datum/antagonist/changeling)
			candidates.Remove(H)

		return 1
	return 0

/datum/admins/proc/makeRevs()

	var/datum/game_mode/revolution/temp = new
	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		temp.restricted_jobs += temp.protected_jobs

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	var/antnum = input(owner, "How many revolutionaries you want to create? Enter 0 to cancel","Amount:", 0) as num
	if(!antnum || antnum <= 0)
		return
	log_admin("[key_name(owner)] tried making [antnum] revolutionaries with One-Click-Antag")
	message_admins("[key_name_admin(owner)] tried making [antnum] revolutionaries with One-Click-Antag")

	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		if(CandCheck(ROLE_REV, applicant, temp))
			candidates += applicant

	if(length(candidates))
		var/numRevs = min(length(candidates), antnum)

		for(var/i = 0, i<numRevs, i++)
			H = pick(candidates)
			H?.mind?.add_antag_datum(/datum/antagonist/rev/head)
			candidates.Remove(H)
		return 1
	return 0

/datum/admins/proc/makeWizard()

	var/confirm = alert("Are you sure?", "Confirm creation", "Yes", "No")
	if(confirm != "Yes")
		return 0
	var/image/I = new('icons/mob/simple_human.dmi', "wizard")
	var/list/candidates = SSghost_spawns.poll_candidates("Do you wish to be considered for the position of a Wizard Federation 'diplomat'?", "wizard", source = I)

	log_admin("[key_name(owner)] tried making a Wizard with One-Click-Antag")
	message_admins("[key_name_admin(owner)] tried making a Wizard with One-Click-Antag")

	if(length(candidates))
		var/mob/dead/observer/selected = pick(candidates)
		candidates -= selected

		var/mob/living/carbon/human/new_character = makeBody(selected)
		new_character.mind.add_antag_datum(/datum/antagonist/wizard)
		new_character.forceMove(pick(GLOB.wizardstart))
		dust_if_respawnable(selected)
		return TRUE
	return FALSE


/datum/admins/proc/makeCult()

	var/datum/game_mode/cult/temp = new
	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		temp.restricted_jobs += temp.protected_jobs

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null
	var/antnum = input(owner, "How many cultists do you want to create? Enter 0 to cancel.", "Amount:", 0) as num
	if(!antnum || antnum <= 0)
		return
	log_admin("[key_name(owner)] tried making a Cult with One-Click-Antag")
	message_admins("[key_name_admin(owner)] tried making a Cult with One-Click-Antag")

	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		if(CandCheck(ROLE_CULTIST, applicant, temp))
			candidates += applicant

	if(!length(candidates))
		return FALSE

	for(var/I in 1 to antnum)
		if(!length(candidates))
			return
		H = pick_n_take(candidates)

		var/datum/antagonist/cultist/cultist = H.mind.add_antag_datum(/datum/antagonist/cultist)
		cultist.equip_roundstart_cultist(H)
	return TRUE

//Abductors
/datum/admins/proc/makeAbductorTeam()

	var/confirm = alert("Are you sure?", "Confirm creation", "Yes", "No")
	if(confirm != "Yes")
		return 0
	new /datum/event/abductor

	log_admin("[key_name(owner)] tried making Abductors with One-Click-Antag")
	message_admins("[key_name_admin(owner)] tried making Abductors with One-Click-Antag")

	return 1

/datum/admins/proc/makeAliens()
	var/antnum = input(owner, "How many aliens you want to create? Enter 0 to cancel.","Amount:", 0) as num
	if(!antnum || antnum <= 0)
		return
	var/datum/event/alien_infestation/E = new /datum/event/alien_infestation
	E.spawncount = antnum
	log_admin("[key_name(owner)] tried making Aliens with One-Click-Antag")
	message_admins("[key_name_admin(owner)] tried making Aliens with One-Click-Antag")

	return TRUE

/*
/datum/admins/proc/makeSpaceNinja()
	space_ninja_arrival()
	return 1
*/

/proc/makeBody(mob/dead/observer/G_found) // Uses stripped down and bastardized code from respawn character
	if(!G_found || !G_found.key)	return

	//First we spawn a dude.
	var/mob/living/carbon/human/new_character = new(pick(GLOB.latejoin))//The mob being spawned.

	// Then clone stuff over
	G_found.client.prefs.active_character.copy_to(new_character)

	new_character.dna.ready_dna(new_character)
	new_character.key = G_found.key

	return new_character

/datum/admins/proc/create_syndicate_death_commando(obj/spawn_location, syndicate_leader_selected = 0)
	var/mob/living/carbon/human/new_syndicate_commando = new(spawn_location.loc)
	var/syndicate_commando_leader_rank = pick("Lieutenant", "Captain", "Major")
	var/syndicate_commando_rank = pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
	var/syndicate_commando_name = pick(GLOB.last_names)

	var/datum/character_save/S = new //Randomize appearance for the commando.
	S.randomise()
	if(syndicate_leader_selected)
		S.real_name = "[syndicate_commando_leader_rank] [syndicate_commando_name]"
		S.age = rand(35, 45)
	else
		S.real_name = "[syndicate_commando_rank] [syndicate_commando_name]"
	S.copy_to(new_syndicate_commando)

	new_syndicate_commando.dna.ready_dna(new_syndicate_commando)//Creates DNA.

	//Creates mind stuff.
	new_syndicate_commando.mind_initialize()
	new_syndicate_commando.mind.assigned_role = SPECIAL_ROLE_SYNDICATE_DEATHSQUAD
	new_syndicate_commando.mind.special_role = SPECIAL_ROLE_SYNDICATE_DEATHSQUAD
	new_syndicate_commando.mind.offstation_role = TRUE
	//Adds them to current traitor list. Which is really the extra antagonist list.
	SSticker.mode.traitors += new_syndicate_commando.mind
	new_syndicate_commando.equip_syndicate_commando(syndicate_leader_selected)

	return new_syndicate_commando

/datum/admins/proc/makeVampires()

	var/datum/game_mode/vampire/temp = new
	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		temp.restricted_jobs += temp.protected_jobs

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	var/antnum = input(owner, "How many vampires you want to create? Enter 0 to cancel","Amount:", 0) as num
	if(!antnum || antnum <= 0)
		return

	log_admin("[key_name(owner)] tried making [antnum] Vampires with One-Click-Antag")
	message_admins("[key_name_admin(owner)] tried making [antnum] Vampires with One-Click-Antag")

	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		if(CandCheck(ROLE_VAMPIRE, applicant, temp))
			candidates += applicant

	if(length(candidates))
		var/numVampires = min(length(candidates), antnum)

		for(var/i = 0, i<numVampires, i++)
			H = pick(candidates)
			H.mind.make_vampire()
			candidates.Remove(H)

		return 1
	return 0

/datum/admins/proc/makeMindflayers()
	var/datum/game_mode/vampire/temp = new()

	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		temp.restricted_jobs += temp.protected_jobs

	var/input_num = input(owner, "How many Mindflayers you want to create? Enter 0 to cancel","Amount:", 0) as num|null
	if(input_num <= 0 || isnull(input_num))
		qdel(temp)
		return FALSE

	log_admin("[key_name(owner)] tried making [input_num] Mindflayers with One-Click-Antag")
	message_admins("[key_name_admin(owner)] tried making [input_num] Mindflayers with One-Click-Antag")
	var/list/possible_mindflayers = temp.get_players_for_role(ROLE_MIND_FLAYER, FALSE, "Machine")
	var/num_mindflayers = min(length(possible_mindflayers), input_num)
	if(!num_mindflayers)
		return FALSE
	for(var/i in 1 to num_mindflayers)
		var/datum/mind/flayer = pick_n_take(possible_mindflayers)
		flayer.make_mind_flayer()
	qdel(temp)
	return TRUE

/datum/admins/proc/makeThunderdomeTeams() // Not strictly an antag, but this seemed to be the best place to put it.
	var/max_thunderdome_players = 10
	var/team_to_assign_to = "Green"
	var/list/red_spawn_locations = GLOB.tdome1.Copy()
	var/list/blue_spawn_locations = GLOB.tdome2.Copy()
	log_admin("[key_name(owner)] tried making Thunderdome Teams with One-Click-Antag")
	message_admins("[key_name_admin(owner)] tried making Thunderdome Teams with One-Click-Antag")

	//Generates a list of candidates from active ghosts.
	var/list/thunderdome_candidates = shuffle(SSghost_spawns.poll_candidates("Participate in a Thunderdome match?", poll_time = 30 SECONDS, ignore_respawnability = TRUE, flash_window = TRUE, check_antaghud = FALSE))
	if(length(thunderdome_candidates) < 2) // One person thunderdome ain't great
		log_admin("[key_name(owner)] tried making Thunderdome Teams with One-Click-Antag, but not enough people signed up.")
		message_admins("[key_name_admin(owner)] tried making Thunderdome Teams with One-Click-Antag, but not enough people signed up.")
		return FALSE
	// Time to set up our team structure
	if(length(thunderdome_candidates) > max_thunderdome_players)
		thunderdome_candidates.Cut(max_thunderdome_players + 1)
	if(ISODD(length(thunderdome_candidates))) // We want fair fights
		var/surplus_candidate = pick_n_take(thunderdome_candidates)
		to_chat(surplus_candidate, "<span class='warning'>You were not chosen due to an odd number of participants.</span>")
	for(var/mob/dead/observer/candidate_to_spawn in thunderdome_candidates)
		if(!candidate_to_spawn || !candidate_to_spawn.key || !candidate_to_spawn.client)
			continue
		var/datum/character_save/S = new
		S.randomise()
		switch(team_to_assign_to)
			if("Green")
				var/turf/possible_spawn_loc_red = pick_n_take(red_spawn_locations)
				var/mob/living/carbon/human/new_thunderdome_member = new(get_turf(possible_spawn_loc_red))
				S.copy_to(new_thunderdome_member)
				new_thunderdome_member.dna.ready_dna(new_thunderdome_member)
				thunderdome_candidates.Remove(candidate_to_spawn)
				new_thunderdome_member.key = candidate_to_spawn.key
				to_chat(new_thunderdome_member, "You are a member of the <font color='green'><b>GREEN</b></font> Thunderdome team! Gear up and help your team destroy the red team!")
				new_thunderdome_member.mind.offstation_role = TRUE
				team_to_assign_to = "Red"
			if("Red")
				var/turf/possible_spawn_loc_blue = pick_n_take(blue_spawn_locations)
				var/mob/living/carbon/human/new_thunderdome_member = new(get_turf(possible_spawn_loc_blue))
				S.copy_to(new_thunderdome_member)
				new_thunderdome_member.dna.ready_dna(new_thunderdome_member)
				new_thunderdome_member.key = candidate_to_spawn.key
				to_chat(new_thunderdome_member, "You are a member of the <font color='red'><b>RED</b></font> Thunderdome team! Gear up and help your team destroy the green team!")
				new_thunderdome_member.mind.offstation_role = TRUE
				team_to_assign_to = "Green"
		dust_if_respawnable(candidate_to_spawn)
