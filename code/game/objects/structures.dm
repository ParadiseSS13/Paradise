/obj/structure
	icon = 'icons/obj/structures.dmi'
	pressure_resistance = 8
	max_integrity = 300
	face_while_pulling = TRUE
	flags_ricochet = RICOCHET_HARD
	receive_ricochet_chance_mod = 0.6
	var/climbable
	/// Determines if a structure adds the TRAIT_TURF_COVERED to its turf.
	var/creates_cover = FALSE
	var/list/mob/living/climbers = list()
	var/broken = FALSE
	/// How long this takes to unbuckle yourself from.
	var/unbuckle_time = 0 SECONDS

	new_attack_chain = TRUE

/obj/structure/New()
	..()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		if(SSticker && SSticker.current_state == GAME_STATE_PLAYING)
			QUEUE_SMOOTH(src)
			QUEUE_SMOOTH_NEIGHBORS(src)
		if(smoothing_flags & SMOOTH_CORNERS)
			icon_state = ""
	if(SSticker)
		GLOB.cameranet.update_visibility(src)

/obj/structure/Initialize(mapload)
	if(!armor)
		armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 50)
	if(creates_cover && isturf(loc))
		ADD_TRAIT(loc, TRAIT_TURF_COVERED, UNIQUE_TRAIT_SOURCE(src))
	return ..()

/obj/structure/Destroy()
	climbers = null
	if(SSticker)
		GLOB.cameranet.update_visibility(src)
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		var/turf/T = get_turf(src)
		QUEUE_SMOOTH_NEIGHBORS(T)
	REMOVE_FROM_SMOOTH_QUEUE(src)
	if(creates_cover && isturf(loc))
		REMOVE_TRAIT(loc, TRAIT_TURF_COVERED, UNIQUE_TRAIT_SOURCE(src))
	return ..()

/obj/structure/Move(atom/newloc, direct = 0, glide_size_override = 0, update_dir = TRUE)
	var/atom/old = loc
	if(!..())
		return FALSE

	if(creates_cover)
		if(isturf(old))
			REMOVE_TRAIT(old, TRAIT_TURF_COVERED, UNIQUE_TRAIT_SOURCE(src))
		if(isturf(loc))
			ADD_TRAIT(loc, TRAIT_TURF_COVERED, UNIQUE_TRAIT_SOURCE(src))
	return TRUE

/obj/structure/MouseDrop_T(atom/movable/C, mob/user as mob)
	if(..())
		return TRUE
	if(C == user)
		INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/structure, start_climb), user)
		return TRUE

/obj/structure/proc/density_check()
	for(var/obj/O in orange(0, src))
		if(O.density && !istype(O, /obj/machinery/door/window)) //Ignores windoors, as those already block climbing, otherwise a windoor on the opposite side of a table would prevent climbing.
			return O
	var/turf/T = get_turf(src)
	if(T.density)
		return T
	return null

/obj/structure/proc/do_climb(mob/living/user)
	if(!can_touch(user) || !climbable)
		return FALSE
	var/blocking_object = density_check()
	if(blocking_object)
		to_chat(user, "<span class='warning'>You cannot climb onto [src], as it is blocked by \a [blocking_object]!</span>")
		return FALSE

	if(!isturf(loc))
		return FALSE

	if(HAS_MIND_TRAIT(user, TRAIT_TABLE_LEAP))
		user.visible_message("<span class='warning'>[user] gets ready to vault up onto [src]!</span>")
		if(!do_after(user, 0.5 SECONDS, target = src))
			return FALSE
	else
		user.visible_message("<span class='warning'>[user] starts climbing onto [src]!</span>")
		if(!do_after(user, 5 SECONDS, target = src))
			return FALSE

	if(!can_touch(user) || !climbable)
		return FALSE

	return TRUE

/obj/structure/proc/start_climb(mob/living/user)
	climbers += user
	RegisterSignal(user, COMSIG_PARENT_QDELETING, PROC_REF(remove_climber)) // Just in case the climber is deleted before finishing
	if(do_climb(user))
		user.forceMove(get_turf(src))
		if(HAS_MIND_TRAIT(user, TRAIT_TABLE_LEAP))
			user.visible_message("<span class='warning'>[user] leaps up onto [src]!</span>")
		else
			user.visible_message("<span class='warning'>[user] climbs onto [src]!</span>")
	if(QDELETED(src)) // Table was destroyed while we were climbing it
		return
	climbers -= user
	UnregisterSignal(user, COMSIG_PARENT_QDELETING)
	return TRUE

