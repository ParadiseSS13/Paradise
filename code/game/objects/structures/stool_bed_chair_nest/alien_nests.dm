//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.

/obj/structure/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/mob/alien.dmi'
	icon_state = "nest"
	max_integrity = 120
	var/image/nest_overlay
	comfort = 0
	flags = NODECONSTRUCT

/obj/structure/bed/nest/New()
	nest_overlay = image('icons/mob/alien.dmi', "nestoverlay", layer=MOB_LAYER - 0.2)
	return ..()

/obj/structure/bed/nest/user_unbuckle_mob(mob/living/user)
	if(has_buckled_mobs())
		for(var/buck in buckled_mobs) //breaking a nest releases all the buckled mobs, because the nest isn't holding them down anymore
			var/mob/living/M = buck

			if(user.get_int_organ(/obj/item/organ/internal/xenos/plasmavessel))
				unbuckle_mob(M)
				add_fingerprint(user)
				return

			if(M != user)
				M.visible_message("<span class='notice'>[user.name] pulls [M.name] free from the sticky nest!</span>",\
					"<span class='notice'>[user.name] pulls you free from the gelatinous resin.</span>",\
					"<span class='italics'>You hear squelching...</span>")
			else
				M.visible_message("<span class='warning'>[M.name] struggles to break free from the gelatinous resin!</span>",\
					"<span class='notice'>You struggle to break free from the gelatinous resin... (Stay still for two minutes.)</span>",\
					"<span class='italics'>You hear squelching...</span>")
				if(!do_after(M, 1200, target = src))
					if(M && M.buckled)
						to_chat(M, "<span class='warning'>You fail to escape \the [src]!</span>")
					return
				if(!M.buckled)
					return
				M.visible_message("<span class='warning'>[M.name] breaks free from the gelatinous resin!</span>",\
					"<span class='notice'>You break free from the gelatinous resin!</span>",\
					"<span class='italics'>You hear squelching...</span>")

			unbuckle_mob(M)
			add_fingerprint(user)


/obj/structure/bed/nest/user_buckle_mob(mob/living/M, mob/living/user)
	if (!ismob(M) || (get_dist(src, user) > 1) || (M.loc != loc) || user.incapacitated() || M.buckled)
		return

	if(M.get_int_organ(/obj/item/organ/internal/xenos/plasmavessel))
		return

	if(!user.get_int_organ(/obj/item/organ/internal/xenos/plasmavessel))
		return

	if(has_buckled_mobs())
		unbuckle_all_mobs()

	if(buckle_mob(M))
		M.visible_message("<span class='notice'>[user.name] secretes a thick vile goo, securing [M.name] into [src]!</span>",\
			"<span class='danger'>[user.name] drenches you in a foul-smelling resin, trapping you in [src]!</span>",\
			"<span class='italics'>You hear squelching...</span>")


/obj/structure/bed/nest/post_buckle_mob(mob/living/M)
	M.pixel_y = 0
	M.pixel_x = initial(M.pixel_x) + 2
	M.layer = BELOW_MOB_LAYER
	add_overlay(nest_overlay)

/obj/structure/bed/nest/post_unbuckle_mob(mob/living/M)
	M.pixel_x = M.get_standard_pixel_x_offset(M.lying)
	M.pixel_y = M.get_standard_pixel_y_offset(M.lying)
	M.layer = initial(M.layer)
	cut_overlay(nest_overlay)

/obj/structure/bed/nest/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/effects/attackblob.ogg', 100, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/bed/nest/attack_alien(mob/living/carbon/alien/user)
	if(user.a_intent != INTENT_HARM)
		return attack_hand(user)
	else
		return ..()