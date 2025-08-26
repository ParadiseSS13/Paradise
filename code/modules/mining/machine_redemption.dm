/**
  * # Ore Redemption Machine
  *
  * Turns all the various mining machines into a single unit to speed up tmining and establish a point system.
  */
/obj/machinery/mineral/ore_redemption
	name = "ore redemption machine"
	desc = "A machine that accepts ore and instantly transforms it into workable material sheets. Points for ore are generated based on type and can be redeemed at a mining equipment vendor."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"
	density = TRUE
	anchored = TRUE
	req_access = list(ACCESS_MINERAL_STOREROOM)
	speed_process = TRUE
	// Settings
	/// The access number required to claim points from the machine.
	var/req_access_claim = ACCESS_MINING_STATION
	/// If TRUE, [/obj/machinery/mineral/ore_redemption/var/req_access_claim] is ignored and any ID may be used to claim points.
	var/anyone_claim = FALSE
	/// List of supply console department names that can receive a notification about ore dumps.
	/// A list may be provided as entry value to only notify when specific ore is dumped.
	var/list/supply_consoles = list(
		"Science",
		"Robotics",
		"Research Director's Desk",
		"Engineering" = list(MAT_METAL, MAT_GLASS, MAT_PLASMA),
		"Chief Engineer's Desk" = list(MAT_METAL, MAT_GLASS, MAT_PLASMA),
		"Atmospherics" = list(MAT_METAL, MAT_GLASS, MAT_PLASMA),
		"Bar" = list(MAT_URANIUM, MAT_PLASMA),
		"Virology" = list(MAT_PLASMA, MAT_URANIUM, MAT_GOLD)
	)
	// Variables
	/// The number of unclaimed points.
	var/points = 0
	/// Sheet multiplier applied when smelting ore. Updated by [/obj/machinery/proc/RefreshParts].
	var/sheet_per_ore = 1
	/// Point multiplier applied when smelting ore. Updated by [/obj/machinery/proc/RefreshParts].
	var/point_upgrade = 1
	/// Whether the message to relevant supply consoles was sent already or not for an ore dump. If FALSE, another will be sent.
	var/message_sent = TRUE
	/// List of ore yet to process.
	var/list/obj/item/stack/ore/ore_buffer = null
	/// Locally known R&D designs.
	var/datum/research/files
	/// The currently inserted design disk.
	var/obj/item/disk/design_disk/inserted_disk
	var/datum/component/material_container/mat_container
	var/invalid_material


