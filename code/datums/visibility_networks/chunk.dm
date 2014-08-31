#define UPDATE_BUFFER 25 // 2.5 seconds

// CAMERA CHUNK
//
// A 16x16 grid of the map with a list of turfs that can be seen, are visible and are dimmed.
// Allows the mob using this chunk to stream these chunks and know what it can and cannot see.

/datum/visibility_chunk
	var/obscured_image = 'icons/effects/cameravis.dmi'
	var/obscured_sub = "black"
	var/list/obscuredTurfs = list()
	var/list/visibleTurfs = list()
	var/list/obscured = list()
	var/list/viewpoints = list()
	var/list/turfs = list()
	var/list/seenby = list()
	var/visible = 0
	var/changed = 0
	var/updating = 0
	var/x = 0
	var/y = 0
	var/z = 0

/datum/visibility_chunk/proc/add(mob/new_mob)

	// if this thing doesn't use one of these visibility systems, kick it out
	if (!new_mob.visibility_interface)
		return

	// if the mob being added isn't a valid form of that mob, kick it out
	if (!new_mob.visibility_interface:canBeAddedToChunk(src))
		return

	// add this chunk to the list of visible chunks
	new_mob.visibility_interface:addChunk(src)

	visible++
	seenby += new_mob
	if(changed && !updating)
		update()

/datum/visibility_chunk/proc/remove(mob/new_mob)
	// if this thing doesn't use one of these visibility systems, kick it out
	if (!new_mob.visibility_interface)
		return

	// if the mob being added isn't a valid form of that mob, kick it out
	if (!new_mob.visibility_interface:canBeAddedToChunk(src))
		return

	// remove the chunk
	new_mob.visibility_interface:removeChunk(src)

	// remove the mob from out lists
	seenby -= new_mob
	if(visible > 0)
		visible--

/datum/visibility_chunk/proc/visibilityChanged(turf/loc)
	if(!visibleTurfs[loc])
		return
	hasChanged()

/datum/visibility_chunk/proc/hasChanged(var/update_now = 0)
	if(visible || update_now)
		if(!updating)
			updating = 1
			spawn(UPDATE_BUFFER) // Batch large changes, such as many doors opening or closing at once
				update()
				updating = 0
	else
		changed = 1

		
/*
This function needs to be overwritten to return True if the viewpoint object is valid, and false if it is not.
*/
/datum/visibility_chunk/proc/validViewpoint(var/viewpoint)
	return FALSE

/*
This function needs to be overwritten to return a list of visible turfs for that viewpoint
*/
/datum/visibility_chunk/proc/getVisibleTurfsForViewpoint(var/viewpoint)
	return list()

// returns a list of turfs which can be seen in by the chunks viewpoints
/datum/visibility_chunk/proc/getVisibleTurfs()
	var/list/newVisibleTurfs = list()
	for(var/viewpoint in viewpoints)
		if (validViewpoint(viewpoint))
			for (var/turf/t in getVisibleTurfsForViewpoint(viewpoint))
				newVisibleTurfs[t]=t
	return newVisibleTurfs

/*
This function needs to be overwritten to find nearby viewpoint objects to the chunk center.
*/
/datum/visibility_chunk/proc/findNearbyViewpoints()
	return FALSE

/*
This function can be overwritten to change or randomize the obscuring images
*/
/datum/visibility_chunk/proc/setObscuredImage(var/turf/target_turf)
	if(!target_turf.obscured)
		target_turf.obscured = image(obscured_image, target_turf, obscured_sub, 15)

/datum/visibility_chunk/proc/update()

	set background = 1

	// get a list of all the turfs that our viewpoints can see
	var/list/newVisibleTurfs = getVisibleTurfs()

	// Removes turf that isn't in turfs.
	newVisibleTurfs &= turfs

	var/list/visAdded = newVisibleTurfs - visibleTurfs
	var/list/visRemoved = visibleTurfs - newVisibleTurfs

	visibleTurfs = newVisibleTurfs
	obscuredTurfs = turfs - newVisibleTurfs

	// update the visibility overlays
	for(var/turf in visAdded)
		var/turf/t = turf
		if(t.obscured)
			obscured -= t.obscured
			for(var/mob/current_mob in seenby)
				if (current_mob.visibility_interface)
					current_mob.visibility_interface:removeObscuredTurf(t)

	for(var/turf in visRemoved)
		var/turf/t = turf
		if(obscuredTurfs[t])
			setObscuredImage(t)
			obscured += t.obscured
			for(var/mob/current_mob in seenby)
				if (current_mob.visibility_interface)
					current_mob.visibility_interface:addObscuredTurf(t)
				else
					seenby -= current_mob


// Create a new chunk, since the chunks are made as they are needed.
/datum/visibility_chunk/New(loc, x, y, z)

	// 0xf = 15
	x &= ~0xf
	y &= ~0xf

	src.x = x
	src.y = y
	src.z = z

	for(var/turf/t in range(10, locate(x + 8, y + 8, z)))
		if(t.x >= x && t.y >= y && t.x < x + 16 && t.y < y + 16)
			turfs[t] = t

	// locate all nearby viewpoints
	findNearbyViewpoints()

	// get the turfs that are visible to those viewpoints
	visibleTurfs = getVisibleTurfs()

	// Removes turf that isn't in turfs.
	visibleTurfs &= turfs

	// create the list of turfs we can't see
	obscuredTurfs = turfs - visibleTurfs

	// create the list of obscuring images to add to viewing clients
	for(var/turf in obscuredTurfs)
		var/turf/t = turf
		setObscuredImage(t)
		obscured += t.obscured

#undef UPDATE_BUFFER