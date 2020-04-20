
GLOBAL_LIST_EMPTY(assistant_occupations)


GLOBAL_LIST_INIT(command_positions, list(
	"Capitan",
	"Jefe de Personal",
	"Jefe de Seguridad",
	"Jefe de Ingenieros",
	"Director de Ciencias",
	"Jefe Medico",
	"Representante de Nanotrasen"
))


GLOBAL_LIST_INIT(engineering_positions, list(
	"Jefe de Ingenieros",
	"Ingeniero",
	"Experto en Soporte de Vida",
	"Mecanico"
))


GLOBAL_LIST_INIT(medical_positions, list(
	"Jefe Medico",
	"Doctor Medico",
	"Genetista",
	"Psiquiatra",
	"Quimico",
	"Virologo",
	"Paramedico",
	"Medico Forense"
))


GLOBAL_LIST_INIT(science_positions, list(
	"Director de Ciencias",
	"Cientifico",
	"Genetista",	//Part of both medical and science
	"Robotista",
))

//BS12 EDIT
GLOBAL_LIST_INIT(support_positions, list(
	"Jefe de Personal",
	"Bartender",
	"Botanico",
	"Chef",
	"Conserje",
	"Bibliotecario",
	"Quartermaster",
	"Tecnico de Cargo",
	"Minero",
	"Agente de Asuntos Internos",
	"Capellan",
	"Payaso",
	"Mimo",
	"Barbero",
	"Magistrado",
	"Representante de Nanotrasen",
	"Blueshield"
))

GLOBAL_LIST_INIT(supply_positions, list(
	"Jefe de Personal",
	"Quartermaster",
	"Tecnico de Cargo",
	"Minero"
))

GLOBAL_LIST_INIT(service_positions, (support_positions - supply_positions + list("Jefe de Personal")))


GLOBAL_LIST_INIT(security_positions, list(
	"Jefe de Seguridad",
	"Carcelero",
	"Detective",
	"Oficial de Seguridad",
	"Brig Physician",
	"Security Pod Pilot",
	"Magistrado"
))


GLOBAL_LIST_INIT(civilian_positions, list(
	"Civil"
))

GLOBAL_LIST_INIT(nonhuman_positions, list(
	"AI",
	"Cyborg",
	"Drone",
	"pAI"
))

GLOBAL_LIST_INIT(whitelisted_positions, list(
	"Blueshield",
	"Representante de Nanotrasen",
	"Barbero",
	"Mecanico",
	"Brig Physician",
	"Magistrado",
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
