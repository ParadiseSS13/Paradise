/obj/structure/flock/rift
	name = "glowing portal thingymabob"
	desc = "That doesn't look human."
	flock_desc = "The rift through which your Flock will enter this world."
	flock_id = "Entry Rift"
	icon_state = "rift"

	density = FALSE
	max_integrity = 200

	build_time = 10 SECONDS
	no_flock_decon = TRUE

/obj/structure/flock/rift/update_info_tag()
	info_tag.set_text("Entry Time: [build_time_left()] seconds")

/obj/structure/flock/rift/finish_building()
	. = ..()

	for(var/i in 1 to 4)
		new /obj/structure/flock/egg(src, flock)

	// 1 flockbit
	new /obj/structure/flock/egg/bit(src, flock)

	var/list/convertable_turfs = list()
	for(var/turf/open/floor/T in RANGE_TURFS(2, src))
		if(!isflockturf(T) && T.can_flock_convert())
			convertable_turfs += T

	shuffle_inplace(convertable_turfs)
	convertable_turfs.len = min(convertable_turfs.len, 12)

	// Convert turfs
	for(var/turf/open/floor/T as anything in convertable_turfs)
		if(flock)
			flock.claim_turf(T)
		else
			flock_convert_turf(T)

	// Spawn sentinels
	var/sentinel_count = 0
	for(var/turf/simulated/floor/flock/T in convertable_turfs)
		if(!T.can_flock_occupy())
			continue

		new /obj/structure/flock/sentinel(T, flock)
		sentinel_count++
		if(sentinel_count == 2)
			break

	// Spread contents
	var/turf/turfloc = get_turf(src)
	for(var/atom/movable/AM as anything in src)
		AM.forceMove(turfloc)
		AM.throw_at(get_random_perimeter_turf(turfloc, 10), 10, 3, spin = FALSE)

	qdel(src)
