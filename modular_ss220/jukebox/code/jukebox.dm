/obj/machinery/jukebox
	name = "\improper музыкальный автомат"
	desc = "Классический музыкальный автомат."
	icon = 'modular_ss220/jukebox/icons/jukebox.dmi'
	icon_state = "jukebox"
	atom_say_verb = "states"
	density = TRUE
	anchored = FALSE
	idle_power_consumption = 10
	active_power_consumption = 100
	max_integrity = 200
	integrity_failure = 100
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 20, ACID = 10)
	var/active = FALSE
	var/list/rangers = list()
	var/stop = 0
	var/list/songs = list()
	var/datum/track/selection = null
	var/volume = 25
	var/max_volume = 25
	var/songs_path = "config/jukebox_music/sounds/"
	COOLDOWN_DECLARE(jukebox_error_cd)

/obj/machinery/jukebox/anchored
	anchored = TRUE

/obj/machinery/jukebox/bar
	req_access = list(ACCESS_BAR)

/obj/machinery/jukebox/bar/anchored
	anchored = TRUE

/obj/machinery/jukebox/disco
	name = "\improper танцевальный диско-шар - тип IV"
	desc = "Первые три прототипа были сняты с производства после инцидентов с массовыми жертвами."
	icon_state = "disco"
	max_integrity = 300
	integrity_failure = 150
	volume = 50
	max_volume = 75
	var/list/spotlights = list()
	var/list/sparkles = list()

/obj/machinery/jukebox/disco/anchored
	anchored = TRUE

/obj/machinery/jukebox/disco/anchored/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE

/datum/track/New(name, path, length, beat)
	song_name = name
	song_path = path
	song_length = length
	song_beat = beat

/obj/machinery/jukebox/Initialize(mapload)
	. = ..()
	var/list/tracks = flist(songs_path)

	for(var/S in tracks)
		var/datum/track/T = new()
		T.song_path = file(songs_path + S)
		var/list/L = splittext(S,"+")
		if(L.len != 3)
			continue
		T.song_name = L[1]
		T.song_length = text2num(L[2])
		T.song_beat = text2num(L[3])
		songs |= T

	if(songs.len)
		selection = pick(songs)

/obj/machinery/jukebox/Destroy()
	dance_over()
	return ..()

/obj/machinery/jukebox/attackby(obj/item/O, mob/user, params)
	if(!active && !(resistance_flags & INDESTRUCTIBLE))
		if(iswrench(O))
			if(!anchored && !isinspace())
				to_chat(user, span_notice("You secure [src] to the floor."))
				anchored = TRUE
			else if(anchored)
				to_chat(user, span_notice("You unsecure and disconnect [src]."))
				anchored = FALSE
			playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
			return
	return ..()

/obj/machinery/jukebox/update_icon_state()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]_broken"
		return
	if(active)
		icon_state = "[initial(icon_state)]-active"
	else
		icon_state = "[initial(icon_state)]"

/obj/machinery/jukebox/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		underlays += emissive_appearance(icon, "[icon_state]_lightmask")

/obj/machinery/jukebox/power_change()
	if(!..())
		return
	if(stat & NOPOWER)
		turn_off()
		return ..()

/obj/machinery/jukebox/obj_break(damage_flag)
	if(!(stat & BROKEN))
		stat |= BROKEN
		turn_off()

/obj/machinery/jukebox/attack_hand(mob/user)
	..()
	src.add_fingerprint(user)
	if(!anchored)
		to_chat(user, span_warning("Это устройство должно быть закреплено гаечным ключом!"))
		return
	if(!allowed(user) && !isobserver(user))
		to_chat(user, span_warning("Ошибка: Отказано в доступе."))
		user.playsound_local(src, 'sound/misc/compiler-failure.ogg', 25, TRUE)
		return
	if(!songs.len && !isobserver(user))
		to_chat(user, span_warning("Ошибка: Для вашей станции не было авторизовано ни одной музыкальной композиции. Обратитесь к Центральному командованию с просьбой решить эту проблему."))
		user.playsound_local(src, 'sound/misc/compiler-failure.ogg', 25, TRUE)
		return
	if(stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)

/obj/machinery/jukebox/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/jukebox/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Jukebox", name)
		ui.open()

/obj/machinery/jukebox/ui_data(mob/user)
	var/list/data = list()
	data["active"] = active
	data["songs"] = list()
	for(var/datum/track/S in songs)
		var/list/track_data = list(
			name = S.song_name
		)
		data["songs"] += list(track_data)
	data["track_selected"] = null
	data["track_length"] = null
	data["track_beat"] = null
	if(selection)
		data["track_selected"] = selection.song_name
		data["track_length"] = DisplayTimeText(selection.song_length)
		data["track_beat"] = selection.song_beat
	data["volume"] = volume
	return data

