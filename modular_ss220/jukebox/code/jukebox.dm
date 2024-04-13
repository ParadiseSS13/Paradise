/obj/machinery/jukebox
	name = "\proper музыкальный автомат"
	desc = "Классический музыкальный автомат."
	icon = 'modular_ss220/jukebox/icons/jukebox.dmi'
	icon_state = "jukebox"
	base_icon_state = "jukebox"
	atom_say_verb =  "states"
	anchored = TRUE
	density = TRUE
	idle_power_consumption = 10
	active_power_consumption = 100
	max_integrity = 200
	integrity_failure = 100
	req_access = list(ACCESS_BAR)
	/// Cooldown between "Error" sound effects being played
	COOLDOWN_DECLARE(jukebox_error_cd)
	/// Cooldown between being allowed to play another song
	COOLDOWN_DECLARE(jukebox_song_cd)
	/// TimerID to when the current song ends
	var/song_timerid
	/// Does Jukebox require coin?
	var/need_coin = FALSE
	/// Inserted coin for payment
	var/obj/item/coin/payment
	/// The actual music player datum that handles the music
	var/datum/jukebox/music_player
	// Type of music_player
	var/jukebox_type = /datum/jukebox

/obj/machinery/jukebox/Initialize(mapload)
	. = ..()
	music_player = new jukebox_type(src)

/obj/machinery/jukebox/Destroy()
	stop_music()
	QDEL_NULL(payment)
	QDEL_NULL(music_player)
	return ..()

/obj/machinery/jukebox/wrench_act(mob/user, obj/item/tool)
	if(music_player.active_song_sound || (resistance_flags & INDESTRUCTIBLE))
		return
	. = TRUE
	if(!tool.use_tool(src, user, 0, volume = tool.tool_volume))
		return
	if(!anchored && !isinspace())
		anchored = TRUE
		WRENCH_ANCHOR_MESSAGE
	else if(anchored)
		anchored = FALSE
		WRENCH_UNANCHOR_MESSAGE
	playsound(src, 'sound/items/deconstruct.ogg', 50, 1)

/obj/machinery/jukebox/update_icon_state()
	if(stat & (BROKEN))
		icon_state = "[base_icon_state]_broken"
	else
		icon_state = "[base_icon_state][music_player.active_song_sound ? "-active" : null]"

/obj/machinery/jukebox/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & (NOPOWER|BROKEN))
		return
	if(music_player.active_song_sound)
		underlays += emissive_appearance(icon, "[icon_state]_lightmask")

/obj/machinery/jukebox/attack_hand(mob/user)
	if(!anchored)
		to_chat(user, span_warning("Это устройство должно быть закреплено гаечным ключом!"))
		return
	if(!length(music_player.songs))
		to_chat(user, span_warning("Ошибка: Для вашей станции не было авторизовано ни одной музыкальной композиции. Обратитесь к Центральному командованию с просьбой решить эту проблему."))
		user.playsound_local(src, 'sound/misc/compiler-failure.ogg', 25, TRUE)
		return
	ui_interact(user)

/obj/machinery/jukebox/attack_ghost(mob/user)
	if(anchored)
		return ui_interact(user)

/obj/machinery/jukebox/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/coin))
		if(payment)
			to_chat(user, span_info("Монетка уже вставлена."))
			return
		if(!user.drop_item())
			to_chat(user, span_warning("Монетка выскользнула с вашей руки!"))
			return
		item.forceMove(src)
		payment = item
		to_chat(user, span_notice("Вы вставили [item] в музыкальный автомат."))
		playsound(src, 'modular_ss220/aesthetics_sounds/sound/coin_accept.ogg', 50, TRUE)
		ui_interact(user)
		add_fingerprint(user)
	if(item.GetID())
		if(allowed(user))
			need_coin = !need_coin
			to_chat(user, span_notice("Вы [need_coin ? "вернули" : "сняли"] ограничения [need_coin ? "в" : "с"] [src]."))
		else
			to_chat(user, span_warning("Access denied."))
			return


/obj/machinery/jukebox/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/jukebox/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Jukebox", name)
		ui.open()

/obj/machinery/jukebox/ui_data(mob/user)
	var/list/data = ..()
	music_player.get_ui_data(data)

	data["need_coin"] = need_coin
	data["payment"] = payment
	data["advanced_admin"] = user.can_advanced_admin_interact()

	return data

/obj/machinery/jukebox/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle")
			if(isnull(music_player.active_song_sound))
				if(!COOLDOWN_FINISHED(src, jukebox_song_cd))
					to_chat(usr, span_warning("Ошибка: Устройство перезагружается после предыдущего трека, \
						Оно будет готово через [DisplayTimeText(COOLDOWN_TIMELEFT(src, jukebox_song_cd))]."))
					if(COOLDOWN_FINISHED(src, jukebox_error_cd))
						playsound(src, 'sound/misc/compiler-failure.ogg', 33, TRUE)
						COOLDOWN_START(src, jukebox_error_cd, 15 SECONDS)
					return TRUE

				activate_music()
			else
				stop_music()

			return TRUE

		if("select_track")
			if(!isnull(music_player.active_song_sound))
				to_chat(usr, span_warning("Ошибка: Вы не можете сменить трек, пока не закончится текущий."))
				return TRUE

			var/datum/track/new_song = music_player.songs[params["track"]]
			if(QDELETED(src) || !istype(new_song, /datum/track))
				return TRUE

			music_player.selection = new_song
			return TRUE

		if("set_volume")
			var/new_volume = params["volume"]
			if(new_volume == "reset")
				music_player.reset_volume()
			else if(new_volume == "min")
				music_player.set_new_volume(0)
			else if(new_volume == "max")
				music_player.set_volume_to_max()
			else if(isnum(text2num(new_volume)))
				music_player.set_new_volume(text2num(new_volume))
			return TRUE

		if("loop")
			music_player.sound_loops = !!params["looping"]
			return TRUE

/obj/machinery/jukebox/proc/activate_music()
	if(!isnull(music_player.active_song_sound))
		return FALSE

	music_player.start_music()
	change_power_mode(ACTIVE_POWER_USE)
	update_icon()
	if(!music_player.sound_loops)
		song_timerid = addtimer(CALLBACK(src, PROC_REF(stop_music)), music_player.selection.song_length, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_DELETE_ME)
	return TRUE

/obj/machinery/jukebox/proc/stop_music()
	if(!isnull(song_timerid))
		deltimer(song_timerid)

	music_player.unlisten_all()
	music_player.endTime = 0
	music_player.startTime = 0
	QDEL_NULL(payment)

	if(!QDELING(src))
		COOLDOWN_START(src, jukebox_song_cd, 5 SECONDS)
		playsound(src,'sound/machines/terminal_off.ogg', 50, TRUE)
		change_power_mode(IDLE_POWER_USE)
		update_icon()
	return TRUE

/obj/machinery/jukebox/obj_break()
	if(stat & BROKEN)
		return
	stat |= BROKEN
	idle_power_consumption = 0
	stop_music()
