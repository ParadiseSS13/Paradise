/datum/job/cargo_tech
	title = "Cargo Technician"
	flag = JOB_CARGOTECH
	department_flag = JOBCAT_SUPPORT
	total_positions = 2
	spawn_positions = 2
	job_department_flags = DEP_FLAG_SUPPLY
	supervisors = "the quartermaster"
	department_head = list("Quartermaster")
	selection_color = "#eeddbe"
	access = list(
		ACCESS_CARGO_BAY,
		ACCESS_CARGO,
		ACCESS_MAILSORTING,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SUPPLY_SHUTTLE,
	)
	skeleton_access = list(
		ACCESS_MINING,
		ACCESS_MINING_STATION,
		ACCESS_SMITH,
	)
	alt_titles = list(
		"Mail Carrier",
		"Courier",
		"Logistics Technician",
		"Requisitions Specialist",
	)
	outfit = /datum/outfit/job/cargo_tech
	standard_paycheck = CREW_PAY_LOW
	difficulty = EASY_DIFFICULTY
	description = "Cargo Technicians have the responsibility of handling cargo orders and delivering mail.\n\n\
					Difficulties: Loading and unloading crates, economy, paperwork, menu navigation"

/datum/job/smith
	title = "Smith"
	flag = JOB_SMITH
	department_flag = JOBCAT_SUPPORT
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_SUPPLY
	supervisors = "the quartermaster"
	department_head = list("Quartermaster")
	selection_color = "#eeddbe"
	access = list(
		ACCESS_CARGO_BAY,
		ACCESS_CARGO,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING,
		ACCESS_MINING_STATION,
		ACCESS_SMITH,
	)
	skeleton_access = list(
		ACCESS_MAILSORTING,
		ACCESS_SUPPLY_SHUTTLE,
	)
	alt_titles = list(
		"Metalworker",
		"Tinkerer",
	)
	outfit = /datum/outfit/job/smith
	standard_paycheck = CREW_PAY_LOW
	difficulty = MEDIUM_DIFFICULTY
	description = "The Smith has the responsibility of refining ores, as well as making tool bits and armor plates.\n\n\
					Difficulties: Smithing, controls"

/datum/job/mining
	title = "Shaft Miner"
	flag = JOB_MINER
	department_flag = JOBCAT_SUPPORT
	total_positions = 6
	spawn_positions = 8
	job_department_flags = DEP_FLAG_SUPPLY
	supervisors = "the quartermaster"
	department_head = list("Quartermaster")
	selection_color = "#eeddbe"
	access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING_STATION,
		ACCESS_MINING,
	)
	skeleton_access = list(
		ACCESS_MAILSORTING,
		ACCESS_CARGO,
		ACCESS_CARGO_BAY,
		ACCESS_SUPPLY_SHUTTLE,
		ACCESS_SMITH,
	)
	alt_titles = list("Spelunker")
	outfit = /datum/outfit/job/mining
	standard_paycheck = CREW_PAY_LOW
	difficulty = HARD_DIFFICULTY
	description = "Shaft Miners have the responsibility of mining ores on Lavaland.\n\n\
					Difficulties: Mining, combat"

/datum/job/explorer
	title = "Explorer"
	flag = JOB_EXPLORER
	department_flag = JOBCAT_SUPPORT
	job_department_flags = DEP_FLAG_SUPPLY
	total_positions = 4
	spawn_positions = 4
	supervisors = "the quartermaster"
	department_head = list("Quartermaster")
	selection_color = "#eeddbe"
	access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_EXPEDITION,
		ACCESS_EVA,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_TELEPORTER,
		ACCESS_CARGO,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING_STATION,
	)
	skeleton_access = list(
		ACCESS_CARGO_BAY,
		ACCESS_SUPPLY_SHUTTLE,
		ACCESS_MAILSORTING,
		ACCESS_MINING_STATION,
		ACCESS_MINING,
		ACCESS_SMITH,
	)
	alt_titles = list(
		"Salvage Technician",
		"Scavenger",
	)
	outfit = /datum/outfit/job/explorer
	standard_paycheck = CREW_PAY_LOW
	difficulty = HARD_DIFFICULTY
	description = "Explorers have the responsibility of exploring space near the station.\n\n\
					Difficulties: Space movement, combat, space exploration, mining"
