#define MINIMUM_MOLES 3 //! the minimum amount of moles we transfer, regardless of pressure on the other side.

/obj/machinery/atmospherics/unary/reactor_gas_node
	name = "reactor gas intake"
	desc = "A sturdy-looking gas inlet that injects gas into the reactor."
	icon = 'icons/obj/fission/reactor_machines.dmi'
	icon_state = "gas_node"
	layer = GAS_PIPE_VISIBLE_LAYER
	max_integrity = 2000
	target_pressure = 100000 // Maximum pressure in KPA
	flags_2 = NO_MALF_EFFECT_2

	/// Hold which reactor the intake is connected to.
	var/obj/machinery/atmospherics/fission_reactor/linked_reactor
	/// Is this vent taking air in or out. TRUE by default.
	var/intake_vent = TRUE

/obj/machinery/atmospherics/unary/reactor_gas_node/output
	name = "Reactor Gas Extractor"
	intake_vent = FALSE

/obj/machinery/atmospherics/unary/reactor_gas_node/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/reactor_gas_node(src)
	component_parts += new /obj/item/stack/sheet/metal(src, 2)
	component_parts += new /obj/item/stack/cable_coil(src, 2)
	initialize_directions = dir
	RefreshParts()
	update_icon()
	return INITIALIZE_HINT_LATELOAD

// Needs lateload to prevent reactor not being initialized yet and thus not able to set the link.
/obj/machinery/atmospherics/unary/reactor_gas_node/LateInitialize()
	. = ..()
	form_link(TRUE)

/obj/machinery/atmospherics/unary/reactor_gas_node/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("A wrench can be used to alter the direction of the node.")
	. += SPAN_NOTICE("Gas nodes will only link with reactors when facing a reactor from the side opposite of the inlet pipe.")

/obj/machinery/atmospherics/unary/reactor_gas_node/process_atmos()
	if(stat & (NOPOWER|BROKEN))
		return FALSE
	if(!linked_reactor)
		return FALSE
	if(linked_reactor.admin_intervention)
		return FALSE
	if(linked_reactor.safety_override) // We dont want to cool down an intentional runaway reactor
		return FALSE
	var/datum/gas_mixture/network1
	var/datum/gas_mixture/network2

	if(intake_vent)
		network1 = linked_reactor.air_contents
		network2 = air_contents
	else
		network1 = air_contents
		network2 = linked_reactor.air_contents

	if(!network1 || !network2)
		return FALSE

	// This is basically passive gate code
	var/output_starting_pressure = network1.return_pressure()
	var/input_starting_pressure = network2.return_pressure()

	// Calculate necessary moles to transfer using PV = nRT
	if((network2.total_moles() > 0) && (network2.temperature() > 0))
		var/pressure_delta = min(target_pressure - output_starting_pressure, (input_starting_pressure - output_starting_pressure) / 2)
		if(intake_vent)
			pressure_delta = max(pressure_delta, MINIMUM_MOLES) // Always work at least a little bit when inputting gas
		var/transfer_moles = pressure_delta * network1.volume / (network2.temperature() * R_IDEAL_GAS_EQUATION)

		// Actually transfer the gas
		var/datum/gas_mixture/removed = network2.remove(transfer_moles)
		network1.merge(removed)

		parent.update = TRUE

	return TRUE

/obj/machinery/atmospherics/unary/reactor_gas_node/screwdriver_act(mob/living/user, obj/item/I)
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)

/obj/machinery/atmospherics/unary/reactor_gas_node/crowbar_act(mob/living/user, obj/item/I)
	to_chat(user, SPAN_INFORMATION("You begin to pry out the internal piping..."))
	if(I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume))
		default_deconstruction_crowbar(user, I)

/obj/machinery/atmospherics/unary/reactor_gas_node/wrench_act(mob/user, obj/item/I)
	var/list/choices = list("West" = WEST, "East" = EAST, "South" = SOUTH, "North" = NORTH)
	var/selected = tgui_input_list(user, "Select a direction for the connector.", "Connector Direction", choices)
	if(!selected)
		return ITEM_INTERACT_COMPLETE
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume))
		return ITEM_INTERACT_COMPLETE
	if(!Adjacent(user))
		to_chat(user, SPAN_WARNING("You moved away before construction was finished!"))
		return ITEM_INTERACT_COMPLETE
	dir = choices[selected]
	initialize_directions = dir
	for(var/obj/machinery/atmospherics/target in get_step(src, dir))
		if(target.initialize_directions & get_dir(target,src))
			node = target
			break
	form_link(FALSE)
	initialize_atmos_network()
	update_icon()
	return ITEM_INTERACT_COMPLETE

/obj/machinery/atmospherics/unary/reactor_gas_node/proc/form_link(silent = FALSE)
	linked_reactor = null
	var/turf/T = get_step(src, REVERSE_DIR(dir))
	for(var/obj/machinery/atmospherics/fission_reactor/reactor in T)
		linked_reactor = reactor
	for(var/obj/structure/filler/filler in T)
		if(istype(filler.parent, /obj/machinery/atmospherics/fission_reactor))
			linked_reactor = filler.parent
	if(silent)
		return
	if(!linked_reactor)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		audible_message(SPAN_INFO("The gas node buzzes as it fails to connect to a reactor."))
	else
		playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
		audible_message(SPAN_INFO("The gas node pings as it connects to the reactor."))

/obj/machinery/atmospherics/unary/reactor_gas_node/multitool_act(mob/living/user, obj/item/I)
	to_chat(user, SPAN_INFORMATION("You begin to reverse the gas flow direction..."))
	if(do_after_once(user, 1 SECONDS, TRUE, src, allow_moving = FALSE))
		intake_vent = !intake_vent
		if(intake_vent)
			name = "Reactor Gas Intake"
		else
			name = "Reactor Gas Extractor"
	return ..()

#undef MINIMUM_MOLES
