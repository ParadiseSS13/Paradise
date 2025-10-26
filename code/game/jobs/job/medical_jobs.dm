/datum/job/cmo
	title = "Chief Medical Officer"
	flag = JOB_CMO
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_COMMAND | DEP_FLAG_MEDICAL
	supervisors = "the captain"
	department_head = list("Captain")
	selection_color = "#b8ebfa"
	req_admin_notify = 1
	department_account_access = TRUE
	access = list(
		ACCESS_CHEMISTRY,
		ACCESS_CMO,
		ACCESS_EVA,
		ACCESS_HEADS,
		ACCESS_KEYCARD_AUTH,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_PARAMEDIC,
		ACCESS_PSYCHIATRIST,
		ACCESS_RC_ANNOUNCE,
		ACCESS_SEC_DOORS,
		ACCESS_SURGERY,
		ACCESS_VIROLOGY,
		ACCESS_WEAPONS
	)
	minimal_player_age = 21
	exp_map = list(EXP_TYPE_MEDICAL = 1200)
	blacklisted_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY)
	outfit = /datum/outfit/job/cmo
	important_information = "This role requires you to coordinate a department. You are required to be familiar with Standard Operating Procedure (Medical), basic job duties, and act professionally (roleplay)."
	standard_paycheck = CREW_PAY_HIGH

/datum/outfit/job/cmo
	name = "Chief Medical Officer"
	jobtype = /datum/job/cmo

	uniform = /obj/item/clothing/under/rank/medical/cmo
	suit = /obj/item/clothing/suit/storage/labcoat/cmo
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/cmo
	l_ear = /obj/item/radio/headset/heads/cmo
	id = /obj/item/card/id/cmo
	suit_store = /obj/item/flashlight/pen
	l_hand = /obj/item/storage/firstaid/regular/doctor
	pda = /obj/item/pda/heads/cmo
	backpack_contents = list(
		/obj/item/melee/classic_baton/telescopic = 1
	)

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical

/datum/outfit/job/cmo/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_MED_EXAMINE, JOB_TRAIT)

/datum/job/doctor
	title = "Medical Doctor"
	flag = JOB_DOCTOR
	department_flag = JOBCAT_MEDSCI
	total_positions = 5
	spawn_positions = 3
	job_department_flags = DEP_FLAG_MEDICAL
	supervisors = "the chief medical officer"
	department_head = list("Chief Medical Officer")
	selection_color = "#cbf7ff"
	access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MORGUE,
		ACCESS_SURGERY
	)
	alt_titles = list("Surgeon","Nurse")
	minimal_player_age = 3
	exp_map = list(EXP_TYPE_CREW = 180)
	outfit = /datum/outfit/job/doctor
	standard_paycheck = CREW_PAY_MEDIUM

/datum/outfit/job/doctor
	name = "Medical Doctor"
	jobtype = /datum/job/doctor

	uniform = /obj/item/clothing/under/rank/medical/doctor
	suit = /obj/item/clothing/suit/storage/labcoat/medical
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/medical
	suit_store = /obj/item/flashlight/pen
	l_hand = /obj/item/storage/firstaid/regular/doctor
	pda = /obj/item/pda/medical

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical

/datum/outfit/job/doctor/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_MED_EXAMINE, JOB_TRAIT)

/datum/job/coroner
	title = "Coroner"
	flag = JOB_CORONER
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_MEDICAL
	supervisors = "the chief medical officer"
	department_head = list("Chief Medical Officer")
	selection_color = "#cbf7ff"
	access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MORGUE
	)
	minimal_player_age = 3
	exp_map = list(EXP_TYPE_CREW = 180)
	outfit = /datum/outfit/job/coroner
	standard_paycheck = CREW_PAY_MEDIUM

/datum/outfit/job/coroner
	name = "Coroner"
	jobtype = /datum/job/coroner

	uniform = /obj/item/clothing/under/rank/medical/scrubs/coroner
	suit = /obj/item/clothing/suit/storage/labcoat/mortician
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/coroner
	suit_store = /obj/item/flashlight/pen
	l_hand = /obj/item/clipboard
	pda = /obj/item/pda/medical

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical

	backpack_contents = list(
					/obj/item/clothing/head/surgery/black = 1,
					/obj/item/autopsy_scanner = 1,
					/obj/item/reagent_scanner = 1,
					/obj/item/healthanalyzer = 1,
					/obj/item/storage/box/bodybags = 1)

/datum/outfit/job/coroner/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_CORPSE_RESIST, JOB_TRAIT)

/datum/outfit/job/doctor/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Surgeon")
				uniform = /obj/item/clothing/under/rank/medical/scrubs
				head = /obj/item/clothing/head/surgery/blue
			if("Medical Doctor")
				uniform = /obj/item/clothing/under/rank/medical/doctor
			if("Nurse")
				if(H.gender == FEMALE)
					if(prob(50))
						uniform = /obj/item/clothing/under/rank/medical/nursesuit
					else
						uniform = /obj/item/clothing/under/rank/medical/nurse
					head = /obj/item/clothing/head/nursehat
				else
					uniform = /obj/item/clothing/under/rank/medical/scrubs/purple

