/datum/event/camera_failure/start()
	var/failed_cameras
	var/failure_limit = rand(1, 3)
	var/list/cameras = GLOB.cameranet.cameras.Copy()
	for(var/obj/machinery/camera/C in cameras)
		if(failed_cameras >= failure_limit)
			return
		C = pick_n_take(cameras)
		if(!istype(C))
			break
		if(!("SS13" in C.network) || C.start_active) // We dont want protected cameras to be affected
			continue
		if(C.status)
			C.toggle_cam(null, FALSE)
			failed_cameras ++
