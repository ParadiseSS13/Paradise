/obj/machinery/science_satellite
	name = "satellite chassis"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "autolathe"
	var/list/parts
	desc = "A satellite chassis constructected from plasteel."
	anchored = FALSE
	density = 1
	var/obj/item/multitool/linked_multitool

/obj/machinery/science_satellite/Initialize(mapload)
	. = ..()
	parts = list()

/obj/machinery/science_satellite/basic/Initialize(mapload)
	. = ..()
	parts = list(
		/obj/item/satellite_component/engine/basic_engine,
		/obj/item/satellite_component/computer/basic
	)

/obj/machinery/science_satellite/science/Initialize(mapload)
	. = ..()
	parts = list(
		/obj/item/satellite_component/engine/basic/small_engine,
		/obj/item/satellite_component/computer/basic,
		/obj/item/satellite_component/meteorological_surveyor,
		/obj/item/satellite_component/plasma_lab,
		/obj/item/satellite_component/magnetometer,
		/obj/item/satellite_component/solar_panel,
		/obj/item/satellite_component/solar_panel,
		/obj/item/satellite_component/solar_panel,
		/obj/item/satellite_component/solar_panel
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
