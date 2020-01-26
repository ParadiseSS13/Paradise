//Camera action button stuff

/datum/action/innate/camera_move
	var/direction //What way do we go when clicked?

/datum/action/innate/camera_move/Grant(mob/M, obj/machinery/computer/security/S)
	target = S
	return ..()

/datum/action/innate/camera_move/Activate() //Attempt to move to a new camera
	if(!owner || owner.machine != target)
		return
	var/obj/machinery/computer/security/camera_console = owner.machine
	var/obj/machinery/camera/my_cam = camera_console.watchers[owner]
	var/obj/machinery/camera/my_cached_cam = my_cam.cached_cameras["[direction]"] //The camera we previously cached
	if(my_cached_cam == CAMERA_BUTTON_NO_CAMERA)
		return
	if(my_cached_cam && camera_console.switch_to_camera(owner, my_cached_cam))
		return
	var/turf/my_turf = get_turf(my_cam)
	var/obj/machinery/camera/new_camera //The camera to move to
	my_turf = get_step(my_turf, direction) //One forward to start
	for(var/i in 1 to CAMERA_MAX_DISTANCE_TO_LOOK)
		new_camera = find_camera(my_turf, direction, (round(i/2)+1)) //This will search in a narrowish cone ahead of the camera
		if(new_camera)
			if(camera_console.switch_to_camera(owner, new_camera))
				my_cam.cache_camera(new_camera, direction)
				return
			new_camera = null
		my_turf = get_step(my_turf, direction) //Go forwards one
	my_cam.cache_camera(CAMERA_BUTTON_NO_CAMERA, direction) //We found nothing!

/datum/action/innate/camera_move/proc/find_camera(turf/T, direction_to_check, width_of_box) //tries to find a camera in a 1-by-X box around a central turf, then returns that camera
	var/obj/machinery/camera/C
	C = locate() in T
	if(C)
		return C
	if(width_of_box <= 1) //No need to check to the sides
		return
	var/box_size //Didn't find one on our turf, check to the sides
	if(direction_to_check == NORTH || direction_to_check == SOUTH)
		box_size = "[width_of_box * 2 - 1]x1"
	else
		box_size = "1x[width_of_box * 2 - 1]"
	for(var/turf/turf_to_check in orange(box_size, T))
		C = locate() in turf_to_check
		if(C)
			return C
//Camera action button types
/datum/action/innate/camera_move/move_n
	name = "Pan Fore"
	button_icon_state = "camera_n"
	direction = NORTH

/datum/action/innate/camera_move/move_e
	name = "Pan Starboard"
	button_icon_state = "camera_e"
	direction = EAST

/datum/action/innate/camera_move/move_s
	name = "Pan Aft"
	button_icon_state = "camera_s"
	direction = SOUTH

/datum/action/innate/camera_move/move_w
	name = "Pan Port"
	button_icon_state = "camera_w"
	direction = WEST
