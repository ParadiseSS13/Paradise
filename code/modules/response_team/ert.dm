// ERTs

#define ERT_TYPE_AMBER		1
#define ERT_TYPE_RED		2
#define ERT_TYPE_GAMMA		3

/datum/game_mode
	var/list/datum/mind/ert = list()

GLOBAL_LIST_EMPTY(response_team_members)
GLOBAL_VAR_INIT(responseteam_age, 21) // Minimum account age to play as an ERT member
GLOBAL_DATUM(active_team, /datum/response_team)
GLOBAL_VAR_INIT(send_emergency_team, FALSE)
GLOBAL_VAR_INIT(ert_request_answered, FALSE)

/client/proc/response_team()
	set name = "Dispatch CentComm Response Team"
	set category = "Event"
	set desc = "Send an CentComm response team to the station."

	if(!check_rights(R_EVENT))
		return

	if(!SSticker)
		to_chat(usr, "<span class='warning'>The game hasn't started yet!</span>")
		return

	if(SSticker.current_state == GAME_STATE_PREGAME)
		to_chat(usr, "<span class='warning'>The round hasn't started yet!</span>")
		return

	if(GLOB.send_emergency_team)
		to_chat(usr, "<span class='warning'>Central Command has already dispatched an emergency response team!</span>")
		return

	var/datum/nano_module/ert_manager/E = new()
	E.ui_interact(usr)


