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
	var/list/all_liquids = intake_1.fluid_datum.fluid_container.fluids + intake_2.fluid_datum.fluid_container.fluids
	if(!length(all_liquids))
		return
