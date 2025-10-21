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

/*
* For getting coordinate signs from a direction define. I.E. NORTHWEST is (-1,1), SOUTH is (0,-1)
* Returns a length 2 list where the first value is the sign of x, and the second is the sign of y
*/
/proc/get_signs_from_direction(direction)
	var/x_sign = 1
	var/y_sign = 1
	x_sign = ((direction & EAST) ? 1 : -1)
	y_sign = ((direction & NORTH) ? 1 : -1)
	if(DIR_JUST_VERTICAL(direction))
		x_sign = 0
	if(DIR_JUST_HORIZONTAL(direction))
		y_sign = 0
	return list(x_sign, y_sign)

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

/// Angle between two arbitrary points and horizontal line same as [/proc/get_angle]
/proc/get_angle_raw(start_x, start_y, start_pixel_x, start_pixel_y, end_x, end_y, end_pixel_x, end_pixel_y)
	var/dy = (32 * end_y + end_pixel_y) - (32 * start_y + start_pixel_y)
	var/dx = (32 * end_x + end_pixel_x) - (32 * start_x + start_pixel_x)
	if(!dy)
		return (dx >= 0) ? 90 : 270
	. = arctan(dx/dy)
	if(dy < 0)
		. += 180
	else if(dx < 0)
		. += 360

// Returns location. Returns null if no location was found.
/proc/get_teleport_loc(turf/location, mob/target, distance = 1, density = TRUE, errorx = 0, errory = 0, eoffsetx = 0, eoffsety = 0)
	/*
	Location where the teleport begins, target that will teleport, distance to go, density checking 0/1(yes/no).
	Random error in tile placement x, error in tile placement y, and block offset.
	Block offset tells the proc how to place the box. Behind teleport location, relative to starting location, forward, etc.
	Negative values for offset are accepted, think of it in relation to North, -x is west, -y is south. Error defaults to positive.
	Turf and target are seperate in case you want to teleport some distance from a turf the target is not standing on or something.
	*/

	var/dirx = 0 // Generic location finding variable.
	var/diry = 0

	var/xoffset = 0 // Generic counter for offset location.
	var/yoffset = 0

	var/b1xerror = 0 // Generic placing for point A in box. The lower left.
	var/b1yerror = 0
	var/b2xerror = 0 // Generic placing for point B in box. The upper right.
	var/b2yerror = 0

	errorx = abs(errorx) // Error should never be negative.
	errory = abs(errory)

	switch(target.dir) // This can be done through equations but switch is the simpler method. And works fast to boot.
		// Directs on what values need modifying.
		if(NORTH)
			diry += distance
			yoffset += eoffsety
			xoffset += eoffsetx
			b1xerror -= errorx
			b1yerror -= errory
			b2xerror += errorx
			b2yerror += errory
		if(SOUTH)
			diry -= distance
			yoffset -= eoffsety
			xoffset += eoffsetx
			b1xerror -= errorx
			b1yerror -= errory
			b2xerror += errorx
			b2yerror += errory
		if(EAST)
			dirx += distance
			yoffset += eoffsetx // Flipped.
			xoffset += eoffsety
			b1xerror -= errory // Flipped.
			b1yerror -= errorx
			b2xerror += errory
			b2yerror += errorx
		if(WEST)
			dirx -= distance
			yoffset -= eoffsetx // Flipped.
			xoffset += eoffsety
			b1xerror -= errory // Flipped.
			b1yerror -= errorx
			b2xerror += errory
			b2yerror += errorx

	var/turf/destination = locate(location.x + dirx, location.y + diry, location.z)

	if(!destination)
		return

	if(!errorx && !errory)
		if(density && destination.density)
			return
		if(destination.x > world.maxx || destination.x < 1 || destination.y > world.maxy || destination.y < 1)
			return
		return destination

	var/list/destination_list = list()

	/*
	This will draw a block around the target turf, given what the error is.
	Specifying `errorx` and `errory` will basically draw a different sort of block.
	If the values are the same, it will be a square. If they are different, it will be a rectengle.
	In either case, it will center based on offset. Offset is position from center.
	Offset always calculates in relation to direction faced. In other words, depending on the direction of the teleport,
	the offset should remain positioned in relation to destination.
	*/
	var/turf/center = locate((destination.x + xoffset), (destination.y + yoffset), location.z) // So now, find the new center.

	// Now to find a box from center location and make that our destination.
	for(var/turf/T in block(center.x + b1xerror, center.y + b1yerror, location.z, center.x + b2xerror, center.y + b2yerror, location.z))
		if(density && T.density)
			continue
		if(T.x > world.maxx || T.x < 1 || T.y > world.maxy || T.y < 1)
			continue // Don't want them to teleport off the map.
		destination_list += T
	if(!length(destination_list))
		return
	return pick(destination_list)


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

