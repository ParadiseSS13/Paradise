/////SINGULARITY SPAWNER
/obj/machinery/the_singularitygen/
	name = "Gravitational Singularity Generator"
	desc = "An odd device which produces a Gravitational Singularity when set up."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "TheSingGen"
	anchored = 0
	density = 1
	use_power = 0
	var/energy = 0
	var/creation_type = /obj/singularity

	// You can buckle someone to the singularity generator, then start the engine. Fun!
	can_buckle = TRUE
	buckle_lying = 0
	buckle_requires_restraints = 1

/obj/machinery/the_singularitygen/process()
	var/turf/T = get_turf(src)
	if(src.energy >= 200)
		message_admins("A [creation_type] has been created at [x], [y], [z] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
		investigate_log("A [creation_type] has been created at [x], [y], [z]","singulo")

		var/obj/singularity/S = new creation_type(T, 50)
		transfer_fingerprints_to(S)
		if(src) qdel(src)

/obj/machinery/the_singularitygen/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/wrench))
		anchored = !anchored
		playsound(src.loc, W.usesound, 75, 1)
		if(anchored)
			user.visible_message("[user.name] secures [src.name] to the floor.", \
				"You secure the [src.name] to the floor.", \
				"You hear a ratchet")
			src.add_hiddenprint(user)
		else
			user.visible_message("[user.name] unsecures [src.name] from the floor.", \
				"You unsecure the [src.name] from the floor.", \
				"You hear a ratchet")
		return
	else if(user.a_intent == INTENT_GRAB)
		if(istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if(isliving(G.affecting))
				var/mob/living/H = G.affecting
				if(!H.restrained())
					to_chat(user, "[H] needs to be restrained before you can put them on [src]!")
					return
				if(do_mob(user, src, 120))
					user_buckle_mob(H, user, check_loc = FALSE)//the check_loc logic works in reverse if anyone is wondering...
					qdel(G)
	return ..()

/obj/machinery/the_singularitygen/MouseDrop_T(mob/living/carbon/human/target, mob/user)
	if(!Adjacent(user) || !user.Adjacent(target) || !isliving(target))
		return
	if(!target.restrained())
		to_chat(user, "[target] needs to be restrained before you can put them on [src]!")
		return
	if(do_mob(user, src, 120))
		user_buckle_mob(target, user, check_loc = FALSE)