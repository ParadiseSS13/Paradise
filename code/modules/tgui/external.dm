/**
 * External tgui definitions, such as src_object APIs.
 *
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * public
 *
 * Used to open and update UIs.
 * If this proc is not implemented properly, the UI will not update correctly.
 *
 * required user mob The mob who opened/is using the UI.
 * optional ui datum/tgui The UI to be updated, if it exists.
 */
/datum/proc/ui_interact(mob/user, datum/tgui/ui)
	return FALSE // Not implemented.

/**
 * public
 *
 * Data to be sent to the UI.
 * This must be implemented for a UI to work.
 *
 * required user mob The mob interacting with the UI.
 *
 * return list Data to be sent to the UI.
 */
/datum/proc/ui_data(mob/user)
	// 1) this is polled several times a second, so sleeping means more running threads, needlessly tanking performance
	// 2) if you try to sleep, you get fun bugs ranging from BSOD to uninteractable white windows, to windows straight up vanishing.
	// Just don't.
	SHOULD_NOT_SLEEP(TRUE)
	return list() // Not implemented.

/**
 * public
 *
 * Static Data to be sent to the UI.
 *
 * Static data differs from normal data in that it's large data that should be
 * sent infrequently. This is implemented optionally for heavy uis that would
 * be sending a lot of redundant data frequently. Gets squished into one
 * object on the frontend side, but the static part is cached.
 *
 * required user mob The mob interacting with the UI.
 *
 * return list Statuic Data to be sent to the UI.
 */
/datum/proc/ui_static_data(mob/user)
	SHOULD_NOT_SLEEP(TRUE)
	return list()

/**
 * public
 *
 * Forces an update on static data. Should be done manually whenever something
 * happens to change static data.
 *
 * required user the mob currently interacting with the ui
 * optional ui ui to be updated
 */
/datum/proc/update_static_data(mob/user, datum/tgui/ui)
	if(!ui)
		ui = SStgui.get_open_ui(user, src)
	if(ui)
		ui.send_full_update()

/**
 * public
 *
 * Called on a UI when the UI receieves a href.
 * Think of this as Topic().
 *
 * required action string The action/button that has been invoked by the user.
 * required params list A list of parameters attached to the button.
 *
 * return bool If the UI should be updated or not.
 */
/datum/proc/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	// If UI is not interactive or usr calling Topic is not the UI user, bail.
	if(!ui || ui.status != UI_INTERACTIVE)
		return TRUE

/**
 * public
 *
 * Called on an object when a tgui object is being created, allowing you to
 * push various assets to tgui, for examples spritesheets.
 *
 * return list List of asset datums or file paths.
 */
/datum/proc/ui_assets(mob/user)
	return list()

/**
 * private
 *
 * The UI's host object (usually src_object).
 * This allows modules/datums to have the UI attached to them,
 * and be a part of another object.
 */
/datum/proc/ui_host(mob/user)
	return src // Default src.

/**
 * private
 *
 * The UI's state controller to be used for created uis
 * This is a proc over a var for memory reasons
 */
/datum/proc/ui_state(mob/user)
	return GLOB.default_state

/**
 * global
 *
 * Associative list of JSON-encoded shared states that were set by
 * tgui clients.
 */
/* check_grep:ignore */ /datum/var/list/tgui_shared_states

/**
 * global
 *
 * Tracks open UIs for a user.
 */
/* check_grep:ignore */ /mob/var/list/tgui_open_uis = list()

/**
 * global
 *
 * Tracks open windows for a user.
 */
/* check_grep:ignore */ /client/var/list/tgui_windows = list()

/**
 * global
 *
 * TRUE if cache was reloaded by tgui dev server at least once.
 */
/* check_grep:ignore */ /client/var/tgui_cache_reloaded = FALSE

/**
 * public
 *
 * Called on a UI's object when the UI is closed, not to be confused with
 * client/verb/uiclose(), which closes the ui window
 */
/datum/proc/ui_close(mob/user)

/**
 * verb
 *
 * Called by UIs when they are closed.
 * Must be a verb so winset() can call it.
 *
 * required uiref ref The UI that was closed.
 */
/client/verb/uiclose(window_id as text)
	// Name the verb, and hide it from the user panel.
	set name = "uiclose"
	set hidden = TRUE
	var/mob/user = src && src.mob
	if(!user)
		return
	// Close all tgui datums based on window_id.
	SStgui.force_close_window(user, window_id)

/**
 * Middleware for /client/Topic.
 *
 * return bool If TRUE, prevents propagation of the topic call.
 */
/proc/tgui_Topic(href_list)
	// Skip non-tgui topics
	if(!href_list["tgui"])
		return FALSE
	var/type = href_list["type"]
	// Unconditionally collect tgui logs
	if(type == "log")
		log_tgui(usr, href_list["message"])
	// Reload all tgui windows
	if(type == "cacheReloaded")
		if(!check_rights(R_ADMIN) || usr.client.tgui_cache_reloaded)
			return TRUE
		// Mark as reloaded
		usr.client.tgui_cache_reloaded = TRUE
		// Notify windows
		var/list/windows = usr.client.tgui_windows
		for(var/window_id in windows)
			var/datum/tgui_window/window = windows[window_id]
			if(window.status == TGUI_WINDOW_READY)
				window.on_message(type, null, href_list)
		return TRUE
	// Locate window
	var/window_id = href_list["window_id"]
	var/datum/tgui_window/window
	if(window_id)
		window = usr.client.tgui_windows[window_id]
		if(!window)
			log_tgui(usr, "Error: Couldn't find the window datum, force closing.")
			SStgui.force_close_window(usr, window_id)
			return TRUE
	// Decode payload
	var/payload
	if(href_list["payload"])
		var/payload_text = href_list["payload"]
		if(!rustg_json_is_valid(payload_text))
			log_tgui(usr, "Error: Invalid JSON")
			return TRUE

		payload = json_decode(payload_text)
	// Pass message to window
	if(window)
		window.on_message(type, payload, href_list)
	return TRUE
