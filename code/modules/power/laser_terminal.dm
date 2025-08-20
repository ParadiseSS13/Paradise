GLOBAL_LIST_EMPTY(laser_terminals)

/obj/machinery/power/laser_terminal
	name = "Laser Terminal"
	desc = "A terminal designed to capture power sent by the power transmission laser"
	icon = 'icons/obj/machines/ptl_terminal.dmi'
	icon_state = "ptl_terminal_0"
	base_icon_state = "ptl_terminal_0"
	pixel_y = 10
	var/conversion_efficiency = 0.5

/obj/machinery/power/laser_terminal/Initialize(mapload)
	. = ..()
	UID()
	GLOB.laser_terminals += src
	component_parts = list()
	component_parts += new /obj/item/circuitboard/laser_terminal(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()
	connect_to_network()

/obj/machinery/power/laser_terminal/Destroy()
	GLOB.laser_terminals -= src
	. = ..()

/obj/machinery/power/laser_terminal/RefreshParts()
	var/cap_rating = 0
	for(var/obj/item/stock_parts/capacitor/cap in component_parts)
		cap_rating += cap.rating
	// Goes from half to full conversion depending on capacitor level
	conversion_efficiency = cap_rating / 8

/obj/machinery/power/laser_terminal/on_ptl_tick(obj/machinery/power/transmission_laser/ptl, output_level)
	produce_direct_power(output_level * WATT_TICK_TO_JOULE * conversion_efficiency)
