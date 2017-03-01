client/proc/one_click_antag()
	set name = "Create Antagonist"
	set desc = "Auto-create an antagonist of your choice"
	set category = "Event"

	if(!check_rights(R_SERVER|R_EVENT))	return

	if(holder)
		holder.one_click_antag()
	return


/datum/admins/proc/one_click_antag()

	var/dat = {"<B>One-click Antagonist</B><br>
		<a href='?src=[UID()];makeAntag=1'>Make Traitors</a><br>
		<a href='?src=[UID()];makeAntag=2'>Make Changelings</a><br>
		<a href='?src=[UID()];makeAntag=3'>Make Revolutionaries</a><br>
		<a href='?src=[UID()];makeAntag=4'>Make Cult</a><br>
		<a href='?src=[UID()];makeAntag=5'>Make Wizard (Requires Ghosts)</a><br>
		<a href='?src=[UID()];makeAntag=6'>Make Vampires</a><br>
		<a href='?src=[UID()];makeAntag=7'>Make Space Raiders (Requires Ghosts)</a><br>
		<a href='?src=[UID()];makeAntag=8'>Make Abductor Team (Requires Ghosts)</a><br>
		"}
	usr << browse(dat, "window=oneclickantag;size=400x400")
	return


/datum/admins/proc/makeTraitors()
	var/datum/game_mode/traitor/temp = new

	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in player_list)
		if(ROLE_TRAITOR in applicant.client.prefs.be_special)
			if(player_old_enough_antag(applicant.client,ROLE_TRAITOR))
				if(!applicant.stat)
					if(applicant.mind)
						if(!applicant.mind.special_role)
							if(!jobban_isbanned(applicant, "traitor") && !jobban_isbanned(applicant, "Syndicate"))
								if(!(applicant.mind.assigned_role in temp.restricted_jobs))
									if(!(applicant.client.prefs.species in temp.protected_species))
										candidates += applicant

	if(candidates.len)
		var/numTratiors = min(candidates.len, 3)

		for(var/i = 0, i<numTratiors, i++)
			H = pick(candidates)
			H.mind.make_Tratior()
			candidates.Remove(H)

		return 1


	return 0


/datum/admins/proc/makeChanglings()

	var/datum/game_mode/changeling/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in player_list)
		if(ROLE_CHANGELING in applicant.client.prefs.be_special)
			if(player_old_enough_antag(applicant.client,ROLE_CHANGELING))
				if(!applicant.stat)
					if(applicant.mind)
						if(!applicant.mind.special_role)
							if(!jobban_isbanned(applicant, "changeling") && !jobban_isbanned(applicant, "Syndicate"))
								if(!(applicant.mind.assigned_role in temp.restricted_jobs))
									if(!(applicant.client.prefs.species in temp.protected_species))
										candidates += applicant

	if(candidates.len)
		var/numChanglings = min(candidates.len, 3)

		for(var/i = 0, i<numChanglings, i++)
			H = pick(candidates)
			H.mind.make_Changling()
			candidates.Remove(H)

		return 1

	return 0

/datum/admins/proc/makeRevs()

	var/datum/game_mode/revolution/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in player_list)
		if(ROLE_REV in applicant.client.prefs.be_special)
			if(player_old_enough_antag(applicant.client,ROLE_REV))
				if(applicant.stat == CONSCIOUS)
					if(applicant.mind)
						if(!applicant.mind.special_role)
							if(!jobban_isbanned(applicant, "revolutionary") && !jobban_isbanned(applicant, "Syndicate"))
								if(!(applicant.mind.assigned_role in temp.restricted_jobs))
									if(!(applicant.client.prefs.species in temp.protected_species))
										candidates += applicant

	if(candidates.len)
		var/numRevs = min(candidates.len, 3)

		for(var/i = 0, i<numRevs, i++)
			H = pick(candidates)
			H.mind.make_Rev()
			candidates.Remove(H)
		return 1

	return 0

/datum/admins/proc/makeWizard()

	var/list/candidates = pollCandidates("Do you wish to be considered for the position of a Wizard Foundation 'diplomat'?", "wizard")

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

	for(var/mob/living/carbon/human/applicant in player_list)
		if(ROLE_CULTIST in applicant.client.prefs.be_special)
			if(player_old_enough_antag(applicant.client,ROLE_CULTIST))
				if(applicant.stat == CONSCIOUS)
					if(applicant.mind)
						if(!applicant.mind.special_role)
							if(!jobban_isbanned(applicant, "cultist") && !jobban_isbanned(applicant, "Syndicate"))
								if(!(applicant.mind.assigned_role in temp.restricted_jobs))
									if(!(applicant.client.prefs.species in temp.protected_species))
										candidates += applicant

	if(candidates.len)
		var/numCultists = min(candidates.len, 4)

		for(var/i = 0, i<numCultists, i++)
			H = pick(candidates)
			H.mind.make_Cultist()
			candidates.Remove(H)

		return 1

	return 0



