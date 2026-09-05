/datum/job/captain
	title = "Captain"
	flag = JOB_CAPTAIN
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	supervisors = "Nanotrasen officials"
	department_head = list("Nanotrasen Navy Officer")
	selection_color = "#ccccff"
	req_admin_notify = 1
	job_department_flags = DEP_FLAG_COMMAND
	department_account_access = TRUE
	access = list() 	//See get_access()
	alt_titles = list(
		"Station Commander",
		"Head of Command",
		"Commanding Officer",
	)
	minimal_player_age = 30
	exp_map = list(EXP_TYPE_COMMAND = 1200)
	blacklisted_disabilities = list(
		DISABILITY_FLAG_BLIND,
		DISABILITY_FLAG_DEAF,
		DISABILITY_FLAG_MUTE,
		DISABILITY_FLAG_DIZZY,
		DISABILITY_FLAG_NERVOUS,
		DISABILITY_FLAG_LISP,
	)
	outfit = /datum/outfit/job/captain
	important_information = "This role requires you to coordinate a department. You are required to be familiar with Standard Operating Procedure (Command), basic job duties, and act professionally (roleplay)."
	standard_paycheck = CREW_PAY_HIGH
	difficulty = VERY_HARD_DIFFICULTY
	description = "The Captain has the responsibility to oversee heads of staff.\n\n\
					Difficulties: Standard Operating Procedure (General, Legal, Command), Space Law, paperwork, AI modules, communication"

/datum/job/captain/get_access()
	return get_all_accesses()

/datum/job/captain/announce(mob/living/carbon/human/H)
	. = ..()
	// Why the hell are captain announcements minor
	GLOB.minor_announcement.Announce("All hands, Captain [H.real_name] on deck!")

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
		ACCESS_ENGINEERING_GENERAL,
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
		ACCESS_WEAPONS,
	)
	skeleton_access = list(ACCESS_CAPTAIN)
	alt_titles = list(
		"Security Director",
		"Sheriff",
	)
	minimal_player_age = 21
	exp_map = list(EXP_TYPE_SECURITY = 1200)
	blacklisted_disabilities = list(
		DISABILITY_FLAG_BLIND,
		DISABILITY_FLAG_DEAF,
		DISABILITY_FLAG_MUTE,
		DISABILITY_FLAG_DIZZY,
		DISABILITY_FLAG_NERVOUS,
		DISABILITY_FLAG_LISP,
		DISABILITY_FLAG_PARAPLEGIC,
	)
	missing_limbs_allowed = FALSE
	outfit = /datum/outfit/job/hos
	important_information = "This role requires you to coordinate a department. You are required to be familiar with Standard Operating Procedure (Security), Space Law, basic job duties, and act professionally (roleplay)."
	standard_paycheck = CREW_PAY_HIGH
	difficulty = EXTREMELY_HARD_DIFFICULTY
	description = "The Head of Security has the responsibility of overseeing the Security department.\n\n\
					Difficulties: Space Law, Standard Operating Procedure (General, Legal, Security), combat, identifying antagonists, communication"

