/obj/machinery/science_satellite
	name = "satellite chassis"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "autolathe"
	var/list/parts
	desc = "A satellite chassis constructected from plasteel."
	anchored = FALSE
	density = 1

/obj/machinery/science_satellite/Initialize(mapload)
	. = ..()
	to_chat(usr, SPAN_DEBUG("Created [src]"))
	parts = list()

/obj/machinery/science_satellite/screwdriver_act(mob/living/user, obj/item/I)
	to_chat(user, SPAN_DEBUG("screwdriver act. Panel: [panel_open]"))
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", I)

/obj/machinery/science_satellite/crowbar_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return

	to_chat(user, SPAN_DEBUG("crowbar act. Panel: [panel_open]"))
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	for(var/obj/item/satellite_component/component in parts)
		component.loc = get_turf(src)
		//var/obj/item/satellite_component/new_component = new typeof(component)
		//new_component.loc = src.loc
	new /obj/item/stack/sheet/plasteel(loc, 10)
	default_deconstruction_crowbar(user, I)


/obj/machinery/science_satellite/multitool_act(mob/living/user, obj/item/I)
	to_chat(user, SPAN_DEBUG("multitool act. Panel: [panel_open]"))
