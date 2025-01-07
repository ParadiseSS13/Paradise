/obj/item/refinery_spawner
	name = "packaged refinery"
	desc = "A fully functional refinery, tightly packed with bluespace technology to automatically deploy where needed."

/obj/item/refinery_spawner/activate_self(mob/user)
	if(..())
		return
	var/direction = tgui_input_list(user, "What direction should the refinery be?", "Refinery package", GLOB.cardinal)
	if(!direction)
		return

	new /obj/machinery/fluid_pipe/plasma_refinery(get_turf(src), direction)



/*
/obj/machinery/atmospherics/unary/plasma_condenser
	name = "Plasma Condenser"
	desc = "Turns refined plasma into plasma gas."

/obj/machinery/atmospherics/unary/plasma_refinery
	name = "Plasma Refinery"
	desc = "Turns plasma gas into plasma fuel. Can accept a combination of gases and chemicals to improve purity."
*/
/obj/machinery/fluid_pipe/plasma_refinery
	name = "Plasma Refinery"
	desc = "Turns crude plasma into refined plasma. Can accept a combination of chemicals to improve purity."
	icon = 'icons/obj/pipes/fluid_machinery.dmi'
	icon_state = "refinery"
	just_a_pipe = FALSE
	pixel_x = -32
	/// Intake of fluids
	var/obj/machinery/fluid_pipe/abstract/refinery_intake/intake
	/// Currently selected recipe
	var/datum/refinery_recipe/selected_recipe

/obj/machinery/fluid_pipe/abstract/refinery_intake
	icon = null
	icon_state = null

/obj/machinery/fluid_pipe/plasma_refinery/Initialize(mapload, direction)
	. = ..()
	//dir = direction
	make_intakes()

/obj/machinery/fluid_pipe/plasma_refinery/examine(mob/user)
	. = ..()
	if(selected_recipe)
		. += "[src] currently has [selected_recipe.type] selected."
	else
		. += "No recipe is currently selected."

/obj/machinery/fluid_pipe/plasma_refinery/update_icon_state()
	return

/obj/machinery/fluid_pipe/plasma_refinery/proc/make_intakes()
	dir = EAST
	switch(dir)
		if(NORTH)
			AddComponent(/datum/component/multitile, list(
				list(MACH_CENTER),
				list(    1)
			))

		if(SOUTH)
			AddComponent(/datum/component/multitile, list(
				list(    1),
				list(MACH_CENTER)
			))

		if(EAST)
			AddComponent(/datum/component/multitile, list(
				list(1, MACH_CENTER)
			))

		if(WEST)
			AddComponent(/datum/component/multitile, list(
				list(MACH_CENTER, 1)
			))

	intake = new(get_step(src, REVERSE_DIR(dir)))

/obj/machinery/fluid_pipe/plasma_refinery/attack_hand(mob/user)
	if(..())
		return TRUE
	var/recipe = tgui_input_list(user, "What recipe do you want to select?", "Refinery", subtypesof(/datum/refinery_recipe))
	if(!recipe)
		return TRUE
	selected_recipe = new recipe

/obj/machinery/fluid_pipe/plasma_refinery/process()
	if(!selected_recipe)
		return

	var/list/all_liquids = intake?.fluid_datum.fluid_container.fluids
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
		fluid_datum.fluid_container.add_fluid(GLOB.fluid_id_to_path[id], selected_recipe.output[id])


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
