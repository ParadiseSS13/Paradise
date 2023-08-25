#define ASSIGNMENT_ANY "Any"
#define ASSIGNMENT_AI "AI"
#define ASSIGNMENT_CYBORG "Cyborg"
#define ASSIGNMENT_ENGINEER "Engineer"
#define ASSIGNMENT_BOTANIST "Botanist"
#define ASSIGNMENT_JANITOR "Janitor"
#define ASSIGNMENT_MEDICAL "Medical"
#define ASSIGNMENT_SCIENTIST "Scientist"
#define ASSIGNMENT_SECURITY "Security"

#define ONE_EVENT 10000 //! 1 event in `cumulative_event_expectancy` units.
#define MAX_EVENTS_PER_CHECK (ONE_EVENT * 6)

#define MAX_RIFT_EVENT_RANGE 5
#define RIFT_EVENT_RANGE(rift_size) min(rift_size * 2, MAX_RIFT_EVENT_RANGE)

/datum/brs_event_container

	var/datum/bluespace_rift/rift
	var/list/available_events

	/// Expected number of events, in 0.0001 (adding 10 000 means adding 1 event, to not mess with really small fractions).
	var/cumulative_event_expectancy = 0
	/// How often this should be processed
	var/time_between_checks = 1 MINUTES

	var/last_check = 0

/datum/brs_event_container/New(datum/bluespace_rift/rift)
	. = ..()
	src.rift = rift

/datum/brs_event_container/process()
	if(world.time < (last_check + time_between_checks))
		return

	if(cumulative_event_expectancy == 0)
		last_check = world.time
		return
	
	if(cumulative_event_expectancy > MAX_EVENTS_PER_CHECK)
		cumulative_event_expectancy = MAX_EVENTS_PER_CHECK

	// More than one event expected
	while(cumulative_event_expectancy >= ONE_EVENT)
		cumulative_event_expectancy -= ONE_EVENT
		start_event()
	
	// Less than one event expected
	if(cumulative_event_expectancy > 0)
		if(rand(ONE_EVENT) < cumulative_event_expectancy)
			start_event()
			cumulative_event_expectancy = 0

	last_check = world.time

/** Immediately spawns one random event. */
/datum/brs_event_container/proc/start_event()

	var/datum/event_meta/picked_event_meta = pick_event()
	if(!picked_event_meta)
		return

	// Just to be sure. This prevents the event from being added to the the round's random event pool.
	picked_event_meta.severity = EVENT_LEVEL_NONE

	if(istype(picked_event_meta, /datum/event_meta/bluespace_rift_event_meta))
		var/datum/event_meta/bluespace_rift_event_meta/t_meta = picked_event_meta
		t_meta.rift = rift
	
	new picked_event_meta.event_type(picked_event_meta)

/datum/brs_event_container/proc/pick_event()
	if(!length(available_events))
		return
	var/list/possible_events = list()
	var/active_with_role = number_active_with_role()
	for(var/datum/event_meta/event_meta as anything in available_events)
		var/event_weight = event_meta.get_weight(active_with_role)
		if(event_meta.enabled && event_weight)
			possible_events[event_meta] = event_weight
	
	var/picked_event_meta = pickweight(possible_events)
	return picked_event_meta