/obj/machinery/jukebox/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle")
			if(QDELETED(src))
				return
			if(!active)
				if(stop > world.time)
					to_chat(usr, span_warning("Ошибка: Устройство находится в состоянии сброса, оно будет готово снова через [DisplayTimeText(stop-world.time)]."))
					if(!COOLDOWN_FINISHED(src, jukebox_error_cd))
						return
					playsound(src, 'sound/misc/compiler-failure.ogg', 50, TRUE)
					COOLDOWN_START(src, jukebox_error_cd, 5 SECONDS)
					return
				activate_music()
				START_PROCESSING(SSobj, src)
				return TRUE
			else
				stop = 0
				return TRUE
		if("select_track")
			if(active)
				to_chat(usr, span_warning("Ошибка: Вы не можете сменить композицию, пока не закончится текущая."))
				return
			var/list/available = list()
			for(var/datum/track/S in songs)
				available[S.song_name] = S
			var/selected = params["track"]
			if(QDELETED(src) || !selected || !istype(available[selected], /datum/track))
				return
			selection = available[selected]
			return TRUE
		if("set_volume")
			var/new_volume = params["volume"]
			if(new_volume  == "reset")
				volume = initial(volume)
				return TRUE
			else if(new_volume == "min")
				volume = 0
				return TRUE
			else if(new_volume == "max")
				volume = max_volume
				return TRUE
			else if(text2num(new_volume) != null)
				if(text2num(new_volume) > max_volume)
					volume = max_volume
				else
					volume = text2num(new_volume)
					return TRUE

/obj/machinery/jukebox/proc/activate_music()
	active = TRUE
	update_icon()
	START_PROCESSING(SSobj, src)
	stop = world.time + selection.song_length

/obj/machinery/jukebox/disco/activate_music()
	..()
	dance_setup()
	lights_spin()

/obj/machinery/jukebox/disco/proc/dance_setup()
	stop = world.time + selection.song_length
	var/turf/cen = get_turf(src)
	FOR_DVIEW(var/turf/t, 3, get_turf(src),INVISIBILITY_LIGHTING)
		if(t.x == cen.x && t.y > cen.y)
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = "red"
			L.light_power = 30 - (get_dist(src, L) * 8)
			L.range = 1+get_dist(src, L)
			spotlights+=L
			continue
		if(t.x == cen.x && t.y < cen.y)
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = "purple"
			L.light_power = 30 - (get_dist(src, L) * 8)
			L.range = 1+get_dist(src, L)
			spotlights+=L
			continue
		if(t.x > cen.x && t.y == cen.y)
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = "#ffff00"
			L.light_power = 30 - (get_dist(src, L) * 8)
			L.range = 1+get_dist(src, L)
			spotlights+=L
			continue
		if(t.x < cen.x && t.y == cen.y)
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = "green"
			L.light_power = 30 - (get_dist(src, L) * 8)
			L.range = 1+get_dist(src, L)
			spotlights+=L
			continue
		if((t.x+1 == cen.x && t.y+1 == cen.y) || (t.x+2==cen.x && t.y+2 == cen.y))
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = "sw"
			L.light_power = 30 - (get_dist(src, L) * 8)
			L.range = 1.4+get_dist(src, L)
			spotlights+=L
			continue
		if((t.x-1 == cen.x && t.y-1 == cen.y) || (t.x-2==cen.x && t.y-2 == cen.y))
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = "ne"
			L.light_power = 30 - (get_dist(src, L) * 8)
			L.range = 1.4+get_dist(src, L)
			spotlights+=L
			continue
		if((t.x-1 == cen.x && t.y+1 == cen.y) || (t.x-2==cen.x && t.y+2 == cen.y))
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = "se"
			L.light_power = 30 - (get_dist(src, L) * 8)
			L.range = 1.4+get_dist(src, L)
			spotlights+=L
			continue
		if((t.x+1 == cen.x && t.y-1 == cen.y) || (t.x+2==cen.x && t.y-2 == cen.y))
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = "nw"
			L.light_power = 30 - (get_dist(src, L) * 8)
			L.range = 1.4+get_dist(src, L)
			spotlights+=L
			continue
		continue
	END_FOR_DVIEW

/obj/machinery/jukebox/disco/proc/hierofunk()
	for(var/i in 1 to 10)
		new /obj/effect/temp_visual/hierophant/telegraph/edge(get_turf(src))
		sleep(0.5 SECONDS)

