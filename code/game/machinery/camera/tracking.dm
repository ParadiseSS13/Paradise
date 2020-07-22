/mob/living/silicon/ai/proc/InvalidTurf(turf/T as turf)
	if(!T)
		return 1
	if(!is_level_reachable(T.z))
		return 1
	return 0


/mob/living/silicon/ai/var/max_locations = 10
/mob/living/silicon/ai/var/stored_locations[0]

/mob/living/silicon/ai/proc/get_camera_list()

	track.cameras.Cut()

	if(src.stat == 2)
		return

	var/list/L = list()
	for(var/obj/machinery/camera/C in cameranet.cameras)
		L.Add(C)

	camera_sort(L)

	var/list/T = list()

	for(var/obj/machinery/camera/C in L)
		var/list/tempnetwork = C.network & src.network
		if(tempnetwork.len)
			T[text("[][]", C.c_tag, (C.can_use() ? null : " (Deactivated)"))] = C

	track.cameras = T
	return T


/mob/living/silicon/ai/proc/ai_camera_list(var/camera in get_camera_list())
	set category = "AI Commands"
	set name = "Show Camera List"

	if(src.stat == 2)
		to_chat(src, "You can't list the cameras because you are dead!")
		return

	if(!camera || camera == "Cancel")
		return 0

	var/obj/machinery/camera/C = track.cameras[camera]
	src.eyeobj.setLoc(C)

	return

/mob/living/silicon/ai/proc/ai_store_location(loc as text)
	set category = "AI Commands"
	set name = "Store Camera Location"
	set desc = "Stores your current camera location by the given name"

	loc = sanitize(copytext(loc, 1, MAX_MESSAGE_LEN))
	if(!loc)
		to_chat(src, "<span class='warning'>Must supply a location name</span>")
		return

	if(stored_locations.len >= max_locations)
		to_chat(src, "<span class='warning'>Cannot store additional locations. Remove one first</span>")
		return

	if(loc in stored_locations)
		to_chat(src, "<span class='warning'>There is already a stored location by this name</span>")
		return

	var/L = get_turf(eyeobj)
	if(InvalidTurf(get_turf(L)))
		to_chat(src, "<span class='warning'>Unable to store this location</span>")
		return

	stored_locations[loc] = L
	to_chat(src, "Location '[loc]' stored")

/mob/living/silicon/ai/proc/sorted_stored_locations()
	return sortList(stored_locations)

/mob/living/silicon/ai/proc/ai_goto_location(loc in sorted_stored_locations())
	set category = "AI Commands"
	set name = "Goto Camera Location"
	set desc = "Returns to the selected camera location"

	if(!(loc in stored_locations))
		to_chat(src, "<span class='warning'>Location [loc] not found</span>")
		return

	var/L = stored_locations[loc]
	src.eyeobj.setLoc(L)

/mob/living/silicon/ai/proc/ai_remove_location(loc in sorted_stored_locations())
	set category = "AI Commands"
	set name = "Delete Camera Location"
	set desc = "Deletes the selected camera location"

	if(!(loc in stored_locations))
		to_chat(src, "<span class='warning'>Location [loc] not found</span>")
		return

	stored_locations.Remove(loc)
	to_chat(src, "Location [loc] removed")

// Used to allow the AI is write in mob names/camera name from the CMD line.
/datum/trackable
	var/list/names = list()
	var/list/namecounts = list()
	var/list/humans = list()
	var/list/others = list()
	var/list/cameras = list()

/mob/living/silicon/ai/proc/trackable_mobs()

	track.names.Cut()
	track.namecounts.Cut()
	track.humans.Cut()
	track.others.Cut()

	if(usr.stat == 2)
		return list()

	for(var/mob/living/M in GLOB.mob_list)
		if(!M.can_track(usr))
			continue

		// Human check
		var/human = 0
		if(istype(M, /mob/living/carbon/human))
			human = 1

		var/name = M.name
		if(name in track.names)
			track.namecounts[name]++
			name = text("[] ([])", name, track.namecounts[name])
		else
			track.names.Add(name)
			track.namecounts[name] = 1
		if(human)
			track.humans[name] = M
		else
			track.others[name] = M

	var/list/targets = sortList(track.humans) + sortList(track.others)

	return targets

/mob/living/silicon/ai/proc/ai_camera_track(target_name in trackable_mobs())
	set category = "AI Commands"
	set name = "Track With Camera"
	set desc = "Select who you would like to track."

	if(src.stat == DEAD)
		to_chat(src, "You can't track with camera because you are dead!")
		return
	if(!target_name)
		return

	var/mob/target = (isnull(track.humans[target_name]) ? track.others[target_name] : track.humans[target_name])

	ai_actual_track(target)

/mob/living/silicon/ai/proc/ai_cancel_tracking(var/forced = 0)
	if(!cameraFollow)
		return

	to_chat(src, "Follow camera mode [forced ? "terminated" : "ended"].")
	cameraFollow = null

/mob/living/silicon/ai/proc/ai_actual_track(mob/living/target)
	if(!istype(target))
		return
	var/mob/living/silicon/ai/U = usr

	U.cameraFollow = target
	U.tracking = 1

	to_chat(U, "<span class='notice'>Attempting to track [target.get_visible_name()]...</span>")
	sleep(min(30, get_dist(target, U.eyeobj) / 4))
	spawn(15) //give the AI a grace period to stop moving.
		U.tracking = 0

	if(!target || !target.can_track(usr))
		to_chat(U, "<span class='warning'>Target is not near any active cameras.</span>")
		U.cameraFollow = null
		return

	to_chat(U, "<span class='notice'>Now tracking [target.get_visible_name()] on camera.</span>")

	var/cameraticks = 0
	spawn(0)
		while(U.cameraFollow == target)
			if(U.cameraFollow == null)
				return

			if(!target.can_track(usr))
				U.tracking = 1
				if(!cameraticks)
					to_chat(U, "<span class='warning'>Target is not near any active cameras. Attempting to reacquire...</span>")
				cameraticks++
				if(cameraticks > 9)
					U.cameraFollow = null
					to_chat(U, "<span class='warning'>Unable to reacquire, cancelling track...</span>")
					U.tracking = 0
					return
				else
					sleep(10)
					continue

			else
				cameraticks = 0
				U.tracking = 0

			if(U.eyeobj)
				U.eyeobj.setLoc(get_turf(target))

			else
				view_core()
				U.cameraFollow = null
				return

			sleep(10)

/proc/near_camera(mob/living/M)
	if(!isturf(M.loc))
		return 0
	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(!(R.camera && R.camera.can_use()) && !cameranet.checkCameraVis(M))
			return 0
	else if(!cameranet.checkCameraVis(M))
		return 0
	return 1

/obj/machinery/camera/attack_ai(mob/living/silicon/ai/user)
	if(!istype(user))
		return
	if(!src.can_use())
		return
	user.eyeobj.setLoc(get_turf(src))


/mob/living/silicon/ai/attack_ai(mob/user)
	ai_camera_list()

/proc/camera_sort(list/L)
	var/obj/machinery/camera/a
	var/obj/machinery/camera/b

	for(var/i = L.len, i > 0, i--)
		for(var/j = 1 to i - 1)
			a = L[j]
			b = L[j + 1]
			if(a.c_tag_order != b.c_tag_order)
				if(a.c_tag_order > b.c_tag_order)
					L.Swap(j, j + 1)
			else
				if(sorttext(a.c_tag, b.c_tag) < 0)
					L.Swap(j, j + 1)
	return L
