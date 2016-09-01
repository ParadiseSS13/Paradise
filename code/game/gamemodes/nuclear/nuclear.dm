/datum/game_mode
	var/list/datum/mind/syndicates = list()

proc/issyndicate(mob/living/M as mob)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.syndicates)

/datum/game_mode/nuclear
	name = "nuclear emergency"
	config_tag = "nuclear"
	required_players = 30	// 30 players - 5 players to be the nuke ops = 25 players remaining
	required_enemies = 5
	recommended_enemies = 5

	var/const/agents_possible = 5 //If we ever need more syndicate agents.

	var/nukes_left = 1 // Call 3714-PRAY right now and order more nukes! Limited offer!
	var/nuke_off_station = 0 //Used for tracking if the syndies actually haul the nuke to the station
	var/syndies_didnt_escape = 0 //Used for tracking if the syndies got the shuttle off of the z-level


/datum/game_mode/nuclear/announce()
	to_chat(world, "<B>The current game mode is - Nuclear Emergency!</B>")
	to_chat(world, "<B>A [syndicate_name()] Strike Force is approaching [station_name()]!</B>")
	to_chat(world, "A nuclear explosive was being transported by Nanotrasen to a military base. The transport ship mysteriously lost contact with Space Traffic Control (STC). About that time a strange disk was discovered around [station_name()]. It was identified by Nanotrasen as a nuclear authentication disk and now Syndicate Operatives have arrived to retake the disk and detonate SS13! There are most likely Syndicate starships are in the vicinity, so take care not to lose the disk!\n<B>Syndicate</B>: Reclaim the disk and detonate the nuclear bomb anywhere on SS13.\n<B>Personnel</B>: Hold the disk and <B>escape with the disk</B> on the shuttle!")

/datum/game_mode/nuclear/can_start()//This could be better, will likely have to recode it later
	if(!..())
		return 0

	var/list/possible_syndicates = get_players_for_role(ROLE_OPERATIVE)
	var/agent_number = 0

	if(possible_syndicates.len < 1)
		return 0

	if(possible_syndicates.len > agents_possible)
		agent_number = agents_possible
	else
		agent_number = possible_syndicates.len

	var/n_players = num_players()
	if(agent_number > n_players)
		agent_number = n_players/2

	while(agent_number > 0)
		var/datum/mind/new_syndicate = pick(possible_syndicates)
		syndicates += new_syndicate
		possible_syndicates -= new_syndicate //So it doesn't pick the same guy each time.
		agent_number--

	for(var/datum/mind/synd_mind in syndicates)
		synd_mind.assigned_role = "MODE" //So they aren't chosen for other jobs.
		synd_mind.special_role = SPECIAL_ROLE_NUKEOPS
	return 1


/datum/game_mode/nuclear/pre_setup()
	return 1


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/proc/update_synd_icons_added(datum/mind/synd_mind)
	var/datum/atom_hud/antag/opshud = huds[ANTAG_HUD_OPS]
	opshud.join_hud(synd_mind.current)
	set_antag_hud(synd_mind.current, "hudoperative")

/datum/game_mode/proc/update_synd_icons_removed(datum/mind/synd_mind)
	var/datum/atom_hud/antag/opshud = huds[ANTAG_HUD_OPS]
	opshud.leave_hud(synd_mind.current)
	set_antag_hud(synd_mind.current, null)

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/nuclear/post_setup()

	var/list/turf/synd_spawn = list()

	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "Syndicate-Spawn")
			synd_spawn += get_turf(A)
			qdel(A)
			continue

	var/obj/effect/landmark/uplinklocker = locate("landmark*Syndicate-Uplink")	//i will be rewriting this shortly
	var/obj/effect/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")

	var/nuke_code = "[rand(10000, 99999)]"
	var/leader_selected = 0
	var/agent_number = 1
	var/spawnpos = 1

	for(var/datum/mind/synd_mind in syndicates)
		if(spawnpos > synd_spawn.len)
			spawnpos = 2
		synd_mind.current.loc = synd_spawn[spawnpos]

		forge_syndicate_objectives(synd_mind)
		create_syndicate(synd_mind)
		greet_syndicate(synd_mind)
		equip_syndicate(synd_mind.current)

		if(!leader_selected)
			prepare_syndicate_leader(synd_mind, nuke_code)
			leader_selected = 1
		else
			synd_mind.current.real_name = "[syndicate_name()] Operative #[agent_number]"

			var/list/foundIDs = synd_mind.current.search_contents_for(/obj/item/weapon/card/id)
			if(foundIDs.len)
				for(var/obj/item/weapon/card/id/ID in foundIDs)
					ID.name = "[syndicate_name()] Operative ID card"
					ID.registered_name = synd_mind.current.real_name

			agent_number++
		spawnpos++
		update_synd_icons_added(synd_mind)

	//update_all_synd_icons()

	if(uplinklocker)
		new /obj/structure/closet/syndicate/nuclear(uplinklocker.loc)
	if(nuke_spawn && synd_spawn.len > 0)
		var/obj/machinery/nuclearbomb/syndicate/the_bomb = new /obj/machinery/nuclearbomb/syndicate(nuke_spawn.loc)
		the_bomb.r_code = nuke_code

	return ..()

