/datum/event/solar_flare
	startWhen = 2
	endWhen = 3
	announceWhen = 1

/datum/event/solar_flare/announce()
	GLOB.event_announcement.Announce("A solar flare has been detected on collision course with the station.", "Incoming Solar Flare", 'sound/AI/attention.ogg')

/datum/event/solar_flare/start()
	SSweather.run_weather(/datum/weather/solar_flare)