/datum/brs_event_container/normal
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_NONE, "Атмосферная аномалия",		/datum/event/anomaly/anomaly_pyro,		60),
		new /datum/event_meta(EVENT_LEVEL_NONE, "Вортекс-аномалия",			/datum/event/anomaly/anomaly_vortex,	60),
		new /datum/event_meta(EVENT_LEVEL_NONE, "Блюспейс-аномалия",		/datum/event/anomaly/anomaly_bluespace,	60),
		new /datum/event_meta(EVENT_LEVEL_NONE, "Флюкс-аномалия",			/datum/event/anomaly/anomaly_flux,		60),
		new /datum/event_meta(EVENT_LEVEL_NONE, "Гравитационная аномалия",	/datum/event/anomaly/anomaly_grav,		60),

		new /datum/event_meta/bluespace_rift_event_meta(EVENT_LEVEL_NONE, "Телепортация живых",			/datum/event/bluespace_rift_event/teleport_living,							500),
		new /datum/event_meta/bluespace_rift_event_meta(EVENT_LEVEL_NONE, "Поменять местами живых",		/datum/event/bluespace_rift_event/teleport_living/shuffle,					500),
		new /datum/event_meta/bluespace_rift_event_meta(EVENT_LEVEL_NONE, "Телепортация живых далеко",	/datum/event/bluespace_rift_event/teleport_living/within_z,					500),

		new /datum/event_meta/bluespace_rift_event_meta(EVENT_LEVEL_NONE, "Взрывы",						/datum/event/bluespace_rift_event/explosions,								200),
		new /datum/event_meta/bluespace_rift_event_meta(EVENT_LEVEL_NONE, "ЭМИ",						/datum/event/bluespace_rift_event/explosions/em_pulses,						300),
		new /datum/event_meta/bluespace_rift_event_meta(EVENT_LEVEL_NONE, "Вспышки",					/datum/event/bluespace_rift_event/explosions/flashes,						400),
		new /datum/event_meta/bluespace_rift_event_meta(EVENT_LEVEL_NONE, "Дым",						/datum/event/bluespace_rift_event/explosions/smoke,							400),
		new /datum/event_meta/bluespace_rift_event_meta(EVENT_LEVEL_NONE, "Искры",						/datum/event/bluespace_rift_event/explosions/sparks,						500),

		new /datum/event_meta/bluespace_rift_event_meta(EVENT_LEVEL_NONE, "Химические взрывы",			/datum/event/bluespace_rift_event/explosions/random_chem_effect,			100),
		new /datum/event_meta/bluespace_rift_event_meta(EVENT_LEVEL_NONE, "Опасные химические взрывы",	/datum/event/bluespace_rift_event/explosions/random_chem_effect/dangerous,	100),
		new /datum/event_meta/bluespace_rift_event_meta(EVENT_LEVEL_NONE, "Клоунские химические взрывы",/datum/event/bluespace_rift_event/explosions/random_chem_effect/funny,		100),
		new /datum/event_meta/bluespace_rift_event_meta(EVENT_LEVEL_NONE, "Испачкать пол",				/datum/event/bluespace_rift_event/explosions/random_chem_effect/dirt,		100),

		new /datum/event_meta/bluespace_rift_event_meta(EVENT_LEVEL_NONE, "Снег",						/datum/event/bluespace_rift_event/snow,										200),
	)

/**
*	event_meta for bluespace rift events. Keeps a reference to the rift. 
*/
/datum/event_meta/bluespace_rift_event_meta
	var/datum/bluespace_rift/rift

/** 
*	Base class.
*	Event that affects things in the area around the rift. Should use bluespace_rift_event_meta.
*/
/datum/event/bluespace_rift_event
	// Rift objects in the range of which the event will go
	var/list/obj/effect/abstract/bluespace_rift/rift_objects

/datum/event/bluespace_rift_event/setup()
	pick_rift_objects()

/datum/event/bluespace_rift_event/proc/pick_rift_objects()
	rift_objects = list()

	if(!istype(event_meta, /datum/event_meta/bluespace_rift_event_meta))
		return

	var/datum/event_meta/bluespace_rift_event_meta/t_meta = event_meta
	if(!length(t_meta.rift.rift_objects))
		return

	for(var/obj/effect/abstract/bluespace_rift/rift_obj as anything in t_meta.rift.rift_objects)
		if(rift_obj.is_close_to_singularity())
			// Don't blow up the engine area
			continue
		rift_objects += rift_obj

// The class is not supposed to have any instances, but let's add something funny just in case it does.
/datum/event/bluespace_rift_event/start()
	for(var/rift_obj in rift_objects)
		playsound(rift_obj, 'sound/misc/sadtrombone.ogg', 100)

/datum/event/bluespace_rift_event/end()
	// Since it appears that SSevents keeps references to all ended events,
	// these might interfere with the deletion of the rift.
	rift_objects = null
	var/datum/event_meta/bluespace_rift_event_meta/t_meta = event_meta
	t_meta.rift = null

/** 
*	Teleports random mobs around the rift not too far from where they were. 
*/
/datum/event/bluespace_rift_event/teleport_living
	// min/max objects that will be chosen to teleport
	var/max_num_objects = 30
	var/min_num_objects = 5

	// How far the objects can be teleported
	var/teleport_radius = 6

	var/list/objects_in_range
	var/num_objects_to_teleport

/datum/event/bluespace_rift_event/teleport_living/setup()
	..()

	// Get objects in range
	objects_in_range = list()
	for(var/obj/effect/abstract/bluespace_rift/rift_obj as anything in rift_objects)
		for(var/mob/living/mob in range(RIFT_EVENT_RANGE(rift_obj.size), rift_obj))
			objects_in_range |= mob
	
	// Set the number of objects that will be teleported
	min_num_objects = min(min_num_objects, length(objects_in_range))
	max_num_objects = min(max_num_objects, length(objects_in_range))
	num_objects_to_teleport = rand(min_num_objects, max_num_objects)

