/datum/station_goal/secondary/random_bulk_reagent/scichem
	name = "Random Bulk Chemical"
	department = "Science"
	abstract = FALSE

/datum/station_goal/secondary/random_bulk_reagent/scichem/randomize_params()
	..()
	account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SCIENCE)
	reward = SSeconomy.credits_per_scichem_goal
	report_message = "We're running an experiment with [initial(reagent_type.name)] and need more. Please send us [amount] units of it."
