/// The base amount of plants that can be stored before taking our matter bin into account.
#define BASE_MAX_STORABLE_PLANTS 40

/obj/machinery/biogenerator
	name = "biogenerator"
	desc = "Converts plants into biomass, which can be used to construct useful items."
	icon = 'icons/obj/machines/biogenerator.dmi'
	icon_state = "biogen-empty"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
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
	QDEL_LIST(stored_plants)
	return ..()

/obj/machinery/biogenerator/ex_act(severity)
	container?.ex_act(severity)
	..()

/obj/machinery/biogenerator/handle_atom_del(atom/A)
	..()
	if(A != container)
		return
	container = null
	update_icon()
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

/obj/machinery/biogenerator/update_icon()
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

/obj/machinery/biogenerator/attackby(obj/item/O, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(processing)
		to_chat(user, "<span class='warning'>[src] is currently processing.</span>")
		return
	if(exchange_parts(user, O))
		return

	if(istype(O, /obj/item/reagent_containers/glass))
		if(panel_open)
			to_chat(user, "<span class='warning'>Close the maintenance panel first.</span>")
			return
		if(container)
			to_chat(user, "<span class='warning'>A container is already loaded into [src].</span>")
			return
		if(!user.drop_item())
			return

		O.forceMove(src)
		container = O
		to_chat(user, "<span class='notice'>You add the [container] to [src].</span>")
		update_icon()
		SStgui.update_uis(src)
		return TRUE

	else if(istype(O, /obj/item/storage/bag/plants))
		if(length(stored_plants) >= max_storable_plants)
			to_chat(user, "<span class='warning'>[src] can't hold any more plants!</span>")
			return

		var/obj/item/storage/bag/plants/PB = O
		for(var/obj/item/reagent_containers/food/snacks/grown/G in PB.contents)
			if(length(stored_plants) >= max_storable_plants)
				break
			PB.remove_from_storage(G, src)
			stored_plants += G

		if(length(stored_plants) < max_storable_plants)
			to_chat(user, "<span class='info'>You empty [PB] into [src].</span>")
		else
			to_chat(user, "<span class='info'>You fill [src] to its capacity.</span>")

		SStgui.update_uis(src)
		return TRUE

	else if(istype(O, /obj/item/reagent_containers/food/snacks/grown))
		if(length(stored_plants) >= max_storable_plants)
			to_chat(user, "<span class='warning'>[src] can't hold any more plants!</span>")
			return
		if(!user.unEquip(O))
			return

		O.forceMove(src)
		stored_plants += O
		to_chat(user, "<span class='info'>You put [O] in [src].</span>")
		SStgui.update_uis(src)
		return TRUE

	else if(istype(O, /obj/item/disk/design_disk))
		user.visible_message("[user] begins to load [O] in [src]...",
			"You begin to load a design from [O]...",
			"You hear the chatter of a floppy drive.")
		processing = TRUE
		SStgui.update_uis(src)

		var/obj/item/disk/design_disk/D = O
		if(do_after(user, 1 SECONDS, target = src))
			files.AddDesign2Known(D.blueprint)

		processing = FALSE
		update_ui_product_list()
		return TRUE
	else
		to_chat(user, "<span class='warning'>You cannot put this in [name]!</span>")

/**
 * Builds/Updates the `product_list` used by the UI.
 */
/obj/machinery/biogenerator/proc/update_ui_product_list()
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

	SStgui.update_uis(src, update_static_data = TRUE)

/obj/machinery/biogenerator/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/biogenerator/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/biogenerator/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Biogenerator", "Biogenerator", 390, 600, master_ui, state)
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
	update_icon()

	var/plants_processed = length(stored_plants)
	for(var/obj/plant as anything in stored_plants)
		var/plant_biomass = plant.reagents.get_reagent_amount("nutriment") + plant.reagents.get_reagent_amount("plantmatter")
		biomass += max(plant_biomass, 0.1) * 10 * productivity
		qdel(plant)

	stored_plants.Cut()
	playsound(loc, 'sound/machines/blender.ogg', 50, 1)
	use_power(plants_processed * 150)
	addtimer(CALLBACK(src, .proc/end_processing), (plants_processed * 5) / productivity)

/obj/machinery/biogenerator/proc/end_processing()
	processing = FALSE
	SStgui.update_uis(src)
	update_icon()

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

	// Creating all other items, such as monkey cubes or nutriment bottles.
	else
		if(!check_cost(D, amount))
			return
		for(var/i in 1 to amount)
			new D.build_path(get_turf(src))

	biomass -= (D.materials[MAT_BIOMASS] / efficiency) * amount
	SStgui.update_uis(src)
	update_icon()

/**
 * Detach the `container` from the biogenerator.
 */
/obj/machinery/biogenerator/proc/detach_container()
	if(!container)
		return
	container.forceMove(get_turf(src))
	container = null
	update_icon()

#undef BASE_MAX_STORABLE_PLANTS
