/datum/job/rd
	title = "Research Director"
	flag = JOB_RD
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_COMMAND | DEP_FLAG_SCIENCE
	supervisors = "the captain"
	department_head = list("Captain")
	selection_color = "#ffddff"
	req_admin_notify = 1
	department_account_access = TRUE
	access = list(
		ACCESS_AI_UPLOAD,
		ACCESS_EVA,
		ACCESS_EXPEDITION,
		ACCESS_GENETICS,
		ACCESS_HEADS,
		ACCESS_KEYCARD_AUTH,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINISAT,
		ACCESS_MORGUE,
		ACCESS_RC_ANNOUNCE,
		ACCESS_RD,
		ACCESS_RESEARCH,
		ACCESS_ROBOTICS,
		ACCESS_SEC_DOORS,
		ACCESS_TCOMSAT,
		ACCESS_TECH_STORAGE,
		ACCESS_TELEPORTER,
		ACCESS_TOX_STORAGE,
		ACCESS_TOX,
		ACCESS_XENOBIOLOGY,
		ACCESS_WEAPONS
	)
	minimal_player_age = 21
	blacklisted_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY)
	exp_map = list(EXP_TYPE_SCIENCE = 1200)
	// All science-y guys get bonuses for maxing out their tech.
	required_objectives = list(
		/datum/job_objective/further_research
	)

	outfit = /datum/outfit/job/rd
	important_information = "This role requires you to coordinate a department. You are required to be familiar with Standard Operating Procedure (Science), basic job duties, and act professionally (roleplay)."
	standard_paycheck = CREW_PAY_HIGH

/datum/outfit/job/rd
	name = "Research Director"
	jobtype = /datum/job/rd

	uniform = /obj/item/clothing/under/rank/rnd/rd
	suit = /obj/item/clothing/suit/storage/labcoat/rd
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/rd
	l_ear = /obj/item/radio/headset/heads/rd
	id = /obj/item/card/id/rd
	l_hand = /obj/item/clipboard
	pda = /obj/item/pda/heads/rd
	backpack_contents = list(
		/obj/item/melee/classic_baton/telescopic = 1
	)

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel_tox
	dufflebag = /obj/item/storage/backpack/duffel/science

/datum/outfit/job/rd/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_CRAFTY, JOB_TRAIT)

/datum/job/scientist
	title = "Scientist"
	flag = JOB_SCIENTIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 6
	spawn_positions = 6
	job_department_flags = DEP_FLAG_SCIENCE
	supervisors = "the research director"
	department_head = list("Research Director")
	selection_color = "#ffeeff"
	access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_RESEARCH,
		ACCESS_TOX_STORAGE,
		ACCESS_TOX,
	)
	alt_titles = list("Anomalist", "Plasma Researcher", "Chemical Researcher")
	minimal_player_age = 3
	exp_map = list(EXP_TYPE_CREW = 300)
	// All science-y guys get bonuses for maxing out their tech.
	required_objectives = list(
		/datum/job_objective/further_research
	)

	outfit = /datum/outfit/job/scientist
	standard_paycheck = CREW_PAY_MEDIUM

/datum/outfit/job/scientist
	name = "Scientist"
	jobtype = /datum/job/scientist

	uniform = /obj/item/clothing/under/rank/rnd/scientist
	suit = /obj/item/clothing/suit/storage/labcoat/science
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_sci
	id = /obj/item/card/id/research
	pda = /obj/item/pda/toxins

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel_tox
	dufflebag = /obj/item/storage/backpack/duffel/science

/datum/outfit/job/scientist/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_CRAFTY, JOB_TRAIT)

/datum/job/xenobiologist
	title = "Xenobiologist"
	flag = JOB_XENOBIOLOGIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 2
	spawn_positions = 2
	job_department_flags = DEP_FLAG_SCIENCE
	supervisors = "the research director"
	department_head = list("Research Director")
	selection_color = "#ffeeff"
	access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_RESEARCH,
		ACCESS_XENOBIOLOGY,
		ACCESS_EVA,
		ACCESS_MINING,
		ACCESS_MINING_STATION,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_TELEPORTER,
	)
	alt_titles = list("Xenoarcheologist", "Slime Cultivator", "Slime Rancher")
	minimal_player_age = 3
	exp_map = list(EXP_TYPE_CREW = 300)
	// All science-y guys get bonuses for maxing out their tech.
	required_objectives = list(
		/datum/job_objective/scan_organs,
	)

	outfit = /datum/outfit/job/xenobiologist
	standard_paycheck = CREW_PAY_MEDIUM

