#define EXOFAB_BASE_CAPACITY 200000
#define EXOFAB_CAPACITY_PER_RATING 50000
#define EXOFAB_EFFICIENCY_PER_RATING 0.15
#define EXOFAB_SPEED_UPGRADE_MULTIPLIER 0.2

/**
  * # Exosuit Fabricator
  *
  * A machine that allows for the production of exosuits and robotic parts.
  */
/obj/machinery/mecha_part_fabricator
	name = "exosuit fabricator"
	desc = "Nothing is being built."
	icon = 'icons/obj/machines/robotics.dmi'
	icon_state = "fab-idle"
	var/icon_open = "fab-o"
	var/icon_closed = "fab-idle"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 5000
	// Settings
	/// Bitflags of design types that can be produced.
	var/allowed_design_types = MECHFAB
	/// List of categories to display in the UI. Designs intended for each respective category need to have the name in [/datum/design/category]. Defined in [Initialize()][/atom/proc/Initialize].
	var/list/categories = null
	/// Unused. Ensures backwards compatibility with some maps.
	var/id = null
	// Variables
	/// Production time multiplier. A lower value means faster production. Updated by [CheckParts()][/atom/proc/CheckParts].
	var/time_coeff = 1
	/// Resource efficiency multiplier. A lower value means less resources consumed. Updated by [CheckParts()][/atom/proc/CheckParts].
	var/component_coeff = 1
	/// Holds the locally known R&D designs.
	var/datum/research/local_designs = null
	/// Whether a R&D sync is currently in progress.
	var/syncing = FALSE
	/// The currently selected category.
	var/selected_category = null
	/// The design that is being currently being built.
	var/datum/design/being_built = null
	/// The world.time at which the current design build started.
	var/build_start = 0
	/// The world.time at which the current design build will end.
	var/build_end = 0
	/// The build queue. Lazy list.
	var/list/datum/design/build_queue = null
	/// Whether the queue is currently being processed.
	var/processing_queue = FALSE
	var/ui_theme = "nanotrasen"

