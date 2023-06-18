/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	density = TRUE
	anchored = TRUE
	idle_power_consumption = 300
	active_power_consumption = 300
	max_integrity = 200
	integrity_failure = 100
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 40, ACID = 20)
	var/obj/item/circuitboard/circuit = null //if circuit==null, computer can't disassembly
	var/icon_keyboard = "generic_key"
	var/icon_screen = "generic"
	var/light_range_on = 1
	var/light_power_on = 0.7
	/// Are we in the middle of a flicker event?
	var/flickering = FALSE
	/// Are we forcing the icon to be represented in a no-power state?
	var/force_no_power_icon_state = FALSE

/obj/machinery/computer/Initialize()
	. = ..()
	power_change()
	update_icon()

/obj/machinery/computer/process()
	if(stat & (NOPOWER|BROKEN))
		return FALSE
	return TRUE

/obj/machinery/computer/extinguish_light(force = FALSE)
	set_light(0)
	underlays.Cut()
	visible_message("<span class='danger'>[src] grows dim, its screen barely readable.</span>")

/*
 * Reimp, flash the screen on and off repeatedly.
 */
/obj/machinery/computer/flicker()
	if(flickering)
		return FALSE

	if(stat & (BROKEN|NOPOWER))
		return FALSE

	flickering = TRUE
	INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/machinery/computer, flicker_event))

	return TRUE

/*
 * Proc to be called by invoke_async in the above flicker() proc.
 */
/obj/machinery/computer/proc/flicker_event()
	var/amount = rand(5, 15)

	for(var/i in 1 to amount)
		force_no_power_icon_state = TRUE
		update_icon()
		sleep(rand(1, 3))

		force_no_power_icon_state = FALSE
		update_icon()
		sleep(rand(1, 10))
	update_icon()
	flickering = FALSE

/obj/machinery/computer/update_overlays()
	. = ..()
	underlays.Cut()
	if((stat & NOPOWER) || force_no_power_icon_state)
		if(icon_keyboard)
			. += "[icon_keyboard]_off"
		return

	// This whole block lets screens and keyboards ignore lighting and be visible even in the darkest room
	var/overlay_state = icon_screen
	if(stat & BROKEN)
		overlay_state = "[icon_state]_broken"
	. += "[overlay_state]"
	if(!(stat & BROKEN) && light)
		underlays += emissive_appearance(icon, "[icon_state]_lightmask")

	if(icon_keyboard)
		. += "[icon_keyboard]"
		underlays += emissive_appearance(icon, "[icon_keyboard]_lightmask")

/obj/machinery/computer/power_change()
	. = ..() //we don't check parent return due to this also being contigent on the BROKEN stat flag
	if((stat & (BROKEN|NOPOWER)))
		set_light(0)
	else
		set_light(light_range_on, light_power_on)
	if(.)
		update_icon()

/obj/machinery/computer/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(stat & BROKEN)
				playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
			else
				playsound(src.loc, 'sound/effects/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/machinery/computer/obj_break(damage_flag)
	if(circuit && !(flags & NODECONSTRUCT)) //no circuit, no breaking
		if(!(stat & BROKEN))
			playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)
			stat |= BROKEN
			update_icon()
			set_light(0)

/obj/machinery/computer/emp_act(severity)
	..()
	switch(severity)
		if(1)
			if(prob(50))
				obj_break(ENERGY)
		if(2)
			if(prob(10))
				obj_break(ENERGY)

/obj/machinery/computer/deconstruct(disassembled = TRUE, mob/user)
	on_deconstruction()
	if(!(flags & NODECONSTRUCT))
		if(circuit) //no circuit, no computer frame
			var/obj/structure/computerframe/A = new /obj/structure/computerframe(loc)
			var/obj/item/circuitboard/M = new circuit(A)
			A.name += " ([M.board_name])"
			A.setDir(dir)
			A.circuit = M
			A.anchored = TRUE
			if(stat & BROKEN)
				if(user)
					to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
				else
					playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
				new /obj/item/shard(drop_location())
				new /obj/item/shard(drop_location())
				A.state = 4
			else
				if(user)
					to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
				A.state = 5
			A.update_icon()
		for(var/obj/C in src)
			C.forceMove(loc)
	qdel(src)

/obj/machinery/computer/proc/set_broken()
	if(!(resistance_flags & INDESTRUCTIBLE))
		stat |= BROKEN
		update_icon()

/obj/machinery/computer/proc/decode(text)
	// Adds line breaks
	text = replacetext(text, "\n", "<BR>")
	return text

/obj/machinery/computer/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/computer/attack_hand(mob/user)
	/* Observers can view computers, but not actually use them via Topic*/
	if(isobserver(user))
		return FALSE
	return ..()

/obj/machinery/computer/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	if(circuit && !(flags & NODECONSTRUCT))
		if(I.use_tool(src, user, 20, volume = I.tool_volume))
			deconstruct(TRUE, user)

/obj/machinery/computer/hit_by_thrown_carbon(mob/living/carbon/human/C, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	if(!self_hurt && prob(50 * (damage / 15)))
		obj_break(MELEE)
		take_damage(damage, BRUTE)
		self_hurt = TRUE
	return ..()

