#define DEFAULT_TIME 10 SECONDS

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
	/// The time needed to finish enrichment
	var/time_to_completion
	/// the soundloop we will be using while operating
	var/datum/looping_sound/centrifuge/soundloop
	var/soundloop_type

	COOLDOWN_DECLARE(enrichment_timer)

/obj/machinery/nuclear_centrifuge/Initialize(mapload)
	. = ..()
	soundloop = new(list(src), FALSE)
	component_parts = list()
	component_parts += new /obj/item/circuitboard/nuclear_centrifuge(src)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	RefreshParts()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/nuclear_centrifuge/examine(mob/user)
	. = ..()
	if(held_rod)
		. += SPAN_NOTICE("The current fuel rod may be removed with ALT-Click.")

/obj/machinery/nuclear_centrifuge/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/nuclear_centrifuge/RefreshParts()
	average_component_rating = 0
	for(var/obj/item/stock_parts/manipulator/part in component_parts)
		average_component_rating += part.rating
	average_component_rating /= 4 //average all 4 components
	work_time = DEFAULT_TIME / average_component_rating

/obj/machinery/nuclear_centrifuge/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	. = ..()
	if(istype(used, /obj/item/nuclear_rod/fuel))
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
	if(held_rod)
		if(power_state == ACTIVE_POWER_USE)
			to_chat(user, SPAN_WARNING("You cannot remove the fuel rod while the machine is running!"))
			return
		held_rod.forceMove(loc)
		held_rod = null
		icon_state = "centrifuge_empty"
		playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)

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
		to_chat(user, SPAN_WARNING("The machine cannot be opened while it contains a fuel rod."))
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
	playsound(src, 'sound/machines/buzz-sigh.ogg', 30, 1)
	soundloop.stop()

/obj/machinery/nuclear_centrifuge/proc/finish_enrichment()
	icon_state = "centrifuge_full"
	playsound(src, 'sound/machines/ping.ogg', 30, 1)
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

	/// is the machine currently operating
	var/busy = FALSE
	/// The item we have loaded into the general slot
	var/obj/item/loaded_item
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
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)

	RefreshParts()
	create_designs()

/obj/machinery/nuclear_rod_fabricator/RefreshParts()
	var/temp_coeff = 12
	var/average_component_rating = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		temp_coeff -= M.rating
		average_component_rating += M.rating
	work_time = DEFAULT_TIME / average_component_rating
	efficiency_coeff = clamp(temp_coeff / 10, 0.05, 1)
	temp_coeff = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		temp_coeff += M.rating
	materials.max_amount = temp_coeff * 75000


/obj/machinery/nuclear_rod_fabricator/proc/is_insertion_ready(mob/user)
	if(panel_open)
		to_chat(user, SPAN_WARNING("You can't load [src] while it's opened!"))
		return FALSE

	if(busy)
		to_chat(user, SPAN_WARNING("[src] is busy right now."))
		return FALSE

	if(stat & BROKEN)
		to_chat(user, SPAN_WARNING("[src] is broken."))
		return FALSE

	if(stat & NOPOWER)
		to_chat(user, SPAN_WARNING("[src] has no power."))
		return FALSE

	if(loaded_item)
		to_chat(user, SPAN_WARNING("[src] is already loaded."))
		return FALSE

	return TRUE

/obj/machinery/nuclear_rod_fabricator/Destroy()
	if(loaded_item)
		loaded_item.forceMove(get_turf(src))
		loaded_item = null
	materials = null
	return ..()

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
		A = A / max(1, (being_built.materials[M] * efficiency_coeff))
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

/obj/machinery/nuclear_rod_fabricator/proc/create_designs()
	category_fuel = list()
	category_moderator = list()
	category_coolant = list()

	for(var/rod_path in subtypesof(/obj/item/nuclear_rod))
		if(rod_path == /obj/item/nuclear_rod || rod_path == /obj/item/nuclear_rod/fuel || rod_path == /obj/item/nuclear_rod/moderator || rod_path == /obj/item/nuclear_rod/coolant)
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
		to_chat(user, SPAN_WARNING("You can't access [src] while it's opened."))
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

			// Check if we have enough materials
			var/obj/item/nuclear_rod/temp_rod = new rod_type_path()
			var/list/required_materials = temp_rod.materials
			qdel(temp_rod)

			if(!required_materials || !length(required_materials))
				to_chat(usr, SPAN_WARNING("This rod design has no material requirements defined - please create an issue report"))
				return FALSE

			for(var/mat_id in required_materials)
				var/required_amount = required_materials[mat_id] * efficiency_coeff
				if(materials.amount(mat_id) < required_amount)
					to_chat(usr, SPAN_WARNING("Not enough materials! Need [required_amount] units of [mat_id]."))
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
		to_chat(user, SPAN_WARNING("The machine cannot be opened while it is operating."))
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
	to_chat(usr, SPAN_NOTICE("[src] fabricates \a [new_rod.name]."))
	playsound(src, 'sound/machines/ping.ogg', 50, 1)

