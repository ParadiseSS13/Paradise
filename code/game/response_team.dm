//STRIKE TEAMS
//Thanks to Kilakk for the admin-button portion of this code.

#define ERT_TYPE_AMBER		1
#define ERT_TYPE_RED		2
#define ERT_TYPE_GAMMA		3

var/list/response_team_members = list()
var/responseteam_age = 21 // Minimum account age to play as an ERT member
var/datum/response_team/active_team = null
var/send_emergency_team

/client/proc/response_team()
	set name = "Dispatch CentComm Response Team"
	set category = "Event"
	set desc = "Send an CentComm response team to the station."

	if(!check_rights(R_EVENT))
		return

	if(!ticker)
		to_chat(usr, "\red The game hasn't started yet!")
		return

	if(ticker.current_state == 1)
		to_chat(usr, "\red The round hasn't started yet!")
		return

	if(send_emergency_team)
		to_chat(usr, "\red Central Command has already dispatched an emergency response team!")
		return

	if(alert("Do you want to dispatch an Emergency Response Team?",,"Yes","No") != "Yes")
		return

	if(get_security_level() != "red") // Allow admins to reconsider if the alert level isn't Red
		switch(alert("The station is not in red alert. Do you still want to dispatch a response team?",,"Yes","No"))
			if("No")
				return

	if(send_emergency_team)
		to_chat(usr, "\red Central Command has already dispatched an emergency response team!")
		return

	var/ert_type = pick_ert_type()

	if(!ert_type)
		return

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
			if(alert("Confirm: Deploy code 'RED' <b>medium ERT</b>?", "Emergency Response Team", "Confirm", "Cancel") == "Confirm")
				return new /datum/response_team/red
			else
				return pick_ert_type()
		if("Code Gamma")
			if(alert("Confirm: Deploy code 'GAMMA' <b>elite ERT</b>?", "Emergency Response Team", "Confirm", "Cancel") == "Confirm")
				return new /datum/response_team/gamma
			else
				return pick_ert_type()
	return 0

