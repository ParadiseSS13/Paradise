/mob/camera/eye/hologram
	name = "Inactive Hologram Eye"
	ai_detector_visible = FALSE
	acceleration = FALSE
	var/obj/machinery/hologram/holopad/holopad

/mob/camera/eye/hologram/Initialize(mapload, owner_name, camera_origin, mob/living/user)
	..()
	holopad = camera_origin
	set_loc(holopad)

/mob/camera/eye/hologram/rename_camera(new_name)
	name = "Hologram ([new_name])"

/// Hologram movement copies the delays and diagonal delays of regular mob movement
/// for crew, and for AI unless fast holograms are enabled
/mob/camera/eye/hologram/relaymove(mob/user, direct)
	var/mob/living/silicon/ai/ai = user
	if(istype(ai) && ai.fast_holograms)
		return ..()
	var/turf/new_location = get_turf(get_step(src, direct))
	if(new_location.z != z || get_dist(new_location, src) > 1)
		return
	var/base_delay = GLOB.configuration.movement.base_run_speed
	var/diag_delay = base_delay * SQRT_2
	var/delay = (direct & (direct - 1)) ? diag_delay : base_delay
	user.client.move_delay = debounced_move(normalized_delay_speed(delay))
	user.last_movement = world.time
	set_loc(new_location)

/mob/camera/eye/hologram/proc/debounced_move(delay_speed)
	var/old_move_delay = user.client.move_delay
	if(old_move_delay + world.tick_lag > world.time)
		return old_move_delay + delay_speed
	else
		return world.time + delay_speed

/mob/camera/eye/hologram/proc/normalized_delay_speed(delay_speed)
	return TICKS2DS(-round(-(DS2TICKS(delay_speed))))

/// Requires the cameranet to be validated.
/mob/camera/eye/hologram/validate_active_cameranet()
	..(TRUE)

/// Moves the associated hologram, and the previously controlled object (probably an AI eye), to the new location.
/mob/camera/eye/hologram/set_loc(T)
	. = ..()
	var/turf/new_location = get_turf(T)
	holopad.move_hologram(user, new_location)
	var/mob/camera/eye/previous_eye = user_previous_remote_control
	if(istype(previous_eye))
		previous_eye.set_loc(new_location)