/datum/game_mode/proc/create_syndicate(var/datum/mind/synd_mind) // So we don't have inferior species as ops - randomize a human
	var/mob/living/carbon/human/M = synd_mind.current
	var/obj/item/organ/external/head/head_organ = M.get_organ("head")

	M.set_species("Human",1)
	M.dna.ready_dna(M) // Quadriplegic Nuke Ops won't be participating in the paralympics

	var/hair_c = pick("#8B4513","#000000","#FF4500","#FFD700") // Brown, black, red, blonde
	var/eye_c = pick("#000000","#8B4513","1E90FF") // Black, brown, blue
	var/skin_tone = pick(-50, -30, -10, 0, 0, 0, 10) // Caucasian/black
	var/hair_style = "Bald"
	var/facial_hair_style = "Shaved"
	if(M.gender == MALE)
		hair_style = pick(hair_styles_male_list)
		facial_hair_style = pick(facial_hair_styles_list)
	else
		hair_style = pick(hair_styles_female_list)
		if(prob(5))
			facial_hair_style = pick(facial_hair_styles_list)

	head_organ.r_facial = hex2num(copytext(hair_c, 2, 4))
	head_organ.g_facial = hex2num(copytext(hair_c, 4, 6))
	head_organ.b_facial = hex2num(copytext(hair_c, 6, 8))
	head_organ.r_hair = hex2num(copytext(hair_c, 2, 4))
	head_organ.g_hair = hex2num(copytext(hair_c, 4, 6))
	head_organ.b_hair = hex2num(copytext(hair_c, 6, 8))
	var/eyes_red = hex2num(copytext(eye_c, 2, 4))
	var/eyes_green = hex2num(copytext(eye_c, 4, 6))
	var/eyes_blue = hex2num(copytext(eye_c, 6, 8))
	M.change_eye_color(eyes_red, eyes_green, eyes_blue)
	M.s_tone = skin_tone
	head_organ.h_style = hair_style
	head_organ.f_style = facial_hair_style
	M.body_accessory = null

/datum/game_mode/proc/prepare_syndicate_leader(var/datum/mind/synd_mind, var/nuke_code)
	var/leader_title = pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")
	/*
	spawn(1)
		NukeNameAssign(nukelastname(synd_mind.current),syndicates) //allows time for the rest of the syndies to be chosen
	*/
	synd_mind.current.real_name = "[syndicate_name()] Team [leader_title]"
	to_chat(synd_mind.current, "<B>You are the Syndicate leader for this mission. You are responsible for the distribution of telecrystals and your ID is the only one who can open the launch bay doors.</B>")
	to_chat(synd_mind.current, "<B>If you feel you are not up to this task, give your ID to another operative.</B>")
	to_chat(synd_mind.current, "<B>In your hand you will find a special item capable of triggering a greater challenge for your team. Examine it carefully and consult with your fellow operatives before activating it.</B>")

	var/obj/item/device/nuclear_challenge/challenge = new /obj/item/device/nuclear_challenge
	synd_mind.current.equip_to_slot_or_del(challenge, slot_r_hand)

	var/list/foundIDs = synd_mind.current.search_contents_for(/obj/item/weapon/card/id)

	if(foundIDs.len)
		for(var/obj/item/weapon/card/id/ID in foundIDs)
			ID.name = "[syndicate_name()] [leader_title] ID card"
			ID.registered_name = synd_mind.current.real_name
			ID.access += access_syndicate_leader
	else
		message_admins("Warning: Nuke Ops spawned without access to leave their spawn area!")

	if(nuke_code)
		synd_mind.store_memory("<B>Syndicate Nuclear Bomb Code</B>: [nuke_code]", 0, 0)
		to_chat(synd_mind.current, "The nuclear authorization code is: <B>[nuke_code]</B>")
		var/obj/item/weapon/paper/P = new
		P.info = "The nuclear authorization code is: <b>[nuke_code]</b>"
		P.name = "nuclear bomb code"
		var/obj/item/weapon/stamp/syndicate/stamp = new
		P.stamp(stamp)
		qdel(stamp)

		if(ticker.mode.config_tag=="nuclear")
			P.loc = synd_mind.current.loc
		else
			var/mob/living/carbon/human/H = synd_mind.current
			P.loc = H.loc
			H.equip_to_slot_or_del(P, slot_r_store, 0)
			H.update_icons()

	else
		nuke_code = "code will be provided later"
	return


