/obj/machinery/ai_node
	name = "AI Node"
	desc = "If you see me, make an issue report!"
	icon = 'icons/obj/machines/ai_machinery.dmi'
	icon_state = "processor-off"
	density = TRUE
	anchored = TRUE
	max_integrity = 100
	idle_power_consumption = 5
	active_power_consumption = 250
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
	/// Used to ensure it takes a few seconds of being hot before overheating
	var/overheat_counter = 0
	/// How efficient is this machine?
	var/efficiency = 1

/obj/machinery/ai_node/process()
	..()
	if(active)
		var/datum/milla_safe/ai_node_process/milla = new()
		milla.invoke_async(src)

/obj/machinery/ai_node/Destroy()
	. = ..()
	if(assigned_ai)
		assigned_ai.program_picker.modify_resource(resource_key, -resource_amount)
		assigned_ai = null

/obj/machinery/ai_node/on_deconstruction()
	. = ..()
	if(assigned_ai)
		assigned_ai.program_picker.modify_resource(resource_key, -resource_amount)
		assigned_ai = null

/obj/machinery/ai_node/update_icon_state()
	. = ..()
	if(overheating)
		icon_state = "[icon_base]-hot"
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
	update_idle_power_consumption(power_channel, initial(idle_power_consumption) * efficiency)
	update_active_power_consumption(power_channel, initial(active_power_consumption) * efficiency)
	var/old_resource_amount = resource_amount
	resource_amount = round_down(initial(resource_amount) * efficiency)
	// Adjust the resources of the connected AI if the machine is on
	if(assigned_ai)
		assigned_ai.program_picker.modify_resource(resource_key, (resource_amount - old_resource_amount))

/obj/machinery/ai_node/attack_hand(user as mob)
	if(overheating)
		to_chat(user, "<span class = 'notice'>You turn the overheating [src] off.</span>")
		overheating = FALSE
		update_icon(UPDATE_ICON_STATE)
		return
	active = !active
	to_chat(user, "<span class = 'notice'>You turn the [src] [active ? "On" : "Off"]</span>")
	if(active) // We're booting up
		find_ai()
		if(!assigned_ai) // No eligible AI found, abort
			active = FALSE
			to_chat(user, "<span class = 'warning'>ERROR: No AI detected. Shutting down...</span>")
			to_chat(user, "<span class = 'notice'>The Processing Node turns off.</span>")
		else // We have an AI
			assigned_ai.program_picker.modify_resource(resource_key, resource_amount)
			change_power_mode(ACTIVE_POWER_USE)
	else // We're shutting down
		if(assigned_ai)
			assigned_ai.program_picker.modify_resource(resource_key, -resource_amount)
			assigned_ai = null
		change_power_mode(IDLE_POWER_USE)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/ai_node/proc/find_ai()
	if(!resource_key)
		return
	for(var/mob/living/silicon/ai/new_ai in GLOB.ai_list)
		if(!assigned_ai) // Not found
			assigned_ai = new_ai // Assign to the first AI in the list to start
			continue
		if(resource_key == "memory" && assigned_ai.program_picker.memory > new_ai.program_picker.memory)
			assigned_ai = new_ai
			continue
		if(resource_key == "bandwidth" && assigned_ai.program_picker.bandwidth > new_ai.program_picker.bandwidth)
			assigned_ai = new_ai

/obj/machinery/ai_node/proc/Overheat()
	active = FALSE
	if(assigned_ai)
		assigned_ai.program_picker.modify_resource(resource_key, -resource_amount)
		assigned_ai = null
	obj_integrity -= 34 // Overheat it three times and it breaks
	change_power_mode(IDLE_POWER_USE)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/ai_node/proc/change_ai(mob/living/silicon/ai/new_ai)
	if(!new_ai)
		return
	if(!istype(new_ai))
		return
	assigned_ai.program_picker.modify_resource(resource_key, -resource_amount)
	assigned_ai = new_ai
	assigned_ai.program_picker.modify_resource(resource_key, resource_amount)

/datum/milla_safe/ai_node_process