//Chemist is a medical job damnit	//YEAH FUCK YOU SCIENCE	-Pete	//Guys, behave -Erro
/datum/job/chemist
	title = "Chemist"
	flag = JOB_CHEMIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 2
	spawn_positions = 2
	job_department_flags = DEP_FLAG_MEDICAL
	supervisors = "the chief medical officer"
	department_head = list("Chief Medical Officer")
	selection_color = "#cbf7ff"
	access = list(
		ACCESS_CHEMISTRY,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM
	)
	alt_titles = list("Pharmacist","Pharmacologist")
	minimal_player_age = 7
	exp_map = list(EXP_TYPE_CREW = 300)
	outfit = /datum/outfit/job/chemist
	standard_paycheck = CREW_PAY_MEDIUM

/datum/outfit/job/chemist
	name = "Chemist"
	jobtype = /datum/job/chemist

	uniform = /obj/item/clothing/under/rank/medical/chemist
	r_pocket = /obj/item/storage/bag/chemistry
	suit = /obj/item/clothing/suit/storage/labcoat/chemist
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_med
	glasses = /obj/item/clothing/glasses/science
	id = /obj/item/card/id/chemist
	pda = /obj/item/pda/chemist

	backpack = /obj/item/storage/backpack/chemistry
	satchel = /obj/item/storage/backpack/satchel_chem
	dufflebag = /obj/item/storage/backpack/duffel/chemistry

/datum/outfit/job/chemist/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_QUICK_HEATER, JOB_TRAIT)

/datum/job/virologist
	title = "Virologist"
	flag = JOB_VIROLOGIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_MEDICAL
	supervisors = "the chief medical officer"
	department_head = list("Chief Medical Officer")
	selection_color = "#cbf7ff"
	access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_VIROLOGY
	)
	alt_titles = list("Pathologist","Microbiologist")
	minimal_player_age = 7
	exp_map = list(EXP_TYPE_CREW = 300)
	required_objectives = list(
		/datum/job_objective/virus_samples
	)
	outfit = /datum/outfit/job/virologist
	standard_paycheck = CREW_PAY_MEDIUM


/datum/outfit/job/virologist
	name = "Virologist"
	jobtype = /datum/job/virologist

	uniform = /obj/item/clothing/under/rank/medical/virologist
	r_pocket = /obj/item/storage/bag/bio
	suit = /obj/item/clothing/suit/storage/labcoat/virologist
	shoes = /obj/item/clothing/shoes/white
	mask = /obj/item/clothing/mask/surgical
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/virologist
	suit_store = /obj/item/flashlight/pen
	pda = /obj/item/pda/viro

	backpack = /obj/item/storage/backpack/virology
	satchel = /obj/item/storage/backpack/satchel_vir
	dufflebag = /obj/item/storage/backpack/duffel/virology

/datum/outfit/job/virologist/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_GERMOPHOBE, JOB_TRAIT)

/datum/job/psychiatrist
	title = "Psychiatrist"
	flag = JOB_PSYCHIATRIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_MEDICAL
	supervisors = "the chief medical officer"
	department_head = list("Chief Medical Officer")
	selection_color = "#cbf7ff"
	access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_PSYCHIATRIST
	)
	alt_titles = list("Psychologist","Therapist")
	outfit = /datum/outfit/job/psychiatrist
	standard_paycheck = CREW_PAY_MEDIUM

/datum/outfit/job/psychiatrist
	name = "Psychiatrist"
	jobtype = /datum/job/psychiatrist

	uniform = /obj/item/clothing/under/rank/medical/doctor
	suit = /obj/item/clothing/suit/storage/labcoat/psych
	shoes = /obj/item/clothing/shoes/laceup
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/psychiatrist
	suit_store = /obj/item/flashlight/pen
	pda = /obj/item/pda/medical

/datum/outfit/job/psychiatrist/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Psychiatrist")
				uniform = /obj/item/clothing/under/rank/medical/psych
			if("Psychologist")
				uniform = /obj/item/clothing/under/rank/medical/psych/turtleneck
			if("Therapist")
				uniform = /obj/item/clothing/under/rank/medical/doctor

/datum/job/paramedic
	title = "Paramedic"
	flag = JOB_PARAMEDIC
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_MEDICAL
	supervisors = "the chief medical officer"
	department_head = list("Chief Medical Officer")
	selection_color = "#cbf7ff"
	access = list(
		ACCESS_CARGO,
		ACCESS_EVA,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_MAILSORTING,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING_STATION,
		ACCESS_MINING,
		ACCESS_MORGUE,
		ACCESS_PARAMEDIC,
		ACCESS_TELEPORTER
	)
	minimal_player_age = 3
	exp_map = list(EXP_TYPE_CREW = 180)
	outfit = /datum/outfit/job/paramedic
	important_information = "You are the first responder to medical emergencies outside the sanctity of the Medbay. You can also respond to Lavaland emergencies via the mining shuttle located in Cargo, or space emergencies via the Teleporter near the Bridge."
	standard_paycheck = CREW_PAY_MEDIUM

/datum/outfit/job/paramedic
	name = "Paramedic"
	jobtype = /datum/job/paramedic

	uniform = /obj/item/clothing/under/rank/medical/paramedic
	head = /obj/item/clothing/head/soft/paramedic
	mask = /obj/item/clothing/mask/cigarette
	l_ear = /obj/item/radio/headset/headset_med/para
	id = /obj/item/card/id/paramedic
	l_pocket = /obj/item/flashlight/pen
	pda = /obj/item/pda/medical
	backpack_contents = list(
		/obj/item/healthanalyzer = 1,
		/obj/item/sensor_device = 1,
		/obj/item/pinpointer/crew = 1)

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical
	box = /obj/item/storage/box/engineer

/datum/outfit/job/paramedic/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_SPEED_DEMON, JOB_TRAIT)
