/**
 * Creates a JSON encoded message to open TGUI say modals properly.
 *
 * Arguments:
 * channel - The channel to open the modal in.
 * Returns:
 * string - A JSON encoded message to open the modal.
 */
/client/proc/tgui_say_create_open_command(channel)
	var/message = TGUI_CREATE_MESSAGE("open", list(
		channel = channel,
	))
	return "\".output tgui_say.browser:update [message]\""

/**
 * The tgui say modal. This initializes an input window which hides until
 * the user presses one of the speech hotkeys. Once something is entered, it will
 * delegate the speech to the proper channel.
 */
/datum/tgui_say
	/// The user who opened the window
	var/client/client
	/// The modal window
	var/datum/tgui_window/window
	/// Boolean for whether the tgui_say was opened by the user.
	var/window_open

/** Creates the new input window to exist in the background. */
/datum/tgui_say/New(client/client, id)
	src.client = client
	window = new(client, id)
	winset(client, "tgui_say", "size=1,1;is-visible=0;")
	window.subscribe(src, PROC_REF(on_message))
	window.is_browser = TRUE

/**
 * After a brief period, injects the scripts into
 * the window to listen for open commands.
 */
/datum/tgui_say/proc/initialize()
	set waitfor = FALSE
	// Sleep to defer initialization to after client constructor
	sleep(3 SECONDS)
	window.initialize(
			strict_mode = TRUE,
			fancy = TRUE,
			inline_css = file("tgui/public/tgui-say.bundle.css"),
			inline_js = file("tgui/public/tgui-say.bundle.js"),
	);

/**
 * Ensures nothing funny is going on window load.
 * Minimizes the window, sets max length, closes all
 * typing and thinking indicators. This is triggered
 * as soon as the window sends the "ready" message.
 */
/datum/tgui_say/proc/load()
	window_open = FALSE
	winset(client, "tgui_say", "pos=848,500;size=275,30;is-visible=0;")
	window.send_message("props", list(
		"lightMode" = (client.prefs.toggles2 & PREFTOGGLE_2_ENABLE_TGUI_SAY_LIGHT_MODE),
		"maxLength" = MAX_MESSAGE_LEN,
	))
	stop_thinking()
	return TRUE

/**
 * Sets the window as "opened" server side, though it is already
 * visible to the user. We do this to set local vars &
 * start typing (if enabled and in an IC channel).
 *
 * Arguments:
 * payload - A list containing the channel the window was opened in.
 */
/datum/tgui_say/proc/open(payload)
	if(!payload?["channel"])
		CRASH("No channel provided to an open TGUI-Say")
	window_open = TRUE
	switch(payload["channel"])
		if(ME_CHANNEL, RADIO_CHANNEL, SAY_CHANNEL, WHISPER_CHANNEL)
			start_thinking()
	return TRUE

/**
 * Closes the window serverside. Closes any open chat bubbles
 * regardless of preference.
 */
/datum/tgui_say/proc/close()
	window_open = FALSE
	stop_thinking()
	stop_typing()

/**
 * The equivalent of ui_act, this waits on messages from the window
 * and delegates actions.
 */
/datum/tgui_say/proc/on_message(type, payload)
	switch(type)
		if("ready")
			load()
			return TRUE
		if("open")
			open(payload)
			return TRUE
		if("close")
			close()
			return TRUE
		if("thinking")
			if(payload["visible"] == TRUE)
				start_thinking()
				return TRUE
			if(payload["visible"] == FALSE)
				stop_thinking()
				return TRUE
			return FALSE
		if("typing")
			start_typing(payload["isMeChannel"])
			return TRUE
		if("entry")
			handle_entry(payload)
			return TRUE

	return FALSE
