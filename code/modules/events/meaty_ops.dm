/datum/event/meteor_wave/goreop/announce()
	var/meteor_declaration = "Метеоритные оперативники заявили о своем намерении полностью уничтожить [station_name()] своими собственными телами. Осмелится ли экипаж остановить их?"
	GLOB.event_announcement.Announce(meteor_declaration, "Объявление 'Войны'", 'sound/effects/siren.ogg')

/datum/event/meteor_wave/goreop/setup()
	waves = 3


/datum/event/meteor_wave/goreop/tick()
	if(waves && activeFor >= next_meteor)
		spawn() spawn_meteors(5, GLOB.meteors_ops)
		next_meteor += rand(15, 30)
		waves--
		endWhen = (waves ? next_meteor + 1 : activeFor + 15)



/datum/event/meteor_wave/goreop/end()
	GLOB.event_announcement.Announce("Все метеориты мертвы. Майор Станция одержал победу.", "МЕТЕОРИТЫ.")
