/client/proc/one_click_antag()
	set name = "Create Antagonist"
	set desc = "Auto-create an antagonist of your choice"
	set category = "Event"

	if(!check_rights(R_SERVER|R_EVENT))	return

	if(holder)
		holder.one_click_antag()
	return


/datum/admins/proc/one_click_antag()

	var/dat = {"<meta charset="UTF-8"><B>One-click Antagonist</B><br>
		<a href='?src=[UID()];makeAntag=1'>Make Traitors</a><br>
		<a href='?src=[UID()];makeAntag=2'>Make Changelings</a><br>
		<a href='?src=[UID()];makeAntag=3'>Make Revolutionaries</a><br>
		<a href='?src=[UID()];makeAntag=4'>Make Cult</a><br>
		<a href='?src=[UID()];makeAntag=5'>Make Clockwork Cult</a><br>
		<a href='?src=[UID()];makeAntag=6'>Make Wizard (Requires Ghosts)</a><br>
		<a href='?src=[UID()];makeAntag=7'>Make Vampires</a><br>
		<a href='?src=[UID()];makeAntag=8'>Make Vox Raiders (Requires Ghosts)</a><br>
		<a href='?src=[UID()];makeAntag=9'>Make Abductor Team (Requires Ghosts)</a><br>
		<a href='?src=[UID()];makeAntag=10'>Make Space Ninja (Requires Ghosts)</a><br>
		"}
	usr << browse(dat, "window=oneclickantag;size=400x400")
	return

/datum/admins/proc/CandCheck(var/role = null, var/mob/living/carbon/human/M, var/datum/game_mode/temp = null)
  // You pass in ROLE define (optional), the applicant, and the gamemode, and it will return true / false depending on whether the applicant qualify for the candidacy in question
	if(jobban_isbanned(M, "Syndicate"))
		return FALSE
	if(M.stat || !M.mind || M.mind.special_role || M.mind.offstation_role)
		return FALSE
	if(temp)
		if((M.mind.assigned_role in temp.restricted_jobs) || (M.client.prefs.species in temp.protected_species))
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

	if(config.protect_roles_from_antagonist)
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

	if(candidates.len)
		var/numTraitors = min(candidates.len, antnum)

		for(var/i = 0, i<numTraitors, i++)
			H = pick(candidates)
			H.mind.make_Traitor()
			candidates.Remove(H)

		return 1
	return 0


/datum/admins/proc/makeChangelings()

	var/datum/game_mode/changeling/temp = new
	if(config.protect_roles_from_antagonist)
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

	if(candidates.len)
		var/numChangelings = min(candidates.len, antnum)

		for(var/i = 0, i<numChangelings, i++)
			H = pick(candidates)
			H.mind.make_Changeling()
			candidates.Remove(H)

		return 1
	return 0

/datum/admins/proc/makeRevs()

	var/datum/game_mode/revolution/temp = new
	if(config.protect_roles_from_antagonist)
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

	if(candidates.len)
		var/numRevs = min(candidates.len, antnum)

		for(var/i = 0, i<numRevs, i++)
			H = pick(candidates)
			H.mind.make_Rev()
			candidates.Remove(H)
		return 1
	return 0

/datum/admins/proc/makeWizard()

	var/confirm = alert("Are you sure?", "Confirm creation", "Yes", "No")
	if(confirm != "Yes")
		return 0
	var/image/I = new('icons/mob/simple_human.dmi', "wizard")
	var/list/candidates = SSghost_spawns.poll_candidates("Do you wish to be considered for the position of a Wizard Foundation 'diplomat'?", ROLE_WIZARD, source = I)

	log_admin("[key_name(owner)] tried making a Wizard with One-Click-Antag")
	message_admins("[key_name_admin(owner)] tried making a Wizard with One-Click-Antag")

	if(candidates.len)
		var/mob/dead/observer/selected = pick(candidates)
		candidates -= selected

		var/mob/living/carbon/human/new_character = makeBody(selected)
		new_character.mind.make_Wizard()
		return 1
	return 0


/datum/admins/proc/makeCult()

	var/datum/game_mode/cult/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null
	var/antnum = input(owner, "How many cultists do you want to create? Enter 0 to cancel.", "Amount:", 0) as num
	if(!antnum || antnum <= 0) // 5 because cultist can really screw balance over if spawned in high amount.
		return
	log_admin("[key_name(owner)] tried making a Cult with One-Click-Antag")
	message_admins("[key_name_admin(owner)] tried making a Cult with One-Click-Antag")

	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		if(CandCheck(ROLE_CULTIST, applicant, temp))
			candidates += applicant

	if(length(candidates))
		var/numCultists = min(length(candidates), antnum)

		for(var/I in 1 to numCultists)
			H = pick(candidates)
			to_chat(H, CULT_GREETING)
			SSticker.mode.add_cultist(H.mind)
			SSticker.mode.equip_cultist(H)
			candidates.Remove(H)
		return TRUE
	return FALSE

/datum/admins/proc/makeClockwork()

	var/datum/game_mode/clockwork/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null
	var/antnum = input(owner, "How many cultists do you want to create? Enter 0 to cancel.", "Amount:", 0) as num
	if(!antnum || antnum <= 0) // 5 because cultist can really screw balance over if spawned in high amount.
		return
	log_admin("[key_name(owner)] tried making a Clockwork Cult with One-Click-Antag")
	message_admins("[key_name_admin(owner)] tried making a Clockwork Cult with One-Click-Antag")

	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		if(CandCheck(ROLE_CLOCKER, applicant, temp))
			candidates += applicant

	if(length(candidates))
		var/numclocks = min(length(candidates), antnum)

		for(var/I in 1 to numclocks)
			H = pick(candidates)
			to_chat(H, CLOCK_GREETING)
			SSticker.mode.add_clocker(H.mind)
			SSticker.mode.equip_clocker(H)
			candidates.Remove(H)
		return TRUE
	return FALSE

/datum/admins/proc/makeNukeTeam()

	var/list/mob/candidates = list()
	var/mob/theghost = null
	var/time_passed = world.time

	var/antnum = input(owner, "How many nuclear operative you want to create? Enter 0 to cancel.","Amount:", 0) as num
	if(!antnum || antnum <= 0)
		return
	log_admin("[key_name(owner)] tried making a [antnum] person Nuke Op Team with One-Click-Antag")
	message_admins("[key_name_admin(owner)] tried making a [antnum] person Nuke Op Team with One-Click-Antag")

	for(var/mob/G in GLOB.respawnable_list)
		if(istype(G) && G.client && (ROLE_OPERATIVE in G.client.prefs.be_special))
			if(!jobban_isbanned(G, "operative") && !jobban_isbanned(G, "Syndicate"))
				if(player_old_enough_antag(G.client,ROLE_OPERATIVE))
					spawn(0)
						switch(alert(G,"Do you wish to be considered for a nuke team being sent in?","Please answer in 30 seconds!","Yes","No"))
							if("Yes")
								if((world.time-time_passed)>300)//If more than 30 game seconds passed.
									return
								candidates += G
							if("No")
								return
							else
								return

	sleep(300)

	if(candidates.len)
		var/agentcount = 0

		for(var/i = 0, i<antnum,i++)
			shuffle(candidates) //More shuffles means more randoms
			for(var/mob/j in candidates)
				if(!j || !j.client)
					candidates.Remove(j)
					continue

				theghost = candidates
				candidates.Remove(theghost)

				var/mob/living/carbon/human/new_character=makeBody(theghost)
				new_character.mind.make_Nuke()

				agentcount++

		if(agentcount < 1)
			return 0

		var/obj/effect/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")
		var/obj/effect/landmark/closet_spawn = locate("landmark*Nuclear-Closet")

		var/nuke_code = rand(10000, 99999)

		if(nuke_spawn)
			var/obj/item/paper/P = new
			P.info = "Sadly, the Syndicate could not get you a nuclear bomb.  We have, however, acquired the arming code for the station's onboard nuke.  The nuclear authorization code is: <b>[nuke_code]</b>"
			P.name = "nuclear bomb code and instructions"
			P.loc = nuke_spawn.loc

		if(closet_spawn)
			new /obj/structure/closet/syndicate/nuclear(closet_spawn.loc)

		for(var/datum/mind/synd_mind in SSticker.mode.syndicates)
			if(synd_mind.current)
				if(synd_mind.current.client)
					for(var/image/I in synd_mind.current.client.images)
						if(I.icon_state == "synd")
							qdel(I)

		for(var/datum/mind/synd_mind in SSticker.mode.syndicates)
			if(synd_mind.current)
				if(synd_mind.current.client)
					for(var/datum/mind/synd_mind_1 in SSticker.mode.syndicates)
						if(synd_mind_1.current)
							var/I = image('icons/mob/mob.dmi', loc = synd_mind_1.current, icon_state = "synd")
							synd_mind.current.client.images += I

		for(var/obj/machinery/nuclearbomb/bomb in GLOB.machines)
			bomb.r_code = nuke_code						// All the nukes are set to this code.
	return 1

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
	var/datum/event/alien_infestation/E = new /datum/event/alien_infestation

	var/antnum = input(owner, "How many aliens you want to create? Enter 0 to cancel.","Amount:", 0) as num
	if(!antnum || antnum <= 0)
		return
	log_admin("[key_name(owner)] tried making Aliens with One-Click-Antag")
	message_admins("[key_name_admin(owner)] tried making Aliens with One-Click-Antag")

	E.spawncount = antnum
	// TODO The fact we have to do this rather than just have events start
	// when we ask them to, is bad.
	E.processing = TRUE
	return TRUE


/datum/admins/proc/makeSpaceNinja()
	var/confirm = alert("Are you sure?", "Confirm creation", "Yes", "No")
	if(confirm != "Yes")
		return 0
	var/datum/objective/custom_objective = null
	if(alert(usr, "Хотите ли вы выдать этому ниндзя особую цель?","Особая цель","Да", "Нет") == "Да")
		var/expl = sanitize(copytext_char(input("Custom objective:", "Objective", "") as text|null,1,MAX_MESSAGE_LEN))
		if(!expl)
			return
		custom_objective = new
		custom_objective.explanation_text = expl
	var/image/I = new('icons/mob/ninja_previews.dmi', "ninja_preview_new_hood_green")
	var/list/candidates = SSghost_spawns.poll_candidates("Do you wish to be considered for the position of a Spider Clan Assassin'?", ROLE_NINJA, source = I)

	log_admin("[key_name(owner)] tried making a Space Ninja with One-Click-Antag")
	message_admins("[key_name_admin(owner)] tried making a Space Ninja with One-Click-Antag")

	if(candidates.len)
		var/mob/dead/observer/selected = pick(candidates)
		candidates -= selected
		var/mob/living/carbon/human/new_character = makeBody(selected)
		new_character.mind.make_Space_Ninja(custom_objective)
		return 1
	return 0

/proc/makeBody(var/mob/dead/observer/G_found) // Uses stripped down and bastardized code from respawn character
	if(!G_found || !G_found.key)	return

	//First we spawn a dude.
	var/mob/living/carbon/human/new_character = new(pick(GLOB.latejoin))//The mob being spawned.

	var/datum/preferences/A = new(G_found.client)
	A.copy_to(new_character)

	new_character.dna.ready_dna(new_character)
	new_character.key = G_found.key

	return new_character

/datum/admins/proc/create_syndicate_death_commando(obj/spawn_location, syndicate_leader_selected = 0)
	var/mob/living/carbon/human/new_syndicate_commando = new(spawn_location.loc)
	var/syndicate_commando_leader_rank = pick("Лейтенант", "Капитан", "Майор")
	var/syndicate_commando_rank = pick("Младший Сержант", "Сержант", "Старший Сержант", "Старшина", "Прапорщик", "Старший Прапорщик")
	var/syndicate_commando_name = pick(GLOB.last_names)

	var/datum/preferences/A = new()//Randomize appearance for the commando.
	if(syndicate_leader_selected)
		A.real_name = "[syndicate_commando_leader_rank] [A.gender==FEMALE ? pick(GLOB.last_names_female) : syndicate_commando_name]"
		A.age = rand(35,45)
	else
		A.real_name = "[syndicate_commando_rank] [A.gender==FEMALE ? pick(GLOB.last_names_female) : syndicate_commando_name]"
	A.copy_to(new_syndicate_commando)

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

/datum/admins/proc/makeVoxRaiders()
	var/antnum = input(owner, "How many raiders you want to create? Enter 0 to cancel.","Amount:", 0) as num
	if(!antnum || antnum <= 0)
		return
	log_admin("[key_name(owner)] tried making Vox Raiders with One-Click-Antag")
	message_admins("[key_name_admin(owner)] tried making Vox Raiders with One-Click-Antag")

	var/list/candidates = SSghost_spawns.poll_candidates("Do you wish to be considered for a vox raiding party arriving on the station?", ROLE_RAIDER)

	if(!length(candidates))
		return 0

	var/raider_num = min(antnum, candidates.len)
	var/datum/game_mode/mode = SSticker.mode
	//If there no vox objectives - create them
	if(!mode.raid_objectives || !mode.raid_objectives.len)
		mode.raid_objectives = mode.forge_vox_objectives()
	//Spawns vox raiders and equips them.
	while(raider_num > 0)
		var/mob/dead/observer/candidate = pick(candidates)
		candidates -= candidate

		var/datum/mind/raider = new

		SSticker.minds += raider
		mode.raiders += raider

		raider.assigned_role = SPECIAL_ROLE_RAIDER
		raider.special_role = SPECIAL_ROLE_RAIDER
		raider.offstation_role = TRUE

		if(mode.raid_objectives)
			raider.objectives = mode.raid_objectives.Copy()

		var/index = raider_num
		if(index > GLOB.raider_spawn.len)
			index = 1

		var/mob/living/carbon/human/new_vox = new /mob/living/carbon/human/vox(GLOB.raider_spawn[index])
		new_vox.mind = raider
		raider.current = new_vox
		raider.original = new_vox

		raider.key = candidate.key
		new_vox.key = raider.key

		mode.create_vox(raider)
		mode.greet_vox(raider)

		raider_num--
	return 1

/datum/admins/proc/makeVampires()

	var/datum/game_mode/vampire/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	var/antnum = input(owner, "How many vampires you want to create? Enter 0 to cancel","Amount:", 0) as num
	if(!antnum || antnum <= 0)
		return

	log_admin("[key_name(owner)] tried making Vampires with One-Click-Antag")
	message_admins("[key_name_admin(owner)] tried making Vampires with One-Click-Antag")

	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		if(CandCheck(ROLE_VAMPIRE, applicant, temp))
			candidates += applicant

	if(candidates.len)
		var/numVampires = min(candidates.len, antnum)

		for(var/i = 0, i<numVampires, i++)
			H = pick(candidates)
			H.mind.make_Vampire()
			candidates.Remove(H)

		return 1
	return 0

/datum/admins/proc/makeThunderdomeTeams() // Not strictly an antag, but this seemed to be the best place to put it.

	var/list/mob/candidates = list()
	var/mob/theghost = null
	var/time_passed = world.time

	log_admin("[key_name(owner)] tried making Thunderdome Teams with One-Click-Antag")
	message_admins("[key_name_admin(owner)] tried making Thunderdone Teams with One-Click-Antag")

	//Generates a list of candidates from active ghosts.
	for(var/mob/G in GLOB.respawnable_list)
		spawn(0)
			switch(alert(G,"Do you wish to be considered for a Thunderdome match about to start?","Please answer in 30 seconds!","Yes","No"))
				if("Yes")
					if((world.time-time_passed)>300)//If more than 30 game seconds passed.
						return
					candidates += G
				if("No")
					return
				else
					return

	sleep(300) //Debug.

	for(var/mob/dead/observer/G in candidates)
		if(!G.key)
			candidates.Remove(G)

	if(candidates.len)
		var/teamOneMembers = 5
		var/teamTwoMembers = 5
		var/datum/preferences/A = new()
		for(var/thing in GLOB.landmarks_list)
			var/obj/effect/landmark/L = thing
			if(L.name == "tdome1")
				if(teamOneMembers<=0)
					break

				var/mob/living/carbon/human/newMember = new(L.loc)

				A.copy_to(newMember)

				newMember.dna.ready_dna(newMember)

				while((!theghost || !theghost.client) && candidates.len)
					theghost = pick(candidates)
					candidates.Remove(theghost)

				if(!theghost)
					qdel(newMember)
					break

				newMember.key = theghost.key
				teamOneMembers--
				to_chat(newMember, "You are a member of the <font color = 'green'><b>GREEN</b></font> Thunderdome team! Gear up and help your team destroy the red team!")

			if(L.name == "tdome2")
				if(teamTwoMembers<=0)
					break

				var/mob/living/carbon/human/newMember = new(L.loc)

				A.copy_to(newMember)

				newMember.dna.ready_dna(newMember)

				while((!theghost || !theghost.client) && candidates.len)
					theghost = pick(candidates)
					candidates.Remove(theghost)

				if(!theghost)
					qdel(newMember)
					break

				newMember.key = theghost.key
				teamTwoMembers--
				to_chat(newMember, "You are a member of the <font color = 'red'><b>RED</b></font> Thunderdome team! Gear up and help your team destroy the green team!")
	else
		return 0
	return 1
