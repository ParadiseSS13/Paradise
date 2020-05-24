GLOBAL_DATUM_INIT(captain_announcement, /datum/announcement/minor, new(do_newscast = 0)) // Why the hell are captain announcements minor
/datum/job/captain
	title = "Captain"
	flag = JOB_CAPTAIN
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	supervisors = "Nanotrasen officials"
	department_head = list("Nanotrasen Navy Officer")
	selection_color = "#ccccff"
	req_admin_notify = 1
	is_command = 1
	access = list() 			//See get_access()
	minimal_access = list() 	//See get_access()
	minimal_player_age = 30
	exp_requirements = 300
	exp_type = EXP_TYPE_COMMAND
	disabilities_allowed = 0
	outfit = /datum/outfit/job/captain

/datum/job/captain/get_access()
	return get_all_accesses()

/datum/job/captain/announce(mob/living/carbon/human/H)
	. = ..()
	GLOB.captain_announcement.Announce("All hands, Captain [H.real_name] on deck!")

/datum/outfit/job/captain
	name = "Captain"
	jobtype = /datum/job/captain
	uniform = /obj/item/clothing/under/rank/captain
	suit = /obj/item/clothing/suit/armor/vest/capcarapace
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/caphat
	l_ear = /obj/item/radio/headset/heads/captain/alt
	glasses = /obj/item/clothing/glasses/sunglasses
	id = /obj/item/card/id/gold
	pda = /obj/item/pda/captain
	backpack_contents = list(
		/obj/item/storage/box/ids = 1,
		/obj/item/melee/classic_baton/telescopic = 1
	)
	implants = list(/obj/item/implant/mindshield)
	backpack = /obj/item/storage/backpack/captain
	satchel = /obj/item/storage/backpack/satchel_cap
	dufflebag = /obj/item/storage/backpack/duffel/captain

/datum/outfit/job/captain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H && H.w_uniform)
		var/obj/item/clothing/under/U = H.w_uniform
		var/obj/item/clothing/accessory/medal/gold/captain/M = new /obj/item/clothing/accessory/medal/gold/captain(U)
		U.accessories += M
		M.on_attached(U)



/datum/job/hop
	title = "Head of Personnel"
	flag = JOB_HOP
	department_flag = JOBCAT_SUPPORT
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	department_head = list("Captain")
	selection_color = "#ddddff"
	req_admin_notify = 1
	is_command = 1
	minimal_player_age = 21
	exp_requirements = 300
	exp_type = EXP_TYPE_COMMAND
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
			            ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_CHANGE_IDS, ACCESS_AI_UPLOAD, ACCESS_EVA, ACCESS_HEADS,
			            ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
			            ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_LAWYER,
			            ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
			            ACCESS_CLOWN, ACCESS_MIME, ACCESS_HOP, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
			            ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_CHANGE_IDS, ACCESS_AI_UPLOAD, ACCESS_EVA, ACCESS_HEADS,
			            ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
			            ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_LAWYER,
			            ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
			            ACCESS_CLOWN, ACCESS_MIME, ACCESS_HOP, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM)
	outfit = /datum/outfit/job/hop

/datum/outfit/job/hop
	name = "Head of Personnel"
	jobtype = /datum/job/hop
	uniform = /obj/item/clothing/under/rank/head_of_personnel
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/hopcap
	l_ear = /obj/item/radio/headset/heads/hop
	id = /obj/item/card/id/silver
	pda = /obj/item/pda/heads/hop
	backpack_contents = list(
		/obj/item/storage/box/ids = 1,
		/obj/item/melee/classic_baton/telescopic = 1
	)

	implants = list()



/datum/job/nanotrasenrep
	title = "Nanotrasen Representative"
	flag = JOB_NANO
	department_flag = JOBCAT_KARMA
	total_positions = 1
	spawn_positions = 1
	supervisors = "the command staff"
	department_head = list("Captain")
	selection_color = "#ddddff"
	req_admin_notify = 1
	is_command = 1
	transfer_allowed = FALSE
	minimal_player_age = 21
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
			            ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_CHANGE_IDS, ACCESS_EVA, ACCESS_HEADS,
			            ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
			            ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_LAWYER,
			            ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
			            ACCESS_CLOWN, ACCESS_MIME, ACCESS_HOP, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_WEAPONS, ACCESS_NTREP)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
			            ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_EVA, ACCESS_HEADS,
			            ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
			            ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_LAWYER,
			            ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
			            ACCESS_CLOWN, ACCESS_MIME, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_WEAPONS, ACCESS_NTREP)
	outfit = /datum/outfit/job/nanotrasenrep

/datum/outfit/job/nanotrasenrep
	name = "Nanotrasen Representative"
	jobtype = /datum/job/nanotrasenrep
	uniform = /obj/item/clothing/under/rank/ntrep
	suit = /obj/item/clothing/suit/storage/ntrep
	shoes = /obj/item/clothing/shoes/centcom
	l_ear = /obj/item/radio/headset/heads/ntrep
	id = /obj/item/card/id/nanotrasen
	l_pocket = /obj/item/lighter/zippo/nt_rep
	pda = /obj/item/pda/heads/ntrep
	backpack_contents = list(
		/obj/item/melee/classic_baton/ntcane = 1
	)
	implants = list(/obj/item/implant/mindshield)



