 /**
  * tgui subsystem
  *
  * Contains all tgui state and subsystem code.
 **/


SUBSYSTEM_DEF(tgui)
	name = "TGUI"
	wait = 9
	flags = SS_NO_INIT
	priority = FIRE_PRIORITY_TGUI
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	offline_implications = "All TGUIs will no longer process. Shuttle call recommended."

	var/list/currentrun = list()
	var/list/open_uis = list() // A list of open UIs, grouped by src_object and ui_key.
	var/list/processing_uis = list() // A list of processing UIs, ungrouped.
	var/basehtml // The HTML base used for all UIs.

/datum/controller/subsystem/tgui/PreInit()
	basehtml = file2text('tgui/packages/tgui/public/tgui.html')

/datum/controller/subsystem/tgui/Shutdown()
	close_all_uis()

/datum/controller/subsystem/tgui/get_stat_details()
	return "P:[length(processing_uis)]"

/datum/controller/subsystem/tgui/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["processing"] = length(processing_uis)
	.["custom"] = cust


/datum/controller/subsystem/tgui/fire(resumed = 0)
	if(!resumed)
		src.currentrun = processing_uis.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/tgui/ui = currentrun[currentrun.len]
		currentrun.len--
		if(ui && ui.user && ui.src_object)
			ui.process()
		else
			processing_uis.Remove(ui)
		if(MC_TICK_CHECK)
			return

/**
 * public
 *
 * Get an open UI given a user, src_object, and ui_key and try to update it with data.
 * Returns the found UI.
 *
 * * mob/user - The mob who opened/is using the UI. (REQUIRED)
 * * datum/src_object - The object/datum which owns the UI. (REQUIRED)
 * * ui_key - The ui_key of the UI. (REQUIRED)
 * * datum/tgui/ui - The UI to be updated, if it exists. (OPTIONAL)
 * * force_open - If the UI should be re-opened instead of updated. (OPTIONAL)
 */
/datum/controller/subsystem/tgui/proc/try_update_ui(mob/user, datum/src_object, ui_key, datum/tgui/ui, force_open = FALSE)
	if(isnull(ui)) // No UI was passed, so look for one.
		ui = get_open_ui(user, src_object, ui_key)

	if(!isnull(ui))
		var/data = src_object.ui_data(user) // Get data from the src_object.
		if(!force_open) // UI is already open; update it.
			ui.push_data(data)
		else // Re-open it anyways.
			ui.reinitialize(null, data)
		return ui // We found the UI, return it.
	else
		return null // We couldn't find a UI.

/**
 * private
 *
 * Get an open UI given a user, src_object, and ui_key.
 * Returns the found UI.
 *
 * * mob/user - The mob who opened/is using the UI. (REQUIRED)
 * * datum/src_object - The object/datum which owns the UI. (REQUIRED)
 * * ui_key - The ui_key of the UI. (REQUIRED)
 */
/datum/controller/subsystem/tgui/proc/get_open_ui(mob/user, datum/src_object, ui_key)
	var/src_object_key = "[src_object.UID()]"
	if(isnull(open_uis[src_object_key]) || !islist(open_uis[src_object_key]))
		return null // No UIs open.
	else if(isnull(open_uis[src_object_key][ui_key]) || !islist(open_uis[src_object_key][ui_key]))
		return null // No UIs open for this object.

	for(var/datum/tgui/ui in open_uis[src_object_key][ui_key]) // Find UIs for this object.
		if(ui.user == user) // Make sure we have the right user
			return ui

	return null // Couldn't find a UI!

/**
 * private
 *
 * Update all UIs attached to src_object.
 * Returns the number of UIs updated.
 *
 * * datum/src_object - The object/datum which owns the UIs.
 * * update_static_data - If the static data of the `src_object` should be updated for every viewing user.
 */
