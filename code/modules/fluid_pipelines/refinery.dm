/// Global associated list, index is the name of the recipe, key is the typepath
GLOBAL_LIST_EMPTY(refinery_recipes)

/obj/machinery/fluid_pipe/refinery
	name = "Plasma Refinery"
	desc = "Turns crude plasma into refined plasma. Can accept a combination of chemicals to improve purity."
	icon = 'icons/obj/pipes/64x64fluid_machinery.dmi'
	icon_state = "refinery_4"
	dir = EAST
	layer = MOB_LAYER + 0.5
	pixel_x = -32
	just_a_pipe = FALSE
	just_a_pipe = FALSE
	/// Intake of fluids
	var/obj/machinery/fluid_pipe/abstract/refinery_intake/intake
	/// Currently selected recipe
	var/datum/refinery_recipe/selected_recipe

/obj/machinery/fluid_pipe/abstract/refinery_intake

/obj/machinery/fluid_pipe/abstract/refinery_intake/Initialize(mapload, direction, _parent)
	connect_dirs = GLOB.cardinal.Copy()
	connect_dirs -= direction
	return ..()

/obj/machinery/fluid_pipe/abstract/refinery_intake/Destroy()
	. = ..()
	parent = null

/obj/machinery/fluid_pipe/abstract/refinery_intake/special_connect_check(obj/machinery/fluid_pipe/pipe)
	return (pipe == parent)

/obj/machinery/fluid_pipe/refinery/special_connect_check(obj/machinery/fluid_pipe/pipe)
	return (pipe == intake)

/obj/machinery/fluid_pipe/refinery/Initialize(mapload, direction)
	if(direction)
		dir = direction
		if(dir == WEST)
			icon_state = "refinery_8"
			dir = WEST
			pixel_x = 0
			connect_dirs = list(WEST, SOUTH)
		// Default direction is east so no need to change this

	connect_dirs = GLOB.cardinal.Copy()
	connect_dirs -= REVERSE_DIR(dir)
	make_intakes()
	return ..()

/obj/machinery/fluid_pipe/refinery/Destroy()
	qdel(intake)
	return ..()

/obj/machinery/fluid_pipe/refinery/examine(mob/user)
	. = ..()
	if(!selected_recipe)
		. += "No recipe is currently selected."
		return

	. += "Current recipe: [selected_recipe.name]."
	. += "Required fluids:"

	for(var/fluid as anything in selected_recipe.input)
		var/datum/fluid/path = GLOB.fluid_id_to_path[fluid]
		. += "[initial(path.fluid_name)], [selected_recipe.input[fluid]]"

/obj/machinery/fluid_pipe/refinery/update_icon_state()
	return

/obj/machinery/fluid_pipe/refinery/update_overlays()
	. = ..()
	if(!anchored)
		return

	for(var/obj/pipe as anything in get_adjacent_pipes())
		. += "connector_[dir == EAST ? "r" : "l"]_[get_dir(src, pipe)]"
	for(var/obj/pipe as anything in intake.get_adjacent_pipes())
		. += "connector_[dir == EAST ? "l" : "r"]_[get_dir(intake, pipe)]"

/obj/machinery/fluid_pipe/refinery/proc/make_intakes()
	switch(dir)
		if(EAST)
			AddComponent(/datum/component/multitile, list(
				list(1, MACH_CENTER)
			))
			pixel_x = -32

		if(WEST)
			AddComponent(/datum/component/multitile, list(
				list(MACH_CENTER, 1)
			))

	intake = new(get_step(src, REVERSE_DIR(dir)), dir, src)

/obj/machinery/fluid_pipe/refinery/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	to_chat(user, "You start [anchored ? "un" : ""]wrenching [src].")
	if(!do_after(user, 3 SECONDS * I.toolspeed, TRUE, src))
		to_chat(user, "You stop.") // DGTODO: add span classes + message
		return

	if(!anchored)
		anchored = TRUE
		make_intakes()
		blind_connect()
	else
		anchored = FALSE
		DeleteComponent(/datum/component/multitile)
		qdel(intake)
		cut_overlays()