/////////////////////////////////////////////////////////////////////////

/**
 * Get a list of turfs in a line from `starting_atom` to `ending_atom`.
 *
 * Uses the ultra-fast [Bresenham Line-Drawing Algorithm](https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm).
 */
/proc/get_line(atom/starting_atom, atom/ending_atom)
	var/current_x_step = starting_atom.x//start at x and y, then add 1 or -1 to these to get every turf from starting_atom to ending_atom
	var/current_y_step = starting_atom.y
	var/starting_z = starting_atom.z

	var/list/line = list(get_turf(starting_atom))
	var/x_distance = ending_atom.x - current_x_step //x distance
	var/y_distance = ending_atom.y - current_y_step

	var/abs_x_distance = abs(x_distance)//Absolute value of x distance
	var/abs_y_distance = abs(y_distance)

	var/x_distance_sign = SIGN(x_distance) //Sign of x distance (+ or -)
	var/y_distance_sign = SIGN(y_distance)

	var/x = abs_x_distance >> 1 //Counters for steps taken, setting to distance/2
	var/y = abs_y_distance >> 1 //Bit-shifting makes me l33t.  It also makes get_line() unnessecarrily fast.

	if(abs_x_distance >= abs_y_distance) //x distance is greater than y
		for(var/distance_counter in 0 to (abs_x_distance - 1))//It'll take abs_x_distance steps to get there
			y += abs_y_distance

			if(y >= abs_x_distance) //Every abs_y_distance steps, step once in y direction
				y -= abs_x_distance
				current_y_step += y_distance_sign

			current_x_step += x_distance_sign //Step on in x direction
			line += locate(current_x_step, current_y_step, starting_z)//Add the turf to the list
	else
		for(var/distance_counter in 0 to (abs_y_distance - 1))
			x += abs_x_distance

			if(x >= abs_y_distance)
				x -= abs_y_distance
				current_x_step += x_distance_sign

			current_y_step += y_distance_sign
			line += locate(current_x_step, current_y_step, starting_z)
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
	if(ISEVEN(f)) //Ensure the last digit is an odd number
		f += 1
	return f

//Turns 1479 into 147.9
/proc/format_frequency(f)
	return "[round(f / 10)].[f % 10]"

//Picks a string of symbols to display as the law number for hacked or ion laws
/proc/ionnum()
	return "[pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")]"

// Selects an unlinked borg, used in the robot upload console
/proc/freeborg(mob/user)
	var/select
	var/list/borgs = list()
	for(var/mob/living/silicon/robot/A in GLOB.player_list)
		if(A.stat == DEAD || A.connected_ai || A.scrambledcodes || isdrone(A))
			continue
		var/name = "[A.real_name] ([A.modtype] [A.braintype])"
		borgs[name] = A

	if(length(borgs))
		select = tgui_input_list(user, "Unshackled borg signals detected:", "Borg selection", borgs)
		return borgs[select]

