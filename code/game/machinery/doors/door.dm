#define DOOR_OPEN_LAYER 2.7		//Under all objects if opened. 2.7 due to tables being at 2.6
#define DOOR_CLOSED_LAYER 3.1	//Above most items if closed

/obj/machinery/door
	name = "Door"
	desc = "It opens and closes."
	icon = 'icons/obj/doors/Doorint.dmi'
	icon_state = "door1"
	anchored = 1
	opacity = 1
	density = 1
	layer = DOOR_OPEN_LAYER
	var/open_layer = DOOR_OPEN_LAYER
	var/closed_layer = DOOR_CLOSED_LAYER

	var/visible = 1
	var/p_open = 0
	var/operating = 0
	var/autoclose = 0
	var/autoclose_timer
	var/glass = 0
	var/normalspeed = 1
	var/auto_close_time = 150
	var/auto_close_time_dangerous = 5
	var/heat_proof = 0 // For rglass-windowed airlocks and firedoors
	var/emergency = 0
	var/air_properties_vary_with_direction = 0
	var/block_air_zones = 1 //If set, air zones cannot merge across the door even when it is opened.

	//Multi-tile doors
	dir = EAST
	var/width = 1

/obj/machinery/door/New()
	. = ..()
	if(density)
		layer = closed_layer
	else
		layer = open_layer

	update_dir()
	update_freelook_sight()
	airlocks += src

/obj/machinery/door/setDir(newdir)
	..()
	update_dir()

/obj/machinery/door/proc/update_dir()
	if(width > 1)
		if(dir in list(EAST, WEST))
			bound_width = width * world.icon_size
			bound_height = world.icon_size
		else
			bound_width = world.icon_size
			bound_height = width * world.icon_size

/obj/machinery/door/initialize()
	air_update_turf(1)
	..()

/obj/machinery/door/Destroy()
	density = 0
	air_update_turf(1)
	update_freelook_sight()
	airlocks -= src
	if(autoclose_timer)
		deltimer(autoclose_timer)
		autoclose_timer = 0
	return ..()

/obj/machinery/door/Bumped(atom/AM)
	if(p_open || operating || emagged)
		return
	if(isliving(AM))
		var/mob/living/M = AM
		if(world.time - M.last_bumped <= 10) return	//Can bump-open one airlock per second. This is to prevent shock spam.
		M.last_bumped = world.time
		if(!M.restrained())
			if(M.mob_size > MOB_SIZE_SMALL)
				bumpopen(M)
			else if(ispet(M))
				var/mob/living/simple_animal/A = AM
				if(A.collar)
					bumpopen(M)
		return

	if(istype(AM, /obj/mecha))
		var/obj/mecha/mecha = AM
		if(density)
			if(mecha.occupant && (allowed(mecha.occupant) || check_access_list(mecha.operation_req_access) || emergency == 1))
				open()
			else
				do_animate("deny")
		return
	return


/obj/machinery/door/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density

/obj/machinery/door/CanAtmosPass()
	return !density

/obj/machinery/door/proc/bumpopen(mob/user)
	if(operating)
		return
	add_fingerprint(user)
	if(!requiresID())
		user = null

	if(density && !emagged)
		if(allowed(user) || emergency == 1)
			open()
			if(istype(user, /mob/living/simple_animal/bot))
				var/mob/living/simple_animal/bot/B = user
				B.door_opened(src)
		else
			do_animate("deny")
	return

/obj/machinery/door/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/door/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/door/attack_hand(mob/user)
	return attackby(user, user)

/obj/machinery/door/attack_tk(mob/user)
	if(requiresID() && !allowed(null))
		return
	..()

/obj/machinery/door/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/detective_scanner))
		return

	if(isrobot(user))
		return //borgs can't attack doors open because it conflicts with their AI-like interaction with them.

	add_fingerprint(user)
	if(operating || emagged)
		return
	if(density && (istype(I, /obj/item/weapon/card/emag) || istype(I, /obj/item/weapon/melee/energy/blade)))
		emag_act(user)
		return 1

	if(allowed(user) || emergency == 1 || user.can_advanced_admin_interact())
		if(density)
			open()
		else
			close()
		return

	if(density)
		do_animate("deny")

