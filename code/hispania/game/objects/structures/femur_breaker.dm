#define BREAKER_ANIMATION_LENGTH 32
#define BREAKER_SLAT_RAISED     1
#define BREAKER_SLAT_MOVING     2
#define BREAKER_SLAT_DROPPED    3
#define BREAKER_ACTIVATE_DELAY   30
#define BREAKER_WRENCH_DELAY     10
#define BREAKER_ACTION_INUSE      5
#define BREAKER_ACTION_WRENCH     6

/obj/structure/femur_breaker
	name = "femur breaker"
	desc = "A large structure used to break the femurs of traitors and treasonists."
	icon = 'icons/hispania/obj/femur_breaker.dmi'
	icon_state = "breaker_raised"
	can_buckle = TRUE
	anchored = TRUE
	density = TRUE
	max_buckled_mobs = 1
	buckle_lying = TRUE
	buckle_prevents_pull = TRUE
	buckle_offset = -6
	layer = ABOVE_MOB_LAYER
	var/slat_status = BREAKER_SLAT_RAISED
	var/current_action = 0 // What's currently happening to the femur breaker

/obj/structure/femur_breaker/examine(mob/user)
	. = ..()
	var/msg = ""
	msg += "It is [anchored ? "secured to the floor." : "unsecured."]<br/>"
	if(slat_status == BREAKER_SLAT_RAISED)
		msg += "The breaker slat is in a neutral position."
	else
		msg += "The breaker slat is lowered, and must be raised."

	if(LAZYLEN(buckled_mobs))
		msg += "<br/>Someone appears to be strapped in. You can help them unbuckle, or activate the femur breaker."
	. += msg

/obj/structure/femur_breaker/attack_hand(mob/user)
	add_fingerprint(user)
	// Currently being used
	if(current_action)
		return

	switch(slat_status)
		if(BREAKER_SLAT_MOVING)
			return
		if(BREAKER_SLAT_DROPPED)
			current_action = BREAKER_ACTION_INUSE
			slat_status = BREAKER_SLAT_MOVING
			icon_state = "breaker_raise"
			addtimer(CALLBACK(src, .proc/raise_slat), BREAKER_ANIMATION_LENGTH)
			current_action = 0
			return
		if(BREAKER_SLAT_RAISED)
			if(LAZYLEN(buckled_mobs))
				if(user.a_intent == INTENT_HARM)
					user.visible_message("<span class='warning'>[user] begins to pull the lever!</span>",
						                 "<span class='warning'>You begin to the pull the lever.</span>")
					current_action = BREAKER_ACTION_INUSE

					if(do_after(user, BREAKER_ACTIVATE_DELAY, target = src) && slat_status == BREAKER_SLAT_RAISED)
						slat_status = BREAKER_SLAT_MOVING
						icon_state = "breaker_drop"
						drop_slat(user)
						current_action = 0
					else
						current_action = 0
				else
					var/mob/living/carbon/human/H = buckled_mobs[1]

					if(H)
						H.regenerate_icons()

					unbuckle_all_mobs()
			else //HERE
				slat_status = BREAKER_SLAT_DROPPED
				icon_state = "breaker_drop"

/obj/structure/femur_breaker/proc/damage_leg(mob/living/carbon/human/H)
	var/obj/item/organ/external/affected = H.get_organ(pick("l_leg", "r_leg"))
	affected.receive_damage(50)
	affected.fracture()
	H.emote("scream")

/obj/structure/femur_breaker/proc/raise_slat()
	slat_status = BREAKER_SLAT_RAISED
	icon_state = "breaker_raised"

/obj/structure/femur_breaker/proc/drop_slat(mob/user)
	if(buckled_mobs.len)
		current_action = BREAKER_ACTION_INUSE
		var/mob/living/carbon/human/H = buckled_mobs[1]

		if(!H)
			return
		if(H.stat == CONSCIOUS)
			playsound(src, 'sound/hispania/machines/femur_breaker.ogg', 50, FALSE)
		H.Stun(BREAKER_ANIMATION_LENGTH)
		addtimer(CALLBACK(src, .proc/damage_leg, H), BREAKER_ANIMATION_LENGTH, TIMER_UNIQUE)
		add_attack_logs(user, H, "femur broke with [src]")

		if(H.key && H.stat == CONSCIOUS)
			attract_oldman()

	slat_status = BREAKER_SLAT_DROPPED
	icon_state = "breaker"
	current_action = 0

