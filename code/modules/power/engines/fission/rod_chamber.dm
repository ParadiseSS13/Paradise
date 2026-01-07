#define CHAMBER_HEAT_DAMAGE 15 //! How much damage reactor chambers do when on.

/obj/machinery/atmospherics/reactor_chamber
	name = "rod housing chamber"
	desc = "A chamber used to house nuclear rods of various types to facilitate a fission reaction."
	icon = 'icons/obj/fission/reactor_chamber.dmi'
	icon_state = "chamber_down"
	layer = BELOW_OBJ_LAYER
	pass_flags_self = PASSTAKE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	max_integrity = 400
	armor = list(melee = 80, bullet = 30, laser = 30, energy = 10, bomb = 40, rad = INFINITY, fire = INFINITY, acid = INFINITY) // Fairly robust
	idle_power_consumption = 100
	flags_2 = NO_MALF_EFFECT_2

	/// Each reactor chamber can only be linked to a single reactor, if somehow theres two.
	var/obj/machinery/atmospherics/fission_reactor/linked_reactor
	/// Holds the specific rod inserted into the chamber
	var/obj/item/nuclear_rod/held_rod
	/// Is the chamber up, down, or open
	var/chamber_state = 1
	/// Has the requirements for the rod inside this chamber been met?
	var/requirements_met = FALSE
	/// Is the rod chamber actively running and providing its effects
	var/operational = FALSE
	/// Holds the list of linked neighbors
	var/list/neighbors = list()
	/// Skip this chamber when building links
	var/skip_link = FALSE
	/// The total amount of heat produced by this chamber
	var/heat_total
	/// The total amount of power produced by this rod
	var/power_total
	/// Is the chamber currently in an enrichment process
	var/enriching = FALSE
	/// Has the chamber been welded shut. Uh oh!
	var/welded = FALSE
	/// Holds the current accumulated power mod value from its neighbors
	var/power_mod_total = 1
	/// Holds the current accumulated heat mod value from its neighbors
	var/heat_mod_total = 1
	/// A simple binary to prevent open/close spam mucking up the anims
	var/lockout = FALSE
	/// Holds our durability bar overlay level. Updates overlays if it changes
	var/durability_level = 0
	/// Holds our previous overlay.
	var/previous_durability_level

