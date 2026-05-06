/datum/action/cooldown/flock/release_control
	name = "Release Control"
	desc = "Release yourself from this drone."
	button_icon_state = "eject"

/datum/action/cooldown/flock/release_control/Activate(atom/target)
	. = ..()
	var/mob/living/basic/flock/drone/bird = owner
	if(!bird.flock)
		to_chat(bird, span_warning("You have no flock to return to."))
		return

	bird.release_control(TRUE)
