
//objects in /obj/effect should never be things that are attackable, use obj/structure instead.
//Effects are mostly temporary visual effects like sparks, smoke, as well as decals, etc...

/obj/effect
	icon = 'icons/effects/effects.dmi'
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	move_resist = INFINITY
	anchored = 1
	can_be_hit = FALSE

/obj/effect/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	return

/obj/effect/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	return FALSE

/obj/effect/singularity_act()
	qdel(src)
	return FALSE

/obj/effect/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	return

/obj/effect/acid_act()
	return

/obj/effect/mech_melee_attack(obj/mecha/M)
	return 0

/obj/effect/blob_act(obj/structure/blob/B)
	return

/obj/effect/experience_pressure_difference()
	return

/obj/effect/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(60))
				qdel(src)
		if(3)
			if(prob(25))
				qdel(src)

/obj/effect/decal
	plane = FLOOR_PLANE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/no_scoop = FALSE   //if it has this, don't let it be scooped up
	var/no_clear = FALSE    //if it has this, don't delete it when its' scooped up
	var/list/scoop_reagents = null

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

/obj/effect/decal/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	qdel(src)

/obj/effect/decal/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	if(reagents)
		reagents.temperature_reagents(exposed_temperature)
	if(!(resistance_flags & FIRE_PROOF)) //non fire proof decal or being burned by lava
		qdel(src)

/obj/effect/decal/blob_act(obj/structure/blob/B)
	if(B && B.loc == loc)
		qdel(src)