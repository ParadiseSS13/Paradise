var/datum/announcement/minor/captain_announcement = new(do_newscast = 0)
/datum/job/captain
	title = "Captain"
	flag = CAPTAIN
	department_flag = ENGSEC
	total_positions = 1
	spawn_positions = 1
	supervisors = "Nanotrasen officials"
	selection_color = "#ccccff"
	req_admin_notify = 1
	is_command = 1
	access = list() 			//See get_access()
	minimal_access = list() 	//See get_access()
	minimal_player_age = 30
	exp_requirements = 1200
	exp_type = EXP_TYPE_CREW
	outfit = /datum/outfit/job/captain

/datum/job/captain/get_access()
	return get_all_accesses()

/datum/job/captain/announce(mob/living/carbon/human/H)
	. = ..()
	captain_announcement.Announce("All hands, Captain [H.real_name] on deck!")
	callHook("captain_spawned", list("captain" = H))

/datum/outfit/job/captain
	name = "Captain"
	jobtype = /datum/job/captain

	uniform = /obj/item/clothing/under/rank/captain
	suit = /obj/item/clothing/suit/armor/vest/capcarapace
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/caphat
	l_ear = /obj/item/device/radio/headset/heads/captain/alt
	glasses = /obj/item/clothing/glasses/sunglasses
	id = /obj/item/weapon/card/id/gold
	pda = /obj/item/device/pda/captain
	backpack_contents = list(
		/obj/item/weapon/storage/box/ids = 1,
		/obj/item/weapon/melee/classic_baton/telescopic = 1
	)

	implants = list(/obj/item/weapon/implant/mindshield)

	backpack = /obj/item/weapon/storage/backpack/captain
	satchel = /obj/item/weapon/storage/backpack/satchel_cap
	dufflebag = /obj/item/weapon/storage/backpack/duffel/captain

/datum/outfit/job/captain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H && H.w_uniform)
		var/obj/item/clothing/under/U = H.w_uniform
		var/obj/item/clothing/accessory/medal/gold/captain/M = new /obj/item/clothing/accessory/medal/gold/captain(U)
		U.accessories += M
		M.on_attached(U)



/datum/job/hop
	title = "Head of Personnel"
	flag = HOP
	department_flag = SUPPORT
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ddddff"
	req_admin_notify = 1
	is_command = 1
	minimal_player_age = 21
	exp_requirements = 600
	exp_type = EXP_TYPE_CREW
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

	outfit = /datum/outfit/job/hop

/datum/outfit/job/hop
	name = "Head of Personnel"
	jobtype = /datum/job/hop

	uniform = /obj/item/clothing/under/rank/head_of_personnel
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/hopcap
	l_ear = /obj/item/device/radio/headset/heads/hop
	id = /obj/item/weapon/card/id/silver
	pda = /obj/item/device/pda/heads/hop
	backpack_contents = list(
		/obj/item/weapon/storage/box/ids = 1,
		/obj/item/weapon/melee/classic_baton/telescopic = 1
	)

	implants = list()



/datum/job/nanotrasenrep
	title = "Nanotrasen Representative"
	flag = NANO
	department_flag = KARMA
	total_positions = 1
	spawn_positions = 1
	supervisors = "the command staff"
	selection_color = "#ddddff"
	req_admin_notify = 1
	is_command = 1
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

	outfit = /datum/outfit/job/nanotrasenrep

/datum/outfit/job/nanotrasenrep
	name = "Nanotrasen Representative"
	jobtype = /datum/job/nanotrasenrep

	uniform = /obj/item/clothing/under/rank/ntrep
	suit = /obj/item/clothing/suit/storage/ntrep
	shoes = /obj/item/clothing/shoes/centcom
	l_ear = /obj/item/device/radio/headset/heads/ntrep
	id = /obj/item/weapon/card/id/nanotrasen
	l_pocket = /obj/item/weapon/lighter/zippo/nt_rep
	pda = /obj/item/device/pda/heads/ntrep
	backpack_contents = list(
		/obj/item/weapon/melee/classic_baton/ntcane = 1
	)

	implants = list(/obj/item/weapon/implant/mindshield)



/datum/job/blueshield
	title = "Blueshield"
	flag = BLUESHIELD
	department_flag = KARMA
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Nanotrasen representative"
	selection_color = "#ddddff"
	req_admin_notify = 1
	is_command = 1
	minimal_player_age = 21
	access = list(access_security, access_sec_doors, access_brig, access_court, access_forensics_lockers,
			            access_medical, access_engine, access_change_ids, access_eva, access_heads,
			            access_all_personal_lockers, access_maint_tunnels, access_bar, access_janitor, access_construction, access_morgue,
			            access_crematorium, access_kitchen, access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
			            access_theatre, access_chapel_office, access_library, access_research, access_mining, access_heads_vault, access_mining_station,
			            access_clown, access_mime, access_hop, access_RC_announce, access_keycard_auth, access_gateway, access_weapons, access_blueshield)
	minimal_access = list(access_forensics_lockers, access_sec_doors, access_medical, access_construction, access_engine, access_maint_tunnels, access_research,
			            access_RC_announce, access_keycard_auth, access_heads, access_blueshield, access_weapons)

	outfit = /datum/outfit/job/blueshield

