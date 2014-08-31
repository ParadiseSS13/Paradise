/datum/visibility_interface
	var/chunk_type = null
	var/mob/controller = null
	var/list/visible_chunks = list()


/datum/visibility_interface/New(var/mob/controller)
	src.controller = controller


/datum/visibility_interface/proc/validMob()
	return getClient()

/datum/visibility_interface/proc/getClient()
	return controller.client

/datum/visibility_interface/proc/canBeAddedToChunk(var/datum/visibility_chunk/test_chunk)
	return istype(test_chunk,chunk_type)


/datum/visibility_interface/proc/addChunk(var/datum/visibility_chunk/test_chunk)
	visible_chunks+=test_chunk
	var/client/currentClient = getClient()
	if(currentClient)
		currentClient.images += test_chunk.obscured


/datum/visibility_interface/proc/removeChunk(var/datum/visibility_chunk/test_chunk)
	visible_chunks-=test_chunk
	var/client/currentClient = getClient()
	if(currentClient)
		currentClient.images -= test_chunk.obscured


/datum/visibility_interface/proc/removeObscuredTurf(var/turf/target_turf)
	if(validMob())
		var/client/currentClient = getClient()
		if(currentClient)
			currentClient.images -= target_turf.obscured


/datum/visibility_interface/proc/addObscuredTurf(var/turf/target_turf)
	if(validMob())
		var/client/currentClient = getClient()
		if(currentClient)
			currentClient.images -= target_turf.obscured