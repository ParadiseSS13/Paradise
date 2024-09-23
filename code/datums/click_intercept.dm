/**
 * # Click intercept datum
 *
 * Datum which is intended to be stored by a client's `click_intercept` variable.
 * Used to override normal clicking behavior when clicking on an object.
 * While active, a mob's `ClickOn` proc will redirect to the `InterceptClickOn()` proc instead.
 */
/datum/click_intercept
	/// A reference to the client which is assigned this click intercept datum.
	var/client/holder = null
	/// Any `atom/movable/screen/buttons` the client is meant to receive when assigned this click intercept datum.
	var/list/atom/movable/screen/buttons = list()

/datum/click_intercept/New(client/C)
	create_buttons()
	holder = C
	holder.click_intercept = src
	holder.show_popup_menus = FALSE
	holder.screen += buttons
	return ..()

/datum/click_intercept/Destroy()
	holder.screen -= buttons
	holder.click_intercept = null
	holder.show_popup_menus = TRUE
	holder = null
	QDEL_LIST_CONTENTS(buttons)
	return ..()

/**
 * Called when you want to cancel a client's click intercept and return to normal clicking.
 */
/datum/click_intercept/proc/quit()
	qdel(src)

/**
 * Base proc, intended to be overriden. Code that adds datum specific buttons to the list of `buttons`, should go here.
 */
/datum/click_intercept/proc/create_buttons()
	return

/**
 * Called in various mob's `ClickOn` procs, which happens when they click on an object in the world.
 *
 * If the mob's `client.click_intercept` variable is set to something other than null, calls the `InterceptClickOn` proc for that click intercept datum. Aka, this proc.
 *
 * Arguments:
 * * user - the mob which just clicked on something.
 * * params - the `params` arguemnt passed from the `ClickOn` proc.
 * * object - the atom that was just clicked.
 */
/datum/click_intercept/proc/InterceptClickOn(mob/user, params, atom/object)
	return
