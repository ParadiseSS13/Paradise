//STRIKE TEAMS
//Thanks to Kilakk for the admin-button portion of this code.

#define ERT_TYPE_AMBER		1
#define ERT_TYPE_RED		2
#define ERT_TYPE_GAMMA		3

/datum/game_mode
	var/list/datum/mind/ert = list()

var/list/response_team_members = list()
var/responseteam_age = 21 // Minimum account age to play as an ERT member
var/datum/response_team/active_team = null
var/send_emergency_team
var/ert_request_answered = 0

/client/proc/response_team()
	set name = "Dispatch CentComm Response Team"
	set category = "Event"
	set desc = "Send an CentComm response team to the station."

	if(!check_rights(R_EVENT))
		return

	if(!ticker)
		to_chat(usr, "<span class='warning'>The game hasn't started yet!</span>")
		return

	if(ticker.current_state == 1)
		to_chat(usr, "<span class='warning'>The round hasn't started yet!</span>")
		return

	if(send_emergency_team)
		to_chat(usr, "<span class='warning'>Central Command has already dispatched an emergency response team!</span>")
		return

	if(alert("Do you want to dispatch an Emergency Response Team?",,"Yes","No") != "Yes")
		return

	if(get_security_level() != "red") // Allow admins to reconsider if the alert level isn't Red
		switch(alert("The station is not in red alert. Do you still want to dispatch a response team?",,"Yes","No"))
			if("No")
				return

	if(send_emergency_team)
		to_chat(usr, "<span class='warning'>Central Command has already dispatched an emergency response team!</span>")
		return

	var/ert_type = pick_ert_type()

	if(!ert_type)
		return

	ert_request_answered = 1
	message_admins("[key_name_admin(usr)] is dispatching an Emergency Response Team", 1)
	log_admin("[key_name(usr)] used Dispatch Emergency Response Team..")
	trigger_armed_response_team(ert_type)

/client/proc/pick_ert_type()
	switch(alert("Please select the ERT type you wish to deploy.", "Emergency Response Team", "Code Amber", "Code Red", "Code Gamma", "Cancel"))
		if("Code Amber")
			if(alert("Confirm: Deploy code 'AMBER' light ERT?", "Emergency Response Team", "Confirm", "Cancel") == "Confirm")
				return new /datum/response_team/amber
			else
				return pick_ert_type()
		if("Code Red")
			if(alert("Confirm: Deploy code 'RED' medium ERT?", "Emergency Response Team", "Confirm", "Cancel") == "Confirm")
				return new /datum/response_team/red
			else
				return pick_ert_type()
		if("Code Gamma")
			if(alert("Confirm: Deploy code 'GAMMA' elite ERT?", "Emergency Response Team", "Confirm", "Cancel") == "Confirm")
				return new /datum/response_team/gamma
			else
				return pick_ert_type()
	return 0

