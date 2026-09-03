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
	skeleton_access = list(
		ACCESS_ROBOTICS,
		ACCESS_MORGUE,
		ACCESS_TECH_STORAGE,
		ACCESS_GENETICS,
		ACCESS_XENOBIOLOGY,
		ACCESS_MINING,
		ACCESS_MINING_STATION,
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
	difficulty = MEDIUM_DIFFICULTY
	description = "Scientists have the responsibility of increasing the station's research levels.\n\n\
					Difficulties: R&D, toxins, chemistry, anomalies, menu navigation"

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
	skeleton_access = list(
		ACCESS_TOX_STORAGE,
		ACCESS_TOX,
		ACCESS_ROBOTICS,
		ACCESS_MORGUE,
		ACCESS_TECH_STORAGE,
		ACCESS_GENETICS,
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
	difficulty = MEDIUM_DIFFICULTY
	description = "Xenobiologists have the responsibility of researching slimes and the organs of fauna.\n\n\
					Difficulties: Xenobiology, surgery"

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
	skeleton_access = list(
		ACCESS_TOX_STORAGE,
		ACCESS_TOX,
		ACCESS_GENETICS,
		ACCESS_XENOBIOLOGY,
		ACCESS_MINING,
		ACCESS_MINING_STATION,
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
	difficulty = MEDIUM_DIFFICULTY
	description = "Roboticists have the responsibility of building exosuits, cyborgs, and implants.\n\n\
					Difficulties: Cyborg/exosuit/IPC construction/maintenance, AI modules, paperwork, MODsuits, surgery"

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
	skeleton_access = list(
		ACCESS_MINERAL_STOREROOM,
		ACCESS_TOX_STORAGE,
		ACCESS_TOX,
		ACCESS_ROBOTICS,
		ACCESS_MORGUE,
		ACCESS_TECH_STORAGE,
		ACCESS_XENOBIOLOGY,
		ACCESS_MINING,
		ACCESS_MINING_STATION,
	)
	alt_titles = list("Genetic Researcher")
	minimal_player_age = 3
	exp_map = list(EXP_TYPE_CREW = 180)
	outfit = /datum/outfit/job/geneticist
	standard_paycheck = CREW_PAY_MEDIUM
	difficulty = MEDIUM_DIFFICULTY
	description = "Geneticists have the responsibility of researching and providing genetic powers.\n\n\
					Difficulties: Genetics, menu navigation"