/mob/dead/observer/verb/JoinResponseTeam()
	set category = "Ghost"
	set name = "Join Emergency Response Team"
	set desc = "Join the Emergency Response Team. Only possible if it has been called by the crew."

	if(!istype(usr,/mob/dead/observer) && !istype(usr,/mob/new_player))
		to_chat(usr, "You need to be an observer or new player to use this.")
		return

	if(!send_emergency_team)
		to_chat(usr, "No emergency response team is currently being sent.")
		return

	if(jobban_isbanned(usr, ROLE_ERT))
		to_chat(usr, "<span class='warning'>You are jobbanned from the emergency reponse team!</span>")
		return

	var/player_age_check = check_client_age(usr.client, responseteam_age)
	if(player_age_check && config.use_age_restriction_for_antags)
		to_chat(usr, "<span class='warning'>This role is not yet available to you. You need to wait another [player_age_check] days.</span>")
		return

	if(src.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
		to_chat(usr, "\blue <B>Upon using the antagHUD you forfeited the ability to join the round.</B>")
		return

	if(response_team_members.len > 6)
		to_chat(usr, "The emergency response team is already full!")
		return

	for (var/obj/effect/landmark/L in landmarks_list)
		if (L.name == "Response Team")
			L.name = null

			if(alert(usr, "Would you like to join the Emergency Response Team?", "Emergency Response Team", "Yes", "No") == "No")
				L.name = "Response Team"
				return

			if(!src.client)
				return
			var/client/C = src.client
			var/mob/living/carbon/human/new_commando = C.create_response_team(L.loc)
			qdel(L)
			new_commando.mind.key = usr.key
			new_commando.key = usr.key
			new_commando.update_icons()

			return

/proc/trigger_armed_response_team(var/datum/response_team/response_team_type)

	active_team = response_team_type
	active_team.announce_team()

	send_emergency_team = 1
	sleep(600 * 5)
	send_emergency_team = 0 // Can no longer join the ERT.

/*
	var/area/security/nuke_storage/nukeloc = locate() //To find the nuke in the vault
	var/obj/machinery/nuclearbomb/nuke = locate() in nukeloc
	if(!nuke)
		nuke = locate() in world
	var/obj/item/weapon/paper/P = new
	P.info = "Your orders, Commander, are to use all means necessary to return the station to a survivable condition.<br>To this end, you have been provided with the best tools we can give for Security, Medical, Engineering and Janitorial duties. The nuclear authorization code is: <b>[ nuke ? nuke.r_code : "UNKNOWN"]</b>. Be warned, if you detonate this without good reason, we will hold you to account for damages. Memorise this code, and then destroy this message."
	P.name = "ERT Orders and Emergency Nuclear Code"
	var/obj/item/weapon/stamp/centcom/stamp = new
	P.stamp(stamp)
	qdel(stamp)
	for (var/obj/effect/landmark/A in world)
		if (A.name == "nukecode")
			P.loc = A.loc
			qdel(A)
			continue
*/

/client/proc/create_response_team(obj/spawn_location)
	var/mob/living/carbon/human/M = new(null)
	var/obj/item/organ/external/head/head_organ = M.get_organ("head")
	response_team_members |= M

	var/new_gender = alert(usr, "Please select your gender.", "Character Generation", "Male", "Female")
	if (new_gender)
		if(new_gender == "Male")
			M.change_gender(MALE)
		else
			M.change_gender(FEMALE)

	M.set_species("Human",1)
	M.dna.ready_dna(M)

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
	M.r_eyes = hex2num(copytext(eye_c, 2, 4))
	M.g_eyes = hex2num(copytext(eye_c, 4, 6))
	M.b_eyes = hex2num(copytext(eye_c, 6, 8))
	M.s_tone = skin_tone
	head_organ.h_style = hair_style
	head_organ.f_style = facial_hair_style

	M.real_name = "[pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant First Class", "Master Sergeant", "Sergeant Major")] [pick(last_names)]"
	M.name = M.real_name
	M.age = rand(23,35)

	//Creates mind stuff.
	M.mind = new
	M.mind.current = M
	M.mind.original = M
	M.mind.assigned_role = "MODE"
	M.mind.special_role = "Response Team"
	if(!(M.mind in ticker.minds))
		ticker.minds += M.mind //Adds them to regular mind list.
	M.loc = spawn_location

	var/class = 0
	while (!class)
		class = input("Which loadout would you like to choose?") in active_team.get_slot_list()
		if(!active_team.check_slot_available(class)) // Because the prompt does not update automatically when a slot gets filled.
			class = 0

	active_team.equip_officer(class, M)

	return M