/mob/dead/observer/proc/JoinResponseTeam()
	if(!send_emergency_team)
		to_chat(src, "No emergency response team is currently being sent.")
		return 0

	if(jobban_isbanned(src, ROLE_ERT))
		to_chat(src, "<span class='warning'>You are jobbanned from the emergency reponse team!</span>")
		return 0

	var/player_age_check = check_client_age(client, responseteam_age)
	if(player_age_check && config.use_age_restriction_for_antags)
		to_chat(src, "<span class='warning'>This role is not yet available to you. You need to wait another [player_age_check] days.</span>")
		return 0

	if(has_enabled_antagHUD == 1 && config.antag_hud_restricted)
		to_chat(src, "<span class='boldnotice'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
		return 0

	if(response_team_members.len > 6)
		to_chat(src, "The emergency response team is already full!")
		return 0

	return 1

/proc/trigger_armed_response_team(var/datum/response_team/response_team_type)
	response_team_members = list()
	active_team = response_team_type

	send_emergency_team = 1
	var/list/ert_candidates = pollCandidates("Join the Emergency Response Team?",, responseteam_age, 600, 1)
	if(!ert_candidates.len)
		active_team.cannot_send_team()
		send_emergency_team = 0
		return 0

	// Respawnable players get first dibs
	for(var/mob/dead/observer/M in ert_candidates)
		if((M in respawnable_list) && M.JoinResponseTeam())
			response_team_members |= M
	// If there's still open slots, non-respawnable players can fill them
	for(var/mob/dead/observer/M in (ert_candidates - respawnable_list))
		if(M.JoinResponseTeam())
			response_team_members |= M

	if(!response_team_members.len)
		active_team.cannot_send_team()
		send_emergency_team = 0
		return 0

	var/index = 1
	for(var/mob/M in response_team_members)
		if(index > emergencyresponseteamspawn.len)
			index = 1

		var/client/C = M.client
		var/mob/living/carbon/human/new_commando = C.create_response_team(emergencyresponseteamspawn[index])
		new_commando.mind.key = M.key
		new_commando.key = M.key
		new_commando.update_icons()
		index++

	send_emergency_team = 0
	active_team.announce_team()
	return 1

/client/proc/create_response_team(var/turf/spawn_location)
	var/mob/living/carbon/human/M = new(null)
	var/obj/item/organ/external/head/head_organ = M.get_organ("head")

	var/new_gender = alert(src, "Please select your gender.", "ERT Character Generation", "Male", "Female")

	var/class = 0
	while(!class)
		class = input(src, "Which loadout would you like to choose?") in active_team.get_slot_list()
		if(!active_team.check_slot_available(class)) // Because the prompt does not update automatically when a slot gets filled.
			class = 0

	if(new_gender)
		if(new_gender == "Male")
			M.change_gender(MALE)
		else
			M.change_gender(FEMALE)

	M.set_species("Human",1)
	M.dna.ready_dna(M)
	M.reagents.add_reagent("mutadone", 1) //No fat/blind/colourblind/epileptic/whatever ERT.
	M.overeatduration = 0

	var/hair_c = pick("#8B4513","#000000","#FF4500","#FFD700") // Brown, black, red, blonde
	var/eye_c = pick("#000000","#8B4513","1E90FF") // Black, brown, blue
	var/skin_tone = pick(-50, -30, -10, 0, 0, 0, 10) // Caucasian/black

	head_organ.r_facial = color2R(hair_c)
	head_organ.g_facial = color2G(hair_c)
	head_organ.b_facial = color2B(hair_c)
	head_organ.r_hair = color2R(hair_c)
	head_organ.g_hair = color2G(hair_c)
	head_organ.b_hair = color2B(hair_c)
	M.change_eye_color(color2R(eye_c), color2G(eye_c), color2B(eye_c))
	M.s_tone = skin_tone
	head_organ.h_style = random_hair_style(M.gender, head_organ.species.name)
	head_organ.f_style = random_facial_hair_style(M.gender, head_organ.species.name)

	M.real_name = "[pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant First Class", "Master Sergeant", "Sergeant Major")] [pick(last_names)]"
	M.name = M.real_name
	M.age = rand(23,35)
	M.regenerate_icons()
	M.update_body()

	//Creates mind stuff.
	M.mind = new
	M.mind.current = M
	M.mind.original = M
	M.mind.assigned_role = "MODE"
	M.mind.special_role = SPECIAL_ROLE_ERT
	if(!(M.mind in ticker.minds))
		ticker.minds += M.mind //Adds them to regular mind list.
	ticker.mode.ert += M.mind
	M.forceMove(spawn_location)

	active_team.equip_officer(class, M)

	return M


/datum/response_team
	var/command_slots = 1
	var/engineer_slots = 3
	var/medical_slots = 3
	var/security_slots = 3

	var/command_outfit
	var/engineering_outfit
	var/medical_outfit
	var/security_outfit

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

		if("Commander")
			command_slots = 0

			// Override name and age for the commander
			M.real_name = "[pick("Lieutenant", "Captain", "Major")] [pick(last_names)]"
			M.name = M.real_name
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

/datum/response_team/amber/announce_team()
	event_announcement.Announce("Attention, [station_name()]. We are sending a code AMBER light Emergency Response Team. Standby.", "ERT En-Route")

// -- RED TEAM --

/datum/response_team/red
	engineering_outfit = /datum/outfit/job/centcom/response_team/engineer/red
	security_outfit = /datum/outfit/job/centcom/response_team/security/red
	medical_outfit = /datum/outfit/job/centcom/response_team/medic/red
	command_outfit = /datum/outfit/job/centcom/response_team/commander/red

/datum/response_team/red/announce_team()
	event_announcement.Announce("Attention, [station_name()]. We are sending a code RED Emergency Response Team. Standby.", "ERT En-Route")

// -- GAMMA TEAM --

/datum/response_team/gamma
	engineering_outfit = /datum/outfit/job/centcom/response_team/engineer/gamma
	security_outfit = /datum/outfit/job/centcom/response_team/security/gamma
	medical_outfit = /datum/outfit/job/centcom/response_team/medic/gamma
	command_outfit = /datum/outfit/job/centcom/response_team/commander/gamma

/datum/response_team/gamma/announce_team()
	event_announcement.Announce("Attention, [station_name()]. We are sending a code GAMMA elite Emergency Response Team. Standby.", "ERT En-Route")

