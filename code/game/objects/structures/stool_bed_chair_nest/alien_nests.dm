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
	if(!istype(M) || user.incapacitated() || M.buckled)
		return

	if(M != user && !HAS_TRAIT(M, TRAIT_HANDS_BLOCKED) && (!in_range(M, src) || !do_after(user, 1 SECONDS, target = M)))
		return FALSE

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
			buckled_mob.throw_alert("ghost_nest", /atom/movable/screen/alert/ghost/xeno)
			to_chat(buckled_mob, "<span class='ghostalert'>You may now click on the ghost prompt on your screen to leave your body. You will be alerted when you're removed from the nest.</span>")
			if(tgui_alert(buckled_mob, "You may now ghost and keep respawnability, you will be notified if you leave the nest, would you like to do so?", "Ghosting", list("Yes", "No")) != "Yes")
				return
			buckled_mob.ghostize(TRUE)

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

/obj/structure/bed/revival_nest
	name = "alien rejuvenation nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a flytrap. Heals damaged aliens and slowly revives the dead."
	icon = 'icons/mob/alien.dmi'
	icon_state = "placeholder_rejuv_nest"
	max_integrity = 30
	var/image/nest_overlay
	comfort = 0
	flags = NODECONSTRUCT
	var/processing_ticks = 0
	var/revive_timer

/obj/structure/bed/revival_nest/Initialize(mapload)
	. = ..()
	nest_overlay = image('icons/mob/alien.dmi', "nestoverlay", layer = MOB_LAYER - 0.2)

/obj/structure/bed/revival_nest/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	for(var/mob/living/M in buckled_mobs) //breaking a nest releases all the buckled mobs, because the nest isn't holding them down anymore
		if(user.get_int_organ(/obj/item/organ/internal/alien/hivenode))
			unbuckle_mob(M)
			add_fingerprint(user)

/obj/structure/bed/revival_nest/post_buckle_mob(mob/living/M)
	M.layer = BELOW_MOB_LAYER
	add_overlay(nest_overlay)

/obj/structure/bed/revival_nest/post_unbuckle_mob(mob/living/M)
	M.layer = initial(M.layer)
	cut_overlay(nest_overlay)
	STOP_PROCESSING(SSobj, src)
	deltimer(revive_timer)
	revive_timer = null

/obj/structure/bed/revival_nest/process()
	for(var/mob/living/buckled_mob in buckled_mobs)
		processing_ticks++
		if(!buckled_mob.get_int_organ(/obj/item/organ/internal/alien/hivenode))
			continue
		buckled_mob.adjustBruteLoss(-5)
		buckled_mob.adjustFireLoss(-5)
		buckled_mob.adjustToxLoss(-5)
		buckled_mob.adjustOxyLoss(-5)
		buckled_mob.adjustCloneLoss(-5)
		for(var/datum/disease/virus in buckled_mob.viruses)
			if(virus.stage < 1 && processing_ticks >= 4)
				virus.cure()
				processing_ticks = 0
			if(virus.stage > 1 && processing_ticks >= 4)
				virus.stage--
				processing_ticks = 0
		if(buckled_mob.stat == DEAD && !revive_timer && isalien(buckled_mob))
			revive_timer = addtimer(CALLBACK(src, PROC_REF(revive_dead_alien), buckled_mob), 40 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)

/obj/structure/bed/revival_nest/proc/revive_dead_alien(mob/living/carbon/alien/dead_alien)
	dead_alien.revive()
	dead_alien.visible_message("<span class='warning'>Vines seep into the back of [dead_alien], and it awakes with a burning rage!</span>")
	if(dead_alien.ghost_can_reenter())
		var/mob/dead/observer/dead_bro = dead_alien.grab_ghost()
		SEND_SOUND(dead_alien, sound('sound/voice/hiss5.ogg'))
		if(isalienqueen(dead_alien))
			for(var/mob/living/carbon/alien/humanoid/queen/living_queen in GLOB.alive_mob_list)
				if(living_queen.key || !living_queen.get_int_organ(/obj/item/organ/internal/brain))
					to_chat(dead_bro, "<span class='warning'>We already have an alive queen. We've been reverted to our drone form!</span>")
					qdel(dead_alien)
					var/mob/living/carbon/alien/humanoid/drone/new_drone = new(get_turf(src))
					new_drone.key = dead_bro.key
	else
		var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as [dead_alien]?", ROLE_ALIEN, FALSE, source = dead_alien)
		if(!length(candidates))
			return
		var/mob/C = pick(candidates)
		dead_alien.key = C.key
		dust_if_respawnable(C)
		dead_alien.mind.name = dead_alien.name
		dead_alien.mind.assigned_role = SPECIAL_ROLE_XENOMORPH
		dead_alien.mind.special_role = SPECIAL_ROLE_XENOMORPH
		SEND_SOUND(dead_alien, sound('sound/voice/hiss5.ogg'))

/obj/structure/bed/revival_nest/user_buckle_mob(mob/living/M, mob/living/user)
	if(!istype(M) || user.incapacitated() || M.buckled)
		return

	if(M != user && !HAS_TRAIT(M, TRAIT_HANDS_BLOCKED) && (!in_range(M, src) || !do_after(user, 1 SECONDS, target = M)))
		return FALSE

	if(!user.get_int_organ(/obj/item/organ/internal/alien/hivenode))
		to_chat(user, "<span class='noticealien'>Your lack of linkage to the hive prevents you from buckling [M] into [src].</span>")
		return

	if(has_buckled_mobs())
		unbuckle_all_mobs()

	if(!M.get_int_organ(/obj/item/organ/internal/alien/hivenode))
		to_chat(user, "<span class='noticealien'>[src] would be of no use to [M].</span>")
		return

	if(buckle_mob(M))
		M.visible_message("<span class='notice'>[user] secretes a thick vile goo, securing [M] into [src]!</span>",\
			"<span class='danger'>[user] drenches you in a foul-smelling resin, trapping you in [src]!</span>",\
			"<span class='italics'>You hear squelching...</span>")
		START_PROCESSING(SSobj, src)

/obj/structure/bed/revival_nest/attack_alien(mob/living/carbon/alien/user)
	if(user.a_intent != INTENT_HARM)
		return attack_hand(user)
	if(!do_after(user, 4 SECONDS, target = src) || QDELETED(src))
		return
	playsound(get_turf(user), pick('sound/effects/alien_resin_break2.ogg', 'sound/effects/alien_resin_break1.ogg'), 50, FALSE)
	qdel(src)
