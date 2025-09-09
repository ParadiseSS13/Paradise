/obj/machinery/door
	name = "door"
	desc = "It opens and closes."
	icon = 'icons/obj/doors/doorint.dmi'
	icon_state = null
	anchored = TRUE
	opacity = TRUE
	density = TRUE
	layer = OPEN_DOOR_LAYER
	power_channel = PW_CHANNEL_ENVIRONMENT
	max_integrity = 350
	armor = list(MELEE = 30, BULLET = 30, LASER = 20, ENERGY = 20, BOMB = 10, RAD = 100, FIRE = 80, ACID = 70)
	flags = PREVENT_CLICK_UNDER
	damage_deflection = 10
	var/closingLayer = CLOSED_DOOR_LAYER
	var/visible = TRUE
	/// Is it currently in the process of opening, closing or being tampered
	var/operating = NONE
	var/autoclose = FALSE
	/// Whether the door detects things and mobs in its way and reopen or crushes them.
	var/safe = TRUE
	// Whether the door is bolted or not.
	var/locked = FALSE
	var/glass = FALSE
	var/reinforced_glass = FALSE
	var/welded = FALSE
	var/normalspeed = TRUE
	var/auto_close_time = 150
	var/auto_close_time_dangerous = 15
	/// The type of door frame to drop during deconstruction
	var/assemblytype
	var/datum/effect_system/spark_spread/spark_system
	var/real_explosion_block	//ignore this, just use explosion_block
	var/heat_proof = FALSE // For rglass-windowed airlocks and firedoors
	var/emergency = FALSE
	/// Unrestricted sides. A bitflag for which direction (if any) can open the door with no access.
	var/unres_sides = 0
	//Multi-tile doors
	var/width = 1
	/// List. Player view blocking fillers for multi-tile doors.
	var/list/fillers
	//Whether nonstandard door sounds (cmag laughter) are off cooldown.
	var/sound_ready = TRUE
	var/sound_cooldown = 1 SECONDS

	/// ID for the window tint button, or another external control
	var/id
	var/polarized_glass = FALSE
	var/polarized_on

	/// How many levels of foam do we have on us? Capped at 5
	var/foam_level = 0

	/// How much this door reduces superconductivity to when closed.
	var/superconductivity = DOOR_HEAT_TRANSFER_COEFFICIENT
	/// So explosion doesn't deal extra damage for multitile airlocks
	COOLDOWN_DECLARE(explosion_cooldown)


/obj/machinery/door/Initialize(mapload)
	. = ..()
	set_init_door_layer()
	update_bounds()
	update_freelook_sight()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(2, 1, src)
	// Yes I know this isnt an airlock but its required because of the dumb reason of
	// pod doors and shutters similar using this list as well
	GLOB.airlocks += src

	//doors only block while dense though so we have to use the proc
	real_explosion_block = explosion_block
	explosion_block = EXPLOSION_BLOCK_PROC

	update_icon()
	recalculate_atmos_connectivity()

/obj/machinery/door/proc/set_init_door_layer()
	if(density)
		layer = closingLayer
	else
		layer = initial(layer)

/obj/machinery/door/setDir(newdir)
	..()
	update_bounds()

/obj/machinery/door/power_change()
	if(!..())
		return
	update_icon()

/// We don't wanna end up getting ex_act() multiple times because we are located at multiple tiles
/obj/machinery/door/ex_act()
	if(width > 1)
		if(!COOLDOWN_FINISHED(src, explosion_cooldown))
			return
		COOLDOWN_START(src, explosion_cooldown, 1 SECONDS)
	return ..()

/obj/machinery/door/Destroy()
	density = FALSE
	recalculate_atmos_connectivity()
	update_freelook_sight()
	GLOB.airlocks -= src
	QDEL_NULL(spark_system)
	return ..()

/obj/machinery/door/Bumped(atom/AM)
	. = ..()
	if(operating || emagged || foam_level)
		return
	if(ismob(AM))
		var/mob/B = AM
		if((isrobot(B)) && B.stat)
			return
		if(isliving(AM))
			var/mob/living/M = AM
			if(M.restrained() && !check_access(null))
				return
			if(M.mob_size > MOB_SIZE_TINY)
				bumpopen(M)
			return

	if(ismecha(AM))
		var/obj/mecha/mecha = AM
		if(density)
			if(mecha.occupant && allowed(mecha.occupant) || check_access_list(mecha.operation_req_access))
				if(HAS_TRAIT(src, TRAIT_CMAGGED))
					cmag_switch(FALSE, mecha.occupant)
					return
				open()
			else
				if(HAS_TRAIT(src, TRAIT_CMAGGED))
					cmag_switch(TRUE, mecha.occupant)
					return
				do_animate("deny")
		return

