/datum/event/solar_flare
	name =  "Solar Flare"
	startWhen = 2
	endWhen = 3
	announceWhen = 1

/datum/event/solar_flare/announce()
	GLOB.minor_announcement.Announce("A solar flare has been detected on collision course with the station. Do not conduct space walks or approach windows until the flare has passed!", "Incoming Solar Flare", 'sound/AI/flare.ogg')

/datum/event/solar_flare/start()
	SSweather.run_weather(/datum/weather/solar_flare)
