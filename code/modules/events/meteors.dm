/datum/event/meteor_wave
	startWhen		= 5
	endWhen 		= 7
	var/next_meteor = 6
	var/waves = 1

/datum/event/meteor_wave/setup()
	waves = severity * rand(1,3)

/datum/event/meteor_wave/announce()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			GLOB.event_announcement.Announce("Se han detectado meteoros en curso de colision con la estacion.", "Alerta de Meteoros", new_sound = 'sound/AI/meteors.ogg')
		else
			GLOB.event_announcement.Announce("La estacion esta bajo una lluvia de meteoros.", "Alerta de Meteoros")

//meteor showers are lighter and more common,
/datum/event/meteor_wave/tick()
	if(waves && activeFor >= next_meteor)
		spawn() spawn_meteors(severity * rand(1,2), get_meteors())
		next_meteor += rand(15, 30) / severity
		waves--
		endWhen = (waves ? next_meteor + 1 : activeFor + 15)

/datum/event/meteor_wave/end()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			GLOB.event_announcement.Announce("La estacion se ha despejado la tormenta de meteoritos.", "Alerta de Meteoros")
		else
			GLOB.event_announcement.Announce("Se ha despejado la lluvia de meteoritos", "Alerta de Meteoros")

/datum/event/meteor_wave/proc/get_meteors()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			return GLOB.meteors_catastrophic
		if(EVENT_LEVEL_MODERATE)
			return GLOB.meteors_threatening
		else
			return GLOB.meteors_normal
