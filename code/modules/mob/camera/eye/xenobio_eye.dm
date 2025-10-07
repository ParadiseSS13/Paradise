/mob/camera/eye/xenobio
	name = "Xenobiology Console Camera Eye"
	visible_icon = TRUE
	ai_detector_visible = FALSE
	var/allowed_area

/mob/camera/eye/xenobio/Initialize(mapload, owner_name, camera_origin, mob/living/user)
	. = ..()
	var/area/A = get_area(camera_origin)
	allowed_area = A.name

/mob/camera/eye/xenobio/rename_camera(new_name)
	name = "Xenobiology Console ([new_name])"

/// Prevents the camera eye from going outside of the xenobiology area
/mob/camera/eye/xenobio/set_loc(T)
	var/area/new_area = get_area(T)
	if(!new_area)
		return
	if(new_area.name != allowed_area && !new_area.xenobiology_compatible)
		return
	return ..()
