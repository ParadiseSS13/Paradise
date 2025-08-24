/datum/job/hos
	title = "Head of Security"
	flag = JOB_HOS
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_COMMAND | DEP_FLAG_SECURITY
	supervisors = "the captain"
	department_head = list("Captain")
	selection_color = "#ffdddd"
	req_admin_notify = 1
	department_account_access = TRUE
	access = list(
		ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_ARMORY,
		ACCESS_BRIG,
		ACCESS_CARGO_BAY,
		ACCESS_CARGO,
		ACCESS_CONSTRUCTION,
		ACCESS_COURT,
		ACCESS_ENGINE,
		ACCESS_EVA,
		ACCESS_EVIDENCE,
		ACCESS_EXPEDITION,
		ACCESS_FORENSICS_LOCKERS,
		ACCESS_HEADS,
		ACCESS_HOS,
		ACCESS_KEYCARD_AUTH,
		ACCESS_MAILSORTING,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MINING,
		ACCESS_MORGUE,
		ACCESS_RC_ANNOUNCE,
		ACCESS_RESEARCH,
		ACCESS_SEC_DOORS,
		ACCESS_SECURITY,
		ACCESS_SUPPLY_SHUTTLE,
		ACCESS_WEAPONS
	)
	minimal_player_age = 21
	exp_map = list(EXP_TYPE_SECURITY = 1200)
	blacklisted_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY, DISABILITY_FLAG_NERVOUS, DISABILITY_FLAG_LISP, DISABILITY_FLAG_PARAPLEGIC)
	missing_limbs_allowed = FALSE
	outfit = /datum/outfit/job/hos
	important_information = "This role requires you to coordinate a department. You are required to be familiar with Standard Operating Procedure (Security), Space Law, basic job duties, and act professionally (roleplay)."
	standard_paycheck = CREW_PAY_HIGH

/datum/outfit/job/hos
	name = "Head of Security"
	jobtype = /datum/job/hos

	uniform = /obj/item/clothing/under/rank/security/head_of_security
	suit = /obj/item/clothing/suit/armor/hos
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/hos
	l_ear = /obj/item/radio/headset/heads/hos/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/hos
	suit_store = /obj/item/gun/energy/gun
	pda = /obj/item/pda/heads/hos
	backpack_contents = list(
		/obj/item/restraints/handcuffs = 1,
		/obj/item/melee/classic_baton/telescopic = 1
	)

	bio_chips = list(/obj/item/bio_chip/mindshield)

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security

/datum/outfit/job/hos/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	add_verb(H, /mob/living/carbon/human/proc/sop_legal)
	add_verb(H, /mob/living/carbon/human/proc/space_law)

/datum/job/warden
	title = "Warden"
	flag = JOB_WARDEN
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_SECURITY
	supervisors = "the head of security"
	department_head = list("Head of Security")
	selection_color = "#ffeeee"
	access = list(
		ACCESS_ARMORY,
		ACCESS_BRIG,
		ACCESS_COURT,
		ACCESS_EVIDENCE,
		ACCESS_MAINT_TUNNELS,
		ACCESS_SEC_DOORS,
		ACCESS_SECURITY,
		ACCESS_WEAPONS
	)
	minimal_player_age = 21
	exp_map = list(EXP_TYPE_SECURITY = 600)
	blacklisted_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY, DISABILITY_FLAG_NERVOUS, DISABILITY_FLAG_LISP, DISABILITY_FLAG_PARAPLEGIC)
	missing_limbs_allowed = FALSE
	outfit = /datum/outfit/job/warden
	standard_paycheck = CREW_PAY_MEDIUM

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

	bio_chips = list(/obj/item/bio_chip/mindshield)

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security

/datum/outfit/job/warden/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	add_verb(H, /mob/living/carbon/human/proc/sop_legal)
	add_verb(H, /mob/living/carbon/human/proc/space_law)

/datum/job/detective
	title = "Detective"
	flag = JOB_DETECTIVE
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_SECURITY
	supervisors = "the head of security"
	department_head = list("Head of Security")
	selection_color = "#ffeeee"
	alt_titles = list("Forensic Technician")
	access = list(
		ACCESS_BRIG,
		ACCESS_COURT,
		ACCESS_EVIDENCE,
		ACCESS_FORENSICS_LOCKERS,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MORGUE,
		ACCESS_SEC_DOORS,
		ACCESS_SECURITY,
		ACCESS_WEAPONS
	)
	minimal_player_age = 14
	exp_map = list(EXP_TYPE_CREW = 600)
	blacklisted_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY, DISABILITY_FLAG_PARAPLEGIC)
	missing_limbs_allowed = FALSE
	outfit = /datum/outfit/job/detective
	important_information = "Track, investigate, and look cool while doing it."
	standard_paycheck = CREW_PAY_MEDIUM

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
	l_pocket = /obj/item/toy/crayon/white/chalk
	r_pocket = /obj/item/lighter/zippo
	pda = /obj/item/pda/detective
	backpack_contents = list(
		/obj/item/storage/box/evidence = 1,
		/obj/item/melee/classic_baton/telescopic = 1
	)

	bio_chips = list(/obj/item/bio_chip/mindshield)

/datum/outfit/job/detective/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_CORPSE_RESIST, JOB_TRAIT) // too cool to vomit
	add_verb(H, /mob/living/carbon/human/proc/sop_legal)
	add_verb(H, /mob/living/carbon/human/proc/space_law)

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
	job_department_flags = DEP_FLAG_SECURITY
	supervisors = "the head of security"
	department_head = list("Head of Security")
	selection_color = "#ffeeee"
	access = list(
		ACCESS_BRIG,
		ACCESS_COURT,
		ACCESS_EVIDENCE,
		ACCESS_MAINT_TUNNELS,
		ACCESS_SEC_DOORS,
		ACCESS_SECURITY,
		ACCESS_WEAPONS
	)
	minimal_player_age = 14
	exp_map = list(EXP_TYPE_CREW = 600)
	blacklisted_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY, DISABILITY_FLAG_PARAPLEGIC)
	missing_limbs_allowed = FALSE
	outfit = /datum/outfit/job/officer
	important_information = "Space Law is the law, not a suggestion."
	standard_paycheck = CREW_PAY_MEDIUM

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
	bio_chips = list(/obj/item/bio_chip/mindshield)
	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security

/datum/outfit/job/officer/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	add_verb(H, /mob/living/carbon/human/proc/sop_legal)
	add_verb(H, /mob/living/carbon/human/proc/space_law)
