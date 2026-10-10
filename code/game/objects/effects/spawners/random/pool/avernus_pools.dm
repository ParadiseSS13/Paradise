/datum/spawn_pool/avernus_deepmaints_power
	available_points = 1

/obj/effect/spawner/random/pool/avernus_deepmaints_power
	spawn_pool = /datum/spawn_pool/avernus_deepmaints_power
	unique_picks = TRUE
	guaranteed = TRUE
	point_value = 1
	record_spawn = TRUE
	loot = list(
		/obj/machinery/power/apc/autoattach/deepmaints,
	)

/obj/effect/spawner/random/pool/avernus_deepmaints_power/record_item(type_path_to_make)
	if(ispath(type_path_to_make, /obj/effect))
		return

	SSblackbox.record_feedback("tally", "avernus_lootpools", 1, "[type_path_to_make]")
