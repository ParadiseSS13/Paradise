/**
 * A component that should be attached to things that have been tilted over, and can be righted.
 * This can optionally block normal attack_hand interactions
 */

/datum/component/tilted
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// How long it should take to untilt
	var/untilt_duration
	/// Whether we should block any interactions with it
	var/block_interactions
	/// The angle by which we rotated as a result of tilting. Should help us avoid cases where something gets tilted until it's upright.
	var/rotated_angle

/datum/component/tilted/Initialize(_untilt_duration = 16 SECONDS, _block_interactions = FALSE, _rotated_angle)
	. = ..()
	untilt_duration = _untilt_duration
	block_interactions = _block_interactions
	rotated_angle = _rotated_angle

/datum/component/tilted/InheritComponent(datum/component/C, i_am_original, _untilt_duration, _block_interactions, _rotated_angle)
	. = ..()
	untilt_duration = _untilt_duration
	block_interactions = _block_interactions
	rotated_angle += _rotated_angle

	if(rotated_angle % 360 == 0)
		qdel(src)

/datum/component/tilted/RegisterWithParent()
	. = ..()

	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(on_alt_click))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_interact))
	RegisterSignal(parent, COMSIG_MOVABLE_TRY_UNTILT, PROC_REF(on_try_untilt))
	RegisterSignal(parent, COMSIG_MOVABLE_UNTILTED, PROC_REF(on_untilt))

/datum/component/tilted/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_CLICK_ALT)
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND)
	UnregisterSignal(parent, COMSIG_MOVABLE_TRY_UNTILT)
	UnregisterSignal(parent, COMSIG_MOVABLE_UNTILTED)

/datum/component/tilted/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER  // COMSIG_PARENT_EXAMINE
	examine_list += "<span class='notice'>It's been tilted over. <i>Alt+Click</i> it to right it.</span>"

/datum/component/tilted/proc/on_alt_click(atom/source, mob/user)
	SIGNAL_HANDLER  // COMSIG_CLICK_ALT
	INVOKE_ASYNC(src, PROC_REF(untilt), user, untilt_duration)
	return COMPONENT_CANCEL_ALTCLICK

/datum/component/tilted/proc/on_interact(atom/source, mob/user)
	SIGNAL_HANDLER  // COMSIG_ATOM_ATTACK_HAND
	if(block_interactions)
		to_chat(user, "<span class='warning'>You can't do that right now, you need to right it first!</span>")
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/tilted/proc/on_untilt(atom/source, mob/user)
	SIGNAL_HANDLER
	qdel(src)

/datum/component/tilted/proc/on_try_untilt(atom/source, mob/living/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(untilt), user, untilt_duration)

/// Untilt a tilted object.
/datum/component/tilted/proc/untilt(mob/living/user, duration = 10 SECONDS)
	var/atom/movable/atom_parent = parent

	if(!istype(atom_parent))
		return

	if(!istype(user) || !atom_parent.Adjacent(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	if(user)
		user.visible_message(
			"[user] begins to right [parent].",
			"You begin to right [parent]."
		)
		if(!do_after(user, duration, TRUE, parent))
			return
		user.visible_message(
			"<span class='notice'>[user] rights [parent].</span>",
			"<span class='notice'>You right [parent].</span>",
			"<span class='notice'>You hear a loud clang.</span>"
		)

	if(QDELETED(atom_parent))
		return

	atom_parent.unbuckle_all_mobs(TRUE)

	SEND_SIGNAL(parent, COMSIG_MOVABLE_UNTILTED, user)

	atom_parent.layer = initial(atom_parent.layer)

	var/matrix/M = matrix()
	M.Turn(0)
	atom_parent.transform = M
	if(istype(user) && user.incapacitated())
		return COMPONENT_BLOCK_UNTILT