/mob/dead/observer/proc/JoinResponseTeam()
	if(!GLOB.send_emergency_team)
		to_chat(src, "<span class='warning'>No emergency response team is currently being sent.</span>")
		return 0

	if(jobban_isbanned(src, ROLE_ERT))
		to_chat(src, "<span class='warning'>You are jobbanned from playing on an emergency response team!</span>")
		return 0

	var/player_age_check = check_client_age(client, GLOB.responseteam_age)
	if(player_age_check && config.use_age_restriction_for_antags)
		to_chat(src, "<span class='warning'>This role is not yet available to you. You need to wait another [player_age_check] days.</span>")
		return 0

	if(cannotPossess(src))
		to_chat(src, "<span class='boldnotice'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
		return 0

	return 1

/proc/trigger_armed_response_team(datum/response_team/response_team_type, commander_slots, security_slots, medical_slots, engineering_slots, janitor_slots, paranormal_slots, cyborg_slots)
	GLOB.response_team_members = list()
	GLOB.active_team = response_team_type
	GLOB.active_team.setSlots(commander_slots, security_slots, medical_slots, engineering_slots, janitor_slots, paranormal_slots, cyborg_slots)

	GLOB.send_emergency_team = TRUE
	var/list/ert_candidates = shuffle(pollCandidates("Join the Emergency Response Team?",, GLOB.responseteam_age, 600, 1, GLOB.role_playtime_requirements[ROLE_ERT]))
	if(!ert_candidates.len)
		GLOB.active_team.cannot_send_team()
		GLOB.send_emergency_team = FALSE
		return

	// Respawnable players get first dibs
	for(var/mob/dead/observer/M in ert_candidates)
		if(jobban_isbanned(M, ROLE_TRAITOR) || jobban_isbanned(M, "Security Officer") || jobban_isbanned(M, "Captain") || jobban_isbanned(M, "Cyborg"))
			continue
		if((M in GLOB.respawnable_list) && M.JoinResponseTeam())
			GLOB.response_team_members |= M
	// If there's still open slots, non-respawnable players can fill them
	for(var/mob/dead/observer/M in (ert_candidates - GLOB.respawnable_list))
		if(M.JoinResponseTeam())
			GLOB.response_team_members |= M

	if(!GLOB.response_team_members.len)
		GLOB.active_team.cannot_send_team()
		GLOB.send_emergency_team = FALSE
		return

	var/list/ert_gender_prefs = list()
	for(var/mob/M in GLOB.response_team_members)
		ert_gender_prefs.Add(input_async(M, "Please select a gender (10 seconds):", list("Male", "Female")))
	addtimer(CALLBACK(GLOBAL_PROC, .proc/get_ert_role_prefs, GLOB.response_team_members, ert_gender_prefs), 100)

/proc/get_ert_role_prefs(list/response_team_members, list/ert_gender_prefs) // Why the FUCK is this variable the EXACT SAME as the global one
	var/list/ert_role_prefs = list()
	for(var/datum/async_input/A in ert_gender_prefs)
		A.close()
	for(var/mob/M in response_team_members)
		ert_role_prefs.Add(input_ranked_async(M, "Please order ERT roles from most to least preferred (20 seconds):", GLOB.active_team.get_slot_list()))
	addtimer(CALLBACK(GLOBAL_PROC, .proc/dispatch_response_team, response_team_members, ert_gender_prefs, ert_role_prefs), 200)

/proc/dispatch_response_team(list/response_team_members, list/ert_gender_prefs, list/ert_role_prefs)
	var/spawn_index = 1

	for(var/i = 1, i <= response_team_members.len, i++)
		if(spawn_index > GLOB.emergencyresponseteamspawn.len)
			break
		if(!GLOB.active_team.get_slot_list().len)
			break
		var/gender_pref = ert_gender_prefs[i].result
		var/role_pref = ert_role_prefs[i].close()
		var/mob/M = response_team_members[i]
		if(!M || !M.client)
			continue
		if(!gender_pref || !role_pref)
			// Player was afk and did not select
			continue
		for(var/role in role_pref)
			if(GLOB.active_team.check_slot_available(role))
				var/mob/living/new_commando = M.client.create_response_team(gender_pref, role, GLOB.emergencyresponseteamspawn[spawn_index])
				GLOB.active_team.reduceSlots(role)
				spawn_index++
				if(!M || !new_commando)
					break
				new_commando.mind.key = M.key
				new_commando.key = M.key
				new_commando.update_icons()
				break
	GLOB.send_emergency_team = FALSE

	if(GLOB.active_team.count)
		GLOB.active_team.announce_team()
		return
	// Everyone who said yes was afk
	GLOB.active_team.cannot_send_team()

/client/proc/create_response_team(new_gender, role, turf/spawn_location)
	if(role == "Cyborg")
		var/cyborg_unlock = GLOB.active_team.getCyborgUnlock()
		var/mob/living/silicon/robot/ert/R = new /mob/living/silicon/robot/ert(spawn_location, cyborg_unlock)
		return R

	var/mob/living/carbon/human/M = new(null)
	var/obj/item/organ/external/head/head_organ = M.get_organ("head")

	if(new_gender)
		if(new_gender == "Male")
			M.change_gender(MALE)
		else
			M.change_gender(FEMALE)

	M.set_species(/datum/species/human, TRUE)
	M.dna.ready_dna(M)
	M.cleanSE() //No fat/blind/colourblind/epileptic/whatever ERT.
	M.overeatduration = 0

	var/hair_c = pick("#8B4513","#000000","#FF4500","#FFD700") // Brown, black, red, blonde
	var/eye_c = pick("#000000","#8B4513","1E90FF") // Black, brown, blue
	var/skin_tone = rand(-120, 20) // A range of skin colors

	head_organ.facial_colour = hair_c
	head_organ.sec_facial_colour = hair_c
	head_organ.hair_colour = hair_c
	head_organ.sec_hair_colour = hair_c
	M.change_eye_color(eye_c)
	M.s_tone = skin_tone
	head_organ.h_style = random_hair_style(M.gender, head_organ.dna.species.name)
	head_organ.f_style = random_facial_hair_style(M.gender, head_organ.dna.species.name)

	M.rename_character(null, "[pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant First Class", "Master Sergeant", "Sergeant Major")] [pick(GLOB.last_names)]")
	M.age = rand(23,35)
	M.regenerate_icons()
	M.update_body()
	M.update_dna()

	//Creates mind stuff.
	M.mind = new
	M.mind.current = M
	M.mind.original = M
	M.mind.assigned_role = SPECIAL_ROLE_ERT
	M.mind.special_role = SPECIAL_ROLE_ERT
	if(!(M.mind in SSticker.minds))
		SSticker.minds += M.mind //Adds them to regular mind list.
	SSticker.mode.ert += M.mind
	M.forceMove(spawn_location)

	SSjobs.CreateMoneyAccount(M, role, null)

	GLOB.active_team.equip_officer(role, M)

	return M


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
	var/cyborg_unlock = 0