/obj/machinery/mecha_part_fabricator/New()
	// Set up some datums
	var/datum/component/material_container/materials = AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_BLUESPACE), 0, FALSE, /obj/item/stack, CALLBACK(src, .proc/can_insert_materials), CALLBACK(src, .proc/on_material_insert))
	materials.precise_insertion = TRUE
	local_designs = new /datum/research(src)
	..()
	// Components
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mechfab(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()
	if(is_taipan(z))
		req_access = list(ACCESS_SYNDICATE)

/obj/machinery/mecha_part_fabricator/Initialize(mapload)
	. = ..()
	categories = list(
		"Cyborg",
		"Cyborg Repair",
		"Ripley",
		"Firefighter",
		"Clarke",
		"Odysseus",
		"Gygax",
		"Durand",
		"H.O.N.K",
		"Reticence",
		"Phazon",
		"Exosuit Equipment",
		"Cyborg Upgrade Modules",
		"Medical",
		"Misc"
	)

/obj/machinery/mecha_part_fabricator/Destroy()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()
	QDEL_NULL(local_designs)
	return ..()

/obj/machinery/mecha_part_fabricator/RefreshParts()
	var/coef_mats = 0
	var/coef_resources = 1 + EXOFAB_EFFICIENCY_PER_RATING
	var/coef_speed = -1
	for(var/sp in component_parts)
		var/obj/item/stock_parts/SP = sp
		if(istype(SP, /obj/item/stock_parts/matter_bin))
			coef_mats += SP.rating
		else if(istype(SP, /obj/item/stock_parts/micro_laser))
			coef_resources -= SP.rating * EXOFAB_EFFICIENCY_PER_RATING
		else if(istype(SP, /obj/item/stock_parts/manipulator))
			coef_speed += SP.rating

	// Update our efficiencies
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.max_amount = (EXOFAB_BASE_CAPACITY + (coef_mats * EXOFAB_CAPACITY_PER_RATING))
	component_coeff = coef_resources
	time_coeff = round(initial(time_coeff) - (initial(time_coeff) * coef_speed) * EXOFAB_SPEED_UPGRADE_MULTIPLIER, 0.01)

/**
  * Calculates the total resource cost of a design, applying [/obj/machinery/mecha_part_fabricator/var/component_coeff].
  *
  * Arguments:
  * * D - The design whose cost to calculate.
  */
/obj/machinery/mecha_part_fabricator/proc/get_design_cost(datum/design/D, roundto = 1)
	var/list/resources = list()
	for(var/R in D.materials)
		var/cost = round(D.materials[R] * component_coeff, roundto)
		if(!cost)
			continue
		resources[R] = cost
	return resources

/**
  * Calculates the total build time of a design, applying [/obj/machinery/mecha_part_fabricator/var/time_coeff].
  *
  * Arguments:
  * * D - The design whose build time to calculate.
  */
/obj/machinery/mecha_part_fabricator/proc/get_design_build_time(datum/design/D, roundto = 1)
	return round(initial(D.construction_time) * time_coeff, roundto)

/**
  * Returns whether the machine contains enough resources to build the given design.
  *
  * Arguments:
  * * D - The design to check.
  */
/obj/machinery/mecha_part_fabricator/proc/can_afford_design(datum/design/D)
	if(length(D.reagents_list)) // No reagents storage - no reagent designs.
		return FALSE
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	return materials.has_materials(get_design_cost(D))

/**
  * Attempts to build the first item in the queue.
  */
/obj/machinery/mecha_part_fabricator/proc/process_queue()
	if(!processing_queue || being_built || !length(build_queue))
		return
	var/datum/design/D = build_queue[1]
	if(build_design(D))
		build_queue.Cut(1, 2)

/**
  * Given a design, attempts to build it.
  *
  * Arguments:
  * * D - The design to build.
  */
/obj/machinery/mecha_part_fabricator/proc/build_design(datum/design/D)
	. = FALSE
	if(!local_designs.known_designs[D.id] || !(D.build_type & allowed_design_types))
		return
	if(being_built)
		atom_say("Ошибка: уже в процессе производства!")
		return
	if(!can_afford_design(D))
		atom_say("Ошибка: недостаточно материалов для производства [D.name]!")
		return

	// Subtract the materials from the holder
	var/list/final_cost = get_design_cost(D)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.use_amount(final_cost)

	// Start building the design
	var/build_time = get_design_build_time(D)
	being_built = D
	build_start = world.time
	build_end = build_start + build_time
	desc = "It's building \a [initial(D.name)]."
	use_power = ACTIVE_POWER_USE
	add_overlay("[icon_state]-active")
	addtimer(CALLBACK(src, .proc/build_design_timer_finish, D, final_cost), build_time)

	return TRUE

/obj/machinery/mecha_part_fabricator/proc/log_printing_design(datum/design/D)
	for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
		if(S.disabled)
			continue
		if(S.syndicate)
			continue
		if(istype(S, /obj/machinery/r_n_d/server/robotics) || istype(S, /obj/machinery/r_n_d/server/centcom))
			S.add_usage_log(usr, D, src)

/**
  * Called when the timer for building a design finishes.
  *
  * Arguments:
  * * D - The design being built.
  * * final_cost - The materials consumed during the build.
  */
/obj/machinery/mecha_part_fabricator/proc/build_design_timer_finish(datum/design/D, list/final_cost)
	// Spawn the item (in a lockbox if restricted) OR mob (e.g. IRC body)
	var/atom/A = new D.build_path(get_step(src, SOUTH))
	if(istype(A, /obj/item))
		var/obj/item/I = A
		I.materials = final_cost
		if(D.locked)
			var/obj/item/storage/lockbox/research/large/L = new(get_step(src, SOUTH))
			I.forceMove(L)
			L.name += " ([I.name])"
			L.origin_tech = I.origin_tech

	// Clean up
	being_built = null
	build_start = 0
	build_end = 0
	desc = initial(desc)
	use_power = IDLE_POWER_USE
	cut_overlays()
	atom_say("[A] завершён.")

	// Keep the queue processing going if it's on
	process_queue()

	SStgui.update_uis(src)

/**
  * Syncs the R&D designs from the first [/obj/machinery/computer/rdconsole] in the area.
  */
/obj/machinery/mecha_part_fabricator/proc/sync()
	addtimer(CALLBACK(src, .proc/sync_timer_finish), 3 SECONDS)
	syncing = TRUE

/**
  * Called when the timer for syncing finishes.
  */
/obj/machinery/mecha_part_fabricator/proc/sync_timer_finish()
	syncing = FALSE
	var/area/A = get_area(src)
	for(var/obj/machinery/computer/rdconsole/RDC in A) // These computers should have their own global..
		if(!RDC.sync)
			continue
		RDC.files.push_data(local_designs)
		atom_say("Успешная синхронизация с серверами РНД.")
		break
	SStgui.update_uis(src)

/**
  * Called by [/datum/component/material_container] when material sheets are inserted in the machine.
  *
  * Arguments:
  * * type_inserted - The material type.
  * * id_inserted - The material ID.
  * * amount_inserted - The amount of sheets inserted.
  */
/obj/machinery/mecha_part_fabricator/proc/on_material_insert(type_inserted, id_inserted, amount_inserted)
	var/stack_name = copytext(id_inserted, 2)
	add_overlay("fab-load-[stack_name]")
	addtimer(CALLBACK(src, .proc/on_material_insert_timer_finish), 1 SECONDS)
	process_queue()
	SStgui.update_uis(src)

/**
  * Called when the timer after inserting material sheets finishes.
  */
/obj/machinery/mecha_part_fabricator/proc/on_material_insert_timer_finish()
	cut_overlays()

/**
  * Returns whether the machine can accept new materials.
  */
/obj/machinery/mecha_part_fabricator/proc/can_insert_materials(mob/user)
	if(panel_open)
		to_chat(user, "<span class='warning'>[src] cannot be loaded with new materials while opened!</span>")
		return FALSE
	if(being_built)
		to_chat(user, "<span class='warning'>[src] is currently building a part! Please wait until completion.</span>")
		return FALSE
	return TRUE

// Interaction code
/obj/machinery/mecha_part_fabricator/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, icon_open, icon_closed, W))
		return
	if(exchange_parts(user, W))
		return
	if(default_deconstruction_crowbar(user, W))
		return TRUE
	return ..()

