/obj/machinery/holo_barrier
	name = "Holo-barrier"
	desc = "A machine that can be activated to create a barrier that stops the flow of air, but allows organisms to pass through."
	icon_state = "holofield"
	anchored = TRUE
	var/operating = FALSE //Is it on?

/obj/machinery/holo_barrier/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return

	if(!anchored)
		to_chat(user, "<span class=`notice`>Anchor [src] down first!</span>")
		return

	handle_barrier(loc)

/obj/machinery/holo_barrier/proc/handle_barrier(turf/barrier_turf)
	if(operating)
		for(var/obj/effect/holo_forcefield/wall in barrier_turf)
			qdel(wall)
		operating = FALSE
	else
		use_power(1000)
		visible_message("<span class='danger'>A holographic barrier appears!</span>")
		new /obj/effect/holo_forcefield(barrier_turf)
		operating = TRUE

/obj/machinery/holo_barrier/Destroy()
	. = ..()
	if(operating)
		handle_barrier()

/obj/machinery/holo_barrier/process()
	if(!operating)
		return
	use_power(10000) // This doesn't work properly, or our power system is just really fucked.
	for(var/turf/simulated/T in range(1, src))
		if(T.air?.return_pressure() > 300) // The barrier can hold about 3x normal atmospheric pressure before it shuts down
			for(var/obj/effect/holo_forcefield/wall in loc) // For some reason handle_barrier wouldn't work properly here, so I'm doing it like this instead
				qdel(wall)
			operating = FALSE
			break

/obj/machinery/holo_barrier/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(default_unfasten_wrench(user, I, time = 3 SECONDS))
		return
	anchored = !anchored
	to_chat(user, "<span class='notice'>You [anchored ? "tighten" : "loosen"] [src].</span>")
	if(operating)
		handle_barrier()
