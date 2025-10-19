/// Stores a list of all AI resource nodes
GLOBAL_LIST_EMPTY(ai_nodes)

#define ALLOCATED_RESOURCES 0
#define ONLINE_NODES 		1

/obj/machinery/ai_node
	name = "AI Node"
	desc = "If you see me, make an issue report!"
	icon = 'icons/obj/machines/ai_machinery.dmi'
	icon_state = "processor-off"
	density = TRUE
	anchored = TRUE
	max_integrity = 100
	idle_power_consumption = 5
	active_power_consumption = 750
	var/icon_base
	/// Is the machine active
	var/active = FALSE
	/// What AI is this machine associated with
	var/mob/living/silicon/ai/assigned_ai = null
	/// Identifier for what resource to remove
	var/resource_key
	/// How much resources does this machine provide
	var/resource_amount = 1
	/// How much heat does this put out?
	var/heat_amount = 25000
	/// Are we overheating?
	var/overheating = FALSE
	// What's the overheat temperature?
	var/overheat_temp = 324
	/// Used to ensure it takes a few seconds of being hot before overheating
	var/overheat_counter = 0
	/// How efficient is this machine?
	var/efficiency = 1
	/// Milla controller
	var/datum/milla_safe/ai_node_process/milla = new()


/obj/machinery/ai_node/Initialize(mapload)
	. = ..()
	GLOB.ai_nodes += src

/obj/machinery/ai_node/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This machine is temperature sensitive. Any temperature colder than 273K will freeze it, whle any temperature higher than [overheat_temp]K will cause it to overheat.</span>"

/obj/machinery/ai_node/process()
	..()
	if(active)
		if(stat & NOPOWER)
			atom_say("ERROR: Insufficient power! Shutting down...")
			turn_off()
			return
		milla.invoke_async(src)

/obj/machinery/ai_node/Destroy()
	. = ..()
	turn_off()
	GLOB.ai_nodes -= src

/obj/machinery/ai_node/on_deconstruction()
	. = ..()
	if(assigned_ai)
		assigned_ai.program_picker.modify_resource(resource_key, -resource_amount)
		assigned_ai = null
	GLOB.ai_nodes -= src

/obj/machinery/ai_node/screwdriver_act(mob/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	. = TRUE
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)

/obj/machinery/ai_node/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/ai_node/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/ai_node/update_icon_state()
	. = ..()
	if(overheating)
		icon_state = "[icon_base]-hot"
		return
	if(panel_open)
		icon_state = "[icon_base]-open"
		return
	icon_state = "[icon_base]-[active ? "on" : "off"]"

/obj/machinery/ai_node/attack_ai(mob/user)
	return

/obj/machinery/ai_node/RefreshParts()
	. = ..()
	var/E
	for(var/obj/item/stock_parts/capacitor/M in component_parts)
		E += M.rating
	efficiency = E / 2
	// Adjust values according to the new stock parts.
	heat_amount = initial(heat_amount) * efficiency
	overheat_temp = initial(overheat_temp) + (50 * efficiency)
	update_idle_power_consumption(power_channel, initial(idle_power_consumption) * efficiency)
	update_active_power_consumption(power_channel, initial(active_power_consumption) * efficiency)
	var/old_resource_amount = resource_amount
	resource_amount = round_down(initial(resource_amount) * efficiency)
	// Adjust the resources of the connected AI if the machine is on
	if(assigned_ai)
		assigned_ai.program_picker.modify_resource(resource_key, (resource_amount - old_resource_amount))

/obj/machinery/ai_node/attack_hand(user as mob)
	toggle(user)

/obj/machinery/ai_node/proc/toggle(mob/user = null)
	if(overheating)
		if(user)
			to_chat(user, "<span class='notice'>You turn the overheating [src] off.</span>")
		overheating = FALSE
		update_icon(UPDATE_ICON_STATE)
		return
	active = !active
	if(user)
		to_chat(user, "<span class='notice'>You turn [src] [active ? "on" : "off"].</span>")
	if(active) // We're booting up
		refresh_ai()
	else // We're shutting down
		turn_off()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/ai_node/proc/refresh_ai()
	assigned_ai = null
	find_ai()
	if(!assigned_ai) // No eligible AI found, abort
		active = FALSE
		atom_say("ERROR: No AI detected. Shutting down...")
		turn_off()
	else // We have an AI
		assigned_ai.program_picker.modify_resource(resource_key, resource_amount)
		var/area/our_area = get_area(src)
		to_chat(assigned_ai, "<span class='notice'>New server node connected at: [our_area.name].</span>")
		change_power_mode(ACTIVE_POWER_USE)
		update_icon(UPDATE_ICON_STATE)

