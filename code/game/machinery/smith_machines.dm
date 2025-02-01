/obj/machinery/mineral/smart_hopper
	name = "smart hopper"
	desc = "An electronic deposit bin that accepts raw ores and delivers them to an adjacent magma crucible."
	icon = 'icons/obj/machines/smithing_machines.dmi'
	icon_state = "hopper"
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF
	/// Linked magma crucible
	var/obj/machinery/magma_crucible/linked_crucible
	/// Access to claim points
	var/req_access_claim = ACCESS_MINING_STATION
	/// The number of unclaimed points.
	var/points = 0
	/// Point multiplier
	var/point_upgrade = 1
	/// List of ore yet to process.
	var/list/obj/item/stack/ore/ore_buffer = list()
	/// Whether the message to relevant supply consoles was sent already or not for an ore dump. If FALSE, another will be sent.
	var/message_sent = TRUE
	/// If TRUE, [/obj/machinery/mineral/smart_hopper/var/req_access_claim] is ignored and any ID may be used to claim points.
	var/anyone_claim = FALSE
	var/list/supply_consoles = list(
		"Smith's Office",
		"Quartermaster's Desk"
	)

/obj/machinery/mineral/smart_hopper/Initialize(mapload)
	. = ..()
	// Stock parts
	component_parts = list()
	component_parts += new /obj/item/circuitboard/smart_hopper(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()
	// POLTODO: Handle linking to adjacent magma crucible

/obj/machinery/mineral/smart_hopper/process()
	if(panel_open || !has_power())
		return
	// Check if the input turf has a [/obj/structure/ore_box] to draw ore from. Otherwise suck ore from the turf
	var/atom/input = get_step(src, input_dir)
	var/obj/structure/ore_box/OB = locate() in input
	if(OB)
		input = OB
	// Suck the ore in
	for(var/obj/item/stack/ore/O in input)
		if(QDELETED(O))
			continue
		ore_buffer |= O
		O.forceMove(src)
		CHECK_TICK
	// Process it
	if(length(ore_buffer))
		message_sent = FALSE
		process_ores(ore_buffer)
	else if(!message_sent)
		SStgui.update_uis(src)
		send_console_message()
		message_sent = TRUE

// Interactions
/obj/machinery/mineral/smart_hopper/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/storage/part_replacer))
		return ..()

	if(!has_power())
		return ..()

	if(istype(used, /obj/item/card/id))
		var/obj/item/card/id/ID = used
		if(!points)
			to_chat(usr, "<span class='warning'>There are no points to claim.</span>");
			return ITEM_INTERACT_COMPLETE
		if(anyone_claim || (req_access_claim in ID.access))
			ID.mining_points += points
			ID.total_mining_points += points
			to_chat(usr, "<span class='notice'><b>[points] Mining Points</b> claimed. You have earned a total of <b>[ID.total_mining_points] Mining Points</b> this Shift!</span>")
			points = 0
			SStgui.update_uis(src)
		else
			to_chat(usr, "<span class='warning'>Required access not found.</span>")
		add_fingerprint(usr)
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/machinery/mineral/smart_hopper/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/mineral/smart_hopper/multitool_act(mob/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	if(!has_power())
		return
	if(!I.tool_start_check(src, user, 0))
		return
	input_dir = turn(input_dir, -90)
	output_dir = turn(output_dir, -90)
	to_chat(user, "<span class='notice'>You change [src]'s I/O settings, setting the input to [dir2text(input_dir)] and the output to [dir2text(output_dir)].</span>")

/obj/machinery/mineral/smart_hopper/proc/process_ores(list/obj/item/stack/ore/L)
	if(!linked_crucible)
		return
	for(var/ore in L)
		transfer_ore(ore)

/obj/machinery/mineral/smart_hopper/proc/transfer_ore(obj/item/stack/ore/O)
	// Insert materials
	var/datum/component/material_container/materials = linked_crucible.GetComponent(/datum/component/material_container)
	var/amount_compatible = materials.get_item_material_amount(O)
	if(amount_compatible)
		// Prevents duping
		if(O.refined_type)
			materials.insert_item(O, linked_crucible.sheet_per_ore)
		else
			materials.insert_item(O, 1)
	// Award points if the ore actually transfers to the magma crucible
	give_points(O.type, O.amount)
	// Delete the stack
	ore_buffer -= O
	qdel(O)

/obj/machinery/mineral/smart_hopper/proc/send_console_message()
	if(!is_station_level(z))
		return

	var/list/msg = list("Now available in [get_area_name(src, TRUE) || "Unknown"]:")
	var/mats_in_stock = list()
	var/datum/component/material_container/materials = linked_crucible.GetComponent(/datum/component/material_container)
	for(var/MAT in materials.materials)
		var/datum/material/M = materials.materials[MAT]
		var/mineral_amount = M.amount / MINERAL_MATERIAL_AMOUNT
		if(mineral_amount)
			mats_in_stock += M.id
			msg.Add("[capitalize(M.name)]: [mineral_amount] sheets")

	// No point sending a message if we're dry
	if(!length(mats_in_stock))
		return

	// Notify
	for(var/c in GLOB.allRequestConsoles)
		var/obj/machinery/requests_console/C = c
		if(!(C.department in supply_consoles))
			continue
		if(!supply_consoles[C.department] || length(supply_consoles[C.department] - mats_in_stock))
			C.createMessage("Smart Hopper", "New Minerals Available!", msg, RQ_LOWPRIORITY)

/obj/machinery/mineral/smart_hopper/proc/give_points(obj/item/stack/ore/ore_path, ore_amount)
	if(initial(ore_path.refined_type))
		points += initial(ore_path.points) * point_upgrade * ore_amount

/obj/machinery/magma_crucible
	name = "magma crucible"
	desc = "A massive machine that smelts down raw ore into a fine slurry, then sorts it into respective tanks for storage and use."
	icon = 'icons/obj/machines/magma_crucible.dmi'
	icon_state = "crucible"
	max_integrity = 300
	pixel_x = -32	// 3x3
	pixel_y = -32
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF
	/// Sheet multiplier applied when smelting ore.
	var/sheet_per_ore = 1

/obj/machinery/magma_crucible/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_BLUESPACE), INFINITY, FALSE, /obj/item/stack, null, null)
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
	// POLTODO: Handle smelting

