/**
 * Base state and helpers for states. Just does some sanity checks,
 * implement a proper state for in-depth checks.
 *
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * public
 *
 * Checks the UI state for a mob.
 *
 * required user mob The mob who opened/is using the UI.
 * required state datum/ui_state The state to check.
 *
 * return UI_state The state of the UI.
 */
/datum/proc/ui_status(mob/user, datum/ui_state/state)
	var/src_object = ui_host(user)
	. = UI_CLOSE
	if(!state)
		return

	if(isobserver(user))
		// If they turn on ghost AI control, admins can always interact.
		if(user.can_admin_interact())
			. = max(., UI_INTERACTIVE)

		// Regular ghosts can always at least view if in range.
		if(user.client)
			var/clientviewlist = getviewsize(user.client.view)
			if(get_dist(src_object, user) < max(clientviewlist[1], clientviewlist[2]))
				. = max(., UI_UPDATE)

	// Check if the state allows interaction
	var/result = state.can_use_topic(src_object, user)
	. = max(., result)

/**
 * private
 *
 * Checks if a user can use src_object's UI, and returns the state.
 * Can call a mob proc, which allows overrides for each mob.
 *
 * required src_object datum The object/datum which owns the UI.
 * required user mob The mob who opened/is using the UI.
 *
 * return UI_state The state of the UI.
 */
/datum/ui_state/proc/can_use_topic(src_object, mob/user)
	// Don't allow interaction by default.
	return UI_CLOSE

/**
 * public
 *
 * Standard interaction/sanity checks. Different mob types may have overrides.
 *
 * return UI_state The state of the UI.
 */
/mob/proc/shared_ui_interaction(src_object)
	// Close UIs if mindless.
	if(!client)
		return UI_CLOSE
	// Disable UIs if unconcious.
	else if(stat)
		return UI_DISABLED
	// Update UIs if incapicitated but concious.
	else if(incapacitated())
		return UI_UPDATE
	return UI_INTERACTIVE

/mob/living/silicon/ai/shared_ui_interaction(src_object)
	// Disable UIs if the AI is unpowered.
	if(lacks_power() && !apc_override)
		return UI_DISABLED
	return ..()

/mob/living/silicon/robot/shared_ui_interaction(src_object)
	// Disable UIs if the Borg is unpowered or locked.
	if(!cell || cell.charge <= 0 || lockcharge)
		return UI_DISABLED
	return ..()

/**
 * public
 *
 * Check the distance for a living mob.
 * Really only used for checks outside the context of a mob.
 * Otherwise, use shared_living_ui_distance().
 *
 * required src_object The object which owns the UI.
 * required user mob The mob who opened/is using the UI.
 *
 * return UI_state The state of the UI.
 */
/atom/proc/contents_ui_distance(src_object, mob/living/user)
	// Just call this mob's check.
	return user.shared_living_ui_distance(src_object)

/**
 * public
 *
 * Distance versus interaction check.
 *
 * required src_object atom/movable The object which owns the UI.
 *
 * return UI_state The state of the UI.
 */
/mob/living/proc/shared_living_ui_distance(atom/movable/src_object, viewcheck = TRUE)
	// If the object is obscured, close it.
	if(viewcheck && !(src_object in view(src)))
		return UI_CLOSE
	var/dist = get_dist(src_object, src)
	// Open and interact if 1-0 tiles away.
	if(dist <= 1)
		return UI_INTERACTIVE
	// View only if 2-3 tiles away.
	else if(dist <= 2)
		return UI_UPDATE
	// Disable if 5 tiles away.
	else if(dist <= 5)
		return UI_DISABLED
	// Otherwise, we got nothing.
	return UI_CLOSE

/mob/living/carbon/human/shared_living_ui_distance(atom/movable/src_object, viewcheck)
	if(HAS_TRAIT(src, TRAIT_TELEKINESIS) && (get_dist(src, src_object) <= 2))
		return UI_INTERACTIVE
	if(ismecha(loc) && get_dist(loc, src_object) <= 1)
		return UI_INTERACTIVE
	return ..()
