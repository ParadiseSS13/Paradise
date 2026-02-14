/datum/satellite_stats
	var/weight = 0
	var/fuel_efficiency = 0
	var/fuel_capacity = 0
	var/science_multiplier = 0
	var/power_generation = 0
	var/power_storage = 0
	var/power_consumption = 0
	var/power_capacity = 0


/datum/satellite_stats/computer/basic
	weight = 10
	power_consumption = 10
	science_multiplier = 10
	power_capacity = 10

/datum/satellite_stats/computer/science
	weight = 10
	power_consumption = 25
	science_multiplier = 20
	power_capacity = 10

/datum/satellite_stats/computer/efficient
	weight = 10
	power_consumption = 7
	science_multiplier = 5
	power_capacity = 10

/datum/satellite_stats/engine/basic_engine
	weight = 10
	fuel_capacity = 10
	fuel_efficiency = 10
	power_generation = 1

/datum/satellite_stats/engine/small_engine
	weight = 5
	fuel_capacity = 5
	fuel_efficiency = 7
	power_generation = 1

/datum/satellite_stats/engine/ion_engine
	weight = 10
	fuel_capacity = 1
	fuel_efficiency = 50
	power_consumption = 10

/datum/satellite_stats/science_instrument/meteorological_surveyor
	weight = 10
	power_consumption = 10

/datum/satellite_stats/science_instrument/plasma_lab
	weight = 10
	power_consumption = 5

/datum/satellite_stats/science_instrument/magnetometer
	weight = 10
	power_consumption = 10

/datum/satellite_stats/misc_part/solar_panel
	weight = 2
	power_generation = 5

/datum/satellite_stats/misc_part/electric_generator
	weight = 5
	power_generation = 20

/datum/satellite_stats/misc_parts/power_cell
	weight = 5
	power_capacity = 20
