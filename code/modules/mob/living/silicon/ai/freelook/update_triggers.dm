#define BORG_CAMERA_BUFFER 30

//UPDATE TRIGGERS, when the chunk (and the surrounding chunks) should update.

// TURFS

/turf
	var/image/obscured

/turf/proc/visibilityChanged()
	if(ticker)
		cameranet.updateVisibility(src)

/turf/simulated/Del()
	visibilityChanged()
	..()

/turf/simulated/New()
	..()
	visibilityChanged()



// STRUCTURES

/obj/structure/Del()
	if(ticker)
		cameranet.updateVisibility(src)
	..()

/obj/structure/New()
	..()
	if(ticker)
		cameranet.updateVisibility(src)

// EFFECTS

/obj/effect/Del()
	if(ticker)
		cameranet.updateVisibility(src)
	..()

/obj/effect/New()
	..()
	if(ticker)
		cameranet.updateVisibility(src)


// DOORS

// Simply updates the visibility of the area when it opens/closes/destroyed.
/obj/machinery/door/proc/update_freelok_sight()
	// Glass door glass = 1
	// don't check then?
	if(!glass && cameranet)
		cameranet.updateVisibility(src, 0)


// ROBOT MOVEMENT

// Update the portable camera everytime the Robot moves.
// This might be laggy, comment it out if there are problems.
/mob/living/silicon/robot/var/updating = 0

/mob/living/silicon/robot/Move()
	var/oldLoc = src.loc
	. = ..()
	if(.)
		if(src.camera && src.camera.network.len)
			if(!updating)
				updating = 1
				spawn(BORG_CAMERA_BUFFER)
					if(oldLoc != src.loc)
						cameranet.updatePortableCamera(src.camera)
					updating = 0

// CAMERA

// An addition to deactivate which removes/adds the camera from the chunk list based on if it works or not.

/obj/machinery/camera/deactivate(user as mob, var/choice = 1)
	..(user, choice)
	if(src.can_use())
		cameranet.addCamera(src)
	else
		src.SetLuminosity(0)
		cameranet.removeCamera(src)

/obj/machinery/camera/New()
	..()
	//Camera must be added to global list of all cameras no matter what...
	if(cameranet.cameras_unsorted || !ticker)
		cameranet.cameras += src
		cameranet.cameras_unsorted = 1
	else
		dd_insertObjectList(cameranet.cameras, src)

	var/list/open_networks = difflist(network,restricted_camera_networks) //...but if all of camera's networks are restricted, it only works for specific camera consoles.
	if(open_networks.len) //If there is at least one open network, chunk is available for AI usage.
		cameranet.addCamera(src)

/obj/machinery/camera/Del()
	cameranet.cameras -= src
	var/list/open_networks = difflist(network,restricted_camera_networks)
	if(open_networks.len)
		cameranet.removeCamera(src)
	..()

#undef BORG_CAMERA_BUFFER