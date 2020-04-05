/obj/effect/accelerated_particle
	name = "Accelerated Particles"
	desc = "Small things moving very fast."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "particle"
	anchored = TRUE
	density = FALSE
	var/movement_range = 10
	var/energy = 10
	var/speed = 1

/obj/effect/accelerated_particle/weak
	movement_range = 8
	energy = 5

/obj/effect/accelerated_particle/strong
	movement_range = 15
	energy = 15

/obj/effect/accelerated_particle/powerful
	movement_range = 20
	energy = 50


/obj/effect/accelerated_particle/Initialize(loc)
	. = ..()
	addtimer(CALLBACK(src, .proc/propagate), 1)
	RegisterSignal(src, COMSIG_CROSSED_MOVABLE, .proc/try_irradiate)
	RegisterSignal(src, COMSIG_MOVABLE_CROSSED, .proc/try_irradiate)
	QDEL_IN(src, movement_range)

/obj/effect/accelerated_particle/proc/try_irradiate(src, atom/A)
	if(isliving(A))
		var/mob/living/L = A
		L.apply_effect((energy * 6), IRRADIATE, 0)
	else if(istype(A, /obj/machinery/the_singularitygen))
		var/obj/machinery/the_singularitygen/S = A
		S.energy += energy
	else if(istype(A, /obj/structure/blob))
		var/obj/structure/blob/B = A
		B.take_damage(energy * 0.6)
		movement_range = 0

/obj/effect/accelerated_particle/Bump(obj/singularity/S)
	if(!istype(S))
		return ..()
	S.energy += energy


/obj/effect/accelerated_particle/ex_act(severity)
	qdel(src)

/obj/effect/accelerated_particle/singularity_pull()
	return

/obj/effect/accelerated_particle/proc/propagate()
	addtimer(CALLBACK(src, .proc/propagate), 1)
	if(!step(src,dir))
		forceMove(get_step(src, dir))