/datum/job/chief_engineer
	title = "Chief Engineer"
	flag = JOB_CHIEF
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_COMMAND | DEP_FLAG_ENGINEERING
	supervisors = "the captain"
	department_head = list("Captain")
	selection_color = "#ffeeaa"
	req_admin_notify = 1
	department_account_access = TRUE
	access = list(
		ACCESS_ATMOSPHERICS,
		ACCESS_CE,
		ACCESS_ENGINEERING_GENERAL,
		ACCESS_STATION_ENGINEER,
		ACCESS_ENGINE_EQUIP,
		ACCESS_ENGINE,
		ACCESS_EVA,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_HEADS,
		ACCESS_KEYCARD_AUTH,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINISAT,
		ACCESS_RC_ANNOUNCE,
		ACCESS_SEC_DOORS,
		ACCESS_TCOMSAT,
		ACCESS_TECH_STORAGE,
		ACCESS_TELEPORTER,
		ACCESS_WEAPONS,
	)
	skeleton_access = list(ACCESS_CAPTAIN)
	alt_titles = list(
		"Engineering Director",
		"Senior Engineer",
		"Engine Foreman",
	)
	minimal_player_age = 21
	exp_map = list(EXP_TYPE_ENGINEERING = 1200)
	blacklisted_disabilities = list(
		DISABILITY_FLAG_BLIND,
		DISABILITY_FLAG_DEAF,
		DISABILITY_FLAG_MUTE,
		DISABILITY_FLAG_DIZZY,
		DISABILITY_FLAG_NERVOUS,
		DISABILITY_FLAG_LISP,
		DISABILITY_FLAG_PARAPLEGIC,
	)
	missing_limbs_allowed = FALSE
	outfit = /datum/outfit/job/chief_engineer
	important_information = "This role requires you to coordinate a department. You are required to be familiar with Standard Operating Procedure (Engineering), basic job duties, and act professionally (roleplay)."
	standard_paycheck = CREW_PAY_HIGH
	difficulty = HARD_DIFFICULTY
	description = "The Chief Engineer has the responsibility of overseeing the Engineering department.\n\n\
					Difficulties: Standard Operating Procedure (General, Engineering), construction (advanced), hacking, engines (supermatter, tesla, singularity), communication"

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
		ACCESS_WEAPONS,
	)
	skeleton_access = list(ACCESS_CAPTAIN)
	alt_titles = list(
		"Senior Researcher",
		"Chief Research Officer",
	)
	minimal_player_age = 21
	blacklisted_disabilities = list(
		DISABILITY_FLAG_BLIND,
		DISABILITY_FLAG_DEAF,
		DISABILITY_FLAG_MUTE,
		DISABILITY_FLAG_DIZZY,
	)
	exp_map = list(EXP_TYPE_SCIENCE = 1200)
	// All science-y guys get bonuses for maxing out their tech.
	required_objectives = list(
		/datum/job_objective/further_research
	)

	outfit = /datum/outfit/job/rd
	important_information = "This role requires you to coordinate a department. You are required to be familiar with Standard Operating Procedure (Science), basic job duties, and act professionally (roleplay)."
	standard_paycheck = CREW_PAY_HIGH
	difficulty = MEDIUM_DIFFICULTY
	description = "The Research Director has the responsibility of overseeing the Science department.\n\n\
					Difficulties: Standard Operating Procedure (General, Science), R&D, xenobiology, toxins, chemistry, robotics, genetics, AI modules, anomalies"

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
		ACCESS_WEAPONS,
	)
	skeleton_access = list(ACCESS_CAPTAIN)
	alt_titles = list(
		"Medical Director",
		"Senior Physician",
	)
	minimal_player_age = 21
	exp_map = list(EXP_TYPE_MEDICAL = 1200)
	blacklisted_disabilities = list(
		DISABILITY_FLAG_BLIND,
		DISABILITY_FLAG_DEAF,
		DISABILITY_FLAG_MUTE,
		DISABILITY_FLAG_DIZZY,
	)
	outfit = /datum/outfit/job/cmo
	important_information = "This role requires you to coordinate a department. You are required to be familiar with Standard Operating Procedure (Medical), basic job duties, and act professionally (roleplay)."
	standard_paycheck = CREW_PAY_HIGH
	difficulty = HARD_DIFFICULTY
	description = "The Chief Medical Officer has the responsibility of overseeing the Medical Department.\n\n\
					Difficulties: Standard Operating Procedure (General, Medical), surgery, cloning, healing, virology, autopsies, communication"