/datum/outfit/job/xenobiologist
	name = "Xenobiologist"
	jobtype = /datum/job/xenobiologist

	uniform = /obj/item/clothing/under/rank/rnd/scientist
	r_pocket = /obj/item/storage/bag/bio
	suit = /obj/item/clothing/suit/storage/labcoat/science
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	glasses = /obj/item/clothing/glasses/science
	l_ear = /obj/item/radio/headset/headset_sci
	id = /obj/item/card/id/xenobiology
	pda = /obj/item/pda/toxins

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel_tox
	dufflebag = /obj/item/storage/backpack/duffel/science

	backpack_contents = list(
		/obj/item/healthanalyzer = 1,
		/obj/item/storage/box/bodybags = 1,
		/obj/item/clipboard = 1,
	)

/datum/job/roboticist
	title = "Roboticist"
	flag = JOB_ROBOTICIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 2
	spawn_positions = 2
	job_department_flags = DEP_FLAG_SCIENCE
	supervisors = "the research director"
	department_head = list("Research Director")
	selection_color = "#ffeeff"
	access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE, // As a job that handles so many corpses, it makes sense for them to have morgue access.
		ACCESS_RESEARCH,
		ACCESS_ROBOTICS,
		ACCESS_TECH_STORAGE
	)
	alt_titles = list("Biomechanical Engineer","Mechatronic Engineer")
	minimal_player_age = 3
	exp_map = list(EXP_TYPE_CREW = 180)

	required_objectives = list(
		/datum/job_objective/make_cyborg,
		/datum/job_objective/make_ripley
	)

	outfit = /datum/outfit/job/roboticist
	standard_paycheck = CREW_PAY_MEDIUM

/datum/outfit/job/roboticist
	name = "Roboticist"
	jobtype = /datum/job/roboticist

	uniform = /obj/item/clothing/under/rank/rnd/roboticist
	suit = /obj/item/clothing/suit/storage/labcoat/robowhite
	belt = /obj/item/storage/belt/utility/full
	l_ear = /obj/item/radio/headset/headset_sci
	id = /obj/item/card/id/roboticist
	pda = /obj/item/pda/roboticist

	backpack = /obj/item/storage/backpack/robotics
	satchel = /obj/item/storage/backpack/satchel_robo
	dufflebag = /obj/item/storage/backpack/duffel/robotics

/datum/outfit/job/roboticist/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_CYBORG_SPECIALIST, JOB_TRAIT)

/datum/job/geneticist
	title = "Geneticist"
	flag = JOB_GENETICIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 2
	spawn_positions = 2
	job_department_flags = DEP_FLAG_SCIENCE
	supervisors = "the research director"
	department_head = list("Research Director")
	selection_color = "#ffeeff"
	access = list(
		ACCESS_GENETICS,
		ACCESS_MAINT_TUNNELS,
		ACCESS_RESEARCH
	)
	minimal_player_age = 3
	exp_map = list(EXP_TYPE_CREW = 180)
	outfit = /datum/outfit/job/geneticist
	standard_paycheck = CREW_PAY_MEDIUM

/datum/outfit/job/geneticist
	name = "Geneticist"
	jobtype = /datum/job/geneticist

	uniform = /obj/item/clothing/under/rank/rnd/geneticist
	suit = /obj/item/clothing/suit/storage/labcoat/genetics
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_sci
	id = /obj/item/card/id/geneticist
	suit_store = /obj/item/flashlight/pen
	pda = /obj/item/pda/geneticist

	backpack = /obj/item/storage/backpack/genetics
	satchel = /obj/item/storage/backpack/satchel_gen
	dufflebag = /obj/item/storage/backpack/duffel/genetics

/datum/outfit/job/geneticist/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_GENETIC_BUDGET, JOB_TRAIT)
