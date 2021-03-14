/**
 * tgui external
 *
 * Contains all external tgui declarations.
 */

/**
 * public
 *
 * Used to open and update UIs.
 * If this proc is not implemented properly, the UI will not update correctly.
 *
 * * mob/user - The mob who opened/is using the UI. (REQUIRED)
 * * ui_key - The ui_key of the UI. (OPTIONAL)
 * * datum/tgui/ui - The UI to be updated, if it exists. (OPTIONAL)
 * * force_open - If the UI should be re-opened instead of updated. (OPTIONAL)
 * * datum/tgui/master_ui - The parent UI. (OPTIONAL)
 * * datum/ui_state/state - The state used to determine status. (OPTIONAL)
 */
/datum/proc/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	return FALSE // Not implemented.

/**
 * public
 *
 * Data to be sent to the UI.
 * This must be implemented for a UI to work.
 *
 * * mob/user - The mob interacting with the UI.
 */
/datum/proc/ui_data(mob/user)
	return list() // Not implemented.

/**
 * public
 *
 * Static Data to be sent to the UI.
 * Static data differs from normal data in that it's large data that should be sent infrequently
 * This is implemented optionally for heavy uis that would be sending a lot of redundant data
 * frequently.
 * Gets squished into one object on the frontend side, but the static part is cached.
 *
 * * mob/user - The mob interacting with the UI.
 */
/datum/proc/ui_static_data(mob/user)
	return list()

/**
 * public
 *
 * Forces an update on static data. Should be done manually whenever something happens to change static data.
 *
 * * mob/user - The mob currently interacting with the UI. (REQUIRED)
 * * datum/tgui/ui - UI to be updated (OPTIONAL)
 * * ui_key - Key of the UI to be updated. (OPTIONAL)
 */
/datum/proc/update_static_data(mob/user, datum/tgui/ui, ui_key = "main")
	ui = SStgui.try_update_ui(user, src, ui_key, ui)
	// If there was no ui to update, there's no static data to update either.
	if(!ui)
		return
	ui.push_data(null, ui_static_data(user), TRUE)

/**
 * public
 *
 * Called on a UI when the UI receieves a href.
 * Think of this as Topic().
 * Returns TRUE if the UI should be updated, and FALSE if not.
 *
 * * action - The action/button that has been invoked by the user.
 * * list/params - A list of parameters attached to the button.
 */
/datum/proc/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	// If UI is not interactive or usr calling Topic is not the UI user, bail.
	if(!ui || ui.status != STATUS_INTERACTIVE)
		return TRUE

/**
 * public
 *
 * Called on an object when a tgui object is being created, allowing you to
 * customise the html
 * For example: inserting a custom stylesheet that you need in the head
 *
 * For this purpose, some tags are available in the html, to be parsed out
 ^ with replacetext
 * (customheadhtml) - Additions to the head tag
 *
 * * html - The html base text.
 */
/datum/proc/ui_base_html(html)
	return html

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
 * global
 *
 * Associative list of JSON-encoded shared states that were set by
 * tgui clients.
 */
/datum/var/list/tgui_shared_states

/**
 * global
 *
 * Used to track UIs for a mob.
 */
/mob/var/list/open_uis = list()
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
 * * uid - The UI that was closed.
 */
/client/verb/uiclose(uid as text)
	// Name the verb, and hide it from the user panel.
	set name = "uiclose"
	set hidden = TRUE

	// Get the UI based on the UID.
	var/datum/tgui/ui = locateUID(uid)

	// If we found the UI, close it.
	if(istype(ui))
		ui.close()
		// Unset machine just to be sure.
		if(src && src.mob)
			src.mob.unset_machine()
