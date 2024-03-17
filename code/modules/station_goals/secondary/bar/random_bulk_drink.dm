/datum/station_goal/secondary/random_bulk_reagent/bar
	name = "Random Bulk Drink"
	department = "Bar"
	abstract = FALSE

/datum/station_goal/secondary/random_bulk_reagent/bar/randomize_params()
	..()
	report_message = "A visiting dignitary loves [initial(reagent_type.name)]. Please send us at least [amount] units of it."
