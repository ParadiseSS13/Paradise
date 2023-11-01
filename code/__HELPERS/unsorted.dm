/*
 * A large number of misc global procs.
 */

 /* Get the direction of startObj relative to endObj.
  * Return values: To the right, 1. Below, 2. To the left, 3. Above, 4. Not found adjacent in cardinal directions, 0.
  */
/proc/getRelativeDirection(atom/movable/startObj, atom/movable/endObj)
	if(endObj.x == startObj.x + 1 && endObj.y == startObj.y)
		return EAST

	if(endObj.x == startObj.x - 1 && endObj.y == startObj.y)
		return WEST

	if(endObj.y == startObj.y + 1 && endObj.x == startObj.x)
		return NORTH

	if(endObj.y == startObj.y - 1 && endObj.x == startObj.x)
		return SOUTH

	return 0

//Returns the middle-most value
/proc/dd_range(low, high, num)
	return max(low,min(high,num))

//Returns whether or not A is the middle most value
/proc/InRange(A, lower, upper)
	if(A < lower) return 0
	if(A > upper) return 0
	return 1


/proc/get_angle(atom/movable/start, atom/movable/end)//For beams.
	if(!start || !end)
		return 0
	var/dy
	var/dx
	dy = (32 * end.y + end.pixel_y) - (32 * start.y + start.pixel_y)
	dx = (32 * end.x + end.pixel_x) - (32 * start.x + start.pixel_x)
	if(!dy)
		return (dx >= 0) ? 90 : 270
	. = arctan(dx / dy)
	if(dy < 0)
		. += 180
	else if(dx < 0)
		. += 360

//Returns location. Returns null if no location was found.
/proc/get_teleport_loc(turf/location,mob/target,distance = 1, density = TRUE, errorx = 0, errory = 0, eoffsetx = 0, eoffsety = 0)
/*
Location where the teleport begins, target that will teleport, distance to go, density checking 0/1(yes/no).
Random error in tile placement x, error in tile placement y, and block offset.
Block offset tells the proc how to place the box. Behind teleport location, relative to starting location, forward, etc.
Negative values for offset are accepted, think of it in relation to North, -x is west, -y is south. Error defaults to positive.
Turf and target are seperate in case you want to teleport some distance from a turf the target is not standing on or something.
*/

	var/dirx = 0//Generic location finding variable.
	var/diry = 0

	var/xoffset = 0//Generic counter for offset location.
	var/yoffset = 0

	var/b1xerror = 0//Generic placing for point A in box. The lower left.
	var/b1yerror = 0
	var/b2xerror = 0//Generic placing for point B in box. The upper right.
	var/b2yerror = 0

	errorx = abs(errorx)//Error should never be negative.
	errory = abs(errory)
	//var/errorxy = round((errorx+errory)/2)//Used for diagonal boxes.

	switch(target.dir)//This can be done through equations but switch is the simpler method. And works fast to boot.
	//Directs on what values need modifying.
		if(1)//North
			diry+=distance
			yoffset+=eoffsety
			xoffset+=eoffsetx
			b1xerror-=errorx
			b1yerror-=errory
			b2xerror+=errorx
			b2yerror+=errory
		if(2)//South
			diry-=distance
			yoffset-=eoffsety
			xoffset+=eoffsetx
			b1xerror-=errorx
			b1yerror-=errory
			b2xerror+=errorx
			b2yerror+=errory
		if(4)//East
			dirx+=distance
			yoffset+=eoffsetx//Flipped.
			xoffset+=eoffsety
			b1xerror-=errory//Flipped.
			b1yerror-=errorx
			b2xerror+=errory
			b2yerror+=errorx
		if(8)//West
			dirx-=distance
			yoffset-=eoffsetx//Flipped.
			xoffset+=eoffsety
			b1xerror-=errory//Flipped.
			b1yerror-=errorx
			b2xerror+=errory
			b2yerror+=errorx

	var/turf/destination=locate(location.x+dirx,location.y+diry,location.z)

	if(destination)//If there is a destination.
		if(errorx||errory)//If errorx or y were specified.
			var/destination_list[] = list()//To add turfs to list.
			//destination_list = new()
			/*This will draw a block around the target turf, given what the error is.
			Specifying the values above will basically draw a different sort of block.
			If the values are the same, it will be a square. If they are different, it will be a rectengle.
			In either case, it will center based on offset. Offset is position from center.
			Offset always calculates in relation to direction faced. In other words, depending on the direction of the teleport,
			the offset should remain positioned in relation to destination.*/

			var/turf/center = locate((destination.x+xoffset),(destination.y+yoffset),location.z)//So now, find the new center.

			//Now to find a box from center location and make that our destination.
			for(var/turf/T in block(locate(center.x+b1xerror,center.y+b1yerror,location.z), locate(center.x+b2xerror,center.y+b2yerror,location.z) ))
				if(density&&T.density)	continue//If density was specified.
				if(T.x>world.maxx || T.x<1)	continue//Don't want them to teleport off the map.
				if(T.y>world.maxy || T.y<1)	continue
				destination_list += T
			if(destination_list.len)
				destination = pick(destination_list)
			else	return

		else//Same deal here.
			if(density&&destination.density)	return
			if(destination.x>world.maxx || destination.x<1)	return
			if(destination.y>world.maxy || destination.y<1)	return
	else	return

	return destination


/proc/is_in_teleport_proof_area(atom/O)
	if(!O)
		return FALSE
	var/area/A = get_area(O)
	if(!A)
		return FALSE
	if(A.tele_proof)
		return TRUE
	if(!is_teleport_allowed(O.z))
		return TRUE
	else
		return FALSE

// Returns true if direction is blocked from loc
// Checks if doors are open
/proc/DirBlocked(turf/loc, dir)
	for(var/obj/structure/window/D in loc)
		if(!D.density)
			continue
		if(D.fulltile)
			return 1
		if(D.dir == dir)
			return 1

	for(var/obj/machinery/door/D in loc)
		if(!D.density)//if the door is open
			continue
		else return 1	// if closed, it's a real, air blocking door
	return 0

/////////////////////////////////////////////////////////////////////////

/**
 * Gets the turfs which are between the two given atoms. Including their positions
 * Only works for atoms on the same Z level which is not 0. So an atom located in a non turf won't work
 * Arguments:
 * * M - The source atom
 * * N - The target atom
 */
/proc/getline(atom/M, atom/N)//Ultra-Fast Bresenham Line-Drawing Algorithm
	if(!M.z || M.z != N.z)	// Same Z level and not 0. Else all below breaks
		return list()
	var/px=M.x		//starting x
	var/py=M.y
	var/line[] = list(locate(px,py,M.z))
	var/dx=N.x-px	//x distance
	var/dy=N.y-py
	var/dxabs=abs(dx)//Absolute value of x distance
	var/dyabs=abs(dy)
	var/sdx=SIGN(dx)	//Sign of x distance (+ or -)
	var/sdy=SIGN(dy)
	var/x=dxabs>>1	//Counters for steps taken, setting to distance/2
	var/y=dyabs>>1	//Bit-shifting makes me l33t.  It also makes getline() unnessecarrily fast.
	var/j			//Generic integer for counting
	if(dxabs>=dyabs)	//x distance is greater than y
		for(j=0;j<dxabs;j++)//It'll take dxabs steps to get there
			y+=dyabs
			if(y>=dxabs)	//Every dyabs steps, step once in y direction
				y-=dxabs
				py+=sdy
			px+=sdx		//Step on in x direction
			line+=locate(px,py,M.z)//Add the turf to the list
	else
		for(j=0;j<dyabs;j++)
			x+=dxabs
			if(x>=dyabs)
				x-=dyabs
				px+=sdx
			py+=sdy
			line+=locate(px,py,M.z)
	return line

//Same as the thing below just for density and without support for atoms.
/proc/can_line(atom/source, atom/target, length = 5)
	var/turf/current = get_turf(source)
	var/turf/target_turf = get_turf(target)
	var/steps = 0

	while(current != target_turf)
		if(steps > length)
			return FALSE
		if(!current)
			return FALSE
		if(current.density)
			return FALSE
		current = get_step_towards(current, target_turf)
		steps++
	return TRUE

//Returns whether or not a player is a guest using their ckey as an input
/proc/IsGuestKey(key)
	if(findtext(key, "Guest-", 1, 7) != 1) //was findtextEx
		return 0

	var/i, ch, len = length(key)

	for(i = 7, i <= len, ++i)
		ch = text2ascii(key, i)
		if(ch < 48 || ch > 57)
			return 0
	return 1

//Ensure the frequency is within bounds of what it should be sending/recieving at
/proc/sanitize_frequency(f, low = PUBLIC_LOW_FREQ, high = PUBLIC_HIGH_FREQ)
	f = round(f)
	f = max(low, f)
	f = min(high, f)
	if((f % 2) == 0) //Ensure the last digit is an odd number
		f += 1
	return f

//Turns 1479 into 147.9
/proc/format_frequency(f)
	return "[round(f / 10)].[f % 10]"

