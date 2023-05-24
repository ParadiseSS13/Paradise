// CAMERA NET
//
// The datum containing all the chunks.
GLOBAL_DATUM_INIT(cameranet, /datum/cameranet, new())

/datum/cameranet
	var/name = "Camera Net" // Name to show for VV and stat()

	// The cameras on the map, no matter if they work or not. Updated in obj/machinery/camera.dm by New() and Destroy().
	var/list/cameras = list()
	// The chunks of the map, mapping the areas that the cameras can see.
	var/list/chunks = list()
	var/ready = FALSE

	// The object used for the clickable stat() button.
	var/obj/effect/statclick/statclick

// Checks if a chunk has been Generated in x, y, z.
/datum/cameranet/proc/chunkGenerated(x, y, z)
	x &= ~(CAMERA_CHUNK_SIZE - 1)
	y &= ~(CAMERA_CHUNK_SIZE - 1)
	var/key = "[x],[y],[z]"
	return (chunks[key])

// Returns the chunk in the x, y, z.
// If there is no chunk, it creates a new chunk and returns that.
/datum/cameranet/proc/getCameraChunk(x, y, z)
	x &= ~(CAMERA_CHUNK_SIZE - 1)
	y &= ~(CAMERA_CHUNK_SIZE - 1)
	var/key = "[x],[y],[z]"
	if(!chunks[key])
		chunks[key] = new /datum/camerachunk(null, x, y, z)

	return chunks[key]

// Updates what the aiEye can see. It is recommended you use this when the aiEye moves or it's location is set.

/datum/cameranet/proc/visibility(list/moved_eyes, client/C, list/other_eyes)
	if(!islist(moved_eyes))
		moved_eyes = moved_eyes ? list(moved_eyes) : list()
	if(islist(other_eyes))
		other_eyes = (other_eyes - moved_eyes)
	else
		other_eyes = list()

	var/list/chunks_pre_seen = list()
	var/list/chunks_post_seen = list()

	for(var/V in moved_eyes)
		var/mob/camera/aiEye/eye = V
		if(C)
			chunks_pre_seen |= eye.visibleCameraChunks
		// 0xf = 15
		var/static_range = eye.static_visibility_range
		var/x1 = max(0, eye.x - static_range) & ~(CAMERA_CHUNK_SIZE - 1)
		var/y1 = max(0, eye.y - static_range) & ~(CAMERA_CHUNK_SIZE - 1)
		var/x2 = min(world.maxx, eye.x + static_range) & ~(CAMERA_CHUNK_SIZE - 1)
		var/y2 = min(world.maxy, eye.y + static_range) & ~(CAMERA_CHUNK_SIZE - 1)

		var/list/visibleChunks = list()

		for(var/x = x1; x <= x2; x += CAMERA_CHUNK_SIZE)
			for(var/y = y1; y <= y2; y += CAMERA_CHUNK_SIZE)
				visibleChunks |= getCameraChunk(x, y, eye.z)

		var/list/remove = eye.visibleCameraChunks - visibleChunks
		var/list/add = visibleChunks - eye.visibleCameraChunks

		for(var/chunk in remove)
			var/datum/camerachunk/c = chunk
			c.remove(eye, FALSE)

		for(var/chunk in add)
			var/datum/camerachunk/c = chunk
			c.add(eye, FALSE)

		if(C)
			chunks_post_seen |= eye.visibleCameraChunks

	if(C)
		for(var/V in other_eyes)
			var/mob/camera/aiEye/eye = V
			chunks_post_seen |= eye.visibleCameraChunks

		var/list/remove = chunks_pre_seen - chunks_post_seen
		var/list/add = chunks_post_seen - chunks_pre_seen

		for(var/chunk in remove)
			var/datum/camerachunk/c = chunk
			C.images -= c.obscured

		for(var/chunk in add)
			var/datum/camerachunk/c = chunk
			C.images += c.obscured


// Updates the chunks that the turf is located in. Use this when obstacles are destroyed or	when doors open.

/datum/cameranet/proc/updateVisibility(atom/A, opacity_check = 1)

	if(!SSticker || (opacity_check && !A.opacity))
		return
	majorChunkChange(A, 2)

