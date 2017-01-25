// AI EYE
//
// An invisible (no icon) mob that the AI controls to look around the station with.
// It streams chunks as it moves around, which will show it what the AI can and cannot see.

/mob/camera/aiEye
	name = "Inactive AI Eye"

	icon = 'icons/mob/AI.dmi' //Allows ghosts to see what the AI is looking at.
	icon_state = "eye"
	alpha = 127
	invisibility = SEE_INVISIBLE_OBSERVER

	var/list/visibleCameraChunks = list()
	var/mob/living/silicon/ai/ai = null
	var/relay_speech = FALSE


// Use this when setting the aiEye's location.
// It will also stream the chunk that the new loc is in.

/mob/camera/aiEye/setLoc(T)

	if(ai)
		if(!isturf(ai.loc))
			return
		T = get_turf(T)
		loc = T
		cameranet.visibility(src)
		if(ai.client)
			ai.client.eye = src
		//Holopad
		if(ai.holo)
			ai.holo.move_hologram()

/mob/camera/aiEye/Move()
	return 0

/mob/camera/aiEye/proc/GetViewerClient()
	if(ai)
		return ai.client
	return null

/mob/camera/aiEye/Destroy()
	ai = null
	return ..()

/atom/proc/move_camera_by_click()
	if(istype(usr, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = usr
		if(AI.eyeobj && AI.client.eye == AI.eyeobj)
			AI.cameraFollow = null
			if(isturf(src.loc) || isturf(src))
				AI.eyeobj.setLoc(src)

// AI MOVEMENT

// This will move the AIEye. It will also cause lights near the eye to light up, if toggled.
// This is handled in the proc below this one.

/client/proc/AIMove(n, direct, var/mob/living/silicon/ai/user)

	var/initial = initial(user.sprint)
	var/max_sprint = 50

	if(user.cooldown && user.cooldown < world.timeofday) // 3 seconds
		user.sprint = initial

	for(var/i = 0; i < max(user.sprint, initial); i += 20)
		var/turf/step = get_turf(get_step(user.eyeobj, direct))
		if(step)
			user.eyeobj.setLoc(step)

	user.cooldown = world.timeofday + 5
	if(user.acceleration)
		user.sprint = min(user.sprint + 0.5, max_sprint)
	else
		user.sprint = initial

	if(!user.tracking)
		user.cameraFollow = null

	//user.unset_machine() //Uncomment this if it causes problems.
	//user.lightNearbyCamera()
	if(user.camera_light_on)
		user.light_cameras()

// Return to the Core.
/mob/living/silicon/ai/proc/core()
	set category = "AI Commands"
	set name = "AI Core"

	view_core()

/mob/living/silicon/ai/proc/view_core()

	current = null
	cameraFollow = null
	unset_machine()

	if(src.eyeobj && src.loc)
		src.eyeobj.loc = src.loc
	else
		to_chat(src, "ERROR: Eyeobj not found. Creating new eye...")
		src.eyeobj = new(src.loc)
		src.eyeobj.ai = src
		src.eyeobj.name = "[src.name] (AI Eye)" // Give it a name

	eyeobj.setLoc(loc)

/mob/living/silicon/ai/proc/toggle_acceleration()
	set category = "AI Commands"
	set name = "Toggle Camera Acceleration"

	if(usr.stat == 2)
		return //won't work if dead
	acceleration = !acceleration
	to_chat(usr, "Camera acceleration has been toggled [acceleration ? "on" : "off"].")

/mob/camera/aiEye/hear_say(var/message, var/verb = "says", var/datum/language/language = null, var/alt_name = "", var/italics = 0, var/mob/speaker = null, var/sound/speech_sound, var/sound_vol)
	if(relay_speech)
		ai.relay_speech(speaker, message, verb, language)