/datum/controller/subsystem/tgui/proc/update_uis(datum/src_object, update_static_data = FALSE)
	var/src_object_key = "[src_object.UID()]"
	if(isnull(open_uis[src_object_key]) || !islist(open_uis[src_object_key]))
		return 0 // Couldn't find any UIs for this object.

	var/update_count = 0
	for(var/ui_key in open_uis[src_object_key])
		for(var/datum/tgui/ui in open_uis[src_object_key][ui_key])
			if(ui && ui.src_object && ui.user && ui.src_object.ui_host(ui.user)) // Check the UI is valid.
				if(update_static_data)
					src_object.update_static_data(ui.user, ui, ui_key)
				ui.process(force = 1) // Update the UI.
				update_count++ // Count each UI we update.
	return update_count

/**
 * private
 *
 * Close all UIs attached to src_object.
 * Returns the number of UIs closed.
 *
 * * datum/src_object - The object/datum which owns the UIs.
 */
/datum/controller/subsystem/tgui/proc/close_uis(datum/src_object)
	if(!src_object.unique_datum_id) // First check if the datum has an UID set
		return 0
	var/src_object_key = "[src_object.UID()]"
	if(isnull(open_uis[src_object_key]) || !islist(open_uis[src_object_key]))
		return 0 // Couldn't find any UIs for this object.

	var/close_count = 0
	for(var/ui_key in open_uis[src_object_key])
		for(var/datum/tgui/ui in open_uis[src_object_key][ui_key])
			if(ui && ui.src_object && ui.user && ui.src_object.ui_host(ui.user)) // Check the UI is valid.
				ui.close() // Close the UI.
				close_count++ // Count each UI we close.
	return close_count

/**
 *
 * Gets the amount of open UIs on an object
 * Returns the number of UIs open.
 *
 * * datum/src_object - The object/datum which owns the UIs.
 */
/datum/controller/subsystem/tgui/proc/get_open_ui_count(datum/src_object)
	if(!src_object.unique_datum_id) // First check if the datum has an UID set
		return 0
	var/src_object_key = "[src_object.UID()]"
	if(isnull(open_uis[src_object_key]) || !islist(open_uis[src_object_key]))
		return 0 // Couldn't find any UIs for this object.

	var/open_count = 0
	for(var/ui_key in open_uis[src_object_key])
		for(var/datum/tgui/ui in open_uis[src_object_key][ui_key])
			if(ui && ui.src_object && ui.user && ui.src_object.ui_host(ui.user)) // Check the UI is valid.
				open_count++ // Count each UI thats open

	return open_count


/**
 * private
 *
 * Close *ALL* UIs
 * Returns the number of UIs closed.
 */
/datum/controller/subsystem/tgui/proc/close_all_uis()
	var/close_count = 0
	for(var/src_object_key in open_uis)
		for(var/ui_key in open_uis[src_object_key])
			for(var/datum/tgui/ui in open_uis[src_object_key][ui_key])
				if(ui && ui.src_object && ui.user && ui.src_object.ui_host(ui.user)) // Check the UI is valid.
					ui.close() // Close the UI.
					close_count++ // Count each UI we close.
	return close_count

/**
 * private
 *
 * Update all UIs belonging to a user.
 * Returns the number of UIs updated.
 *
 * * mob/user - The mob who opened/is using the UI. (REQUIRED)
 * * datum/src_object - If provided, only update UIs belonging this src_object. (OPTIONAL)
 * * ui_key - If provided, only update UIs with this UI key. (OPTIONAL)
 */
/datum/controller/subsystem/tgui/proc/update_user_uis(mob/user, datum/src_object = null, ui_key = null)
	if(isnull(user.open_uis) || !islist(user.open_uis) || open_uis.len == 0)
		return 0 // Couldn't find any UIs for this user.

	var/update_count = 0
	for(var/datum/tgui/ui in user.open_uis)
		if((isnull(src_object) || !isnull(src_object) && ui.src_object == src_object) && (isnull(ui_key) || !isnull(ui_key) && ui.ui_key == ui_key))
			ui.process(force = 1) // Update the UI.
			update_count++ // Count each UI we upadte.
	return update_count

/**
 * private
 *
 * Close all UIs belonging to a user.
 * Returns the number of UIs closed.
 *
 * * mob/user - The mob who opened/is using the UI. (REQUIRED)
 * * datum/src_object - If provided, only close UIs belonging this src_object. (OPTIONAL)
 * * ui_key - If provided, only close UIs with this UI key. (OPTIONAL)
 */
