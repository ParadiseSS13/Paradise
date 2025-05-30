#define RIVER_MAX_X 200
#define RIVER_MAX_Y 200

#define RIVER_MIN_X 50
#define RIVER_MIN_Y 50

#define WARNING_DELAY (4 SECONDS) // the warning time that a warning will be deisplayed before the lava conversion occurs

#define BRIDGE_PROB 2 // the percent probability of a bridge to spawn for every tile forward the river travels

GLOBAL_LIST_EMPTY(river_waypoint_presets)

/obj/effect/landmark/river_waypoint
	name = "river waypoint"
	/// Whether the turf of this landmark has already been linked to others during river generation.
	var/connected = FALSE
	invisibility = INVISIBILITY_ABSTRACT

/// A straightforward system for making "rivers", paths made up of a specific
/// turf type that are generated in a random path on a z-level.
/datum/river_spawner
	/// The z-level to generate the river on. There is theoretically nothing stopping
	/// this from being used across z-levels, but we're keeping things simple.
	var/target_z
	/// The initial probability that a river tile will spread to adjacent tiles.
	var/spread_prob
	/// The amount reduced from spread_prob on every spread iteration to cause falloff.
	var/spread_prob_loss
	/// The base type that makes up the river.
	var/river_turf_type = /turf/simulated/floor/lava/mapping_lava
	/// The area that the spawner is allowed to spread or detour to.
	var/whitelist_area_type = /area/lavaland/surface/outdoors
	/// The type that the spawner is allowed to spread or detour to.
	var/whitelist_turf_type = /turf/simulated/mineral
	/// The turf used when a spread of the tile stops.
	var/shoreline_turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	/// To hold all the found turfs to convert to the lava type
	var/list/collected_turfs = list()
	/// Does the lava generate a warning beforehand
	var/warning
	/// Do we ignore building any bridges?
	var/ignore_bridges

/datum/river_spawner/New(target_z_, spread_prob_ = 25, spread_prob_loss_ = 11)
	target_z = target_z_
	spread_prob = spread_prob_
	spread_prob_loss = spread_prob_loss_

/// Generate a river between the bounds specified by (`min_x`, `min_y`) and
/// (`max_x`, `max_y`).
///
/// `nodes` is the number of unique points in those bounds the river will
/// connect to. Note that `nodes` says little about the resultant size of the
/// river due to its ability to detour far away from the direct path between them.
/// set ignore_bridges TRUE to not spawn any new bridges, and set warning to TRUE to
/// allow for the new generations to have a telegraphed icon first
/datum/river_spawner/proc/generate(nodes = 4, min_x = RIVER_MIN_X, min_y = RIVER_MIN_Y, max_x = RIVER_MAX_X, max_y = RIVER_MAX_Y, ignore_bridges = FALSE, warning = FALSE)
	var/list/river_nodes = list()
	var/num_spawned = 0

	var/list/possible_locs = block(min_x, min_y, target_z, max_x, max_y, target_z)
	while(num_spawned < nodes && length(possible_locs))
		// Random chance of pulling a pre-mapped river waypoint instead.
		if(length(GLOB.river_waypoint_presets) && prob(50))
			var/obj/effect/landmark/river_waypoint/waypoint = pick(GLOB.river_waypoint_presets)
			if(waypoint.z == target_z)
				river_nodes += waypoint
				num_spawned++
				GLOB.river_waypoint_presets -= waypoint
		else
			var/turf/T = pick_n_take(possible_locs)
			var/area/A = get_area(T)
			if(!istype(A, whitelist_area_type) || (T.flags & NO_LAVA_GEN))
				continue
			else
				river_nodes += new /obj/effect/landmark/river_waypoint(T)
				num_spawned++

	//make some randomly pathing rivers
	for(var/A in river_nodes)
		var/obj/effect/landmark/river_waypoint/W = A
		if(W.z != target_z || W.connected)
			continue
		W.connected = TRUE
		var/turf/cur_turf = get_turf(W)
		if(istype(get_area(cur_turf), whitelist_area_type) && !(cur_turf.flags & NO_LAVA_GEN))
			collected_turfs += cur_turf
		else if(ignore_bridges && (cur_turf.flags & LAVA_BRIDGE))
			collected_turfs += cur_turf
		var/turf/target_turf = get_turf(pick(river_nodes - W))
		if(!target_turf)
			break
		var/detouring = 0
		var/cur_dir = get_dir(cur_turf, target_turf)
		while(cur_turf != target_turf)
			var/attempts = 100
			do
				if(detouring) //randomly snake around a bit
					if(prob(20))
						detouring = 0
						cur_dir = get_dir(cur_turf, target_turf)
				else if(prob(20))
					detouring = 1
					if(prob(50))
						cur_dir = turn(cur_dir, 45)
					else
						cur_dir = turn(cur_dir, -45)
				else
					cur_dir = get_dir(cur_turf, target_turf)

			// we may veer off the map entirely, returning a null turf; if so, go back and try again
			while(get_step(cur_turf, cur_dir) == null && attempts-- > 0)

			cur_turf = get_step(cur_turf, cur_dir)
			if(isnull(cur_turf))
				stack_trace("Encountered a null turf in river loop, target turf was [target_turf], x=[target_turf.x], y=[target_turf.y].")
				break
			var/area/new_area = get_area(cur_turf)
			if(!istype(new_area, whitelist_area_type) || (cur_turf.flags & NO_LAVA_GEN)) //Rivers will skip ruins
				detouring = 0
				cur_dir = get_dir(cur_turf, target_turf)
				cur_turf = get_step(cur_turf, cur_dir)
				continue
			else
				collected_turfs += cur_turf

	handle_change(warning, ignore_bridges)

	for(var/WP in river_nodes)
		qdel(WP)

