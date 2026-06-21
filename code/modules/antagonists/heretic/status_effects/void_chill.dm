/*!
 * Contains the "Void Chill" status effect. Harmful debuff which freezes and slows down non-heretics
 * Cannot affect silicons (How are you gonna freeze a robot?)
 */
/datum/status_effect/void_chill
	id = "void_chill"
	duration = 30 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/void_chill
	status_type = STATUS_EFFECT_REFRESH
	on_remove_on_mob_delete = TRUE
	///Current amount of stacks we have
	var/stacks
	///Maximum of stacks that we could possibly get
	var/stack_limit = 5
	///icon for the overlay
	var/image/stacks_overlay

/datum/status_effect/void_chill/on_creation(mob/living/new_owner, new_stacks, ...)
	. = ..()
	RegisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_stacks_overlay))
	set_stacks(new_stacks)
	owner.add_atom_colour(COLOR_BLUE_LIGHT, TEMPORARY_COLOUR_PRIORITY)
	owner.update_icon(UPDATE_OVERLAYS)

/datum/status_effect/void_chill/on_apply()
	if(issilicon(owner))
		return FALSE
	return TRUE

/datum/status_effect/void_chill/on_remove()
	owner.update_icon(UPDATE_OVERLAYS)
	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_BLUE_LIGHT)
	owner.remove_alt_appearance("heretic_status")
	REMOVE_TRAIT(owner, TRAIT_HYPOTHERMIC, src.UID())
	UnregisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS)

/datum/status_effect/void_chill/tick()
	owner.adjust_bodytemperature(-6 * stacks)

/datum/status_effect/void_chill/refresh(mob/living/new_owner, new_stacks, forced = FALSE)
	. = ..()
	if(forced)
		set_stacks(new_stacks)
	else
		adjust_stacks(new_stacks)
	owner.update_icon(UPDATE_OVERLAYS)

///Updates the overlay that gets applied on our victim
/datum/status_effect/void_chill/proc/update_stacks_overlay(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	linked_alert?.update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)
	owner.remove_alt_appearance("heretic_status")
	stacks_overlay = image('icons/effects/effects.dmi', owner, "void_chill_partial")
	if(stacks >= 5)
		stacks_overlay = image('icons/effects/effects.dmi', owner, "void_chill_oh_fuck")
	owner.add_alt_appearance("heretic_status", stacks_overlay, owner)

/**
 * Setter and adjuster procs for stacks
 *
 * Arguments:
 * - new_stacks
 *
 */

/datum/status_effect/void_chill/proc/set_stacks(new_stacks)
	stacks = max(0, min(stack_limit, new_stacks))
	update_movespeed(stacks)

/datum/status_effect/void_chill/proc/adjust_stacks(new_stacks)
	stacks = max(0, min(stack_limit, stacks + new_stacks))
	update_movespeed(stacks)
	if(stacks >= 5)
		ADD_TRAIT(owner, TRAIT_HYPOTHERMIC, src.UID())


///Updates the movespeed of owner based on the amount of stacks of the debuff
/datum/status_effect/void_chill/proc/update_movespeed(stacks)
	linked_alert.maptext = MAPTEXT_TINY_UNICODE("<span style='text-align:center'>[stacks]</span>")
	if(stacks >= 5 && (!ishuman(owner) || HAS_TRAIT(owner, TRAIT_RESISTCOLD))) // Everyone will feel the cold.
		owner.SetSlowed(30 SECONDS, 1) //Debuff always lasts 30 seconds, and is refreshed when stacks are updated. QED, the slow should always be set to 30 seconds

/datum/status_effect/void_chill/lasting
	id = "lasting_void_chill"

//---- Screen alert
/atom/movable/screen/alert/status_effect/void_chill
	name = "Void Chill"
	desc = "There's something freezing you from within and without. You've never felt cold this oppressive before..."
	icon_state = "void_chill_minor"

/atom/movable/screen/alert/status_effect/void_chill/update_icon_state()
	. = ..()
	if(!istype(attached_effect, /datum/status_effect/void_chill))
		return
	var/datum/status_effect/void_chill/chill_effect = attached_effect
	if(chill_effect.stacks >= 5)
		icon_state = "void_chill_oh_fuck"

/atom/movable/screen/alert/status_effect/void_chill/update_desc(updates)
	. = ..()
	if(!istype(attached_effect, /datum/status_effect/void_chill))
		return
	var/datum/status_effect/void_chill/chill_effect = attached_effect
	if(chill_effect.stacks >= 5)
		desc = "You had your chance to run, now it's too late. You may never feel warmth again..."