/obj/proc/atmosanalyzer_scan(datum/gas_mixture/air_contents, mob/user, obj/target = src)
	var/obj/icon = target
	user.visible_message("[user] has used the analyzer on [target].", "<span class='notice'>You use the analyzer on [target].</span>")
	var/pressure = air_contents.return_pressure()
	var/total_moles = air_contents.total_moles()
	var/volume = air_contents.return_volume()

	user.show_message("<span class='notice'>Results of analysis of [bicon(icon)] [target].</span>", 1)
	if(total_moles>0)
		var/o2_concentration = air_contents.oxygen/total_moles
		var/n2_concentration = air_contents.nitrogen/total_moles
		var/co2_concentration = air_contents.carbon_dioxide/total_moles
		var/plasma_concentration = air_contents.toxins/total_moles
		var/n2o_concentration = air_contents.sleeping_agent/total_moles

		var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration+n2o_concentration)

		user.show_message("<span class='notice'>Pressure: [round(pressure,0.1)] kPa</span>", 1)
		user.show_message("<span class='notice'>Nitrogen: [round(n2_concentration*100)] % ([round(air_contents.nitrogen,0.01)] moles)</span>", 1)
		user.show_message("<span class='notice'>Oxygen: [round(o2_concentration*100)] % ([round(air_contents.oxygen,0.01)] moles)</span>", 1)
		user.show_message("<span class='notice'>CO2: [round(co2_concentration*100)] % ([round(air_contents.carbon_dioxide,0.01)] moles)</span>", 1)
		user.show_message("<span class='notice'>Plasma: [round(plasma_concentration*100)] % ([round(air_contents.toxins,0.01)] moles)</span>", 1)
		user.show_message("<span class='notice'>Nitrous Oxide: [round(n2o_concentration*100)] % ([round(air_contents.sleeping_agent,0.01)] moles)</span>", 1)
		if(unknown_concentration>0.01)
			user.show_message("<span class='danger'>Unknown: [round(unknown_concentration*100)] % ([round(unknown_concentration*total_moles,0.01)] moles)</span>", 1)
		user.show_message("<span class='notice'>Total: [round(total_moles,0.01)] moles</span>", 1)
		user.show_message("<span class='notice'>Temperature: [round(air_contents.temperature-T0C)] &deg;C</span>", 1)
		user.show_message("<span class='notice'>Volume: [round(volume)] Liters</span>", 1)
	else
		user.show_message("<span class='notice'>[target] is empty!</span>", 1)
		user.show_message("<span class='notice'>Volume: [round(volume)] Liters</span>", 1)
	return

//Picks a string of symbols to display as the law number for hacked or ion laws
/proc/ionnum()
	return "[pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")]"

//When an AI is activated, it can choose from a list of non-slaved borgs to have as a slave.
/proc/freeborg()
	var/select = null
	var/list/borgs = list()
	for(var/mob/living/silicon/robot/A in GLOB.player_list)
		if(A.stat == 2 || A.connected_ai || A.scrambledcodes || isdrone(A))
			continue
		var/name = "[A.real_name] ([A.modtype] [A.braintype])"
		borgs[name] = A

	if(borgs.len)
		select = input("Unshackled borg signals detected:", "Borg selection", null, null) as null|anything in borgs
		return borgs[select]

//When a borg is activated, it can choose which AI it wants to be slaved to
/proc/active_ais()
	. = list()
	for(var/mob/living/silicon/ai/A in GLOB.alive_mob_list)
		if(A.stat == DEAD)
			continue
		if(A.control_disabled)
			continue
		. += A
	return .

//Find an active ai with the least borgs. VERBOSE PROCNAME HUH!
/proc/select_active_ai_with_fewest_borgs()
	var/mob/living/silicon/ai/selected
	var/list/active = active_ais()
	for(var/thing in active)
		var/mob/living/silicon/ai/A = thing
		if(!selected || (length(selected.connected_robots) > length(A.connected_robots)))
			selected = A

	return selected

/proc/select_active_ai(mob/user)
	var/list/ais = active_ais()
	if(ais.len)
		if(user)	. = input(usr,"AI signals detected:", "AI selection") in ais
		else		. = pick(ais)
	return .

/proc/get_sorted_mobs()
	var/list/old_list = getmobs()
	var/list/AI_list = list()
	var/list/Dead_list = list()
	var/list/keyclient_list = list()
	var/list/key_list = list()
	var/list/logged_list = list()
	for(var/named in old_list)
		var/mob/M = old_list[named]
		if(issilicon(M))
			AI_list |= M
		else if(isobserver(M) || M.stat == DEAD)
			Dead_list |= M
		else if(M.key && M.client)
			keyclient_list |= M
		else if(M.key)
			key_list |= M
		else
			logged_list |= M
		old_list.Remove(named)
	var/list/new_list = list()
	new_list += AI_list
	new_list += keyclient_list
	new_list += key_list
	new_list += logged_list
	new_list += Dead_list
	return new_list

