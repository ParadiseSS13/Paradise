/datum/event/solar_flare
	startWhen = 2
	endWhen = 3
	announceWhen = 1

/datum/event/solar_flare/announce()
	GLOB.minor_announcement.Announce("Солнечная вспышка зафиксирована на встречном со станцией курсе. Не выходите в открытый космос и не приближайтесь к окнам до конца вспышки.", "ВНИМАНИЕ: Солнечная вспышка.", 'sound/AI/flare.ogg')

/datum/event/solar_flare/start()
	SSweather.run_weather(/datum/weather/solar_flare)