/obj/machinery/ai_node/proc/turn_off()
	active = FALSE
	if(assigned_ai)
		assigned_ai.program_picker.modify_resource(resource_key, -resource_amount)
		var/area/our_area = get_area(src)
		to_chat(assigned_ai, "<span class='warning'>Server node disconnected at: [our_area.name]!</span>")
		assigned_ai = null
	change_power_mode(IDLE_POWER_USE)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/ai_node/proc/find_ai()
	if(!resource_key)
		return
	for(var/mob/living/silicon/ai/new_ai as anything in GLOB.ai_list)
		if(new_ai.stat || new_ai.in_storage || new_ai.shunted)
			continue
		if(istype(new_ai.loc, /obj/machinery/power/apc))
			continue
		if(!assigned_ai) // Not found
			assigned_ai = new_ai // Assign to the first AI in the list to start
			continue
		if(resource_key == "memory" && assigned_ai.program_picker.memory > new_ai.program_picker.memory)
			assigned_ai = new_ai
			continue
		if(resource_key == "bandwidth" && assigned_ai.program_picker.bandwidth > new_ai.program_picker.bandwidth)
			assigned_ai = new_ai

/obj/machinery/ai_node/proc/overheat()
	turn_off()
	atom_say("ERROR: Heat critical!")
	obj_integrity -= (max_integrity / 3) // Overheat it three times and it breaks
	change_power_mode(IDLE_POWER_USE)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/ai_node/proc/change_ai(mob/living/silicon/ai/new_ai)
	if(!new_ai)
		return
	if(!istype(new_ai))
		return
	var/area/our_area = get_area(src)
	assigned_ai.program_picker.modify_resource(resource_key, -resource_amount)
	to_chat(assigned_ai, "<span class='warning'>Server node disconnected at: [our_area.name]!</span>")
	assigned_ai = new_ai
	assigned_ai.program_picker.modify_resource(resource_key, resource_amount)
	to_chat(assigned_ai, "<span class='notice'>New server node connected at: [our_area.name].</span>")

/datum/milla_safe/ai_node_process

/datum/milla_safe/ai_node_process/on_run(obj/machinery/ai_node/node)
	var/turf/simulated/L = get_turf(node)
	if(!istype(L))
		return
	var/datum/gas_mixture/env = get_turf_air(L)
	var/transfer_moles = 0.25 * env.total_moles()
	var/datum/gas_mixture/removed = env.remove(transfer_moles)
	if(!removed)
		node.overheat_counter++
		if(node.overheat_counter >= 5)
			node.overheat()
		return
	var/heat_capacity = removed.heat_capacity()
	if(heat_capacity)
		removed.set_temperature(removed.temperature() + node.heat_amount / heat_capacity)
	env.merge(removed)
	// Heat check
	if(env.temperature() > node.overheat_temp || env.temperature() < 273) // If the temperature is outside 0-100C...
		// Turn the node off due to temperature problems
		node.overheat_counter++
		if(node.overheat_counter >= 5)
			node.overheat()
		return
	if(node.overheat_counter)
		node.overheat_counter--

/obj/machinery/ai_node/processing_node
	name = "processing node"
	desc = "A rack of processors with a manual on/off switch. While running, it grants an AI memory."
	resource_key = "memory"
	icon_base = "processor"

