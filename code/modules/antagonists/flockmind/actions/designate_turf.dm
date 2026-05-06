/datum/action/cooldown/flock/designate_tile
	name = "Designate Priority Tile"
	desc = "Add or remove a tile to the urgent tiles the Flock should claim."
	button_icon_state = "designate_tile"

	click_to_activate = TRUE
	unset_after_click = FALSE
	click_cd_override = 0

/datum/action/cooldown/flock/designate_tile/is_valid_target(atom/cast_on)
	var/turf/T = get_turf(cast_on)
	return T?.can_flock_convert()

/datum/action/cooldown/flock/designate_tile/Activate(atom/target)
	var/turf/turf_target = get_turf(target)
	if(isflockturf(target))
		to_chat(owner, span_alert("That tile has already been converted by the flock."))
		return FALSE

	if(!turf_target.can_flock_convert())
		to_chat(owner, span_alert("The flock is unable to convert that."))
		return FALSE

	var/mob/camera/flock/ghost_bird = owner
	if(!ghost_bird.flock.marked_for_conversion[turf_target])
		if(ghost_bird.flock.turf_reservations[turf_target])
			to_chat(ghost_bird, span_alert("That tile is already scheduled for conversion."))
			return FALSE

		ghost_bird.flock.marked_for_conversion[turf_target] = TRUE
		ghost_bird.flock.add_notice(turf_target, FLOCK_NOTICE_PRIORITY)
		return TRUE

	else
		ghost_bird.flock.marked_for_conversion -= turf_target
		ghost_bird.flock.remove_notice(turf_target, FLOCK_NOTICE_PRIORITY)
		return TRUE
