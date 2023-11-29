/datum/modpack/jobs
	name = "Работы"
	desc = "Новые джобки и изменения старых"
	author = "furior, PhantomRU"

/datum/modpack/jobs/initialize()
	. = ..()

	GLOB.security_positions |= GLOB.security_positions_ss220
	GLOB.active_security_positions |= GLOB.security_positions_ss220

	GLOB.medical_positions |= GLOB.medical_positions_ss220
	GLOB.engineering_positions |= GLOB.engineering_positions_ss220
	GLOB.science_positions |= GLOB.science_positions_ss220
