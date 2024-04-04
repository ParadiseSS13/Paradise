/datum/station_goal/secondary/random_bulk_reagent/kitchen
	name = "Random Bulk Condiment"
	department = "Kitchen"
	abstract = FALSE

/datum/station_goal/secondary/random_bulk_reagent/kitchen/randomize_params()
	..()
	department_account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SERVICE)
	report_message = "Steve drank all of our [initial(reagent_type.name)]. Please send us another [amount] units of it."
