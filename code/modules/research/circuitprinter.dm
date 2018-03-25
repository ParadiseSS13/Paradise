/*///////////////Circuit Imprinter (By Darem)////////////////////////
	Used to print new circuit boards (for computers and similar systems) and AI modules. Each circuit board pattern are stored in
a /datum/desgin on the linked R&D console. You can then print them out in a fasion similar to a regular lathe. However, instead of
using metal and glass, it uses glass and reagents (usually sulfuric acis).

*/
/obj/machinery/r_n_d/circuit_imprinter
	name = "Circuit Imprinter"
	desc = "Manufactures circuit boards for the construction of machines."
	icon_state = "circuit_imprinter"
	flags = OPENCONTAINER

	var/datum/material_container/materials
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
	component_parts += new /obj/item/weapon/circuitboard/circuit_imprinter(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(null)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(null)
	materials = new(src, list(MAT_METAL=1, MAT_GLASS=1, MAT_GOLD=1, MAT_DIAMOND=1))
	RefreshParts()
	
	reagents.my_atom = src

/obj/machinery/r_n_d/circuit_imprinter/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/circuit_imprinter(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker/large(null)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker/large(null)
	RefreshParts()
	
	reagents.my_atom = src

/obj/machinery/r_n_d/circuit_imprinter/blob_act()
	if(prob(50))
		qdel(src)
	
/obj/machinery/r_n_d/circuit_imprinter/Destroy()
	QDEL_NULL(materials)
	return ..()

/obj/machinery/r_n_d/circuit_imprinter/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
		G.reagents.trans_to(src, G.reagents.total_volume)
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	materials.max_amount = T * 75000.0
	T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		T += M.rating
	efficiency_coeff = 2 ** (T - 1) //Only 1 manipulator here, you're making runtimes Razharas

/obj/machinery/r_n_d/circuit_imprinter/proc/check_mat(datum/design/being_built, var/M)
	var/A = materials.amount(M)
	if(!A)
		A = reagents.get_reagent_amount(M)
		A = A / max(1, (being_built.reagents[M]))
	else
		A = A / max(1, (being_built.materials[M]))
	return A
	
/obj/machinery/r_n_d/circuit_imprinter/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(shocked)
		shock(user,50)
	if(default_deconstruction_screwdriver(user, "circuit_imprinter_t", "circuit_imprinter", O))
		if(linked_console)
			linked_console.linked_imprinter = null
			linked_console = null
		return

	if(exchange_parts(user, O))
		return

	if(panel_open)
		if(istype(O, /obj/item/weapon/crowbar))
			for(var/obj/I in component_parts)
				if(istype(I, /obj/item/weapon/reagent_containers/glass/beaker))
					reagents.trans_to(I, reagents.total_volume)
				I.loc = src.loc
			for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
				reagents.trans_to(G, G.reagents.maximum_volume)
			materials.retrieve_all()
			default_deconstruction_crowbar(O)
			return 1
		else
			to_chat(user, "<span class='warning'>You can't load the [src.name] while it's opened.</span>")
			return
	if(disabled)
		return 1
	if(!linked_console)
		to_chat(user, "<span class='warning'>The [name] must be linked to an R&D console first!</span>")
		return 1
	if(busy)
		to_chat(user, "<span class='warning'>The [name] is busy. Please wait for completion of previous operation.</span>")
		return 1
	if(O.is_open_container())
		return
	if(stat)
		return 1
	if(!istype(O, /obj/item/stack/sheet/))
		to_chat(user, "<span class='warning'>You cannot insert this item into the [name]!</span>")
		return 1

	if(!materials.has_space( materials.get_item_material_amount(O) ))
		to_chat(user, "<span class='warning'>The [src.name]'s material bin is full! Please remove material before adding more.</span>")
		return 1

	var/obj/item/stack/sheet/stack = O
	var/amount = round(input("How many sheets do you want to add?") as num)
	if(!in_range(src, stack) || !user.Adjacent(src))
		return
	var/amount_inserted = materials.insert_stack(O,amount)
	if(!amount_inserted)
		return 1
	else
		busy = 1
		use_power(max(1000, (MINERAL_MATERIAL_AMOUNT*amount_inserted/10)))
		to_chat(user, "<span class='notice'>You add [amount_inserted] sheets to the [src.name].</span>")
		var/stackname = stack.name
		src.overlays += "circuitprinter_[stackname]"
		sleep(10)
		src.overlays -= "circuitprinter_[stackname]"
		busy = 0
	updateUsrDialog()