//When a borg is activated, it can choose which AI it wants to be slaved to
/proc/active_ais()
	. = list()
	for(var/mob/living/silicon/ai/A in GLOB.ai_list)
		if(A.stat == DEAD)
			continue
		if(A.control_disabled)
			continue
		. += A

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
	if(!length(ais))
		return
	if(user)
		return tgui_input_list(user, "AI signals detected:", "AI selection", ais)
	else
		return pick(ais)

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
	for(var/mob/living/brain/M in sortmob)
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
		if(!istype(M, /mob/living/simple_animal/slime))
			moblist.Add(M)
	for(var/mob/living/basic/M in sortmob)
		moblist.Add(M)
	for(var/mob/camera/blob/M in sortmob)
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
	if(units < 1000) // Less than a kJ
		return "[round(units, 0.1)] J"
	else if(units < 1000000) // Less than a MJ
		return "[round(units * 0.001, 0.01)] kJ"
	else if(units < 1000000000) // Less than a GJ
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
	var/atom/current = M
	while(current?.loc && !isturf(current.loc))
		current = current.loc
		if(stop_type && istype(current, stop_type))
			break
	return current

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


/// Returns the turf located at the map edge in the specified direction relative to target_atom used for mass driver
/proc/get_edge_target_turf(atom/target_atom, direction)
	if(!target_atom)
		return FALSE
	var/turf/target = get_turf(target_atom)
	if(!target)
		return FALSE
		//since NORTHEAST == NORTH|EAST, etc, doing it this way allows for diagonal mass drivers in the future
		//and isn't really any more complicated

	var/x = target_atom.x
	var/y = target_atom.y
	if(direction & NORTH)
		y = world.maxy
	else if(direction & SOUTH) //you should not have both NORTH and SOUTH in the provided direction
		y = 1
	if(direction & EAST)
		x = world.maxx
	else if(direction & WEST)
		x = 1
	if(IS_DIR_DIAGONAL(direction)) //let's make sure it's accurately-placed for diagonals
		var/lowest_distance_to_map_edge = min(abs(x - target_atom.x), abs(y - target_atom.y))
		return get_ranged_target_turf(target_atom, direction, lowest_distance_to_map_edge)
	return locate(x, y, target_atom.z)

/** returns turf relative to A in given direction at set range
// result is bounded to map size
// note range is non-pythagorean
// used for disposal system
*/
/proc/get_ranged_target_turf(atom/target_atom, direction, range)

	var/x = target_atom.x
	var/y = target_atom.y
	if(direction & NORTH)
		y = min(world.maxy, y + range)
	else if(direction & SOUTH)
		y = max(1, y - range)
	if(direction & EAST)
		x = min(world.maxx, x + range)
	else if(direction & WEST) //if you have both EAST and WEST in the provided direction, then you're gonna have issues
		x = max(1, x - range)

	return locate(x, y, target_atom.z)

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

// returns turf relative to A for a given clockwise angle at set range
// result is bounded to map size
/proc/get_angle_target_turf(atom/A, angle, range)
	if(!istype(A))
		return null
	var/x = A.x
	var/y = A.y

	x += range * sin(angle)
	y += range * cos(angle)

	//Restricts to map boundaries while keeping the final angle the same
	var/dx = A.x - x
	var/dy = A.y - y
	var/ratio
	if(dy == 0) //prevents divide-by-zero errors
		ratio = INFINITY
	else
		ratio = dx / dy

	if(x < 1)
		y += (1 - x) / ratio
		x = 1
	else if(x > world.maxx)
		y += (world.maxx - x) / ratio
		x = world.maxx

	if(y < 1)
		x += (1 - y) * ratio
		y = 1
	else if(y > world.maxy)
		x += (world.maxy - y) * ratio
		y = world.maxy

	return locate(round(x, 1), round(y, 1), A.z)

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
		if(length(part.contents) && searchDepth)
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
				return FALSE
			if(IS_OPAQUE_TURF(current))
				return FALSE
			current = get_step_towards(current, target_turf)
			steps++

	return TRUE

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

	var/list/areas = list()
	for(var/area/N in world)
		if(istype(N, areatype)) areas += N
	return areas

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all turfs in areas of that type of that type in the world.
/proc/get_area_turfs(areatype)
	if(!areatype)
		return
	if(istext(areatype))
		areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/turfs = list()
	for(var/area/N as anything in GLOB.all_areas)
		if(istype(N, areatype))
			for(var/turf/T in N)
				turfs += T
	return turfs

