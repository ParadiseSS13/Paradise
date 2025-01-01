/mob/camera/eye
	name = "Inactive Camera Eye"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "camera_target"
	alpha = 127
	invisibility = SEE_INVISIBLE_OBSERVER

	var/list/visibleCameraChunks = list()
	var/mob/living/user = null
	var/user_previous_remote_control = null
	var/origin = null
	var/relay_speech = FALSE
	var/static_visibility_range = 16
	// Decides if it is shown by AI Detector or not
	var/ai_detector_visible = TRUE
	var/visible_icon = FALSE
	var/list/networks = list("SS13")
	var/image/user_image = null

	// Camera acceleration settings
	// Initially, the camera moves one turf per move. If there is no movement for
	// cooldown_rate in deciseconds, the camera will reset to this movement rate.
	// Every move otherwise increases sprint by acceleration_rate, until sprint
	// exceeds sprint_threshold, and the movement rate increases by one per move.
	// The movement rate is 1 + round(sprint / sprint_threshold).

	/// The maximum sprint value - this caps acceleration
	var/max_sprint = 50
	/// The minimum sprint needed to increase base velocity
	var/sprint_threshold = 20
	/// The amount that sprint is increased per move
	var/acceleration_rate = 0.5
	/// Keeps track of acceleration - movement rate is 1 + round(sprint / sprint_threshold)
	var/sprint = 10
	/// The absolute time that sprint will reset to its initial value
	var/cooldown = 0
	/// The time after which sprint should be reset to its initial state, if no movements are made
	var/cooldown_rate = 5
	/// Toggles camera acceleration on or off.
	var/acceleration = 1

/mob/camera/eye/Initialize(mapload, owner_name, camera_origin, mob/living/user)
	. = ..()
	name = "Camera Eye ([owner_name])"
	origin = camera_origin
	give_control(user)
	update_visibility()
	refresh_visible_icon()
	validate_active_cameranet()

/mob/camera/eye/proc/validate_active_cameranet(strict = 0)
	var/camera = first_active_camera()
	if(strict && !camera)
		to_chat(user, "<span class='warning'>ERROR: No linked and active camera network found.</span>")
		qdel(src)

/mob/camera/eye/proc/first_active_camera()
	for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		if(!C.can_use())
			continue
		if(length(C.network & networks))
			return get_turf(C)
	
/mob/camera/eye/proc/update_visibility()
	GLOB.cameranet.visibility(src, user.client)

/mob/camera/eye/proc/refresh_visible_icon()
	if(visible_icon && user.client)
		user.client.images -= user_image
		user_image = image(icon,loc,icon_state,FLY_LAYER)
		user.client.images += user_image

/mob/camera/eye/setLoc(T, hide_unseen_with_static = 1)
	if(user)
		T = get_turf(T)
		..(T)
		update_visibility()
		refresh_visible_icon()

/mob/camera/eye/Move()
	return FALSE

/atom/proc/move_camera_by_click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		if(AI.eyeobj && (AI.client.eye == AI.eyeobj) && (AI.eyeobj.z == z))
			AI.cameraFollow = null
			if(isturf(loc) || isturf(src))
				AI.eyeobj.setLoc(src)

/mob/camera/eye/proc/GetViewerClient()
	return user?.client

/mob/camera/eye/proc/RemoveImages()
	var/client/C = GetViewerClient()
	if(!C)
		return
	for(var/datum/camerachunk/chunk as anything in visibleCameraChunks)
		C.images -= chunk.obscured
	if(visible_icon)
		C.images -= user_image

/mob/camera/eye/proc/release_control()
	if(!istype(user))
		return
	if(user.client)
		user.reset_perspective(user.client.mob)
		RemoveImages()
	user.remote_control = null
	if(user_previous_remote_control)
		user.reset_perspective(user_previous_remote_control)
		user.remote_control = user_previous_remote_control
		user_previous_remote_control = null
	user = null

/mob/camera/eye/proc/give_control(mob/new_user)
	if(!istype(new_user))
		return
	release_control()
	user = new_user
	rename_camera(user.name)
	if(istype(user.remote_control))
		user_previous_remote_control = user.remote_control
	user.remote_control = src
	user.reset_perspective(src)

/mob/camera/eye/proc/rename_camera(new_name)
	name = "Camera Eye ([new_name])"

/mob/camera/eye/proc/release_chunks()
	for(var/datum/camerachunk/chunk as anything in visibleCameraChunks)
		chunk.remove(src)

/mob/camera/eye/Destroy()
	release_control()
	release_chunks()
	return ..()

/mob/camera/eye/relaymove(mob/user,direct)
	var/initial = initial(sprint)

	if(cooldown && cooldown < world.timeofday)
		sprint = initial
	
	for(var/i in 0 to sprint step sprint_threshold)
		var/turf/next_step= get_turf(get_step(src, direct))
		if(next_step)
			setLoc(next_step)

	cooldown = world.timeofday + cooldown_rate
	if(acceleration)
		sprint = min(sprint + acceleration_rate, max_sprint)
	else
		sprint = initial

/mob/camera/eye/hear_say(list/message_pieces, verb = "says", italics = 0, mob/speaker = null, sound/speech_sound, sound_vol, sound_frequency, use_voice = TRUE)
	if(relay_speech)
		user.hear_say(message_pieces, verb, italics, speaker, speech_sound, sound_vol, sound_frequency)