/datum/river_spawner/proc/spread_turf(turf/start_turf, probability = 30, prob_loss = 25, whitelisted_area, ignore_bridges)
	if(probability <= 0)
		return
	var/list/cardinal_turfs = list()
	var/list/diagonal_turfs = list()

	for(var/F in RANGE_TURFS(1, start_turf) - start_turf)
		var/turf/T = F
		var/area/new_area = get_area(T)
		if(!ignore_bridges && (T.flags & LAVA_BRIDGE))
			continue
		else if(!T || (T.density && !istype(T, whitelist_turf_type)) || istype(T, /turf/simulated/floor/indestructible) || (whitelisted_area && !istype(new_area, whitelisted_area)) || (T.flags & NO_LAVA_GEN))
			continue

		if(get_dir(start_turf, F) in GLOB.cardinal)
			cardinal_turfs += F
		else
			diagonal_turfs += F

	for(var/F in cardinal_turfs) //cardinal turfs are always changed but don't always spread
		var/turf/T = F
		if(!istype(T, start_turf.type) && T.ChangeTurf(start_turf.type, ignore_air = TRUE) && prob(probability))
			spread_turf(T, probability - prob_loss, prob_loss, whitelisted_area)

	for(var/F in diagonal_turfs) //diagonal turfs only sometimes change, but will always spread if changed
		var/turf/T = F
		if(!istype(T, shoreline_turf_type) && prob(probability) && T.ChangeTurf(start_turf.type, ignore_air = TRUE))
			spread_turf(T, probability - prob_loss, prob_loss, whitelisted_area)
		else if(istype(T, whitelist_turf_type) && !istype(T, start_turf.type))
			T.ChangeTurf(shoreline_turf_type, ignore_air = TRUE)

/// handles changing the lava turfs, and if it should delay it and place warnings
/datum/river_spawner/proc/handle_change(warning, ignore_bridges)
	var/lava_counter = 0
	for(var/turf/listed_turf in collected_turfs)
		var/affected_turf = get_turf(listed_turf)
		if(warning)
			if(lava_counter++ >= 2)
				new /obj/effect/temp_visual/river_warning(affected_turf)
				lava_counter = 0
			addtimer(CALLBACK(src, PROC_REF(convert_turf), affected_turf), WARNING_DELAY)
		else
			convert_turf(affected_turf, ignore_bridges)

	collected_turfs.Cut()

/// actually convert the turf
/datum/river_spawner/proc/convert_turf(turf/cur_turf, ignore_bridges)
	var/turf/river_turf = cur_turf.ChangeTurf(river_turf_type, ignore_air = TRUE)
	spread_turf(river_turf, spread_prob, spread_prob_loss, whitelist_area_type, ignore_bridges)
	if(prob(BRIDGE_PROB) && !ignore_bridges)
		new /obj/effect/spawner/dynamic_bridge(cur_turf)

/obj/effect/temp_visual/river_warning
	icon = 'icons/effects/96x96.dmi'
	icon_state = "warning"
	layer = BELOW_MOB_LAYER
	duration = WARNING_DELAY
	randomdir = FALSE
	pixel_x = -32
	pixel_y = -32

#undef WARNING_DELAY
#undef BRIDGE_PROB

#undef RIVER_MAX_X
#undef RIVER_MAX_Y

#undef RIVER_MIN_X
#undef RIVER_MIN_Y
