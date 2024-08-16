/obj/effect/spawner/random/maintenance
	name = "Maintenance loot spawner"
	spawn_loot_chance = 55
	spawn_random_offset_max_pixels = 8

/obj/effect/spawner/random/maintenance/Initialize(mapload)
	loot = GLOB.maintenance_loot_tables
	spawn_loot_count = rand(2, 4)

	if(HAS_TRAIT(SSstation, STATION_TRAIT_EMPTY_MAINT))
		spawn_loot_chance = 30
	else if(HAS_TRAIT(SSstation, STATION_TRAIT_FILLED_MAINT))
		spawn_loot_chance = 80

	. = ..()
