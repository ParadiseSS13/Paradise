/datum/job/chief_engineer
	title = "Chief Engineer"
	flag = CHIEF
	department_flag = ENGSEC
	total_positions = 1
	spawn_positions = 1
	is_engineering = 1
	supervisors = "the captain"
	department_head = list("Captain")
	selection_color = "#ffeeaa"
	req_admin_notify = 1
	access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
			            access_teleporter, access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
			            access_heads, access_construction, access_sec_doors,
			            access_ce, access_RC_announce, access_keycard_auth, access_tcomsat, access_minisat, access_mechanic, access_mineral_storeroom)
	minimal_access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
			            access_teleporter, access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
			            access_heads, access_construction, access_sec_doors,
			            access_ce, access_RC_announce, access_keycard_auth, access_tcomsat, access_minisat, access_mechanic, access_mineral_storeroom)
	minimal_player_age = 21
	exp_requirements = 600
	exp_type = EXP_TYPE_CREW
	outfit = /datum/outfit/job/chief_engineer

/datum/outfit/job/chief_engineer
	name = "Chief Engineer"
	jobtype = /datum/job/chief_engineer

	uniform = /obj/item/clothing/under/rank/chief_engineer
	belt = /obj/item/weapon/storage/belt/utility/chief/full
	gloves = /obj/item/clothing/gloves/color/black/ce
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/hardhat/white
	l_ear = /obj/item/device/radio/headset/heads/ce
	id = /obj/item/weapon/card/id/ce
	l_pocket = /obj/item/device/t_scanner
	pda = /obj/item/device/pda/heads/ce
	backpack_contents = list(
		/obj/item/weapon/melee/classic_baton/telescopic = 1
	)

	backpack = /obj/item/weapon/storage/backpack/industrial
	satchel = /obj/item/weapon/storage/backpack/satchel_eng
	dufflebag = /obj/item/weapon/storage/backpack/duffel/engineering
	box = /obj/item/weapon/storage/box/engineer


/datum/job/engineer
	title = "Station Engineer"
	flag = ENGINEER
	department_flag = ENGSEC
	total_positions = 5
	spawn_positions = 5
	is_engineering = 1
	supervisors = "the chief engineer"
	department_head = list("Chief Engineer")
	selection_color = "#fff5cc"
	access = list(access_eva, access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction, access_atmospherics, access_mineral_storeroom)
	minimal_access = list(access_eva, access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction, access_mineral_storeroom)
	alt_titles = list("Maintenance Technician","Engine Technician","Electrician")
	minimal_player_age = 7
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW
	outfit = /datum/outfit/job/engineer

/datum/outfit/job/engineer
	name = "Station Engineer"
	jobtype = /datum/job/engineer

	uniform = /obj/item/clothing/under/rank/engineer
	belt = /obj/item/weapon/storage/belt/utility/full
	shoes = /obj/item/clothing/shoes/workboots
	head = /obj/item/clothing/head/hardhat
	l_ear = /obj/item/device/radio/headset/headset_eng
	id = /obj/item/weapon/card/id/engineering
	l_pocket = /obj/item/device/t_scanner
	pda = /obj/item/device/pda/engineering

	backpack = /obj/item/weapon/storage/backpack/industrial
	satchel = /obj/item/weapon/storage/backpack/satchel_eng
	dufflebag = /obj/item/weapon/storage/backpack/duffel/engineering
	box = /obj/item/weapon/storage/box/engineer



/datum/job/atmos
	title = "Life Support Specialist"
	flag = ATMOSTECH
	department_flag = ENGSEC
	total_positions = 3
	spawn_positions = 2
	is_engineering = 1
	supervisors = "the chief engineer"
	department_head = list("Chief Engineer")
	selection_color = "#fff5cc"
	access = list(access_eva, access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction, access_atmospherics, access_mineral_storeroom)
	minimal_access = list(access_eva, access_atmospherics, access_maint_tunnels, access_external_airlocks, access_emergency_storage, access_construction, access_mineral_storeroom)
	alt_titles = list("Atmospheric Technician")
	minimal_player_age = 7
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW
	outfit = /datum/outfit/job/atmos

/datum/outfit/job/atmos
	name = "Life Support Specialist"
	jobtype = /datum/job/atmos

	uniform = /obj/item/clothing/under/rank/atmospheric_technician
	belt = /obj/item/weapon/storage/belt/utility/atmostech
	shoes = /obj/item/clothing/shoes/workboots
	l_ear = /obj/item/device/radio/headset/headset_eng
	id = /obj/item/weapon/card/id/engineering
	pda = /obj/item/device/pda/atmos

	backpack = /obj/item/weapon/storage/backpack/industrial
	satchel = /obj/item/weapon/storage/backpack/satchel_eng
	dufflebag = /obj/item/weapon/storage/backpack/duffel/atmos
	box = /obj/item/weapon/storage/box/engineer

/datum/job/mechanic
	title = "Mechanic"
	flag = MECHANIC
	department_flag = KARMA
	total_positions = 1
	spawn_positions = 1
	is_engineering = 1
	supervisors = "the chief engineer"
	department_head = list("Chief Engineer")
	selection_color = "#fff5cc"
	access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_mechanic, access_external_airlocks, access_mineral_storeroom)
	minimal_access = list(access_maint_tunnels, access_emergency_storage, access_mechanic, access_external_airlocks, access_mineral_storeroom)
	outfit = /datum/outfit/job/mechanic

/datum/outfit/job/mechanic
	name = "Mechanic"
	jobtype = /datum/job/mechanic

	uniform = /obj/item/clothing/under/rank/mechanic
	belt = /obj/item/weapon/storage/belt/utility/full
	shoes = /obj/item/clothing/shoes/workboots
	head = /obj/item/clothing/head/hardhat
	l_ear = /obj/item/device/radio/headset/headset_eng
	id = /obj/item/weapon/card/id/engineering
	r_pocket = /obj/item/device/t_scanner
	pda = /obj/item/device/pda/engineering
	backpack_contents = list(
		/obj/item/weapon/pod_paint_bucket = 1
	)

	backpack = /obj/item/weapon/storage/backpack/industrial
	satchel = /obj/item/weapon/storage/backpack/satchel_eng
	dufflebag = /obj/item/weapon/storage/backpack/duffel/engineering
	box = /obj/item/weapon/storage/box/engineer
