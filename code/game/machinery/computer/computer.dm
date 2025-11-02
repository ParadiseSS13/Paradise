/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	density = TRUE
	anchored = TRUE
	idle_power_consumption = 300
	active_power_consumption = 300
	integrity_failure = 100
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 40, ACID = 20)
	var/obj/item/circuitboard/circuit = null //if circuit==null, computer can't disassembly
	var/icon_keyboard = "generic_key"
	var/icon_screen = "generic"
	var/light_range_on = 2
	var/light_power_on = 0.9
	/// Are we in the middle of a flicker event?
	var/flickering = FALSE
	/// Are we forcing the icon to be represented in a no-power state?
	var/force_no_power_icon_state = FALSE
	/// Cached list of colors associated with overlays
	var/list/cached_emissive_color = list()
	/// Reference to active download animation effect
	var/obj/effect/temp_visual/computer_download/active_download_effect

/obj/machinery/computer/Initialize(mapload)
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

	if(!(stat & BROKEN))
		if(!cached_emissive_color[overlay_state])
			// Get the average color of the computer screen so it can be used as a tinted glow
			// Shamelessly stolen from /tg/'s /datum/component/customizable_reagent_holder.
			var/icon/emissive_avg_screen_color = new(icon, overlay_state)
			emissive_avg_screen_color.Scale(1, 1)
			cached_emissive_color[overlay_state] = copytext(emissive_avg_screen_color.GetPixel(1, 1), 1, 8) // remove opacity
		set_light(light_range_on, light_power_on, cached_emissive_color[overlay_state])

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
		if(EMP_HEAVY)
			if(prob(50))
				obj_break(ENERGY)
		if(EMP_LIGHT)
			if(prob(10))
				obj_break(ENERGY)

/obj/machinery/computer/Destroy()
	if(active_download_effect)
		qdel(active_download_effect)
		active_download_effect = null
	return ..()

/obj/machinery/computer/deconstruct(disassembled = TRUE, mob/user)
	on_deconstruction()
	// Destroy flayer download effect if present
	if(active_download_effect)
		qdel(active_download_effect)
		active_download_effect = null
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

/obj/machinery/computer/attack_by(obj/item/I, mob/user, params)
	// Check if someone is trying to Download using a power cable
	if(!istype(I, /obj/item/apc_powercord) || !ishuman(user))
		return ..()

	var/mob/living/carbon/human/H = user
	var/datum/antagonist/mindflayer/flayer_datum = H.mind?.has_antag_datum(/datum/antagonist/mindflayer)

	if(flayer_datum)
		for(var/datum/objective/download/download_obj in flayer_datum.get_antag_objectives())
			if(download_obj.target_console == src)
				var/old_icon_screen = icon_screen
				to_chat(user, "<span class='boldnotice'>You insert your power cable into the data port on the console and begin the transfer...</span>")
				active_download_effect = new /obj/effect/temp_visual/computer_download(get_turf(src), src)
				if(do_after(user, 18 SECONDS, target = src))
					download_obj.complete_objective()
					if(active_download_effect)
						qdel(active_download_effect)
						active_download_effect = null
					icon_screen = old_icon_screen
					return TRUE
				else
					to_chat(user, "<span class='warning'>Your power cable is ejected, interrupting the transfer.</span>")
					if(active_download_effect)
						qdel(active_download_effect)
						active_download_effect = null
					icon_screen = old_icon_screen
					return TRUE

	// Not a flayer, or wrong download console.
	to_chat(user, "<span class='boldnotice'>You insert your power cable into the data port on the console, hoping to find something interesting.</span>")
	if(do_after(user, 18 SECONDS, target = src))
		show_random_download_message(user)
		return TRUE
	else
		to_chat(user, "<span class='warning'>Your power cable is ejected, interrupting the transfer.</span>")
		return TRUE

/obj/machinery/computer/proc/show_random_download_message(mob/user)
	var/list/download_messages = list(
		"<span class='notice'>A message flashes on the screen: \"[user.name] is not in the sudoers file. This incident will be reported.\"</span>"
	)
	var/message = pick(download_messages)
	to_chat(user, message)

/obj/machinery/computer/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	if(circuit && !(flags & NODECONSTRUCT))
		if(I.use_tool(src, user, 20, volume = I.tool_volume))
			deconstruct(TRUE, user)

/obj/machinery/computer/hit_by_thrown_mob(mob/living/C, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	if(!self_hurt && prob(50 * (damage / 15)))
		obj_break(MELEE)
		take_damage(damage, BRUTE)
		self_hurt = TRUE
	return ..()

/obj/machinery/computer/nonfunctional
	name = "derelict computer"
	desc = "A computer long since rendered non-functional due to lack of maintenance. \
		It is spitting out error messages."
	circuit = /obj/item/circuitboard/nonfunctional

// Temp effect for download objective
/obj/effect/temp_visual/computer_download
	icon = 'icons/obj/computer.dmi'
	icon_state = "flayer_downloading_transparent"
	duration = 180
	layer = OBJ_LAYER - 0.1
	randomdir = FALSE
	var/obj/machinery/computer/target_computer

/obj/effect/temp_visual/computer_download/Initialize(mapload, obj/machinery/computer/computer)
	if(computer)
		target_computer = computer
		setDir(target_computer.dir)
		pixel_x = target_computer.pixel_x
		pixel_y = target_computer.pixel_y
	. = ..()

/obj/effect/temp_visual/computer_download/Destroy()
	if(target_computer)
		target_computer.active_download_effect = null
		target_computer = null
	return ..()
