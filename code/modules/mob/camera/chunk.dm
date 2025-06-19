/// A 16x16 grid of the map with a list of turfs that can be seen, are visible and are dimmed.
/// Allows camera eyes to stream these chunks and know what they can and cannot see.
/datum/camerachunk
	var/list/obscured_turfs = list()
	var/list/visible_turfs = list()
	var/list/obscured = list()
	var/list/active_cameras = list()
	var/list/inactive_cameras = list()
	var/list/turfs = list()
	var/list/seenby = list()
	var/changed = FALSE
	var/updating = FALSE
	var/x = 0
	var/y = 0
	var/z = 0

/// Adds a camera to the chunk if it has not already been added.
/datum/camerachunk/proc/add_camera(obj/machinery/camera/cam)
	if(active_cameras[cam] || inactive_cameras[cam])
		return
	if(cam.non_chunking_camera)
		return
	// Register all even though it is active/inactive. Won't get called incorrectly
	RegisterSignal(cam, COMSIG_CAMERA_OFF, PROC_REF(deactivate_camera), TRUE)
	RegisterSignal(cam, COMSIG_CAMERA_ON, PROC_REF(activate_camera), TRUE)
	RegisterSignal(cam, COMSIG_PARENT_QDELETING, PROC_REF(remove_camera), TRUE)
	RegisterSignal(cam, COMSIG_CAMERA_MOVED, PROC_REF(camera_moved), TRUE)
	if(cam.can_use())
		active_cameras[cam] = cam
	else
		inactive_cameras[cam] = cam

/// Handles each movement by a camera that has been added to the chunk.
/datum/camerachunk/proc/camera_moved(obj/machinery/camera/cam, atom/old_loc)
	var/turf/T = get_turf(cam)

	// Falls outside of the chunk view distance
	if(T.x + CAMERA_VIEW_DISTANCE < x || T.x - CAMERA_VIEW_DISTANCE >= x + CAMERA_CHUNK_SIZE || T.y + CAMERA_VIEW_DISTANCE < y || T.y - CAMERA_VIEW_DISTANCE >= y + CAMERA_CHUNK_SIZE || T.z != z)
		remove_camera(cam)

/// Removes a camera from the chunk.
/datum/camerachunk/proc/remove_camera(obj/machinery/camera/cam)
	UnregisterSignal(cam, list(COMSIG_CAMERA_OFF, COMSIG_CAMERA_ON, COMSIG_PARENT_QDELETING, COMSIG_CAMERA_MOVED))
	active_cameras -= cam
	inactive_cameras -= cam
	SScamera.queue(src)

/datum/camerachunk/proc/activate_camera(obj/machinery/camera/cam)
	inactive_cameras -= cam
	active_cameras += cam
	SScamera.queue(src)

/datum/camerachunk/proc/deactivate_camera(obj/machinery/camera/cam)
	inactive_cameras += cam
	active_cameras -= cam
	SScamera.queue(src)

/// Add a camera eye to the chunk, then update if changed.
/datum/camerachunk/proc/add(mob/camera/eye/eye, add_images = TRUE)
	if(add_images)
		var/client/client = eye.get_viewer_client()
		if(client)
			client.images += obscured
	eye.visible_camera_chunks += src
	seenby += eye
	RegisterSignal(eye, COMSIG_PARENT_QDELETING, PROC_REF(eye_destroyed))
	if(changed)
		SScamera.queue(src)

/datum/camerachunk/proc/eye_destroyed(mob/camera/eye/eye)
	remove(eye, FALSE)

/// Remove a camera eye from the chunk, then update if changed.
/datum/camerachunk/proc/remove(mob/camera/eye/eye, remove_images = TRUE)
	if(remove_images)
		var/client/client = eye.get_viewer_client()
		if(client)
			client.images -= obscured
	eye.visible_camera_chunks -= src
	seenby -= eye
	UnregisterSignal(eye, COMSIG_PARENT_QDELETING)