/obj/machinery/door/Move(new_loc, new_dir)
	var/turf/T = loc
	. = ..()
	move_update_air(T)

	update_bounds()

/obj/machinery/door/CanPass(atom/movable/mover, border_dir)
	if(istype(mover))
		if(mover.checkpass(PASSDOOR) && !locked)
			return TRUE
		if(mover.checkpass(PASSGLASS))
			return !opacity
	return !density

/obj/machinery/door/CanAtmosPass(direction)
	return operating || !density

/obj/machinery/door/get_superconductivity(direction)
	if(!density)
		return ..()
	if(heat_proof)
		return ZERO_HEAT_TRANSFER_COEFFICIENT
	return superconductivity

/obj/machinery/door/proc/bumpopen(mob/user)
	if(operating)
		return
	add_fingerprint(user)

	if(foam_level)
		return

	if(density && !emagged)
		if(allowed(user))
			if(HAS_TRAIT(src, TRAIT_CMAGGED))
				cmag_switch(FALSE, user)
				return
			open()
			if(isbot(user))
				var/mob/living/simple_animal/bot/B = user
				B.door_opened(src)
		else
			if(pry_open_check(user))
				return
			if(HAS_TRAIT(src, TRAIT_CMAGGED))
				cmag_switch(TRUE, user)
				return
			do_animate("deny")