/datum/response_team
	var/command_slots = 1
	var/engineer_slots = 3
	var/medical_slots = 3
	var/security_slots = 3

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
	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/ert/alt(src), slot_l_ear)

	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(M)
	L.imp_in = M
	L.implanted = 1
	M.sec_hud_set_implants()

	switch(officer_type)
		if("Engineer")
			engineer_slots -= 1
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/engineer(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/ert/engineer(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/responseteam(M), slot_in_backpack)

			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full/multitool(M), slot_belt)

			var/obj/item/weapon/card/id/W = new(src)
			W.assignment = "Emergency Response Team Member"
			W.registered_name = M.real_name
			W.name = "[M.real_name]'s ID Card (Emergency Response Team Engineer)"
			W.icon_state = "ERT_engineering"
			W.access = get_centcom_access(W.assignment)
			M.equip_to_slot_or_del(W, slot_wear_id)

			var/obj/item/device/pda/heads/pda = new(src)
			pda.owner = M.real_name
			pda.ownjob = "Emergency Response Team Member"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			pda.icon_state = "pda-engineer"
			M.equip_to_slot_or_del(pda, slot_wear_pda)


		if("Security")
			security_slots -= 1
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/security(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/ert/security(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/responseteam(M), slot_in_backpack)

			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/security/response_team(M), slot_belt)

			var/obj/item/weapon/card/id/W = new(src)
			W.assignment = "Emergency Response Team Member"
			W.registered_name = M.real_name
			W.name = "[M.real_name]'s ID Card (Emergency Response Team Officer)"
			W.icon_state = "ERT_security"
			W.access = get_centcom_access(W.assignment)
			M.equip_to_slot_or_del(W, slot_wear_id)

			var/obj/item/device/pda/heads/pda = new(src)
			pda.owner = M.real_name
			pda.ownjob = "Emergency Response Team Member"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			pda.icon_state = "pda-security"
			M.equip_to_slot_or_del(pda, slot_wear_pda)


		if("Medic")
			medical_slots -= 1
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/ert/medical(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/responseteam(M), slot_in_backpack)

			var/obj/item/weapon/card/id/W = new(src)
			W.assignment = "Emergency Response Team Member"
			W.registered_name = M.real_name
			W.name = "[M.real_name]'s ID Card (Emergency Response Team Medic)"
			W.icon_state = "ERT_medical"
			W.access = get_centcom_access(W.assignment)
			M.equip_to_slot_or_del(W, slot_wear_id)

			var/obj/item/device/pda/heads/pda = new(src)
			pda.owner = M.real_name
			pda.ownjob = "Emergency Response Team Member"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			pda.icon_state = "pda-medical"
			M.equip_to_slot_or_del(pda, slot_wear_pda)


		if("Commander")
			command_slots = 0

			// Override name and age for the commander
			M.real_name = "[pick("Lieutenant", "Captain", "Major")] [pick(last_names)]"
			M.name = M.real_name
			M.age = rand(35,45)

			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom_officer(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/ert/commander(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/responseteam(M), slot_in_backpack)

			var/obj/item/weapon/card/id/W = new(src)
			W.assignment = "Emergency Response Team Leader"
			W.registered_name = M.real_name
			W.name = "[M.real_name]'s ID Card (Emergency Response Team Leader)"
			W.icon_state = "ERT_leader"
			W.access = get_centcom_access(W.assignment)
			M.equip_to_slot_or_del(W, slot_wear_id)

			var/obj/item/device/pda/heads/pda = new(src)
			pda.owner = M.real_name
			pda.ownjob = "Emergency Response Team Leader"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_wear_pda)


/datum/response_team/proc/announce_team()
	command_announcement.Announce("Attention, [station_name()]. We are attempting to assemble a team of highly trained assistants to aid(?) you. Standby.", "Central Command")

// -- AMBER TEAM --

/datum/response_team/amber

/datum/response_team/amber/announce_team()
	command_announcement.Announce("Attention, [station_name()]. We are attempting to assemble a code AMBER light Emergency Response Team. Standby.", "Central Command")