/obj/machinery/atmospherics/reactor_chamber/Initialize(mapload)
	. = ..()
	dupe_check()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/reactor_chamber(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stack/sheet/mineral/plastitanium(src, 2)
	component_parts += new /obj/item/stack/sheet/metal(src, 2)
	component_parts += new /obj/item/stack/cable_coil(src, 5)
	RefreshParts()
	update_icon(UPDATE_OVERLAYS)
	RegisterSignal(src, COMSIG_PARENT_EXAMINE, PROC_REF(deep_examine))
	return INITIALIZE_HINT_LATELOAD

// Needs to be late so it does not initialize before the reactor or the other neighbors are ready
/obj/machinery/atmospherics/reactor_chamber/LateInitialize()
	. = ..()
	find_link()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/atmospherics/reactor_chamber/uranium

/obj/machinery/atmospherics/reactor_chamber/uranium/Initialize(mapload)
	. = ..()
	held_rod = new /obj/item/nuclear_rod/fuel/uranium_238(src)

/obj/machinery/atmospherics/reactor_chamber/heavy_water

/obj/machinery/atmospherics/reactor_chamber/heavy_water/Initialize(mapload)
	. = ..()
	held_rod = new /obj/item/nuclear_rod/moderator/heavy_water(src)

/obj/machinery/atmospherics/reactor_chamber/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("[src] can be sealed/unsealed from its base with a lit welder using harm intent, but only while the chamber is lowered.")
	. += SPAN_NOTICE("Alt+click to open and close the shielding while the chamber is raised.")
	. += SPAN_NOTICE("Click on the chamber while it is closed to raise and lower it.")

	if(isobserver(user))
		// observers get regular examine + nested multitool info
		var/list/deep_info = get_deep_examine_info()
		if(length(deep_info))
			. += chat_box_examine(deep_info.Join("<br>"))

/obj/machinery/atmospherics/reactor_chamber/on_deconstruction()
	desync()
	if(held_rod) // We shouldnt be able to decon with this in, but just in case
		if(held_rod.reactor_overheat_modifier)
			linked_reactor.update_overheat_threshold(-held_rod.reactor_overheat_modifier)
		held_rod.forceMove(loc)
		held_rod = null
	return ..()

/obj/machinery/atmospherics/reactor_chamber/Destroy()
	if(held_rod && held_rod.reactor_overheat_modifier)
		linked_reactor.update_overheat_threshold(-held_rod.reactor_overheat_modifier)
	QDEL_NULL(held_rod)
	if(linked_reactor)
		desync()
	UnregisterSignal(src, COMSIG_PARENT_EXAMINE)
	return ..()

/obj/machinery/atmospherics/reactor_chamber/update_icon_state()
	return

/obj/machinery/atmospherics/reactor_chamber/update_overlays()
	. = ..()
	overlays.Cut()
	if(welded)
		var/mutable_appearance/weld_overlay = mutable_appearance(layer = BELOW_OBJ_LAYER + 0.03)
		weld_overlay.icon_state = "welded"
		. += weld_overlay
	if(chamber_state == CHAMBER_OPEN)
		var/mutable_appearance/cover_icon = mutable_appearance(layer = ABOVE_ALL_MOB_LAYER + 0.02)
		cover_icon.icon = icon
		cover_icon.icon_state = "door_open"
		. += cover_icon

	if(!held_rod)
		return
	if(chamber_state == CHAMBER_OPEN)
		var/mutable_appearance/rod_overlay = mutable_appearance(layer = ABOVE_ALL_MOB_LAYER + 0.01)
		rod_overlay.icon = icon
		if(istype(held_rod, /obj/item/nuclear_rod/fuel))
			rod_overlay.icon_state = "fuel_overlay"
		if(istype(held_rod, /obj/item/nuclear_rod/coolant))
			rod_overlay.icon_state = "coolant_overlay"
		if(istype(held_rod, /obj/item/nuclear_rod/moderator))
			rod_overlay.icon_state = "moderator_overlay"
		. += rod_overlay

	var/mutable_appearance/state_overlay = mutable_appearance(layer = BELOW_OBJ_LAYER + 0.01)
	state_overlay.icon = icon
	if(chamber_state == CHAMBER_DOWN)
		if(enriching)
			state_overlay.icon_state = "blue"
		else if(requirements_met)
			if(operational)
				state_overlay.icon_state = "green"
			else
				state_overlay.icon_state = "orange"
		else
			if(operational)
				state_overlay.icon_state = "orange"
			else
				state_overlay.icon_state = "red"

		var/mutable_appearance/display_overlay = mutable_appearance(layer = BELOW_OBJ_LAYER + 0.01)
		if(istype(held_rod, /obj/item/nuclear_rod/fuel))
			display_overlay.icon_state = "display_fuel"
		if(istype(held_rod, /obj/item/nuclear_rod/moderator))
			display_overlay.icon_state =  "display_moderator"
		if(istype(held_rod, /obj/item/nuclear_rod/coolant))
			display_overlay.icon_state =  "display_coolant"
		. += display_overlay
	if(chamber_state == CHAMBER_OVERLOAD_IDLE)
		if(held_rod && istype(held_rod, /obj/item/nuclear_rod/fuel))
			state_overlay.icon_state = "orange"
		else
			state_overlay.icon_state = "red"
	if(chamber_state == CHAMBER_OVERLOAD_ACTIVE)
		state_overlay.icon_state = "overload"
	. += state_overlay

	var/mutable_appearance/durability_overlay = mutable_appearance(icon, layer = BELOW_OBJ_LAYER + 0.01)
	durability_overlay.icon_state = "dur_[previous_durability_level]"
	. += durability_overlay

/// Check for multiple on a tile and nuke it
/obj/machinery/atmospherics/reactor_chamber/proc/dupe_check()
	var/obj/machinery/atmospherics/reactor_chamber/chamber = locate() in range(0, src)
	if(chamber && chamber != src)
		visible_message(SPAN_WARNING("[src] has no room to deploy and breaks apart!"))
		chamber.deconstruct()

/obj/machinery/atmospherics/reactor_chamber/attack_hand(mob/user)
	if(!user)
		return
	if(linked_reactor && linked_reactor.admin_intervention)
		to_chat(user, SPAN_WARNING("An unusual force prevents you from moving the chamber!"))
		return
	if(stat & NOPOWER)
		to_chat(user, SPAN_WARNING("The chamber's locks wont disengage without power!"))
		return

	if(!is_mecha_occupant(user))
		add_fingerprint(user)

	switch(chamber_state)
		if(CHAMBER_DOWN, CHAMBER_OVERLOAD_IDLE)
			if(!Adjacent(user))
				return
			if(welded)
				to_chat(user, SPAN_WARNING("[src] is welded shut. It wont budge!"))
				return
			if(!density_check(user))
				return
			var/delay = 1 SECONDS
			if(linked_reactor && !linked_reactor.offline)
				delay = 8 SECONDS
				if(!is_mecha_occupant(user)) // Mech users are unaffected
					burn_handler(user)
			if(do_after_once(user, delay, target = src, allow_moving = FALSE))
				if(!Adjacent(user)) // For mecha users
					return
				if(density_check(user))
					raise()
				return

		if(CHAMBER_UP)
			if(!density_check(user))
				return
			if(do_after_once(user, 2 SECONDS, target = src, allow_moving = FALSE))
				if(chamber_state != CHAMBER_UP) // So that we cant lower while in the open state
					return
				if(density_check(user))
					lower()
				return

		if(CHAMBER_OPEN)
			if(issilicon(user)) // Handled seperately. Dont pull out this way
				return
			if(!held_rod)
				to_chat(user, SPAN_WARNING("There is no rod inside of the chamber to remove!"))
				return
			if(user.put_in_hands(held_rod))
				held_rod.add_fingerprint(user)
				held_rod = null
				playsound(loc, 'sound/machines/podopen.ogg', 50, TRUE)
				update_icon(UPDATE_OVERLAYS)
				return

			to_chat(user, SPAN_WARNING("Your hands are currently full!"))
			return
		if(CHAMBER_OVERLOAD_ACTIVE)
			to_chat(user, SPAN_ALERT("The chamber lockdowns have been engaged, preventing it from being raised!"))
			return
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/atmospherics/reactor_chamber/AltClick(mob/user, modifiers)
	if(!Adjacent(user) || lockout)
		return
	if(linked_reactor && linked_reactor.admin_intervention)
		to_chat(user, SPAN_WARNING("An unusual force prevents you from manipulating the chamber!"))
		return
	if(chamber_state == CHAMBER_UP)
		if(!lockout)
			open()
		return
	if(chamber_state == CHAMBER_OPEN)
		if(panel_open == TRUE)
			to_chat(user, SPAN_WARNING("You must close the maintenance panel before the chamber can be sealed!"))
			return
		if(!lockout)
			close()
		return

/obj/machinery/atmospherics/reactor_chamber/proc/density_check(mob/user)
	for(var/atom/thing in get_turf(src))
		if(thing == src)
			continue
		if(thing.density)
			to_chat(user, SPAN_WARNING("The chamber is being blocked from opening!"))
			return FALSE
	return TRUE

/obj/machinery/atmospherics/reactor_chamber/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(issilicon(user) && get_dist(src, user) > 1)
		attack_hand(user)
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/nuclear_rod))
		if(chamber_state == CHAMBER_OPEN)
			if(held_rod)
				to_chat(user, SPAN_WARNING("There is already a rod inside of the chamber!"))
				return ITEM_INTERACT_COMPLETE
			if(panel_open)
				to_chat(user, SPAN_WARNING("The open maintenance panel prevents the rod from slotting inside!"))
				return ITEM_INTERACT_COMPLETE
			if(user.transfer_item_to(used, src, force = TRUE))
				held_rod = used
				playsound(loc, 'sound/machines/podclose.ogg', 50, TRUE)
				update_icon(UPDATE_OVERLAYS)
				return ITEM_INTERACT_COMPLETE

