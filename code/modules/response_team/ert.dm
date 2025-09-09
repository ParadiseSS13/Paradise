// ERTs

#define ERT_TYPE_AMBER		1
#define ERT_TYPE_RED		2
#define ERT_TYPE_GAMMA		3

GLOBAL_LIST_EMPTY(response_team_members)
GLOBAL_VAR_INIT(responseteam_age, 21) // Minimum account age to play as an ERT member
GLOBAL_DATUM(active_team, /datum/response_team)
GLOBAL_VAR_INIT(send_emergency_team, FALSE)
GLOBAL_VAR_INIT(ert_request_answered, FALSE)
GLOBAL_LIST_EMPTY(ert_request_messages)

/client/proc/response_team()
	set name = "Dispatch CentComm Response Team"
	set category = "Event"
	set desc = "Send an CentComm response team to the station."

	if(!check_rights(R_EVENT))
		return

	if(SSticker.current_state < GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>The game hasn't started yet!</span>")
		return

	if(SSticker.current_state == GAME_STATE_PREGAME)
		to_chat(usr, "<span class='warning'>The round hasn't started yet!</span>")
		return

	var/datum/ui_module/ert_manager/E = new()
	E.ui_interact(usr)


/mob/proc/JoinResponseTeam()
	if(!GLOB.send_emergency_team)
		to_chat(src, "<span class='warning'>No emergency response team is currently being sent.</span>")
		return FALSE

	if(jobban_isbanned(src, ROLE_ERT))
		to_chat(src, "<span class='warning'>You are jobbanned from playing on an emergency response team!</span>")
		return FALSE

	var/player_age_check = check_client_age(client, GLOB.responseteam_age)
	if(player_age_check && GLOB.configuration.gamemode.antag_account_age_restriction)
		to_chat(src, "<span class='warning'>This role is not yet available to you. You need to wait another [player_age_check] days.</span>")
		return FALSE

	return TRUE

/mob/dead/observer/JoinResponseTeam()
	. = ..()
	if(!check_ahud_rejoin_eligibility())
		to_chat(src, "<span class='boldnotice'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
		return FALSE

/proc/trigger_armed_response_team(datum/response_team/response_team_type, commander_slots, security_slots, medical_slots, engineering_slots, janitor_slots, paranormal_slots, cyborg_slots, cyborg_security)
	GLOB.response_team_members = list()
	GLOB.active_team = response_team_type
	GLOB.active_team.setSlots(commander_slots, security_slots, medical_slots, engineering_slots, janitor_slots, paranormal_slots, cyborg_slots)
	GLOB.active_team.cyborg_security_permitted = cyborg_security

	GLOB.send_emergency_team = TRUE
	var/list/ert_candidates = shuffle(SSghost_spawns.poll_candidates("Join the Emergency Response Team?", null, GLOB.responseteam_age, 45 SECONDS, TRUE, GLOB.role_playtime_requirements[ROLE_ERT]))
	if(!length(ert_candidates))
		GLOB.active_team.cannot_send_team()
		GLOB.send_emergency_team = FALSE
		return

	// Respawnable players get first dibs
	for(var/mob/M in ert_candidates)
		if(jobban_isbanned(M, ROLE_TRAITOR) || jobban_isbanned(M, "Security Officer") || jobban_isbanned(M, "Captain") || jobban_isbanned(M, "Cyborg"))
			continue
		if((HAS_TRAIT(M, TRAIT_RESPAWNABLE)) && M.JoinResponseTeam())
			GLOB.response_team_members |= M
			M.RegisterSignal(M, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/mob, remove_from_ert_list), TRUE)

	// If there's still open slots, non-respawnable players can fill them
	for(var/mob/M in (ert_candidates - GLOB.response_team_members))
		if(M.JoinResponseTeam())
			GLOB.response_team_members |= M
			M.RegisterSignal(M, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/mob, remove_from_ert_list), TRUE)

	if(!length(GLOB.response_team_members))
		GLOB.active_team.cannot_send_team()
		GLOB.send_emergency_team = FALSE
		return

	var/list/ert_gender_prefs = list()
	for(var/mob/M in GLOB.response_team_members)
		ert_gender_prefs.Add(input_async(M, "Please select a gender (10 seconds):", list("Male", "Female")))
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(get_ert_species_prefs), GLOB.response_team_members, ert_gender_prefs), 10 SECONDS)

