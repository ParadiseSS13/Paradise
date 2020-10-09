/obj/structure/musician
	name = "Not A Piano"
	desc = "Something broke!"
	var/can_play_unanchored = FALSE
	var/list/allowed_instrument_ids
	var/datum/song/song

/obj/structure/musician/Initialize(mapload)
	. = ..()
	song = new(src, allowed_instrument_ids)
	allowed_instrument_ids = null

/obj/structure/musician/Destroy()
	QDEL_NULL(song)
	return ..()

/obj/structure/musician/attack_hand(mob/user)
	add_fingerprint(user)
	tgui_interact(user)

/obj/structure/musician/tgui_data(mob/user)
	return song.tgui_data(user)

/obj/structure/musician/tgui_interact(mob/user)
	song.tgui_interact(user)

/obj/structure/musician/tgui_act(action, params)
	if(..())
		return
	return song.tgui_act(action, params)

/obj/structure/musician/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I, 40)
	return TRUE

/**
  * Whether the instrument should stop playing
  *
  * Arguments:
  * * user - The user
  */
/obj/structure/musician/proc/should_stop_playing(mob/user)
	if(!(anchored || can_play_unanchored))
		return TRUE
	if(!user)
		return FALSE
	return !tgui_status(user, GLOB.tgui_physical_state)
