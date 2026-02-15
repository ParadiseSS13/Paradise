/obj/machinery/science_satellite
	name = "satellite chassis"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "autolathe"
	var/list/parts = new()
	desc = "A satellite chassis constructected from plasteel."
	anchored = FALSE
	density = 1
	var/obj/item/multitool/linked_multitool
	var/datum/satellite_stats/satellite_stats = new()
	var/current_power = 0
	var/current_fuel = 0
	var/list/linked_consoles = new()

/obj/machinery/science_satellite/Initialize(mapload)
	. = ..()

/obj/machinery/science_satellite/basic/Initialize(mapload)
	. = ..()
	parts = list(
		new /obj/item/satellite_component/engine/basic_engine,
		new /obj/item/satellite_component/computer/basic
	)
	//adjust_stats()

/obj/machinery/science_satellite/proc/adjust_stats(obj/item/satellite_component/component, add = TRUE)
	to_chat(usr, SPAN_NOTICE("add: [add]"))
	if(!istype(component))
		return

	var/multiplier = (add)? 1 : -1 //if add is false, we're subtracting, which is the same as adding a negative number
	satellite_stats.weight += component.component_stats.weight * multiplier
	satellite_stats.fuel_efficiency += component.component_stats.fuel_efficiency * multiplier
	satellite_stats.fuel_capacity += component.component_stats.fuel_capacity * multiplier
	satellite_stats.science_multiplier += component.component_stats.science_multiplier * multiplier
	satellite_stats.power_generation += component.component_stats.power_generation * multiplier
	satellite_stats.power_consumption += component.component_stats.power_consumption * multiplier
	satellite_stats.power_capacity += component.component_stats.power_capacity * multiplier

/obj/machinery/science_satellite/science/Initialize(mapload)
	. = ..()
	parts = list(
		new /obj/item/satellite_component/engine/small_engine,
		new /obj/item/satellite_component/computer/basic,
		new /obj/item/satellite_component/science_instrument/meteorological_surveyor,
		new /obj/item/satellite_component/science_instrument/plasma_lab,
		new /obj/item/satellite_component/science_instrument/magnetometer,
		new /obj/item/satellite_component/misc_part/solar_panel,
		new /obj/item/satellite_component/misc_part/solar_panel,
		new /obj/item/satellite_component/misc_part/solar_panel,
		new /obj/item/satellite_component/misc_part/solar_panel
	)

/obj/machinery/science_satellite/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", I)

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

/obj/machinery/science_satellite/Destroy()
	for(var/obj/machinery/computer/satellite_monitor/console in linked_consoles)
		console.linked_satellites -= src
	. = ..()