/obj/machinery/mineral/ore_redemption/Initialize(mapload)
	. = ..()
	mat_container = AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_BLUESPACE, MAT_PLATINUM, MAT_IRIDIUM, MAT_PALLADIUM), INFINITY, FALSE, /obj/item/stack, null, CALLBACK(src, PROC_REF(on_material_insert)))
	ore_buffer = list()
	files = new /datum/research/smelter(src)
	// Stock parts
	component_parts = list()
	component_parts += new /obj/item/circuitboard/ore_redemption(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/assembly/igniter(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/mineral/ore_redemption/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/ore_redemption(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/assembly/igniter(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/**
  * # Ore Redemption Machine (Labor Camp)
  *
  * Labor camp variant of the ORM. Points can be claimed by anyone.
  */
/obj/machinery/mineral/ore_redemption/labor
	name = "labor camp ore redemption machine"
	req_access = list()
	anyone_claim = TRUE

/obj/machinery/mineral/ore_redemption/labor/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/ore_redemption/labor(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/assembly/igniter(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/mineral/ore_redemption/Destroy()
	// Move any stuff inside us out
	var/turf/T = get_turf(src)
	inserted_disk?.forceMove(T)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()
	// Clean up
	QDEL_NULL(files)
	return ..()

/obj/machinery/mineral/ore_redemption/RefreshParts()
	var/P = ORM_BASE_POINT_MULT
	var/S = ORM_BASE_SHEET_MULT
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		P += ORM_POINT_MULT_ADD_PER_RATING * M.rating
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		S += ORM_SHEET_MULT_ADD_PER_RATING * M.rating
		// Manipulators do nothing
	// Update our values
	point_upgrade = P
	sheet_per_ore = S
	SStgui.update_uis(src)

/obj/machinery/mineral/ore_redemption/power_change()
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/mineral/ore_redemption/update_icon_state()
	if(has_power())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/mineral/ore_redemption/process()
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
	for(var/obj/item/stack/stack in input)
		if(QDELETED(stack))
			return
		if(!mat_container.insert_stack(stack, stack.amount))
			stack.forceMove(get_step(src, output_dir))
			invalid_material = TRUE
		CHECK_TICK
	if(invalid_material)
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		atom_say("ERROR - Spitting out invalid materials.")
		invalid_material = FALSE
	// Process it
	if(length(ore_buffer))
		message_sent = FALSE
		process_ores(ore_buffer)
	else if(!message_sent)
		SStgui.update_uis(src)
		send_console_message()
		message_sent = TRUE

// Interactions
/obj/machinery/mineral/ore_redemption/item_interaction(mob/living/user, obj/item/used, list/modifiers)
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

	if(istype(used, /obj/item/disk/design_disk))
		if(!user.drop_item())
			return ITEM_INTERACT_COMPLETE
		used.forceMove(src)
		inserted_disk = used
		SStgui.update_uis(src)
		interact(user)
		user.visible_message(
			"<span class='notice'>[user] inserts [used] into [src].</span>",
			"<span class='notice'>You insert [used] into [src].</span>"
		)
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/gripper))
		if(!try_refill_storage(user))
			to_chat(user, "<span class='notice'>You fail to retrieve any sheets from [src].</span>")
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/mineral/ore_redemption/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/mineral/ore_redemption/multitool_act(mob/user, obj/item/I)
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

/obj/machinery/mineral/ore_redemption/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "ore_redemption-open", "ore_redemption", I))
		SStgui.update_uis(src)
		return TRUE

/obj/machinery/mineral/ore_redemption/wrench_act(mob/user, obj/item/I)
	if(default_unfasten_wrench(user, I, time = 6 SECONDS))
		return TRUE

/obj/machinery/mineral/ore_redemption/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/mineral/ore_redemption/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/mineral/ore_redemption/ex_act(severity)
	do_sparks(5, TRUE, src)
	..()

// UI
/obj/machinery/mineral/ore_redemption/ui_data(mob/user)
	var/list/data = list()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

	// General info
	data["points"] = points
	data["disk"] = inserted_disk ? list(
		"name" = inserted_disk.name,
		"design" = inserted_disk.blueprint?.name,
		"compatible" = (inserted_disk.blueprint?.build_type & SMELTER)
	) : null

	// Sheets
	var/list/sheets = list()
	for(var/MAT in materials.materials)
		var/datum/material/M = materials.materials[MAT]
		if(!M)
			continue
		var/obj/item/stack/ore/O = M.ore_type
		sheets += list(list(
			"id" = MAT,
			"name" = M.name,
			"amount" = M.amount / MINERAL_MATERIAL_AMOUNT,
			"value" = initial(O.points) * point_upgrade
		))
	data["sheets"] = sheets

	// Alloys
	var/list/alloys = list()
	for(var/v in files.known_designs)
		var/datum/design/D = files.known_designs[v]
		alloys += list(list(
			"id" = D.id,
			"name" = D.name,
			"description" = D.desc,
			"amount" = get_num_smeltable_alloy(D)
		))
	data["alloys"] = alloys

	return data

/obj/machinery/mineral/ore_redemption/ui_act(action, list/params)
	if(..())
		return

	. = TRUE
	switch(action)
		if("sheet", "alloy")
			if(!allowed(usr))
				to_chat(usr, "<span class='warning'>Required access not found.</span>")
				return FALSE
			var/id = params["id"]
			var/amount = round(text2num(params["amount"]))
			if(!amount || amount < 1)
				return FALSE
			var/out_loc = get_step(src, output_dir)
			var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
			if(action == "sheet")
				var/datum/material/M = materials.materials[id]
				if(!M)
					return FALSE
				var/stored = M.amount / MINERAL_MATERIAL_AMOUNT
				var/desired = min(amount, stored, MAX_STACK_SIZE)
				materials.retrieve_sheets(desired, id, out_loc)
			else
				var/datum/design/D = files.FindDesignByID(id)
				if(!D)
					return FALSE
				var/stored = get_num_smeltable_alloy(D)
				var/desired = min(amount, stored, MAX_STACK_SIZE)
				if(!desired)
					return FALSE
				materials.use_amount(D.materials, desired)
				// Spawn the alloy
				var/result = new D.build_path(src)
				if(istype(result, /obj/item/stack/sheet))
					var/obj/item/stack/sheet/mineral/A = result
					A.amount = desired
					unload_mineral(A)
				else
					unload_mineral(result)
		if("eject_disk")
			if(!inserted_disk)
				return FALSE
			if(ishuman(usr))
				usr.put_in_hands(inserted_disk)
				usr.visible_message("<span class='notice'>[usr] retrieves [inserted_disk] from [src].</span>", \
									"<span class='notice'>You retrieve [inserted_disk] from [src].</span>")
			else
				inserted_disk.forceMove(get_turf(src))
			inserted_disk = null
		if("download")
			if(inserted_disk?.blueprint?.build_type & SMELTER)
				files.AddDesign2Known(inserted_disk.blueprint)
				atom_say("Design \"[inserted_disk.blueprint.name]\" downloaded successfully.")
		else
			return FALSE
	add_fingerprint(usr)

/obj/machinery/mineral/ore_redemption/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/mineral/ore_redemption/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OreRedemption", name)
		ui.open()
		ui.set_autoupdate(FALSE)

/obj/machinery/mineral/ore_redemption/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/materials),
		get_asset_datum(/datum/asset/spritesheet/alloys)
	)

