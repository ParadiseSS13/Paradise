/datum/event/sleet_storm
	name =  "Sleet Storm"
	startWhen = 2
	endWhen = 3
	announceWhen = 1

/datum/event/sleet_storm/announce()
	GLOB.minor_announcement.Announce("A sleet storm has been detected to intercept the station. Do not leave the complex until the storm has passed!", "Incoming Sleet Storm", 'sound/AI/flare.ogg')

/datum/event/sleet_storm/start()
	SSweather.run_weather(/datum/weather/sleet_storm)
