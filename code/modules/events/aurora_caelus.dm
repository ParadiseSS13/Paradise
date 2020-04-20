/datum/event/aurora_caelus
	announceWhen = 5
	startWhen = 1
	endWhen = 50
	var/list/aurora_colors = list("#A2FF80", "#A2FF8B", "#A2FF96", "#A2FFA5", "#A2FFB6", "#A2FFC7", "#A2FFDE")
	var/aurora_progress = 0 //this cycles from 1 to 7, slowly changing colors from gentle green to gentle blue

/datum/event/aurora_caelus/announce()
	GLOB.event_announcement.Announce("[station_name()]: Una inofensiva nube de iones se acerca a su estacion lo que agotara su energia golpeando el casco. \
Nanotrasen ha aprobado un breve descanso para que todos los empleados se relajen y observen este raro evento. \
Durante este tiempo, la luz de las estrellas sera brillante pero suave, cambiando entre los tranquilos colores verde y azul. \
Cualquier miembro del personal que desee ver estas luces por si mismo puede dirigirse al area mas cercana a ellos en los puestos de visualizacion abiertos al espacio. \
Esperamos que disfruten las luces.", "Iones inofensivos acercandose", new_sound = 'sound/misc/notice2.ogg', from = "Division Meteorologica de Nanotrasen")
	for(var/V in GLOB.player_list)
		var/mob/M = V
		if((M.client.prefs.toggles & SOUND_MIDI) && is_station_level(M.z))
			M.playsound_local(null, 'sound/ambience/aurora_caelus.ogg', 20, FALSE, pressure_affected = FALSE)

/datum/event/aurora_caelus/start()
	for(var/area in GLOB.all_areas)
		var/area/A = area
		if(initial(A.dynamic_lighting) == DYNAMIC_LIGHTING_IFSTARLIGHT)
			for(var/turf/space/S in A)
				S.set_light(S.light_range * 3, S.light_power * 0.5)

/datum/event/aurora_caelus/tick()
	if(aurora_progress >= aurora_colors.len)
		return
	if(activeFor % 5 == 0)
		aurora_progress++
		var/aurora_color = aurora_colors[aurora_progress]
		for(var/area in GLOB.all_areas)
			var/area/A = area
			if(initial(A.dynamic_lighting) == DYNAMIC_LIGHTING_IFSTARLIGHT)
				for(var/turf/space/S in A)
					S.set_light(l_color = aurora_color)

/datum/event/aurora_caelus/end()
	for(var/area in GLOB.all_areas)
		var/area/A = area
		if(initial(A.dynamic_lighting) == DYNAMIC_LIGHTING_IFSTARLIGHT)
			for(var/turf/space/S in A)
				fade_to_black(S)
	GLOB.event_announcement.Announce("El evento Aurora Caelus ahora esta terminando. Las condiciones de la luz de las estrellas volveran lentamente a la normalidad. \
Cuando esto haya concluido, regrese a su lugar de trabajo y continue con el mismo normalmente. \
Ten un turno agradable, [station_name()], Y gracias por mirar con nosotros.",
"Iones inofensivos disipandose", new_sound = 'sound/misc/notice2.ogg', from = "Division Meteorologica de Nanotrasen")

/datum/event/aurora_caelus/proc/fade_to_black(turf/space/S)
	set waitfor = FALSE
	var/new_light = config.starlight
	while(S.light_range > new_light)
		S.set_light(S.light_range - 0.2)
		sleep(30)
	S.set_light(new_light, 1, l_color = "") // we should be able to use `, null` as the last arg but BYOND is a piece of FUCKING SHIT AND SET_LIGHT DOESN'T WORK THAT WAY DESPITE EVERY FUCKING THING ABOUT IT INDICATING THAT IT GODDAMN WELL SHOULD AAAAAAAAAAAAAAAAA
