GLOBAL_LIST_EMPTY(laser_terminals)

/obj/machinery/power/laser_terminal
	name = "Laser Terminal"
	desc = "A terminal designed to capture power sent by the power transmission laser"
	icon = 'icons/obj/machines/ptl_terminal.dmi'
	icon_state = "ptl_terminal_0"
	base_icon_state = "ptl_terminal_0"
	pixel_y = 10
	density = TRUE
	/// How much of the received energy we end up outputting to the grid
	var/conversion_efficiency = 0.5
	/// List of lasers targetting us
	var/list/lasers = list()
	/// The amount of power coming into the PTL
	var/total_input
	/// id of the terminal so you know which one you're targetting
	var/id = 0

/obj/item/circuitboard/machine/laser_terminal
	board_name = "Laser Terminal"
	icon_state = "engineering"
	build_path = /obj/machinery/power/laser_terminal
	origin_tech = "plasmatech=3; powerstorage=4"
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/capacitor = 2,
	)

/obj/machinery/power/laser_terminal/Initialize(mapload)
	. = ..()
	id = copytext(UID(), findlasttext(UID(), "_") + 1)
	GLOB.laser_terminals += src
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/laser_terminal(null)
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

/obj/machinery/power/laser_terminal/on_ptl_target(obj/machinery/power/transmission_laser/ptl)
	lasers |= ptl

/obj/machinery/power/laser_terminal/on_ptl_untarget(obj/machinery/power/transmission_laser/ptl)
	lasers -= ptl

/obj/machinery/power/laser_terminal/update_overlays()
	. = ..()
	if(total_input > 0)
		. += "ptl_terminal_graph"
		. += "ptl_terminal_blinkers"
		. += "ptl_terminal_light"
	switch(total_input)
		if(1 MW to 10 MW)
			. += "ptl_terminal_bar_1"
		if(10 MW to 20 MW)
			. += "ptl_terminal_bar_2"
		if(20 MW to 50 MW)
			. += "ptl_terminal_bar_3"
		if(50 MW to 100 MW)
			. += "ptl_terminal_bar_4"
		if(100 MW to 1 GW)
			. += "ptl_terminal_bar_5"
		if(1 GW to INFINITY)
			. += "ptl_terminal_bar_6"

/obj/machinery/power/laser_terminal/process()
	var/tick_input = 0
	for(var/obj/machinery/power/transmission_laser/ptl in lasers)
		if(ptl.firing)
			tick_input += ptl.output_level
	// We use another var so we don't zero total input since it's also used for other things that could potentially happen mid-process
	total_input = tick_input
	produce_direct_power(total_input * conversion_efficiency)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/power/laser_terminal/screwdriver_act(mob/living/user, obj/item/I)
	return default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), I)

/obj/machinery/power/laser_terminal/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(panel_open)
		to_chat(user, "<span class='warning'>Close the maintenance panel first!</span>")
		return
	. = default_unfasten_wrench(user, I, 2)
	if(anchored)
		connect_to_network()
	else
		disconnect_from_network()

/obj/machinery/power/laser_terminal/crowbar_act(mob/living/user, obj/item/I)
	return default_deconstruction_crowbar(user, I, FALSE)

/obj/machinery/power/laser_terminal/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	to_chat(user, chat_box_examine("<span class='notice'>Unit ID: [id]<br>Input Power: [DisplayPower(total_input)]<br>Output Power: [DisplayPower(total_input * conversion_efficiency)]</span>"))
