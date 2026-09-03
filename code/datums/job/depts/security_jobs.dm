/datum/job/warden
	title = "Warden"
	flag = JOB_WARDEN
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_SECURITY
	supervisors = "the head of security"
	department_head = list("Head of Security")
	selection_color = "#ffeeee"
	access = list(
		ACCESS_ARMORY,
		ACCESS_BRIG,
		ACCESS_COURT,
		ACCESS_EVIDENCE,
		ACCESS_MAINT_TUNNELS,
		ACCESS_SEC_DOORS,
		ACCESS_SECURITY,
		ACCESS_WEAPONS
	)
	skeleton_access = list(
		ACCESS_FORENSICS_LOCKERS,
		ACCESS_MORGUE,
	)
	alt_titles = list("Bailiff", "Correctional Officer", "Armorer")
	minimal_player_age = 21
	exp_map = list(EXP_TYPE_SECURITY = 600)
	blacklisted_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY, DISABILITY_FLAG_NERVOUS, DISABILITY_FLAG_LISP, DISABILITY_FLAG_PARAPLEGIC)
	missing_limbs_allowed = FALSE
	outfit = /datum/outfit/job/warden
	important_information = "Space Law is the law, not a suggestion."
	standard_paycheck = CREW_PAY_MEDIUM
	difficulty = HARD_DIFFICULTY
	description = "The Warden has the responsibility of monitoring prisoners.\n\n\
					Difficulties: Space Law, Standard Operating Procedure (Legal), identifying antagonists"

/datum/job/detective
	title = "Detective"
	flag = JOB_DETECTIVE
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_SECURITY
	supervisors = "the head of security"
	department_head = list("Head of Security")
	selection_color = "#ffeeee"
	alt_titles = list("Forensic Technician", "Investigator")
	access = list(
		ACCESS_BRIG,
		ACCESS_COURT,
		ACCESS_EVIDENCE,
		ACCESS_FORENSICS_LOCKERS,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MORGUE,
		ACCESS_SEC_DOORS,
		ACCESS_SECURITY,
		ACCESS_WEAPONS
	)
	minimal_player_age = 14
	exp_map = list(EXP_TYPE_CREW = 600)
	blacklisted_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY, DISABILITY_FLAG_PARAPLEGIC)
	missing_limbs_allowed = FALSE
	outfit = /datum/outfit/job/detective
	important_information = "Track, investigate, and look cool while doing it. Space Law is not a suggestion."
	standard_paycheck = CREW_PAY_MEDIUM
	difficulty = MEDIUM_DIFFICULTY
	description = "The Detective has the responsibility of solving crimes and uncovering criminals.\n\n\
					Difficulties: Space Law, Standard Operating Procedure (Legal), forensics, identifying antagonists"

/datum/job/officer
	title = "Security Officer"
	flag = JOB_OFFICER
	department_flag = JOBCAT_ENGSEC
	total_positions = 7
	spawn_positions = 7
	job_department_flags = DEP_FLAG_SECURITY
	supervisors = "the head of security"
	department_head = list("Head of Security")
	selection_color = "#ffeeee"
	access = list(
		ACCESS_BRIG,
		ACCESS_COURT,
		ACCESS_EVIDENCE,
		ACCESS_MAINT_TUNNELS,
		ACCESS_SEC_DOORS,
		ACCESS_SECURITY,
		ACCESS_WEAPONS
	)
	skeleton_access = list(
		ACCESS_FORENSICS_LOCKERS,
		ACCESS_MORGUE,
	)
	alt_titles = list("Deputy", "Ranger", "Constable")
	minimal_player_age = 14
	exp_map = list(EXP_TYPE_CREW = 600)
	blacklisted_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY, DISABILITY_FLAG_PARAPLEGIC)
	missing_limbs_allowed = FALSE
	outfit = /datum/outfit/job/officer
	important_information = "Space Law is the law, not a suggestion."
	standard_paycheck = CREW_PAY_MEDIUM
	difficulty = MEDIUM_DIFFICULTY
	description = "Security Officers have the responsibility of enforcing Space Law and protecting the crew.\n\n\
					Difficulties: Space Law, Standard Operating Procedure (Legal), combat, identifying antagonists"