/datum/game_mode/proc/forge_syndicate_objectives(var/datum/mind/syndicate)
	var/datum/objective/nuclear/syndobj = new
	syndobj.owner = syndicate
	syndicate.objectives += syndobj


/datum/game_mode/proc/greet_syndicate(var/datum/mind/syndicate, var/you_are=1)
	if(you_are)
		to_chat(syndicate.current, "\blue You are a [syndicate_name()] agent!")
	var/obj_count = 1
	for(var/datum/objective/objective in syndicate.objectives)
		to_chat(syndicate.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	return


/datum/game_mode/proc/random_radio_frequency()
	return 1337 // WHY??? -- Doohl


/datum/game_mode/proc/equip_syndicate(mob/living/carbon/human/synd_mob)
	var/radio_freq = SYND_FREQ

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate/alt(synd_mob)
	R.set_frequency(radio_freq)
	synd_mob.equip_to_slot_or_del(R, slot_l_ear)

	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(synd_mob), slot_w_uniform)
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(synd_mob), slot_shoes)
	synd_mob.equip_or_collect(new /obj/item/clothing/gloves/combat(synd_mob), slot_gloves)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/card/id/syndicate(synd_mob), slot_wear_id)
	if(synd_mob.backbag == 2) synd_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(synd_mob), slot_back)
	if(synd_mob.backbag == 3) synd_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(synd_mob), slot_back)
	if(synd_mob.backbag == 4) synd_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(synd_mob), slot_back)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/pill/initropidril(synd_mob), slot_in_backpack)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/pistol(synd_mob), slot_belt)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(synd_mob.back), slot_in_backpack)

	var/obj/item/device/radio/uplink/U = new /obj/item/device/radio/uplink(synd_mob)
	U.hidden_uplink.uplink_owner="[synd_mob.key]"
	U.hidden_uplink.uses = 20
	synd_mob.equip_to_slot_or_del(U, slot_in_backpack)

	if(synd_mob.species)

		/*
		Incase anyone ever gets the burning desire to have nukeops with randomized apperances. -- Dave
		synd_mob.gender = pick(MALE, FEMALE) // Randomized appearances for the nukeops.
		var/datum/preferences/pref = new()
		A.randomize_appearance_for(synd_mob)
		*/

		var/race = synd_mob.species.name

		switch(race)
			if("Vox" || "Vox Armalis")
				synd_mob.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/syndicate(synd_mob), slot_wear_mask)
				synd_mob.equip_to_slot_or_del(new /obj/item/weapon/tank/nitrogen(synd_mob), slot_l_hand)
				synd_mob.internal = synd_mob.l_hand
				synd_mob.update_internals_hud_icon(1)

	var/obj/item/weapon/implant/explosive/E = new/obj/item/weapon/implant/explosive(synd_mob)
	E.implant(synd_mob)
	synd_mob.faction |= "syndicate"
	synd_mob.update_icons()
	return 1


/datum/game_mode/nuclear/check_win()
	if(nukes_left == 0)
		return 1
	return ..()


/datum/game_mode/proc/is_operatives_are_dead()
	for(var/datum/mind/operative_mind in syndicates)
		if(!istype(operative_mind.current,/mob/living/carbon/human))
			if(operative_mind.current)
				if(operative_mind.current.stat!=2)
					return 0
	return 1


