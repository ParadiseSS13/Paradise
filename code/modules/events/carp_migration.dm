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
		announcement = "Массовая миграция неизвестных биологических объектов была зафиксирована вблизи станции [station_name()], будьте наготове."
	else
		announcement = "Неизвестные биологические объекты были зафиксированы вблизи станции [station_name()], будьте наготове."
	GLOB.minor_announcement.Announce(announcement, "ВНИМАНИЕ: Неопознанные формы жизни.")

/datum/event/carp_migration/start()

	if(severity == EVENT_LEVEL_MAJOR)
		spawn_fish(length(GLOB.landmarks_list))
	else if(severity == EVENT_LEVEL_MODERATE)
		spawn_fish(rand(4, 6)) 			//12 to 30 carp, in small groups
	else
		spawn_fish(rand(1, 3), 1, 2)	//1 to 6 carp, alone or in pairs

/datum/event/carp_migration/proc/spawn_fish(num_groups, group_size_min = 3, group_size_max = 5)
	var/list/spawn_locations = list()

	for(var/thing in GLOB.carplist)
		spawn_locations.Add(get_turf(thing))
	spawn_locations = shuffle(spawn_locations)
	num_groups = min(num_groups, length(spawn_locations))

	var/i = 1
	while(i <= num_groups)
		var/group_size = rand(group_size_min, group_size_max)
		for(var/j = 1, j <= group_size, j++)
			var/carptype = pickweight(spawned_mobs)
			new carptype(spawn_locations[i])
		i++
