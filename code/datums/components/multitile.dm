///Lets multitile objects have dense walls around them based on the coordinate map
/datum/component/multitile
	///Reference to all fillers
	var/list/all_fillers = list()

/*
  * These should all be done in this style. It represents a coordinate map of the grid around `src`.
  * The src itself should always have no density, as the density should be set on the atom and not with a filler
  * list(
		list(0, 0, 0,		   0, 0),
		list(0, 0, 0,		   0, 0),
		list(0, 0, MACH_CENTER, 0, 0),
		list(0, 0, 0,		   0, 0),
		list(0, 0, 0,		   0, 0)
	)
 */

//distance_from_center does not include src itself
/datum/component/multitile/Initialize(new_filler_map)
	if(!length(new_filler_map))
		return COMPONENT_INCOMPATIBLE

	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/max_height = length(new_filler_map)
	var/max_width = length(new_filler_map[1]) //it should have the same length on every row

	var/offset_x = 0
	var/offset_y = 0

	var/atom/owner = parent

	for(var/i in 1 to length(new_filler_map))
		if(length(new_filler_map[i] != max_width))
			stack_trace("A multitile component was passed a list wich did not have the same length every row. Atom parent is: [parent]")
			var/obj/machinery/machine = parent
			machine.deconstruct()
			return COMPONENT_INCOMPATIBLE

		for(var/j in 1 to length(new_filler_map[i]))
			if(new_filler_map[i][j] == MACH_CENTER)
				offset_x = j - ((length(new_filler_map[i]) + 1) / 2)
				offset_y = i - ((length(new_filler_map) + 1) / 2)

	var/distance_from_center_x = (max_width - 1) / 2
	var/distance_from_center_y = (max_height - 1) / 2

	if(owner.x - offset_x + distance_from_center_x > world.maxx || owner.x + offset_x - distance_from_center_x < 1)
		var/obj/machinery/machine = parent
		machine.deconstruct()
		return COMPONENT_INCOMPATIBLE

	if(owner.y + offset_y + distance_from_center_y > world.maxy || owner.y - offset_y - distance_from_center_y < 1)
		var/obj/machinery/machine = parent
		machine.deconstruct()
		return COMPONENT_INCOMPATIBLE

	var/current_height = 0
	var/current_width = 1
	var/tile_index = 1

	for(var/turf/filler_turf as anything in block( 
	owner.x - offset_x - distance_from_center_x, owner.y + offset_y - distance_from_center_y, owner.z,
	owner.x - offset_x + distance_from_center_x, owner.y + offset_y + distance_from_center_y, owner.z,
	))
		//Last check is for filler row lists of length 1.
		if(new_filler_map[max_height - current_height][current_width] == 1) // Because the `block()` proc always works from the bottom left to the top right, we have to loop through our list in reverse
			var/obj/structure/filler/new_filler = new(filler_turf)
			all_fillers += new_filler
		current_width += 1
		tile_index++
		if(tile_index % max_width == 1)
			current_height += 1
			current_width = 1
			if(current_height == max_height)
				break

/datum/component/multitile/Destroy(force, silent)
	QDEL_LIST_CONTENTS(all_fillers)
	return ..()