// POLTODO: UI for seeing current minerals as a bar graph

/obj/machinery/casting_bench
	name = "casting bench"
	desc = "A table with a large basin for pouring molten metal. It has a slot for a mold."
	icon = 'icons/obj/machines/smithing_machines.dmi'
	icon_state = "casting_bench"
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF
	/// Linked magma crucible
	var/obj/machinery/magma_crucible/linked_crucible
	/// Input direction
	var/input_dir = NORTH

/obj/machinery/power_hammer
	name = "power hammer"
	desc = "A heavy-duty pneumatic hammer designed to shape and mold molten metal."
	icon = 'icons/obj/machines/large_smithing_machines.dmi'
	icon_state = "power_hammer"
	max_integrity = 200
	pixel_x = 0	// 2x2
	pixel_y = -32
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF

/obj/machinery/lava_furnace
	name = "lava furnace"
	desc = "A furnace that uses the innate heat of lavaland to reheat metal that has not been fully reshaped."
	icon = 'icons/obj/machines/large_smithing_machines.dmi'
	icon_state = "furnace"
	max_integrity = 200
	pixel_x = 0	// 2x2
	pixel_y = -32
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF

/obj/machinery/kinetic_assembler
	name = "kinetic assembler"
	desc = "A smart assembler that takes components and combines them at the strike of a hammer."
	icon = 'icons/obj/machines/smithing_machines.dmi'
	icon_state = "assembler"
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF
