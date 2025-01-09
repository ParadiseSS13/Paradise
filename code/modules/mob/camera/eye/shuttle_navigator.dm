/mob/camera/eye/shuttle_docker
	name = "Shuttle Docker Camera Eye"
	ai_detector_visible = FALSE
	simulated = FALSE
	var/list/placement_images = list()
	var/list/placed_images = list()

/mob/camera/eye/shuttle_docker/Initialize(mapload, owner_name, camera_origin, mob/living/user)
	..()
	set_loc(first_active_camera())

/mob/camera/eye/shuttle_docker/rename_camera(new_name)
	name = "Shuttle Docker Camera Eye ([new_name])"

/// Prevents the shuttle docker eye from updating global cameranet chunks. Shuttle dockers don't use station cameras.
/mob/camera/eye/shuttle_docker/update_visibility()
	return FALSE

/// Prevents moving the camera eye into the station, and updates the current location's landing spot validity.
/mob/camera/eye/shuttle_docker/set_loc(T)
	if(isspaceturf(get_turf(T)) || istype(get_area(T), /area/space) || istype(get_area(T), /area/shuttle))
		..()
		var/obj/machinery/computer/camera_advanced/shuttle_docker/console = origin
		console.check_landing_spot()

/mob/camera/eye/shuttle_docker/update_remote_sight(mob/living/user)
	user.sight = SEE_TURFS
	
	..()
	return TRUE
