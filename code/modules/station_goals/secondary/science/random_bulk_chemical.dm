/datum/station_goal/secondary/random_bulk_reagent/scichem
	name = "Random Bulk Chemical"
	department = "Science"
	weight = 9

/datum/station_goal/secondary/random_bulk_reagent/scichem/randomize_params()
	..()
	department_account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SCIENCE)
	report_message = "We're running an experiment with [initial(reagent_type.name)] and need more. Please send us [amount] units of it."
