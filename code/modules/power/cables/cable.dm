
/*
	* Cable directions (d1 and d2)
	* 9   1   5
	* 	\ | /
	* 8 - 0 - 4
	* 	/ | \
	* 10  2   6
If d1 = 0 and d2 = 0, there's no cable
If d1 = 0 and d2 = dir, it's a O-X cable, getting from the center of the tile to dir (knot cable)
If d1 = dir1 and d2 = dir2, it's a full X-X cable, getting from dir1 to dir2
By design, d1 is the smallest direction and d2 is the highest
*/

/*
	* # /obj/structure/cable
	*
	* The red wire thingies you see on the ground all over the station in maintenance
	* the d1 and d2 vars deal with the "directions" of the cables, since all instances of this cable structure are
	* just lines, they have two endpoints (d1 and d2).
*/
/obj/structure/cable
	name = "power cable"
	desc = "A flexible superconducting cable for heavy-duty power transfer."
	icon = 'icons/obj/power_cond/power_cond_white.dmi'
	icon_state = "0-1"
	level = 1
	anchored = TRUE
	on_blueprints = TRUE
	color = COLOR_RED

	//The following vars are set here for the benefit of mapping - they are reset when the cable is spawned
	alpha = 128	//is set to 255 when spawned
	plane = GAME_PLANE //is set to FLOOR_PLANE when spawned
	layer = LOW_OBJ_LAYER //isset to WIRE_LAYER when spawned

	/// The direction of endpoint one of this cable
	var/d1 = 0
	/// The direction of enpoint two of this cable
	var/d2 = 1
	/// The regional powernet this cable is registered to
	var/datum/regional_powernet/powernet

/obj/structure/cable/Initialize(mapload)
	. = ..()
	//we set vars in definition for mapping, now we revert it in init()
	plane = FLOOR_PLANE	//move it down so ambient occlusion ignores it
	alpha = 255			//make it not semi-transparent
	layer = WIRE_LAYER	//put it on the right level

	// ensure d1 & d2 reflect the icon_state for entering and exiting cable
	var/dash = findtext(icon_state, "-")
	d1 = text2num(copytext(icon_state, 1, dash))
	d2 = text2num(copytext(icon_state, dash + 1))

	var/turf/T = get_turf(src)	// hide if turf is not intact
	LAZYADD(GLOB.cable_list, src)	//add it to the global cable list
	if(T.transparent_floor)
		return
	if(level == 1)
		hide(T.intact)

/obj/structure/cable/Destroy()
	if(powernet)
		cut_cable_from_powernet()		// update the powernets
	LAZYREMOVE(GLOB.cable_list, src)	//remove it from global cable list
	return ..()							// then go ahead and delete the cable

/obj/structure/cable/update_icon_state()
	if(invisibility)
		icon_state = "[d1]-[d2]-f"
	else
		icon_state = "[d1]-[d2]"

/// If underfloor, hide the cable
/obj/structure/cable/hide(i)
	if(level == 1 && isturf(loc))
		invisibility = i ? INVISIBILITY_MAXIMUM : 0
	update_icon()

