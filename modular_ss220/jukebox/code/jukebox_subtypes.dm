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

// Drums
/obj/machinery/jukebox/drum_red
	name = "\proper красный барабан"
	desc = "Крутые барабаны от какой-то группы."
	icon_state = "drum_red_unanchored"
	base_icon_state = "drum_red"
	jukebox_type = /datum/jukebox/drum
	anchored = FALSE

/obj/machinery/jukebox/drum_red/wrench_act()
	. = ..()
	icon_state = "[base_icon_state][anchored ? null : "_unanchored"]"

/obj/machinery/jukebox/drum_red/update_icon_state()
	if(stat & (BROKEN))
		icon_state = "[base_icon_state]_broken"
	else
		icon_state = "[base_icon_state][music_player.active_song_sound ? "-active" : null]"

/obj/machinery/jukebox/drum_red/drum_yellow
	name = "\proper желтый барабан"
	icon_state = "drum_yellow_unanchored"
	base_icon_state = "drum_yellow"

/obj/machinery/jukebox/drum_red/drum_blue
	name = "\proper синий барабан"
	icon_state = "drum_blue_unanchored"
	base_icon_state = "drum_blue"

/datum/supply_packs/misc/bigband/New()
	. = ..()
	contains |= /obj/machinery/jukebox/drum_red
