/datum/station_goal/secondary/variety_reagent/medchem
	name = "Variety of Medicine"
	department = "Chemistry"
	generic_name_plural = "medicines"
	weight = 1

/datum/station_goal/secondary/variety_reagent/medchem/randomize_params()
	..()
	department_account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_MEDICAL)
	report_message = "A refrigiration failure on a smaller station has left them critically low on supplies. Please send us at least [amount_per] units each of [different_types] different medicines. Pills, patches, bottles, however you can send them, just keep the medicines from mixing."