#define DISCO_INFENO_RANGE (rand(85, 115)*0.01)

/obj/machinery/jukebox/disco/proc/lights_spin()
	for(var/i in 1 to 25)
		if(QDELETED(src) || !active)
			return
		var/obj/effect/overlay/sparkles/S = new /obj/effect/overlay/sparkles(src)
		S.alpha = 0
		sparkles += S
		switch(i)
			if(1 to 8)
				spawn(0)
					S.orbit(src, 30, TRUE, 60, 36, TRUE, FALSE)
			if(9 to 16)
				spawn(0)
					S.orbit(src, 62, TRUE, 60, 36, TRUE, FALSE)
			if(17 to 24)
				spawn(0)
					S.orbit(src, 95, TRUE, 60, 36, TRUE, FALSE)
			if(25)
				S.pixel_y = 7
				S.forceMove(get_turf(src))
		sleep(0.7 SECONDS)
	for(var/obj/reveal in sparkles)
		reveal.alpha = 255
	while(active)
		for(var/obj/item/flashlight/spotlight/glow in spotlights) // The multiples reflects custom adjustments to each colors after dozens of tests
			if(QDELETED(src) || !active || QDELETED(glow))
				return
			if(glow.light_color == "red")
				glow.light_color = "nw"
				glow.light_power = glow.light_power * 1.48
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == "nw")
				glow.light_color = "green"
				glow.light_range = glow.range * DISCO_INFENO_RANGE
				glow.light_power = glow.light_power * 2 // Any changes to power must come in pairs to neutralize it for other colors
				glow.update_light()
				continue
			if(glow.light_color == "green")
				glow.light_color = "sw"
				glow.light_power = glow.light_power * 0.5
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == "sw")
				glow.light_color = "purple"
				glow.light_power = glow.light_power * 2.27
				glow.light_range = glow.range * DISCO_INFENO_RANGE
				glow.update_light()
				continue
			if(glow.light_color == "purple")
				glow.light_color = "se"
				glow.light_power = glow.light_power * 0.44
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == "se")
				glow.light_color = "#ffff00"
				glow.light_range = glow.range * DISCO_INFENO_RANGE
				glow.update_light()
				continue
			if(glow.light_color == "#ffff00")
				glow.light_color = "ne"
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == "ne")
				glow.light_color = "red"
				glow.light_power = glow.light_power * 0.68
				glow.light_range = glow.range * DISCO_INFENO_RANGE
				glow.update_light()
				continue
		if(prob(2))  // Unique effects for the dance floor that show up randomly to mix things up
			INVOKE_ASYNC(src, PROC_REF(hierofunk))
		sleep(selection.song_beat)

#undef DISCO_INFENO_RANGE

/obj/machinery/jukebox/disco/proc/dance(mob/living/M) //Show your moves
	set waitfor = FALSE
	if(M.client)
		if(!(M.client.prefs.toggles2 & PREFTOGGLE_2_DANCE_DISCO)) //they just dont wanna dance
			return
	switch(rand(0,9))
		if(0 to 1)
			dance2(M)
		if(2 to 3)
			dance3(M)
		if(4 to 6)
			dance4(M)
		if(7 to 9)
			dance5(M)

/obj/machinery/jukebox/disco/proc/dance2(mob/living/M)
	for(var/i = 1, i < 10, i++)
		for(var/d in list(NORTH, SOUTH, EAST, WEST, EAST, SOUTH, NORTH, SOUTH, EAST, WEST, EAST, SOUTH))
			M.setDir(d)
			if(i == WEST && !M.incapacitated())
				M.SpinAnimation(7, 1)
			sleep(0.1 SECONDS)
		sleep(2 SECONDS)

/obj/machinery/jukebox/disco/proc/dance3(mob/living/M)
	var/matrix/initial_matrix = matrix(M.transform)
	for(var/i in 1 to 75)
		if(!M)
			return
		switch(i)
			if(1 to 15)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(0, 1)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if(16 to 30)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(1, -1)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if(31 to 45)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(-1, -1)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if(46 to 60)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(-1, 1)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if(61 to 75)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(1, 0)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
		M.setDir(turn(M.dir, 90))
		switch(M.dir)
			if(NORTH)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(0,3)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if(SOUTH)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(0,-3)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if(EAST)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(3,0)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if(WEST)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(-3,0)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
		sleep(0.1 SECONDS)
	M.lying_fix()