/datum/response_team/proc/setSlots(com=1, sec=3, med=3, eng=3, jan=0, par=0, cyb=0)
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

/datum/response_team/proc/getCyborgUnlock()
	return cyborg_unlock

/datum/response_team/proc/get_slot_list()
	var/list/slots_available = list()
	for(var/role in slots)
		if(slots[role])
			slots_available.Add(role)
	return slots_available

/datum/response_team/proc/check_slot_available(role)
	return slots[role]

/datum/response_team/proc/equip_officer(var/officer_type, var/mob/living/carbon/human/M)
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
	GLOB.event_announcement.Announce("[station_name()], we are unfortunately unable to send you an Emergency Response Team at this time.", "ERT Unavailable")

/datum/response_team/proc/announce_team()
	GLOB.event_announcement.Announce("Attention, [station_name()]. We are sending a team of highly trained assistants to aid(?) you. Standby.", "ERT En-Route")

// -- AMBER TEAM --

/datum/response_team/amber
	engineering_outfit = /datum/outfit/job/centcom/response_team/engineer/amber
	security_outfit = /datum/outfit/job/centcom/response_team/security/amber
	medical_outfit = /datum/outfit/job/centcom/response_team/medic/amber
	command_outfit = /datum/outfit/job/centcom/response_team/commander/amber
	janitor_outfit = /datum/outfit/job/centcom/response_team/janitorial/amber
	paranormal_outfit = /datum/outfit/job/centcom/response_team/paranormal/amber

/datum/response_team/amber/announce_team()
	GLOB.event_announcement.Announce("Attention, [station_name()]. We are sending a code AMBER light Emergency Response Team. Standby.", "ERT En-Route")

// -- RED TEAM --

/datum/response_team/red
	engineering_outfit = /datum/outfit/job/centcom/response_team/engineer/red
	security_outfit = /datum/outfit/job/centcom/response_team/security/red
	medical_outfit = /datum/outfit/job/centcom/response_team/medic/red
	command_outfit = /datum/outfit/job/centcom/response_team/commander/red
	janitor_outfit = /datum/outfit/job/centcom/response_team/janitorial/red
	paranormal_outfit = /datum/outfit/job/centcom/response_team/paranormal/red

/datum/response_team/red/announce_team()
	GLOB.event_announcement.Announce("Attention, [station_name()]. We are sending a code RED Emergency Response Team. Standby.", "ERT En-Route")

// -- GAMMA TEAM --

/datum/response_team/gamma
	engineering_outfit = /datum/outfit/job/centcom/response_team/engineer/gamma
	security_outfit = /datum/outfit/job/centcom/response_team/security/gamma
	medical_outfit = /datum/outfit/job/centcom/response_team/medic/gamma
	command_outfit = /datum/outfit/job/centcom/response_team/commander/gamma
	janitor_outfit = /datum/outfit/job/centcom/response_team/janitorial/gamma
	paranormal_outfit = /datum/outfit/job/centcom/response_team/paranormal/gamma
	cyborg_unlock = 1

/datum/response_team/gamma/announce_team()
	GLOB.event_announcement.Announce("Attention, [station_name()]. We are sending a code GAMMA elite Emergency Response Team. Standby.", "ERT En-Route")

/datum/outfit/job/centcom/response_team
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

	implants = list(/obj/item/implant/mindshield)

/obj/item/radio/centcom
	name = "centcomm bounced radio"
	frequency = ERT_FREQ
	icon_state = "radio"
