/datum/event/aurora_caelus
	name = "Aurora Caelus"
	nominal_severity = EVENT_LEVEL_MAJOR
	endWhen = 50
	/// List of colors that the aurora takes
	var/list/aurora_colors = list("#A2FF80", "#A2FF8B", "#A2FF96", "#A2FFA5", "#A2FFAF", "#A2FFB6", "#A2FFC1", "#A2FFC7", "#A2FFDE", "#A2FFEE")
	/// Event stage
	var/aurora_progress = 0
	/// Target light range
	var/aurora_light_range = 4

/datum/event/aurora_caelus/announce(false_alarm)
	. = ..()
	GLOB.major_announcement.Announce(
		"[station_name()]: A harmless cloud of ions is approaching your station, and will exhaust their energy battering the hull. During this time, starlight will be bright but gentle, shifting between quiet green and blue colors. \n\nNanotrasen has approved a short break for all employees to relax and observe this very rare event. Any staff who would like to view these lights for themselves may proceed to the area nearest to them with viewing ports to open space. \n\nWe hope you enjoy the lights.",
		"Nanotrasen Meteorology Division",
		'sound/misc/announce.ogg'
	)

/datum/event/aurora_caelus/start()
	addtimer(CALLBACK(src, PROC_REF(start_music)), 5 SECONDS)

/datum/event/aurora_caelus/tick()
	. = ..()
	if(activeFor % 5 == 0)
		aurora_progress++
		var/aurora_color = aurora_colors[aurora_progress]
		for(var/turf/spess in GLOB.starlight)
			if(isspaceturf(spess))
				spess.set_light(aurora_light_range, 1.2, aurora_color)
				continue
			spess.set_light(aurora_light_range, initial(spess.light_power) * 0.6, aurora_color)

/datum/event/aurora_caelus/end()
	. = ..()
	for(var/turf/spess in GLOB.starlight)
		fade_back(spess)
	GLOB.major_announcement.Announce("The Aurora Caelus event is now ending. Starlight conditions will slowly return to normal. When this has concluded, please return to your workplace and continue work as normal. \n\nHave a pleasant shift, [station_name()], and thank you for watching with us.",
		"Nanotrasen Meteorology Division",
		'sound/misc/announce.ogg'
	)

/datum/event/aurora_caelus/proc/start_music()
	for(var/mob/M in GLOB.player_list)
		if(!M.client || isnewplayer(M))
			continue
		if(M.client.prefs.sound & SOUND_MIDI)
			M.playsound_local(M, 'sound/ambience/aurora_caelus.ogg', 20, FALSE, pressure_affected = FALSE)

/datum/event/aurora_caelus/proc/fade_back(turf/spess, target_light_range = 2, target_light_power = 2)
	if(!isspaceturf(spess))
		target_light_range = initial(spess.light_range)
		target_light_power = initial(spess.light_power)
	if(spess.light_range > target_light_range)
		spess.set_light(spess.light_range - 0.2, target_light_power)
		addtimer(CALLBACK(src, PROC_REF(fade_back), spess), 3 SECONDS)
		return
	spess.set_light(initial(spess.light_range), initial(spess.light_power), initial(spess.light_color))
	if(isspaceturf(spess))
		var/turf/space/spess_turf = spess
		spess_turf.update_starlight()
