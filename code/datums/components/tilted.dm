/**
 * A component that should be attached to things that have been tilted over, and can be righted.
 * This can optionally block normal attack_hand interactions
 */

/datum/component/tilted
	/// How long it should take to untilt
	var/untilt_duration
	/// Whether we should block any interactions with it
	var/block_interactions

/datum/component/tilted/Initialize(_untilt_duration = 16 SECONDS, _block_interactions = FALSE)
	. = ..()
	untilt_duration = _untilt_duration
	block_interactions = _block_interactions


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
	INVOKE_ASYNC(parent, TYPE_PROC_REF(/atom/movable, untilt), user, untilt_duration)
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
	if(!istype(user))
		return COMPONENT_BLOCK_UNTILT
	if(user.incapacitated())
		return COMPONENT_BLOCK_UNTILT


/datum/component/tilted/proc/do_untilt(atom/movable/source, mob/user)
	if(SEND_SIGNAL(source, COMSIG_MOVABLE_TRY_UNTILT, user) & COMPONENT_BLOCK_UNTILT)
		return

	if(user)
		user.visible_message(
			"[user] begins to right [parent].",
			"You begin to right [parent]."
		)
		if(!do_after(user, untilt_duration, TRUE, parent))
			return
		user.visible_message(
			"<span class='notice'>[user] rights [parent].</span>",
			"<span class='notice'>You right [parent].</span>",
			"<span class='notice'>You hear a loud clang.</span>"
		)

	source.unbuckle_all_mobs(TRUE)

	SEND_SIGNAL(source, COMSIG_MOVABLE_UNTILTED, user)

	source.layer = initial(source.layer)

	var/matrix/M = matrix()
	M.Turn(0)
	source.transform = M

	qdel(src)




