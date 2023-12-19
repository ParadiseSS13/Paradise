///////////////////////////////////////////
// GLOBAL PROCS for powernets handling
//////////////////////////////////////////

/// remove the old powernet and replace it with a new one throughout the network.
/proc/propagate_network(obj/O, datum/regional_powernet/PN)
	var/list/worklist = list()
	var/list/found_machines = list()
	var/index = 1
	var/obj/P = null

	worklist += O //start propagating from the passed object

	while(index <= length(worklist)) //until we've exhausted all power objects
		P = worklist[index] //get the next power object found
		index++

		if(istype(P, /obj/structure/cable))
			var/obj/structure/cable/C = P
			if(C.powernet != PN) //add it to the powernet, if it isn't already there
				PN.add_cable(C)
			worklist |= C.get_connections() //get adjacents power objects, with or without a powernet

		else if(P.anchored && istype(P, /obj/machinery/power))
			var/obj/machinery/power/M = P
			found_machines |= M //we wait until the powernet is fully propagates to connect the machines

	//now that the powernet is set, connect found machines to it
	for(var/obj/machinery/power/PM in found_machines)
		if(!PM.connect_to_network()) //couldn't find a node on its turf...
			PM.disconnect_from_network() //... so disconnect if already on a powernet


//Merge two powernets, the bigger (in cable length term) absorbing the other
/proc/merge_powernets(datum/regional_powernet/net1, datum/regional_powernet/net2)
	if(!net1 || !net2) //if one of the powernet doesn't exist, return
		return

	if(net1 == net2) //don't merge same powernets
		return

	//We assume net1 is larger. If net2 is in fact larger we are just going to make them switch places to reduce on code.
	if(net1.cables.len < net2.cables.len)	//net2 is larger than net1. Let's switch them around
		var/temp = net1
		net1 = net2
		net2 = temp

	//merge net2 into net1
	for(var/obj/structure/cable/Cable in net2.cables) //merge cables
		net1.add_cable(Cable)

	for(var/obj/machinery/power/Node in net2.nodes) //merge power machines
		if(!Node.connect_to_network())
			Node.disconnect_from_network() //if somehow we can't connect the machine to the new powernet, disconnect it from the old nonetheless

	return net1

//Determines how strong could be shock, deals damage to mob, uses power.
//M is a mob who touched wire/whatever
//power_source is a source of electricity, can be powercell, area, apc, cable, powernet or null
//source is an object caused electrocuting (airlock, grille, etc)
//No animations will be performed by this proc.
/proc/electrocute_mob(mob/living/M, power_source, obj/source, siemens_coeff = 1, dist_check = FALSE)
	if(!M || ismecha(M.loc))
		return FALSE	//feckin mechs are dumb
	if(dist_check)
		if(!in_range(source, M))
			return FALSE
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			if(G.siemens_coefficient == 0)
				return FALSE		//to avoid spamming with insulated glvoes on

	var/area/source_area
	if(isarea(power_source))
		source_area = power_source
		power_source = source_area.get_apc()
	if(istype(power_source, /obj/structure/cable))
		var/obj/structure/cable/Cable = power_source
		power_source = Cable.powernet

	var/datum/regional_powernet/PN
	var/obj/item/stock_parts/cell/cell

	if(istype(power_source, /datum/regional_powernet))
		PN = power_source
	else if(istype(power_source, /obj/item/stock_parts/cell))
		cell = power_source
	else if(istype(power_source, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/apc = power_source
		cell = apc.cell
		if(apc.terminal)
			PN = apc.terminal.powernet
	else if(!power_source)
		return 0
	else
		log_admin("ERROR: /proc/electrocute_mob([M], [power_source], [source]): wrong power_source")
		return 0
	if(!cell && !PN)
		return 0
	var/PN_damage = 0
	var/cell_damage = 0
	if(PN)
		PN_damage = PN.get_electrocute_damage()
	if(cell)
		cell_damage = cell.get_electrocute_damage()
	var/shock_damage = 0
	if(PN_damage >= cell_damage)
		power_source = PN
		shock_damage = PN_damage
	else
		power_source = cell
		shock_damage = cell_damage
	var/drained_hp = M.electrocute_act(shock_damage, source, siemens_coeff) //zzzzzzap!
	var/drained_energy = drained_hp*20

	if(source_area)
		source_area.powernet.use_active_power(drained_energy / GLOB.CELLRATE)
	else if(istype(power_source, /datum/regional_powernet))
		var/drained_power = drained_energy/GLOB.CELLRATE //convert from "joules" to "watts"
		PN.queued_power_demand += (min(drained_power, max(PN.queued_power_production - PN.queued_power_demand, 0)))
	else if(istype(power_source, /obj/item/stock_parts/cell))
		cell.use(drained_energy)
	return drained_energy
