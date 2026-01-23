#define DEFAULT_OPERATION_TIME 10 SECONDS //! The base amount of time needed to craft an item

/// MARK: Centrifuge
/obj/machinery/nuclear_centrifuge
	name = "Fuel Enrichment Centrifuge"
	desc = "An advanced device capable of separating and collecting fissile materials from enriched fuel rods."
	icon = 'icons/obj/fission/reactor_machines.dmi'
	icon_state = "centrifuge_empty"
	idle_power_consumption = 200
	active_power_consumption = 3000
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF | FREEZE_PROOF
	armor = list(melee = 25, bullet = 10, laser = 30, energy = 0, bomb = 0, rad = INFINITY, fire = INFINITY, acid = 70)

	/// The time it takes for the machine to process a rod
	var/work_time
	/// The averaged amount of all stock parts
	var/average_component_rating
	/// The result when we are done operating
	var/rod_result
	/// Holds the rod object inserted into the machine
	var/obj/item/nuclear_rod/held_rod
	/// the soundloop we will be using while operating
	var/datum/looping_sound/centrifuge/soundloop

	COOLDOWN_DECLARE(enrichment_timer)

/obj/machinery/nuclear_centrifuge/Initialize(mapload)
	. = ..()
	soundloop = new(list(src), FALSE)
	component_parts = list()
	component_parts += new /obj/item/circuitboard/nuclear_centrifuge(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	RefreshParts()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/nuclear_centrifuge/examine(mob/user)
	. = ..()
	if(held_rod)
		. += SPAN_NOTICE("The current fuel rod may be removed with <b>Alt-Click</b>.")

/obj/machinery/nuclear_centrifuge/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/nuclear_centrifuge/RefreshParts()
	average_component_rating = 0
	for(var/obj/item/stock_parts/manipulator/part in component_parts)
		average_component_rating += part.rating
	average_component_rating /= 4 // average all 4 components
	work_time = DEFAULT_OPERATION_TIME / average_component_rating

/obj/machinery/nuclear_centrifuge/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	. = ..()
	if(!istype(used, /obj/item/nuclear_rod/fuel))
		return CONTINUE_ATTACK
	if(stat & NOPOWER)
		return ITEM_INTERACT_COMPLETE
	if(panel_open)
		to_chat(user, SPAN_WARNING("You must close the access panel first!"))
		return ITEM_INTERACT_COMPLETE
	if(power_state == ACTIVE_POWER_USE) // dont start a new cycle when on
		to_chat(user, SPAN_WARNING("There is already a fuel rod being processed!"))
		return ITEM_INTERACT_COMPLETE
	var/obj/item/nuclear_rod/fuel/rod = used
	var/list/enrichment_to_name = list()
	var/list/radial_list = list()
	var/obj/item/nuclear_rod/fuel/rod_enrichment
	if(rod.power_enrich_progress >= rod.enrichment_cycles && rod.power_enrich_result)
		rod_enrichment = rod.power_enrich_result
		enrichment_to_name["[rod_enrichment::name]"] = rod_enrichment
		radial_list["[rod_enrichment::name]"] = image(icon = rod_enrichment::icon, icon_state = rod_enrichment::icon_state)
	if(rod.heat_enrich_progress >= rod.enrichment_cycles && rod.heat_enrich_result)
		rod_enrichment = rod.heat_enrich_result
		enrichment_to_name["[rod_enrichment::name]"] = rod_enrichment
		radial_list["[rod_enrichment::name]"] = image(icon = rod_enrichment::icon, icon_state = rod_enrichment::icon_state)
	if(!length(radial_list))
		to_chat(user, SPAN_WARNING("This rod has no potential for enrichment!"))
		return ITEM_INTERACT_COMPLETE
	var/enrichment_choice = show_radial_menu(user, src, radial_list, src, radius = 30, require_near = TRUE)
	if(!enrichment_choice)
		return ITEM_INTERACT_COMPLETE
	rod_result = enrichment_to_name[enrichment_choice]
	held_rod = rod
	user.transfer_item_to(rod, src)
	begin_enrichment()
	return ITEM_INTERACT_COMPLETE

/obj/machinery/nuclear_centrifuge/AltClick(mob/user, modifiers)
	if(!held_rod)
		return
	if(power_state == ACTIVE_POWER_USE)
		to_chat(user, SPAN_WARNING("You cannot remove the fuel rod while the machine is running!"))
		return
	held_rod.forceMove(get_turf(src))
	held_rod = null
	icon_state = "centrifuge_empty"
	playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)

