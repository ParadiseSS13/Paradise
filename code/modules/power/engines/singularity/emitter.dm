#define EMITTER_NEEDS_WRENCH 0
#define EMITTER_NEEDS_WELDER 1
#define EMITTER_WELDED		 2

/obj/machinery/power/emitter
	name = "emitter"
	desc = "A heavy duty industrial laser."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter"
	anchored = FALSE
	density = TRUE
	req_access = list(ACCESS_ENGINE_EQUIP)

	idle_power_consumption = 10
	active_power_consumption = 300

	/// Is the emitter turned on
	var/active = FALSE
	/// Is the emitter powered
	var/powered = FALSE
	/// Delay between each emitter shot (In deciseconds)
	var/fire_delay = 100
	/// Maximum delay between each emitter shot
	var/maximum_fire_delay = 100
	/// Minimum delay between each emitter shot
	var/minimum_fire_delay = 20
	/// When was the last emitter shot
	var/last_shot = 0
	/// How many shots have been fired
	var/shot_number = 0
	/// Construction state
	var/state = EMITTER_NEEDS_WRENCH
	/// Locked by an ID card
	var/locked = FALSE

	var/projectile_type = /obj/projectile/beam/emitter/hitscan
	var/projectile_sound = 'sound/weapons/emitter.ogg'
	var/datum/effect_system/spark_spread/sparks

/obj/machinery/power/emitter/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/emitter(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	RefreshParts()
	if(state == EMITTER_WELDED && anchored)
		connect_to_network()
	sparks = new
	sparks.attach(src)
	sparks.set_up(5, 1, src)
	AddElement(/datum/element/hostile_machine)

/obj/machinery/power/emitter/cherenkov
	icon_state = "emitter_+a"
	anchored = TRUE
	state = EMITTER_WELDED

/obj/machinery/power/emitter/cherenkov/Initialize(mapload)
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/emitter(null)
	component_parts += new /obj/item/stock_parts/micro_laser/quadultra(null)
	component_parts += new /obj/item/stock_parts/manipulator/femto(null)
	RefreshParts()
	active = TRUE
	update_icon()

/obj/machinery/power/emitter/examine(mob/user)
	. = ..()
	if(panel_open)
		. += SPAN_NOTICE("The maintenance panel is open.")
	. += SPAN_NOTICE("<b>Alt-Click</b> to rotate [src].")

/obj/machinery/power/emitter/RefreshParts()
	var/max_firedelay = 120
	var/firedelay = 120
	var/min_firedelay = 24
	var/power_usage = 350
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		max_firedelay -= 20 * L.rating
		min_firedelay -= 4 * L.rating
		firedelay -= 20 * L.rating
	maximum_fire_delay = max_firedelay
	minimum_fire_delay = min_firedelay
	fire_delay = firedelay
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		power_usage -= 50 * M.rating
	active_power_consumption = power_usage

/obj/machinery/power/emitter/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(anchored)
		to_chat(user, SPAN_NOTICE("It is fastened to the floor!"))
		return
	dir = turn(dir, 90)

/obj/machinery/power/emitter/Destroy()
	msg_admin_attack("Emitter deleted at ([x],[y],[z] - [ADMIN_JMP(src)]) [usr ? "Broken by [key_name_admin(usr)]" : ""]", ATKLOG_FEW)
	log_game("Emitter deleted at ([x],[y],[z])")
	investigate_log("<font color='red'>deleted</font> at ([x],[y],[z]) [usr ? "Broken by [key_name(usr)]" : ""]",INVESTIGATE_SINGULO)
	QDEL_NULL(sparks)
	return ..()

/obj/machinery/power/emitter/update_icon_state()
	if(active && powernet && get_available_power())
		icon_state = "emitter_+a"
	else
		icon_state = "emitter"

/obj/machinery/power/emitter/emag_act(mob/living/user)
	if(!emagged)
		locked = FALSE
		emagged = TRUE
		if(user)
			user.visible_message(SPAN_WARNING("[user] shorts out the lock on [src]."),
				SPAN_WARNING("You short out the lock on [src]."))
		return TRUE

/obj/machinery/power/emitter/attack_hand(mob/user)
	add_fingerprint(user)
	if(state != EMITTER_WELDED)
		to_chat(user, SPAN_WARNING("[src] needs to be firmly secured to the floor first."))
		return TRUE
	if(!powernet)
		to_chat(user, SPAN_WARNING("The emitter isn't connected to a wire."))
		return TRUE
	if(panel_open)
		to_chat(user, SPAN_WARNING("The maintenance panel needs to be closed!"))
		return
	if(locked)
		to_chat(user, SPAN_WARNING("The controls are locked!"))
		return

	var/toggle
	if(active)
		active = FALSE
		toggle = "off"
		shot_number = 0
		fire_delay = maximum_fire_delay
		investigate_log("turned <font color='red'>off</font> by [key_name(user)]", INVESTIGATE_SINGULO)
	else
		active = TRUE
		toggle = "on"
		investigate_log("turned <font color='green'>on</font> by [key_name(user)]", INVESTIGATE_SINGULO)

	to_chat(user, "You turn [src] [toggle].")
	message_admins("Emitter turned [toggle] by [key_name_admin(user)] in ([x], [y], [z] - <A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
	log_game("Emitter turned [toggle] by [key_name(user)] in [x], [y], [z]")
	update_icon()

/obj/machinery/power/emitter/attack_animal(mob/living/simple_animal/M)
	if(ismegafauna(M) && anchored)
		state = EMITTER_NEEDS_WRENCH
		anchored = FALSE
		M.visible_message(SPAN_WARNING("[M] rips [src] free from its moorings!"))
	else
		..()
	if(!anchored)
		step(src, get_dir(M, src))

/obj/machinery/power/emitter/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/card/id) && !istype(used, /obj/item/pda))
		return ..()

	if(emagged)
		to_chat(user, SPAN_WARNING("The lock seems to be broken."))
		return ITEM_INTERACT_COMPLETE

	if(!allowed(user))
		to_chat(user, SPAN_WARNING("Access denied."))
		return ITEM_INTERACT_COMPLETE

	if(active)
		locked = !locked
		to_chat(user, SPAN_NOTICE("The controls are now [locked ? "locked" : "unlocked"]."))
	else
		locked = FALSE //just in case it somehow gets locked
		to_chat(user, SPAN_WARNING("The controls can only be locked when [src] is online!"))

	return ITEM_INTERACT_COMPLETE

