/datum/modpack/bureaucracy
	name = "Бюрократия"
	desc = "Добавляет бланки в ксерокс."
	author = "Aylong220, Furior, RV666"

/datum/modpack/bureaucracy/initialize()
	. = ..()
	for(var/datum/bureaucratic_form/form as anything in subtypesof(/datum/bureaucratic_form))
		GLOB.bureaucratic_forms["[form]"] = new form
