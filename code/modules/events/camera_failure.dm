/datum/event/camera_failure
	name = "Camera Failure"
	role_weights = list(ASSIGNMENT_ENGINEERING = 10)

/datum/event/camera_failure/start()
	var/failed_cameras
	var/failure_limit = rand(1, 3)
	for(var/obj/machinery/camera/C in shuffle(GLOB.cameranet.cameras))
		if(!("SS13" in C.network) || C.start_active) // We dont want protected cameras to be affected
			continue
		if(!C.status)
			continue
		C.toggle_cam(null, FALSE)
		failed_cameras++
		if(failed_cameras >= failure_limit)
			return