/obj/machinery/power/emitter/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(active)
		to_chat(user, SPAN_WARNING("Turn off [src] first!"))
		return
	if(state == EMITTER_WELDED)
		to_chat(user, SPAN_WARNING("[src] needs to be unwelded from the floor!"))
		return

	if(state == EMITTER_NEEDS_WRENCH)
		for(var/obj/machinery/power/emitter/E in get_turf(src))
			if(E.anchored)
				to_chat(user, SPAN_WARNING("There is already an emitter here!"))
				return
		state = EMITTER_NEEDS_WELDER
		anchored = TRUE
		user.visible_message(SPAN_NOTICE("[user] secures [src] to the floor."),
			SPAN_NOTICE("You secure the external reinforcing bolts to the floor."),
			SPAN_NOTICE("You hear a ratchet."))
	else
		state = EMITTER_NEEDS_WRENCH
		anchored = FALSE
		user.visible_message(SPAN_NOTICE("[user] unsecures [src]'s reinforcing bolts from the floor."),
			SPAN_NOTICE("You undo the external reinforcing bolts."),
			SPAN_NOTICE("You hear a ratchet."))
	playsound(src, I.usesound, I.tool_volume, TRUE)

/obj/machinery/power/emitter/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(active)
		to_chat(user, SPAN_WARNING("[src] needs to be disabled first!"))
		return
	default_deconstruction_screwdriver(user, "emitter_open", "emitter", I)

/obj/machinery/power/emitter/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	default_deconstruction_crowbar(user, I)

/obj/machinery/power/emitter/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(active)
		to_chat(user, SPAN_NOTICE("Turn off [src] first."))
		return
	if(state == EMITTER_NEEDS_WRENCH)
		to_chat(user, SPAN_WARNING("[src] needs to be wrenched to the floor."))
		return
	if(!I.tool_use_check(user, 0))
		return

	if(state == EMITTER_NEEDS_WELDER)
		WELDER_ATTEMPT_FLOOR_WELD_MESSAGE
	else if(state == EMITTER_WELDED)
		WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE

	if(!I.use_tool(src, user, 20, volume = I.tool_volume))
		return

	if(state == EMITTER_NEEDS_WELDER)
		WELDER_FLOOR_WELD_SUCCESS_MESSAGE
		connect_to_network()
		state = EMITTER_WELDED
	else if(state == EMITTER_WELDED)
		WELDER_FLOOR_SLICE_SUCCESS_MESSAGE
		disconnect_from_network()
		state = EMITTER_NEEDS_WELDER

/obj/machinery/power/emitter/emp_act(severity)//Emitters are hardened but still might have issues
	return TRUE

/obj/machinery/power/emitter/process()
	if((stat & BROKEN) || !active)
		return
	if(state != EMITTER_WELDED || (!powernet && active_power_consumption))
		active = FALSE
		update_icon()
		return

	if(!active_power_consumption || get_surplus() >= active_power_consumption)
		consume_direct_power(active_power_consumption)
		if(!powered)
			powered = TRUE
			update_icon()
			investigate_log("regained power and turned <font color='green'>on</font>",INVESTIGATE_SINGULO)
	else
		if(powered)
			powered = FALSE
			update_icon()
			investigate_log("lost power and turned <font color='red'>off</font>",INVESTIGATE_SINGULO)
		return

	if(!check_delay())
		return FALSE
	fire_beam()

/obj/machinery/power/emitter/proc/check_delay()
	if((last_shot + fire_delay) <= world.time)
		return TRUE
	return FALSE

/obj/machinery/power/emitter/proc/fire_beam()
	var/obj/projectile/P = new projectile_type(get_turf(src))
	playsound(get_turf(src), projectile_sound, 50, TRUE)
	if(prob(35))
		sparks.start()
	switch(dir)
		if(NORTH)
			P.yo = 20
			P.xo = 0
		if(NORTHEAST)
			P.yo = 20
			P.xo = 20
		if(EAST)
			P.yo = 0
			P.xo = 20
		if(SOUTHEAST)
			P.yo = -20
			P.xo = 20
		if(WEST)
			P.yo = 0
			P.xo = -20
		if(SOUTHWEST)
			P.yo = -20
			P.xo = -20
		if(NORTHWEST)
			P.yo = 20
			P.xo = -20
		else // Any other
			P.yo = -20
			P.xo = 0

	last_shot = world.time
	if(shot_number < 3)
		fire_delay = 20
		shot_number++
	else
		fire_delay = rand(minimum_fire_delay, maximum_fire_delay)
		shot_number = 0

	P.setDir(dir)
	P.starting = loc
	P.Angle = null
	P.fire()
	return P

#undef EMITTER_NEEDS_WRENCH
#undef EMITTER_NEEDS_WELDER
#undef EMITTER_WELDED
