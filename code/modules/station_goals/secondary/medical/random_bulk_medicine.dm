/datum/station_goal/secondary/random_bulk_reagent/medchem
	name = "Random Bulk Medicine"
	department = "Medbay"
	abstract = FALSE

/datum/station_goal/secondary/random_bulk_reagent/medchem/randomize_params()
	..()
	report_message = "Doctor, I've got a fever, and the only prescription, is more [initial(reagent_type.name)]. No, really, send us [amount] units of it, please."
