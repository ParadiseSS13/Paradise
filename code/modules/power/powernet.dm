/datum/powernet
	var/list/cables = list()	// all cables & junctions
	var/list/nodes = list()		// all connected machines

	var/load = 0				// the current load on the powernet, increased by each machine at processing
	var/newavail = 0			// what available power was gathered last tick, then becomes...
	var/avail = 0				//...the current available power in the powernet
	var/viewload = 0			// the load as it appears on the power console (gradually updated)
	var/number = 0				// Unused //TODEL

	var/perapc = 0			// per-apc avilability
	var/perapc_excess = 0
	var/netexcess = 0			// excess power on the powernet (typically avail-load)

	var/problem = 0	// If either of these is set to 1 there is some sort of issue at the powernet.


/datum/powernet/New()
	powernets += src
	..()

/datum/powernet/Destroy()
	//Go away references, you suck!
	for(var/obj/structure/cable/C in cables)
		cables -= C
		C.powernet = null
	for(var/obj/machinery/power/M in nodes)
		nodes -= M
		M.powernet = null

	powernets -= src
	return ..()

//Returns the amount of excess power (before refunding to SMESs) from last tick.
//This is for machines that might adjust their power consumption using this data.
/datum/powernet/proc/last_surplus()
	return max(avail - load, 0)

/datum/powernet/proc/draw_power(var/amount)
	var/draw = between(0, amount, avail - load)
	load += draw
	return draw

/datum/powernet/proc/is_empty()
	return !cables.len && !nodes.len

//remove a cable from the current powernet
//if the powernet is then empty, delete it
//Warning : this proc DON'T check if the cable exists
/datum/powernet/proc/remove_cable(var/obj/structure/cable/C)
	cables -= C
	C.powernet = null
	if(is_empty())//the powernet is now empty...
		qdel(src)///... delete it - qdel

//add a cable to the current powernet
//Warning : this proc DON'T check if the cable exists
/datum/powernet/proc/add_cable(var/obj/structure/cable/C)
	if(C.powernet)// if C already has a powernet...
		if(C.powernet == src)
			return
		else
			C.powernet.remove_cable(C) //..remove it
	C.powernet = src
	cables +=C

//remove a power machine from the current powernet
//if the powernet is then empty, delete it
//Warning : this proc DON'T check if the machine exists
/datum/powernet/proc/remove_machine(var/obj/machinery/power/M)
	nodes -=M
	M.powernet = null
	if(is_empty())//the powernet is now empty...
		qdel(src)///... delete it - qdel


//add a power machine to the current powernet
//Warning : this proc DON'T check if the machine exists
/datum/powernet/proc/add_machine(var/obj/machinery/power/M)
	if(M.powernet)// if M already has a powernet...
		if(M.powernet == src)
			return
		else
			M.disconnect_from_network()//..remove it
	M.powernet = src
	nodes[M] = M

// Triggers warning for certain amount of ticks
/datum/powernet/proc/trigger_warning(var/duration_ticks = 20)
	problem = max(duration_ticks, problem)

//handles the power changes in the powernet
//called every ticks by the powernet controller
/datum/powernet/proc/reset()
	var/numapc = 0

	if(problem > 0)
		problem = max(problem - 1, 0)

	if(nodes && nodes.len) // Added to fix a bad list bug -- TLE
		for(var/obj/machinery/power/terminal/term in nodes)
			if( istype( term.master, /obj/machinery/power/apc ) )
				numapc++

	netexcess = avail - load

	if(numapc)
		//very simple load balancing. If there was a net excess this tick then it must have been that some APCs used less than perapc, since perapc*numapc = avail
		//Therefore we can raise the amount of power rationed out to APCs on the assumption that those APCs that used less than perapc will continue to do so.
		//If that assumption fails, then some APCs will miss out on power next tick, however it will be rebalanced for the tick after.
		if(netexcess >= 0)
			perapc_excess += min(netexcess/numapc, (avail - perapc) - perapc_excess)
		else
			perapc_excess = 0

		perapc = avail/numapc + perapc_excess

	if(netexcess > 100 && nodes && nodes.len)		// if there was excess power last cycle
		for(var/obj/machinery/power/smes/S in nodes)	// find the SMESes in the network
			S.restore()				// and restore some of the power that was used

	//updates the viewed load (as seen on power computers)
	viewload = round(load)

	//reset the powernet
	load = 0
	avail = newavail
	newavail = 0

/datum/powernet/proc/get_electrocute_damage()
	switch(avail)
		if(5000000 to INFINITY)
			return min(rand(200,300),rand(200,300))
		if(4000000 to 5000000)
			return min(rand(80,180),rand(80,180))
		if(1000000 to 4000000)
			return min(rand(50,160),rand(50,160))
		if(200000 to 1000000)
			return min(rand(25,80),rand(25,80))
		if(100000 to 200000)//Ave powernet
			return min(rand(20,60),rand(20,60))
		if(50000 to 100000)
			return min(rand(15,40),rand(15,40))
		if(1000 to 50000)
			return min(rand(10,20),rand(10,20))
		else
			return 0

////////////////////////////////////////////////
// Misc.
///////////////////////////////////////////////


// return a knot cable (O-X) if one is present in the turf
// null if there's none
/turf/proc/get_cable_node()
	if(!istype(src, /turf/simulated/floor))
		return null
	for(var/obj/structure/cable/C in src)
		if(C.d1 == 0)
			return C
	return null

/area/proc/get_apc()
	// This was a simple locate() in src, but an unresolved BYOND bug causes trying to locate() in an
	//  area to take an inconceivably long time, especially for large areas.
	// See: http://www.byond.com/forum/?post=1860571
	var/obj/machinery/power/apc/FINDME
	for(FINDME in src)
		return FINDME