/obj/machinery/atmospherics/reactor_chamber/screwdriver_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	. = TRUE
	if(chamber_state != CHAMBER_OPEN)
		to_chat(user, SPAN_ALERT("[src] must be raised and opened first!"))
		return
	if(linked_reactor && !linked_reactor.offline)
		to_chat(user, SPAN_ALERT("The safety locks prevent maintenance while the reactor is on!"))
		return
	if(held_rod)
		to_chat(user, SPAN_ALERT("You cannot reach the maintenance panel if there is a rod inside!"))
		return
	default_deconstruction_screwdriver(user, "chamber_maint", "chamber_open", I)

/obj/machinery/atmospherics/reactor_chamber/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	default_deconstruction_crowbar(user, I)

/obj/machinery/atmospherics/reactor_chamber/welder_act(mob/living/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		if(chamber_state == CHAMBER_OVERLOAD_IDLE || chamber_state == CHAMBER_OVERLOAD_ACTIVE)
			to_chat(user, SPAN_WARNING("You probably shouldn't try to weld it right now."))
			return ITEM_INTERACT_COMPLETE
		if(chamber_state != CHAMBER_DOWN)
			return ITEM_INTERACT_COMPLETE
		to_chat(user, SPAN_WARNING("You begin [welded ? "unwelding" : "welding"] [src]"))
		if(!I.use_tool(src, user, (6 SECONDS) * I.toolspeed, volume = I.tool_volume))
			return ITEM_INTERACT_COMPLETE
		if(welded)
			unweld()
		else
			weld_shut()
		update_icon(UPDATE_OVERLAYS)
		return ITEM_INTERACT_COMPLETE
	if(obj_integrity < max_integrity)
		to_chat(user, SPAN_WARNING("You begin repairing [src]."))
		if(!I.use_tool(src, user, (3 SECONDS) * I.toolspeed, volume = I.tool_volume))
			return ITEM_INTERACT_COMPLETE
		obj_integrity = max_integrity // Lets make sure we can keep these healthy if need be
	else
		to_chat(user, SPAN_WARNING("[src] is not in need of repair."))
		return ITEM_INTERACT_COMPLETE


/obj/machinery/atmospherics/reactor_chamber/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	show_deep_examine(user)

/obj/machinery/atmospherics/reactor_chamber/proc/get_deep_examine_info()
	if(chamber_state != CHAMBER_DOWN)
		return null
	if(!held_rod)
		return list(SPAN_WARNING("There is no nuclear rod inside this housing chamber."))
	if(!linked_reactor)
		return list(SPAN_WARNING("This chamber is not connected to a reactor."))

	var/operating_rate = linked_reactor.operating_rate()
	var/durability_mod = held_rod.get_durability_mod()
	var/list/message = list()
	message += SPAN_NOTICE("[held_rod] is currently contained within this chamber.")

	message += ""

	if(held_rod.durability == 0)
		message += SPAN_NOTICE("The rod has been fully depleted and rendered inert.")
		return message
	else
		message += SPAN_NOTICE("Rod integrity is at [(held_rod.durability / held_rod.max_durability) * 100]%.")

	message += ""

	if(power_total && operational)
		message += SPAN_NOTICE("The chamber is currently producing [(power_total * operating_rate * durability_mod) / 1000] KiloWatts of energy.")
		message += SPAN_NOTICE("The chamber has a power modifier of [power_mod_total].")
	else
		message += SPAN_NOTICE("The chamber is producing no power.")
	if(istype(held_rod, /obj/item/nuclear_rod/fuel))
		var/obj/item/nuclear_rod/fuel/rod = held_rod
		if(rod.power_enrich_progress >= rod.enrichment_cycles && rod.power_enrich_result)
			message += SPAN_NOTICE("[held_rod] has been power enriched")
		else
			message += SPAN_NOTICE("[held_rod] has not yet finished a power enrichment process.")

	message += ""

	if(heat_total)
		message += SPAN_NOTICE("The chamber is currently producing [heat_total * HEAT_MODIFIER * operating_rate * durability_mod] joules of heat.")
		message += SPAN_NOTICE("The chamber has a heat modifier of [heat_mod_total].")
	else
		message += SPAN_NOTICE("The chamber is producing no heat.")
	if(istype(held_rod, /obj/item/nuclear_rod/fuel))
		var/obj/item/nuclear_rod/fuel/rod = held_rod
		if(rod.heat_enrich_progress >= rod.enrichment_cycles && rod.heat_enrich_result)
			message += SPAN_NOTICE("[held_rod] has been heat enriched")
		else
			message += SPAN_NOTICE("[held_rod] has not yet finished a heat enrichment process.")

	return message

/obj/machinery/atmospherics/reactor_chamber/proc/show_deep_examine(mob/user)
	var/list/info = get_deep_examine_info()
	if(!info)
		return ITEM_INTERACT_COMPLETE

	to_chat(user, chat_box_examine(info.Join("<br>")))
	return ITEM_INTERACT_COMPLETE

/obj/machinery/atmospherics/reactor_chamber/proc/deep_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER // COMSIG_PARENT_EXAMINE
	show_deep_examine(user)

/obj/machinery/atmospherics/reactor_chamber/proc/raise(playsound = TRUE)
	chamber_state = CHAMBER_UP
	icon_state = "chamber_up_anim"
	lockout = TRUE
	addtimer(CALLBACK(src, PROC_REF(finish_raise_anim)), 0.7 SECONDS)
	density = TRUE
	operational = FALSE
	enriching = FALSE
	requirements_met = FALSE
	layer = ABOVE_MOB_LAYER
	power_total = 0
	check_minimum_modifier()
	if(held_rod && held_rod.reactor_overheat_modifier)
		linked_reactor.update_overheat_threshold(-held_rod.reactor_overheat_modifier)
	if(playsound)
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
	if(istype(held_rod, /obj/item/nuclear_rod/fuel))
		if(linked_reactor.offline)
			held_rod.start_rads()
		else
			held_rod.start_rads(linked_reactor.reactivity_multiplier)

	update_icon()
	for(var/obj/machinery/atmospherics/reactor_chamber/chamber in neighbors)
		if(!chamber.held_rod)
			continue
		if(chamber.check_status())
			chamber.requirements_met = TRUE
		else
			chamber.requirements_met = FALSE

/obj/machinery/atmospherics/reactor_chamber/proc/finish_raise_anim()
	lockout = FALSE
	icon_state = "chamber_up"

/obj/machinery/atmospherics/reactor_chamber/proc/lower(playsound = TRUE)
	density = FALSE
	layer = BELOW_OBJ_LAYER
	if(playsound)
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)

	if(linked_reactor && linked_reactor.safety_override)
		chamber_state = CHAMBER_OVERLOAD_IDLE
		icon_state = "chamber_overload"
		if(linked_reactor.check_overload_ready())
			linked_reactor.set_overload()
		update_icon()
		return

	chamber_state = CHAMBER_DOWN
	icon_state = "chamber_down_anim"
	addtimer(CALLBACK(src, PROC_REF(finish_down_anim)), 1.3 SECONDS)

	if(!held_rod)
		update_icon()
		return

	held_rod.stop_rads()
	if(held_rod.reactor_overheat_modifier)
		linked_reactor.update_overheat_threshold(held_rod.reactor_overheat_modifier)
	previous_durability_level = clamp(ROUND_UP(((held_rod.durability / held_rod.max_durability) * 5) - 0.8), 0, 5)
	if(check_status())
		requirements_met = TRUE
	else
		requirements_met = FALSE
	check_minimum_modifier()
	update_icon()

