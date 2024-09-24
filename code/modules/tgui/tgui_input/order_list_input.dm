/**
 * Creates a TGUI input list window and returns the user's response.
 *
 * This proc should be used to create alerts that the caller will wait for a response from.
 * Arguments:
 * * user - The user to show the input box to.
 * * message - The content of the input box, shown in the body of the TGUI window.
 * * title - The title of the input box, shown on the top of the TGUI window.
 * * items - The options that can be chosen by the user, each string is assigned a button on the UI.
 * * default - If an option is already preselected on the UI. Current values, etc.
 * * timeout - The timeout of the input box, after which the menu will close and qdel itself. Set to zero for no timeout.
 */
/proc/tgui_input_ranked_list(mob/user, message, title = "Select", list/items, default, timeout = 0, ui_state = GLOB.always_state)
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

	// doesn't support this
	// if(user.client?.prefs?.toggles2 & PREFTOGGLE_2_DISABLE_TGUI_INPUT)
	// 	return input(user, message, title, default) as null|anything in items

	var/datum/tgui_list_input/ranked/input = new(user, message, title, items, default, timeout, ui_state)

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
/datum/tgui_list_input/ranked
	modal_type = "RankedListInputModal"

/datum/tgui_list_input/ranked/handle_submit_action(params)
	if(!(params["entry"] in items))
		return FALSE
	set_choice(items_map[params["entry"]])
	return TRUE

// ctodo remove
/client/verb/test_rankedlist_shit()
	name = "Test"

	var/list/shitlist = list("Bob", "Alice", "Dooley", "Estephan", "Charlie")
	var/list/new_list = tgui_input_ranked_list(src, "Sort These Alphabetically!", "Sorting", )
	to_chat(world, json_encode(new_list))