/obj/machinery/fluid_pipe/refinery/attack_hand(mob/user)
	if(!anchored)
		// I dug myself into this hole and I'll like it
		if(dir == EAST)
			dir = WEST
			icon_state = "refinery_8"
			pixel_x = 0
			connect_dirs = list(WEST, SOUTH)
		else
			dir = EAST
			icon_state = "refinery_4"
			pixel_x = -32
			connect_dirs = list(EAST, SOUTH)
		return

	if(!length(GLOB.refinery_recipes))
		for(var/datum/refinery_recipe/recipe as anything in subtypesof(/datum/refinery_recipe))
			GLOB.refinery_recipes[initial(recipe.name)] = recipe

	var/datum/refinery_recipe/recipe = tgui_input_list(user, "What recipe do you want to select?", "Refinery", GLOB.refinery_recipes)
	if(!recipe)
		return TRUE
	recipe = GLOB.refinery_recipes[recipe]
	selected_recipe = new recipe

/obj/machinery/fluid_pipe/refinery/process()
	if(!selected_recipe || (fluid_datum == intake.fluid_datum))
		return

	var/list/all_liquids = intake?.fluid_datum.fluids
	if(!length(all_liquids))
		return
	if(length(selected_recipe.input) > length(all_liquids))
		// DEBUG DGTODO
		message_admins("List of inputs is: [json_encode(all_liquids)]")
		return

	var/inputs_satisfied = list()
	// 516 TODO
	for(var/datum/fluid/liquid as anything in all_liquids)
		if(liquid.fluid_amount >= selected_recipe.input[liquid.fluid_id])
			inputs_satisfied += liquid

	if(length(inputs_satisfied) != length(selected_recipe.input))
		return

	for(var/datum/fluid/liquid as anything in inputs_satisfied)
		liquid.fluid_amount -= selected_recipe.input[liquid.fluid_id]

	for(var/id, amount in selected_recipe.output)
		fluid_datum.add_fluid(GLOB.fluid_id_to_path[id], amount)
	if(selected_recipe.solid_output)
		new selected_recipe.solid_output(get_turf(src))

/obj/machinery/fluid_pipe/refinery/west
	icon_state = "refinery_8"
	dir = WEST
	pixel_x = 0
	connect_dirs = list(WEST, SOUTH)

// MARK: refinery recipes

/datum/refinery_recipe
	var/name = "Undefined"
	/// The fluids we require and the amounts of each. Example: list("unr_pl" = 50)
	var/list/input = list()
	/// Output fluids. Example: list("ref_pl" =  50)
	var/list/output = list()
	/// Any solid output
	var/obj/item/solid_output
	/// Will the reaction work if there are more fluid types present than the required ones
	var/only_exact_match = TRUE
	/// Only doable on lavaland?
	var/lavaland_only = TRUE

// Simplest refinery recipe, very inefficient
/datum/refinery_recipe/refined_plasma
	name = "Refined plasma"
	input = list("unr_pl" = 20)
	output = list("ref_pl" = 5)

/datum/refinery_recipe/refined_plasma/catalyze
	name = "Refined plasma (with catalyzer)"
	input = list("unr_pl" = 40, "brine" = 10)
	output = list("ref_pl" = 30)

// Basic fuel, easy to make and faster but creates waste
/datum/refinery_recipe/basic_fuel
	name = "Basic fuel"
	input = list("ref_pl" = 20)
	output = list("b_fuel" = 10, "waste" = 5)

/datum/refinery_recipe/turbofuel
	name = "Turbofuel"
	input = list("ref_pl" = 40, "b_fuel" = 10, "ref_oil" = 10)
	output = list("tur_fuel" = 20)

/datum/refinery_recipe/refined_oil
	name = "Oil refining"
	input = list("water" = 30, "unr_oil" = 20)
	output = list("water" = 15, "ref_oil" = 10, "visc_oil" = 10)

/datum/refinery_recipe/plastic
	name = "Plastic"
	input = list("visc_oil" = 20, "waste" = 30, "water" = 20)
	output = list("water" = 10)
	solid_output = /obj/item/stack/sheet/plastic