/obj/machinery/atmospherics/reactor_chamber/proc/finish_down_anim()
	icon_state = "chamber_down"

/obj/machinery/atmospherics/reactor_chamber/proc/close(playsound = TRUE)
	chamber_state = CHAMBER_UP
	new /obj/effect/temp_visual/chamber_closing(loc)
	addtimer(CALLBACK(src, PROC_REF(finish_closing)), 0.5 SECONDS)
	lockout = TRUE
	if(playsound)
		playsound(loc, 'sound/machines/switch.ogg', 50, TRUE)

/obj/machinery/atmospherics/reactor_chamber/proc/finish_closing()
	lockout = FALSE
	icon_state = "chamber_up"
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/atmospherics/reactor_chamber/proc/open(playsound = TRUE)
	chamber_state = CHAMBER_OPEN
	icon_state = "chamber_open"
	var/cover_icon = mutable_appearance(icon, icon_state = "doors_opening", layer = ABOVE_ALL_MOB_LAYER + 0.02)
	add_overlay(cover_icon)
	lockout = TRUE
	addtimer(CALLBACK(src, PROC_REF(finish_opening)), 0.5 SECONDS)
	if(playsound)
		playsound(loc, 'sound/machines/switch.ogg', 50, TRUE)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/atmospherics/reactor_chamber/proc/finish_opening()
	lockout = FALSE

