// CAMERA CHUNK
//
// A 16x16 grid of the map with a list of turfs that can be seen, are visible and are dimmed.
// Allows the AI Eye to stream these chunks and know what it can and cannot see.

/datum/camerachunk
	var/list/obscuredTurfs = list()
	var/list/visibleTurfs = list()
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

/datum/camerachunk/proc/camera_moved(obj/machinery/camera/cam, atom/old_loc)
	var/turf/T = get_turf(cam)

	// Falls outside of the chunk view distance
	if(T.x + CAMERA_VIEW_DISTANCE < x || T.x - CAMERA_VIEW_DISTANCE >= x + CAMERA_CHUNK_SIZE || T.y + CAMERA_VIEW_DISTANCE < y || T.y - CAMERA_VIEW_DISTANCE >= y + CAMERA_CHUNK_SIZE || T.z != z)
		remove_camera(cam)

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

// Add an AI eye to the chunk, then update if changed.
/datum/camerachunk/proc/add(mob/camera/aiEye/eye, add_images = TRUE)
	if(add_images)
		var/client/client = eye.GetViewerClient()
		if(client)
			client.images += obscured
	eye.visibleCameraChunks += src
	seenby += eye
	RegisterSignal(eye, COMSIG_PARENT_QDELETING, PROC_REF(aiEye_destroyed))
	if(changed)
		SScamera.queue(src)

/datum/camerachunk/proc/aiEye_destroyed(mob/camera/aiEye/eye)
	remove(eye, FALSE)

// Remove an AI eye from the chunk, then update if changed.
/datum/camerachunk/proc/remove(mob/camera/aiEye/eye, remove_images = TRUE)
	if(remove_images)
		var/client/client = eye.GetViewerClient()
		if(client)
			client.images -= obscured
	eye.visibleCameraChunks -= src
	seenby -= eye
	UnregisterSignal(eye, COMSIG_PARENT_QDELETING)

// Called when a chunk has changed. I.E: A wall was deleted.

/datum/camerachunk/proc/visibilityChanged(turf/loc)
	if(!visibleTurfs[loc])
		return
	hasChanged()

// Updates the chunk, makes sure that it doesn't update too much. If the chunk isn't being watched it will
// instead be flagged to update the next time an AI Eye moves near it.

/datum/camerachunk/proc/hasChanged(update_now = 0)
	if(update_now)
		update()
		SScamera.remove_from_queue(src)

	if(length(seenby))
		SScamera.queue(src)
	else
		changed = TRUE

// The actual updating. It gathers the visible turfs from cameras and puts them into the appropiate lists.

/datum/camerachunk/proc/update()
	var/list/newVisibleTurfs = list()

	for(var/obj/machinery/camera/c as anything in active_cameras)
		var/turf/point = locate(src.x + (CAMERA_CHUNK_SIZE / 2), src.y + (CAMERA_CHUNK_SIZE / 2), src.z)
		var/turf/T = get_turf(c)
		if(get_dist(point, T) > CAMERA_VIEW_DISTANCE + (CAMERA_CHUNK_SIZE / 2))
			continue // Still needed for Ais who get created on Z level 1 on the spot of the new player

		for(var/turf/t in c.can_see())
			if(turfs[t])
				newVisibleTurfs[t] = t

	var/list/visAdded = newVisibleTurfs - visibleTurfs
	var/list/visRemoved = visibleTurfs - newVisibleTurfs

	visibleTurfs = newVisibleTurfs
	obscuredTurfs = turfs - newVisibleTurfs
	var/list/images_to_remove = list()
	var/list/images_to_add = list()
	for(var/turf/t as anything in visAdded)
		if(t.obscured)
			obscured -= t.obscured
			images_to_remove += t.obscured

	for(var/turf/t as anything in visRemoved)
		if(!t.obscured)
			t.obscured = image('icons/effects/cameravis.dmi', t, null, BYOND_LIGHTING_LAYER + 0.1)
			t.obscured.plane = BYOND_LIGHTING_PLANE + 1
		obscured += t.obscured
		images_to_add += t.obscured

	for(var/mob/camera/aiEye/eye as anything in seenby)
		var/client/client = eye.GetViewerClient()
		if(client)
			client.images -= images_to_remove
			client.images += images_to_add
	changed = FALSE

// Create a new camera chunk, since the chunks are made as they are needed.
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
				visibleTurfs[t] = t

	obscuredTurfs = turfs - visibleTurfs

	for(var/turf/t as anything in obscuredTurfs)
		if(!t.obscured)
			t.obscured = image('icons/effects/cameravis.dmi', t, "black", BYOND_LIGHTING_LAYER + 0.1)
			t.obscured.plane = BYOND_LIGHTING_PLANE + 1
		obscured += t.obscured
