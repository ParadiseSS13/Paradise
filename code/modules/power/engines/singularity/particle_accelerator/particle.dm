/obj/effect/accelerated_particle
	name = "Accelerated Particles"
	desc = "Small things moving very fast."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "particle"
	var/movement_range = 11
	var/energy = 10

/obj/effect/accelerated_particle/weak
	movement_range = 9
	energy = 5

/obj/effect/accelerated_particle/strong
	movement_range = 16
	energy = 15

/obj/effect/accelerated_particle/powerful
	movement_range = 21
	energy = 50


/obj/effect/accelerated_particle/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(propagate)), 1)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(try_irradiate)
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_movable_moved))
	QDEL_IN(src, movement_range)

/obj/effect/accelerated_particle/proc/on_movable_moved(datum/source, old_location, direction, forced)
	if(isturf(loc))
		for(var/atom/A in loc)
			try_irradiate(src, A)

/obj/effect/accelerated_particle/proc/try_irradiate(source, atom/A)
	if(isliving(A))
		var/mob/living/L = A
		L.base_rad_act(source, energy * 6, GAMMA_RAD)
	else if(istype(A, /obj/machinery/the_singularitygen))
		var/obj/machinery/the_singularitygen/S = A
		S.energy += energy
	else if(istype(A, /obj/structure/blob))
		var/obj/structure/blob/B = A
		B.take_damage(energy * 0.6)
		movement_range = 0

/// The particles bump the singularity
/obj/effect/accelerated_particle/Bump(obj/singularity/S)
	if(!istype(S))
		return ..()
	S.energy += energy
	energy = 0

/// The singularity bumps the particles
/obj/effect/accelerated_particle/singularity_act()
	return

/obj/effect/accelerated_particle/ex_act(severity)
	qdel(src)

/obj/effect/accelerated_particle/singularity_pull()
	return

/obj/effect/accelerated_particle/proc/propagate()
	addtimer(CALLBACK(src, PROC_REF(propagate)), 1)
	if(!step(src,dir))
		forceMove(get_step(src, dir))
