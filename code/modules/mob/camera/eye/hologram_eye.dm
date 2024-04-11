/mob/camera/eye/hologram
	name = "Inactive Hologram Eye"
	ai_detector_visible = FALSE
	acceleration = FALSE
	relay_speech = TRUE
	var/obj/machinery/hologram/holopad/holopad = null

/mob/camera/eye/hologram/Initialize(mapload, name, origin, mob/living/user)
	..()
	holopad = origin
	setLoc(holopad, 0, TRUE)

/mob/camera/eye/hologram/rename_camera(new_name)
	name = "Hologram ([new_name])"

// Hologram eye relaymove code is sinfully and shamelessly ripped
// directly from /client/Move to mimic normal run speed
/mob/camera/eye/hologram/relaymove(mob/user, direct)
	var/turf/step = get_turf(get_step(src, direct))
	var/old_move_delay = user.client.move_delay
	user.client.move_delay = world.time + world.tick_lag
	var/delay = GLOB.configuration.movement.base_run_speed
	if(old_move_delay + world.tick_lag > world.time)
		user.client.move_delay = old_move_delay
	else
		user.client.move_delay = world.time
	if(!(direct & (direct - 1)))
		setLoc(step, delay)
	else
		var/diag_delay = delay * SQRT_2
		setLoc(step, diag_delay)
		if(loc == step)
			delay = diag_delay
	user.last_movement = world.time
	delay = TICKS2DS(-round(-(DS2TICKS(delay))))
	user.client.move_delay += delay

/mob/camera/eye/hologram/validate_active_cameranet()
	..(TRUE)

/mob/camera/eye/hologram/setLoc(T, delay, initial = 0)
	var/turf/step = get_turf(T)
	if(initial)
		return ..(step)
	if(step.z != z || get_dist(step, src) > 1)
		return
	if(delay > 0)
		spawn(delay / 2)
			setLoc(step, 0)
	else
		..()
		update_visibility()
		refresh_visible_icon()
		holopad.move_hologram(user, step)
		if(isAIEye(user_previous_remote_control))
			var/mob/camera/eye/previous_eye = user_previous_remote_control
			previous_eye.setLoc(step)
