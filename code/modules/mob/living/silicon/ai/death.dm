/mob/living/silicon/ai/death(gibbed)
	if(stat == DEAD)	return
	stat = DEAD
	if (src.custom_sprite == 1)//check for custom AI sprite, defaulting to blue screen if no.
		icon_state = "[ckey]-ai-crash"
	else icon_state = "ai-crash"
	update_canmove()
	if(src.eyeobj)
		src.eyeobj.setLoc(get_turf(src))
	if(blind)	blind.layer = 0
	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO

	var/callshuttle = 0

	for(var/obj/machinery/computer/communications/commconsole in world)
		if((commconsole.z in config.admin_levels))
			continue
		if(istype(commconsole.loc,/turf))
			break
		callshuttle++

	for(var/obj/item/weapon/circuitboard/communications/commboard in world)
		if((commboard.z in config.admin_levels))
			continue
		if(istype(commboard.loc,/turf) || istype(commboard.loc,/obj/item/weapon/storage))
			break
		callshuttle++

	for(var/mob/living/silicon/ai/shuttlecaller in player_list)
		if((shuttlecaller.z in config.admin_levels))
			continue
		if(!shuttlecaller.stat && shuttlecaller.client && istype(shuttlecaller.loc,/turf))
			break
		callshuttle++

	if(ticker.mode.name == "revolution" || ticker.mode.name == "AI malfunction" || sent_strike_team)
		callshuttle = 0

	if(callshuttle == 3) //if all three conditions are met
		emergency_shuttle.call_evac()
		log_game("All the AIs, comm consoles and boards are destroyed. Shuttle called.")
		message_admins("All the AIs, comm consoles and boards are destroyed. Shuttle called.", 1)

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
