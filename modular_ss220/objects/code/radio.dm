/obj/item/radio
	/// Max listening and broadcasting range
	var/max_hear_range
	///Tells whether the hear range can be changed
	var/has_fixed_hear_range = TRUE

	/// Overlay when speaker is on
	var/overlay_speaker_idle = null
	/// Overlay when receiving a message
	var/overlay_speaker_active = null

	/// Overlay when mic is on
	var/overlay_mic_idle = null
	/// Overlay when speaking a message (is displayed simultaneously with speaker_active)
	var/overlay_mic_active = null

/obj/item/radio/Initialize(mapload)
	. = ..()
	max_hear_range = max_hear_range || canhear_range

/obj/item/radio/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Radio220", name)
		ui.open()

/obj/item/radio/ui_data(mob/user)
	var/data = ..()
	data["hearRange"] = canhear_range
	data["maxHearRange"] = max_hear_range
	data["hasFixedHearRange"] = has_fixed_hear_range
	return data

/obj/item/radio/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("range")
			if(has_fixed_hear_range)
				return FALSE
			var/new_range = isnum(params["set"]) ? params["set"] : text2num(params["set"])
			if(new_range <= max_hear_range)
				canhear_range = new_range
				return TRUE
			else
				return FALSE

/obj/item/radio/update_overlays()
	. = ..()
	if(b_stat)
		return
	if(broadcasting && overlay_mic_idle)
		. += overlay_mic_idle
	if(listening && overlay_speaker_idle)
		. += overlay_speaker_idle

/obj/item/radio/ToggleReception(mob/user)
	. = ..()
	if(!isnull(overlay_speaker_idle))
		update_icon()

/obj/item/radio/ToggleBroadcast(mob/user)
	. = ..()
	if(!isnull(overlay_mic_idle))
		update_icon()

/obj/item/radio/hear_talk(mob/M, list/message_pieces, verb)
	. = ..()
	if(!isnull(overlay_speaker_active))
		flick_overlay_view(image(icon, src, overlay_speaker_active, BELOW_MOB_LAYER), src, 1 SECONDS)

/obj/item/radio/talk_into(mob/living/M, list/message_pieces, channel, verbage)
	. = ..()
	if(!isnull(overlay_mic_active))
		flick_overlay_view(image(icon, src, overlay_mic_active), src, 5 SECONDS)

/obj/item/radio/borg
	max_hear_range = 3
	has_fixed_hear_range = FALSE