/datum/job/hop
	title = "Head of Personnel"
	flag = JOB_HOP
	department_flag = JOBCAT_SUPPORT
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	department_head = list("Captain")
	selection_color = "#ddddff"
	req_admin_notify = 1
	job_department_flags = DEP_FLAG_COMMAND
	minimal_player_age = 21
	department_account_access = TRUE
	exp_map = list(EXP_TYPE_SERVICE = 1200)
	access = list(
		ACCESS_AI_UPLOAD,
		ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_BAR,
		ACCESS_BRIG,
		ACCESS_CARGO,
		ACCESS_CHANGE_IDS,
		ACCESS_CHAPEL_OFFICE,
		ACCESS_CLOWN,
		ACCESS_ENGINEERING_GENERAL,
		ACCESS_COURT,
		ACCESS_CREMATORIUM,
		ACCESS_EVA,
		ACCESS_EXPEDITION,
		ACCESS_HEADS_VAULT,
		ACCESS_HEADS,
		ACCESS_HOP,
		ACCESS_HYDROPONICS,
		ACCESS_JANITOR,
		ACCESS_KEYCARD_AUTH,
		ACCESS_KITCHEN,
		ACCESS_INTERNAL_AFFAIRS,
		ACCESS_LIBRARY,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MIME,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_RC_ANNOUNCE,
		ACCESS_RESEARCH,
		ACCESS_SEC_DOORS,
		ACCESS_SECURITY,
		ACCESS_THEATRE,
		ACCESS_WEAPONS,
	)
	skeleton_access = list(ACCESS_CAPTAIN)
	alt_titles = list(
		"Head of Service",
		"Crew Relations Officer",
	)
	blacklisted_disabilities = list(
		DISABILITY_FLAG_BLIND,
		DISABILITY_FLAG_DEAF,
		DISABILITY_FLAG_MUTE,
		DISABILITY_FLAG_DIZZY,
		DISABILITY_FLAG_NERVOUS,
		DISABILITY_FLAG_LISP,
	)
	outfit = /datum/outfit/job/hop
	important_information = "This role requires you to coordinate a department. You are required to be familiar with Standard Operating Procedure (Service), basic job duties, and act professionally (roleplay)."
	standard_paycheck = CREW_PAY_HIGH
	difficulty = MEDIUM_DIFFICULTY
	description = "The Head of Personnel has the responsibility of overseeing the Service department.\n\n\
					Difficulties: Standard Operating Procedure (Standard, Service, Command), Space Law, administration, IDs, paperwork "

/datum/job/qm
	title = "Quartermaster"
	flag = JOB_QUARTERMASTER
	department_flag = JOBCAT_SUPPORT
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_SUPPLY | DEP_FLAG_COMMAND
	supervisors = "the captain"
	department_head = list("Captain")
	department_account_access = TRUE
	selection_color = "#e2c59d"
	access = list(
		ACCESS_CARGO_BAY,
		ACCESS_CARGO_BOT,
		ACCESS_CARGO,
		ACCESS_HEADS_VAULT,
		ACCESS_HEADS,
		ACCESS_KEYCARD_AUTH,
		ACCESS_MAILSORTING,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING_STATION,
		ACCESS_MINING,
		ACCESS_QM,
		ACCESS_RC_ANNOUNCE,
		ACCESS_SEC_DOORS,
		ACCESS_SUPPLY_SHUTTLE,
		ACCESS_WEAPONS,
		ACCESS_TELEPORTER,
		ACCESS_EXPEDITION,
		ACCESS_SMITH,
	)
	skeleton_access = list(ACCESS_CAPTAIN)
	alt_titles = list(
		"Supply Director",
		"Chief Logistics Officer",
		"Requisitions Foreman",
	)
	blacklisted_disabilities = list(
		DISABILITY_FLAG_BLIND,
		DISABILITY_FLAG_DEAF,
		DISABILITY_FLAG_MUTE,
		DISABILITY_FLAG_DIZZY,
	)
	outfit = /datum/outfit/job/qm
	important_information = "This role requires you to coordinate a department. You are required to be familiar with Standard Operating Procedure (Supply), basic job duties, and act professionally (roleplay)."
	exp_map = list(EXP_TYPE_SUPPLY = 1200)
	standard_paycheck = CREW_PAY_HIGH
	difficulty = MEDIUM_DIFFICULTY
	description = "The Quartermaster has the responsibility of overseeing the Supply department.\n\n\
					Difficulties: Standard Operating Procedure (General, Supply, Command), mining, cargo, economy, paperwork"
