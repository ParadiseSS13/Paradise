#define BASE_POINT_MULT 0.60
#define BASE_SHEET_MULT 0.60
#define POINT_MULT_ADD_PER_RATING 0.10
#define SHEET_MULT_ADD_PER_RATING 0.20
#define OPERATION_SPEED_MULT_PER_RATING 0.25

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
	/// What consoles get alerted when this is filled
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
	// Try to link to magma crucible on initialize. Link to the first crucible it can find.
	for(var/obj/machinery/magma_crucible/crucible in view(2, src))
		linked_crucible = crucible
		return

/obj/machinery/mineral/smart_hopper/RefreshParts()
	var/P = BASE_POINT_MULT
	for(var/obj/item/stock_parts/M in component_parts)
		P += POINT_MULT_ADD_PER_RATING * M.rating
	// Update our values
	point_upgrade = P
	SStgui.update_uis(src)

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

/obj/machinery/mineral/smart_hopper/multitool_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	if(panel_open)
		var/obj/item/multitool/M = I
		if(!istype(M.buffer, /obj/machinery/magma_crucible))
			to_chat(usr, "<span class='warning'>You cannot link [src] to [M.buffer]!</span>")
			return
		linked_crucible = M.buffer

/obj/machinery/mineral/smart_hopper/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/mineral/smart_hopper/wrench_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	if(!has_power())
		return
	if(!I.tool_start_check(src, user, 0))
		return
	input_dir = turn(input_dir, -90)
	to_chat(user, "<span class='notice'>You change [src]'s input, moving the input to [dir2text(input_dir)].</span>")

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

/obj/machinery/magma_crucible/RefreshParts()
	var/S = BASE_SHEET_MULT
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		S += SHEET_MULT_ADD_PER_RATING * M.rating
	// Update our values
	sheet_per_ore = S
	SStgui.update_uis(src)
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
	/// How long does an operation take
	var/operation_time = 10 SECONDS
	/// How many sheets are smelted at once?
	var/sheets = 10
	/// Smelter files to know what to make
	var/datum/research/files

/obj/machinery/casting_bench/Initialize(mapload)
	. = ..()
	// Stock parts
	component_parts = list()
	component_parts += new /obj/item/circuitboard/casting_bench(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()
	files = new /datum/research/smelter(src)
	// Try to link to magma crucible on initialize. Link to the first crucible it can find.
	for(var/obj/machinery/magma_crucible/crucible in view(2, src))
		linked_crucible = crucible
		return

/obj/machinery/casting_bench/RefreshParts()
	var/O = 0
	var/S = 0
	for(var/obj/item/stock_parts/M in component_parts)
		O += OPERATION_SPEED_MULT_PER_RATING * M.rating
		S += 5 * M.rating
	// Update our values
	operation_time = initial(operation_time) - O
	sheets = initial(sheets) + S

/obj/machinery/casting_bench/multitool_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	if(panel_open)
		var/obj/item/multitool/M = I
		if(!istype(M.buffer, /obj/machinery/magma_crucible))
			to_chat(usr, "<span class='warning'>You cannot link [src] to [M.buffer]!</span>")
			return
		linked_crucible = M.buffer

/obj/machinery/casting_bench/attack_hand(mob/user)
	. = ..()
	//var/datum/component/material_container/materials = linked_crucible.GetComponent(/datum/component/material_container)
	// TODO: SMELTING

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
	/// How long does an operation take
	var/operation_time = 10 SECONDS

/obj/machinery/power_hammer/Initialize(mapload)
	. = ..()
	// Stock parts
	component_parts = list()
	component_parts += new /obj/item/circuitboard/power_hammer(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/plasteel(null)
	RefreshParts()

/obj/machinery/power_hammer/RefreshParts()
	var/S = 0
	for(var/obj/item/stock_parts/M in component_parts)
		S += OPERATION_SPEED_MULT_PER_RATING * M.rating
	// Update our values
	operation_time = initial(operation_time) - S

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
	/// How long does an operation take
	var/operation_time = 10 SECONDS

/obj/machinery/lava_furnace/Initialize(mapload)
	. = ..()
	// Stock parts
	component_parts = list()
	component_parts += new /obj/item/circuitboard/lava_furnace(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/assembly/igniter(null)
	RefreshParts()

/obj/machinery/lava_furnace/RefreshParts()
	var/S = 0
	for(var/obj/item/stock_parts/M in component_parts)
		S += OPERATION_SPEED_MULT_PER_RATING * M.rating
	// Update our values
	operation_time = initial(operation_time) - S

/obj/machinery/kinetic_assembler
	name = "kinetic assembler"
	desc = "A smart assembler that takes components and combines them at the strike of a hammer."
	icon = 'icons/obj/machines/smithing_machines.dmi'
	icon_state = "assembler"
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF
	/// How long does an operation take
	var/operation_time = 10 SECONDS

/obj/machinery/kinetic_assembler/Initialize(mapload)
	. = ..()
	// Stock parts
	component_parts = list()
	component_parts += new /obj/item/circuitboard/kinetic_assembler(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/kinetic_assembler/RefreshParts()
	var/S = 0
	for(var/obj/item/stock_parts/M in component_parts)
		S += OPERATION_SPEED_MULT_PER_RATING * M.rating
	// Update our values
	operation_time = initial(operation_time) - S


#undef BASE_POINT_MULT
#undef BASE_SHEET_MULT
#undef POINT_MULT_ADD_PER_RATING
#undef SHEET_MULT_ADD_PER_RATING
#undef OPERATION_SPEED_MULT_PER_RATING
