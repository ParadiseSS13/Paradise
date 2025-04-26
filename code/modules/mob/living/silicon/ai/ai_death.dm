/mob/living/silicon/ai/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	if(custom_sprite)//check for custom AI sprite, defaulting to blue screen if no.
		icon_state = "[ckey]-ai_dead"
	else if("[icon_state]_dead" in icon_states(icon,1))
		icon_state = "[icon_state]_dead"
	else
		icon_state = "ai_dead"
	if(eyeobj)
		eyeobj.set_loc(get_turf(src))

	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()

	if(nuking)
		SSsecurity_level.set_level(SEC_LEVEL_RED)
		nuking = FALSE
		for(var/obj/item/pinpointer/point in GLOB.pinpointer_list)
			point.the_disk = null //Point back to the disk.

	if(doomsday_device)
		doomsday_device.timing = FALSE
		SSshuttle.clearHostileEnvironment(doomsday_device)
		if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
			SSshuttle.emergency.mode = SHUTTLE_DOCKED
			SSshuttle.emergency.timer = world.time
			GLOB.major_announcement.Announce("Hostile environment resolved. You have 3 minutes to board the Emergency Shuttle.", "Priority Announcement", 'sound/AI/eshuttle_dock.ogg')
		qdel(doomsday_device)

	if(explosive)
		spawn(10) // REEEEEEEE
			explosion(src.loc, 3, 6, 12, 15, cause = "Adminbus explosive AI")

	for(var/obj/machinery/ai_status_display/O as anything in GLOB.ai_displays) //change status
		O.mode = AI_DISPLAY_MODE_BSOD

	if(istype(loc, /obj/item/aicard))
		loc.icon_state = "aicard-404"