/obj/machinery/nuclear_rod_fabricator/proc/abort_fabrication()
	power_state = IDLE_POWER_USE
	icon_state = "rod_fab"
	playsound(src, 'sound/machines/buzz-sigh.ogg', 30, 1)

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

// MARK: Reactor Power Output

/obj/machinery/power/reactor_power
	name = "reactor output terminal"
	desc = "A bundle of heavy watt power cables for managing power output from the reactor."
	icon_state = "term"
	plane = FLOOR_PLANE
	layer = WIRE_TERMINAL_LAYER //a bit above wires
	resistance_flags = INDESTRUCTIBLE
	var/power_gen = 0
	var/obj/machinery/atmospherics/fission_reactor/linked_reactor

/obj/machinery/power/reactor_power/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/power/reactor_power/LateInitialize()
	. = ..()
	linked_reactor = GLOB.main_fission_reactor

/obj/machinery/power/reactor_power/process()
	if(linked_reactor && linked_reactor.can_create_power)
		produce_direct_power(linked_reactor.final_power)

/// MARK: Monitor

/obj/machinery/computer/fission_monitor
	name = "NGCR monitoring console"
	desc = "Used to monitor the Nanotrasen Gas Cooled Fission Reactor."
	icon_keyboard = "power_key"
	icon_screen = "smmon_0"
	circuit = /obj/item/circuitboard/fission_monitor
	light_color = LIGHT_COLOR_YELLOW
	/// Last status of the active reactor for caching purposes
	var/last_status
	/// Reference to the active reactor
	var/obj/machinery/atmospherics/fission_reactor/active

/obj/machinery/computer/fission_monitor/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/fission_monitor/LateInitialize()
	. = ..()
	active = GLOB.main_fission_reactor

/obj/machinery/computer/fission_monitor/Destroy()
	active = null
	return ..()

/obj/machinery/computer/fission_monitor/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/fission_monitor/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/fission_monitor/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/fission_monitor/process()
	if(stat & (NOPOWER|BROKEN))
		return FALSE

	if(active)
		var/new_status = active.get_status()
		if(last_status != new_status)
			last_status = new_status
			if(last_status == SUPERMATTER_ERROR)
				last_status = SUPERMATTER_INACTIVE
			icon_screen = "smmon_[last_status]"
			update_icon()

	return TRUE

/obj/machinery/computer/fission_monitor/multitool_act(mob/living/user, obj/item/I)
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/multitool = I
	if(istype(multitool.buffer, /obj/machinery/atmospherics/fission_reactor))
		active = multitool.buffer
		to_chat(user, SPAN_NOTICE("You load the buffer's linking data to [src]."))

/obj/machinery/computer/fission_monitor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ReactorMonitor", name)
		ui.open()

	return TRUE

/obj/machinery/computer/fission_monitor/ui_data(mob/user)
	var/list/data = list()
	// If we somehow dont have an engine anymore, handle it here.
	if(!active)
		active = null
		return
	if(active.stat & BROKEN)
		active = null
		return

	var/datum/gas_mixture/air = active.air_contents
	var/power_kilowatts = round((active.final_power / 1000), 1)

	data["venting"] = active.venting
	data["NGCR_integrity"] = active.get_integrity()
	data["NGCR_power"] = power_kilowatts
	data["NGCR_ambienttemp"] = air.temperature()
	data["NGCR_ambientpressure"] = air.return_pressure()
	data["NGCR_coefficient"] = active.reactivity_multiplier
	if(active.control_lockout)
		data["NGCR_throttle"] = 0
	else
		data["NGCR_throttle"] = 100 - active.desired_power
	data["NGCR_operatingpower"] = 100 - active.operating_power
	var/list/gasdata = list()
	var/TM = air.total_moles()
	if(TM)
		gasdata.Add(list(list("name"= "Oxygen", "amount" = air.oxygen(), "portion" = round(100 * air.oxygen() / TM, 0.01))))
		gasdata.Add(list(list("name"= "Carbon Dioxide", "amount" = air.carbon_dioxide(), "portion" = round(100 * air.carbon_dioxide() / TM, 0.01))))
		gasdata.Add(list(list("name"= "Nitrogen", "amount" = air.nitrogen(), "portion" = round(100 * air.nitrogen() / TM, 0.01))))
		gasdata.Add(list(list("name"= "Plasma", "amount" = air.toxins(), "portion" = round(100 * air.toxins() / TM, 0.01))))
		gasdata.Add(list(list("name"= "Nitrous Oxide", "amount" = air.sleeping_agent(), "portion" = round(100 * air.sleeping_agent() / TM, 0.01))))
		gasdata.Add(list(list("name"= "Agent B", "amount" = air.agent_b(), "portion" = round(100 * air.agent_b() / TM, 0.01))))
	else
		gasdata.Add(list(list("name"= "Oxygen", "amount" = 0, "portion" = 0)))
		gasdata.Add(list(list("name"= "Carbon Dioxide", "amount" = 0,"portion" = 0)))
		gasdata.Add(list(list("name"= "Nitrogen", "amount" = 0,"portion" = 0)))
		gasdata.Add(list(list("name"= "Plasma", "amount" = 0,"portion" = 0)))
		gasdata.Add(list(list("name"= "Nitrous Oxide", "amount" = 0,"portion" = 0)))
		gasdata.Add(list(list("name"= "Agent B", "amount" = 0,"portion" = 0)))
	data["gases"] = gasdata

	return data

