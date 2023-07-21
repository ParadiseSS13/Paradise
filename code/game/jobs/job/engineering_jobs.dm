/datum/job/chief_engineer
	title = "Chief Engineer"
	flag = JOB_CHIEF
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	is_engineering = TRUE
	supervisors = "the captain"
	department_head = list("Captain")
	selection_color = "#ffeeaa"
	req_admin_notify = 1
	department_account_access = TRUE
	access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS,
						ACCESS_TELEPORTER, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ATMOSPHERICS, ACCESS_EMERGENCY_STORAGE, ACCESS_EVA,
						ACCESS_HEADS, ACCESS_CONSTRUCTION, ACCESS_SEC_DOORS,
						ACCESS_CE, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_MINISAT, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS,
						ACCESS_TELEPORTER, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ATMOSPHERICS, ACCESS_EMERGENCY_STORAGE, ACCESS_EVA,
						ACCESS_HEADS, ACCESS_CONSTRUCTION, ACCESS_SEC_DOORS,
						ACCESS_CE, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_MINISAT, ACCESS_MINERAL_STOREROOM)
	minimal_player_age = 21
	exp_map = list(EXP_TYPE_ENGINEERING = 1200)
	blacklisted_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY)
	missing_limbs_allowed = FALSE
	outfit = /datum/outfit/job/chief_engineer
	important_information = "This role requires you to coordinate a department. You are required to be familiar with Standard Operating Procedure (Engineering), basic job duties, and act professionally (roleplay)."

/datum/outfit/job/chief_engineer
	name = "Chief Engineer"
	jobtype = /datum/job/chief_engineer

	uniform = /obj/item/clothing/under/rank/engineering/chief_engineer
	belt = /obj/item/storage/belt/utility/chief/full
	gloves = /obj/item/clothing/gloves/color/black/ce
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/hardhat/white
	l_ear = /obj/item/radio/headset/heads/ce
	id = /obj/item/card/id/ce
	l_pocket = /obj/item/t_scanner
	pda = /obj/item/pda/heads/ce
	backpack_contents = list(
		/obj/item/melee/classic_baton/telescopic = 1
	)

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel_eng
	dufflebag = /obj/item/storage/backpack/duffel/engineering
	box = /obj/item/storage/box/engineer


/datum/job/engineer
	title = "Station Engineer"
	flag = JOB_ENGINEER
	department_flag = JOBCAT_ENGSEC
	total_positions = 5
	spawn_positions = 5
	is_engineering = 1
	supervisors = "the chief engineer"
	department_head = list("Chief Engineer")
	selection_color = "#fff5cc"
	access = list(ACCESS_EVA, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_EVA, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_MINERAL_STOREROOM)
	alt_titles = list("Maintenance Technician","Engine Technician","Electrician")
	minimal_player_age = 7
	exp_map = list(EXP_TYPE_CREW = 300)
	outfit = /datum/outfit/job/engineer

/datum/outfit/job/engineer
	name = "Station Engineer"
	jobtype = /datum/job/engineer

	uniform = /obj/item/clothing/under/rank/engineering/engineer
	belt = /obj/item/storage/belt/utility/full
	shoes = /obj/item/clothing/shoes/workboots
	head = /obj/item/clothing/head/hardhat
	l_ear = /obj/item/radio/headset/headset_eng
	id = /obj/item/card/id/engineering
	l_pocket = /obj/item/t_scanner
	pda = /obj/item/pda/engineering

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel_eng
	dufflebag = /obj/item/storage/backpack/duffel/engineering
	box = /obj/item/storage/box/engineer



/datum/job/atmos
	title = "Life Support Specialist"
	flag = JOB_ATMOSTECH
	department_flag = JOBCAT_ENGSEC
	total_positions = 3
	spawn_positions = 2
	is_engineering = 1
	supervisors = "the chief engineer"
	department_head = list("Chief Engineer")
	selection_color = "#fff5cc"
	access = list(ACCESS_EVA, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_EVA, ACCESS_ATMOSPHERICS, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_EMERGENCY_STORAGE, ACCESS_CONSTRUCTION, ACCESS_MINERAL_STOREROOM, ACCESS_TECH_STORAGE)
	alt_titles = list("Atmospheric Technician")
	minimal_player_age = 7
	exp_map = list(EXP_TYPE_CREW = 300)
	outfit = /datum/outfit/job/atmos

/datum/outfit/job/atmos
	name = "Life Support Specialist"
	jobtype = /datum/job/atmos

	uniform = /obj/item/clothing/under/rank/engineering/atmospheric_technician
	belt = /obj/item/storage/belt/utility/atmostech
	shoes = /obj/item/clothing/shoes/workboots
	l_ear = /obj/item/radio/headset/headset_eng
	id = /obj/item/card/id/atmostech
	pda = /obj/item/pda/atmos

	backpack = /obj/item/storage/backpack/industrial/atmos
	satchel = /obj/item/storage/backpack/satchel_atmos
	dufflebag = /obj/item/storage/backpack/duffel/atmos
	box = /obj/item/storage/box/engineer