/datum/admins/proc/makeNukeTeam()

	var/list/mob/candidates = list()
	var/mob/theghost = null
	var/time_passed = world.time

	for(var/mob/G in respawnable_list)
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
		var/numagents = 5
		var/agentcount = 0

		for(var/i = 0, i<numagents,i++)
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

		var/nuke_code = "[rand(10000, 99999)]"

		if(nuke_spawn)
			var/obj/item/weapon/paper/P = new
			P.info = "Sadly, the Syndicate could not get you a nuclear bomb.  We have, however, acquired the arming code for the station's onboard nuke.  The nuclear authorization code is: <b>[nuke_code]</b>"
			P.name = "nuclear bomb code and instructions"
			P.loc = nuke_spawn.loc

		if(closet_spawn)
			new /obj/structure/closet/syndicate/nuclear(closet_spawn.loc)

		for(var/obj/effect/landmark/A in /area/syndicate_station/start)//Because that's the only place it can BE -Sieve
			if(A.name == "Syndicate-Gear-Closet")
				new /obj/structure/closet/syndicate/personal(A.loc)
				qdel(A)
				continue

			if(A.name == "Syndicate-Bomb")
				new /obj/effect/spawner/newbomb/timer/syndicate(A.loc)
				qdel(A)
				continue

		for(var/datum/mind/synd_mind in ticker.mode.syndicates)
			if(synd_mind.current)
				if(synd_mind.current.client)
					for(var/image/I in synd_mind.current.client.images)
						if(I.icon_state == "synd")
							qdel(I)

		for(var/datum/mind/synd_mind in ticker.mode.syndicates)
			if(synd_mind.current)
				if(synd_mind.current.client)
					for(var/datum/mind/synd_mind_1 in ticker.mode.syndicates)
						if(synd_mind_1.current)
							var/I = image('icons/mob/mob.dmi', loc = synd_mind_1.current, icon_state = "synd")
							synd_mind.current.client.images += I

		for(var/obj/machinery/nuclearbomb/bomb in world)
			bomb.r_code = nuke_code						// All the nukes are set to this code.

	return 1


//Abductors
/datum/admins/proc/makeAbductorTeam()
	new /datum/event/abductor
	return 1

/datum/admins/proc/makeAliens()
	var/datum/event/alien_infestation/E = new /datum/event/alien_infestation
	E.spawncount = 3
	// TODO The fact we have to do this rather than just have events start
	// when we ask them to, is bad.
	E.processing = TRUE
	return TRUE

/*
/datum/admins/proc/makeSpaceNinja()
	space_ninja_arrival()
	return 1
*/

/datum/admins/proc/makeDeathsquad()
	var/list/mob/candidates = list()
	var/mob/theghost = null
	var/time_passed = world.time
	var/input = "Purify the station."
	if(prob(10))
		input = "Save Runtime and any other cute things on the station."

	var/syndicate_leader_selected = 0 //when the leader is chosen. The last person spawned.

	//Generates a list of commandos from active ghosts. Then the user picks which characters to respawn as the commandos.
	for(var/mob/G in respawnable_list)
		if(!jobban_isbanned(G, "Syndicate"))
			spawn(0)
				switch(alert(G,"Do you wish to be considered for an elite syndicate strike team being sent in?","Please answer in 30 seconds!","Yes","No"))
					if("Yes")
						if((world.time-time_passed)>300)//If more than 30 game seconds passed.
							return
						candidates += G
					if("No")
						return
					else
						return
	sleep(300)

	for(var/mob/dead/observer/G in candidates)
		if(!G.key)
			candidates.Remove(G)

	if(candidates.len)
		var/numagents = 6
		//Spawns commandos and equips them.
		for(var/obj/effect/landmark/L in /area/syndicate_mothership/elite_squad)
			if(numagents<=0)
				break
			if(L.name == "Syndicate-Commando")
				syndicate_leader_selected = numagents == 1?1:0

				var/mob/living/carbon/human/new_syndicate_commando = create_syndicate_death_commando(L, syndicate_leader_selected)


				while((!theghost || !theghost.client) && candidates.len)
					theghost = pick(candidates)
					candidates.Remove(theghost)

				if(!theghost)
					qdel(new_syndicate_commando)
					break

				new_syndicate_commando.key = theghost.key
				new_syndicate_commando.internal = new_syndicate_commando.s_store
				new_syndicate_commando.update_internals_hud_icon(1)

				//So they don't forget their code or mission.


				to_chat(new_syndicate_commando, "\blue You are an Elite Syndicate. [!syndicate_leader_selected?"commando":"<B>LEADER</B>"] in the service of the Syndicate. \nYour current mission is: <span class='danger'> [input]</span>")

				numagents--
		if(numagents >= 6)
			return 0

		for(var/obj/effect/landmark/L in /area/shuttle/syndicate_elite)
			if(L.name == "Syndicate-Commando-Bomb")
				new /obj/effect/spawner/newbomb/timer/syndicate(L.loc)

	return 1


