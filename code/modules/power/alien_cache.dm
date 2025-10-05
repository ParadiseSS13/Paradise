#define CACHE_MAX_LEVEL 10
#define LEVEL_DISTRIBUTION_SIGMA 0.5
#define LEVEL_REQUIREMENT(level) ((300 MJ) * ((level) ** 3))

/obj/machinery/alien_cache
	name = "Alien Cache"
	desc = "A strange storage device of alien design"
	icon = 'icons/obj/machines/alien_cache.dmi'
	icon_state = "cache_0"
	base_icon_state = "cache_0"
	pixel_x = -32
	pixel_y = -32
	density = TRUE
	anchored = TRUE
	// Alien stuff is pretty tough
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// The maximum reachable level
	var/max_level = CACHE_MAX_LEVEL
	/// The deepest level we opened
	var/level_reached = 0
	/// The total amount of energy consumed
	var/total_energy = 0
	/// Assoc list of level to rewards found at that level with a weight for each
	var/list/random_rewards = list(
									// level 1
									list(
										/obj/item/stack/sheet/mineral/abductor/fifty = 1,
										/obj/machinery/the_singularitygen/tesla = 0.3,
										/obj/machinery/the_singularitygen = 0.3,
										/obj/item/stack/sheet/mineral/bananium/thirty = 1,
										/obj/item/stack/sheet/mineral/tranquillite/thirty = 1,
										),
									// level 2
									list(
										/obj/effect/spawner/random/alien_cache/alien_surgical_tool = 1,
										/obj/item/mod/module/dispenser = 1,
										/obj/effect/spawner/alien_cache/mob_capsule = 1,
										/obj/item/storage/pill_bottle/random_meds/labelled = 1,
										),
									// level 3
									list(
										/obj/item/mod/module/jetpack/advanced = 1,
										/obj/effect/spawner/alien_cache/gas_canister = 1,
										/obj/effect/spawner/random/alien_cache/alien_tool_borg = 1,
										),
									// level 4
									list(
										/obj/effect/spawner/random/alien_cache/alien_tool = 1,
										/obj/item/assembly/signaler/anomaly/random = 1,
										/obj/effect/spawner/alien_cache/gas_canister/agent_b = 1,
										),
									// level 5
									list(
										/obj/item/storage/belt/military/abductor/full = 1,
										/obj/item/guardiancreator/biological = 1,
										),
									)
	/// List of guaranteed rewards you get from the last stage
	var/list/open_rewards = list(
								/obj/item/circuitboard/machine/bluespace_tap = 1,
								)
	/// Terminal for receiving power through
	var/obj/machinery/power/terminal/terminal

/obj/machinery/alien_cache/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/multitile, list(
		list(1, MACH_CENTER, 1),
		list(1, 0,		   1),
	))

/obj/machinery/alien_cache/update_overlays()
	. = ..()
	var/my_alpha = 0
	for(var/cache_level in 1 to CACHE_MAX_LEVEL)
		if(total_energy <= 0 || cache_level > level_reached + 1)
			break
		if(cache_level < level_reached + 1)
			my_alpha = 255
		if(cache_level == level_reached + 1)
			my_alpha = clamp(1 - ((LEVEL_REQUIREMENT(cache_level) - total_energy) / (LEVEL_REQUIREMENT(cache_level + 1) - LEVEL_REQUIREMENT(cache_level))), 0, 1)
			my_alpha *= 255
		. += mutable_appearance(icon, "cache_level_[cache_level]", alpha = my_alpha)

/obj/machinery/alien_cache/examine(mob/user)
	. = ..()
	if(panel_open)
		. += "<span class='notice'>The panel is open, revealing unterminated internal wiring.</span>"
	else
		. += "<span class='notice'>There's a loose panel on the front that could be pried open with a screwdriver</span>"

/obj/machinery/alien_cache/display_parts(user)
	return list("<span class='warning'>ERROR: UNIDENTIFIED MACHINE DESIGN</span>")

/// generate a list with weights for tiers of loot depending on the reached level
/obj/machinery/alien_cache/proc/tier_weights()
	var/list/tiers = list()
	// Generate a weighted list of all possible tiers using normal distribution
	var/avg_tier = (length(random_rewards) * level_reached / max_level)
	for(var/i in 1 to length(random_rewards))
		var/tier_prob = normal_distribution(i, avg_tier, LEVEL_DISTRIBUTION_SIGMA)
		if(tier_prob > 0)
			tiers["[i]"] = tier_prob

	return tiers

