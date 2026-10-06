SUBSYSTEM_DEF(lighting)
	name = "Lighting"
	wait = 2
	init_order = INIT_ORDER_LIGHTING
	flags = SS_TICKER
	offline_implications = "Lighting will no longer update. Shuttle call recommended."
	cpu_display = SS_CPUDISPLAY_HIGH
	var/static/list/sources_queue = list() // List of lighting sources queued for update.
	var/static/list/corners_queue = list() // List of lighting corners queued for update.
	var/static/list/objects_queue = list() // List of lighting objects queued for update.
	/// Goes up by one every light source update. See [/datum/controller/subsystem/lighting/proc/get_update_stamp]
	var/static/update_stamp = 0

/datum/controller/subsystem/lighting/get_stat_details()
	return "L:[length(sources_queue)]|C:[length(corners_queue)]|O:[length(objects_queue)]"

/datum/controller/subsystem/lighting/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["sources_queue"] = length(sources_queue)
	cust["corners_queue"] = length(corners_queue)
	cust["objects_queue"] = length(objects_queue)
	.["custom"] = cust

/datum/controller/subsystem/lighting/Initialize()
	if(!initialized)
		if(GLOB.configuration.general.starlight)
			for(var/I in GLOB.all_areas)
				var/area/A = I
				if(A.dynamic_lighting == DYNAMIC_LIGHTING_IFSTARLIGHT)
					A.luminosity = 0

		create_all_lighting_objects()

	fire(FALSE, TRUE)

/datum/controller/subsystem/lighting/fire(resumed, init_tick_checks)
	MC_SPLIT_TICK_INIT(3)
	if(!init_tick_checks)
		MC_SPLIT_TICK
	var/list/queue = sources_queue
	var/i = 0
	for(i in 1 to length(queue))
		var/datum/light_source/L = queue[i]

		L.update_corners()

		L.needs_update = LIGHTING_NO_UPDATE

		if(init_tick_checks)
			CHECK_TICK
		else if(MC_TICK_CHECK)
			break
	if(i)
		queue.Cut(1, i + 1)
		i = 0

	if(!init_tick_checks)
		MC_SPLIT_TICK

	queue = corners_queue
	for(i in 1 to length(queue))
		var/datum/lighting_corner/C = queue[i]

		C.needs_update = FALSE
		C.update_objects()

		if(init_tick_checks)
			CHECK_TICK
		else if(MC_TICK_CHECK)
			break
	if(i)
		queue.Cut(1, i + 1)
		i = 0


	if(!init_tick_checks)
		MC_SPLIT_TICK

	queue = objects_queue
	for(i in 1 to length(queue))
		var/datum/lighting_object/O = queue[i]

		if(QDELETED(O))
			continue

		O.update()
		O.needs_update = FALSE
		if(init_tick_checks)
			CHECK_TICK
		else if(MC_TICK_CHECK)
			break
	if(i)
		queue.Cut(1, i + 1)


/**
 * Returns a unique number for a light source update to stamp the corners it visits with.
 * Lets update_corners() skip corners it has already seen without building an associative list.
 *
 * Wraps back to 1 before hitting [LIGHTING_MAX_UPDATE_STAMP], and clears every corner's stamp when it does,
 * so an old stamp can never match a new one. The clear is slow, but only happens every ~16.7 million updates.
 */
/datum/controller/subsystem/lighting/proc/get_update_stamp()
	if(++update_stamp < LIGHTING_MAX_UPDATE_STAMP)
		return update_stamp
	// Corners aren't kept in a list, and the linter only allows looping over bare datums, so check the type ourselves
	for(var/datum/thing)
		if(istype(thing, /datum/lighting_corner))
			var/datum/lighting_corner/corner = thing
			corner.update_stamp = 0
	update_stamp = 1
	return update_stamp

/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	..()