/obj/machinery/nuclear_centrifuge/process()
	if(stat & NOPOWER)
		if(power_state == ACTIVE_POWER_USE)
			abort_enrichment()
		return
	if(power_state == IDLE_POWER_USE)
		return
	if(!COOLDOWN_FINISHED(src, enrichment_timer))
		return
	finish_enrichment()

/obj/machinery/nuclear_centrifuge/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(held_rod)
		to_chat(user, SPAN_WARNING("The machine cannot be opened while it contains a fuel rod!"))
		return ITEM_INTERACT_COMPLETE
	default_deconstruction_screwdriver(user, "centrifuge_maint", "centrifuge_empty", I)

/obj/machinery/nuclear_centrifuge/proc/begin_enrichment()
	power_state = ACTIVE_POWER_USE
	icon_state = "centrifuge_on"
	COOLDOWN_START(src, enrichment_timer, work_time)
	soundloop.start()

/obj/machinery/nuclear_centrifuge/proc/abort_enrichment()
	power_state = IDLE_POWER_USE
	icon_state = "centrifuge_full"
	playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
	soundloop.stop()

/obj/machinery/nuclear_centrifuge/proc/finish_enrichment()
	icon_state = "centrifuge_full"
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	power_state = IDLE_POWER_USE
	var/new_rod = new rod_result(contents)
	rod_result = null
	QDEL_NULL(held_rod)
	held_rod = new_rod
	soundloop.stop()

// MARK: Rod Fabricator

/obj/machinery/nuclear_rod_fabricator
	name = "Nuclear Fuel Rod Fabricator"
	desc = "A highly specialized fabricator for crafting nuclear rods."
	icon = 'icons/obj/fission/reactor_machines.dmi'
	icon_state = "rod_fab"
	idle_power_consumption = 50
	active_power_consumption = 3000
	density = TRUE
	resistance_flags = FIRE_PROOF | FREEZE_PROOF
	armor = list(melee = 25, bullet = 10, laser = 30, energy = 0, bomb = 0, rad = INFINITY, fire = INFINITY, acid = 70)

	/// Our holder for materials
	var/datum/component/material_container/materials
	/// How fast do we operate and/or do we get extra rods
	var/efficiency_coeff = 1
	/// The list for carrying fuel rods
	var/list/category_fuel = list()
	/// The list for carrying moderator rods
	var/list/category_moderator = list()
	/// The list for carrying coolant rods
	var/list/category_coolant = list()
	/// Is the rod fabricator currently upgraded from science
	var/upgraded = FALSE
	/// What is the current item being produced
	var/schematic
	/// The time it takes for the machine to process a rod
	var/work_time

	COOLDOWN_DECLARE(fabrication_timer)

/obj/machinery/nuclear_rod_fabricator/upgraded
	upgraded = TRUE

/obj/machinery/nuclear_rod_fabricator/Initialize(mapload)
	. = ..()
	materials = AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_BLUESPACE, MAT_PLASTIC), 0, TRUE, /obj/item/stack, CALLBACK(src, PROC_REF(is_insertion_ready)), CALLBACK(src, PROC_REF(AfterMaterialInsert)))
	materials.precise_insertion = TRUE
	component_parts = list()
	component_parts += new /obj/item/circuitboard/nuclear_rod_fabricator(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)

	RefreshParts()
	create_designs()

/obj/machinery/nuclear_rod_fabricator/RefreshParts()
	var/temp_coeff = 12
	var/average_component_rating = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		temp_coeff -= M.rating
		average_component_rating += M.rating
	work_time = DEFAULT_OPERATION_TIME / average_component_rating
	efficiency_coeff = clamp(temp_coeff / 10, 0.05, 1)
	temp_coeff = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		temp_coeff += M.rating
	materials.max_amount = temp_coeff * 75000

/obj/machinery/nuclear_rod_fabricator/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/nuclear_rod_fabricator/proc/is_insertion_ready(mob/user)
	if(panel_open)
		to_chat(user, SPAN_WARNING("You can't load [src] while it's opened!"))
		return FALSE

	if(stat & BROKEN)
		to_chat(user, SPAN_WARNING("[src] is broken."))
		return FALSE

	if(stat & NOPOWER)
		to_chat(user, SPAN_WARNING("[src] has no power."))
		return FALSE

	return TRUE

