/datum/event/aurora_caelus
	announceWhen = 5
	startWhen = 1
	endWhen = 50
	var/list/aurora_colors = list("#A2FF80", "#A2FF8B", "#A2FF96", "#A2FFA5", "#A2FFB6", "#A2FFC7", "#A2FFDE")
	var/aurora_progress = 0 //this cycles from 1 to 7, slowly changing colors from gentle green to gentle blue

/datum/event/aurora_caelus/announce()
	event_announcement.Announce("[station_name()]: A harmless cloud of ions is approaching your station, and will exhaust their energy battering the hull. \
Nanotrasen has approved a short break for all employees to relax and observe this very rare event. \
During this time, starlight will be bright but gentle, shifting between quiet green and blue colors. \
Any staff who would like to view these lights for themselves may proceed to the area nearest to them with viewing ports to open space. \
We hope you enjoy the lights.", "Harmless ions approaching", new_sound = 'sound/misc/notice2.ogg', from = "Nanotrasen Meteorology Division")
	for(var/V in GLOB.player_list)
		var/mob/M = V
		if((M.client.prefs.toggles & SOUND_MIDI) && is_station_level(M.z))
			M.playsound_local(null, 'sound/ambience/aurora_caelus.ogg', 20, FALSE, pressure_affected = FALSE)

/datum/event/aurora_caelus/start()
	for(var/s in GLOB.station_level_space_turfs)
		var/turf/space/S = s
		S.set_light(S.light_range * 3, S.light_power * 0.5, aurora_colors[1])
		CHECK_TICK

/datum/event/aurora_caelus/tick()
	if(aurora_progress >= aurora_colors.len)
		return
	if(activeFor % 5 == 0)
		aurora_progress++
		var/aurora_color = aurora_colors[aurora_progress]
		for(var/s in GLOB.station_level_space_turfs)
			var/turf/space/S = s
			S.set_light(l_color = aurora_color)
			CHECK_TICK

/datum/event/aurora_caelus/end()
	for(var/s in GLOB.station_level_space_turfs)
		var/turf/space/S = s
		fade_to_black(S)
	event_announcement.Announce("The Aurora Caelus event is now ending. Starlight conditions will slowly return to normal. \
When this has concluded, please return to your workplace and continue work as normal. \
Have a pleasant shift, [station_name()], and thank you for watching with us.",
"Harmless ions dissipating", new_sound = 'sound/misc/notice2.ogg', from = "Nanotrasen Meteorology Division")

/datum/event/aurora_caelus/proc/fade_to_black(turf/space/S)
	set waitfor = FALSE
	var/new_light = config.starlight
	while(S.light_range > new_light)
		S.set_light(S.light_range - 0.2)
		sleep(30)
	S.set_light(new_light, 1, l_color = "") // we should be able to use `, null` as the last arg but BYOND is a piece of FUCKING SHIT AND SET_LIGHT DOESN'T WORK THAT WAY DESPITE EVERY FUCKING THING ABOUT IT INDICATING THAT IT GODDAMN WELL SHOULD AAAAAAAAAAAAAAAAA
