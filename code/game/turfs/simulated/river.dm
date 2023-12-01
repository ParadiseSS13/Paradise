#define RANDOM_UPPER_X 200
#define RANDOM_UPPER_Y 200

#define RANDOM_LOWER_X 50
#define RANDOM_LOWER_Y 50

/proc/spawn_rivers(target_z, nodes = 4, turf_type = /turf/simulated/floor/plating/lava/smooth/mapping_lava, whitelist_area = /area/lavaland/surface/outdoors, min_x = RANDOM_LOWER_X, min_y = RANDOM_LOWER_Y, max_x = RANDOM_UPPER_X, max_y = RANDOM_UPPER_Y, prob = 25, prob_loss = 11)
	var/list/river_nodes = list()
	var/num_spawned = 0
	var/list/possible_locs = block(locate(min_x, min_y, target_z), locate(max_x, max_y, target_z))
	while(num_spawned < nodes && possible_locs.len)
		var/turf/T = pick(possible_locs)
		var/area/A = get_area(T)
		if(!istype(A, whitelist_area) || (T.flags & NO_LAVA_GEN))
			possible_locs -= T
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
		cur_turf.ChangeTurf(turf_type, ignore_air = TRUE)
		var/turf/target_turf = get_turf(pick(river_nodes - W))
		if(!target_turf)
			break
		var/detouring = 0
		var/cur_dir = get_dir(cur_turf, target_turf)
		while(cur_turf != target_turf)

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

			cur_turf = get_step(cur_turf, cur_dir)
			if(isnull(cur_turf)) //This might be the fuck up. Kill the loop if this happens
				stack_trace("Encountered a null turf in river loop, target turf was [target_turf], x=[target_turf.x], y=[target_turf.y].")
				break
			var/area/new_area = get_area(cur_turf)
			if(!istype(new_area, whitelist_area) || (cur_turf.flags & NO_LAVA_GEN)) //Rivers will skip ruins
				detouring = 0
				cur_dir = get_dir(cur_turf, target_turf)
				cur_turf = get_step(cur_turf, cur_dir)
				continue
			else
				var/turf/river_turf = cur_turf.ChangeTurf(turf_type, ignore_air = TRUE)
				if(prob(1))
					new /obj/effect/spawner/bridge(river_turf)
				river_turf.Spread(prob, prob_loss, whitelist_area)

	for(var/WP in river_nodes)
		qdel(WP)


/obj/effect/landmark/river_waypoint
	name = "river waypoint"
	var/connected = FALSE
	invisibility = INVISIBILITY_ABSTRACT


/turf/proc/Spread(probability = 30, prob_loss = 25, whitelisted_area)
	if(probability <= 0)
		return
	var/list/cardinal_turfs = list()
	var/list/diagonal_turfs = list()
	var/logged_turf_type
	for(var/F in RANGE_TURFS(1, src) - src)
		var/turf/T = F
		var/area/new_area = get_area(T)
		if(!T || (T.density && !ismineralturf(T)) || istype(T, /turf/simulated/floor/indestructible) || (whitelisted_area && !istype(new_area, whitelisted_area)) || (T.flags & NO_LAVA_GEN))
			continue

		if(!logged_turf_type && ismineralturf(T))
			var/turf/simulated/mineral/M = T
			logged_turf_type = M.turf_type

		if(get_dir(src, F) in GLOB.cardinal)
			cardinal_turfs += F
		else
			diagonal_turfs += F

	for(var/F in cardinal_turfs) //cardinal turfs are always changed but don't always spread
		var/turf/T = F
		if(!istype(T, logged_turf_type) && T.ChangeTurf(type, ignore_air = TRUE) && prob(probability))
			T.Spread(probability - prob_loss, prob_loss, whitelisted_area)
			if(prob(1))
				new /obj/effect/spawner/bridge(T)

	for(var/F in diagonal_turfs) //diagonal turfs only sometimes change, but will always spread if changed
		var/turf/T = F
		if(!istype(T, logged_turf_type) && prob(probability) && T.ChangeTurf(type, ignore_air = TRUE))
			T.Spread(probability - prob_loss, prob_loss, whitelisted_area)
		else if(ismineralturf(T))
			var/turf/simulated/mineral/M = T
			M.ChangeTurf(M.turf_type, ignore_air = TRUE)
			if(prob(1))
				new /obj/effect/spawner/bridge(M)


#undef RANDOM_UPPER_X
#undef RANDOM_UPPER_Y

#undef RANDOM_LOWER_X
#undef RANDOM_LOWER_Y
