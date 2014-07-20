/datum/visibility_network
	var/list/viewpoints = list()

	// the type of chunk used by this network
	var/datum/visibility_chunk/ChunkType = /datum/visibility_chunk

	// The chunks of the map, mapping the areas that the viewpoints can see.
	var/list/chunks = list()

	var/ready = 0


// Creates a chunk key string from x,y,z coordinates
/datum/visibility_network/proc/createChunkKey(x,y,z)
	x &= ~0xf
	y &= ~0xf
	return "[x],[y],[z]"


// Checks if a chunk has been Generated in x, y, z.
/datum/visibility_network/proc/chunkGenerated(x, y, z)
	return (chunks[createChunkKey(x, y, z)])


// Returns the chunk in the x, y, z.
// If there is no chunk, it creates a new chunk and returns that.
/datum/visibility_network/proc/getChunk(x, y, z)
	var/key = createChunkKey(x, y, z)
	if(!chunks[key])
		chunks[key] = new ChunkType(null, x, y, z)
	return chunks[key]


/datum/visibility_network/proc/visibility(var/mob/targetMob)

	// if we've got not visibility interface on the mob, we canot do this
	if (!targetMob.visibility_interface)
		return

	// 0xf = 15
	var/x1 = max(0, targetMob.x - 16) & ~0xf
	var/y1 = max(0, targetMob.y - 16) & ~0xf
	var/x2 = min(world.maxx, targetMob.x + 16) & ~0xf
	var/y2 = min(world.maxy, targetMob.y + 16) & ~0xf

	var/list/visibleChunks = list()

	for(var/x = x1; x <= x2; x += 16)
		for(var/y = y1; y <= y2; y += 16)
			visibleChunks += getChunk(x, y, targetMob.z)

	var/list/remove = targetMob.visibility_interface:visible_chunks - visibleChunks
	var/list/add = visibleChunks - targetMob.visibility_interface:visible_chunks

	for(var/datum/visibility_chunk/chunk in remove)
		chunk.remove(targetMob)

	for(var/datum/visibility_chunk/chunk in add)
		chunk.add(targetMob)


// Updates the chunks that the turf is located in. Use this when obstacles are destroyed or	when doors open.
/datum/visibility_network/proc/updateVisibility(atom/A, var/opacity_check = 1)
	if(!ticker || (opacity_check && !A.opacity))
		return
	majorChunkChange(A, 2)


/datum/visibility_network/proc/updateChunk(x, y, z)
	if(!chunkGenerated(x, y, z))
		return
	var/datum/visibility_chunk/chunk = getChunk(x, y, z)
	chunk.hasChanged()


/datum/visibility_network/proc/validViewpoint(var/viewpoint)
	return FALSE


/datum/visibility_network/proc/addViewpoint(var/viewpoint)
	if(validViewpoint(viewpoint))
		majorChunkChange(viewpoint, 1)


/datum/visibility_network/proc/removeViewpoint(var/viewpoint)
	if(validViewpoint(viewpoint))
		majorChunkChange(viewpoint, 0)

/datum/visibility_network/proc/getViewpointFromMob(var/mob/currentMob)
	return FALSE

/datum/visibility_network/proc/updateMob(var/mob/currentMob)
	var/viewpoint = getViewpointFromMob(currentMob)
	if(viewpoint)
		updateViewpoint(viewpoint)


/datum/visibility_network/proc/updateViewpoint(var/viewpoint)
	if(validViewpoint(viewpoint))
		majorChunkChange(viewpoint, 1)


// Never access this proc directly!!!!
// This will update the chunk and all the surrounding chunks.
// It will also add the atom to the cameras list if you set the choice to 1.
// Setting the choice to 0 will remove the viewpoint from the chunks.
// If you want to update the chunks around an object, without adding/removing a viewpoint, use choice 2.
/datum/visibility_network/proc/majorChunkChange(atom/c, var/choice)
	// 0xf = 15
	if(!c)
		return

	var/turf/T = get_turf(c)
	if(T)
		var/x1 = max(0, T.x - 8) & ~0xf
		var/y1 = max(0, T.y - 8) & ~0xf
		var/x2 = min(world.maxx, T.x + 8) & ~0xf
		var/y2 = min(world.maxy, T.y + 8) & ~0xf

		for(var/x = x1; x <= x2; x += 16)
			for(var/y = y1; y <= y2; y += 16)
				if(chunkGenerated(x, y, T.z))
					var/datum/visibility_chunk/chunk = getChunk(x, y, T.z)
					if(choice == 0)
						// Remove the viewpoint.
						chunk.viewpoints -= c
					else if(choice == 1)
						// You can't have the same viewpoint in the list twice.
						chunk.viewpoints |= c
					chunk.hasChanged()

// checks if the network can see a particular atom
/datum/visibility_network/proc/checkCanSee(var/atom/target)
	var/turf/position = get_turf(target)
	return checkTurfVis(position)

/datum/visibility_network/proc/checkTurfVis(var/turf/position)
	var/datum/visibility_chunk/chunk = getChunk(position.x, position.y, position.z)
	if(chunk)
		if(chunk.changed)
			chunk.hasChanged(1) // Update now, no matter if it's visible or not.
		if(chunk.visibleTurfs[position])
			return 1
	return 0