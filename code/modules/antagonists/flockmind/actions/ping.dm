/datum/action/cooldown/flock/ping
	name = "Ping"
	desc = "Request attention from other partitions of the Flock."
	button_icon_state = "ping"
	cooldown_time = 5 SECONDS
	click_to_activate = TRUE

/datum/action/cooldown/flock/ping/is_valid_target(atom/cast_on)
	return get_turf(cast_on)

/datum/action/cooldown/flock/ping/Activate(atom/target)
	. = ..()
	var/mob/camera/flock/ghost_bird = owner
	ghost_bird.flock.ping(target, ghost_bird)
