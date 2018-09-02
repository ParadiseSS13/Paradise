/mob/living/silicon/ai/death(gibbed)
	if(stat == DEAD)
		return
	stat = DEAD
	if(custom_sprite == 1)//check for custom AI sprite, defaulting to blue screen if no.
		icon_state = "[ckey]-ai_dead"
	else if("[icon_state]_dead" in icon_states(icon,1))
		icon_state = "[icon_state]_dead"
	else
		icon_state = "ai_dead"
	update_canmove()
	if(eyeobj)
		eyeobj.setLoc(get_turf(src))
	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO

	shuttle_caller_list -= src
	SSshuttle.autoEvac()

	if(nuking)
		set_security_level("red")
		nuking = 0
		for(var/obj/item/pinpointer/point in pinpointer_list)
			point.the_disk = null //Point back to the disk.

	if(doomsday_device)
		doomsday_device.timing = 0
		SSshuttle.emergencyNoEscape = 0
		if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
			SSshuttle.emergency.mode = SHUTTLE_DOCKED
			SSshuttle.emergency.timer = world.time
			priority_announcement.Announce("Hostile environment resolved. You have 3 minutes to board the Emergency Shuttle.", "Priority Announcement", 'sound/AI/shuttledock.ogg')
		qdel(doomsday_device)

	if(explosive)
		spawn(10)
			explosion(src.loc, 3, 6, 12, 15)

	for(var/obj/machinery/ai_status_display/O in world) //change status
		spawn( 0 )
		O.mode = 2
		if(istype(loc, /obj/item/aicard))
			loc.icon_state = "aicard-404"

	timeofdeath = world.time
	if(mind)	mind.store_memory("Time of death: [station_time_timestamp("hh:mm:ss", timeofdeath)]", 0)

	return ..(gibbed)