/datum/outfit/job/centcom/response_team
	name = "Response team"
	var/rt_assignment = "Emergency Response Team Member"
	var/rt_job = "This is a bug"
	allow_backbag_choice = FALSE
	allow_loadout = FALSE
	pda = /obj/item/device/pda/heads/ert
	id = /obj/item/weapon/card/id/ert
	l_ear = /obj/item/device/radio/headset/ert/alt

	implants = list(/obj/item/weapon/implant/mindshield)

/datum/outfit/job/centcom/response_team/pre_equip()
	. = ..()
	backpack_contents.Insert(1, /obj/item/weapon/storage/box/responseteam)
	backpack_contents[/obj/item/weapon/storage/box/responseteam] = 1

/datum/outfit/job/centcom/response_team/imprint_idcard(mob/living/carbon/human/H)
	var/obj/item/weapon/card/id/W = H.wear_id
	if(!istype(W))
		return
	W.assignment = rt_assignment
	W.rank = W.assignment
	W.age = H.age
	W.sex = capitalize(H.gender)
	W.registered_name = H.real_name
	W.name = "[H.real_name]'s ID Card ([rt_job])"
	W.access = get_centcom_access(W.assignment)
	W.photo = get_id_photo(H)

/datum/outfit/job/centcom/response_team/imprint_pda(mob/living/carbon/human/H)
	var/obj/item/device/pda/PDA = H.wear_pda
	if(istype(PDA))
		PDA.owner = H.real_name
		PDA.ownjob = rt_assignment
		PDA.ownrank = rt_assignment
		PDA.name = "PDA-[H.real_name] ([PDA.ownjob])"

/datum/outfit/job/centcom/response_team/commander
	name = "RT Commander"
	rt_assignment = "Emergency Response Team Leader"
	rt_job = "Emergency Response Team Leader"

	uniform = /obj/item/clothing/under/rank/centcom_officer
	back = /obj/item/weapon/storage/backpack/ert/commander

	id = /obj/item/weapon/card/id/ert/commander

	l_pocket = /obj/item/weapon/pinpointer
	r_pocket = /obj/item/weapon/melee/classic_baton/telescopic

/datum/outfit/job/centcom/response_team/commander/amber
	name = "RT Commander (Amber)"
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/color/black
	suit = /obj/item/clothing/suit/armor/vest/ert/command
	glasses = /obj/item/clothing/glasses/sunglasses

	belt = /obj/item/weapon/gun/energy/gun

	backpack_contents = list(
		/obj/item/clothing/head/helmet/ert/command = 1,
		/obj/item/clothing/mask/gas/sechailer = 1,
		/obj/item/weapon/restraints/handcuffs = 1,
		/obj/item/weapon/storage/lockbox/mindshield = 1
	)

/datum/outfit/job/centcom/response_team/commander/red
	name = "RT Commander (Red)"
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/space/hardsuit/ert/commander
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses

	belt = /obj/item/weapon/gun/energy/gun/nuclear

	backpack_contents = list(
		/obj/item/clothing/head/helmet/space/hardsuit/ert/commander = 1,
		/obj/item/clothing/mask/gas/sechailer/swat = 1,
		/obj/item/weapon/restraints/handcuffs = 1,
		/obj/item/weapon/storage/lockbox/mindshield = 1
	)

/datum/outfit/job/centcom/response_team/commander/gamma
	name = "RT Commander (Gamma)"
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/space/hardsuit/ert/commander
	glasses = /obj/item/clothing/glasses/hud/security/night

	belt = /obj/item/weapon/gun/energy/gun/nuclear

	backpack_contents = list(
		/obj/item/clothing/head/helmet/space/hardsuit/ert/commander = 1,
		/obj/item/clothing/mask/gas/sechailer/swat = 1,
		/obj/item/weapon/restraints/handcuffs = 1,
		/obj/item/weapon/storage/lockbox/mindshield = 1,
		/obj/item/weapon/gun/energy/pulse/pistol = 1
		)

/datum/outfit/job/centcom/response_team/security
	name = "RT Security"
	rt_job = "Emergency Response Team Officer"
	uniform = /obj/item/clothing/under/rank/security
	back = /obj/item/weapon/storage/backpack/ert/security
	belt = /obj/item/weapon/storage/belt/security/response_team
	pda = /obj/item/device/pda/heads/ert/security
	id = /obj/item/weapon/card/id/ert/security
	var/has_grenades = FALSE