/obj/machinery/nuclear_rod_fabricator/proc/AfterMaterialInsert(type_inserted, id_inserted, amount_inserted)
	var/stack_name
	if(ispath(type_inserted, /obj/item/stack/ore/bluespace_crystal))
		stack_name = "bluespace"
		use_power(MINERAL_MATERIAL_AMOUNT / 10)
	else
		var/obj/item/stack/S = type_inserted
		stack_name = initial(S.name)
		use_power(min(1000, (amount_inserted / 100)))
	add_overlay("protolathe_[stack_name]")
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, cut_overlay), "protolathe_[stack_name]"), 10)

/obj/machinery/nuclear_rod_fabricator/proc/check_mat(obj/item/nuclear_rod/being_built, M)
	var/A = materials.amount(M)
	if(!A)
		visible_message(SPAN_WARNING("Something has gone very wrong. Alert a developer."))
		return
	else
		A /= max(1, (being_built.materials[M] * efficiency_coeff))
	return A

/obj/machinery/nuclear_rod_fabricator/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/storage/part_replacer))
		return ..()

	if(panel_open)
		to_chat(user, SPAN_WARNING("You can't load [src] while the maintenance panel is opened."))
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/rod_fabricator_upgrade))
		upgraded = TRUE
		create_designs()
		user.drop_item(used)
		qdel(used)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/nuclear_rod_fabricator/crowbar_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	materials.retrieve_all()
	default_deconstruction_crowbar(user, I)

/obj/machinery/nuclear_rod_fabricator/on_deconstruction()
	if(upgraded)
		new /obj/item/rod_fabricator_upgrade(loc)
	return ..()

/obj/machinery/nuclear_rod_fabricator/proc/create_designs()
	category_fuel = list()
	category_moderator = list()
	category_coolant = list()

	for(var/obj/rod_path as anything in subtypesof(/obj/item/nuclear_rod))
		if(initial(rod_path.desc) == ABSTRACT_TYPE_DESC)
			continue

		var/datum/nuclear_rod_design/D = new /datum/nuclear_rod_design()
		D.build_metadata_list(rod_path)

		if(!D.metadata["craftable"])
			continue

		if(D.metadata["upgrade_required"] && !upgraded)
			continue

		if(ispath(rod_path, /obj/item/nuclear_rod/fuel))
			category_fuel += D
		else if(ispath(rod_path, /obj/item/nuclear_rod/moderator))
			category_moderator += D
		else if(ispath(rod_path, /obj/item/nuclear_rod/coolant))
			category_coolant += D

/obj/machinery/nuclear_rod_fabricator/ui_data(mob/user)
	var/list/data = list()

	data["fuel_rods"] = list()
	for(var/datum/nuclear_rod_design/D in category_fuel)
		data["fuel_rods"] += list(D.metadata)

	data["moderator_rods"] = list()
	for(var/datum/nuclear_rod_design/D in category_moderator)
		data["moderator_rods"] += list(D.metadata)

	data["coolant_rods"] = list()
	for(var/datum/nuclear_rod_design/D in category_coolant)
		data["coolant_rods"] += list(D.metadata)

	// Add available resources from the material container
	data["resources"] = list()
	if(materials)
		// Get all material types that the fabricator supports
		var/list/supported_materials = list(
			MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA,
			MAT_URANIUM, MAT_TITANIUM, MAT_BLUESPACE, MAT_PLASTIC, MAT_BANANIUM, MAT_TRANQUILLITE
		)
		for(var/mat_id in supported_materials)
			var/amount = materials.amount(mat_id)
			if(amount > 0)
				var/sheets = round(amount / MINERAL_MATERIAL_AMOUNT)
				var/display_name = CallMaterialName(mat_id)
				data["resources"][display_name] = list(
					"amount" = amount,
					"sheets" = sheets,
					"id" = mat_id
				)

	return data

/obj/machinery/nuclear_rod_fabricator/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/nuclear_rod_fabricator/interact(mob/user)
	. = ..()
	if(panel_open)
		to_chat(user, SPAN_WARNING("You can't access [src] while it's opened!"))
		return

/obj/machinery/nuclear_rod_fabricator/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/nuclear_rod_fabricator/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NuclearRodFabricator", name)
		ui.open()

