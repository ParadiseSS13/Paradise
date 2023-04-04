/datum/event/meteor_wave/gore/announce()
		GLOB.event_announcement.Announce("Unknown biological debris have been detected near [station_name()], please stand-by.", "Debris Alert")

/datum/event/meteor_wave/gore/setup()
	waves = 3

/datum/event/meteor_wave/gore/get_meteor_count()
	return rand(5, 8)

/datum/event/meteor_wave/gore/get_meteors()
	return GLOB.meteors_gore

/datum/event/meteor_wave/gore/end()
	GLOB.event_announcement.Announce("The station has cleared the debris.", "Debris Alert")
