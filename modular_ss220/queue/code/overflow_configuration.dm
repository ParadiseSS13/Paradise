/datum/configuration_section/overflow_configuration
	var/reservation_time = 1 MINUTES

/datum/configuration_section/overflow_configuration/load_data(list/data)
	. = ..()

	CONFIG_LOAD_NUM(reservation_time, data["reservation_time"])