/obj/structure/femur_breaker/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(!anchored)
		to_chat(usr, "<span class='warning'>The [src] needs to be wrenched to the floor!</span>")
		return FALSE

	if(!istype(M, /mob/living/carbon/human))
		to_chat(usr, "<span class='warning'>It doesn't look like [M.p_they()] can fit into this properly!</span>")
		return FALSE

	if(slat_status != BREAKER_SLAT_RAISED)
		to_chat(usr, "<span class='warning'>The femur breaker must be in its neutral position before buckling someone in!</span>")
		return FALSE

	return ..(M, force, FALSE)

/obj/structure/femur_breaker/post_buckle_mob(mob/living/M)
	if(!istype(M, /mob/living/carbon/human))
		return

	var/mob/living/carbon/human/H = M

	if(H.dna)
		if (H.dna.species)
			var/datum/species/S = H.dna.species

			if (!istype(S))
				unbuckle_all_mobs()
		else
			unbuckle_all_mobs()
	else
		unbuckle_all_mobs()

	..()

/obj/structure/femur_breaker/attackby(obj/item/W, mob/user, params)
	if(iswrench(W))
		if(current_action)
			return

		current_action = BREAKER_ACTION_WRENCH

		if(do_after(user, BREAKER_WRENCH_DELAY, target = src))
			current_action = 0
			if(has_buckled_mobs())
				to_chat(user, "<span class='warning'>Can't unfasten, someone's strapped in!</span>")
				return

			if(current_action)
				return
			to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secure [src].</span>")
			anchored = !anchored
			playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
			dir = SOUTH
			return TRUE
		else
			current_action = 0
	if(iswelder(W))
		var/obj/item/weldingtool/WT = W
		if(!WT.remove_fuel(0, user))
			return
		to_chat(user, "<span class='notice'>You begin cutting [src] apart...</span>")
		playsound(loc, WT.usesound, 40, 1)
		if(do_after(user, 150 * WT.toolspeed, 1, target = src))
			if(!WT.tool_enabled)
				return
			playsound(loc, WT.usesound, 50, 1)
			visible_message("<span class='notice'>[user] slices apart [src].</span>",
							"<span class='notice'>You cut [src] apart with [WT].</span>",
							"<span class='italics'>You hear welding.</span>")
			var/turf/T = get_turf(src)
			new /obj/item/stack/sheet/plasteel(T, 10)
			new /obj/item/stack/rods(T, 20)
			new /obj/item/stack/sheet/metal(T, 10)
			new /obj/item/stack/cable_coil(T, 30)
			qdel(src)
		return
	else
		return ..()

/obj/structure/femur_breaker/proc/attract_oldman()
	for(var/mob/living/simple_animal/hostile/oldman/M in GLOB.player_list)
		if(!M)
			return
		var/mob/living/carbon/human/H = buckled_mobs[1]
		to_chat(M, "<span class='warning'>You sense an incapacited victim nearby...</span>")
		if(M.dimension)
			M.forceMove(get_turf(src))
			M.notransform = TRUE
			to_chat(M, "<span class='danger'>You cannot resist your hunger and you go directly to them!</span>")
			spawn(2 SECONDS)
				if(world.time - M.time_spawned > 20 MINUTES)
					new /obj/effect/decal/cleanable/blood/oil/sludge(get_turf(src))
					playsound(src, 'sound/hispania/effects/oldman/sacrifice.ogg', 50, FALSE)
					M.icon_state = "sacrifice"
					M.maxHealth = 999999 //Para que sobreviva durante la animacion
					M.health = 999999
					M.incorporeal_move = 0
					M.density = TRUE
					M.pass_flags = 0
					M.dimension = FALSE
					M.mob_size = MOB_SIZE_LARGE
					M.invisibility = 0
					spawn(14 SECONDS)
						H.gib()
						spawn(2 SECONDS)
							M.icon_state = "idle"
							M.death()
				else
					M.notransform = FALSE

#undef BREAKER_ANIMATION_LENGTH
#undef BREAKER_SLAT_RAISED
#undef BREAKER_SLAT_MOVING
#undef BREAKER_SLAT_DROPPED
#undef BREAKER_ACTIVATE_DELAY
#undef BREAKER_WRENCH_DELAY
#undef BREAKER_ACTION_INUSE
#undef BREAKER_ACTION_WRENCH