/// Simple datum for storing coordinates.
/datum/coords
	var/x_pos
	var/y_pos
	var/z_pos

/datum/coords/New(x_pos_, y_pos_, z_pos_)
	x_pos = x_pos_
	y_pos = y_pos_
	z_pos = z_pos_

/datum/coords/proc/to_string(z = null)
	return "([x_pos],[y_pos],[z ? z : z_pos])"

/area/proc/move_contents_to(area/A, turf_to_leave, direction) // someone rewrite this function i beg of you
	//Takes: Area. Optional: turf type to leave behind.
	//Returns: Nothing.
	//Notes: Attempts to move the contents of one area to another area.
	//       Movement based on lower left corner. Tiles that do not fit
	//		 into the new area will not be moved.

	if(!A || !src) return 0

	var/list/turfs_src = get_area_turfs(type)
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

	var/list/refined_src = list()
	for(var/turf/T in turfs_src)
		refined_src += T
		refined_src[T] = new/datum/coords
		var/datum/coords/C = refined_src[T]
		C.x_pos = (T.x - src_min_x)
		C.y_pos = (T.y - src_min_y)

	var/list/refined_trg = list()
	for(var/turf/T in turfs_trg)
		refined_trg += T
		refined_trg[T] = new/datum/coords
		var/datum/coords/C = refined_trg[T]
		C.x_pos = (T.x - trg_min_x)
		C.y_pos = (T.y - trg_min_y)

	var/list/from_update = list()
	var/list/to_update = list()

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
					X.icon = old_icon1 // Shuttle floors are in shuttle.dmi while the defaults are floors.dmi

					// Give the new turf our air, if simulated
					if(issimulatedturf(X) && issimulatedturf(T))
						var/datum/milla_safe/area_move_transrer_gas/milla = new()
						milla.invoke_async(T, X)

					// Quick visual fix for some weird shuttle corner artefacts when on transit space tiles
					if(direction && findtext(X.icon_state, "swall_s"))
						// Spawn a new shuttle corner object
						var/obj/corner = new
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
							X.icon_state = replacetext(O.icon_state, "_f", "_s") // Revert the turf to the old icon_state
							X.name = "wall"
							qdel(O) // Prevents multiple shuttle corners from stacking
							continue

						if(QDELETED(O))
							continue

						O.loc.Exited(O)
						O.set_loc(X)
						O.loc.Entered(O)

					for(var/mob/M in T)
						if(!M.move_on_shuttle)
							continue
						M.loc = X

					to_update += X

					if(turf_to_leave)
						from_update += T.ChangeTurf(turf_to_leave)
					else
						T.ChangeTurf(T.baseturf)

					refined_src -= T
					refined_trg -= B
					continue moving

/datum/milla_safe/area_move_transrer_gas

/datum/milla_safe/area_move_transrer_gas/on_run(turf/source, turf/target)
	get_turf_air(target).copy_from(get_turf_air(source))

/proc/DuplicateObject(obj/original, perfectcopy = 0, sameloc = 0, atom/newloc)
	if(!original)
		return

	var/obj/O

	if(sameloc)
		O = new original.type(original.loc)
	else
		O = new original.type(newloc)

	if(perfectcopy)
		if(O && original)
			var/static/list/forbidden_vars = list("type", "loc", "locs", "vars", "parent", "parent_type", "pixloc", "verbs", "ckey", "key", "power_supply", "contents", "reagents", "stat", "x", "y", "z", "group", "comp_lookup", "datum_components")

			for(var/V in original.vars - forbidden_vars)
				if(islist(original.vars[V]))
					var/list/L = original.vars[V]
					O.vars[V] = L.Copy()
				else if(istype(original.vars[V], /datum))
					continue // This would reference the original's object, that will break when it is used or deleted.
				else
					O.vars[V] = original.vars[V]
	if(istype(O))
		O.update_icon()
	return O