/obj/machinery/mecha_part_fabricator/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/mecha_part_fabricator/attack_hand(mob/user)
	if(..())
		return
	if(!allowed(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return
	ui_interact(user)

/obj/machinery/mecha_part_fabricator/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	if(!selected_category)
		selected_category = categories[1]

	var/datum/asset/materials_assets = get_asset_datum(/datum/asset/simple/materials)
	materials_assets.send(user)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ExosuitFabricator", name, 800, 600)
		ui.open()
		ui.set_autoupdate(FALSE)

/obj/machinery/mecha_part_fabricator/ui_data(mob/user)
	var/list/data = list()
	data["syncing"] = syncing
	data["processingQueue"] = processing_queue
	data["categories"] = categories
	data["curCategory"] = selected_category
	data["ui_theme"] = ui_theme

	// Materials
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	var/list/mats = list()
	for(var/MAT in materials.materials)
		var/datum/material/M = materials.materials[MAT]
		if(!M.amount)
			continue
		mats[MAT] = M.amount
	data["materials"] = mats
	data["capacity"] = materials.max_amount

	// Queue and deficit
	var/list/queue = list()
	var/list/queue_deficit = mats.Copy() // What (and how much) materials are we missing to fully process the queue? Any negative values after the loop mean a deficit for a particular material.
	for(var/d in build_queue)
		var/datum/design/D = d
		var/list/out = list("name" = D.name, "time" = get_design_build_time(D))
		// Add to deficit
		var/list/actual_cost = get_design_cost(D)
		for(var/cost_id in actual_cost)
			queue_deficit[cost_id] -= actual_cost[cost_id]
			if(queue_deficit[cost_id] < 0) // This design costs more mats than we have, mark it as such.
				out["notEnough"] = TRUE
		queue += list(out)
	data["queue"] = queue
	data["queueDeficit"] = queue_deficit

	// Current category
	if(selected_category)
		var/list/category_designs = list()
		for(var/v in local_designs.known_designs)
			var/datum/design/D = local_designs.known_designs[v]
			if(!(D.build_type & allowed_design_types) || !(selected_category in D.category) || length(D.reagents_list))
				continue
			var/list/design_out = list("id" = D.id, "name" = D.name, "cost" = get_design_cost(D), "time" = get_design_build_time(D))
			if(!can_afford_design(D))
				design_out["notEnough"] = TRUE
			category_designs += list(design_out)
		data["designs"] = category_designs

	// Current build
	if(being_built)
		data["building"] = being_built.name
		data["buildStart"] = build_start
		data["buildEnd"] = build_end
		data["worldTime"] = world.time
	else // Redundant data to ensure the clientside state is refreshed.
		data["building"] = null
		data["buildStart"] = null
		data["buildEnd"] = null

	return data

/obj/machinery/mecha_part_fabricator/ui_act(action, params)
	if(..())
		return

	. = TRUE
	switch(action)
		if("category")
			var/new_cat = params["cat"]
			if(!(new_cat in categories))
				return
			selected_category = new_cat
		if("build")
			var/id = params["id"]
			var/datum/design/D = local_designs.known_designs[id]
			if(!D)
				return
			build_design(D)
			log_printing_design(D)
		if("queue")
			var/id = params["id"]
			if(!(id in local_designs.known_designs))
				return
			var/datum/design/D = local_designs.known_designs[id]
			if(!(D.build_type & allowed_design_types) || length(D.reagents_list))
				return
			LAZYADD(build_queue, D)
			log_printing_design(D)
			process_queue()
		if("queueall")
			LAZYINITLIST(build_queue)
			for(var/v in local_designs.known_designs)
				var/datum/design/D = local_designs.known_designs[v]
				if(!(D.build_type & allowed_design_types) || !(selected_category in D.category) || length(D.reagents_list))
					continue
				build_queue += D
				log_printing_design(D)
			process_queue()
		if("unqueue")
			if(!build_queue)
				return
			var/index = text2num(params["index"])
			if(!ISINDEXSAFE(build_queue, index))
				return
			build_queue.Cut(index, index + 1)
		if("unqueueall")
			if(!build_queue)
				return
			build_queue = list()
		if("queueswap")
			if(!build_queue)
				return
			var/index_from = text2num(params["from"])
			var/index_to = text2num(params["to"])
			if(!ISINDEXSAFE(build_queue, index_from) || !ISINDEXSAFE(build_queue, index_to))
				return
			build_queue.Swap(index_from, index_to)
		if("process")
			processing_queue = !processing_queue
			process_queue()
		if("sync")
			if(syncing)
				return
			sync()
		if("withdraw")
			var/id = params["id"]
			var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
			var/datum/material/M = materials.materials[id]
			if(!M || !M.amount)
				return
			var/num_sheets = input(usr, "How many sheets do you want to withdraw?", "Withdrawing [M.name]") as num|null
			if(isnull(num_sheets) || num_sheets <= 0)
				return
			materials.retrieve_sheets(num_sheets, id)
		else
			return FALSE
	add_fingerprint(usr)

/**
  * # Exosuit Fabricator (upgraded)
  *
  * Upgraded variant of [/obj/machinery/mecha_part_fabricator].
  */
/obj/machinery/mecha_part_fabricator/upgraded/New()
	..()
	// Upgraded components
	QDEL_LIST(component_parts)
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mechfab(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/**
  * # Spacepod Fabricator
  *
  * Spacepod variant of [/obj/machinery/mecha_part_fabricator].
  */
/obj/machinery/mecha_part_fabricator/spacepod
	name = "spacepod fabricator"
	allowed_design_types = PODFAB
	req_access = list(ACCESS_MECHANIC)

/obj/machinery/mecha_part_fabricator/spacepod/New()
	..()
	QDEL_LIST(component_parts)
	component_parts = list()
	component_parts += new /obj/item/circuitboard/podfab(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/mecha_part_fabricator/spacepod/Initialize(mapload)
	. = ..()
	categories = list(
		"Pod_Weaponry",
		"Pod_Armor",
		"Pod_Cargo",
		"Pod_Parts",
		"Pod_Frame",
		"Misc"
	)

/**
  * # Robotic Fabricator
  *
  * Cyborgs-only variant of [/obj/machinery/mecha_part_fabricator].
  */
/obj/machinery/mecha_part_fabricator/robot
	name = "robotic fabricator"
	categories = list("Cyborg")

/obj/machinery/mecha_part_fabricator/syndicate
	name = "Syndicate exosuit fabricator"
	desc = "Nothing is being built."
	req_access = list(ACCESS_SYNDICATE)
	ui_theme = "nologo"

/obj/machinery/mecha_part_fabricator/syndicate/New()
	..()
	// Components
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mechfab/syndicate(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()
	if(is_taipan(z))
		icon_state = "fabsyndie-idle"
		icon_open = "fabsyndie-o"
		icon_closed = "fabsyndie-idle"

/obj/machinery/mecha_part_fabricator/syndicate/Initialize(mapload)
	. = ..()
	categories = list(
		"Cyborg",
		"Cyborg Repair",
		"Ripley",
		"Firefighter",
		"Clarke",
		"Odysseus",
		"Dark Gygax",
		"Rover",
		"H.O.N.K",
		"Reticence",
		"Phazon",
		"Exosuit Equipment",
		"Cyborg Upgrade Modules",
		"Medical",
		"Misc",
		"Syndicate"
	)


#undef EXOFAB_BASE_CAPACITY
#undef EXOFAB_CAPACITY_PER_RATING
#undef EXOFAB_EFFICIENCY_PER_RATING
#undef EXOFAB_SPEED_UPGRADE_MULTIPLIER
