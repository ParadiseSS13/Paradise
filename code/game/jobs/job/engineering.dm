/datum/job/chief_engineer
	title = "Chief Engineer"
	flag = JOB_CHIEF
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	is_engineering = 1
	supervisors = "the captain"
	department_head = list("Captain")
	selection_color = "#ffeeaa"
	req_admin_notify = 1
	access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS,
			            ACCESS_TELEPORTER, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ATMOSPHERICS, ACCESS_EMERGENCY_STORAGE, ACCESS_EVA,
			            ACCESS_HEADS, ACCESS_CONSTRUCTION, ACCESS_SEC_DOORS,
			            ACCESS_CE, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_MINISAT, ACCESS_MECHANIC, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS,
			            ACCESS_TELEPORTER, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ATMOSPHERICS, ACCESS_EMERGENCY_STORAGE, ACCESS_EVA,
			            ACCESS_HEADS, ACCESS_CONSTRUCTION, ACCESS_SEC_DOORS,
			            ACCESS_CE, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_MINISAT, ACCESS_MECHANIC, ACCESS_MINERAL_STOREROOM)
	minimal_player_age = 21
	min_age_allowed = 30
	exp_requirements = 3000
	exp_type = EXP_TYPE_ENGINEERING
	outfit = /datum/outfit/job/chief_engineer

/datum/outfit/job/chief_engineer
	name = "Chief Engineer"
	jobtype = /datum/job/chief_engineer

	uniform = /obj/item/clothing/under/rank/chief_engineer
	belt = /obj/item/storage/belt/utility/chief/full
	gloves = /obj/item/clothing/gloves/color/black/ce
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/hardhat/white
	l_ear = /obj/item/radio/headset/heads/ce
	id = /obj/item/card/id/ce
	l_pocket = /obj/item/lighter/zippo/ce
	r_pocket = /obj/item/t_scanner
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
	exp_requirements = 600
	exp_type = EXP_TYPE_ENGINEERING
	outfit = /datum/outfit/job/engineer

/datum/outfit/job/engineer
	name = "Station Engineer"
	jobtype = /datum/job/engineer

	uniform = /obj/item/clothing/under/rank/engineer
	suit = /obj/item/clothing/suit/storage/hazardvest
	belt = /obj/item/storage/belt/utility/full
	shoes = /obj/item/clothing/shoes/workboots
	head = /obj/item/clothing/head/hardhat/orange
	l_ear = /obj/item/radio/headset/headset_eng
	id = /obj/item/card/id/engineering
	l_pocket = /obj/item/t_scanner
	pda = /obj/item/pda/engineering

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel_eng
	dufflebag = /obj/item/storage/backpack/duffel/engineering
	box = /obj/item/storage/box/engineer


/datum/job/engineer/trainee
	title = "Trainee Engineer"
	flag = JOB_ENGINEER_TRAINEE
	total_positions = 5
	spawn_positions = 3
	department_head = list("Chief Engineer", "Station Engineer")
	selection_color = "#fff5cc"
	alt_titles = list("Engineer Assistant", "Technical Assistant", "Engineer Student", "Technical Student", "Technical Trainee")
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	exp_max	= 600
	exp_type_max = EXP_TYPE_ENGINEERING
	is_novice = TRUE
	outfit = /datum/outfit/job/engineer/trainee

/datum/outfit/job/engineer/trainee
	name = "Trainee Engineer"
	jobtype = /datum/job/engineer/trainee

	uniform = /obj/item/clothing/under/rank/engineer/trainee
	l_pocket = /obj/item/paper/deltainfo
	id = /obj/item/card/id/engineering/trainee
	gloves = /obj/item/clothing/gloves/color/orange

/datum/outfit/job/engineer/trainee/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/rank/engineer/trainee/skirt
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Engineer Assistant")
				uniform = /obj/item/clothing/under/rank/engineer/trainee/assistant
				if(H.gender == FEMALE)
					uniform = /obj/item/clothing/under/rank/engineer/trainee/assistant/skirt
			if("Technical Assistant")
				uniform = /obj/item/clothing/under/rank/engineer/trainee/assistant
				if(H.gender == FEMALE)
					uniform = /obj/item/clothing/under/rank/engineer/trainee/assistant/skirt
				head = /obj/item/clothing/head/soft/orange
			if("Technical Student", "Technical Trainee")
				head = /obj/item/clothing/head/soft/orange
			if("Engineer Student")
				head = /obj/item/clothing/head/beret/eng


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
	access = list(ACCESS_EVA, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS, ACCESS_MINERAL_STOREROOM, ACCESS_EMERGENCY_STORAGE)
	minimal_access = list(ACCESS_EVA, ACCESS_ATMOSPHERICS, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_EMERGENCY_STORAGE, ACCESS_CONSTRUCTION, ACCESS_MINERAL_STOREROOM, ACCESS_TECH_STORAGE)
	alt_titles = list("Atmospheric Technician")
	minimal_player_age = 7
	exp_requirements = 900
	exp_type = EXP_TYPE_ENGINEERING
	outfit = /datum/outfit/job/atmos

/datum/outfit/job/atmos
	name = "Life Support Specialist"
	jobtype = /datum/job/atmos

	uniform = /obj/item/clothing/under/rank/atmospheric_technician
	belt = /obj/item/storage/belt/utility/atmostech
	shoes = /obj/item/clothing/shoes/workboots
	l_ear = /obj/item/radio/headset/headset_eng
	id = /obj/item/card/id/engineering
	pda = /obj/item/pda/atmos

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel_eng
	dufflebag = /obj/item/storage/backpack/duffel/atmos
	box = /obj/item/storage/box/engineer


/datum/job/mechanic
	title = "Mechanic"
	flag = JOB_MECHANIC
	department_flag = JOBCAT_KARMA
	total_positions = 1
	spawn_positions = 1
	is_engineering = 1
	supervisors = "the chief engineer"
	department_head = list("Chief Engineer")
	selection_color = "#fff5cc"
	access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_MECHANIC, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MINERAL_STOREROOM, ACCESS_EMERGENCY_STORAGE)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_EMERGENCY_STORAGE, ACCESS_MECHANIC, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MINERAL_STOREROOM)
	exp_requirements = 900
	exp_type = EXP_TYPE_ENGINEERING
	outfit = /datum/outfit/job/mechanic

/datum/outfit/job/mechanic
	name = "Mechanic"
	jobtype = /datum/job/mechanic

	uniform = /obj/item/clothing/under/rank/mechanic
	belt = /obj/item/storage/belt/utility/full
	shoes = /obj/item/clothing/shoes/workboots
	head = /obj/item/clothing/head/hardhat
	l_ear = /obj/item/radio/headset/headset_eng
	id = /obj/item/card/id/engineering
	r_pocket = /obj/item/t_scanner
	pda = /obj/item/pda/engineering
	backpack_contents = list(
		/obj/item/pod_paint_bucket = 1
	)

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel_eng
	dufflebag = /obj/item/storage/backpack/duffel/engineering
	box = /obj/item/storage/box/engineer
