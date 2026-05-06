/datum/flockdrone_part
	var/mob/living/basic/flock/drone/drone
	/// Reference to the associated screen object, if it exists (grr mobs that havent had a player connected)
	var/atom/movable/screen/flockdrone_part/screen_obj

/datum/flockdrone_part/New(drone)
	src.drone = drone

/datum/flockdrone_part/Destroy(force, ...)
	screen_obj?.part_ref = null
	screen_obj = null
	drone = null
	return ..()

/datum/flockdrone_part/proc/is_active()
	return drone.active_part == src

/// Called when a drone with this part active left clicks on an atom. in_reach is TRUE if the target atom is reachable.
/datum/flockdrone_part/proc/left_click_on(atom/target, in_reach)
	return

/// Called when a drone with this part active right clicks on an atom. in_reach is TRUE if the target atom is reachable.
/datum/flockdrone_part/proc/right_click_on(atom/target, in_reach)
	return
