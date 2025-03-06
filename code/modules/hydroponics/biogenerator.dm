/// The base amount of plants that can be stored before taking our matter bin into account.
#define BASE_MAX_STORABLE_PLANTS 40

/obj/machinery/biogenerator
	name = "biogenerator"
	desc = "Converts plants into biomass, which can be used to construct useful items."
	icon = 'icons/obj/biogenerator.dmi'
	icon_state = "biogen-empty"
	density = TRUE
	anchored = TRUE
	idle_power_consumption = 40
	/// Is the biogenerator curretly grinding up plants?
	var/processing = FALSE
	/// The container that is used to store reagents from certain products.
	var/obj/item/reagent_containers/glass/container
	/// The amount of biomass stored in the machine.
	var/biomass = 0
	/// Used to modify the cost of producing items. A higher number means cheaper costs.
	var/efficiency = 0
	/// Used to modify how much biomass is produced by grinding plants. A higher number means more biomass.
	var/productivity = 0
	/// A list of plants currently stored plants in the biogenerator.
	var/list/stored_plants = list()
	/// The maximum amount of plants the biogenerator can store.
	var/max_storable_plants = BASE_MAX_STORABLE_PLANTS
	/// A reference to the biogenerator's research, which contains designs that it can build.
	var/datum/research/files
	/// A list which holds all categories and items the biogenator has available. Used with the UI to save having to rebuild this every time someone opens it.
	var/list/product_list = list()
	/// The [/datum/design]'s categories which can be produced by this machine and can be uploaded via a disk.
	var/static/list/categories = list("Food", "Botany Chemicals", "Organic Materials", "Leather and Cloth")
	var/static/list/acceptable_items = typecacheof(list(
		/obj/item/seeds,
		/obj/item/unsorted_seeds,
		/obj/item/food/grown,
		/obj/item/grown,
		/obj/item/food/grown/ash_flora,
		/obj/item/food/honeycomb))

