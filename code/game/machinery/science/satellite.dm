#define NODE_PROCESSING_COOLDOWN 6 SECONDS

/obj/machinery/science_satellite
	name = "satellite chassis"
	var/internal_name // to stop the handlabler
	icon = 'icons/obj/machines/science_satellite.dmi'
	icon_state = "satellite_closed"
	var/list/parts = new()
	desc = "A satellite chassis constructected from plasteel."
	anchored = FALSE
	density = 1
	var/obj/item/multitool/linked_multitool
	var/datum/satellite_stats/base_stats/satellite_stats = new()
	var/list/linked_consoles = new()
	var/list/maneuver_data = new()
	var/datum/orbit_data/orbit_data = new()
	var/status = "OK"
	var/collected_science_data = 0

	var/generators_in_use = 0

	var/list/recently_processed_weather_nodes = list()


/obj/machinery/science_satellite/Initialize(mapload)
	. = ..()
	internal_name = name
	orbit_data.stats = satellite_stats
	orbit_data.owner = src
	update_icon()
	SSscience_satellite.satellites += src

/obj/machinery/science_satellite/basic/Initialize(mapload)
	parts = list(
		new /obj/item/satellite_component/engine/basic_engine,
		new /obj/item/satellite_component/computer/basic
	)
	recalculate_stats()
	. = ..()

/obj/machinery/science_satellite/debug/Initialize(mapload)
	parts = list(
		new /obj/item/satellite_component/engine/basic_engine,
		new /obj/item/satellite_component/computer/science,
		new /obj/item/satellite_component/computer/science,
		new /obj/item/satellite_component/computer/science,
		new /obj/item/satellite_component/science_instrument/meteorological_surveyor,
		new /obj/item/satellite_component/science_instrument/plasma_lab,
		new /obj/item/satellite_component/science_instrument/magnetometer,
		new /obj/item/satellite_component/misc_part/solar_panel,
		new /obj/item/satellite_component/misc_part/solar_panel,
		new /obj/item/satellite_component/misc_part/solar_panel,
		new /obj/item/satellite_component/misc_part/solar_panel,
		new /obj/item/satellite_component/misc_part/power_cell,
		new /obj/item/satellite_component/misc_part/power_cell,
		new /obj/item/satellite_component/misc_part/power_cell,
		new /obj/item/satellite_component/misc_part/electric_generator,
		new /obj/item/satellite_component/misc_part/electric_generator,
		new /obj/item/satellite_component/misc_part/electric_generator
	)
	recalculate_stats()
	. = ..()

/obj/machinery/science_satellite/ion/Initialize(mapload)
	parts = list(
		new /obj/item/satellite_component/engine/ion_engine,
		new /obj/item/satellite_component/computer/efficient,
		new /obj/item/satellite_component/science_instrument/meteorological_surveyor,
		new /obj/item/satellite_component/science_instrument/plasma_lab,
		new /obj/item/satellite_component/science_instrument/magnetometer,
		new /obj/item/satellite_component/misc_part/solar_panel,
		new /obj/item/satellite_component/misc_part/solar_panel,
		new /obj/item/satellite_component/misc_part/solar_panel,
		new /obj/item/satellite_component/misc_part/solar_panel,
		new /obj/item/satellite_component/misc_part/electric_generator,
		new /obj/item/satellite_component/misc_part/electric_generator,
		new /obj/item/satellite_component/misc_part/electric_generator
	)
	recalculate_stats()
	. = ..()

/// Adds data to a satellite using its science multiplier
/obj/machinery/science_satellite/proc/collect_data(amount)
	collected_science_data += amount * satellite_stats.science_multiplier

/// Calculates the display message to give users in the UI
/obj/machinery/science_satellite/proc/calculate_status()
	status = "Idle"
	if(!orbit_data.position)
		status = "Waiting for launch"
	if(orbit_data.planned_maneuvers.len > 0)
		status = "Waiting for maneuver"
		if(is_performing_maneuver())
			status = "Performing maneuver"
	if(orbit_data.periapsis < orbit_data.light_airdrag)
		status = "Warning, expected air drag at periapsis"
	if(orbit_data.periapsis < orbit_data.thick_airdrag)
		status = "Danger! Periapsis inside atmosphere!"

/obj/machinery/science_satellite/proc/is_performing_maneuver()
	for(var/datum/maneuver_data/manuever in orbit_data.planned_maneuvers)
		if(manuever.world_time_at_maneuver < world.time)
			return TRUE

	return FALSE

