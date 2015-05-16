//STRIKE TEAMS
//Thanks to Kilakk for the admin-button portion of this code.

var/list/response_team_members = list()
var/list/response_team_types = list("Security","Medical","Engineering","Janitorial")
var/list/response_team_chosen_types = list()
var/responseteam_age = 21 // Minimum account age to play as an ERT member
var/global/send_emergency_team = 0 // Used for automagic response teams
                                   // 'admin_emergency_team' for admin-spawned response teams
var/ert_base_chance = 10 // Default base chance. Will be incremented by increment ERT chance.
var/can_call_ert

/client/proc/response_team()
	set name = "Dispatch Emergency Response Team"
	set category = "Event"
	set desc = "Send an emergency response team to the station."

	if(!check_rights(R_EVENT))
		return

	if(!ticker)
		usr << "\red The game hasn't started yet!"
		return

	if(ticker.current_state == 1)
		usr << "\red The round hasn't started yet!"
		return

	if(send_emergency_team)
		usr << "\red Central Command has already dispatched an emergency response team!"
		return

	if(alert("Do you want to dispatch an Emergency Response Team?",,"Yes","No") != "Yes")
		return


	if(get_security_level() != "red") // Allow admins to reconsider if the alert level isn't Red
		switch(alert("The station is not in red alert. Do you still want to dispatch a response team?",,"Yes","No"))
			if("No")
				return

	if(send_emergency_team)
		usr << "\red Central Command has already dispatched an emergency response team!"
		return

	if(pick_ert_type())
		return

	message_admins("[key_name_admin(usr)] is dispatching an Emergency Response Team.", 1)
	log_admin("[key_name(usr)] used Dispatch Response Team.")
	trigger_armed_response_team(1)

/client/proc/pick_ert_type()
	var/erttype = input("Which type of Emergency Response Team would you like to dispatch?","Emergency Response Team Type", "") as null|anything in response_team_types
	if(!erttype)
		return 1
	response_team_chosen_types |= erttype
	if(alert(usr, "Would you like to add another Emergency Response Team type?", "Emergency Response Team Type", "Yes", "No") == "Yes")
		pick_ert_type()
	else
		return 0

/mob/dead/observer/verb/JoinResponseTeam()
	set category = "Ghost"
	set name = "Join Emergency Response Team"
	set desc = "Join the Emergency Response Team. Only possible if it has been called by the crew."

	if(!istype(usr,/mob/dead/observer) && !istype(usr,/mob/new_player))
		usr << "You need to be an observer or new player to use this."
		return

	if(!send_emergency_team)
		usr << "No emergency response team is currently being sent."
		return

	if(jobban_isbanned(usr, "Emergency Response Team"))
		usr << "<span class='warning'>You are jobbanned from the emergency reponse team!</span>"
		return

	var/player_age_check = check_client_age(usr.client, responseteam_age)
	if(player_age_check && config.use_age_restriction_for_antags)
		usr << "<span class='warning'>This role is not yet available to you. You need to wait another [player_age_check] days.</span>"
		return

	if(src.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
		usr << "\blue <B>Upon using the antagHUD you forfeited the ability to join the round.</B>"
		return

	if(response_team_members.len > 6)
		usr << "The emergency response team is already full!"
		return

	for (var/obj/effect/landmark/L in landmarks_list)
		if (L.name == "Response Team")
			L.name = null

			if(alert(usr, "Would you like to join the Emergency Response Team?", "Emergency Response Team", "Yes", "No") == "No")
				L.name = "Response Team"
				return

			var/leader_selected = isemptylist(response_team_members)
			if(!src.client)
				return
			var/client/C = src.client
			var/mob/living/carbon/human/new_commando = C.create_response_team(L.loc, leader_selected)
			del(L) // Do not qdel landmarks!
			new_commando.mind.key = usr.key
			new_commando.key = usr.key
			new_commando.update_icons()

			new_commando << "\blue You are [!leader_selected?"a member":"the <B>LEADER</B>"] of an Emergency Response Team, a type of military division, under Central Command's service. There is an emergency on [station_name()], and you are tasked to go and fix the problem."
			new_commando << "<b>You should first gear up and discuss a plan with your team. More members may be joining, so don't move out before you're ready."
			if(!leader_selected)
				new_commando << "<b>As member of the Emergency Response Team, you answer only to your leader and Central Command officials.</b>"
			else
				new_commando << "<b>As leader of the Emergency Response Team, you answer only to Central Command, and have authority to override the Captain where it is necessary to achieve your mission goals. It is recommended that you attempt to cooperate with the captain where possible, however."
			return

// returns a number of dead players in %
/proc/percentage_dead()
	var/total = 0
	var/deadcount = 0
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.client) // Monkeys and mice don't have a client, amirite?
			if(H.stat == 2)
				deadcount++
			total++

	if(total == 0)
		return 0
	else
		return round(100 * deadcount / total)

