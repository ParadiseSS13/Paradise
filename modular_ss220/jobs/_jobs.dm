/datum/modpack/jobs
	name = "Работы"
	desc = "Новые джобки и изменения старых"
	author = "furior, PhantomRU"

/datum/modpack/jobs/initialize()
	. = ..()

	GLOB.security_positions |= GLOB.security_positions_ss220 + GLOB.security_donor_jobs
	GLOB.active_security_positions |= GLOB.security_positions_ss220 + GLOB.security_donor_jobs

	GLOB.medical_positions |= GLOB.medical_positions_ss220
	GLOB.engineering_positions |= GLOB.engineering_positions_ss220
	GLOB.science_positions |= GLOB.science_positions_ss220

	GLOB.service_positions |= GLOB.service_donor_jobs
	GLOB.supply_positions |= GLOB.supply_donor_jobs
	GLOB.assistant_positions |= GLOB.assistant_donor_jobs
