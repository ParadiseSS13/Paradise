/// Camera eyes are remote-control mobs that can move and see throughout the global cameranet.
/// They're used in AI eyes, holograms, advanced camera consoles, abductor consoles, shuttle consoles,
/// and xenobiology consoles. When created, the user with which they are initialized will be granted control,
/// and their movements will be relayed to the camera eye instead. When destroyed, the user's control of the
/// camera eye will be released; if they were previously remote controlling another object (such as another
/// camera eye) then they will be put back in control of that object; otherwise they will return to their body.
/mob/camera/eye
	name = "Inactive Camera Eye"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "camera_target"
	alpha = 127
	invisibility = INVISIBILITY_HIGH

	/// The list of camera chunks currently visible to the camera eye.
	var/list/visible_camera_chunks = list()
	/// The user controlling the eye.
	var/mob/living/user
	/// The thing that the user was previously remote controlling before this eye.
	var/user_previous_remote_control
	/// The object that created the eye.
	var/origin
	/// If true, speech near the camera eye will be relayed to its controller.
	var/relay_speech = FALSE
	/// Sets the camera eye visibility range; does not expand viewport, only affects cameranet obscuring
	var/static_visibility_range = 16
	/// Toggles whether this eye is detectable by AI Detectors.
	var/ai_detector_visible = TRUE
	/// Toggles whether the eye's icon should be visible to its user.
	var/visible_icon = FALSE
	/// The list of cameranets that this camera eye can see and access.
	var/list/networks = list("SS13")
	/// The in-memory image of the camera eye's icon.
	var/image/user_image

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
	if(!validate_active_cameranet())
		return INITIALIZE_HINT_QDEL

/// Validates that there is an active cameranet. If strict is 0, does nothing.
/// Returns 1 if there is an active cameranet. Warns the user and returns 0 if there is not.
/mob/camera/eye/proc/validate_active_cameranet(strict = 0)
	var/camera = first_active_camera()
	if(strict && !camera)
		to_chat(user, "<span class='warning'>ERROR: No linked and active camera network found.</span>")
		return FALSE
	return TRUE

/// Returns the turf of the first active camera in the global cameranet.
/mob/camera/eye/proc/first_active_camera()
	for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		if(!C.can_use())
			continue
		if(length(C.network & networks))
			return get_turf(C)

/// Updates what the global cameranet can see with respect to this eye and its user's client.
/mob/camera/eye/proc/update_visibility()
	GLOB.cameranet.visibility(src, user.client)

/// Refreshes user_image in the user's client.images.
/mob/camera/eye/proc/refresh_visible_icon()
	if(visible_icon && user.client)
		user.client.images -= user_image
		user_image = image(icon,loc,icon_state,FLY_LAYER)
		user.client.images += user_image

/// Sets the camera eye's location to T, updates global cameranet visibility, and refreshes user_images.
/mob/camera/eye/set_loc(T)
	if(user)
		T = get_turf(T)
		..(T)
		update_visibility()
		refresh_visible_icon()

/// Disables independent movement by camera eyes; camera eyes must be controlled by relaymove.
/mob/camera/eye/Move()
	return FALSE

/// If `usr` is an AI, set the camera eye's location to the location of the atom clicked.
/atom/proc/move_camera_by_click()
	if(is_ai(usr))
		var/mob/living/silicon/ai/AI = usr
		if(AI.eyeobj && (AI.client.eye == AI.eyeobj) && (AI.eyeobj.z == z))
			AI.camera_follow = null
			if(isturf(loc) || isturf(src))
				AI.eyeobj.set_loc(src)

/// Returns the user's client, if it exists; otherwise returns null.
/mob/camera/eye/proc/get_viewer_client()
	return user?.client

/// Removes obscured chunk images and user_images from the user's client.images.
/mob/camera/eye/proc/remove_images()
	var/client/C = get_viewer_client()
	if(!C)
		return
	for(var/datum/camerachunk/chunk as anything in visible_camera_chunks)
		C.images -= chunk.obscured
	if(visible_icon)
		C.images -= user_image

/// Calls `remove_images`, changes the user's remote control from this camera eye to `user_previous_remote_control`.
/mob/camera/eye/proc/release_control()
	if(!istype(user))
		return
	if(user.client)
		user.reset_perspective(user.client.mob)
		remove_images()
	user.remote_control = null
	if(user_previous_remote_control)
		user.reset_perspective(user_previous_remote_control)
		user.remote_control = user_previous_remote_control
		user_previous_remote_control = null
	user = null

/// Forces this eye's current user to release control, renames this eye, and grants `new_user` control of this eye.
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

/// Renames the camera eye (only visible in observer Orbit menu)
/mob/camera/eye/proc/rename_camera(new_name)
	name = "Camera Eye ([new_name])"

/// Remove this eye from all chunks containing it.
/mob/camera/eye/proc/release_chunks()
	for(var/datum/camerachunk/chunk as anything in visible_camera_chunks)
		chunk.remove(src)

/mob/camera/eye/Destroy()
	release_control()
	release_chunks()
	return ..()

/// Called when the user controlling this eye attempts to move; uses camera acceleration settings.
/mob/camera/eye/relaymove(mob/user,direct)
	var/initial = initial(sprint)

	if(cooldown && cooldown < world.timeofday)
		sprint = initial

	for(var/i in 0 to sprint step sprint_threshold)
		var/turf/next_step= get_turf(get_step(src, direct))
		if(next_step)
			set_loc(next_step)

	cooldown = world.timeofday + cooldown_rate
	if(acceleration)
		sprint = min(sprint + acceleration_rate, max_sprint)
	else
		sprint = initial

/// If `relay_speech` is truthy, allows the camera eye's user to hear speech spoken at the eye's location.
/mob/camera/eye/hear_say(list/message_pieces, verb = "says", italics = 0, mob/speaker = null, sound/speech_sound, sound_vol, sound_frequency, use_voice = TRUE)
	if(relay_speech)
		user.hear_say(message_pieces, verb, italics, speaker, speech_sound, sound_vol, sound_frequency)
