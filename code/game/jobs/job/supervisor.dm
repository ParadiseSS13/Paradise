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
	job_department_flags = DEP_FLAG_COMMAND
	department_account_access = TRUE
	access = list() 	//See get_access()
	minimal_player_age = 30
	exp_map = list(EXP_TYPE_COMMAND = 1200)
	blacklisted_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY, DISABILITY_FLAG_NERVOUS, DISABILITY_FLAG_LISP)
	outfit = /datum/outfit/job/captain
	important_information = "This role requires you to coordinate a department. You are required to be familiar with Standard Operating Procedure (Command), basic job duties, and act professionally (roleplay)."

/datum/job/captain/get_access()
	return get_all_accesses()

/datum/job/captain/announce(mob/living/carbon/human/H)
	. = ..()
	// Why the hell are captain announcements minor
	GLOB.minor_announcement.Announce("All hands, Captain [H.real_name] on deck!")

/datum/outfit/job/captain
	name = "Captain"
	jobtype = /datum/job/captain
	uniform = /obj/item/clothing/under/rank/captain
	suit = /obj/item/clothing/suit/armor/vest/capcarapace
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/caphat
	l_ear = /obj/item/radio/headset/heads/captain/alt
	glasses = /obj/item/clothing/glasses/hud/skills/sunglasses
	id = /obj/item/card/id/captains_spare/assigned
	pda = /obj/item/pda/captain
	backpack_contents = list(
		/obj/item/storage/box/ids = 1,
		/obj/item/melee/classic_baton/telescopic = 1
	)
	bio_chips = list(/obj/item/bio_chip/mindshield)
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
	job_department_flags = DEP_FLAG_COMMAND
	minimal_player_age = 21
	department_account_access = TRUE
	exp_map = list(EXP_TYPE_SERVICE = 1200)
	access = list(
		ACCESS_AI_UPLOAD,
		ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_BAR,
		ACCESS_BRIG,
		ACCESS_CARGO,
		ACCESS_CHANGE_IDS,
		ACCESS_CHAPEL_OFFICE,
		ACCESS_CLOWN,
		ACCESS_CONSTRUCTION,
		ACCESS_COURT,
		ACCESS_CREMATORIUM,
		ACCESS_ENGINE,
		ACCESS_EVA,
		ACCESS_EXPEDITION,
		ACCESS_HEADS_VAULT,
		ACCESS_HEADS,
		ACCESS_HOP,
		ACCESS_HYDROPONICS,
		ACCESS_JANITOR,
		ACCESS_KEYCARD_AUTH,
		ACCESS_KITCHEN,
		ACCESS_INTERNAL_AFFAIRS,
		ACCESS_LIBRARY,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MIME,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_RC_ANNOUNCE,
		ACCESS_RESEARCH,
		ACCESS_SEC_DOORS,
		ACCESS_SECURITY,
		ACCESS_THEATRE,
		ACCESS_WEAPONS
	)
	blacklisted_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY , DISABILITY_FLAG_NERVOUS, DISABILITY_FLAG_LISP)
	outfit = /datum/outfit/job/hop
	important_information = "This role requires you to coordinate a department. You are required to be familiar with Standard Operating Procedure (Service), basic job duties, and act professionally (roleplay)."

/datum/outfit/job/hop
	name = "Head of Personnel"
	jobtype = /datum/job/hop
	uniform = /obj/item/clothing/under/rank/civilian/hop
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/hop
	glasses = /obj/item/clothing/glasses/hud/skills/sunglasses
	l_ear = /obj/item/radio/headset/heads/hop
	id = /obj/item/card/id/hop
	pda = /obj/item/pda/heads/hop
	backpack_contents = list(
		/obj/item/storage/box/ids = 1,
		/obj/item/melee/classic_baton/telescopic = 1
	)

	bio_chips = list()



