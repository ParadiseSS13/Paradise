/////////////////////////////////////////////////////////////////////////////////////////
// Research
/////////////////////////////////////////////////////////////////////////////////////////

// MAXIMUM SCIENCE
/datum/job_objective/further_research
	completion_payment = 5
	per_unit = 1

/datum/job_objective/further_research/get_description()
	var/desc = "Проводите исследования во всех областях, и отправьте ваши наработки на ЦК карго-шаттлом!"
	desc += "([units_completed] областей исследовано.)"
	return sanitize_local(desc)

/datum/job_objective/further_research/check_for_completion()
	for(var/tech in shuttle_master.techLevels)
		if(shuttle_master.techLevels[tech] > 0)
			return 1
	return 0

/////////////////////////////////////////////////////////////////////////////////////////
// Robotics
/////////////////////////////////////////////////////////////////////////////////////////

//Cyborgs
/datum/job_objective/make_cyborg
	completion_payment = 100
	per_unit = 1

/datum/job_objective/make_cyborg/get_description()
	var/desc = "Создайте киборга."
	desc += "([units_completed] создано.)"
	return sanitize_local(desc)



//Mechas! RIPLEY
/datum/job_objective/make_ripley
	completion_payment = 200
	per_unit = 1

/datum/job_objective/make_ripley/get_description()
	var/desc = "Создайте мехаскафандр класса Ripley или Firefighter."
	desc += "([units_completed] создано.)"
	return sanitize_local(desc)

//ODYSSEUS
/datum/job_objective/make_odysseus
	completion_payment = 400
	per_unit = 1

/datum/job_objective/make_odysseus/get_description()
	var/desc = "Создайте мехаскафандр класса Odysseus."
	desc += "([units_completed] создано.)"
	return sanitize_local(desc)

//DURAND
/datum/job_objective/make_durand
	completion_payment = 400
	per_unit = 1

/datum/job_objective/make_durand/get_description()
	var/desc = "Создайте мехаскафандр класса Durand."
	desc += "([units_completed] создано.)"
	return sanitize_local(desc)

//PHAZON
/datum/job_objective/make_phazon
	completion_payment = 600
	per_unit = 1

/datum/job_objective/make_phazon/get_description()
	var/desc = "Создайте мехаскафандр класса Phazon."
	desc += "([units_completed] создано.)"
	return sanitize_local(desc)

//HONKER
/datum/job_objective/make_honker
	completion_payment = 555
	per_unit = 1

/datum/job_objective/make_honker/get_description()
	var/desc = "Создайте мехаскафандр класса H.O.N.K."
	desc += "([units_completed] создано.)"
	return sanitize_local(desc)

//GYGAX
/datum/job_objective/make_gygax
	completion_payment = 600
	per_unit = 1

/datum/job_objective/make_gygax/get_description()
	var/desc = "Создайте мехаскафандр класса Gygax"
	desc += "([units_completed] создано.)"
	return sanitize_local(desc)
