/obj/machinery/chem_dispenser/botanical
	name = "botanical chemical dispenser"
	desc = "Creates and dispenses chemicals useful for botany."
	icon = 'icons/hispania/obj/chemical.dmi'
	dispensable_reagents = list(
		"mutagen",
		"saltpetre",
		"eznutriment",
		"left4zednutriment",
		"robustharvestnutriment",
		"water",
		"atrazine",
		"pestkiller",
		"ammonia",
		"ash",
		"diethylamine")
	upgrade_reagents = "cryoxadone"

/obj/machinery/chem_dispenser/botanical/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_dispenser/botanical(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new cell_type(null)
	RefreshParts()



/obj/machinery/chem_dispenser/botanical/RefreshParts()
	recharge_amount = initial(recharge_amount)
	var/newpowereff = 0.0666666
	for(var/obj/item/stock_parts/cell/P in component_parts)
		cell = P
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		newpowereff += 0.0166666666 * M.rating
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_amount *= C.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		if(M.rating > 3)
			dispensable_reagents |= upgrade_reagents
	powerefficiency = round(newpowereff, 0.01)