/obj/machinery/atmospherics/reactor_chamber/proc/set_idle_overload()
	if(chamber_state == CHAMBER_DOWN)
		chamber_state = CHAMBER_OVERLOAD_IDLE
		icon_state = "chamber_overload"
	if(welded)
		welded = FALSE
	operational = FALSE
	enriching = FALSE
	requirements_met = FALSE
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/atmospherics/reactor_chamber/proc/set_active_overload()
	chamber_state = CHAMBER_OVERLOAD_ACTIVE
	icon_state = "chamber_down"
	update_icon(UPDATE_OVERLAYS)

/// Gets the neighbors of the current chamber, and adds itself to its neighbors. can prompt a cascade of linking
/obj/machinery/atmospherics/reactor_chamber/proc/get_neighbors()
	for(var/direction in GLOB.cardinal)
		var/obj/machinery/atmospherics/reactor_chamber/chamber = locate() in get_step(src, direction)
		if(!chamber)
			continue
		if(chamber.linked_reactor && chamber.linked_reactor != linked_reactor) // If for some god forsaken reason we have two
			continue
		if((chamber in neighbors) || (src in chamber.neighbors))
			continue
		neighbors += chamber
		chamber.neighbors += src
		if(!chamber.linked_reactor)
			chamber.linked_reactor = linked_reactor
			linked_reactor.connected_chambers += chamber
			chamber.get_neighbors()