/obj/machinery/ai_node/processing_node/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/processing_node(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stack/sheet/mineral/gold(null)
	component_parts += new /obj/item/stack/sheet/mineral/silver(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	component_parts += new /obj/item/stack/sheet/mineral/diamond(null)
	RefreshParts()

/obj/machinery/ai_node/network_node
	name = "network node"
	desc = "A rack of servers with a manual on/off switch. While running, it grants an AI bandwidth."
	icon_state = "network-off"
	resource_key = "bandwidth"
	icon_base = "network"

/obj/machinery/ai_node/network_node/examine_more(mob/user)
	. = ..()
	. += "I don't know but I've been told, \
	Captain's got a network node, \
	Likes to press the on/off switch, \
	Dig that crazy corporate snitch!"

/obj/machinery/ai_node/network_node/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/network_node(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stack/sheet/mineral/gold(null)
	component_parts += new /obj/item/stack/sheet/mineral/silver(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	component_parts += new /obj/item/stack/sheet/mineral/diamond(null)
	RefreshParts()

/obj/machinery/computer/ai_resource
	name = "AI Resource Control Console"
	desc = "Used to reassign memory and bandwidth between multiple AI units."
	icon_keyboard = "rd_key"
	icon_screen = "ai_resource"
	req_access = list(ACCESS_RD)
	circuit = /obj/item/circuitboard/ai_resource_console
	light_color = LIGHT_COLOR_PURPLE
	/// UI Screen Index
	var/screen = ALLOCATED_RESOURCES

/obj/machinery/computer/ai_resource/attack_ai(mob/user) // Bad AI, no access to stealing resources
	to_chat(user, "<span class='warning'>ERROR: Firewall blocked! Station AI's are not permitted to interface with this console!</span>")
	return

/obj/machinery/computer/ai_resource/attack_hand(mob/user)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	ui_interact(user)

/obj/machinery/computer/ai_resource/proc/is_authenticated(mob/user)
	if(!istype(user))
		return FALSE
	if(user.can_admin_interact())
		return TRUE
	if(allowed(user))
		return TRUE
	return FALSE

/obj/machinery/computer/ai_resource/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/ai_resource/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AIResourceManagementConsole", name)
		ui.open()

/obj/machinery/computer/ai_resource/ui_data(mob/user)
	var/list/data = list()
	data["auth"] = is_authenticated(user)
	data["screen"] = screen
	data["ai_list"] = list()
	data["nodes_list"] = list()
	for(var/mob/living/silicon/ai/A in GLOB.ai_list)
		if(istype(A.loc, /obj/machinery/power/apc)) // AIs in APCs as malf should be hidden
			continue
		if(A.shunted)
			continue
		var/list/ai_data = list(
			"name" = A.name,
			"uid" = A.UID(),
			"memory" = A.program_picker.memory,
			"memory_max" = A.program_picker.total_memory,
			"bandwidth" = A.program_picker.bandwidth,
			"bandwidth_max" = A.program_picker.total_bandwidth
		)
		data["ai_list"] += list(ai_data)
	for(var/obj/machinery/ai_node/node as anything in GLOB.ai_nodes)
		var/list/node_data = list(
			"name" = node.name,
			"uid" = node.UID(),
			"resource" = node.resource_key,
			"amount" = node.resource_amount,
			"assigned_ai" = node.assigned_ai
		)
		data["nodes_list"] += list(node_data)
	return data

/obj/machinery/computer/ai_resource/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	. = FALSE
	if(!is_authenticated(ui.user))
		to_chat(ui.user, "<span class='warning'>Access denied.</span>")
		return
	if(SSticker.current_state == GAME_STATE_FINISHED)
		to_chat(ui.user, "<span class='warning'>Access denied, AIs are no longer your station's property.</span>")
		return

	switch(action)
		if("menu")
			switch(text2num(params["screen"]))
				if(ALLOCATED_RESOURCES)
					screen = ALLOCATED_RESOURCES
					return TRUE
				if(ONLINE_NODES)
					screen = ONLINE_NODES
					return TRUE
		if("reassign")
			if(!length(GLOB.ai_list))
				return FALSE
			var/list/ais = list()
			for(var/mob/living/silicon/ai/new_ai as anything in GLOB.ai_list)
				if(new_ai.stat || new_ai.in_storage || new_ai.shunted)
					continue
				if(istype(new_ai.loc, /obj/machinery/power/apc))
					continue
				ais += new_ai
			var/new_ai = tgui_input_list(usr, "Pick a new AI", "AI Selector", ais)
			if(!new_ai)
				return FALSE
			var/obj/machinery/ai_node/selected_node = locateUID(params["uid"])
			if(!selected_node)
				return FALSE
			selected_node.change_ai(new_ai)
			return TRUE

#undef ALLOCATED_RESOURCES
#undef ONLINE_NODES