/datum/outfit/job/centcom/response_team/security/pre_equip()
	. = ..()
	if(has_grenades)
		var/grenadebox = /obj/item/weapon/storage/box/flashbangs
		if(prob(50))
			grenadebox = /obj/item/weapon/storage/box/teargas
		backpack_contents.Insert(1, grenadebox)
		backpack_contents[grenadebox] = 1

/datum/outfit/job/centcom/response_team/security/amber
	name = "RT Security (Amber)"
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/color/black
	suit = /obj/item/clothing/suit/armor/vest/ert/security
	suit_store = /obj/item/weapon/gun/energy/gun/advtaser
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses

	r_hand = /obj/item/weapon/gun/energy/laser

	backpack_contents = list(
		/obj/item/clothing/head/helmet/ert/security = 1,
		/obj/item/clothing/mask/gas/sechailer = 1,
		/obj/item/weapon/storage/box/zipties = 1
	)

/datum/outfit/job/centcom/response_team/security/red
	name = "RT Security (Red)"
	has_grenades = TRUE

	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/color/black
	suit = /obj/item/clothing/suit/space/hardsuit/ert/security
	suit_store = /obj/item/weapon/gun/energy/gun/advtaser
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses

	r_hand = /obj/item/weapon/gun/energy/lasercannon

	backpack_contents = list(
		/obj/item/clothing/head/helmet/space/hardsuit/ert/security = 1,
		/obj/item/clothing/mask/gas/sechailer = 1,
		/obj/item/weapon/storage/box/handcuffs = 1,
		/obj/item/weapon/gun/energy/ionrifle/carbine = 1
	)

/datum/outfit/job/centcom/response_team/security/gamma
	name = "RT Security (Gamma)"
	has_grenades = TRUE
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/space/hardsuit/ert/security
	suit_store = /obj/item/weapon/gun/energy/gun/nuclear
	glasses = /obj/item/clothing/glasses/hud/security/night

	r_hand = /obj/item/weapon/gun/energy/pulse/carbine

	backpack_contents = list(
		/obj/item/clothing/head/helmet/space/hardsuit/ert/security = 1,
		/obj/item/clothing/mask/gas/sechailer/swat = 1,
		/obj/item/weapon/storage/box/handcuffs = 1,
		/obj/item/weapon/gun/energy/ionrifle/carbine = 1
	)

/datum/outfit/job/centcom/response_team/engineer
	name = "RT Engineer"
	rt_job = "Emergency Response Team Engineer"
	back = /obj/item/weapon/storage/backpack/ert/engineer
	uniform = /obj/item/clothing/under/rank/engineer

	belt = /obj/item/weapon/storage/belt/utility/full/multitool
	pda = /obj/item/device/pda/heads/ert/engineering
	id = /obj/item/weapon/card/id/ert/engineering

/datum/outfit/job/centcom/response_team/engineer/amber
	name = "RT Engineer (Amber)"
	shoes = /obj/item/clothing/shoes/magboots
	gloves = /obj/item/clothing/gloves/color/yellow
	suit = /obj/item/clothing/suit/space/hardsuit/ert/engineer
	suit_store = /obj/item/weapon/tank/emergency_oxygen/engi
	glasses = /obj/item/clothing/glasses/meson

	l_pocket = /obj/item/device/t_scanner
	r_pocket = /obj/item/weapon/melee/classic_baton/telescopic

	backpack_contents = list(
		/obj/item/clothing/head/helmet/space/hardsuit/ert/engineer = 1,
		/obj/item/clothing/mask/gas = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/stack/sheet/metal/fifty = 1
	)

/datum/outfit/job/centcom/response_team/engineer/red
	name = "RT Engineer (Red)"
	shoes = /obj/item/clothing/shoes/magboots
	gloves = /obj/item/clothing/gloves/color/yellow
	suit = /obj/item/clothing/suit/space/hardsuit/ert/engineer
	suit_store = /obj/item/weapon/tank/emergency_oxygen/engi
	glasses = /obj/item/clothing/glasses/meson

	l_pocket = /obj/item/device/t_scanner/extended_range
	r_pocket = /obj/item/weapon/melee/classic_baton/telescopic

	backpack_contents = list(
		/obj/item/clothing/head/helmet/space/hardsuit/ert/engineer = 1,
		/obj/item/clothing/mask/gas = 1,
		/obj/item/weapon/rcd/preloaded = 1,
		/obj/item/weapon/rcd_ammo = 3,
		/obj/item/weapon/gun/energy/gun = 1
	)

