#define TRAIT_CHANCE_DELTA 25

/obj/effect/spawner/random/maintenance
	name = "Maintenance loot spawner"
	spawn_loot_chance = 65
	spawn_random_offset_max_pixels = 8
	record_spawn = TRUE

/obj/effect/spawner/random/maintenance/Initialize(mapload)
	loot = GLOB.maintenance_loot_tables
	spawn_loot_count = rand(2, 4)
	if(is_station_level(z))
		GLOB.maints_loot_spawns += loc

	if(HAS_TRAIT(SSstation, STATION_TRAIT_EMPTY_MAINT))
		spawn_loot_chance -= TRAIT_CHANCE_DELTA
	else if(HAS_TRAIT(SSstation, STATION_TRAIT_FILLED_MAINT))
		spawn_loot_chance += TRAIT_CHANCE_DELTA

	. = ..()

#undef TRAIT_CHANCE_DELTA
