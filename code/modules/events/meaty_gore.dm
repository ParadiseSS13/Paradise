/datum/event/meteor_wave/gore/announce()
		GLOB.minor_announcement.Announce("Неизвестные биологические отходы были обнаружены вблизи [station_name()], ожидайте.", "ВНИМАНИЕ: Космический мусор.")

/datum/event/meteor_wave/gore/setup()
	waves = 3

/datum/event/meteor_wave/gore/get_meteor_count()
	return rand(5, 8)

/datum/event/meteor_wave/gore/get_meteors()
	return GLOB.meteors_gore

/datum/event/meteor_wave/gore/end()
	GLOB.minor_announcement.Announce("Станция прошла загрязненный участок.", "ВНИМАНИЕ: Космический мусор.")