/datum/cameranet/proc/updateChunk(x, y, z)
	// 0xf = 15
	if(!chunkGenerated(x, y, z))
		return
	var/datum/camerachunk/chunk = getCameraChunk(x, y, z)
	chunk.hasChanged()

// Removes a camera from a chunk.

/datum/cameranet/proc/removeCamera(obj/machinery/camera/c)
	majorChunkChange(c, 0)

// Add a camera to a chunk.

/datum/cameranet/proc/addCamera(obj/machinery/camera/c)
	majorChunkChange(c, 1)

// Used for Cyborg cameras. Since portable cameras can be in ANY chunk.

/datum/cameranet/proc/updatePortableCamera(obj/machinery/camera/c, turf/old_loc)
	majorChunkChange(c, 1, old_loc)

// Never access this proc directly!!!!
// This will update the chunk and all the surrounding chunks.
// It will also add the atom to the cameras list if you set the choice to 1.
// Setting the choice to 0 will remove the camera from the chunks.
// If you want to update the chunks around an object, without adding/removing a camera, use choice 2.

/datum/cameranet/proc/majorChunkChange(atom/c, choice, turf/old_loc = null)
	// 0xf = 15
	if(!c)
		return

	var/turf/T = get_turf(c)
	if(!T)
		return

	if(old_loc)
		// Check if the current turf falls in the same chunka as the old_loc. If so, don't do anything
		if(T.x & ~(CAMERA_CHUNK_SIZE - 1) == old_loc.x & ~(CAMERA_CHUNK_SIZE - 1) && T.y & ~(CAMERA_CHUNK_SIZE - 1) == old_loc.y & ~(CAMERA_CHUNK_SIZE - 1))
			return

	// Use camera view distance here to actually know how far a camera can max watch
	var/x1 = max(0, T.x - CAMERA_VIEW_DISTANCE) & ~(CAMERA_CHUNK_SIZE - 1)
	var/y1 = max(0, T.y - CAMERA_VIEW_DISTANCE) & ~(CAMERA_CHUNK_SIZE - 1)
	var/x2 = min(world.maxx, T.x + CAMERA_VIEW_DISTANCE) & ~(CAMERA_CHUNK_SIZE - 1)
	var/y2 = min(world.maxy, T.y + CAMERA_VIEW_DISTANCE) & ~(CAMERA_CHUNK_SIZE - 1)

	for(var/x = x1; x <= x2; x += CAMERA_CHUNK_SIZE)
		for(var/y = y1; y <= y2; y += CAMERA_CHUNK_SIZE)
			if(chunkGenerated(x, y, T.z))
				var/datum/camerachunk/chunk = getCameraChunk(x, y, T.z)
				if(choice == 0)
					// Remove the camera.
					chunk.remove_camera(c)
				else if(choice == 1)
					// You can't have the same camera in the list twice.
					chunk.add_camera(c)
				chunk.hasChanged()

// Will check if a mob is on a viewable turf. Returns 1 if it is, otherwise returns 0.

/datum/cameranet/proc/checkCameraVis(mob/living/target as mob)

	// 0xf = 15
	var/turf/position = get_turf(target)
	return checkTurfVis(position)

/datum/cameranet/proc/checkTurfVis(turf/position)
	var/datum/camerachunk/chunk = getCameraChunk(position.x, position.y, position.z)
	if(chunk)
		if(chunk.changed)
			chunk.hasChanged(1) // Update now, no matter if it's visible or not.
		if(chunk.visibleTurfs[position])
			return 1
	return 0

/*
/datum/cameranet/proc/stat_entry()
	if(!statclick)
		statclick = new/obj/effect/statclick/debug(null, "Initializing...", src)

	stat(name, statclick.update("Cameras: [cameranet.cameras.len] | Chunks: [cameranet.chunks.len]"))
*/

// Debug verb for VVing the chunk that the turf is in.
/*
/turf/verb/view_chunk()
	set src in world

	if(cameranet.chunkGenerated(x, y, z))
		var/datum/camerachunk/chunk = cameranet.getCameraChunk(x, y, z)
		usr.client.debug_variables(chunk)
*/