// counts the number of antagonists in %
/proc/percentage_antagonists()
	var/total = 0
	var/antagonists = 0
	for(var/mob/living/carbon/human/H in mob_list)
		if(is_special_character(H) >= 1)
			antagonists++
		total++

	if(total == 0)
		return 0
	else
		return round(100 * antagonists / total)

// Increments the ERT chance automatically, so that the later it is in the round,
// the more likely an ERT is to be able to be called.
/proc/increment_ert_chance()
	while(send_emergency_team == 0) // There is no ERT at the time.
		if(get_security_level() == "green")
			ert_base_chance += 1
		if(get_security_level() == "blue")
			ert_base_chance += 2
		if(get_security_level() == "red")
			ert_base_chance += 3
		if(get_security_level() == "gamma")
			ert_base_chance += 7
		if(get_security_level() == "epsilon")
			ert_base_chance += 9
		if(get_security_level() == "delta")
			ert_base_chance += 10           // Need those big guns
		sleep(600 * 3) // Minute * Number of Minutes

/proc/trigger_armed_response_team(var/force = 0)
	if(!can_call_ert && !force)
		return
	if(send_emergency_team)
		return

	var/send_team_chance = ert_base_chance // Is incremented by increment_ert_chance.
	send_team_chance += 2*percentage_dead() // the more people are dead, the higher the chance
	send_team_chance += percentage_antagonists() // the more antagonists, the higher the chance
	send_team_chance = min(send_team_chance, 100)

	if(force)
		send_team_chance = 100

	// there's only a certain chance a team will be sent
	if(!prob(send_team_chance))
		command_announcement.Announce("It would appear that an emergency response team was requested for [station_name()]. Unfortunately, we were unable to send one at this time.", "Central Command")
		can_call_ert = 0 // Only one call per round, ladies.
		return

	command_announcement.Announce("It would appear that an emergency response team was requested for [station_name()]. We will prepare and send one as soon as possible.", "Central Command")
	can_call_ert = 0 // Only one call per round, gentlemen.
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
	for (var/obj/effect/landmark/A in world)
		if (A.name == "nukecode")
			P.loc = A.loc
			del(A)
			continue
*/

/client/proc/create_response_team(obj/spawn_location, leader_selected = 0)
	var/mob/living/carbon/human/M = new(null)
	response_team_members |= M

