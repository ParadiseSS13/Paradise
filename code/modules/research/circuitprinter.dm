/*///////////////Circuit Imprinter (By Darem)////////////////////////
	Used to print new circuit boards (for computers and similar systems) and AI modules. Each circuit board pattern are stored in
a /datum/desgin on the linked R&D console. You can then print them out in a fasion similar to a regular lathe. However, instead of
using metal and glass, it uses glass and reagents (usually sulfuric acis).

*/
/obj/machinery/r_n_d/circuit_imprinter
	name = "Circuit Imprinter"
	desc = "Manufactures circuit boards for the construction of machines."
	icon_state = "circuit_imprinter"
	container_type = OPENCONTAINER

	categories = list(
		"AI Modules",
		"Computer Boards",
		"Engineering Machinery",
		"Exosuit Modules",
		"Hydroponics Machinery",
		"Medical Machinery",
		"Misc. Machinery",
		"Research Machinery",
		"Subspace Telecomms",
		"Teleportation Machinery"
	)

/obj/machinery/r_n_d/circuit_imprinter/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/circuit_imprinter(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker(null)
	create_reagents()
	RefreshParts()

/obj/machinery/r_n_d/circuit_imprinter/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/circuit_imprinter(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	RefreshParts()

/obj/machinery/r_n_d/circuit_imprinter/Destroy()
	if(linked_console)
		linked_console.linked_imprinter = null
	return ..()

/obj/machinery/r_n_d/circuit_imprinter/RefreshParts()
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.maximum_volume += G.volume
		G.reagents.trans_to(src, G.reagents.total_volume)

	materials.max_amount = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		materials.max_amount += M.rating * 75000

	var/T = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		T += M.rating
	T = clamp(T, 1, 4)
	efficiency_coeff = 1 / (2 ** (T - 1))

/obj/machinery/r_n_d/circuit_imprinter/check_mat(datum/design/being_built, M)
	var/list/all_materials = being_built.reagents_list + being_built.materials

	var/A = materials.amount(M)
	if(!A)
		A = reagents.get_reagent_amount(M)

	return round(A / max(1, (all_materials[M] * efficiency_coeff)))

/obj/machinery/r_n_d/circuit_imprinter/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/storage/part_replacer))
		return ..()

	if(panel_open)
		to_chat(user, "<span class='warning'>You can't load [src] while it's opened.</span>")
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/r_n_d/circuit_imprinter/crowbar_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	for(var/obj/component in component_parts)
		if(istype(component, /obj/item/reagent_containers/glass/beaker))
			reagents.trans_to(component, reagents.total_volume)
		component.loc = src.loc
	materials.retrieve_all()
	default_deconstruction_crowbar(user, I)

/obj/machinery/r_n_d/circuit_imprinter/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!default_deconstruction_screwdriver(user, "circuit_imprinter_t", "circuit_imprinter", I))
		return
	if(linked_console)
		linked_console.linked_imprinter = null
		linked_console = null
