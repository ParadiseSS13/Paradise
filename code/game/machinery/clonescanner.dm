/obj/machinery/clonescanner
	name = "cloning scanner"
	desc = "An advanced machine that thoroughly scans the current state of a cadaver for use in cloning."
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "scanner_0" //temp.. maybe? probably? i dunno
	density = TRUE
	anchored = TRUE

	//The linked cloning console.
	var/obj/machinery/computer/cloning/console

/obj/machinery/clonescanner/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/clonescanner(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	update_icon()

/obj/machinery/clonescanner/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/M = I
	M.set_multitool_buffer(user, src)