/// Returns a list of rewards with length equal to amount
/obj/machinery/alien_cache/proc/pick_rewards(amount = 1)
	. = list()
	if(!amount || amount < 1)
		return

	var/list/tiers = tier_weights()

	for(var/i in 1 to amount)
		var/selected_level = text2num(pickweight_fraction(tiers))
		if(length(random_rewards[selected_level]))
			. += pickweight_fraction(random_rewards[selected_level])
		else
			. += "no rewards in level [selected_level]"

/obj/machinery/alien_cache/process()
	if(terminal && level_reached < max_level)
		var/available = terminal.get_surplus()
		terminal.consume_direct_power(available)
		total_energy += available * WATT_TICK_TO_JOULE
		if(total_energy >= LEVEL_REQUIREMENT(level_reached + 1))
			level_reached++
			var/list/rewards = pick_rewards(3)
			spawn_loot(rewards)
			if(level_reached >= max_level)
				spawn_loot(open_rewards)
	update_icon(UPDATE_OVERLAYS)


/obj/machinery/alien_cache/proc/spawn_loot(list/loot)
	var/spawn_side = prob(50) ? WEST : EAST
	if(dir & (EAST | WEST))
		// We can turn EAST/WEST into NORTH/SOUTH simply by right shifting
		spawn_side = spawn_side >> 2
	var/turf/spawnloc = get_step(get_step(get_step(src, dir), dir), spawn_side)
	new /obj/effect/portal(spawnloc, null, src, 10)
	for(var/lootpath in loot)
		new lootpath(spawnloc)

/// Items interaction mostly stolen from SMES
/obj/machinery/alien_cache/item_interaction(mob/living/user, obj/item/used, list/modifiers)
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
		var/turf/temporary_location = get_step(src, REVERSE_DIR(dir))

		if(isspaceturf(temporary_location))
			to_chat(user, "<span class='warning'>You can't build a terminal on space.</span>")
			return ITEM_INTERACT_COMPLETE

		else if(istype(temporary_location))
			if(temporary_location.intact)
				to_chat(user, "<span class='warning'>You must remove the floor plating first.</span>")
				return ITEM_INTERACT_COMPLETE

		to_chat(user, "<span class='notice'>You try to connect the cable to [src]</span>")
		playsound(loc, C.usesound, 50, TRUE)

		if(do_after(user, 5 SECONDS, target = get_turf(src)))
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

				make_terminal(user, temporary_location)
				terminal.connect_to_network()
				stat &= ~BROKEN
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/alien_cache/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	to_chat(user, chat_box_examine("<span class='notice'>Total energy: [DisplayJoules(total_energy)]<br>Levels opened: [level_reached]</span>"))

/obj/machinery/alien_cache/screwdriver_act(mob/living/user, obj/item/I)
	// Opening using screwdriver
	return default_deconstruction_screwdriver(user, "[icon_state]-o", initial(icon_state), I)

/obj/machinery/alien_cache/wirecutter_act(mob/living/user, obj/item/I)
	// No terminal to cut, just bonk
	if(!terminal)
		return FALSE
	// If we have a terminal assume we are trying to disassemble it
	. = TRUE
	var/turf/T = get_turf(terminal)
	if(T.intact) //is the floor plating removed ?
		to_chat(user, "<span class='alert'>You must first expose the power terminal!</span>")
		return
	if(!panel_open)
		to_chat(user, "<span class='alert'>You must first open the panel</span>")
	to_chat(user, "<span class='notice'>You begin to dismantle the power terminal...</span>")
	playsound(src.loc, I.usesound, 50, TRUE)

	if(do_after(user, 5 SECONDS * I.toolspeed, target = src))
		if(terminal && panel_open)
			if(prob(50) && electrocute_mob(usr, terminal.powernet, terminal, 1, TRUE)) // Animate the electrocution if uncautious and unlucky
				do_sparks(5, TRUE, src)
				return

			// Returns wires on deletion of the terminal
			new /obj/item/stack/cable_coil(T, 10)
			user.visible_message(\
				"<span class='alert'>[user.name] cuts the cables and dismantles the power terminal.</span>",\
				"<span class='notice'>You cut the cables and dismantle the power terminal.</span>")
			qdel(terminal)
			return

/// Terminal creation proc stolen from SMES
/obj/machinery/alien_cache/proc/make_terminal(user, temporary_location)
	// Create a terminal object at the same position as original turf loc
	// Wires will attach to this
	terminal = new /obj/machinery/power/terminal(temporary_location)
	terminal.master = src
	terminal.dir = REVERSE_DIR(dir)

#undef CACHE_MAX_LEVEL
#undef LEVEL_DISTRIBUTION_SIGMA
#undef LEVEL_REQUIREMENT