/obj/machinery/biogenerator/Initialize(mapload)
	. = ..()
	files = new(src)
	component_parts = list()
	component_parts += new /obj/item/circuitboard/biogenerator(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/biogenerator/Destroy()
	QDEL_NULL(container)
	QDEL_NULL(files)
	QDEL_LIST_CONTENTS(stored_plants)
	return ..()

/obj/machinery/biogenerator/ex_act(severity)
	container?.ex_act(severity)
	..()

/obj/machinery/biogenerator/handle_atom_del(atom/A)
	..()
	if(A != container)
		return
	container = null
	update_icon(UPDATE_ICON_STATE)
	SStgui.update_uis(src)

/obj/machinery/biogenerator/RefreshParts()
	var/effeciency_prev = efficiency
	efficiency = 0
	productivity = 0
	max_storable_plants = BASE_MAX_STORABLE_PLANTS

	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		productivity += B.rating
		max_storable_plants *= B.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		efficiency += M.rating

	if(effeciency_prev != efficiency)
		update_ui_product_list() // We have have a higher `efficiency` now, and need to re-calc the product costs.

/obj/machinery/biogenerator/update_icon_state()
	if(panel_open)
		icon_state = "biogen-empty-o"
	else if(!container)
		icon_state = "biogen-empty"
	else if(!processing)
		icon_state = "biogen-stand"
	else
		icon_state = "biogen-work"

/obj/machinery/biogenerator/screwdriver_act(mob/living/user, obj/item/I)
	if(!default_deconstruction_screwdriver(user, "biogen-empty-o", "biogen-empty", I))
		return FALSE
	if(container)
		container.forceMove(loc)
		container = null
	return TRUE

/obj/machinery/biogenerator/crowbar_act(mob/living/user, obj/item/I)
	return default_deconstruction_crowbar(user, I)

/obj/machinery/biogenerator/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	// TODO: This feels off, no where else do we have a blanket "print a
	// message for any other kind of item interaction attempt" that's keyed to intent
	// See if this can be made more sensible after everything's been migrated
	// to the new attack chain
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(used, /obj/item/storage/part_replacer))
		return ..()

	if(processing)
		to_chat(user, "<span class='warning'>[src] is currently processing.</span>")
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/reagent_containers/glass))
		if(panel_open)
			to_chat(user, "<span class='warning'>Close the maintenance panel first.</span>")
			return ITEM_INTERACT_COMPLETE

		if(container)
			to_chat(user, "<span class='warning'>A container is already loaded into [src].</span>")
			return ITEM_INTERACT_COMPLETE

		if(!user.drop_item())
			return ITEM_INTERACT_COMPLETE

		used.forceMove(src)
		container = used
		to_chat(user, "<span class='notice'>You add the [container] to [src].</span>")
		update_icon(UPDATE_ICON_STATE)
		SStgui.update_uis(src)
		return ITEM_INTERACT_COMPLETE

	else if(istype(used, /obj/item/storage/bag/plants))
		if(length(stored_plants) >= max_storable_plants)
			to_chat(user, "<span class='warning'>[src] can't hold any more plants!</span>")
			return ITEM_INTERACT_COMPLETE

		var/obj/item/storage/bag/plants/PB = used
		for(var/obj/item/P in PB.contents)
			// No need to filter here, because plant bags should have the same list of acceptable items we do.
			if(length(stored_plants) >= max_storable_plants)
				break
			PB.remove_from_storage(P, src)
			stored_plants += P

		if(length(stored_plants) < max_storable_plants)
			to_chat(user, "<span class='notice'>You empty [PB] into [src].</span>")
		else
			to_chat(user, "<span class='notice'>You fill [src] to its capacity.</span>")

		SStgui.update_uis(src)
		return ITEM_INTERACT_COMPLETE

	else if(is_type_in_typecache(used, acceptable_items))
		if(length(stored_plants) >= max_storable_plants)
			to_chat(user, "<span class='warning'>[src] can't hold any more plants!</span>")
			return ITEM_INTERACT_COMPLETE
		if(!user.transfer_item_to(used, src))
			return ITEM_INTERACT_COMPLETE

		stored_plants += used
		to_chat(user, "<span class='notice'>You put [used] in [src].</span>")
		SStgui.update_uis(src)
		return ITEM_INTERACT_COMPLETE

	else if(istype(used, /obj/item/disk/design_disk))
		user.visible_message("[user] begins to load [used] in [src]...",
			"You begin to load a design from [used]...",
			"You hear the chatter of a floppy drive.")
		processing = TRUE
		SStgui.update_uis(src)

		var/obj/item/disk/design_disk/D = used
		if(do_after(user, 1 SECONDS, target = src))
			files.AddDesign2Known(D.blueprint)

		processing = FALSE
		update_ui_product_list(user)
		return ITEM_INTERACT_COMPLETE

	to_chat(user, "<span class='warning'>You cannot put [used] in [src]!</span>")
	return ITEM_INTERACT_COMPLETE

/**
 * Builds/Updates the `product_list` used by the UI.
 */
/obj/machinery/biogenerator/proc/update_ui_product_list(mob/user)
	product_list = list()
	for(var/category in categories)
		product_list[category] = list()

	for(var/V in files.known_designs)
		var/datum/design/D = files.known_designs[V]
		for(var/category in categories)
			if(!(category in D.category))
				continue
			product_list[category][D.name] = list(
				"name" = D.name,
				"id" = D.id,
				"cost" = D.materials[MAT_BIOMASS] / efficiency
			)

	update_static_data(user)
	SStgui.update_uis(src)

/obj/machinery/biogenerator/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/biogenerator/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/biogenerator/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/biogenerator/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Biogenerator", "Biogenerator")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/biogenerator/ui_data(mob/user)
	var/list/data = list(
		"processing" = processing,
		"biomass" = biomass,
		"has_plants" = length(stored_plants) ? TRUE : FALSE
	)
	if(container)
		data["container"] = TRUE
		data["container_curr_reagents"] = container.reagents.total_volume
		data["container_max_reagents"] = container.reagents.maximum_volume
	else
		data["container"] = FALSE

	return data

/obj/machinery/biogenerator/ui_static_data(mob/user)
	return list("product_list" = product_list)

/obj/machinery/biogenerator/ui_act(action, list/params)
	if(..())
		return

	. = TRUE
	switch(action)
		if("activate")
			process_plants(usr)
		if("detach_container")
			detach_container()
		if("eject_plants")
			eject_plants()
		if("create")
			var/datum/design/D = files.known_designs[params["id"]]
			if(!D)
				return
			var/amount = clamp(text2num(params["amount"]), 1, 10)
			create_product(D, amount)