/obj/structure/proc/remove_climber(mob/living/climber)
	SIGNAL_HANDLER // COMSIG_PARENT_QDELETING

	climbers -= climber
	UnregisterSignal(climber, COMSIG_PARENT_QDELETING)

/obj/structure/proc/structure_shaken()
	for(var/mob/living/M in get_turf(src))

		if(IS_HORIZONTAL(M))
			return //No spamming this on people.

		M.Weaken(10 SECONDS)
		to_chat(M, "<span class='warning'>You topple as \the [src] moves under you!</span>")

		if(prob(25))

			var/damage = rand(15,30)
			var/mob/living/carbon/human/H = M
			if(!istype(H))
				to_chat(H, "<span class='warning'>You land heavily!</span>")
				M.adjustBruteLoss(damage)
				return

			var/obj/item/organ/external/affecting

			switch(pick("ankle","wrist","head","knee","elbow"))
				if("ankle")
					affecting = H.get_organ(pick("l_foot", "r_foot"))
				if("knee")
					affecting = H.get_organ(pick("l_leg", "r_leg"))
				if("wrist")
					affecting = H.get_organ(pick("l_hand", "r_hand"))
				if("elbow")
					affecting = H.get_organ(pick("l_arm", "r_arm"))
				if("head")
					affecting = H.get_organ("head")

			if(affecting)
				to_chat(M, "<span class='warning'>You land heavily on your [affecting.name]!</span>")
				affecting.receive_damage(damage, 0)
				if(affecting.parent)
					affecting.parent.add_autopsy_data("Misadventure", damage)
			else
				to_chat(H, "<span class='warning'>You land heavily!</span>")
				H.adjustBruteLoss(damage)

			H.UpdateDamageIcon()

/obj/structure/proc/can_touch(mob/living/user)
	if(!istype(user))
		return FALSE
	if(!Adjacent(user))
		return FALSE
	if(user.restrained() || user.buckled)
		to_chat(user, "<span class='notice'>You need your hands and legs free for this.</span>")
		return FALSE
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return FALSE
	if(issilicon(user))
		to_chat(user, "<span class='notice'>You need hands for this.</span>")
		return FALSE
	return TRUE

/obj/structure/proc/get_climb_text()
	return "<span class='notice'>You can <b>Click-Drag</b> yourself to [src] to climb on top of it after a short delay.</span>"

/obj/structure/examine(mob/user)
	. = ..()
	if(!(resistance_flags & INDESTRUCTIBLE))
		if(resistance_flags & ON_FIRE)
			. += "<span class='warning'>It's on fire!</span>"
		if(broken)
			. += "<span class='notice'>It appears to be broken.</span>"
		var/examine_status = examine_status(user)
		if(examine_status)
			. += examine_status
	if(climbable)
		. += get_climb_text()

/obj/structure/proc/examine_status(mob/user) //An overridable proc, mostly for falsewalls.
	var/healthpercent = (obj_integrity/max_integrity) * 100
	switch(healthpercent)
		if(50 to 99)
			return  "It looks slightly damaged."
		if(25 to 50)
			return  "It appears heavily damaged."
		if(0 to 25)
			if(!broken)
				return  "<span class='warning'>It's falling apart!</span>"

/obj/structure/proc/prevents_buckled_mobs_attacking()
	return FALSE

/obj/structure/zap_act(power, zap_flags)
	if(zap_flags & ZAP_OBJ_DAMAGE)
		take_damage(power / 8000, BURN, ENERGY)
	power -= power / 2000 //walls take a lot out of ya
	. = ..()

/obj/structure/fall_and_crush(turf/target_turf, crush_damage, should_crit, crit_damage_factor, datum/tilt_crit/forced_crit, weaken_time, knockdown_time, ignore_gravity, should_rotate, angle, rightable, block_interactions)
	. = ..(target_turf, crush_damage, should_crit, crit_damage_factor, forced_crit, weaken_time, knockdown_time, ignore_gravity, should_rotate, angle, rightable = TRUE, block_interactions_until_righted = FALSE)
