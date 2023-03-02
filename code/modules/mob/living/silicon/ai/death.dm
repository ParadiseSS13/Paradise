/mob/living/silicon/ai/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	if(custom_sprite == 1)//check for custom AI sprite, defaulting to blue screen if no.
		icon_state = "[ckey]-ai_dead"
	else if("[icon_state]_dead" in icon_states(icon,1))
		icon_state = "[icon_state]_dead"
	else
		icon_state = "ai_dead"
	if(eyeobj)
		eyeobj.setLoc(get_turf(src))

	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()

	if(mind in SSticker.mode.traitors)
		GLOB.disable_robotics_consoles = FALSE

	if(nuking)
		set_security_level("red")
		nuking = 0
		for(var/obj/item/pinpointer/point in GLOB.pinpointer_list)
			point.the_disk = null //Point back to the disk.

	if(doomsday_device)
		doomsday_device.timing = 0
		SSshuttle.emergencyNoEscape = 0
		if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
			SSshuttle.emergency.mode = SHUTTLE_DOCKED
			SSshuttle.emergency.timer = world.time
			GLOB.priority_announcement.Announce("Вредоносное окружение устранено. У вас есть 3 минуты, чтобы подняться на борт эвакуационного шаттла.", "Приоритетное оповещение.", 'sound/AI/shuttledock.ogg')
		qdel(doomsday_device)

	if(explosive)
		spawn(10)
			explosion(src.loc, 3, 6, 12, 15, cause = "AI exploded")

	for(var/obj/machinery/ai_status_display/O in GLOB.machines) //change status
		O.mode = 2

	if(istype(loc, /obj/item/aicard))
		loc.icon_state = "aicard-404"
