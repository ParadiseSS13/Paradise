///Hack computer cameras to use them as a secret camera network
/datum/spell/flayer/surveilance_monitor
	name = "Camfecting Bug"
	power_type = FLAYER_PURCHASABLE_POWER
	category = CATEGORY_INTRUDER
	base_cooldown = 1 SECONDS //DEBUGGGG ONLY
	var/obj/item/camera_bug/internal_camera
	var/maximum_hacked_computers = 6
	var/list/active_bugs = list()

/datum/spell/flayer/surveilance_monitor/AltClick(mob/user)
	if(!internal_camera)
		internal_camera = new /obj/item/camera_bug(user)
	internal_camera.ui_interact(user)

/datum/spell/flayer/surveilance_monitor/create_new_targeting()
	var/datum/spell_targeting/click/C = new()
	C.try_auto_target = FALSE
	C.allowed_type = /obj/machinery/computer
	C.range = 5
	return C

/datum/spell/flayer/surveilance_monitor/cast(list/targets, mob/user)
	if(!internal_camera)
		internal_camera = new /obj/item/camera_bug(user)
	if(length(active_bugs) >= maximum_hacked_computers)
		var/obj/item/wall_bug/to_destroy = tgui_input_list(user, "Choose an active camera to destroy.", "Maximum Camera Limit Reached.", active_bugs)
		if(to_destroy)
			active_bugs -= to_destroy
			QDEL_NULL(to_destroy)
		return TRUE

	var/obj/machinery/computer/target = targets[1]
	var/obj/item/wall_bug/computer_bug/nanobot = new /obj/item/wall_bug/computer_bug(target, flayer)
	nanobot.name += " - [get_area(target)]"
	nanobot.link_to_camera(internal_camera)
	active_bugs += nanobot
	flayer.send_swarm_message("Surveilance unit #[internal_camera.connections] deployed.")
	return TRUE
