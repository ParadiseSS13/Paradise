/datum/element/tilted
	element_flags = ELEMENT_BESPOKE
	var/tilt_angle
	var/untilt_duration

/datum/element/tilted/Attach(datum/target, tilt_angle, untilt_duration = 7 SECONDS)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	src.tilt_angle = tilt_angle
	src.untilt_duration = untilt_duration
	RegisterSignal(target, COMSIG_CLICK_ALT, PROC_REF(on_alt_click))

/datum/element/tilted/proc/on_alt_click(atom/source, mob/user)
	SIGNAL_HANDLER  // COMSIG_CLICK_ALT
	INVOKE_ASYNC(src, PROC_REF(do_untilt), source, user)
	return COMPONENT_CANCEL_ALTCLICK

/datum/element/tilted/proc/do_untilt(atom/movable/source, mob/user)

	if(SEND_SIGNAL(source, COMSIG_MOVABLE_TRY_UNTILT, user) & COMPONENT_BLOCK_UNTILT)
		return

	if(user)
		user.visible_message(
			"[user] begins to right [src].",
			"You begin to right [src]."
		)
		if(!do_after(user, untilt_duration, TRUE, src))
			return
		user.visible_message(
			"<span class='notice'>[user] rights [src].</span>",
			"<span class='notice'>You right [src].</span>",
			"<span class='notice'>You hear a loud clang.</span>"
		)

	source.unbuckle_all_mobs(TRUE)

	SEND_SIGNAL(source, COMSIG_MOVABLE_UNTILTED, user)

	source.layer = initial(source.layer)

	var/matrix/M = matrix()
	M.Turn(0)
	source.transform = M




