/datum/action/cooldown/flock/diffract_drone
	name = "Diffract Drone"
	desc = "Split a drone into flockbits, mindless automata that only convert whatever they find."
	button_icon_state = "diffract"
	click_to_activate = TRUE

/datum/action/cooldown/flock/diffract_drone/is_valid_target(atom/cast_on)
	if(!isflockdrone(cast_on))
		return FALSE

	var/mob/living/basic/flock/drone/bird = cast_on
	if(bird.stat == DEAD)
		return FALSE

	return TRUE

/datum/action/cooldown/flock/diffract_drone/PreActivate(atom/target)
	. = ..()

/datum/action/cooldown/flock/diffract_drone/Activate(atom/target)
	. = ..()
	var/mob/living/basic/flock/drone/bird = target
	bird.split_into_bits()
