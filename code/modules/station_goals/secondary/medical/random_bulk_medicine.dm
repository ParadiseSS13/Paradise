/datum/station_goal/secondary/random_bulk_reagent/medchem
	name = "Random Bulk Medicine"
	department = "Chemistry"
	weight = 9

/datum/station_goal/secondary/random_bulk_reagent/medchem/randomize_params()
	..()
	department_account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_MEDICAL)
	report_message = "Doctor, I've got a fever, and the only prescription, is more [initial(reagent_type.name)]. No, really, send us [amount] units of it, please."
