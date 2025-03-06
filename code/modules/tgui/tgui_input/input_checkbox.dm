/**
 * Creates a TGUI input list window and returns the user's response in a ranked order.
 *
 * Arguments:
 * * user - The user to show the input box to.
 * * message - The content of the input box, shown in the body of the TGUI window.
 * * title - The title of the input box, shown on the top of the TGUI window.
 * * items - The options that can be chosen by the user, each string is assigned a button on the UI.
 * * default - If an option is already preselected on the UI. Current values, etc.
 * * timeout - The timeout of the input box, after which the menu will close and qdel itself. Set to zero for no timeout.
 */
/proc/tgui_input_checkbox_list(mob/user, message, title = "Select", list/items, default, timeout = 0, ui_state = GLOB.always_state)
	if(!user)
		user = usr

	if(!length(items))
		CRASH("[user] tried to open an empty TGUI Input Checkbox List. Contents are: [items]")

	if(!istype(user))
		if(!isclient(user))
			CRASH("We passed something that wasn't a user/client in a TGUI Input Checkbox List! The passed user was [user]!")
		var/client/client = user
		user = client.mob

	if(isnull(user.client))
		return

	var/datum/tgui_list_input/checkbox/input = new(user, message, title, items, default, timeout, ui_state)

	if(input.invalid)
		qdel(input)
		return

	input.ui_interact(user)
	input.wait()
	if(input)
		. = input.choice
		qdel(input)

/**
 * # tgui_list_input/ranked
 *
 * Datum used for allowing a user to sort a TGUI-controlled list input that prompts the user with
 * a message and shows a list of rankable options
 */
/datum/tgui_list_input/checkbox
	modal_type = "CheckboxListInputModal"

/datum/tgui_list_input/checkbox/handle_new_items(list/_items)
	var/list/repeat_items = list()
	// Gets rid of illegal characters
	var/static/regex/blacklisted_words = regex(@{"([^\u0020-\u8000]+)"})

	for(var/key in _items)
		var/string_key = blacklisted_words.Replace("[key]", "")

		// Avoids duplicated keys E.g: when areas have the same name
		string_key = avoid_assoc_duplicate_keys(string_key, repeat_items)
		src.items += list(list(
			"key" = string_key,
			"checked" = (_items[key] ? TRUE : FALSE)
		))
	src.items_map = _items // we use this differently

/datum/tgui_list_input/checkbox/handle_submit_action(params)
	var/list/associated = list()
	for(var/list/sublist in params["entry"])
		associated[sublist["key"]] = (sublist["checked"] in list(1, "1", "true"))

	if(!lists_equal_unordered(associated, items_map))
		return FALSE
	set_choice(associated)
	return TRUE