/area/proc/copy_contents_to(area/A, platingRequired = FALSE, perfect_copy = TRUE)
	//Takes: Area. Optional: If it should copy to areas that don't have plating
	//Returns: List containing copied objects or `FALSE` if source/target area are null.
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

	var/list/refined_src = list()
	for(var/turf/T in turfs_src)
		refined_src += T
		refined_src[T] = new/datum/coords
		var/datum/coords/C = refined_src[T]
		C.x_pos = (T.x - src_min_x)
		C.y_pos = (T.y - src_min_y)

	var/list/refined_trg = list()
	for(var/turf/T in turfs_trg)
		refined_trg += T
		refined_trg[T] = new/datum/coords
		var/datum/coords/C = refined_trg[T]
		C.x_pos = (T.x - trg_min_x)
		C.y_pos = (T.y - trg_min_y)

	var/list/to_update = list()
	var/list/copied_objects = list()

	moving:
		for(var/turf/T in refined_src)
			var/datum/coords/C_src = refined_src[T]

			for(var/turf/B in refined_trg)
				var/datum/coords/C_trg = refined_trg[B]

				if(C_src.x_pos == C_trg.x_pos && C_src.y_pos == C_trg.y_pos)
					if(platingRequired && isspaceturf(B))
						continue moving

					var/old_dir1 = T.dir
					var/old_icon_state1 = T.icon_state
					var/old_icon1 = T.icon

					var/turf/X = new T.type(B)
					X.dir = old_dir1
					X.icon_state = old_icon_state1
					X.icon = old_icon1 // Shuttle floors are in shuttle.dmi while the defaults are floors.dmi

					var/list/newobjs = list()
					var/list/newmobs = list()

					for(var/obj/O in T)
						newobjs += DuplicateObject(O, perfect_copy, FALSE, X)

					for(var/mob/M in T)
						if(!M.move_on_shuttle)
							continue
						newmobs += DuplicateObject(M, TRUE, FALSE, X)

					copied_objects += newobjs
					copied_objects += newmobs

					for(var/V in T.vars)
						if(!(V in list(
							"ckey",
							"comp_lookup",
							"contents",
							"destination_x",
							"destination_y",
							"destination_z",
							"group",
							"key",
							"loc",
							"locs",
							"luminosity",
							"parent_type",
							"parent",
							"pixloc",
							"signal_procs",
							"type",
							"vars",
							"verbs",
							"x",
							"y",
							"z",
						)))
							X.vars[V] = T.vars[V]

					to_update += X

					refined_src -= T
					refined_trg -= B
					continue moving

	return copied_objects


/proc/get_cardinal_dir(atom/A, atom/B)
	var/dx = abs(B.x - A.x)
	var/dy = abs(B.y - A.y)
	return get_dir(A, B) & (rand() * (dx+dy) < dy ? 3 : 12)

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
	switch(zone)
		if("r_hand")
			return "right hand"
		if("l_hand")
			return "left hand"
		if("r_arm")
			return "right arm"
		if("l_arm")
			return "left arm"
		if("r_foot")
			return "right foot"
		if("l_foot")
			return "left foot"
		if("r_leg")
			return "right leg"
		if("l_leg")
			return "left leg"
		else
			return zone

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
	var/icon/AM_icon = icon(AM.icon, AM.icon_state)
	var/AM_icon_height = AM_icon.Height()
	var/AM_icon_width = AM_icon.Width()
	if(AM_icon_height != world.icon_size || AM_icon_width != world.icon_size)
		pixel_x_offset += ((AM_icon_height / world.icon_size) - 1) * (world.icon_size * 0.5)
		pixel_y_offset += ((AM_icon_width / world.icon_size) - 1) * (world.icon_size * 0.5)

	//DY and DX
	var/rough_x = round(round(pixel_x_offset, world.icon_size) / world.icon_size)
	var/rough_y = round(round(pixel_y_offset, world.icon_size) / world.icon_size)

	//Find coordinates
	var/turf/T = get_turf(AM) //use AM's turfs, as it's coords are the same as AM's AND AM's coords are lost if it is inside another atom
	if(!T)
		return null
	var/final_x = T.x + rough_x
	var/final_y = T.y + rough_y

	if(final_x || final_y)
		return locate(final_x, final_y, T.z)

