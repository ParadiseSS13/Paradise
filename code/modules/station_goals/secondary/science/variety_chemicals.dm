/datum/station_goal/secondary/variety_reagent/scichem
	name = "Variety of Chemicals"
	progress_type = /datum/secondary_goal_progress/variety_reagent
	department = "Science"
	generic_name_plural = "chemicals"
	abstract = FALSE

/datum/station_goal/secondary/variety_reagent/bar/randomize_params()
	..()
	report_message = "We're training a drug moose, and need some samples of drugs. Send us at least [amount_per] units of [different_types] different ones. --Not Steve"
