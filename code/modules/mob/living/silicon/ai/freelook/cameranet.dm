/datum/visibility_network/cameras
	ChunkType = /datum/visibility_chunk/camera

/datum/visibility_network/cameras/getViewpointFromMob(var/mob/currentMob)
	var/mob/living/silicon/robot/currentRobot=currentMob
	if(currentRobot)
		return currentRobot.camera
	return FALSE

/datum/visibility_network/cameras/validViewpoint(var/viewpoint)
	var/obj/machinery/camera/c = viewpoint
	if (!c)
		return FALSE
	return c.can_use()


// adding some indirection so that I don't have to edit a ton of files
/datum/visibility_network/cameras/proc/addCamera(var/camera)
	return addViewpoint(camera)

/datum/visibility_network/cameras/proc/removeCamera(var/camera)
	return removeViewpoint(camera)

/datum/visibility_network/cameras/proc/checkCameraVis(var/atom/target)
	return checkCanSee(target)