/datum/game_mode/nuclear/declare_completion()
	var/disk_rescued = 1
	for(var/obj/item/weapon/disk/nuclear/D in world)
		var/disk_area = get_area(D)
		if(!is_type_in_list(disk_area, centcom_areas))
			if(disk_area == shuttle_master.emergency.areaInstance && shuttle_master.emergency.mode >= SHUTTLE_ESCAPE) //snowflaked into objectives because shitty bay shuttles had areas to auto-determine this
				break
			disk_rescued = 0
			break
	var/crew_evacuated = (shuttle_master.emergency.mode >= SHUTTLE_ESCAPE)
	//var/operatives_are_dead = is_operatives_are_dead()


	//nukes_left
	//station_was_nuked
	//derp //Used for tracking if the syndies actually haul the nuke to the station	//no
	//herp //Used for tracking if the syndies got the shuttle off of the z-level	//NO, DON'T FUCKING NAME VARS LIKE THIS

	if(!disk_rescued &&  station_was_nuked &&          !syndies_didnt_escape)
		feedback_set_details("round_end_result","win - syndicate nuke")
		to_chat(world, "<FONT size = 3><B>Syndicate Major Victory!</B></FONT>")
		to_chat(world, "<B>[syndicate_name()] operatives have destroyed [station_name()]!</B>")

	else if(!disk_rescued &&  station_was_nuked &&           syndies_didnt_escape)
		feedback_set_details("round_end_result","halfwin - syndicate nuke - did not evacuate in time")
		to_chat(world, "<FONT size = 3><B>Total Annihilation</B></FONT>")
		to_chat(world, "<B>[syndicate_name()] operatives destroyed [station_name()] but did not leave the area in time and got caught in the explosion.</B> Next time, don't lose the disk!")

	else if(!disk_rescued && !station_was_nuked &&  nuke_off_station && !syndies_didnt_escape)
		feedback_set_details("round_end_result","halfwin - blew wrong station")
		to_chat(world, "<FONT size = 3><B>Crew Minor Victory</B></FONT>")
		to_chat(world, "<B>[syndicate_name()] operatives secured the authentication disk but blew up something that wasn't [station_name()].</B> Next time, don't lose the disk!")

	else if(!disk_rescued && !station_was_nuked &&  nuke_off_station &&  syndies_didnt_escape)
		feedback_set_details("round_end_result","halfwin - blew wrong station - did not evacuate in time")
		to_chat(world, "<FONT size = 3><B>[syndicate_name()] operatives have earned Darwin Award!</B></FONT>")
		to_chat(world, "<B>[syndicate_name()] operatives blew up something that wasn't [station_name()] and got caught in the explosion.</B> Next time, don't lose the disk!")

	else if( disk_rescued                                         && is_operatives_are_dead())
		feedback_set_details("round_end_result","loss - evacuation - disk secured - syndi team dead")
		to_chat(world, "<FONT size = 3><B>Crew Major Victory!</B></FONT>")
		to_chat(world, "<B>The Research Staff has saved the disc and killed the [syndicate_name()] Operatives</B>")

	else if( disk_rescued                                        )
		feedback_set_details("round_end_result","loss - evacuation - disk secured")
		to_chat(world, "<FONT size = 3><B>Crew Major Victory</B></FONT>")
		to_chat(world, "<B>The Research Staff has saved the disc and stopped the [syndicate_name()] Operatives!</B>")

	else if(!disk_rescued                                         && is_operatives_are_dead())
		feedback_set_details("round_end_result","loss - evacuation - disk not secured")
		to_chat(world, "<FONT size = 3><B>Syndicate Minor Victory!</B></FONT>")
		to_chat(world, "<B>The Research Staff failed to secure the authentication disk but did manage to kill most of the [syndicate_name()] Operatives!</B>")

	else if(!disk_rescued                                         &&  crew_evacuated)
		feedback_set_details("round_end_result","halfwin - detonation averted")
		to_chat(world, "<FONT size = 3><B>Syndicate Minor Victory!</B></FONT>")
		to_chat(world, "<B>[syndicate_name()] operatives recovered the abandoned authentication disk but detonation of [station_name()] was averted.</B> Next time, don't lose the disk!")

	else if(!disk_rescued                                         && !crew_evacuated)
		feedback_set_details("round_end_result","halfwin - interrupted")
		to_chat(world, "<FONT size = 3><B>Neutral Victory</B></FONT>")
		to_chat(world, "<B>Round was mysteriously interrupted!</B>")

	..()
	return


