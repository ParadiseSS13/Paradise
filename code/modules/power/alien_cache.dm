#define CACHE_MAX_LEVEL 10
#define LEVEL_DISTRIBUTION_SIGMA 0.5
#define LEVEL_REQUIREMENT(level) ((300 MJ) * (level ** 3))

/obj/machinery/power/alien_cache
	name = "Alien Cache"
	desc = "A strange storage device of alien design"
	icon = 'icons/obj/machines/alien_cache.dmi'
	icon_state = "cache_0"
	base_icon_state = "cache_0"
	pixel_x = -32
	pixel_y = -32
	density = TRUE
	// Alien stuff is pretty tough
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// The maximum reachable level
	var/max_level = CACHE_MAX_LEVEL
	/// The deepest level we opened
	var/reached_level = 0
	/// The total amount of energy consumed
	var/total_energy = 0
	/// Assoc list of random rewards to the level they are normally found at
	var/list/random_rewards = list(
									/obj/item/screwdriver/abductor = 1,
									/obj/item/wrench/abductor = 1,
									/obj/item/multitool/abductor = 1,
									/obj/item/wirecutters/abductor = 1,
									/obj/item/crowbar/abductor = 1,
									/obj/item/stack/sheet/mineral/bananium/thirty = 1,
									/obj/item/stack/sheet/mineral/tranquillite/thirty = 1,
									/obj/item/stack/sheet/mineral/abductor/fifty = 1,
									/obj/item/storage/belt/military/abductor/full = 1,
									/obj/machinery/atmospherics/portable/canister/agent_b = 2,
									)
	/// List of guaranteed rewards you get from the last stage
	var/list/open_rewards = list()
	/// Terminal for receiving power through
	var/obj/machinery/power/terminal/terminal

/obj/machinery/power/alien_cache/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/multitile, list(
		list(1, MACH_CENTER, 1),
		list(1, 0,		   1),
	))

/obj/machinery/power/alien_cache/examine(mob/user)
	. = ..()
	if(panel_open)
		. += "<span class='notice'>The panel is open, revealing the internal wiring</span>"
	else
		. += "<span class='notice'>There's a loose panel on the front that could be pried open with a screwdriver</span>"

/obj/machinery/power/alien_cache/display_parts(user)
	return list("<span class='warning'>ERROR: UNIDENTIFIED MACHINE DESIGN</span>")

/// generate a list with weights for levels depending on the reached level
/obj/machinery/power/alien_cache/proc/level_weights()
	var/list/levels = list()
	// Generate a weighted list of all possible levels using normal distribution
	for(var/i in 1 to max_level)
		var/level_prob = normal_distribution(i, reached_level, LEVEL_DISTRIBUTION_SIGMA)
		if(level_prob > 0)
			levels["[i]"] = level_prob

	return levels

/// Returns a list of rewards with length equal to amount
/obj/machinery/power/alien_cache/proc/pick_rewards(amount = 1)
	. = list()
	if(!amount || amount < 1)
		return

	var/list/levels = level_weights()

	for(var/i in 1 to amount)
		var/selected_level = pickweight(levels)
		var/list/pool = list()
		for(var/reward in random_rewards)
			if(random_rewards[reward] == selected_level)
				pool += reward
		if(length(pool))
			. += pick(pool)
		else
			. += "no rewards in level [selected_level]"

/obj/machinery/power/alien_cache/process()
	if(terminal)
		var/available = terminal.get_surplus()
		terminal.consume_direct_power(available)
		total_energy += available * WATT_TICK_TO_JOULE
		if(total_energy >= LEVEL_REQUIREMENT(reached_level + 1))
			reached_level++
			to_chat(world, "Level: [reached_level]\nRewards: [english_list(pick_rewards())]")

