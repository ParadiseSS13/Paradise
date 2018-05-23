/datum/event/koi_migration
	announceWhen	= 50
	endWhen 		= 900

	var/list/spawned_koi = list()

/datum/event/koi_migration/setup()
	announceWhen = rand(40, 60)
	endWhen = rand(600,1200)

/datum/event/koi_migration/announce()
	var/announcement = ""
	announcement = "Unknown biological [spawned_koi.len == 1 ? "entity has" : "entities have"] been detected near [station_name()], please stand-by."
	event_announcement.Announce(announcement, "Lifesign Alert")

/datum/event/koi_migration/start()
	spawn_fish(landmarks_list.len)

/datum/event/koi_migration/proc/spawn_fish(var/num_groups, var/group_size_min=3, var/group_size_max=5)
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
			var/carptype = /mob/living/simple_animal/hostile/retaliate/carp/koi
			spawned_koi.Add(new carptype(spawn_locations[i]))
		i++

/datum/event/koi_migration/end()
	for(var/mob/living/simple_animal/hostile/retaliate/carp/koi/C in spawned_koi)
		if(!C.stat)
			var/turf/T = get_turf(C)
			if(istype(T, /turf/space))
				qdel(C)