/**
 * Tells the biogenerator to grind up any stored plants, and produce an appropriate amount of biomass.
 *
 * Argumens:
 * * mob/user - the mob who activated the biogenerator
 */
/obj/machinery/biogenerator/proc/process_plants(mob/user)
	if(stat & (NOPOWER | BROKEN))
		return
	if(processing)
		to_chat(user, "<span class='warning'>[src] is currently processing!</span>")
		return

	processing = TRUE
	SStgui.update_uis(src)
	update_icon(UPDATE_ICON_STATE)

	var/plants_processed = length(stored_plants)
	var/new_biomass = 0
	for(var/obj/plant as anything in stored_plants)
		var/plant_biomass = plant.reagents?.get_reagent_amount("nutriment") + plant.reagents?.get_reagent_amount("plantmatter")
		new_biomass += max(plant_biomass, 0.1)
		qdel(plant)
	biomass += new_biomass * 10 * productivity

	stored_plants.Cut()
	playsound(loc, 'sound/machines/blender.ogg', 50, TRUE)
	use_power(plants_processed * 150)
	addtimer(CALLBACK(src, PROC_REF(end_processing)), min(20 SECONDS, new_biomass))

/obj/machinery/biogenerator/proc/end_processing()
	processing = FALSE
	SStgui.update_uis(src)
	update_icon(UPDATE_ICON_STATE)

/**
 * Ejects the biogenerator's stored plants
 */
/obj/machinery/biogenerator/proc/eject_plants()
	for(var/obj/plant as anything in stored_plants)
		plant.forceMove(get_turf(src))
	stored_plants.Cut()
	SStgui.update_uis(src)

/**
 * Check if the biogenerator has enough biomass to create the passed in design `D`, times the `mutiplier`.
 *
 * Arguments:
 * * datum/design/D - the design we want to create
 * * multiplier - how many of this design should be built
 */
/obj/machinery/biogenerator/proc/check_cost(datum/design/D, multiplier = 1)
	if(!D.materials[MAT_BIOMASS] || ((D.materials[MAT_BIOMASS] / efficiency) * multiplier) > biomass)
		return FALSE
	return TRUE

/**
 * Check if the biogenerator's `container` can hold the reagents we're trying to give it.
 *
 * Arguments:
 * * datum/design/D - the design we want to create reagents from
 * * multiplier - how many of this design should be built
 */
/obj/machinery/biogenerator/proc/check_container_volume(datum/design/D, multiplier = 1)
	var/sum_reagents = 0
	for(var/R in D.make_reagents)
		sum_reagents +=  D.make_reagents[R]
	sum_reagents *= multiplier

	if(container.reagents.total_volume + sum_reagents > container.reagents.maximum_volume)
		return FALSE
	return TRUE

/**
 * Create biogenerator products and subtracts the appropriate biomass cost.
 *
 * Arguments:
 * * datum/design/D - the design we want to create, or create reagents from
 * * amount - how many of this design should be built
 */
/obj/machinery/biogenerator/proc/create_product(datum/design/D, amount)
	// Creating stack-based items like cloth or cardboard.
	if(ispath(D.build_path, /obj/item/stack))
		if(!check_cost(D, amount))
			return
		new D.build_path(get_turf(src), amount)

	// Filling the `container` with reagents.
	else if(length(D.make_reagents))
		if(!check_container_volume(D, amount))
			return
		for(var/R in D.make_reagents)
			container.reagents.add_reagent(R, D.make_reagents[R] * amount)

	// Creating all other items, such as monkey cubes or nutrient bottles.
	else
		if(!check_cost(D, amount))
			return
		for(var/i in 1 to amount)
			new D.build_path(get_turf(src))

	biomass -= (D.materials[MAT_BIOMASS] / efficiency) * amount
	SStgui.update_uis(src)
	update_icon(UPDATE_ICON_STATE)

/**
 * Detach the `container` from the biogenerator.
 */
/obj/machinery/biogenerator/proc/detach_container()
	if(!container)
		return
	container.forceMove(get_turf(src))
	container = null
	update_icon(UPDATE_ICON_STATE)

#undef BASE_MAX_STORABLE_PLANTS
