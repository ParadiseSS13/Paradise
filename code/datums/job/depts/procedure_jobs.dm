/datum/job/judge
	title = "Magistrate"
	flag = JOB_JUDGE
	department_flag = JOBCAT_ENGSEC
	total_positions = 1
	spawn_positions = 1
	supervisors = "Nanotrasen Asset Protection"
	department_head = list("Captain")
	selection_color = "#ddddff"
	req_admin_notify = TRUE
	job_department_flags = DEP_FLAG_LEGAL
	transfer_allowed = FALSE
	minimal_player_age = 30
	exp_map = list(EXP_TYPE_SECURITY = 6000) // 100 hours baby
	access = list(
		ACCESS_BRIG,
		ACCESS_COURT,
		ACCESS_EVIDENCE,
		ACCESS_HEADS,
		ACCESS_INTERNAL_AFFAIRS,
		ACCESS_MAGISTRATE,
		ACCESS_MAINT_TUNNELS,
		ACCESS_RC_ANNOUNCE,
		ACCESS_SEC_DOORS,
		ACCESS_SECURITY,
		ACCESS_WEAPONS,
		ACCESS_TRAINER
	)
	alt_titles = list("Judge")
	blacklisted_disabilities = list(DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_NERVOUS, DISABILITY_FLAG_LISP)
	outfit = /datum/outfit/job/judge
	important_information = "This role requires you to oversee legal matters and make important decisions about sentencing. You are required to have an extensive knowledge of Space Law and Security SOP and only operate within, not outside, the boundaries of the law."
	standard_paycheck = CREW_PAY_MEDIUM
	difficulty = HARD_DIFFICULTY
	description = "The Magistrate has the responsibility of being the final word on Space Law and ensuring it's enforced properly.\n\n\
					Difficulties: Space Law, Standard Operating Procedure (General, Legal), communication"

/datum/job/iaa
	title = "Internal Affairs Agent"
	flag = JOB_INTERNAL_AFFAIRS
	department_flag = JOBCAT_SUPPORT
	total_positions = 2
	spawn_positions = 2
	job_department_flags = DEP_FLAG_LEGAL
	supervisors = "the magistrate"
	department_head = list("Captain")
	selection_color = "#ddddff"
	access = list(
		ACCESS_CARGO,
		ACCESS_ENGINEERING_GENERAL,
		ACCESS_COURT,
		ACCESS_INTERNAL_AFFAIRS,
		ACCESS_MAILSORTING,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_RESEARCH,
		ACCESS_SEC_DOORS
	)
	alt_titles = list("Human Resources Agent", "Inspector")
	minimal_player_age = 30
	exp_map = list(EXP_TYPE_CREW = 600)
	blacklisted_disabilities = list(DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_NERVOUS, DISABILITY_FLAG_LISP)
	outfit = /datum/outfit/job/iaa
	important_information = "Your job is to deal with affairs regarding Standard Operating Procedure. You are NOT in charge of Space Law affairs, nor can you override it. You are NOT a prisoner defence lawyer."
	standard_paycheck = CREW_PAY_MEDIUM
	difficulty = MEDIUM_DIFFICULTY
	description = "Internal Affairs Agents have the responsibility of ensuring departments are following Standard Operating Procedure.\n\n\
					Difficulties: Standard Operating Procedure (General, Departmental), paperwork"