/obj/machinery/computer/fission_monitor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(stat & (BROKEN|NOPOWER))
		return

	if(action == "set_throttle")
		var/temp_number = text2num(params["NGCR_throttle"])
		active.desired_power = 100 - temp_number

	if(action == "toggle_vent")
		if(active.vent_lockout)
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
			visible_message(SPAN_WARNING("ERROR: Vent servos unresponsive. Manual closure required."))
		else
			active.venting = !active.venting

// MARK: Circuits

/obj/item/circuitboard/nuclear_centrifuge
	board_name = "Nuclear Centrifuge"
	icon_state = "engineering"
	build_path = /obj/machinery/nuclear_centrifuge
	board_type = "machine"
	origin_tech = "programming=4;engineering=4"
	req_components = list(/obj/item/stock_parts/manipulator = 4)

/obj/item/circuitboard/nuclear_rod_fabricator
	board_name = "Nuclear Rod Fabricator"
	icon_state = "engineering"
	build_path = /obj/machinery/nuclear_rod_fabricator
	board_type = "machine"
	origin_tech = "programming=4;engineering=4"
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/matter_bin = 2,
		)

/obj/item/circuitboard/machine/reactor_chamber
	board_name = "Reactor Chamber"
	icon_state = "engineering"
	build_path = /obj/machinery/atmospherics/reactor_chamber
	origin_tech = "engineering=2"
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/metal = 2,
		/obj/item/stack/sheet/mineral/plastitanium = 2,
	)

#undef DEFAULT_TIME

// MARK: Slag

/obj/item/slag
	name = "corium slag"
	desc = "A large clump of active nuclear fuel fused with structural reactor metals."
	icon = 'icons/effects/effects.dmi'
	icon_state = "big_molten"
	move_resist = MOVE_FORCE_STRONG // Massive chunk of metal slag, shouldnt be moving it without carrying.
	w_class = WEIGHT_CLASS_HUGE
	force = 15
	throwforce = 10

/obj/item/slag/Initialize(mapload)
	. = ..()
	scatter_atom()
	var/datum/component/inherent_radioactivity/rad_component = AddComponent(/datum/component/inherent_radioactivity, 200, 200, 200, 2)
	START_PROCESSING(SSradiation, rad_component)

// MARK: Starter Grenade

/obj/item/grenade/nuclear_starter
	name = "Neutronic Agitator"
	desc = "A throwable device capable of inducing an artificial startup in rod chambers. Won't do anything for chambers not positioned correctly, or chambers without any rods inserted."

/obj/item/grenade/nuclear_starter/prime()
	playsound(src.loc, 'sound/weapons/bsg_explode.ogg', 50, TRUE, -3)
	var/obj/effect/warp_effect/supermatter/warp = new(loc)
	addtimer(CALLBACK(src, PROC_REF(delete_pulse), warp), 0.5 SECONDS)
	warp.pixel_x += 16
	warp.pixel_y += 16
	warp.transform = matrix().Scale(0.01,0.01)
	animate(warp, time = 0.5 SECONDS, transform = matrix().Scale(1,1))
	var/list/chamber_list = list()
	for(var/obj/machinery/atmospherics/reactor_chamber/chamber in range(3, loc))
		chamber_list += chamber
	for(var/obj/machinery/atmospherics/reactor_chamber/chamber in chamber_list)
		if(chamber.chamber_state == CHAMBER_DOWN && chamber.held_rod)
			chamber.operational = TRUE
			chamber.update_icon(UPDATE_OVERLAYS)
	for(var/obj/machinery/atmospherics/reactor_chamber/chamber in chamber_list)
		if(chamber.check_status())
			chamber.requirements_met = TRUE
		else
			chamber.requirements_met = FALSE
		chamber.update_icon(UPDATE_OVERLAYS)
	icon = "null" // make it look like it detonated.

/obj/item/grenade/nuclear_starter/proc/delete_pulse(warp)
	QDEL_NULL(warp)
	qdel(src)