/datum/controller/subsystem/tgui/proc/close_user_uis(mob/user, datum/src_object = null, ui_key = null)
	if(isnull(user.open_uis) || !islist(user.open_uis) || open_uis.len == 0)
		return 0 // Couldn't find any UIs for this user.

	var/close_count = 0
	for(var/datum/tgui/ui in user.open_uis)
		if((isnull(src_object) || !isnull(src_object) && ui.src_object == src_object) && (isnull(ui_key) || !isnull(ui_key) && ui.ui_key == ui_key))
			ui.close() // Close the UI.
			close_count++ // Count each UI we close.
	return close_count

/**
 * private
 *
 * Add a UI to the list of open UIs.
 *
 * * datum/tgui/ui - The UI to be added.
 */
/datum/controller/subsystem/tgui/proc/on_open(datum/tgui/ui)
	var/src_object_key = "[ui.src_object.UID()]"
	if(isnull(open_uis[src_object_key]) || !islist(open_uis[src_object_key]))
		open_uis[src_object_key] = list(ui.ui_key = list()) // Make a list for the ui_key and src_object.
	else if(isnull(open_uis[src_object_key][ui.ui_key]) || !islist(open_uis[src_object_key][ui.ui_key]))
		open_uis[src_object_key][ui.ui_key] = list() // Make a list for the ui_key.

	// Append the UI to all the lists.
	ui.user.open_uis |= ui
	var/list/uis = open_uis[src_object_key][ui.ui_key]
	uis |= ui
	processing_uis |= ui

/**
 * private
 *
 * Remove a UI from the list of open UIs.
 * Returns TRUE if removed, and FALSE if not.
 *
 * * datum/tgui/ui - The UI to be removed.
 */
/datum/controller/subsystem/tgui/proc/on_close(datum/tgui/ui)
	var/src_object_key = "[ui.src_object.UID()]"
	if(isnull(open_uis[src_object_key]) || !islist(open_uis[src_object_key]))
		return FALSE // It wasn't open.
	else if(isnull(open_uis[src_object_key][ui.ui_key]) || !islist(open_uis[src_object_key][ui.ui_key]))
		return FALSE // It wasn't open.

	processing_uis.Remove(ui) // Remove it from the list of processing UIs.
	if(ui.user)	// If the user exists, remove it from them too.
		ui.user.open_uis.Remove(ui)
	var/Ukey = ui.ui_key
	var/list/uis = open_uis[src_object_key][Ukey] // Remove it from the list of open UIs.
	uis.Remove(ui)
	if(!uis.len)
		var/list/uiobj = open_uis[src_object_key]
		uiobj.Remove(Ukey)
		if(!uiobj.len)
			open_uis.Remove(src_object_key)

	return TRUE // Let the caller know we did it.

/**
 * private
 *
 * Handle client logout, by closing all their UIs.
 * Returns the number of UIs closed.
 *
 * * mob/user - The mob which logged out.
 */
/datum/controller/subsystem/tgui/proc/on_logout(mob/user)
	return close_user_uis(user)

/**
 * private
 *
 * Handle clients switching mobs, by transferring their UIs.
 * Returns TRUE if the UIs were transferred, and FALSE if not.
 *
 * * mob/source - The client's original mob.
 * * mob/target - The client's new mob.
 */
/datum/controller/subsystem/tgui/proc/on_transfer(mob/source, mob/target)
	if(!source || isnull(source.open_uis) || !islist(source.open_uis) || open_uis.len == 0)
		return FALSE // The old mob had no open UIs.

	if(isnull(target.open_uis) || !islist(target.open_uis))
		target.open_uis = list() // Create a list for the new mob if needed.

	for(var/datum/tgui/ui in source.open_uis)
		ui.user = target // Inform the UIs of their new owner.
		target.open_uis.Add(ui) // Transfer all the UIs.

	source.open_uis.Cut() // Clear the old list.
	return TRUE // Let the caller know we did it.
