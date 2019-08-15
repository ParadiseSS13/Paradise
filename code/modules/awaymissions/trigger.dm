/obj/effect/step_trigger/message
	var/message	//the message to give to the mob
	var/once = 1

/obj/effect/step_trigger/message/Trigger(mob/M as mob)
	if(M.client)
		to_chat(M, "<span class='info'>[message]</span>")
		if(once)
			qdel(src)

/obj/effect/step_trigger/teleport_fancy
	var/locationx
	var/locationy
	var/uses = 1	//0 for infinite uses
	var/entersparks = 0
	var/exitsparks = 0
	var/entersmoke = 0
	var/exitsmoke = 0

/obj/effect/step_trigger/teleport_fancy/Trigger(mob/M as mob)
	var/dest = locate(locationx, locationy, z)
	M.Move(dest)

	if(entersparks)
		do_sparks(4, 1, src)
	if(exitsparks)
		do_sparks(4, 1, dest)

	if(entersmoke)
		var/datum/effect_system/smoke_spread/s = new
		s.set_up(4, 1, src, 0)
		s.start()
	if(exitsmoke)
		var/datum/effect_system/smoke_spread/s = new
		s.set_up(4, 1, dest, 0)
		s.start()

	uses--
	if(uses == 0)
		qdel(src)