/**
  * Smelts the given stack of ore.
  *
  * Arguments:
  * * O - The ore stack to smelt.
  */
/obj/machinery/mineral/ore_redemption/proc/smelt_ore(obj/item/stack/ore/O)
	// Award points if the ore actually smelts to something
	give_points(O.type, O.amount)
	// Insert materials
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	var/amount_compatible = materials.get_item_material_amount(O)
	if(amount_compatible)
		// Prevents duping
		if(O.refined_type)
			materials.insert_item(O, sheet_per_ore)
		else
			materials.insert_item(O, 1)
	// Delete the stack
	ore_buffer -= O
	qdel(O)

/**
  * Adds a set number of mining points, based on the ore points, the ore amount, and the ORM upgrade state.
  *
  * Arguments:
  * * ore_path - The typepath of the inserted ore.
  * * ore_amount - The amount of ore which has been inserted.
  */
/obj/machinery/mineral/ore_redemption/proc/give_points(obj/item/stack/ore/ore_path, ore_amount)
	if(initial(ore_path.refined_type))
		points += initial(ore_path.points) * point_upgrade * ore_amount

/**
  * Returns the amount of alloy sheets that can be produced from the given design.
  *
  * Arguments:
  * * D - The smelting design.
  */
/obj/machinery/mineral/ore_redemption/proc/get_num_smeltable_alloy(datum/design/D)
	if(length(D.make_reagents))
		return 0

	var/result = 0
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	for(var/MAT in D.materials)
		var/M = D.materials[MAT]
		var/datum/material/stored = materials.materials[MAT]
		if(!M || !stored)
			return FALSE
		var/smeltable = round(stored.amount / M)
		if(!smeltable)
			return FALSE
		if(!result)
			result = smeltable
		result = min(result, smeltable)
	return result

/**
  * Processes the given list of ores.
  *
  * Arguments:
  * * L - List of ores to process.
  */
/obj/machinery/mineral/ore_redemption/proc/process_ores(list/obj/item/stack/ore/L)
	for(var/ore in L)
		smelt_ore(ore)

/**
  * Notifies all relevant supply consoles with the machine's contents.
  */
/obj/machinery/mineral/ore_redemption/proc/send_console_message()
	if(!is_station_level(z))
		return

	var/list/msg = list("Now available in [get_area_name(src, TRUE) || "Unknown"]:")
	var/mats_in_stock = list()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
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
			C.createMessage("Ore Redemption Machine", "New Minerals Available!", msg, RQ_LOWPRIORITY)

/obj/machinery/mineral/ore_redemption/proc/try_refill_storage(mob/living/silicon/robot/robot)
	. = FALSE
	if(!istype(robot))
		return
	if(!istype(robot.module, /obj/item/robot_module/engineering)) // Should only happen for drones
		return

	for(var/datum/robot_storage/material/mat_store in robot.module.material_storages)
		if(mat_store.amount == mat_store.max_amount) // Already full, no need to run a check
			to_chat(robot, "<span class='notice'>[mat_store] could not be filled due to it already being full.</span>")
			continue
		var/datum/component/material_container/container_component = GetComponent(/datum/component/material_container)
		for(var/mat_id in container_component.materials)
			var/datum/material/stack = container_component.materials[mat_id] // Should have only `/datum/material` in the list
			var/obj/item/stack/sheet/sheet = stack.sheet_type
			if(ispath(mat_store.stack, sheet))
				var/amount_to_add
				var/total_stacks = stack.amount / MINERAL_MATERIAL_AMOUNT // To account for 1 sheet being 2000 units of metal
				if(total_stacks >= (mat_store.max_amount - mat_store.amount))
					amount_to_add = round(mat_store.max_amount - mat_store.amount)
					to_chat(robot, "<span class='notice'>You refill [mat_store] to full.</span>")
				else
					amount_to_add = round(total_stacks) // In case we have half a sheet stored
					to_chat(robot, "<span class='notice'>You refill [amount_to_add] sheets to [mat_store].</span>")
				mat_store.amount += amount_to_add
				remove_from_storage(stack, amount_to_add)
				. = TRUE
				break // We found our match for this material storage, so we go to the next one

/obj/machinery/mineral/ore_redemption/proc/remove_from_storage(datum/material/stack, sheet_amount)
	return stack.amount -= sheet_amount * MINERAL_MATERIAL_AMOUNT

/**
  * Called when an item is inserted manually as material.
  *
  * Arguments:
  * * inserted_type - The type of the inserted item.
  * * last_inserted_id - The ID of the last material to have been inserted.
  * * inserted - The amount of material inserted.
  */
/obj/machinery/mineral/ore_redemption/proc/on_material_insert(inserted_type, last_inserted_id, inserted)
	give_points(inserted_type, inserted)
	SStgui.update_uis(src)
