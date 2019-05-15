/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	density = 1
	anchored = 1.0
	use_power = IDLE_POWER_USE
	idle_power_usage = 300
	active_power_usage = 300
	obj_integrity = 200
	max_integrity = 200
	integrity_failure = 100
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 40, acid = 20)
	var/obj/item/circuitboard/circuit = null //if circuit==null, computer can't disassembly
	var/processing = 0
	var/icon_keyboard = "generic_key"
	var/icon_screen = "generic"
	var/light_range_on = 2
	var/light_power_on = 1
	var/overlay_layer
	var/state = null

/obj/machinery/computer/New()
	overlay_layer = layer
	..()

/obj/machinery/computer/Initialize()
	..()
	power_change()
	update_icon()

/obj/machinery/computer/process()
	if(stat & (NOPOWER|BROKEN))
		return 0
	return 1

/obj/machinery/computer/extinguish_light()
	set_light(0)
	visible_message("<span class='danger'>[src] grows dim, its screen barely readable.</span>")

/obj/machinery/computer/update_icon()
	overlays.Cut()
	if(stat & NOPOWER)
		if(icon_keyboard)
			overlays += image(icon,"[icon_keyboard]_off",overlay_layer)
		return

	if(stat & BROKEN)
		overlays += image(icon,"[icon_state]_broken",overlay_layer)
	else
		overlays += image(icon,icon_screen,overlay_layer)

	if(icon_keyboard)
		overlays += image(icon, icon_keyboard ,overlay_layer)


/obj/machinery/computer/power_change()
	..()
	update_icon()
	if((stat & (BROKEN|NOPOWER)))
		set_light(0)
	else
		set_light(light_range_on, light_power_on)

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
	if(istype(user, /mob/dead/observer)) return 0
	return ..()

/obj/machinery/computer/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver) && circuit && !(flags & NODECONSTRUCT))
		var/obj/item/screwdriver/S = I
		playsound(src.loc, S.usesound, 50, 1)
		if(do_after(user, 20 * S.toolspeed, target = src))
			deconstruct(TRUE,user)
	else
		return ..()

/obj/machinery/computer/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(stat & BROKEN)
				playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
			else
				playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)

/obj/machinery/computer/obj_break(damage_flag)
	if(circuit && !(flags & NODECONSTRUCT)) //no circuit, no breaking
		if(!(stat & BROKEN))
			playsound(loc, 'sound/effects/Glassbr3.ogg', 100, 1)
			stat |= BROKEN
			update_icon()

/obj/machinery/computer/emp_act(severity)
	switch(severity)
		if(1)
			if(prob(50))
				obj_break("energy")
		if(2)
			if(prob(10))
				obj_break("energy")
	..()

/obj/machinery/computer/deconstruct(disassembled = TRUE, mob/user)
	on_deconstruction()
	if(!(flags & NODECONSTRUCT))
		if(circuit) //no circuit, no computer frame
			var/obj/structure/computerframe/A = new /obj/structure/computerframe(src.loc)
			A.setDir(dir)
			A.circuit = circuit
			A.anchored = 1
			if(stat & BROKEN)
				if(user)
					to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
				else
					playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
				new /obj/item/shard(drop_location())
				new /obj/item/shard(drop_location())
				A.state = 3
				A.icon_state = "3"
			else
				if(user)
					to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
				A.state = 4
				A.icon_state = "4"
			circuit = null
		for(var/obj/C in src)
			C.forceMove(loc)

	qdel(src)