/obj/machinery/door/emag_act(mob/user)
	if(density)
		flick("door_spark", src)
		sleep(6)
		open()
		emagged = 1
		return 1

/obj/machinery/door/blob_act()
	if(prob(40))
		qdel(src)
	return


/obj/machinery/door/emp_act(severity)
	if(prob(20/severity) && (istype(src,/obj/machinery/door/airlock) || istype(src,/obj/machinery/door/window)) )
		spawn(0)
			open()
	..()


/obj/machinery/door/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(25))
				qdel(src)
		if(3.0)
			if(prob(80))
				var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
				s.set_up(2, 1, src)
				s.start()
	return


/obj/machinery/door/update_icon()
	if(density)
		icon_state = "door1"
	else
		icon_state = "door0"
	return

/obj/machinery/door/proc/do_animate(animation)
	switch(animation)
		if("opening")
			if(p_open)
				flick("o_doorc0", src)
			else
				flick("doorc0", src)
		if("closing")
			if(p_open)
				flick("o_doorc1", src)
			else
				flick("doorc1", src)
		if("deny")
			flick("door_deny", src)
	return

/obj/machinery/door/proc/open()
	if(!density)
		return 1
	if(operating)
		return
	if(!ticker)
		return 0
	operating = 1

	do_animate("opening")
	set_opacity(0)
	sleep(5)
	density = 0
	sleep(5)
	layer = open_layer
	update_icon()
	set_opacity(0)
	operating = 0
	air_update_turf(1)
	update_freelook_sight()

	// The `addtimer` system has the advantage of being cancelable
	if(autoclose)
		autoclose_timer = addtimer(src, "autoclose", normalspeed ? auto_close_time : auto_close_time_dangerous, unique = 1)

	return 1

/obj/machinery/door/proc/close()
	if(density)
		return 1
	if(operating)
		return
	operating = 1

	if(autoclose_timer)
		deltimer(autoclose_timer)
		autoclose_timer = 0

	do_animate("closing")
	layer = closed_layer
	sleep(5)
	density = 1
	sleep(5)
	update_icon()
	if(visible && !glass)
		set_opacity(1)	//caaaaarn!
	operating = 0
	air_update_turf(1)
	update_freelook_sight()
	return

/obj/machinery/door/proc/crush()
	for(var/mob/living/L in get_turf(src))
		if(isalien(L))  //For xenos
			L.adjustBruteLoss(DOOR_CRUSH_DAMAGE * 1.5) //Xenos go into crit after aproximately the same amount of crushes as humans.
			L.emote("roar")
		else if(ishuman(L)) //For humans
			L.adjustBruteLoss(DOOR_CRUSH_DAMAGE)
			if(L.stat == CONSCIOUS)
				L.emote("scream")
			L.Weaken(5)
		else //for simple_animals & borgs
			L.adjustBruteLoss(DOOR_CRUSH_DAMAGE)
		var/turf/location = get_turf(src)
		L.add_splatter_floor(location)


/obj/machinery/door/proc/requiresID()
	return 1

/obj/machinery/door/proc/autoclose()
	autoclose_timer = 0
	if(!qdeleted(src) && !density && !operating && autoclose)
		close()
	return

/obj/machinery/door/Move(new_loc, new_dir)
	var/turf/T = loc
	. = ..()
	move_update_air(T)

	if(width > 1)
		if(dir in list(EAST, WEST))
			bound_width = width * world.icon_size
			bound_height = world.icon_size
		else
			bound_width = world.icon_size
			bound_height = width * world.icon_size

/obj/machinery/door/proc/update_freelook_sight()
	// Glass door glass = 1
	// don't check then?
	if(!glass && cameranet)
		cameranet.updateVisibility(src, 0)

/obj/machinery/door/BlockSuperconductivity() // All non-glass airlocks block heat, this is intended.
	if(opacity || heat_proof)
		return 1
	return 0

/obj/machinery/door/morgue
	icon = 'icons/obj/doors/doormorgue.dmi'

/obj/machinery/door/proc/hostile_lockdown(mob/origin)
	if(!stat) //So that only powered doors are closed.
		close() //Close ALL the doors!

/obj/machinery/door/proc/disable_lockdown()
	if(!stat) //Opens only powered doors.
		open() //Open everything!
