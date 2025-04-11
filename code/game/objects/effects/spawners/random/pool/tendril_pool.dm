/datum/spawn_pool/tendrils
	id = "lavaland_tendril_spawn_pool"

/datum/spawn_pool/tendrils/New()
	. = ..()
	available_points = roll("5d4") + roll("1d6")

/obj/effect/spawner/random/pool/tendril_spawner
	spawn_pool_id = "lavaland_tendril_spawn_pool"
	point_value = 1
	loot = list(
		/obj/structure/spawner/lavaland,
		/obj/structure/spawner/lavaland/goliath,
		/obj/structure/spawner/lavaland/legion,
	)
	record_spawn = TRUE

/obj/effect/spawner/random/pool/tendril_spawner/record_item(type_path_to_make)
	if(ispath(type_path_to_make, /obj/effect))
		return

	SSblackbox.record_feedback("tally", "lavaland_mob_spawns", 1, "[type_path_to_make]")

/obj/effect/spawner/random/pool/tendril_spawner/check_safe(type_path_to_make)
	var/turf/T = get_turf(src)
	for(var/thing in urange(10, T))
		// prevents tendrils spawning in each other's collapse range
		if(istype(thing, /obj/structure/spawner/lavaland) && get_dist(T, thing) <= LAVALAND_TENDRIL_COLLAPSE_RANGE)
			return FALSE

	return ..()
