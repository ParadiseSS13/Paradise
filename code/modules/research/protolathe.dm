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

	categories = list(
		"Bluespace",
		"Equipment",
		"Janitorial",
		"Medical",
		"Mining",
		"Miscellaneous",
		"Power",
		"Stock Parts",
		"Weapons"
	)

/obj/machinery/r_n_d/protolathe/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/protolathe(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	create_reagents()
	RefreshParts()

/obj/machinery/r_n_d/protolathe/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/protolathe(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	RefreshParts()

/obj/machinery/r_n_d/protolathe/Destroy()
	if(linked_console)
		linked_console.linked_lathe = null
	return ..()

/obj/machinery/r_n_d/protolathe/RefreshParts()
	var/T = 0
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.maximum_volume += G.reagents.maximum_volume
		G.reagents.trans_to(src, G.reagents.total_volume)
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	materials.max_amount = T * 75000
	T = 12
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		T -= M.rating
	efficiency_coeff = min(max(0, T / 10), 1)

/obj/machinery/r_n_d/protolathe/check_mat(datum/design/being_built, M)	// now returns how many times the item can be built with the material
	var/A = materials.amount(M)
	if(!A)
		A = reagents.get_reagent_amount(M)
		A = A / max(1, (being_built.reagents_list[M] * efficiency_coeff))
	else
		A = A / max(1, (being_built.materials[M] * efficiency_coeff))
	return A

/obj/machinery/r_n_d/protolathe/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/storage/part_replacer))
		return ..()

	if(default_deconstruction_screwdriver(user, "protolathe_t", "protolathe", used))
		if(linked_console)
			linked_console.linked_lathe = null
			linked_console = null
		return ITEM_INTERACT_COMPLETE

	if(panel_open)
		to_chat(user, "<span class='warning'>You can't load [src] while it's opened.</span>")
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/r_n_d/protolathe/crowbar_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	for(var/obj/component in component_parts)
		if(istype(component, /obj/item/reagent_containers/glass/beaker))
			reagents.trans_to(component, reagents.total_volume)
		component.loc = src.loc
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.trans_to(G, G.reagents.maximum_volume)
	materials.retrieve_all()
	default_deconstruction_crowbar(user, I)
