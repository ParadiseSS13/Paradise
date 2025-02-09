/datum/radiation_wave
	/// The thing that spawned this radiation wave
	var/source
	/// The center of the wave
	var/turf/master_turf
	/// How far we've moved
	var/steps = 0
	/// How strong it was originaly
	var/intensity
	/// How much contaminated material it still has
	var/remaining_contam
	/// Higher than 1 makes it drop off faster, 0.5 makes it drop off half etc
	var/range_modifier
	/// The distance from the source point the wave can cover without losing any weight.
	var/source_radius
	/// The direction of movement
	var/move_dir
	/// The directions to the side of the wave, stored for easy looping
	var/list/__dirs
	/// Weights of the current tiles from left to right relative to the direction of travel
	var/list/weights = list(1)
	/// Sum of all weights
	var/weight_sum = 1
	/// Whether or not this radiation wave can create contaminated objects
	var/can_contaminate

/datum/radiation_wave/New(atom/_source, _intensity = 0)

	source = "[_source] \[[_source.UID()]\]"
	master_turf = get_turf(_source)
	intensity = _intensity
	START_PROCESSING(SSradiation, src)

/datum/radiation_wave/Destroy()
	. = QDEL_HINT_IWILLGC
	STOP_PROCESSING(SSradiation, src)
	..()


/// Deals with wave propagation. Radiation waves always expand in a 90 degree cone
/datum/radiation_wave/process()
	// If the wave is too weak to do anything
	if(weight_sum * intensity < RAD_BACKGROUND_RADIATION)
		qdel(src)
		return
	/// We start iteration from the top left corner of the current wave step
	master_turf = get_step(master_turf, NORTHWEST)
	if(!master_turf)
		qdel(src)
		return
	steps++
	var/list/new_weights = list()
	var/turf/current_turf = master_turf
	weight_sum = 0
	var/weight_left
	var/weight_center
	var/weight_right
	var/index
	var/walk_dir = EAST
	for(var/i = 0, i < 8 * steps, i++)
		index = (i % (2 * steps + 1)) + 1
		// Get weights for rear, right rear and left rear tiles if they were part of the previous step, where rear means towards the center
		weight_left = index > 2 ? weights[index - 2] : 0
		weight_center = (index > 1 && index < (2 * steps)) ? weights[index - 1] : 0
		weight_right = index <  (2 * steps + 1) ? weights[index] : 0
		// The weight of the current tile the average of the weights of the tiles we checked for earlier
		// And is reduced by irradiating things and getting blocked
		new_weights += radiate(current_turf, ((steps * 2 - 1) / (steps * 2 + 1)) * (weight_left + weight_center + weight_right) / (1 + ((index > 1) && index < (2 * steps + 1)) && (steps > 1)) + (index > 2 && index < (2 * steps)))
		weight_sum += new_weights[i]
		// turn when we reach a corner
		if(index == (2 * steps + 1))
			walk_dir = turn(dir, 90)
		// Advance to next turf and calculate the index on the edge
		current_turf = get_step(current_turf, walk_dir)

	weights = new_weights

/datum/radiation_wave/proc/check_obstructions(list/atoms)
	var/width = steps
	var/cmove_dir = move_dir
	if(cmove_dir == NORTH || cmove_dir == SOUTH)
		width--
	width = 1 + (2 * width)

	for(var/k in 1 to length(atoms))
		var/atom/thing = atoms[k]
		if(!thing)
			continue
		if(SEND_SIGNAL(thing, COMSIG_ATOM_RAD_WAVE_PASSING, src, width) & COMPONENT_RAD_WAVE_HANDLED)
			continue
		if(thing.rad_insulation != RAD_NO_INSULATION)
			intensity *= (1 - ((1 - thing.rad_insulation) / width))

/// Calls rad act on each relevant atom in the turf and returns the resulting weight for that tile after reduction by insulation
/datum/radiation_wave/proc/radiate(turf/current_turf, weight)
	var/list/turf_atoms = get_rad_contents(current_turf)
	for(var/k in turf_atoms)
		var/atom/thing = k
		if(QDELETED(thing))
			continue
		weight = weight * thing.rad_act(weight * intensity)
	// return the resulting weight if the radiation on the tile would end up greater than background
	return (((weight * intensity) > RAD_BACKGROUND_RADIATION) ? weight : 0)
