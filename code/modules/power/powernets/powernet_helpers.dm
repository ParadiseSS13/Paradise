///////////////////////////////////////////
// GLOBAL PROCS for powernets handling
//////////////////////////////////////////

/// remove the old powernet and replace it with a new one throughout the network.
/datum/regional_powernet/proc/propagate_network(obj/root_node)
	// A full list of cables that we are iterating through, contains visited and unvisited objects
	var/list/worklist = list(root_node) //start propagating from the passed object
	// All power machines that connect to one of our nodes in the worklist, built throughout propagation and will be revisted at the end of the proc
	var/list/found_machines = list()
	// The current index we are at in our worklist
	var/index = 1
	// The object we're current working with -> worklist[index]
	var/obj/current_object = null

	while(index <= length(worklist))
		current_object = worklist[index] // get the next power object found and increment index
		index++
		if(iscable(current_object))
			var/obj/structure/cable/C = current_object
			if(C.powernet == src)
				continue
			if(C.power_voltage_type != power_voltage_type)
				log_debug("[C.UID()] Voltage Incompatibility")
				if(power_voltage_type == VOLTAGE_HIGH)
					short_circuit(C.powernet, C)
				continue
			add_cable(C)
			worklist |= C.get_connections(power_voltage_type) //get adjacents power objects, with or without a powernet
		else if(current_object.anchored && ispowermachine(current_object))
			// we wait until the powernet is fully propagates to connect the machines
			found_machines |= current_object

	// now that the powernet is set, connect found machines to it
	for(var/obj/machinery/power/PM as anything in found_machines)
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


