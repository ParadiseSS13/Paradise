/datum/event/radiation_storm
	name = "Radiation Storm"
	nominal_severity = EVENT_LEVEL_MODERATE
	role_weights = list(ASSIGNMENT_MEDICAL = 5)
	role_requirements = list(ASSIGNMENT_MEDICAL = 5)

/datum/event/radiation_storm/setup()
	startWhen = 3
	endWhen = startWhen + 1
	announceWhen = 1

/datum/event/radiation_storm/announce()
	GLOB.minor_announcement.Announce("High levels of radiation detected near the station. Maintenance is best shielded from radiation.", "Anomaly Alert", 'sound/AI/radiation.ogg')
	//sound not longer matches the text, but an audible warning is probably good

/datum/event/radiation_storm/start()
	SSweather.run_weather(/datum/weather/rad_storm)
