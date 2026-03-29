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
				M.visible_message(SPAN_NOTICE("[user.name] pulls [M.name] free from the sticky nest!"),\
					SPAN_NOTICE("[user.name] pulls you free from the gelatinous resin."),\
					SPAN_ITALICS("You hear squelching..."))
			else
				M.visible_message(SPAN_WARNING("[M.name] struggles to break free from the gelatinous resin!"),\
					SPAN_NOTICE("You struggle to break free from the gelatinous resin... (Stay still for two minutes.)"),\
					SPAN_ITALICS("You hear squelching..."))
				if(!do_after(M, 120 SECONDS, target = src, hidden = TRUE))
					if(M && M.buckled)
						to_chat(M, SPAN_WARNING("You fail to escape \the [src]!"))
					return
				if(!M.buckled)
					return
				M.visible_message(SPAN_WARNING("[M.name] breaks free from the gelatinous resin!"),\
					SPAN_NOTICE("You break free from the gelatinous resin!"),\
					SPAN_ITALICS("You hear squelching..."))

			unbuckle_mob(M)
			add_fingerprint(user)

/obj/structure/bed/nest/user_buckle_mob(mob/living/M, mob/living/user)
	if(!istype(M) || user.incapacitated() || M.buckled)
		return

	if(M != user && !HAS_TRAIT(M, TRAIT_HANDS_BLOCKED) && (!in_range(M, src) || !do_after(user, 1 SECONDS, target = M)))
		return FALSE

	if(M.get_int_organ(/obj/item/organ/internal/alien/hivenode))
		to_chat(user, SPAN_NOTICEALIEN("[M]'s linkage with the hive prevents you from securing them into [src]"))
		return

	if(!user.get_int_organ(/obj/item/organ/internal/alien/hivenode))
		to_chat(user, SPAN_NOTICEALIEN("Your lack of linkage to the hive prevents you from buckling [M] into [src]"))
		return

	if(has_buckled_mobs())
		unbuckle_all_mobs()

	if(buckle_mob(M))
		M.visible_message(SPAN_NOTICE("[user.name] secretes a thick vile goo, securing [M.name] into [src]!"),\
			SPAN_DANGER("[user.name] drenches you in a foul-smelling resin, trapping you in [src]!"),\
			SPAN_ITALICS("You hear squelching..."))
	ghost_timer = addtimer(CALLBACK(src, PROC_REF(ghost_check), user), 15 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)

/obj/structure/bed/nest/proc/ghost_check(mob/user)
	if(!length(buckled_mobs))
		return
	for(var/mob/living/carbon/human/buckled_mob in buckled_mobs)
		var/obj/item/clothing/mask/facehugger/hugger_mask = buckled_mob.wear_mask
		if(istype(hugger_mask) && !hugger_mask.sterile && (locate(/obj/item/organ/internal/body_egg/alien_embryo) in buckled_mob.internal_organs))
			if(user && !isalien(user))
				return
			buckled_mob.throw_alert("ghost_nest", /atom/movable/screen/alert/ghost/xeno)
			to_chat(buckled_mob, SPAN_GHOSTALERT("You may now click on the ghost prompt on your screen to leave your body. You will be alerted when you're removed from the nest."))
			if(tgui_alert(buckled_mob, "You may now ghost and keep respawnability, you will be notified if you leave the nest, would you like to do so?", "Ghosting", list("Yes", "No")) != "Yes")
				return
			buckled_mob.ghostize()

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