//Returns a list of all mobs with their name
/proc/getmobs()

	var/list/mobs = sortmobs()
	var/list/names = list()
	var/list/creatures = list()
	var/list/namecounts = list()
	for(var/mob/M in mobs)
		var/name = M.name
		if(name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		if(M.real_name && M.real_name != M.name)
			name += " \[[M.real_name]\]"
		if(M.stat == DEAD)
			if(isobserver(M))
				name += " \[ghost\]"
			else
				name += " \[dead\]"
		creatures[name] = M

	return creatures

//Orders mobs by type then by name
/proc/sortmobs()
	var/list/moblist = list()
	var/list/sortmob = sortAtom(GLOB.mob_list)
	for(var/mob/living/silicon/ai/M in sortmob)
		moblist.Add(M)
		if(M.eyeobj)
			moblist.Add(M.eyeobj)
	for(var/mob/living/silicon/pai/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/silicon/robot/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/human/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/brain/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/alien/M in sortmob)
		moblist.Add(M)
	for(var/mob/dead/observer/M in sortmob)
		moblist.Add(M)
	for(var/mob/new_player/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/simple_animal/slime/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/simple_animal/M in sortmob)
		moblist.Add(M)
	return moblist

// Format a power value in W, kW, MW, or GW.
/proc/DisplayPower(powerused)
	if(powerused < 1000) //Less than a kW
		return "[powerused] W"
	else if(powerused < 1000000) //Less than a MW
		return "[round((powerused * 0.001), 0.01)] kW"
	else if(powerused < 1000000000) //Less than a GW
		return "[round((powerused * 0.000001), 0.001)] MW"
	return "[round((powerused * 0.000000001), 0.0001)] GW"

// Format an energy value in J, kJ, MJ, or GJ. 1W = 1J/s.
/proc/DisplayJoules(units)
	if (units < 1000) // Less than a kJ
		return "[round(units, 0.1)] J"
	else if (units < 1000000) // Less than a MJ
		return "[round(units * 0.001, 0.01)] kJ"
	else if (units < 1000000000) // Less than a GJ
		return "[round(units * 0.000001, 0.001)] MJ"
	return "[round(units * 0.000000001, 0.0001)] GJ"

// Format an energy value measured in Power Cell units.
/proc/DisplayEnergy(units)
	// APCs process every (SSmachines.wait * 0.1) seconds, and turn 1 W of
	// excess power into GLOB.CELLRATE energy units when charging cells.
	// With the current configuration of wait=20 and CELLRATE=0.002, this
	// means that one unit is 1 kJ.
	return DisplayJoules(units * SSmachines.wait * 0.1 / GLOB.CELLRATE)

//Forces a variable to be posative
/proc/modulus(M)
	if(M >= 0)
		return M
	if(M < 0)
		return -M

/proc/get_mob_by_ckey(key)
	if(!key)
		return
	for(var/mob/M in GLOB.mob_list)
		if(M.ckey == key)
			return M

/proc/get_client_by_ckey(ckey)
	if(cmptext(copytext(ckey, 1, 2),"@"))
		ckey = findStealthKey(ckey)
	return GLOB.directory[ckey]


/proc/findStealthKey(txt)
	if(txt)
		for(var/P in GLOB.stealthminID)
			if(GLOB.stealthminID[P] == txt)
				return P

//Returns the atom sitting on the turf.
//For example, using this on a disk, which is in a bag, on a mob, will return the mob because it's on the turf.
//Optional arg 'type' to stop once it reaches a specific type instead of a turf.
/proc/get_atom_on_turf(atom/movable/M, stop_type)
	var/atom/loc = M
	while(loc?.loc && !isturf(loc.loc))
		loc = loc.loc
		if(stop_type && istype(loc, stop_type))
			break
	return loc

/*
Returns 1 if the chain up to the area contains the given typepath
0 otherwise
*/
/atom/proc/is_found_within(typepath)
	var/atom/A = src
	while(A.loc)
		if(istype(A.loc, typepath))
			return 1
		A = A.loc
	return 0

// the on-close client verb
// called when a browser popup window is closed after registering with proc/onclose()
// if a valid atom reference is supplied, call the atom's Topic() with "close=1"
// otherwise, just reset the client mob's machine var.


// returns the turf located at the map edge in the specified direction relative to A
// used for mass driver
/proc/get_edge_target_turf(atom/A, direction)

	var/turf/target = locate(A.x, A.y, A.z)
	if(!A || !target)
		return 0
		//since NORTHEAST == NORTH & EAST, etc, doing it this way allows for diagonal mass drivers in the future
		//and isn't really any more complicated

		// Note diagonal directions won't usually be accurate
	if(direction & NORTH)
		target = locate(target.x, world.maxy, target.z)
	if(direction & SOUTH)
		target = locate(target.x, 1, target.z)
	if(direction & EAST)
		target = locate(world.maxx, target.y, target.z)
	if(direction & WEST)
		target = locate(1, target.y, target.z)

	return target

// returns turf relative to A in given direction at set range
// result is bounded to map size
// note range is non-pythagorean
// used for disposal system
/proc/get_ranged_target_turf(atom/A, direction, range)

	var/x = A.x
	var/y = A.y
	if(direction & NORTH)
		y = min(world.maxy, y + range)
	if(direction & SOUTH)
		y = max(1, y - range)
	if(direction & EAST)
		x = min(world.maxx, x + range)
	if(direction & WEST)
		x = max(1, x - range)

	return locate(x,y,A.z)

/**
 * Get ranged target turf, but with direct targets as opposed to directions
 *
 * Starts at atom starting_atom and gets the exact angle between starting_atom and target
 * Moves from starting_atom with that angle, Range amount of times, until it stops, bound to map size
 * Arguments:
 * * starting_atom - Initial Firer / Position
 * * target - Target to aim towards
 * * range - Distance of returned target turf from starting_atom
 * * offset - Angle offset, 180 input would make the returned target turf be in the opposite direction
 */
/proc/get_ranged_target_turf_direct(atom/starting_atom, atom/target, range, offset)
	var/angle = ATAN2(target.x - starting_atom.x, target.y - starting_atom.y)
	if(offset)
		angle += offset
	var/turf/starting_turf = get_turf(starting_atom)
	for(var/i in 1 to range)
		var/turf/check = locate(starting_atom.x + cos(angle) * i, starting_atom.y + sin(angle) * i, starting_atom.z)
		if(!check)
			break
		starting_turf = check

	return starting_turf

// returns turf relative to A offset in dx and dy tiles
// bound to map limits
/proc/get_offset_target_turf(atom/A, dx, dy)
	var/x = min(world.maxx, max(1, A.x + dx))
	var/y = min(world.maxy, max(1, A.y + dy))
	return locate(x,y,A.z)

//returns random gauss number
/proc/GaussRand(sigma)
	var/x,y,rsq
	do
		x=2*rand()-1
		y=2*rand()-1
		rsq=x*x+y*y
	while(rsq>1 || !rsq)
	return sigma*y*sqrt(-2*log(rsq)/rsq)

//returns random gauss number, rounded to 'roundto'
/proc/GaussRandRound(sigma, roundto)
	return round(GaussRand(sigma),roundto)

//Will return the contents of an atom recursivly to a depth of 'searchDepth'
/atom/proc/GetAllContents(searchDepth = 5)
	var/list/toReturn = list()

	for(var/atom/part in contents)
		toReturn += part
		if(part.contents.len && searchDepth)
			toReturn += part.GetAllContents(searchDepth - 1)

	return toReturn

//Searches contents of the atom and returns the sum of all w_class of obj/item within
/atom/proc/GetTotalContentsWeight(searchDepth = 5)
	var/weight = 0
	var/list/content = GetAllContents(searchDepth)
	for(var/obj/item/I in content)
		weight += I.w_class
	return weight

//Step-towards method of determining whether one atom can see another. Similar to viewers()
/proc/can_see(atom/source, atom/target, length=5) // I couldnt be arsed to do actual raycasting :I This is horribly inaccurate.
	var/turf/current = get_turf(source)
	var/turf/target_turf = get_turf(target)
	var/steps = 1

	if(current != target_turf)
		current = get_step_towards(current, target_turf)
		while(current != target_turf)
			if(steps > length)
				return 0
			if(current.opacity)
				return 0
			for(var/thing in current)
				var/atom/A = thing
				if(A.opacity)
					return 0
			current = get_step_towards(current, target_turf)
			steps++

	return 1

/proc/is_blocked_turf(turf/T, exclude_mobs, list/excluded_objs)
	if(T.density)
		return TRUE
	if(locate(/mob/living/silicon/ai) in T) //Prevents jaunting onto the AI core cheese, AI should always block a turf due to being a dense mob even when unanchored
		return TRUE
	if(!exclude_mobs)
		for(var/mob/living/L in T)
			if(L.density)
				return TRUE
	var/any_excluded_objs = length(excluded_objs)
	for(var/obj/O in T)
		if(any_excluded_objs && (O in excluded_objs))
			continue
		if(O.density)
			return TRUE
	return FALSE

/proc/get_step_towards2(atom/ref , atom/trg)
	var/base_dir = get_dir(ref, get_step_towards(ref,trg))
	var/turf/temp = get_step_towards(ref,trg)

	if(is_blocked_turf(temp))
		var/dir_alt1 = turn(base_dir, 90)
		var/dir_alt2 = turn(base_dir, -90)
		var/turf/turf_last1 = temp
		var/turf/turf_last2 = temp
		var/free_tile = null
		var/breakpoint = 0

		while(!free_tile && breakpoint < 10)
			if(!is_blocked_turf(turf_last1))
				free_tile = turf_last1
				break
			if(!is_blocked_turf(turf_last2))
				free_tile = turf_last2
				break
			turf_last1 = get_step(turf_last1,dir_alt1)
			turf_last2 = get_step(turf_last2,dir_alt2)
			breakpoint++

		if(!free_tile) return get_step(ref, base_dir)
		else return get_step_towards(ref,free_tile)

	else return get_step(ref, base_dir)

//Takes: Anything that could possibly have variables and a varname to check.
//Returns: 1 if found, 0 if not.
/proc/hasvar(datum/A, varname)
	if(A.vars.Find(lowertext(varname))) return 1
	else return 0

//Returns: all the areas in the world
/proc/return_areas()
	var/list/area/areas = list()
	for(var/area/A in world)
		areas += A
	return areas

//Returns: all the areas in the world, sorted.
/proc/return_sorted_areas()
	return sortAtom(return_areas())

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all areas of that type in the world.
/proc/get_areas(areatype)
	if(!areatype) return null
	if(istext(areatype)) areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/areas = new/list()
	for(var/area/N in world)
		if(istype(N, areatype)) areas += N
	return areas

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all turfs in areas of that type of that type in the world.
/proc/get_area_turfs(areatype)
	if(!areatype) return null
	if(istext(areatype)) areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/turfs = new/list()
	for(var/area/N in world)
		if(istype(N, areatype))
			for(var/turf/T in N) turfs += T
	return turfs

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all atoms	(objs, turfs, mobs) in areas of that type of that type in the world.
/proc/get_area_all_atoms(areatype)
	if(!areatype) return null
	if(istext(areatype)) areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/atoms = new/list()
	for(var/area/N in world)
		if(istype(N, areatype))
			for(var/atom/A in N)
				atoms += A
	return atoms

/datum/coords //Simple datum for storing coordinates.
	var/x_pos = null
	var/y_pos = null
	var/z_pos = null

/area/proc/move_contents_to(area/A, turftoleave=null, direction = null)
	//Takes: Area. Optional: turf type to leave behind.
	//Returns: Nothing.
	//Notes: Attempts to move the contents of one area to another area.
	//       Movement based on lower left corner. Tiles that do not fit
	//		 into the new area will not be moved.

	if(!A || !src) return 0

	var/list/turfs_src = get_area_turfs(src.type)
	var/list/turfs_trg = get_area_turfs(A.type)

	var/src_min_x = 0
	var/src_min_y = 0
	for(var/turf/T in turfs_src)
		if(T.x < src_min_x || !src_min_x) src_min_x	= T.x
		if(T.y < src_min_y || !src_min_y) src_min_y	= T.y

	var/trg_min_x = 0
	var/trg_min_y = 0
	for(var/turf/T in turfs_trg)
		if(T.x < trg_min_x || !trg_min_x) trg_min_x	= T.x
		if(T.y < trg_min_y || !trg_min_y) trg_min_y	= T.y

	var/list/refined_src = new/list()
	for(var/turf/T in turfs_src)
		refined_src += T
		refined_src[T] = new/datum/coords
		var/datum/coords/C = refined_src[T]
		C.x_pos = (T.x - src_min_x)
		C.y_pos = (T.y - src_min_y)

	var/list/refined_trg = new/list()
	for(var/turf/T in turfs_trg)
		refined_trg += T
		refined_trg[T] = new/datum/coords
		var/datum/coords/C = refined_trg[T]
		C.x_pos = (T.x - trg_min_x)
		C.y_pos = (T.y - trg_min_y)

	var/list/fromupdate = new/list()
	var/list/toupdate = new/list()

	moving:
		for(var/turf/T in refined_src)
			var/datum/coords/C_src = refined_src[T]
			for(var/turf/B in refined_trg)
				var/datum/coords/C_trg = refined_trg[B]
				if(C_src.x_pos == C_trg.x_pos && C_src.y_pos == C_trg.y_pos)

					var/old_dir1 = T.dir
					var/old_icon_state1 = T.icon_state
					var/old_icon1 = T.icon

					var/turf/X = B.ChangeTurf(T.type)
					X.dir = old_dir1
					X.icon_state = old_icon_state1
					X.icon = old_icon1 //Shuttle floors are in shuttle.dmi while the defaults are floors.dmi

					// Give the new turf our air, if simulated
					if(issimulatedturf(X) && issimulatedturf(T))
						var/turf/simulated/sim = X
						sim.copy_air_with_tile(T)


					/* Quick visual fix for some weird shuttle corner artefacts when on transit space tiles */
					if(direction && findtext(X.icon_state, "swall_s"))

						// Spawn a new shuttle corner object
						var/obj/corner = new()
						corner.loc = X
						corner.density = TRUE
						corner.anchored = TRUE
						corner.icon = X.icon
						corner.icon_state = replacetext(X.icon_state, "_s", "_f")
						corner.tag = "delete me"
						corner.name = "wall"

						// Find a new turf to take on the property of
						var/turf/nextturf = get_step(corner, direction)
						if(!nextturf || !isspaceturf(nextturf))
							nextturf = get_step(corner, turn(direction, 180))


						// Take on the icon of a neighboring scrolling space icon
						X.icon = nextturf.icon
						X.icon_state = nextturf.icon_state


					for(var/obj/O in T)

						// Reset the shuttle corners
						if(O.tag == "delete me")
							X.icon = 'icons/turf/shuttle.dmi'
							X.icon_state = replacetext(O.icon_state, "_f", "_s") // revert the turf to the old icon_state
							X.name = "wall"
							qdel(O) // prevents multiple shuttle corners from stacking
							continue
						if(!isobj(O)) continue
						O.loc.Exited(O)
						O.setLoc(X,teleported=1)
						O.loc.Entered(O)
					for(var/mob/M in T)
						if(!M.move_on_shuttle)
							continue
						M.loc = X

//					var/area/AR = X.loc

//					if(AR.lighting_use_dynamic)							//TODO: rewrite this code so it's not messed by lighting ~Carn
//						X.opacity = !X.opacity
//						X.set_opacity(!X.opacity)

					toupdate += X

					if(turftoleave)
						fromupdate += T.ChangeTurf(turftoleave)
					else
						T.ChangeTurf(T.baseturf)

					refined_src -= T
					refined_trg -= B
					continue moving

	if(toupdate.len)
		for(var/turf/simulated/T1 in toupdate)
			SSair.remove_from_active(T1)
			T1.CalculateAdjacentTurfs()
			SSair.add_to_active(T1,1)

	if(fromupdate.len)
		for(var/turf/simulated/T2 in fromupdate)
			SSair.remove_from_active(T2)
			T2.CalculateAdjacentTurfs()
			SSair.add_to_active(T2,1)




/proc/DuplicateObject(obj/original, perfectcopy = 0 , sameloc = 0, atom/newloc = null)
	if(!original)
		return null

	var/obj/O = null

	if(sameloc)
		O=new original.type(original.loc)
	else
		O=new original.type(newloc)

	if(perfectcopy)
		if((O) && (original))
			var/static/list/forbidden_vars = list("type","loc","locs","vars", "parent","parent_type", "verbs","ckey","key","power_supply","contents","reagents","stat","x","y","z","group", "comp_lookup", "datum_components")

			for(var/V in original.vars - forbidden_vars)
				if(istype(original.vars[V],/list))
					var/list/L = original.vars[V]
					O.vars[V] = L.Copy()
				else if(istype(original.vars[V],/datum))
					continue	// this would reference the original's object, that will break when it is used or deleted.
				else
					O.vars[V] = original.vars[V]
	if(istype(O))
		O.update_icon()
	return O

/area/proc/copy_contents_to(area/A , platingRequired = 0, perfect_copy = TRUE)
	//Takes: Area. Optional: If it should copy to areas that don't have plating
	//Returns: Nothing.
	//Notes: Attempts to move the contents of one area to another area.
	//       Movement based on lower left corner. Tiles that do not fit
	//		 into the new area will not be moved.

	if(!A || !src)
		return FALSE

	var/list/turfs_src = get_area_turfs(src.type)
	var/list/turfs_trg = get_area_turfs(A.type)

	var/src_min_x = 0
	var/src_min_y = 0
	for(var/turf/T in turfs_src)
		if(T.x < src_min_x || !src_min_x)
			src_min_x	= T.x
		if(T.y < src_min_y || !src_min_y)
			src_min_y	= T.y

	var/trg_min_x = 0
	var/trg_min_y = 0
	for(var/turf/T in turfs_trg)
		if(T.x < trg_min_x || !trg_min_x)
			trg_min_x	= T.x
		if(T.y < trg_min_y || !trg_min_y)
			trg_min_y	= T.y

	var/list/refined_src = new/list()
	for(var/turf/T in turfs_src)
		refined_src += T
		refined_src[T] = new/datum/coords
		var/datum/coords/C = refined_src[T]
		C.x_pos = (T.x - src_min_x)
		C.y_pos = (T.y - src_min_y)

	var/list/refined_trg = new/list()
	for(var/turf/T in turfs_trg)
		refined_trg += T
		refined_trg[T] = new/datum/coords
		var/datum/coords/C = refined_trg[T]
		C.x_pos = (T.x - trg_min_x)
		C.y_pos = (T.y - trg_min_y)

	var/list/toupdate = new/list()

	var/copiedobjs = list()


	moving:
		for(var/turf/T in refined_src)
			var/datum/coords/C_src = refined_src[T]
			for(var/turf/B in refined_trg)
				var/datum/coords/C_trg = refined_trg[B]
				if(C_src.x_pos == C_trg.x_pos && C_src.y_pos == C_trg.y_pos)

					var/old_dir1 = T.dir
					var/old_icon_state1 = T.icon_state
					var/old_icon1 = T.icon

					if(platingRequired)
						if(isspaceturf(B))
							continue moving
					var/turf/X = new T.type(B)
					X.dir = old_dir1
					X.icon_state = old_icon_state1
					X.icon = old_icon1 //Shuttle floors are in shuttle.dmi while the defaults are floors.dmi

					var/list/objs = new/list()
					var/list/newobjs = new/list()
					var/list/mobs = new/list()
					var/list/newmobs = new/list()

					for(var/obj/O in T)

						if(!isobj(O))
							continue

						objs += O


					for(var/obj/O in objs)
						newobjs += DuplicateObject(O , perfect_copy)


					for(var/obj/O in newobjs)
						O.loc = X

					for(var/mob/M in T)

						if(!M.move_on_shuttle)
							continue
						mobs += M

					for(var/mob/M in mobs)
						newmobs += DuplicateObject(M , 1)

					for(var/mob/M in newmobs)
						M.loc = X

					copiedobjs += newobjs
					copiedobjs += newmobs



					for(var/V in T.vars)
						if(!(V in list("type","loc","locs","vars", "parent", "parent_type","verbs","ckey","key","x","y","z","destination_z", "destination_x", "destination_y","contents", "luminosity", "group")))
							X.vars[V] = T.vars[V]

					toupdate += X

					refined_src -= T
					refined_trg -= B
					continue moving



	if(toupdate.len)
		for(var/turf/simulated/T1 in toupdate)
			T1.CalculateAdjacentTurfs()
			SSair.add_to_active(T1,1)


	return copiedobjs



/proc/get_cardinal_dir(atom/A, atom/B)
	var/dx = abs(B.x - A.x)
	var/dy = abs(B.y - A.y)
	return get_dir(A, B) & (rand() * (dx+dy) < dy ? 3 : 12)

//chances are 1:value. anyprob(1) will always return true
/proc/anyprob(value)
	return (rand(1,value)==value)

/proc/view_or_range(distance = world.view , center = usr , type)
	switch(type)
		if("view")
			. = view(distance,center)
		if("range")
			. = range(distance,center)
	return

/proc/oview_or_orange(distance = world.view , center = usr , type)
	switch(type)
		if("view")
			. = oview(distance,center)
		if("range")
			. = orange(distance,center)
	return

/proc/get_mob_with_client_list()
	var/list/mobs = list()
	for(var/mob/M in GLOB.mob_list)
		if(M.client)
			mobs += M
	return mobs


/proc/parse_zone(zone)
	if(zone == "r_hand") return "right hand"
	else if(zone == "l_hand") return "left hand"
	else if(zone == "l_arm") return "left arm"
	else if(zone == "r_arm") return "right arm"
	else if(zone == "l_leg") return "left leg"
	else if(zone == "r_leg") return "right leg"
	else if(zone == "l_foot") return "left foot"
	else if(zone == "r_foot") return "right foot"
	else if(zone == "l_hand") return "left hand"
	else if(zone == "r_hand") return "right hand"
	else if(zone == "l_foot") return "left foot"
	else if(zone == "r_foot") return "right foot"
	else return zone

/*

 Gets the turf this atom's *ICON* appears to inhabit
 It takes into account:
 * Pixel_x/y
 * Matrix x/y

 NOTE: if your atom has non-standard bounds then this proc
 will handle it, but:
 * if the bounds are even, then there are an even amount of "middle" turfs, the one to the EAST, NORTH, or BOTH is picked
 (this may seem bad, but you're atleast as close to the center of the atom as possible, better than byond's default loc being all the way off)
 * if the bounds are odd, the true middle turf of the atom is returned

*/

/proc/get_turf_pixel(atom/movable/AM)
	if(!istype(AM))
		return

	//Find AM's matrix so we can use it's X/Y pixel shifts
	var/matrix/M = matrix(AM.transform)

	var/pixel_x_offset = AM.pixel_x + M.get_x_shift()
	var/pixel_y_offset = AM.pixel_y + M.get_y_shift()

	//Irregular objects
	if(AM.bound_height != world.icon_size || AM.bound_width != world.icon_size)
		var/icon/AMicon = icon(AM.icon, AM.icon_state)
		pixel_x_offset += ((AMicon.Width()/world.icon_size)-1)*(world.icon_size*0.5)
		pixel_y_offset += ((AMicon.Height()/world.icon_size)-1)*(world.icon_size*0.5)
		qdel(AMicon)

	//DY and DX
	var/rough_x = round(round(pixel_x_offset,world.icon_size)/world.icon_size)
	var/rough_y = round(round(pixel_y_offset,world.icon_size)/world.icon_size)

	//Find coordinates
	var/turf/T = get_turf(AM) //use AM's turfs, as it's coords are the same as AM's AND AM's coords are lost if it is inside another atom
	if(!T)
		return null
	var/final_x = T.x + rough_x
	var/final_y = T.y + rough_y

	if(final_x || final_y)
		return locate(final_x, final_y, T.z)

//Finds the distance between two atoms, in pixels
//centered = 0 counts from turf edge to edge
//centered = 1 counts from turf center to turf center
//of course mathematically this is just adding world.icon_size on again
/proc/getPixelDistance(atom/A, atom/B, centered = 1)
	if(!istype(A)||!istype(B))
		return 0
	. = bounds_dist(A, B) + sqrt((((A.pixel_x+B.pixel_x)**2) + ((A.pixel_y+B.pixel_y)**2)))
	if(centered)
		. += world.icon_size

/proc/get(atom/loc, type)
	while(loc)
		if(istype(loc, type))
			return loc
		loc = loc.loc
	return null

/proc/get_turf_or_move(turf/location)
	return get_turf(location)


//For objects that should embed, but make no sense being is_sharp or is_pointed()
//e.g: rods
GLOBAL_LIST_INIT(can_embed_types, typecacheof(list(
	/obj/item/stack/rods,
	/obj/item/pipe)))

/proc/can_embed(obj/item/W)
	if(is_sharp(W))
		return 1
	if(is_pointed(W))
		return 1

	if(is_type_in_typecache(W, GLOB.can_embed_types))
		return 1

/proc/is_hot(obj/item/W as obj)
	if(W.tool_behaviour == TOOL_WELDER)
		if(W.tool_enabled)
			return 2500
		else
			return 0
	if(istype(W, /obj/item/lighter))
		var/obj/item/lighter/O = W
		if(O.lit)
			return 1500
		else
			return 0
	if(istype(W, /obj/item/match))
		var/obj/item/match/O = W
		if(O.lit)
			return 1000
		else
			return 0
	if(istype(W, /obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/O = W
		if(O.lit)
			return 1000
		else
			return 0
	if(istype(W, /obj/item/candle))
		var/obj/item/candle/O = W
		if(O.lit)
			return 1000
		else
			return 0
	if(istype(W, /obj/item/flashlight/flare))
		var/obj/item/flashlight/flare/O = W
		if(O.on)
			return 1000
		else
			return 0
	if(istype(W, /obj/item/gun/energy/plasmacutter))
		return 3800
	if(istype(W, /obj/item/melee/energy))
		var/obj/item/melee/energy/O = W
		if(O.active)
			return 3500
		else
			return 0
	if(istype(W, /obj/item/assembly/igniter))
		return 20000
	else
		return 0

//Whether or not the given item counts as sharp in terms of dealing damage
/proc/is_sharp(obj/O)
	if(!O)
		return 0
	if(O.sharp)
		return 1
	return 0

/proc/reverse_direction(dir)
	switch(dir)
		if(NORTH)
			return SOUTH
		if(NORTHEAST)
			return SOUTHWEST
		if(EAST)
			return WEST
		if(SOUTHEAST)
			return NORTHWEST
		if(SOUTH)
			return NORTH
		if(SOUTHWEST)
			return NORTHEAST
		if(WEST)
			return EAST
		if(NORTHWEST)
			return SOUTHEAST

/*
Checks if that loc and dir has a item on the wall
*/
GLOBAL_LIST_INIT(wall_items, typecacheof(list(/obj/machinery/power/apc, /obj/machinery/alarm,
	/obj/item/radio/intercom, /obj/structure/extinguisher_cabinet, /obj/structure/reagent_dispensers/peppertank,
	/obj/machinery/status_display, /obj/machinery/requests_console, /obj/machinery/light_switch, /obj/structure/sign,
	/obj/machinery/newscaster, /obj/machinery/firealarm, /obj/structure/noticeboard, /obj/machinery/door_control,
	/obj/machinery/computer/security/telescreen, /obj/machinery/airlock_controller,
	/obj/item/storage/secure/safe, /obj/machinery/door_timer, /obj/machinery/flasher, /obj/machinery/keycard_auth,
	/obj/structure/mirror, /obj/structure/closet/fireaxecabinet, /obj/machinery/computer/security/telescreen/entertainment,
	/obj/structure/sign)))

/proc/gotwallitem(loc, dir)
	for(var/obj/O in loc)
		if(is_type_in_typecache(O, GLOB.wall_items))
			//Direction works sometimes
			if(O.dir == dir)
				return 1

			//Some stuff doesn't use dir properly, so we need to check pixel instead
			switch(dir)
				if(SOUTH)
					if(O.pixel_y > 10)
						return 1
				if(NORTH)
					if(O.pixel_y < -10)
						return 1
				if(WEST)
					if(O.pixel_x > 10)
						return 1
				if(EAST)
					if(O.pixel_x < -10)
						return 1

	//Some stuff is placed directly on the wallturf (signs)
	for(var/obj/O in get_step(loc, dir))
		if(is_type_in_typecache(O, GLOB.wall_items))
			if(abs(O.pixel_x) <= 10 && abs(O.pixel_y) <= 10)
				return 1
	return 0

/proc/atan2(x, y)
	if(!x && !y) return 0
	return y >= 0 ? arccos(x / sqrt(x * x + y * y)) : -arccos(x / sqrt(x * x + y * y))

/proc/format_text(text)
	return replacetext(replacetext(text,"\proper ",""),"\improper ","")

/*
Standard way to write links -Sayu
*/

/proc/topic_link(datum/D, arglist, content)
	if(istype(arglist,/list))
		arglist = list2params(arglist)
	return "<a href='?src=[D.UID()];[arglist]'>[content]</a>"



/proc/get_location_accessible(mob/M, location)
	var/covered_locations	= 0	//based on body_parts_covered
	var/face_covered		= 0	//based on flags_inv
	var/eyesmouth_covered	= 0	//based on flags_cover
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		for(var/obj/item/clothing/I in list(C.back, C.wear_mask))
			covered_locations |= I.body_parts_covered
			face_covered |= I.flags_inv
			eyesmouth_covered |= I.flags_cover
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			for(var/obj/item/I in list(H.wear_suit, H.w_uniform, H.shoes, H.belt, H.gloves, H.glasses, H.head, H.r_ear, H.l_ear))
				covered_locations |= I.body_parts_covered
				face_covered |= I.flags_inv
				eyesmouth_covered |= I.flags_cover

	switch(location)
		if("head")
			if(covered_locations & HEAD)
				return 0
		if("eyes")
			if(face_covered & HIDEEYES || eyesmouth_covered & GLASSESCOVERSEYES || eyesmouth_covered & HEADCOVERSEYES)
				return 0
		if("mouth")
			if(covered_locations & HEAD || face_covered & HIDEFACE || eyesmouth_covered & MASKCOVERSMOUTH)
				return 0
		if("chest")
			if(covered_locations & UPPER_TORSO)
				return 0
		if("groin")
			if(covered_locations & LOWER_TORSO)
				return 0
		if("l_arm")
			if(covered_locations & ARM_LEFT)
				return 0
		if("r_arm")
			if(covered_locations & ARM_RIGHT)
				return 0
		if("l_leg")
			if(covered_locations & LEG_LEFT)
				return 0
		if("r_leg")
			if(covered_locations & LEG_RIGHT)
				return 0
		if("l_hand")
			if(covered_locations & HAND_LEFT)
				return 0
		if("r_hand")
			if(covered_locations & HAND_RIGHT)
				return 0
		if("l_foot")
			if(covered_locations & FOOT_LEFT)
				return 0
		if("r_foot")
			if(covered_locations & FOOT_RIGHT)
				return 0

	return 1

/proc/check_target_facings(mob/living/initator, mob/living/target)
	/*This can be used to add additional effects on interactions between mobs depending on how the mobs are facing each other, such as adding a crit damage to blows to the back of a guy's head.
	Given how click code currently works (Nov '13), the initiating mob will be facing the target mob most of the time
	That said, this proc should not be used if the change facing proc of the click code is overriden at the same time*/
	if(!ismob(target) || IS_HORIZONTAL(target))
	//Make sure we are not doing this for things that can't have a logical direction to the players given that the target would be on their side
		return FACING_FAILED
	if(initator.dir == target.dir) //mobs are facing the same direction
		return FACING_SAME_DIR
	if(is_A_facing_B(initator, target) && is_A_facing_B(target, initator)) //mobs are facing each other
		return FACING_EACHOTHER
	if(initator.dir + 2 == target.dir || initator.dir - 2 == target.dir || initator.dir + 6 == target.dir || initator.dir - 6 == target.dir) //Initating mob is looking at the target, while the target mob is looking in a direction perpendicular to the 1st
		return FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR


/atom/proc/GetTypeInAllContents(typepath)
	var/list/processing_list = list(src)
	var/list/processed = list()

	var/atom/found = null

	while(processing_list.len && found==null)
		var/atom/A = processing_list[1]
		if(istype(A, typepath))
			found = A

		processing_list -= A

		for(var/atom/a in A)
			if(!(a in processed))
				processing_list |= a

		processed |= A

	return found

/proc/random_step(atom/movable/AM, steps, chance)
	var/initial_chance = chance
	while(steps > 0)
		if(prob(chance))
			step(AM, pick(GLOB.alldirs))
		chance = max(chance - (initial_chance / steps), 0)
		steps--

/proc/get_random_colour(simple, lower, upper)
	var/colour
	if(simple)
		colour = pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))
	else
		for(var/i=1;i<=3;i++)
			var/temp_col = "[num2hex(rand(lower,upper), 2)]"
			colour += temp_col
	return colour

/proc/get_distant_turf(turf/T, direction, distance)
	if(!T || !direction || !distance)	return

	var/dest_x = T.x
	var/dest_y = T.y
	var/dest_z = T.z

	if(direction & NORTH)
		dest_y = min(world.maxy, dest_y+distance)
	if(direction & SOUTH)
		dest_y = max(0, dest_y-distance)
	if(direction & EAST)
		dest_x = min(world.maxy, dest_x+distance)
	if(direction & WEST)
		dest_x = max(0, dest_x-distance)

	return locate(dest_x,dest_y,dest_z)

GLOBAL_DATUM_INIT(dview_mob, /mob/dview, new)

//Version of view() which ignores darkness, because BYOND doesn't have it.
/proc/dview(range = world.view, center, invis_flags = 0)
	if(!center)
		return

	GLOB.dview_mob.loc = center

	GLOB.dview_mob.see_invisible = invis_flags

	. = view(range, GLOB.dview_mob)
	GLOB.dview_mob.loc = null

/mob/dview
	invisibility = 101
	density = FALSE
	move_force = 0
	pull_force = 0
	move_resist = INFINITY
	simulated = 0
	see_in_dark = 1e6

/mob/dview/New() //For whatever reason, if this isn't called, then BYOND will throw a type mismatch runtime when attempting to add this to the mobs list. -Fox
	SHOULD_CALL_PARENT(FALSE)

/mob/dview/Destroy()
	SHOULD_CALL_PARENT(FALSE)
	// should never be deleted
	return QDEL_HINT_LETMELIVE

/proc/IsValidSrc(A)
	if(istype(A, /datum))
		var/datum/D = A
		return !QDELETED(D)
	if(isclient(A))
		return TRUE
	return FALSE

//can a window be here, or is there a window blocking it?
/proc/valid_window_location(turf/T, dir_to_check)
	if(!T)
		return FALSE
	for(var/obj/O in T)
		if(istype(O, /obj/machinery/door/window) && (O.dir == dir_to_check || dir_to_check == FULLTILE_WINDOW_DIR))
			return FALSE
		if(istype(O, /obj/structure/windoor_assembly))
			var/obj/structure/windoor_assembly/W = O
			if(W.ini_dir == dir_to_check || dir_to_check == FULLTILE_WINDOW_DIR)
				return FALSE
		if(istype(O, /obj/structure/window))
			var/obj/structure/window/W = O
			if(W.ini_dir == dir_to_check || W.ini_dir == FULLTILE_WINDOW_DIR || dir_to_check == FULLTILE_WINDOW_DIR)
				return FALSE
	return TRUE

//datum may be null, but it does need to be a typed var
#define NAMEOF(datum, X) (#X || ##datum.##X)

#define VARSET_LIST_CALLBACK(target, var_name, var_value) CALLBACK(GLOBAL_PROC, PROC_REF(___callbackvarset), ##target, ##var_name, ##var_value)
//dupe code because dm can't handle 3 level deep macros
#define VARSET_CALLBACK(datum, var, var_value) CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(___callbackvarset), ##datum, NAMEOF(##datum, ##var), ##var_value)

/proc/___callbackvarset(list_or_datum, var_name, var_value)
	if(length(list_or_datum))
		list_or_datum[var_name] = var_value
		return
	var/datum/D = list_or_datum
	if(IsAdminAdvancedProcCall())
		D.vv_edit_var(var_name, var_value)	//same result generally, unless badmemes
	else
		D.vars[var_name] = var_value

//Get the dir to the RIGHT of dir if they were on a clock
//NORTH --> NORTHEAST
/proc/get_clockwise_dir(dir)
	. = angle2dir(dir2angle(dir)+45)

//Get the dir to the LEFT of dir if they were on a clock
//NORTH --> NORTHWEST
/proc/get_anticlockwise_dir(dir)
	. = angle2dir(dir2angle(dir)-45)


//Compare A's dir, the clockwise dir of A and the anticlockwise dir of A
//To the opposite dir of the dir returned by get_dir(B,A)
//If one of them is a match, then A is facing B
/proc/is_A_facing_B(atom/A, atom/B)
	if(!istype(A) || !istype(B))
		return 0
	if(isliving(A))
		var/mob/living/LA = A
		if(IS_HORIZONTAL(LA))
			return 0
	var/goal_dir = angle2dir(dir2angle(get_dir(B, A)+180))
	var/clockwise_A_dir = get_clockwise_dir(A.dir)
	var/anticlockwise_A_dir = get_anticlockwise_dir(B.dir)

	if(A.dir == goal_dir || clockwise_A_dir == goal_dir || anticlockwise_A_dir == goal_dir)
		return 1
	return 0

//Centers an image.
//Requires:
//The Image
//The x dimension of the icon file used in the image
//The y dimension of the icon file used in the image
// eg: center_image(I, 32,32)
// eg2: center_image(I, 96,96)
/proc/center_image(image/I, x_dimension = 0, y_dimension = 0)
	if(!I)
		return

	if(!x_dimension || !y_dimension)
		return

	//Get out of here, punk ass kids calling procs needlessly
	if((x_dimension == world.icon_size) && (y_dimension == world.icon_size))
		return I

	//Offset the image so that it's bottom left corner is shifted this many pixels
	//This makes it infinitely easier to draw larger inhands/images larger than world.iconsize
	//but still use them in game
	var/x_offset = -((x_dimension/world.icon_size)-1)*(world.icon_size*0.5)
	var/y_offset = -((y_dimension/world.icon_size)-1)*(world.icon_size*0.5)

	//Correct values under world.icon_size
	if(x_dimension < world.icon_size)
		x_offset *= -1
	if(y_dimension < world.icon_size)
		y_offset *= -1

	I.pixel_x = x_offset
	I.pixel_y = y_offset

	return I

//similar function to RANGE_TURFS(), but will search spiralling outwards from the center (like the above, but only turfs)
/proc/spiral_range_turfs(dist=0, center=usr, orange=0)
	if(!dist)
		if(!orange)
			return list(center)
		else
			return list()

	var/turf/t_center = get_turf(center)
	if(!t_center)
		return list()

	var/list/L = list()
	var/turf/T
	var/y
	var/x
	var/c_dist = 1

	if(!orange)
		L += t_center

	while( c_dist <= dist )
		y = t_center.y + c_dist
		x = t_center.x - c_dist + 1
		for(x in x to t_center.x+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y + c_dist - 1
		x = t_center.x + c_dist
		var/list/temp_list_one = list()
		for(y in t_center.y-c_dist to y)
			T = locate(x,y,t_center.z)
			if(T)
				temp_list_one += T
		L += reverselist(temp_list_one)

		y = t_center.y - c_dist
		x = t_center.x + c_dist - 1
		var/list/temp_list_two = list()
		for(x in t_center.x-c_dist to x)
			T = locate(x,y,t_center.z)
			if(T)
				temp_list_two += T
		L += reverselist(temp_list_two)

		y = t_center.y - c_dist + 1
		x = t_center.x - c_dist
		for(y in y to t_center.y+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
		c_dist++

	return L

//ultra range (no limitations on distance, faster than range for distances > 8); including areas drastically decreases performance
/proc/urange(dist=0, atom/center=usr, orange=0, areas=0)
	if(!dist)
		if(!orange)
			return list(center)
		else
			return list()

	var/list/turfs = RANGE_TURFS(dist, center)
	if(orange)
		turfs -= get_turf(center)
	. = list()
	for(var/V in turfs)
		var/turf/T = V
		. += T
		. += T.contents
		if(areas)
			. |= T.loc

/proc/turf_clear(turf/T)
	for(var/atom/A in T)
		if(A.simulated)
			return FALSE
	return TRUE

/proc/screen_loc2turf(scr_loc, turf/origin)
	var/tX = splittext(scr_loc, ",")
	var/tY = splittext(tX[2], ":")
	var/tZ = origin.z
	tY = tY[1]
	tX = splittext(tX[1], ":")
	tX = tX[1]
	tX = max(1, min(world.maxx, origin.x + (text2num(tX) - (world.view + 1))))
	tY = max(1, min(world.maxy, origin.y + (text2num(tY) - (world.view + 1))))
	return locate(tX, tY, tZ)

/proc/get_closest_atom(type, list, source)
	var/closest_atom
	var/closest_distance
	for(var/A in list)
		if(!istype(A, type))
			continue
		var/distance = get_dist(source, A)
		if(!closest_distance)
			closest_distance = distance
			closest_atom = A
		else
			if(closest_distance > distance)
				closest_distance = distance
				closest_atom = A
	return closest_atom

/proc/pick_closest_path(value, list/matches = get_fancy_list_of_atom_types())
	if(value == FALSE) //nothing should be calling us with a number, so this is safe
		value = input("Enter type to find (blank for all, cancel to cancel)", "Search for type") as null|text
		if(isnull(value))
			return
	value = trim(value)
	if(!isnull(value) && value != "")
		matches = filter_fancy_list(matches, value)

	if(matches.len == 0)
		return

	var/chosen
	if(matches.len == 1)
		chosen = matches[1]
	else
		chosen = input("Select a type", "Pick Type", matches[1]) as null|anything in matches
		if(!chosen)
			return
	chosen = matches[chosen]
	return chosen

/proc/make_types_fancy(list/types)
	if(ispath(types))
		types = list(types)
	. = list()
	for(var/type in types)
		var/typename = "[type]"
		var/static/list/TYPES_SHORTCUTS = list(
			//longest paths comes first - otherwise they get shadowed by the more generic ones
			/obj/effect/decal/cleanable = "CLEANABLE",
			/obj/effect = "EFFECT",
			/obj/item/ammo_casing = "AMMO",
			/obj/item/book/manual = "MANUAL",
			/obj/item/borg/upgrade = "BORG_UPGRADE",
			/obj/item/cartridge = "PDA_CART",
			/obj/item/clothing/head/helmet/space = "SPESSHELMET",
			/obj/item/clothing/head = "HEAD",
			/obj/item/clothing/under = "UNIFORM",
			/obj/item/clothing/shoes = "SHOES",
			/obj/item/clothing/suit = "SUIT",
			/obj/item/clothing/gloves = "GLOVES",
			/obj/item/clothing/mask/cigarette = "CIGARRETE", // oof
			/obj/item/clothing/mask = "MASK",
			/obj/item/clothing/glasses = "GLASSES",
			/obj/item/clothing = "CLOTHING",
			/obj/item/grenade/clusterbuster = "CLUSTERBUSTER",
			/obj/item/grenade = "GRENADE",
			/obj/item/gun = "GUN",
			/obj/item/implant = "IMPLANT",
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack = "MECHA_MISSILE_RACK",
			/obj/item/mecha_parts/mecha_equipment/weapon = "MECHA_WEAPON",
			/obj/item/mecha_parts/mecha_equipment = "MECHA_EQUIP",
			/obj/item/melee = "MELEE",
			/obj/item/mmi = "MMI",
			/obj/item/nullrod = "NULLROD",
			/obj/item/organ/external = "EXT_ORG",
			/obj/item/organ/internal/cyberimp = "CYBERIMP",
			/obj/item/organ/internal = "INT_ORG",
			/obj/item/organ = "ORGAN",
			/obj/item/pda = "PDA",
			/obj/item/projectile = "PROJ",
			/obj/item/radio/headset = "HEADSET",
			/obj/item/reagent_containers/glass/beaker = "BEAKER",
			/obj/item/reagent_containers/glass/bottle = "BOTTLE",
			/obj/item/reagent_containers/food/pill/patch = "PATCH",
			/obj/item/reagent_containers/food/pill = "PILL",
			/obj/item/reagent_containers/food/drinks = "DRINK",
			/obj/item/reagent_containers/food = "FOOD",
			/obj/item/reagent_containers/syringe = "SYRINGE",
			/obj/item/reagent_containers = "REAGENT_CONTAINERS",
			/obj/item/robot_parts = "ROBOT_PARTS",
			/obj/item/seeds = "SEED",
			/obj/item/slime_extract = "SLIME_CORE",
			/obj/item/stack/sheet/mineral = "MINERAL",
			/obj/item/stack/sheet = "SHEET",
			/obj/item/stack/tile = "TILE",
			/obj/item/stack = "STACK",
			/obj/item/stock_parts/cell = "POWERCELL",
			/obj/item/stock_parts = "STOCK_PARTS",
			/obj/item/storage/firstaid = "FIRSTAID",
			/obj/item/storage = "STORAGE",
			/obj/item/tank = "GAS_TANK",
			/obj/item/toy/crayon = "CRAYON",
			/obj/item/toy = "TOY",
			/obj/item = "ITEM",
			/obj/machinery/atmospherics = "ATMOS_MACH",
			/obj/machinery/computer = "CONSOLE",
			/obj/machinery/door/airlock = "AIRLOCK",
			/obj/machinery/door = "DOOR",
			/obj/machinery/kitchen_machine = "KITCHEN",
			/obj/machinery/atmospherics/portable/canister = "CANISTER",
			/obj/machinery/atmospherics/portable = "PORT_ATMOS",
			/obj/machinery/power = "POWER",
			/obj/machinery = "MACHINERY",
			/obj/mecha = "MECHA",
			/obj/structure/closet/crate = "CRATE",
			/obj/structure/closet = "CLOSET",
			/obj/structure/statue = "STATUE",
			/obj/structure/chair = "CHAIR", // oh no
			/obj/structure/bed = "BED",
			/obj/structure/chair/stool = "STOOL",
			/obj/structure/table = "TABLE",
			/obj/structure = "STRUCTURE",
			/obj/vehicle = "VEHICLE",
			/obj = "O",
			/datum = "D",
			/turf/simulated/floor = "SIM_FLOOR",
			/turf/simulated/wall = "SIM_WALL",
			/turf = "T",
			/mob/living/carbon/alien = "XENO",
			/mob/living/carbon/human = "HUMAN",
			/mob/living/carbon = "CARBON",
			/mob/living/silicon/robot = "CYBORG",
			/mob/living/silicon/ai = "AI",
			/mob/living/silicon = "SILICON",
			/mob/living/simple_animal/bot = "BOT",
			/mob/living/simple_animal = "SIMPLE",
			/mob/living = "LIVING",
			/mob = "M"
		)
		for(var/tn in TYPES_SHORTCUTS)
			if(copytext(typename, 1, length("[tn]/") + 1) == "[tn]/")
				typename = TYPES_SHORTCUTS[tn]+copytext(typename,length("[tn]/"))
				break
		.[typename] = type


/proc/get_fancy_list_of_atom_types()
	var/static/list/pre_generated_list
	if(!pre_generated_list) //init
		pre_generated_list = make_types_fancy(typesof(/atom))
	return pre_generated_list


/proc/get_fancy_list_of_datum_types()
	var/static/list/pre_generated_list
	if(!pre_generated_list) //init
		pre_generated_list = make_types_fancy(sortList(typesof(/datum) - typesof(/atom)))
	return pre_generated_list


/proc/filter_fancy_list(list/L, filter as text)
	var/list/matches = new
	for(var/key in L)
		var/value = L[key]
		if(findtext("[key]", filter) || findtext("[value]", filter))
			matches[key] = value
	return matches

//Key thing that stops lag. Cornerstone of performance in ss13, Just sitting here, in unsorted.dm.

//Increases delay as the server gets more overloaded,
//as sleeps aren't cheap and sleeping only to wake up and sleep again is wasteful
#define DELTA_CALC max(((max(TICK_USAGE, world.cpu) / 100) * max(Master.sleep_delta-1,1)), 1)

//returns the number of ticks slept
/proc/stoplag(initial_delay)
	if(!Master || !(Master.current_runlevel & RUNLEVELS_DEFAULT))
		sleep(world.tick_lag)
		return 1
	if(!initial_delay)
		initial_delay = world.tick_lag
	. = 0
	var/i = DS2TICKS(initial_delay)
	do
		. += CEILING(i*DELTA_CALC, 1)
		sleep(i*world.tick_lag*DELTA_CALC)
		i *= 2
	while(TICK_USAGE > min(TICK_LIMIT_TO_RUN, Master.current_ticklimit))

#undef DELTA_CALC

/*
 * This proc gets a list of all "points of interest" (poi's) that can be used by admins to track valuable mobs or atoms (such as the nuke disk).
 * @param mobs_only if set to TRUE it won't include locations to the returned list
 * @param skip_mindless if set to TRUE it will skip mindless mobs
 * @param force_include_bots if set to TRUE it will include bots even if skip_mindless is set to TRUE
 * @param force_include_cameras if set to TRUE it will include camera eyes even if skip_mindless is set to TRUE
 * @return returns a list with the found points of interest
*/
/proc/getpois(mobs_only = FALSE, skip_mindless = FALSE, force_include_bots = FALSE, force_include_cameras = FALSE)
	var/list/mobs = sortmobs()
	var/list/names = list()
	var/list/pois = list()
	var/list/namecounts = list()

	for(var/mob/M in mobs)
		if(skip_mindless && (!M.mind && !M.ckey))
			if(!(force_include_bots && isbot(M)) && !(force_include_cameras && istype(M, /mob/camera)))
				continue
		if(M.client && M.client.holder && M.client.holder.fakekey) //stealthmins
			continue
		var/name = M.name
		if(name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		if(M.real_name && M.real_name != M.name)
			name += " \[[M.real_name]\]"
		if(M.stat == DEAD)
			if(isobserver(M))
				name += " \[ghost\]"
			else
				name += " \[dead\]"
		pois[name] = M

	if(!mobs_only)
		for(var/atom/A in GLOB.poi_list)
			if(!A || !A.loc)
				continue
			var/name = A.name
			if(names.Find(name))
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
			pois[name] = A

	return pois

/proc/get_observers()
	var/list/ghosts = list()
	for(var/mob/dead/observer/M in GLOB.player_list) // for every observer with a client
		ghosts += M

	return ghosts

#define RANDOM_COLOUR (rgb(rand(0,255),rand(0,255),rand(0,255)))

/// This proc returns every player with a client who is not a ghost or a new_player
/proc/get_living_players(exclude_nonhuman = FALSE, exclude_offstation = FALSE)
	var/list/living_players = list()

	for(var/mob/living/M in GLOB.player_list)
		if(exclude_nonhuman && !ishuman(M))
			continue
		if(exclude_offstation && M.mind?.offstation_role)
			continue
		living_players += M

	return living_players

/proc/make_bit_triplet()
	var/list/num_sample  = list(1, 2, 3, 4, 5, 6, 7, 8, 9)
	var/result = 0
	for(var/i = 0, i < 3, i++)
		var/num = pick(num_sample)
		num_sample -= num
		result += (1 << num)
	return result

/proc/pixel_shift_dir(dir, amount_x = 32, amount_y = 32) //Returns a list with pixel_shift values that will shift an object's icon one tile in the direction passed.
	amount_x = min(max(0, amount_x), 32) //No less than 0, no greater than 32.
	amount_y = min(max(0, amount_x), 32)
	var/list/shift = list("x" = 0, "y" = 0)
	switch(dir)
		if(NORTH)
			shift["y"] = amount_y
		if(SOUTH)
			shift["y"] = -amount_y
		if(EAST)
			shift["x"] = amount_x
		if(WEST)
			shift["x"] = -amount_x
		if(NORTHEAST)
			shift = list("x" = amount_x, "y" = amount_y)
		if(NORTHWEST)
			shift = list("x" = -amount_x, "y" = amount_y)
		if(SOUTHEAST)
			shift = list("x" = amount_x, "y" = -amount_y)
		if(SOUTHWEST)
			shift = list("x" = -amount_x, "y" = -amount_y)

	return shift

/**
  * Returns a list of atoms in a location of a given type. Can be refined to look for pixel-shift.
  *
  * Arguments:
  * * loc - The atom to look in.
  * * type - The type to look for.
  * * check_shift - If true, will exclude atoms whose pixel_x/pixel_y do not match shift_x/shift_y.
  * * shift_x - If check_shift is true, atoms whose pixel_x is different to this will be excluded.
  * * shift_y - If check_shift is true, atoms whose pixel_y is different to this will be excluded.
  */
/proc/get_atoms_of_type(atom/loc, type, check_shift = FALSE, shift_x = 0, shift_y = 0)
	. = list()
	if(!loc)
		return
	for(var/a in loc)
		var/atom/A = a
		if(!istype(A, type))
			continue
		if(check_shift && !(A.pixel_x == shift_x && A.pixel_y == shift_y))
			continue
		. += A

/proc/pass()
	return

/atom/proc/Shake(pixelshiftx = 15, pixelshifty = 15, duration = 250)
	var/initialpixelx = pixel_x
	var/initialpixely = pixel_y
	var/shiftx = rand(-pixelshiftx,pixelshiftx)
	var/shifty = rand(-pixelshifty,pixelshifty)
	animate(src, pixel_x = pixel_x + shiftx, pixel_y = pixel_y + shifty, time = 0.2, loop = duration)
	pixel_x = initialpixelx
	pixel_y = initialpixely

/proc/params2turf(scr_loc, turf/origin, client/C)
	if(!scr_loc)
		return null
	var/tX = splittext(scr_loc, ",")
	var/tY = splittext(tX[2], ":")
	var/tZ = origin.z
	tY = tY[1]
	tX = splittext(tX[1], ":")
	tX = tX[1]
	var/list/actual_view = getviewsize(C ? C.view : world.view)
	tX = clamp(origin.x + text2num(tX) - round(actual_view[1] / 2) - 1, 1, world.maxx)
	tY = clamp(origin.y + text2num(tY) - round(actual_view[2] / 2) - 1, 1, world.maxy)
	return locate(tX, tY, tZ)

/proc/CallAsync(datum/source, proctype, list/arguments)
	set waitfor = FALSE
	return call(source, proctype)(arglist(arguments))

/proc/IsFrozen(atom/A)
	if(A in GLOB.frozen_atom_list)
		return TRUE
	return FALSE

// Check if the source atom contains another atom
/atom/proc/contains(atom/location)
	if(!location)
		return FALSE
	if(location == src)
		return TRUE

	return contains(location.loc)

/proc/log_connection(ckey, ip, cid, connection_type)
	ASSERT(connection_type in list(CONNECTION_TYPE_ESTABLISHED, CONNECTION_TYPE_DROPPED_IPINTEL, CONNECTION_TYPE_DROPPED_BANNED, CONNECTION_TYPE_DROPPED_INVALID))
	var/datum/db_query/query_accesslog = SSdbcore.NewQuery("INSERT INTO connection_log (`datetime`, `ckey`, `ip`, `computerid`, `result`, `server_id`) VALUES(Now(), :ckey, :ip, :cid, :result, :server_id)", list(
		"ckey" = ckey,
		"ip" = "[ip ? ip : ""]", // This is important. NULL is not the same as "", and if you directly open the `.dmb` file, you get a NULL IP.
		"cid" = cid,
		"result" = connection_type,
		"server_id" = GLOB.configuration.system.instance_id
	))
	query_accesslog.warn_execute()
	qdel(query_accesslog)

/**
  * Returns the clean name of an audio channel.
  *
  * Arguments:
  * * channel - The channel number.
  */
/proc/get_channel_name(channel)
	switch(channel)
		if(CHANNEL_LOBBYMUSIC)
			return "Lobby Music"
		if(CHANNEL_ADMIN)
			return "Admin MIDIs"
		if(CHANNEL_VOX)
			return "AI Announcements"
		if(CHANNEL_JUKEBOX)
			return "Dance Machines"
		if(CHANNEL_HEARTBEAT)
			return "Heartbeat"
		if(CHANNEL_BUZZ)
			return "White Noise"
		if(CHANNEL_AMBIENCE)
			return "Ambience"
		if(CHANNEL_ENGINE)
			return "Engine Ambience"
		if(CHANNEL_FIREALARM)
			return "Fire Alarms"
		if(CHANNEL_ASH_STORM)
			return "Ash Storms"
		if(CHANNEL_RADIO_NOISE)
			return "Radio Noise"
		if(CHANNEL_BOSS_MUSIC)
			return "Boss Music"
		// SS220 ADDITON START
		if(CHANNEL_TTS_LOCAL)
			return "TTS Local"
		if(CHANNEL_TTS_RADIO)
			return "TTS Radio"
		if(CHANNEL_CINEMATIC)
			return "Cinematic music"
		// SS220 ADDITION END

/proc/slot_bitfield_to_slot(input_slot_flags) // Kill off this garbage ASAP; slot flags and clothing flags should be IDENTICAL. GOSH DARN IT. Doesn't work with ears or pockets, either.
	switch(input_slot_flags)
		if(SLOT_FLAG_OCLOTHING)
			return SLOT_HUD_OUTER_SUIT
		if(SLOT_FLAG_ICLOTHING)
			return SLOT_HUD_JUMPSUIT
		if(SLOT_FLAG_GLOVES)
			return SLOT_HUD_GLOVES
		if(SLOT_FLAG_EYES)
			return SLOT_HUD_GLASSES
		if(SLOT_FLAG_MASK)
			return SLOT_HUD_WEAR_MASK
		if(SLOT_FLAG_HEAD)
			return SLOT_HUD_HEAD
		if(SLOT_FLAG_FEET)
			return SLOT_HUD_SHOES
		if(SLOT_FLAG_ID)
			return SLOT_HUD_WEAR_ID
		if(SLOT_FLAG_BELT)
			return SLOT_HUD_BELT
		if(SLOT_FLAG_BACK)
			return SLOT_HUD_BACK
		if(SLOT_FLAG_PDA)
			return SLOT_HUD_WEAR_PDA
		if(SLOT_FLAG_TIE)
			return SLOT_HUD_TIE


/**
  * HTTP Get (Powered by RUSTG)
  *
  * This proc should be used as a replacement for [world.Export()] due to an underlying issue with it.
  * See: https://www.byond.com/forum/post/2772166
  * The one thing you will need to be aware of is that this no longer wraps the response inside a "file", so anything that relies on a file2text() unwrap will need tweaking.
  * RUST HTTP also has better support for HTTPS as well as weird quirks with modern webservers.
  * Returns an assoc list that follows the standard [world.Export()] format (https://secure.byond.com/docs/ref/index.html#/world/proc/Export), with the above exception
  *
  * Arguments:
  * * url - URL to GET
  */
/proc/HTTPGet(url)
	var/datum/http_request/req = new()
	req.prepare(RUSTG_HTTP_METHOD_GET, url)
	req.begin_async()

	// Check if we are complete
	UNTIL(req.is_complete())
	var/datum/http_response/res = req.into_response()

	if(res.errored)
		. = list() // Return an empty list
		CRASH("Internal error during HTTP get: [res.error]")

	var/list/output = list()
	output["STATUS"] = res.status_code

	// Handle changes of line format. ASCII 13 = CR
	var/content = replacetext(res.body, "[ascii2text(13)]\n", "\n")
	output["CONTENT"] = content

	return output

/// Given a color in the format of "#RRGGBB", will return if the color is dark.
/proc/is_color_dark(color, threshold = 25)
	var/hsl = rgb2num(color, COLORSPACE_HSL)
	return hsl[3] < threshold
