
//objects in /obj/effect should never be things that are attackable, use obj/structure instead.
//Effects are mostly temporary visual effects like sparks, smoke, as well as decals, etc...

/obj/effect
	icon = 'icons/effects/effects.dmi'
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = 1
	can_be_hit = FALSE

/obj/effect/attackby(obj/item/I, mob/living/user, params)
	return

/obj/effect/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	return

/obj/effect/fire_act(exposed_temperature, exposed_volume)
	return

/obj/effect/acid_act()
	return

/obj/effect/mech_melee_attack(obj/mecha/M)
	return 0

/obj/effect/blob_act()
	return

/obj/effect/ex_act(severity, target)
	if(target == src)
		qdel(src)
	else
		switch(severity)
			if(1)
				qdel(src)
			if(2)
				if(prob(60))
					qdel(src)
			if(3)
				if(prob(25))
					qdel(src)

/obj/effect/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	return

/obj/effect/decal
	name = "decal"
	anchored = 1
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	plane = FLOOR_PLANE
	var/no_scoop = FALSE   //if it has this, don't let it be scooped up
	var/no_clear = FALSE    //if it has this, don't delete it when its' scooped up
	var/list/scoop_reagents = null

/obj/effect/decal/fire_act(exposed_temperature, exposed_volume)
	if(!(resistance_flags & FIRE_PROOF)) //non fire proof decal or being burned by lava
		qdel(src)

/obj/effect/decal/Initialize(mapload)
	. = ..()
	if(scoop_reagents)
		create_reagents(100)
		reagents.add_reagent_list(scoop_reagents)

/obj/effect/decal/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/reagent_containers/food/drinks))
		scoop(I, user)

/obj/effect/decal/proc/scoop(obj/item/I, mob/user)
	if(reagents && I.reagents && !no_scoop)
		if(!reagents.total_volume)
			to_chat(user, "<span class='notice'>There isn't enough [src] to scoop up!</span>")
			return
		if(I.reagents.total_volume >= I.reagents.maximum_volume)
			to_chat(user, "<span class='notice'>[I] is full!</span>")
			return
		to_chat(user, "<span class='notice'>You scoop [src] into [I]!</span>")
		reagents.trans_to(I, reagents.total_volume)
		if(!reagents.total_volume && !no_clear) //scooped up all of it
			qdel(src)
