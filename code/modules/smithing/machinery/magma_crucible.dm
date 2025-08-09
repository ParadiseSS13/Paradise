/obj/machinery/magma_crucible
	name = "magma crucible"
	desc = "A massive machine that smelts down raw ore into a fine slurry, then sorts it into respective tanks for storage and use."
	icon = 'icons/obj/machines/magma_crucible.dmi'
	icon_state = "crucible"
	max_integrity = 300
	pixel_y = -32
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF
	/// Sheet multiplier applied when smelting ore.
	var/sheet_per_ore = 1
	/// State for adding ore
	var/adding_ore
	/// State for if ore is being taken from it
	var/pouring
	/// How many outputs are we pouring to? Do not stop animating until we are no longer pouring.
	var/number_of_pours = 0
	/// List of linked machines
	var/list/linked_machines = list()

/obj/machinery/magma_crucible/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_BLUESPACE, MAT_PALLADIUM, MAT_IRIDIUM, MAT_PLATINUM, MAT_BRASS), INFINITY, FALSE, list(/obj/item/stack, /obj/item/smithed_item), null, null)
	AddComponent(/datum/component/multitile, list(
		list(1,				1,	1),
		list(MACH_CENTER,	1,	1),
		list(1,				1,	1),
	))
	// Stock parts
	component_parts = list()
	component_parts += new /obj/item/circuitboard/magma_crucible(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/assembly/igniter(null)
	RefreshParts()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/magma_crucible/examine(mob/user)
	. = ..()
	. += "<span class='notice'>You can check the contents of [src] using a multitool.</span>"

/obj/machinery/magma_crucible/screwdriver_act(mob/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	. = TRUE
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)

/obj/machinery/magma_crucible/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/magma_crucible/RefreshParts()
	var/sheet_mult = SMITHING_BASE_SHEET_MULT
	for(var/obj/item/stock_parts/micro_laser/component in component_parts)
		sheet_mult += SMITHING_SHEET_MULT_ADD_PER_RATING * component.rating
	// Update our values
	sheet_per_ore = sheet_mult

/obj/machinery/magma_crucible/update_overlays()
	. = ..()
	overlays.Cut()
	if(adding_ore)
		. += "crucible_input"
	if(panel_open)
		. += "crucible_wires"
	if(pouring)
		. += "crucible_output"
	else if(has_power() && !(stat & (BROKEN)))
		. += "crucible_passive"

/obj/machinery/magma_crucible/update_icon_state()
	. = ..()
	if(!has_power())
		icon_state = "[initial(icon_state)]_off"
	else
		icon_state = initial(icon_state)

/obj/machinery/magma_crucible/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/magma_crucible/Destroy()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()
	for(var/obj/machinery/machine in linked_machines)
		if(istype(machine, /obj/machinery/mineral/smart_hopper))
			var/obj/machinery/mineral/smart_hopper/hopper = machine
			hopper.linked_crucible = null
		if(istype(machine, /obj/machinery/smithing/casting_basin))
			var/obj/machinery/smithing/casting_basin/basin = machine
			basin.linked_crucible = null
	linked_machines.Cut()
	return ..()

/obj/machinery/magma_crucible/power_change()
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/magma_crucible/proc/animate_transfer(time_to_animate)
	adding_ore = TRUE
	update_icon(UPDATE_OVERLAYS)
	addtimer(CALLBACK(src, PROC_REF(stop_animating)), time_to_animate)

/obj/machinery/magma_crucible/proc/stop_animating()
	adding_ore = FALSE
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/magma_crucible/proc/animate_pour(time_to_animate)
	pouring = TRUE
	number_of_pours++
	update_icon(UPDATE_OVERLAYS)
	addtimer(CALLBACK(src, PROC_REF(stop_pouring)), time_to_animate)

/obj/machinery/magma_crucible/proc/stop_pouring()
	number_of_pours--
	if(!number_of_pours)
		pouring = FALSE
		update_icon(UPDATE_OVERLAYS)

/obj/machinery/magma_crucible/attack_ghost(mob/dead/observer/user)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/magma_crucible/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/magma_crucible/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(panel_open)
		if(!I.multitool_check_buffer(user))
			return
		var/obj/item/multitool/multi = I
		multi.set_multitool_buffer(user, src)
		to_chat(user, "<span class='notice'>You save [src]'s linking data to the buffer.</span>")
		return

	var/list/msgs = list()
	msgs += "<span class='notice'>Scanning contents of [src]:</span>"

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	for(var/MAT in materials.materials)
		var/datum/material/M = materials.materials[MAT]
		if(!M)
			continue
		msgs += "[M.name]: [floor(M.amount / MINERAL_MATERIAL_AMOUNT)] sheets."
	to_chat(user, chat_box_regular(msgs.Join("<br>")))

/obj/machinery/magma_crucible/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/magma_crucible/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MaterialContainer", name)
		ui.open()

/obj/machinery/magma_crucible/ui_data(mob/user)
	..()
	var/datum/component/material_container/material_container = GetComponent(/datum/component/material_container)
	return material_container.get_ui_data(user)

/obj/machinery/magma_crucible/ui_static_data(mob/user)
	..()
	var/datum/component/material_container/material_container = GetComponent(/datum/component/material_container)
	return material_container.get_ui_static_data(user)
