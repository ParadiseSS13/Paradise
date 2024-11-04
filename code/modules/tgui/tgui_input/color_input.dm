/**
 * Creates a TGUI color picker window and returns the user's response.
 *
 * This proc should be used to create a color picker that the caller will wait for a response from.
 * Arguments:
 * * user - The user to show the picker to.
 * * title - The of the picker modal, shown on the top of the TGUI window.
 * * timeout - The timeout of the picker, after which the modal will close and qdel itself. Set to zero for no timeout.
 * * autofocus - The bool that controls if this picker should grab window focus.
 */
/proc/tgui_input_color(mob/user, message, title, default = "#000000", timeout = 0, autofocus = TRUE, ui_state = GLOB.always_state)
	if(!user)
		user = usr
	if(!istype(user))
		if(!isclient(user))
			CRASH("We passed something that wasn't a user/client in a TGUI Input Color! The passed thing was [user]!")
		var/client/client = user
		user = client.mob

	if(isnull(user.client))
		return

	// Client does NOT have tgui_input on: Returns regular input
	if(user.client?.prefs?.toggles2 & PREFTOGGLE_2_DISABLE_TGUI_INPUT)
		return input(user, message, title, default) as color|null

	var/datum/tgui_input_color/picker = new(user, message, title, default, timeout, autofocus, ui_state)
	picker.ui_interact(user)
	picker.wait()
	if(picker)
		. = picker.choice
		qdel(picker)

/**
 * tgui_input_color
 *
 * Datum used for instantiating and using a TGUI-controlled color picker.
 */
/datum/tgui_input_color
	/// The title of the TGUI window
	var/title
	/// The message to show the user
	var/message
	/// The default choice, used if there is an existing value
	var/default
	/// The color the user selected, null if no selection has been made
	var/choice
	/// The time at which the tgui_input_color was created, for displaying timeout progress.
	var/start_time
	/// The lifespan of the tgui_input_color, after which the window will close and delete itself.
	var/timeout
	/// The bool that controls if this modal should grab window focus
	var/autofocus
	/// Boolean field describing if the tgui_input_color was closed by the user.
	var/closed
	/// The attached timer that handles this objects timeout deletion
	var/deletion_timer
	/// The TGUI UI state that will be returned in ui_state(). Default: always_state
	var/datum/ui_state/state

/datum/tgui_input_color/New(mob/user, message, title, default, timeout, autofocus, ui_state)
	src.autofocus = autofocus
	src.title = title
	src.default = default
	src.message = message
	src.state = ui_state

	if(timeout)
		src.timeout = timeout
		start_time = world.time
		deletion_timer = QDEL_IN(src, timeout)

/datum/tgui_input_color/Destroy(force, ...)
	SStgui.close_uis(src)
	state = null
	deltimer(deletion_timer)
	return ..()

/**
 * Waits for a user's response to the tgui_input_color's prompt before returning. Returns early if
 * the window was closed by the user.
 */
/datum/tgui_input_color/proc/wait()
	while(!choice && !closed && !QDELETED(src))
		stoplag(1)

/datum/tgui_input_color/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ColorPickerModal")
		ui.open()
		ui.set_autoupdate(timeout > 0)

/datum/tgui_input_color/ui_close(mob/user)
	closed = TRUE

/datum/tgui_input_color/ui_state(mob/user)
	return state

/datum/tgui_input_color/ui_static_data(mob/user)
	var/list/data = list()
	data["autofocus"] = autofocus
	data["large_buttons"] = !user.client?.prefs || (user.client.prefs.toggles2 & PREFTOGGLE_2_LARGE_INPUT_BUTTONS)
	data["swapped_buttons"] = !user.client?.prefs || (user.client.prefs.toggles2 & PREFTOGGLE_2_SWAP_INPUT_BUTTONS)
	data["title"] = title
	data["default_color"] = default
	data["message"] = message
	return data

/datum/tgui_input_color/ui_data(mob/user)
	var/list/data = list()
	if(timeout)
		data["timeout"] = CLAMP01((timeout - (world.time - start_time) - 1 SECONDS) / (timeout - 1 SECONDS))
	return data

/datum/tgui_input_color/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("submit")
			if(!findtext(params["entry"], GLOB.is_color))
				return
			choice = params["entry"]
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE
		if("cancel")
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE
