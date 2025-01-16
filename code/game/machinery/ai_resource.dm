/obj/machinery/processingnode
	name = "Processing Node"
	desc = "Test Description"
	icon = 'icons/obj/machines/ai_machinery.dmi'
	icon_state = "processor-off"
	density = TRUE
	anchored = TRUE
	max_integrity = 100
	idle_power_consumption = 5
	active_power_consumption = 200

	var/active = FALSE
	var/mob/living/silicon/ai/assigned_ai = null

/obj/machinery/processingnode/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/processingnode(null)
	component_parts += new /obj/item/stock_parts/capacitor(null, 2)
	component_parts += new /obj/item/stack/sheet/mineral/gold(null, 10)
	component_parts += new /obj/item/stack/sheet/mineral/silver(null, 10)
	component_parts += new /obj/item/stack/sheet/mineral/diamond(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/processingnode/attack_hand(user as mob)
	to_chat(user, "<span class = 'notice'>You toggle the Processing Node from [active ? "On" : "Off"] to [active ? "Off" : "On"]</span>")
	active = !active
	if(active) // We're booting up
		// Find the AI with lowest memory
		for(var/mob/living/silicon/ai/new_ai in GLOB.ai_list)
			if(!assigned_ai) //not found
				assigned_ai = new_ai //search for new in global ai list
			if(assigned_ai.program_picker.memory > new_ai.program_picker.memory)
				assigned_ai = new_ai

		if(!assigned_ai) // No eligible AI found, abort
			active = FALSE
			to_chat(user, "<span class = 'warning'>ERROR: No AI detected. Shutting down...</span>")
			to_chat(user, "<span class = 'notice'>The Processing Node turns off.</span>")
		else // We have an AI, up its memory
			assigned_ai.program_picker.memory++

	else // We're shutting down
		// TODO rest of shutting down code
		assigned_ai.program_picker.memory--
		assigned_ai = null
		to_chat(user, "Turning off")
	update_icon(UPDATE_ICON_STATE)
	if(assigned_ai)
		// "destroyed" "do"
		// assigned_ai.program_picker.memory--
		// assigned_ai = null

/obj/machinery/processingnode/update_icon_state()
	icon_state = "processor-[active ? "on" : "off"]"
