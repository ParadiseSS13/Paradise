/mob/living/silicon/decoy/death(gibbed)
	if(stat == DEAD)
		return
	stat = DEAD
	icon_state = "ai-crash"
	for(var/obj/machinery/ai_status_display/O in world) //change status
		if(O.z == z)
			O.mode = 2
	..(0)
	gib()