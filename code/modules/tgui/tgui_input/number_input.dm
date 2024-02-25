/**
 * Creates a TGUI window with a number input. Returns the user's response as num | null.
 *
 * This proc should be used to create windows for number entry that the caller will wait for a response from.
 * If tgui fancy chat is turned off: Will return a normal input. If a max or min value is specified, will
 * validate the input inside the UI and ui_act.
 *
 * Arguments:
 * * user - The user to show the number input to.
 * * message - The content of the number input, shown in the body of the TGUI window.
 * * title - The title of the number input modal, shown on the top of the TGUI window.
 * * default - The default (or current) value, shown as a placeholder. Users can press refresh with this.
 * * max_value - Specifies a maximum value. If none is set, any number can be entered. Pressing "max" defaults to 1000.
 * * min_value - Specifies a minimum value. Often 0.
 * * timeout - The timeout of the number input, after which the modal will close and qdel itself. Set to zero for no timeout.
 * * round_value - whether the inputted number is rounded down into an integer.
 */
/proc/tgui_input_number(mob/user, message, title = "Number Input", default = 0, max_value = 10000, min_value = 0, timeout = 0, round_value = TRUE, ui_state = GLOB.always_state)
	if(!user)
		user = usr

	if(!istype(user))
		if(!isclient(user))
			CRASH("We passed something that wasn't a user/client in a TGUI Input Number! The passed user was [user]!")
		var/client/client = user
		user = client.mob

	if(isnull(user.client))
		return

	// Client does NOT have tgui_input on: Returns regular input
	if(user.client?.prefs?.toggles2 & PREFTOGGLE_2_DISABLE_TGUI_INPUT)
		var/input_number = input(user, message, title, default) as null|num
		return clamp(round_value ? round(input_number) : input_number, min_value, max_value)

	var/datum/tgui_input_number/number_input = new(user, message, title, default, max_value, min_value, timeout, round_value, ui_state)

	number_input.ui_interact(user)
	number_input.wait()
	if(number_input)
		. = number_input.entry
		qdel(number_input)

/**
 * # tgui_input_number
 *
 * Datum used for instantiating and using a TGUI-controlled number input that prompts the user with
 * a message and has an input for number entry.
 */
/datum/tgui_input_number
	/// Boolean field describing if the tgui_input_number was closed by the user.
	var/closed
	/// The default (or current) value, shown as a default. Users can press reset with this.
	var/default
	/// The entry that the user has return_typed in.
	var/entry
	/// The maximum value that can be entered.
	var/max_value
	/// The prompt's body, if any, of the TGUI window.
	var/message
	/// The minimum value that can be entered.
	var/min_value
	/// Whether the submitted number is rounded down into an integer.
	var/round_value
	/// The time at which the number input was created, for displaying timeout progress.
	var/start_time
	/// The lifespan of the number input, after which the window will close and delete itself.
	var/timeout
	/// The title of the TGUI window
	var/title
	/// The TGUI UI state that will be returned in ui_state(). Default: always_state
	var/datum/ui_state/state

/datum/tgui_input_number/New(mob/user, message, title, default, max_value, min_value, timeout, round_value, ui_state)
	src.default = default
	src.max_value = max_value
	src.message = message
	src.min_value = min_value
	src.title = title
	src.round_value = round_value
	src.state = ui_state

	if(timeout)
		src.timeout = timeout
		start_time = world.time
		QDEL_IN(src, timeout)

	/// Checks for empty numbers - bank accounts, etc.
	if(max_value == 0)
		src.min_value = 0
		if(default)
			src.default = 0

	/// Sanity check
	if(default < min_value)
		src.default = min_value

	if(default > max_value)
		CRASH("Default value is greater than max value.")

/datum/tgui_input_number/Destroy(force)
	SStgui.close_uis(src)
	state = null
	return ..()

/**
 * Waits for a user's response to the tgui_input_number's prompt before returning. Returns early if
 * the window was closed by the user.
 */
/datum/tgui_input_number/proc/wait()
	while(!entry && !closed && !QDELETED(src))
		stoplag(1)

/datum/tgui_input_number/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NumberInputModal")
		ui.open()

/datum/tgui_input_number/ui_close(mob/user)
	closed = TRUE

/datum/tgui_input_number/ui_state(mob/user)
	return state

/datum/tgui_input_number/ui_static_data(mob/user)
	var/list/data = list()
	data["init_value"] = default // Default is a reserved keyword
	data["min_value"] = min_value
	data["max_value"] = max_value
	data["round_value"] = round_value
	data["message"] = message
	data["large_buttons"] = user.client?.prefs?.toggles2 & PREFTOGGLE_2_LARGE_INPUT_BUTTONS
	data["swapped_buttons"] = user.client?.prefs?.toggles2 & PREFTOGGLE_2_SWAP_INPUT_BUTTONS
	data["title"] = title
	return data

/datum/tgui_input_number/ui_data(mob/user)
	var/list/data = list()
	if(timeout)
		data["timeout"] = CLAMP01((timeout - (world.time - start_time) - 1 SECONDS) / (timeout - 1 SECONDS))
	return data

/datum/tgui_input_number/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("submit")
			if(!isnum(params["entry"]))
				CRASH("A non number was input into TGUI Input Number by [usr]")
			var/choice = round_value ? round(params["entry"]) : params["entry"]
			if(choice > max_value)
				CRASH("A number greater than the max value was input into TGUI Input Number by [usr]")
			if(choice < min_value)
				CRASH("A number less than the min value was input into TGUI Input Number by [usr]")
			set_entry(choice)
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE
		if("cancel")
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE

/datum/tgui_input_number/proc/set_entry(entry)
	src.entry = entry