/proc/get_ert_species_prefs(list/response_team_members, list/ert_gender_prefs)
	for(var/datum/async_input/A in ert_gender_prefs)
		A.close()
	var/list/ert_species_prefs = list()
	for(var/mob/M in GLOB.response_team_members)
		ert_species_prefs.Add(input_async(M, "Please select a species (10 seconds):", list("Human", "Tajaran", "Skrell", "Unathi", "Diona", "Vulpkanin", "Nian", "Drask", "Kidan", "Grey", "Random")))
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(get_ert_role_prefs), GLOB.response_team_members, ert_gender_prefs, ert_species_prefs), 10 SECONDS)

/proc/get_ert_role_prefs(list/response_team_members, list/ert_gender_prefs, list/ert_species_prefs) // Why the FUCK is this variable the EXACT SAME as the global one
	var/list/ert_role_prefs = list()
	for(var/datum/async_input/A in ert_species_prefs)
		A.close()
	for(var/mob/M in response_team_members)
		ert_role_prefs.Add(input_ranked_async(M, "Please order ERT roles from most to least preferred (20 seconds):", GLOB.active_team.get_slot_list()))
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(dispatch_response_team), response_team_members, ert_gender_prefs, ert_species_prefs, ert_role_prefs), 20 SECONDS)

/proc/dispatch_response_team(list/response_team_members, list/datum/async_input/ert_gender_prefs, list/datum/async_input/ert_species_prefs, list/datum/async_input/ert_role_prefs)
	var/spawn_index = 1

	for(var/i = 1, i <= length(response_team_members), i++)
		if(spawn_index > length(GLOB.emergencyresponseteamspawn))
			break
		if(!length(GLOB.active_team.get_slot_list()))
			break
		var/gender_pref = ert_gender_prefs[i].result
		var/species_pref = ert_species_prefs[i].result
		var/role_pref = ert_role_prefs[i].close()
		var/mob/M = response_team_members[i]
		if(!M || !M.client)
			continue
		if(!gender_pref || !role_pref)
			// Player was afk and did not select
			continue
		for(var/role in role_pref)
			if(GLOB.active_team.check_slot_available(role))
				var/mob/living/new_commando = M.client.create_response_team_part_1(gender_pref, species_pref, role, GLOB.emergencyresponseteamspawn[spawn_index])
				GLOB.active_team.reduceSlots(role)
				spawn_index++
				if(!M || !new_commando)
					break
				new_commando.mind.key = M.key
				new_commando.key = M.key
				dust_if_respawnable(M)
				new_commando.update_icons()
				break
	GLOB.send_emergency_team = FALSE

	if(GLOB.active_team.count)
		GLOB.active_team.announce_team()
		return
	// Everyone who said yes was afk
	GLOB.active_team.cannot_send_team()