/// Items interaction mostly stolen from SMES
/obj/machinery/power/alien_cache/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	// Opening using screwdriver
	if(default_deconstruction_screwdriver(user, "[icon_state]-o", initial(icon_state), used))
		update_icon()
		return ITEM_INTERACT_COMPLETE

	// Building and linking a terminal
	if(istype(used, /obj/item/stack/cable_coil))
		var/dir = get_dir(user, src)
		if(dir & (dir - 1)) // Checks for diagonal interaction
			return ITEM_INTERACT_COMPLETE

		if(terminal) // Checks for an existing terminal
			to_chat(user, "<span class='alert'>[src] already has a terminal!</span>")
			return ITEM_INTERACT_COMPLETE

		if(!panel_open) // Checks to see if the panel is closed
			to_chat(user, "<span class='alert'>You must open the panel first!</span>")
			return ITEM_INTERACT_COMPLETE

		var/turf/T = get_turf(user)
		if(T.intact) // Checks to see if floor plating is present
			to_chat(user, "<span class='alert'>You must first remove the floor plating!</span>")
			return ITEM_INTERACT_COMPLETE

		var/obj/item/stack/cable_coil/C = used
		if(C.get_amount() < 10)
			to_chat(user, "<span class='alert'>You need more wires.</span>")
			return ITEM_INTERACT_COMPLETE

		if(user.loc == loc)
			to_chat(user, "<span class='warning'>You must not be on the same tile as [src].</span>")
			return ITEM_INTERACT_COMPLETE

		// Direction the terminal will face to
		var/temporary_direction = get_dir(user, src)
		switch(temporary_direction)
			if(NORTHEAST, SOUTHEAST)
				temporary_direction = EAST
			if(NORTHWEST, SOUTHWEST)
				temporary_direction = WEST
		var/turf/temporary_location = get_step(src, REVERSE_DIR(temporary_direction))

		if(isspaceturf(temporary_location))
			to_chat(user, "<span class='warning'>You can't build a terminal on space.</span>")
			return ITEM_INTERACT_COMPLETE

		else if(istype(temporary_location))
			if(temporary_location.intact)
				to_chat(user, "<span class='warning'>You must remove the floor plating first.</span>")
				return ITEM_INTERACT_COMPLETE

		to_chat(user, "<span class='notice'>You try to connect the cable to [src]</span>")
		playsound(loc, C.usesound, 50, TRUE)

		if(do_after(user, 5 SECONDS, target = src))
			if(!terminal && panel_open)
				T = get_turf(user)
				var/obj/structure/cable/N = T.get_cable_node() //get the connecting node cable, if there's one
				if(prob(50) && electrocute_mob(usr, N, N, 1, TRUE)) //animate the electrocution if uncautious and unlucky
					do_sparks(5, TRUE, src)
					return

				C.use(10) // make sure the cable gets used up
				user.visible_message(\
					"<span class='notice'>[user.name] adds the cables and connects the power terminal.</span>",\
					"<span class='notice'>You add the cables and connect the power terminal.</span>")

				make_terminal(user, temporary_direction, temporary_location)
				terminal.connect_to_network()
				stat &= ~BROKEN
		return ITEM_INTERACT_COMPLETE

	// Disassembling the terminal
	if(istype(used, /obj/item/wirecutters) && terminal && panel_open)
		var/turf/T = get_turf(terminal)
		if(T.intact) //is the floor plating removed ?
			to_chat(user, "<span class='alert'>You must first expose the power terminal!</span>")
			return ITEM_INTERACT_COMPLETE

		to_chat(user, "<span class='notice'>You begin to dismantle the power terminal...</span>")
		playsound(src.loc, used.usesound, 50, TRUE)

		if(do_after(user, 5 SECONDS * used.toolspeed, target = src))
			if(terminal && panel_open)
				if(prob(50) && electrocute_mob(usr, terminal.powernet, terminal, 1, TRUE)) // Animate the electrocution if uncautious and unlucky
					do_sparks(5, TRUE, src)
					return ITEM_INTERACT_COMPLETE

				// Returns wires on deletion of the terminal
				new /obj/item/stack/cable_coil(T, 10)
				user.visible_message(\
					"<span class='alert'>[user.name] cuts the cables and dismantles the power terminal.</span>",\
					"<span class='notice'>You cut the cables and dismantle the power terminal.</span>")
				qdel(terminal)
				return ITEM_INTERACT_COMPLETE

	return ..()

/// Terminal creation proc stolen from SMES
/obj/machinery/power/alien_cache/proc/make_terminal(user, temporary_direction, temporary_location)
	// Create a terminal object at the same position as original turf loc
	// Wires will attach to this
	terminal = new /obj/machinery/power/terminal(temporary_location)
	terminal.dir = temporary_direction
	terminal.master = src

#undef CACHE_MAX_LEVEL
#undef LEVEL_DISTRIBUTION_SIGMA
