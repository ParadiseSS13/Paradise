/obj/machinery/processing_node
	name = "Processing Node"
	desc = "Test Description"
	icon = 'icons/obj/machines/ai_machinery.dmi'
	icon_state = "processor-off"
	density = TRUE
	anchored = TRUE
	max_integrity = 100
	idle_power_consumption = 5
	active_power_consumption = 200
	/// Is the machine active
	var/active = FALSE
	/// What AI is this machine associated with
	var/mob/living/silicon/ai/assigned_ai = null

/obj/machinery/processing_node/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/processing_node(null)
	component_parts += new /obj/item/stock_parts/capacitor(null, 2)
	component_parts += new /obj/item/stack/sheet/mineral/gold(null, 10)
	component_parts += new /obj/item/stack/sheet/mineral/silver(null, 10)
	component_parts += new /obj/item/stack/sheet/mineral/diamond(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/processing_node/attack_hand(user as mob)
	to_chat(user, "<span class = 'notice'>You toggle the Processing Node from [active ? "On" : "Off"] to [active ? "Off" : "On"]</span>")
	active = !active
	if(active) // We're booting up
		// Find the AI with lowest memory
		for(var/mob/living/silicon/ai/new_ai in GLOB.ai_list)
			if(!assigned_ai) // Not found
				assigned_ai = new_ai // Assign to the first AI in the list to start
			if(assigned_ai.program_picker.memory > new_ai.program_picker.memory)
				assigned_ai = new_ai
		if(!assigned_ai) // No eligible AI found, abort
			active = FALSE
			to_chat(user, "<span class = 'warning'>ERROR: No AI detected. Shutting down...</span>")
			to_chat(user, "<span class = 'notice'>The Processing Node turns off.</span>")
		else // We have an AI, up its memory
			assigned_ai.program_picker.memory++
			change_power_mode(ACTIVE_POWER_USE)
	else // We're shutting down
		if(assigned_ai)
			assigned_ai.program_picker.memory--
			assigned_ai = null
		change_power_mode(IDLE_POWER_USE)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/processing_node/Destroy()
	. = ..()
	if(assigned_ai)
		assigned_ai.program_picker.memory--
		assigned_ai = null

/obj/machinery/processing_node/on_deconstruction()
	. = ..()
	if(assigned_ai)
		assigned_ai.program_picker.memory--
		assigned_ai = null

/obj/machinery/processing_node/update_icon_state()
	. = ..()
	icon_state = "processor-[active ? "on" : "off"]"