/*
	var/new_facial = input("Please select facial hair color.", "Character Generation") as color
	if(new_facial)
		M.r_facial = hex2num(copytext(new_facial, 2, 4))
		M.g_facial = hex2num(copytext(new_facial, 4, 6))
		M.b_facial = hex2num(copytext(new_facial, 6, 8))

	var/new_hair = input("Please select hair color.", "Character Generation") as color
	if(new_facial)
		M.r_hair = hex2num(copytext(new_hair, 2, 4))
		M.g_hair = hex2num(copytext(new_hair, 4, 6))
		M.b_hair = hex2num(copytext(new_hair, 6, 8))

	var/new_eyes = input("Please select eye color.", "Character Generation") as color
	if(new_eyes)
		M.r_eyes = hex2num(copytext(new_eyes, 2, 4))
		M.g_eyes = hex2num(copytext(new_eyes, 4, 6))
		M.b_eyes = hex2num(copytext(new_eyes, 6, 8))

	var/new_tone = input("Please select skin tone level: 1-220 (1 = albino, 35 = caucasian, 150 = black, 220 = 'very' black)", "Character Generation")  as text

	if (!new_tone)
		new_tone = 35
	M.s_tone = max(min(round(text2num(new_tone)), 220), 1)
	M.s_tone =  -M.s_tone + 35

	// hair
	var/list/all_hairs = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair
	var/list/hairs = list()

	// loop through potential hairs
	for(var/x in all_hairs)
		var/datum/sprite_accessory/hair/H = new x // create new hair datum based on type x
		hairs.Add(H.name) // add hair name to hairs
		del(H) // delete the hair after it's all done

//	var/new_style = input("Please select hair style.", "Character Generation")  as null|anything in hairs
//hair
	var/new_hstyle = input(usr, "Select a hair style.", "Grooming")  as null|anything in hair_styles_list
	if(new_hstyle)
		M.h_style = new_hstyle

	// facial hair
	var/new_fstyle = input(usr, "Select a facial hair style.", "Grooming")  as null|anything in facial_hair_styles_list
	if(new_fstyle)
		M.f_style = new_fstyle

	// if new style selected (not cancel)
	if (new_style)
		M.h_style = new_style

		for(var/x in all_hairs) // loop through all_hairs again. Might be slightly CPU expensive, but not significantly.
			var/datum/sprite_accessory/hair/H = new x // create new hair datum
			if(H.name == new_style)
				M.h_style = H // assign the hair_style variable a new hair datum
				break
			else
				del(H) // if hair H not used, delete. BYOND can garbage collect, but better safe than sorry

	// facial hair
	var/list/all_fhairs = typesof(/datum/sprite_accessory/facial_hair) - /datum/sprite_accessory/facial_hair
	var/list/fhairs = list()

	for(var/x in all_fhairs)
		var/datum/sprite_accessory/facial_hair/H = new x
		fhairs.Add(H.name)
		del(H)

	new_style = input("Please select facial hair style.", "Character Generation")  as null|anything in fhairs

	if(new_style)
		M.f_style = new_style
		for(var/x in all_fhairs)
			var/datum/sprite_accessory/facial_hair/H = new x
			if(H.name == new_style)
				M.f_style = H
				break
			else
				del(H)

	//M.rebuild_appearance()
	*/

	var/new_gender = alert(usr, "Please select your gender.", "Character Generation", "Male", "Female")
	if (new_gender)
		if(new_gender == "Male")
			M.gender = MALE
		else
			M.gender = FEMALE

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

	M.r_facial = hex2num(copytext(hair_c, 2, 4))
	M.g_facial = hex2num(copytext(hair_c, 4, 6))
	M.b_facial = hex2num(copytext(hair_c, 6, 8))
	M.r_hair = hex2num(copytext(hair_c, 2, 4))
	M.g_hair = hex2num(copytext(hair_c, 4, 6))
	M.b_hair = hex2num(copytext(hair_c, 6, 8))
	M.r_eyes = hex2num(copytext(eye_c, 2, 4))
	M.g_eyes = hex2num(copytext(eye_c, 4, 6))
	M.b_eyes = hex2num(copytext(eye_c, 6, 8))
	M.s_tone = skin_tone
	M.h_style = hair_style
	M.f_style = facial_hair_style

	M.real_name = "[!leader_selected ? pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant First Class", "Master Sergeant", "Sergeant Major") : pick("Lieutenant", "Captain", "Major")] [pick(last_names)]"
	M.name = M.real_name
	M.age = !leader_selected ? rand(23,35) : rand(35,45)

	//Creates mind stuff.
	M.mind = new
	M.mind.current = M
	M.mind.original = M
	M.mind.assigned_role = "MODE"
	M.mind.special_role = "Response Team"
	if(!(M.mind in ticker.minds))
		ticker.minds += M.mind //Adds them to regular mind list.
	M.loc = spawn_location

	var/class = input("Which class would you like to choose?") in response_team_chosen_types
	if(leader_selected)
		equip_emergencyresponsesquad(M, "Commander", class)
	else
		equip_emergencyresponsesquad(M, class)

	return M