/obj/machinery/jukebox/disco/proc/dance4(mob/living/M)
	var/speed = rand(1, 3)
	set waitfor = 0
	var/time = 30
	while(time)
		sleep(speed)
		for(var/i in 1 to speed)
			M.setDir(pick(GLOB.cardinal))
			if(IS_HORIZONTAL(M))
				M.stand_up()
			else
				M.lay_down()
		time--

/obj/machinery/jukebox/disco/proc/dance5(mob/living/M)
	animate(M, transform = matrix(180, MATRIX_ROTATE), time = 1, loop = 0)
	var/matrix/initial_matrix = matrix(M.transform)
	for(var/i in 1 to 60)
		if(!M)
			return
		if(i<31)
			initial_matrix = matrix(M.transform)
			initial_matrix.Translate(0,1)
			animate(M, transform = initial_matrix, time = 1, loop = 0)
		if(i>30)
			initial_matrix = matrix(M.transform)
			initial_matrix.Translate(0,-1)
			animate(M, transform = initial_matrix, time = 1, loop = 0)
		M.setDir(turn(M.dir, 90))
		switch(M.dir)
			if(NORTH)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(0,3)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if(SOUTH)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(0,-3)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if(EAST)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(3,0)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
			if(WEST)
				initial_matrix = matrix(M.transform)
				initial_matrix.Translate(-3,0)
				animate(M, transform = initial_matrix, time = 1, loop = 0)
		sleep(0.1 SECONDS)
	M.lying_fix()

/obj/machinery/jukebox/proc/dance_over()
	for(var/mob/living/L in rangers)
		if(!L || !L.client)
			continue
		L.stop_sound_channel(CHANNEL_JUKEBOX)
	rangers = list()

/obj/machinery/jukebox/disco/dance_over()
	..()
	QDEL_LIST_CONTENTS(spotlights)
	QDEL_LIST_CONTENTS(sparkles)

/obj/machinery/jukebox/proc/turn_off()
	active = FALSE
	change_power_mode(IDLE_POWER_USE)
	STOP_PROCESSING(SSobj, src)
	dance_over()
	playsound(src,'sound/machines/terminal_off.ogg',50,1)
	update_icon()
	stop = world.time + 3 SECONDS

/obj/machinery/jukebox/process()
	if(world.time < stop && active)
		var/sound/song_played = sound(selection.song_path)
		if(active)
			active_power_consumption = (volume * 10)
			change_power_mode(ACTIVE_POWER_USE)
		for(var/mob/M in range(14,src))
			if(!M.client)
				continue
			if(!(M in rangers))
				rangers[M] = TRUE
				M.playsound_local(get_turf(M), null, volume, channel = CHANNEL_JUKEBOX, S = song_played)
		for(var/mob/L in rangers)
			if(get_dist(src, L) > 14)
				rangers -= L
				if(!L || !L.client)
					continue
				L.stop_sound_channel(CHANNEL_JUKEBOX)
	else if(active)
		turn_off()

/obj/machinery/jukebox/disco/process()
	. = ..()
	if(active)
		for(var/mob/living/M in rangers)
			if(prob(5+(allowed(M)*4)) && (M.mobility_flags & MOBILITY_MOVE))
				dance(M)

//Drum

/obj/machinery/jukebox/drum_red
	name = "\improper красный барабан"
	desc = "Крутые барабаны от какой-то группы."
	icon = 'modular_ss220/jukebox/icons/jukebox.dmi'
	icon_state = "drum_red"
	songs_path = "config/drum_music/"

/obj/machinery/jukebox/drum_red/update_icon_state()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]_broken"
		return
	icon_state = "[initial(icon_state)]"

	if(active)
		icon_state = "[initial(icon_state)]-active"
	else if(anchored)
		icon_state = "[initial(icon_state)]_anchored"

/obj/machinery/jukebox/drum_red/attackby(obj/item/O, mob/user, params)
	if(active || (resistance_flags & INDESTRUCTIBLE))
		return

	if(!iswrench(O))
		return ..()

	if(!anchored && !isinspace())
		to_chat(user, span_notice("You secure [src] to the floor."))
		anchored = TRUE
		update_icon()
	else if(anchored)
		to_chat(user, span_notice("You unsecure and disconnect [src]."))
		anchored = FALSE
		update_icon()

	playsound(src, 'sound/items/deconstruct.ogg', 50, 1)

/obj/machinery/jukebox/drum_red/drum_yellow
	name = "\improper желтый барабан"
	icon_state = "drum_yello"

/obj/machinery/jukebox/drum_red/drum_blue
	name = "\improper синий барабан"
	icon_state = "drum_blue"

