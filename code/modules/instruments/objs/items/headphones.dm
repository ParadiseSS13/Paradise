/obj/item/clothing/ears/headphones
	name = "headphones"
	desc = "Unce unce unce unce."
	icon_state = "headphones0"
	item_state = "headphones0"
	actions_types = list(/datum/action/item_action/change_headphones_song, /datum/action/item_action/toggle_music_notes)
	var/datum/song/headphones/song
	var/on = FALSE

/obj/item/clothing/ears/headphones/Initialize(mapload)
	. = ..()
	song = new(src, "piano") // Piano is the default instrument but all instruments are allowed
	song.instrument_range = 0
	song.allowed_instrument_ids = SSinstruments.synthesizer_instrument_ids
	// To update the icon
	RegisterSignal(src, COMSIG_SONG_START, PROC_REF(start_playing))
	RegisterSignal(src, COMSIG_SONG_END, PROC_REF(stop_playing))

/obj/item/clothing/ears/headphones/Destroy()
	QDEL_NULL(song)
	return ..()

/obj/item/clothing/ears/headphones/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/change_headphones_song)
		ui_interact(user)
	else if(actiontype == /datum/action/item_action/toggle_music_notes)
		toggle_visual_notes(user)

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtons()

/obj/item/clothing/ears/headphones/proc/toggle_visual_notes(mob/user)
	on = !on
	update_icon(UPDATE_ICON_STATE)
	user.regenerate_icons()

/obj/item/clothing/ears/headphones/ui_data(mob/user)
	return song.ui_data(user)

/obj/item/clothing/ears/headphones/ui_interact(mob/user)
	if(should_stop_playing(user) || user.incapacitated())
		return
	song.ui_interact(user)

/obj/item/clothing/ears/headphones/ui_act(action, params)
	if(..())
		return
	return song.ui_act(action, params)

/obj/item/clothing/ears/headphones/update_icon_state()
	var/mob/living/carbon/human/user = loc
	if(istype(user))
		user.update_action_buttons_icon()
		user.update_inv_ears()
	icon_state = item_state = "headphones[on]"

/obj/item/clothing/ears/headphones/item_action_slot_check(slot)
	if(slot == SLOT_HUD_LEFT_EAR || slot == SLOT_HUD_RIGHT_EAR)
		return TRUE

/**
  * Called by a component signal when our song starts playing.
  */
/obj/item/clothing/ears/headphones/proc/start_playing()
	on = TRUE
	update_icon(UPDATE_ICON_STATE)

/**
  * Called by a component signal when our song stops playing.
  */
/obj/item/clothing/ears/headphones/proc/stop_playing()
	on = FALSE
	update_icon(UPDATE_ICON_STATE)

/**
  * Whether the headphone's song should stop playing
  *
  * Arguments:
  * * user - The user
  */
/obj/item/clothing/ears/headphones/proc/should_stop_playing(mob/living/carbon/human/user)
	return !(src in user) || !istype(user) || !((src == user.l_ear) || (src == user.r_ear))

// special subtype so it uses the correct item type
/datum/song/headphones

/datum/song/headphones/should_stop_playing(mob/user)
	. = ..()
	if(.)
		return TRUE
	var/obj/item/clothing/ears/headphones/I = parent
	return I.should_stop_playing(user)