/proc/get(atom/loc, type)
	while(loc)
		if(istype(loc, type))
			return loc
		loc = loc.loc
	return null

//For objects that should embed, but make no sense being sharp or is_pointed()
//e.g: rods
GLOBAL_LIST_INIT(can_embed_types, typecacheof(list(
	/obj/item/stack/rods,
	/obj/item/pipe)))

/proc/can_embed(obj/item/W)
	if(W.sharp)
		return TRUE
	if(is_pointed(W))
		return TRUE

	if(is_type_in_typecache(W, GLOB.can_embed_types))
		return TRUE

/*
Checks if that loc and dir has a item on the wall
*/
GLOBAL_LIST_INIT(wall_items, typecacheof(list(/obj/machinery/power/apc, /obj/machinery/alarm,
	/obj/item/radio/intercom, /obj/structure/extinguisher_cabinet, /obj/structure/reagent_dispensers/peppertank,
	/obj/machinery/status_display, /obj/machinery/requests_console, /obj/structure/sign,
	/obj/machinery/newscaster, /obj/machinery/firealarm, /obj/structure/noticeboard, /obj/machinery/door_control,
	/obj/machinery/computer/security/telescreen, /obj/machinery/airlock_controller,
	/obj/item/storage/secure/safe, /obj/machinery/door_timer, /obj/machinery/flasher, /obj/machinery/keycard_auth,
	/obj/structure/mirror, /obj/structure/closet/fireaxecabinet, /obj/machinery/computer/security/telescreen/entertainment,
	/obj/structure/sign, /obj/machinery/barsign, /obj/machinery/light, /obj/machinery/light_construct)))

/proc/gotwallitem(loc, dir)
	for(var/obj/O in loc)
		if(is_type_in_typecache(O, GLOB.wall_items) && dir == O.dir)
			return TRUE

	// Some stuff is placed directly on the wallturf (signs)
	for(var/obj/O in get_step(loc, dir))
		if(is_type_in_typecache(O, GLOB.wall_items))
			return TRUE
	return FALSE

/proc/atan2(x, y)
	if(!x && !y) return 0
	return y >= 0 ? arccos(x / sqrt(x * x + y * y)) : -arccos(x / sqrt(x * x + y * y))

/proc/format_text(text)
	return replacetext(replacetext(text,"\proper ",""),"\improper ","")

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

	var/atom/found

	while(length(processing_list) && isnull(found))
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
		if(istype(O, /obj/machinery/power/rad_collector))
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

	while(c_dist <= dist)
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

/proc/pick_closest_path(value, list/matches = get_fancy_list_of_atom_types(), skip_filter = FALSE)
	if(!skip_filter)
		if(!value) //nothing should be calling us with a number, so this is safe
			value = input("Enter type to find (blank for all, cancel to cancel)", "Search for type") as null|text
			if(isnull(value))
				return
		value = trim(value)
		if(!isnull(value) && value != "")
			matches = filter_fancy_list(matches, value)

		if(!length(matches))
			return

	var/chosen
	if(length(matches) == 1)
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
			/obj/item/bio_chip = "BIO_CHIP",
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
			/obj/item/reagent_containers/patch = "PATCH",
			/obj/item/reagent_containers/pill = "PILL",
			/obj/item/reagent_containers/drinks = "DRINK",
			/obj/item/food = "FOOD",
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
			/datum/station_goal/secondary = "S_GOAL",
			/datum/station_goal = "GOAL",
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
	var/list/matches = list()
	for(var/key in L)
		var/value = L[key]
		if(findtext("[key]", filter) || findtext("[value]", filter))
			matches[key] = value
	return matches

/proc/return_typenames(type)
	return splittext("[type]", "/")

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
	var/list/num_sample = list(1, 2, 3, 4, 5, 6, 7, 8, 9)
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

