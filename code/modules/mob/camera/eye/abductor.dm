/mob/camera/eye/abductor
	name = "Abductor Camera Eye"
	ai_detector_visible = FALSE

/mob/camera/eye/abductor/Initialize(mapload, owner_name, camera_origin, user)
	..()
	set_loc(first_active_camera())

/mob/camera/eye/abductor/rename_camera(new_name)
	name = "Abductor Camera Eye ([new_name])"

/// Requires the cameranet to be validated.
/mob/camera/eye/abductor/validate_active_cameranet()
	..(TRUE)
