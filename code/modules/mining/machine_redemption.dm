#define BASE_POINT_MULT 0.65
#define BASE_SHEET_MULT 0.65
#define POINT_MULT_ADD_PER_RATING 0.35
#define SHEET_MULT_ADD_PER_RATING 0.35

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
	input_dir = NORTH
	output_dir = SOUTH
	req_access = list(ACCESS_MINERAL_STOREROOM)
	speed_process = TRUE
	layer = BELOW_OBJ_LAYER
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
	/// The currently inserted ID.
	var/obj/item/card/id/inserted_id = null
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


/obj/machinery/mineral/ore_redemption/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_BLUESPACE), INFINITY, FALSE, /obj/item/stack, null, CALLBACK(src, PROC_REF(on_material_insert)))
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
  * # Ore Redemption Machine (Golem)
  *
  * Golem variant of the ORM.
  */
/obj/machinery/mineral/ore_redemption/golem
	req_access = list(ACCESS_FREE_GOLEMS)
	req_access_claim = ACCESS_FREE_GOLEMS

/obj/machinery/mineral/ore_redemption/golem/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/ore_redemption/golem(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
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
	inserted_id?.forceMove(T)
	inserted_disk?.forceMove(T)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()
	// Clean up
	QDEL_NULL(files)
	return ..()

/obj/machinery/mineral/ore_redemption/RefreshParts()
	var/P = BASE_POINT_MULT
	var/S = BASE_SHEET_MULT
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		P += POINT_MULT_ADD_PER_RATING * M.rating
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		S += SHEET_MULT_ADD_PER_RATING * M.rating
		// Manipulators do nothing
	// Update our values
	point_upgrade = P
	sheet_per_ore = S
	SStgui.update_uis(src)

/obj/machinery/mineral/ore_redemption/power_change()
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)
	if(inserted_id && !(stat & NOPOWER))
		visible_message("<span class='notice'>The ID slot indicator light flickers on [src] as it spits out a card before powering down.</span>")
		inserted_id.forceMove(get_turf(src))
		inserted_id = null

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
	// Process it
	if(length(ore_buffer))
		message_sent = FALSE
		process_ores(ore_buffer)
	else if(!message_sent)
		SStgui.update_uis(src)
		send_console_message()
		message_sent = TRUE

// Interactions
/obj/machinery/mineral/ore_redemption/attackby(obj/item/I, mob/user, params)
	if(exchange_parts(user, I))
		return
	if(!has_power())
		return ..()

	if(istype(I, /obj/item/card/id))
		try_insert_id(user)
		return

	else if(istype(I, /obj/item/disk/design_disk))
		if(!user.drop_item())
			return
		I.forceMove(src)
		inserted_disk = I
		SStgui.update_uis(src)
		interact(user)
		user.visible_message("<span class='notice'>[user] inserts [I] into [src].</span>",
							"<span class='notice'>You insert [I] into [src].</span>")
		return
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
	data["id"] = inserted_id ? list("name" = "[inserted_id.registered_name] ([inserted_id.assignment])", "points" = inserted_id.mining_points) : null
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
		if("claim")
			if(!inserted_id || !points)
				return
			if(anyone_claim || (req_access_claim in inserted_id.access))
				inserted_id.mining_points += points
				to_chat(usr, "<span class='notice'>[points] points claimed.</span>")
				points = 0
			else
				to_chat(usr, "<span class='warning'>Required access not found.</span>")
		if("sheet", "alloy")
			if(!(check_access(inserted_id) || allowed(usr)))
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
				materials.use_amount(D.materials, desired)
				// Spawn the alloy
				var/result = new D.build_path(src)
				if(istype(result, /obj/item/stack/sheet))
					var/obj/item/stack/sheet/mineral/A = result
					A.amount = amount
					unload_mineral(A)
				else
					unload_mineral(result)
		if("insert_id")
			try_insert_id(usr)
		if("eject_id")
			if(!inserted_id)
				return FALSE
			if(ishuman(usr))
				usr.put_in_hands(inserted_id)
				usr.visible_message("<span class='notice'>[usr] retrieves [inserted_id] from [src].</span>", \
									"<span class='notice'>You retrieve [inserted_id] from [src].</span>")
			else
				inserted_id.forceMove(get_turf(src))
			inserted_id = null
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

/obj/machinery/mineral/ore_redemption/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	var/datum/asset/materials_assets = get_asset_datum(/datum/asset/simple/materials)
	materials_assets.send(user)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "OreRedemption", name, 500, 600)
		ui.open()
		ui.set_autoupdate(FALSE)

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
		materials.insert_item(O, sheet_per_ore)
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
			C.createMessage("Ore Redemption Machine", "New Minerals Available!", msg, 1) // RQ_NORMALPRIORITY

/**
  * Tries to insert the ID card held by the given user into the machine.
  *
  * Arguments:
  * * user - The ID whose active hand to check for an ID card to insert.
  */
/obj/machinery/mineral/ore_redemption/proc/try_insert_id(mob/user)
	. = FALSE
	var/obj/item/card/id/I = user.get_active_hand()
	if(!istype(I))
		return
	if(inserted_id)
		to_chat(user, "<span class='warning'>There is already an ID inside!</span>")
		return
	if(!user.drop_item())
		return
	I.forceMove(src)
	inserted_id = I
	SStgui.update_uis(src)
	interact(user)
	user.visible_message("<span class='notice'>[user] inserts [I] into [src].</span>", \
							"<span class='notice'>You insert [I] into [src].</span>")
	return TRUE

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

#undef BASE_POINT_MULT
#undef BASE_SHEET_MULT
#undef POINT_MULT_ADD_PER_RATING
#undef SHEET_MULT_ADD_PER_RATING