/datum/job/nanotrasenrep
	title = "Nanotrasen Representative"
	flag = JOB_NANO
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	supervisors = "the command staff"
	department_head = list("Captain")
	selection_color = "#ddddff"
	req_admin_notify = TRUE
	job_department_flags = DEP_FLAG_COMMAND
	transfer_allowed = FALSE
	minimal_player_age = 21
	exp_map = list(EXP_TYPE_COMMAND = 3000) // 50 hours baby
	access = list(
		ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_BAR,
		ACCESS_BRIG,
		ACCESS_CARGO_BAY,
		ACCESS_CARGO_BOT,
		ACCESS_CARGO,
		ACCESS_CHAPEL_OFFICE,
		ACCESS_CLOWN,
		ACCESS_CONSTRUCTION,
		ACCESS_COURT,
		ACCESS_CREMATORIUM,
		ACCESS_ENGINE,
		ACCESS_EVA,
		ACCESS_EXPEDITION,
		ACCESS_HEADS_VAULT,
		ACCESS_HEADS,
		ACCESS_HYDROPONICS,
		ACCESS_JANITOR,
		ACCESS_KEYCARD_AUTH,
		ACCESS_KITCHEN,
		ACCESS_INTERNAL_AFFAIRS,
		ACCESS_LIBRARY,
		ACCESS_MAILSORTING,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MIME,
		ACCESS_MINING_STATION,
		ACCESS_MINING,
		ACCESS_MORGUE,
		ACCESS_NTREP,
		ACCESS_RC_ANNOUNCE,
		ACCESS_RESEARCH,
		ACCESS_SEC_DOORS,
		ACCESS_SECURITY,
		ACCESS_SUPPLY_SHUTTLE,
		ACCESS_THEATRE,
		ACCESS_WEAPONS
	)
	blacklisted_disabilities = list(DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_NERVOUS, DISABILITY_FLAG_LISP)
	outfit = /datum/outfit/job/nanotrasenrep
	important_information = "This role requires you to advise the Command team about Standard Operating Procedure, Chain of Command, and report to Central Command about various matters. You are required to act in a manner befitting someone representing Nanotrasen."

/datum/outfit/job/nanotrasenrep
	name = "Nanotrasen Representative"
	jobtype = /datum/job/nanotrasenrep
	uniform = /obj/item/clothing/under/rank/procedure/representative
	suit = /obj/item/clothing/suit/storage/ntrep
	shoes = /obj/item/clothing/shoes/centcom
	glasses = /obj/item/clothing/glasses/hud/skills/sunglasses
	l_ear = /obj/item/radio/headset/heads/ntrep
	id = /obj/item/card/id/ntrep
	l_pocket = /obj/item/lighter/zippo/nt_rep
	pda = /obj/item/pda/heads/ntrep
	backpack_contents = list(
		/obj/item/melee/classic_baton/ntcane = 1
	)
	bio_chips = list(/obj/item/bio_chip/mindshield)



/datum/job/blueshield
	title = "Blueshield"
	flag = JOB_BLUESHIELD
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Nanotrasen representative"
	department_head = list("Captain")
	selection_color = "#ddddff"
	req_admin_notify = TRUE
	job_department_flags = DEP_FLAG_COMMAND
	transfer_allowed = FALSE
	minimal_player_age = 21
	exp_map = list(EXP_TYPE_COMMAND = 3000) // 50 hours baby
	access = list(
		ACCESS_BLUESHIELD,
		ACCESS_CARGO,
		ACCESS_CONSTRUCTION,
		ACCESS_ENGINE,
		ACCESS_HEADS,
		ACCESS_KEYCARD_AUTH,
		ACCESS_MAILSORTING,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MINING,
		ACCESS_RC_ANNOUNCE,
		ACCESS_RESEARCH,
		ACCESS_SEC_DOORS,
		ACCESS_WEAPONS
	)
	blacklisted_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY, DISABILITY_FLAG_NERVOUS, DISABILITY_FLAG_LISP)
	missing_limbs_allowed = FALSE
	outfit = /datum/outfit/job/blueshield
	important_information = "This role requires you to ensure the safety of the Heads of Staff, not the general crew. You may perform arrests only if the combatant is directly threatening a member of Command, the Nanotrasen Representative, or the Magistrate."