/datum/outfit/job/centcom/response_team/engineer/gamma
	name = "RT Engineer (Gamma)"
	shoes = /obj/item/clothing/shoes/magboots/advance
	gloves = /obj/item/clothing/gloves/color/yellow
	suit = /obj/item/clothing/suit/space/hardsuit/ert/engineer
	suit_store = /obj/item/weapon/tank/emergency_oxygen/double/full
	glasses = /obj/item/clothing/glasses/meson/night

	l_pocket = /obj/item/device/t_scanner/extended_range
	r_pocket = /obj/item/weapon/melee/classic_baton/telescopic

	backpack_contents = list(
		/obj/item/clothing/head/helmet/space/hardsuit/ert/engineer = 1,
		/obj/item/clothing/mask/gas/sechailer/swat = 1,
		/obj/item/weapon/rcd/combat = 1,
		/obj/item/weapon/rcd_ammo/large = 3,
		/obj/item/weapon/gun/energy/pulse/pistol = 1
	)

/datum/outfit/job/centcom/response_team/medic
	name = "RT Medic"
	rt_job = "Emergency Response Team Medic"
	uniform = /obj/item/clothing/under/rank/medical
	back = /obj/item/weapon/storage/backpack/ert/medical
	pda = /obj/item/device/pda/heads/ert/medical
	id = /obj/item/weapon/card/id/ert/medic

	l_pocket = /obj/item/weapon/reagent_containers/hypospray/CMO
	r_pocket = /obj/item/weapon/melee/classic_baton/telescopic

/datum/outfit/job/centcom/response_team/medic/amber
	name = "RT Medic (Amber)"

	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/color/latex
	suit = /obj/item/clothing/suit/armor/vest/ert/medical
	glasses = /obj/item/clothing/glasses/hud/health

	belt = /obj/item/weapon/storage/belt/medical/response_team

	l_pocket = /obj/item/weapon/reagent_containers/hypospray/CMO
	r_pocket = /obj/item/weapon/melee/classic_baton/telescopic

	backpack_contents = list(
		/obj/item/clothing/head/helmet/ert/medical = 1,
		/obj/item/clothing/mask/surgical = 1,
		/obj/item/weapon/storage/firstaid/o2 = 1,
		/obj/item/weapon/storage/firstaid/brute = 1,
		/obj/item/weapon/storage/firstaid/adv = 1,
	)

/datum/outfit/job/centcom/response_team/medic/red
	name = "RT Medic (Red)"
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	suit = /obj/item/clothing/suit/space/hardsuit/ert/medical
	glasses = /obj/item/clothing/glasses/hud/health/health_advanced

	belt = /obj/item/weapon/defibrillator/compact/loaded


	backpack_contents = list(
		/obj/item/clothing/head/helmet/space/hardsuit/ert/medical = 1,
		/obj/item/clothing/mask/surgical = 1,
		/obj/item/weapon/storage/firstaid/o2 = 1,
		/obj/item/weapon/storage/firstaid/toxin = 1,
		/obj/item/weapon/storage/firstaid/adv = 1,
		/obj/item/weapon/storage/firstaid/surgery = 1,
		/obj/item/weapon/gun/energy/gun = 1
	)

/datum/outfit/job/centcom/response_team/medic/gamma
	name = "RT Medic (Gamma)"
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/space/hardsuit/ert/medical
	glasses = /obj/item/clothing/glasses/hud/health/night

	belt = /obj/item/weapon/defibrillator/compact/loaded

	l_pocket = /obj/item/weapon/reagent_containers/hypospray/combat/nanites

	r_hand = /obj/item/weapon/gun/medbeam
	backpack_contents = list(
		/obj/item/clothing/head/helmet/space/hardsuit/ert/medical = 1,
		/obj/item/clothing/mask/gas/sechailer/swat = 1,
		/obj/item/weapon/storage/firstaid/surgery = 1,
		/obj/item/weapon/gun/energy/pulse/pistol = 1
	)

/obj/item/device/radio/centcom
	name = "centcomm bounced radio"
	frequency = ERT_FREQ
	icon_state = "radio"

/obj/item/weapon/storage/box/responseteam/
	name = "boxed survival kit"

/obj/item/weapon/storage/box/responseteam/New()
	..()
	contents = list()
	sleep(1)
	new /obj/item/clothing/mask/breath( src )
	new /obj/item/weapon/tank/emergency_oxygen/engi( src )
	new /obj/item/device/flashlight/flare( src )
	new /obj/item/weapon/kitchen/knife/combat( src )
	new /obj/item/device/radio/centcom( src )
	new /obj/item/weapon/reagent_containers/food/pill/salicylic( src )
	new /obj/item/weapon/reagent_containers/food/pill/patch/synthflesh( src )
	return