/// Removes the chamber from neighbor from its neighbors, and forces them to run status checks
/obj/machinery/atmospherics/reactor_chamber/proc/desync()
	if(length(neighbors))
		for(var/obj/machinery/atmospherics/reactor_chamber/chamber in neighbors)
			chamber.neighbors -= src
		neighbors.Cut()
	if(linked_reactor)
		linked_reactor.connected_chambers -= src
		linked_reactor.clear_reactor_network(restart = TRUE)

/// Forms the two-way link between the reactor and the chamber, then searches for valid neighbors.
/obj/machinery/atmospherics/reactor_chamber/proc/form_link(obj/machinery/atmospherics/fission_reactor/reactor)
	if(linked_reactor || skip_link) // Prevent duplicate linking or unwanted chambers
		return
	linked_reactor = reactor
	linked_reactor.connected_chambers |= src
	get_neighbors()

/// Searches for a valid reactor or linked chamber nearby
/obj/machinery/atmospherics/reactor_chamber/proc/find_link()
	if(linked_reactor) // We already have a linked reactor
		return
	var/turf/nearby_turf
	for(var/direction in GLOB.cardinal)
		nearby_turf = get_step(src, direction)
		var/obj/machinery/atmospherics/fission_reactor/reactor = locate() in nearby_turf
		if(reactor)
			form_link(reactor)
			return TRUE
		var/obj/structure/filler/filler = locate() in nearby_turf
		if(filler &&istype(filler.parent, /obj/machinery/atmospherics/fission_reactor))
			form_link(filler.parent)
			return TRUE
		var/obj/machinery/atmospherics/reactor_chamber/chamber = locate() in nearby_turf
		if(chamber &&chamber.linked_reactor)
			form_link(chamber.linked_reactor)
			return TRUE
	return FALSE

/// Validates that all rod requirements are being met
/obj/machinery/atmospherics/reactor_chamber/proc/check_status()
	if(!held_rod)
		return FALSE

	var/list/temp_requirements = list()
	temp_requirements += held_rod.adjacent_requirements // A temporary modable holder
	if(!temp_requirements)
		return TRUE

	for(var/obj/machinery/atmospherics/reactor_chamber/chamber in neighbors)
		if(!chamber.operational)
			continue
		if(chamber.held_rod.type in temp_requirements)
			temp_requirements -= chamber.held_rod.type
			continue
		for(var/requirement in temp_requirements)
			if(chamber.held_rod.type in typesof(requirement))
				temp_requirements -= requirement
				break

	if(!length(temp_requirements))
		return TRUE

	return FALSE