/// Called when a chunk has changed. I.E: A wall was deleted.
/datum/camerachunk/proc/visibility_changed(turf/loc)
	if(!visible_turfs[loc])
		return
	has_changed()

/// Updates the chunk, makes sure that it doesn't update too much. If the chunk isn't being watched it will
/// instead be flagged to update the next time a camera eye moves near it.
/datum/camerachunk/proc/has_changed(update_now = 0)
	if(update_now)
		update()
		SScamera.remove_from_queue(src)

	if(length(seenby))
		SScamera.queue(src)
	else
		changed = TRUE

/// Gathers the visible turfs from cameras and puts them into the appropiate lists.
/datum/camerachunk/proc/update()
	var/list/new_visible_turfs = list()

	for(var/obj/machinery/camera/c as anything in active_cameras)
		var/turf/point = locate(src.x + (CAMERA_CHUNK_SIZE / 2), src.y + (CAMERA_CHUNK_SIZE / 2), src.z)
		var/turf/T = get_turf(c)
		if(get_dist(point, T) > CAMERA_VIEW_DISTANCE + (CAMERA_CHUNK_SIZE / 2))
			// Still needed for Ais who get created on Z level 1 on the spot of the new player
			continue

		for(var/turf/t in c.can_see())
			if(turfs[t])
				new_visible_turfs[t] = t

	var/list/vis_added = new_visible_turfs - visible_turfs
	var/list/vis_removed = visible_turfs - new_visible_turfs

	visible_turfs = new_visible_turfs
	obscured_turfs = turfs - new_visible_turfs
	var/list/images_to_remove = list()
	var/list/images_to_add = list()
	for(var/turf/t as anything in vis_added)
		if(t.obscured)
			obscured -= t.obscured
			images_to_remove += t.obscured

	for(var/turf/t as anything in vis_removed)
		if(!t.obscured)
			t.obscured = image('icons/effects/cameravis.dmi', t, null, BYOND_LIGHTING_LAYER + 0.1)
			t.obscured.appearance_flags = RESET_TRANSFORM
			t.obscured.plane = BYOND_LIGHTING_PLANE + 1
		obscured += t.obscured
		images_to_add += t.obscured

	for(var/mob/camera/eye/eye as anything in seenby)
		var/client/client = eye.get_viewer_client()
		if(client)
			client.images -= images_to_remove
			client.images += images_to_add
	changed = FALSE

/// Create a new camera chunk, since the chunks are made as they are needed.
/datum/camerachunk/New(loc, x, y, z)

	// 0xf = 15
	x &= ~(CAMERA_CHUNK_SIZE - 1)
	y &= ~(CAMERA_CHUNK_SIZE - 1)

	src.x = x
	src.y = y
	src.z = z

	var/half_chunk = CAMERA_CHUNK_SIZE / 2
	for(var/obj/machinery/camera/c in urange(half_chunk + CAMERA_VIEW_DISTANCE, locate(x + half_chunk, y + half_chunk, z)))
		add_camera(c)

	for(var/turf/t in block(max(x, 1), max(y, 1), max(z, 1), min(x + CAMERA_CHUNK_SIZE - 1, world.maxx), min(y + CAMERA_CHUNK_SIZE - 1, world.maxy), z))
		turfs[t] = t

	for(var/obj/machinery/camera/c as anything in active_cameras)
		for(var/turf/t in c.can_see())
			if(turfs[t])
				visible_turfs[t] = t

	obscured_turfs = turfs - visible_turfs

	for(var/turf/t as anything in obscured_turfs)
		if(!t.obscured)
			t.obscured = image('icons/effects/cameravis.dmi', t, "black", BYOND_LIGHTING_LAYER + 0.1)
			t.obscured.appearance_flags = RESET_TRANSFORM
			t.obscured.plane = BYOND_LIGHTING_PLANE + 1
		obscured += t.obscured
