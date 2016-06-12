/mob/living/silicon/ai/death(gibbed)
	if(stat == DEAD)	return
	stat = DEAD
	if (src.custom_sprite == 1)//check for custom AI sprite, defaulting to blue screen if no.
		icon_state = "[ckey]-ai-crash"
	else icon_state = "ai-crash"
	update_canmove()
	if(eyeobj)
		eyeobj.setLoc(get_turf(src))
	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO

	shuttle_caller_list -= src
	shuttle_master.autoEvac()

	if(explosive)
		spawn(10)
			explosion(src.loc, 3, 6, 12, 15)

	for(var/obj/machinery/ai_status_display/O in world) //change status
		spawn( 0 )
		O.mode = 2
		if (istype(loc, /obj/item/device/aicard))
			loc.icon_state = "aicard-404"

	timeofdeath = worldtime2text()
	if(mind)	mind.store_memory("Time of death: [timeofdeath]", 0)

	return ..(gibbed)
