/datum/job/bartender
	title = "Bartender"
	flag = JOB_BARTENDER
	department_flag = JOBCAT_SUPPORT
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_SERVICE
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(
		ACCESS_BAR,
		ACCESS_MAINT_TUNNELS,
		ACCESS_WEAPONS,
		ACCESS_MINERAL_STOREROOM,
	)
	skeleton_access = list(
		ACCESS_KITCHEN,
		ACCESS_HYDROPONICS,
		ACCESS_MORGUE,
	)
	alt_titles = list(
		"Barkeep",
		"Waiter",
		"Brewmaster",
		"Barista",
	)
	outfit = /datum/outfit/job/bartender
	standard_paycheck = CREW_PAY_LOW
	difficulty = LOW_DIFFICULTY
	description = "The Bartender has the responsibility of mixing drinks for the crew.\n\n\
					Difficulties: Mixing drinks"

/datum/job/chef
	title = "Chef"
	flag = JOB_CHEF
	department_flag = JOBCAT_SUPPORT
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_SERVICE
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(
		ACCESS_KITCHEN,
		ACCESS_MAINT_TUNNELS,
	)
	skeleton_access = list(
		ACCESS_BAR,
		ACCESS_MORGUE,
		ACCESS_HYDROPONICS,
		ACCESS_MINERAL_STOREROOM,
	)
	alt_titles = list(
		"Cook",
		"Culinary Artist",
		"Butcher",
	)
	outfit = /datum/outfit/job/chef
	standard_paycheck = CREW_PAY_LOW
	difficulty = MEDIUM_DIFFICULTY
	description = "The Chef has the responsibility of cooking food for the crew.\n\n\
					Difficulties: Martial arts, cooking"

/datum/job/hydro
	title = "Botanist"
	flag = JOB_BOTANIST
	department_flag = JOBCAT_SUPPORT
	total_positions = 3
	spawn_positions = 2
	job_department_flags = DEP_FLAG_SERVICE
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(
		ACCESS_HYDROPONICS,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MORGUE,
	)
	skeleton_access = list(
		ACCESS_KITCHEN,
		ACCESS_BAR,
		ACCESS_MINERAL_STOREROOM,
	)
	alt_titles = list(
		"Hydroponicist",
		"Botanical Researcher",
		"Farmer",
		"Gardener",
	)
	outfit = /datum/outfit/job/hydro
	standard_paycheck = CREW_PAY_LOW
	difficulty = MEDIUM_DIFFICULTY
	description = "Botanists have the responsibility of growing plants for the Chef.\n\n\
					Difficulties: Growing plants, maniuplating plant traits"

/datum/job/clown
	title = "Clown"
	flag = JOB_CLOWN
	department_flag = JOBCAT_SUPPORT
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_SERVICE
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(
		ACCESS_CLOWN,
		ACCESS_MAINT_TUNNELS,
		ACCESS_THEATRE,
	)
	alt_titles = list(
		"Jester",
		"Entertainer",
		"Comedian",
	)
	outfit = /datum/outfit/job/clown
	standard_paycheck = CREW_PAY_LOW
	difficulty = EASY_DIFFICULTY
	description = "The Clown has the responsibility of entertaining the crew.\n\n\
					Difficulties: A sense of humor. Honk!"

/datum/job/mime
	title = "Mime"
	flag = JOB_MIME
	department_flag = JOBCAT_SUPPORT
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_SERVICE
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_MIME,
		ACCESS_THEATRE,
	)
	alt_titles = list(
		"Pantomime",
		"Performer",
		"Performance Artist",
	)
	outfit = /datum/outfit/job/mime
	standard_paycheck = CREW_PAY_LOW
	difficulty = EASY_DIFFICULTY
	description = "The Mime has the responsibility of entertaining the crew non-verbally.\n\n\
					Difficulties: Emotes"

/datum/job/janitor
	title = "Janitor"
	flag = JOB_JANITOR
	department_flag = JOBCAT_SUPPORT
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_SERVICE
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(
		ACCESS_JANITOR,
		ACCESS_MAINT_TUNNELS,
	)
	alt_titles = list("Custodial Technician")
	outfit = /datum/outfit/job/janitor
	standard_paycheck = CREW_PAY_LOW
	difficulty = EASY_DIFFICULTY
	description = "Janitors have the responsibility of cleaning the station.\n\n\
					Difficulties: cleaning, lights replacement, movement, controls"

//More or less assistants
/datum/job/librarian
	title = "Librarian"
	flag = JOB_LIBRARIAN
	department_flag = JOBCAT_SUPPORT
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_SERVICE
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(
		ACCESS_LIBRARY,
		ACCESS_MAINT_TUNNELS,
	)
	alt_titles = list(
		"Journalist",
		"Reporter",
		"News Anchor",
		"Antiquarian",
		"Curator",
	)
	outfit = /datum/outfit/job/librarian
	standard_paycheck = CREW_PAY_LOW
	difficulty = EASY_DIFFICULTY
	description = "The Librarian has the responsibility of providing books for the crew.\n\n\
					Difficulties: Paperwork, controls"

/datum/job/chaplain
	title = "Chaplain"
	flag = JOB_CHAPLAIN
	department_flag = JOBCAT_SUPPORT
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_SERVICE
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(
		ACCESS_CHAPEL_OFFICE,
		ACCESS_CREMATORIUM,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MORGUE,
	)
	alt_titles = list(
		"Priest",
		"Cleric",
		"Clergyman",
		"Bishop",
		"Deacon",
		"Reverend",
		"Pastor",
		"Occult Specialist",
		"Paranormal Specialist",
		"Rabbi",
		"Monk",
		"Kannushi",
	)
	outfit = /datum/outfit/job/chaplain
	standard_paycheck = CREW_PAY_LOW
	difficulty = EASY_DIFFICULTY
	description = "The Chaplain has the responsibility of providing religious services for the crew.\n\n\
					Difficulties: Controls, funerals"

/datum/job/assistant
	title = "Assistant"
	flag = JOB_ASSISTANT
	department_flag = JOBCAT_SUPPORT
	total_positions = -1
	spawn_positions = -1
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list()			//See /datum/job/assistant/get_access()
	alt_titles = list(
		"Off-Duty",
		"Retired",
		"Intern",
	)
	outfit = /datum/outfit/job/assistant
	difficulty = NONE_DIFFICULTY
	description = "Assistants have the responsibility to learn the game.\n\n\
					Difficulties: Learning the controls. Radio headsets"

/datum/job/assistant/get_access()
	if(GLOB.configuration.jobs.assistant_maint_access)
		return list(ACCESS_MAINT_TUNNELS)
	else
		return list()

/datum/outfit/job/assistant
	name = "Assistant"
	jobtype = /datum/job/assistant

	uniform = /obj/item/clothing/under/color/random
	id = /obj/item/card/id/assistant
