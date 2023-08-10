/datum/bluespace_rift
	var/name = "Блюспейс Разлом"
	var/effect_type = /obj/effect/abstract/bluespace_rift
	var/rift_count = 1
	var/rift_size = 5
	var/time_per_tile = 10 SECONDS

	var/goal_uid
	var/list/rift_objects
	var/datum/brs_event_container/events

	var/times_rift_scanned = 0
	var/events_mined = 0

/datum/bluespace_rift/New(goal_uid)
	..()
	if(isnull(goal_uid))
		CRASH("Missing argument goal_uid")

	src.goal_uid = goal_uid

	rift_objects = list()
	for(var/i in 1 to rift_count)
		var/new_rift_obj = new effect_type(null, rift_size, time_per_tile)
		rift_objects += new_rift_obj

	events = new /datum/brs_event_container/normal(rift = src)

	GLOB.bluespace_rifts_list |= src

	START_PROCESSING(SSprocessing, src)

/datum/bluespace_rift/Destroy()
	GLOB.bluespace_rifts_list.Remove(src)
	STOP_PROCESSING(SSprocessing, src)
	QDEL_LIST(rift_objects)
	QDEL_NULL(events)
	return ..()

/datum/bluespace_rift/process()

	// Process rift objects
	for(var/obj/effect/abstract/bluespace_rift/rift as anything in rift_objects)
		rift.move()
	
	// Process events

	// Spawn events only when they are scanning
	if(!times_rift_scanned)
		return

	// Update event probability
	events.cumulative_event_expectancy += events_mined * (1 + (2 * log(times_rift_scanned)))

	times_rift_scanned = 0
	events_mined = 0
	
	// Process events spawn 
	events.process()

/datum/bluespace_rift/proc/probe(successful = FALSE)
	if(!successful)
		events.start_event()
		return

	var/picked_rift_obj = pick(rift_objects)
	new /obj/effect/spawner/lootdrop/bluespace_rift(get_turf(picked_rift_obj))

/datum/bluespace_rift/proc/spawn_reward()
	var/picked_rift_obj = pick(rift_objects)
	new /obj/effect/spawner/lootdrop/bluespace_rift/goal_complete(get_turf(picked_rift_obj))

/datum/bluespace_rift/big
	name = "Большой Блюспейс Разлом"
	rift_count = 1
	rift_size = 7
	time_per_tile = 14 SECONDS

/datum/bluespace_rift/fog
	name = "Блюспейс Туманность"
	rift_count = 1
	rift_size = 9
	time_per_tile = 18 SECONDS

/datum/bluespace_rift/twin
	name = "Разлом-Близнец"
	rift_count = 2
	rift_size = 3
	time_per_tile = 8 SECONDS

/datum/bluespace_rift/crack
	name = "Блюспейс Трещина"
	rift_count = 5
	rift_size = 1
	time_per_tile = 6 SECONDS

/datum/bluespace_rift/hunter
	name = "Разлом-Охотник"
	effect_type = /obj/effect/abstract/bluespace_rift/hunter
	rift_count = 1
	rift_size = 3
