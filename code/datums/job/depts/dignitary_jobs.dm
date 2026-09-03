/datum/job/nanotrasenrep
	title = "Nanotrasen Representative"
	flag = JOB_NANO
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	supervisors = "the command staff"
	department_head = list("Captain")
	selection_color = "#ddddff"
	req_admin_notify = TRUE
	job_department_flags = DEP_FLAG_COMMAND
	transfer_allowed = FALSE
	minimal_player_age = 21
	exp_map = list(EXP_TYPE_COMMAND = 3000) // 50 hours baby
	access = list(
		ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_BAR,
		ACCESS_BRIG,
		ACCESS_CARGO_BAY,
		ACCESS_CARGO_BOT,
		ACCESS_CARGO,
		ACCESS_CHAPEL_OFFICE,
		ACCESS_CLOWN,
		ACCESS_ENGINEERING_GENERAL,
		ACCESS_COURT,
		ACCESS_CREMATORIUM,
		ACCESS_ENGINE,
		ACCESS_EVA,
		ACCESS_EXPEDITION,
		ACCESS_HEADS_VAULT,
		ACCESS_HEADS,
		ACCESS_HYDROPONICS,
		ACCESS_JANITOR,
		ACCESS_KEYCARD_AUTH,
		ACCESS_KITCHEN,
		ACCESS_INTERNAL_AFFAIRS,
		ACCESS_LIBRARY,
		ACCESS_MAILSORTING,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MIME,
		ACCESS_MINING_STATION,
		ACCESS_MINING,
		ACCESS_MORGUE,
		ACCESS_NTREP,
		ACCESS_RC_ANNOUNCE,
		ACCESS_RESEARCH,
		ACCESS_SEC_DOORS,
		ACCESS_SECURITY,
		ACCESS_SUPPLY_SHUTTLE,
		ACCESS_THEATRE,
		ACCESS_WEAPONS,
		ACCESS_TRAINER
	)
	blacklisted_disabilities = list(DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_NERVOUS, DISABILITY_FLAG_LISP)
	outfit = /datum/outfit/job/nanotrasenrep
	important_information = "This role requires you to advise the Command team about Standard Operating Procedure, Chain of Command, and report to Central Command about various matters. You are required to act in a manner befitting someone representing Nanotrasen."
	standard_paycheck = CREW_PAY_MEDIUM
	difficulty = LOW_DIFFICULTY
	description = "The Nanotrasen Representative has the responsibility of ensuring heads of staff are following Standard Operating Procedure.\n\n\
					Difficulties: Standard Operating Procedure (General, Command), paperwork, communication"

/datum/job/blueshield
	title = "Blueshield"
	flag = JOB_BLUESHIELD
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Nanotrasen representative"
	department_head = list("Captain")
	selection_color = "#ddddff"
	req_admin_notify = TRUE
	job_department_flags = DEP_FLAG_COMMAND
	transfer_allowed = FALSE
	minimal_player_age = 21
	exp_map = list(EXP_TYPE_COMMAND = 3000) // 50 hours baby
	access = list(
		ACCESS_BLUESHIELD,
		ACCESS_CARGO,
		ACCESS_ENGINEERING_GENERAL,
		ACCESS_ENGINE,
		ACCESS_EVIDENCE,
		ACCESS_HEADS,
		ACCESS_KEYCARD_AUTH,
		ACCESS_MAILSORTING,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MINING,
		ACCESS_RC_ANNOUNCE,
		ACCESS_RESEARCH,
		ACCESS_SEC_DOORS,
		ACCESS_WEAPONS
	)
	alt_titles = list("Blueshield Officer", "Bodyguard", "Command Escort")
	blacklisted_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY, DISABILITY_FLAG_NERVOUS, DISABILITY_FLAG_LISP, DISABILITY_FLAG_PARAPLEGIC)
	missing_limbs_allowed = FALSE
	outfit = /datum/outfit/job/blueshield
	important_information = "This role requires you to ensure the safety of the Heads of Staff, not the general crew. You may perform arrests only if the combatant is directly threatening a member of Command, the Nanotrasen Representative, or the Magistrate."
	standard_paycheck = CREW_PAY_MEDIUM
	difficulty = HARD_DIFFICULTY
	description = "The Blueshield has the responsibility of protecting heads of staff and dignitaries.\n\n\
					Difficulties: Healing, combat, communication"

/datum/job/nanotrasentrainer
	title = "Nanotrasen Career Trainer"
	flag = JOB_INSTRUCTOR
	department_flag = JOBCAT_ENGSEC
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Nanotrasen Representative"
	department_head = list("Captain")
	selection_color = "#ddddff"
	mentor_only = TRUE
	job_department_flags = DEP_FLAG_COMMAND
	transfer_allowed = FALSE
	access = list(
		ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_CARGO,
		ACCESS_MAILSORTING,
		ACCESS_ENGINEERING_GENERAL,
		ACCESS_COURT,
		ACCESS_EVA,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_RESEARCH,
		ACCESS_SEC_DOORS,
		ACCESS_THEATRE,
		ACCESS_INTERNAL_AFFAIRS,
		ACCESS_TRAINER
	)
	blacklisted_disabilities = list(DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_NERVOUS, DISABILITY_FLAG_LISP)
	outfit = /datum/outfit/job/nct
	important_information = "Your job is to try to assist as many crew members as possible regardless of department. You are NOT permitted to give command staff advice on any command SOP questions or aid in legal advice."
	standard_paycheck = CREW_PAY_MEDIUM
	difficulty = MEDIUM_DIFFICULTY
	description = "Nanotrasen Career Trainers (NCTs for short) are currently a mentor/admin only job. They are held to a higher standard, like any other staff-only job.\n\n\
					Difficulties: Training crew."
