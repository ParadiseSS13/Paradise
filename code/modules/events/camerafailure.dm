/datum/event/camera_failure/start()
	var/iterations = 1
	var/list/cameras = GLOB.cameranet.cameras.Copy()
	while(prob(100 / iterations))
		var/obj/machinery/camera/C = pick_n_take(cameras)
		if(!C)
			break
		if(!("SS13" in C.network) || C.start_active)
			continue
		if(C.status)
			C.toggle_cam(null, FALSE)
		iterations *= 2
