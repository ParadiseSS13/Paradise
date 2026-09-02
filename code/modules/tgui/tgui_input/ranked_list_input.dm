/**
 * Creates a TGUI ranked input list window and returns the user's response in a ranked order.
 *
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
		CRASH("[user] tried to open an empty TGUI Input Ranked List. Contents are: [items]")

	if(!istype(user))
		if(!isclient(user))
			CRASH("We passed something that wasn't a user/client in a TGUI Input Ranked List! The passed user was [user]!")
		var/client/client = user
		user = client.mob

	if(isnull(user.client))
		return

	// We don't support disabled TGUI input (PREFTOGGLE_2_DISABLE_TGUI_INPUT), get with the times old man

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
	if(!lists_equal_unordered(params["entry"], items))
		return FALSE
	set_choice(params["entry"])
	return TRUE