/datum/response_team/amber/equip_officer(var/officer_type, var/mob/living/carbon/human/M)
	..()

	switch(officer_type)
		if("Engineer")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/yellow(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/engineer(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/engi(M), slot_s_store)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/meson(M), slot_glasses)

			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/ert/engineer(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/sheet/glass(M, amount=50), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/sheet/metal(M, amount=50), slot_in_backpack)

			M.equip_to_slot_or_del(new /obj/item/device/t_scanner(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/classic_baton/telescopic(M), slot_r_store)

		if("Security")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/black(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest/ert/security(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun/advtaser(M), slot_s_store)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/security/sunglasses(M), slot_glasses)

			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/ert/security(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/sechailer(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/zipties(M), slot_in_backpack)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/laser(M), slot_r_hand)

		if("Medic")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/latex(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest/ert/medical(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(M), slot_glasses)

			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/medical/response_team(M), slot_belt)

			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/ert/medical(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/surgical(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/o2(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/brute(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/adv(M), slot_in_backpack)

			M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/hypospray/CMO(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/classic_baton/telescopic(M), slot_r_store)

		if("Commander")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/black(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest/ert/command(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), slot_glasses)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(M), slot_belt)

			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/ert/command(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/sechailer(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/restraints/handcuffs(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/lockbox/loyalty(M), slot_in_backpack)

			M.equip_to_slot_or_del(new /obj/item/weapon/pinpointer(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/classic_baton/telescopic(M), slot_r_store)

// -- RED TEAM --

/datum/response_team/red

/datum/response_team/red/announce_team()
	command_announcement.Announce("Attention, [station_name()]. We are attempting to assemble a code RED Emergency Response Team. Standby.", "Central Command")

/datum/response_team/red/equip_officer(var/officer_type, var/mob/living/carbon/human/M)
	..()

	switch(officer_type)
		if("Engineer")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/yellow(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/engineer(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/engi(M), slot_s_store)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/meson(M), slot_glasses)

			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/ert/engineer(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(M), slot_in_backpack)
			var/obj/item/weapon/rcd/R = new /obj/item/weapon/rcd(src)
			R.matter = 100
			M.equip_to_slot_or_del(R, slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/rcd_ammo(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/rcd_ammo(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/rcd_ammo(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(M), slot_in_backpack)

			M.equip_to_slot_or_del(new /obj/item/device/t_scanner/extended_range(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/classic_baton/telescopic(M), slot_r_store)

		if("Security")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/black(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/security(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun/advtaser(M), slot_s_store)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/security/sunglasses(M), slot_glasses)

			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/ert/security(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/sechailer(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/handcuffs(M), slot_in_backpack)
			if(prob(50))
				M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/teargas(M), slot_in_backpack)
			else
				M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/flashbangs(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/ionrifle/carbine(M), slot_in_backpack)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasercannon(M), slot_r_hand)

		if("Medic")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/latex/nitrile(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/medical(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health/health_advanced(M), slot_glasses)

			M.equip_to_slot_or_del(new /obj/item/weapon/defibrillator/compact/loaded(M), slot_belt)

			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/ert/medical(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/surgical(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/o2(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/toxin(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/adv(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/surgery(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(M), slot_in_backpack)

			M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/hypospray/CMO(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/classic_baton/telescopic(M), slot_r_store)

		if("Commander")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/black(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/commander(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/security/sunglasses(M), slot_glasses)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun/nuclear(M), slot_belt)

			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/ert/commander(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/sechailer/swat(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/restraints/handcuffs(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/lockbox/loyalty(M), slot_in_backpack)

			M.equip_to_slot_or_del(new /obj/item/weapon/pinpointer(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/classic_baton/telescopic(M), slot_r_store)

// -- GAMMA TEAM --

/datum/response_team/gamma

/datum/response_team/gamma/announce_team()
	command_announcement.Announce("Attention, [station_name()]. We are attempting to assemble a code GAMMA elite Emergency Response Team. Standby.", "Central Command")

/datum/response_team/gamma/equip_officer(var/officer_type, var/mob/living/carbon/human/M)
	..()

	switch(officer_type)
		if("Engineer")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots/advance(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/yellow(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/engineer(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/double/full(M), slot_s_store)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/meson/night(M), slot_glasses)

			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/ert/engineer(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/sechailer/swat(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/rcd/combat, slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/rcd_ammo/large(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/rcd_ammo/large(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/rcd_ammo/large(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse/pistol(M), slot_in_backpack)

			M.equip_to_slot_or_del(new /obj/item/device/t_scanner/extended_range(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/classic_baton/telescopic(M), slot_r_store)

		if("Security")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat/swat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/security(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun/nuclear(M), slot_s_store)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/security/night(M), slot_glasses)

			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/ert/security(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/sechailer/swat(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/handcuffs(M), slot_in_backpack)
			if(prob(50))
				M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/teargas(M), slot_in_backpack)
			else
				M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/flashbangs(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/ionrifle/carbine(M), slot_in_backpack)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse/carbine(M), slot_r_hand)

		if("Medic")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat/swat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/medical(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health/night(M), slot_glasses)

			M.equip_to_slot_or_del(new /obj/item/weapon/defibrillator/compact/loaded(M), slot_belt)

			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/ert/medical(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/sechailer/swat(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/surgery(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse/pistol(M), slot_in_backpack)

			M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/hypospray/combat/nanites(src), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/classic_baton/telescopic(M), slot_r_store)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/medbeam(M), slot_r_hand)

		if("Commander")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat/swat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/commander(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/security/night(M), slot_glasses)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun/nuclear(M), slot_belt)

			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/ert/commander(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/sechailer/swat(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/restraints/handcuffs(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/lockbox/loyalty(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse/pistol(M), slot_in_backpack)

			M.equip_to_slot_or_del(new /obj/item/weapon/pinpointer(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/classic_baton/telescopic(M), slot_r_store)


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
