#define RANDOM_UPPER_X 200
#define RANDOM_UPPER_Y 200

#define RANDOM_LOWER_X 50
#define RANDOM_LOWER_Y 50

/proc/spawn_rivers(target_z = 5, nodes = 4, turf_type = /turf/simulated/floor/plating/airless/lavaland, whitelist_area = /area/lavaland/surface/outdoors, min_x = RANDOM_LOWER_X, min_y = RANDOM_LOWER_Y, max_x = RANDOM_UPPER_X, max_y = RANDOM_UPPER_Y)
	var/list/river_nodes = list()
	var/num_spawned = 0
	var/sanity = 100 //how many times we will try again if we hit a protected area
	while(num_spawned < nodes)
		var/turf/F = locate(rand(min_x, max_x), rand(min_y, max_y), target_z)
		if(sanity)
			var/area/A = get_area(F)
			if(!istype(A, whitelist_area) || A.mapgen_protected)
				sanity--
				continue
		river_nodes += new /obj/effect/landmark/river_waypoint(F)
		num_spawned++

	//make some randomly pathing rivers
	for(var/A in river_nodes)
		var/obj/effect/landmark/river_waypoint/W = A
		if (W.z != target_z || W.connected)
			continue
		W.connected = 1
		var/turf/cur_turf = new turf_type(get_turf(W))
		//cur_turf.ChangeTurf(turf_type)
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
			var/area/new_area = get_area(cur_turf)
			if(!istype(new_area, whitelist_area) || new_area.mapgen_protected) //Rivers will skip ruins
				detouring = 0
				cur_dir = get_dir(cur_turf, target_turf)
				cur_turf = get_step(cur_turf, cur_dir)
				continue
			else
				var/turf/open/river_turf = new turf_type(cur_turf)
				river_turf.Spread(30, 25, whitelist_area)

	for(var/WP in river_nodes)
		qdel(WP)


/obj/effect/landmark/river_waypoint
	name = "river waypoint"
	var/connected = 0
	invisibility = INVISIBILITY_ABSTRACT


/turf/proc/Spread(probability = 30, prob_loss = 25, whitelist_area)
	if(probability <= 0)
		return

	for(var/turf/F in orange(1, src))
		var/area/A = get_area(F)
		if((whitelist_area && !istype(A, whitelist_area)) || A.mapgen_protected)
			continue
		if(!F.density || istype(F, /turf/closed/mineral))
			var/turf/L = new src.type(F)

			if(L && prob(probability))
				L.Spread(probability - prob_loss)


#undef RANDOM_UPPER_X
#undef RANDOM_UPPER_Y

#undef RANDOM_LOWER_X
#undef RANDOM_LOWER_Y