// MARK: Rad Proof Pool

/turf/simulated/floor/plasteel/reactor_pool
	name = "holding pool"
	icon = 'icons/obj/fission/pool.dmi'
	icon_state = "pool_round"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER
	var/obj/machinery/poolcontroller/linkedcontroller = null

/turf/simulated/floor/plasteel/reactor_pool/Initialize(mapload)
	. = ..()
	var/image/overlay_image = image('icons/misc/beach.dmi', icon_state = "seadeep", layer = ABOVE_MOB_LAYER)
	overlay_image.plane = GAME_PLANE
	overlay_image.alpha = 75
	overlays += overlay_image
	RegisterSignal(src, COMSIG_ATOM_INITIALIZED_ON, PROC_REF(InitializedOn))

/turf/simulated/floor/plasteel/reactor_pool/crowbar_act(mob/user, obj/item/I)
	return

/turf/simulated/floor/plasteel/reactor_pool/proc/InitializedOn(atom/A)
	if(!linkedcontroller)
		return
	if(istype(A, /obj/effect/decal/cleanable)) // Better a typecheck than looping through thousands of turfs everyday
		linkedcontroller.decalinpool += A

/turf/simulated/floor/plasteel/reactor_pool/Entered(atom/movable/AM, atom/OldLoc)
	. = ..()
	if(!linkedcontroller)
		return
	if(ismob(AM))
		linkedcontroller.mobinpool += AM

/turf/simulated/floor/plasteel/reactor_pool/Exited(atom/movable/AM, direction)
	. = ..()
	if(!linkedcontroller)
		return
	if(ismob(AM))
		linkedcontroller.mobinpool -= AM


/turf/simulated/floor/plasteel/reactor_pool/wall
	icon_state = "pool_wall_round"

/turf/simulated/floor/plasteel/reactor_pool/wall/ladder
	icon_state = "ladder_wall_round"

/turf/simulated/floor/plasteel/reactor_pool/wall/filter
	icon_state = "filter_wall_round"

/turf/simulated/floor/plasteel/reactor_pool/square
	icon_state = "pool_sharp_square"

/obj/structure/railing/pool_lining
	name = "pool lining"
	icon = 'icons/obj/fission/pool.dmi'
	icon_state = "poolborder"
	flags = ON_BORDER | NODECONSTRUCT | INDESTRUCTIBLE
	max_integrity = 200

/obj/structure/railing/pool_lining/ex_act(severity)
	if(severity == EXPLODE_HEAVY || severity == EXPLODE_DEVASTATE)
		qdel(src)

/obj/structure/railing/corner/pool_corner
	name = "pool lining"
	icon = 'icons/obj/fission/pool.dmi'
	icon_state = "bordercorner"

/obj/structure/railing/corner/pool_corner/inner
	icon_state = "innercorner"

/obj/machinery/poolcontroller/invisible/nuclear
	srange = 6
	deep_water = TRUE

/obj/machinery/poolcontroller/invisible/nuclear/Initialize(mapload)
	var/contents_loop = linked_area
	if(!linked_area)
		contents_loop = range(srange, src)

	for(var/turf/T in contents_loop)
		if(istype(T, /turf/simulated/floor/plasteel/reactor_pool))
			var/turf/simulated/floor/plasteel/reactor_pool/W = T
			W.linkedcontroller = src
			linkedturfs += T
	return ..()

/obj/machinery/poolcontroller/invisible/nuclear/Destroy()
	for(var/turf/simulated/floor/plasteel/reactor_pool/W in linkedturfs)
		if(W.linkedcontroller == src)
			W.linkedcontroller = null
	return ..()

/obj/machinery/poolcontroller/invisible/nuclear/processMob()
	for(var/mob/M in mobinpool)
		if(!istype(get_turf(M), /turf/simulated/floor/plasteel/reactor_pool))
			mobinpool -= M
			continue

		M.clean_blood(radiation_clean = TRUE)

		if(isliving(M))
			var/mob/living/L = M
			L.ExtinguishMob()
			L.adjust_fire_stacks(-20) //Douse ourselves with water to avoid fire more easily

		if(ishuman(M))
			handleDrowning(M)

/// MARK: Fab  upgrade

/obj/item/rod_fabricator_upgrade
	name = "Nuclear Fabricator Upgrade"
	desc = "A design disk containing a dizzying amount of designs and improvements for nuclear rod fabrication."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk5"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'
	new_attack_chain = TRUE

/// MARK: Chamber Doors

/obj/effect/temp_visual/chamber_closing
	icon = 'icons/obj/fission/reactor_chamber.dmi'
	icon_state = "doors_closing"
	duration = 0.7 SECONDS
	layer = ABOVE_ALL_MOB_LAYER + 0.03

