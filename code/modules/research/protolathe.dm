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
	flags = OPENCONTAINER

	var/max_material_storage = 100000 //All this could probably be done better with a list but meh.
	var/m_amount = 0.0
	var/g_amount = 0.0
	var/gold_amount = 0.0
	var/silver_amount = 0.0
	var/plasma_amount = 0.0
	var/uranium_amount = 0.0
	var/diamond_amount = 0.0
	var/clown_amount = 0.0
	var/efficiency_coeff

	var/list/categories = list(
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

	reagents = new()


/obj/machinery/r_n_d/protolathe/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/protolathe(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker/large(null)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker/large(null)
	RefreshParts()

	reagents.my_atom = src
	
/obj/machinery/r_n_d/protolathe/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/protolathe(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker/large(null)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker/large(null)
	RefreshParts()

	reagents.my_atom = src

/obj/machinery/r_n_d/protolathe/proc/TotalMaterials() //returns the total of all the stored materials. Makes code neater.
	return m_amount + g_amount + gold_amount + silver_amount + plasma_amount + uranium_amount + diamond_amount + clown_amount

/obj/machinery/r_n_d/protolathe/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
		G.reagents.trans_to(src, G.reagents.total_volume)
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	max_material_storage = T * 75000
	T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		T += (M.rating/3)
	efficiency_coeff = max(T, 1)

/obj/machinery/r_n_d/protolathe/proc/check_mat(datum/design/being_built, var/M)	// now returns how many times the item can be built with the material
	var/A = 0
	switch(M)
		if("$metal")
			A = m_amount
		if("$glass")
			A = g_amount
		if("$gold")
			A = gold_amount
		if("$silver")
			A = silver_amount
		if("$plasma")
			A = plasma_amount
		if("$uranium")
			A = uranium_amount
		if("$diamond")
			A = diamond_amount
		if("$bananium")
			A = clown_amount
		else
			A = reagents.get_reagent_amount(M)
	A = A / max(1, (being_built.materials[M]/efficiency_coeff))
	return A

/obj/machinery/r_n_d/protolathe/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if (shocked)
		shock(user,50)
	if (default_deconstruction_screwdriver(user, "protolathe_t", "protolathe", O))
		if(linked_console)
			linked_console.linked_lathe = null
			linked_console = null
		return

	if(exchange_parts(user, O))
		return

	if (panel_open)
		if(istype(O, /obj/item/weapon/crowbar))
			for(var/obj/I in component_parts)
				if(istype(I, /obj/item/weapon/reagent_containers/glass/beaker))
					reagents.trans_to(I, reagents.total_volume)
				if(I.reliability != 100 && crit_fail)
					I.crit_fail = 1
				I.loc = src.loc
			for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
				reagents.trans_to(G, G.reagents.maximum_volume)
			if(m_amount >= MINERAL_MATERIAL_AMOUNT)
				var/obj/item/stack/sheet/metal/G = new /obj/item/stack/sheet/metal(src.loc)
				G.amount = round(m_amount / G.perunit)
			if(g_amount >= MINERAL_MATERIAL_AMOUNT)
				var/obj/item/stack/sheet/glass/G = new /obj/item/stack/sheet/glass(src.loc)
				G.amount = round(g_amount / G.perunit)
			if(plasma_amount >= MINERAL_MATERIAL_AMOUNT)
				var/obj/item/stack/sheet/mineral/plasma/G = new /obj/item/stack/sheet/mineral/plasma(src.loc)
				G.amount = round(plasma_amount / G.perunit)
			if(silver_amount >= MINERAL_MATERIAL_AMOUNT)
				var/obj/item/stack/sheet/mineral/silver/G = new /obj/item/stack/sheet/mineral/silver(src.loc)
				G.amount = round(silver_amount / G.perunit)
			if(gold_amount >= MINERAL_MATERIAL_AMOUNT)
				var/obj/item/stack/sheet/mineral/gold/G = new /obj/item/stack/sheet/mineral/gold(src.loc)
				G.amount = round(gold_amount / G.perunit)
			if(uranium_amount >= MINERAL_MATERIAL_AMOUNT)
				var/obj/item/stack/sheet/mineral/uranium/G = new /obj/item/stack/sheet/mineral/uranium(src.loc)
				G.amount = round(uranium_amount / G.perunit)
			if(diamond_amount >= MINERAL_MATERIAL_AMOUNT)
				var/obj/item/stack/sheet/mineral/diamond/G = new /obj/item/stack/sheet/mineral/diamond(src.loc)
				G.amount = round(diamond_amount / G.perunit)
			if(clown_amount >= MINERAL_MATERIAL_AMOUNT)
				var/obj/item/stack/sheet/mineral/bananium/G = new /obj/item/stack/sheet/mineral/bananium(src.loc)
				G.amount = round(clown_amount / G.perunit)
			default_deconstruction_crowbar(O)
			return 1
		else
			user << "<span class='warning'>You can't load the [src.name] while it's opened.</span>"
			return 1
	if (disabled)
		return
	if (!linked_console)
		user << "<span class='warning'> The [src.name] must be linked to an R&D console first!</span>"
		return 1
	if (busy)
		user << "<span class='warning'>The [src.name] is busy. Please wait for completion of previous operation.</span>"
		return 1
	if (O.is_open_container())
		return
	if (!istype(O, /obj/item/stack/sheet) || istype(O, /obj/item/stack/sheet/wood))
		user << "<span class='warning'>You cannot insert this item into the [src.name]!</span>"
		return 1
	if (stat)
		return 1
	if(istype(O,/obj/item/stack/sheet))
		var/obj/item/stack/sheet/S = O
		if (TotalMaterials() + S.perunit > max_material_storage)
			user << "<span class='warning'>The [src.name]'s material bin is full. Please remove material before adding more.</span>"
			return 1

	var/obj/item/stack/sheet/stack = O
	var/amount = round(input("How many sheets do you want to add?") as num)//No decimals
	if(!stack || stack.amount <= 0 || amount <= 0)
		return
	if(amount > stack.amount)
		amount = stack.amount
	if(max_material_storage - TotalMaterials() < (amount*stack.perunit))//Can't overfill
		amount = min(stack.amount, round((max_material_storage-TotalMaterials())/stack.perunit))

	icon_state = "protolathe"
	busy = 1
	use_power(max(1000, (MINERAL_MATERIAL_AMOUNT*amount/10)))
	user << "<span class='notice'>You add [amount] sheets to the [src.name].</span>"
	icon_state = "protolathe"
	if(istype(stack, /obj/item/stack/sheet/metal))
		m_amount += amount * MINERAL_MATERIAL_AMOUNT
	else if(istype(stack, /obj/item/stack/sheet/glass))
		g_amount += amount * MINERAL_MATERIAL_AMOUNT
	else if(istype(stack, /obj/item/stack/sheet/mineral/gold))
		gold_amount += amount * MINERAL_MATERIAL_AMOUNT
	else if(istype(stack, /obj/item/stack/sheet/mineral/silver))
		silver_amount += amount * MINERAL_MATERIAL_AMOUNT
	else if(istype(stack, /obj/item/stack/sheet/mineral/plasma))
		plasma_amount += amount * MINERAL_MATERIAL_AMOUNT
	else if(istype(stack, /obj/item/stack/sheet/mineral/uranium))
		uranium_amount += amount * MINERAL_MATERIAL_AMOUNT
	else if(istype(stack, /obj/item/stack/sheet/mineral/diamond))
		diamond_amount += amount * MINERAL_MATERIAL_AMOUNT
	else if(istype(stack, /obj/item/stack/sheet/mineral/bananium))
		clown_amount += amount * MINERAL_MATERIAL_AMOUNT
	stack.use(amount)
	busy = 0
	src.updateUsrDialog()

	if(stack)
		var/stackname = stack.name
		src.overlays += "protolathe_[stackname]"
		sleep(10)
		src.overlays -= "protolathe_[stackname]"

	return
