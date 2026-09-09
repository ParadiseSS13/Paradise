/obj/machinery/door/flock
	icon = 'icons/goonstation/mob/featherzone.dmi'
	name = "imposing wall"
	desc = "It sounds like it's hollow."
	max_integrity = 200
	armor = list(MELEE = -20, BULLET = -20, LASER = 80, ENERGY = 80, BOMB = 0, RAD = 100, FIRE = 80, ACID = 100)
	autoclose = TRUE
	auto_close_time = 5 SECONDS
	safe = FALSE

/obj/machinery/door/flock/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_FLOCK_EXAMINE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_FLOCK_THING, INNATE_TRAIT)
	AddComponent(/datum/component/flock_object)
	AddComponent(/datum/component/flock_protection, report_unarmed=FALSE)

/obj/machinery/door/flock/get_flock_id()
	return "Solid seal aperature"

/obj/machinery/door/flock/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return FALSE

/obj/machinery/door/flock/allowed(mob/M)
	return isflockmob(M)

/obj/machinery/door/flock/CanPathfindPass(to_dir, datum/can_pass_info/pass_info)
	var/atom/M = locateUID(pass_info.caller_uid)
	if(!M)
		return ..()
	if(isflockmob(M))
		return TRUE
	return ..()

/obj/machinery/door/flock/crush()
	for(var/turf/T in get_airlock_turfs())
		for(var/mob/living/L in T)
			if(isflockmob(L))
				continue
			L.visible_message(SPAN_WARNING("[src] closes on [L], crushing [L.p_them()]!"), SPAN_USERDANGER("[src] closes on you and crushes you!"))
			if(isalien(L))  // For xenos
				L.adjustBruteLoss(DOOR_CRUSH_DAMAGE * 1.5) // Xenos go into crit after aproximately the same amount of crushes as humans.
				L.emote("roar")
			else if(ishuman(L)) // For humans
				L.adjustBruteLoss(DOOR_CRUSH_DAMAGE)
				if(L.stat == CONSCIOUS)
					L.emote("scream")
				L.Weaken(10 SECONDS)
			else // for simple_animals & borgs
				L.adjustBruteLoss(DOOR_CRUSH_DAMAGE)
			L.add_splatter_floor(T)
		for(var/obj/mecha/M in T)
			M.take_damage(DOOR_CRUSH_DAMAGE)

/obj/machinery/door/flock/deconstruct(disassembled)
	. = ..()
	var/turf/T = get_turf(src)
	if(disassembled)
		new /obj/item/stack/sheet/gnesis(T, 2)
		return
	new /obj/item/stack/sheet/gnesis(T, 1)

/obj/machinery/door/flock/do_animate(animation)
	. = ..()
	if(animation == "deny")
		playsound(src, 'sound/goonstation/flockmind/flockdrone_door_deny.ogg', 50, TRUE, -2)

/obj/machinery/door/flock/try_flock_convert(datum/flock/flock, force)
	return

/obj/machinery/door/flock/examine(mob/user)
	if(!isflockmob(user))
		return ..()

	. = list(
		SPAN_FLOCKSAY("<b>###=- Ident confirmed, data packet received.</b>"),
		SPAN_FLOCKSAY("<b>ID:</b> [get_flock_id()]"),
		SPAN_FLOCKSAY("<b>System Integrity:</b> [get_integrity_percentage()]%"),
		SPAN_FLOCKSAY("<b>###=-</b>"),
	)

	if(stat & BROKEN)
		. += SPAN_FLOCKSAY("<b>FUNCTION CRITICALLY IMPAIRED, REPAIRS REQUIRED</>")
		. += SPAN_FLOCKSAY("<b>###=-</b>")
