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
	var/list/req_access_claim = list(ACCESS_MINING_STATION, ACCESS_FREE_GOLEMS)
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
	for(var/obj/machinery/magma_crucible/crucible in view(3, src))
		linked_crucible = crucible
		linked_crucible.linked_machines |= src
		return

/obj/machinery/mineral/smart_hopper/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There are currently [points] claimable points. [points ? "Swipe your ID to claim them." : ""]</span>"

/obj/machinery/mineral/smart_hopper/update_overlays()
	. = ..()
	overlays.Cut()
	if(panel_open)
		. += "hopper_wires"

/obj/machinery/mineral/smart_hopper/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/mineral/smart_hopper/RefreshParts()
	var/point_mult = SMITHING_BASE_POINT_MULT
	for(var/obj/item/stock_parts/component in component_parts)
		point_mult += SMITHING_POINT_MULT_ADD_PER_RATING * component.rating
	// Update our values
	point_upgrade = point_mult
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
	for(var/obj/item/stack/ore/ore in input)
		if(QDELETED(ore))
			continue
		ore_buffer |= ore
		ore.forceMove(src)
		CHECK_TICK
	// Process it
	if(length(ore_buffer))
		message_sent = FALSE
		process_ores(ore_buffer)
	else if(!message_sent)
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
			to_chat(user, "<span class='warning'>There are no points to claim.</span>");
			return ITEM_INTERACT_COMPLETE
		var/claimed = FALSE
		for(var/access in req_access_claim)
			if(anyone_claim || (access in ID.access))
				ID.mining_points += points
				ID.total_mining_points += points
				to_chat(user, "<span class='notice'><b>[points] Mining Points</b> claimed. You have earned a total of <b>[ID.total_mining_points] Mining Points</b> this Shift!</span>")
				points = 0
				claimed = TRUE
				break
		if(!claimed)
			to_chat(user, "<span class='warning'>Required access not found.</span>")
		add_fingerprint(user)
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/machinery/mineral/smart_hopper/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	if(panel_open)
		var/obj/item/multitool/multi = I
		if(!istype(multi.buffer, /obj/machinery/magma_crucible))
			to_chat(user, "<span class='warning'>You cannot link [src] to [multi.buffer]!</span>")
			return
		linked_crucible = multi.buffer
		linked_crucible.linked_machines |= src
		to_chat(user, "<span class='notice'>You link [src] to [multi.buffer].</span>")

/obj/machinery/mineral/smart_hopper/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/mineral/smart_hopper/screwdriver_act(mob/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	. = TRUE
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)

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

/obj/machinery/mineral/smart_hopper/Destroy()
	if(linked_crucible)
		linked_crucible.linked_machines -= src
		linked_crucible = null
	if(ore_buffer)
		for(var/obj/item/ores in ore_buffer)
			ores.forceMove(src.loc)
	return ..()

/obj/machinery/mineral/smart_hopper/proc/process_ores(list/obj/item/stack/ore/ore_list)
	if(!linked_crucible)
		return
	for(var/ore in ore_list)
		transfer_ore(ore)

/obj/machinery/mineral/smart_hopper/proc/transfer_ore(obj/item/stack/ore/O)
	if(!linked_crucible)
		return
	// Award points if the ore is actually transferable to the magma crucible
	give_points(O.type, O.amount)
	animate_transfer(O.amount)
	// Insert materials
	var/datum/component/material_container/materials = linked_crucible.GetComponent(/datum/component/material_container)
	var/amount_compatible = materials.get_item_material_amount(O)
	if(amount_compatible)
		// Prevents duping
		if(O.refined_type)
			materials.insert_item(O, linked_crucible.sheet_per_ore)
		else
			materials.insert_item(O, 1)
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
	for(var/obj/machinery/requests_console/console as anything in GLOB.allRequestConsoles)
		if(!(console.department in supply_consoles))
			continue
		if(!supply_consoles[console.department] || length(supply_consoles[console.department] - mats_in_stock))
			console.createMessage("Smart Hopper", "New Minerals Available!", msg, RQ_LOWPRIORITY)

/obj/machinery/mineral/smart_hopper/proc/give_points(obj/item/stack/ore/ore_path, ore_amount)
	if(initial(ore_path.refined_type))
		points += initial(ore_path.points) * point_upgrade * ore_amount

/obj/machinery/mineral/smart_hopper/proc/animate_transfer(ore_amount)
	icon_state = "hopper_on"
	var/time_to_animate = max(ore_amount * 2, 1 SECONDS)
	addtimer(VARSET_CALLBACK(src, icon_state, "hopper"), time_to_animate)
	linked_crucible.animate_transfer(time_to_animate)

/obj/machinery/mineral/smart_hopper/attack_ghost(mob/dead/observer/user)
	. = ..()
	ui_interact(user)

/obj/machinery/mineral/smart_hopper/attack_hand(mob/user)
	. = ..()
	ui_interact(user)

/obj/machinery/mineral/smart_hopper/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/mineral/smart_hopper/ui_interact(mob/user, datum/tgui/ui = null)
	if(!linked_crucible)
		return FALSE
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MaterialContainer", name)
		ui.open()

/obj/machinery/mineral/smart_hopper/ui_data(mob/user)
	..()
	var/datum/component/material_container/material_container = linked_crucible.GetComponent(/datum/component/material_container)
	return material_container.get_ui_data(user)

/obj/machinery/mineral/smart_hopper/ui_static_data(mob/user)
	..()
	var/datum/component/material_container/material_container = linked_crucible.GetComponent(/datum/component/material_container)
	return material_container.get_ui_static_data(user, TRUE, point_upgrade)
