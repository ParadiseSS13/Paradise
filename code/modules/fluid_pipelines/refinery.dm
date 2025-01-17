/obj/machinery/fluid_pipe/plasma_refinery
	name = "Plasma Refinery"
	desc = "Turns crude plasma into refined plasma. Can accept a combination of chemicals to improve purity."
	icon = 'icons/obj/pipes/64x64fluid_machinery.dmi'
	icon_state = "refinery_4"
	dir = EAST
	pixel_x = -32
	just_a_pipe = FALSE
	density = TRUE
	new_attack_chain = TRUE
	just_a_pipe = FALSE
	/// Intake of fluids
	var/obj/machinery/fluid_pipe/abstract/refinery_intake/intake
	/// Currently selected recipe
	var/datum/refinery_recipe/selected_recipe

/obj/machinery/fluid_pipe/abstract/refinery_intake

/obj/machinery/fluid_pipe/abstract/refinery_intake/Initialize(mapload, _parent, direction)
	connect_dirs = GLOB.cardinal.Copy()
	connect_dirs -= dir
	return ..()

/obj/machinery/fluid_pipe/plasma_refinery/Initialize(mapload, direction)
	if(direction)
		dir = direction
	connect_dirs = GLOB.cardinal.Copy()
	connect_dirs -= REVERSE_DIR(dir)
	make_intakes()
	return ..()

/obj/machinery/fluid_pipe/plasma_refinery/Destroy()
	qdel(intake)
	return ..()

/obj/machinery/fluid_pipe/plasma_refinery/examine(mob/user)
	. = ..()
	if(selected_recipe)
		. += "[src] currently has [selected_recipe.type] selected."
	else
		. += "No recipe is currently selected."

/obj/machinery/fluid_pipe/plasma_refinery/update_icon_state()
	return

/obj/machinery/fluid_pipe/plasma_refinery/update_overlays()
	. = ..()
	if(dir == EAST) // DGTODO clean this up
		for(var/obj/pipe as anything in get_adjacent_pipes())
			. += "connector_r_[get_dir(src, pipe)]"
		for(var/obj/pipe as anything in intake.get_adjacent_pipes())
			. += "connector_l_[get_dir(intake, pipe)]"
	else
		for(var/obj/pipe as anything in get_adjacent_pipes())
			. += "connector_l_[get_dir(src, pipe)]"
		for(var/obj/pipe as anything in intake.get_adjacent_pipes())
			. += "connector_r_[get_dir(intake, pipe)]"

/obj/machinery/fluid_pipe/plasma_refinery/proc/make_intakes()
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

/obj/machinery/fluid_pipe/plasma_refinery/attack_hand(mob/user)
	if(..())
		return TRUE
	var/recipe = tgui_input_list(user, "What recipe do you want to select?", "Refinery", subtypesof(/datum/refinery_recipe))
	if(!recipe)
		return TRUE
	selected_recipe = new recipe

/obj/machinery/fluid_pipe/plasma_refinery/process()
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

	// 516 TODO
	for(var/id in selected_recipe.output)
		fluid_datum.add_fluid(GLOB.fluid_id_to_path[id], selected_recipe.output[id])

/obj/machinery/fluid_pipe/plasma_refinery/east
	icon_state = "refinery_4"
	dir = EAST
	pixel_x = -32

/obj/machinery/fluid_pipe/plasma_refinery/west
	icon_state = "refinery_8"
	dir = WEST

// MARK: refinery recipes

/datum/refinery_recipe
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
	input = list("unr_pl" = 20)
	output = list("ref_pl" = 5)

/datum/refinery_recipe/refined_plasma/catalyze
	input = list("unr_pl" = 40, "brine" = 10)
	output = list("ref_pl" = 30, "brine" = 10)

// Basic fuel, easy to make and faster but creates waste
/datum/refinery_recipe/basic_fuel
	input = list("ref_pl" = 20)
	output = list("b_fuel" = 10, "waste" = 5)

/datum/refinery_recipe/turbofuel
	input = list("ref_pl" = 40, "b_fuel" = 10, "ref_oil" = 10)
	output = list("tur_fuel" = 20)

/datum/refinery_recipe/refined_oil
	input = list("water" = 30, "unr_oil" = 20)
	output = list("water" = 15, "ref_oil" = 10, "visc_oil" = 10)

/datum/refinery_recipe/plastic
	input = list("visc_oil" = 20, "waste" = 30)
	output = list("water" = 10)
	solid_output = /obj/item/stack/sheet/plastic