/datum/outfit/job/blueshield
	name = "Blueshield"
	jobtype = /datum/job/blueshield

	uniform = /obj/item/clothing/under/rank/blueshield
	suit = /obj/item/clothing/suit/armor/vest/blueshield
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/jackboots
	l_ear = /obj/item/device/radio/headset/heads/blueshield/alt
	glasses = /obj/item/clothing/glasses/hud/health/health_advanced
	id = /obj/item/weapon/card/id/nanotrasen
	pda = /obj/item/device/pda/heads/blueshield
	backpack_contents = list(
		/obj/item/weapon/storage/box/deathimp = 1,
		/obj/item/weapon/gun/energy/gun/blueshield = 1
	)

	implants = list(/obj/item/weapon/implant/mindshield)

	backpack = /obj/item/weapon/storage/backpack/security
	satchel = /obj/item/weapon/storage/backpack/satchel_sec
	dufflebag = /obj/item/weapon/storage/backpack/duffel/security


/datum/job/judge
	title = "Magistrate"
	flag = JUDGE
	department_flag = KARMA
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Nanotrasen Supreme Court"
	selection_color = "#ddddff"
	req_admin_notify = 1
	is_legal = 1
	minimal_player_age = 30
	access = list(access_security, access_sec_doors, access_brig, access_court, access_forensics_lockers,
			            access_medical, access_engine, access_change_ids, access_eva, access_heads,
			            access_all_personal_lockers, access_maint_tunnels, access_bar, access_janitor, access_construction, access_morgue,
			            access_crematorium, access_kitchen, access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
			            access_theatre, access_chapel_office, access_library, access_research, access_mining, access_heads_vault, access_mining_station,
			            access_clown, access_mime, access_hop, access_RC_announce, access_keycard_auth, access_gateway, access_magistrate)
	minimal_access = list(access_security, access_sec_doors, access_brig, access_court, access_maint_tunnels, access_lawyer, access_magistrate, access_heads)

	outfit = /datum/outfit/job/judge

/datum/outfit/job/judge
	name = "Magistrate"
	jobtype = /datum/job/judge

	uniform = /obj/item/clothing/under/suit_jacket/really_black
	suit = /obj/item/clothing/suit/judgerobe
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	head = /obj/item/clothing/head/powdered_wig
	l_ear = /obj/item/device/radio/headset/heads/magistrate/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/weapon/card/id/nanotrasen
	l_pocket = /obj/item/device/flash
	pda = /obj/item/device/pda/heads/magistrate
	backpack_contents = list(
		/obj/item/weapon/melee/classic_baton/telescopic = 1
	)

	implants = list(/obj/item/weapon/implant/mindshield)

	satchel = /obj/item/weapon/storage/backpack/satchel_sec
	dufflebag = /obj/item/weapon/storage/backpack/duffel/security



//var/global/lawyer = 0//Checks for another lawyer //This changed clothes on 2nd lawyer, both IA get the same dreds.
/datum/job/lawyer
	title = "Internal Affairs Agent"
	flag = LAWYER
	department_flag = SUPPORT
	total_positions = 2
	spawn_positions = 2
	is_legal = 1
	supervisors = "the magistrate"
	selection_color = "#ddddff"
	access = list(access_lawyer, access_court, access_sec_doors, access_maint_tunnels)
	minimal_access = list(access_lawyer, access_court, access_sec_doors, access_maint_tunnels)
	alt_titles = list("Lawyer","Public Defender")
	minimal_player_age = 30
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW
	outfit = /datum/outfit/job/lawyer

/datum/outfit/job/lawyer
	name = "Internal Affairs Agent"
	jobtype = /datum/job/lawyer

	uniform = /obj/item/clothing/under/rank/internalaffairs
	suit = /obj/item/clothing/suit/storage/internalaffairs
	shoes = /obj/item/clothing/shoes/brown
	l_ear = /obj/item/device/radio/headset/headset_sec/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/weapon/card/id/security
	l_pocket = /obj/item/device/laser_pointer
	r_pocket = /obj/item/device/flash
	l_hand = /obj/item/weapon/storage/briefcase
	pda = /obj/item/device/pda/lawyer

	implants = list(/obj/item/weapon/implant/mindshield)

	satchel = /obj/item/weapon/storage/backpack/satchel_sec
	dufflebag = /obj/item/weapon/storage/backpack/duffel/security
