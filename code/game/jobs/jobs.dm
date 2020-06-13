
GLOBAL_LIST_EMPTY(assistant_occupations)


GLOBAL_LIST_INIT(command_positions, list(
	"Captain",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Chief Medical Officer",
	"Nanotrasen Representative"
))


GLOBAL_LIST_INIT(engineering_positions, list(
	"Chief Engineer",
	"Station Engineer",
	"Life Support Specialist",
	"Mechanic"
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
	"Magistrate",
	"Nanotrasen Representative",
	"Blueshield"
))

GLOBAL_LIST_INIT(supply_positions, list(
	"Head of Personnel",
	"Quartermaster",
	"Cargo Technician",
	"Shaft Miner"
))

GLOBAL_LIST_INIT(service_positions, (support_positions - supply_positions + list("Head of Personnel")))


GLOBAL_LIST_INIT(security_positions, list(
	"Head of Security",
	"Warden",
	"Detective",
	"Security Officer",
	"Brig Physician",
	"Security Pod Pilot",
	"Magistrate"
))


GLOBAL_LIST_INIT(civilian_positions, list(
	"Civilian"
))

GLOBAL_LIST_INIT(nonhuman_positions, list(
	"AI",
	"Cyborg",
	"Drone",
	"pAI"
))

GLOBAL_LIST_INIT(whitelisted_positions, list(
	"Blueshield",
	"Nanotrasen Representative",
	"Barber",
	"Mechanic",
	"Brig Physician",
	"Magistrate",
	"Security Pod Pilot",
))


/proc/guest_jobbans(var/job)
	return (job in GLOB.whitelisted_positions)

/proc/get_job_datums()
	var/list/occupations = list()
	var/list/all_jobs = typesof(/datum/job)

	for(var/A in all_jobs)
		var/datum/job/job = new A()
		if(!job)	continue
		occupations += job

	return occupations

/proc/get_alternate_titles(var/job)
	var/list/jobs = get_job_datums()
	var/list/titles = list()

	for(var/datum/job/J in jobs)
		if(!J)	continue
		if(J.title == job)
			titles = J.alt_titles

	return titles

GLOBAL_LIST_INIT(exp_jobsmap, list(
	EXP_TYPE_LIVING = list(), // all living mobs
	EXP_TYPE_CREW = list(titles = command_positions | engineering_positions | medical_positions | science_positions | support_positions | supply_positions | security_positions | civilian_positions | list("AI","Cyborg") | whitelisted_positions), // crew positions
	EXP_TYPE_SPECIAL = list(), // antags, ERT, etc
	EXP_TYPE_GHOST = list(), // dead people, observers
	EXP_TYPE_EXEMPT = list(), // special grandfather setting
	EXP_TYPE_COMMAND = list(titles = command_positions),
	EXP_TYPE_ENGINEERING = list(titles = engineering_positions),
	EXP_TYPE_MEDICAL = list(titles = medical_positions),
	EXP_TYPE_SCIENCE = list(titles = science_positions),
	EXP_TYPE_SUPPLY = list(titles = supply_positions),
	EXP_TYPE_SECURITY = list(titles = security_positions),
	EXP_TYPE_SILICON = list(titles = list("AI","Cyborg")),
	EXP_TYPE_SERVICE = list(titles = service_positions),
	EXP_TYPE_WHITELIST = list(titles = whitelisted_positions) // karma-locked jobs
))
