/datum/station_goal/secondary/variety_reagent/scichem
	name = "Variety of Chemicals"
	different_types = 5
	department = "Science"
	generic_name_plural = "chemicals"
	weight = 1

/datum/station_goal/secondary/variety_reagent/scichem/randomize_params()
	..()
	department_account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SCIENCE)
	report_message = "We're training a drug moose, and need some samples of drugs. Send us at least [amount_per] units each of [different_types] different ones. --Not Steve"
