/datum/job/doctor
	title = "Medical Doctor"
	flag = JOB_DOCTOR
	department_flag = JOBCAT_MEDSCI
	total_positions = 5
	spawn_positions = 3
	job_department_flags = DEP_FLAG_MEDICAL
	supervisors = "the chief medical officer"
	department_head = list("Chief Medical Officer")
	selection_color = "#cbf7ff"
	access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MORGUE,
		ACCESS_SURGERY,
	)
	skeleton_access = list(
		ACCESS_CHEMISTRY,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_VIROLOGY,
	)
	alt_titles = list(
		"Surgeon",
		"Nurse",
		"Physician",
		"Medical Student",
		"Medical Resident",
	)
	minimal_player_age = 3
	exp_map = list(EXP_TYPE_CREW = 180)
	outfit = /datum/outfit/job/doctor
	standard_paycheck = CREW_PAY_MEDIUM
	difficulty = MEDIUM_DIFFICULTY
	description = "Medical Doctors have the responsibility of performing medical care, including surgery and cloning of the dead.\n\n\
					Difficulties: Surgery, cloning, healing"

/datum/job/coroner
	title = "Coroner"
	flag = JOB_CORONER
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_MEDICAL
	supervisors = "the chief medical officer"
	department_head = list("Chief Medical Officer")
	selection_color = "#cbf7ff"
	access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MORGUE,
	)
	skeleton_access = list(
		ACCESS_SURGERY,
		ACCESS_CHEMISTRY,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_VIROLOGY,
	)
	alt_titles = list("Mortician")
	minimal_player_age = 3
	exp_map = list(EXP_TYPE_CREW = 180)
	outfit = /datum/outfit/job/coroner
	standard_paycheck = CREW_PAY_MEDIUM
	difficulty = LOW_DIFFICULTY
	description = "The Coroner has the responsibility of organizing dead crew members and their belongings.\n\n\
					Difficulties: Autopsies"

//Chemist is a medical job damnit	//YEAH FUCK YOU SCIENCE	-Pete	//Guys, behave -Erro
/datum/job/chemist
	title = "Chemist"
	flag = JOB_CHEMIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 2
	spawn_positions = 2
	job_department_flags = DEP_FLAG_MEDICAL
	supervisors = "the chief medical officer"
	department_head = list("Chief Medical Officer")
	selection_color = "#cbf7ff"
	access = list(
		ACCESS_CHEMISTRY,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
	)
	skeleton_access = list(
		ACCESS_MORGUE,
		ACCESS_SURGERY,
		ACCESS_VIROLOGY,
	)
	alt_titles = list(
		"Pharmacist",
		"Pharmacologist",
	)
	minimal_player_age = 7
	exp_map = list(EXP_TYPE_CREW = 300)
	outfit = /datum/outfit/job/chemist
	standard_paycheck = CREW_PAY_MEDIUM
	difficulty = MEDIUM_DIFFICULTY
	description = "Chemists have the responsibility of providing medicine to medical.\n\n\
					Difficulties: Chemistry, menu navigation"

/datum/job/virologist
	title = "Virologist"
	flag = JOB_VIROLOGIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_MEDICAL
	supervisors = "the chief medical officer"
	department_head = list("Chief Medical Officer")
	selection_color = "#cbf7ff"
	access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_VIROLOGY,
	)
	skeleton_access = list(
		ACCESS_MORGUE,
		ACCESS_SURGERY,
		ACCESS_CHEMISTRY,
		ACCESS_MINERAL_STOREROOM,
	)
	alt_titles = list(
		"Pathologist",
		"Microbiologist",
	)
	minimal_player_age = 7
	exp_map = list(EXP_TYPE_CREW = 300)
	required_objectives = list(
		/datum/job_objective/virus_samples
	)
	outfit = /datum/outfit/job/virologist
	standard_paycheck = CREW_PAY_MEDIUM
	difficulty = MEDIUM_DIFFICULTY
	description = "The Virologist has the responsibility of manipulating and creating viruses as well as vaccines.\n\n\
					Difficulties: Virus mutation, virus curing, virus mixing, menu navigation"

/datum/job/psychiatrist
	title = "Psychiatrist"
	flag = JOB_PSYCHIATRIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_MEDICAL
	supervisors = "the chief medical officer"
	department_head = list("Chief Medical Officer")
	selection_color = "#cbf7ff"
	access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_PSYCHIATRIST,
	)
	skeleton_access = list(
		ACCESS_MORGUE,
		ACCESS_SURGERY,
		ACCESS_CHEMISTRY,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_VIROLOGY,
	)
	alt_titles = list(
		"Psychologist",
		"Therapist",
	)
	outfit = /datum/outfit/job/psychiatrist
	standard_paycheck = CREW_PAY_MEDIUM
	difficulty = EASY_DIFFICULTY
	description = "The Psychologist has the responsibility to keep the crew sane.\n\n\
					Difficulties: Communication, menu navigation"

/datum/job/paramedic
	title = "Paramedic"
	flag = JOB_PARAMEDIC
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_MEDICAL
	supervisors = "the chief medical officer"
	department_head = list("Chief Medical Officer")
	selection_color = "#cbf7ff"
	access = list(
		ACCESS_CARGO,
		ACCESS_EVA,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_MAILSORTING,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING_STATION,
		ACCESS_MINING,
		ACCESS_MORGUE,
		ACCESS_PARAMEDIC,
		ACCESS_TELEPORTER,
	)
	skeleton_access = list(
		ACCESS_SURGERY,
		ACCESS_CHEMISTRY,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_VIROLOGY,
	)
	alt_titles = list(
		"Emergency Medical Technician",
		"First Responder",
		"Rescue Technician",
	)
	minimal_player_age = 3
	exp_map = list(EXP_TYPE_CREW = 180)
	outfit = /datum/outfit/job/paramedic
	important_information = "You are the first responder to medical emergencies outside the sanctity of the Medbay. You can also respond to Lavaland emergencies via the mining shuttle located in Cargo, or space emergencies via the Teleporter near the Bridge."
	standard_paycheck = CREW_PAY_MEDIUM
	difficulty = LOW_DIFFICULTY
	description = "The Paramedic has the responsibility of rescuing crew members from danger.\n\n\
					Difficulties: Healing"
