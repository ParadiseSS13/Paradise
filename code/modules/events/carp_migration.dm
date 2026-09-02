/datum/event/carp_migration
	name = "Carp Migration"
	announceWhen	= 50
	noAutoEnd = TRUE
	nominal_severity = EVENT_LEVEL_MODERATE
	role_weights = list(ASSIGNMENT_ENGINEERING = 1, ASSIGNMENT_SECURITY = 2)
	role_requirements = list(ASSIGNMENT_ENGINEERING = 1, ASSIGNMENT_SECURITY = 1.5)
	nominal_severity = EVENT_LEVEL_MODERATE
	var/list/spawned_mobs = list(
		/mob/living/basic/carp = 95,
		/mob/living/basic/carp/megacarp = 5)
	/// Carps spawned by the event
	var/list/my_carps = list()
	/// Did we manage to spawn carps
	var/spawned = FALSE

/datum/event/carp_migration/process()
	if(!length(my_carps) && spawned)
		kill()
	return ..()

// Resource calculation independent of event
/datum/event/carp_migration/event_resource_cost()
	return list()

/datum/event/carp_migration/proc/remove_carp(mob/source)
	SIGNAL_HANDLER // COMSIG_MOB_DEATH
	my_carps -= source
	UnregisterSignal(source, COMSIG_MOB_DEATH)

/datum/event/carp_migration/setup()
	announceWhen = rand(40, 60)

/datum/event/carp_migration/announce()
	var/announcement = ""
	if(severity == EVENT_LEVEL_MAJOR)
		announcement = "Massive migration of unknown biological entities has been detected near [station_name()], please stand-by."
	else
		announcement = "Unknown biological entities have been detected near [station_name()], please stand-by."
	GLOB.minor_announcement.Announce(announcement, "Lifesign Alert")

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
			var/mob/carp = new carptype(spawn_locations[i])
			RegisterSignal(carp, COMSIG_MOB_DEATH, PROC_REF(remove_carp))
			my_carps += carp
			spawned = TRUE
		i++
