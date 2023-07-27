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
	var/ghost_timer

/obj/structure/bed/nest/Initialize(mapload)
	. = ..()
	nest_overlay = image('icons/mob/alien.dmi', "nestoverlay", layer=MOB_LAYER - 0.2)

/obj/structure/bed/nest/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(has_buckled_mobs())
		for(var/buck in buckled_mobs) //breaking a nest releases all the buckled mobs, because the nest isn't holding them down anymore
			var/mob/living/M = buck

			if(user.get_int_organ(/obj/item/organ/internal/alien/plasmavessel))
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
				if(!do_after(M, 120 SECONDS, target = src))
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
	if(!istype(M) || (get_dist(src, user) > 1) || (M.loc != loc) || user.incapacitated() || M.buckled)
		return

	if(M.get_int_organ(/obj/item/organ/internal/alien/hivenode))
		to_chat(user, "<span class='noticealien'>[M]'s linkage with the hive prevents you from securing them into [src]</span>")
		return

	if(!user.get_int_organ(/obj/item/organ/internal/alien/hivenode))
		to_chat(user, "<span class='noticealien'>Your lack of linkage to the hive prevents you from buckling [M] into [src]</span>")
		return

	if(has_buckled_mobs())
		unbuckle_all_mobs()

	if(buckle_mob(M))
		M.visible_message("<span class='notice'>[user.name] secretes a thick vile goo, securing [M.name] into [src]!</span>",\
			"<span class='danger'>[user.name] drenches you in a foul-smelling resin, trapping you in [src]!</span>",\
			"<span class='italics'>You hear squelching...</span>")
	ghost_timer = addtimer(CALLBACK(src, PROC_REF(ghost_check), user), 15 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)

/obj/structure/bed/nest/proc/ghost_check(mob/user)
	if(!length(buckled_mobs))
		return
	for(var/mob/living/carbon/human/buckled_mob in buckled_mobs)
		var/obj/item/clothing/mask/facehugger/hugger_mask = buckled_mob.wear_mask
		if(istype(hugger_mask) && !hugger_mask.sterile && (locate(/obj/item/organ/internal/body_egg/alien_embryo) in buckled_mob.internal_organs))
			if(user && !isalien(user))
				return
			buckled_mob.throw_alert("ghost_nest", /obj/screen/alert/ghost)
			to_chat(buckled_mob, "<span class='ghostalert'>You may now ghost, you keep respawnability in this state. You will be alerted when you're removed from the nest.</span>")

/obj/structure/bed/nest/post_buckle_mob(mob/living/M)
	M.pixel_y = 0
	M.pixel_x = initial(M.pixel_x) + 2
	M.layer = BELOW_MOB_LAYER
	add_overlay(nest_overlay)

/obj/structure/bed/nest/post_unbuckle_mob(mob/living/M)
	M.pixel_x = M.get_standard_pixel_x_offset()
	M.pixel_y = M.get_standard_pixel_y_offset()
	M.layer = initial(M.layer)
	cut_overlay(nest_overlay)
	deltimer(ghost_timer)
	M.clear_alert("ghost_nest")
	M.notify_ghost_cloning("You have been unbuckled from an alien nest! Click that alert to re-enter your body.", source = src)

/obj/structure/bed/nest/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/effects/attackblob.ogg', 100, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/bed/nest/attack_alien(mob/living/carbon/alien/user)
	if(user.a_intent != INTENT_HARM)
		return attack_hand(user)
	if(!do_after(user, 4 SECONDS, target = src) || QDELETED(src))
		return
	playsound(loc, pick('sound/effects/alien_resin_break2.ogg','sound/effects/alien_resin_break1.ogg'), 50, FALSE)
	qdel(src)

/obj/structure/bed/nest/prevents_buckled_mobs_attacking()
	return TRUE
