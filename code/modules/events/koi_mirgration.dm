/datum/event/carp_migration
	spawned_mobs = list(
    /mob/living/simple_animal/hostile/retaliate/carp/koi = 95,
    /mob/living/simple_animal/hostile/retaliate/carp/koi/honk = 2,
	)


/datum/event/carp_migration/koi/start()
	spawn_fish(landmarks_list.len)

/datum/event/carp_migration/koi/spawn_fish(var/num_groups, var/group_size_min=3, var/group_size_max=5)
	var/list/spawn_locations = list()

	for(var/obj/effect/landmark/C in landmarks_list)
		if(C.name == "carpspawn")
			spawn_locations.Add(C.loc)
	spawn_locations = shuffle(spawn_locations)
	num_groups = min(num_groups, spawn_locations.len)

	var/i = 1
	while(i <= num_groups)
		var/group_size = rand(group_size_min, group_size_max)
		for(var/j = 1, j <= group_size, j++)
			var/carptype = pickweight(spawned_mobs)
			spawned_carp.Add(new carptype(spawn_locations[i]))
		i++

/datum/event/carp_migration/koi/end()
	for(var/mob/living/simple_animal/hostile/retaliate/carp/koi/C in spawned_carp)
		if(!C.stat)
			var/turf/T = get_turf(C)
			if(istype(T, /turf/space))
				qdel(C)
