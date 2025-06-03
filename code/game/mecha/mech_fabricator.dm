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
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab-idle"
	density = TRUE
	anchored = TRUE
	idle_power_consumption = 20
	active_power_consumption = 5000
	// Settings
	/// Bitflags of design types that can be produced.
	var/allowed_design_types = MECHFAB
	/// List of categories to display in the UI. Designs intended for each respective category need to have the name in [/datum/design/category]. Defined in [Initialize()][/atom/proc/Initialize].
	var/list/categories = null
	/// Unused. Ensures backwards compatibility with some maps.
	var/id = null
	/// Defines what direction this thing spits out it's produced parts
	var/output_dir = SOUTH
	// Variables
	/// Production time multiplier. A lower value means faster production. Updated by [CheckParts()][/atom/proc/CheckParts].
	var/time_coeff = 1
	/// Resource efficiency multiplier. A lower value means less resources consumed. Updated by [CheckParts()][/atom/proc/CheckParts].
	var/component_coeff = 1
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
	/// ID to autolink to, used in mapload
	var/autolink_id = null
	/// UID of the network that we use
	var/network_manager_uid = null

/obj/machinery/mecha_part_fabricator/Initialize(mapload)
	..()
	// Set up some datums
	var/datum/component/material_container/materials = AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_BLUESPACE), 0, FALSE, /obj/item/stack, CALLBACK(src, PROC_REF(can_insert_materials)), CALLBACK(src, PROC_REF(on_material_insert)))
	materials.precise_insertion = TRUE

	// Components
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mechfab(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

	categories = list(
		"Cyborg",
		"Cyborg Repair",
		"Cyborg Upgrades",
		"IPC",
		"IPC Upgrades",
		"MODsuit Construction",
		"MODsuit Modules",
		"Ripley",
		"Firefighter",
		"Nkarrdem",
		"Odysseus",
		"Gygax",
		"Durand",
		"H.O.N.K",
		"Reticence",
		"Phazon",
		"Exosuit Equipment",
		"Medical",
		"Misc"
	)

	output_dir = dir
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/mecha_part_fabricator/LateInitialize()
	for(var/obj/machinery/computer/rnd_network_controller/RNC as anything in GLOB.rnd_network_managers)
		if(RNC.network_name == autolink_id)
			network_manager_uid = RNC.UID()
			RNC.mechfabs += UID()

/obj/machinery/mecha_part_fabricator/proc/get_files()
	if(!network_manager_uid)
		return null

	var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
	if(!RNC)
		network_manager_uid = null
		return null

	return RNC.research_files

/obj/machinery/mecha_part_fabricator/Destroy()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()

	var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
	if(RNC)
		// Unlink us
		RNC.mechfabs -= UID()

	return ..()

/obj/machinery/mecha_part_fabricator/multitool_act(mob/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	output_dir = turn(output_dir, -90)
	to_chat(user, "<span class='notice'>You change [src] to output to the [dir2text(output_dir)].</span>")

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

	var/datum/research/files = get_files()
	if(!files)
		atom_say("Error - No research network linked.")
		return

	if(!files.known_designs[D.id] || !(D.build_type & allowed_design_types))
		return
	if(being_built)
		atom_say("Error: Something is already being built!")
		return
	if(!can_afford_design(D))
		atom_say("Error: Insufficient materials to build [D.name]!")
		return
	if(stat & NOPOWER)
		atom_say("Error: Insufficient power!")
		return

	var/turf_to_print_on = get_step(src, output_dir)
	if(iswallturf(turf_to_print_on))
		atom_say("Error: Output blocked by a wall!")
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
	change_power_mode(ACTIVE_POWER_USE)
	add_overlay("fab-active")
	addtimer(CALLBACK(src, PROC_REF(build_design_timer_finish), D, final_cost), build_time)

	return TRUE

/**
  * Called when the timer for building a design finishes.
  *
  * Arguments:
  * * D - The design being built.
  * * final_cost - The materials consumed during the build.
  */
/obj/machinery/mecha_part_fabricator/proc/build_design_timer_finish(datum/design/D, list/final_cost)
	// Spawn the item (in a lockbox if restricted) OR mob (e.g. IRC body)
	var/atom/A = new D.build_path(get_step(src, output_dir))
	if(is_station_level(z))
		SSblackbox.record_feedback("tally", "station_mechfab_production", 1, "[D.type]")
	if(isitem(A))
		var/obj/item/I = A
		I.materials = final_cost
		if(D.locked)
			var/obj/item/storage/lockbox/research/modsuit/L = new(get_step(src, output_dir))
			I.forceMove(L)
			L.name += " ([I.name])"
			L.origin_tech = I.origin_tech
			L.req_access = D.access_requirement
			var/list/lockbox_access
			for(var/access in L.req_access)
				lockbox_access += "[get_access_desc(access)] "
				L.desc = "A locked box. It is locked to [lockbox_access]access."

	// Clean up
	being_built = null
	build_start = 0
	build_end = 0
	desc = initial(desc)
	change_power_mode(IDLE_POWER_USE)
	cut_overlays()
	atom_say("[A] is complete.")

	// Keep the queue processing going if it's on
	process_queue()

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
	addtimer(CALLBACK(src, PROC_REF(on_material_insert_timer_finish)), 1 SECONDS)
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

/obj/machinery/mecha_part_fabricator/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(default_deconstruction_screwdriver(user, "fab-o", "fab-idle", used))
		return ITEM_INTERACT_COMPLETE

	if(default_deconstruction_crowbar(user, used))
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/mecha_part_fabricator/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/mecha_part_fabricator/attack_hand(mob/user)
	if(..())
		return
	if(!allowed(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	ui_interact(user)

/obj/machinery/mecha_part_fabricator/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/mecha_part_fabricator/ui_interact(mob/user, datum/tgui/ui = null)
	if(!selected_category)
		selected_category = categories[1]

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ExosuitFabricator", name)
		ui.open()
		ui.set_autoupdate(FALSE)

/obj/machinery/mecha_part_fabricator/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/materials)
	)

/obj/machinery/mecha_part_fabricator/ui_data(mob/user)
	var/list/data = list()

	var/datum/research/files = get_files()
	if(!files)
		data["linked"] = FALSE

		var/list/controllers = list()
		for(var/obj/machinery/computer/rnd_network_controller/RNC as anything in GLOB.rnd_network_managers)
			controllers += list(list("addr" = RNC.UID(), "net_id" = RNC.network_name))
		data["controllers"] = controllers

		return data

	data["linked"] = TRUE
	data["processingQueue"] = processing_queue
	data["categories"] = categories
	data["curCategory"] = selected_category

	var/list/tech_levels = list()
	for(var/tech_id in files.known_tech)
		var/datum/tech/T = files.known_tech[tech_id]
		if(T.level <= 0)
			continue
		var/list/this_tech_list = list()
		this_tech_list["name"] = T.name
		this_tech_list["level"] = T.level
		this_tech_list["desc"] = T.desc
		tech_levels[++tech_levels.len] = this_tech_list
	data["tech_levels"] = tech_levels

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
		for(var/tech_id in files.known_designs)
			var/datum/design/D = files.known_designs[tech_id]
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

	// We switch these actions first because they can be done without files
	switch(action)
		if("unlink")
			if(!network_manager_uid)
				return
			var/choice = tgui_alert(usr, "Are you SURE you want to unlink this fabricator?\nYou wont be able to re-link without the network manager password", "Unlink", list("Yes", "No"))
			if(choice == "Yes")
				unlink()

			return TRUE

		// You should only be able to link if its not linked, to prevent weirdness
		if("linktonetworkcontroller")
			if(network_manager_uid)
				return
			var/obj/machinery/computer/rnd_network_controller/C = locateUID(params["target_controller"])
			if(istype(C, /obj/machinery/computer/rnd_network_controller))
				var/user_pass = tgui_input_text(usr, "Please enter network password", "Password Entry")
				// Check the password
				if(user_pass == C.network_password)
					C.mechfabs += UID()
					network_manager_uid = C.UID()
					to_chat(usr, "<span class='notice'>Successfully linked to <b>[C.network_name]</b>.</span>")
				else
					to_chat(usr, "<span class='alert'><b>ERROR:</b> Password incorrect.</span>")
			else
				to_chat(usr, "<span class='alert'><b>ERROR:</b> Controller not found. Please file an issue report.</span>")

			return TRUE


	var/datum/research/files = get_files()
	if(!files)
		to_chat(usr, "<span class='danger'>Error - No research network linked.</span>")
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
			var/datum/design/D = files.known_designs[id]
			if(!D)
				return
			build_design(D)
		if("queue")
			var/id = params["id"]
			if(!(id in files.known_designs))
				return
			var/datum/design/D = files.known_designs[id]
			if(!(D.build_type & allowed_design_types) || length(D.reagents_list))
				return
			LAZYADD(build_queue, D)
			process_queue()
		if("queueall")
			LAZYINITLIST(build_queue)
			for(var/tech_id in files.known_designs)
				var/datum/design/D = files.known_designs[tech_id]
				if(!(D.build_type & allowed_design_types) || !(selected_category in D.category) || length(D.reagents_list))
					continue
				build_queue += D
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
		if("withdraw")
			var/id = params["id"]
			var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
			var/datum/material/M = materials.materials[id]
			if(!M || !M.amount)
				return
			var/num_sheets = tgui_input_number(usr, "How many sheets do you want to withdraw?", "Withdrawing [M.name]", max_value = round(M.amount / 2000))
			if(isnull(num_sheets) || num_sheets <= 0)
				return
			materials.retrieve_sheets(num_sheets, id)
		else
			return FALSE
	add_fingerprint(usr)

/obj/machinery/mecha_part_fabricator/proc/unlink()
	var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
	RNC.mechfabs -= UID()
	network_manager_uid = null
	SStgui.update_uis(src)

/**
  * # Exosuit Fabricator (upgraded)
  *
  * Upgraded variant of [/obj/machinery/mecha_part_fabricator].
  */
/obj/machinery/mecha_part_fabricator/upgraded/Initialize(mapload)
	. = ..()
	// Upgraded components
	QDEL_LIST_CONTENTS(component_parts)
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mechfab(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/mecha_part_fabricator/station
	autolink_id = "station_rnd"

#undef EXOFAB_BASE_CAPACITY
#undef EXOFAB_CAPACITY_PER_RATING
#undef EXOFAB_EFFICIENCY_PER_RATING
#undef EXOFAB_SPEED_UPGRADE_MULTIPLIER