/datum/job/blueshield
	title = "Blueshield"
	flag = JOB_BLUESHIELD
	department_flag = JOBCAT_KARMA
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Nanotrasen representative"
	department_head = list("Captain")
	selection_color = "#ddddff"
	req_admin_notify = 1
	is_command = 1
	transfer_allowed = FALSE
	minimal_player_age = 21
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
			            ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_CHANGE_IDS, ACCESS_EVA, ACCESS_HEADS,
			            ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
			            ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_LAWYER,
			            ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
			            ACCESS_CLOWN, ACCESS_MIME, ACCESS_HOP, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_WEAPONS, ACCESS_BLUESHIELD)
	minimal_access = list(ACCESS_FORENSICS_LOCKERS, ACCESS_SEC_DOORS, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_ENGINE, ACCESS_MAINT_TUNNELS, ACCESS_RESEARCH,
			            ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_HEADS, ACCESS_BLUESHIELD, ACCESS_WEAPONS)
	outfit = /datum/outfit/job/blueshield

/datum/outfit/job/blueshield
	name = "Blueshield"
	jobtype = /datum/job/blueshield
	uniform = /obj/item/clothing/under/rank/blueshield
	suit = /obj/item/clothing/suit/armor/vest/blueshield
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/jackboots
	l_ear = /obj/item/radio/headset/heads/blueshield/alt
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	id = /obj/item/card/id/nanotrasen
	pda = /obj/item/pda/heads/blueshield
	backpack_contents = list(
		/obj/item/storage/box/deathimp = 1,
		/obj/item/gun/energy/gun/blueshield = 1
	)
	implants = list(/obj/item/implant/mindshield)
	backpack = /obj/item/storage/backpack/blueshield
	satchel = /obj/item/storage/backpack/satchel_blueshield
	dufflebag = /obj/item/storage/backpack/duffel/blueshield


/datum/job/judge
	title = "Magistrate"
	flag = JOB_JUDGE
	department_flag = JOBCAT_KARMA
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Nanotrasen Supreme Court"
	department_head = list("Captain")
	selection_color = "#ddddff"
	req_admin_notify = 1
	is_legal = 1
	transfer_allowed = FALSE
	minimal_player_age = 30
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
			            ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_CHANGE_IDS, ACCESS_EVA, ACCESS_HEADS,
			            ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
			            ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_LAWYER,
			            ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
			            ACCESS_CLOWN, ACCESS_MIME, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_MAGISTRATE)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_LAWYER, ACCESS_MAGISTRATE, ACCESS_HEADS)
	outfit = /datum/outfit/job/judge

/datum/outfit/job/judge
	name = "Magistrate"
	jobtype = /datum/job/judge
	uniform = /obj/item/clothing/under/suit_jacket/really_black
	suit = /obj/item/clothing/suit/judgerobe
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	head = /obj/item/clothing/head/powdered_wig
	l_ear = /obj/item/radio/headset/heads/magistrate/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/nanotrasen
	l_pocket = /obj/item/flash
	pda = /obj/item/pda/heads/magistrate
	backpack_contents = list(
		/obj/item/melee/classic_baton/telescopic = 1
	)
	implants = list(/obj/item/implant/mindshield)
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security



//GLOBAL_VAR_INIT(lawyer, 0) //Checks for another lawyer //This changed clothes on 2nd lawyer, both IA get the same dreds. | This was deprecated back in 2014, and its now 2020
/datum/job/lawyer
	title = "Internal Affairs Agent"
	flag = JOB_LAWYER
	department_flag = JOBCAT_SUPPORT
	total_positions = 2
	spawn_positions = 2
	is_legal = 1
	supervisors = "the magistrate"
	department_head = list("Captain")
	selection_color = "#ddddff"
	access = list(ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS, ACCESS_MAINT_TUNNELS, ACCESS_RESEARCH, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING)
	minimal_access = list(ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS, ACCESS_MAINT_TUNNELS, ACCESS_RESEARCH, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING)
	alt_titles = list("Human Resources Agent")
	minimal_player_age = 30
	exp_requirements = 600
	exp_type = EXP_TYPE_CREW
	outfit = /datum/outfit/job/lawyer

/datum/outfit/job/lawyer
	name = "Internal Affairs Agent"
	jobtype = /datum/job/lawyer
	uniform = /obj/item/clothing/under/rank/internalaffairs
	suit = /obj/item/clothing/suit/storage/internalaffairs
	shoes = /obj/item/clothing/shoes/brown
	l_ear = /obj/item/radio/headset/headset_sec/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/read_only
	id = /obj/item/card/id/security
	l_pocket = /obj/item/laser_pointer
	r_pocket = /obj/item/flash
	l_hand = /obj/item/storage/briefcase
	pda = /obj/item/pda/lawyer
	implants = list(/obj/item/implant/mindshield)
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security