/datum/game_mode/proc/auto_declare_completion_nuclear()
	if(syndicates.len || GAMEMODE_IS_NUCLEAR)
		var/text = "<br><FONT size=3><B>The syndicate operatives were:</B></FONT>"

		var/purchases = ""
		var/TC_uses = 0

		for(var/datum/mind/syndicate in syndicates)

			text += "<br><b>[syndicate.key]</b> was <b>[syndicate.name]</b> ("
			if(syndicate.current)
				if(syndicate.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(syndicate.current.real_name != syndicate.name)
					text += " as <b>[syndicate.current.real_name]</b>"
			else
				text += "body destroyed"
			text += ")"
			for(var/obj/item/device/uplink/H in world_uplinks)
				if(H && H.uplink_owner && H.uplink_owner==syndicate.key)
					TC_uses += H.used_TC
					purchases += H.purchase_log

		text += "<br>"

		text += "(Syndicates used [TC_uses] TC) [purchases]"

		if(TC_uses==0 && station_was_nuked && !is_operatives_are_dead())
			text += "<BIG><IMG CLASS=icon SRC=\ref['icons/BadAss.dmi'] ICONSTATE='badass'></BIG>"

		to_chat(world, text)
	return 1

/proc/nukelastname(var/mob/M as mob) //--All praise goes to NEO|Phyte, all blame goes to DH, and it was Cindi-Kate's idea. Also praise Urist for copypasta ho.
	var/randomname = pick(last_names)
	var/newname = sanitize(copytext(input(M,"You are the nuke operative [pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")]. Please choose a last name for your family.", "Name change",randomname),1,MAX_NAME_LEN))

	if(!newname)
		newname = randomname

	else
		if(newname == "Unknown" || newname == "floor" || newname == "wall" || newname == "rwall" || newname == "_")
			to_chat(M, "That name is reserved.")
			return nukelastname(M)

	return newname

/proc/NukeNameAssign(var/lastname,var/list/syndicates)
	for(var/datum/mind/synd_mind in syndicates)
		switch(synd_mind.current.gender)
			if(MALE)
				synd_mind.name = "[pick(first_names_male)] [pick(last_names)]"
			if(FEMALE)
				synd_mind.name = "[pick(first_names_female)] [pick(last_names)]"
		synd_mind.current.real_name = synd_mind.name
	return

/datum/game_mode/nuclear/set_scoreboard_gvars()
	var/foecount = 0
	for(var/datum/mind/M in ticker.mode.syndicates)
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

	for(var/obj/machinery/nuclearbomb/nuke in world)
		if(nuke.r_code == "Nope")	continue
		var/turf/T = get_turf(nuke)
		var/area/A = T.loc

		var/list/thousand_penalty = list(/area/syndicate_station, /area/wizard_station, /area/solar, /area)
		var/list/fiftythousand_penalty = list(/area/security/main, /area/security/brig, /area/security/armoury, /area/security/checkpoint2)

		if(is_type_in_list(A, thousand_penalty))
			score_nuked_penalty = 1000

		else if(is_type_in_list(A, fiftythousand_penalty))
			score_nuked_penalty = 50000

		else if(istype(A, /area/engine))
			score_nuked_penalty = 100000

		else
			score_nuked_penalty = 10000

		break

		var/killpoints = score_opkilled * 250
		var/arrestpoints = score_arrested * 1000
		score_crewscore += killpoints
		score_crewscore += arrestpoints
		if(score_nuked)
			score_crewscore -= score_nuked_penalty



/datum/game_mode/nuclear/get_scoreboard_stats()
	var/foecount = 0
	var/crewcount = 0

	var/diskdat = ""
	var/bombdat = null

	for(var/datum/mind/M in ticker.mode.syndicates)
		foecount++

	for(var/mob/living/C in world)
		if(ishuman(C) || isAI(C) || isrobot(C))
			if(C.stat == 2) continue
			if(!C.client) continue
			crewcount++

	var/obj/item/weapon/disk/nuclear/N = locate() in world
	if(istype(N))
		var/atom/disk_loc = N.loc
		while(!isturf(disk_loc))
			if(ismob(disk_loc))
				var/mob/M = disk_loc
				diskdat += "Carried by [M.real_name] "
			if(isobj(disk_loc))
				var/obj/O = disk_loc
				diskdat += "in \a [O]"
			disk_loc = disk_loc.loc
		diskdat += "in [disk_loc.loc]"


	if(!diskdat)
		diskdat = "WARNING: Nuked_penalty could not be found, look at [__FILE__], [__LINE__]."

	var/dat = ""
	dat += "<b><u>Mode Statistics</b></u><br>"

	dat += "<b>Number of Operatives:</b> [foecount]<br>"
	dat += "<b>Number of Surviving Crew:</b> [crewcount]<br>"

	dat += "<b>Final Location of Nuke:</b> [bombdat]<br>"
	dat += "<b>Final Location of Disk:</b> [diskdat]<br>"

	dat += "<br>"

	dat += "<b>Operatives Arrested:</b> [score_arrested] ([score_arrested * 1000] Points)<br>"
	dat += "<b>All Operatives Arrested:</b> [score_allarrested ? "Yes" : "No"] (Score tripled)<br>"

	dat += "<b>Operatives Killed:</b> [score_opkilled] ([score_opkilled * 1000] Points)<br>"
	dat += "<b>Station Destroyed:</b> [score_nuked ? "Yes" : "No"] (-[score_nuked_penalty] Points)<br>"
	dat += "<hr>"

	return dat