/obj/machinery/science_satellite/proc/try_collecting_data_from_all_components(science_type, amount_to_collect, datum/weather_node/weather_node = null)
	if(weather_node in recently_processed_weather_nodes)
		return

	for(var/obj/item/satellite_component/component in parts)
		for(var/capability in component.component_stats.capabilities)
			if(!satellite_stats.enough_power_for_component_use(component)) // ddont check parts we dont have power to use
				continue
			else if(capability == science_type) // if we have power, and the type is a match
				collect_data(amount_to_collect)
				satellite_stats.current_power -= component.component_stats.power_consumption
				if(!weather_node)
					continue

				weather_node.science_yield *= weather_node.science_depletion_rate
				recently_processed_weather_nodes += weather_node

				// If SSscience_satellite is stopped and restarted this might allow collecting from the same node twice, low impact and unlikely to happen
				addtimer(CALLBACK(src, PROC_REF(remove_weather_node_from_processed), weather_node), NODE_PROCESSING_COOLDOWN)

/obj/machinery/science_satellite/proc/remove_weather_node_from_processed(datum/weather_node/weather_node)
	recently_processed_weather_nodes -= weather_node

/obj/machinery/science_satellite/update_overlays()
	. = ..()
	for(var/obj/item/satellite_component/part in parts)
		if(!part.overlay_icon)
			continue

		var/image/overlay_image = image(icon, part.overlay_icon)
		overlay_image.color = part.color
		. += overlay_image

/obj/machinery/science_satellite/proc/adjust_stats(obj/item/satellite_component/component, add = TRUE)

	if(!istype(component))
		return

	var/multiplier = (add)? 1 : -1 //if add is false, we're subtracting, which is the same as adding a negative number
	satellite_stats.weight += component.component_stats.weight * multiplier
	satellite_stats.fuel_efficiency += component.component_stats.fuel_efficiency * multiplier
	satellite_stats.fuel_capacity += component.component_stats.fuel_capacity * multiplier
	satellite_stats.science_multiplier += component.component_stats.science_multiplier * multiplier
	satellite_stats.passive_power_generation += component.component_stats.passive_power_generation * multiplier
	satellite_stats.active_power_generation += component.component_stats.active_power_generation * multiplier
	satellite_stats.power_consumption += component.component_stats.power_consumption * multiplier
	satellite_stats.power_capacity += component.component_stats.power_capacity * multiplier
	if(add)
		satellite_stats.capabilities += component.component_stats.capabilities
	else
		satellite_stats.capabilities -= component.component_stats.capabilities

	satellite_stats.current_fuel = satellite_stats.fuel_capacity
	satellite_stats.current_power = satellite_stats.power_capacity

	satellite_stats.update_fuel_usage()
	//satellite_stats.fuel_usage = (1 + satellite_stats.weight * 0.1) / satellite_stats.fuel_efficiency

/obj/machinery/science_satellite/proc/recalculate_stats()
	satellite_stats = new()

	for(var/obj/item/satellite_component/component in parts)
		adjust_stats(component)

/obj/machinery/science_satellite/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	default_deconstruction_screwdriver(user, "satellite_open", "satellite_closed", I)

/obj/machinery/science_satellite/crowbar_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return

	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	for(var/obj/item/satellite_component/component in parts)
		component.loc = get_turf(src)

	new /obj/item/stack/sheet/plasteel(loc, 10)
	default_deconstruction_crowbar(user, I)


/obj/machinery/science_satellite/multitool_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return

	if(!istype(I, /obj/item/multitool))
		return

	var/obj/item/multitool/multitool = I
	//if(multitool != linked_multitool) //if we try to load this satellite into a different multitool
	//	if(linked_multitool.buffer == src) //then we want to check if this satellite was also in the buffer of the previous multitool
	//		linked_multitool?.buffer = null //then clear the buffer of the previous multitool, so that the same satellite cant be linked to multiple consoles

	multitool.set_multitool_buffer(user, src)
	linked_multitool = multitool

/obj/machinery/science_satellite/Destroy(var/console_message = null)
	SSscience_satellite.satellites -= src
	for(var/obj/machinery/computer/science_collector/satellite_monitor/console in linked_consoles)
		console.linked_satellites -= src
		if(console_message)
			console.atom_say(console_message)
	. = ..()

/obj/machinery/science_satellite/attack_hand(mob/user)
	if(stat & (BROKEN | NOPOWER))
		return

	if(!panel_open)
		return

	var/new_name = tgui_input_text(user, "Input a new name for this satellite.", "Satellite name", internal_name)
	if (!new_name || !Adjacent(user))
		return

	to_chat(user, SPAN_NOTICE("You set the name of [src] to [new_name]."))
	name = new_name
	internal_name = new_name

/obj/machinery/science_satellite/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("<b>Click</b> with a multitool when the panel is open to store the satellite's connection data into the multitools buffer.")
	. += SPAN_NOTICE("<b>Click</b> with an empty hand when the panel is open to rename the satellite.")

#undef NODE_PROCESSING_COOLDOWN