/obj/machinery/atmospherics/reactor_chamber/process()
	if(!linked_reactor)
		if(find_link())
			get_neighbors()
		return
	if(linked_reactor.admin_intervention)
		return
	if(!held_rod)
		return
	if(chamber_state != CHAMBER_DOWN) // We should only process reactor info when down
		return
	durability_level = clamp(ROUND_UP(((held_rod.durability / held_rod.max_durability) * 5) - 0.8), 0, 5)
	if(durability_level != previous_durability_level)
		previous_durability_level = durability_level
		update_icon(UPDATE_OVERLAYS)
	if(!linked_reactor.offline)
		held_rod.calc_stat_decrease() // Only need to re-calc durability loss when the chamber is down and reactor is online
	if(linked_reactor && linked_reactor.safety_override && !linked_reactor.control_lockout) // we only remove control lockout when the others are ready
		if(chamber_state == CHAMBER_OVERLOAD_IDLE && istype(held_rod, /obj/item/nuclear_rod/fuel))
			set_active_overload() // For latejoiners
	if(operational && held_rod.durability <= 0)
		requirements_met = FALSE
		update_icon(UPDATE_OVERLAYS)
		return
	if(!requirements_met && !operational)
		if(check_status())
			requirements_met = TRUE
			update_icon(UPDATE_OVERLAYS)
			return
	if(requirements_met && !operational)
		if(prob(20))
			operational = TRUE
			update_icon(UPDATE_OVERLAYS)
			return
	if(!requirements_met && operational) // If it loses requirements, it wont immediately turn off
		if(istype(held_rod, /obj/item/nuclear_rod/coolant))
			if(prob(15)) // Higher rates of coolant rod failures once they're already on. Good luck.
				operational = FALSE
				update_icon(UPDATE_OVERLAYS)
		else if(prob(1))
			enriching = FALSE
			operational = FALSE
			update_icon(UPDATE_OVERLAYS)
		return

/obj/machinery/atmospherics/reactor_chamber/process_atmos()
	if(!held_rod || !linked_reactor || linked_reactor.offline)
		return
	if(chamber_state != CHAMBER_OPEN && chamber_state != CHAMBER_UP)
		return
	if(linked_reactor.admin_intervention)
		return

	var/datum/milla_safe/chamber_process/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/chamber_process

/datum/milla_safe/chamber_process/on_run(obj/machinery/atmospherics/reactor_chamber/chamber)
	var/turf/T = get_turf(chamber)
	var/datum/gas_mixture/environment = get_turf_air(T)

	if(isnull(T)) // We have a null turf...something is wrong, stop processing this entity.
		return PROCESS_KILL

	if(!istype(chamber.loc, /turf)) // How in the FUCK did we manage this
		return  // Yeah just stop.

	if(T.density)
		var/turf/did_it_melt = T.ChangeTurf(T.baseturf)
		if(!did_it_melt.density) // In case some joker finds way to place these on indestructible walls
			chamber.visible_message(SPAN_WARNING("[chamber] melts through [T]!"))
		return

	var/heat_capacity = environment.heat_capacity()
	var/heat_change = max(chamber.heat_total / heat_capacity) * HEAT_MODIFIER // the hotter the rod, the hotter the air
	var/temp = environment.temperature()
	if(chamber.chamber_state == CHAMBER_UP) // Its not fully exposed yet, and heating the reactor
		heat_change *= 0.25
	heat_change = max(heat_change, 1) // Always heat up at least a little
	environment.set_temperature(temp + heat_change)

/// Calculate how much heat and energy we should be making
/obj/machinery/atmospherics/reactor_chamber/proc/calculate_stats(operating_rate = 0)
	power_total = (held_rod.power_amount * operating_rate)
	heat_total = (held_rod.heat_amount * operating_rate)

	power_mod_total = 1
	heat_mod_total = 1
	for(var/obj/machinery/atmospherics/reactor_chamber/chamber in neighbors)
		if(!chamber.held_rod || chamber.chamber_state == CHAMBER_OPEN)
			continue
		if(istype(chamber.held_rod, /obj/item/nuclear_rod/coolant) && !chamber.operational) // Do not apply negative heat gen on coolant when not on.
			heat_mod_total *= 1
		else if(held_rod.heat_amount > 0) // Do not multiply negative heat.
			heat_mod_total *= chamber.held_rod.current_heat_mod // We generate heat even when its not operational
		if(operational && chamber.chamber_state == CHAMBER_DOWN)
			if(held_rod.power_amount > 0) // Do not multiply negative power.
				power_mod_total *= chamber.held_rod.current_power_mod

	power_total *= power_mod_total
	heat_total *= heat_mod_total

