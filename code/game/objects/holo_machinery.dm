/obj/machinery/holo_barrier
	name = "Holo-barrier"
	desc = "A machine that can be activated to create a barrier that stops the flow of air, but allows organisms to pass through."
	icon_state = "holofield"
	anchored = TRUE
	var/operating = FALSE //Is it on?

/obj/machinery/holo_barrier/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return

	if(operating)
		remove_barrier(loc)
		return

//	if(locked)
//		to_chat(user, "<span class='warning'>Wait for [occupant.name] to finish being loaded!</span>")
//		return

	create_barrier(loc)

/obj/machinery/holo_barrier/proc/create_barrier(turf/barrier_turf)
	use_power(1000)
	visible_message("<span class='danger'>A holographic barrier appears!</span>")

	operating = TRUE
	new /obj/effect/holo_forcefield(barrier_turf)
	update_icon(UPDATE_OVERLAYS | UPDATE_ICON_STATE)

/obj/machinery/holo_barrier/proc/remove_barrier(turf/barrier_turf)
	for(var/obj/effect/holo_forcefield/wall in barrier_turf)
		qdel(wall)
	operating = FALSE
