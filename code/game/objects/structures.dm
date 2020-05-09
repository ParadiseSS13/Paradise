/obj/structure
	icon = 'icons/obj/structures.dmi'
	pressure_resistance = 8
	max_integrity = 300
	var/climbable
	var/mob/climber
	var/broken = FALSE

/obj/structure/New()
	if (!armor)
		armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	..()
	if(smooth)
		if(SSticker && SSticker.current_state == GAME_STATE_PLAYING)
			queue_smooth(src)
			queue_smooth_neighbors(src)
		icon_state = ""
	if(climbable)
		verbs += /obj/structure/proc/climb_on
	if(SSticker)
		GLOB.cameranet.updateVisibility(src)

/obj/structure/Destroy()
	if(SSticker)
		GLOB.cameranet.updateVisibility(src)
	if(smooth)
		var/turf/T = get_turf(src)
		spawn(0)
			queue_smooth_neighbors(T)
	return ..()

/obj/structure/proc/climb_on()

	set name = "Climb structure"
	set desc = "Climbs onto a structure."
	set category = null
	set src in oview(1)

	do_climb(usr)

/obj/structure/MouseDrop_T(var/atom/movable/C, mob/user as mob)
	if(..())
		return
	if(C == user)
		do_climb(user)

/obj/structure/proc/density_check()
	for(var/obj/O in orange(0, src))
		if(O.density && !istype(O, /obj/machinery/door/window)) //Ignores windoors, as those already block climbing, otherwise a windoor on the opposite side of a table would prevent climbing.
			return O
	var/turf/T = get_turf(src)
	if(T.density)
		return T
	return null

/obj/structure/proc/do_climb(var/mob/living/user)
	if(!can_touch(user) || !climbable)
		return
	var/blocking_object = density_check()
	if(blocking_object)
		to_chat(user, "<span class='warning'>You cannot climb [src], as it is blocked by \a [blocking_object]!</span>")
		return

	var/turf/T = src.loc
	if(!T || !istype(T)) return

	usr.visible_message("<span class='warning'>[user] starts climbing onto \the [src]!</span>")
	climber = user
	if(!do_after(user, 50, target = src))
		climber = null
		return

	if(!can_touch(user) || !climbable)
		climber = null
		return

	usr.loc = get_turf(src)
	if(get_turf(user) == get_turf(src))
		usr.visible_message("<span class='warning'>[user] climbs onto \the [src]!</span>")

	climber = null

/obj/structure/proc/structure_shaken()

	for(var/mob/living/M in get_turf(src))

		if(M.lying) return //No spamming this on people.

		M.Weaken(5)
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

/obj/structure/proc/can_touch(var/mob/user)
	if(!user)
		return 0
	if(!Adjacent(user))
		return 0
	if(user.restrained() || user.buckled)
		to_chat(user, "<span class='notice'>You need your hands and legs free for this.</span>")
		return 0
	if(user.stat || user.paralysis || user.sleeping || user.lying || user.IsWeakened())
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