/client/proc/create_response_team_part_1(new_gender, new_species, role, turf/spawn_location)
	if(role == "Cyborg")
		var/mob/living/silicon/robot/ert/R = new GLOB.active_team.borg_path(spawn_location)
		if(!GLOB.active_team.cyborg_security_permitted && !length(R.force_modules))
			R.force_modules = list("Engineering", "Medical")
		return R

	var/mob/living/carbon/human/M = new(spawn_location)

	if(new_gender)
		if(new_gender == "Male")
			M.change_gender(MALE)
			M.change_body_type(MALE)
		else
			M.change_gender(FEMALE)
			M.change_body_type(FEMALE)

	if(!new_species)
		new_species = "Human"
	if(new_species == "Random")
		new_species = pick("Human", "Tajaran", "Skrell", "Unathi", "Diona", "Vulpkanin", "Nian", "Drask", "Kidan", "Grey")
	var/datum/species/S = GLOB.all_species[new_species]
	var/species = S.type
	M.set_species(species, TRUE)
	M.dna.ready_dna(M)
	M.cleanSE() //No fat/blind/colourblind/epileptic/whatever ERT.
	M.overeatduration = 0
	var/obj/item/organ/external/head/head_organ = M.get_organ("head")
	var/eye_c = pick("#000000", "#8B4513", "#1E90FF", "#8c00ff", "#a80c0c", "#2fdb63") // Black, brown, blue, purple, red, green

	switch(new_species) //Diona not included as they don't use the hair colours, kidan use accessory, drask are skin tone Grey not included as they are BALD
		if("Human", "Tajaran", "Vulpkanin", "Nian")
			var/hair_c_htvn = pick("#8B4513", "#000000", "#FF4500", "#FFD700", "#d4d1bf") // Brown, black, red, blonde, grey
			head_organ.facial_colour = hair_c_htvn
			head_organ.sec_facial_colour = hair_c_htvn
			head_organ.hair_colour = hair_c_htvn
			head_organ.sec_hair_colour = hair_c_htvn
			M.skin_colour = hair_c_htvn
		if("Skrell", "Unathi") //Some common skrell / unathi colours
			var/list/su = list("#1f138b", "#272525", "#07a035", "#8c00ff", "#a80c0c")
			var/hair_c_su = pick_n_take(su)
			head_organ.facial_colour = hair_c_su
			head_organ.sec_facial_colour = hair_c_su
			head_organ.hair_colour = hair_c_su
			head_organ.sec_hair_colour = hair_c_su
			if(new_species == "Skrell")
				M.skin_colour = hair_c_su
			else
				M.skin_colour = pick(su) //Pick a diffrent colour for body.


	M.change_eye_color(eye_c, FALSE)
	M.change_skin_tone(random_skin_tone(M.dna.species.name))
	head_organ.headacc_colour = pick("#1f138b", "#272525", "#07a035", "#8c00ff", "#a80c0c")
	head_organ.h_style = random_hair_style(M.gender, head_organ.dna.species.name)
	if(M.gender != FEMALE) // no beard for women pls
		head_organ.f_style = random_facial_hair_style(M.gender, head_organ.dna.species.name)

	M.rename_character(M.real_name, "[pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant First Class", "Master Sergeant", "Sergeant Major")] [pick(GLOB.last_names)]")
	M.age = rand(23,35)
	M.update_dna()
	M.regenerate_icons()

	//Creates mind stuff.
	M.mind = new
	M.mind.bind_to(M)
	M.mind.set_original_mob(M)
	M.mind.assigned_role = SPECIAL_ROLE_ERT
	M.mind.special_role = SPECIAL_ROLE_ERT
	M.mind.offstation_role = TRUE
	if(!(M.mind in SSticker.minds))
		SSticker.minds += M.mind //Adds them to regular mind list.
	SSticker.mode.ert += M.mind

	SSjobs.CreateMoneyAccount(M, role, null)

	GLOB.active_team.equip_officer(role, M)

	return M

/mob/proc/remove_from_ert_list(ghost)
	SIGNAL_HANDLER
	GLOB.response_team_members -= src

/datum/response_team
	var/list/slots = list(
		Commander = 0,
		Security = 0,
		Engineer = 0,
		Medic = 0,
		Janitor = 0,
		Paranormal = 0,
		Cyborg = 0
	)
	var/count = 0

	var/command_outfit
	var/engineering_outfit
	var/medical_outfit
	var/security_outfit
	var/janitor_outfit
	var/paranormal_outfit
	var/borg_path = /mob/living/silicon/robot/ert
	var/cyborg_security_permitted = FALSE

	/// Whether the ERT announcement should be hidden from the station
	var/silent

/datum/response_team/proc/setSlots(com=1, sec=4, med=0, eng=0, jan=0, par=0, cyb=0)
	slots["Commander"] = com
	slots["Security"] = sec
	slots["Medic"] = med
	slots["Engineer"] = eng
	slots["Janitor"] = jan
	slots["Paranormal"] = par
	slots["Cyborg"] = cyb

/datum/response_team/proc/reduceSlots(role)
	slots[role]--
	count++

/datum/response_team/proc/get_slot_list()
	RETURN_TYPE(/list)
	var/list/slots_available = list()
	for(var/role in slots)
		if(slots[role])
			slots_available.Add(role)
	return slots_available

/datum/response_team/proc/check_slot_available(role)
	return slots[role]

