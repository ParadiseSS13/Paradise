/datum/job/rd
	title = "Research Director"
	flag = JOB_RD
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	is_science = 1
	supervisors = "the captain"
	department_head = list("Captain")
	selection_color = "#ffddff"
	req_admin_notify = 1
	department_account_access = TRUE
	access = list(ACCESS_RD, ACCESS_HEADS, ACCESS_TOX, ACCESS_GENETICS, ACCESS_MORGUE,
					ACCESS_TOX_STORAGE, ACCESS_TECH_STORAGE, ACCESS_TELEPORTER, ACCESS_SEC_DOORS,
					ACCESS_RESEARCH, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY, ACCESS_AI_UPLOAD,
					ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_EXPEDITION, ACCESS_XENOARCH, ACCESS_MINISAT, ACCESS_MINERAL_STOREROOM, ACCESS_NETWORK)
	minimal_access = list(ACCESS_EVA, ACCESS_RD, ACCESS_HEADS, ACCESS_TOX, ACCESS_GENETICS, ACCESS_MORGUE,
					ACCESS_TOX_STORAGE, ACCESS_TECH_STORAGE, ACCESS_TELEPORTER, ACCESS_SEC_DOORS,
					ACCESS_RESEARCH, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY, ACCESS_AI_UPLOAD,
					ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_EXPEDITION, ACCESS_XENOARCH, ACCESS_MINISAT, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM, ACCESS_NETWORK)
	minimal_player_age = 21
	blacklisted_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY)
	exp_map = list(EXP_TYPE_SCIENCE = 1200)
	// All science-y guys get bonuses for maxing out their tech.
	required_objectives = list(
		/datum/job_objective/further_research
	)

	outfit = /datum/outfit/job/rd
	important_information = "This role requires you to coordinate a department. You are required to be familiar with Standard Operating Procedure (Science), basic job duties, and act professionally (roleplay)."

/datum/outfit/job/rd
	name = "Research Director"
	jobtype = /datum/job/rd

	uniform = /obj/item/clothing/under/rank/rnd/research_director
	suit = /obj/item/clothing/suit/storage/labcoat/rd
	shoes = /obj/item/clothing/shoes/brown
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


/datum/job/scientist
	title = "Scientist"
	flag = JOB_SCIENTIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 6
	spawn_positions = 6
	is_science = 1
	supervisors = "the research director"
	department_head = list("Research Director")
	selection_color = "#ffeeff"
	access = list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_XENOARCH, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_XENOARCH, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM)
	alt_titles = list("Xenoarcheologist", "Anomalist", "Plasma Researcher", "Xenobiologist", "Chemical Researcher")
	minimal_player_age = 3
	exp_map = list(EXP_TYPE_CREW = 300)
	// All science-y guys get bonuses for maxing out their tech.
	required_objectives = list(
		/datum/job_objective/further_research
	)

	outfit = /datum/outfit/job/scientist

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


/datum/job/roboticist
	title = "Roboticist"
	flag = JOB_ROBOTICIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 2
	spawn_positions = 2
	is_science = 1
	supervisors = "the research director"
	department_head = list("Research Director")
	selection_color = "#ffeeff"
	access = list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_TECH_STORAGE, ACCESS_MORGUE, ACCESS_RESEARCH, ACCESS_MINERAL_STOREROOM) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	minimal_access = list(ACCESS_ROBOTICS, ACCESS_TECH_STORAGE, ACCESS_MORGUE, ACCESS_RESEARCH, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	alt_titles = list("Biomechanical Engineer","Mechatronic Engineer")
	minimal_player_age = 3
	exp_map = list(EXP_TYPE_CREW = 180)

	required_objectives = list(
		/datum/job_objective/make_cyborg,
		/datum/job_objective/make_ripley
	)

	outfit = /datum/outfit/job/roboticist

/datum/outfit/job/roboticist
	name = "Roboticist"
	jobtype = /datum/job/roboticist

	uniform = /obj/item/clothing/under/rank/rnd/roboticist
	suit = /obj/item/clothing/suit/storage/labcoat/robowhite
	belt = /obj/item/storage/belt/utility/full
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/radio/headset/headset_sci
	id = /obj/item/card/id/roboticist
	pda = /obj/item/pda/roboticist