/proc/makeBody(var/mob/dead/observer/G_found) // Uses stripped down and bastardized code from respawn character
	if(!G_found || !G_found.key)	return

	//First we spawn a dude.
	var/mob/living/carbon/human/new_character = new(pick(latejoin))//The mob being spawned.

	var/datum/preferences/A = new(G_found.client)
	A.copy_to(new_character)

	new_character.dna.ready_dna(new_character)
	new_character.key = G_found.key

	return new_character

/datum/admins/proc/create_syndicate_death_commando(obj/spawn_location, syndicate_leader_selected = 0)
	var/mob/living/carbon/human/new_syndicate_commando = new(spawn_location.loc)
	var/syndicate_commando_leader_rank = pick("Lieutenant", "Captain", "Major")
	var/syndicate_commando_rank = pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
	var/syndicate_commando_name = pick(last_names)

	var/datum/preferences/A = new()//Randomize appearance for the commando.
	if(syndicate_leader_selected)
		A.real_name = "[syndicate_commando_leader_rank] [syndicate_commando_name]"
		A.age = rand(35,45)
	else
		A.real_name = "[syndicate_commando_rank] [syndicate_commando_name]"
	A.copy_to(new_syndicate_commando)

	new_syndicate_commando.dna.ready_dna(new_syndicate_commando)//Creates DNA.

	//Creates mind stuff.
	new_syndicate_commando.mind_initialize()
	new_syndicate_commando.mind.assigned_role = "MODE"
	new_syndicate_commando.mind.special_role = SPECIAL_ROLE_SYNDICATE_DEATHSQUAD

	//Adds them to current traitor list. Which is really the extra antagonist list.
	ticker.mode.traitors += new_syndicate_commando.mind
	new_syndicate_commando.equip_syndicate_commando(syndicate_leader_selected)

	return new_syndicate_commando

/datum/admins/proc/makeVampires()

	var/datum/game_mode/vampire/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in player_list)
		if(ROLE_VAMPIRE in applicant.client.prefs.be_special)
			if(player_old_enough_antag(applicant.client,ROLE_VAMPIRE))
				if(!applicant.stat)
					if(applicant.mind)
						if(!applicant.mind.special_role)
							if(!jobban_isbanned(applicant, "vampire") && !jobban_isbanned(applicant, "Syndicate"))
								if(!(applicant.job in temp.restricted_jobs))
									if(!(applicant.client.prefs.species in temp.protected_species))
										candidates += applicant

	if(candidates.len)
		var/numVampires = min(candidates.len, 3)

		for(var/i = 0, i<numVampires, i++)
			H = pick(candidates)
			ticker.mode.vampires += H.mind
			ticker.mode.grant_vampire_powers(H)
			ticker.mode.update_vampire_icons_added(H.mind)
			candidates.Remove(H)

		return 1

	return 0

/datum/admins/proc/makeRaiders()
	var/list/mob/candidates = list()
	var/mob/theghost = null
	var/input = "Loot and burn the station or trade with it."

	candidates = pollCandidates("Do you wish to be considered for a Space Pirate party about to be sent in?", SPECIAL_ROLE_RAIDER, 1)

	for(var/mob/dead/observer/G in candidates)
		if(!G.key)
			candidates.Remove(G)
	for(var/mob/j in candidates)
		if(!j || !j.client)
			candidates.Remove(j)
			continue

	if(candidates.len)
		var/raidernum = rand(3, 6)
		for(var/obj/effect/landmark/L in world)
			if(!candidates.len || !raidernum)
				break
			if(L.name != "raiderstart")
				continue

			theghost = pick(candidates)
			candidates.Remove(theghost)
			var/mob/living/carbon/human/M = new(get_turf(L))
			M.key = theghost.key
			var/datum/preferences/P = new
			P.species = M.client.prefs.species
			P.real_name = M.generate_name()
			P.random_character()
			P.copy_to(M)
			theghost.name = M.real_name
			M.equip_raider()
			to_chat(M, "<span class='danger'>You're a Space Pirate hired by the Syndicate. \nYour current mission is: [input]</span>")
			raidernum--
	return 1


/datum/admins/proc/makeThunderdomeTeams() // Not strictly an antag, but this seemed to be the best place to put it.

	var/list/mob/candidates = list()
	var/mob/theghost = null
	var/time_passed = world.time

	//Generates a list of candidates from active ghosts.
	for(var/mob/G in respawnable_list)
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
		for(var/obj/effect/landmark/L in world)
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
