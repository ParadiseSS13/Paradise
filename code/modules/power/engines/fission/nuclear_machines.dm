#define DEFAULT_TIME 10 SECONDS

/// MARK: Cetrifuge
/obj/machinery/nuclear_centrifuge
	name = "Fuel Enrichment Centrifuge"
	desc = "An advanced device capable of seperating and collecting fissile materials from enriched fuel rods."
	icon = 'icons/obj/fission/reactor_parts.dmi'
	icon_state = "centrifuge"
	power_state = IDLE_POWER_USE
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

/obj/machinery/nuclear_centrifuge/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/nuclear_centrifuge/update_overlays()
	. = ..()
	if(power_state == ACTIVE_POWER_USE)
		. += "centrifuge_spinning"
	else
		. += "centrifuge_empty"
	. += "centrifuge_glass"

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
			return
		if(panel_open)
			return
		if(power_state == ACTIVE_POWER_USE) // dont start a new cycle when on
			return
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
			to_chat(user, "<span class='warning'>This rod has no potential for enrichment!</span>")
			return ITEM_INTERACT_COMPLETE

		var/enrichment_choice = show_radial_menu(user, src, radial_list, src, radius = 30, require_near = TRUE)
		if(!enrichment_choice)
			return
		rod_result = enrichment_to_name[enrichment_choice]
		held_rod = rod
		user.transfer_item_to(rod, src)
		begin_enrichment()
		return ITEM_INTERACT_COMPLETE

/obj/machinery/nuclear_centrifuge/process()
	if(stat & NOPOWER)
		if(power_state == ACTIVE_POWER_USE)
			abort_enrichment()
		return
	if(power_state == IDLE_POWER_USE)
		return
	if(world.time < time_to_completion)
		return
	finish_enrichment()

/obj/machinery/nuclear_centrifuge/proc/begin_enrichment()
	power_state = ACTIVE_POWER_USE
	update_icon(UPDATE_OVERLAYS)
	time_to_completion = world.time + 10 SECONDS
	soundloop.start()

/obj/machinery/nuclear_centrifuge/proc/abort_enrichment()
	held_rod.forceMove(loc)
	held_rod = null
	power_state = IDLE_POWER_USE
	update_icon(UPDATE_OVERLAYS)
	playsound(src, 'sound/machines/buzz-sigh.ogg', 30, 1)
	soundloop.stop()

/obj/machinery/nuclear_centrifuge/proc/finish_enrichment()
	held_rod = null
	power_state = IDLE_POWER_USE
	update_icon(UPDATE_OVERLAYS)
	playsound(src, 'sound/machines/ping.ogg', 30, 1)
	new rod_result(loc)
	rod_result = null
	soundloop.stop()

// MARK: Rod Fabricator

/obj/machinery/nuclear_rod_fabricator
	name = "Nuclear Fuel Rod Fabricator"
	desc = "A highly specialized fabricator for crafting nuclear rods."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "protolathe"
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

/obj/machinery/nuclear_rod_fabricator/RefreshParts()
	var/temp_coeff = 12
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		temp_coeff -= M.rating
	efficiency_coeff = clamp(temp_coeff / 10, 0, 1)
	temp_coeff = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		temp_coeff += M.rating
	materials.max_amount = temp_coeff * 75000


/obj/machinery/nuclear_rod_fabricator/proc/is_insertion_ready(mob/user)
	if(panel_open)
		to_chat(user, "<span class='warning'>You can't load [src] while it's opened!</span>")
		return FALSE

	if(busy)
		to_chat(user, "<span class='warning'>[src] is busy right now.</span>")
		return FALSE

	if(stat & BROKEN)
		to_chat(user, "<span class='warning'>[src] is broken.</span>")
		return FALSE

	if(stat & NOPOWER)
		to_chat(user, "<span class='warning'>[src] has no power.</span>")
		return FALSE

	if(loaded_item)
		to_chat(user, "<span class='warning'>[src] is already loaded.</span>")
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
		visible_message("<span class='warning'>Something has gone very wrong. Alert a developer.</span>")
		return
	else
		A = A / max(1, (being_built.materials[M] * efficiency_coeff))
	return A

/obj/machinery/nuclear_rod_fabricator/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/storage/part_replacer))
		return ..()

	if(panel_open)
		to_chat(user, "<span class='warning'>You can't load [src] while it's opened.</span>")
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/nuclear_rod_fabricator/crowbar_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	materials.retrieve_all()
	default_deconstruction_crowbar(user, I)

/obj/machinery/nuclear_rod_fabricator/proc/create_designs()
	for(var/obj/item/nuclear_rod/rod in subtypesof(/obj/item/nuclear_rod))
		if(!rod.craftable)
			continue
		if(istype(rod, /obj/item/nuclear_rod/fuel))
			category_fuel += rod
		if(istype(rod, /obj/item/nuclear_rod/moderator))
			category_moderator += rod
		if(istype(rod, /obj/item/nuclear_rod/coolant))
			category_coolant += rod

/obj/machinery/nuclear_rod_fabricator/proc/get_rod_info(rod_type)
	return rod_type
#warn finish this when burza gets to the UI screen

/obj/machinery/nuclear_rod_fabricator/interact(mob/user)
	. = ..()
	if(panel_open)
		to_chat(user, "<span class='warning'>You can't access [src] while it's opened.</span>")
		return
	ui_interact(user)

/obj/machinery/nuclear_rod_fabricator/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/nuclear_rod_fabricator/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Autolathe", name)
		ui.open()

// MARK: Temp rod fab
/obj/machinery/temp_rod_fab
	name = "DEBUG Nuclear Fuel Rod Fabricator"
	desc = "A highly specialized fabricator for crafting nuclear rods."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "protolathe"
	idle_power_consumption = 50
	density = TRUE
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/temp_rod_fab/attack_hand(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/carbon = user
	var/list/choices = list("Fuel", "Moderator", "Coolant")
	var/selected = tgui_input_list(carbon, "Select a nuclear rod type:", "Nuclear Rods", choices)

	if(!selected)
		return
	if(!Adjacent(carbon))
		return

	var/list/rod_list = list()
	switch(selected)
		if("Fuel")
			for(var/obj/item/nuclear_rod/fuel/rod in subtypesof(/obj/item/nuclear_rod/fuel))
				rod_list += rod
		if("Moderator")
			for(var/obj/item/nuclear_rod/moderator/rod in subtypesof(/obj/item/nuclear_rod/moderator))
				rod_list += rod
		if("Coolant")
			for(var/obj/item/nuclear_rod/coolant/rod in subtypesof(/obj/item/nuclear_rod/coolant))
				rod_list += rod

	selected = tgui_input_list(carbon, "Select a nuclear rod:", "Nuclear Rods", rod_list)

	if(!selected)
		return
	if(!Adjacent(carbon))
		return

	var/obj/item/nuclear_rod/new_rod = selected
	carbon.put_in_hands(new_rod)

/obj/machinery/power/reactor_power
	name = "DEBUG Nucear Power Output"
	desc = "A place for the reactor to spit out its output"
	icon_state = "teg"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/power_gen = 0
	var/obj/machinery/atmospherics/fission_reactor/linked_reactor

/obj/machinery/power/reactor_power/Initialize(mapload)
	. = ..()
	linked_reactor = GLOB.main_fission_reactor

/obj/machinery/power/reactor_power/process()
	produce_direct_power(linked_reactor.final_power)

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

#undef DEFAULT_TIME
