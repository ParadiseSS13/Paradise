/mob/living/silicon/ai/var/max_locations = 10
/mob/living/silicon/ai/var/stored_locations[0]

/mob/living/silicon/ai/proc/InvalidTurf(turf/T as turf)
	if(!T)
		return 1
	if((T.z in config.admin_levels))
		return 1
	if(T.z > 6)
		return 1
	return 0

/mob/living/silicon/ai/proc/get_camera_list()

	if(src.stat == 2)
		return

	cameranet.process_sort()

	var/list/T = list()
	T["Cancel"] = "Cancel"
	for (var/obj/machinery/camera/C in cameranet.cameras)
		var/list/tempnetwork = C.network&src.network
		if (tempnetwork.len)
			T[text("[][]", C.c_tag, (C.can_use() ? null : " (Deactivated)"))] = C

	track = new()
	track.cameras = T
	return T


/mob/living/silicon/ai/proc/ai_camera_list(var/camera in get_camera_list())
	set category = "AI Commands"
	set name = "Show Camera List"

	if(src.stat == 2)
		src << "You can't list the cameras because you are dead!"
		return

	if (!camera || camera == "Cancel")
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
		src << "\red Must supply a location name"
		return

	if(stored_locations.len >= max_locations)
		src << "\red Cannot store additional locations. Remove one first"
		return

	if(loc in stored_locations)
		src << "\red There is already a stored location by this name"
		return

	var/L = src.eyeobj.getLoc()
	if (InvalidTurf(get_turf(L)))
		src << "\red Unable to store this location"
		return

	stored_locations[loc] = L
	src << "Location '[loc]' stored"

/mob/living/silicon/ai/proc/sorted_stored_locations()
	return sortList(stored_locations)

/mob/living/silicon/ai/proc/ai_goto_location(loc in sorted_stored_locations())
	set category = "AI Commands"
	set name = "Goto Camera Location"
	set desc = "Returns to the selected camera location"

	if (!(loc in stored_locations))
		src << "\red Location [loc] not found"
		return

	var/L = stored_locations[loc]
	src.eyeobj.setLoc(L)

/mob/living/silicon/ai/proc/ai_remove_location(loc in sorted_stored_locations())
	set category = "AI Commands"
	set name = "Delete Camera Location"
	set desc = "Deletes the selected camera location"

	if (!(loc in stored_locations))
		src << "\red Location [loc] not found"
		return

	stored_locations.Remove(loc)
	src << "Location [loc] removed"

// Used to allow the AI is write in mob names/camera name from the CMD line.
/datum/trackable
	var/list/names = list()
	var/list/namecounts = list()
	var/list/humans = list()
	var/list/others = list()
	var/list/cameras = list()

/mob/living/silicon/ai/proc/trackable_mobs()

	if(usr.stat == 2)
		return list()

	var/datum/trackable/TB = new()
	for(var/mob/living/M in mob_list)
		// Easy checks first.
		// Don't detect mobs on Centcom. Since the wizard den is on Centcomm, we only need this.
		if(InvalidTurf(get_turf(M)))
			continue
		if(M == usr)
			continue
		if(M.invisibility)//cloaked
			continue
		if(M.digitalcamo)
			continue

		// Human check
		var/human = 0
		if(istype(M, /mob/living/carbon/human))
			human = 1
			var/mob/living/carbon/human/H = M
			//Cameras can't track people wearing an untrackable card
			var/obj/item/weapon/card/id/id = H.wear_id
			if(istype(id) && id.is_untrackable())
				continue
			if(istype(H.head, /obj/item/clothing/head))
				var/obj/item/clothing/head/hat = H.head
				if(hat.blockTracking)
					continue
		 // Now, are they trackable? (This is last because it's the most intensive check)
		if(!trackable(M))
			continue

		var/name = M.name
		if (name in TB.names)
			TB.namecounts[name]++
			name = text("[] ([])", name, TB.namecounts[name])
		else
			TB.names.Add(name)
			TB.namecounts[name] = 1
		if(human)
			TB.humans[name] = M
		else
			TB.others[name] = M

	var/list/targets = sortList(TB.humans) + sortList(TB.others)
	src.track = TB
	return targets

/mob/living/silicon/ai/proc/ai_camera_track(var/target_name in trackable_mobs())
	set category = "AI Commands"
	set name = "Track With Camera"
	set desc = "Select who you would like to track."

	if(src.stat == 2)
		src << "You can't track with camera because you are dead!"
		return
	if(!target_name)
		src.cameraFollow = null

	var/mob/target = (isnull(track.humans[target_name]) ? track.others[target_name] : track.humans[target_name])
	src.track = null
	ai_actual_track(target)

/mob/living/silicon/ai/proc/ai_cancel_tracking(var/forced = 0)
	if(!cameraFollow)
		return

	src << "Follow camera mode [forced ? "terminated" : "ended"]."
	cameraFollow = null

/mob/living/silicon/ai/proc/ai_actual_track(atom/movable/target as mob|obj)
	if(!istype(target))	return
	var/mob/living/silicon/ai/U = usr

	U.cameraFollow = target
	U << "Now tracking [target.name] on camera."

	spawn (0)
		while (U.cameraFollow == target)
			if (U.cameraFollow == null)
				return

			if (!trackable(target))
				U << "<span class='warning'>Target is not on or near any active cameras on the station.</span>"
				sleep(100)
				continue

			if(U.eyeobj)
				U.eyeobj.setLoc(get_turf(target), 0)
			else
				view_core()
				return
			sleep(10)

/proc/near_camera(var/mob/living/M)
	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(!(R.camera && R.camera.can_use()) && !cameranet.checkCameraVis(M))
			return 0
	else if(!isturf(M.loc) || !cameranet.checkCameraVis(M))
		return 0
	return 1

/proc/trackable(atom/movable/M)
	var/turf/T = get_turf(M)
	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/weapon/card/id/id = H.wear_id
		if(istype(id) && id.is_untrackable())
			return 0
		if(H.digitalcamo)
			return 0
		if(istype(H.head, /obj/item/clothing/head))
			var/obj/item/clothing/head/hat = H.head
			if (hat.blockTracking)
				return 0
	if(istype(M.loc,/obj/effect/dummy))
		return 0
		
	if((T && (T.z in config.contact_levels)) && ((hassensorlevel(M, SUIT_SENSOR_TRACKING) || M in aibots)))
		return 1

	return near_camera(M)

/obj/machinery/camera/attack_ai(var/mob/living/silicon/ai/user as mob)
	if (!istype(user))
		return
	if (!src.can_use())
		return
	user.eyeobj.setLoc(get_turf(src))


/mob/living/silicon/ai/attack_ai(var/mob/user as mob)
	ai_camera_list()