/datum/event/bluespace_rift_event/teleport_living/start()
	for(var/i in 1 to num_objects_to_teleport)
		var/mob = pick_n_take(objects_in_range)
		do_teleport(mob, mob, teleport_radius)

/datum/event/bluespace_rift_event/teleport_living/end()
	..()
	objects_in_range = null

/** 
*	Makes random mobs around the rift switch their places.
*/
/datum/event/bluespace_rift_event/teleport_living/shuffle

/datum/event/bluespace_rift_event/teleport_living/shuffle/start()
	if(num_objects_to_teleport < 2)
		return
	for(var/i in 1 to FLOOR(num_objects_to_teleport / 2, 1))
		var/mob1 = pick_n_take(objects_in_range)
		var/mob2 = pick_n_take(objects_in_range)
		var/mob1_was_here = get_turf(mob1)
		do_teleport(mob1, mob2)
		do_teleport(mob2, mob1_was_here)

/** 
*	Teleports random mobs around the rift not too far from where they were. 
*/
/datum/event/bluespace_rift_event/teleport_living/within_z

/datum/event/bluespace_rift_event/teleport_living/within_z/start()
	var/rift_z = length(rift_objects) ? rift_objects[1].z : null
	if(isnull(rift_z))
		return
	for(var/i in 1 to num_objects_to_teleport)
		var/mob = pick_n_take(objects_in_range)
		var/turf = find_safe_turf(rift_z)
		if(!turf)
			return
		do_teleport(mob, turf)

/** 
*	Random number of explosions around the rift. 
*/
/datum/event/bluespace_rift_event/explosions
	// min/max total number of explosions
	var/max_explosions = 6
	var/min_explosions = 2

	// min/max explosion radius in tiles
	var/max_explosion_radius = 3
	var/min_explosion_radius = 1

	var/list/turf/turfs_in_range
	var/num_explosions

/datum/event/bluespace_rift_event/explosions/setup()
	..()

	// Get turfs in range
	turfs_in_range = list()
	for(var/obj/effect/abstract/bluespace_rift/rift_obj as anything in rift_objects)
		turfs_in_range |= RANGE_TURFS(RIFT_EVENT_RANGE(rift_obj.size), rift_obj)
	// Set the number of explosions
	min_explosions = min(min_explosions, length(turfs_in_range))
	max_explosions = min(max_explosions, length(turfs_in_range))
	num_explosions = rand(min_explosions, max_explosions)

/datum/event/bluespace_rift_event/explosions/start()
	for(var/i in 1 to num_explosions)
		var/radius = rand(min_explosion_radius, max_explosion_radius)
		var/epicenter = pick_n_take(turfs_in_range)
		explosion(
			epicenter, 
			light_impact_range = radius,
			flash_range = radius, 
			flame_range =  radius, 
			cause = "Bluespace rift event \"[event_meta.name]\""
		)

/datum/event/bluespace_rift_event/explosions/end()
	..()
	turfs_in_range = null

/** 
*	Random number of em pulses around the rift. 
*/
/datum/event/bluespace_rift_event/explosions/em_pulses

/datum/event/bluespace_rift_event/explosions/em_pulses/start()
	for(var/i in 1 to num_explosions)
		var/radius = rand(min_explosion_radius, max_explosion_radius)
		var/epicenter = pick_n_take(turfs_in_range)
		empulse(
			epicenter, 
			heavy_range = radius,
			light_range = radius, 
			log =  TRUE, 
			cause = "Bluespace rift event \"[event_meta.name]\""
		)

/** 
*	Random number of flashes around the rift.
*/
/datum/event/bluespace_rift_event/explosions/flashes
	max_explosion_radius = 6
	min_explosion_radius = 3

/datum/event/bluespace_rift_event/explosions/flashes/start()
	for(var/i in 1 to num_explosions)
		var/radius = rand(min_explosion_radius, max_explosion_radius)
		var/epicenter = pick_n_take(turfs_in_range)
		playsound(epicenter, 'sound/effects/bang.ogg', 100, TRUE)
		bang(
			epicenter,
			epicenter,
			range = radius
		)

/** 
*	Random number of smoke clouds around the rift.
*/
/datum/event/bluespace_rift_event/explosions/smoke

/datum/event/bluespace_rift_event/explosions/smoke/start()
	for(var/i in 1 to num_explosions)
		var/epicenter = pick_n_take(turfs_in_range)
		playsound(epicenter, 'sound/effects/smoke.ogg', 50, TRUE)
		new /obj/effect/particle_effect/smoke/bad(epicenter)