/atom/proc/Shake(pixelshiftx = 15, pixelshifty = 15, duration = 250)
	var/initialpixelx = pixel_x
	var/initialpixely = pixel_y
	var/shiftx = rand(-pixelshiftx,pixelshiftx)
	var/shifty = rand(-pixelshifty,pixelshifty)
	animate(src, pixel_x = pixel_x + shiftx, pixel_y = pixel_y + shifty, time = 0.2, loop = duration)
	pixel_x = initialpixelx
	pixel_y = initialpixely

/// Returns a turf based on text inputs, original turf and viewing client
/proc/parse_caught_click_modifiers(list/modifiers, turf/origin, client/viewing_client)
	if(!modifiers)
		return

	var/screen_loc = splittext(modifiers["screen-loc"], ",")
	var/list/actual_view = getviewsize(viewing_client ? viewing_client.view : world.view)
	var/click_turf_x = splittext(screen_loc[1], ":")
	var/click_turf_y = splittext(screen_loc[2], ":")
	var/click_turf_z = origin.z

	var/click_turf_px = text2num(click_turf_x[2])
	var/click_turf_py = text2num(click_turf_y[2])
	click_turf_x = origin.x + text2num(click_turf_x[1]) - round(actual_view[1] / 2) - 1
	click_turf_y = origin.y + text2num(click_turf_y[1]) - round(actual_view[2] / 2) - 1

	var/turf/click_turf = locate(clamp(click_turf_x, 1, world.maxx), clamp(click_turf_y, 1, world.maxy), click_turf_z)
	LAZYSET(modifiers, "icon-x", "[(click_turf_px - click_turf.pixel_x) + ((click_turf_x - click_turf.x) * world.icon_size)]")
	LAZYSET(modifiers, "icon-y", "[(click_turf_py - click_turf.pixel_y) + ((click_turf_y - click_turf.y) * world.icon_size)]")
	return click_turf

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
	var/datum/db_query/query_accesslog = SSdbcore.NewQuery("INSERT INTO connection_log (`datetime`, `ckey`, `ip`, `computerid`, `result`, `server_id`) VALUES(Now(), :ckey, INET_ATON(:ip), :cid, :result, :server_id)", list(
		"ckey" = ckey,
		"ip" = "[ip ? ip : "127.0.0.1"]",
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
		if(CHANNEL_GENERAL)
			return "General Sounds"
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
			return "Weather"
		if(CHANNEL_RADIO_NOISE)
			return "Radio Noise"
		if(CHANNEL_BOSS_MUSIC)
			return "Boss Music"
		if(CHANNEL_SURGERY_SOUNDS)
			return "Surgery Sounds"

/**
  * HTTP Get (Powered by rustlibs)
  *
  * This proc should be used as a replacement for [/world/proc/Export] due to an underlying issue with it.
  * See: https://www.byond.com/forum/post/2772166
  * The one thing you will need to be aware of is that this no longer wraps the response inside a "file", so anything that relies on a file2text() unwrap will need tweaking.
  * RUST HTTP also has better support for HTTPS as well as weird quirks with modern webservers.
  * Returns an assoc list that follows the standard [/world/proc/Export] format (https://secure.byond.com/docs/ref/index.html#/world/proc/Export), with the above exception
  *
  * Arguments:
  * * url - URL to GET
  */
/proc/HTTPGet(url)
	var/datum/http_request/req = new
	req.prepare(RUSTLIBS_HTTP_METHOD_GET, url)
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

/**
 * This proc takes a list of types, and returns them in the format below.
 * [type] = amount of type in list.
 * Useful for recipes.
 */
/proc/type_list_to_counted_assoc_list(list/origin_list)
	var/list/return_list = list()
	for(var/datum/path as anything in origin_list)
		if(isdatum(path))
			path = path.type
		if(!return_list[path])
			return_list[path] = 0
		return_list[path] += 1
	return return_list

// Wrappers for BYOND default procs which can't directly be called by call().
/proc/_step(ref, dir)
	step(ref, dir)
