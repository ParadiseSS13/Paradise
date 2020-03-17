/*
Protolathe

Similar to an autolathe, you load glass and metal sheets (but not other objects) into it to be used as raw materials for the stuff
it creates. All the menus and other manipulation commands are in the R&D console.

Note: Must be placed west/left of and R&D console to function.

*/
/obj/machinery/r_n_d/protolathe
	name = "Protolathe"
	desc = "Converts raw materials into useful objects."
	icon_state = "protolathe"
	container_type = OPENCONTAINER

	var/efficiency_coeff

	var/list/categories = list(
								"Bluespace",
								"Computer Parts",
								"Equipment",
								"Janitorial",
								"Medical",
								"Mining",
								"Miscellaneous",
								"Power",
								"Stock Parts",
								"Weapons"
								)

	reagents = new()


/obj/machinery/r_n_d/protolathe/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/protolathe(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	RefreshParts()

	reagents.my_atom = src

/obj/machinery/r_n_d/protolathe/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/protolathe(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	RefreshParts()

	reagents.my_atom = src

/obj/machinery/r_n_d/protolathe/RefreshParts()
	var/T = 0
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		G.reagents.trans_to(src, G.reagents.total_volume)
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	materials.max_amount = T * 75000
	T = 1.2
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		T -= M.rating/10
	efficiency_coeff = min(max(0, T), 1)

/obj/machinery/r_n_d/protolathe/proc/check_mat(datum/design/being_built, var/M)	// now returns how many times the item can be built with the material
	var/A = materials.amount(M)
	if(!A)
		A = reagents.get_reagent_amount(M)
		A = A / max(1, (being_built.reagents_list[M]))
	else
		A = A / max(1, (being_built.materials[M]))
	return A

/obj/machinery/r_n_d/protolathe/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(shocked)
		if(shock(user,50))
			return TRUE
	if(default_deconstruction_screwdriver(user, "protolathe_t", "protolathe", O))
		if(linked_console)
			linked_console.linked_lathe = null
			linked_console = null
		return

	if(exchange_parts(user, O))
		return

	if(panel_open)
		if(istype(O, /obj/item/crowbar))
			for(var/obj/I in component_parts)
				if(istype(I, /obj/item/reagent_containers/glass/beaker))
					reagents.trans_to(I, reagents.total_volume)
				I.loc = src.loc
			for(var/obj/item/reagent_containers/glass/G in component_parts)
				reagents.trans_to(G, G.reagents.maximum_volume)
			materials.retrieve_all()
			default_deconstruction_crowbar(user, O)
			return 1
		else
			to_chat(user, "<span class='warning'>You can't load the [src.name] while it's opened.</span>")
			return 1
	if(O.is_open_container())
		return FALSE
	else
		return ..()
