var/list/assistant_occupations = list(
)


var/list/command_positions = list(
	"Captain",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Chief Medical Officer",
	"Nanotrasen Representative"
)


var/list/engineering_positions = list(
	"Chief Engineer",
	"Station Engineer",
	"Life Support Specialist",
	"Mechanic"
)


var/list/medical_positions = list(
	"Chief Medical Officer",
	"Medical Doctor",
	"Geneticist",
	"Psychiatrist",
	"Chemist",
	"Virologist",
	"Paramedic",
	"Coroner"
)


var/list/science_positions = list(
	"Research Director",
	"Scientist",
	"Roboticist",
)

//BS12 EDIT
var/list/support_positions = list(
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
)

var/list/supply_positions = list(
	"Head of Personnel",
	"Quartermaster",
	"Cargo Technician",
	"Shaft Miner"
)

var/list/service_positions = support_positions - supply_positions + list("Head of Personnel")


var/list/security_positions = list(
	"Head of Security",
	"Warden",
	"Detective",
	"Security Officer",
	"Brig Physician",
	"Security Pod Pilot",
	"Magistrate",
	"Forensic Specialist"
)


var/list/civilian_positions = list(
	"Civilian"
)

var/list/nonhuman_positions = list(
	"AI",
	"Cyborg",
	"Drone",
	"pAI"
)

var/list/whitelisted_positions = list(
	"Blueshield",
	"Nanotrasen Representative",
	"Barber",
	"Mechanic",
	"Brig Physician",
	"Magistrate",
	"Security Pod Pilot",
)

var/list/hispa_whitelist = list (
	"Captain",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Chief Medical Officer",
	"Nanotrasen Representative",
	"AI",
	"Blueshield",
	"Cyborg",
	"Magistrate",
	"Warden",
)


/proc/guest_jobbans(var/job)
	return (job in whitelisted_positions)

/proc/heads_jobbans(var/job)
	return (job in hispa_whitelist)

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

var/global/list/exp_jobsmap = list(
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
)
