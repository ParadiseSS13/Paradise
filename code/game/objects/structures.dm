/obj/structure
	icon = 'icons/obj/structures.dmi'
	pressure_resistance = 8
	max_integrity = 300
	face_while_pulling = TRUE
	var/climbable
	/// Determines if a structure adds the TRAIT_TURF_COVERED to its turf.
	var/creates_cover = FALSE
	var/mob/living/climber
	var/broken = FALSE

/obj/structure/New()
	..()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		if(SSticker && SSticker.current_state == GAME_STATE_PLAYING)
			QUEUE_SMOOTH(src)
			QUEUE_SMOOTH_NEIGHBORS(src)
		if(smoothing_flags & SMOOTH_CORNERS)
			icon_state = ""
	if(climbable)
		verbs += /obj/structure/proc/climb_on
	if(SSticker)
		GLOB.cameranet.updateVisibility(src)

/obj/structure/Initialize(mapload)
	if(!armor)
		armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 50)
	if(creates_cover && isturf(loc))
		ADD_TRAIT(loc, TRAIT_TURF_COVERED, UNIQUE_TRAIT_SOURCE(src))
	return ..()

/obj/structure/Destroy()
	if(SSticker)
		GLOB.cameranet.updateVisibility(src)
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		var/turf/T = get_turf(src)
		QUEUE_SMOOTH_NEIGHBORS(T)
	REMOVE_FROM_SMOOTH_QUEUE(src)
	if(creates_cover && isturf(loc))
		REMOVE_TRAIT(loc, TRAIT_TURF_COVERED, UNIQUE_TRAIT_SOURCE(src))
	return ..()

/obj/structure/Move()
	var/atom/old = loc
	if(!..())
		return FALSE

	if(creates_cover)
		if(isturf(old))
			REMOVE_TRAIT(old, TRAIT_TURF_COVERED, UNIQUE_TRAIT_SOURCE(src))
		if(isturf(loc))
			ADD_TRAIT(loc, TRAIT_TURF_COVERED, UNIQUE_TRAIT_SOURCE(src))
	return TRUE

/obj/structure/proc/climb_on()

	set name = "Climb structure"
	set desc = "Climbs onto a structure."
	set category = null
	set src in oview(1)

	do_climb(usr)

/obj/structure/MouseDrop_T(atom/movable/C, mob/user as mob)
	if(..())
		return TRUE
	if(C == user)
		INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/structure, do_climb), user)
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
		to_chat(user, "<span class='warning'>You cannot climb [src], as it is blocked by \a [blocking_object]!</span>")
		return FALSE

	var/turf/T = src.loc
	if(!T || !istype(T)) return FALSE

	climber = user
	if(HAS_TRAIT(climber, TRAIT_TABLE_LEAP))
		user.visible_message("<span class='warning'>[user] gets ready to vault up onto [src]!</span>")
		if(!do_after(user, 0.5 SECONDS, target = src))
			climber = null
			return FALSE
	else
		user.visible_message("<span class='warning'>[user] starts climbing onto [src]!</span>")
		if(!do_after(user, 5 SECONDS, target = src))
			climber = null
			return FALSE

	if(!can_touch(user) || !climbable)
		climber = null
		return FALSE

	var/old_loc = usr.loc
	user.loc = get_turf(src)
	user.Moved(old_loc, get_dir(old_loc, usr.loc), FALSE)
	if(get_turf(user) == get_turf(src))
		if(HAS_TRAIT(climber, TRAIT_TABLE_LEAP))
			user.visible_message("<span class='warning'>[user] leaps up onto [src]!</span>")
		else
			user.visible_message("<span class='warning'>[user] climbs onto [src]!</span>")

	climber = null
	return TRUE

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

			switch(pick(list("ankle","wrist","head","knee","elbow")))
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
	return

/obj/structure/proc/can_touch(mob/living/user)
	if(!istype(user))
		return 0
	if(!Adjacent(user))
		return 0
	if(user.restrained() || user.buckled)
		to_chat(user, "<span class='notice'>You need your hands and legs free for this.</span>")
		return 0
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return 0
	if(issilicon(user))
		to_chat(user, "<span class='notice'>You need hands for this.</span>")
		return 0
	return 1

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
