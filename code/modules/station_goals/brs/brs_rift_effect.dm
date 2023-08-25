/obj/effect/abstract/bluespace_rift
	name = "Неопознанный блюспейс разлом"
	desc = "Аномальное образование с неизвестными свойствами."
	icon = 'icons/obj/engines_and_power/singularity.dmi'
	icon_state = "singularity_fog"
	appearance_flags = 0
	layer = MASSIVE_OBJ_LAYER
	invisibility = INVISIBILITY_ANOMALY
	level = 1 // t-ray scaners show only things with level = 1
	luminosity = 1
	alpha = 180
	var/size
	var/time_per_tile

	var/max_scanner_overload_range = 9
	var/min_scanner_overload_range = 1

	// How often scanner overload range changes.
	var/max_range_update_interval = 120 SECONDS
	var/min_range_update_interval = 30 SECONDS

	/// z-level the rift object should remain on.
	var/rift_z
	/// World time when the next step should happen.
	var/next_step
	/// An object on the map (turf, mob, etc.)
	var/atom/target_loc

	var/scanner_overload_range = 0
	var/range_update_time = 0

/obj/effect/abstract/bluespace_rift/Initialize(mapload, size, time_per_tile)
	. = ..()

	if(!isnull(loc))
		// Most likely admin-spawned, it won't work that way.
		return INITIALIZE_HINT_QDEL

	if(!size || !time_per_tile)
		CRASH("Missing arguments")

	src.size = size
	src.time_per_tile = time_per_tile

	next_step = 0
	rift_z = level_name_to_num(MAIN_STATION)

	check_z()
	change_direction()

	GLOB.poi_list |= src

	// resize
	var/matrix/new_transform = matrix()
	new_transform.Scale(size)
	transform = new_transform

	// repaint
	color = rand_hex_color()

	// assign a name
	name = "Блюспейс разлом [pick(GLOB.greek_letters)] [pick(GLOB.greek_letters)] \Roman[rand(1,10)]"

/obj/effect/abstract/bluespace_rift/Destroy()
	GLOB.poi_list.Remove(src)
	return ..()

/** Movement processing, must be called from `process` function. */
/obj/effect/abstract/bluespace_rift/proc/move()

	// Check rift z level
	check_z()

	// Check if the target is still reachable
	if(QDELETED(target_loc) || (target_loc.z != rift_z))
		change_direction()

	// Move the object by the required steps
	var/iterations = 0
	while(next_step < world.time)

		// Safety check against infinite loop
		if(iterations > 10)
			next_step = world.time + time_till_next_step()
			break
		iterations++

		// The actual step
		forceMove(get_step_towards(src, target_loc))
		next_step += time_till_next_step()
		
		if(is_target_reached())
			change_direction()

	// Update scanner overload range
	if(range_update_time < world.time)
		scanner_overload_range = rand(min_scanner_overload_range, max_scanner_overload_range)
		range_update_time = world.time + rand(min_range_update_interval, max_range_update_interval)

/** Returns `TRUE` if the rift is close to a singularity or tesla, `FLASE` otherwise. 
	Use this before doing anything destructive.
*/
/obj/effect/abstract/bluespace_rift/proc/is_close_to_singularity(radius = 15)
	for(var/singularity in GLOB.singularities)
		if(!atoms_share_level(src, singularity))
			continue
		if(get_dist(src, singularity) <= radius)
			return TRUE
	return FALSE

/** Check if the object is on the right z-level. If not, teleport it to the right z-level. */
/obj/effect/abstract/bluespace_rift/proc/check_z()
	if(isnull(rift_z))
		CRASH("Missing z_level value.")
	if(z != rift_z)
		loc = pick_turf_to_go()

/obj/effect/abstract/bluespace_rift/proc/change_direction()
	target_loc = pick_turf_to_go()

/obj/effect/abstract/bluespace_rift/proc/pick_turf_to_go()

	var/min_x = TRANSITION_BORDER_WEST + 1
	var/max_x = TRANSITION_BORDER_EAST - 1
	var/min_y = TRANSITION_BORDER_SOUTH + 1
	var/max_y = TRANSITION_BORDER_NORTH - 1

	// Pick a random turf, any non-space is acceptable.
	for(var/i in 1 to 50)
		var/rand_x = rand(min_x, max_x)
		var/rand_y = rand(min_y, max_y)

		var/turf/rand_turf = locate(rand_x, rand_y, rift_z)
		if(istype(rand_turf.loc, /area/space))
			continue

		return rand_turf

	// Use a turf with random coordinates if failing to find a station turf.
	var/rand_x = rand(min_x, max_x)
	var/rand_y = rand(min_y, max_y)
	var/rand_turf = locate(rand_x, rand_y, rift_z)
	return rand_turf

/obj/effect/abstract/bluespace_rift/proc/is_target_reached()
	return get_turf(src) == get_turf(target_loc)

/obj/effect/abstract/bluespace_rift/proc/time_till_next_step()
	return time_per_tile

/** The speed of a `hunter` rift depends on how close the target is. */
/obj/effect/abstract/bluespace_rift/hunter

/obj/effect/abstract/bluespace_rift/hunter/change_direction()
	target_loc = pick_mob_to_chase()
	if(!target_loc)
		// Use a random turf if there are no players on the station
		..()

/obj/effect/abstract/bluespace_rift/hunter/time_till_next_step()
	var/dist_to_target = get_dist(src, target_loc)
	var/time_till_next_step = clamp(dist_to_target * 0.5, 2, 20) SECONDS
	return time_till_next_step

/obj/effect/abstract/bluespace_rift/hunter/proc/pick_mob_to_chase()
	var/list/candidate_players = list()

	for(var/mob/player in GLOB.player_list)
		if(player.z != rift_z)
			continue
		if(!isliving(player))
			continue
		if(!player.client)
			continue
		if(player == target_loc)
			continue
		candidate_players += player
	
	if(!length(candidate_players))
		return

	var/rand_player = pick(candidate_players)
	return rand_player
