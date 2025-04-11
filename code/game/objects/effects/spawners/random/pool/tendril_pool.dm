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