/proc/equip_emergencyresponsesquad(var/mob/living/carbon/human/M, var/role, var/role2)
	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/ert/alt(src), slot_l_ear)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom_officer(M), slot_w_uniform)

	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(M)
	L.imp_in = M
	L.implanted = 1

	switch(role)
		if("Commander")
			if(role2 == "Janitorial")
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/galoshes(M), slot_shoes)
			else
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots/advance(M), slot_shoes)

			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/commander(M), slot_wear_suit)
			var/obj/item/clothing/suit/space/rig/R = M.wear_suit
			R.helmet = new /obj/item/clothing/head/helmet/space/rig/ert/commander(M)
			M.equip_to_slot_or_del(R.helmet, slot_head)
			R.helmet.flags |= NODROP

			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/swat(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/ert/commander(M), slot_back)

			var/obj/item/weapon/card/id/W = new(src)
			W.assignment = "Emergency Response Team Leader"
			W.registered_name = M.real_name
			W.name = "[M.real_name]'s ID Card (Emergency Response Team - Commander)"
			W.icon_state = "centcom"
			W.access = get_centcom_access(W.assignment)
			M.equip_to_slot_or_del(W, slot_wear_id)

			var/obj/item/device/pda/heads/pda = new(src)
			pda.owner = M.real_name
			pda.ownjob = "Emergency Response Team Leader"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_wear_pda)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(M), slot_s_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/double/full(M), slot_r_store)

			M.equip_to_slot_or_del(new /obj/item/weapon/pinpointer/advpinpointer(M), slot_in_backpack)

			switch(role2)
				if("Security")
					M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
					M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud(M), slot_glasses)
					M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/security/response_team(M), slot_belt)

					M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/security/night(M), slot_in_backpack)
					M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/handcuffs(M), slot_in_backpack)
					M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun/nuclear(M), slot_in_backpack)
					M.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/tele(M), slot_in_backpack)

				if("Medical")
					M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/latex/nitrile(M), slot_gloves)
					M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health/night(M), slot_glasses)
					M.equip_to_slot_or_del(new /obj/item/weapon/defibrillator/compact/combat/loaded(M), slot_belt)

					M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/fire(M), slot_in_backpack)
					M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/o2(M), slot_in_backpack)
					M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/toxin(M), slot_in_backpack)
					M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/hypospray/CMO(M), slot_in_backpack)

					M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/adv(M), slot_r_hand)

				if("Engineering")
					M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
					M.equip_to_slot_or_del(new /obj/item/clothing/glasses/meson/night(M), slot_glasses)
					M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full/multitool(M), slot_belt)

					M.equip_to_slot_or_del(new /obj/item/weapon/rcd/combat(M), slot_in_backpack)
					M.equip_to_slot_or_del(new /obj/item/weapon/rcd_ammo/large(M), slot_in_backpack)
					M.equip_to_slot_or_del(new /obj/item/weapon/rcd_ammo/large(M), slot_in_backpack)
					M.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/full(M), slot_in_backpack)
					M.equip_to_slot_or_del(new /obj/item/stack/sheet/glass/full(M), slot_in_backpack)
					M.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/full(M), slot_in_backpack)

					M.equip_to_slot_or_del(new /obj/item/weapon/storage/briefcase/inflatable(M), slot_r_hand)

				if("Janitorial")
					M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/purple(M), slot_gloves)
					M.equip_to_slot_or_del(new /obj/item/clothing/glasses/janitor, slot_glasses)
					M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/janitor/full, slot_belt)

					M.equip_to_slot_or_del(new /obj/item/clothing/glasses/night(src), slot_in_backpack)
					M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/lights/mixed(src), slot_in_backpack)
					M.equip_to_slot_or_del(new /obj/item/weapon/scythe/tele(src), slot_in_backpack)
					M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/glass/bucket(src), slot_in_backpack)

					M.equip_to_slot_or_del(new /obj/item/weapon/mop/advanced(M), slot_r_hand)

					new /obj/structure/mopbucket/full(get_turf(M))

		if("Security")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/security(M), slot_wear_suit)

			var/obj/item/clothing/suit/space/rig/R = M.wear_suit
			R.helmet = new /obj/item/clothing/head/helmet/space/rig/ert/security(M)
			M.equip_to_slot_or_del(R.helmet, slot_head)
			R.helmet.flags |= NODROP

			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/swat(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/ert/security(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud(M), slot_glasses)

			var/obj/item/weapon/card/id/W = new(src)
			W.assignment = "Emergency Response Team Member"
			W.registered_name = M.real_name
			W.name = "[M.real_name]'s ID Card (Emergency Response Team - Officer)"
			W.icon_state = "centcom"
			W.access = get_centcom_access(W.assignment)
			M.equip_to_slot_or_del(W, slot_wear_id)

			var/obj/item/device/pda/heads/pda = new(src)
			pda.owner = M.real_name
			pda.ownjob = "Emergency Response Team Member"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			pda.icon_state = "pda-security"
			M.equip_to_slot_or_del(pda, slot_wear_pda)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(M), slot_s_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/double/full(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/restraints/handcuffs, slot_l_store)

			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/security/night(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/handcuffs(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun/nuclear(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/tele(M), slot_in_backpack)

			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/security/response_team(M), slot_belt)

		if("Medical")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/latex/nitrile(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/medical(M), slot_wear_suit)

			var/obj/item/clothing/suit/space/rig/R = M.wear_suit
			R.helmet = new /obj/item/clothing/head/helmet/space/rig/ert/medical(M)
			M.equip_to_slot_or_del(R.helmet, slot_head)
			R.helmet.flags |= NODROP

			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/swat(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/ert/medical(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health/night(M), slot_glasses)

			var/obj/item/weapon/card/id/W = new(src)
			W.assignment = "Emergency Response Team Member"
			W.registered_name = M.real_name
			W.name = "[M.real_name]'s ID Card (Emergency Response Team - Medic)"
			W.icon_state = "centcom"
			W.access = get_centcom_access(W.assignment)
			M.equip_to_slot_or_del(W, slot_wear_id)

			var/obj/item/device/pda/heads/pda = new(src)
			pda.owner = M.real_name
			pda.ownjob = "Emergency Response Team Member"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			pda.icon_state = "pda-medical"
			M.equip_to_slot_or_del(pda, slot_wear_pda)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(M), slot_s_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/double/full(M), slot_r_store)

			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/fire(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/o2(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/toxin(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/hypospray/CMO(M), slot_in_backpack)

			M.equip_to_slot_or_del(new /obj/item/weapon/defibrillator/compact/combat/loaded(M), slot_belt)

			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/adv(M), slot_r_hand)

		if("Engineering")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots/advance(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/ert/engineer(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/engineer(M), slot_wear_suit)

			var/obj/item/clothing/suit/space/rig/R = M.wear_suit
			R.helmet = new /obj/item/clothing/head/helmet/space/rig/ert/engineer(M)
			M.equip_to_slot_or_del(R.helmet, slot_head)
			R.helmet.flags |= NODROP

			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/swat(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/meson/night(M), slot_glasses)

			var/obj/item/weapon/card/id/W = new(src)
			W.assignment = "Emergency Response Team Member"
			W.registered_name = M.real_name
			W.name = "[M.real_name]'s ID Card (Emergency Response Team - Engineer)"
			W.icon_state = "centcom"
			W.access = get_centcom_access(W.assignment)
			M.equip_to_slot_or_del(W, slot_wear_id)

			var/obj/item/device/pda/heads/pda = new(src)
			pda.owner = M.real_name
			pda.ownjob = "Emergency Response Team Member"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			pda.icon_state = "pda-engineer"
			M.equip_to_slot_or_del(pda, slot_wear_pda)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(M), slot_s_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/double/full(M), slot_r_store)

			M.equip_to_slot_or_del(new /obj/item/weapon/rcd/combat(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/rcd_ammo/large(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/rcd_ammo/large(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/full(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/sheet/glass/full(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/full(M), slot_in_backpack)

			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full/multitool(M), slot_belt)

		if("Janitorial")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/galoshes(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/purple(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/janitor(M), slot_wear_suit)

			var/obj/item/clothing/suit/space/rig/R = M.wear_suit
			R.helmet = new /obj/item/clothing/head/helmet/space/rig/ert/janitor(M)
			M.equip_to_slot_or_del(R.helmet, slot_head)
			R.helmet.flags |= NODROP

			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/swat(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/ert/janitor(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/janitor(M), slot_glasses)

			var/obj/item/weapon/card/id/W = new(src)
			W.assignment = "Emergency Response Team Member"
			W.registered_name = M.real_name
			W.name = "[M.real_name]'s ID Card (Emergency Response Team - Janitor)"
			W.icon_state = "centcom"
			W.access = get_centcom_access(W.assignment)
			M.equip_to_slot_or_del(W, slot_wear_id)

			var/obj/item/device/pda/heads/pda = new(src)
			pda.owner = M.real_name
			pda.ownjob = "Emergency Response Team Member"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			pda.icon_state = "pda-janitor"
			M.equip_to_slot_or_del(pda, slot_wear_pda)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(M), slot_s_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/double/full(M), slot_r_store)

			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/night(src), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/lights/mixed(src), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/scythe/tele(src), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/glass/bucket(src), slot_in_backpack)

			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/janitor/full, slot_belt)

			M.equip_to_slot_or_del(new /obj/item/weapon/mop/advanced(M), slot_r_hand)

			new /obj/structure/mopbucket/full(get_turf(M))

/*/mob/living/carbon/human/proc/equip_strike_team(leader_selected = 0) Old ERT equip verb.

	//Special radio setup
	equip_to_slot_or_del(new /obj/item/device/radio/headset/ert/alt(src), slot_l_ear)

	//Replaced with new ERT uniform
	equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom_officer(src), slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(src), slot_shoes)
	equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)
	equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(src), slot_back)

	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Emergency Response Team[leader_selected ? " Leader" : ""]"
	W.registered_name = real_name
	W.name = "[real_name]'s ID Card ([W.assignment])"
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += list(access_cent_general, access_cent_living, access_cent_storage)

	var/obj/item/device/pda/heads/pda = new(src)
	pda.owner = real_name
	pda.ownjob = "Emergency Response Team[leader_selected ? " Leader" : ""]"
	pda.name = "PDA-[real_name] ([pda.ownjob])"
	equip_to_slot_or_del(pda, slot_wear_pda)

	if (leader_selected)
		W.access += access_cent_teleporter
	equip_to_slot_or_del(W, slot_wear_id)

	// Loyalty implant
	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(src)
	L.imp_in = src
	L.implanted = 1

	return 1*/
