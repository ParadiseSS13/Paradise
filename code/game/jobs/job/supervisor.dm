var/datum/announcement/minor/captain_announcement = new(do_newscast = 1)
/datum/job/captain
	title = "Captain"
	flag = CAPTAIN
	department_flag = ENGSEC
	total_positions = 1
	spawn_positions = 1
	supervisors = "Nanotrasen officials"
	selection_color = "#ccccff"
	idtype = /obj/item/weapon/card/id/gold
	req_admin_notify = 1
	access = list() 			//See get_access()
	minimal_access = list() 	//See get_access()
	minimal_player_age = 30
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/heads/captain/alt(H), slot_l_ear)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/captain(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_cap(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		var/obj/item/clothing/under/U = new /obj/item/clothing/under/rank/captain(H)
		var/obj/item/clothing/accessory/medal/gold/captain/M = new /obj/item/clothing/accessory/medal/gold/captain(U)
		U.accessories += M
		M.on_attached(U)
		H.equip_or_collect(U, slot_w_uniform)
		H.equip_or_collect(new /obj/item/device/pda/captain(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/clothing/suit/armor/vest/capcarapace(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/head/caphat(H), slot_head)
		H.equip_or_collect(new /obj/item/clothing/glasses/sunglasses(H), slot_glasses)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/ids(H), slot_r_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/ids(H.back), slot_in_backpack)
			H.equip_or_collect(new /obj/item/weapon/melee/classic_baton/telescopic(H.back), slot_in_backpack)
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
		L.imp_in = H
		L.implanted = 1
		H.sec_hud_set_implants()
		captain_announcement.Announce("All hands, captain [H.real_name] on deck!")
		callHook("captain_spawned", list("captain" = H))
		return 1

	get_access()
		return get_all_accesses()



/datum/job/hop
	title = "Head of Personnel"
	flag = HOP
	department_flag = SUPPORT
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ddddff"
	idtype = /obj/item/weapon/card/id/silver
	req_admin_notify = 1
	minimal_player_age = 21
	access = list(access_security, access_sec_doors, access_brig, access_court, access_forensics_lockers,
			            access_medical, access_engine, access_change_ids, access_ai_upload, access_eva, access_heads,
			            access_all_personal_lockers, access_maint_tunnels, access_bar, access_janitor, access_construction, access_morgue,
			            access_crematorium, access_kitchen, access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
			            access_theatre, access_chapel_office, access_library, access_research, access_mining, access_heads_vault, access_mining_station,
			            access_clown, access_mime, access_hop, access_RC_announce, access_keycard_auth, access_gateway, access_weapons, access_mineral_storeroom)
	minimal_access = list(access_security, access_sec_doors, access_brig, access_court, access_forensics_lockers,
			            access_medical, access_engine, access_change_ids, access_ai_upload, access_eva, access_heads,
			            access_all_personal_lockers, access_maint_tunnels, access_bar, access_janitor, access_construction, access_morgue,
			            access_crematorium, access_kitchen, access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
			            access_theatre, access_chapel_office, access_library, access_research, access_mining, access_heads_vault, access_mining_station,
			            access_clown, access_mime, access_hop, access_RC_announce, access_keycard_auth, access_gateway, access_weapons, access_mineral_storeroom)


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/heads/hop(H), slot_l_ear)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		H.equip_or_collect(new /obj/item/clothing/under/rank/head_of_personnel(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/head/hopcap(H), slot_head)
		H.equip_or_collect(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_or_collect(new /obj/item/device/pda/heads/hop(H), slot_wear_pda)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/ids(H), slot_r_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/ids(H.back), slot_in_backpack)
			H.equip_or_collect(new /obj/item/weapon/melee/classic_baton/telescopic(H.back), slot_in_backpack)
		return 1


/datum/job/nanotrasenrep
	title = "Nanotrasen Representative"
	flag = NANO
	department_flag = KARMA
	total_positions = 1
	spawn_positions = 1
	supervisors = "the command staff"
	selection_color = "#ddddff"
	idtype = /obj/item/weapon/card/id/nanotrasen
	req_admin_notify = 1
	minimal_player_age = 21
	access = list(access_security, access_sec_doors, access_brig, access_court, access_forensics_lockers,
			            access_medical, access_engine, access_change_ids, access_eva, access_heads,
			            access_all_personal_lockers, access_maint_tunnels, access_bar, access_janitor, access_construction, access_morgue,
			            access_crematorium, access_kitchen, access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
			            access_theatre, access_chapel_office, access_library, access_research, access_mining, access_heads_vault, access_mining_station,
			            access_clown, access_mime, access_hop, access_RC_announce, access_keycard_auth, access_gateway, access_weapons, access_ntrep)
	minimal_access = list(access_security, access_sec_doors, access_brig, access_court, access_forensics_lockers,
			            access_medical, access_engine, access_eva, access_heads,
			            access_all_personal_lockers, access_maint_tunnels, access_bar, access_janitor, access_construction, access_morgue,
			            access_crematorium, access_kitchen, access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
			            access_theatre, access_chapel_office, access_library, access_research, access_mining, access_heads_vault, access_mining_station,
			            access_clown, access_mime, access_hop, access_RC_announce, access_keycard_auth, access_gateway, access_weapons, access_ntrep)

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/heads/ntrep(H), slot_l_ear)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/melee/baton/loaded/ntcane(H.back), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/lighter/zippo/nt_rep(H.back), slot_in_backpack)
		H.equip_or_collect(new /obj/item/clothing/under/rank/ntrep(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/suit/storage/ntrep(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/clothing/shoes/centcom(H), slot_shoes)
		H.equip_or_collect(new /obj/item/device/pda/heads/ntrep(H), slot_wear_pda)
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
		L.imp_in = H
		L.implanted = 1
		H.sec_hud_set_implants()
		return 1

/datum/job/blueshield
	title = "Blueshield"
	flag = BLUESHIELD
	department_flag = KARMA
	total_positions = 1
	spawn_positions = 1
	supervisors = "the nanotrasen representative"
	selection_color = "#ddddff"
	idtype = /obj/item/weapon/card/id/nanotrasen
	req_admin_notify = 1
	minimal_player_age = 21
	access = list(access_security, access_sec_doors, access_brig, access_court, access_forensics_lockers,
			            access_medical, access_engine, access_change_ids, access_eva, access_heads,
			            access_all_personal_lockers, access_maint_tunnels, access_bar, access_janitor, access_construction, access_morgue,
			            access_crematorium, access_kitchen, access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
			            access_theatre, access_chapel_office, access_library, access_research, access_mining, access_heads_vault, access_mining_station,
			            access_clown, access_mime, access_hop, access_RC_announce, access_keycard_auth, access_gateway, access_weapons, access_blueshield)
	minimal_access = list(access_forensics_lockers, access_sec_doors, access_medical, access_construction, access_engine, access_maint_tunnels, access_research,
			            access_RC_announce, access_keycard_auth, access_heads, access_blueshield, access_weapons)

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/heads/blueshield/alt(H), slot_l_ear)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/security(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		H.equip_or_collect(new /obj/item/clothing/gloves/combat(H), slot_gloves)
		H.equip_or_collect(new /obj/item/clothing/shoes/jackboots(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/glasses/hud/health/health_advanced, slot_glasses)
		H.equip_or_collect(new /obj/item/clothing/under/rank/blueshield(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/suit/armor/vest/blueshield(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/device/pda/heads/blueshield(H), slot_wear_pda)

		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/deathimp(H), slot_r_hand)
			H.equip_or_collect(new /obj/item/weapon/gun/energy/gun/blueshield(H), slot_l_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/deathimp(H.back), slot_in_backpack)
			H.equip_or_collect(new /obj/item/weapon/gun/energy/gun/blueshield(H.back), slot_in_backpack)
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
		L.imp_in = H
		L.implanted = 1
		H.sec_hud_set_implants()
		return 1

/datum/job/judge
	title = "Magistrate"
	flag = JUDGE
	department_flag = KARMA
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Nanotrasen Supreme Court"
	selection_color = "#ddddff"
	idtype = /obj/item/weapon/card/id/nanotrasen
	req_admin_notify = 1
	minimal_player_age = 30
	access = list(access_security, access_sec_doors, access_brig, access_court, access_forensics_lockers,
			            access_medical, access_engine, access_change_ids, access_eva, access_heads,
			            access_all_personal_lockers, access_maint_tunnels, access_bar, access_janitor, access_construction, access_morgue,
			            access_crematorium, access_kitchen, access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
			            access_theatre, access_chapel_office, access_library, access_research, access_mining, access_heads_vault, access_mining_station,
			            access_clown, access_mime, access_hop, access_RC_announce, access_keycard_auth, access_gateway, access_magistrate)
	minimal_access = list(access_security, access_sec_doors, access_brig, access_court, access_maint_tunnels, access_lawyer, access_magistrate)

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/heads/magistrate/alt(H), slot_l_ear)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		H.equip_or_collect(new /obj/item/clothing/under/suit_jacket/really_black(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/suit/judgerobe(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/clothing/shoes/centcom(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/head/powdered_wig(H), slot_head)
		H.equip_or_collect(new /obj/item/clothing/glasses/hud/security/sunglasses(H), slot_glasses)
		H.equip_or_collect(new /obj/item/device/pda/heads/magistrate(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/weapon/melee/classic_baton/telescopic(H.back), slot_in_backpack)
		H.equip_or_collect(new /obj/item/device/flash(H), slot_r_store)
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
		L.imp_in = H
		L.implanted = 1
		H.sec_hud_set_implants()
		return 1

//var/global/lawyer = 0//Checks for another lawyer //This changed clothes on 2nd lawyer, both IA get the same dreds.
/datum/job/lawyer
	title = "Internal Affairs Agent"
	flag = LAWYER
	department_flag = SUPPORT
	total_positions = 2
	spawn_positions = 2
	supervisors = "the magistrate"
	selection_color = "#ddddff"
	access = list(access_lawyer, access_court, access_sec_doors, access_maint_tunnels)
	minimal_access = list(access_lawyer, access_court, access_sec_doors, access_maint_tunnels)
	alt_titles = list("Lawyer","Public Defender")
	minimal_player_age = 30
	idtype = /obj/item/weapon/card/id/security

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_sec/alt(H), slot_l_ear)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/rank/internalaffairs(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/suit/storage/internalaffairs(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/glasses/hud/security/sunglasses(H), slot_glasses)
		H.equip_or_collect(new /obj/item/device/pda/lawyer(H), slot_wear_pda)
		H.equip_or_collect(new /obj/item/weapon/storage/briefcase(H), slot_l_hand)
		H.equip_or_collect(new /obj/item/device/laser_pointer(H), slot_l_store)
		H.equip_or_collect(new /obj/item/device/flash(H), slot_r_store)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
		L.imp_in = H
		L.implanted = 1
		H.sec_hud_set_implants()
		return 1
