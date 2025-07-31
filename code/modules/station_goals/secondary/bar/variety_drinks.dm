/datum/station_goal/secondary/variety_reagent/bar
	name = "Variety of Drinks"
	department = "Bar"
	generic_name_plural = "alcoholic drinks"
	weight = 1

/datum/station_goal/secondary/variety_reagent/bar/randomize_params()
	..()
	department_account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SERVICE)
	report_message = "We're hosting a party, and need a variety of alcoholic drinks. Send us at least [amount_per] units each of [different_types] different ones. Keep them separate, and don't include anything too simple; we have our own booze dispenser."
