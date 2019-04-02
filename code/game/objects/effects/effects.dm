
//objects in /obj/effect should never be things that are attackable, use obj/structure instead.
//Effects are mostly temporary visual effects like sparks, smoke, as well as decals, etc...

/obj/effect
	icon = 'icons/effects/effects.dmi'
	burn_state = LAVA_PROOF | FIRE_PROOF
	resistance_flags = INDESTRUCTIBLE
	anchored = 1
	can_be_hit = FALSE

/obj/effect/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	return

/obj/effect/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	return FALSE

/obj/effect/decal
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
	..()