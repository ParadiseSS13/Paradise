// CAMERA NET
//
// The datum containing all the chunks.
GLOBAL_DATUM_INIT(cameranet, /datum/cameranet, new())

/datum/cameranet
	var/name = "Camera Net"

	/// The cameras on the map, no matter if they work or not. Updated in obj/machinery/camera.dm by New() and Destroy().
	var/list/cameras = list()
	/// The chunks of the map, mapping the areas that the cameras can see.
	var/list/chunks = list()
	var/ready = FALSE

/// Returns the chunk at (x, y, z) if it exists, otherwise returns null.
/datum/cameranet/proc/chunk_generated(x, y, z)
	x &= ~(CAMERA_CHUNK_SIZE - 1)
	y &= ~(CAMERA_CHUNK_SIZE - 1)
	var/key = "[x],[y],[z]"
	return (chunks[key])

/// Returns the chunk at (x, y, z) if it exists, otherwise returns a new chunk at that location.
/datum/cameranet/proc/get_camera_chunk(x, y, z)
	x &= ~(CAMERA_CHUNK_SIZE - 1)
	y &= ~(CAMERA_CHUNK_SIZE - 1)
	var/key = "[x],[y],[z]"
	if(!chunks[key])
		chunks[key] = new /datum/camerachunk(null, x, y, z)

	return chunks[key]

/// Updates what the camera network can see.
/datum/cameranet/proc/visibility(list/moved_eyes, client/C)
	if(!islist(moved_eyes))
		moved_eyes = moved_eyes ? list(moved_eyes) : list()

	var/list/chunks_pre_seen = list()
	var/list/chunks_post_seen = list()

	for(var/V in moved_eyes)
		var/mob/camera/eye/eye = V
		if(C)
			chunks_pre_seen |= eye.visible_camera_chunks
		// 0xf = 15
		var/static_range = eye.static_visibility_range
		var/x1 = max(0, eye.x - static_range) & ~(CAMERA_CHUNK_SIZE - 1)
		var/y1 = max(0, eye.y - static_range) & ~(CAMERA_CHUNK_SIZE - 1)
		var/x2 = min(world.maxx, eye.x + static_range) & ~(CAMERA_CHUNK_SIZE - 1)
		var/y2 = min(world.maxy, eye.y + static_range) & ~(CAMERA_CHUNK_SIZE - 1)

		var/list/visible_chunks = list()

		for(var/x = x1; x <= x2; x += CAMERA_CHUNK_SIZE)
			for(var/y = y1; y <= y2; y += CAMERA_CHUNK_SIZE)
				visible_chunks |= get_camera_chunk(x, y, eye.z)

		var/list/remove = eye.visible_camera_chunks - visible_chunks
		var/list/add = visible_chunks - eye.visible_camera_chunks

		for(var/chunk in remove)
			var/datum/camerachunk/c = chunk
			c.remove(eye, FALSE)

		for(var/chunk in add)
			var/datum/camerachunk/c = chunk
			c.add(eye, FALSE)

		if(C)
			chunks_post_seen |= eye.visible_camera_chunks

	if(C)
		var/list/remove = chunks_pre_seen - chunks_post_seen
		var/list/add = chunks_post_seen - chunks_pre_seen

		for(var/chunk in remove)
			var/datum/camerachunk/c = chunk
			C.images -= c.obscured

		for(var/chunk in add)
			var/datum/camerachunk/c = chunk
			C.images += c.obscured


/// Updates the chunks that the turf is located in. Use this when obstacles are destroyed or	when doors open.
/datum/cameranet/proc/update_visibility(atom/A, opacity_check = 1)
	if(SSticker.current_state < GAME_STATE_PREGAME || (opacity_check && !A.opacity))
		return
	major_chunk_change(update = A)

/// Removes a camera from a chunk.
/datum/cameranet/proc/remove_camera(obj/machinery/camera/c)
	major_chunk_change(remove = c)

/// Add a camera to a chunk.
/datum/cameranet/proc/add_camera(obj/machinery/camera/c)
	major_chunk_change(add = c)

/// Refreshes the chunk location of a portable camera. Used by Cyborgs.
/datum/cameranet/proc/update_portable_camera(obj/machinery/camera/c, turf/old_loc)
	major_chunk_change(add = c, old_loc = old_loc)

/// Private method for updating the chunk an atom is in, and all surrounding chunks.
/// `add` will be added as a camera to the chunk of its current location and all surrounding chunks.
/// `remove` will be removed as a camera from the chunk of its current location and all surrounding chunks.
/// `update` will not be added or removed as a camera, but its surrounding chunks will be updated.
/// These parameters are mutually exclusive.
/datum/cameranet/proc/major_chunk_change(atom/add = null, atom/remove = null, atom/update = null, turf/old_loc = null)
	// 0xf = 15
	if(!add && !remove && !update)
		return
	if(add && remove)
		CRASH("Adding and removing a camera to the cameranet simultaneously is not implemented")

	var/atom/c = remove
	if(!c)
		c = add
	if(!c)
		c = update

	var/turf/T = get_turf(c)
	if(!T)
		return

	// Check if the turf to add falls in the same chunk as the old_loc. If so, do nothing
	if(old_loc)
		if(T.x & ~(CAMERA_CHUNK_SIZE - 1) == old_loc.x & ~(CAMERA_CHUNK_SIZE - 1) && T.y & ~(CAMERA_CHUNK_SIZE - 1) == old_loc.y & ~(CAMERA_CHUNK_SIZE - 1))
			return

	// Use camera view distance here to actually know how far a camera can max watch
	var/x1 = max(0, T.x - CAMERA_VIEW_DISTANCE) & ~(CAMERA_CHUNK_SIZE - 1)
	var/y1 = max(0, T.y - CAMERA_VIEW_DISTANCE) & ~(CAMERA_CHUNK_SIZE - 1)
	var/x2 = min(world.maxx, T.x + CAMERA_VIEW_DISTANCE) & ~(CAMERA_CHUNK_SIZE - 1)
	var/y2 = min(world.maxy, T.y + CAMERA_VIEW_DISTANCE) & ~(CAMERA_CHUNK_SIZE - 1)

	for(var/x = x1; x <= x2; x += CAMERA_CHUNK_SIZE)
		for(var/y = y1; y <= y2; y += CAMERA_CHUNK_SIZE)
			if(chunk_generated(x, y, T.z))
				var/datum/camerachunk/chunk = get_camera_chunk(x, y, T.z)
				if(remove)
					// Remove the camera.
					chunk.remove_camera(c)
				else if(add)
					// You can't have the same camera in the list twice.
					chunk.add_camera(c)
				chunk.has_changed()

/// Returns 1 if a mob is on a viewable turf, otherwise returns 0.
/datum/cameranet/proc/check_camera_vis(mob/living/target as mob)
	// 0xf = 15
	var/turf/position = get_turf(target)
	return check_turf_vis(position)

/datum/cameranet/proc/check_turf_vis(turf/position)
	var/datum/camerachunk/chunk = get_camera_chunk(position.x, position.y, position.z)
	if(chunk)
		if(chunk.changed)
			chunk.has_changed(1) // Update now, no matter if it's visible or not.
		if(chunk.visible_turfs[position])
			return 1
	return 0
