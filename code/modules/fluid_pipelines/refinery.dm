/obj/machinery/atmospherics/unary/plasma_condenser
	name = "Plasma Condenser"
	desc = "Turns refined plasma into plasma gas."

/obj/machinery/atmospherics/unary/plasma_refinery
	name = "Plasma Refinery"
	desc = "Turns plasma gas into plasma fuel. Can accept a combination of gases and chemicals to improve purity."

/obj/machinery/fluid_pipe/plasma_refinery
	name = "Plasma Refinery"
	desc = "Turns crude plasma into refined plasma. Can accept a combination of chemicals to improve purity."
	just_a_pipe = FALSE
	/// First intake of fluids
	var/obj/machinery/fluid_pipe/abstract/refinery_intake/intake_1
	/// Second intake of fluids
	var/obj/machinery/fluid_pipe/abstract/refinery_intake/intake_2
	/// Currently selected recipe
	var/datum/refinery_recipe/selected_recipe

/obj/machinery/fluid_pipe/abstract/refinery_intake

/obj/machinery/fluid_pipe/plasma_refinery/Initialize(mapload)
	. = ..()
	make_intakes()

/obj/machinery/fluid_pipe/plasma_refinery/proc/make_intakes()
	// I should really standardize this somehow
	var/x_offset = 0
	var/y_offset = 1
	var/is_side_x = TRUE
	switch(dir)
		if(NORTH)
			AddComponent(/datum/component/multitile, list(
				list(1,      1,		 1),
				list(1, MACH_CENTER, 1)
			))

		if(SOUTH)
			y_offset = -1
			AddComponent(/datum/component/multitile, list(
				list(1, MACH_CENTER, 1),
				list(1,      1,		 1)
			))

		if(EAST)
			x_offset = 1
			is_side_x = FALSE
			AddComponent(/datum/component/multitile, list(
				list(1,			  1),
				list(MACH_CENTER, 1),
				list(1,			  1)
			))

		if(WEST)
			x_offset = -1
			is_side_x = FALSE
			AddComponent(/datum/component/multitile, list(
				list(1,		1),
				list(1, MACH_CENTER),
				list(1,		1)
			))

	if(is_side_x)
		new intake_1(locate(x_offset + 1, y_offset, z))
		new intake_2(locate(x_offset - 1, y_offset, z))
	else
		new intake_1(locate(x_offset, y_offset + 1, z))
		new intake_2(locate(x_offset, y_offset - 1, z))

/obj/machinery/fluid_pipe/plasma_refinery/process()
	if(!selected_recipe)
		return

	var/list/all_liquids = intake_1.fluid_datum.fluid_container.fluids + intake_2.fluid_datum.fluid_container.fluids
	if(!length(all_liquids))
		return
	if(length(selected_recipe.input) > length(all_liquids))
		// DEBUG DGTODO
		message_admins("List of inputs is: [json_encode(all_liquids)]")
		return

	for(var/datum/fluid/liquid as anything in select_recipe.input)
		var/datum/fluid/input = all_liquids[]
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