/obj/machinery/nuclear_rod_fabricator/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("fabricate_rod")
			var/rod_type_path = text2path(params["type_path"])
			if(!rod_type_path)
				return FALSE

			var/datum/nuclear_rod_design/selected_design
			for(var/datum/nuclear_rod_design/D in category_fuel + category_moderator + category_coolant)
				if(D.type_path == rod_type_path)
					selected_design = D
					break

			if(!selected_design)
				return FALSE

			if(power_state == ACTIVE_POWER_USE)
				to_chat(usr, SPAN_WARNING("A rod is already being fabricated!"))
				return FALSE

			// Check if we have enough materials
			var/obj/item/nuclear_rod/temp_rod = new rod_type_path()
			var/list/required_materials = temp_rod.materials
			qdel(temp_rod)

			if(!required_materials || !length(required_materials))
				to_chat(usr, SPAN_WARNING("This rod design has no material requirements defined - please create an issue report!"))
				return FALSE

			for(var/mat_id in required_materials)
				var/required_amount = required_materials[mat_id] * efficiency_coeff
				if(materials.amount(mat_id) < required_amount)
					to_chat(usr, SPAN_WARNING("Not enough materials! Need [required_amount] units of [mat_id]!"))
					return FALSE

			// Spend materials
			var/list/materials_to_use = list()
			for(var/mat_id in required_materials)
				materials_to_use[mat_id] = required_materials[mat_id] * efficiency_coeff

			if(!materials.use_amount(materials_to_use))
				to_chat(usr, SPAN_WARNING("Failed to deduct materials!"))
				return FALSE

			// Begin Process
			begin_fabrication(rod_type_path)

			return TRUE

		if("eject_material")
			var/material_id = params["id"]
			var/amount = params["amount"]

			if(!material_id || !materials.materials[material_id])
				return FALSE

			var/desired_sheets = 0
			if(amount == "custom")
				var/datum/material/M = materials.materials[material_id]
				var/max_sheets = round(M.amount / MINERAL_MATERIAL_AMOUNT)
				if(max_sheets <= 0)
					to_chat(usr, SPAN_WARNING("Not enough [M.name] to eject!"))
					return FALSE
				desired_sheets = tgui_input_number(usr, "How many sheets do you want to eject?", "Ejecting [M.name]", 1, max_sheets, 1)
				if(isnull(desired_sheets))
					return FALSE
			else
				desired_sheets = text2num(amount)

			desired_sheets = max(0, round(desired_sheets))
			if(desired_sheets > 0)
				materials.retrieve_sheets(desired_sheets, material_id, get_turf(src))
				to_chat(usr, SPAN_NOTICE("[src] ejects [desired_sheets] sheets."))

			return TRUE

	return FALSE

/obj/machinery/nuclear_rod_fabricator/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(power_state == ACTIVE_POWER_USE)
		to_chat(user, SPAN_WARNING("The machine cannot be opened while it is operating!"))
		return ITEM_INTERACT_COMPLETE
	default_deconstruction_screwdriver(user, "rod_fab_maint", "rod_fab", I)

/obj/machinery/nuclear_rod_fabricator/proc/begin_fabrication(rod_type_path)
	power_state = ACTIVE_POWER_USE
	icon_state = "rod_fab_on"
	COOLDOWN_START(src, fabrication_timer, work_time)
	schematic = rod_type_path

/obj/machinery/nuclear_rod_fabricator/proc/finish_fabrication()
	power_state = IDLE_POWER_USE
	icon_state = "rod_fab"
	var/obj/item/nuclear_rod/new_rod = new schematic(get_turf(src))
	src.visible_message(SPAN_NOTICE("[src] fabricates \a [new_rod.name]."))
	playsound(src, 'sound/machines/ping.ogg', 50, TRUE)

/obj/machinery/nuclear_rod_fabricator/proc/abort_fabrication()
	power_state = IDLE_POWER_USE
	icon_state = "rod_fab"
	playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)

/obj/machinery/nuclear_rod_fabricator/process()
	if(stat & NOPOWER)
		if(power_state == ACTIVE_POWER_USE)
			abort_fabrication()
		return
	if(power_state == IDLE_POWER_USE)
		return
	if(!COOLDOWN_FINISHED(src, fabrication_timer))
		return
	finish_fabrication()

#undef DEFAULT_OPERATION_TIME