/obj/machinery/atmospherics/reactor_chamber/proc/eject_rod()
	raise(FALSE)
	open(FALSE)
	var/datum/effect_system/smoke_spread/bad/smoke = new()
	smoke.set_up(5, FALSE, loc)
	smoke.start()
	var/rad_type = pick(ALPHA_RAD, BETA_RAD, GAMMA_RAD)
	for(var/turf/T in view(2, loc))
		T.contaminate_atom(src, 300, rad_type)
	var/distance_traveled = rand(10, 60)
	var/angle = rand(0, 360)
	var/turf/end = get_turf_in_angle(angle, loc, distance_traveled)
	var/obj/effect/immovablerod/nuclear_rod/nuclear_rod = new(loc, end)
	var/matrix/M = new
	M.Turn(angle)
	nuclear_rod.transform = M
	nuclear_rod.icon = held_rod.icon
	nuclear_rod.icon_state = held_rod.icon_state
	nuclear_rod.held_rod = held_rod
	held_rod.forceMove(src)
	held_rod = null
	update_icon(UPDATE_OVERLAYS)
	playsound(src, 'sound/effects/bang.ogg', 70, TRUE)
	audible_message(SPAN_USERDANGER("POW!"))

/obj/machinery/atmospherics/reactor_chamber/proc/weld_shut()
	welded = TRUE
	playsound(loc, 'sound/items/welder2.ogg', 60, TRUE)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/atmospherics/reactor_chamber/proc/unweld()
	welded = FALSE
	playsound(loc, 'sound/items/welder2.ogg', 60, TRUE)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/atmospherics/reactor_chamber/proc/burn_handler(mob/user)
	var/burn_damage = CHAMBER_HEAT_DAMAGE
	if(linked_reactor.check_overheating()) // Ouch, even hotter!
		burn_damage *= 2
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			if(G.max_heat_protection_temperature)
				burn_damage *= 0.5
			else if(HAS_TRAIT(H, TRAIT_RESISTHEAT) || HAS_TRAIT(H, TRAIT_RESISTHEATHANDS))
				burn_damage *= 0.5
		var/obj/item/organ/external/affecting = H.get_organ("[user.hand ? "l" : "r" ]_hand")
		if(affecting.receive_damage(0, burn_damage)) // Burn damage to them fingers
			H.UpdateDamageIcon()
			H.updatehealth()
	else if(isliving(user))
		var/mob/living/L = user
		if(issilicon(L)) // More resistant by default
			burn_damage *= 0.5
		L.adjustFireLoss(burn_damage)

/obj/machinery/atmospherics/reactor_chamber/proc/check_minimum_modifier()
	if(!linked_reactor)
		return
	if(!held_rod)
		return
	if(!held_rod.minimum_temp_modifier)
		return
	if(held_rod.minimum_temp_modifier >= linked_reactor.minimum_operating_temp)
		linked_reactor.update_minimum_temp()

/obj/effect/immovablerod/nuclear_rod
	name = "\improper Nuclear Coolant Rod"
	desc = "Getting hit by this might make you wish you got radiation sickness instead."
	notify = FALSE
	var/obj/held_rod

/// Lets not break the reactor with this.
/obj/effect/immovablerod/nuclear_rod/clong_thing(atom/victim)
	if(istype(victim, /obj/machinery/atmospherics/fission_reactor))
		return
	if(istype(victim, /obj/structure/filler))
		var/obj/structure/filler/filler = victim
		if(istype(filler.parent, /obj/machinery/atmospherics/fission_reactor))
			return
	if(istype(victim, /obj/machinery/atmospherics/reactor_chamber))
		return

	if(isobj(victim) && victim.density)
		victim.ex_act(EXPLODE_HEAVY)
	else if(ismob(victim))
		if(ishuman(victim))
			var/mob/living/carbon/human/H = victim
			H.visible_message(SPAN_DANGER("[H.name] is penetrated by an ejected coolant rod!"),
				SPAN_USERDANGER("The rod penetrates you!"),
				SPAN_DANGER("You hear a CLANG!"))
			H.adjustBruteLoss(100) // Not as strong as a normal rod
		if(victim.density || prob(20)) // We want to hit more things than a normal rod though
			victim.ex_act(EXPLODE_HEAVY)

/obj/effect/immovablerod/nuclear_rod/Move()
	. = ..()
	if(loc == end)
		qdel(src)

/obj/effect/immovablerod/nuclear_rod/Destroy()
	held_rod.forceMove(get_turf(src))
	return ..()

#undef CHAMBER_HEAT_DAMAGE