/datum/response_team/proc/equip_officer(officer_type, mob/living/carbon/human/M)
	switch(officer_type)
		if("Engineer")
			M.equipOutfit(engineering_outfit)

		if("Security")
			M.equipOutfit(security_outfit)

		if("Medic")
			M.equipOutfit(medical_outfit)

		if("Janitor")
			M.equipOutfit(janitor_outfit)

		if("Paranormal")
			M.equipOutfit(paranormal_outfit)

		if("Commander")
			M.equipOutfit(command_outfit)

/datum/response_team/proc/cannot_send_team()
	if(silent)
		message_admins("A silent response team failed to spawn. Likely, no one signed up.")
		return
	GLOB.major_announcement.Announce("[station_name()], we are unfortunately unable to send you an Emergency Response Team at this time.", "ERT Unavailable")

/datum/response_team/proc/announce_team()
	if(silent)
		return
	GLOB.major_announcement.Announce("Attention, [station_name()]. We are sending a team of highly trained assistants to aid(?) you. Standby.", "ERT En-Route")

// -- AMBER TEAM --

/datum/response_team/amber
	engineering_outfit = /datum/outfit/job/response_team/engineer/amber
	security_outfit = /datum/outfit/job/response_team/security/amber
	medical_outfit = /datum/outfit/job/response_team/medic/amber
	command_outfit = /datum/outfit/job/response_team/commander/amber
	janitor_outfit = /datum/outfit/job/response_team/janitorial/amber
	paranormal_outfit = /datum/outfit/job/response_team/paranormal/amber

/datum/response_team/amber/announce_team()
	if(silent)
		return
	GLOB.major_announcement.Announce("Attention, [station_name()]. We are sending a code AMBER light Emergency Response Team. Standby.", "ERT En-Route")

// -- RED TEAM --

/datum/response_team/red
	engineering_outfit = /datum/outfit/job/response_team/engineer/red
	security_outfit = /datum/outfit/job/response_team/security/red
	medical_outfit = /datum/outfit/job/response_team/medic/red
	command_outfit = /datum/outfit/job/response_team/commander/red
	janitor_outfit = /datum/outfit/job/response_team/janitorial/red
	paranormal_outfit = /datum/outfit/job/response_team/paranormal/red
	borg_path = /mob/living/silicon/robot/ert/red

/datum/response_team/red/announce_team()
	if(silent)
		return
	GLOB.major_announcement.Announce("Attention, [station_name()]. We are sending a code RED Emergency Response Team. Standby.", "ERT En-Route")

// -- GAMMA TEAM --

/datum/response_team/gamma
	engineering_outfit = /datum/outfit/job/response_team/engineer/gamma
	security_outfit = /datum/outfit/job/response_team/security/gamma
	medical_outfit = /datum/outfit/job/response_team/medic/gamma
	command_outfit = /datum/outfit/job/response_team/commander/gamma
	janitor_outfit = /datum/outfit/job/response_team/janitorial/gamma
	paranormal_outfit = /datum/outfit/job/response_team/paranormal/gamma
	borg_path = /mob/living/silicon/robot/ert/gamma

/datum/response_team/gamma/announce_team()
	if(silent)
		return
	GLOB.major_announcement.Announce("Attention, [station_name()]. We are sending a code GAMMA elite Emergency Response Team. Standby.", "ERT En-Route")

/datum/outfit/job/response_team
	name = "Response team"
	var/rt_assignment = "Emergency Response Team Member"
	var/rt_job = "This is a bug"
	var/rt_mob_job = "This is a bug" // The job set on the actual mob.
	allow_backbag_choice = FALSE
	allow_loadout = FALSE
	pda = /obj/item/pda/heads/ert
	id = /obj/item/card/id/ert
	l_ear = /obj/item/radio/headset/ert/alt
	box = /obj/item/storage/box/responseteam
	gloves = /obj/item/clothing/gloves/combat

	bio_chips = list(/obj/item/bio_chip/mindshield)

/obj/item/radio/centcom
	name = "centcomm bounced radio"
	frequency = ERT_FREQ
	icon_state = "radio"
	freqlock = TRUE

#undef ERT_TYPE_AMBER
#undef ERT_TYPE_RED
#undef ERT_TYPE_GAMMA
