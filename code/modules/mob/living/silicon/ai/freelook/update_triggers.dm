// CAMERA

// An addition to deactivate which removes/adds the camera from the chunk list based on if it works or not.

/obj/machinery/camera/deactivate(user as mob, var/choice = 1)
	..(user, choice)
	if(src.can_use())
		cameranet.addViewpoint(src)
	else
		src.SetLuminosity(0)
		cameranet.removeViewpoint(src)

/obj/machinery/camera/New()
	..()
	cameranet.viewpoints += src //Camera must be added to global list of all cameras no matter what...
	var/list/open_networks = difflist(network,RESTRICTED_CAMERA_NETWORKS) //...but if all of camera's networks are restricted, it only works for specific camera consoles.
	if(open_networks.len) //If there is at least one open network, chunk is available for AI usage.
		cameranet.addViewpoint(src)

/obj/machinery/camera/Del()
	cameranet.viewpoints -= src
	var/list/open_networks = difflist(network,RESTRICTED_CAMERA_NETWORKS)
	if(open_networks.len)
		cameranet.removeViewpoint(src)
	..()

#undef BORG_CAMERA_BUFFER