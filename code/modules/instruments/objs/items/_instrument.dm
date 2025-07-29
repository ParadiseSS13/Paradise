//copy pasta of the space piano, don't hurt me -Pete
/obj/item/instrument
	name = "generic instrument"
	icon = 'icons/obj/musician.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/instruments_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/instruments_righthand.dmi'
	force = 10
	max_integrity = 100
	resistance_flags = FLAMMABLE
	/// Our song datum.
	var/datum/song/handheld/song
	/// Our allowed list of instrument ids. This is nulled on initialize.
	var/list/allowed_instrument_ids
	/// How far away our song datum can be heard.
	var/instrument_range = 15

/obj/item/instrument/Initialize(mapload)
	. = ..()
	song = new(src, allowed_instrument_ids, instrument_range)
	allowed_instrument_ids = null			//We don't need this clogging memory after it's used.

/obj/item/instrument/Destroy()
	QDEL_NULL(song)
	return ..()

/obj/item/instrument/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] begins to play 'Gloomy Sunday'! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/instrument/attack_self__legacy__attackchain(mob/user)
	ui_interact(user)

/obj/item/instrument/ui_data(mob/user)
	return song.ui_data(user)

/obj/item/instrument/ui_interact(mob/user)
	if(!isliving(user) || user.incapacitated())
		return
	song.ui_interact(user)

/obj/item/instrument/ui_act(action, params)
	if(..())
		return
	return song.ui_act(action, params)

/**
  * Whether the instrument should stop playing
  *
  * Arguments:
  * * user - The user
  */
/obj/item/instrument/proc/should_stop_playing(mob/user)
	return !(src in user) || !isliving(user) || user.incapacitated()
