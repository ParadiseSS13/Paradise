/////SINGULARITY SPAWNER
/obj/machinery/the_singularitygen
	name = "Gravitational Singularity Generator"
	desc = "An odd device which produces a Gravitational Singularity when set up."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "TheSingGen"
	density = TRUE
	power_state = NO_POWER_USE
	resistance_flags = FIRE_PROOF
	var/energy = 0
	var/creation_type = /obj/singularity

/obj/machinery/the_singularitygen/process()
	var/turf/T = get_turf(src)
	if(src.energy >= 200)
		message_admins("A [creation_type] has been created at [x], [y], [z] (<A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
		investigate_log("A [creation_type] has been created at [x], [y], [z]",INVESTIGATE_SINGULO)

		var/obj/singularity/S = new creation_type(T, 50)
		transfer_fingerprints_to(S)
		if(src) qdel(src)

/obj/machinery/the_singularitygen/wrench_act(mob/living/user, obj/item/wrench/W)
	. = TRUE
	anchored = !anchored
	if(!W.use_tool(src, user, 2 SECONDS, 0, 50))
		return
	if(anchored)
		user.visible_message("[user.name] secures [src] to the floor.", \
			"You secure [src] to the floor.", \
			"You hear a ratchet.")
		src.add_hiddenprint(user)
	else
		user.visible_message("[user.name] unsecures [src] from the floor.", \
			"You unsecure [src.name] from the floor.", \
			"You hear a ratchet.")

