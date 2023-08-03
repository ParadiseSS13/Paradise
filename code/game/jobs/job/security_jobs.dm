/datum/job/hos
	title = "Head of Security"
	flag = JOB_HOS
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	is_security = 1
	supervisors = "the captain"
	department_head = list("Captain")
	selection_color = "#ffdddd"
	req_admin_notify = 1
	department_account_access = TRUE
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT,
						ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_ALL_PERSONAL_LOCKERS,
						ACCESS_RESEARCH, ACCESS_ENGINE, ACCESS_MINING, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING,
						ACCESS_HEADS, ACCESS_HOS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_EXPEDITION, ACCESS_WEAPONS)
	minimal_access = list(ACCESS_EVA, ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT,
						ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_ALL_PERSONAL_LOCKERS,
						ACCESS_RESEARCH, ACCESS_ENGINE, ACCESS_MINING, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING,
						ACCESS_HEADS, ACCESS_HOS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_EXPEDITION, ACCESS_WEAPONS)
	minimal_player_age = 21
	exp_map = list(EXP_TYPE_SECURITY = 1200)
	blacklisted_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY)
	missing_limbs_allowed = FALSE
	outfit = /datum/outfit/job/hos
	important_information = "This role requires you to coordinate a department. You are required to be familiar with Standard Operating Procedure (Security), Space Law, basic job duties, and act professionally (roleplay)."

/datum/outfit/job/hos
	name = "Head of Security"
	jobtype = /datum/job/hos

	uniform = /obj/item/clothing/under/rank/security/head_of_security
	suit = /obj/item/clothing/suit/armor/hos
	gloves = /obj/item/clothing/gloves/color/black/hos
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/HoS
	l_ear = /obj/item/radio/headset/heads/hos/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/hos
	suit_store = /obj/item/gun/energy/gun
	pda = /obj/item/pda/heads/hos
	backpack_contents = list(
		/obj/item/restraints/handcuffs = 1,
		/obj/item/melee/classic_baton/telescopic = 1
	)

	implants = list(/obj/item/implant/mindshield)

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security



/datum/job/warden
	title = "Warden"
	flag = JOB_WARDEN
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	is_security = 1
	supervisors = "the head of security"
	department_head = list("Head of Security")
	selection_color = "#ffeeee"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_WEAPONS)
	minimal_player_age = 21
	exp_map = list(EXP_TYPE_SECURITY = 600)
	blacklisted_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY)
	missing_limbs_allowed = FALSE
	outfit = /datum/outfit/job/warden

/datum/outfit/job/warden
	name = "Warden"
	jobtype = /datum/job/warden

	uniform = /obj/item/clothing/under/rank/security/warden
	suit = /obj/item/clothing/suit/armor/vest/warden/alt
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/warden
	l_ear = /obj/item/radio/headset/headset_sec/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/warden
	l_pocket = /obj/item/flash
	suit_store = /obj/item/gun/energy/disabler
	pda = /obj/item/pda/warden
	backpack_contents = list(
		/obj/item/restraints/handcuffs = 1
	)

	implants = list(/obj/item/implant/mindshield)

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security



/datum/job/detective
	title = "Detective"
	flag = JOB_DETECTIVE
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	is_security = 1
	supervisors = "the head of security"
	department_head = list("Head of Security")
	selection_color = "#ffeeee"
	alt_titles = list("Forensic Technician")
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_COURT, ACCESS_WEAPONS)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_COURT, ACCESS_WEAPONS)
	alt_titles = list("Forensic Technician")
	minimal_player_age = 14
	exp_map = list(EXP_TYPE_CREW = 600)
	blacklisted_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY)
	missing_limbs_allowed = FALSE
	outfit = /datum/outfit/job/detective
	important_information = "Track, investigate, and look cool while doing it."

/datum/outfit/job/detective
	name = "Detective"
	jobtype = /datum/job/detective

	uniform = /obj/item/clothing/under/rank/security/detective
	suit = /obj/item/clothing/suit/storage/det_suit
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/det_hat
	l_ear = /obj/item/radio/headset/headset_sec/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/detective
	l_pocket = /obj/item/toy/crayon/white
	r_pocket = /obj/item/lighter/zippo
	pda = /obj/item/pda/detective
	backpack_contents = list(
		/obj/item/storage/box/evidence = 1,
		/obj/item/detective_scanner = 1,
		/obj/item/melee/classic_baton/telescopic = 1
	)

	implants = list(/obj/item/implant/mindshield)

/datum/outfit/job/detective/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Forensic Technician")
				suit = /obj/item/clothing/suit/storage/det_suit/forensics/blue
				head = null

/datum/outfit/job/detective/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	H.dna.SetSEState(GLOB.soberblock, TRUE)
	H.check_mutations = 1

/datum/job/officer
	title = "Security Officer"
	flag = JOB_OFFICER
	department_flag = JOBCAT_ENGSEC
	total_positions = 7
	spawn_positions = 7
	is_security = 1
	supervisors = "the head of security"
	department_head = list("Head of Security")
	selection_color = "#ffeeee"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_WEAPONS)
	minimal_player_age = 14
	exp_map = list(EXP_TYPE_CREW = 600)
	blacklisted_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY)
	missing_limbs_allowed = FALSE
	outfit = /datum/outfit/job/officer
	important_information = "Space Law is the law, not a suggestion."

/datum/outfit/job/officer
	name = "Security Officer"
	jobtype = /datum/job/officer
	uniform = /obj/item/clothing/under/rank/security/officer
	suit = /obj/item/clothing/suit/armor/vest/security
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/helmet
	l_ear = /obj/item/radio/headset/headset_sec/alt
	id = /obj/item/card/id/security
	l_pocket = /obj/item/flash
	suit_store = /obj/item/gun/energy/disabler
	pda = /obj/item/pda/security
	backpack_contents = list(
		/obj/item/restraints/handcuffs = 1
	)
	implants = list(/obj/item/implant/mindshield)
	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security

