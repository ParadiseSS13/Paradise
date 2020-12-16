/**
 * tgui state: default_state
 *
 * Checks a number of things -- mostly physical distance for humans and view for robots.
 */

GLOBAL_DATUM_INIT(default_state, /datum/ui_state/default, new)

/datum/ui_state/default/can_use_topic(src_object, mob/user)
	return user.default_can_use_topic(src_object) // Call the individual mob-overridden procs.

/mob/proc/default_can_use_topic(src_object)
	return STATUS_CLOSE // Don't allow interaction by default.

/mob/living/default_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. > STATUS_CLOSE && loc)
		. = min(., loc.contents_ui_distance(src_object, src)) // Check the distance...
	if(. == STATUS_INTERACTIVE) // Non-human living mobs can only look, not touch.
		return STATUS_UPDATE

/mob/living/carbon/human/default_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. > STATUS_CLOSE)
		. = min(., shared_living_ui_distance(src_object)) // Check the distance...

/mob/living/silicon/robot/default_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. <= STATUS_DISABLED)
		return

	// Robots can interact with anything they can see.
	var/list/clientviewlist = getviewsize(client.view)
	if((src_object in view(src)) && (get_dist(src, src_object) <= min(clientviewlist[1],clientviewlist[2])))
		return STATUS_INTERACTIVE
	return STATUS_DISABLED // Otherwise they can keep the UI open.

/mob/living/silicon/ai/default_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. < STATUS_INTERACTIVE)
		return

	// The AI can interact with anything it can see nearby, or with cameras while wireless control is enabled.
	if(!control_disabled && can_see(src_object))
		return STATUS_INTERACTIVE
	return STATUS_CLOSE

/mob/living/simple_animal/revenant/default_can_use_topic(src_object)
	return STATUS_UPDATE

/mob/living/simple_animal/default_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. > STATUS_CLOSE)
		. = min(., shared_living_ui_distance(src_object)) //simple animals can only use things they're near.

/mob/living/silicon/pai/default_can_use_topic(src_object)
	// pAIs can only use themselves and the owner's radio.
	if((src_object == src || src_object == radio) && !stat)
		return STATUS_INTERACTIVE
	else
		return ..()

/mob/dead/observer/default_can_use_topic()
	if(can_admin_interact())
		return STATUS_INTERACTIVE				// Admins are more equal
	return STATUS_UPDATE						// Ghosts can view updates
