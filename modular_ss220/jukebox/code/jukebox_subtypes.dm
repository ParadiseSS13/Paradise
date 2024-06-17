/obj/machinery/jukebox/bar
	need_coin = TRUE

/obj/machinery/jukebox/disco
	name = "\proper танцевальный диско-шар - тип IV"
	desc = "Первые три прототипа были сняты с производства после инцидентов с массовыми жертвами."
	icon_state = "disco"
	base_icon_state = "disco"
	max_integrity = 300
	integrity_failure = 150
	var/list/rangers = list()

	/// Spotlight effects being played
	VAR_PRIVATE/list/obj/item/flashlight/spotlight/spotlights = list()
	/// Sparkle effects being played
	VAR_PRIVATE/list/obj/effect/overlay/sparkles/sparkles = list()

/obj/machinery/jukebox/disco/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/jukebox/disco/activate_music()
	. = ..()
	if(!.)
		return
	dance_setup()
	lights_spin()
	START_PROCESSING(SSobj, src)

/obj/machinery/jukebox/disco/stop_music()
	. = ..()
	if(!.)
		return
	QDEL_LIST_CONTENTS(spotlights)
	QDEL_LIST_CONTENTS(sparkles)
	STOP_PROCESSING(SSobj, src)

/obj/machinery/jukebox/disco/process()
	for(var/mob/living/dancer in music_player.get_active_listeners())
		if(!(dancer.mobility_flags & MOBILITY_MOVE))
			continue
		dance(dancer)

/obj/machinery/jukebox/concertspeaker
	name = "\proper концертная установка"
	desc = "Концертная колонка, которая используется для воспроизведения концертной записи."
	icon = 'modular_ss220/jukebox/icons/jukebox.dmi'
	icon_state = "concertspeaker_unanchored"
	base_icon_state = "concertspeaker"
	jukebox_type = /datum/jukebox/concertspeaker
	anchored = FALSE
	var/receiving = FALSE
	var/code = 0
	var/frequency = 1400

/obj/machinery/jukebox/concertspeaker/examine()
	. = ..()
	. += "<span class='notice'>Используйте гаечный ключ, чтобы разобрать для транспортировки и собрать для игры.</span>"

/obj/machinery/jukebox/concertspeaker/wrench_act()
	. = ..()
	icon_state = "[base_icon_state][anchored ? null : "_unanchored"]"

/obj/machinery/jukebox/concertspeaker/update_icon_state()
	if(stat & (BROKEN))
		icon_state = "[base_icon_state]_broken"
	else
		icon_state = "[base_icon_state][music_player.active_song_sound ? "_active" : null]"

/obj/machinery/jukebox/concertspeaker/Initialize()
	. = ..()
	GLOB.remote_signalers |= src

/obj/machinery/jukebox/concertspeaker/activate_music()
	. = ..()
	signal()

/obj/machinery/jukebox/concertspeaker/stop_music()
	. = ..()
	signal()

/obj/machinery/jukebox/concertspeaker/proc/signal()
	for(var/obj/item/assembly/signaler/S as anything in GLOB.remote_signalers)
		if(S == src)
			continue
		if(S.receiving && (S.code == code) && (S.frequency == frequency))
			S.signal_callback()