// Items usable on a cable :
//   - Wirecutters : cut it duh !
//   - Cable coil : merge cables
//   - Multitool : get the power currently passing through the cable
//
/obj/structure/cable/attackby(obj/item/W, mob/user)
	var/turf/T = get_turf(src)
	if(T.transparent_floor || T.intact)
		to_chat(user, "<span class='danger'>You can't interact with something that's under the floor!</span>")
		return

	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = W
		if(coil.get_amount() < 1)
			to_chat(user, "<span class='warning'>Not enough cable!</span>")
			return
		coil.cable_join(src, user)

	else if(istype(W, /obj/item/rcl))
		var/obj/item/rcl/R = W
		if(R.loaded)
			R.loaded.cable_join(src, user)
			R.is_empty(user)

	else if(istype(W, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = W
		cable_color(C.colourName)

	else
		if(W.flags & CONDUCT)
			shock(user, 50, 0.7)

	add_fingerprint(user)

/obj/structure/cable/multitool_act(mob/user, obj/item/I)
	. = TRUE
	var/turf/T = get_turf(src)
	if(T.intact)
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(powernet && (powernet.available_power > 0))		// is it powered?
		to_chat(user, "<span class='danger'>Total power: [DisplayPower(powernet.available_power)]\nLoad: [DisplayPower(powernet.power_demand)]\nExcess power: [DisplayPower(get_surplus())]</span>")
	else
		to_chat(user, "<span class='danger'>The cable is not powered.</span>")
	shock(user, 5, 0.2)

/obj/structure/cable/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	var/turf/T = get_turf(src)
	if(T.transparent_floor || T.intact)
		to_chat(user, "<span class='danger'>You can't interact with something that's under the floor!</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(shock(user, 50))
		return
	user.visible_message("[user] cuts the cable.", "<span class='notice'>You cut the cable.</span>")
	investigate_log("was cut by [key_name(usr, 1)] in [get_area(user)]([T.x], [T.y], [T.z] - [ADMIN_JMP(T)])","wires")
	deconstruct()

/obj/structure/cable/proc/cable_color(colorC)
	if(!colorC)
		color = COLOR_RED
	else if(colorC == "rainbow")
		color = color_rainbow()
	else if(colorC == "orange") //byond only knows 16 colors by name, and orange isn't one of them
		color = COLOR_ORANGE
	else
		color = colorC

/obj/structure/cable/proc/color_rainbow()
	color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN)
	return color

/obj/structure/cable/deconstruct(disassembled = TRUE)
	var/turf/T = get_turf(src)
	if(usr)
		investigate_log("was deconstructed by [key_name(usr, 1)] in [get_area(usr)]([T.x], [T.y], [T.z] - [ADMIN_JMP(T)])","wires")
	if(!(flags & NODECONSTRUCT))
		if(d1)	// 0-X cables are 1 unit, X-X cables are 2 units long
			new/obj/item/stack/cable_coil(T, 2, paramcolor = color)
		else
			new/obj/item/stack/cable_coil(T, 1, paramcolor = color)
	qdel(src)

/* ===POWERNET PROCS=== */
/// Adds power demand to the powernet, machines should use this
/obj/structure/cable/proc/add_power_demand(amount)
	powernet?.power_demand += amount

/// Gets surplus power available on this cables powernet, machines should use this
/obj/structure/cable/proc/get_surplus()
	return powernet ? powernet.calculate_surplus() : 0

/// Gets power available (NOT EXTRA) on this cables powernet, machines should use this, engines should add power to the net with this proc
/obj/structure/cable/proc/get_available_power()
	return powernet ? powernet.available_power : 0

/// Adds queued power demand to be met next process cycle, non_machines should use this
/obj/structure/cable/proc/add_queued_power_demand(amount)
	powernet?.queued_power_demand += amount

/// Gets surplus power queued for next process cycle on this cables powernet, non_machines should use this
/obj/structure/cable/proc/get_queued_surplus()
	return powernet ? powernet.calculate_queued_surplus() : 0

/// Gets available (NOT EXTRA) power queued for next process cycle on this cables powernet, non_machines should use this
/obj/structure/cable/proc/get_queued_available_power()
	return powernet ? powernet.queued_power_production : 0


/* ===CABLE LAYING HELPERS=== */
/// merge_connected_networks(), merge_connected_networks_on_turf(), and merge_diagonal_networks() all deal with merging
/// cables' powernets together
/*
	* # merge_connected_networks()
	*
	* Check the turf in the next step in that direction to see if our new cable lines up perfectly with
	* another cable and then merge their associated regional powernets.
	*
	* In technical terms, Wires can be merged when they face eachother and have perfectly opposite directions, i.e east and west or north and south
	* To check mergeability, we flip our original direction because in perfectly opposite directions, the inverse of one is equal to the other
	* if the cable we find on the next turf has atleast one direction equal to the inverse of our new cables direction, we know it connects
*/
/obj/structure/cable/proc/merge_connected_networks(direction)
	if(d1 != direction && d2 != direction)
		return //if the cable is not pointed in this direction, do nothing

	//flip the direction, so we can check it against cables in the next turf over
	var/flipped_direction = turn(direction, 180)
	for(var/obj/structure/cable/C in get_step(src, direction))
		if(src == C) // skip ourself
			continue
		if(C.d1 != flipped_direction && C.d2 != flipped_direction)
			continue	//no match! Continue the search
		//if the matching cable somehow got no powernet, make him one (should not happen for cables)
		if(!C.powernet)
			var/datum/regional_powernet/new_powernet = new()
			new_powernet.add_cable(C)
		if(powernet) //if we already have a powernet, then merge the two powernets
			merge_powernets(powernet, C.powernet)
		else
			C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

/*
	* # merge_connected_networks_on_turf()
	*
	* This proc merges powernets with power machines & cables that share a turf
	* first it merges powernets of any cables that share an exact direction and then it will attempt
	* to connect every power machine in the turf to the powernet
*/
/obj/structure/cable/proc/merge_connected_networks_on_turf()
	var/list/to_connect = list()

	for(var/obj/object in loc)
		//first let's add turf cables to our powernet
		if(istype(object, /obj/structure/cable))
			var/obj/structure/cable/C = object
			if(C.d1 == d1 || C.d2 == d1 || C.d1 == d2 || C.d2 == d2) //only connected if they have a common direction
				if(C.powernet == powernet)
					continue
				if(C.powernet)
					merge_powernets(powernet, C.powernet)
				else
					powernet.add_cable(C) //the cable was powernetless, let's just add it to our powernet
		//Now we'll check for APCs
		else if(istype(object, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/N = object
			if(!N.terminal)
				continue // APC are connected through their terminal
			if(N.terminal.powernet == powernet)
				continue
			to_connect += N.terminal //we'll connect the machines after all cables are merged
		//then we'll connect machines on turf with a node cable is present
		else if(istype(object, /obj/machinery/power)) //other power machines
			var/obj/machinery/power/M = object
			if(M.powernet == powernet)
				continue
			to_connect += M //we'll connect the machines after all cables are merged

	//now that cables are done, let's connect found machines
	for(var/obj/machinery/power/PM as anything in to_connect)
		if(!PM.connect_to_network())
			PM.disconnect_from_network() //if we somehow can't connect the machine to the new powernet, remove it from the old nonetheless

/*
	* # merge_diagonal_networks()
	*
	* handles powernet merging diagonally matching cables, proc only takes diagonal directions as params
*/
/obj/structure/cable/proc/merge_diagonal_networks(direction)
	//search for and merge diagonally matching cables from the first direction component (north/south)
	for(var/obj/structure/cable/C in get_step(src, direction & (NORTH|SOUTH)))
		if(src == C) // skip ourself
			continue
		//we've got a diagonally matching cable
		if(C.d1 == FLIP_DIR_VERTICALLY(direction) || C.d2 == FLIP_DIR_VERTICALLY(direction))
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/regional_powernet/new_powernet = new()
				new_powernet.add_cable(C)
			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet, C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

	//the same from the second direction component (east/west)
	for(var/obj/structure/cable/C in get_step(src, direction & (EAST|WEST)))
		if(src == C)
			continue
		if(C.d1 == FLIP_DIR_HORIZONTALLY(direction) || C.d2 == FLIP_DIR_HORIZONTALLY(direction)) //we've got a diagonally matching cable
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/regional_powernet/new_powernet = new()
				new_powernet.add_cable(C)
			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet, C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet


/* ===Powernets handling helpers=== */
/*
	* # get_connections()
	*
	* Builds a list of cables in neighboring procs that form a cable connection with src and returns it
*/
/obj/structure/cable/proc/get_connections()
	. = list()	// this will be a list of all connected power objects
	var/turf/T

	//get matching cables from the first direction
	if(d1) //if not a node cable
		T = get_step(src, d1)
		if(T)
			. += T.power_list(src, turn(d1, 180)) //get adjacents matching cables
	if(IS_DIR_DIAGONAL(d1)) //diagonal direction, must check the 4 possibles adjacents tiles
		T = get_step(src, d1 & (NORTH|SOUTH)) // go north/south
		if(T)
			. += T.power_list(src, FLIP_DIR_VERTICALLY(d1)) //get diagonally matching cables
		T = get_step(src, d1 & (EAST|WEST)) // go east/west
		if(T)
			. += T.power_list(src, FLIP_DIR_HORIZONTALLY(d1)) //get diagonally matching cables
	T = get_turf(src)
	. += T.power_list(src, d1) //get on turf matching cables

	//do the same on the second direction (which can't be 0)
	T = get_step(src, d2)
	if(T)
		. += T.power_list(src, turn(d2, 180)) //get adjacents matching cables

	if(d2&(d2-1)) //diagonal direction, must check the 4 possibles adjacents tiles
		T = get_step(src, d2 & (NORTH|SOUTH)) // go north/south
		if(T)
			. += T.power_list(src, FLIP_DIR_VERTICALLY(d1)) //get diagonally matching cables
		T = get_step(src, d2 & (EAST|WEST)) // go east/west
		if(T)
			. += T.power_list(src, FLIP_DIR_HORIZONTALLY(d1)) //get diagonally matching cables
	T = get_turf(src)
	. += T.power_list(src, d2) //get on turf matching cables

	return .

//should be called after placing a cable which extends another cable, creating a "smooth" cable that no longer terminates in the centre of a turf.
//needed as this can, unlike other placements, disconnect cables
/obj/structure/cable/proc/denode()
	var/turf/T1 = loc
	if(!T1)
		return

	var/list/powerlist = T1.power_list(src, 0) //find the other cables that ended in the centre of the turf, with or without a powernet
	if(length(powerlist))
		var/datum/regional_powernet/PN = new()
		propagate_network(powerlist[1], PN) //propagates the new powernet beginning at the source cable
		if(PN.is_empty()) //can happen with machines made nodeless when smoothing cables
			qdel(PN)

// cut the cable's powernet at this cable and updates the powergrid
/obj/structure/cable/proc/cut_cable_from_powernet(remove = TRUE)
	var/turf/T1 = get_turf(src)
	var/list/P_list
	if(!T1)
		return
	if(d1) //if d1 is not a node
		T1 = get_step(T1, d1)
		P_list = T1.power_list(src, turn(d1, 180), cable_only = TRUE)	// what adjacently joins on to cut cable...
	P_list += T1.power_list(loc, d1, cable_only = TRUE) //... and on turf
	if(!length(P_list))//if nothing in both list, then the cable was a lone cable, just delete it and its powernet
		powernet.remove_cable(src)

		for(var/obj/machinery/power/P in T1)//check if it was powering a machine
			if(!P.connect_to_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_network() //remove from current network (and delete powernet)
		return

	var/obj/O = P_list[1]
	// remove the cut cable from its turf and powernet, so that it doesn't get count in propagate_network worklist
	if(remove)
		loc = null
	powernet.remove_cable(src) //remove the cut cable from its powernet
	// queue it to rebuild
	SSmachines.deferred_powernet_rebuilds += O

	// Disconnect machines connected to nodes
	if(d1 == 0) // if we cut a node (O-X) cable
		for(var/obj/machinery/power/P in T1)
			if(!P.connect_to_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_network() //remove from current network

// shock the user with probability prb
/obj/structure/cable/proc/shock(mob/user, prb, siemens_coeff = 1)
	if(!prob(prb))
		return FALSE
	if(electrocute_mob(user, powernet, src, siemens_coeff))
		do_sparks(5, 1, src)
		return TRUE
	else
		return FALSE

/obj/structure/cable/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

// override, so telekinesis has no effect on a cable
/obj/structure/cable/attack_tk(mob/user)
	return

/obj/structure/cable/yellow
	color = COLOR_YELLOW

/obj/structure/cable/green
	color = COLOR_GREEN

/obj/structure/cable/blue
	color = COLOR_BLUE

/obj/structure/cable/pink
	color = COLOR_PINK

/obj/structure/cable/orange
	color = COLOR_ORANGE

/obj/structure/cable/cyan
	color = COLOR_CYAN

/obj/structure/cable/white
	color = COLOR_WHITE

//
//	This ASCII art represents my brain after looking at cable
//  code for too long, half of this was written before I was even
//  in 3rd grade
//				~~Sirryan
//
//			     _.-^^---....,,--
//			 _--                  --_
//			<                        >)
//			|        KABOOM          |
//			 \._                   _./
//			    ```--. . , ; .--'''
//			          | |   |
//			       .-=||  | |=-.
//			       `-=#$%&%$#=-'
//			          | ;  :|
//			_____.,-#%&$@%#&#~,._____
//
