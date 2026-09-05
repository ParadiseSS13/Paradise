/datum/job/engineer
	title = "Station Engineer"
	flag = JOB_ENGINEER
	department_flag = JOBCAT_ENGSEC
	total_positions = 5
	spawn_positions = 5
	job_department_flags = DEP_FLAG_ENGINEERING
	supervisors = "the chief engineer"
	department_head = list("Chief Engineer")
	selection_color = "#fff5cc"
	access = list(
		ACCESS_ENGINEERING_GENERAL,
		ACCESS_STATION_ENGINEER,
		ACCESS_ENGINE_EQUIP,
		ACCESS_ENGINE,
		ACCESS_EVA,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_TECH_STORAGE,
	)
	skeleton_access = list(ACCESS_ATMOSPHERICS)
	alt_titles = list(
		"Maintenance Technician",
		"Engine Technician",
		"Electrician",
		"Mechanic",
		"Repairman",
	)
	minimal_player_age = 7
	exp_map = list(EXP_TYPE_CREW = 300)
	outfit = /datum/outfit/job/engineer
	standard_paycheck = CREW_PAY_MEDIUM
	difficulty = MEDIUM_DIFFICULTY
	description = "Station Engineers have the responsibility of maintaining the station's infrastructure and operating the station's engine.\n\n\
					Difficulties: Construction (advanced), space movement"

/datum/job/atmos
	title = "Life Support Specialist"
	flag = JOB_ATMOSTECH
	department_flag = JOBCAT_ENGSEC
	total_positions = 3
	spawn_positions = 2
	job_department_flags = DEP_FLAG_ENGINEERING
	supervisors = "the chief engineer"
	department_head = list("Chief Engineer")
	selection_color = "#fff5cc"
	access = list(
		ACCESS_ATMOSPHERICS,
		ACCESS_ENGINEERING_GENERAL,
		ACCESS_ENGINE,
		ACCESS_EVA,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_TECH_STORAGE,
	)
	skeleton_access = list(
		ACCESS_STATION_ENGINEER,
		ACCESS_ENGINE_EQUIP,
	)
	alt_titles = list(
		"Atmospheric Technician",
		"Firefighter",
	)
	minimal_player_age = 7
	exp_map = list(EXP_TYPE_CREW = 300)
	outfit = /datum/outfit/job/atmos
	standard_paycheck = CREW_PAY_MEDIUM
	difficulty = MEDIUM_DIFFICULTY
	description = "Atmospheric Technicians have the responsibility of maintaining the station's atmospherics system.\n\n\
					Difficulties: Atmospherics, pipe manipulation, gas pressure, space movement"
