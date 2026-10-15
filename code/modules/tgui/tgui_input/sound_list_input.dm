/proc/tgui_input_sound_list(mob/user, message, title = "Select", list/items, default, timeout = 0, ui_state = GLOB.always_state)
	if(!user)
		user = usr

	if(!length(items))
		CRASH("[user] tried to open an empty TGUI Input List. Contents are: [items]")

	if(!istype(user))
		if(!isclient(user))
			CRASH("We passed something that wasn't a user/client in a TGUI Input List! The passed user was [user]!")
		var/client/client = user
		user = client.mob

	if(isnull(user.client))
		return

	/// Client does NOT have tgui_input on: Returns regular input
	if(user.client?.prefs?.toggles2 & PREFTOGGLE_2_DISABLE_TGUI_INPUT)
		return input(user, message, title, default) as null|anything in items

	var/datum/tgui_list_input/sound/input = new(user, message, title, items, default, timeout, ui_state)

	if(input.invalid)
		qdel(input)
		return

	input.ui_interact(user)
	input.wait()
	if(input)
		. = input.choice
		qdel(input)

/**
 * # tgui_list_input/sound
 *
 * Datum used for allowing a user to pick and preview sounds from a provided list in TGUI.
 */
/datum/tgui_list_input/sound
	modal_type = "SoundListInputModal"

/datum/tgui_list_input/sound/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("preview")
			if(!(params["entry"] in items_map) || isnull(items_map[params["entry"]]))
				return NONE
			var/sound/preview = sound(
				items_map[params["entry"]],
				repeat = 0,
				wait = 0,
				volume = 60 * usr.client.prefs.get_channel_volume(CHANNEL_GENERAL),
				channel = CHANNEL_GENERAL
			)
			SEND_SOUND(usr, preview)
			return TRUE

/datum/tgui_list_input/sound/handle_new_items(list/_items)
	var/list/repeat_items = list()
	// Gets rid of illegal characters
	var/static/regex/blacklisted_words = regex(@{"([^\u0020-\u8000]+)"})

	for(var/i in _items)
		var/string_key = blacklisted_words.Replace("[i]", "")

		// Avoids duplicated keys E.g: when areas have the same name
		string_key = avoid_assoc_duplicate_keys(string_key, repeat_items)
		src.items += string_key
		src.items_map[string_key] = _items[i]
