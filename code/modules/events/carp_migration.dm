/datum/event/carp_migration
	announceWhen	= 50
	endWhen 		= 900

	var/list/spawned_mobs = list(
    /mob/living/simple_animal/hostile/carp = 95,
    /mob/living/simple_animal/hostile/carp/megacarp = 5)

/datum/event/carp_migration/setup()
	announceWhen = rand(40, 60)
	endWhen = rand(600, 1200)

/datum/event/carp_migration/announce()
	var/announcement = ""
	if(severity == EVENT_LEVEL_MAJOR)
		announcement = "Massive migration of unknown biological entities has been detected near [station_name()], please stand-by."
	else
		announcement = "Unknown biological entities have been detected near [station_name()], please stand-by."
	GLOB.event_announcement.Announce(announcement, "Lifesign Alert")

/datum/event/carp_migration/start()

	if(severity == EVENT_LEVEL_MAJOR)
		spawn_fish(GLOB.landmarks_list.len)
	else if(severity == EVENT_LEVEL_MODERATE)
		spawn_fish(rand(4, 6)) 			//12 to 30 carp, in small groups
	else
		spawn_fish(rand(1, 3), 1, 2)	//1 to 6 carp, alone or in pairs

/datum/event/carp_migration/proc/spawn_fish(num_groups, group_size_min = 3, group_size_max = 5)
	var/list/spawn_locations = list()

	for(var/thing in GLOB.landmarks_list)
		var/obj/effect/landmark/C = thing
		if(C.name == "carpspawn")
			spawn_locations.Add(C.loc)
	spawn_locations = shuffle(spawn_locations)
	num_groups = min(num_groups, spawn_locations.len)

	var/i = 1
	while(i <= num_groups)
		var/group_size = rand(group_size_min, group_size_max)
		for(var/j = 1, j <= group_size, j++)
			var/carptype = pickweight(spawned_mobs)
			new carptype(spawn_locations[i])
		i++
