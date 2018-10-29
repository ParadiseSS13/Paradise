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

	var/efficiency_coeff

	var/list/categories = list(
								"AI Modules",
								"Computer Boards",
								"Computer Parts",
								"Engineering Machinery",
								"Exosuit Modules",
								"Hydroponics Machinery",
								"Medical Machinery",
								"Misc. Machinery",
								"Research Machinery",
								"Subspace Telecomms",
								"Teleportation Machinery"
								)

	reagents = new()

/obj/machinery/r_n_d/circuit_imprinter/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/circuit_imprinter(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker(null)
	RefreshParts()
	reagents.my_atom = src

/obj/machinery/r_n_d/circuit_imprinter/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/circuit_imprinter(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	RefreshParts()
	reagents.my_atom = src

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
	efficiency_coeff = 2 ** (T - 1) //Only 1 manipulator here, you're making runtimes Razharas

/obj/machinery/r_n_d/circuit_imprinter/blob_act()
	if(prob(50))
		qdel(src)


/obj/machinery/r_n_d/circuit_imprinter/proc/check_mat(datum/design/being_built, var/M)
	var/list/all_materials = being_built.reagents_list + being_built.materials

	var/A = materials.amount(M)
	if(!A)
		A = reagents.get_reagent_amount(M)

	return round(A / max(1, (all_materials[M]/efficiency_coeff)))

/obj/machinery/r_n_d/circuit_imprinter/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(shocked)
		if(shock(user,50))
			return TRUE
	if(default_deconstruction_screwdriver(user, "circuit_imprinter_t", "circuit_imprinter", O))
		if(linked_console)
			linked_console.linked_imprinter = null
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
			materials.retrieve_all()
			default_deconstruction_crowbar(O)
			return
		else
			to_chat(user, "<span class='warning'>You can't load the [src.name] while it's opened.</span>")
			return
	if(O.is_open_container())
		return FALSE
	else
		return ..()