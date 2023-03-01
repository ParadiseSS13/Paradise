/datum/event/meteor_wave/gore/announce()
		GLOB.event_announcement.Announce("Неизвестный биологический мусор был обнаружен рядом с [station_name()], пожалуйста, будьте наготове.", "ВНИМАНИЕ: ОБЛОМКИ.")

/datum/event/meteor_wave/gore/setup()
	waves = 3


/datum/event/meteor_wave/gore/tick()
	if(waves && activeFor >= next_meteor)
		spawn() spawn_meteors(rand(5,8), GLOB.meteors_gore)
		next_meteor += rand(15, 30)
		waves--
		endWhen = (waves ? next_meteor + 1 : activeFor + 15)


/datum/event/meteor_wave/gore/end()
	GLOB.event_announcement.Announce("Станция прошла через обломки.", "ВНИМАНИЕ: ОБЛОМКИ.")