/datum/outfit/job/blueshield
	name = "Blueshield"
	jobtype = /datum/job/blueshield
	uniform = /obj/item/clothing/under/rank/procedure/blueshield
	suit = /obj/item/clothing/suit/armor/vest/blueshield
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/jackboots
	l_ear = /obj/item/radio/headset/heads/blueshield/alt
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	id = /obj/item/card/id/blueshield
	pda = /obj/item/pda/heads/blueshield
	backpack_contents = list(
		/obj/item/storage/box/deathimp = 1,
		/obj/item/gun/energy/gun/blueshield = 1
	)
	bio_chips = list(/obj/item/bio_chip/mindshield)
	backpack = /obj/item/storage/backpack/blueshield
	satchel = /obj/item/storage/backpack/satchel_blueshield
	dufflebag = /obj/item/storage/backpack/duffel/blueshield


/datum/job/judge
	title = "Magistrate"
	flag = JOB_JUDGE
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Nanotrasen Supreme Court"
	department_head = list("Captain")
	selection_color = "#ddddff"
	req_admin_notify = TRUE
	job_department_flags = DEP_FLAG_LEGAL
	transfer_allowed = FALSE
	minimal_player_age = 30
	exp_map = list(EXP_TYPE_SECURITY = 6000) // 100 hours baby
	access = list(
		ACCESS_BRIG,
		ACCESS_COURT,
		ACCESS_HEADS,
		ACCESS_INTERNAL_AFFAIRS,
		ACCESS_MAGISTRATE,
		ACCESS_MAINT_TUNNELS,
		ACCESS_RC_ANNOUNCE,
		ACCESS_SEC_DOORS,
		ACCESS_SECURITY,
		ACCESS_WEAPONS
	)
	blacklisted_disabilities = list(DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_NERVOUS, DISABILITY_FLAG_LISP)
	outfit = /datum/outfit/job/judge
	important_information = "This role requires you to oversee legal matters and make important decisions about sentencing. You are required to have an extensive knowledge of Space Law and Security SOP and only operate within, not outside, the boundaries of the law."

/datum/outfit/job/judge
	name = "Magistrate"
	jobtype = /datum/job/judge
	uniform = /obj/item/clothing/under/rank/procedure/magistrate
	suit = /obj/item/clothing/suit/magirobe
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	l_ear = /obj/item/radio/headset/heads/magistrate/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/magistrate
	l_pocket = /obj/item/flash
	r_pocket = /obj/item/clothing/accessory/legal_badge
	pda = /obj/item/pda/heads/magistrate
	backpack_contents = list(
		/obj/item/melee/classic_baton/telescopic = 1
	)
	bio_chips = list(/obj/item/bio_chip/mindshield)
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security


/datum/job/iaa
	title = "Internal Affairs Agent"
	flag = JOB_INTERNAL_AFFAIRS
	department_flag = JOBCAT_SUPPORT
	total_positions = 2
	spawn_positions = 2
	job_department_flags = DEP_FLAG_LEGAL
	supervisors = "the magistrate"
	department_head = list("Captain")
	selection_color = "#ddddff"
	access = list(
		ACCESS_CARGO,
		ACCESS_CONSTRUCTION,
		ACCESS_COURT,
		ACCESS_INTERNAL_AFFAIRS,
		ACCESS_MAILSORTING,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_RESEARCH,
		ACCESS_SEC_DOORS
	)
	alt_titles = list("Human Resources Agent")
	minimal_player_age = 30
	exp_map = list(EXP_TYPE_CREW = 600)
	blacklisted_disabilities = list(DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_NERVOUS, DISABILITY_FLAG_LISP)
	outfit = /datum/outfit/job/iaa
	important_information = "Your job is to deal with affairs regarding Standard Operating Procedure. You are NOT in charge of Space Law affairs, nor can you override it. You are NOT a prisoner defence lawyer."

/datum/outfit/job/iaa
	name = "Internal Affairs Agent"
	jobtype = /datum/job/iaa
	uniform = /obj/item/clothing/under/rank/procedure/iaa
	suit = /obj/item/clothing/suit/storage/iaa/blackjacket
	shoes = /obj/item/clothing/shoes/brown
	l_ear = /obj/item/radio/headset/headset_iaa/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/internalaffairsagent
	l_pocket = /obj/item/laser_pointer
	r_pocket = /obj/item/clothing/accessory/legal_badge/iaa
	l_hand = /obj/item/storage/briefcase
	pda = /obj/item/pda/iaa
	backpack_contents = list(
		/obj/item/flash = 1
	)
	bio_chips = list(/obj/item/bio_chip/mindshield)
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security
