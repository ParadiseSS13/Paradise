/obj/machinery/door
	name = "door"
	desc = "It opens and closes."
	icon = 'icons/obj/doors/doorint.dmi'
	icon_state = "door1"
	anchored = TRUE
	opacity = 1
	density = TRUE
	layer = OPEN_DOOR_LAYER
	power_channel = ENVIRON
	max_integrity = 350
	armor = list("melee" = 30, "bullet" = 30, "laser" = 20, "energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 70)
	flags = PREVENT_CLICK_UNDER
	damage_deflection = 10
	var/closingLayer = CLOSED_DOOR_LAYER
	var/visible = 1
	var/operating = FALSE
	var/autoclose = 0
	var/safe = TRUE //whether the door detects things and mobs in its way and reopen or crushes them.
	var/locked = FALSE //whether the door is bolted or not.
	var/glass = FALSE
	var/welded = FALSE
	var/normalspeed = 1
	var/auto_close_time = 150
	var/auto_close_time_dangerous = 15
	var/assemblytype //the type of door frame to drop during deconstruction
	var/datum/effect_system/spark_spread/spark_system
	var/real_explosion_block	//ignore this, just use explosion_block
	var/heat_proof = FALSE // For rglass-windowed airlocks and firedoors
	var/emergency = FALSE
	var/unres_sides = 0 //Unrestricted sides. A bitflag for which direction (if any) can open the door with no access
	//Multi-tile doors
	var/width = 1

/obj/machinery/door/New()
	..()
	set_init_door_layer()
	update_dir()
	update_freelook_sight()
	GLOB.airlocks += src
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(2, 1, src)

	//doors only block while dense though so we have to use the proc
	real_explosion_block = explosion_block
	explosion_block = EXPLOSION_BLOCK_PROC

/obj/machinery/door/proc/set_init_door_layer()
	if(density)
		layer = closingLayer
	else
		layer = initial(layer)

/obj/machinery/door/setDir(newdir)
	..()
	update_dir()

/obj/machinery/door/power_change()
	..()
	update_icon()

/obj/machinery/door/proc/update_dir()
	if(width > 1)
		if(dir in list(EAST, WEST))
			bound_width = width * world.icon_size
			bound_height = world.icon_size
		else
			bound_width = world.icon_size
			bound_height = width * world.icon_size

/obj/machinery/door/Initialize()
	air_update_turf(1)
	..()

/obj/machinery/door/Destroy()
	density = 0
	air_update_turf(1)
	update_freelook_sight()
	GLOB.airlocks -= src
	QDEL_NULL(spark_system)
	return ..()

/obj/machinery/door/Bumped(atom/AM)
	if(operating || emagged)
		return
	if(ismob(AM))
		var/mob/B = AM
		if((isrobot(B)) && B.stat)
			return
		if(isliving(AM))
			var/mob/living/M = AM
			if(world.time - M.last_bumped <= 10)
				return	//Can bump-open one airlock per second. This is to prevent shock spam.
			M.last_bumped = world.time
			if(M.restrained() && !check_access(null))
				return
			if(M.mob_size > MOB_SIZE_TINY)
				bumpopen(M)
			return

	if(ismecha(AM))
		var/obj/mecha/mecha = AM
		if(density)
			if(mecha.occupant)
				if(world.time - mecha.occupant.last_bumped <= 10)
					return
			if(mecha.occupant && allowed(mecha.occupant) || check_access_list(mecha.operation_req_access))
				open()
			else
				do_animate("deny")
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

	if(density && !emagged)
		if(allowed(user))
			open()
			if(isbot(user))
				var/mob/living/simple_animal/bot/B = user
				B.door_opened(src)
		else
			do_animate("deny")

/obj/machinery/door/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/door/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/door/attack_hand(mob/user)
	return try_to_activate_door(user)

/obj/machinery/door/attack_tk(mob/user)
	if(!allowed(null))
		return
	..()

/obj/machinery/door/proc/try_to_activate_door(mob/user)
	add_fingerprint(user)
	if(operating || emagged)
		return
	if(requiresID() && (allowed(user) || user.can_advanced_admin_interact()))
		if(density)
			open()
		else
			close()
		return
	if(density)
		do_animate("deny")

/obj/machinery/door/allowed(mob/M)
	if(emergency)
		return TRUE
	if(unrestricted_side(M))
		return TRUE
	if(!requiresID())
		return FALSE // Intentional. machinery/door/requiresID() always == 1. airlocks, however, == 0 if ID scan is disabled. Yes, this var is poorly named.
	return ..()

/obj/machinery/door/proc/unrestricted_side(mob/M) //Allows for specific side of airlocks to be unrestrected (IE, can exit maint freely, but need access to enter)
	return get_dir(src, M) & unres_sides

/obj/machinery/door/proc/try_to_crowbar(mob/user, obj/item/I)
	return

/obj/machinery/door/attackby(obj/item/I, mob/user, params)
	if(user.a_intent != INTENT_HARM && istype(I, /obj/item/twohanded/fireaxe))
		try_to_crowbar(user, I)
		return 1
	else if(!(I.flags & NOBLUDGEON) && user.a_intent != INTENT_HARM)
		try_to_activate_door(user)
		return 1
	return ..()


/obj/machinery/door/crowbar_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return
	. = TRUE
	if(operating)
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	try_to_crowbar(user, I)

/obj/machinery/door/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(. && obj_integrity > 0)
		if(damage_amount >= 10 && prob(30))
			spark_system.start()

/obj/machinery/door/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(glass)
				playsound(loc, 'sound/effects/glasshit.ogg', 90, TRUE)
			else if(damage_amount)
				playsound(loc, 'sound/weapons/smash.ogg', 50, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/machinery/door/emag_act(mob/user)
	if(density)
		flick("door_spark", src)
		sleep(6)
		open()
		emagged = 1
		return 1

/obj/machinery/door/emp_act(severity)
	if(prob(20/severity) && (istype(src,/obj/machinery/door/airlock) || istype(src,/obj/machinery/door/window)) )
		spawn(0)
			open()
	..()

/obj/machinery/door/update_icon()
	if(density)
		icon_state = "door1"
	else
		icon_state = "door0"

/obj/machinery/door/proc/do_animate(animation)
	switch(animation)
		if("opening")
			if(panel_open)
				flick("o_doorc0", src)
			else
				flick("doorc0", src)
		if("closing")
			if(panel_open)
				flick("o_doorc1", src)
			else
				flick("doorc1", src)
		if("deny")
			if(!stat)
				flick("door_deny", src)

/obj/machinery/door/proc/open()
	if(!density)
		return TRUE
	if(operating)
		return
	operating = TRUE
	do_animate("opening")
	set_opacity(0)
	sleep(5)
	density = FALSE
	sleep(5)
	layer = initial(layer)
	update_icon()
	set_opacity(0)
	operating = FALSE
	air_update_turf(1)
	update_freelook_sight()
	if(autoclose)
		autoclose_in(normalspeed ? auto_close_time : auto_close_time_dangerous)
	return TRUE

/obj/machinery/door/proc/close()
	if(density)
		return TRUE
	if(operating || welded)
		return
	if(safe)
		for(var/turf/turf in locs)
			for(var/atom/movable/M in turf)
				if(M.density && M != src) //something is blocking the door
					if(autoclose)
						autoclose_in(60)
					return

	operating = TRUE

	do_animate("closing")
	layer = closingLayer
	sleep(5)
	density = TRUE
	sleep(5)
	update_icon()
	if(visible && !glass)
		set_opacity(1)
	operating = 0
	air_update_turf(1)
	update_freelook_sight()
	if(safe)
		CheckForMobs()
	else
		crush()
	return TRUE

/obj/machinery/door/proc/CheckForMobs()
	if(locate(/mob/living) in get_turf(src))
		sleep(1)
		open()

/obj/machinery/door/proc/crush()
	for(var/mob/living/L in get_turf(src))
		L.visible_message("<span class='warning'>[src] closes on [L], crushing [L.p_them()]!</span>", "<span class='userdanger'>[src] closes on you and crushes you!</span>")
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
	for(var/obj/mecha/M in get_turf(src))
		M.take_damage(DOOR_CRUSH_DAMAGE)

/obj/machinery/door/proc/requiresID()
	return 1

/obj/machinery/door/proc/hasPower()
	return !(stat & NOPOWER)

/obj/machinery/door/proc/autoclose()
	if(!QDELETED(src) && !density && !operating && !locked && !welded && autoclose)
		close()

/obj/machinery/door/proc/autoclose_in(wait)
	addtimer(CALLBACK(src, .proc/autoclose), wait, TIMER_UNIQUE | TIMER_NO_HASH_WAIT | TIMER_OVERRIDE)

/obj/machinery/door/proc/update_freelook_sight()
	if(!glass && cameranet)
		cameranet.updateVisibility(src, 0)

/obj/machinery/door/BlockSuperconductivity() // All non-glass airlocks block heat, this is intended.
	if(opacity || heat_proof)
		return 1
	return 0

/obj/machinery/door/morgue
	icon = 'icons/obj/doors/doormorgue.dmi'

/obj/machinery/door/proc/lock()
	return

/obj/machinery/door/proc/unlock()
	return

/obj/machinery/door/proc/hostile_lockdown(mob/origin)
	if(!stat) //So that only powered doors are closed.
		close() //Close ALL the doors!

/obj/machinery/door/proc/disable_lockdown()
	if(!stat) //Opens only powered doors.
		open() //Open everything!

/obj/machinery/door/ex_act(severity)
	//if it blows up a wall it should blow up a door
	..(severity ? max(1, severity - 1) : 0)


/obj/machinery/door/GetExplosionBlock()
	return density ? real_explosion_block : 0
