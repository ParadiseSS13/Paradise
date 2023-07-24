
GLOBAL_LIST_INIT(station_departments, list(DEPARTMENT_COMMAND, DEPARTMENT_MEDICAL, DEPARTMENT_ENGINEERING,
											DEPARTMENT_SCIENCE, DEPARTMENT_SECURITY, DEPARTMENT_SUPPLY,
											DEPARTMENT_SERVICE, DEPARTMENT_ASSISTANT))

/// All roles that are within the command category
GLOBAL_LIST_INIT(command_positions, list(
	"Captain",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Chief Medical Officer",
	"Nanotrasen Representative",
	"Magistrate",
	"Blueshield"
))

/// Only roles that are command of departments, for revolution and similar stuff
GLOBAL_LIST_INIT(command_head_positions, list(
	"Captain",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Chief Medical Officer",
))


GLOBAL_LIST_INIT(engineering_positions, list(
	"Chief Engineer",
	"Station Engineer",
	"Life Support Specialist",
))


GLOBAL_LIST_INIT(medical_positions, list(
	"Chief Medical Officer",
	"Medical Doctor",
	"Geneticist",
	"Psychiatrist",
	"Chemist",
	"Virologist",
	"Paramedic",
	"Coroner"
))


GLOBAL_LIST_INIT(science_positions, list(
	"Research Director",
	"Scientist",
	"Geneticist",	//Part of both medical and science
	"Roboticist",
))

//BS12 EDIT
GLOBAL_LIST_INIT(support_positions, list(
	"Head of Personnel",
	"Bartender",
	"Botanist",
	"Chef",
	"Janitor",
	"Librarian",
	"Quartermaster",
	"Cargo Technician",
	"Shaft Miner",
	"Internal Affairs Agent",
	"Chaplain",
	"Clown",
	"Mime",
	"Barber",
	"Explorer"
))

GLOBAL_LIST_INIT(supply_positions, list(
	"Head of Personnel",
	"Quartermaster",
	"Cargo Technician",
	"Shaft Miner"
))

GLOBAL_LIST_INIT(service_positions, (list("Head of Personnel") + (support_positions - supply_positions)))

/// Roles that include any semblence of security, mostly for jobbans
GLOBAL_LIST_INIT(security_positions, list(
	"Head of Security",
	"Warden",
	"Detective",
	"Security Officer",
	"Magistrate",
	"Blueshield"
))

/// Active security roles
GLOBAL_LIST_INIT(active_security_positions, list(
	"Head of Security",
	"Warden",
	"Detective",
	"Security Officer"
))



GLOBAL_LIST_INIT(assistant_positions, list(
	"Assistant"
))

GLOBAL_LIST_INIT(nonhuman_positions, list(
	"AI",
	"Cyborg",
	"Drone",
	"pAI"
))

/proc/get_job_datums()
	var/list/occupations = list()
	var/list/all_jobs = typesof(/datum/job)

	for(var/A in all_jobs)
		var/datum/job/job = new A()
		if(!job)	continue
		occupations += job

	return occupations

/proc/get_alternate_titles(job)
	var/list/jobs = get_job_datums()
	var/list/titles = list()

	for(var/datum/job/J in jobs)
		if(!J)	continue
		if(J.title == job)
			titles = J.alt_titles

	return titles

GLOBAL_LIST_INIT(exp_jobsmap, list(
	EXP_TYPE_LIVING = list(), // all living mobs
	EXP_TYPE_CREW = list(titles = command_positions | engineering_positions | medical_positions | science_positions | support_positions | supply_positions | security_positions | assistant_positions | list("AI","Cyborg")), // crew positions
	EXP_TYPE_SPECIAL = list(), // antags, ERT, etc
	EXP_TYPE_GHOST = list(), // dead people, observers
	EXP_TYPE_COMMAND = list(titles = command_positions),
	EXP_TYPE_ENGINEERING = list(titles = engineering_positions),
	EXP_TYPE_MEDICAL = list(titles = medical_positions),
	EXP_TYPE_SCIENCE = list(titles = science_positions),
	EXP_TYPE_SUPPLY = list(titles = supply_positions),
	EXP_TYPE_SECURITY = list(titles = security_positions),
	EXP_TYPE_SILICON = list(titles = list("AI","Cyborg")),
	EXP_TYPE_SERVICE = list(titles = service_positions),
))
