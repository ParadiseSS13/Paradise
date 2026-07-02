/datum/action/cooldown/flock/designate_enemy
	name = "Designate Enemy"
	desc = "Mark or unmark someone as an enemy."
	button_icon_state = "designate_enemy"

	click_to_activate = TRUE
	unset_after_click = FALSE
	click_cd_override = 0

/datum/action/cooldown/flock/designate_enemy/is_valid_target(atom/cast_on)
	var/atom/movable/target_movable = cast_on
	if(!istype(target_movable))
		return FALSE
	return !isflockmob(cast_on) && isliving(cast_on) || target_movable.has_buckled_mobs()

/datum/action/cooldown/flock/designate_enemy/Activate(atom/target)
	var/mob/camera/flock/ghost_bird = owner
	var/datum/flock/flock = ghost_bird.flock
	if(!flock)
		return FALSE

	. = ..()

	if(flock.is_mob_ignored(target))
		flock.remove_ignore(target)

	else if(flock.is_mob_enemy(target))
		flock.remove_enemy(target)
		return TRUE

	flock.update_enemy(target)
	return TRUE

/datum/action/cooldown/flock/designate_ignore
	name = "Designate Ignore"
	desc = "Designate someone to be ignored by your Flock."
	button_icon_state = "designate_ignore"

	click_to_activate = TRUE
	unset_after_click = FALSE

/datum/action/cooldown/flock/designate_ignore/is_valid_target(atom/cast_on)
	var/atom/movable/target_movable = cast_on
	if(!istype(target_movable))
		return FALSE
	return !isflockmob(cast_on) && isliving(cast_on) || target_movable.has_buckled_mobs()

/datum/action/cooldown/flock/designate_ignore/Activate(atom/target)
	var/mob/camera/flock/ghost_bird = owner
	var/datum/flock/flock = ghost_bird.flock
	if(!flock)
		return FALSE

	. = ..()

	if(flock.is_mob_ignored(target))
		flock.remove_ignore(target)

	else if(flock.is_mob_enemy(target))
		flock.remove_enemy(target)
		return TRUE

	flock.add_ignore(target)
	return TRUE