/datum/milla_safe/ai_node_process/on_run(obj/machinery/ai_node/node)
	var/turf/simulated/L = get_turf(node)
	if(!istype(L))
		return
	var/datum/gas_mixture/env = get_turf_air(L)
	var/transfer_moles = 0.25 * env.total_moles()
	var/datum/gas_mixture/removed = env.remove(transfer_moles)
	if(!removed)
		return
	var/heat_capacity = removed.heat_capacity()
	if(heat_capacity)
		removed.set_temperature(removed.temperature() + node.heat_amount / heat_capacity)
	env.merge(removed)
	// Heat check
	if(env.temperature() > 373 || env.temperature() < 273) // If the temperature is outside 0-100C...
		// Turn the node off due to temperature problems
		node.overheat_counter++
		if(node.overheat_counter >= 5)
			node.Overheat()
		return
	node.overheat_counter--

/obj/machinery/ai_node/processing_node
	name = "processing node"
	desc = "Highly advanced machinery with a manual switch. While running, it grants an AI memory."
	icon = 'icons/obj/machines/ai_machinery.dmi'
	icon_state = "processor-off"
	resource_key = "memory"
	icon_base = "processor"

/obj/machinery/ai_node/processing_node/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/processing_node(null)
	component_parts += new /obj/item/stock_parts/capacitor(null, 2)
	component_parts += new /obj/item/stack/sheet/mineral/gold(null, 10)
	component_parts += new /obj/item/stack/sheet/mineral/silver(null, 10)
	component_parts += new /obj/item/stack/sheet/mineral/diamond(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/ai_node/network_node
	name = "network node"
	desc = "Highly advanced machinery with an on/off switch. While running, it grants an AI bandwidth."
	icon = 'icons/obj/machines/ai_machinery.dmi'
	icon_state = "network-off"
	resource_key = "bandwidth"
	icon_base = "network"

/obj/machinery/ai_node/network_node/examine_more(mob/user)
	. = ..()
	. += "I don't know but I've been told\
	Captain's got a network node!\
	Likes to press the on/off switch!\
	Dig that crazy corporate snitch!"

/obj/machinery/ai_node/network_node/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/network_node(null)
	component_parts += new /obj/item/stock_parts/capacitor(null, 2)
	component_parts += new /obj/item/stack/sheet/mineral/gold(null, 10)
	component_parts += new /obj/item/stack/sheet/mineral/silver(null, 10)
	component_parts += new /obj/item/stack/sheet/mineral/diamond(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/computer/ai_resource_console
	name = "AI resource control console"
	desc = "Used to reassign memory and bandwidth between multiple AI units."
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "tech_key"
	icon_screen = "ai_resource"
	req_access = list(ACCESS_RD)
	circuit = /obj/item/circuitboard/ai_resource_console
	light_color = LIGHT_COLOR_PURPLE

/obj/machinery/computer/ai_resource/attack_ai(mob/user as mob) // Bad AI, no access to stealing resources
	return

/obj/machinery/computer/ai_resource/attack_hand(mob/user as mob)
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
		ui = new(user, src, "RoboticsControlConsole", name)
		ui.open()

/obj/machinery/computer/ai_resource/ui_data(mob/user)
	var/list/data = list()
	data["auth"] = is_authenticated(user)
	data["ais"] = list()
	for(var/mob/living/silicon/ai/A in GLOB.ai_list)
		var/list/ai_data = list(
			name = A.name,
			uid = A.UID(),
			memory = A.program_picker.memory,
			memory_max = A.program_picker.total_memory,
			bandwidth = A.program_picker.bandwidth,
			bandwidth_max = A.program_picker.total_bandwidth
		)
		data["ais"] += list(ai_data)
	return data

/obj/machinery/computer/ai_resource/ui_act(action, params)
	if(..())
		return
	. = FALSE
	if(!is_authenticated(usr))
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return
	if(SSticker.current_state == GAME_STATE_FINISHED)
		to_chat(usr, "<span class='warning'>Access denied, AIs are no longer your station's property.</span>")
		return
