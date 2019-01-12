// ERTs

#define ERT_TYPE_AMBER		1
#define ERT_TYPE_RED		2
#define ERT_TYPE_GAMMA		3

/datum/game_mode
	var/list/datum/mind/ert = list()

var/list/response_team_members = list()
var/responseteam_age = 21 // Minimum account age to play as an ERT member
var/datum/response_team/active_team = null
var/send_emergency_team = FALSE
var/ert_request_answered = FALSE

/client/proc/response_team()
	set name = "Dispatch CentComm Response Team"
	set category = "Event"
	set desc = "Send an CentComm response team to the station."

	if(!check_rights(R_EVENT))
		return

	if(!ticker)
		to_chat(usr, "<span class='warning'>The game hasn't started yet!</span>")
		return

	if(ticker.current_state == GAME_STATE_PREGAME)
		to_chat(usr, "<span class='warning'>The round hasn't started yet!</span>")
		return

	if(send_emergency_team)
		to_chat(usr, "<span class='warning'>Central Command has already dispatched an emergency response team!</span>")
		return

	var/datum/nano_module/ert_manager/E = new()
	E.ui_interact(usr)


/mob/dead/observer/proc/JoinResponseTeam()
	if(!send_emergency_team)
		to_chat(src, "<span class='warning'>No emergency response team is currently being sent.</span>")
		return 0

	if(jobban_isbanned(src, ROLE_ERT))
		to_chat(src, "<span class='warning'>You are jobbanned from playing on an emergency response team!</span>")
		return 0

	var/player_age_check = check_client_age(client, responseteam_age)
	if(player_age_check && config.use_age_restriction_for_antags)
		to_chat(src, "<span class='warning'>This role is not yet available to you. You need to wait another [player_age_check] days.</span>")
		return 0

	if(cannotPossess(src))
		to_chat(src, "<span class='boldnotice'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
		return 0

	if(response_team_members.len > 6)
		to_chat(src, "<span class='warning'>The emergency response team is already full!</span>")
		return 0

	return 1

/proc/trigger_armed_response_team(var/datum/response_team/response_team_type, commander_slots, security_slots, medical_slots, engineering_slots, janitor_slots, paranormal_slots, cyborg_slots)
	response_team_members = list()
	active_team = response_team_type
	active_team.setSlots(commander_slots, security_slots, medical_slots, engineering_slots, janitor_slots, paranormal_slots, cyborg_slots)

	send_emergency_team = TRUE
	var/list/ert_candidates = pollCandidates("Join the Emergency Response Team?",, responseteam_age, 600, 1, role_playtime_requirements[ROLE_ERT])
	if(!ert_candidates.len)
		active_team.cannot_send_team()
		send_emergency_team = FALSE
		return 0

	// Respawnable players get first dibs
	for(var/mob/dead/observer/M in ert_candidates)
		if(jobban_isbanned(M, ROLE_TRAITOR) || jobban_isbanned(M, "Security Officer") || jobban_isbanned(M, "Captain") || jobban_isbanned(M, "Cyborg"))
			continue
		if((M in GLOB.respawnable_list) && M.JoinResponseTeam())
			response_team_members |= M
	// If there's still open slots, non-respawnable players can fill them
	for(var/mob/dead/observer/M in (ert_candidates - GLOB.respawnable_list))
		if(M.JoinResponseTeam())
			response_team_members |= M

	if(!response_team_members.len)
		active_team.cannot_send_team()
		send_emergency_team = FALSE
		return 0

	var/index = 1
	var/ert_spawn_seconds = 120
	spawn(ert_spawn_seconds * 10) // to account for spawn() using deciseconds
		var/list/unspawnable_ert = list()
		for(var/mob/M in response_team_members)
			if(M)
				unspawnable_ert |= M
		if(unspawnable_ert.len)
			message_admins("ERT SPAWN: The following ERT members could not be spawned within [ert_spawn_seconds] seconds:")
			for(var/mob/M in unspawnable_ert)
				message_admins("- Unspawned ERT: [ADMIN_FULLMONTY(M)]")
	for(var/mob/M in response_team_members)
		if(index > emergencyresponseteamspawn.len)
			index = 1

		if(!M || !M.client)
			continue
		var/client/C = M.client
		var/mob/living/new_commando = C.create_response_team(emergencyresponseteamspawn[index])
		if(!M || !new_commando)
			continue
		new_commando.mind.key = M.key
		new_commando.key = M.key
		new_commando.update_icons()
		index++

	send_emergency_team = FALSE
	active_team.announce_team()
	return 1

/client/proc/create_response_team(var/turf/spawn_location)
	var/class = 0
	while(!class)
		class = input(src, "Which loadout would you like to choose?") in active_team.get_slot_list()
		if(!active_team.check_slot_available(class)) // Because the prompt does not update automatically when a slot gets filled.
			class = 0

	if(class == "Cyborg")
		active_team.reduceCyborgSlots()
		var/cyborg_unlock = active_team.getCyborgUnlock()
		var/mob/living/silicon/robot/ert/R = new /mob/living/silicon/robot/ert(spawn_location, cyborg_unlock)
		return R

	var/mob/living/carbon/human/M = new(null)
	var/obj/item/organ/external/head/head_organ = M.get_organ("head")

	var/new_gender = alert(src, "Please select your gender.", "ERT Character Generation", "Male", "Female")

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
	if(!(M.mind in ticker.minds))
		ticker.minds += M.mind //Adds them to regular mind list.
	ticker.mode.ert += M.mind
	M.forceMove(spawn_location)

	job_master.CreateMoneyAccount(M, class, null)

	active_team.equip_officer(class, M)

	return M


/datum/response_team
	var/command_slots = 1
	var/engineer_slots = 3
	var/medical_slots = 3
	var/security_slots = 3
	var/janitor_slots = 0
	var/paranormal_slots = 0
	var/cyborg_slots = 0

	var/command_outfit
	var/engineering_outfit
	var/medical_outfit
	var/security_outfit
	var/janitor_outfit
	var/paranormal_outfit
	var/cyborg_unlock = 0

/datum/response_team/proc/setSlots(com, sec, med, eng, jan, par, cyb)
	command_slots = com == null ? command_slots : com
	security_slots = sec == null ? security_slots : sec
	medical_slots = med == null ? medical_slots : med
	engineer_slots = eng == null ? engineer_slots : eng
	janitor_slots = jan == null ? janitor_slots : jan
	paranormal_slots = par == null ? paranormal_slots : par
	cyborg_slots = cyb == null ? cyborg_slots : cyb

/datum/response_team/proc/reduceCyborgSlots()
	cyborg_slots--

/datum/response_team/proc/getCyborgUnlock()
	return cyborg_unlock

/datum/response_team/proc/get_slot_list()
	var/list/slots_available = list()
	if(command_slots)
		slots_available |= "Commander"
	if(security_slots)
		slots_available |= "Security"
	if(engineer_slots)
		slots_available |= "Engineer"
	if(medical_slots)
		slots_available |= "Medic"
	if(janitor_slots)
		slots_available |= "Janitor"
	if(paranormal_slots)
		slots_available |= "Paranormal"
	if(cyborg_slots)
		slots_available |= "Cyborg"
	return slots_available

/datum/response_team/proc/check_slot_available(var/slot)
	switch(slot)
		if("Commander")
			return command_slots
		if("Security")
			return security_slots
		if("Engineer")
			return engineer_slots
		if("Medic")
			return medical_slots
		if("Janitor")
			return janitor_slots
		if("Paranormal")
			return paranormal_slots
		if("Cyborg")
			return cyborg_slots
	return 0

/datum/response_team/proc/equip_officer(var/officer_type, var/mob/living/carbon/human/M)
	switch(officer_type)
		if("Engineer")
			engineer_slots -= 1
			M.equipOutfit(engineering_outfit)
			M.job = "ERT Engineering"

		if("Security")
			security_slots -= 1
			M.equipOutfit(security_outfit)
			M.job = "ERT Security"

		if("Medic")
			medical_slots -= 1
			M.equipOutfit(medical_outfit)
			M.job = "ERT Medical"

		if("Janitor")
			janitor_slots -= 1
			M.equipOutfit(janitor_outfit)
			M.job = "ERT Janitor"

		if("Paranormal")
			paranormal_slots -= 1
			M.equipOutfit(paranormal_outfit)
			M.job = "ERT Paranormal"
			M.mind.isholy = TRUE

		if("Commander")
			command_slots = 0

			// Override name and age for the commander
			M.rename_character(null, "[pick("Lieutenant", "Captain", "Major")] [pick(GLOB.last_names)]")
			M.age = rand(35,45)

			M.equipOutfit(command_outfit)
			M.job = "ERT Commander"

/datum/response_team/proc/cannot_send_team()
	event_announcement.Announce("[station_name()], we are unfortunately unable to send you an Emergency Response Team at this time.", "ERT Unavailable")

/datum/response_team/proc/announce_team()
	event_announcement.Announce("Attention, [station_name()]. We are sending a team of highly trained assistants to aid(?) you. Standby.", "ERT En-Route")

// -- AMBER TEAM --

/datum/response_team/amber
	engineering_outfit = /datum/outfit/job/centcom/response_team/engineer/amber
	security_outfit = /datum/outfit/job/centcom/response_team/security/amber
	medical_outfit = /datum/outfit/job/centcom/response_team/medic/amber
	command_outfit = /datum/outfit/job/centcom/response_team/commander/amber
	janitor_outfit = /datum/outfit/job/centcom/response_team/janitorial/amber
	paranormal_outfit = /datum/outfit/job/centcom/response_team/paranormal/amber

/datum/response_team/amber/announce_team()
	event_announcement.Announce("Attention, [station_name()]. We are sending a code AMBER light Emergency Response Team. Standby.", "ERT En-Route")

// -- RED TEAM --

/datum/response_team/red
	engineering_outfit = /datum/outfit/job/centcom/response_team/engineer/red
	security_outfit = /datum/outfit/job/centcom/response_team/security/red
	medical_outfit = /datum/outfit/job/centcom/response_team/medic/red
	command_outfit = /datum/outfit/job/centcom/response_team/commander/red
	janitor_outfit = /datum/outfit/job/centcom/response_team/janitorial/red
	paranormal_outfit = /datum/outfit/job/centcom/response_team/paranormal/red

/datum/response_team/red/announce_team()
	event_announcement.Announce("Attention, [station_name()]. We are sending a code RED Emergency Response Team. Standby.", "ERT En-Route")

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
	event_announcement.Announce("Attention, [station_name()]. We are sending a code GAMMA elite Emergency Response Team. Standby.", "ERT En-Route")

/datum/outfit/job/centcom/response_team
	name = "Response team"
	var/rt_assignment = "Emergency Response Team Member"
	var/rt_job = "This is a bug"
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
