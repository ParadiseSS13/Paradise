/obj/machinery/holo_barrier
	name = "Holo-barrier"
	desc = "A machine that can be activated to create a barrier that stops the flow of air, but allows organisms to pass through."
	icon_state = "holofield"
	anchored = TRUE
	var/operating = FALSE //Is it on?

/obj/machinery/holo_barrier/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return

	handle_barrier(loc)

//	if(locked) TODO: add ID locking to it
//		to_chat(user, "<span class='warning'>Wait for [occupant.name] to finish being loaded!</span>")
//		return

/obj/machinery/holo_barrier/proc/handle_barrier(turf/barrier_turf)
	if(operating)
		for(var/obj/effect/holo_forcefield/wall in barrier_turf)
			qdel(wall)
	else
		use_power(1000)
		visible_message("<span class='danger'>A holographic barrier appears!</span>")
		new /obj/effect/holo_forcefield(barrier_turf)

	operating = !operating