/obj/machinery/door/proc/pry_open_check(mob/user)
	. = TRUE
	if(isterrorspider(user))
		return

	if(foam_level)
		return

	if(!HAS_TRAIT(user, TRAIT_FORCE_DOORS))
		return FALSE

	var/datum/antagonist/vampire/V = user.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(V && HAS_TRAIT_FROM(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT))
		if(!V.bloodusable)
			REMOVE_TRAIT(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT)
			return FALSE
	if(welded)
		to_chat(user, "<span class='warning'>The door is welded.</span>")
		return FALSE
	if(locked)
		to_chat(user, "<span class='warning'>The door is bolted.</span>")
		return FALSE
	if(density)
		visible_message("<span class='danger'>[user] forces the door open!</span>")
		playsound(loc, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		open(TRUE)
	if(V && HAS_TRAIT_FROM(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT))
		V.bloodusable = max(V.bloodusable - 5, 0)

/obj/machinery/door/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/door/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/door/attack_hand(mob/user)
	. = ..()
	return try_to_activate_door(user)

/obj/machinery/door/attack_tk(mob/user)
	if(!allowed(null))
		return
	..()

/obj/machinery/door/proc/try_to_activate_door(mob/user)
	add_fingerprint(user)
	if(operating || emagged || foam_level)
		return
	if(requiresID() && (allowed(user) || user.can_advanced_admin_interact()))
		if(density)
			if(HAS_TRAIT(src, TRAIT_CMAGGED) && !user.can_advanced_admin_interact()) //cmag should not prevent admin intervention
				cmag_switch(FALSE, user)
				return
			open()
		else
			if(HAS_TRAIT(src, TRAIT_CMAGGED) && !user.can_advanced_admin_interact())
				return
			close()
		return TRUE
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		cmag_switch(TRUE, user)
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

/obj/machinery/door/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(HAS_TRAIT(src, TRAIT_CMAGGED) && used.can_clean()) //If the cmagged door is being hit with cleaning supplies, don't open it, it's being cleaned!
		return ITEM_INTERACT_SKIP_TO_AFTER_ATTACK

	else if(!(used.flags & NOBLUDGEON) && user.a_intent != INTENT_HARM)
		try_to_activate_door(user)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/door/crowbar_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return
	. = TRUE
	if(operating)
		return
	if(!I.use_tool(src, user, 0, volume = 0))
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
		emagged = TRUE
		return TRUE

/obj/machinery/door/cmag_act(mob/user)
	if(!density)
		return FALSE
	flick("door_spark", src)
	sleep(6) //The cmag doesn't automatically open doors. It inverts access, not provides it!
	ADD_TRAIT(src, TRAIT_CMAGGED, CLOWN_EMAG)
	return TRUE

//Proc for inverting access on cmagged doors."canopen" should always return the OPPOSITE of the normal result.
/obj/machinery/door/proc/cmag_switch(canopen, mob/living/user)
	if(!canopen || locked || !hasPower())
		if(density) //Windoors can still do their deny animation in unpowered environments, this bugs out if density isn't checked for
			do_animate("deny")
		if(hasPower() && sound_ready)
			playsound(loc, 'sound/machines/honkbot_evil_laugh.ogg', 25, TRUE, ignore_walls = FALSE)
			soundcooldown()
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/card/id/idcard = H.get_idcard()
		if(!idcard?.assignment) //Humans can't game inverted access by taking their ID off or using spare IDs.
			if(!density)
				return
			do_animate("deny")
			to_chat(H, "<span class='warning'>The airlock speaker chuckles: 'What's wrong, pal? Lost your ID? Nyuk nyuk nyuk!'</span>")
			if(sound_ready)
				playsound(loc, 'sound/machines/honkbot_evil_laugh.ogg', 25, TRUE, ignore_walls = FALSE)
				soundcooldown() //Thanks, mechs
			return
	if(density)
		open()
	else
		close()

/obj/machinery/door/proc/soundcooldown()
	if(!sound_ready)
		return
	sound_ready = FALSE
	addtimer(VARSET_CALLBACK(src, sound_ready, TRUE), sound_cooldown)

/obj/machinery/door/proc/toggle_polarization()
	return

/obj/machinery/door/update_icon_state()
	icon_state = "door[density]"

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
			if(stat == CONSCIOUS)
				flick("door_deny", src)

/obj/machinery/door/proc/open()
	if(!density)
		return TRUE
	if(operating)
		return
	SEND_SIGNAL(src, COMSIG_DOOR_OPEN)
	operating = DOOR_OPENING
	recalculate_atmos_connectivity()
	do_animate("opening")
	set_opacity(FALSE)
	if(width > 1)
		set_fillers_opacity(0)
	sleep(5)
	density = FALSE
	if(width > 1)
		set_fillers_density(FALSE)
	sleep(5)
	layer = initial(layer)
	update_icon()
	set_opacity(FALSE)
	if(width > 1)
		set_fillers_opacity(0)
	operating = NONE
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

	SEND_SIGNAL(src, COMSIG_DOOR_CLOSE)
	operating = DOOR_CLOSING

	do_animate("closing")
	layer = closingLayer
	sleep(5)
	density = TRUE
	if(width > 1)
		set_fillers_density(TRUE)
	sleep(5)
	update_icon()
	if(!glass || polarized_on)
		set_opacity(TRUE)
		if(width > 1)
			set_fillers_opacity(TRUE)
	operating = NONE
	recalculate_atmos_connectivity()
	update_freelook_sight()
	if(safe)
		check_for_mobs()
	else
		crush()
	return TRUE

/obj/machinery/door/proc/get_airlock_turfs()
	var/list/airlock_turfs = list(get_turf(src))
	if(width > 1)
		for(var/i in 1 to width - 1)
			airlock_turfs |= get_step(airlock_turfs[i], turn(dir, 90))
	return airlock_turfs

/obj/machinery/door/proc/check_for_mobs()
	for(var/turf/T in get_airlock_turfs())
		if(locate(/mob/living) in T)
			sleep(1)
			open()
			break

/obj/machinery/door/proc/crush()
	for(var/turf/T in get_airlock_turfs())
		for(var/mob/living/L in T)
			L.visible_message("<span class='warning'>[src] closes on [L], crushing [L.p_them()]!</span>", "<span class='userdanger'>[src] closes on you and crushes you!</span>")
			if(isalien(L))  //For xenos
				L.adjustBruteLoss(DOOR_CRUSH_DAMAGE * 1.5) //Xenos go into crit after aproximately the same amount of crushes as humans.
				L.emote("roar")
			else if(ishuman(L)) //For humans
				L.adjustBruteLoss(DOOR_CRUSH_DAMAGE)
				if(L.stat == CONSCIOUS)
					L.emote("scream")
				L.Weaken(10 SECONDS)
			else //for simple_animals & borgs
				L.adjustBruteLoss(DOOR_CRUSH_DAMAGE)
			L.add_splatter_floor(T)
		for(var/obj/mecha/M in T)
			M.take_damage(DOOR_CRUSH_DAMAGE)

/obj/machinery/door/proc/requiresID()
	return 1

/obj/machinery/door/proc/hasPower()
	return !(stat & NOPOWER)

/obj/machinery/door/proc/autoclose()
	if(!QDELETED(src) && !density && !operating && !locked && !welded && autoclose)
		close()

/obj/machinery/door/proc/autoclose_in(wait)
	addtimer(CALLBACK(src, PROC_REF(autoclose)), wait, TIMER_UNIQUE | TIMER_NO_HASH_WAIT | TIMER_OVERRIDE)

/obj/machinery/door/proc/update_freelook_sight()
	if(!glass && GLOB.cameranet)
		GLOB.cameranet.update_visibility(src, 0)

/obj/machinery/door/proc/check_unres() //unrestricted sides. This overlay indicates which directions the player can access even without an ID
	if(hasPower() && unres_sides)
		. = list()
		set_light(l_range = 1, l_power = 1, l_color = "#00FF00")
		if(unres_sides & NORTH)
			var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_n") //layer=src.layer+1
			I.pixel_y = 32
			. += I
		if(unres_sides & SOUTH)
			var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_s") //layer=src.layer+1
			I.pixel_y = -32
			. += I
		if(unres_sides & EAST)
			var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_e") //layer=src.layer+1
			I.pixel_x = 32
			. += I
		if(unres_sides & WEST)
			var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_w") //layer=src.layer+1
			I.pixel_x = -32
			. += I

/obj/machinery/door/morgue
	icon = 'icons/obj/doors/doormorgue.dmi'
	icon_state = "door1"

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

/obj/machinery/door/GetExplosionBlock()
	return density ? real_explosion_block : 0

/obj/machinery/door/zap_act(power, zap_flags)
	zap_flags &= ~ZAP_OBJ_DAMAGE
	. = ..()

/obj/machinery/door/CanPathfindPass(to_dir, datum/can_pass_info/pass_info)
	if(!locateUID(pass_info.caller_uid))
		return ..()
	if(pass_info.pass_flags & PASSDOOR && !locked)
		return TRUE
	if(pass_info.pass_flags & PASSGLASS)
		return !opacity
	return ..()

/**
 * Checks which way the airlock is facing and adjusts the direction accordingly.
 * For use with multi-tile airlocks.
 */

/**
 * Sets the bounds of the airlock. For use with multi-tile airlocks.
 * If the airlock is multi-tile, it will set the bounds to be the size of the airlock.
 * If the airlock doesn't already have fillers, it will create them.
 * If the airlock already has fillers, it will move them to the correct location.
 */
/obj/machinery/door/proc/update_bounds()
	if(width <= 1)
		return

	QDEL_LIST_CONTENTS(fillers)

	if(dir in list(SOUTH, NORTH))
		bound_width = width * world.icon_size
		bound_height = world.icon_size
		bound_y = 0
		pixel_y = 0
		if(dir == NORTH)
			bound_x = -(width - 1) * world.icon_size
			pixel_x = -(width - 1) * world.icon_size
		else
			bound_x = 0
			pixel_x = 0

	else
		bound_width = world.icon_size
		bound_height = width * world.icon_size
		bound_x = 0
		pixel_x = 0
		if(dir == WEST)
			bound_y = -(width - 1) * world.icon_size
			pixel_y = -(width - 1) * world.icon_size
		else
			bound_y = 0
			pixel_y = 0

	LAZYINITLIST(fillers)

	var/obj/last_filler = src
	for(var/i in 1 to width - 1)
		var/obj/airlock_filler_object/filler

		filler = new(src)
		filler.pair_airlock(src)
		filler.loc = get_step(last_filler, turn(dir, 90))
		filler.density = density
		filler.set_opacity(opacity)

		fillers += filler
		last_filler = filler

/obj/machinery/door/proc/set_fillers_density(density)
	if(!length(fillers))
		return

	for(var/obj/airlock_filler_object/filler as anything in fillers)
		filler.density = density

/obj/machinery/door/proc/set_fillers_opacity(opacity)
	if(!length(fillers))
		return

	for(var/obj/airlock_filler_object/filler as anything in fillers)
		filler.set_opacity(opacity)

#define MAX_FOAM_LEVEL 5
// Adds foam to the airlock, which will block it from being opened
/obj/machinery/door/proc/foam_up()
	if(!foam_level)
		new /obj/structure/barricade/foam(get_turf(src))
		foam_level++
		return

	if(foam_level == MAX_FOAM_LEVEL)
		return

	for(var/obj/structure/barricade/foam/blockage in loc.contents)
		blockage.foam_level = min(++blockage.foam_level, 5)
		// The last level will increase the integrity by 50 instead of 25
		if(foam_level == 4)
			blockage.obj_integrity += 50
			blockage.max_integrity += 50
		else
			blockage.obj_integrity += 25
			blockage.max_integrity += 25
		foam_level++
		blockage.icon_state = "foamed_[foam_level]"
		blockage.update_icon(UPDATE_ICON_STATE)

#undef MAX_FOAM_LEVEL
