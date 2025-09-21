GLOBAL_LIST_INIT(turf_rad_item_cache, list("[ALPHA_RAD]" = list(), "[BETA_RAD]" = list(), "[GAMMA_RAD]" = list()))
#define WRAP_INDEX(index, length)((index - 1) % length + 1)

/datum/radiation_wave
	/// The thing that spawned this radiation wave
	var/source
	/// The top left corner of the wave, from which we begin iteration on a step
	var/turf/master_turf
	/// How far we've moved
	var/steps = 0
	/// The strength at the origin. Multiplied by the weight of a tile to determine the strength of radiation there.
	var/intensity
	/// The direction of movement
	var/move_dir
	/// The directions to the side of the wave, stored for easy looping
	var/list/__dirs
	/// Weights of the current tiles in the step going clockwise from the top left corner. Starts as one tile with a weight of 1
	var/list/weights = list(1)
	/// Sum of all weights
	var/weight_sum = 1
	/// The type of particle emitted
	var/emission_type = ALPHA_RAD

/datum/radiation_wave/New(atom/_source, _intensity = 0, _emission_type = ALPHA_RAD)

	source = _source
	master_turf = get_turf(_source)
	intensity = _intensity
	emission_type = _emission_type
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
	var/offset
	var/walk_dir = EAST
	var/ratio = steps > 1 ? (steps - 1) / steps : (1 / 8)
	var/weight_length = length(weights)
	// Iterate around the periphery of a square for each step
	for(var/i in 0 to (8 * steps - 1))
		// our index along the edge we are on, each corner starts a new edge.
		index = (i % (2 * steps)) + 1
		// Get weights for rear, right rear and left rear tiles if they were part of the previous step, where rear means towards the center and left and right are along the edge we are on
		weight_left = index > 2 ? weights[WRAP_INDEX((index + offset - 2), weight_length)] : 0
		weight_center = index > 1 ? weights[WRAP_INDEX((index + offset - 1), weight_length)] : 0
		weight_right = index < (2 * steps) ? weights[WRAP_INDEX((index + offset), weight_length)] : 0
		// The weight of the current tile the average of the weights of the tiles we checked for earlier
		// And is reduced by irradiating things and getting blocked
		if(current_turf && (weight_left + weight_center + weight_right))
			new_weights += radiate(source, current_turf, (ratio) * (weight_left + weight_center + weight_right) / ((1 + (index > 1 && index < (2 * steps + 1) && steps > 1) + (index > 2 && index < (2 * steps)))), emission_type)
		else
			new_weights += 0
		weight_sum += new_weights[i + 1]
		// Advance to next turf
		current_turf = get_step(current_turf, walk_dir)
		// If we reached a corner turn to the right
		if(index == (2 * steps))
			walk_dir = turn(walk_dir, -90)
			offset += 2 * (steps - 1)

	weights = new_weights

/// Calls rad act on each relevant atom in the turf and returns the resulting weight for that tile after reduction by insulation
/datum/radiation_wave/proc/radiate(atom/source, turf/current_turf, weight, emission_type)
	// populate cache if needed
	if(!GLOB.turf_rad_item_cache["[emission_type]"][current_turf])
		GLOB.turf_rad_item_cache["[emission_type]"][current_turf] = get_rad_contents(current_turf, emission_type)

	var/list/turf_atoms = GLOB.turf_rad_item_cache["[emission_type]"][current_turf]
	for(var/k in turf_atoms)
		var/atom/thing = k
		if(QDELETED(thing))
			continue
		weight = weight * thing.base_rad_act(source ,weight * intensity, emission_type)
	// return the resulting weight if the radiation on the tile would end up greater than background
	return (((weight * intensity) > RAD_BACKGROUND_RADIATION) ? weight : 0)

#undef WRAP_INDEX