/** 
*	Random number of sparks around the rift.
*/
/datum/event/bluespace_rift_event/explosions/sparks
	max_explosions = 8
	min_explosions = 4

	var/max_number = 9
	var/min_number = 3

/datum/event/bluespace_rift_event/explosions/sparks/start()
	for(var/i in 1 to num_explosions)
		var/number_of_sparks = rand(min_number, max_number)
		var/epicenter = pick_n_take(turfs_in_range)
		do_sparks(number_of_sparks, FALSE, epicenter)

/** 
*	Random number of random chemical effects around the rift.
*/
/datum/event/bluespace_rift_event/explosions/random_chem_effect
	var/list/grenade_types = list(
		/obj/item/grenade/chem_grenade/meat,
		/obj/item/grenade/chem_grenade/holywater,
		/obj/item/grenade/chem_grenade/hellwater,
		/obj/item/grenade/chem_grenade/drugs,
		/obj/item/grenade/chem_grenade/ethanol,
		/obj/item/grenade/chem_grenade/lube,
		/obj/item/grenade/chem_grenade/metalfoam,
		/obj/item/grenade/chem_grenade/firefighting,
		/obj/item/grenade/chem_grenade/antiweed,
		/obj/item/grenade/chem_grenade/cleaner,
	)

/datum/event/bluespace_rift_event/explosions/random_chem_effect/start()
	// Spawn a random grenade and immediately detonate it. I'm not making those effects from scratch.
	var/grenade_type = pick(grenade_types)

	for(var/i in 1 to num_explosions)
		var/epicenter = pick_n_take(turfs_in_range)
		var/obj/item/grenade/grenade = new grenade_type(epicenter)
		INVOKE_ASYNC(grenade, TYPE_PROC_REF(/obj/item/grenade, prime))

/datum/event/bluespace_rift_event/explosions/random_chem_effect/end()
	..()
	grenade_types = null

/** 
*	Random chemical effects that could harm.
*/
/datum/event/bluespace_rift_event/explosions/random_chem_effect/dangerous
	grenade_types = list(
		/obj/item/grenade/chem_grenade/incendiary,
		/obj/item/grenade/chem_grenade/teargas,
		/obj/item/grenade/chem_grenade/facid,
		/obj/item/grenade/chem_grenade/large/monster,
		/obj/item/grenade/gas/knockout,
		/obj/item/grenade/gluon,
	)

/** 
*	Random chemical effects that could be clownish.
*/
/datum/event/bluespace_rift_event/explosions/random_chem_effect/funny
	grenade_types = list(
		/obj/item/grenade/confetti,
		/obj/item/grenade/clown_grenade,
		/obj/item/grenade/bananade,
	)

/** 
*	Just makes floors dirty.
*/
/datum/event/bluespace_rift_event/explosions/random_chem_effect/dirt
	grenade_types = list(
		/obj/item/grenade/chem_grenade/dirt,
	)

/** 
*	Covers the area around the rift with snow.
*/
/datum/event/bluespace_rift_event/snow
	var/list/turf/turfs_in_range

/datum/event/bluespace_rift_event/snow/setup()
	..()
	// Get turfs in range
	turfs_in_range = list()
	for(var/obj/effect/abstract/bluespace_rift/rift_obj as anything in rift_objects)
		turfs_in_range |= RANGE_TURFS(RIFT_EVENT_RANGE(rift_obj.size), rift_obj)

/datum/event/bluespace_rift_event/snow/start()

	for(var/turf/turf as anything in turfs_in_range)
		if(isspaceturf(turf))
			continue
		if(turf.density)
			continue
		if(!issimulatedturf(turf))
			continue

		var/turf/simulated/t_turf = turf

		t_turf.air.temperature = T0C - 1
		t_turf.air_update_turf()

		if(locate(/obj/effect/snowcloud, t_turf))
			continue
		new /obj/effect/snow(t_turf)
		
/datum/event/bluespace_rift_event/snow/end()
	..()
	turfs_in_range = null

#undef MAX_RIFT_EVENT_RANGE
#undef RIFT_EVENT_RANGE

#undef ONE_EVENT
#undef MAX_EVENTS_PER_CHECK

#undef ASSIGNMENT_ANY
#undef ASSIGNMENT_AI
#undef ASSIGNMENT_CYBORG
#undef ASSIGNMENT_ENGINEER
#undef ASSIGNMENT_BOTANIST
#undef ASSIGNMENT_JANITOR
#undef ASSIGNMENT_MEDICAL
#undef ASSIGNMENT_SCIENTIST
#undef ASSIGNMENT_SECURITY
